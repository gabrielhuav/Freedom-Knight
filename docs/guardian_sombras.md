# Shadow Guardian — Stability Restore and QA

## Recovery change

The animated Shadow Guardian update was temporarily rolled back after the contributor reported two regressions: the inventory button / I-key shortcut disappeared, and the regular enemy flow stopped near the Shadow Guardian encounter.

The original, previously demonstrated playable boss scene and script have been restored. The original boss is still selectable in Arcade and Boss Rush, with the same second phase, telegraphed wave, damage, defeat signal and progression.

A defensive check was added before setting `jefe_activo` in the spawning method, so a null or failed boss instantiation does not leave the map permanently flagged as having an active boss.

The original inventory UI was also restored, with the newly added backpack image loaded **optionally at runtime**. The text button and the **I** shortcut must remain available even if the icon cannot be imported.

## Custom artwork

The new original 4x4 spectral-boss spritesheet (`guardian_sombras_sheet.png`) and the backpack icon (`icono_mochila.png`) remain in the repository as gameplay assets. **The custom boss animations are not active yet.** They must be reintegrated only after the stable gameplay flow is confirmed in Godot.

## Manual QA — required before approval

- [ ] Launch the updated branch in Godot with no parser or resource-loading errors.
- [ ] Confirm that the **Mochila [I]** button is visible and I opens/closes the inventory; test the new icon where supported.
- [ ] Defeat enough regular enemies to trigger the Shadow Guardian, confirm the boss appears and the level does not get stuck.
- [ ] Defeat the boss; verify its death signal, reward and continued regular enemy spawning / map progression.
- [ ] Confirm attack, second phase and shadow-wave warning remain functional.
- [ ] Check save/load, Boss Rush, and Android/Mobile controls.
- [ ] Later, reintroduce custom boss frames incrementally and rerun every check.

**QA status:** This recovery has been committed and statically reviewed; it has **not** yet been executed in the contributor's Godot environment.

Screenshots used for QA should remain in PR comments, not in the gameplay asset directory.
