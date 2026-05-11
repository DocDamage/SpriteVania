# SpriteVania Implementation Roadmap

## Current Creative Direction

The current implementation foundation remains the SpriteVania vertical slice: it is the playable systems base for movement, combat, saves, rooms, UI, progression, and tests. The target game direction is now **The Black Keep**, a larger castle-and-portal action RPG / Metroidvania built on that foundation.

See the full creative and systems direction in [The Black Keep Master Plan](BLACK_KEEP_MASTER_PLAN.md).

## Current Vertical Slice

- Title, continue, settings, and character selection flow.
- Three distinct playable classes with class-specific traversal actions and learned attack skills.
- Save and continue state, including checkpoint room, position, stats, upgrades, shortcuts, boss defeats, discovered rooms, settings, and area completion.
- Save data now carries an explicit version while older unversioned saves remain loadable.
- XP and leveling with HUD updates.
- Room transitions, traversal gates, shortcuts, hazards, enemy contact damage, checkpoint respawn, pause saving, and boss-gated exits.
- Swamp Outskirts route with start, movement, enemy, hazard, checkpoint, upgrade, shortcut, and miniboss rooms.
- HUD feedback for health, resource, XP, level, upgrades, current room, and map discovery.
- Integrated swamp tiles, player animation frames, starter enemy animations, and scene-instantiation coverage.
- Familiar progression includes leveling, evolution, upgradable abilities, enemy attacks, guard mitigation, and evolution-based attack reach.
- Combat reliability includes one-shot death handling and knockback from enemy contact and crawler attacks.
- Full-game expansion groundwork has begun with a two-room Castle Gate route that loads after Swamp completion.

## Remaining Full-Game Priorities

1. Expand Castle Gate into a full route with enemies, checkpoint, upgrade, shortcut, and boss, then build cemetery, church, cold corridor, town, wasteland, horror, and sci-fi routes.
2. Expand boss roster from the first miniboss into full biome bosses with class-readable patterns.
3. Add deeper level-up rewards, optional upgrades, keys, locked doors, and discovery rewards.
4. Add story/NPC content, item descriptions, lore rewards, and class-specific motivation scenes.
5. Finish asset/audio pass: more cut sprite sheets, VFX, UI art/fonts, room transitions, music, and sound effects.
6. Replace the prototype map display with a full minimap screen, icons, and room-state markers.
7. Harden production: export smoke tests, controller support playtests, performance pass, save migrations, and release checklist.

## Vertical Slice Definition

The first complete slice includes:

- One start route, one traversal gate, one checkpoint, one hazard room, one enemy room, one attack-skill pickup, one shortcut, and one miniboss gate.
- At least one class-specific traversal identity and one attack-skill reward per class.
- A complete death loop: damage feedback, respawn at checkpoint, room reset, and saved restored state.
- HUD feedback for health, resource, XP, level, upgrades, discovered rooms, and area completion.
- Clean headless tests for every system above.
