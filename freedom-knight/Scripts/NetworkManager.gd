## ============================================================
##  NetworkManager.gd  — Freedom Knight LAN Multiplayer Core
##  Autoload singleton. LAN-only, ENet + UDP discovery.
##  Host = authoritative server. Clients = input senders.
## ============================================================
extends Node

# ─────────────────────────────────────────────────────────────
#  CONSTANTS
# ─────────────────────────────────────────────────────────────
const GAME_PORT      : int    = 8910
const BROADCAST_PORT : int    = 8911
const MAX_PLAYERS    : int    = 4
const BROADCAST_INTERVAL_FRAMES : int = 60  # ~1s at 60fps
const DISCOVERY_TIMEOUT_SEC  : float = 0.5  # Remove host after X sec of silence
const PROTOCOL_HEADER : String = "FK_LAN_v2:"

# ─────────────────────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────────────────────
signal host_discovered(host_info: Dictionary)    # {ip, gamertag, player_count, max_players}
signal host_lost(ip: String)                      # A host timed out
signal host_list_updated                          # Any change to known_hosts
signal player_registered(peer_id: int, gamertag: String)
signal player_unregistered(peer_id: int)
signal all_players_ready                          # Emitido cuando host tiene >= 1 cliente listo
signal game_start_requested                       # Host fired start
signal connection_succeeded                       # Client connected OK
signal connection_failed                          # Client failed
signal server_disconnected_signal                 # Server went away

# ─────────────────────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────────────────────
var peer: ENetMultiplayerPeer = null
var is_host: bool = false
var game_running: bool = false
var _velocidad_hasta: Dictionary = {}

func conceder_pocion_velocidad(peer_id: int, duracion: float) -> bool:
	if is_multiplayer_active() and not is_server():
		return false
	var ahora = Time.get_ticks_msec()
	if ahora < int(_velocidad_hasta.get(peer_id, 0)):
		return false
	var segundos = clampf(duracion, 0.1, 30.0)
	_velocidad_hasta[peer_id] = ahora + int(segundos * 1000)
	if peer_id == get_my_peer_id():
		_aplicar_pocion_velocidad(segundos)
	else:
		rpc_pocion_velocidad.rpc_id(peer_id, segundos)
	return true

@rpc("authority", "reliable")
func rpc_pocion_velocidad(duracion: float) -> void:
	_aplicar_pocion_velocidad(duracion)

func _aplicar_pocion_velocidad(duracion: float) -> void:
	var jugador = PlayerRegistry.get_local_player()
	if is_instance_valid(jugador) and jugador.has_method("activar_pocion_velocidad"):
		jugador.activar_pocion_velocidad(duracion)

## peer_id → { gamertag:String, ready:bool, alive:bool }
var players: Dictionary = {}

## ip → { gamertag:String, player_count:int, max_players:int, last_seen:float }
var known_hosts: Dictionary = {}

# UDP sockets
var _udp_broadcaster : PacketPeerUDP = null
var _udp_listener    : PacketPeerUDP = null

var _is_discovering  : bool = false

# ─────────────────────────────────────────────────────────────
#  INIT
# ─────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_multiplayer_signals()

func _connect_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# ─────────────────────────────────────────────────────────────
#  PROCESS — UDP broadcast / listen
# ─────────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	_handle_udp_listen()
	_handle_udp_broadcast()
	_cleanup_stale_hosts()

func _handle_udp_listen() -> void:
	if not _is_discovering or _udp_listener == null:
		return
	if not _udp_listener.is_bound():
		return
	while _udp_listener.get_available_packet_count() > 0:
		var raw    = _udp_listener.get_packet()
		var sender = _udp_listener.get_packet_ip()
		var packet = raw.get_string_from_utf8()
		_parse_broadcast_packet(packet, sender)

func _handle_udp_broadcast() -> void:
	if not is_host or _udp_broadcaster == null or not game_running == false:
		return
	if Engine.get_frames_drawn() % BROADCAST_INTERVAL_FRAMES != 0:
		return
	force_broadcast()

func force_broadcast() -> void:
	if not is_host or _udp_broadcaster == null or game_running:
		return
	var payload = _build_broadcast_payload()
	var buf = payload.to_utf8_buffer()
	_udp_broadcaster.set_dest_address("255.255.255.255", BROADCAST_PORT)
	_udp_broadcaster.put_packet(buf)
	_udp_broadcaster.set_dest_address("127.0.0.1", BROADCAST_PORT)
	_udp_broadcaster.put_packet(buf)


func _cleanup_stale_hosts() -> void:
	if not _is_discovering:
		return
	var now = Time.get_ticks_msec() / 1000.0
	var to_remove: Array = []
	for ip in known_hosts:
		if now - known_hosts[ip]["last_seen"] > DISCOVERY_TIMEOUT_SEC * 6:
			to_remove.append(ip)
	for ip in to_remove:
		known_hosts.erase(ip)
		host_lost.emit(ip)
		host_list_updated.emit()

# ─────────────────────────────────────────────────────────────
#  BROADCAST FORMAT
#  "FK_LAN_v2:{gamertag}|{player_count}|{max_players}|{state}"
#  state: "lobby" or "ingame"
# ─────────────────────────────────────────────────────────────
func _build_broadcast_payload() -> String:
	var gt = SaveManager.nombre_jugador if SaveManager.nombre_jugador != "" else "Host"
	var pc = players.size()
	var state = "ingame" if game_running else "lobby"
	return "%s%s|%d|%d|%s" % [PROTOCOL_HEADER, gt, pc, MAX_PLAYERS, state]

func _parse_broadcast_packet(packet: String, sender_ip: String) -> void:
	if not packet.begins_with(PROTOCOL_HEADER):
		return
	var data_str = packet.substr(PROTOCOL_HEADER.length())
	var parts    = data_str.split("|")
	if parts.size() < 4:
		return
	
	var gamertag     = parts[0]
	var player_count = int(parts[1])
	var max_players  = int(parts[2])
	var state        = parts[3]
	var last_seen    = Time.get_ticks_msec() / 1000.0

	# Buscar duplicados por gamertag (si uno es 127.0.0.1 y el otro es LAN IP)
	var duplicate_ip: String = ""
	for ip in known_hosts:
		if known_hosts[ip]["gamertag"] == gamertag:
			if (ip == "127.0.0.1" and sender_ip != "127.0.0.1") or (ip != "127.0.0.1" and sender_ip == "127.0.0.1"):
				duplicate_ip = ip
				break

	if duplicate_ip != "":
		if sender_ip == "127.0.0.1":
			# Ignorar localhost si ya tenemos la LAN IP, pero actualizar datos
			known_hosts[duplicate_ip]["last_seen"] = last_seen
			known_hosts[duplicate_ip]["player_count"] = player_count
			known_hosts[duplicate_ip]["state"] = state
			host_list_updated.emit()
			return
		else:
			# Eliminar la entrada localhost y preferir la IP externa de LAN
			known_hosts.erase(duplicate_ip)
			host_lost.emit(duplicate_ip)

	var info = {
		"ip":           sender_ip,
		"gamertag":     gamertag,
		"player_count": player_count,
		"max_players":  max_players,
		"state":        state,
		"last_seen":    last_seen
	}
	var is_new = not known_hosts.has(sender_ip)
	known_hosts[sender_ip] = info
	if is_new:
		host_discovered.emit(info)
	host_list_updated.emit()

# ─────────────────────────────────────────────────────────────
#  HOST GAME
# ─────────────────────────────────────────────────────────────
func host_game() -> int:
	cleanup()
	peer = ENetMultiplayerPeer.new()
	peer.set_bind_ip("0.0.0.0")
	var err = peer.create_server(GAME_PORT, MAX_PLAYERS)
	if err != OK:
		push_error("[NetworkManager] Error creando servidor ENet: %d" % err)
		return err
	multiplayer.multiplayer_peer = peer
	is_host = true
	game_running = false

	# Register host as player 1 (peer_id 1 = server)
	var host_tag = SaveManager.nombre_jugador if SaveManager.nombre_jugador != "" else "Host"
	_register_local_player_entry(1, host_tag)

	# Start broadcasting
	_udp_broadcaster = PacketPeerUDP.new()
	_udp_broadcaster.set_broadcast_enabled(true)

	print("[NetworkManager] Servidor iniciado. Gamertag: %s" % host_tag)
	return OK

# ─────────────────────────────────────────────────────────────
#  JOIN GAME
# ─────────────────────────────────────────────────────────────
func join_game(ip: String) -> bool:
	cleanup()
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, GAME_PORT)
	if err != OK:
		push_error("[NetworkManager] Error conectando a %s: %d" % [ip, err])
		return false
	multiplayer.multiplayer_peer = peer
	is_host = false
	print("[NetworkManager] Conectando a %s..." % ip)
	return true

# ─────────────────────────────────────────────────────────────
#  DISCOVERY
# ─────────────────────────────────────────────────────────────
func start_discovery() -> void:
	stop_discovery()
	known_hosts.clear()
	_udp_listener = PacketPeerUDP.new()
	var err = _udp_listener.bind(BROADCAST_PORT)
	if err != OK:
		push_error("[NetworkManager] Error bindeando UDP puerto %d: %d" % [BROADCAST_PORT, err])
		return
	_is_discovering = true
	print("[NetworkManager] Discovery iniciado.")

func stop_discovery() -> void:
	_is_discovering = false
	if _udp_listener:
		_udp_listener.close()
		_udp_listener = null
	print("[NetworkManager] Discovery detenido.")

func get_known_hosts() -> Dictionary:
	return known_hosts.duplicate()

# ─────────────────────────────────────────────────────────────
#  PLAYER REGISTRATION (RPCs)
# ─────────────────────────────────────────────────────────────

## Called by client after connecting — sends their gamertag to host
@rpc("any_peer", "reliable", "call_remote")
func rpc_register_player(gamertag: String) -> void:
	if not multiplayer.is_server():
		return
	var sender_id = multiplayer.get_remote_sender_id()
	if game_running:
		print("[NetworkManager] Rechazando registro de peer %d: partida en curso." % sender_id)
		if peer:
			peer.disconnect_peer(sender_id)
		return
	_register_player_entry(sender_id, gamertag)
	# Confirm back to the sender and broadcast to all
	rpc_player_joined.rpc(sender_id, gamertag)
	# Send existing player list to the new client
	for pid in players:
		rpc_player_joined.rpc_id(sender_id, pid, players[pid]["gamertag"])

## Broadcast: a player has joined
@rpc("authority", "reliable", "call_local")
func rpc_player_joined(peer_id: int, gamertag: String) -> void:
	_register_player_entry(peer_id, gamertag)

## Host calls this to start the game for everyone
@rpc("authority", "reliable", "call_local")
func rpc_start_game() -> void:
	game_running = true
	game_start_requested.emit()
	print("[NetworkManager] ¡Partida iniciada!")

## Host marks a player alive/dead
@rpc("authority", "reliable", "call_local")
func rpc_set_player_alive(peer_id: int, alive: bool) -> void:
	if players.has(peer_id):
		players[peer_id]["alive"] = alive
		
	if multiplayer.is_server() and not alive:
		if not any_player_alive():
			_trigger_game_over()

## Client calls this to report its own death — host then marks it authoritatively
@rpc("any_peer", "reliable")
func rpc_report_my_death() -> void:
	if not multiplayer.is_server():
		return
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_set_player_alive.rpc(sender_id, false)

func _trigger_game_over() -> void:
	# Add a small delay so players can see the death animation
	var timer = get_tree().create_timer(4.0)
	timer.timeout.connect(func(): rpc_game_over.rpc())

## Broadcast game over
@rpc("authority", "reliable", "call_local")
func rpc_game_over() -> void:
	game_running = false
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

## Client calls this to report that they loaded the gameplay scene and are ready to receive scene RPCs.
@rpc("any_peer", "reliable")
func rpc_set_peer_in_scene(in_scene: bool) -> void:
	if not multiplayer.is_server():
		return
	var sender_id = multiplayer.get_remote_sender_id()
	if players.has(sender_id):
		players[sender_id]["in_scene"] = in_scene
		print("[NetworkManager] Peer %d in_scene: %s" % [sender_id, in_scene])

func set_local_in_scene(in_scene: bool) -> void:
	var my_id = get_my_peer_id()
	if players.has(my_id):
		players[my_id]["in_scene"] = in_scene
	if is_multiplayer_active() and not is_server():
		rpc_set_peer_in_scene.rpc(in_scene)

func is_peer_in_scene(peer_id: int) -> bool:
	if not is_multiplayer_active():
		return true
	if peer_id == get_my_peer_id():
		return true
	if players.has(peer_id):
		return players[peer_id].get("in_scene", false)
	return false

# ─────────────────────────────────────────────────────────────
#  INTERNAL REGISTRY HELPERS
# ─────────────────────────────────────────────────────────────
func _register_local_player_entry(peer_id: int, gamertag: String) -> void:
	_register_player_entry(peer_id, gamertag)

func _register_player_entry(peer_id: int, gamertag: String) -> void:
	if players.has(peer_id):
		return
	players[peer_id] = {"gamertag": gamertag, "ready": false, "alive": true, "in_scene": false}
	player_registered.emit(peer_id, gamertag)
	# Emitir all_players_ready si hay al menos 1 cliente conectado además del host
	var client_count = 0
	for pid in players:
		if pid != 1:
			client_count += 1
	if client_count >= 1 and multiplayer.is_server():
		all_players_ready.emit()
	print("[NetworkManager] Jugador registrado — ID:%d Gamertag:%s" % [peer_id, gamertag])
	force_broadcast()

func _unregister_player(peer_id: int) -> void:
	if players.has(peer_id):
		players.erase(peer_id)
		player_unregistered.emit(peer_id)
		print("[NetworkManager] Jugador desconectado — ID:%d" % peer_id)
		force_broadcast()
		if game_running and multiplayer.is_server():
			if not any_player_alive():
				print("[NetworkManager] No quedan jugadores vivos tras desconexión. Iniciando Game Over...")
				_trigger_game_over()

# ─────────────────────────────────────────────────────────────
#  UTILITY QUERIES
# ─────────────────────────────────────────────────────────────
func is_server() -> bool:
	return multiplayer.is_server()

func get_my_peer_id() -> int:
	if multiplayer.has_multiplayer_peer():
		return multiplayer.get_unique_id()
	return 1  # Solitario = ID 1

func get_gamertag(peer_id: int) -> String:
	if players.has(peer_id):
		return players[peer_id]["gamertag"]
	return "Desconocido"

func is_multiplayer_active() -> bool:
	return multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer != null

func any_player_alive() -> bool:
	for pid in players:
		if players[pid].get("alive", true):
			return true
	return false

func get_player_count() -> int:
	return max(1, players.size())

# ─────────────────────────────────────────────────────────────
#  CLEANUP
# ─────────────────────────────────────────────────────────────
func cleanup() -> void:
	_velocidad_hasta.clear()
	stop_discovery()
	if _udp_broadcaster:
		_udp_broadcaster.close()
		_udp_broadcaster = null
	_cleanup_peer()
	players.clear()
	known_hosts.clear()
	is_host = false
	game_running = false

func _cleanup_peer() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	peer = null

# ─────────────────────────────────────────────────────────────
#  MULTIPLAYER SIGNAL HANDLERS
# ─────────────────────────────────────────────────────────────
func _on_peer_connected(id: int) -> void:
	print("[NetworkManager] Peer conectado: %d" % id)
	# Host will receive gamertag via rpc_register_player shortly

func _on_peer_disconnected(id: int) -> void:
	print("[NetworkManager] Peer desconectado: %d" % id)
	_unregister_player.call_deferred(id)

func _on_connected_to_server() -> void:
	print("[NetworkManager] Conectado al servidor!")
	# Send our gamertag to the host
	var my_tag = SaveManager.nombre_jugador if SaveManager.nombre_jugador != "" else "Caballero"
	var my_id  = multiplayer.get_unique_id()
	# Register ourselves locally first
	_register_player_entry(my_id, my_tag)
	# Notify host
	rpc_register_player.rpc_id(1, my_tag)
	connection_succeeded.emit()

func _on_connection_failed() -> void:
	push_error("[NetworkManager] Conexión fallida.")
	call_deferred("_deferred_connection_failed")

func _deferred_connection_failed() -> void:
	_cleanup_peer()
	connection_failed.emit()

func _on_server_disconnected() -> void:
	push_warning("[NetworkManager] Servidor desconectado.")
	call_deferred("_deferred_server_disconnected")

func _deferred_server_disconnected() -> void:
	cleanup()
	server_disconnected_signal.emit()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
