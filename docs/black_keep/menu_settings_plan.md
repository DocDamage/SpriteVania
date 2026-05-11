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

## Remaining Work

- Finalize Load Game screen design and save-slot metadata.
- Add real Extras and Credits screens.
- Move long-term settings persistence into a global settings file.
- Add combat-specific settings once Momentum and tag-swapping exist.
- Add final UI art, fonts, audio feedback, and controller-focused navigation polish.

