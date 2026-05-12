# Party System Technical Spec

This spec defines implementation-level planning for Black Keep party data,
character names, active party state, swaps, KO behavior, reserve XP, hub
management, and pair affinity.

## Goals

- Replace class-only player state with character-definition state.
- Support player-given names and fixed titles.
- Keep one visible controlled character on screen.
- Allow three-character active party swapping.
- Preserve individual HP, resource, XP, level, Momentum, and skills.
- Support future hub party management and affinity without blocking milestone
  one.

## Stable Character IDs

Base game:

- `ronin`
- `arc_gunner`
- `iron_knight`
- `black_witch_ash`
- `shadow`
- `gadgeteer`
- `blood_marked`
- `yokai_bound`

New Game Plus:

- `fallen_shogun`

## Core Resources

### CharacterDefinition

Planned fields:

- `id`
- `title`
- `default_display_name`
- `role`
- `short_description`
- `sprite_scene`
- `portrait`
- `base_stats`
- `growth_profile_id`
- `resource_type`
- `starter_selectable`
- `secret`
- `ng_plus_only`
- `tag_attack_id`
- `baseline_skill_ids`
- `learned_skill_table_id`
- `traversal_expression_ids`
- `quest_ids`
- `default_costume_id`
- `default_palette_id`

Rules:

- Definitions are read-only at runtime.
- Save data stores definition IDs, not copied display text.
- Missing definition IDs should fail gracefully in load validation.

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
- `ko_state`
- `last_active_timestamp`

Rules:

- Runtime state is saved.
- Player name is stored here.
- Fixed title comes from `CharacterDefinition`.
- HP/resource/Momentum are individual.

### PartyRoster

Planned fields:

- `characters`
- `unlocked_character_ids`
- `reserve_character_ids`
- `active_party_ids`
- `current_visible_character_id`
- `pair_affinity`
- `party_order_version`

Rules:

- Active party has up to three character IDs.
- Empty active slots are allowed before Witch and Shadow recruitment.
- Reserve IDs are unlocked characters not currently active.

### ActiveParty

Planned fields:

- `slot_1_character_id`
- `slot_2_character_id`
- `slot_3_character_id`
- `current_slot`
- `swap_cooldowns`
- `tag_attack_cooldowns`
- `ko_locked_slots`
- `last_swap_timestamp`
- `combo_state`

Rules:

- `ActiveParty` can be rebuilt from `PartyRoster` on room load.
- Combat-only cooldowns may reset on load unless explicitly saved.

## Initial State

New Game initial state:

- Active slot 1: selected starter.
- Active slot 2: empty.
- Active slot 3: empty.
- Current visible character: selected starter.
- Reserve: empty.
- Unlocked: selected starter.

After Witch recruitment:

- Active slot 1: selected starter.
- Active slot 2: `black_witch_ash`.
- Active slot 3: empty.
- Current visible character remains selected starter unless tutorial swaps.

After Shadow recruitment:

- Active slot 1: selected starter.
- Active slot 2: `black_witch_ash`.
- Active slot 3: `shadow`.
- Current visible character remains current tutorial character unless rescue
  sequence requires Shadow preview.

## Party HUD

Milestone HUD requirements:

- One slot per active character.
- Fixed title or short title.
- Player-given name.
- HP bar.
- Resource bar.
- Momentum ring.
- KO state.
- Tag cooldown state.
- Current visible character highlight.

Empty slot state:

- Hidden or locked placeholder before recruitment.
- Must not look like a broken UI element.

## Swap Rules

Swap is valid when:

- Target slot has an unlocked character.
- Target character is not KO locked.
- Current character is not in a non-cancellable state.
- Momentum cost can be paid, unless swap is a KO auto-switch.

Swap sequence:

1. Buffer swap input if current state allows buffering.
2. Validate target slot.
3. Validate Momentum or KO exception.
4. Store outgoing character runtime values.
5. Spawn or activate incoming character at controlled position.
6. Apply incoming character collision profile.
7. Update camera target.
8. Trigger tag-entry attack if valid and off cooldown.
9. Update HUD.

Position rules:

- Incoming character inherits outgoing world position.
- If collision profile would overlap solid geometry, use nearest safe position.
- Facing direction is preserved unless tag attack overrides it.

## Momentum Rules

Momentum source of truth:

- Individual character runtime state.

Swap cost:

- Read from Momentum tuning by difficulty preset.

Combo refund:

- Awarded to the visible character or incoming character according to combat
  implementation, but must be consistent and tested.

Room transition:

- First-pass decision: carry Momentum between rooms.

Checkpoint respawn:

- First-pass decision: restore Momentum to at least 50 for living active
  characters.

## Tag Attacks

Tag attacks trigger when:

- Swap is player-initiated.
- Incoming tag attack is off cooldown.
- Incoming character has enough Momentum if the tag has an extra cost.
- Current combat state allows tag attack.

Milestone tag attacks:

- Ronin: quick crossing slash.
- Arc-Gunner: entry shot burst.
- Iron Knight: shield crash.
- Black Witch of Ash: Ashen Hexburst.
- Shadow: Silent Arrowfall.

Cooldown:

- Per character.
- Stored in active combat state.
- Usually resets on checkpoint reload.

Reduced motion:

- Camera impulse, large particles, and screen distortion must scale down.

## KO Auto-Switch

Behavior:

- If visible character reaches 0 HP, mark that character KO.
- If another active character is alive, auto-switch to the next living active
  character.
- KO auto-switch costs no Momentum.
- KO auto-switch does not trigger full tag attack.
- Incoming character gets brief invulnerability.
- If no active character survives, trigger death/respawn.

Next-character priority:

1. Next slot clockwise.
2. Previous slot if next is unavailable.
3. Any living slot by active-party order.

KO recovery:

- First-pass decision: KO state clears at checkpoint, inn, save shrine healing,
  or specific item.
- Benched active characters can recover HP only if not KO.

## Bench Recovery

Active but benched characters:

- Recover HP slowly if alive.
- Recover resource slowly if their resource type allows it.
- Do not recover during menus that pause combat unless explicitly allowed.

Reserve characters:

- Do not recover in combat.
- Recover at hub services.

## XP Distribution

First-pass policy:

- Active visible character: 100 percent XP.
- Active benched characters: 100 percent XP.
- Reserve unlocked characters: 50 percent XP.
- Locked or unrecruited characters: 0 percent XP.
- Familiar XP follows familiar-specific rules.

Level-up:

- Can happen on enemy defeat.
- Can happen on reward screen if batching is later preferred.
- Must update runtime stats safely.
- Current HP increase should not kill or reduce current HP.

## Hub Party Management

Cherry Blossom Court hubs should allow:

- Active party selection.
- Character renaming.
- Equipment changes.
- Skill review.
- Costume and palette changes.
- Pair affinity review.
- Training room tests.

Milestone shell:

- Display active party.
- Allow reorder of unlocked characters if three or fewer are unlocked.
- Show locked placeholders for future recruits.
- Allow renaming only if name-input component is ready.

## Pair Affinity And Duo Attacks

Pair affinity is inspired by older docs, adapted to The Black Keep.

Data fields:

- Pair key.
- Affinity XP.
- Affinity level.
- Unlocked duo attack.
- Optional hub scene state.
- Quest or combat unlock requirements.

Milestone one:

- Data model may include empty affinity map.
- No final pair scenes.
- No required duo attack implementation.

## Implementation Sequence

Phase 1: Data resources.

- Add `CharacterDefinition` resources.
- Add starter definitions.
- Add Witch and Shadow definitions.
- Add runtime-state serialization tests.

Phase 2: Character creation bridge.

- Write selected starter into party roster.
- Save player-given name.
- Load current visible character from party state.

Phase 3: Two-character swap.

- Add Witch recruitment.
- Add active slot 2.
- Add swap input and HUD update.
- Add Ashen Hexburst placeholder.

Phase 4: Three-character party.

- Add Shadow recruitment.
- Add active slot 3.
- Add Shadow tag attack placeholder.
- Add KO auto-switch.

Phase 5: Hub management shell.

- Add Sakuramori Court party shrine.
- Add reorder UI placeholder.
- Add rename hook if ready.
- Reorder/rename commits must be atomic: invalid party IDs, missing recruits,
  and blank rename requests fail before mutating roster state.

## Tests

Automated tests:

- Character definitions load by ID.
- Starter definition has required fields.
- Witch is not starter selectable.
- New Game creates one-character active party.
- Witch recruitment creates two-character active party.
- Shadow recruitment creates three-character active party.
- Player-given names save and load.
- Fixed titles come from definitions.
- Swap changes visible character.
- Invalid swap target is ignored safely.
- KO auto-switch picks a living character.
- Full party KO triggers death/respawn.
- Reserve XP is applied only to unlocked reserve characters.
- Party order saves and loads.
- Party Shrine rejects invalid reorder/rename payloads without partial state
  changes.

Manual tests:

- Start as each starter.
- Recruit Witch and swap.
- Rescue Shadow and swap across all three slots.
- KO visible character and observe auto-switch.
- Save and continue after each recruitment.
- Open hub party shrine and return to gameplay.
- Try invalid rename/reorder inputs and verify the previous party state remains.

## Locked Decisions

- Active party has three characters.
- Only one character is visible/control-active at a time.
- Mid-fight swapping is allowed among the active three.
- Full roster changes happen at Cherry Blossom Court hubs.
- Player-given names are stored separately from fixed titles.
- KO auto-switches to another living active character when possible.
- HUD displays KO state for active party members.
- Reserve roster gains partial XP.

## Open Questions

- Should Momentum persist exactly through save/load or normalize on load?
- Should KO state persist through room transitions outside combat?
- How many equipment slots does each character need for milestone one?
- Are familiars party-wide, per-character, or separate from party identity?
- Should hub reorder be available immediately at Sakuramori Court?

## Implementation Notes

- Introduce data resources before large gameplay rewrites.
- Save migration should bridge current class-based player data into character
  roster data.
- Write tests around roster serialization before adding UI.
- Keep title/name formatting centralized.
- Avoid tying character identity to current sprite paths.
