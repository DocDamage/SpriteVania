# SpriteVania Implementation Roadmap

## Current Prototype Spine

- Title, continue, settings, and character selection flow.
- Three distinct playable classes with regular and special attack hooks.
- Save and continue state, including checkpoint room, position, stats, upgrades, shortcuts, boss defeats, and area completion.
- XP and leveling with HUD updates.
- Room transitions, traversal gates, shortcuts, hazards, enemy contact damage, checkpoint respawn, and boss-gated exits.
- Integrated swamp tiles, player animation frames, and starter enemy animations.

## Next Playable-Slice Priorities

1. Player hit feel: invulnerability frames, hit flash, knockback, death animation, and clean damage feedback.
2. Enemy behavior: patrol bounds, aggro ranges, explicit attacks, drops, and boss patterns.
3. Progression content: attack-skill pickups, resource costs, cooldowns, and level-up rewards.
4. Map structure: more rooms, minimap/discovery, locked doors, keys, and backtracking loops.
5. Asset pass: additional sprite sheet cuts, VFX, UI font/art, room transitions, and audio.
6. Menu polish: persistent settings, pause menu, save slots, and input rebinding.
7. QA hardening: scene cleanup scans, export presets, playtest checklist, and performance checks.

## Vertical Slice Definition

A first complete slice should include:

- One start route, one traversal gate, one checkpoint, one hazard room, one enemy room, one attack-skill pickup, one shortcut, and one miniboss gate.
- At least one class-specific traversal identity and one attack-skill reward per class.
- A complete death loop: damage feedback, respawn at checkpoint, room reset, and saved restored state.
- HUD feedback for health, resource, XP, level, upgrades, and area completion.
- Clean headless tests for every system above.
