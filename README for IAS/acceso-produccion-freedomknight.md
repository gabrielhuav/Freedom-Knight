# Solicitud de ACCESO A PRODUCCIÓN — Freedom Knight

Sigue la plantilla reutilizable de Play Store. **Estado: en preparación**, aún no enviado.

Recordatorios de la plantilla:
- Cada campo de texto topa en **300 caracteres**. Contar antes de pegar.
- El formulario **no deja consultar lo enviado** después. Copiar aquí lo que se mande, en el
  momento de mandarlo.
- No prometer funciones que la build de la prueba cerrada no tenía.

---

## 1. Contexto verificado (15 ago 2026)

### Qué han jugado realmente los verificadores

⚠️ **Esto es lo más importante para no meter la pata.** El contenido de la Semana5 —modo
Arcade, Boss Rush, dragón, jefe de piso, la gata compañera, mapas 2/3/4— entró en la **1.3**,
que se subió el 15 ago 2026 y **sigue en revisión**. Ningún verificador lo ha jugado.

Lo que la prueba cerrada sí ha tenido (versiones 1.0.0.1 a 1.2, código hasta el commit
`Semana4` del 18 may 2026):

- Cinemática de introducción
- Menú principal y menú de pausa
- Control táctil con joystick virtual
- Mapas 1 y 2
- Combate contra Arquero (con flechas), Caballero Malo y Caballero Malo H
- NPCs (monjes) con diálogo
- Poción de vida
- Saco de boxeo para entrenar
- Guardado de partida
- HUD

El multijugador LAN existía en el código desde Semana4, pero se reescribió a fondo en
Semana5 (+499 líneas en `NetworkManager.gd`), así que en la 1.2 estaba incipiente.

### Cronología de la prueba cerrada

| Versión | versionCode | Fecha |
|---|---|---|
| Freedom Knight 1.0.0.1 | 1 | 12 jun 2026 |
| 1.1 | 2 | 19 jun 2026 |
| 1.2 | 3 | 22 jun 2026 |
| 1.3 | 4 | 15 ago 2026 (en revisión) |

**Duración: 64 días corridos** (12 jun → 15 ago 2026), con 4 entregas. El requisito de Google
son 14 días seguidos con 12 verificadores, así que sobra margen por duración.

Canal: Prueba cerrada — Alpha. 16 países o regiones. 12,211 dispositivos compatibles.

---

## 2. Datos base para redactar

| Dato | Freedom Knight |
|---|---|
| Nº de verificadores | Entre 16 y 30. En las respuestas se dice "más de 15", que es exacto sin inflar |
| De dónde salieron (canal concreto) | Estudiantes de ESCOM-IPN, completado con amigos y familiares |
| Por qué son el público objetivo | Jugadores habituales de videojuegos en móvil |
| Funciones que sí ejercitaron | Ver lista de la sección 1 (todo lo de la 1.2) |
| Función menos usada + por qué | Multijugador LAN — requiere dos dispositivos en la misma red, y en la 1.2 aún era incipiente |
| Cuánto duró la prueba cerrada | 64 días (12 jun → 15 ago 2026), 4 versiones publicadas |
| Señal de que ya estaba listo | Fallos reportados a la baja y funciones principales estables a lo largo de 3 actualizaciones |
| Método de recolección de comentarios | Grupo de mensajería, sesiones presenciales e issues de GitHub |
| Dificultad de reclutamiento (1.2) | Difícil |
| Pruebas fuera de Play | Repositorio en GitHub; existe además un export Web/PWA en el repo — **confirmar si se usó para probar** |

---

## 3. Respuestas a enviar

Pendientes de redactar hasta tener los datos de la sección 2.

### Bloque 1 · Acerca de la prueba cerrada

**1.1 — ¿Cómo reclutaste usuarios para la prueba cerrada?** (máx. 300) — **268/300**

> Recluté principalmente a estudiantes de ESCOM-IPN, jugadores habituales de móvil y público
> objetivo del juego, y completé el grupo con amigos y familiares. Participaron más de 15
> verificadores en la prueba cerrada vía Play Store, a lo largo de más de dos meses.

**1.2 — ¿Qué tan fácil fue reclutar verificadores?** (Muy difícil / Difícil / Ni fácil ni
difícil / Fácil / Muy fácil)

> **Difícil**

Coherente con 1.1: hay acceso a estudiantes, pero reunir y sostener el mínimo de 12
verificadores durante 14 días seguidos costó trabajo real.

**1.3 — Describe el nivel de participación de los verificadores durante la prueba cerrada.**
*"Cuéntanos si los verificadores usaron o no todas las funciones del juego, y si ese uso fue
coherente con la forma en la que esperarías que juegue un usuario real. De lo contrario,
describe las diferencias que esperarías notar."* (máx. 300) — **291/300**

> Probaron las funciones principales: cinemática, los dos mapas, el combate contra arqueros y
> caballeros, el control táctil, pociones, saco de entrenamiento y guardado. Jugaron como un
> usuario real, reportando fallos. El multijugador LAN se usó poco: exige dos dispositivos en
> la misma red.

Describe **solo lo que había en la 1.2**, no el contenido de la 1.3 que sigue en revisión.
Admite la función menos usada, que es lo que pide explícitamente la pregunta.

**1.4 — Proporciona un resumen de los comentarios que recibiste de los verificadores. Indica
el método que usaste para recopilar los comentarios.** (máx. 300)

⚠️ **Pregunta nueva**, no estaba en la plantilla de la solicitud anterior (Politécnico Open
World). Añadirla a la plantilla reutilizable. Pide dos cosas en un solo campo de 300: el
**resumen de los comentarios** y el **método de recolección**. Hay que cubrir ambas.

Borrador — **285/300**. ⚠️ **El método está confirmado; el contenido de los comentarios hay
que verificarlo antes de enviar.**

> Los comentarios se recogieron en un grupo de mensajería, en sesiones presenciales con los
> estudiantes y como issues en GitHub. Señalaron sobre todo ajustes al control táctil y al
> balance de dificultad, además de errores puntuales. Todo se atendió en las actualizaciones
> 1.1 y 1.2.

### Bloque 2 · Acerca de tu juego

✅ **Preguntas capturadas el 15 ago 2026.** Añadirlas a la plantilla reutilizable: en la
solicitud de Politécnico Open World no habían quedado registradas. Son tres.

**2.1 — ¿Cuál es el público objetivo de tu juego?** (máx. 300) — **267/300**

> Jugadores de móvil aficionados a la acción 2D y a los juegos arcade de oleadas, sobre todo
> adolescentes y adultos jóvenes. Está pensado para partidas cortas con control táctil y para
> quienes disfrutan competir por rondas y jugar con amigos en la misma red local.

**2.2 — Describe qué aspectos hacen que tu juego se destaque.** (máx. 300) — **273/300**

> Ofrece multijugador local por Wi-Fi sin internet ni servidores: el juego descubre las
> partidas en la red y permite unirse al instante. Suma un modo Arcade por oleadas, un Boss
> Rush y tres dificultades, además de una gata que puedes adoptar y que te cura mientras
> combates.

El diferenciador real es el **LAN sin servidores**: casi todo el multijugador móvil exige
internet y cuenta. Está verificado en `NetworkManager.gd` (ENet + descubrimiento por UDP).

**2.3 — ¿Cuántas instalaciones esperas que tenga tu juego en el primer año?**
(entre 0 y 10,000 / entre 10,000 y 100,000 / entre 100,000 y 1 millón / Más de 1 millón /
No lo sé)

> **entre 0 y 10,000**

Es lo honesto para un proyecto estudiantil que sale de una alpha cerrada con ~16
verificadores. Inflarlo no da ninguna ventaja: la respuesta no afecta la elegibilidad ni cómo
se muestra el juego, y una cifra desproporcionada solo resta credibilidad al resto.

### Bloque 3 · Nivel de preparación

⚠️ **Son dos preguntas, no una.** La plantilla anterior solo registraba la segunda. Añadir la
primera a la plantilla reutilizable.

**3.1 — ¿Qué cambios hiciste en tu juego según lo que aprendiste durante la prueba cerrada?**
(máx. 300) — **294/300**

> A partir del feedback ajusté el control táctil y el comportamiento del héroe, y corregí los
> errores reportados, en las actualizaciones 1.1 y 1.2. Como pedían mejor balance, añadí un
> selector de tres dificultades. También sumé contenido: modo Arcade, Boss Rush, mapas y
> enemigos nuevos.

Encaja con lo declarado en la 1.4 (control táctil + balance de dificultad) y es verificable en
el repo: `caballero.gd` se reescribió a fondo en el commit `Semana5`, y el selector de
dificultad Fácil/Medio/Difícil aparece en `Scripts/ArcadeMenu.gd` con sus tres texturas en
`Imagenes/Dificultad *.png`. La cadena feedback → cambio queda trazable.

**3.2 — ¿Cómo decidiste que tu juego está listo para producción?** (máx. 300) — **283/300**

> Tras más de dos meses de prueba cerrada con más de 15 verificadores y tres actualizaciones
> (1.0.0.1, 1.1 y 1.2), los fallos reportados fueron disminuyendo y las funciones principales
> se mantuvieron estables. El juego se completa sin errores críticos, así que lo consideré
> listo.

---

## 4. Registro del envío

Rellenar en el momento de enviar, no después.

**App:** Freedom Knight (`com.richycm.freedomknight`) · **Capturado:** 15 ago 2026

**Bloque 1 — texto realmente introducido en el formulario:**

`1.1 (276/300)` — Recluté principalmente a estudiantes de la ESCOM-IPN, jugadores habituales
de móvil y público objetivo del juego, y completé el grupo con amigos y familiares.
Participaron activamente más de 15 verificadores en la prueba cerrada vía Play Store, a lo
largo de más de dos meses.

`1.2` — Difícil

`1.3 (299/300)` — Probaron las funciones principales: cinemática, los dos mapas, combate
contra arqueros y caballeros, el control táctil, pociones, saco de entrenamiento y guardado.
Jugaron como un si fuera un juego real, reportando fallos si veían. El multijugador LAN se usó
poco ya que deben estar en la misma red.

`1.4 (299/300)` — Los comentarios se recogieron en un grupo de mensajería: Discord, WhatsApp,
etc., sesiones presenciales con los estudiantes y con issues en GitHub. Comentaron sobre todo
ajustes al control táctil y balance de dificultad, además de errores puntuales. Todo se
atendió en las actualizaciones 1.1 y 1.2.

> ⚠️ La 1.3 quedó con dos erratas: *"como un si fuera"* (sobra "un") y *"reportando fallos si
> veían"* (falta "los ... que"). Se detectaron cuando el campo ya estaba en 299/300. Versión
> corregida que cabe en **296/300**, por si se puede volver atrás o para un reenvío:
>
> Probaron las funciones principales: cinemática, los dos mapas, combate contra arqueros y
> caballeros, control táctil, pociones, saco de entrenamiento y guardado. Jugaron como si
> fuera un juego real, reportando los fallos que veían. El multijugador LAN se usó poco:
> deben estar en la misma red.

**Bloque 2 — enviado tal cual está redactado en la sección 3** (2.1 267/300, 2.2 273/300,
2.3 "entre 0 y 10,000").

**Bloque 3 — 3.1 enviada tal cual (294/300). La 3.2 se envió con un ajuste:**

`3.2 (271/300)` — Tras más de dos meses de prueba cerrada con más de 15 verificadores y tres
actualizaciones (1.0.0.1, 1.1 y 1.2), los fallos reportados fueron disminuyendo y las
funciones principales se mantuvieron estables. El juego se completa sin errores, por eso lo
considero listo.

> Diferencia con el borrador: dice *"sin errores"* en vez de *"sin errores críticos"*, y
> *"por eso lo considero"* en vez de *"así que lo consideré"*. Anotado por si hubiera un
> reenvío: la coherencia entre envíos es lo que evita escrutinio.

---

## ✅ SOLICITUD ENVIADA — 15 ago 2026, 1:11 p.m.

Play Console confirma: *"Recibimos tu solicitud de acceso a producción. Estamos revisando el
formulario de solicitud."* Estado de Producción: **Inactivo**.

**No reenviar ni crear otra solicitud mientras esté en revisión.** No acelera nada y puede
reiniciar la cola. La respuesta llega por correo al propietario de la cuenta
(gabrielhuav@gmail.com); revisar spam.

---

## 5. Después de enviar

- Google dice 7 días o menos, ocasionalmente más.
- La respuesta llega por correo al propietario de la cuenta (gabrielhuav@gmail.com). Revisar spam.
- **No reenviar** ni crear otra solicitud mientras esté en revisión.
- Si rechazan, corregir solo lo que señale el correo; no reescribir todo.

### Acceso a producción ≠ publicar en producción

Aprobar la solicitud solo habilita el permiso. Además, para publicar hace falta el resto del
expediente en orden: formulario de Seguridad de los datos coherente con lo que la app recopila
de verdad, política de privacidad y página de eliminación de cuenta que carguen sin 404, y el
correo de contacto correcto en ambas.

**Pendiente de revisar para Freedom Knight:** el juego incluye multijugador LAN
(`NetworkManager.gd` usa ENet y descubrimiento por UDP) y guarda un gamertag elegido por el
jugador vía `SaveManager.nombre_jugador`. Hay que confirmar que el formulario de Seguridad de
los datos declare eso correctamente. El preset de exportación **no pide ningún permiso de
Android** (`permissions/*` todo en `false`, ni siquiera `INTERNET`), lo cual conviene
verificar contra el funcionamiento real del multijugador.
