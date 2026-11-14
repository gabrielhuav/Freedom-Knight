## Guardian de las Sombras - nuevo jefe para Arcade y Boss Rush.
## Conserva la IA y el combate del jefe de piso; utiliza un aspecto
## espectral propio con animaciones de reposo, movimiento y ataque.
extends "res://Scenes/UI/Personajes/Villanos/jefe/jefe_piso.gd"

const RUTA_SPRITES: String = "res://Scenes/UI/Personajes/Villanos/guardian_sombras/guardian_sombras_sheet.png"
const RADIO_ONDA: float = 230.0
const ANTICIPACION_ONDA: float = 0.75
# Los colores morados ya estan integrados en los sprites.
const COLOR_SOMBRA := Color.WHITE
const COLOR_FURIA := Color(1.0, 0.78, 1.0, 1.0)

var fase_dos: bool = false
var ataques_desde_onda: int = 0
var _tiempo_impacto: float = 0.0


func _ready() -> void:
	super._ready()
	_aplicar_sprites_personalizados()
	modulate = COLOR_SOMBRA
	if not _is_client_only():
		vida_maxima *= 1.2
		salud_actual = vida_maxima
		speed *= 1.15
		if is_instance_valid(barra_vida):
			barra_vida.max_value = vida_maxima
			barra_vida.value = salud_actual
	# Igual que los demas jefes, no se agrega un nombre flotante.


# Se ejecuta DESPUES de _ready() del jefe base. Si la textura falla,
# se mantienen intactas las animaciones originales y el combate.
func _aplicar_sprites_personalizados() -> void:
	var textura: Texture2D = load(RUTA_SPRITES) as Texture2D
	if textura == null:
		push_warning("No se pudo cargar el spritesheet del Guardian; se mantiene el arte anterior.")
		return
	if textura.get_width() % 4 != 0 or textura.get_height() % 4 != 0:
		push_warning("El spritesheet del Guardian no tiene dimensiones divisibles entre 4.")
		return
	var ancho: int = int(textura.get_width() / 4)
	var alto: int = int(textura.get_height() / 4)
	var cuadros := SpriteFrames.new()
	for nombre in ["correr", "atacar", "herido", "morir"]:
		cuadros.add_animation(nombre)
	_agregar_fotogramas(cuadros, textura, "default", 0, 0, 4, ancho, alto)
	_agregar_fotogramas(cuadros, textura, "correr", 1, 0, 4, ancho, alto)
	_agregar_fotogramas(cuadros, textura, "atacar", 2, 0, 4, ancho, alto)
	_agregar_fotogramas(cuadros, textura, "herido", 3, 0, 2, ancho, alto)
	_agregar_fotogramas(cuadros, textura, "morir", 3, 2, 2, ancho, alto)
	for nombre in ["default", "correr"]:
		cuadros.set_animation_loop(nombre, true)
	for nombre in ["atacar", "herido", "morir"]:
		cuadros.set_animation_loop(nombre, false)
	cuadros.set_animation_speed("default", 4.0)
	cuadros.set_animation_speed("correr", 7.0)
	cuadros.set_animation_speed("atacar", 6.0)
	cuadros.set_animation_speed("herido", 8.0)
	cuadros.set_animation_speed("morir", 2.0)
	animated_sprite.sprite_frames = cuadros
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	animated_sprite.scale = Vector2(2.25, 2.25)
	animated_sprite.play("default")


func _agregar_fotogramas(cuadros: SpriteFrames, textura: Texture2D, nombre: String, fila: int, inicio: int, cantidad: int, ancho: int, alto: int) -> void:
	for columna in range(inicio, inicio + cantidad):
		var recorte := AtlasTexture.new()
		recorte.atlas = textura
		recorte.region = Rect2(columna * ancho, fila * alto, ancho, alto)
		cuadros.add_frame(nombre, recorte)


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


# El jefe base mantiene la persecucion, colisiones y sincronizacion.
# Solo se dibujan brevemente los cuadros de impacto sin alterar su IA.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_dead:
		return
	# La hoja espectral mira a la izquierda por defecto. Los cuadros
	# de movimiento deben reflejarse al avanzar hacia la derecha.
	# El codigo base usa la orientacion contraria para el jefe original.
	if not _is_client_only() and is_instance_valid(animated_sprite):
		if velocity.x > 0.1:
			animated_sprite.flip_h = true
		elif velocity.x < -0.1:
			animated_sprite.flip_h = false
	if esta_atacando or _is_client_only():
		return
	if _tiempo_impacto > 0.0:
		_tiempo_impacto = maxf(0.0, _tiempo_impacto - delta)
		if animated_sprite.sprite_frames.has_animation("herido"):
			animated_sprite.animation = "herido"
			animated_sprite.frame = 0 if _tiempo_impacto > 0.12 else 1
			animated_sprite.stop()


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
	if not esta_atacando:
		_tiempo_impacto = 0.24
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
