extends Area2D

@export var duracion_efecto: float = 5.0

func _on_body_entered(body: Node2D) -> void:
	# Verifica si quien tocó la poción es el jugador
	if body.is_in_group("jugador"):
		
		# Valida si ya tiene la poción activa para no acumularla
		if body.get("is_speed_boost_active"):
			_mostrar_aviso_en_pantalla()
			return
			
		# Activa el boost de velocidad en el script del caballero
		body.is_speed_boost_active = true
		
		# Temporizador para apagar el efecto a los 5 segundos
		var timer = get_tree().create_timer(duracion_efecto)
		timer.timeout.connect(func():
			if is_instance_valid(body):
				body.is_speed_boost_active = false
		)
		
		# Elimina la poción del mapa
		queue_free()

func _mostrar_aviso_en_pantalla():
	var canvas = CanvasLayer.new()
	var label = Label.new()
	label.text = "Ya tienes una poción en uso, espera a que acabe su efecto para usar otra."
	label.add_theme_color_override("font_color", Color(1, 0, 0)) # Rojo de advertencia
	label.position = Vector2(200, 100)
	
	canvas.add_child(label)
	get_tree().current_scene.add_child(canvas)
	
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		canvas.queue_free()
	)
