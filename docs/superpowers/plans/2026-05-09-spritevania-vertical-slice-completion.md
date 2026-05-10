# SpriteVania Vertical Slice Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the current SpriteVania prototype into a complete first Swamp Outskirts vertical slice with class-specific traversal/attack identity, a readable metroidvania loop, stronger enemies/miniboss, menu polish, and verification.

**Architecture:** Keep the project Godot-native: scene changes in `scenes/`, behavior in focused `scripts/`, data in `data/classes/*.tres`, and regression coverage in `tests/`. Work in the `vertical-slice-completion` branch/worktree and keep agents on disjoint file ownership where possible.

**Tech Stack:** Godot 4.6.2, GDScript, `.tscn` scenes, `.tres` resources, headless Godot script tests.

---

## Execution Model

Use agents for independent work streams, then integrate in this controller session. Do not edit `main` directly.

- **Agent A: Asset Pipeline and Room Presentation**
  - Owns: `resources/animations/*`, `resources/tilesets/*`, `scenes/world/swamp_outskirts/*.tscn`, `tests/test_asset_integration.gd`
  - Goal: make referenced SpriteVania art self-contained enough for tests/export, remove missing-resource warnings, and improve visual layout without changing gameplay APIs.

- **Agent B: Class Mechanics and Progression**
  - Owns: `scripts/player/*`, `scripts/data/class_data.gd`, `data/classes/*.tres`, `scripts/world/upgrade_pickup.gd`, focused tests for combat/progression.
  - Goal: each class has a distinct traversal identity and learned attack skill, with resource costs/cooldowns and saved unlock state.

- **Agent C: Enemy and Miniboss Behavior**
  - Owns: `scripts/enemies/*`, `scenes/enemies/*.tscn`, enemy placements in rooms, `tests/test_enemy_behavior.gd`, `tests/test_player_combat.gd`.
  - Goal: normal enemies have aggro/attack/drops, and the miniboss has telegraphed patterns plus persistent defeat behavior.

- **Agent D: Map UX, Menus, and Save Polish**
  - Owns: `scripts/world/game_world.gd`, `scripts/core/game_state.gd`, `scripts/core/save_manager.gd`, `scripts/ui/*`, `scenes/ui/*`, `scenes/world/GameWorld.tscn`, HUD/minimap/pause tests.
  - Goal: minimap/discovery, room labels, pause menu, save slots or slot-ready save structure, and input/settings polish.

- **Controller: Integration and QA**
  - Owns: plan tracking, conflict resolution, full test suite, export preset, `docs/implementation_roadmap.md`.
  - Goal: merge agent work, keep APIs coherent, run full regression, and document what is complete.

---

## Shared Constraints

- Use existing patterns before adding new abstractions.
- Normal enemies respawn on room re-entry; bosses, shortcuts, checkpoints, area completion, and one-time pickups persist.
- All classes must complete the same Swamp Outskirts critical path.
- Use ASCII in new code and docs.
- Do not delete or revert user-local loose assets. If assets must be committed, copy only the files referenced by committed resources/scenes into tracked paths.
- Each agent should run focused tests and report exact commands/results.

---

## Task 1: Stabilize Asset References and Swamp Room Presentation

**Agent:** Agent A

**Files:**
- Modify: `resources/animations/player_swamp_frames.tres`
- Modify: `resources/animations/swamp_fire_frames.tres`
- Modify: `resources/animations/swamp_spider_frames.tres`
- Modify: `resources/animations/swamp_thing_frames.tres`
- Modify: `resources/tilesets/swamp_tileset.tres`
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
- `godot --headless --path . --script tests/test_asset_integration.gd` exits successfully.
- Referenced textures/sprite frames load without missing-resource parse errors for committed scene/resource files.
- Every Swamp room still has `PlayerStart` or matching entrances, `SwampTileLayer`, `EnemySpawns`, `Pickups`, and connected `Entrances`.
- Existing room transition tests continue passing.

**Steps:**
- [ ] Run `godot --headless --path . --script tests/test_asset_integration.gd` and capture current missing resource paths.
- [ ] Inspect `SpriteVania Assets/tile sets/Gothicvania Swamp files/` and identify the smallest set of texture files actually referenced by committed resources.
- [ ] Either fix resource paths to existing committed assets or stage the referenced assets intentionally; do not stage the whole loose asset dump.
- [ ] Improve room silhouettes with existing tile/decor nodes while preserving node names used by tests.
- [ ] Add or update test assertions that each Swamp room instantiates, has the required containers, and has no null `SwampTileLayer.tile_set`.
- [ ] Run `godot --headless --path . --script tests/test_asset_integration.gd`.
- [ ] Run `godot --headless --path . --script tests/test_room_transitions.gd`.
- [ ] Commit with `git commit -m "Stabilize swamp assets and room presentation"`.

---

## Task 2: Implement Class-Specific Traversal and Attack Skills

**Agent:** Agent B

**Files:**
- Modify: `scripts/player/player.gd`
- Modify: `scripts/player/warden_controller.gd`
- Modify: `scripts/player/gunslinger_controller.gd`
- Modify: `scripts/player/hexbinder_controller.gd`
- Modify: `scripts/player/player_projectile.gd`
- Modify: `scripts/data/class_data.gd`
- Modify: `data/classes/warden.tres`
- Modify: `data/classes/gunslinger.tres`
- Modify: `data/classes/hexbinder.tres`
- Modify: `scripts/world/upgrade_pickup.gd`
- Modify: `scripts/world/game_world.gd` only if needed for unlock routing
- Modify/Create: `tests/test_class_abilities.gd`
- Modify: `tests/test_player_combat.gd`
- Modify: `tests/test_attack_skill_pickup.gd`
- Modify: `tests/test_traversal_unlocks.gd`

**Acceptance:**
- Warden has armored dash plus guard counter/ground-slam style attack skill.
- Gunslinger has hookshot/recoil/slide traversal plus piercing/ricochet style attack skill.
- Hexbinder has blink/float/phase traversal plus binding/curse style attack skill.
- Skills consume resource or respect cooldown; unavailable skills do not fire before unlock.
- Learned traversal and attack skills survive save/load.

**Steps:**
- [ ] Write failing tests in `tests/test_class_abilities.gd` for locked vs unlocked class traversal/action behavior.
- [ ] Write failing tests for resource/cooldown behavior on each class special attack.
- [ ] Extend class data resources with first traversal unlock id and first attack skill id per class.
- [ ] Implement `Player` helpers for `consume_resource`, `can_use_skill`, cooldown tracking, and stat emission after skill use.
- [ ] Implement Warden, Gunslinger, and Hexbinder controllers using those helpers.
- [ ] Ensure `GameWorld._on_upgrade_collected()` resolves generic pickup ids to class-specific ids for both traversal and attack skills.
- [ ] Run `godot --headless --path . --script tests/test_class_abilities.gd`.
- [ ] Run `godot --headless --path . --script tests/test_player_combat.gd`.
- [ ] Run `godot --headless --path . --script tests/test_attack_skill_pickup.gd`.
- [ ] Run `godot --headless --path . --script tests/test_traversal_unlocks.gd`.
- [ ] Commit with `git commit -m "Add class-specific traversal and attack skills"`.

---

## Task 3: Add Enemy Aggro, Attacks, Drops, and Miniboss Patterns

**Agent:** Agent C

**Files:**
- Modify: `scripts/enemies/enemy.gd`
- Modify: `scripts/enemies/swamp_crawler.gd`
- Modify: `scripts/enemies/swamp_miniboss.gd`
- Modify: `scenes/enemies/SwampCrawler.tscn`
- Modify: `scenes/enemies/SwampMiniBoss.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomEnemy.tscn`
- Modify: `scenes/world/swamp_outskirts/RoomMiniBoss.tscn`
- Modify: `tests/test_enemy_behavior.gd`
- Modify: `tests/test_enemy_contact_damage.gd`
- Modify: `tests/test_player_combat.gd`
- Modify: `tests/test_area_completion.gd`

**Acceptance:**
- Crawler patrols, detects nearby player, performs an explicit attack window, then returns to patrol.
- Enemy death can grant XP and optional resource/health drop signal without breaking current XP path.
- Miniboss has at least two telegraphed phases/patterns and can be defeated by all class damage types.
- Miniboss defeat persists and unlocks the completion exit.

**Steps:**
- [ ] Add tests for crawler aggro range, attack cooldown, and return-to-patrol behavior.
- [ ] Add tests for miniboss pattern state transitions and defeated persistence gate.
- [ ] Extend `Enemy` with `attack_damage`, `aggro_range`, `attack_range`, `attack_cooldown`, and optional `drop_resource_amount`.
- [ ] Implement crawler state machine with `patrol`, `chase`, and `attack`.
- [ ] Implement miniboss telegraph/leap/summon-or-slam pattern cycling without relying on random-only behavior in tests.
- [ ] Keep existing `died(enemy_id, xp_reward)` signal compatible.
- [ ] Run `godot --headless --path . --script tests/test_enemy_behavior.gd`.
- [ ] Run `godot --headless --path . --script tests/test_enemy_contact_damage.gd`.
- [ ] Run `godot --headless --path . --script tests/test_area_completion.gd`.
- [ ] Commit with `git commit -m "Deepen swamp enemy and miniboss behavior"`.

---

## Task 4: Complete Map Loop, Minimap, Discovery, and Route Readability

**Agent:** Agent D first pass, with Agent A support only if scene art conflicts arise.

**Files:**
- Modify: `scripts/world/game_world.gd`
- Modify: `scripts/core/game_state.gd`
- Modify: `scripts/ui/hud.gd`
- Modify: `scenes/ui/HUD.tscn`
- Modify: `scenes/world/swamp_outskirts/*.tscn`
- Create: `scripts/world/map_registry.gd`
- Create: `tests/test_map_discovery.gd`
- Modify: `tests/test_save_manager.gd`
- Modify: `tests/test_shortcuts.gd`
- Modify: `tests/test_boss_gated_exits.gd`

**Acceptance:**
- HUD shows current room/area and discovered Swamp rooms.
- Entering a room marks it discovered and persists it in save data.
- Locked traversal gates expose which unlock is required through metadata and remain shared-completable by all classes.
- The playable room chain contains: start, movement, enemy, hazard, checkpoint, upgrade, return shortcut, miniboss, completion.

**Steps:**
- [ ] Add `discovered_rooms: Array[String]` to `GameState.to_dictionary()` and `from_dictionary()`.
- [ ] Create `scripts/world/map_registry.gd` with a static dictionary for Swamp room labels and adjacency.
- [ ] Update `GameWorld.load_room()` to mark rooms discovered and emit/update HUD.
- [ ] Add HUD labels/list for current room and discovered count or compact map text.
- [ ] Add tests for discovery persistence through save/load.
- [ ] Add tests that class-specific traversal unlocks can satisfy the shared shortcut/miniboss route.
- [ ] Run `godot --headless --path . --script tests/test_map_discovery.gd`.
- [ ] Run `godot --headless --path . --script tests/test_save_manager.gd`.
- [ ] Run `godot --headless --path . --script tests/test_shortcuts.gd`.
- [ ] Commit with `git commit -m "Add map discovery and route readability"`.

---

## Task 5: Add Pause Menu, Save Slot Structure, and Input Rebinding Surface

**Agent:** Agent D second pass.

**Files:**
- Create: `scenes/ui/PauseMenu.tscn`
- Create: `scripts/ui/pause_menu.gd`
- Modify: `scripts/ui/main.gd`
- Modify: `scripts/world/game_world.gd`
- Modify: `scripts/core/save_manager.gd`
- Modify: `scripts/core/game_state.gd`
- Modify: `scripts/ui/settings_menu.gd`
- Modify: `scenes/ui/SettingsMenu.tscn`
- Create: `tests/test_pause_menu.gd`
- Modify: `tests/test_settings_menu.gd`
- Modify: `tests/test_save_manager.gd`

**Acceptance:**
- Pressing `pause` in gameplay opens a pause menu with Resume, Settings, Save, and Quit to Title.
- Save manager supports a default slot through a slot-aware API while preserving existing Continue behavior.
- Settings menu shows current controls and supports rebinding at least one action in tests without breaking existing defaults.

**Steps:**
- [ ] Add tests for `SaveManager.save_game_to_slot("slot_1", state)` and `load_game_from_slot("slot_1")`, while `save_game()` still uses the default slot.
- [ ] Add `PauseMenu` scene and script signals: `resume_requested`, `settings_requested`, `save_requested`, `quit_requested`.
- [ ] Update `GameWorld._process()` or `_unhandled_input()` to open/close pause on `pause`.
- [ ] Wire pause save to `_store_player_state()` plus `_save_game_state()`.
- [ ] Add settings UI data methods for input action labels and rebinding one action.
- [ ] Run `godot --headless --path . --script tests/test_pause_menu.gd`.
- [ ] Run `godot --headless --path . --script tests/test_settings_menu.gd`.
- [ ] Run `godot --headless --path . --script tests/test_save_manager.gd`.
- [ ] Commit with `git commit -m "Add pause menu and slot-ready saving"`.

---

## Task 6: QA Hardening, Export Preset, and Documentation Update

**Agent:** Controller, with final review agent.

**Files:**
- Create/Modify: `export_presets.cfg`
- Create: `tests/test_scene_instantiation.gd`
- Modify: `docs/implementation_roadmap.md`
- Modify: `docs/superpowers/specs/2026-05-09-spritevania-vertical-slice-design.md` only if scope changed.

**Acceptance:**
- All committed scenes instantiate headlessly without fatal errors.
- Existing non-fatal Godot cleanup warnings are documented or resolved if caused by project scripts.
- Full focused test suite passes.
- Export preset exists for the target desktop platform.
- Roadmap clearly states what is complete and the next post-slice priorities.

**Steps:**
- [ ] Add `tests/test_scene_instantiation.gd` that loads all committed `scenes/**/*.tscn`, instantiates, enters/exits tree if needed, and frees cleanly.
- [ ] Run every `tests/test_*.gd` script with `godot --headless --path . --script`.
- [ ] Run `godot --headless --path . --quit` to catch project load errors.
- [ ] Run `git diff --check -- scripts scenes tests data resources docs project.godot export_presets.cfg`.
- [ ] Add a Windows Desktop export preset if missing.
- [ ] Update `docs/implementation_roadmap.md` with completed vertical-slice items and remaining full-game work.
- [ ] Commit with `git commit -m "Harden vertical slice verification and export setup"`.

---

## Final Integration

- [ ] Rebase or merge agent commits on `vertical-slice-completion` in a clean order.
- [ ] Resolve conflicts by preserving gameplay APIs and test expectations.
- [ ] Run full test loop:

```powershell
$tests = Get-ChildItem tests -Filter 'test_*.gd' | Sort-Object Name
foreach ($t in $tests) {
  & godot --headless --path . --script $t.FullName
  if (-not $?) { throw "Failed $($t.Name)" }
}
godot --headless --path . --quit
```

- [ ] Run `git status --short --branch`.
- [ ] Push `vertical-slice-completion`.
- [ ] Merge to `main` only after final verification passes or after explicitly reporting remaining blockers.

