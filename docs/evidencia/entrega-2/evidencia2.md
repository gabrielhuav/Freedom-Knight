# Scrum — Freedom Knight (Entrega 2)

## 1. Equipo y repositorios

| Integrante | Usuario GitHub |
|---|---|
| Diego Mendieta | [@DiegxMG](https://github.com/DiegxMG) |
| Sofía Ortega | [@sofiaortegar01](https://github.com/sofiaortegar01) |

- **Repositorio base:** https://github.com/gabrielhuav/Freedom-Knight
- **Fork del equipo:** https://github.com/DiegxMG/Freedom-Knight

## 2. Product Goal

Mejorar la jugabilidad de Freedom Knight en Android y PC añadiendo mecánicas de movilidad y objetos tácticos que den al jugador más control sobre el ritmo del combate y la exploración, manteniendo la estabilidad del modo multijugador.

## 3. Product Backlog

| ID | Historia de usuario | Prioridad | Pull Request | Estado |
|---|---|---|---|---|
| US-01 | Como jugador, quiero que el juego me avise y no gaste la poción de vida cuando mi salud ya está al máximo, para no desperdiciarla. | Alta | [PR #1](https://github.com/gabrielhuav/Freedom-Knight/pull/1) | En revisión |
| US-02 | Como jugador, quiero correr al tocar dos veces rápido el joystick, para moverme más rápido por el mapa cuando lo necesite. | Alta | [PR #2](https://github.com/gabrielhuav/Freedom-Knight/pull/2) | En revisión |
| US-03 | Como jugador, quiero encontrar una poción azul de velocidad que me dé un impulso temporal mayor al sprint, para tener una opción táctica más allá de la curación. | Media | [PR #3](https://github.com/gabrielhuav/Freedom-Knight/pull/3) | En revisión |

## 4. Criterios de aceptación

### US-01 — Bloqueo de poción de vida con salud completa

- **Dado** el modo Arcade con la salud del jugador al máximo y al menos una poción de vida disponible,
- **cuando** el jugador intenta usar la poción,
- **entonces** aparece un aviso en pantalla, la salud no cambia, la poción no se consume y el aviso desaparece solo tras aproximadamente 2 segundos.
- **Comportamiento normal preservado:** con salud menor al 100 %, la poción cura y se consume.

### US-02 — Sprint con doble toque

- **Dado** el jugador en movimiento con el joystick virtual,
- **cuando** suelta el joystick y vuelve a empujarlo en menos de 300 ms,
- **entonces** su velocidad se multiplica por 1.5 (`multiplicador_sprint`).
- Detenerse por completo o atacar reinicia el estado de sprint.

### US-03 — Poción de velocidad (azul)

- **Dado** una partida en modo Arcade,
- **cuando** el sistema genera pociones,
- **entonces** algunas aparecen con la textura azul y, al recogerlas, el jugador obtiene una velocidad mayor que la del sprint.
- No se puede acumular otra poción de velocidad mientras una está activa; se muestra un aviso en pantalla.
- La poción está registrada en el `MultiplayerSpawner` para verse en partidas en red.

## 5. Sprint 2

**Sprint Goal:** entregar tres mejoras jugables (bloqueo de poción con vida llena, sprint por doble toque y poción de velocidad), cada una con su Pull Request y evidencia.

### Sprint Backlog

| Tarea | Historia | Estado |
|---|---|---|
| Validar salud completa y mostrar aviso temporal en `pocion_de_vida.gd` | US-01 | Hecho |
| Declarar variables y programar la lógica de doble toque en `caballero.gd` | US-02 | Hecho |
| Grabar videos de evidencia antes y después del sprint | US-02 | Hecho |
| Crear sprite, escena y script de la poción de velocidad | US-03 | Hecho |
| Priorizar el boost azul sobre el sprint y el movimiento normal en `caballero.gd` | US-03 | Hecho |
| Generar la poción en `escenario_pruebas.gd` y registrarla en el `MultiplayerSpawner` | US-03 | Hecho |
| Grabar video de evidencia de la poción de velocidad | US-03 | Hecho |

## 6. Definition of Done

Una historia se considera terminada cuando:

1. Cumple todos sus criterios de aceptación.
2. Fue probada localmente en Godot.
3. Tiene un Pull Request con descripción (What changed / Why / QA evidence / Risk-rollback).
4. Incluye evidencia (captura o video) del antes y el después.
5. No rompe el flujo de juego existente ni la sincronización multijugador.
6. El Pull Request fue revisado y aceptado por el profesor.

## 7. Sprint Review

- **Incremento entregado:** tres mejoras jugables (ver sección 3).
- **Demostración:** capturas en el PR #1 y videos de evidencia en los PRs #2 y #3.

## 8. Sprint Retrospective

**Qué salió bien**
- Cada Pull Request incluye criterios de aceptación, evidencia y plan de rollback.
- Las mecánicas nuevas quedaron parametrizadas (`multiplicador_sprint`, `probabilidad_pocion_velocidad`), por lo que el balance se puede ajustar sin cambiar la lógica.

**Qué se puede mejorar**
- Algunas ramas se construyeron una sobre otra, por lo que los PRs muestran commits de documentación y de PRs anteriores.
- Vincular cada PR con su issue desde el inicio.

**Acciones para el siguiente sprint**
- Crear una rama por historia, siempre a partir del `main` actualizado del repositorio base.
- Abrir el issue antes de empezar a programar y referenciarlo en el Pull Request.

## 9. Enlaces de verificación

- Pull Request #1: https://github.com/gabrielhuav/Freedom-Knight/pull/1
- Pull Request #2: https://github.com/gabrielhuav/Freedom-Knight/pull/2
- Pull Request #3: https://github.com/gabrielhuav/Freedom-Knight/pull/3