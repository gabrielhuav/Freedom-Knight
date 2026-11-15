# Contribuir a Freedom Knight

Todo cambio a `main` debe llegar mediante un Pull Request. No se permiten pushes directos, force pushes ni eliminaciones de la rama principal.

Antes de integrar:

1. Actualizar la rama respecto de `main` y resolver los conflictos conservando las correcciones ya integradas.
2. Describir el cambio y adjuntar evidencia de las pruebas pertinentes, junto con las limitaciones conocidas.
3. Resolver las conversaciones de revision y obtener la revision aprobatoria exigida por GitHub.
4. Obtener la aprobacion explicita de Gabriel (`@gabrielhuav`) para la version final del PR. Cualquier cambio posterior requiere una nueva aprobacion.

Los asistentes deben entregar el resultado para revision y esperar esa aprobacion; no pueden aprobar en nombre de Gabriel, activar auto-merge ni eludir la proteccion de `main`.

GitHub no permite que el autor apruebe su propio PR. Los PRs de contribuyentes requieren la revision del propietario indicado en `.github/CODEOWNERS`. Si Gabriel es el autor, el PR necesita una revision independiente y una decision explicita de Gabriel; antes de integrar se debe resolver el requisito de propietario con otro mantenedor autorizado por Gabriel, sin desactivar las protecciones.

Usar Godot **4.6.x** (actualmente **4.6.3**) y abrir `freedom-knight/project.godot`.
