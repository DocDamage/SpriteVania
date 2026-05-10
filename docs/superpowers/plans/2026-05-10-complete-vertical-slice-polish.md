# Complete Vertical Slice Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finish the current Swamp Outskirts vertical slice so it plays and presents like a coherent prototype rather than a systems testbed.

**Architecture:** Keep the current Godot-native structure: scenes own layout and presentation, scripts own behavior, resources own data. Changes are split into disjoint work streams so subagents can work without overlapping file ownership. Behavior changes use failing Godot script tests first.

**Tech Stack:** Godot 4.6.2, GDScript, `.tscn` scenes, `.tres` resources, headless Godot script tests, Git.

---

## Definition of Done

- Swamp rooms use committed visual assets or intentional in-repo generated art instead of obvious placeholder textures for main ground, gates, pickups, familiar bolt, checkpoint, and familiar.
- Swamp room layouts are readable: each room has a clear route, landing surfaces, enemy spacing, exit affordances, and no invisible blockers on the critical path.
- Miniboss slam has an actual damage/knockback effect with a tested one-hit-per-window rule.
- Player skills have a sustainable resource recovery loop from enemy kills.
- Pause/menu map UX gives a useful map screen, not only compact HUD discovery text.
- Save data remains compatible and records any new persistent state.
- Full Godot script suite, headless project load, and diff hygiene checks pass.

## Work Streams

### Task 1: Asset and Room Presentation

**Owner:** Asset/room worker

**Files:**
- Modify: `scenes/world/UpgradePickup.tscn`
- Modify: `scenes/world/CheckpointShrine.tscn`
- Modify: `scenes/player/PlayerFamiliar.tscn`
- Modify: `scenes/player/FamiliarBolt.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomStart.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomMovement.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomEnemy.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomHazard.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomCheckpoint.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomUpgrade.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomShortcut.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomMiniBoss.tscn`
- Modify: `tests/test_asset_integration.gd`

**Acceptance:**
- `rg -n "PlaceholderTexture2D" scenes/world scenes/player` has no hits in the scenes listed above unless the placeholder is intentionally renamed to a committed art-like generated texture/resource.
- Critical path exits stay reachable and named metadata used by tests is preserved.
- `tests/test_asset_integration.gd`, `tests/test_room_transitions.gd`, and `tests/test_scene_instantiation.gd` pass cleanly.

**Steps:**
- [ ] Inspect current Swamp room scenes and list all placeholder subresources.
- [ ] Replace obvious placeholder subresources with committed texture resources or richer ColorRect/Sprite2D compositions that read as swamp ground, gates, hazards, shrine, pickup, familiar, and bolt.
- [ ] Adjust room props/platform visuals without changing collision nodes required by tests.
- [ ] Add test assertions that the listed scenes no longer contain `PlaceholderTexture2D`.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_asset_integration.gd 2>&1"`.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_room_transitions.gd 2>&1"`.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_scene_instantiation.gd 2>&1"`.
- [ ] Commit with `git commit -m "Polish swamp room presentation"`.

### Task 2: Miniboss Slam Combat Effect

**Owner:** Enemy/combat worker

**Files:**
- Modify: `scripts/enemies/swamp_miniboss.gd`
- Modify: `tests/test_enemy_behavior.gd`

**Acceptance:**
- Slam applies damage to a player in range during the active slam window.
- Slam applies knockback from the miniboss position when the target supports `apply_knockback`.
- Each target is damaged at most once per slam window.
- Existing leap/pattern tests still pass.

**Steps:**
- [ ] Add a failing test in `tests/test_enemy_behavior.gd` that enters the slam state with a damage probe in range and expects damage plus knockback.
- [ ] Add a failing assertion that the same probe is not damaged twice during the same active slam window.
- [ ] Implement slam hit tracking and range checks in `scripts/enemies/swamp_miniboss.gd`.
- [ ] Reset slam hit tracking when a new slam starts.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_enemy_behavior.gd 2>&1"` and confirm no `SCRIPT ERROR`, `Parse Error`, or `ERROR:`.
- [ ] Commit with `git commit -m "Give miniboss slam a combat effect"`.

### Task 3: Resource Recovery Loop

**Owner:** Progression/resource worker

**Files:**
- Modify: `scripts/player/player.gd`
- Modify: `scripts/world/game_world.gd`
- Modify: `scripts/enemies/enemy.gd`
- Modify: `tests/test_player_combat.gd`
- Modify: `tests/test_familiar_world_persistence.gd` only if world kill handling needs coverage there.

**Acceptance:**
- Enemy kills restore a small amount of player resource without exceeding max resource.
- Existing XP and familiar XP gain still happen from the same enemy death path.
- Resource restoration emits `stats_changed` so HUD updates.

**Steps:**
- [ ] Add a failing test in `tests/test_player_combat.gd` or `tests/test_familiar_world_persistence.gd` that lowers player resource, calls world enemy death handling, and expects resource to increase.
- [ ] Add a failing cap assertion that resource cannot exceed `_max_resource()`.
- [ ] Add `restore_resource(amount: int)` to `scripts/player/player.gd`.
- [ ] Call `restore_resource` from `scripts/world/game_world.gd::_on_enemy_died`.
- [ ] Keep `Enemy.died(enemy_id, xp_reward)` compatible; use a fixed small restore amount in world code unless a drop-specific amount already exists.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_player_combat.gd 2>&1"`.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_hud.gd 2>&1"`.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_familiar_world_persistence.gd 2>&1"`.
- [ ] Commit with `git commit -m "Restore resource from enemy defeats"`.

### Task 4: Pause Map UX

**Owner:** UI/map worker

**Files:**
- Modify: `scripts/ui/pause_menu.gd`
- Modify: `scenes/ui/PauseMenu.tscn`
- Modify: `scripts/world/game_world.gd`
- Modify: `tests/test_pause_menu.gd`
- Modify: `tests/test_map_discovery.gd`

**Acceptance:**
- Pause menu exposes a map view/list containing current room, discovered rooms, and area completion status.
- Game world updates pause menu map data when rooms are loaded and when area completion changes.
- Existing pause save, familiar upgrade, settings, and quit signals continue working.

**Steps:**
- [ ] Add a failing test in `tests/test_pause_menu.gd` that calls a new `set_map_status(status: Dictionary)` API and expects visible current/discovered/completion labels.
- [ ] Add or extend `tests/test_map_discovery.gd` to assert game world pushes map data into the pause menu.
- [ ] Implement `PauseMenu.set_map_status(status: Dictionary)`.
- [ ] Add map labels/list nodes to `scenes/ui/PauseMenu.tscn`.
- [ ] Add `GameWorld._update_pause_menu_map_status()` and call it after room load, pause menu creation, and area completion.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_pause_menu.gd 2>&1"`.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_map_discovery.gd 2>&1"`.
- [ ] Commit with `git commit -m "Add pause menu map view"`.

### Task 5: Save Compatibility and Roadmap Update

**Owner:** Save/docs worker

**Files:**
- Modify: `scripts/core/game_state.gd`
- Modify: `scripts/core/save_manager.gd`
- Modify: `tests/test_save_manager.gd`
- Modify: `docs/implementation_roadmap.md`

**Acceptance:**
- Save data has a `version` field.
- Loading older saves without `version` still works.
- Roadmap states the vertical slice status after Tasks 1-4 and separates full-game roadmap items from current prototype gaps.

**Steps:**
- [ ] Add a failing save-manager test proving `to_dictionary()` includes `version`.
- [ ] Add a failing save-manager test proving `from_dictionary()` handles a dictionary without `version`.
- [ ] Implement `GameState.SAVE_VERSION` and serialize it.
- [ ] Preserve existing fields and load behavior.
- [ ] Update `docs/implementation_roadmap.md` with the new completed items and remaining full-game priorities.
- [ ] Run `cmd /c "godot --headless --path . --script tests\test_save_manager.gd 2>&1"`.
- [ ] Commit with `git commit -m "Version save data and update roadmap"`.

### Task 6: Integration QA

**Owner:** Controller

**Files:**
- Modify only if tests expose defects.

**Acceptance:**
- Every `tests/test_*.gd` script passes.
- `cmd /c "godot --headless --path . --quit 2>&1"` passes without `SCRIPT ERROR`, `Parse Error`, or project load errors.
- `git diff --check -- scripts scenes tests data resources docs project.godot export_presets.cfg` passes.
- Branch merges to `main` and pushes.

**Steps:**
- [ ] Run the full test loop over all `tests/test_*.gd`.
- [ ] Fix any failures with targeted tests first.
- [ ] Run headless project load.
- [ ] Run diff check.
- [ ] Inspect `git status --short`.
- [ ] Merge `complete-vertical-slice-polish` to `main`.
- [ ] Push `main`.
