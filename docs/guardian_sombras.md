# Shadow Guardian — Custom Sprite Integration and QA

## Overview

The Shadow Guardian is a distinct hooded shadow mage, not a recolor of the existing armored floor boss. Its new original 4x4 pixel-art sprite sheet and the backpack icon are included as **gameplay assets**, not screenshots.

### Animation setup

- `guardian_sombras_sheet.png`: 768x768, 16 frames (192x192 each), transparent pixel art.
- **Idle:** first row, 4 frames, looping at 4 FPS.
- **Move:** second row, 4 frames, looping at 7 FPS.
- **Attack / shadow magic:** third row, 4 frames, once at 7 FPS.
- **Hurt:** first two frames of row four, once at 8 FPS.
- **Death:** final two frames of row four, once at 2 FPS, overlaid with the inherited fade and boss-defeat effects.
- `AnimatedSprite2D` builds the Godot `SpriteFrames` from `AtlasTexture` regions. Nearest filtering preserves the pixel-art appearance.
- The visual has a 1.25x in-scene scale, with a resized capsule collision shape (66-pixel radius, 176-pixel height), a raised name label and health bar, and the existing attack detection area.
- A separate original `icono_mochila.png` (48x48) appears in the inventory's touch button.

## Existing gameplay preserved

- Pursuit and melee attacks inherited from the floor boss.
- Second phase at 50% HP, with increased speed and attack frequency.
- Telegraph ring followed by the special shadow-wave attack (0.75 s warning; 230-unit damage radius).
- Arcade boss encounter, Boss Rush selection, host-authoritative multiplayer damage, death signal, explosion and normal progression.

## Manual QA checklist — pending in Godot

- [ ] Open `freedom-knight/project.godot` and confirm all new sprites import and the boss scene parses without errors.
- [ ] Spawn the boss and confirm its **new hooded spectral appearance**, distinct from the floor boss; verify sprite size, health bar and name placement.
- [ ] Confirm idle hover and movement animations, flip behavior and collision against the player and environment.
- [ ] Confirm attack animation, damage feedback and death animation, including loot/potions and progression after defeat.
- [ ] Lower the boss to 50% HP and confirm the phase-two color and combat behavior.
- [ ] Trigger the shadow-wave telegraph and verify attack timing, range and damage.
- [ ] Confirm the new backpack icon is visible and responds to tap and the I key.
- [ ] Verify Android readability and responsiveness at the game's real resolution.
- [ ] Regress Boss Rush and LAN multiplayer, including death and phase synchronization.

**QA status:** The sprites, code and scenes were integrated, but the updated boss has **not** yet been executed in Godot. No runtime success should be claimed until the contributor tests it.

## Source policy

The new boss sheet and the new backpack PNG are **required gameplay assets** that belong in the game's repository. Screenshots used to document testing should remain in PR comments, not in the game's source tree.
