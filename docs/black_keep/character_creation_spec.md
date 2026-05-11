# Character Creation Spec

Character creation starts the Black Keep run by selecting one of three starter titles and naming that character. The Witch is not selectable.

## Starter Choices

- The Ronin
- The Arc-Gunner
- The Iron Knight

Not selectable:

- The Black Witch of Ash
- The Shadow
- Any secret character
- New Game+ character

## Flow

```text
New Game
-> Starter Select
-> Starter Description
-> Name Input
-> Confirmation
-> Opening Scene Variant
-> Modern City Outskirts
```

## Starter Select Screen

Screen needs:

- Three starter cards.
- Title.
- Role description.
- Movement identity preview.
- Combat identity preview.
- Difficulty/readability note.
- Sprite preview.
- Confirm and back controls.

## Starter Title Descriptions

The Ronin:

- Sword-focused starter.
- Strong melee fundamentals.
- Traversal expression: blade-step and disciplined movement.
- Best for players who want direct action combat.

The Arc-Gunner:

- Ranged/tech starter.
- Uses magical firearms or arc-infused shots.
- Traversal expression: recoil boosts and arc movement.
- Best for players who want spacing and mobility.

The Iron Knight:

- Defensive/tank starter.
- Uses armor, shield, and heavy force.
- Traversal expression: shield brace and heavy break movement.
- Best for players who want durability and deliberate combat.

## Name Input Screen

Requirements:

- Prompt for player-given name.
- Preserve fixed title separately.
- Validate empty names.
- Limit length.
- Support keyboard and controller entry.
- Provide cancel/back behavior.

## Confirmation Screen

Show:

- Chosen name.
- Fixed title.
- Starter sprite.
- Short role summary.
- Start Game button.
- Back button to edit name or starter.

## Save Data Fields

Needed fields:

- `selected_starter_id`
- `player_character_names`
- `party_roster`
- `active_party`
- `unlocked_characters`
- `current_visible_character`
- `character_definitions_version`

Existing SpriteVania class/sprite fields can be bridged during migration, but The Black Keep should move toward character-definition IDs.

## Opening Dialogue Variants

Opening should support starter-specific variants:

- Ronin: personal duty, discipline, blade memory.
- Arc-Gunner: modern tactical framing, strange energy detection.
- Iron Knight: survival, protection, cursed armor or oath framing.

Do not write final dialogue yet.

## Locked Decisions

- Three starter options only.
- Witch is recruited later and named during recruitment.
- The player's chosen name and fixed title are separate fields.
- Character creation should lead into Modern City Outskirts.

## Open Questions

- Exact name length limit.
- Whether starter descriptions include difficulty labels.
- Whether initial sprite selection remains separate or is absorbed into starter choice.
- Whether each starter begins with a unique tutorial prompt.

## Implementation Notes

- Keep data model compatible with save migration.
- Use resource IDs, not display strings, for starter selection.
- Store title separately from player-given name.
- Make confirmation screen controller-first.

