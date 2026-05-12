# Character Creation Spec

Character creation starts the Black Keep run by selecting one of three starter
titles and naming that character. The Witch is not selectable.

## Goals

- Make the first meaningful choice clear.
- Keep the player's name separate from fixed character titles.
- Support keyboard and controller from the first menu.
- Create save data that can evolve into the full party system.
- Support the Godot-native CharacterCreator2D recipe pipeline for player appearance, palettes, morph values, and generated animation resources.
- Avoid final dialogue until writing direction is locked.

## Starter Choices

Selectable:

- The Ronin.
- The Arc-Gunner.
- The Iron Knight.

Not selectable:

- The Black Witch of Ash.
- The Shadow.
- Any secret character.
- New Game Plus character.

## Stable IDs

Starter IDs:

- `ronin`
- `arc_gunner`
- `iron_knight`

Later recruit IDs:

- `black_witch_ash`
- `shadow`
- `gadgeteer`
- `blood_marked`
- `yokai_bound`
- `fallen_shogun`

Character creation screen IDs:

- `starter_select`
- `starter_details`
- `name_input`
- `confirm_character`
- `opening_variant`

Save flags:

- `starter_selected`
- `starter_named`
- `new_game_committed`

## Flow

1. Player selects New Game from title screen.
2. Game opens starter select.
3. Player highlights a starter card.
4. Details panel updates with title, role, movement identity, and combat style.
5. Player confirms starter.
6. Game opens name input.
7. Player enters a valid name.
8. Game opens confirmation screen.
9. Player confirms or goes back to edit.
10. Game creates initial save state.
11. Game loads opening variant.
12. Game transitions to `ModernOutskirts_Start`.

Appearance flow:

- Starter selection remains a gameplay/class choice.
- Appearance editing uses the Godot-native CharacterCreator2D recipe model.
- The creator can run as a simplified in-game flow or as the full separate Character Studio app.
- A confirmed recipe stores selected parts, palette IDs, morph values, export profile ID, and optional generated `SpriteFrames` path.
- The game can start from a default starter recipe before the full creator UI is complete.

Back behavior:

- From starter select: return to title screen.
- From starter details: return to starter select.
- From name input: return to starter details.
- From confirmation: return to name input.

## Starter Select Screen

Required content:

- Three starter cards.
- Fixed title.
- Role tagline.
- Sprite preview.
- Combat identity preview.
- Traversal identity preview.
- Difficulty/readability note.
- Confirm action.
- Back action.
- Appearance/customize action when the Godot-native creator is enabled.

Card data:

- Starter ID.
- Title.
- Short role.
- Sprite preview resource.
- Control hint text.
- Locked or available state.

Navigation:

- Keyboard arrows or WASD.
- D-pad.
- Left stick.
- Mouse hover and click.
- Confirm button.
- Cancel/back button.

Accessibility:

- No required timed selection.
- Text must respect font-scale setting.
- Selection state cannot rely on color alone.
- Sprite preview can be disabled or simplified by reduced-motion mode.

## Starter Details

The Ronin:

- Title: The Ronin.
- Role: sword-focused melee starter.
- Combat identity: fast three-hit sword combo, air slash, precise tag timing.
- Traversal expression: blade-step, wall discipline, controlled air movement.
- Readability note: direct and responsive.

The Arc-Gunner:

- Title: The Arc-Gunner.
- Role: ranged and mobility starter.
- Combat identity: arc-infused shots, reload or heat rhythm, spacing control.
- Traversal expression: recoil boost, arc dash, tech-assisted movement.
- Readability note: strong range but needs spacing awareness.

The Iron Knight:

- Title: The Iron Knight.
- Role: defensive heavy starter.
- Combat identity: shield, heavy melee, guard, slower impact attacks.
- Traversal expression: shield brace, heavy break, stable wall movement.
- Readability note: durable but deliberate.

Do not write final character dialogue here.

## Name Input

Requirements:

- Prompt for player-given name.
- Preserve fixed title separately.
- Validate empty names.
- Limit length.
- Support keyboard entry.
- Support controller entry through an on-screen keyboard or text-entry overlay.
- Provide cancel/back behavior.
- Provide reset-to-default behavior.

Name rules:

- Minimum length: 1 visible character.
- Maximum length: 16 visible characters.
- Trim leading and trailing whitespace.
- Collapse repeated internal whitespace to one space.
- Reject control characters.
- Allow letters, numbers, spaces, apostrophes, hyphens, and underscores.
- Store the exact accepted display name after normalization.

Default names:

- Ronin default: Akio.
- Arc-Gunner default: Vale.
- Iron Knight default: Rowan.

These are placeholders and can change later.

## Confirmation Screen

Show:

- Chosen player name.
- Fixed title.
- Starter sprite.
- Short role summary.
- Starting abilities.
- Start Game button.
- Back button.

Start Game behavior:

- Creates or updates selected save slot.
- Writes initial party roster.
- Sets current room to `ModernOutskirts_Start`.
- Sets checkpoint to `checkpoint_modern_start`.
- Marks `starter_selected`, `starter_named`, and `new_game_committed`.

Failure behavior:

- If save write fails, show a non-crashing error and remain on confirmation.
- If selected slot is occupied, require overwrite confirmation before writing.

## Initial Party State

Initial active party:

- Slot 1: selected starter.
- Slot 2: empty.
- Slot 3: empty.

Unlocked characters:

- Selected starter only.

Visible character:

- Selected starter.

Initial abilities:

- Basic movement.
- Basic attack.
- Dash if the project decides dash is baseline.
- Double jump if the project decides modern baseline includes it.

If any advanced movement is withheld for tutorials or seals, the UI must not
promise it during selection.

## Save Data Fields

Character creation writes:

- `save_version`
- `selected_starter_id`
- `player_character_names`
- `character_runtime_states`
- `party_roster`
- `active_party_ids`
- `current_visible_character_id`
- `unlocked_character_ids`
- `current_room_id`
- `current_checkpoint_id`
- `character_definitions_version`
- `character_recipe_id`
- `character_recipe`
- `character_spriteframes_path`
- `character_creator_content_versions`
- `created_timestamp`
- `last_saved_timestamp`

Runtime state defaults:

- Level: 1.
- XP: 0.
- Current HP: max HP.
- Current resource: max resource.
- Momentum: 100 for the selected starter.
- Unlocked skills: starter baseline skills.
- Costume ID: default.
- Palette ID: default.
- Morph values: defaults from the selected body preset.
- Generated SpriteFrames path: empty until the recipe is baked or linked to an imported sheet.

Character recipe data:

- Body type and part slot selections.
- Palette and per-material color selections.
- Morph values for height, width, head size, limb proportions, posture, equipment scale, and other safe rig parameters.
- Content pack IDs and part source IDs for migration and fallback.
- Export profile ID and checklist set used to bake gameplay sheets.

## Opening Variants

Opening variants are structural only in this spec.

Ronin variant:

- Focus: personal duty, discipline, blade memory.
- Room start: same as other starters.
- Gameplay difference: no route difference for milestone one.

Arc-Gunner variant:

- Focus: tactical framing, strange energy detection, modern-world contrast.
- Room start: same as other starters.
- Gameplay difference: ranged tutorial hint can be starter-specific.

Iron Knight variant:

- Focus: survival, protection, armor oath, cursed defense.
- Room start: same as other starters.
- Gameplay difference: guard or heavy-attack hint can be starter-specific.

No final dialogue should be written here.

## UI States

Starter select states:

- Focused.
- Selected.
- Disabled.
- Confirming.

Name input states:

- Empty.
- Valid.
- Too long.
- Invalid characters.
- Save write pending.
- Save write failed.

Confirmation states:

- Ready.
- Overwrite warning.
- Save pending.
- Save failed.

## Tests

Automated tests:

- Starter select lists exactly three selectable starters.
- Witch is not selectable.
- Secret characters are not selectable.
- Starter IDs are saved, not display strings.
- Empty name is rejected.
- Overlong name is rejected or clamped by rule.
- Invalid control characters are rejected.
- Default name can be accepted.
- Confirmation writes initial party state.
- Confirmation writes current room and checkpoint.
- Confirmation persists character appearance recipe data.
- In-game creator preview exposes accessibility, performance, compatibility, and
  equipment socket readiness for the active recipe.
- Generated or linked CharacterCreator2D `SpriteFrames` can be assigned to the spawned player.
- Recipe migration preserves old saves when part IDs or content-pack versions change.
- Back navigation preserves selected starter and name where expected.
- Controller confirm/back actions work in every screen.

Manual tests:

- Create Ronin save.
- Create Arc-Gunner save.
- Create Iron Knight save.
- Cancel from every screen.
- Overwrite occupied slot.
- Use keyboard-only name entry.
- Use controller-only name entry.
- Verify Continue loads the created character.

## Locked Decisions

- Three starter options only.
- Witch is recruited later and named during recruitment.
- The player's chosen name and fixed title are separate fields.
- Character creation leads into Modern City Outskirts.
- Starter selection uses stable IDs.

## Open Questions

- Should dash and double jump be baseline from the opening or tutorial unlocks?
- Should starter cards show difficulty labels or avoid difficulty framing?
- Does each starter get a unique first tutorial prompt in room one?
- Which exact sprite preview resource is used for each starter after import
  tests?
- Which morph controls ship in the in-game creator versus the separate Character Studio app?
- Which recipe fields are allowed to affect gameplay silhouettes before collision validation?

## Implementation Notes

- Keep title/name formatting centralized.
- Use data resources for starter cards.
- Do not hardcode display names into save logic.
- Make confirmation screen controller-first.
- Do not create a blank save before confirmation succeeds.
- Keep Unity out of the production pipeline. CharacterCreator2D source data is reference/input only; the creator, preview rig, morphing, and sheet baker must run in Godot.
