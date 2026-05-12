# The Black Keep Documentation

This folder splits the Black Keep master plan into focused planning documents.
The single-source overview remains
[BLACK_KEEP_MASTER_PLAN.md](../BLACK_KEEP_MASTER_PLAN.md).

The current implementation foundation is still the SpriteVania vertical slice.
The target game direction is now The Black Keep: a real-time action RPG and
Metroidvania about a demonic castle rooted near modern outskirts and a rural
swamp road, with portals into pocket dimensions from different times and places.

## Focused Documents

- [First Milestone](first_milestone.md):
  first playable milestone, active party target, early route, and proof points.
- [Party and Combat](party_and_combat.md):
  roster, active party, Momentum, tag swaps, combo timing, and quests.
- [Menu and Settings Plan](menu_settings_plan.md):
  title screen, menu routing, settings, persistence, and accessibility.
- [Art Pipeline](art_pipeline.md):
  palette rules, sprite requirements, normalization, parallax, and priorities.
- [CharacterCreator2D Port](../character_creator_2d_port.md):
  Godot-native source import, animation profile, bulk export, and runtime handoff.
- [Godot CharacterCreator2D Tool Roadmap](../character_creator_2d_godot_tool_roadmap.md):
  in-game creator, separate Character Studio app, recipes, rig, morphing, and baker roadmap.
- [Asset Classification](asset_classification.md):
  sorting criteria for playable, NPC, enemy, boss, terrain, UI, and VFX.
- [Story Outline](story_outline.md):
  premise, early zones, hubs, seals, Masakiro, World Break, and final dungeon.

## Production Planning Specs

- [Planning Backlog](planning_backlog.md):
  ordered planning tasks and dependencies.
- [Implementation Epics](implementation_epics.md):
  engineering epics, dependencies, acceptance criteria, and delivery order.
- [Technical Architecture Plan](technical_architecture_plan.md):
  resource, manager, save, room, combat, input, and testing architecture.
- [Milestone Task Board](milestone_task_board.md):
  ticket-shaped task sequence for the first playable milestone.
- [Test Strategy](test_strategy.md):
  headless tests, dev scenes, manual playtests, and warning policy.
- [Risk Register](risk_register.md):
  production risks, impact, mitigations, and review cadence.
- [Production Readiness Checklist](production_readiness_checklist.md):
  go/no-go checklist for milestone review and merge readiness.
- [Asset Audit Results](asset_audit_results.md):
  asset classification and playable candidate audit template.
- [Asset Decision Log](asset_decision_log.md):
  prototype approvals, final-art risks, deferred assets, and next actions.
- [Playable Import Test Plan](playable_import_test_plan.md):
  import-test order, slicing assumptions, acceptance criteria, and risks.
- [Playable Import Test Results](playable_import_test_results.md):
  dev-scene findings for imported playable candidates.
- [First Milestone Production Spec](first_milestone_production_spec.md):
  room-by-room build scope for the first Black Keep milestone.
- [First Milestone Build Tasks](first_milestone_build_tasks.md):
  implementation tasks, acceptance criteria, and milestone test plan.
- [Milestone Room Graph](milestone_room_graph.md):
  room IDs, exits, checkpoints, story flags, and transition test matrix.
- [First Milestone Room Layouts](first_milestone_room_layouts.md):
  room dimensions, markers, layout intent, and acceptance checks.
- [Asset Integration Tasks](asset_integration_tasks.md):
  prototype asset imports, slicing work, VFX, UI, terrain, enemies, and boss art.
- [Milestone Verification Plan](milestone_verification_plan.md):
  automated tests, manual playtests, controller checks, and visual review.
- [UI Wireframes](ui_wireframes.md):
  functional layouts for title, save slots, character creation, settings, HUD,
  shrine screens, Extras, and Credits.
- [Balance Tuning Plan](balance_tuning_plan.md):
  first-pass movement, combat, XP, enemy, boss, familiar, economy, and
  difficulty values.
- [Audio Plan](audio_plan.md):
  required music, ambience, UI SFX, player SFX, combat SFX, and zone direction.
- [Credits and License Audit](credits_license_audit.md):
  source, license, credit, commercial-use, and release-readiness tracking.
- [Implementation Ticket Slices](implementation_ticket_slices.md):
  file- and system-oriented implementation tickets for the first milestone.
- [First Implementation Sprint](first_implementation_sprint.md):
  seven-day transition plan from docs into the first code and scene work.
- [Enemy Roster Plan](enemy_roster_plan.md):
  milestone enemy roles, behavior purpose, placement rules, and tests.
- [Dialogue and Tutorial Prompt Spec](dialogue_and_tutorial_prompt_spec.md):
  placeholder text rules, prompt placement, dialogue flags, and accessibility.
- [Quest and Progression Spec](quest_and_progression_spec.md):
  milestone quest chain, progression flags, rewards, and World Break quest rules.
- [Character Creation Spec](character_creation_spec.md):
  starter selection, naming, confirmation, save fields, and opening variants.
- [Party System Technical Spec](party_system_technical_spec.md):
  roster, active party, names, tag attacks, KO behavior, reserve XP, affinity.
- [Momentum Tuning](momentum_tuning.md):
  first-pass values for swaps, combo refunds, cooldowns, and difficulty presets.
- [Combat and Movement Spec](combat_movement_spec.md):
  inputs, combo attacks, dash, jump, wall actions, dive bomb, and controllers.
- [Enemy AI Spec](enemy_ai_spec.md):
  enemy states, patrol paths, attacks, respawn, Samurai Castle AI, and Masakiro.
- [Save and Load UX Spec](save_load_ux_spec.md):
  Continue, Load Game, slots, global settings, save data, and migration.
- [Sakuramori Court Spec](sakuramori_court_spec.md):
  first hub layout, services, NPC schedules, and World Break variant.
- [Samurai Castle Wing Spec](samurai_castle_wing_spec.md):
  first identity dungeon, stealth, rescue, Shadow, Masakiro, and seal reward.
- [World Break State Plan](world_break_state_plan.md):
  pre-break, break event, post-break variants, and data-model notes.
- [Traversal Seals](traversal_seals.md):
  traversal categories and character-specific expressions.
- [Zone Manifest](zone_manifest.md):
  candidate zone list and asset-support acceptance criteria.
- [Final Dungeon Spec](final_dungeon_spec.md):
  Final Tower, Monster Belly, Core, boss gauntlet, and ending outline.

## Canon Direction

Use older Chroma's Edge and Orion material only as inspiration for structure and
systems. The Black Keep replaces Orion, the Lattice, Nix, Dominion, ATB combat,
and the fixed 13-character party with a new world, new cast, real-time tag
combat, player-named heroes, and Black Keep traversal seals.

## Current Foundation

The repo already has a working Godot vertical slice foundation:

- Title, continue, settings, load game, and overwrite-safe character selection flow.
- Three starter classes with movement and combat abilities.
- Save and continue state.
- Room transitions, traversal gates, shortcuts, hazards, enemies, checkpoint
  respawn, pause saving, and boss-gated exits.
- Swamp Outskirts route and Castle Gate groundwork.
- HUD feedback for health, resource, XP, level, upgrades, room, map, active
  party, Momentum, and KO state.
- Familiar progression.
- Witch/Shadow recruitment, tag-entry attacks, KO auto-switch, and Sakuramori
  Court save/party/training service coverage.
- CharacterCreator2D Base Fantasy source package import plus Godot-native
  in-game creator, external Character Studio, CLI export, validation, readiness
  report, and socket baselines.
