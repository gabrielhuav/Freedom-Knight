# Validacion del PR 2 consolidado

Fecha: 14 de noviembre de 2026. Motor: `4.6.3.stable.official.7d41c59c4`.

## Contenido revisado

- Sprint del PR 2: ataque, defensa y pausa invalidan el toque anterior; mantener una direccion al terminar el bloqueo no activa sprint.
- Funciones del PR 6, hasta el commit `6f84203c483fdf24f96ac625390f68aad5299f0c`: Guardian de las Sombras, arte propio, fase dos, onda anticipada, encuentros Arcade/Boss Rush, mochila, cuatro objetos de equipo, botin y persistencia.
- La pocion de vida coincide con `main` despues del PR 4, incluida la limpieza independiente de la vida del nodo de la pocion.
- Guardar y cargar usan `PlayerRegistry` para no seleccionar `HitboxEspada` como jugador. Se conserva el indicador del encuentro del Guardian en los guardados.
- La configuracion del motor sigue en la serie 4.6; las pruebas se ejecutaron con 4.6.3. El README utiliza las rutas reales del proyecto.

## Resultado automatizado

Importacion limpia de los recursos con Godot 4.6.3: salida 0, sin errores de scripts.

`res://tests/regressions.tscn`: **54 comprobaciones, 0 fallos**, salida 0. Ejecucion en una copia del proyecto con nombre y directorio de usuario de QA separados; no se utilizaron partidas personales.

La suite comprueba movimiento normal y sprint; cancelacion por ataque/defensa; vida llena y curacion; limpieza del aviso tras consumir o cambiar de escena; catalogo, capacidad de 12 objetos y bonos de equipo; apertura/cierre de mochila; bloqueo del inventario con una sesion ENet local; guardado desde pausa y carga real de partidas nuevas y antiguas; animaciones y orientacion del Guardian, fase dos, onda con dano, muerte, reanudacion de enemigos y encuentro de Boss Rush.

Los archivos `tests/*` se excluyen de la exportacion Android. El codigo de la pocion del PR 4 y los archivos del jefe de piso original no tienen diferencias frente a `main`.

## Limites y revision pendiente

- No se ha realizado una nueva revision visual del juego combinado. Las comprobaciones de UI verifican nodos, senales y estado, no la apariencia en pantalla.
- No se ha probado el resultado combinado en un dispositivo Android fisico ni entre dos telefonos en Wi-Fi. La comprobacion ENet local solo valida las restricciones de inventario; no equivale a una partida LAN completa.
- No se genero ni firmo un AAB, ni se publico en Play Store.
- Godot muestra la advertencia de ObjectDB al cerrar la escena de juego durante la prueba; no aparecieron errores de script. No se declara ausencia de fugas por esta suite.
- Este PR permanece abierto para revision y aprobacion explicita de Gabriel. No habilitar fusion automatica ni fusionar como consecuencia de que las pruebas pasen.
