## Objeto de equipo recogible. Arcade individual; no afecta a la red.
extends Node2D

const EquipoAssets = preload("res://Scenes/UI/Objetos/equipo_assets.gd")

@export var item_id: String = "espada_hierro"

const DISTANCIA_RECOGER: float = 92.0
var jugador_cercano: Node = null
var etiqueta: Label


func _ready() -> void:
	add_to_group("loot_equipamiento")
	z_index = 4
	# The custom 48x48 pixel-art icon replaces the old placeholder drawing.
	var icono = Sprite2D.new()
	icono.texture = EquipoAssets.obtener_textura(item_id)
	icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(icono)
	etiqueta = Label.new()
	etiqueta.position = Vector2(-100, -65)
	etiqueta.custom_minimum_size = Vector2(200, 44)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 13)
	etiqueta.add_theme_color_override("font_color", Color.WHITE)
	etiqueta.add_theme_color_override("font_outline_color", Color.BLACK)
	etiqueta.add_theme_constant_override("outline_size", 4)
	add_child(etiqueta)
	_actualizar_etiqueta()
	queue_redraw()


func _process(_delta: float) -> void:
	if NetworkManager.is_multiplayer_active():
		return
	var jugador = PlayerRegistry.get_local_player()
	if not is_instance_valid(jugador) or jugador.get("is_dead") == true:
		_set_jugador_cercano(null)
		return
	var distancia = jugador.global_position.distance_to(global_position)
	_set_jugador_cercano(jugador if distancia <= DISTANCIA_RECOGER else null)
	if jugador_cercano != null and Input.is_action_just_pressed("interact"):
		# Cuando hay varios objetos juntos, solo se recoge el mas cercano.
		for otro in get_tree().get_nodes_in_group("loot_equipamiento"):
			if otro != self and is_instance_valid(otro) and not otro.is_queued_for_deletion():
				if jugador.global_position.distance_to(otro.global_position) < distancia:
					return
		if jugador.has_method("agregar_equipo") and jugador.agregar_equipo(item_id):
			queue_free()


func _set_jugador_cercano(jugador: Node) -> void:
	if jugador_cercano == jugador:
		return
	jugador_cercano = jugador
	_actualizar_etiqueta()
	queue_redraw()


func _actualizar_etiqueta() -> void:
	if not is_instance_valid(etiqueta):
		return
	var jugador = PlayerRegistry.get_local_player()
	var nombre = item_id
	if is_instance_valid(jugador) and jugador.has_method("obtener_datos_equipo"):
		nombre = str(jugador.obtener_datos_equipo(item_id).get("nombre", item_id))
	etiqueta.text = "%s\n[E / Interactuar] Recoger" % nombre if jugador_cercano else nombre


func _draw() -> void:
	# Pickup ring behind the actual equipment sprite.
	var color_objeto := Color(0.95, 0.75, 0.28) if item_id.begins_with("espada") else Color(0.35, 0.75, 1.0)
	var radio: float = 27.0 if jugador_cercano else 24.0
	draw_circle(Vector2.ZERO, radio, Color(0.06, 0.06, 0.12, 0.72))
	draw_arc(Vector2.ZERO, radio, 0.0, TAU, 32, color_objeto, 2.0)
