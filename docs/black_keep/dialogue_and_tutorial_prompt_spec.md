# Dialogue And Tutorial Prompt Spec

This document defines dialogue and tutorial prompt requirements without writing
final dialogue. It exists so implementation can add placeholders that match the
planned structure.

## Rules

- Do not write final dialogue until character voice is locked.
- Placeholder text should be functional and clearly marked.
- Tutorial prompts must be short.
- Tutorial prompts must support keyboard and controller glyphs.
- Story dialogue should never block retry loops for too long.
- Skippable scenes must not skip required state changes.

## Dialogue Types

System prompt:

- Short gameplay instruction.
- Can reference input actions.
- Example use: attack, jump, interact, save.

Story beat:

- Character or scene dialogue.
- Advances story context.
- Should be skippable after first view.

Recruitment prompt:

- Naming and confirmation flow.
- Must save state after success.

Warning prompt:

- Save overwrite.
- Delete save.
- Enter boss room.
- Accessibility or settings warning.

Lore note:

- Optional text.
- Can be archived.
- Should not block main progression.

## Placeholder Text Format

Use placeholder text format:

- `TODO_DIALOGUE: short purpose`
- `TODO_TUTORIAL: short purpose`
- `TODO_LORE: short purpose`

Examples:

- `TODO_TUTORIAL: teach attack input`
- `TODO_DIALOGUE: Witch recruitment introduction`
- `TODO_LORE: oni manipulation clue`

## First Milestone Tutorial Prompts

Movement:

- Teach move.
- Teach jump.
- Teach double jump.
- Teach dash.
- Teach air dash.
- Teach wall hang.
- Teach wall jump.
- Teach dash.

Combat:

- Teach attack.
- Teach combo.
- Teach dash strike.
- Teach dive bomb.
- Teach enemy windup.
- Teach healing or checkpoint.

Familiar:

- Teach familiar follow.
- Teach familiar attack.
- Teach familiar level up.
- Teach familiar upgrade.

Party:

- Teach Witch recruitment.
- Teach swap.
- Teach Momentum.
- Teach tag attack.
- Teach Shadow rescue.
- Teach three-character swap.
- Teach KO auto-switch if it happens.

Traversal:

- Teach Rising Torii Seal pickup.
- Teach vertical ascent.

## Prompt Placement

ModernOutskirts_Start:

- Move prompt.
- Jump prompt.

Swamp_MovementTutorial:

- Double jump prompt.
- Dash prompt.
- Wall prompt.
- Dash-strike prompt if available.

Swamp_EnemyTutorial:

- Attack prompt.
- Combo prompt after first hit.

Swamp_Hazard:

- Hazard warning.
- Checkpoint reminder if needed.

CastleGate_DamagedShrine:

- Witch interaction prompt.
- Witch naming prompt.

CastleGate_TagTutorial:

- Swap prompt.
- Momentum prompt.
- Tag attack prompt.

SamuraiCastle_PatrolHall:

- Patrol warning.
- Alarm warning.

SamuraiCastle_ShadowPrison:

- Rescue prompt.
- Shadow naming prompt.

SamuraiCastle_AlarmEscape:

- Three-character swap prompt.

SamuraiCastle_RisingToriiSeal:

- Seal pickup prompt.

SamuraiCastle_AscentTest:

- Vertical ascent prompt.

SakuramoriCourt_SaveShrine:

- Save prompt.

SakuramoriCourt_PartyShrine:

- Party shrine prompt.

## Story Beat Placeholders

Opening variant:

- Ronin opening placeholder.
- Arc-Gunner opening placeholder.
- Iron Knight opening placeholder.

Castle Gate:

- First Keep arrival placeholder.
- Damaged shrine discovery placeholder.

Witch recruitment:

- Witch reveal placeholder.
- Witch naming acceptance placeholder.
- Witch seal explanation placeholder.

Samurai Castle:

- First Feudal Japan fragment placeholder.
- Oni manipulation clue placeholder.
- Patrol warning placeholder.

Shadow recruitment:

- Shadow rescue placeholder.
- Shadow naming acceptance placeholder.
- Alarm escape trigger placeholder.

Masakiro:

- Boss intro placeholder.
- Phase transition placeholder.
- Oni-consumption placeholder.

Sakuramori Court:

- Harune intro placeholder.
- Save shrine explanation placeholder.
- Moonpetal Passage hint placeholder.

## Dialogue State Flags

Suggested flags:

- `seen_opening_variant`
- `seen_keep_arrival`
- `seen_witch_recruitment`
- `seen_tag_tutorial`
- `seen_samurai_castle_intro`
- `seen_shadow_rescue`
- `seen_masakiro_intro`
- `seen_masakiro_defeat`
- `seen_harune_intro`
- `seen_rising_torii_tutorial`

Rules:

- Story beats can be skipped on repeat if flag is set.
- State-changing scenes must still apply state if skipped.
- Tutorial prompts can be disabled after completion.

## Accessibility Requirements

- Text speed setting applies to dialogue.
- Large text setting applies to prompts.
- Subtitles apply to voiced lines if voices are later added.
- Prompt icons must have text fallback.
- Important tutorial content should be available in controls/help menu later.

## Tests

Automated tests:

- Tutorial prompt can resolve keyboard input label.
- Tutorial prompt can resolve controller input label.
- Dialogue flags save and load.
- Skipping a recruitment scene still applies recruitment state.
- Prompt completion flag prevents repeated tutorial spam.

Manual tests:

- Complete first enemy tutorial with keyboard.
- Complete first enemy tutorial with controller.
- Recruit Witch and skip repeated scene.
- Rescue Shadow and verify state persists.
- Enable large text and check prompt fit.
