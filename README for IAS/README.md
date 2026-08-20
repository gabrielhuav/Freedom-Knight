# Contexto del proyecto para asistentes de IA

Documento de referencia con el contexto y **todas las rutas absolutas** tal como están
en esta PC. Escrito el 15 ago 2026.

**Máquina:** PC de escritorio, Windows 11 Pro (10.0.26200), NVIDIA RTX 2060 SUPER.
Shell principal: PowerShell 5.1. Usuario: `gabri`.

> Las rutas de abajo son específicas de ESTA máquina. Si lees esto en otra PC,
> verifica cada una antes de usarla.

---

## 1. Qué es el proyecto

**Freedom Knight** — videojuego 2D hecho en **Godot 4.6**, publicado en Google Play.

- **GDScript puro.** 31 archivos `.gd`, cero C#, cero addons. No hace falta .NET SDK.
- **Renderer:** Forward Plus. Viewport 1200x675, `stretch/mode=canvas_items`.
- **Orientación:** horizontal (`window/handheld/orientation=4`).
- **Escena principal:** `Scenes/UI/MainMenu.tscn` (referida como `uid://ccduinat2mb81`).
- **Autoloads** (declarados en `project.godot`):
  - `SaveManager` → `Managers/SaveManager.gd`
  - `NetworkManager` → `Scripts/NetworkManager.gd`
  - `PlayerRegistry` → `Scripts/PlayerRegistry.gd`

Repo en GitHub: https://github.com/gabrielhuav/Freedom-Knight — rama principal `main`.
Es un proyecto de equipo; el historial va por PRs semanales (`Semana3`, `Semana4`, `Semana5`).

### Estructura

El **proyecto de Godot NO está en la raíz del repo**, está en la subcarpeta `freedom-knight/`.
La raíz del repo solo tiene APKs históricos exportados y el `LICENSE`.

```
Freedom-Knight/                 <- raíz del repo (~400 MB de APKs versionados)
├── freedom-knight/             <- AQUÍ está el project.godot
│   ├── project.godot
│   ├── export_presets.cfg
│   ├── Scenes/  (Cinematica, Efectos, Mapa, UI)
│   ├── Scripts/ (ArcadeMenu, C1_inicio, MainMenu, NetworkManager, PlayerRegistry, mapa/)
│   ├── Managers/ (SaveManager.gd)
│   ├── Imagenes/, SpritesDelJuego/, Sonidos/, Botones_Iconos/
│   └── android/                <- plantilla de compilación de Gradle (NO versionada)
├── Freedomknight1.0/           <- carpeta de salida de los AAB/APK
└── README for IAS/             <- este documento
```

---

## 2. Rutas absolutas en esta PC

### Proyecto

| Qué | Ruta |
|---|---|
| Raíz del repo | `C:\Users\gabri\Documents\GitHub Desktop\Freedom-Knight` |
| **Proyecto Godot** (`--path`) | `C:\Users\gabri\Documents\GitHub Desktop\Freedom-Knight\freedom-knight` |
| `project.godot` | `C:\Users\gabri\Documents\GitHub Desktop\Freedom-Knight\freedom-knight\project.godot` |
| `export_presets.cfg` | `C:\Users\gabri\Documents\GitHub Desktop\Freedom-Knight\freedom-knight\export_presets.cfg` |
| Plantilla Gradle Android | `C:\Users\gabri\Documents\GitHub Desktop\Freedom-Knight\freedom-knight\android\build` |
| Salida de exportación | `C:\Users\gabri\Documents\GitHub Desktop\Freedom-Knight\Freedomknight1.0` |

### Godot

| Qué | Ruta |
|---|---|
| **Godot editor (GUI)** | `C:\Users\gabri\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64.exe` |
| **Godot consola** (para CLI) | `C:\Users\gabri\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64_console.exe` |
| Plantillas de exportación | `C:\Users\gabri\AppData\Roaming\Godot\export_templates\4.6.3.stable` |
| Ajustes del editor | `C:\Users\gabri\AppData\Roaming\Godot\editor_settings-4.6.tres` |
| Keystore de **debug** | `C:\Users\gabri\AppData\Roaming\Godot\keystores\debug.keystore` |

**Versión exacta instalada:** `4.6.3.stable.official.7d41c59c4`, instalada con
`winget install --id GodotEngine.GodotEngine --version 4.6.3`.

> **Importante — no actualizar a Godot 4.7.** El proyecto declara
> `config/features=PackedStringArray("4.6", "Forward Plus")`. Se eligió 4.6.3 (parche de la
> misma serie) a propósito: abrirlo con 4.7 reescribe `project.godot` y genera conflictos
> en los PRs del equipo. Usar siempre la serie **4.6.x**.

El instalador dejó el alias `godot` en el PATH, pero requiere abrir una **terminal nueva**.

### Cadena de herramientas Android

| Qué | Ruta / valor |
|---|---|
| JDK | `C:\Program Files\Amazon Corretto\jdk21.0.5_11` (OpenJDK 21.0.5 LTS) |
| Android SDK | `D:\Android\Sdk` (ojo: en **D:**, no en la ruta por defecto) |
| Android Studio | `C:\Program Files\Android\Android Studio` |
| aapt2 | `D:\Android\Sdk\build-tools\36.0.0\aapt2.exe` |

- **Platforms instaladas:** android-34, android-35, android-36, android-36.1
- **build-tools:** 33.0.1, 34.0.0, 35.0.0, 36.0.0
- **cmdline-tools:** latest
- **NDK: no instalado** — y no hace falta. Godot 4 solo lo necesita para compilar
  plantillas propias o GDExtension nativo, y este proyecto no usa ninguna de las dos.

Godot ya tiene estas rutas configuradas en `editor_settings-4.6.tres`:
`export/android/java_sdk_path` y `export/android/android_sdk_path`.

---

## 3. Comandos

Todos usan el **exe de consola** (el GUI no imprime a stdout). Definir primero:

```powershell
$godot = "C:\Users\gabri\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64_console.exe"
$proj  = "C:\Users\gabri\Documents\GitHub Desktop\Freedom-Knight\freedom-knight"
```

**Abrir el editor:**
```powershell
& $godot -e --path $proj
```

**Correr el juego** (o F5 dentro del editor):
```powershell
& $godot --path $proj
```

**Reimportar assets** (tras un clon limpio; `.godot/` no se versiona):
```powershell
& $godot --headless --path $proj --import
```

**Exportar AAB de debug** (usa el keystore de debug, sin credenciales de release):
```powershell
& $godot --headless --path $proj --export-debug "Android" "C:\ruta\salida\test_debug.aab"
```

### Notas sobre el CLI

- `--install-android-build-template` **no funciona solo**: se cuelga esperando. La ayuda de
  Godot dice "Used in conjunction with --export-release or --export-debug", así que hay que
  pasarlo junto a una exportación. Ya está instalado, no hace falta repetirlo.
- **Godot no termina el proceso cuando se le pasa `--install-android-build-template`**: la
  exportación se completa y el archivo queda bien escrito, pero el proceso se queda vivo a 0%
  de CPU y hay que matarlo a mano. Como la plantilla ya está instalada, omitir ese flag en las
  siguientes exportaciones para evitar el cuelgue.
- La primera compilación de Gradle tarda varios minutos (baja dependencias). Las siguientes
  son de un par de minutos.
- Al cerrar con `--quit-after`, Godot suele imprimir `ObjectDB instances leaked at exit` y
  `N resources still in use at exit`. Es ruido normal de cierre, no un error del juego.

---

## 4. Google Play

- **Package:** `com.richycm.freedomknight`
- **Cuenta de desarrollador:** gabrielhuav@gmail.com
- **Canal actual:** Prueba cerrada — Alpha, 16 países. Ya tienen acceso a producción concedido.

### Historial de versiones subidas

| versionName | versionCode | Fecha | Estado |
|---|---|---|---|
| Freedom Knight 1.0.0.1 | 1 | 12 jun 2026 | reemplazada |
| 1.1 | 2 | 19 jun 2026 | reemplazada |
| **1.2** | **3** | 22 jun 2026 | la más reciente en Play |

| **1.3** | **4** | 15 ago 2026 | generada, resuelve el bloqueo de API 36 |

La 1.3 se subió a **prueba cerrada** el 15 ago 2026 y quedó *"Actualización en etapa de
revisión"* (Play tarda hasta 7 días). El preset ya está avanzado a **1.3.1 / `versionCode` 5**
para la siguiente entrega. El `versionCode` sube de uno en uno sin importar el `versionName`;
Play exige que sea estrictamente mayor que cualquiera ya subido, y el número es global para la
app, no por canal.

### Las dos advertencias de Play sobre el versionCode 4

Ambas son **recomendaciones, no bloqueos** — Play aceptó el bundle. Se investigaron el
15 ago 2026 y la conclusión es que **no vale la pena perseguirlas**:

**1. "No hay un archivo de desofuscación asociado" (R8/Proguard).**
La plantilla de Godot no activa R8: no hay `minifyEnabled` ni `proguardFiles` en ningún
`buildType` de `android/build/build.gradle`, y no se genera ningún `mapping.txt`. Es decir,
el código **no está ofuscado**, así que no hay nada que desofuscar y el aviso es genérico.
Activar R8 en un proyecto Godot es arriesgado: las clases del runtime de Android se cargan por
reflexión y JNI, y R8 las eliminaría sin avisar.

**2. "Contiene código nativo y no subiste símbolos de depuración".**
`build.gradle` trae `debugSymbolLevel 'NONE'`, pero subirlo a `SYMBOL_TABLE` o `FULL` **no
serviría de nada**: la librería que distribuye Godot ya viene sin símbolos. Verificado sobre
`libgodot_android.so` — no tiene `.symtab`, `.debug_info`, `.debug_line` ni `.gnu_debuglink`,
solo `.dynsym` (la tabla dinámica que hace falta para enlazar). Se confirma también porque las
carpetas `merged_native_libs` y `stripped_native_libs` contienen archivos del mismo tamaño
exacto: la tarea de strip no tuvo nada que quitar.
Para tener símbolos reales habría que compilar plantillas de exportación propias desde el
código fuente de Godot, lo que además dispararía el tamaño del AAB.

Nota adicional: `android/` está en el `.gitignore`, así que cualquier edición a
`android/build/build.gradle` no se versiona y se pierde al reinstalar la plantilla.

### Contenido de la 1.3

Todo lo que entró en el commit `Semana5` (f7cbff4, 26 jun 2026), posterior al lanzamiento de
la 1.2: modo Arcade con oleadas, Boss Rush, tres dificultades, multijugador **LAN** (ENet +
descubrimiento UDP, no online), enemigos Lancero/Vikingo/Dragón/jefe de piso, la gata
compañera que cura cada 5 bajas, tres mapas nuevos, y mejoras a menú de pausa y guardado.

### Configuración de compilación (`export_presets.cfg`, preset.0 "Android")

- `gradle_build/use_gradle_build=true`
- `gradle_build/target_sdk="36"`
- `gradle_build/export_format=1` (1 = AAB, 0 = APK)
- `minSdk` = 24 (default de Godot, el campo está vacío)
- `compileSdk` = 36 (viene de la plantilla de Godot 4.6, no se configura a mano)
- **Solo `arm64-v8a`** — armeabi-v7a, x86 y x86_64 están desactivados
- `package/signed=true`, `screen/immersive_mode=true`
- **Permisos** (desde la 1.3.1): `internet`, `access_network_state` y `access_wifi_state` en
  `true`. Todos los demás `permissions/*` siguen en `false`. Ver la sección 7.

---

## 7. Bug crítico encontrado: el multijugador LAN no podía funcionar (20 ago 2026)

**Hallazgo.** El manifiesto de la versión **1.3** (`versionCode` 4), la que se subió a Play,
**no declara ni un solo `uses-permission`**. Verificado sobre el manifiesto fusionado que
generó Gradle:

```
android:minSdkVersion="24"  android:targetSdkVersion="36"
android:versionCode="4"     android:versionName="1.3"
(cero entradas uses-permission)
```

**Consecuencia.** En Android, `INTERNET` es obligatorio para abrir cualquier socket. Sin él,
`ENetMultiplayerPeer` y `PacketPeerUDP` fallan en el dispositivo. El multijugador LAN — la
función que se declaró ante Google como el diferenciador del juego en la pregunta 2.2 de la
solicitud de acceso a producción — **no puede funcionar en esa build**, aunque en el editor de
escritorio funcione perfecto.

**El código está bien.** `NetworkManager.gd` usa `ENetMultiplayerPeer` para la partida y
`PacketPeerUDP` con broadcast a `255.255.255.255:8911` para el descubrimiento, y sí llama a
`set_broadcast_enabled(true)` en la línea 196. El fallo estaba únicamente en el preset de
exportación, donde los `permissions/*` vienen todos en `false` por defecto.

**Por qué no se detectó antes.** El menú de Arcade con la opción LAN entró en la 1.3. Las
versiones que los verificadores probaron (1.0.0.1 a 1.2) no exponían la función, así que nadie
llegó a intentarlo. Coincide con lo declarado en la pregunta 1.3 de la solicitud: *"El
multijugador LAN se usó poco"*.

**Corrección aplicada en la 1.3.1:**

| Permiso | Antes | Ahora | Para qué |
|---|---|---|---|
| `internet` | false | **true** | Obligatorio para cualquier socket. Sin esto no arranca nada |
| `access_network_state` | false | **true** | Consultar el estado de la conexión |
| `access_wifi_state` | false | **true** | Leer la información de la red Wi-Fi |

`change_wifi_multicast_state` se dejó en `false` deliberadamente. Haría falta solo si el
descubrimiento por broadcast fallara en algún dispositivo: Android puede filtrar los paquetes
a `255.255.255.255` sin un `MulticastLock`, que requiere ese permiso. Como el broadcast
dirigido suele entregarse sin él, se prefirió no pedir un permiso extra sin necesidad
comprobada. **Si al probar en dos teléfonos el anfitrión no aparece en la lista, ese permiso es
lo primero que hay que activar.**

**Pendiente de verificar en dispositivo real:** que con estos tres permisos el descubrimiento
LAN y la partida funcionen entre dos teléfonos en la misma red.

---

## 5. Estado del trabajo (15 ago 2026)

### El problema que se está resolviendo

Play Console rechaza actualizaciones con:

> La aplicación debe orientarse a Android 16 (nivel de API 36) o versiones posteriores.
> Tu nivel de API objetivo más alto que no cumple con las políticas es Android 15 (nivel 35).

A partir del **30 ago 2026** el target API debe tener un año o menos de antigüedad.

### La causa

El `target_sdk` estaba forzado a `"35"` a mano en el preset. **No era una limitación del
motor**: el APK anterior ya se compilaba con `compileSdkVersion=36`, así que la plantilla
de Godot 4.6 soporta API 36 sin tocar Gradle ni nada más. Era solo ese override.

### Cambios aplicados a `export_presets.cfg`

| Campo | Antes | Ahora |
|---|---|---|
| `gradle_build/target_sdk` | `"35"` | `"36"` |
| `version/code` | `1` | `4` |
| `version/name` | `"Ofcial"` (typo) | `"1.3"` |
| `gradle_build/export_format` | `0` (APK) | `1` (AAB) |
| `export_path` | `FreedomKnightOficial.apk` | `FreedomKnight1.3_api36.aab` |

El nombre de salida lleva sufijo `_api36` para **no sobrescribir** el `FreedomKnight1.3.aab`
que ya existe en `Freedomknight1.0/` — ese es un build viejo que nunca se subió (Play va en 1.2).

### Validación hecha (compilación de debug)

Se exportó un AAB de debug para confirmar que API 36 compila antes de tocar el build firmado.
Resultado: **AAB de 55.2 MB generado correctamente**. El manifiesto fusionado que produjo
Gradle en
`android\build\build\intermediates\merged_manifest\standardDebug\processStandardDebugMainManifest\AndroidManifest.xml`
confirma los valores:

```
android:minSdkVersion="24"
android:targetSdkVersion="36"   <- el requisito de Play, cumplido
android:versionCode="4"
android:versionName="1.3"
```

Esa es la forma fiable de verificar un AAB en esta máquina, ya que `aapt2` no lo puede leer.

### Riesgo conocido a validar en dispositivo real

Al pasar a target 36, **Android 16 elimina la posibilidad de desactivar el modo edge-to-edge**
(el `windowOptOutEdgeToEdgeEnforcement` que todavía servía en API 35). El preset tiene
`screen/edge_to_edge=false` y esa opción deja de tener efecto. Como el juego corre en
`immersive_mode=true` probablemente no se note, pero conviene instalarlo en un teléfono con
Android 15+ y revisar que la UI no se meta bajo la barra de estado o el notch.

### AAB de release generado y verificado

Salida: `C:\Users\gabri\Downloads\FreedomKnight1.3_api36.aab` (53.7 MB, 15 ago 2026 10:21).
Se exportó por CLI con las variables de entorno `GODOT_ANDROID_KEYSTORE_RELEASE_*`, así la
contraseña nunca quedó escrita en `export_credentials.cfg`.

Verificado antes de subir:

| Qué | Valor |
|---|---|
| `targetSdkVersion` | 36 |
| `versionCode` | 4 |
| `versionName` | 1.3 |
| `minSdkVersion` | 24 |
| Firmante | `CN=ricardoc, OU=FreedomKnight, O=FreedomKnight` |
| SHA-1 | `12:98:0A:04:5A:4A:31:9A:81:AA:A5:07:B0:FE:78:A8:23:C8:29:CF` |
| Bloque | `META-INF/MIJUEGO.RSA` |

### Keystore de release

`C:\Users\gabri\Downloads\nueva.keystore`, alias `MiJuego`. La contraseña la tiene el humano.

Contiene **la misma clave** con la que se firmaron las versiones 1.0.0.1 a 1.2 — se confirmó
comparando su SHA-1 contra el del APK ya publicado. **No es una clave nueva**, pese a que el
archivo tenga fecha reciente.

### Cómo verificar un AAB firmado (sin bundletool)

1. **Manifiesto:** leer el XML fusionado que deja Gradle en
   `android\build\build\intermediates\merged_manifest\standardRelease\processStandardReleaseMainManifest\AndroidManifest.xml`
2. **Firma:** extraer `META-INF/*.RSA` del AAB con `[System.IO.Compression.ZipFile]` y correr
   `keytool -printcert -file <archivo.rsa>`. No pide contraseña.
3. **Referencia:** el certificado esperado se saca de un APK ya publicado con
   `apksigner verify --print-certs <apk>` (esto sí funciona con APK, no con AAB).

---

## 6. Reglas para asistentes de IA

1. **Nunca manejar la contraseña del keystore de release.** El humano tiene el keystore y la
   contraseña. Para exportar firmado desde CLI, indicarle que él defina las variables de
   entorno en su propia terminal y corra el comando — la contraseña no debe pasar por el chat
   ni quedar escrita en ningún archivo:
   `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`,
   `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`.
   La alternativa es que lo haga desde la UI: Proyecto > Exportar > Android.
2. **No commitear** `*.keystore`, `*.jks`, ni credenciales. El `.gitignore` de
   `freedom-knight/` ya los excluye, junto con `.godot/`, `/android/`, `*.apk`, `*.aab`.
3. **No subir a Play ni publicar nada** sin confirmación explícita del humano.
4. `aapt2 dump badging` funciona con **APK pero no con AAB** ("could not identify format of
   APK"). Para inspectar un AAB hace falta `bundletool`, que no está instalado.
5. `Expand-Archive` de PowerShell rechaza extensiones que no sean `.zip`. Para abrir un `.aab`
   usar `[System.IO.Compression.ZipFile]` de .NET.

### Deuda técnica conocida (no tocar sin permiso del equipo)

- La raíz del repo tiene **~400 MB de APKs versionados**. El `.gitignore` que excluye `*.apk`
  está dentro de `freedom-knight/`, así que no cubre la raíz, y los binarios entraron antes.
  Es lo que hace lento el clonado. Es decisión del equipo si se limpian con un rewrite.
- El repo tiene `freedom-knight/temp_mainmenu.gd`, que por el nombre parece un archivo
  temporal olvidado. No se ha verificado si algo lo usa.
