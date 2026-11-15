## Pruebas de comportamiento. Ejecutar en copia con user:// aislado.
extends Node2D

const HEROE = preload("res://Scenes/UI/Personajes/Heroe/caballero.tscn")
const POCION = preload("res://Scenes/UI/PocionesHechizos/PocionDeVida.tscn")
const GUARDIAN = preload("res://Scenes/UI/Personajes/Villanos/guardian_sombras/guardian_sombras.tscn")
const INVENTARIO = preload("res://Scenes/UI/Objetos/inventario_ui.gd")

var fallos: int = 0
var comprobaciones: int = 0
var jugador: Node2D
var fixture: Node2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().create_timer(40.0).timeout.connect(func():
		push_error("La suite excedio 40 segundos")
		get_tree().quit(2)
	)
	call_deferred("probar")


func comprobar(condicion: bool, mensaje: String) -> void:
	comprobaciones += 1
	print(("PASS: " if condicion else "FAIL: ") + mensaje)
	if not condicion:
		fallos += 1


func paso(mover: bool) -> void:
	if mover:
		Input.action_press("right")
	else:
		Input.action_release("right")
	jugador._physics_process(1.0 / 60.0)


func avisos() -> Array[Node]:
	var resultado: Array[Node] = []
	for nodo in get_tree().root.find_children("*", "CanvasLayer", true, false):
		if nodo.layer == 100:
			resultado.append(nodo)
	return resultado


func nueva_pocion():
	var pocion = POCION.instantiate()
	fixture.add_child(pocion)
	pocion.set_process(false)
	pocion.jugador_cerca = jugador
	return pocion


func probar() -> void:
	# El controlador queda fuera de current_scene para sobrevivir al cargar.
	NetworkManager.cleanup()
	multiplayer.multiplayer_peer = null
	fixture = Node2D.new()
	get_tree().root.add_child(fixture)
	get_tree().current_scene = fixture
	jugador = HEROE.instantiate()
	fixture.add_child(jugador)
	jugador.set_physics_process(false)
	await get_tree().process_frame
	await get_tree().process_frame
	probar_sprint()
	await probar_pociones()
	await probar_equipo()
	await probar_guardado()
	await probar_guardian()
	await probar_escenario()
	get_tree().paused = false
	Input.action_release("right")
	if is_instance_valid(fixture):
		fixture.queue_free()
	await get_tree().process_frame
	print("RESULTADO: %d comprobaciones, %d fallos" % [comprobaciones, fallos])
	get_tree().quit(1 if fallos else 0)


func probar_sprint() -> void:
	paso(true)
	comprobar(not jugador.is_sprinting and is_equal_approx(jugador.velocity.length(), jugador.speed), "primer movimiento a velocidad normal")
	paso(false)
	comprobar(jugador.velocity == Vector2.ZERO, "soltar detiene el movimiento")
	paso(true)
	comprobar(jugador.is_sprinting and is_equal_approx(jugador.velocity.length(), jugador.speed * 1.5), "doble toque activa sprint 1.5x")
	jugador.is_attacking = true
	paso(true)
	comprobar(not jugador.is_sprinting and jugador.velocity == Vector2.ZERO, "ataque cancela sprint")
	jugador.is_attacking = false
	paso(true)
	comprobar(not jugador.is_sprinting, "fin de ataque no reactiva sprint con tecla mantenida")
	paso(false)
	paso(true)
	comprobar(jugador.is_sprinting, "un nuevo doble toque vuelve a activar sprint")
	jugador.is_guarding = true
	paso(true)
	comprobar(not jugador.is_sprinting and jugador.velocity == Vector2.ZERO, "defensa cancela sprint")
	jugador.is_guarding = false
	paso(true)
	comprobar(not jugador.is_sprinting, "fin de defensa no reactiva sprint con tecla mantenida")
	paso(false)
	jugador.tiempo_ultimo_toque = Time.get_ticks_msec() - 400
	paso(true)
	comprobar(not jugador.is_sprinting, "toque fuera de ventana de 300ms no activa sprint")
	paso(false)


func probar_pociones() -> void:
	jugador.salud_actual = jugador.vida_maxima
	var pocion = nueva_pocion()
	await get_tree().process_frame
	pocion._usar_pocion()
	comprobar(jugador.salud_actual == jugador.vida_maxima, "vida llena no cambia salud")
	comprobar(not pocion.is_queued_for_deletion(), "vida llena conserva pocion")
	comprobar(avisos().size() == 1, "aviso visible con vida llena")
	await get_tree().create_timer(2.2).timeout
	comprobar(avisos().is_empty(), "aviso desaparece sin consumir pocion")
	pocion._usar_pocion()
	jugador.salud_actual = jugador.vida_maxima - 1
	pocion._usar_pocion()
	await get_tree().process_frame
	comprobar(jugador.salud_actual == jugador.vida_maxima, "curacion respeta salud maxima")
	await get_tree().process_frame
	comprobar(not is_instance_valid(pocion), "curacion consume pocion")
	await get_tree().create_timer(2.2).timeout
	comprobar(avisos().is_empty(), "aviso se limpia aunque la pocion haya desaparecido")
	var otra_escena = Node2D.new()
	get_tree().root.add_child(otra_escena)
	get_tree().current_scene = otra_escena
	pocion = POCION.instantiate()
	otra_escena.add_child(pocion)
	pocion.set_process(false)
	pocion.jugador_cerca = jugador
	pocion._usar_pocion()
	otra_escena.queue_free()
	get_tree().current_scene = fixture
	await get_tree().process_frame
	await get_tree().process_frame
	comprobar(avisos().is_empty(), "salir de escena elimina aviso inmediatamente")
	await get_tree().create_timer(2.2).timeout
	comprobar(avisos().is_empty(), "temporizador no deja aviso tras cambiar de escena")


func probar_equipo() -> void:
	comprobar(not jugador.agregar_equipo("inexistente"), "rechaza equipo desconocido")
	comprobar(jugador.agregar_equipo("espada_sombras"), "recoge espada")
	var ataque_base: int = jugador.poder_ataque
	jugador.equipar_equipo(0)
	comprobar(jugador.poder_ataque == ataque_base + 4, "espada aplica bonus de ataque")
	jugador.equipar_equipo(0)
	comprobar(jugador.poder_ataque == ataque_base, "desequipar retira bonus")
	jugador.equipar_equipo(0)
	comprobar(jugador.agregar_equipo("armadura_acero"), "recoge armadura")
	jugador.equipar_equipo(1)
	comprobar(jugador.obtener_defensa_equipo() == 3, "armadura aplica bonus de defensa")
	jugador.salud_actual = 10
	jugador.recibir_dano(4)
	comprobar(jugador.salud_actual == 9, "armadura reduce dano en combate")
	for _i in range(10):
		jugador.agregar_equipo("espada_hierro")
	comprobar(not jugador.agregar_equipo("armadura_cuero") and jugador.inventario_equipo.size() == 12, "rechaza objeto numero 13")
	var ui = Control.new()
	ui.set_script(INVENTARIO)
	fixture.add_child(ui)
	ui.jugador_actual = jugador
	ui.boton_mochila.pressed.emit()
	comprobar(ui.esta_abierto() and get_tree().paused, "boton mochila abre y pausa")
	await get_tree().process_frame
	var equipados: int = 0
	for boton in ui.lista.get_children():
		if boton is Button and boton.text.begins_with("[EQUIPADO]"):
			equipados += 1
	comprobar(equipados == 2, "solo un arma y una armadura figuran equipadas")
	var tecla = InputEventKey.new()
	tecla.keycode = KEY_I
	tecla.pressed = true
	ui._input(tecla)
	comprobar(not ui.esta_abierto() and not get_tree().paused, "tecla I cierra y reanuda")
	var peer = ENetMultiplayerPeer.new()
	var error: int = peer.create_server(0, 1)
	comprobar(error == OK, "sesion ENet local de prueba disponible")
	if error == OK:
		multiplayer.multiplayer_peer = peer
		var estado: Dictionary = jugador.obtener_estado_equipo()
		jugador.inventario_equipo.clear()
		comprobar(not jugador.agregar_equipo("espada_hierro"), "inventario bloqueado en multijugador")
		ui._process(0.0)
		comprobar(not ui.boton_mochila.visible, "mochila oculta en multijugador")
		multiplayer.multiplayer_peer = null
		peer.close()
		jugador.restaurar_estado_equipo(estado)
	ui.queue_free()
	await get_tree().process_frame


func probar_guardado() -> void:
	var menu = Control.new()
	menu.set_script(load("res://Scenes/UI/MenuPausa.gd"))
	fixture.add_child(menu)
	menu._on_texture_button_pressed_guardar()
	var entrada: LineEdit = menu.find_children("*", "LineEdit", true, false)[0]
	entrada.text = "__QA_PR2_desde_menu"
	for boton in menu.find_children("*", "Button", true, false):
		if boton.text == "Guardar":
			boton.pressed.emit()
	var desde_menu: Dictionary = SaveManager.cargar_datos_ruta("user://saves/__QA_PR2_desde_menu.save")
	comprobar(desde_menu.get("inventario_equipo", {}).get("inventario", []).size() == 12, "menu de pausa guarda al jugador y no a la hitbox")
	comprobar(desde_menu.get("salud_actual") == jugador.salud_actual, "menu de pausa guarda la salud real")
	menu.queue_free()
	SaveManager.escribiendo_texto = false
	var datos = {
		"escena": "res://tests/save_fixture.tscn", "pos_x": 120, "pos_y": 80,
		"nivel": 1, "fuerza": 0, "salud_actual": 8,
		"inventario_equipo": jugador.obtener_estado_equipo()
	}
	SaveManager.guardar_datos_con_nombre("__QA_PR2_regresion", datos)
	var cargados: Dictionary = SaveManager.cargar_datos_ruta("user://saves/__QA_PR2_regresion.save")
	comprobar(cargados.get("inventario_equipo", {}) == datos["inventario_equipo"], "archivo de guardado conserva inventario y equipado")
	await SaveManager.cargar_y_posicionar_datos(cargados)
	fixture = get_tree().current_scene
	jugador = PlayerRegistry.get_local_player()
	jugador.set_physics_process(false)
	comprobar(jugador.inventario_equipo.size() == 12 and jugador.equipo_equipado["arma"] == "espada_sombras", "cargar partida restaura objetos y arma")
	comprobar(jugador.poder_ataque == 6 and jugador.obtener_defensa_equipo() == 3, "cargar partida recalcula bonos")
	comprobar(jugador.global_position == Vector2(120, 80) and jugador.salud_actual == 8, "cargar partida conserva posicion y salud")
	cargados.erase("inventario_equipo")
	await SaveManager.cargar_y_posicionar_datos(cargados)
	fixture = get_tree().current_scene
	jugador = PlayerRegistry.get_local_player()
	jugador.set_physics_process(false)
	comprobar(jugador.inventario_equipo.is_empty() and jugador.poder_ataque == 2, "partida antigua sin equipo sigue cargando")
	SaveManager.borrar_partida("user://saves/__QA_PR2_regresion.save")
	SaveManager.borrar_partida("user://saves/__QA_PR2_desde_menu.save")


func probar_guardian() -> void:
	jugador.vida_maxima = 100
	jugador.salud_actual = 100
	jugador.global_position = Vector2.ZERO
	var jefe = GUARDIAN.instantiate()
	fixture.add_child(jefe)
	jefe.global_position = Vector2(100, 0)
	jefe.set_physics_process(false)
	var cuadros: SpriteFrames = jefe.animated_sprite.sprite_frames
	comprobar(cuadros.get_frame_count("correr") == 4 and cuadros.has_animation("morir"), "Guardian carga animaciones propias")
	comprobar(jefe.barra_vida.max_value == jefe.vida_maxima, "barra de vida del Guardian coincide con sus stats")
	jugador.global_position = Vector2(1000, 0)
	jefe._physics_process(1.0 / 60.0)
	comprobar(jefe.velocity.x > 0 and jefe.animated_sprite.flip_h, "Guardian mira a la derecha al perseguir a la derecha")
	jugador.global_position = Vector2(-1000, 0)
	jefe._physics_process(1.0 / 60.0)
	comprobar(jefe.velocity.x < 0 and not jefe.animated_sprite.flip_h, "Guardian mira a la izquierda al perseguir a la izquierda")
	jugador.global_position = Vector2.ZERO
	jefe.global_position = Vector2(100, 0)
	jefe.recibir_dano(int(ceil(jefe.vida_maxima * 0.51)))
	comprobar(jefe.fase_dos and jefe.attack_cooldown < 1.5, "mitad de salud activa segunda fase")
	var salud_antes: int = jugador.salud_actual
	jefe._lanzar_onda_sombras()
	comprobar(jefe.find_children("*", "Line2D", true, false).size() == 1, "onda anticipa visualmente el ataque")
	await get_tree().create_timer(0.9).timeout
	comprobar(jugador.salud_actual < salud_antes, "onda causa dano en radio")
	comprobar(not jefe.esta_atacando, "onda libera estado de ataque")
	var muertes: Array[int] = [0]
	jefe.murio.connect(func(_pos): muertes[0] += 1)
	jefe.recibir_dano(10000)
	comprobar(jefe.is_dead and muertes[0] == 1, "derrota emite una sola muerte")
	await get_tree().create_timer(1.4).timeout
	comprobar(not is_instance_valid(jefe), "Guardian se elimina tras morir")


func probar_escenario() -> void:
	fixture.queue_free()
	await get_tree().process_frame
	SaveManager.modo_juego = "Arcade"
	fixture = load("res://Scenes/UI/Escenas/escenario_pruebas.tscn").instantiate()
	get_tree().root.add_child(fixture)
	get_tree().current_scene = fixture
	await get_tree().create_timer(1.7).timeout
	fixture._spawnear_guardian()
	comprobar(fixture.jefe_activo, "Arcade incorpora encuentro del Guardian")
	var guardian = fixture.find_child("GuardianSombras_*", false, false)
	comprobar(is_instance_valid(guardian), "Guardian aparece en escenario real")
	if is_instance_valid(guardian):
		guardian.recibir_dano(10000)
		comprobar(not fixture.jefe_activo, "derrota desbloquea progresion y enemigos")
		var anteriores: int = fixture.caballeros_vivos
		fixture._spawnear_un_enemigo()
		comprobar(fixture.caballeros_vivos > anteriores, "enemigos normales siguen apareciendo")
	await get_tree().create_timer(1.4).timeout
	# Seleccionar de forma reproducible la opcion Guardian de Boss Rush.
	fixture.es_boss_rush = true
	fixture.jefe_activo = false
	var semilla_guardian: int = 0
	for valor in range(100):
		seed(valor)
		if randi_range(0, 2) == 1:
			semilla_guardian = valor
			break
	seed(semilla_guardian)
	await fixture._mantener_jefes()
	var jefe_rush = fixture.find_child("Guardian_*", false, false)
	comprobar(is_instance_valid(jefe_rush), "Boss Rush incluye al Guardian")
