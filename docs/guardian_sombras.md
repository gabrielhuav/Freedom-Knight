# Shadow Guardian — Custom Visuals and Recovery QA

## Scope of the change

The previous working Shadow Guardian scene, collision shape, spawn logic, network behavior, boss health and damage mechanics remain in place. The new hooded shadow-wraith art is attached **after the inherited boss initialization**, leaving the original animations as a fallback if the texture cannot be loaded. The 4×4 original transparent pixel-art sheet contains four frames each for idle, movement and attack, two frames for hurt and two frames for death.

The inventory's **Mochila [I]** button now displays a 48×48 original backpack icon through a 44×44 `TextureRect` child. The child ignores mouse input, so touch and mouse clicks remain handled by the button itself. The keyboard I shortcut is unchanged. If the image is unavailable, the text button remains.

## Design constraints preserved

- No changes to the stage's enemy-spawning logic or boss instantiation.
- No changes to boss collisions, health, combat damage, special wave, phase-two logic, or boss reward callbacks.
- No changes to inventory equipment, stats, save/load data, 12-slot capacity, or duplicate-item handling.
- Boss art uses `AnimatedSprite2D` with nearest-neighbor texture filtering, using the existing animation names expected by the inherited boss code: `default`, `correr` and `atacar`.
- The new custom art is a gameplay asset, not QA evidence.

## Manual QA checklist (English)

- [ ] Launch the updated project in Godot without parse errors or missing resources.
- [ ] Confirm the original inventory button remains visible, **with a backpack picture**, and the I key still opens/closes it.
- [ ] Reach the Shadow Guardian encounter in Arcade and verify that regular enemy progression does not stall.
- [ ] Confirm the boss now uses the purple hooded wraith sprites, including idle, movement and attack.
- [ ] Confirm that hit feedback, phase two, shadow-wave warning, collision and damage continue to work.
- [ ] Defeat the boss and verify the death animation, rewards and subsequent map progression.
- [ ] Test Boss Rush, save/load, a physical Android device and LAN multiplayer.

**QA status:** Code and asset paths were checked statically. In-engine execution is still pending contributor testing. Do not mark gameplay-specific checks as passed without runtime evidence.
