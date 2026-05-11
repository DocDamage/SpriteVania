# Technical Architecture Plan

This document proposes the implementation architecture for The Black Keep inside
the current Godot project. It should be refined after reading the existing scene
and script structure before code changes begin.

## Goals

- Keep systems data-driven where practical.
- Avoid hardcoding character identity into player scripts.
- Keep save data versioned and migration-friendly.
- Make room transitions and checkpoints testable.
- Keep milestone implementation compatible with later full-game systems.

## Core Data Resources

Character resources:

- `CharacterDefinition`
- `CharacterGrowthProfile`
- `CharacterSkillTable`
- `TagAttackDefinition`
- `TraversalExpressionDefinition`

Room and zone resources:

- `ZoneDefinition`
- `RoomDefinition`
- `RoomExitDefinition`
- `CheckpointDefinition`
- `EnemySpawnDefinition`
- `TraversalGateDefinition`

Combat resources:

- `AttackDefinition`
- `ComboDefinition`
- `HitboxDefinition`
- `ProjectileDefinition`
- `DamageProfile`
- `EnemyDefinition`
- `BossDefinition`

Settings and save resources:

- `SettingsProfile`
- `SaveGameData`
- `SaveSlotMetadata`
- `SaveMigrationStep`

## Runtime Managers

Game state manager:

- Owns current save data.
- Owns global flags.
- Exposes read/write helpers for story and progression state.

Settings manager:

- Loads global settings before title menu.
- Saves global settings without requiring a game save.
- Applies settings to audio, display, input, and accessibility systems.

Save manager:

- Reads and writes save slots.
- Validates save data.
- Runs migrations.
- Maintains latest-save metadata.

Room manager:

- Loads rooms by stable room ID.
- Resolves exits and spawn markers.
- Applies checkpoint state.
- Owns room re-entry reset behavior.

Party manager:

- Owns roster and active party state.
- Handles recruitment.
- Handles swaps and KO auto-switch requests.
- Provides HUD data.

Combat manager:

- Resolves damage events.
- Tracks combo state.
- Awards XP.
- Reports enemy death to party and familiar systems.

Familiar manager:

- Owns familiar runtime state.
- Handles familiar target selection.
- Saves level, XP, evolution, and abilities.

World state manager:

- Owns World Break state.
- Resolves zone variants.
- Resolves title screen variant from latest valid save.

## Scene Boundaries

Title scene:

- Handles title menu presentation.
- Delegates Continue and Load Game to save manager.
- Delegates Settings to settings menu.

Character creation scene:

- Reads starter definitions.
- Writes initial save data only after confirmation.

Gameplay root:

- Owns player, camera, HUD, current room, and managers needed during gameplay.

Room scenes:

- Contain terrain, collision, exits, spawn markers, enemy spawns, and local
  interactables.
- Should not own global story logic directly.

Hub scenes:

- Use service nodes for save shrine, party shrine, training, shops, and
  placeholders.

Dev scenes:

- Import tests.
- Movement tests.
- Combat tests.
- Enemy AI tests.

## Save Architecture

Save data should include:

- Version.
- Slot ID.
- Current room ID.
- Current checkpoint ID.
- Current player position or spawn marker.
- Party roster.
- Character runtime states.
- Familiar state.
- Story flags.
- Zone states.
- Seal unlocks.
- Discovered rooms.
- Settings overrides.

Write flow:

1. Build save data.
2. Validate required fields.
3. Serialize to temporary file.
4. Read back or validate serialized content.
5. Replace target save.
6. Update slot metadata.

Load flow:

1. Read slot data.
2. Validate parse.
3. Validate version.
4. Run migrations if needed.
5. Validate room and checkpoint.
6. Load safe fallback if room is invalid.
7. Apply settings overrides.
8. Restore gameplay state.

## Room Transition Architecture

Exit data:

- Exit ID.
- Target room ID.
- Target spawn marker ID.
- Required flag.
- Required traversal category.
- Locked feedback text key.

Transition flow:

1. Player enters exit trigger.
2. Room manager validates requirements.
3. Gameplay input is locked.
4. Save pending room transition state if needed.
5. Target room loads.
6. Player spawns at target marker.
7. Camera clamps to target room bounds.
8. Room enemies initialize from respawn policy.
9. Input unlocks.

## Combat Architecture

Damage event fields:

- Source type.
- Source ID.
- Attacker character ID, if any.
- Target ID.
- Attack ID.
- Damage amount.
- Stagger value.
- Knockback vector.
- Tags.

Rules:

- Player attacks and familiar attacks share damage-event structure.
- Enemy death sends XP events to party and familiar systems.
- Hitstop and screen shake read settings before applying.
- Boss damage can use the same event structure with boss-specific resistance.

## Input Architecture

Input actions should be stable and user-remappable.

Gameplay actions:

- Move.
- Jump.
- Attack.
- Special.
- Dash.
- Slide.
- Interact.
- Swap.
- Familiar command.
- Pause.
- Map.

Menu actions:

- Navigate.
- Confirm.
- Back.
- Secondary.
- Tab left.
- Tab right.

Prompt display:

- Reads action names, not hardcoded keys.
- Resolves keyboard, Xbox, PlayStation, Switch, or generic controller labels.

## Testing Architecture

Headless tests should cover:

- Resource loading.
- Save serialization.
- Save migration.
- Room transition graph.
- Enemy state transitions.
- Player movement rules.
- Combat hit resolution.
- Party recruitment.
- Familiar progression.
- Settings persistence.

Dev scenes should cover:

- Playable import tests.
- Movement sandbox.
- Combat sandbox.
- Enemy patrol test.
- Hub service test.

## Implementation Order

1. Save and settings foundation.
2. Character definitions and character creation.
3. Movement and combat reliability.
4. Enemy AI and room reset.
5. Familiar persistence and attacks.
6. Party recruitment and swap system.
7. Milestone room graph implementation.
8. Asset integration.
9. Hub services.
10. World expansion foundation.

## Open Questions

- Which existing scripts already act as managers and should be extended?
- Should resources be custom `Resource` scripts or JSON-like data files?
- How much current player code can be adapted before a refactor is needed?
- Where should derived asset resources live in the current Godot project?
- Which tests already exist and should be extended first?
