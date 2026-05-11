# Menu and Settings Plan

This document tracks the Black Keep title/menu/settings direction. The current implementation already has a functional title flow and a tabbed settings menu, but the final game needs a stronger production UI pass and global settings storage.

## Title Screen

Use the castle/cherry-blossom pixel-art title image as the production identity.

Current title-screen state:

- Game title: `THE BLACK KEEP`.
- Menu stack: Continue, New Game, Load Game, Settings, Accessibility, Extras, Credits, Quit.
- Visual layers: background image, Moon Sky overlay, weather layer, polish layer, vignette, dark left gradient, build/version label.
- Motion options: title parallax, stars, rain, fog, petals.
- Reduced motion disables or reduces parallax, weather, and polish layers.

## Main Menu Routing

Expected menu behavior:

- Continue loads the default save.
- New Game opens character creation.
- Load Game opens the save-slot screen.
- Settings opens the settings menu.
- Accessibility opens the Accessibility tab inside Settings.
- Extras opens a real Extras screen.
- Credits opens a real Credits screen.
- Quit exits the game.

## Load Game Screen

Production save-slot cards should show:

- Slot label.
- Chapter/progress label.
- Current zone or hub.
- Active starter title and player-given name.
- Party icons once party data exists.
- Play time.
- Last saved timestamp.
- Difficulty/combo timing preset.
- Completion percentage or discovered-room count.
- Empty-slot state.
- Delete/copy/backup actions, gated behind confirmation.

Controller behavior:

- D-pad/left stick moves between cards.
- Confirm loads.
- Secondary action opens slot options.
- Back returns to title.

## Current Settings Tabs

- General
- Audio
- Video
- Gameplay
- Controls
- Accessibility

## Future Expanded Settings Tabs

- Gameplay
- Combat
- Controls
- Display
- Audio
- Interface
- Accessibility
- Language/Text
- Save & Data

## Current Persistence

Current settings are saved into existing save data and must not create a blank save. Runtime settings already include audio, display, reduced motion, high contrast, large text, colorblind mode, screen shake, and text speed.

## Global Settings File Plan

Future work should split settings into:

- Global settings file: `user://black_keep_settings.json`
- Save-specific settings inside save files.

This allows settings to persist before any save exists.

Global settings candidates:

- Master/music/SFX volume.
- Fullscreen/window mode.
- VSync.
- Resolution/display scale.
- Input bindings.
- Controller glyph style.
- Colorblind mode.
- Font scale / large text.
- Screen shake.
- Particle intensity.
- Subtitles.
- Dialogue log setting.
- Minimap display preferences.

Save-specific settings candidates:

- Combo timing preset.
- Difficulty.
- Auto-swap on KO.
- Enemy HP bars.
- Damage numbers.
- Character/party-specific tutorial completion.

## Combat Settings To Add

- Combo Timing: Story, Normal, Technical, Expert.
- Momentum refill feedback.
- Tag attack camera intensity.
- Auto-swap on KO.
- Damage numbers.
- Enemy HP bars.
- Hit pause slider.
- Aim assist.
- Swap input style.

## Interface and Language/Text Settings

Interface settings to add:

- HUD scale.
- Minimap size.
- Minimap rotation/fixed orientation.
- Objective tracker visibility.
- Damage number visibility.
- Enemy HP bar visibility.
- Controller glyph theme.

Language/Text settings to add:

- Subtitle toggle.
- Subtitle size.
- Dialogue text speed.
- Dialogue auto-advance.
- Dialogue log access.
- Speaker name display.
- Dyslexia-friendly font option, if a suitable font is approved.

## Accessibility Prompt

First launch should offer an optional accessibility prompt before the title menu or on first Settings open.

Prompt options:

- Large text.
- Reduced motion.
- High contrast.
- Screen shake off.
- Subtitles on.
- Colorblind mode shortcut.
- Remap controls shortcut.

The prompt should be skippable and available again from Accessibility settings.

## Credits Screen Content

Credits should include:

- Project title and team credits.
- Asset pack credits.
- Engine and tool credits.
- Plugin/library credits.
- Special thanks.
- License notes where required.

Do not invent final names or licenses; populate from actual project sources during production.

## Extras Unlock Rules

Potential Extras:

- Bestiary.
- Music player.
- Concept art/gallery.
- Boss rematch.
- Time trial rooms.
- Completed ending viewer.
- Character profiles.
- Lore archive.

Unlock sources:

- Story progression.
- Boss defeats.
- Character quests.
- Secret character recruitment.
- Endings.
- Optional seal completion.

## Remaining Work

- Finalize Load Game screen design and save-slot metadata.
- Add real Extras and Credits screens.
- Move long-term settings persistence into a global settings file.
- Add combat-specific settings once Momentum and tag-swapping exist.
- Add final UI art, fonts, audio feedback, and controller-focused navigation polish.
- Define global/save-specific settings migration path.
- Add first-time accessibility prompt.
- Add Save & Data tab for deleting saves, exporting backups, and viewing save metadata.
