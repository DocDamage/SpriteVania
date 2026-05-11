# Implementation Ticket Slices

This document breaks the first milestone into file- and system-oriented slices.
Paths are expected targets and should be adjusted after inspecting the current
code structure.

## Ticket Rules

- Each ticket should compile or load after completion.
- Each ticket should include tests or a manual verification note.
- Do not mix unrelated systems in one ticket.
- Preserve existing behavior unless the ticket explicitly replaces it.
- Use current project conventions when actual files differ from expected paths.

## Slice 1: Baseline Audit Before Code

Expected files:

- Existing player scripts.
- Existing save scripts.
- Existing title/menu scripts.
- Existing room transition scripts.
- Existing tests.

Work:

- Inspect current architecture.
- Identify manager-like scripts.
- Identify current save file path.
- Identify current input action names.
- Identify current room scene conventions.

Output:

- Short implementation note or issue comment before changing code.

Verification:

- Current tests run or current failures are documented.

## Slice 2: Global Settings Foundation

Expected files:

- `scripts/save/` or current save/settings folder.
- `scripts/ui/settings_menu.gd` or current settings script.
- `tests/test_settings*.gd`.

Work:

- Add global settings load.
- Add global settings save.
- Add default settings.
- Clamp invalid values.
- Prevent settings from creating game save.

Verification:

- Settings persist without save file.
- Invalid settings clamp.

## Slice 3: Save Slot Metadata And Load Game

Expected files:

- Title screen script.
- Save manager script.
- New load game menu scene.
- Load game menu script.
- Save tests.

Work:

- Add save-slot metadata.
- Add slot scan.
- Add real Load Game screen.
- Add corrupt slot handling.
- Update Continue to use latest valid save.

Verification:

- Continue and Load Game are distinct.
- Corrupt save does not crash.

## Slice 4: Character Definitions

Expected files:

- New `scripts/characters/character_definition.gd`.
- New `resources/characters/`.
- Party or save scripts.
- Tests for definitions.

Work:

- Add character definition resource.
- Add Ronin, Arc-Gunner, Iron Knight definitions.
- Add Witch and Shadow definitions.
- Add starter-selectable flag.

Verification:

- Definitions load by ID.
- Witch and Shadow are not starter-selectable.

## Slice 5: Character Creation

Expected files:

- Character creation scene.
- Character creation script.
- Save manager.
- Title routing.
- Tests.

Work:

- Build starter select.
- Build name input.
- Build confirmation.
- Write initial save data.
- Route New Game to character creation.

Verification:

- Each starter can create a save.
- Name validation works.
- Continue loads created save.

## Slice 6: Movement Reliability

Expected files:

- Player controller script.
- Input map setup.
- Movement tests.
- Movement dev scene.

Work:

- Implement velocity dash.
- Add air dash.
- Add double jump.
- Add wall hang, slide, and wall jump.
- Add collision-safe dash.

Verification:

- Movement sandbox passes.
- Dash no longer teleports.

## Slice 7: Attack And Combo

Expected files:

- Player combat script.
- Attack data resource, if added.
- Enemy hurtbox script.
- Combat tests.

Work:

- Add hitbox creation.
- Add three-hit combo.
- Add hit feedback.
- Add attack tutorial prompt hook.
- Add slide attack.
- Add dive bomb and bounce.

Verification:

- Player attacks damage enemy.
- Dive bomb bounces from enemy.

## Slice 8: Enemy AI Foundation

Expected files:

- Enemy base script.
- Enemy state machine.
- Patrol path node script.
- Enemy tests.

Work:

- Add idle, patrol, alert, chase, attack, hurt, dead.
- Add path nodes.
- Add attack windup, active, recovery.
- Add leash.

Verification:

- Enemy patrols and attacks.
- Enemy damages player.

## Slice 9: Room Respawn And Bounds

Expected files:

- Room manager.
- Room scene base.
- Enemy spawn script.
- Room tests.

Work:

- Add room bounds.
- Add camera clamp.
- Add spawn markers.
- Add room-owned enemy spawns.
- Add room re-entry respawn policy.
- Fix first screen left edge.

Verification:

- Player cannot disappear.
- Enemies respawn on room re-entry.

## Slice 10: Familiar Combat And Progression

Expected files:

- Familiar scripts.
- Familiar projectile or hitbox.
- Familiar tests.
- Save manager.

Work:

- Stabilize follow.
- Add target selection.
- Add attack.
- Add XP and level.
- Add evolution.
- Save abilities and upgrades.

Verification:

- Familiar attacks and levels.
- Familiar state saves and loads.

## Slice 11: Witch Recruitment And Two-Character Swap

Expected files:

- Damaged Shrine scene.
- Party manager.
- Character runtime state.
- Party HUD.
- Recruitment tests.

Work:

- Add Witch recruitment trigger.
- Add Witch name prompt.
- Add active slot 2.
- Add swap input.
- Add Momentum ring.
- Add Ashen Hexburst placeholder.

Verification:

- Witch joins once.
- Player can swap with Witch.

## Slice 12: Shadow Recruitment And Three-Character Party

Expected files:

- Shadow Prison scene.
- Party manager.
- Party HUD.
- Recruitment tests.

Work:

- Add Shadow rescue trigger.
- Add Shadow name prompt.
- Add active slot 3.
- Add Silent Arrowfall placeholder.
- Add KO auto-switch.

Verification:

- Shadow joins once.
- Three-character swap works.
- KO auto-switch works.

## Slice 13: Milestone Rooms

Expected files:

- Room scenes from room layout spec.
- TileSet resources.
- Room transition data.
- Scene-instantiation tests.

Work:

- Build blockout rooms.
- Add exits and spawn markers.
- Add checkpoints.
- Add enemies and hazards.
- Add camera bounds.

Verification:

- New Game route reaches Sakuramori Court.

## Slice 14: Masakiro And Rising Torii Seal

Expected files:

- Masakiro boss scene.
- Boss script.
- Seal pickup script.
- Traversal gate helper.
- Boss tests.

Work:

- Add boss arena.
- Add phase behavior.
- Add defeat flag.
- Add seal pickup.
- Add vertical ascent unlock.
- Add ascent test.

Verification:

- Boss defeat unlocks seal and route forward.

## Slice 15: Sakuramori Court Services

Expected files:

- Hub scenes.
- Save shrine script.
- Party shrine script.
- Training dummy script.
- Hub tests.

Work:

- Add hub entrance.
- Add save shrine.
- Add party shrine placeholder.
- Add training yard.
- Add locked placeholders.

Verification:

- Save and continue from hub works.

## Slice 16: Asset Integration Pass

Expected files:

- Derived character resources.
- Derived enemy resources.
- TileSet resources.
- VFX resources.

Work:

- Import prototype playable sprites.
- Import enemy prototypes.
- Import boss prototype.
- Replace swamp trees.
- Add combat VFX.

Verification:

- Import-test scene passes.
- Visual review checklist passes for milestone rooms.

## Slice 17: Milestone Verification

Expected files:

- Tests.
- Known issues document or release notes.

Work:

- Run full headless suite.
- Run keyboard route.
- Run controller route.
- Run reduced-motion route.
- Save/continue from every checkpoint.
- Document known issues.

Verification:

- Production readiness checklist has no blockers.
