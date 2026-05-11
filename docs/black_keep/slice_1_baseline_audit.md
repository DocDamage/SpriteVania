# Slice 1 Baseline Audit

Date: 2026-05-11
Branch: `temporary-full-assets`
Godot: `4.6.2.stable.official.71f334935`

## Scope

This note records the current implementation baseline before Black Keep feature
work. It supports Slice 1 from `docs/black_keep/implementation_ticket_slices.md`.

## Repository State

- Current branch is `temporary-full-assets`, tracking
  `origin/temporary-full-assets`.
- `docs/BLACK_KEEP_MASTER_PLAN.md` is tracked.
- Root `BLACK_KEEP_MASTER_PLAN.md` is currently untracked.
- `docs/Master plan.txt`, `patches/black_keep_import_test_files/`, several
  final-tower `.import` files, and several `.gd.uid` files are untracked.
- Existing tracked Godot `.import` and `.uid` files are part of the repository,
  but the new untracked generated files should be reviewed separately before
  staging.

## Test Baseline

Current command style:

```powershell
cmd /c "godot --headless --path . --script tests\test_save_manager.gd 2>&1"
```

Full local baseline:

```powershell
$tests = Get-ChildItem -LiteralPath tests -Filter 'test_*.gd' | Sort-Object Name
foreach ($test in $tests) {
  cmd /c "godot --headless --path . --script tests\$($test.Name) 2>&1"
}
```

Result: all 29 `tests/test_*.gd` scripts passed.

Passing coverage includes save manager, settings menu, title screen, main title
routing, room transitions, room respawn, map discovery, controller input map,
player combat, player respawn, hazards, enemy behavior, familiar behavior, and
scene instantiation.

## Current Architecture

Entry point:

- `project.godot` sets `application/run/main_scene` to `res://scenes/Main.tscn`.
- `scenes/Main.tscn` is driven by `scripts/ui/main.gd`.
- `SaveManager` is an autoload at `res://scripts/core/save_manager.gd`.

Save model:

- `scripts/core/save_manager.gd` owns persistence.
- Default save path is `user://spritevania_save.json`.
- Slot saves derive from the default path as
  `user://spritevania_save_slot_<slot_id>.json`.
- `scripts/core/game_state.gd` is the save payload model.
- Current saved fields include selected class/sprite, area, room, checkpoint,
  vitals, XP, traversal unlocks, defeated bosses, shortcuts, pickups, completed
  areas, discovered rooms, familiar state, and settings.
- Current settings persistence is embedded in `GameState.settings`, so settings
  changed before a game save exists do not persist yet.

Menus and settings:

- `scripts/ui/title_screen.gd` emits title actions and checks
  `SaveManager.has_save()` for Continue state.
- `scripts/ui/main.gd` routes New Game, Continue, Load Game, Settings,
  Accessibility, Extras, Credits, and Quit.
- `scripts/ui/main.gd` already has a basic Load Game panel with default,
  slot A, slot B, and slot C buttons.
- `scripts/ui/settings_menu.gd` owns runtime settings controls and input
  rebinding.
- Settings clamps already exist for volume, screen shake, text speed, and
  colorblind mode.
- Settings currently persist only when a game save already exists.

Player and input:

- `scripts/player/player.gd` owns movement, dash, jump, wall hang, attacks,
  class actions, damage, XP, and traversal unlock application.
- Class-specific behavior is delegated through
  `scripts/player/player_class_controller.gd` and the Warden, Gunslinger, and
  Hexbinder controller scripts.
- Current input actions in `project.godot` are `move_left`, `move_right`,
  `move_down`, `jump`, `attack`, `special_attack`, `class_action`, `interact`,
  `pause`, and `dash`.
- `scripts/ui/settings_menu.gd` treats all of those except `move_down` as
  rebindable.

Room and world conventions:

- `scripts/world/game_world.gd` owns world state, room loading, room exits,
  checkpoints, hazards, pickups, shortcuts, enemy registration, HUD, pause menu,
  and save writes from gameplay.
- Room IDs are centralized in `GameWorld.ROOM_SCENES` and `GameWorld.ROOM_AREAS`.
- Current default area and room are `swamp_outskirts` and `RoomStart`.
- Existing milestone-adjacent area IDs include `swamp_outskirts` and
  `castle_gate`.
- Room scenes use `scripts/world/room.gd` with exported `room_id`,
  `next_rooms`, and `enemy_spawn_ids`.
- Room exits are `Area2D` nodes with `metadata/next_room`.
- Gated exits use `metadata/required_traversal` or `metadata/requires_defeat`.
- Completion exits use IDs ending in `_complete`; `swamp_outskirts_complete`
  currently routes to `CastleGateStart`.
- Checkpoints use `scripts/world/checkpoint_shrine.gd` and emit
  `checkpoint_activated(checkpoint_id, checkpoint_position)`.
- Hazards are `Area2D` nodes with `metadata/hazard_type`, currently
  `swamp_water` and `spikes`.
- Shortcut gates use `metadata/shortcut_id` and optional `metadata/opens_from`.
- `PlayerStart` markers are used when available for room entry fallback.

## Safe Next Slice

Slice 2 can start with a focused global settings model because the baseline is
clean and the current settings coupling is clear:

- Add a settings persistence path separate from game saves, likely
  `user://black_keep_settings.json`.
- Keep existing menu clamps and runtime application behavior.
- Add tests proving settings persist without creating or requiring
  `user://spritevania_save.json`.
