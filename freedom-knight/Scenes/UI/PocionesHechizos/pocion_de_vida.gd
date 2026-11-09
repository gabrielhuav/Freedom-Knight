extends Area2D

@export var cantidad_curacion: int = 2

var jugador_cerca: Node = null  # quién está en rango

var sound_pocion = preload("res://Sonidos/Efectos/TomarPocion.mp3")
var _sfx_player: AudioStreamPlayer2D

func _ready() -> void:
	_sfx_player = AudioStreamPlayer2D.new()
	_sfx_player.stream = sound_pocion
	
	var target_parent = get_tree().current_scene if (get_tree() and get_tree().current_scene) else get_tree().root
	if target_parent:
		target_parent.add_child.call_deferred(_sfx_player)

	add_to_group("pociones")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	if NetworkManager.is_multiplayer_active() and not NetworkManager.is_server():
		rpc_request_position.rpc_id(1)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		# Solo registrar jugador_cerca si es el jugador LOCAL de este cliente
		# para que el process detecte la tecla de interact del jugador local
		if NetworkManager.is_multiplayer_active():
			if body == PlayerRegistry.get_local_player():
				jugador_cerca = body
		else:
			if body.name == "Caballero":
				jugador_cerca = body

func _on_body_exited(body: Node2D) -> void:
	if body == jugador_cerca:
		jugador_cerca = null

func _process(_delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("interact"):
		if NetworkManager.is_multiplayer_active():
			if NetworkManager.is_server():
				_usar_pocion_server(1)
			else:
				rpc_request_use_potion.rpc_id(1)
		else:
			_usar_pocion()

func _play_potion_sound() -> void:
	if _sfx_player:
		_sfx_player.global_position = global_position
		_sfx_player.play()
		_sfx_player.finished.connect(_sfx_player.queue_free)

func _usar_pocion() -> void:
	if jugador_cerca == null:
		return
	if not jugador_cerca.has_method("curar"):
		return
	if jugador_cerca.salud_actual >= jugador_cerca.vida_maxima:
		print("[POCION] Vida llena, no se usó.")
		_mostrar_aviso_vida_llena()
		return

	print("[POCION] ¡Usada! Curando %d puntos." % cantidad_curacion)
	_apply_potion_to(jugador_cerca)

func _usar_pocion_server(peer_id: int) -> void:
	if not NetworkManager.is_server(): return
	var player_node = PlayerRegistry.get_player(peer_id)
	if player_node and is_instance_valid(player_node):
		# Verificar distancia y salud en el servidor para evitar exploits/desync
		# Comprobar contra global_position y net_position (si existe) para tolerar lag de interpolación
		var target_pos = player_node.global_position
		var net_pos = player_node.get("net_position") if "net_position" in player_node else target_pos
		
		var dist_to_visual = global_position.distance_to(target_pos)
		var dist_to_net = global_position.distance_to(net_pos)
		
		if dist_to_visual < 200.0 or dist_to_net < 200.0:
			if player_node.salud_actual < player_node.vida_maxima:
				_apply_potion_to(player_node)

func _apply_potion_to(player_node: Node) -> void:
	player_node.curar(cantidad_curacion)
	if NetworkManager.is_multiplayer_active():
		rpc_play_potion_sound.rpc()
	else:
		_play_potion_sound()
	queue_free()

@rpc("any_peer", "reliable")
func rpc_request_use_potion() -> void:
	if not NetworkManager.is_server(): return
	var sender_id = multiplayer.get_remote_sender_id()
	_usar_pocion_server(sender_id)

@rpc("any_peer", "reliable")
func rpc_request_position() -> void:
	if not NetworkManager.is_server(): return
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_set_position.rpc_id(sender_id, global_position)

@rpc("authority", "call_local", "reliable")
func rpc_set_position(pos: Vector2) -> void:
	global_position = pos

@rpc("authority", "call_local", "reliable")
func rpc_play_potion_sound() -> void:
	_play_potion_sound()

func _exit_tree() -> void:
	if _sfx_player and not _sfx_player.playing:
		_sfx_player.queue_free()

func _mostrar_aviso_vida_llena() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	
	var label = Label.new()
	label.text = "¡Vida al máximo! No puedes usar la poción"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Estilo del recuadro
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.85)
	style.border_color = Color(0.9, 0.7, 0.2, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	label.add_theme_stylebox_override("normal", style)
	
	# Centrar en la parte superior/media de la pantalla
	label.anchor_left = 0.5
	label.anchor_top = 0.2
	label.anchor_right = 0.5
	label.anchor_bottom = 0.2
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	canvas_layer.add_child(label)
	get_tree().root.add_child(canvas_layer)
	
	# Espera asíncrona de 2 segundos sin congelar el juego
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(canvas_layer):
		canvas_layer.queue_free()
