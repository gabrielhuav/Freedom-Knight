## ============================================================
##  canvas_layer.gd  — Freedom Knight  HUD
##  Usa PlayerRegistry.get_local_player() para encontrar
##  al jugador LOCAL en lugar de buscar "Caballero" hardcodeado.
##  Compatibilidad total con solitario y multijugador.
## ============================================================
extends CanvasLayer

# ─────────────────────────────────────────────────────────────
#  REFERENCIAS
# ─────────────────────────────────────────────────────────────
@onready var contenedor_corazones = $UI/TopRight/BarraVidas
@onready var controles_tactiles   = $UI
@onready var boton_attack         = $UI/BottomRight/attack
@onready var boton_guard          = $UI/BottomRight/guard
@onready var boton_interact       = $UI/BottomRight/interact
@onready var boton_menu           = $UI/TopLeft/menu
@onready var guard_timer_label    = $UI/TopLeft/GuardTimer

var escena_menu = preload("res://Scenes/UI/MenuPausa.tscn")
var menu_pausa  = null
var _usando_mando_o_teclado_pausa: bool = false

# ─────────────────────────────────────────────────────────────
#  TEXTURAS DE CORAZONES
# ─────────────────────────────────────────────────────────────
var tex_lleno = preload("res://Scenes/Efectos/corazon uno.png")
var tex_mitad = preload("res://Scenes/Efectos/Corazon medio.png")
var tex_vacio = preload("res://Scenes/Efectos/corazon vacio.png")

# ─────────────────────────────────────────────────────────────
#  JOYSTICK
# ─────────────────────────────────────────────────────────────
@onready var joystick_node = $UI/BottomLeft/VirtualJoystick
@onready var palo          = $UI/BottomLeft/VirtualJoystick/Palo
@onready var base          = $UI/BottomLeft/VirtualJoystick/Base
var radio                  : float  = 60.0
var direccion              : Vector2 = Vector2.ZERO
var dragging               : bool    = false
var touch_index            : int     = -1
var centro_palo            : Vector2 = Vector2(-27, -27)
var posicion_inicial_joystick : Vector2 = Vector2.ZERO

# ─────────────────────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────────────────────
func _ready() -> void:
	# Calcular centro del joystick dinámicamente con la textura del palo para evitar desalineación visual
	if palo and palo.texture_normal:
		var size = palo.texture_normal.get_size() * palo.scale
		centro_palo = -size / 2.0
		palo.position = centro_palo
		print("[Joystick] Centro palo calculado dinámicamente: ", centro_palo)
	elif palo:
		palo.position = centro_palo

	if joystick_node:
		posicion_inicial_joystick = joystick_node.position

	# Estilizar el temporizador del escudo para que coincida con las demás estadísticas
	if guard_timer_label:
		guard_timer_label.add_theme_font_size_override("font_size", 16)
		guard_timer_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0)) # Azul claro estético
		guard_timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
		guard_timer_label.add_theme_constant_override("outline_size", 4)
		guard_timer_label.position = Vector2(20, 200) # Alineado verticalmente bajo el contador de muertes

	controles_tactiles.show()
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().quit_on_go_back = false

	if boton_menu:
		boton_menu.action = "menu"
		if boton_menu.is_connected("pressed", _on_menu_pressed):
			boton_menu.disconnect("pressed", _on_menu_pressed)

	menu_pausa = escena_menu.instantiate()
	add_child(menu_pausa)
	menu_pausa.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_pausa.hide()

	# Interfaz independiente y compatible con controles tactiles.
	var inv = Control.new()
	inv.set_script(load("res://Scenes/UI/Objetos/inventario_ui.gd"))
	add_child(inv)

	if SaveManager.dificultad_juego == 2:
		if boton_guard: boton_guard.hide()
		if guard_timer_label: guard_timer_label.hide()

# ─────────────────────────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────────────────────────
func _process(_delta: float) -> void:
	_actualizar_feedback_boton(boton_attack,  "attack")
	_actualizar_feedback_boton(boton_guard,   "guard")
	_actualizar_feedback_boton(boton_interact,"interact")
	_actualizar_feedback_boton(boton_menu,    "menu")

	# Guard timer — usa PlayerRegistry para el jugador LOCAL
	if guard_timer_label:
		var player = _get_local_player()
		if player and player.has_method("get_guard_energy"):
			guard_timer_label.text = "Guard: %.1fs" % player.get_guard_energy()

	# Joystick feedback visual
	if not dragging:
		var input_dir = Input.get_vector("left", "right", "up", "down")
		if palo:
			if input_dir != Vector2.ZERO:
				palo.position = centro_palo + (input_dir * (radio * 0.8))
			else:
				palo.position = centro_palo

# ─────────────────────────────────────────────────────────────
#  PLAYER LOCAL LOOKUP (eliminando hardcoded "Caballero")
# ─────────────────────────────────────────────────────────────
func _get_local_player() -> Node:
	return PlayerRegistry.get_local_player()

# ─────────────────────────────────────────────────────────────
#  BOTONES FEEDBACK
# ─────────────────────────────────────────────────────────────
func _actualizar_feedback_boton(boton: TouchScreenButton, accion: String) -> void:
	if boton:
		if accion == "menu" and not Input.is_action_pressed(accion):
			boton.modulate = Color(1, 1, 1, 1)
			return
		if Input.is_action_pressed(accion):
			boton.modulate = Color(0.5, 0.5, 0.5, 1)
		else:
			boton.modulate = Color(1, 1, 1, 1)

# ─────────────────────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if SaveManager.escribiendo_texto: return
	# Esc cierra primero la mochila sin abrir simultaneamente la pausa.
	var inv = get_node_or_null("InventarioUI")
	if inv and inv.has_method("esta_abierto") and inv.esta_abierto() and event.is_action_pressed("menu"):
		inv.cerrar()
		get_viewport().set_input_as_handled()
		return
	_procesar_joystick(event)
	if event.is_action_pressed("menu"):
		_on_menu_pressed()
		
	if menu_pausa and menu_pausa.visible:
		if event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventScreenTouch:
			if _usando_mando_o_teclado_pausa:
				_usando_mando_o_teclado_pausa = false
				var focused = get_viewport().gui_get_focus_owner()
				if focused:
					focused.release_focus()
		elif event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			if event is InputEventJoypadMotion and abs(event.axis_value) < 0.2:
				return
			if not _usando_mando_o_teclado_pausa:
				_usando_mando_o_teclado_pausa = true
				if menu_pausa.has_method("focus_first_button"):
					menu_pausa.focus_first_button()

		if event.is_action_pressed("interact"):
			var focused = get_viewport().gui_get_focus_owner()
			if focused and focused is BaseButton:
				focused.emit_signal("pressed")

func _procesar_joystick(event: InputEvent) -> void:
	if get_tree().paused or (menu_pausa and menu_pausa.visible): return

	if event is InputEventScreenTouch:
		if event.pressed and not dragging:
			var mitad_x = get_viewport().get_visible_rect().size.x / 2.0
			var mitad_y = get_viewport().get_visible_rect().size.y / 2.0
			if event.position.x < mitad_x and event.position.y > mitad_y:
				dragging    = true
				touch_index = event.index
				joystick_node.global_position = event.position
				palo.position = centro_palo
		elif not event.pressed and event.index == touch_index:
			dragging    = false
			touch_index = -1
			direccion   = Vector2.ZERO
			var tween = create_tween()
			tween.tween_property(palo, "position", centro_palo, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(joystick_node, "position", posicion_inicial_joystick, 0.2).set_trans(Tween.TRANS_SINE)

	if event is InputEventScreenDrag and dragging and event.index == touch_index:
		var centro_global  = base.global_position
		var vector         = event.position - centro_global
		var limit          = radio * joystick_node.scale.x
		var vector_limitado = vector.limit_length(limit)
		palo.global_position = centro_global + vector_limitado + (centro_palo * joystick_node.scale)
		direccion = vector_limitado.normalized()

# ─────────────────────────────────────────────────────────────
#  CORAZONES — actualiza con el jugador LOCAL
# ─────────────────────────────────────────────────────────────
func actualizar_vidas(salud: int) -> void:
	if not contenedor_corazones: return
	var corazones = contenedor_corazones.get_children()
	for i in range(corazones.size()):
		var corazon   = corazones[i]
		var valor_base = i * 2
		if salud >= valor_base + 2:
			corazon.texture = tex_lleno
		elif salud >= valor_base + 1:
			corazon.texture = tex_mitad
		else:
			corazon.texture = tex_vacio

# ─────────────────────────────────────────────────────────────
#  MENÚ PAUSA
# ─────────────────────────────────────────────────────────────
func _on_resume_pressed() -> void:
	menu_pausa.hide()
	_toggle_hud(true)
	if not NetworkManager.is_multiplayer_active():
		get_tree().paused = false
	var focused = get_viewport().gui_get_focus_owner()
	if focused:
		focused.release_focus()

func _on_menu_pressed() -> void:
	var inv = get_node_or_null("InventarioUI")
	if inv and inv.has_method("esta_abierto") and inv.esta_abierto():
		inv.cerrar()
		return
	if menu_pausa.visible:
		menu_pausa.hide()
		_toggle_hud(true)
		if not NetworkManager.is_multiplayer_active():
			get_tree().paused = false
		if boton_menu: boton_menu.z_index = 0
		_usando_mando_o_teclado_pausa = false
		var focused = get_viewport().gui_get_focus_owner()
		if focused:
			focused.release_focus()
	else:
		menu_pausa.show()
		_toggle_hud(false)
		if not NetworkManager.is_multiplayer_active():
			get_tree().paused = true
		if boton_menu: boton_menu.z_index = 100
		_usando_mando_o_teclado_pausa = true
		if menu_pausa.has_method("focus_first_button"):
			menu_pausa.focus_first_button()

func _toggle_hud(visible_state: bool) -> void:
	if contenedor_corazones: contenedor_corazones.visible = visible_state
	if boton_attack:         boton_attack.visible  = visible_state
	if boton_guard:          boton_guard.visible   = visible_state and SaveManager.dificultad_juego != 2
	if boton_interact:       boton_interact.visible = visible_state
	if joystick_node:        joystick_node.visible = visible_state
	if guard_timer_label:    guard_timer_label.visible = visible_state and SaveManager.dificultad_juego != 2
	if boton_menu:           boton_menu.visible    = visible_state

	# Ocultar también el contador de estadísticas del escenario si existe
	var escenario = get_tree().current_scene
	if escenario and "label_contador_muertes" in escenario:
		var lbl = escenario.label_contador_muertes
		if is_instance_valid(lbl):
			lbl.visible = visible_state

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_menu_pressed()

# ─────────────────────────────────────────────────────────────
#  BOTONES TÁCTILES — callbacks
# ─────────────────────────────────────────────────────────────
func _on_guard_pressed() -> void:
	var player = _get_local_player()
	if player and player.has_method("_start_guard"):
		player._start_guard()

func _on_guard_released() -> void:
	var player = _get_local_player()
	if player and player.has_method("_stop_guard"):
		player._stop_guard()

func _on_menu_released()    -> void: pass
func _on_interact_pressed() -> void: pass
func _on_interact_released()-> void: pass
func _on_attack_pressed()   -> void: pass
func _on_attack_released()  -> void: pass
