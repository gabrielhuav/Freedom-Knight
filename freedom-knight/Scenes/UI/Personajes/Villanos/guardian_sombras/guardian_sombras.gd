## Guardian de las Sombras - nuevo jefe para Arcade y Boss Rush.
## Reutiliza la IA y las animaciones del jefe de piso; agrega una
## segunda fase y una onda de sombras con aviso visual.
extends "res://Scenes/UI/Personajes/Villanos/jefe/jefe_piso.gd"

const HOJA_SPRITES = preload("res://Scenes/UI/Personajes/Villanos/guardian_sombras/guardian_sombras_sheet.png")
const TAMANO_CUADRO: int = 192
const RADIO_ONDA: float = 230.0
const ANTICIPACION_ONDA: float = 0.75
# La identidad violeta ya esta pintada en los nuevos sprites.
const COLOR_SOMBRA := Color.WHITE
const COLOR_FURIA := Color(1.0, 0.75, 1.0, 1.0)

var fase_dos: bool = false
var ataques_desde_onda: int = 0


# Reemplaza por completo las animaciones heredadas del jefe de piso.
# La hoja de 768x768 contiene una cuadricula de 4x4 cuadros de 192x192.
func _configurar_animaciones() -> void:
	animated_sprite.position = Vector2(3, -18)
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var frames := SpriteFrames.new()
	var nombres := ["default", "correr", "atacar", "herido", "morir"]
	for nombre in nombres:
		if not frames.has_animation(nombre):
			frames.add_animation(nombre)
		frames.clear(nombre)

	_agregar_cuadros(frames, "default", 0, 0, 4)
	_agregar_cuadros(frames, "correr", 1, 0, 4)
	_agregar_cuadros(frames, "atacar", 2, 0, 4)
	_agregar_cuadros(frames, "herido", 3, 0, 2)
	_agregar_cuadros(frames, "morir", 3, 2, 2)

	frames.set_animation_speed("default", 4.0)
	frames.set_animation_speed("correr", 7.0)
	frames.set_animation_speed("atacar", 7.0)
	frames.set_animation_speed("herido", 8.0)
	frames.set_animation_speed("morir", 2.0)
	for nombre in ["default", "correr"]:
		frames.set_animation_loop(nombre, true)
	for nombre in ["atacar", "herido", "morir"]:
		frames.set_animation_loop(nombre, false)
	animated_sprite.sprite_frames = frames
	animated_sprite.play("default")


func _agregar_cuadros(frames: SpriteFrames, nombre: String, fila: int, primera_columna: int, cantidad: int) -> void:
	for columna in range(primera_columna, primera_columna + cantidad):
		var region := AtlasTexture.new()
		region.atlas = HOJA_SPRITES
		region.region = Rect2(columna * TAMANO_CUADRO, fila * TAMANO_CUADRO, TAMANO_CUADRO, TAMANO_CUADRO)
		region.filter_clip = true
		frames.add_frame(nombre, region)


func _crear_barra_vida() -> void:
	super._crear_barra_vida()
	if is_instance_valid(barra_vida):
		barra_vida.position = Vector2(-75, -175)


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
	titulo.position = Vector2(-150, -208)
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
	aviso.position = Vector2(-160, -240)
	aviso.custom_minimum_size = Vector2(320, 32)
	aviso.add_theme_color_override("font_color", Color(1.0, 0.75, 1.0))
	add_child(aviso)
	var tween := create_tween()
	tween.tween_property(aviso, "modulate:a", 0.0, 1.6)
	tween.tween_callback(aviso.queue_free)


func _efecto_dano() -> void:
	if is_dead:
		return
	if animated_sprite.sprite_frames.has_animation("herido"):
		animated_sprite.play("herido")
	var destino: Color = COLOR_FURIA if fase_dos else COLOR_SOMBRA
	modulate = Color(1.0, 0.35, 0.5)
	var tween := create_tween()
	tween.tween_property(self, "modulate", destino, 0.22)


func _morir() -> void:
	if is_dead:
		return
	if animated_sprite.sprite_frames.has_animation("morir"):
		animated_sprite.play("morir")
	super._morir()


func _morir_client() -> void:
	if animated_sprite.sprite_frames.has_animation("morir"):
		animated_sprite.play("morir")
	super._morir_client()


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
