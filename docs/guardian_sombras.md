# Shadow Guardian and Backpack UI — Visual Refinements

## Changes

- Removed the Shadow Guardian's persistent floating name label, matching other bosses. The temporary phase-two message is unchanged.
- Reversed only the Shadow Guardian's sprite-facing logic for the new custom animation sheet: moving right faces right; moving left faces left. The original floor boss and dragon retain their existing movement and visual logic.
- Removed the dark default button background from the backpack's on-screen control by using a flat button. The 44-pixel backpack image and the "Mochila [I]" label now appear next to each other in a single HBoxContainer with 4 pixels of separation. Both child controls ignore mouse input, preserving tap/click handling by the parent button and the I-key shortcut.
- Verified that the original armored floor boss script and sprite in the feature branch are identical to those in `main`. Its source artwork has naturally purple-colored armor; this is part of the original image, not a tint inherited from the new Shadow Guardian. No modifications were made to that independent boss.
- Existing spawning, collision, boss battle logic, equipment statistics, inventory state, save/load and enemy progression were left unchanged.

## QA checklist — manual run required

- [ ] Shadow Guardian appears without a floating boss-name label.
- [ ] During movement, the Guardian faces right when moving right and left when moving left. Validate while pursuing a player on each side.
- [ ] Backpack icon appears without a dark rectangular button backdrop; image and label sit close together.
- [ ] Backpack still opens/closes by button/touch and I key.
- [ ] Original armored floor boss keeps its `main` appearance; no new purple visual effect is applied to it.
- [ ] Shadow Guardian's phase two, shadow wave, death, and further enemy/map progression remain functional.
- [ ] Test in Boss Rush and Android after desktop regression.

**QA status:** This change has been code-reviewed and committed to the feature branch. The new visual refinements require Godot runtime confirmation and must not be marked as passed yet.
