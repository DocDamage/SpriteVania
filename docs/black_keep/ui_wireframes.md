# UI Wireframes

This document defines functional wireframes for the first milestone UI. It is
not a final visual design document.

## UI Rules

- Controller navigation must work on every screen.
- Keyboard and mouse must work on every screen.
- Text must fit at large font scale.
- Selection state cannot rely on color alone.
- Back/cancel must be available on every modal screen.
- Placeholder screens must be safe and explicit.

## Title Screen

Layout:

- Full-screen title background.
- Dark left-side panel or gradient.
- Title at upper-left: `THE BLACK KEEP`.
- Version/build label at lower-left or lower-right.
- Vertical menu stack under title.

Menu order:

1. Continue.
2. New Game.
3. Load Game.
4. Settings.
5. Accessibility.
6. Extras.
7. Credits.
8. Quit.

States:

- Continue enabled.
- Continue disabled.
- Button focused.
- Button pressed.
- Button unavailable.

Acceptance:

- Reduced motion lowers animated title effects.
- Menu remains readable over background.

## Save Slot Screen

Layout:

- Header: Load Game.
- Three large save-slot cards.
- Optional autosave card later.
- Bottom action bar with Load, Options, Delete, Back.

Occupied card content:

- Slot number.
- Character name and fixed title.
- Active party summary.
- Current zone.
- Current room.
- Play time.
- Last saved timestamp.
- Difficulty or combo timing.
- Familiar level.

Empty card content:

- Slot number.
- Empty label.
- New Game action hint.

Damaged card content:

- Slot number.
- Damaged save label.
- Delete action hint.

Acceptance:

- Corrupted saves do not crash the screen.
- Controller focus order is predictable.

## Character Creation

Starter select layout:

- Header: Choose Your First Seal-Bearer.
- Three horizontal or vertical cards.
- Details panel for focused card.
- Confirm and Back hints.

Starter card content:

- Sprite preview.
- Fixed title.
- Role tagline.
- Combat identity.
- Traversal identity.

Name input layout:

- Header: Name Your Character.
- Fixed title display.
- Text input field.
- On-screen keyboard for controller.
- Confirm, Default, and Back actions.

Confirmation layout:

- Sprite preview.
- Player-given name.
- Fixed title.
- Starting role summary.
- Start Game button.
- Back button.

Acceptance:

- Witch and Shadow are never shown as starter choices.
- Name validation errors are readable.

## Settings Menu

Layout:

- Left or top tab list.
- Main settings panel.
- Description footer for focused setting.
- Reset Defaults action.
- Back action.

Tabs:

- Gameplay.
- Combat.
- Controls.
- Display.
- Audio.
- Interface.
- Accessibility.
- Language and Text.
- Save and Data.

Control types:

- Toggle for binary settings.
- Slider for numeric values.
- Stepper for preset values.
- Remap row for input bindings.
- Confirmation modal for destructive actions.

Acceptance:

- Accessibility tab can be opened directly from title.
- Settings persist globally where appropriate.

## Party HUD

Layout:

- Current character panel near top-left or bottom-left.
- Three active party slots.
- HP bar per active member.
- Resource bar per active member.
- Momentum ring per active member.
- Familiar indicator near party or resource area.

Slot states:

- Current visible character.
- Ready to swap.
- Insufficient Momentum.
- Tag cooldown.
- KO.
- Empty locked slot.

Acceptance:

- Current character is obvious.
- KO state is visible.
- Momentum state is readable without relying only on color.

## Combat Feedback

Elements:

- Combo counter.
- Hit sparks.
- Damage numbers, optional.
- Enemy HP bars, optional.
- Attack prompt in tutorial.
- Swap prompt in tag tutorial.

Acceptance:

- First enemy room clearly teaches attack.
- Combat feedback obeys reduced motion and flash settings.

## Party Shrine UI

Layout:

- Header: Party Shrine.
- Active party list.
- Character detail panel.
- Reorder controls.
- Rename action.
- Back action.

Milestone behavior:

- Shows up to three active characters.
- Locked future slots can be visible as placeholders.
- Reorder may be disabled until more than three recruits exist.

Acceptance:

- Canceling does not corrupt party state.

## Save Shrine UI

Layout:

- Shrine interaction prompt.
- Save confirmation modal.
- Last saved feedback.
- Optional heal feedback.

Acceptance:

- Save can be repeated.
- Save failure shows an error without closing into broken state.

## Extras Screen

Layout:

- Grid or list of extras.
- Locked state.
- Back action.

Initial milestone:

- Can show locked placeholders.

Acceptance:

- Opens and exits safely.

## Credits Screen

Layout:

- Scrollable credits list.
- Category headers.
- Back action.

Acceptance:

- Controller can scroll.
- Back exits immediately.
- Content comes from real credits/license data.
