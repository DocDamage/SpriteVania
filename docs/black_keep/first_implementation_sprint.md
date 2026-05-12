# First Implementation Sprint

This sprint is the recommended transition from planning to code. It focuses on
stabilizing the project and implementing the first systems that unlock the rest
of the milestone.

## Sprint Goal

Create a reliable foundation for Black Keep milestone implementation:

- Clean branch state.
- Known test baseline.
- Global settings file.
- Real Load Game entry point.
- Character definitions.
- Character creation route.
- First movement and attack reliability fixes.

## Sprint Non-Goals

- Full party system.
- Full Samurai Castle Wing.
- Final art.
- Final dialogue.
- World Break.
- Final dungeon.

## Sprint Entry Criteria

Before coding:

- Decide whether root `BLACK_KEEP_MASTER_PLAN.md` is tracked.
- Decide how to handle generated Godot `.import` and `.uid` files.
- Run current tests and record baseline.
- Inspect existing save, player, menu, room, and input scripts.
- Confirm current Godot command used for tests.

## Day 1: Repository And Baseline

Tasks:

- Review `git status`.
- Separate intended docs from generated/unrelated files.
- Run full existing test suite.
- Record known warnings and failures.
- Identify current save manager or equivalent.
- Identify current settings menu script.
- Identify current player controller script.
- Identify current room transition system.

Deliverable:

- Baseline implementation note.

Exit criteria:

- We know what is safe to edit first.

## Day 2: Global Settings Foundation

Tasks:

- Add global settings data model.
- Add load defaults.
- Add save to `user://black_keep_settings.json`.
- Add clamping for invalid values.
- Connect current settings menu to global settings where appropriate.
- Add tests for global settings save/load.

Deliverable:

- Settings can persist without game save.

Exit criteria:

- Changing a setting before New Game survives restart or reload.

## Day 3: Save Slot Metadata And Load Game

Tasks:

- Add save-slot metadata read.
- Add latest-valid-save resolver.
- Add corrupt-save safe failure.
- Add basic Load Game screen or menu state.
- Route Load Game to slot selection.
- Keep Continue as latest-save shortcut.

Deliverable:

- Continue and Load Game are separate.

Exit criteria:

- Empty, valid, and damaged slots have safe UI behavior.

## Day 4: Character Definitions

Tasks:

- Add character definition data structure.
- Add Ronin, Arc-Gunner, Iron Knight definitions.
- Add Witch and Shadow definitions as locked recruits.
- Add tests for starter-selectable filtering.

Deliverable:

- Starter data can be read by UI.

Exit criteria:

- Exactly three starter options are returned.

## Day 5: Character Creation UI

Tasks:

- Add starter select screen.
- Add name input.
- Add confirmation screen.
- Write initial save data on confirmation.
- Route New Game to character creation.

Deliverable:

- New Game creates a valid starter save.

Exit criteria:

- Ronin, Arc-Gunner, and Iron Knight can each start.
- Witch and Shadow are excluded.

## Day 6: Movement Reliability Fixes

Tasks:

- Replace teleport dash with velocity dash.
- Add dash trail placeholder.
- Add air dash.
- Add double jump.
- Add wall hang and wall jump if time allows.
- Add movement tests or dev-scene checks.

Deliverable:

- Dash and double jump feel testable.

Exit criteria:

- Dash does not tunnel through simple collision.
- Double jump count resets on landing.

## Day 7: Attack Reliability Fixes

Tasks:

- Add or repair attack hitbox.
- Add enemy hurtbox damage.
- Add first enemy hit feedback.
- Add attack prompt placeholder.
- Add basic combo if current attack is stable.

Deliverable:

- Player can clearly attack and damage monsters.

Exit criteria:

- First enemy can be damaged and killed.
- Enemy hit feedback is visible.

## Sprint Verification

Automated:

- Existing tests pass or known baseline failures remain unchanged.
- New global settings tests pass.
- Save slot metadata tests pass.
- Character definition tests pass.
- Character creation save tests pass.
- Movement tests pass for dash and double jump.
- Combat hitbox test passes.

Manual:

- Title screen opens.
- Settings save before New Game.
- Load Game opens slot UI.
- New Game opens character creation.
- Each starter can create a save.
- Continue loads created save.
- Dash visibly moves.
- Attack damages first enemy.

## Sprint Exit Criteria

Sprint is complete when:

- Planning docs no longer block implementation.
- Branch status is intentional.
- Settings and save foundations are safer.
- Character creation exists.
- Dash is not a teleport.
- Attack can damage enemies.
- The next sprint can focus on enemy AI, familiar, recruitment, and room build.

## Next Sprint Preview

Next sprint should target:

- Enemy AI patrol and attack.
- Room re-entry respawn.
- Familiar follow, attack, XP, and save state.
- Witch recruitment.
- Two-character swap.
- First room-boundary and camera fixes.
