# Implementation Epics

This document groups The Black Keep work into engineering epics. It is meant to
bridge planning documents into actual development sequencing.

## Epic Rules

- Each epic should produce playable or testable progress.
- Dependencies should be explicit.
- Docs can lead implementation, but code tasks should not wait for perfect lore.
- First milestone work has priority over full-game polish.
- Prototype art is acceptable when final-art risk is documented.

## Epic 1: Project State And Save Foundation

Purpose:

- Make save, continue, settings, and new-game state reliable before large party
  systems are added.

Primary docs:

- [Save and Load UX Spec](save_load_ux_spec.md)
- [Character Creation Spec](character_creation_spec.md)
- [Party System Technical Spec](party_system_technical_spec.md)

Tasks:

- Add global settings file.
- Split global and save-specific settings.
- Add save-slot metadata.
- Add real Load Game screen.
- Add save versioning and migration helpers.
- Add corrupted-save handling.
- Add current-room and checkpoint validation.

Acceptance:

- Continue loads the latest valid save.
- Load Game shows slot cards.
- Settings persist before any game save exists.
- Broken saves do not crash title flow.
- Save data has versioned party-ready fields.

Dependencies:

- Current title flow.
- Existing save/continue code.

## Epic 2: Character Creation And Starter Runtime

Purpose:

- Replace the starter choice with Black Keep character-definition IDs, names,
  and initial party state.

Primary docs:

- [Character Creation Spec](character_creation_spec.md)
- [Asset Integration Tasks](asset_integration_tasks.md)
- [Combat and Movement Spec](combat_movement_spec.md)

Tasks:

- Build starter-select screen.
- Add starter detail cards.
- Add name input and validation.
- Add confirmation screen.
- Create initial save data from selected starter.
- Create starter definitions for Ronin, Arc-Gunner, and Iron Knight.
- Add starter preview sprites after import-test assets are ready.

Acceptance:

- Ronin, Arc-Gunner, and Iron Knight can each start a save.
- Witch and Shadow are not selectable.
- Names save separately from titles.
- Continue loads the chosen starter.

Dependencies:

- Epic 1 save foundation.
- Prototype starter sprite imports.

## Epic 3: Movement And Combat Reliability

Purpose:

- Fix playtest-critical feel and readability before larger content work.

Primary docs:

- [Combat and Movement Spec](combat_movement_spec.md)
- [Milestone Verification Plan](milestone_verification_plan.md)

Tasks:

- Replace teleport-style dash with velocity dash.
- Add dash trail or afterimage.
- Add ground dash and air dash.
- Add double jump.
- Add wall hang, controlled wall fall, and wall jump.
- Add dash strike.
- Add dive bomb with enemy bounce.
- Add three-hit combo.
- Add clear attack prompt.
- Add hit sparks and enemy flash.
- Add controller bindings and glyph display.

Acceptance:

- Player can identify attack input.
- Player attacks damage enemies.
- Dash visibly travels over time.
- Double jump, dash, air dash, wall actions, dash strike, and dive bomb pass
  automated and manual checks.
- Keyboard and controller routes work.

Dependencies:

- Existing player controller.
- Input action map.

## Epic 4: Enemy AI And Room Reset

Purpose:

- Make enemies readable, attackable, dangerous, and predictable on room reset.

Primary docs:

- [Enemy AI Spec](enemy_ai_spec.md)
- [Milestone Room Graph](milestone_room_graph.md)

Tasks:

- Add enemy state machine.
- Add patrol path nodes.
- Add aggro, chase, attack, recovery, and leash behavior.
- Add enemy damage windows.
- Add player hitbox to enemy hurtbox damage.
- Add room-owned enemy spawn data.
- Add room re-entry respawn policy.
- Add stuck recovery.

Acceptance:

- Enemies patrol.
- Enemies chase and attack.
- Enemies damage the player.
- Player attacks kill enemies.
- Standard enemies respawn on room re-entry.

Dependencies:

- Combat hitbox work from Epic 3.
- Room graph and room IDs.

## Epic 5: Familiar Progression

Purpose:

- Keep the familiar as a real progression system, not decoration.

Primary docs:

- [First Milestone Build Tasks](first_milestone_build_tasks.md)
- [Milestone Verification Plan](milestone_verification_plan.md)

Tasks:

- Stabilize familiar follow behavior.
- Add familiar target selection.
- Add familiar attack behavior.
- Add familiar XP and leveling.
- Add familiar evolution.
- Add ability upgrades.
- Save familiar level, XP, evolution, and abilities.
- Add HUD feedback.

Acceptance:

- Familiar follows through room transitions.
- Familiar attacks enemies.
- Familiar levels and evolves.
- Familiar state survives save, continue, and respawn.

Dependencies:

- Enemy damage ownership.
- Save foundation.

## Epic 6: Party, Recruitment, And Tag Combat

Purpose:

- Deliver the milestone party target: starter, Witch, and Shadow.

Primary docs:

- [Party System Technical Spec](party_system_technical_spec.md)
- [Samurai Castle Wing Spec](samurai_castle_wing_spec.md)
- [Momentum Tuning](momentum_tuning.md)

Tasks:

- Add `CharacterDefinition` resources.
- Add `CharacterRuntimeState` serialization.
- Add active-party slots.
- Add Witch recruitment and naming.
- Add two-character swapping.
- Add Momentum rings.
- Add Ashen Hexburst tag attack.
- Add Shadow recruitment and naming.
- Add three-character swapping.
- Add Silent Arrowfall tag attack.
- Add KO auto-switch.

Acceptance:

- Witch joins once and saves.
- Shadow joins once and saves.
- Party swaps across available active slots.
- Tag attacks work on valid swap.
- KO auto-switch selects a living active character.

Dependencies:

- Character creation.
- Save foundation.
- Combat and HUD support.

## Epic 6A: Godot CharacterCreator2D Tooling

Purpose:

- Rebuild CharacterCreator2D as a Godot-native in-game creator and separate Character Studio app.

Primary docs:

- [CharacterCreator2D Port](../character_creator_2d_port.md)
- [Godot CharacterCreator2D Tool Roadmap](../character_creator_2d_godot_tool_roadmap.md)
- [Character Creation Spec](character_creation_spec.md)
- [Art Pipeline](art_pipeline.md)

Tasks:

- Define recipe, slot, part, palette, morph, export profile, and content-pack resources.
- Build layered rig preview from imported source parts.
- Expose complete base and aim animation inventory.
- Add checklist-driven bulk export for first-slice, movement, combat, all-base, all-aim, and custom sets.
- Add safe morph controls and validation.
- Bake transparent sheets and generate `SpriteFrames`, manifests, and contact sheets.
- Add recipe migration and missing-part fallback.
- Build separate Character Studio app shell.

Acceptance:

- Character creation can save a recipe and generated `SpriteFrames` path.
- Godot can create, preview, morph, bulk-export, and import a character without Unity.
- All imported CC2D base and aim animations remain selectable for export.
- Headless tests cover manifests, export profile, checklist sets, generated `SpriteFrames`, and runtime player assignment.

## Epic 7: First Milestone Room Build

Purpose:

- Build the complete route from opening to Sakuramori Court.

Primary docs:

- [Milestone Room Graph](milestone_room_graph.md)
- [First Milestone Build Tasks](first_milestone_build_tasks.md)
- [Asset Integration Tasks](asset_integration_tasks.md)

Tasks:

- Build Modern City Outskirts route.
- Build Rural Swamp Road.
- Fix and finish Swamp route visuals and bounds.
- Expand Castle Gate.
- Build Damaged Shrine.
- Build Tag Tutorial.
- Build Samurai Castle Wing.
- Build Masakiro arena.
- Build Rising Torii Seal room.
- Build Sakuramori Court shell.

Acceptance:

- A fresh New Game reaches Sakuramori Court.
- No room transition softlocks.
- No void or disappearing player at room edges.
- Checkpoints and saves work across the route.

Dependencies:

- Movement and combat reliability.
- Enemy AI.
- Asset integration.

## Epic 8: Asset Integration And Visual Completion

Purpose:

- Move from placeholder visuals toward coherent prototype art.

Primary docs:

- [Art Pipeline](art_pipeline.md)
- [Asset Classification](asset_classification.md)
- [Asset Integration Tasks](asset_integration_tasks.md)

Tasks:

- Import Ronin prototype.
- Import Arc-Gunner prototype.
- Import Iron Knight prototype.
- Import Witch prototype.
- Select or prototype Shadow.
- Import standard enemy.
- Import cursed samurai.
- Import oni brute.
- Import Masakiro.
- Build first-pass tile sets for milestone zones.
- Replace unfinished swamp trees.
- Add core combat VFX.

Acceptance:

- Prototype assets are usable in movement and combat.
- Source paths and cleanup needs are documented.
- Milestone rooms look complete enough for meaningful playtests.

Dependencies:

- Asset audit.
- ImageMagick/contact sheets.
- Godot import validation.

## Epic 9: Hub Services And Training

Purpose:

- Make Sakuramori Court useful after the first dungeon.

Primary docs:

- [Sakuramori Court Spec](sakuramori_court_spec.md)
- [Save and Load UX Spec](save_load_ux_spec.md)

Tasks:

- Add save shrine.
- Add healing behavior.
- Add party shrine placeholder.
- Add training dummy.
- Add traversal practice area.
- Add locked placeholders for shop, blacksmith, archive, and Moonpetal Passage.

Acceptance:

- Player can save and continue in Sakuramori Court.
- Player can practice swaps, attacks, and vertical ascent.
- Placeholder services do not trap or corrupt state.

Dependencies:

- Party system.
- Room build.

## Epic 10: World Expansion Foundation

Purpose:

- Prepare the project for full-game expansion after the first milestone.

Primary docs:

- [Traversal Seals](traversal_seals.md)
- [Zone Manifest](zone_manifest.md)
- [World Break State Plan](world_break_state_plan.md)
- [Final Dungeon Spec](final_dungeon_spec.md)

Tasks:

- Add traversal-gate helper.
- Add zone-state data.
- Add World Break state fields.
- Add seal unlock data.
- Add title-screen variant resolver.
- Add route fallback rules for obsolete room IDs.

Acceptance:

- New zones can declare seal gates.
- World state can be saved and loaded.
- Title can respond to latest save state.
- Future zone work has stable IDs and gates.

Dependencies:

- Save foundation.
- First milestone route IDs.
