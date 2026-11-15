# Reglas para asistentes

## Aprobacion e integracion

- Todo cambio destinado a `main` debe pasar por un Pull Request. No hacer push directo a `main`.
- Nunca fusionar un PR sin la aprobacion explicita de Gabriel (`@gabrielhuav`) para ese PR y su version final revisada.
- Antes de pedir aprobacion, presentar el enlace del PR, el commit revisado, los cambios, las pruebas ejecutadas, sus resultados y cualquier limitacion pendiente.
- Una solicitud de revision, correccion o pruebas no autoriza la fusion. Que las pruebas pasen tampoco autoriza la fusion.
- Si aparecen commits nuevos despues de la aprobacion, repetir las comprobaciones afectadas y solicitar una nueva aprobacion antes de fusionar.
- No activar auto-merge, aprobar en nombre de Gabriel ni eludir protecciones de `main`.
- La aprobacion en el chat y las revisiones obligatorias de GitHub son requisitos separados: cumplir ambos antes de fusionar.

## Desarrollo y validacion

- Usar ramas de trabajo y mantener los cambios ajenos intactos.
- Usar Godot 4.6.x, actualmente 4.6.3. No migrar la version del motor como efecto secundario de editar escenas.
- El proyecto Godot esta en `freedom-knight/`, no en la raiz ni en `juego/`.
- Leer `README for IAS/README.md` y `README for IAS/onboarding-desarrolladores.md` antes de modificar el juego.
- Probar las funciones afectadas y sus regresiones. Distinguir las pruebas automatizadas de las pruebas visuales, Android y LAN en dispositivos fisicos.
- Nunca solicitar ni registrar contrasenas de firma. No versionar keystores, credenciales ni nuevos binarios de exportacion.
