# Play Store · Solicitud de ACCESO A PRODUCCIÓN

**Plantilla reutilizable v2 — cuestionario completo.** Actualizada el 15 ago 2026 tras el
envío de Freedom Knight.

> **Qué cambió respecto de la v1.** La versión anterior (escrita tras Politécnico Open World)
> registraba **4 preguntas**. El formulario real tiene **9**. Faltaban cinco: la de comentarios
> del Bloque 1, las tres completas del Bloque 2 y la primera del Bloque 3. Aquí están todas,
> con su texto literal.

---

## 1. Qué es este trámite

Google exige a las cuentas de desarrollador personal correr una prueba cerrada con al menos
**12 verificadores durante 14 días seguidos** antes de poder publicar en producción. Cumplido
eso, se habilita el formulario de solicitud, con tres bloques:

1. Acerca de la prueba cerrada
2. Acerca de tu juego
3. Acerca del nivel de preparación para publicar en producción

### Tres cosas que muerden

- **Cada campo de texto topa en 300 caracteres** y no avisa hasta que pegas de más.
  Contar antes, y contarlo con script — a ojo se falla por uno o dos.
- **El formulario no deja consultar lo enviado.** Si te rechazan, un reenvío tendría que
  improvisar respuestas nuevas, y la incoherencia entre envíos es justo lo que dispara
  escrutinio. Copia aquí lo que mandes, **en el momento de mandarlo**.
- **Las preguntas cambian.** Entre el envío de POW (ago 2026) y el de Freedom Knight
  (ago 2026) aparecieron cinco preguntas nuevas. Captura el texto literal cada vez.

---

## 2. El cuestionario completo (9 preguntas)

### Bloque 1 · Acerca de la prueba cerrada

**1.1** — ¿Cómo reclutaste usuarios para la prueba cerrada?
*"Por ejemplo, ¿le pediste a amigos y familiares que participaran? ¿o recurriste a un
proveedor de pruebas pagado?"* · máx. 300

**1.2** — ¿Qué tan fácil fue reclutar verificadores para tu juego?
Opción única: Muy difícil · Difícil · Ni fácil ni difícil · Fácil · Muy fácil

**1.3** — Describe el nivel de participación de los verificadores durante la prueba cerrada.
*"Cuéntanos si los verificadores usaron o no todas las funciones del juego, y si ese uso fue
coherente con la forma en la que esperarías que juegue un usuario real. De lo contrario,
describe las diferencias que esperarías notar."* · máx. 300

**1.4** — Proporciona un resumen de los comentarios que recibiste de los verificadores. Indica
el método que usaste para recopilar los comentarios. · máx. 300

> Pide **dos cosas en un solo campo**: el resumen de los comentarios y el método de
> recolección. Hay que cubrir ambas o la respuesta queda incompleta.

### Bloque 2 · Acerca de tu juego

**2.1** — ¿Cuál es el público objetivo de tu juego? · máx. 300

**2.2** — Describe qué aspectos hacen que tu juego se destaque · máx. 300

**2.3** — ¿Cuántas instalaciones esperas que tenga tu juego en el primer año?
Opción única: entre 0 y 10,000 · entre 10,000 y 100,000 · entre 100,000 y 1 millón ·
Más de 1 millón · No lo sé

> Google aclara en el propio formulario: *"Tus respuestas no se muestran en Google Play y no
> afectarán las funciones ni los servicios a los que puedes acceder en Play Console, la forma
> en que se muestra tu juego ni tu elegibilidad."* Inflar la cifra no compra nada.

### Bloque 3 · Nivel de preparación

**3.1** — ¿Qué cambios hiciste en tu juego según lo que aprendiste durante la prueba cerrada?
· máx. 300

> **La pregunta clave del formulario.** Verifica que la prueba cerrada haya servido para algo,
> no que hayas dejado pasar 14 días. Debe enlazar con lo que declaraste en la 1.4:
> feedback → cambio concreto, trazable.

**3.2** — ¿Cómo decidiste que tu juego está listo para producción? · máx. 300

---

## 3. Ejemplo trabajado: Freedom Knight

Enviado el **15 ago 2026, 1:11 p.m.** Paquete `com.richycm.freedomknight`.
Conteos verificados con script. Estado: en revisión.

**1.1 · 276/300**
> Recluté principalmente a estudiantes de la ESCOM-IPN, jugadores habituales de móvil y
> público objetivo del juego, y completé el grupo con amigos y familiares. Participaron
> activamente más de 15 verificadores en la prueba cerrada vía Play Store, a lo largo de más
> de dos meses.

**1.2 → Difícil**
> Coherente con la 1.1: hay acceso a estudiantes, pero reunir y sostener el mínimo de 12
> durante 14 días seguidos costó trabajo real. En POW se respondió "Fácil"; la respuesta
> honesta depende del caso y no penaliza.

**1.3 · 299/300**
> Probaron las funciones principales: cinemática, los dos mapas, combate contra arqueros y
> caballeros, el control táctil, pociones, saco de entrenamiento y guardado. Jugaron como un
> si fuera un juego real, reportando fallos si veían. El multijugador LAN se usó poco ya que
> deben estar en la misma red.

*(Se coló una errata: "como un si fuera" y "reportando fallos si veían". Se detectó con el
campo ya en 299/300. Lección: redactar y contar antes de pegar, no editar dentro del campo.)*

**1.4 · 299/300**
> Los comentarios se recogieron en un grupo de mensajería: Discord, WhatsApp, etc., sesiones
> presenciales con los estudiantes y con issues en GitHub. Comentaron sobre todo ajustes al
> control táctil y balance de dificultad, además de errores puntuales. Todo se atendió en las
> actualizaciones 1.1 y 1.2.

**2.1 · 267/300**
> Jugadores de móvil aficionados a la acción 2D y a los juegos arcade de oleadas, sobre todo
> adolescentes y adultos jóvenes. Está pensado para partidas cortas con control táctil y para
> quienes disfrutan competir por rondas y jugar con amigos en la misma red local.

**2.2 · 273/300**
> Ofrece multijugador local por Wi-Fi sin internet ni servidores: el juego descubre las
> partidas en la red y permite unirse al instante. Suma un modo Arcade por oleadas, un Boss
> Rush y tres dificultades, además de una gata que puedes adoptar y que te cura mientras
> combates.

**2.3 → entre 0 y 10,000**

**3.1 · 294/300**
> A partir del feedback ajusté el control táctil y el comportamiento del héroe, y corregí los
> errores reportados, en las actualizaciones 1.1 y 1.2. Como pedían mejor balance, añadí un
> selector de tres dificultades. También sumé contenido: modo Arcade, Boss Rush, mapas y
> enemigos nuevos.

**3.2 · 271/300**
> Tras más de dos meses de prueba cerrada con más de 15 verificadores y tres actualizaciones
> (1.0.0.1, 1.1 y 1.2), los fallos reportados fueron disminuyendo y las funciones principales
> se mantuvieron estables. El juego se completa sin errores, por eso lo considero listo.

---

## 4. Qué hace que una respuesta funcione

Lo que sostiene los ejemplos de arriba, y lo que hay que reproducir en cada app:

- **Un canal de reclutamiento concreto y verosímil**, no "amigos y familiares" a secas.
  "Estudiantes de ESCOM-IPN" es específico y comprobable.
- **Una razón por la que ese grupo es el público objetivo.** En POW: el juego ocurre en su
  propio campus. En FK: son jugadores habituales de móvil. Si no hay vínculo temático, di por
  qué el grupo representa al usuario real.
- **Un número, y honesto.** "Más de 50" pesa más que "varios". Con 16–30 verificadores, "más
  de 15" es exacto sin inflar; poner "más de 25" por sonar mejor es lo que hunde el resto.
- **Admitir la función que se usó poco, y por qué.** En ambas apps: el multijugador, porque
  necesita dos dispositivos. La 1.3 pide explícitamente las diferencias; ocultarlas es peor.
- **Criterio de "listo" medible**, no una opinión: los fallos reportados bajaron, las funciones
  principales se mantuvieron estables, no hay errores críticos.
- **Cadena feedback → cambio, trazable** (para la 3.1). Si en la 1.4 dijiste que el feedback
  fue sobre control táctil y balance, la 3.1 debe decir qué hiciste con cada cosa. En FK ambas
  afirmaciones se pueden verificar en el repo.

### Qué evitar

- Superlativos sin respaldo.
- "Todos probaron todo" — nadie lo cree.
- **Prometer en el Bloque 1 funciones que la build de la prueba cerrada no tenía.** Ojo con
  esto: en FK, el modo Arcade y el Boss Rush se subieron en la 1.3, que aún estaba en revisión
  el día del envío. Los verificadores nunca los jugaron, así que la 1.3 describe **solo** lo
  que había hasta la 1.2. En el **Bloque 2 sí** se pueden mencionar: esa sección pregunta por
  el juego, no por la prueba.
- Editar dentro del campo cuando ya vas en 299/300. Redacta fuera, cuenta, y pega.

---

## 5. Para adaptar a otra app

Rellena esto antes de escribir; con estos datos las respuestas salen casi solas.

| Dato | App nueva |
|---|---|
| Nº de verificadores (Play Console › Prueba cerrada › Verificadores) | |
| De dónde salieron (canal concreto) | |
| Por qué son el público objetivo | |
| Funciones que sí ejercitaron **en la build que probaron** | |
| Función menos usada + por qué | |
| Cuánto duró la prueba cerrada (fechas exactas) | |
| Método de recolección de comentarios | |
| Qué dijeron los comentarios (2–3 temas concretos) | |
| Qué cambiaste a raíz de esos comentarios | |
| Señal medible de que ya estaba listo | |
| Público objetivo del juego | |
| Diferenciador real (verificable en el código) | |
| Instalaciones esperadas primer año | |

### Registro del envío

Pegar en el momento de enviar, no después.

```
App:           
Enviado:       
1.1 (   /300): 
1.2:           
1.3 (   /300): 
1.4 (   /300): 
2.1 (   /300): 
2.2 (   /300): 
2.3:           
3.1 (   /300): 
3.2 (   /300): 
```

### Contar caracteres sin fallar

En Git Bash o WSL, redacta en un archivo `respuestas.txt` con formato `clave|texto` y corre:

```bash
while IFS='|' read -r k v; do printf "%-8s -> %s\n" "$k" "${#v}"; done < respuestas.txt
```

Cuenta correctamente los acentos y la ñ, que es donde falla el conteo a ojo.

---

## 6. Después de enviar

- Google dice **7 días o menos**, "ocasionalmente puede llevar más".
- La respuesta llega por correo **al propietario de la cuenta** de Play Console. Revisa spam.
- **No reenvíes** ni crees otra solicitud mientras esté en revisión. No acelera nada y puede
  reiniciar la cola.
- Si rechazan, el correo dice qué corregir. Corrige **solo eso** y reenvía; no reescribas todo
  — de ahí la importancia del registro.

---

## 7. Acceso a producción ≠ publicar en producción

Que aprueben la solicitud **solo habilita el permiso**. Producción sigue en *Inactivo* hasta
que promuevas una versión a propósito.

Y ojo con los relojes en paralelo: la **revisión del AAB** y la **solicitud de acceso** son
trámites independientes, cada uno con su plazo. Aprobar uno no aprueba el otro, y ninguno
publica nada por sí solo.

Si tu CI sube a una pista concreta —en POW `android-release.yml` está fijado a
`tracks: alpha`— seguirá subiendo ahí hasta que cambies ese valor. No ocurre solo al ser
aprobado.

Publicar sigue exigiendo el resto del expediente en orden:

- **Formulario de Seguridad de los datos** coherente con lo que la app recopila de verdad.
  Es el que más rechazos causa por incoherencia.
- **Política de privacidad** y **página de eliminación de cuenta** que carguen sin 404.
- **Correo de contacto** correcto en ambas.

Si las sirves desde GitHub Pages, protege esa rama: que la borren es un rechazo garantizado.
