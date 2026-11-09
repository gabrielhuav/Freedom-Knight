## ============================================================
##  caballero.gd  — Freedom Knight
##  Jugador principal (local).
##  En solitario: funciona exactamente igual que antes.
##  En multijugador: 
##    - Host: controla su caballero, sincroniza posición, aplica daño
##    - Cliente: envía input al host, interpola su propia posición
##  REGLA DE ORO: solo el HOST aplica daño y lógica de combate.
## ============================================================
extends CharacterBody2D

signal nivel_subido

const ANIM_IDLE   = "idle"
const ANIM_MOVE   = "move"
const ANIM_ATTACK = "attack"
const ANIM_GUARD  = "guard"
const ANIM_DEATH  = "death"
const GUARD_MAX           : float = 5.0
const GUARD_RECHARGE_RATE : float = 1.0

# ─────────────────────────────────────────────────────────────
#  EXPORTS
# ─────────────────────────────────────────────────────────────
@export_group("Movimiento")
@export var speed: float = 200.0

@export_group("Combate")
@export var vida_maxima  : int = 10
@export var poder_ataque : int = 2
@export var fuerza       : int = 0
var dano_base    : int   = 2
var salud_actual : int
var guard_energy : float = GUARD_MAX
var is_guarding  : bool  = false

@export_group("Nivel y Experiencia")
var nivel         : int   = 1
var experiencia   : int   = 0
var max_nivel     : int   = 1000
var velocidad_base: float = 200.0

@export_group("Sprint y Poción de Velocidad")
@export var multiplicador_sprint       : float = 1.5
@export var multiplicador_pocion_azul  : float = 2.2  # Superior al sprint normal
@export var ventana_doble_toque_ms     : int   = 300
var is_sprinting            : bool = false
var is_speed_boost_active   : bool = false
var estaba_moviendose       : bool = false
var tiempo_ultimo_toque     : int  = -10000

# ─────────────────────────────────────────────────────────────
#  NODOS
# ─────────────────────────────────────────────────────────────
@onready var sprite : AnimatedSprite2D = $AnimatedSprite
@onready var hitbox : Area2D           = $HitboxEspada

# ─────────────────────────────────────────────────────────────
#  ESTADO
# ─────────────────────────────────────────────────────────────
var is_attacking : bool = false
var is_dead      : bool = false

var sound_espada  = preload("res://Sonidos/Efectos/espada.mp3")
var _sfx_player   : AudioStreamPlayer2D

var label_nombre  : Label
var label_nivel   : Label

# ─────────────────────────────────────────────────────────────
#  NETWORKING
# ─────────────────────────────────────────────────────────────
## peer_id de este jugador (1 en solitario, asignado por ENet en multiplayer)
var my_peer_id : int = 1

## Acumulador — usado en _send_state_sync para throttling

## Acumulador de tiempo para envío de sincronización (20Hz)
const SYNC_RATE : float = 0.05   # seconds between syncs
var _sync_timer : float = 0.0

# ─────────────────────────────────────────────────────────────
#  LIFECYCLE
# ─────────────────────────────────────────────────────────────
func _ready() -> void:
	_sfx_player = AudioStreamPlayer2D.new()
	_sfx_player.stream = sound_espada
	add_child(_sfx_player)

	# Determinar peer_id (el nodo mantiene su nombre original "Caballero")
	my_peer_id = NetworkManager.get_my_peer_id()

	# Registrar en PlayerRegistry
	PlayerRegistry.set_local_peer_id(my_peer_id)
	PlayerRegistry.register(my_peer_id, self)

	add_to_group("jugador")

	# Capas de físicas
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)

	salud_actual = vida_maxima

	# HitboxEspada
	hitbox.set_collision_layer_value(1, false)
	hitbox.set_collision_layer_value(4, true)
	hitbox.set_collision_mask_value(3, true)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

	# Labels
	_setup_labels()

	await get_tree().process_frame
	await get_tree().process_frame
	actualizar_ui_corazones()

func _exit_tree() -> void:
	PlayerRegistry.unregister(my_peer_id)

func _setup_labels() -> void:
	label_nombre = Label.new()
	var tag = SaveManager.nombre_jugador
	label_nombre.text = tag if tag != "" else "Caballero"
	label_nombre.add_theme_font_size_override("font_size", 12)
	label_nombre.add_theme_color_override("font_color", Color.WHITE)
	label_nombre.add_theme_color_override("font_outline_color", Color.BLACK)
	label_nombre.add_theme_constant_override("outline_size", 4)
	label_nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_nombre.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label_nombre.z_index = 10
	label_nombre.position = Vector2(-50, -45)
	label_nombre.custom_minimum_size = Vector2(100, 20)
	add_child(label_nombre)

	label_nivel = Label.new()
	label_nivel.add_theme_font_size_override("font_size", 10)
	label_nivel.add_theme_color_override("font_color", Color.GOLD)
	label_nivel.add_theme_color_override("font_outline_color", Color.BLACK)
	label_nivel.add_theme_constant_override("outline_size", 3)
	label_nivel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_nivel.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label_nivel.z_index = 10
	label_nivel.position = Vector2(-50, -75)
	label_nivel.custom_minimum_size = Vector2(100, 20)
	add_child(label_nivel)
	_actualizar_ui_nivel()

# ─────────────────────────────────────────────────────────────
#  PHYSICS PROCESS
# ─────────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	# Congelar controles si el menú de pausa está visible
	var ui = get_tree().current_scene.find_child("Botones", true)
	var is_paused = false
	if ui and ui.get("menu_pausa") and ui.menu_pausa.visible:
		is_paused = true
		velocity = Vector2.ZERO
		_update_animations(Vector2.ZERO)
		
	if is_instance_valid(label_nombre): label_nombre.visible = not is_paused
	if is_instance_valid(label_nivel): label_nivel.visible = not is_paused
	
	if is_paused:
		return

	if is_dead:
		if NetworkManager.is_multiplayer_active():
			# Buscar jugadores vivos en el registry (incluye el caballero_remoto del host)
			var vivos = PlayerRegistry.get_alive_players()
			# Filtrar solo los que tienen global_position real (remotos también)
			var objetivo: Node = null
			for p in vivos:
				# Excluir este mismo nodo y nodos sin posición
				if is_instance_valid(p) and p != self:
					objetivo = p
					break
			if objetivo:
				var cam = get_node_or_null("Camera2D")
				if cam:
					if not cam.top_level:
						cam.set_as_top_level(true)
					cam.global_position = cam.global_position.lerp(objetivo.global_position, delta * 5.0)
		return

	var direction = _get_move_direction()

	# Guard input (local siempre)
	if Input.is_action_just_pressed("guard"):
		_start_guard()
	elif Input.is_action_just_released("guard"):
		_stop_guard()

	# Attack input (local siempre)
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_guarding:
		_execute_attack()

	# Movement & Speed logic (Sprint + Potion Boost)
	if is_guarding or is_attacking:
		velocity = Vector2.ZERO
		is_sprinting = false
		estaba_moviendose = false
	else:
		var se_esta_moviendo = direction.length() > 0.2
		
		if estaba_moviendose and not se_esta_moviendo:
			is_sprinting = false
			tiempo_ultimo_toque = Time.get_ticks_msec()
			
		elif not estaba_moviendose and se_esta_moviendo:
			var tiempo_actual = Time.get_ticks_msec()
			if (tiempo_actual - tiempo_ultimo_toque) <= ventana_doble_toque_ms:
				is_sprinting = true
				
		estaba_moviendose = se_esta_moviendo
		
		# Cálculo final de la velocidad con prioridad a la poción azul
		var velocidad_final = speed
		if is_speed_boost_active:
			velocidad_final = speed * multiplicador_pocion_azul
		elif is_sprinting:
			velocidad_final = speed * multiplicador_sprint
			
		velocity = direction * velocidad_final

	move_and_slide()

	# Guard energy
	if is_guarding:
		guard_energy = max(0.0, guard_energy - delta)
		if guard_energy <= 0.0:
			_stop_guard()
	elif guard_energy < GUARD_MAX:
		guard_energy = min(GUARD_MAX, guard_energy + GUARD_RECHARGE_RATE * delta)

	if not is_attacking:
		_update_animations(direction)

	# ── Networking: enviar estado al host o broadcast a clientes ──
	if NetworkManager.is_multiplayer_active():
		_sync_timer += delta
		if _sync_timer >= SYNC_RATE:
			_sync_timer = 0.0
			_send_state_sync()

func _get_move_direction() -> Vector2:
	var ui = get_tree().current_scene.find_child("Botones", true)
	if ui and "direccion" in ui and ui.direccion != Vector2.ZERO:
		return ui.direccion
	return Input.get_vector("left", "right", "up", "down")

# ─────────────────────────────────────────────────────────────
#  ANIMATIONS
# ─────────────────────────────────────────────────────────────
func _update_animations(direction: Vector2) -> void:
	if is_guarding:
		sprite.play(ANIM_GUARD)
		return
	if direction == Vector2.ZERO:
		sprite.play(ANIM_IDLE)
	else:
		sprite.play(ANIM_MOVE)
		if direction.x > 0:
			sprite.flip_h = false
			hitbox.scale.x = 1
		elif direction.x < 0:
			sprite.flip_h = true
			hitbox.scale.x = -1

# ─────────────────────────────────────────────────────────────
#  COMBAT
# ─────────────────────────────────────────────────────────────
func _execute_attack() -> void:
	is_attacking = true
	if _sfx_player:
		_sfx_player.play()
	sprite.sprite_frames.set_animation_loop(ANIM_ATTACK, false)
	sprite.play(ANIM_ATTACK)
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	await sprite.animation_finished
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	is_attacking = false

func _start_guard() -> void:
	if is_dead or is_guarding: return
	if guard_energy <= 0.0: return
	if SaveManager.dificultad_juego == 2: return
	if is_attacking:
		is_attacking = false
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	is_guarding = true
	sprite.play(ANIM_GUARD)

func _stop_guard() -> void:
	if not is_guarding: return
	is_guarding = false

func get_guard_energy() -> float:
	return guard_energy

# ─────────────────────────────────────────────────────────────
#  DAMAGE SYSTEM
#  En solitario: funciona igual que siempre.
#  En multiplayer: SOLO el host llama recibir_dano() en la
#  instancia del jugador. El cliente no calcula daño.
# ─────────────────────────────────────────────────────────────
func recibir_dano(cantidad: int) -> void:
	if is_dead: return
	if is_guarding:
		print("¡ATAQUE BLOQUEADO POR EL ESCUDO!")
		return

	# En modo cliente: el host maneja el daño, ignorar llamadas locales
	# (solo sucedería si algo local llama esto erróneamente)
	if NetworkManager.is_multiplayer_active() and not NetworkManager.is_server():
		return

	var defensa      = floor(nivel / 3.0)
	var dano_recibido = max(1, cantidad - defensa)
	salud_actual     -= dano_recibido
	salud_actual     = clampi(salud_actual, 0, vida_maxima)

	_efecto_dano()
	actualizar_ui_corazones()

	if NetworkManager.is_multiplayer_active():
		var escenario = get_tree().current_scene
		if is_instance_valid(escenario) and escenario.has_method("notify_remote_damage"):
			escenario.notify_remote_damage(1)

	if salud_actual <= 0:
		_morir()

## Host notifica daño al cliente para efectos visuales
@rpc("authority", "reliable")
func _rpc_notify_damage() -> void:
	# Solo el cliente propio ve este RPC
	_efecto_dano()
	actualizar_ui_corazones()

# ─────────────────────────────────────────────────────────────
#  DEATH
# ─────────────────────────────────────────────────────────────
func _morir() -> void:
	if is_dead: return
	is_dead = true
	print("[Caballero] Caído. Peer: %d" % my_peer_id)

	velocity = Vector2.ZERO
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	hitbox.monitoring = false

	# Forzar que la animación de muerte no loopee
	if sprite and sprite.sprite_frames:
		sprite.sprite_frames.set_animation_loop(ANIM_DEATH, false)
		sprite.play(ANIM_DEATH)
		
		# Dejarlo como fantasma transparente para que pueda seguir siendo espectador visible
		var t = create_tween()
		t.tween_property(sprite, "modulate:a", 0.4, 1.0)

	# Notificar al host/red que este jugador murió
	if NetworkManager.is_multiplayer_active():
		if NetworkManager.is_server():
			# Si soy el host, marcarme como muerto y notificar por RPC a todos los clientes
			NetworkManager.rpc_set_player_alive.rpc(1, false)
			_rpc_notify_host_death.rpc(_get_kill_count())
		else:
			# El cliente reporta su propia muerte al host vía RPC any_peer
			NetworkManager.rpc_report_my_death.rpc_id(1)

	# Estadísticas de muertes
	var muertes = _get_kill_count()
	_show_death_ui(muertes)

	await sprite.animation_finished
	await get_tree().create_timer(4.0).timeout

	if not NetworkManager.is_multiplayer_active():
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

func _get_kill_count() -> int:
	var escenario = get_tree().current_scene
	var total = 0
	if "enemigos_derrotados" in escenario:
		total += escenario.enemigos_derrotados
	if "arqueros_derrotados" in escenario:
		total += escenario.arqueros_derrotados
	if "lanceros_derrotados" in escenario:
		total += escenario.lanceros_derrotados
	return total

func _show_death_ui(muertes: int) -> void:
	var escenario = get_tree().current_scene
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	escenario.add_child(canvas)

	var text_muerte = Label.new()
	if NetworkManager.is_multiplayer_active():
		text_muerte.text = "¡HAS CAÍDO!\nEspectando a tus aliados..."
		text_muerte.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		text_muerte.position = Vector2(0, 50)
	else:
		var bg = ColorRect.new()
		bg.color = Color(0, 0, 0, 0)
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		canvas.add_child(bg)
		var tween_bg = create_tween()
		tween_bg.tween_property(bg, "color:a", 0.7, 1.0)
		text_muerte.text = "¡HAS CAÍDO!\nDerrotaste a %d enemigos." % muertes
		text_muerte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	text_muerte.add_theme_font_size_override("font_size", 24)
	text_muerte.add_theme_color_override("font_color", Color.RED)
	text_muerte.add_theme_color_override("font_outline_color", Color.BLACK)
	text_muerte.add_theme_constant_override("outline_size", 6)
	text_muerte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_muerte.set_anchors_preset(Control.PRESET_FULL_RECT)
	text_muerte.modulate.a = 0
	canvas.add_child(text_muerte)

	var tween = create_tween()
	tween.tween_property(text_muerte, "modulate:a", 1.0, 1.0)

# ─────────────────────────────────────────────────────────────
#  VISUAL EFFECTS
# ─────────────────────────────────────────────────────────────
func _efecto_dano() -> void:
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	if not is_dead:
		sprite.modulate = Color.WHITE
	else:
		sprite.modulate = Color(0.5, 0.5, 0.5)

# ─────────────────────────────────────────────────────────────
#  HEALING
# ─────────────────────────────────────────────────────────────
func curar(cantidad: int) -> void:
	if is_dead or salud_actual >= vida_maxima: return
	salud_actual += cantidad
	salud_actual = clampi(salud_actual, 0, vida_maxima)
	_efecto_curacion()
	actualizar_ui_corazones()

	if NetworkManager.is_multiplayer_active():
		var escenario = get_tree().current_scene
		if is_instance_valid(escenario) and escenario.has_method("notify_remote_heal"):
			escenario.notify_remote_heal(1)

func _efecto_curacion() -> void:
	sprite.modulate = Color.GREEN
	await get_tree().create_timer(0.3).timeout
	sprite.modulate = Color.WHITE

# ─────────────────────────────────────────────────────────────
#  HUD
#  Usa PlayerRegistry.get_local_player() en lugar de buscar
#  "Caballero" hardcodeado. Esta función es para compatibilidad.
# ─────────────────────────────────────────────────────────────
func actualizar_ui_corazones() -> void:
	var ui = get_tree().current_scene.find_child("Botones", true)
	if ui and ui.has_method("actualizar_vidas"):
		ui.actualizar_vidas(salud_actual)

# ─────────────────────────────────────────────────────────────
#  HITBOX ESPADA — Solo aplica daño si somos host o solitario
# ─────────────────────────────────────────────────────────────
func _on_hitbox_espada_body_entered(body: Node2D) -> void:
	if body == self: return
	
	# Fuego amigo: sólo dañar enemigos o mascotas no adoptadas
	var es_gata_no_adoptada = body.is_in_group("mascotas") and body.get("state") != 1 # State.ADOPTED is 1
	var es_saco = body.name.begins_with("SacoBoxeo")
	if not body.is_in_group("enemigos") and not es_gata_no_adoptada and not es_saco:
		return

	# En red: el cliente solicita al host aplicar el daño físico
	if NetworkManager.is_multiplayer_active() and not NetworkManager.is_server():
		var enemy_path = body.get_path()
		rpc_request_damage_enemy.rpc_id(1, enemy_path)
		return

	# Host o solitario
	if body.has_method("recibir_dano"):
		if body.is_in_group("mascotas") or body.name.begins_with("SacoBoxeo"):
			body.recibir_dano(poder_ataque, self)
		else:
			body.recibir_dano(poder_ataque)
		ganar_experiencia(1)

# ─────────────────────────────────────────────────────────────
#  NETWORKING — Sincronización de estado
# ─────────────────────────────────────────────────────────────
func _send_state_sync() -> void:
	var anim: String = str(sprite.animation) if sprite else "idle"
	var flip: bool   = sprite.flip_h         if sprite else false

	if NetworkManager.is_server():
		# Host → broadcast posición a todos los clientes
		# (via escenario_pruebas que hace los RPCs al caballero remoto)
		pass
	else:
		# Cliente → enviar input al host
		_rpc_client_input.rpc_id(1, global_position, velocity, anim, flip, salud_actual, nivel)

## Cliente envía su estado al host
@rpc("any_peer", "unreliable_ordered")
func _rpc_client_input(pos: Vector2, vel: Vector2, anim: String, flip: bool, salud: int, nivel_val: int) -> void:
	if not NetworkManager.is_server(): return
	var sender = multiplayer.get_remote_sender_id()
	
	# El host actualiza la representación local del jugador cliente
	var remote_node = PlayerRegistry.get_player(sender)
	if remote_node and remote_node.has_method("sync_state"):
		remote_node.sync_state(pos, vel, anim, flip, salud, nivel_val)
		
	# Retransmitir la posición de este cliente a todos los demás clientes listos
	var escenario = get_tree().current_scene
	if escenario and escenario.has_method("rpc_sync_player"):
		for pid in NetworkManager.players:
			if pid != 1 and pid != sender:
				if NetworkManager.is_peer_in_scene(pid):
					escenario.rpc_sync_player.rpc_id(pid, sender, pos, vel, anim, flip, salud, nivel_val)

## RPCs recibidos por el cliente desde el host para aplicar estado oficial
@rpc("authority", "reliable")
func rpc_apply_damage(nueva_salud: int) -> void:
	salud_actual = nueva_salud
	_efecto_dano()
	actualizar_ui_corazones()
	if salud_actual <= 0:
		_morir()

@rpc("authority", "reliable")
func rpc_apply_death(muertes: int) -> void:
	is_dead = true
	velocity = Vector2.ZERO
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	hitbox.monitoring = false
	if sprite and sprite.sprite_frames:
		sprite.sprite_frames.set_animation_loop(ANIM_DEATH, false)
		sprite.play(ANIM_DEATH)
		var t = create_tween()
		t.tween_property(sprite, "modulate:a", 0.4, 1.0)
	_show_death_ui(muertes)

@rpc("authority", "reliable")
func rpc_apply_heal(nueva_salud: int) -> void:
	salud_actual = nueva_salud
	_efecto_curacion()
	actualizar_ui_corazones()

@rpc("any_peer", "reliable")
func rpc_request_damage_enemy(enemy_path: NodePath) -> void:
	if not NetworkManager.is_server(): return
	var sender_id = multiplayer.get_remote_sender_id()
	
	var enemy = get_node_or_null(enemy_path)
	if not enemy or not is_instance_valid(enemy): return
	
	var is_dead_state = enemy.get("is_dead") or enemy.get("state") == 2 # State.DEAD is 2
	if is_dead_state: return
	
	# Verificar distancia y poder de ataque del cliente
	var client_node = PlayerRegistry.get_player(sender_id)
	if not client_node or not is_instance_valid(client_node): return
	
	var max_dist = 180.0
	if enemy.is_in_group("jefe"):
		max_dist = 350.0 # El jefe final tiene un radio de colisión gigante
		
	var dist = client_node.global_position.distance_to(enemy.global_position)
	if dist <= max_dist:
		if enemy.has_method("recibir_dano"):
			var client_power = client_node.get("poder_ataque") if "poder_ataque" in client_node else 2
			if enemy.is_in_group("mascotas") or enemy.name.begins_with("SacoBoxeo"):
				enemy.recibir_dano(client_power, client_node)
			else:
				enemy.recibir_dano(client_power)
			rpc_give_experience.rpc_id(sender_id, 1)

@rpc("authority", "reliable")
func rpc_give_experience(amount: int) -> void:
	ganar_experiencia(amount)

@rpc("authority", "reliable")
func rpc_apply_mejorar_fuerza(cantidad: int) -> void:
	mejorar_fuerza(cantidad)

@rpc("authority", "reliable")
func _rpc_notify_host_death(muertes: int) -> void:
	var remoto_host = PlayerRegistry.get_player(1)
	if remoto_host and remoto_host.has_method("notify_death"):
		remoto_host.notify_death(muertes)

# ─────────────────────────────────────────────────────────────
#  EXPERIENCE & LEVEL
# ─────────────────────────────────────────────────────────────
func ganar_experiencia(cantidad: int) -> void:
	if is_dead or nivel >= max_nivel: return
	experiencia += cantidad
	var exp_necesaria = 5 * nivel
	while experiencia >= exp_necesaria and nivel < max_nivel:
		experiencia    -= exp_necesaria
		nivel          += 1
		exp_necesaria   = 5 * nivel
		_subir_de_nivel()
	_actualizar_ui_nivel()

func _subir_de_nivel() -> void:
	nivel_subido.emit()
	speed         = min(600.0, velocidad_base + (nivel * 5.0))
	poder_ataque  = dano_base + floor(fuerza / 3.0) + floor(nivel / 2.0)

	var tween = create_tween()
	sprite.modulate = Color.YELLOW
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.4)

	var aura = sprite.duplicate()
	add_child(aura)
	aura.modulate = Color(1.0, 0.8, 0.0, 0.6)
	aura.z_index  = -1
	var tween_aura = create_tween()
	tween_aura.tween_property(aura, "scale", Vector2(1.8, 1.8), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_aura.parallel().tween_property(aura, "modulate:a", 0.0, 1.0)
	tween_aura.tween_callback(aura.queue_free)

	curar(2)
	print("[Caballero] ¡Nivel %d! Vel: %s Daño: %s" % [nivel, speed, poder_ataque])

func _actualizar_ui_nivel() -> void:
	if is_instance_valid(label_nivel):
		var exp_necesaria = 5 * nivel
		var porcentaje    = (float(experiencia) / float(exp_necesaria)) * 100.0
		if nivel >= max_nivel:
			label_nivel.text = "Lvl: MAX"
		else:
			label_nivel.text  = "Lvl: %d [%d%%]" % [nivel, porcentaje]

func mejorar_fuerza(cantidad: int) -> void:
	fuerza       += cantidad
	poder_ataque  = dano_base + floor(fuerza / 3.0) + floor(nivel / 2.0)
	print("[Caballero] Fuerza: %d | Daño: %d" % [fuerza, poder_ataque])
	var escenario = get_tree().current_scene
	if "fuerza_jugador" in escenario:
		escenario.fuerza_jugador = self.fuerza

func _play_sword_sound() -> void:
	if _sfx_player:
		_sfx_player.play()
