# Inventario y equipamiento (Arcade individual)

Esta contribución añade un inventario simple de **12 espacios** y equipo funcional a Freedom Knight, con una interfaz accesible en PC y Android. Se desarrolla en una rama separada del Guardián de las Sombras.

## Flujo de juego

1. Derrotar enemigos normales: tienen un **25 % de probabilidad** de dejar un objeto de equipo (máximo 5 objetos simultáneos en el suelo). Los jefes de Boss Rush y el dragón de Arcade dejan un objeto garantizado, sujeto al límite de cinco.
2. Acercarse al objeto hasta ver la instrucción de recogida.
3. Presionar **E** / acción `interact` (botón de mano en Android) para recogerlo.
4. Abrir la **mochila** desde su botón táctil superior izquierdo o mediante la tecla **I**.
5. Tocar o hacer clic en un objeto para **equiparlo o desequiparlo**. Se equipa como máximo un arma y una armadura.
6. Guardar la partida desde el menú de pausa; el inventario y equipo se registran en el guardado. Las partidas antiguas pueden cargarse con el inventario vacío.

## Equipo disponible

| Objeto | Categoría | Efecto |
| --- | --- | --- |
| Espada de hierro | Arma | +2 ataque |
| Espada de las sombras | Arma | +4 ataque |
| Armadura de cuero | Armadura | +1 defensa |
| Armadura de acero | Armadura | +3 defensa |

El daño final conserva el cálculo de defensa/nivel existente; el equipamiento agrega bonos. No se añaden texturas descargadas: el botín usa formas dibujadas mediante `_draw` y la UI usa controles de Godot.

## Alcance y limitaciones

- **Primera entrega solo para Arcade individual.** En multijugador se deshabilitan el botín y el inventario para evitar la manipulación de estadísticas desde clientes sin un protocolo autoritativo completo.
- No se añade capacidad de vender objetos, combinarlos, ni cambiar los sprites o animaciones según la armadura equipada.
- El guardado conserva inventario/equipo en datos JSON. El script valida IDs del catálogo antes de restaurarlos.
- Hay elementos repetidos posibles, que se muestran por su nombre; una sola selección por tipo de equipo es efectiva.

## Lista de pruebas manuales pendientes

- [ ] Abrir `freedom-knight/project.godot` en Godot, sin errores de parseo.
- [ ] Iniciar Arcade individual: abrir/cerrar mochila con **I** y con el botón táctil.
- [ ] Comprobar que se puede reanudar el juego y usar el menú pausa sin quedar bloqueado.
- [ ] Derrotar enemigos hasta que aparezca botín. Acercarse y recoger con **E** / botón de mano.
- [ ] Equipar espada y verificar que el ataque mostrado aumenta; pulsar de nuevo y verificar que vuelve a su valor original.
- [ ] Equipar armadura y comprobar reducción del daño que recibe el personaje.
- [ ] Llenar 12 espacios y comprobar que no se puede recoger un decimotercer objeto.
- [ ] Guardar, salir y cargar la partida; verificar que se conservan los objetos y el equipo elegido.
- [ ] Probar apertura, desplazamiento y selección del inventario en pantalla táctil.
- [ ] Verificar que una sesión multijugador no muestra la mochila ni genera objetos en el suelo.

**Estado de QA:** estas pruebas deben realizarse en Godot; no están marcadas como aprobadas por el simple hecho de crear los archivos.
