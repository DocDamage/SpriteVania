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

