# Ficha de Idea de Proyecto - Entrega 1

## 1. Información General
* **Ruta elegida:** FreedomKnight.
* **Motivo de la elección:** Provee una base sólida de mecánicas de plataformas y combate en 2D desarrollada sobre Godot Engine, lo que permite enfocarse en enriquecer la experiencia de juego, diseño de niveles y optimización del rendimiento móvil, además es la motivación para la idea del juego que el equipo quiere proponer en el semestre.

## 2. Definición del Problema y Usuario
* **Descripción del problema en una sola frase:** Los jugadores de títulos casuales de plataformas en dispositivos móviles carecen de experiencias arcade desafiantes que recompensen la precisión sin depender de micropagos invasivos o conectividad constante.
* **Usuario y contexto:** Jugadores jóvenes y estudiantes aficionados a los videojuegos retro/arcade de plataformas que buscan partidas cortas, ágiles e intensas durante sus traslados o tiempos libres en su dispositivo móvil.
* **Alternativa actual:** Juegos de plataformas móviles convencionales saturados de publicidad obligatoria o títulos que exigen conexión permanente a internet.

## 3. Alcance del Proyecto
* **Tarea principal del usuario:** Controlar al caballero para superar obstáculos, derrotar enemigos y sobrevivir a través de los niveles gestionando sus vidas y habilidades.
* **Criterio de éxito:** El jugador puede completar una ronda de juego con fluidez, recibiendo retroalimentación inmediata sobre su salud/vidas y visualizando el estado de fin de partida al ser derrotado.
* **Alcance de la primera versión (v1.0):**
  * Movimiento básico del personaje y combate cuerpo a cuerpo.
  * Sistema de vidas del jugador y pantalla de fin de partida (*Game Over*).
  * Menú principal navegable de forma local.
* **Funciones deliberadamente aplazadas (futuras entregas):**
  * Sistema de guardado en la nube y tabla de clasificación global.
  * Múltiples tipos de armas e inventario interactivo.
  * Modo historia extendido con cinemáticas complejas.
* **Evidencia que sostiene la idea:** Se declara de forma explícita que actualmente se trata de una **hipótesis sin validar**, sujeta a pruebas de usabilidad y balanceo de dificultad durante el semestre.

## 4. Historia de Usuario Principal
* **Historia:** Como jugador de plataformas móviles, quiero tener un contador visible de vidas y una pantalla de fin de partida clara para saber cuánto margen de error tengo antes de perder la sesión.
* **Criterio de aceptación:**
  * **Dado** que el jugador se encuentra en una partida activa con 1 vida restante,
  * **Cuando** recibe un impacto letal o cae en un área de daño,
  * **Entonces** la vida se reduce a 0 y el juego transiciona de forma inmediata y observable a la pantalla de Game Over impidiendo el control del personaje.

## 5. Material Visual
*(Aquí se enlazan los bocetos de las pantallas principales, controles en pantalla, estado de Game Over y diagrama de recorrido del usuario)*.
* `docs/material-visual/boceto_pantallas.png` - Elaborado por el equipo
* `docs/material-visual/diagrama_flujo_usuario.png` - Elaborado por el equipo.