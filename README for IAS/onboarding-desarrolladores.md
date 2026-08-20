# Guía de desarrollo — Freedom Knight

Para desarrolladores que se incorporan al proyecto. Escrita el 20 ago 2026.

Si nunca has tocado Godot, no te preocupes: el proyecto es GDScript puro, sin C# ni plugins.
Lo que sí conviene es leer la sección de **trampas conocidas** antes de tu primer cambio, o
vas a perder una tarde en cosas que ya nos pasaron.

---

## 1. Levantar el proyecto

### Lo que necesitas instalar

| Herramienta | Versión | Para qué |
|---|---|---|
| **Godot 4.6.x** | 4.6.3 | El motor. Descarga la versión **estándar**, NO la .NET/Mono |
| Git | cualquiera | Clonar el repo |

Nada más. No hace falta .NET, ni Android Studio, ni el SDK de Android — eso solo se necesita
para generar el APK/AAB, y de eso se encarga quien publica.

> ### No abras el proyecto con Godot 4.7 o superior
> `project.godot` declara `config/features=PackedStringArray("4.6", "Forward Plus")`. Si lo
> abres con 4.7, Godot reescribe ese archivo y genera un conflicto en el siguiente PR para
> todo el equipo. Usa siempre la serie **4.6.x**.

En Windows con winget:

```powershell
winget install --id GodotEngine.GodotEngine --version 4.6.3
```

### Clonar y abrir

```bash
git clone https://github.com/gabrielhuav/Freedom-Knight.git
```

> **Ojo con el peso.** El repo trae ~400 MB de APKs históricos versionados en la raíz. El clon
> tarda varios minutos. Es deuda técnica conocida, ver la sección 8.

**El proyecto de Godot NO está en la raíz.** Está en la subcarpeta `freedom-knight/`. Cuando
Godot te pida la carpeta del proyecto, apunta ahí — es donde vive `project.godot`.

La primera vez que lo abras, Godot importará todos los assets (unos 146). Tarda un par de
minutos y es normal; se cachea en `.godot/`, que no se versiona.

Para correr el juego: **F5**. Arranca en el menú principal.

---

## 2. Mapa del código

```
freedom-knight/
├── project.godot          Configuración del motor y los autoloads
├── export_presets.cfg     Configuración de exportación (Android/Windows/Web)
├── Managers/
│   └── SaveManager.gd     Autoload · estado global y guardado
├── Scripts/
│   ├── MainMenu.gd        Menú principal
│   ├── ArcadeMenu.gd      Menú de Arcade, dificultad y multijugador LAN
│   ├── NetworkManager.gd  Autoload · multijugador LAN
│   ├── PlayerRegistry.gd  Autoload · registro de jugadores en red
│   ├── C1_inicio.gd       Cinemática de introducción
│   └── mapa/              Scripts de los mapas del modo Historia
├── Scenes/
│   ├── Cinematica/        Cinemáticas
│   ├── Mapa/              Mapas del modo Historia
│   └── UI/
│       ├── MainMenu.tscn  ← ESCENA PRINCIPAL, el juego arranca aquí
│       ├── MenuPausa.*    Menú de pausa
│       ├── Escenas/       Escenarios de juego y mapas de Arcade
│       ├── Personajes/    Héroe, NPCs y enemigos
│       └── PocionesHechizos/
├── Imagenes/, SpritesDelJuego/, Sonidos/, Botones_Iconos/
└── android/               Plantilla de compilación (NO se versiona)
```

### Los archivos grandes, por si buscas dónde tocar

| Archivo | Líneas | Qué es |
|---|---|---|
| `Scenes/UI/Escenas/escenario_pruebas.gd` | 1310 | **El escenario de juego principal.** El nombre engaña |
| `Scripts/ArcadeMenu.gd` | 757 | Todo el menú de Arcade, construido por código |
| `Scenes/UI/Personajes/Heroe/caballero.gd` | 628 | El personaje jugable |
| `Scripts/NetworkManager.gd` | 446 | Multijugador LAN |
| `Scripts/MainMenu.gd` | 355 | Menú principal |

Los enemigos viven en `Scenes/UI/Personajes/Villanos/`, una carpeta por cada uno: Arquero,
CaballeroMalo, CaballeroMaloH, Lancero, Vikingo, dragon y jefe.

---

## 3. Los tres autoloads

Un *autoload* (o singleton) es un nodo que Godot carga al arrancar y que existe durante toda la
sesión, accesible desde cualquier script por su nombre. Están declarados en `project.godot`.
Aquí hay tres, y entenderlos es el 80% de entender el proyecto.

### SaveManager — estado global y guardado

Es el pizarrón compartido entre escenas. Cuando cambias de escena todo lo demás se destruye;
lo que está aquí sobrevive.

```gdscript
SaveManager.nombre_jugador     # el gamertag que eligió el jugador
SaveManager.partida_actual     # ruta de la partida cargada
SaveManager.dificultad_juego   # 0 = Fácil, 1 = Medio, 2 = Difícil
SaveManager.modo_juego         # "Arcade" o "BossRush"
SaveManager.escribiendo_texto  # true mientras el jugador escribe en un campo
```

Las partidas se guardan en `user://saves/`. En Windows eso es
`%APPDATA%\Godot\app_userdata\Freedom Knight\saves\`.

> **`escribiendo_texto` importa más de lo que parece.** Sirve para que el juego no interprete
> las teclas como controles mientras el jugador escribe su nombre. Si añades un campo de
> texto, ponlo en `true` al enfocar y en `false` al salir, o el personaje se moverá mientras
> teclean.

### NetworkManager — multijugador LAN

Multijugador **solo en red local**, sin servidores ni internet. Funciona en dos capas:

1. **Descubrimiento por UDP.** El anfitrión emite un paquete a `255.255.255.255:8911` una vez
   por segundo. Los clientes escuchan ese puerto y arman la lista de partidas disponibles.
2. **La partida en sí** va por `ENetMultiplayerPeer`, el sistema de red de Godot.

Señales útiles: `host_discovered`, `host_lost`, `host_list_updated`, `all_players_ready`.

### PlayerRegistry — quién es quién en red

Lleva la cuenta de los jugadores conectados y traduce entre *peer id* (el identificador de red)
y el nodo del jugador dentro de la escena.

```gdscript
PlayerRegistry.get_local_player()          # tu propio personaje
PlayerRegistry.get_all_players()           # todos, incluido tú
PlayerRegistry.get_alive_players()         # los que no han muerto
PlayerRegistry.get_nearest_player_to(pos)  # el más cercano a una posición
PlayerRegistry.is_networked()              # ¿hay partida en red activa?
```

> **Para la IA de enemigos usa `get_nearest_player_to()`, no busques al jugador por nodo.** En
> partida local hay un jugador; en red puede haber varios. Un enemigo que persiga siempre a
> `get_local_player()` se comporta mal en multijugador, y es un bug que solo aparece cuando
> pruebas con dos dispositivos.

---

## 4. Flujo de escenas

El juego arranca en `Scenes/UI/MainMenu.tscn` y de ahí se ramifica:

```
MainMenu.tscn
│
├── [Historia]  →  Cinematica/C1_inicio.tscn  →  Mapa/1.tscn
│
└── [Arcade]    →  Escenas/ArcadeMenu.tscn
                    ├── Solo        ┐
                    ├── Boss Rush   ├→  Escenas/escenario_pruebas.tscn
                    └── LAN         ┘
```

Los cambios de escena se hacen con `get_tree().change_scene_to_file(ruta)`. Para encontrar
todos los puntos donde ocurre:

```bash
grep -rn "change_scene_to_file" --include="*.gd" .
```

Fíjate en que **ArcadeMenu no lanza escenas distintas por modo**: los tres botones llevan a
`escenario_pruebas.tscn`. Lo que cambia es `SaveManager.modo_juego` y
`SaveManager.dificultad_juego`, que la escena lee al arrancar. Si vas a añadir un modo nuevo,
ese es el patrón a seguir.

---

## 5. Tu primer cambio, paso a paso

Ejemplo real: **subirle la vida al Vikingo**.

1. **Crea una rama.** Nunca trabajes en `main` directo.
   ```bash
   git checkout -b feat/vida-vikingo
   ```
2. **Encuentra el archivo.** Los enemigos están en `Scenes/UI/Personajes/Villanos/`. Cada uno
   tiene su carpeta con un `.gd` y un `.tscn`.
3. **Busca la variable.** Suelen ser `@export`, lo que significa que también se pueden editar
   desde el inspector de Godot sin tocar código:
   ```gdscript
   @export var max_health: int = 3
   ```
4. **Pruébalo con F5.** No confíes en que "se ve bien en el código".
5. **Commit y push:**
   ```bash
   git add -A
   git commit -m "Subir la vida del Vikingo de 3 a 5"
   git push -u origin feat/vida-vikingo
   ```
6. **Abre un Pull Request** hacia `main`. El equipo trabaja por PRs; así se integraron
   `Semana3`, `Semana4` y `Semana5`.

---

## 6. Convenciones del equipo

- **El código y los comentarios van en español.** Los nombres de nodos, variables y funciones
  siguen esa convención: `caballero_malo`, `pocion_de_vida`, `guardar_datos()`. Mantenla,
  aunque no sea lo habitual en otros proyectos.
- **Ramas por PR**, nunca commits directos a `main`.
- **Un `.gd` por `.tscn`**, en la misma carpeta y con el mismo nombre.
- **Usa `@export`** para los valores que un diseñador querría ajustar (vida, velocidad, daño).
  Así se tocan desde el inspector sin editar código.
- **No subas binarios.** El `.gitignore` ya excluye `*.apk`, `*.aab`, `*.exe` y `.godot/`.

---

## 7. Trampas conocidas

Cosas que ya nos costaron tiempo. Léelas antes, no después.

**`escenario_pruebas.tscn` no es un escenario de pruebas.** Es el escenario de juego principal,
con 1310 líneas de lógica. El nombre viene de cuando sí lo era. No lo borres pensando que es
código muerto.

**`temp_mainmenu.gd` sí es código muerto.** No lo referencia ninguna escena ni ningún script.
Se puede borrar, pero está pendiente de acordarlo con el equipo.

**El multijugador LAN necesita permisos de Android declarados a mano.** El preset de
exportación tiene una lista larguísima de `permissions/*` y todos vienen en `false` por
defecto. Sin `permissions/internet=true` **cualquier socket falla en el dispositivo** y el
multijugador no arranca, aunque en el editor de escritorio funcione perfecto. Nos pasó de
verdad: la versión 1.3 se subió a Play sin ningún permiso declarado. Se corrigió en la 1.3.1.

**Prueba el multijugador en dos dispositivos físicos, en la misma red Wi-Fi.** No se puede
validar con un solo teléfono ni desde el editor. Es la función que menos se prueba justamente
por eso, y donde más bugs se acumulan.

**Al ejecutar Godot por línea de comandos**, al cerrar imprime `ObjectDB instances leaked at
exit` y `N resources still in use at exit`. Es ruido normal de cierre, no un error del juego.

---

## 8. Deuda técnica conocida

No la arregles por tu cuenta; coméntalo con el equipo primero.

- **~400 MB de APKs versionados en la raíz del repo.** El `.gitignore` que excluye `*.apk` está
  dentro de `freedom-knight/`, así que no cubre la raíz, y los binarios entraron antes de esa
  regla. Es lo que hace lento el clonado. Limpiarlo exige reescribir el historial, y eso rompe
  el clon de todos.
- **`escenario_pruebas.gd` con 1310 líneas** concentra demasiada responsabilidad.
- **`temp_mainmenu.gd`** sin referencias.

---

## 9. Publicar una versión

Normalmente lo hace quien tiene el keystore. Queda documentado para que entiendas qué implica
tu cambio.

1. Subir `version/code` en `export_presets.cfg`. **Siempre de uno en uno**, sin importar el
   `version/name`. Google Play rechaza un `versionCode` que no sea estrictamente mayor que
   cualquiera ya subido.
2. Exportar el AAB firmado con el keystore de release.
3. Subirlo a Play Console.

Rutas, comandos y detalles completos: `README.md`, en esta misma carpeta.

**Nunca subas al repo** un `.keystore`, un `.jks` ni el archivo `export_credentials.cfg`, donde
Godot guarda la contraseña del keystore en texto plano. El `.gitignore` ya los excluye, pero
revísalo si cambias de rama.

---

## 10. Dónde está lo demás

En esta carpeta `README for IAS/`:

| Archivo | Qué contiene |
|---|---|
| `README.md` | Contexto técnico completo, rutas de compilación, cómo generar el AAB |
| `plantilla-acceso-produccion-play.md` | Cuestionario de acceso a producción de Google Play |
| `acceso-produccion-freedomknight.md` | La solicitud concreta que se envió para este juego |
