# Freedom Knight

Juego de accion 2D para PC y Android, desarrollado en GDScript como proyecto de equipo en ESCOM-IPN. Incluye Historia, Arcade por oleadas, Boss Rush y multijugador LAN mediante ENet y descubrimiento UDP.

## Ejecutar

1. Instalar **Godot 4.6.3 estandar**, sin .NET. Mantener la serie 4.6.x; no migrar el proyecto a 4.7.
2. Clonar este repositorio e importar **freedom-knight/project.godot**.
3. Esperar la importacion de recursos y pulsar **F5**.

El proyecto utiliza Forward Plus, viewport 1200 x 675 y orientacion horizontal. La escena inicial es `freedom-knight/Scenes/UI/MainMenu.tscn`.

## Organizacion

- `freedom-knight/Scenes/UI/Personajes/Heroe/caballero.gd`: controles, combate, sprint e inventario.
- `freedom-knight/Scenes/UI/Escenas/escenario_pruebas.gd`: escenario de Arcade y Boss Rush, enemigos, botin y progresion; no es una escena de pruebas.
- `freedom-knight/Scenes/UI/Personajes/Villanos/guardian_sombras/`: Guardian de las Sombras, con dos fases y ataque de area anticipado.
- `freedom-knight/Scenes/UI/Objetos/`: objetos recogibles y mochila de 12 espacios, con armas y armaduras.
- `freedom-knight/Managers/SaveManager.gd`: guardado local en `user://saves/`.
- `freedom-knight/Scripts/NetworkManager.gd` y `PlayerRegistry.gd`: red local y registro de jugadores.
- `docs/`: documentacion de funciones y evidencia de las entregas.

La mochila abre con **I** o el boton en pantalla; los objetos se recogen con la accion **Interactuar**. Armas y armaduras aplican bonos y se guardan con la partida. Inventario y botin se desactivan en multijugador hasta implementar sincronizacion autoritativa.

## Pruebas

Ejecutar `res://tests/regressions.tscn` con Godot 4.6.3 en una copia del proyecto con un directorio de usuario separado, para no afectar partidas personales:

```powershell
& $godot --headless --path $proyectoPruebas res://tests/regressions.tscn
```

La suite comprueba sprint, pociones, inventario, equipamiento, guardado y el Guardian. Crea un guardado temporal de QA. `tests/*` se excluye de las exportaciones. Las pruebas automatizadas no sustituyen la revision visual ni las pruebas Android y LAN en dos dispositivos fisicos.

La accion de GitHub `Godot checks` verifica sintaxis GDScript y la presencia de `docs/pruebas.md`; no compila Android ni ejecuta toda la suite.

## Contribuir y publicar

Todo cambio a `main` debe pasar por PR y obtener la aprobacion explicita de Gabriel para su version final. No fusionar automaticamente al pasar las pruebas.

El paquete Android es `com.richycm.freedomknight`; los perfiles estan en `freedom-knight/export_presets.cfg`. Para compilar Android se necesitan SDK, JDK, plantillas de exportacion y las credenciales de quien publica. Nunca subir contrasenas, keystores, caches ni nuevos APK/AAB al repositorio.
