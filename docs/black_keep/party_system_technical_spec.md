# Party System Technical Spec

This spec defines implementation-level planning for Black Keep party data, character names, active party state, swaps, KO behavior, reserve XP, hub management, and pair affinity.

## Core Resources

### CharacterDefinition

Planned fields:

- `id`
- `title`
- `default_display_name`
- `role`
- `sprite_scene`
- `portrait`
- `base_stats`
- `resource_type`
- `starter_selectable`
- `secret`
- `ng_plus_only`
- `tag_attack_id`
- `traversal_expression_ids`
- `quest_ids`

### CharacterRuntimeState

Planned fields:

- `character_id`
- `player_name`
- `unlocked`
- `level`
- `xp`
- `current_hp`
- `current_resource`
- `momentum`
- `equipment`
- `unlocked_skills`
- `quest_state`
- `costume_id`
- `palette_id`

### PartyRoster

Planned fields:

- `characters`
- `unlocked_character_ids`
- `reserve_character_ids`
- `active_party_ids`
- `current_visible_character_id`
- `pair_affinity`

### ActiveParty

Planned fields:

- `slot_1_character_id`
- `slot_2_character_id`
- `slot_3_character_id`
- `current_slot`
- `swap_cooldowns`
- `tag_attack_cooldowns`
- `ko_locked_slots`

## Locked Decisions

- Active party has 3 characters.
- Only one character is visible/control-active at a time.
- Mid-fight swapping is allowed among the active 3.
- Full roster changes happen at Cherry Blossom Court hubs.
- Player-given names are stored separately from fixed titles.
- KO auto-switches to another living active character when possible.
- Reserve roster gains partial XP.

## Individual Character State

Each character needs:

- HP.
- Resource.
- Momentum.
- Level.
- XP.
- Skills.
- Equipment.
- Player-given name.
- Fixed title.

## Tag Attacks

Tag attacks trigger when a character swaps in under valid conditions.

Needed rules:

- Entry attack per character.
- Cooldown per character or per tag attack.
- Momentum cost/refund interaction.
- Combo scaling.
- Boss immunity/stagger rules.
- Accessibility and reduced camera intensity hooks.

## Swap Combo Rules

Swap should consider:

- Momentum availability.
- Swap input buffering.
- Current attack cancel windows.
- Combo timer.
- Perfect-swap timing window.
- Whether incoming character can perform a tag-entry attack.

## KO Auto-Switch

Behavior:

- If the visible character is KO'd, auto-switch to the next living active character.
- If no active character is alive, trigger death/respawn.
- KO'd active characters recover slowly only if rules allow.
- UI must clearly show KO state and next active character.

## Bench Recovery

Active but benched characters recover slowly.

Reserve characters do not recover in combat unless a separate item/system allows it.

## Reserve XP

Reserve roster gains partial XP so late-game characters do not fall too far behind.

First-pass policy:

- Active visible character: 100% XP.
- Active benched characters: 100% XP.
- Reserve unlocked characters: 50% XP.

## Hub Party Management

Cherry Blossom Court hubs should allow:

- Active party selection.
- Character renaming.
- Equipment changes.
- Skill review.
- Costume/palette changes.
- Pair affinity review.
- Training room tests.

## Pair Affinity and Duo Attacks

Pair affinity is inspiration from older docs, adapted to The Black Keep.

Needed data:

- Pair key.
- Affinity level.
- Unlocked duo attack.
- Optional hub scene state.
- Quest or combat unlock requirements.

Do not write final pair scenes yet.

## Open Questions

- Whether Momentum is stored in save data or reset on load.
- Whether KO state persists through room transitions.
- Whether reserve XP applies before recruitment quests are complete.
- How many equipment slots each character has.
- Whether familiars are per-character, party-wide, or replaced by party systems.

## Implementation Notes

- Introduce data resources before large gameplay rewrites.
- Save migration should bridge current class-based player data into character roster data.
- Write tests around roster serialization before adding UI.
- Keep title/name formatting centralized.

