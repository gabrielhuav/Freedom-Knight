# Guardián de las Sombras — guía de validación

Este cambio agrega un nuevo jefe en el proyecto `freedom-knight` de Godot 4.6.

## Qué se agregó

- Escena independiente `guardian_sombras.tscn`, con sprites de jefe ya existentes (sin assets de terceros).
- IA de persecución y ataque reutilizando la lógica del jefe de piso.
- Fase 2 al bajar de 50% de salud: apariencia morada intensa, mayor velocidad y ataques más frecuentes.
- Onda de sombras cada tres ataques durante la fase 2, con anillo de advertencia visible durante 0.75 s. El objetivo puede esquivar alejándose más de 230 unidades del jefe.
- En Arcade, encuentro único al alcanzar aproximadamente 30 enemigos derrotados (umbral adaptativo). Se conserva el jefe del mapa al umbral original.
- Tercera opción de jefe en Boss Rush.
- Registro de la escena en MultiplayerSpawner. La selección de objetivos y la aplicación de daño corresponden al host/solitario.

## Pruebas manuales necesarias

> Las pruebas siguientes están **pendientes** hasta ejecutar el proyecto en Godot 4.6. No se deben marcar como aprobadas antes de contar con evidencia.

1. Abrir `freedom-knight/project.godot` en Godot 4.6 y confirmar que no hay errores de parseo o recursos faltantes.
2. Iniciar Arcade en solitario, derrotar aproximadamente 30 enemigos y verificar que aparece **Guardián de las Sombras** una sola vez.
3. Confirmar que el jefe persigue al jugador, puede recibir daño y muestra su barra de vida.
4. Reducir su salud por debajo del 50%: observar apariencia más intensa, aviso de fase 2 y aumento de agresividad.
5. Durante la fase 2, comprobar advertencia circular y esquiva de la onda saliendo del radio. Dentro del radio se debe aplicar daño una sola vez.
6. Derrotar al jefe y comprobar que desaparece, aparecen dos pociones y se reanuda la progresión.
7. Continuar hasta el siguiente jefe de mapa y verificar que el encuentro nuevo no impide cambiar de zona.
8. Iniciar Boss Rush y realizar varias rondas: deben poder aparecer los tres tipos de jefes.
9. Probar LAN con host y un cliente: verificar presencia del jefe en ambos, fase 2, anillo de advertencia y daño decidido únicamente por el host.
10. Capturar un video breve que muestre aparición, cambio de fase, onda y derrota.

## Limitaciones

- Las ilustraciones del Guardián reutilizan los recursos gráficos del jefe existente, diferenciadas con una paleta violeta. No se añaden imágenes externas nuevas.
- Los resultados visuales, de balance y de sincronización multijugador requieren ejecución real.
