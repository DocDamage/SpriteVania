# The Black Keep Documentation

This folder splits the Black Keep master plan into focused planning documents. The single-source overview remains [BLACK_KEEP_MASTER_PLAN.md](../BLACK_KEEP_MASTER_PLAN.md).

The current implementation foundation is still the SpriteVania vertical slice. The target game direction is now The Black Keep: a real-time action RPG / Metroidvania about a demonic castle rooted near modern outskirts and a rural swamp road, with portals into pocket dimensions from different points in time and space.

## Focused Documents

- [First Milestone](first_milestone.md): first playable Black Keep milestone, active party target, early route, and milestone proof points.
- [Party and Combat](party_and_combat.md): playable roster, active party, Momentum, tag swaps, combo timing, and character quest structure.
- [Menu and Settings Plan](menu_settings_plan.md): title screen, menu routing, settings tabs, persistence, accessibility, and remaining UI work.
- [Art Pipeline](art_pipeline.md): palette/style rules, sprite requirements, normalization pipeline, parallax, and area art priorities.
- [Asset Classification](asset_classification.md): asset sorting plan and criteria for playable, NPC, enemy, boss, terrain, UI, VFX, and fallback usage.
- [Story Outline](story_outline.md): premise, early zones, hubs, traversal seals, Feudal Japan fragments, Masakiro, World Break, and final dungeon.

## Production Planning Specs

- [Planning Backlog](planning_backlog.md): ordered planning tasks and dependencies.
- [Asset Audit Results](asset_audit_results.md): asset classification and playable candidate audit template.
- [Playable Import Test Plan](playable_import_test_plan.md): import-test order, slicing assumptions, acceptance criteria, and candidate-specific risks.
- [First Milestone Production Spec](first_milestone_production_spec.md): room-by-room build scope for the first Black Keep milestone.
- [Character Creation Spec](character_creation_spec.md): starter selection, naming, confirmation, save fields, and opening variants.
- [Party System Technical Spec](party_system_technical_spec.md): implementation-level party roster, active party, names, tag attacks, KO behavior, reserve XP, and affinity planning.
- [Momentum Tuning](momentum_tuning.md): first-pass values for Momentum, swaps, combo refunds, tag cooldowns, and difficulty presets.
- [Sakuramori Court Spec](sakuramori_court_spec.md): first hub layout, services, NPC schedules, and World Break variant.
- [Samurai Castle Wing Spec](samurai_castle_wing_spec.md): first identity dungeon, stealth/rescue, Shadow recruitment, Masakiro, and seal reward.
- [World Break State Plan](world_break_state_plan.md): pre-break, break event, post-break state, variants, and data-model notes.
- [Traversal Seals](traversal_seals.md): traversal categories and character-specific expressions.
- [Zone Manifest](zone_manifest.md): candidate zone list and asset-support acceptance criteria.
- [Final Dungeon Spec](final_dungeon_spec.md): Final Tower, Monster Belly, Core, boss gauntlet, and ending-choice outline.

## Canon Direction

Use older Chroma's Edge / Orion material only as inspiration for structure and systems. The Black Keep replaces Orion, the Lattice, Nix, Dominion, ATB combat, and the fixed 13-character party with a new world, new cast, real-time tag combat, player-named heroes, and Black Keep traversal seals.

## Current Foundation

The repo already has a working Godot vertical slice foundation:

- Title, continue, settings, load game, and character selection flow.
- Three starter classes with movement and combat abilities.
- Save/continue state.
- Room transitions, traversal gates, shortcuts, hazards, enemies, checkpoint respawn, pause saving, and boss-gated exits.
- Swamp Outskirts route and Castle Gate groundwork.
- HUD feedback for health, resource, XP, level, upgrades, current room, and map discovery.
- Familiar progression.
