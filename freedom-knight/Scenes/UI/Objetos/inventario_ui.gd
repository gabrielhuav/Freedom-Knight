## Interfaz de inventario accesible con I o boton tactil.
## Solo Arcade individual. No altera el estado de la partida multijugador.
extends Control

var boton_mochila: Button
var capa_oscura: ColorRect
var ventana: PanelContainer
var lista: VBoxContainer
var resumen: Label
var abierto: bool = false
var jugador_actual: Node = null


func _ready() -> void:
	name = "InventarioUI"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crear_interfaz()


func _process(_delta: float) -> void:
	if NetworkManager.is_multiplayer_active():
		if abierto:
			cerrar()
		boton_mochila.hide()
		return
	boton_mochila.visible = not abierto
	if not is_instance_valid(jugador_actual):
		jugador_actual = PlayerRegistry.get_local_player()
		if is_instance_valid(jugador_actual) and jugador_actual.has_signal("inventario_actualizado"):
			if not jugador_actual.inventario_actualizado.is_connected(_refrescar):
				jugador_actual.inventario_actualizado.connect(_refrescar)


func _input(event: InputEvent) -> void:
	if SaveManager.escribiendo_texto or NetworkManager.is_multiplayer_active():
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_I:
		alternar()
		get_viewport().set_input_as_handled()


func alternar() -> void:
	if abierto:
		cerrar()
	else:
		abrir()


func esta_abierto() -> bool:
	return abierto


func abrir() -> void:
	var hud = get_parent()
	if hud and hud.get("menu_pausa") and hud.menu_pausa.visible:
		return
	if not is_instance_valid(jugador_actual):
		jugador_actual = PlayerRegistry.get_local_player()
	if not is_instance_valid(jugador_actual) or jugador_actual.get("is_dead") == true:
		return
	abierto = true
	capa_oscura.show()
	boton_mochila.hide()
	_refrescar()
	get_tree().paused = true


func cerrar() -> void:
	abierto = false
	capa_oscura.hide()
	boton_mochila.show()
	if not NetworkManager.is_multiplayer_active():
		get_tree().paused = false


func _crear_interfaz() -> void:
	boton_mochila = Button.new()
	boton_mochila.text = "Mochila [I]"
	boton_mochila.position = Vector2(135, 30)
	boton_mochila.custom_minimum_size = Vector2(115, 48)
	boton_mochila.add_theme_font_size_override("font_size", 16)
	boton_mochila.pressed.connect(alternar)
	add_child(boton_mochila)

	capa_oscura = ColorRect.new()
	capa_oscura.color = Color(0.02, 0.025, 0.065, 0.87)
	capa_oscura.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	capa_oscura.mouse_filter = Control.MOUSE_FILTER_STOP
	capa_oscura.hide()
	add_child(capa_oscura)

	ventana = PanelContainer.new()
	ventana.set_anchors_preset(Control.PRESET_CENTER)
	ventana.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ventana.grow_vertical = Control.GROW_DIRECTION_BOTH
	ventana.custom_minimum_size = Vector2(520, 440)
	ventana.position = Vector2(-260, -220)
	var fondo = StyleBoxFlat.new()
	fondo.bg_color = Color(0.09, 0.11, 0.18, 0.98)
	fondo.border_color = Color(0.64, 0.47, 0.20)
	fondo.set_border_width_all(3)
	fondo.set_corner_radius_all(12)
	ventana.add_theme_stylebox_override("panel", fondo)
	capa_oscura.add_child(ventana)

	var contenido = VBoxContainer.new()
	contenido.add_theme_constant_override("separation", 10)
	ventana.add_child(contenido)

	var cabecera = HBoxContainer.new()
	contenido.add_child(cabecera)
	var titulo = Label.new()
	titulo.text = "MOCHILA Y EQUIPAMIENTO"
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titulo.add_theme_font_size_override("font_size", 22)
	titulo.add_theme_color_override("font_color", Color.GOLD)
	cabecera.add_child(titulo)
	var cerrar_btn = Button.new()
	cerrar_btn.text = "Cerrar"
	cerrar_btn.custom_minimum_size = Vector2(90, 44)
	cerrar_btn.pressed.connect(cerrar)
	cabecera.add_child(cerrar_btn)

	resumen = Label.new()
	resumen.add_theme_font_size_override("font_size", 16)
	contenido.add_child(resumen)

	var ayuda = Label.new()
	ayuda.text = "Pulsa un objeto para equiparlo o desequiparlo."
	contenido.add_child(ayuda)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 270)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contenido.add_child(scroll)
	lista = VBoxContainer.new()
	lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lista)
	# Ajustar dimensiones al dispositivo cuando aparezca en pantalla.
	capa_oscura.resized.connect(_ajustar_ventana)
	call_deferred("_ajustar_ventana")


func _ajustar_ventana() -> void:
	if not is_instance_valid(ventana):
		return
	var tam = get_viewport_rect().size
	var ancho = minf(540.0, maxf(300.0, tam.x - 28.0))
	var alto = minf(470.0, maxf(270.0, tam.y - 28.0))
	ventana.custom_minimum_size = Vector2.ZERO
	ventana.size = Vector2(ancho, alto)
	ventana.position = (tam - ventana.size) * 0.5


func _refrescar() -> void:
	if not is_instance_valid(lista) or not is_instance_valid(jugador_actual):
		return
	for hijo in lista.get_children():
		hijo.queue_free()
	var objetos: Array = jugador_actual.inventario_equipo
	var equipado: Dictionary = jugador_actual.equipo_equipado
	var arma: String = str(equipado.get("arma", ""))
	var armadura: String = str(equipado.get("armadura", ""))
	resumen.text = "Espacios: %d / %d     Ataque: %d     Armadura: +%d" % [
		objetos.size(), jugador_actual.CAPACIDAD_INVENTARIO,
		jugador_actual.poder_ataque, jugador_actual.obtener_defensa_equipo()
	]
	if objetos.is_empty():
		var sin_objetos = Label.new()
		sin_objetos.text = "Mochila vacia. Derrota enemigos y recoge botines con E."
		lista.add_child(sin_objetos)
		return
	for i in range(objetos.size()):
		var id: String = str(objetos[i])
		var info: Dictionary = jugador_actual.obtener_datos_equipo(id)
		var texto: String = str(info.get("nombre", id))
		var bonificacion: int = int(info.get("ataque", 0)) if info.get("tipo") == "arma" else int(info.get("defensa", 0))
		texto += "   +%d %s" % [bonificacion, "ataque" if info.get("tipo") == "arma" else "defensa"]
		if (info.get("tipo") == "arma" and arma == id) or (info.get("tipo") == "armadura" and armadura == id):
			texto = "[EQUIPADO] " + texto
		var indice := i
		var boton = Button.new()
		boton.text = texto
		boton.custom_minimum_size = Vector2(0, 48)
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.pressed.connect(func(): jugador_actual.equipar_equipo(indice))
		lista.add_child(boton)
