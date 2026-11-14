# Inventory and Equipment (Single-player Arcade)

This feature adds a 12-slot backpack, collectible loot, equippable weapons and armor, and save/load support to Freedom Knight. The combined pull request also includes the Shadow Guardian boss.

## How it works

1. Defeat enemies. Regular enemies have a **25% equipment drop chance**, with at most five loot items on the ground at once. Supported boss defeats also drop equipment, subject to the same limit.
2. Approach an equipment pickup and press **E** or use the existing **interact** action.
3. Open the backpack with **I** or the on-screen backpack button.
4. Select an item to equip or unequip it. One weapon and one armor piece can be equipped simultaneously.
5. Save the game from the pause menu. Inventory and equipped items are included in single-player save data; older saves remain loadable.

## Item catalog and custom sprites

| Item | Bonus | Asset |
| --- | --- | --- |
| Iron Sword | +2 attack | `res://SpritesDelJuego/Equipamiento/espada_hierro.png` |
| Shadow Sword | +4 attack | `res://SpritesDelJuego/Equipamiento/espada_sombras.png` |
| Leather Armor | +1 defense | `res://SpritesDelJuego/Equipamiento/armadura_cuero.png` |
| Steel Armor | +3 defense | `res://SpritesDelJuego/Equipamiento/armadura_acero.png` |

Four original **48 × 48 PNG sprites with transparent backgrounds** replace the old geometric placeholders and appear beside their item labels in the backpack. The shared `equipo_assets.gd` maps IDs to textures. Nearest-neighbor filtering retains sharp pixel edges. The artwork was generated for this contribution and resized into game-ready sprites.

**Asset policy:** The four PNG files are required gameplay resources and belong in the repository. QA screenshots remain in the PR conversation, not in the currently changed project files.

## Scope and limitations

- Equipment and loot currently work only in **single-player Arcade**. Multiplayer remains unchanged until authoritative equipment synchronization is implemented.
- Equipped items modify attack/defense statistics, but do not replace the knight character's animation sprites.
- Selling, combining, dropping, and trading equipment are outside this feature's scope.
- Duplicate item types are possible; only one item of each equipment category can be active.

## Manual QA checklist

- [ ] Open `freedom-knight/project.godot` in Godot and confirm the new textures import without errors.
- [ ] Start single-player Arcade and verify that all four ground item types have distinct pixel-art icons.
- [ ] Pick up ground loot using **E** or the touch interact button.
- [ ] Open the backpack and verify the four icons are rendered beside item names and bonuses.
- [ ] Equip and unequip a sword and armor; confirm attack/defense modifiers are applied correctly.
- [ ] Save and reload; verify items, equipped state, and icons persist.
- [ ] Verify the 12-slot inventory limit.
- [ ] Test the interface on a physical Android device and different resolutions.
- [ ] Confirm that multiplayer mode does not spawn inventory loot or show the backpack.

**QA status:** The previous inventory implementation was tested manually in Godot. The newly added artwork integration has not yet been tested in-engine.
