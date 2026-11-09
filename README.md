# Freedom Knight - Proyecto Móviles

Este repositorio contiene el desarrollo del juego **Freedom Knight** sobre el motor Godot Engine, adaptado y extendido como proyecto de la unidad de aprendizaje de Desarrollo de Aplicaciones Móviles Nativas en ESCOM IPN.

---

## 1. Entorno de Desarrollo y Requisitos
Para compilar y ejecutar este proyecto se requiere el siguiente entorno:
* **Sistema Operativo:** Windows 10/11 o distribución Linux de 64 bits.
* **Motor:** Godot Engine 4.x (versión estándar de 64 bits, sin necesidad de soporte .NET).
* **Control de versiones:** Git 2.x o superior.

---

## 2. Pasos de Construcción y Ejecución (Clon Limpio)
Siga estos pasos exactos para compilar y ejecutar el proyecto desde cero:

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/gabrielhuav/Freedom-Knight
   ```

2. **Descargar Godot Engine 4.x:**
   Descargue el ejecutable portable oficial desde [godotengine.org](https://godotengine.org) y descomprima el archivo en una carpeta local.

3. **Importar el proyecto:**
   * Abra el ejecutable de Godot Engine.
   * En el Administrador de Proyectos (*Project Manager*), haga clic en **Importar** (*Import*).
   * Haga clic en **Examinar** (*Browse*) y seleccione la ruta:
     ```text
     Freedom-Knight/juego/project.godot
     ```
   * Seleccione `project.godot` y presione **Importar y editar** (*Import & Edit*).

4. **Ejecutar el juego:**
   Presione la tecla **F5** (o el botón ▶️ en la esquina superior derecha) para lanzar la escena principal en modo depuración.

### Problemas encontrados y soluciones durante la primera ejecución
* **Detección del archivo `project.godot`:** Inicialmente el motor no detectaba el proyecto en la raíz del repositorio, ya que los archivos de Godot están alojados dentro del subdirectorio `/juego/`. Se solucionó navegando e importando directamente la ruta relativa `juego/project.godot`.
* **Renderizado y compatibilidad:** Al ejecutar en equipos portátiles, se comprobó que el renderizador estuviera en modo **Compatibility** para asegurar una tasa de cuadros estable y evitar fallos con drivers gráficos.

---

## 3. Estructura del Repositorio (Sección 2.1)
El repositorio está organizado siguiendo la estructura modular de Godot Engine, separando lógica, nodos, recursos visuales/sonoros y documentación:

* **Carpetas de código (`juego/Scripts/` o `juego/Managers/`):** Archivos de script en GDScript (`.gd`) que definen el comportamiento de las entidades: control del personaje (`Knight.gd` / `Player.gd`), máquinas de estados, lógica de daño, barra de vida, comportamiento de enemigos y captura de eventos de entrada.
* **Carpetas de escenas y nodos (`juego/Scenes/`):** Archivos de escena (`.tscn`) que estructuran el árbol de nodos: interfaz de usuario (`MainMenu.tscn`, HUD, menús de pausa), pantalla de juego principal, niveles y capas de mapa (`TileMap`).
* **Recursos multimedia (`juego/Imagenes/`, `juego/Botones_Iconos/`):** Gráficos y spritesheets (`.png`) del caballero, enemigos y escenarios; elementos de interfaz (botones, iconos); audio (`.ogg`, `.wav`) y fuentes tipográficas.
* **Documentación (`docs/` y raíz):**
  * `README.md`: Descripción general del juego y guía de ejecución desde un clon limpio.
  * `docs/idea.md`: Ficha técnica de la idea, usuario y alcance.
  * `docs/pruebas.md`: Matriz de pruebas del juego (casos iniciales y estados de pantalla).
  * `docs/licencias.md`: Registro formal de licencias de assets y código.
  * `docs/evidencia/entrega-1/`: Capturas y evidencias individuales de ejecución.
* **Archivos de configuración:**
  * `juego/project.godot`: Archivo principal de metadatos, configuración de resolución, escalado, mapa de acciones (*Input Map*) y escena inicial.
  * `export_presets.cfg`: Perfiles de exportación para compilar hacia Android (`.apk` / `.aab`) y PC.
  * `.gitignore`: Archivos y directorios omitidos por Git.

---

## 4. Punto de Entrada y Configuración de Construcción
* **Punto de entrada:** En Godot, el punto de entrada es la escena principal declarada en `project.godot` bajo la sección `[application]`:
  ```ini
  [application]
  run/main_scene="res://MainMenu.tscn"
  ```
  Al iniciar la aplicación, Godot carga dicha escena, la cual instancia la interfaz gráfica del menú principal (pantalla con Modo Historia, Modo Arcade, Continuar y Configuración) y conecta sus señales de navegación.

* **Configuración de construcción:** Se define en `export_presets.cfg` (junto con `project.godot`), donde se especifican las rutas del SDK/NDK de Android, nombre del paquete (`com.richycm.freedomknight`), versión del juego, permisos en el manifest y arquitectura de destino (`arm64-v8a`, `armeabi-v7a`).

---

## 5. Exclusiones del Archivo .gitignore y Justificación Técnica
* **`.godot/` (Godot 4) o `.import/`:** Carpetas de caché donde el motor almacena versiones binarias optimizadas de texturas, sonidos y fuentes. Se generan automáticamente por el editor al importar; subirlas causaría conflictos continuos de merge y engrosaría el repositorio de forma innecesaria.
* **Archivos de compilación y ejecutables (`*.apk`, `*.aab`, `*.exe`, `*.pck`, `*.so`):** Artefactos finales de construcción que no deben almacenarse en Git para no saturar el historial de versiones con binarios pesados.
* **Firmas y llaves criptográficas (`*.keystore`, `*.jks`):** Contienen credenciales privadas para firmar el paquete de Android; versionarlas representaría una vulnerabilidad crítica de seguridad.
* **Temporales del sistema operativo y editores (`.DS_Store`, `Thumbs.db`, `.vscode/`):** Archivos locales de cada entorno de trabajo que no aportan funcionalidad al proyecto.

---

## 6. Flujos de Integración Continua (.github/workflows)
* **Propósito y estado:** Los flujos de CI se definen en archivos `.yml` dentro de `.github/workflows/` (por ejemplo, linting o chequeo de scripts).
* **Verificación en Godot:** Al tratarse de un proyecto sobre Godot Engine y no Android nativo con Gradle, si la compilación del APK exige configuraciones pesadas de *export templates*, la integración continua se enfoca en validación de sintaxis/linter de scripts `.gd` y verificación de integridad de recursos `.tscn`, complementándose con las matrices de QA manual descritas en la entrega.

---

## 7. Arquitectura de la Aplicación (Sección 2.2)

### Diagrama de Capas
```text
┌────────────────────────────────────────────────────────┐
│             Capa de Presentación / UI                  │
│  - MainMenu.tscn (TextureRect, TextureButton, Label)   │
│  - HUD / Escenas de Juego (.tscn)                      │
└──────────────────────────┬─────────────────────────────┘
                           │ Señales (pressed, colisiones)
                           ▼
┌────────────────────────────────────────────────────────┐
│              Capa de Lógica y Control                  │
│  - Scripts GDScript (res://Scripts/, res://Managers/)  │
│  - Manejo de flujo de escenas (SceneTree)              │
└──────────────────────────┬─────────────────────────────┘
                           │ Modifica / Controla
                           ▼
┌────────────────────────────────────────────────────────┐
│            Capa de Entidades y Simulación 2D           │
│  - CharacterBody2D, Area2D, CollisionShape2D           │
│  - Físicas integradas de Godot Engine                  │
└────────────────────────────────────────────────────────┘
```

### Distribución de Responsabilidades
* **Dónde vive la interfaz:** En los archivos de escena `.tscn` ubicados en `res://Scenes/` y `res://MainMenu.tscn`, formados por árboles de nodos de interfaz (`Control`, `TextureRect`, `TextureButton`, `Label`).
* **Dónde vive la lógica:** En los archivos en GDScript (`.gd`) dentro de las carpetas `res://Scripts/` y `res://Managers/`. Estos scripts implementan el ciclo de vida del motor (`_ready()`, `_process()`, `_physics_process()`) y atienden eventos mediante el sistema de señales de Godot.
* **Dónde vive el acceso a datos:** El juego base no cuenta con una base de datos externa ni consumo de APIs remotas. Los estados de partida, configuraciones y variables se gestionan en memoria volátil durante la sesión local.
* **Dependencias externas y ejecución:**
  * **Motor:** Se ejecuta sobre Godot Engine 4.x (estándar de 64 bits) sin librerías externas adicionales de terceros.
  * **Ejecución local vs. remota:** El 100% del código y los recursos se ejecutan de manera nativa y local en el dispositivo del usuario; no existe dependencia de servicios web, APIs ni servidores en la nube.

---

## 8. Recorrido del Código: Inicio de Partida (Sección 2.3)
Se analiza la funcionalidad correspondiente a la acción de iniciar el juego desde la pantalla principal.

1. **Acción del usuario:**
   El usuario hace clic sobre el botón interactivo de la pantalla de inicio (nodo `TextureButton` dentro del contenedor del menú principal).

2. **Evento y emisión de señal:**
   El nodo emite la señal estándar de Godot:
   ```text
   signal pressed()
   ```
   Dicha señal se encuentra conectada al script controlador de la escena (`MainMenu.gd`).

3. **Fragmento de código real del proyecto:**
   En el script que gestiona la escena `MainMenu.tscn`, el método receptor procesa el evento y solicita al árbol de escenas la transición hacia la escena del nivel jugable:
   ```gdscript
   func _on_arcade_pressed() -> void:
       get_tree().change_scene_to_file("res://Scenes/Nivel.tscn")
   ```
   * **Líneas involucradas:**
     * `func _on_arcade_pressed() -> void`: captura el evento del botón Arcade.
     * `get_tree().change_scene_to_file(...)`: descarga de la memoria la escena actual (`MainMenu.tscn`) e instancia en su lugar el nodo raíz de la escena del nivel especificado.

4. **Archivos a modificar para alterar este comportamiento:**
   Para cambiar el flujo de esta funcionalidad (por ejemplo, para que en lugar de iniciar inmediatamente abra una pantalla de selección de nivel o dificultad):
   * **Archivo de interfaz:** `res://MainMenu.tscn` (para añadir los nuevos botones, textos o contenedores del menú).
   * **Archivo de lógica:** `res://Scripts/MainMenu.gd` (para modificar la ruta de la escena destino en `change_scene_to_file()` o redirigir a un modal/submenú intermediario antes del cambio de escena).