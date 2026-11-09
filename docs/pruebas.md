# Matriz de Pruebas del Sistema - Entrega 1

## Casos de Prueba Iniciales (Línea Base del Juego)

| ID | Caso de Prueba | Dispositivo / Entorno | Pasos de Ejecución | Resultado Esperado | Resultado Real | Estado |
|---|---|---|---|---|---|---|
| TC-01 | Flujo principal de navegación | PC / Windows 11 (Godot 4.x Debug) | 1. Iniciar la aplicación.<br>2. Presionar el botón "Arcade". | El juego transiciona correctamente a la escena del nivel sin errores de carga. | Transición fluida a la escena jugable. | Aprobado |
| TC-02 | Entrada de controles (físicas y movimiento) | PC / Windows 11 (Godot 4.x Debug) | 1. Iniciar partida.<br>2. Presionar teclas de dirección (flechas / A-D) y tecla de salto/ataque. | El personaje se desplaza, ejecuta la animación de movimiento y responde a las colisiones con el suelo. | El caballero responde adecuadamente a las teclas y colisiona con el entorno. | Aprobado |
| TC-03 | Redimensión y recreación de ventana | PC / Windows 11 (Godot 4.x Debug) | 1. Iniciar el juego en ventana.<br>2. Maximizar o cambiar el tamaño de la ventana manualmente. | La interfaz y el viewport del juego escalan proporcionalmente sin desbordamientos gráficos. | La relación de aspecto se mantiene y los botones del menú se adaptan. | Aprobado |
| TC-04 | Modo desconectado / Red no disponible | PC / Windows 11 (Godot 4.x Debug) | 1. Desconectar la conexión a internet.<br>2. Abrir y ejecutar el juego desde cero. | El juego inicia y se ejecuta de forma 100% autónoma y local sin advertencias de red. | Ejecución completa sin dependencias de red. | Aprobado |
| TC-05 | Accesibilidad y contraste de interfaz | PC / Windows 11 (Godot 4.x Debug) | 1. Navegar por el menú principal.<br>2. Verificar contraste de texto en etiquetas y legibilidad de fuentes. | Los textos de "Arcade", "Configuración" y demás opciones son legibles y diferenciables sobre el fondo. | Tipografía legible con área táctil/clic delimitada correctamente. | Aprobado |