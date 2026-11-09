extends Node

const SAVE_DIR = "user://saves/"
var nombre_jugador: String = ""
var partida_actual: String = ""
var escribiendo_texto: bool = false
var dificultad_juego: int = 1 # 0 = Facil, 1 = Medio, 2 = Dificil
var modo_juego: String = "Arcade"

func _ready():
	var dir = DirAccess.open("user://")
	if dir == null:
		push_error("No se pudo abrir el directorio user:// para inicializar los guardados.")
		return
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	cargar_config()

func guardar_datos_con_nombre(nombre_partida: String, datos: Dictionary) -> void:
	datos["nombre_jugador"] = nombre_jugador
	datos["nombre_partida"] = nombre_partida
	partida_actual = nombre_partida # Rastrear como la partida actual
	datos["fecha"] = Time.get_datetime_string_from_system(false, true)
	
	var modo = "Historia"
	if "pruebas" in String(datos.get("escena", "")).to_lower():
		modo = "Pruebas"
	datos["modo"] = modo
	
	# Reemplazar espacios para el nombre de archivo
	var safe_name = nombre_partida.validate_filename()
	var path = SAVE_DIR + safe_name + ".save"
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir archivo de guardado.")
		return
	
	file.store_string(JSON.stringify(datos))
	file.close()

func obtener_lista_partidas() -> Array:
	var partidas = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".save"):
				var datos = cargar_datos_ruta(SAVE_DIR + file_name)
				if not datos.is_empty():
					datos["archivo"] = SAVE_DIR + file_name
					partidas.append(datos)
			file_name = dir.get_next()
	
	# Ordenar por fecha descendente (más recientes primero)
	partidas.sort_custom(func(a, b): return a.get("fecha", "") > b.get("fecha", ""))
	return partidas

func cargar_datos_ruta(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	
	var contenido = file.get_as_text()
	file.close()
	
	var resultado = JSON.parse_string(contenido)
	if typeof(resultado) == TYPE_DICTIONARY:
		return resultado
	
	return {}

# Función legacy por si se necesita
func guardar_datos(datos: Dictionary) -> void:
	guardar_datos_con_nombre("AutoSave", datos)

func cargar_datos() -> Dictionary:
	var lista = obtener_lista_partidas()
	if lista.size() > 0:
		var datos = lista[0]
		if datos.has("nombre_jugador"):
			nombre_jugador = datos["nombre_jugador"]
		return datos
	return {}

func existe_partida() -> bool:
	return obtener_lista_partidas().size() > 0

func borrar_partida(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		
func cargar_y_posicionar_datos(datos: Dictionary) -> void:
	if datos.is_empty():
		return
	
	if datos.has("nombre_jugador"):
		nombre_jugador = datos["nombre_jugador"]
	if datos.has("nombre_partida"):
		partida_actual = datos["nombre_partida"]
	
	var old_scene = get_tree().current_scene
	
	# 1. Cambiamos la escena
	get_tree().change_scene_to_file(datos["escena"])
	
	# 2. Esperamos a que la escena vieja se libere y cargue la nueva
	while get_tree().current_scene == old_scene or get_tree().current_scene == null:
		await get_tree().process_frame
	
	# 3. Esperamos 2 frames para la inicialización (_ready) de los nuevos nodos
	for i in range(2):
		await get_tree().process_frame
	
	# 4. Buscamos y restauramos al jugador
	var player = get_tree().get_first_node_in_group("Jugador")
	if player == null:
		player = get_tree().get_first_node_in_group("jugador")
		
	if player:
		if player is CharacterBody2D:
			player.velocity = Vector2.ZERO
			
		player.global_position = Vector2(datos["pos_x"], datos["pos_y"])
		
		# Restaurar nivel y estadísticas
		if datos.has("nivel") and "nivel" in player:
			player.nivel = datos["nivel"]
		if datos.has("experiencia") and "experiencia" in player:
			player.experiencia = datos["experiencia"]
		if datos.has("fuerza") and "fuerza" in player:
			player.fuerza = datos["fuerza"]
		if datos.has("salud_actual") and "salud_actual" in player:
			player.salud_actual = datos["salud_actual"]
			
		# Recalcular estadísticas derivadas del jugador
		if "velocidad_base" in player and "speed" in player:
			player.speed = min(600.0, player.velocidad_base + (player.nivel * 5.0))
		# Cargar objetos y equipamiento tras recuperar nivel y fuerza.
		# Las partidas antiguas (sin inventario_equipo) siguen siendo validas.
		if player.has_method("restaurar_estado_equipo"):
			player.restaurar_estado_equipo(datos.get("inventario_equipo", {}))
		elif "dano_base" in player and "poder_ataque" in player:
			player.poder_ataque = player.dano_base + floor(player.fuerza / 3.0) + floor(player.nivel / 2.0)
			
		# Forzar refresco visual de nivel y vida
		if player.has_method("_actualizar_ui_nivel"):
			player._actualizar_ui_nivel()
		if player.has_method("actualizar_ui_corazones"):
			player.actualizar_ui_corazones()
			
		print("¡Carga exitosa! Jugador posicionado en: ", player.global_position, 
			" | Nivel: ", player.nivel, " | Fuerza: ", player.fuerza, " | Salud: ", player.salud_actual)
	else:
		print("Error: No se encontró al jugador en los grupos 'Jugador'/'jugador'")

	# 5. Restaurar progreso del escenario si aplica
	var escenario = get_tree().current_scene
	if escenario:
		if datos.has("enemigos_derrotados") and "enemigos_derrotados" in escenario:
			escenario.enemigos_derrotados = datos["enemigos_derrotados"]
		if datos.has("arqueros_derrotados") and "arqueros_derrotados" in escenario:
			escenario.arqueros_derrotados = datos["arqueros_derrotados"]
		if datos.has("lanceros_derrotados") and "lanceros_derrotados" in escenario:
			escenario.lanceros_derrotados = datos["lanceros_derrotados"]
		if datos.has("vikingos_derrotados") and "vikingos_derrotados" in escenario:
			escenario.vikingos_derrotados = datos["vikingos_derrotados"]
		if datos.has("tiempo_partida") and "tiempo_partida" in escenario:
			escenario.tiempo_partida = datos["tiempo_partida"]
		if datos.has("dragon_spawned") and "dragon_spawned" in escenario:
			escenario.dragon_spawned = datos["dragon_spawned"]

		# Cargar el mapa correcto si el índice es mayor a 0
		if datos.has("indice_mapa_actual") and "indice_mapa_actual" in escenario:
			var idx = datos["indice_mapa_actual"]
			escenario.indice_mapa_actual = idx
			if idx > 0 and idx <= escenario.progresion_mapas.size():
				var config = escenario.progresion_mapas[idx - 1]
				var tilemap_viejo = escenario.get_node_or_null("TileMapLayer")
				if tilemap_viejo:
					tilemap_viejo.name = "TileMapLayer_Old"
					tilemap_viejo.queue_free()
				var nuevo_mapa = config["escena"].instantiate()
				nuevo_mapa.name = "TileMapLayer"
				escenario.add_child(nuevo_mapa)
				escenario.move_child(nuevo_mapa, 0)
				# Esperamos un frame para que se inicialice la zona de spawn
				await escenario.get_tree().process_frame
				if escenario.has_method("_calcular_limites"):
					escenario._calcular_limites()

		if datos.has("oleada_actual") and "oleada_actual" in escenario:
			# Restamos 1 porque _subir_dificultad() incrementa la oleada en 1
			escenario.oleada_actual = datos["oleada_actual"] - 1
			
		# Sincronizar la UI de muertes y recalcular parámetros de spawn enemigos
		if escenario.has_method("_subir_dificultad"):
			escenario._subir_dificultad()

		# Restaurar gatos (mascotas) si existen en los datos guardados
		if datos.has("gatos"):
			# Primero, limpiar cualquier gato salvaje/inicial preexistente en la escena
			for m in get_tree().get_nodes_in_group("mascotas"):
				if is_instance_valid(m):
					m.queue_free()
			
			var gata_scene = load("res://Scenes/UI/Personajes/Gata/gata.tscn")
			if gata_scene:
				for cat_data in datos["gatos"]:
					var cat_instance = gata_scene.instantiate()
					cat_instance.global_position = Vector2(cat_data["pos_x"], cat_data["pos_y"])
					if cat_data.has("state"):
						cat_instance.state = cat_data["state"]
					if cat_data.has("target_peer_id"):
						cat_instance.target_peer_id = cat_data["target_peer_id"]
					if cat_data.has("current_health"):
						cat_instance.current_health = cat_data["current_health"]
					if cat_data.has("max_health"):
						cat_instance.max_health = cat_data["max_health"]
					if cat_data.has("enemies_killed_since_heal"):
						cat_instance.enemies_killed_since_heal = cat_data["enemies_killed_since_heal"]
					
					escenario.add_child(cat_instance, true)
					
					# Si está adoptado, configurar referencia del dueño y actualizar label
					if cat_instance.state == 1: # State.ADOPTED is 1
						cat_instance.player = PlayerRegistry.get_player(cat_instance.target_peer_id)
						var gamertag = ""
						if NetworkManager.is_multiplayer_active():
							gamertag = NetworkManager.get_gamertag(cat_instance.target_peer_id)
						else:
							gamertag = SaveManager.nombre_jugador
						if gamertag == "": gamertag = "Caballero"
						
						var lbl_interact = cat_instance.get_node_or_null("LabelInteract")
						if lbl_interact:
							lbl_interact.text = "Gato de %s" % gamertag
							lbl_interact.add_theme_color_override("font_color", Color.GOLD)
							lbl_interact.visible = true

func cargar_y_posicionar() -> void:
	var datos = cargar_datos()
	cargar_y_posicionar_datos(datos)

# --- PERSISTENCIA DE CONFIGURACIÓN ---
func guardar_config() -> void:
	var config = {"nombre_jugador": nombre_jugador}
	var file = FileAccess.open("user://config.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config))
		file.close()

func cargar_config() -> void:
	if FileAccess.file_exists("user://config.json"):
		var file = FileAccess.open("user://config.json", FileAccess.READ)
		if file:
			var contenido = file.get_as_text()
			file.close()
			var config = JSON.parse_string(contenido)
			if typeof(config) == TYPE_DICTIONARY:
				if config.has("nombre_jugador"):
					nombre_jugador = config["nombre_jugador"]
