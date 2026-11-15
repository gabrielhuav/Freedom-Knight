extends Area2D

@export var duracion_efecto: float = 5.0
var consumida: bool = false

func _ready() -> void:
	add_to_group("pociones")
	if NetworkManager.is_multiplayer_active() and not NetworkManager.is_server():
		set_deferred("monitoring", false)
		rpc_request_position.rpc_id(1)

func _on_body_entered(body: Node2D) -> void:
	if consumida or body != PlayerRegistry.get_local_player() or body.get("is_dead") == true:
		return
	if not body.has_method("activar_pocion_velocidad"):
		return
	if body.is_speed_boost_active:
		_mostrar_aviso_en_pantalla()
		return
	if NetworkManager.is_multiplayer_active() and not NetworkManager.is_server():
		rpc_request_use.rpc_id(1)
	else:
		_usar_en_servidor(NetworkManager.get_my_peer_id())

func _usar_en_servidor(peer_id: int) -> void:
	if consumida or (NetworkManager.is_multiplayer_active() and not NetworkManager.is_server()):
		return
	var jugador = PlayerRegistry.get_player(peer_id)
	if not is_instance_valid(jugador) or jugador.get("is_dead") == true:
		return
	var posicion: Vector2 = jugador.get("net_position") if "net_position" in jugador else jugador.global_position
	if global_position.distance_to(posicion) > 92.0:
		return
	if not NetworkManager.conceder_pocion_velocidad(peer_id, duracion_efecto):
		if peer_id == NetworkManager.get_my_peer_id():
			_mostrar_aviso_en_pantalla()
		else:
			rpc_aviso.rpc_id(peer_id)
		return
	consumida = true
	# Solo el anfitrion elimina el nodo replicado por MultiplayerSpawner.
	queue_free()

@rpc("any_peer", "reliable")
func rpc_request_use() -> void:
	if NetworkManager.is_server():
		_usar_en_servidor(multiplayer.get_remote_sender_id())

@rpc("any_peer", "reliable")
func rpc_request_position() -> void:
	if NetworkManager.is_server():
		rpc_set_position.rpc_id(multiplayer.get_remote_sender_id(), global_position)

@rpc("authority", "call_local", "reliable")
func rpc_set_position(pos: Vector2) -> void:
	global_position = pos
	set_deferred("monitoring", true)

@rpc("authority", "reliable")
func rpc_aviso() -> void:
	_mostrar_aviso_en_pantalla()

func _mostrar_aviso_en_pantalla() -> void:
	var canvas = CanvasLayer.new()
	var label = Label.new()
	label.text = "Ya tienes una pocion de velocidad activa."
	label.position = Vector2(200, 100)
	canvas.add_child(label)
	get_tree().current_scene.add_child(canvas)
	get_tree().create_timer(2.0).timeout.connect(canvas.queue_free, CONNECT_ONE_SHOT)
