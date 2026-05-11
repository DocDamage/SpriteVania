# Credits And License Audit

This document defines the credits and license audit needed before any public
release or broad distribution.

## Goals

- Track every third-party asset source.
- Prevent unknown-license assets from entering release builds.
- Prepare accurate credits screen content.
- Keep prototype-only assets clearly separated from release-ready assets.

## Audit Fields

Each source pack or external asset should record:

- Source path.
- Asset pack name.
- Creator or vendor.
- Source URL, if known.
- License type.
- License file path.
- Required credit text.
- Commercial-use status.
- Modification permission.
- Redistribution restrictions.
- Used in game.
- Prototype only.
- Replacement needed.

## Asset Groups To Audit

Sprite and character assets:

- Player sprites.
- CraftPix characters.
- Enemies.
- Bosses.
- NPCs.
- Familiar art.

Environment assets:

- Tile sets.
- Backgrounds.
- Parallax layers.
- Final tower assets.
- Monster Belly assets.
- Core textures and effects.

UI assets:

- Fonts.
- Icons.
- Controller glyphs.
- GUI frames.
- Title image.

Audio assets:

- Music.
- Ambience.
- SFX.
- UI sounds.

Tools and libraries:

- Godot engine.
- Plugins.
- Scripts.
- External processing tools.
- Any third-party code libraries.

## Release Rules

Rules:

- Unknown license means not release-ready.
- Prototype-only assets can be used in local development but must be marked.
- Credits must match actual asset usage.
- Modified assets should still credit original source if required.
- Font licenses must be checked before shipping.
- Audio licenses must be checked before shipping.

## Credits Screen Sections

Recommended sections:

- Project.
- Development.
- Art assets.
- Audio assets.
- Fonts.
- Engine and tools.
- Plugins and libraries.
- Special thanks.
- License notices.

## Audit Workflow

1. List all used asset source paths.
2. Group paths by source pack.
3. Locate license files or vendor pages.
4. Record required credit text.
5. Mark commercial-use status.
6. Mark modification permission.
7. Mark prototype-only or release-ready.
8. Add credits-screen entry.
9. Block release if any used asset has unknown status.

## First Milestone Audit Targets

Required first:

- Title screen image.
- Ronin prototype.
- Arc-Gunner prototype.
- Iron Knight prototype.
- Witch prototype.
- Shadow prototype.
- Standard enemy prototype.
- Cursed samurai prototype.
- Oni brute prototype.
- Masakiro prototype.
- Swamp tiles and trees.
- Castle Gate tiles.
- Samurai Castle tiles.
- Sakuramori Court tiles.
- VFX placeholders.
- Fonts used in title/menu/settings.
- Audio placeholders, if added.

## Open Questions

- Which asset packs already include license files in the repo?
- Which assets came from user uploads versus third-party packs?
- Which generated or edited assets need separate attribution notes?
- Should credits be profile-wide static content or loaded from data?
