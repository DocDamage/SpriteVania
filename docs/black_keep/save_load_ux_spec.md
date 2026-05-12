# Save And Load UX Spec

This spec defines the save, continue, load slot, settings, and migration plan
needed for the first Black Keep milestone.

## Goals

- Continue works from the title screen.
- Load Game opens a real save-slot screen.
- Settings can persist before any game save exists.
- Save data can preserve party, familiar, room, and progression state.
- Older saves either migrate cleanly or fail with a clear message.
- Save slots show enough information for players to choose confidently.

## Save Slot Count

First-pass target:

- Three manual slots.
- One autosave slot.
- One backup recovery slot.

The UI may start with three manual slots only if autosave is not implemented
yet, but the data model should leave room for autosave.

## Title Menu Behavior

Continue:

- Loads the most recently played valid save.
- Disabled or dimmed when no valid save exists.
- Shows a short error if the most recent save is corrupted.

New Game:

- Opens character creation.
- Warns before overwriting a selected occupied slot.
- Binds overwrite confirmation to the current starter/name payload, so changing
  character details requires a fresh warning.
- Can create a save only after starter selection and name confirmation.

Load Game:

- Opens save-slot screen.
- Shows occupied and empty slots.
- Allows loading, deleting, and copying later.

Settings:

- Opens global settings.
- Does not require save data.

Accessibility:

- Opens Settings directly to Accessibility tab.
- If first-time accessibility prompt exists, it can also route here.

## Save Slot Card

Each occupied slot should show:

- Player starter title and player-given name.
- Active party names and titles.
- Current zone.
- Current room display name.
- Level summary.
- Familiar level and evolution.
- Play time.
- Completion percentage placeholder.
- Last saved date and time.
- Difficulty or combo timing preset.
- Thumbnail placeholder or current room icon.

Each empty slot should show:

- Empty state label.
- New Game action.
- Optional import or copy action later.

Corrupted or incompatible slot:

- Show slot number.
- Show problem summary.
- Allow delete.
- Do not crash the title screen.

## Save Data Fields

Top-level fields:

- Save version.
- Created timestamp.
- Last saved timestamp.
- Play time seconds.
- Current scene ID.
- Current room ID.
- Spawn marker ID.
- Player position.
- Current checkpoint ID.
- Current difficulty.
- Settings overrides, if save-specific.

Player fields:

- Starter character ID.
- Current visible character ID.
- Active party IDs.
- Unlocked character IDs.
- Character runtime states.
- Party order.
- Pair affinity map.

Progression fields:

- Recruited Witch flag.
- Recruited Shadow flag.
- Defeated boss flags.
- Unlocked traversal seals.
- Opened shortcuts.
- Collected upgrades.
- Discovered rooms.
- Completed quests.
- Current route flags.

Familiar fields:

- Familiar unlocked flag.
- Familiar name, if supported.
- Familiar level.
- Familiar XP.
- Familiar evolution ID.
- Familiar unlocked abilities.
- Familiar equipped abilities.
- Familiar upgrade levels.

Combat and movement fields:

- Learned attack skills.
- Learned movement abilities.
- Current HP per character.
- Current resource per character.
- Momentum per character, if carried between rooms.
- KO state, if persisted.

## Global Settings File

Global settings path:

- `user://black_keep_settings.json`

Global settings should include:

- Audio volume.
- Display mode.
- Resolution or scaling.
- VSync.
- Screen shake.
- Particle amount.
- Reduced motion.
- Flash intensity.
- Colorblind mode.
- Font scale.
- Subtitles.
- Dialogue log preference.
- Controller glyph style.
- Input bindings.
- Dead zones.
- Language.

Save-specific settings should include:

- Combat timing preset.
- Difficulty.
- Auto-swap on KO.
- Enemy HP bars.
- Damage numbers.
- Minimap display mode.

## Save Migration

Migration rules:

- Every save must declare a version.
- Unversioned saves should be treated as legacy SpriteVania saves.
- Legacy saves should migrate only fields that are clearly compatible.
- Missing new fields should receive safe defaults.
- Failed migration should not delete the old save.
- Migration should write a backup before overwriting.

First migration target:

- Convert current class-based player selection into starter character ID.
- Convert current XP and level into starter runtime state.
- Convert current room/checkpoint into milestone scene IDs where possible.
- Set locked party roster defaults.
- Initialize familiar data if old save has familiar progression.
- Initialize CharacterCreator2D recipe fields, morph values, content-pack versions, and generated `SpriteFrames` paths with safe defaults if absent.

## Save Timing

Autosave candidates:

- After character creation confirmation.
- After character recipe confirmation or successful character sheet bake.
- After reaching a checkpoint.
- After Witch recruitment.
- After Shadow recruitment.
- After boss defeat.
- After Rising Torii Seal pickup.
- On hub save shrine interaction.

Manual save:

- Allowed at save shrines.
- Later may be allowed at hub inns.

Do not autosave:

- During boss active combat.
- During death transition.
- During room transition before destination confirms loaded.
- In the middle of name input.

## Robustness Requirements

Save writing:

- Write to temporary file first.
- Validate serialized data.
- Replace target save after successful write.
- Keep previous save as backup where practical.

Save loading:

- Validate JSON parse.
- Validate version.
- Validate required fields.
- Validate scene and room IDs.
- Fallback to checkpoint marker if player position is invalid.
- Fallback to title error instead of crashing.

Settings loading:

- Invalid setting values clamp to allowed ranges.
- Missing settings use defaults.
- Input binding conflicts show a warning.

## Tests

Automated tests:

- Continue disabled with no saves.
- Continue loads most recent save.
- Load Game lists occupied and empty slots.
- Corrupted save does not crash slot screen.
- Save write uses version field.
- Legacy save migrates expected fields.
- Missing fields receive defaults.
- Familiar state serializes and deserializes.
- Party roster serializes and deserializes.
- Unlocked seals serialize and deserialize.
- Settings save without creating game save.
- Accessibility button opens settings accessibility tab.

Manual tests:

- Create new save in slot 1.
- Create new save in slot 2.
- Continue loads latest slot.
- Load older slot manually.
- Delete a slot.
- Change settings before New Game and verify persistence.
- Save after Witch recruitment and reload.
- Save after Shadow recruitment and reload.
- Save after Masakiro defeat and reload.
