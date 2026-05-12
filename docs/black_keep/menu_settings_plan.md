# Menu And Settings Plan

This document tracks the Black Keep title, menu, settings, load-game, credits,
extras, and accessibility direction. The current implementation already has a
functional title flow and a tabbed settings menu, but the final game needs a
stronger production UI pass and global settings storage.

## Goals

- Make Continue, New Game, Load Game, Settings, Accessibility, Extras, Credits,
  and Quit behave predictably.
- Keep settings available before any save exists.
- Support controller-first navigation.
- Separate global settings from save-specific settings.
- Make accessibility reachable before gameplay starts.
- Keep placeholder screens safe and clear until final content exists.

## Title Screen

Current title-screen state:

- Game title: `THE BLACK KEEP`.
- Menu stack: Continue, New Game, Load Game, Settings, Accessibility, Extras,
  Credits, Quit.
- Visual layers: background image, Moon Sky overlay, weather layer, polish
  layer, vignette, dark left gradient, build/version label.
- Motion options: title parallax, stars, rain, fog, petals.
- Reduced motion disables or reduces parallax, weather, and polish layers.

Production requirements:

- Continue is disabled or visually dimmed when no valid save exists.
- Load Game opens save slots.
- Accessibility opens Settings on the Accessibility tab.
- Extras and Credits open real screens or safe placeholder screens.
- Quit asks for confirmation on platforms where accidental quit is likely.

## Main Menu Routing

Continue:

- Load most recent valid save.
- If latest save is invalid, show load error and offer Load Game.

New Game:

- Open character creation.
- If save slots exist, ask for slot selection before final confirmation.

Load Game:

- Open save-slot screen.
- Never silently behave like Continue in production.

Settings:

- Open settings at last selected tab or General.

Accessibility:

- Open settings directly to Accessibility.

Extras:

- Open Extras screen.
- Show locked content if no unlocks exist.

Credits:

- Open Credits screen.
- Credits content must come from real project sources.

Quit:

- Exit game or return to platform shell.

## Save Slot Screen

Save slot card fields:

- Slot label.
- Current chapter or progress label.
- Current zone or hub.
- Active starter title and player-given name.
- Active party names or icons.
- Familiar level and evolution.
- Play time.
- Last saved timestamp.
- Difficulty or combo timing preset.
- Completion percentage or discovered-room count.
- Thumbnail, room icon, or placeholder image.

Actions:

- Load.
- Start New Game in empty slot.
- Delete.
- Copy, later.
- Backup/export, later.

Controller behavior:

- D-pad or left stick moves between cards.
- Confirm loads or selects.
- Secondary action opens slot options.
- Back returns to title.
- Delete requires hold or confirmation.

Corrupt slot behavior:

- Show slot as damaged.
- Allow delete.
- Do not crash title screen.
- Do not offer Continue into the damaged slot.

## Settings Tabs

Current tabs:

- General.
- Audio.
- Video.
- Gameplay.
- Controls.
- Accessibility.

Final target tabs:

- Gameplay.
- Combat.
- Controls.
- Display.
- Audio.
- Interface.
- Accessibility.
- Language and Text.
- Save and Data.

## Global Settings

Global settings file:

- `user://black_keep_settings.json`

Global settings should include:

- Master volume.
- Music volume.
- SFX volume.
- Fullscreen or window mode.
- VSync.
- Resolution or display scale.
- Input bindings.
- Controller glyph style.
- Stick dead zones.
- Colorblind mode.
- Font scale.
- Large text.
- Screen shake.
- Particle intensity.
- Reduced motion.
- Flash intensity.
- Subtitles.
- Dialogue log setting.
- Language.
- Minimap display preference.

Global settings rules:

- Can be saved without game save data.
- Missing values use defaults.
- Invalid values clamp to valid ranges.
- Input conflicts show warnings.
- Settings writes should use a temp file then replace.

## Save-Specific Settings

Save-specific settings include:

- Difficulty.
- Combo timing preset.
- Auto-swap on KO.
- Enemy HP bars.
- Damage numbers.
- Character tutorial completion.
- Party-specific accessibility overrides, if ever needed.
- Controller glyph style is global and currently supports Generic, Xbox,
  PlayStation, and Switch text-label prompts before final glyph art.

Rules:

- Save-specific settings travel with the save file.
- Global settings still affect presentation.
- Save-specific settings should not create a save before New Game confirmation.

## Combat Settings

Required:

- Combo Timing: Story, Normal, Technical, Expert.
- Momentum refill feedback.
- Tag attack camera intensity.
- Auto-swap on KO.
- Damage numbers.
- Enemy HP bars.
- Hit pause slider.
- Aim assist.
- Swap input style.

Swap input styles:

- Cycle left/right.
- Direct slot buttons.
- Hold radial, later if needed.

## Interface Settings

Interface settings:

- HUD scale.
- Minimap size.
- Minimap fixed or rotating orientation.
- Objective tracker visibility.
- Damage number visibility.
- Enemy HP bar visibility.
- Controller glyph theme.
- Interaction prompt size.
- Familiar HUD visibility.
- Party KO state visibility.

## Language And Text Settings

Language and text settings:

- Language.
- Subtitle toggle.
- Subtitle size.
- Dialogue text speed.
- Dialogue auto-advance.
- Dialogue log access.
- Speaker name display.
- Font scale.
- Dyslexia-friendly font option, if a suitable font is approved.

## Accessibility Settings

Accessibility settings:

- Large text.
- High contrast.
- Reduced motion.
- Screen shake amount.
- Flash intensity.
- Particle amount.
- Colorblind mode.
- Hold/toggle options for repeated inputs.
- Controller remapping.
- Aim assist.
- Combat timing preset shortcut.
- Subtitle defaults.

First launch prompt:

- Offer large text.
- Offer reduced motion.
- Offer high contrast.
- Offer screen shake off.
- Offer subtitles on.
- Offer colorblind mode shortcut.
- Offer remap controls shortcut.

The prompt must be skippable and available again from Accessibility settings.

## Extras Screen

Potential extras:

- Bestiary.
- Music player.
- Concept art or gallery.
- Boss rematch.
- Time trial rooms.
- Ending viewer.
- Character profiles.
- Lore archive.

Unlock sources:

- Story progression.
- Boss defeats.
- Character quests.
- Secret character recruitment.
- Endings.
- Optional seal completion.

Rules:

- Locked extras should show a clean locked state.
- Unlock text should avoid spoilers unless already discovered.
- Extras should not modify game saves except for explicit settings or records.

## Credits Screen

Credits should include:

- Project title.
- Team credits.
- Asset pack credits.
- Engine and tool credits.
- Plugin or library credits.
- Special thanks.
- License notes where required.

Rules:

- Do not invent final names or licenses.
- Populate from actual project sources during production.
- Credits should be scrollable by keyboard, mouse, and controller.
- Credits should allow back/cancel at any time.

## Save And Data Tab

Future Save and Data tab:

- View save metadata.
- Delete save slots.
- Export backup.
- Restore backup.
- Reset settings.
- Reset input bindings.
- Clear extras unlocks, if supported.

Safety:

- Destructive actions require confirmation.
- Delete actions should not be available from accidental focus state.
- Backup and restore failures should show clear errors.

## Tests

Automated tests:

- Continue disabled with no valid save.
- Continue loads most recent valid save.
- Load Game opens slot screen.
- Accessibility opens Accessibility tab.
- Settings save globally without game save.
- Invalid setting values clamp.
- Input conflicts are detected.
- Corrupt save slot does not crash.
- Extras screen opens.
- Credits screen opens.

Manual tests:

- Keyboard title navigation.
- Controller title navigation.
- Mouse title navigation.
- Create and load save slot.
- Delete save slot with confirmation.
- Change settings before New Game and verify persistence.
- Use first-launch accessibility prompt.
- Open and exit Extras and Credits.

## Locked Decisions

- Load Game should become a real save-slot screen.
- Accessibility routes to Settings Accessibility tab.
- Settings must split global and save-specific data.
- Reduced motion affects title screen and gameplay VFX.

## Open Questions

- Exact visual design of save-slot cards.
- Whether New Game asks for slot before or after character creation.
- Which controller glyph set ships first.
- Which final font supports accessibility best.
- Whether Extras unlocks are profile-wide or save-specific.
