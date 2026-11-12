## Guardian de las Sombras - nuevo jefe para Arcade y Boss Rush.
## Reutiliza la IA y las animaciones del jefe de piso; agrega una
## segunda fase y una onda de sombras con aviso visual.
extends "res://Scenes/UI/Personajes/Villanos/jefe/jefe_piso.gd"

const RADIO_ONDA: float = 230.0
const ANTICIPACION_ONDA: float = 0.75
const COLOR_SOMBRA := Color(0.63, 0.42, 0.95, 1.0)
const COLOR_FURIA := Color(0.88, 0.28, 0.98, 1.0)

var fase_dos: bool = false
var ataques_desde_onda: int = 0


func _ready() -> void:
	super._ready()
	modulate = COLOR_SOMBRA
	if not _is_client_only():
		vida_maxima *= 1.2
		salud_actual = vida_maxima
		speed *= 1.15
		if is_instance_valid(barra_vida):
			barra_vida.max_value = vida_maxima
			barra_vida.value = salud_actual
	_actualizar_nombre()


func _actualizar_nombre() -> void:
	var titulo := Label.new()
	titulo.text = "GUARDIAN DE LAS SOMBRAS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(-150, -320)
	titulo.custom_minimum_size = Vector2(300, 28)
	titulo.add_theme_color_override("font_color", Color(0.9, 0.72, 1.0))
	titulo.add_theme_color_override("font_outline_color", Color.BLACK)
	titulo.add_theme_constant_override("outline_size", 4)
	add_child(titulo)


func recibir_dano(cantidad: int) -> void:
	if is_dead or _is_client_only():
		return
	super.recibir_dano(cantidad)
	if not is_dead and not fase_dos and salud_actual <= vida_maxima * 0.5:
		_activar_fase_dos()


func _process(delta: float) -> void:
	super._process(delta)
	# En clientes la salud llega por el RPC ya existente del jefe base.
	if _is_client_only() and not fase_dos and not is_dead:
		if salud_actual <= vida_maxima * 0.5:
			_activar_fase_dos()


func _activar_fase_dos() -> void:
	if fase_dos:
		return
	fase_dos = true
	if not _is_client_only():
		speed *= 1.35
		attack_cooldown *= 0.8
	modulate = COLOR_FURIA
	if is_instance_valid(barra_vida):
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.7, 0.16, 0.9)
		barra_vida.add_theme_stylebox_override("fill", estilo)
	var aviso := Label.new()
	aviso.text = "FASE 2 - FURIA SOMBRIA"
	aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aviso.position = Vector2(-160, -360)
	aviso.custom_minimum_size = Vector2(320, 32)
	aviso.add_theme_color_override("font_color", Color(1.0, 0.75, 1.0))
	add_child(aviso)
	var tween := create_tween()
	tween.tween_property(aviso, "modulate:a", 0.0, 1.6)
	tween.tween_callback(aviso.queue_free)


func _efecto_dano() -> void:
	var destino: Color = COLOR_FURIA if fase_dos else COLOR_SOMBRA
	modulate = Color(1.0, 0.35, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", destino, 0.22)


func _atacar_jugador() -> void:
	if is_dead or not is_instance_valid(player):
		return
	if fase_dos and ataques_desde_onda >= 2:
		ataques_desde_onda = 0
		_lanzar_onda_sombras()
		return
	ataques_desde_onda += 1
	super._atacar_jugador()


func _lanzar_onda_sombras() -> void:
	esta_atacando = true
	velocity = Vector2.ZERO
	if animated_sprite.sprite_frames.has_animation("atacar"):
		animated_sprite.play("atacar")
	# El anfitrion anuncia el ataque a todos; el daño se aplica solo
	# en el host para evitar golpes duplicados en multijugador.
	if NetworkManager.is_multiplayer_active():
		if NetworkManager.is_server():
			rpc_aviso_onda_sombras.rpc()
	else:
		_mostrar_aviso_onda()

	await get_tree().create_timer(ANTICIPACION_ONDA).timeout
	if is_dead or not is_inside_tree():
		return
	for objetivo in PlayerRegistry.get_all_players():
		if not is_instance_valid(objetivo):
			continue
		if objetivo.get("is_dead") == true:
			continue
		if global_position.distance_to(objetivo.global_position) <= RADIO_ONDA:
			if objetivo.has_method("recibir_dano"):
				objetivo.recibir_dano(poder_ataque)
	esta_atacando = false
	attack_timer = attack_cooldown


@rpc("authority", "call_local", "reliable")
func rpc_aviso_onda_sombras() -> void:
	_mostrar_aviso_onda()


func _mostrar_aviso_onda() -> void:
	if is_dead:
		return
	var aro := Line2D.new()
	aro.width = 9.0
	aro.default_color = Color(0.92, 0.3, 1.0, 0.85)
	aro.closed = true
	aro.z_index = 8
	for i in range(49):
		var angulo := TAU * float(i) / 48.0
		aro.add_point(Vector2(cos(angulo), sin(angulo)) * RADIO_ONDA)
	aro.scale = Vector2(0.85, 0.85)
	add_child(aro)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(aro, "scale", Vector2.ONE, ANTICIPACION_ONDA)
	tween.tween_property(aro, "modulate:a", 0.0, ANTICIPACION_ONDA)
	tween.set_parallel(false)
	tween.tween_callback(aro.queue_free)
