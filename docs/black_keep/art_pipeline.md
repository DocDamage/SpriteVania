# Art Pipeline

The Black Keep can use assets with strong area identities, but all production
assets must feel like one coherent game.

## Goals

- Preserve source assets.
- Normalize mixed asset packs into one readable game style.
- Get prototype assets into Godot quickly without pretending they are final.
- Keep pixel-art import settings consistent.
- Make every gameplay-critical sprite readable in motion.
- Track cleanup needs instead of burying them in code.

## Source Asset Rules

- Never overwrite source asset files.
- Derived and cleaned assets should live in a clearly named project folder.
- Every derived asset should record its source path.
- Sprite slicing should be repeatable.
- Temporary prototype art should be labeled as prototype.
- Final art should not depend on undocumented manual edits.

Recommended derived folders:

- `assets/black_keep/characters/`
- `assets/black_keep/enemies/`
- `assets/black_keep/bosses/`
- `assets/black_keep/tilesets/`
- `assets/black_keep/parallax/`
- `assets/black_keep/vfx/`
- `assets/black_keep/ui/`

If the project already has a stronger convention, use that convention instead.

## Import Settings

Pixel-art-safe import settings:

- Filter off.
- Mipmaps off.
- Lossless compression.
- Repeat disabled unless a tile or parallax layer requires it.
- Nearest-neighbor scaling.
- No unintended texture smoothing.

Validation:

- Open in Godot and verify `.import` settings.
- Confirm sprites remain sharp at game scale.
- Confirm parallax layers do not shimmer badly during camera movement.
- Confirm UI icons remain readable after scale changes.

## Style Normalization

Normalize:

- Palette.
- Outlines.
- Scale.
- Brightness.
- Contrast.
- Animation timing.
- Collision readability.
- UI readability.

Do not over-normalize:

- Each world fragment should keep a recognizable identity.
- Feudal Japan, Gothic, swamp, modern, and final-dungeon spaces should feel
  distinct.
- Normalization should make them compatible, not identical.

## Scale Targets

Playable characters:

- Prototype target: current player collision size.
- Visual target: readable at normal gameplay zoom.
- Avoid large sprite differences that make hitboxes feel unfair.

Enemies:

- Small enemies should be clearly below player height.
- Standard enemies should be close to player height.
- Brutes and bosses can exceed player height if attack readability remains
  clear.

Tiles:

- Collision should match visible solid surfaces.
- Decorative foreground should not hide enemy attacks.
- Slopes and ledges should be visually clear.

## Playable Sprite Requirements

Playable candidates are chosen by animation completeness first.

Required target animations:

- Idle.
- Run.
- Jump.
- Fall.
- Attack.
- Hurt.
- Death.
- Special.
- Dash.
- Slide.

Optional but valuable:

- Wall hang.
- Wall slide.
- Dive bomb.
- Guard.
- Tag entry.
- Victory or recruit pose.

Sprites missing dash, slide, or special animations can still qualify if the
missing animations can be faked with VFX, existing frames, or generated frames
that are later cleaned in Aseprite.

## Character Pipeline

1. Select candidate sprite.
2. Record source path.
3. Check animation completeness.
4. Identify missing required actions.
5. Slice sheets into repeatable frame outputs.
6. Normalize palette, outline, scale, brightness, and contrast.
7. Build `SpriteFrames` or equivalent Godot animation resource.
8. Attach prototype collision, hurtbox, and hitbox data.
9. Test in import-test scene.
10. Test in movement room.
11. Test in combat room.
12. Record final pass, prototype pass, defer, or reject decision.

## Enemy Pipeline

1. Select enemy archetype.
2. Record source path.
3. Confirm idle, move, attack, hurt, and death coverage.
4. Slice or map animation frames.
5. Assign collision and hurtbox.
6. Assign attack hitbox or projectile origin.
7. Test patrol path.
8. Test player damage.
9. Test enemy death and respawn.
10. Record XP value and drop-table placeholder.

## Tile And Terrain Pipeline

1. Select zone and source tile folders.
2. Build one representative test room.
3. Assign tile collision.
4. Add one-way platforms only where visually clear.
5. Add foreground and background decoration.
6. Test player movement, dash, wall jump, and camera.
7. Check screen fill at target resolutions.
8. Record missing tile needs.

## Parallax Pipeline

Minimum layers:

- Far sky or horizon.
- Distant silhouettes.
- Midground architecture, trees, or ruins.
- Gameplay layer.
- Foreground atmosphere.
- Weather or particles.
- World Break overlay variant.

Priority zones:

- Title screen.
- Swamp.
- Castle Gate.
- Samurai Castle Wing.
- Cherry Blossom Courts.
- Graveyard.
- Church.
- Final Tower.
- Monster Belly.
- Core.

Requirements:

- Parallax fills all target viewports.
- Layers do not reveal seams during camera movement.
- Reduced-motion settings can reduce animated layers.
- Gameplay silhouettes remain readable in front of parallax.

## VFX Pipeline

Required first-pass VFX:

- Hit spark.
- Enemy hit flash.
- Dash trail.
- Double-jump burst.
- Wall slide dust.
- Slide attack slash.
- Dive-bomb impact.
- Ashen Hexburst.
- Silent Arrowfall.
- Projectile muzzle flash.
- Save shrine activation.
- Rising Torii Seal pickup.

Rules:

- VFX should be readable before they are flashy.
- Hit feedback should not hide enemy windups.
- Reduced motion and flash intensity settings must affect high-intensity VFX.
- Prototype VFX can be simple if timing is clear.

## UI Art Pipeline

Required UI surfaces:

- Title menu.
- Character creation.
- Save-slot cards.
- Settings tabs.
- Party HUD.
- Momentum rings.
- Familiar HUD indicator.
- Controller glyphs.
- Dialogue or interaction prompts.

Rules:

- Text must fit at supported font scales.
- Selection state cannot rely on color alone.
- Controller and keyboard prompts must share the same action source.
- Placeholder UI should be clean and readable.

## Acceptance Gates

Prototype pass:

- Asset imports without smoothing.
- Correct animation plays in Godot.
- Scale is close enough for gameplay tests.
- Collision and hitboxes can be assigned.
- Known art issues are documented.

Production pass:

- Palette and scale match surrounding assets.
- Missing critical animations are filled or convincingly faked.
- Motion is readable.
- Collision matches visual form.
- Reduced-motion and accessibility settings remain readable.

Reject:

- Animation coverage is too thin for the role.
- Scale cleanup is too costly.
- Silhouette does not read in gameplay.
- Asset clashes too strongly with the game style.
- Licensing or source uncertainty blocks use.

## Tests

Automated checks:

- Required derived assets exist.
- Required animations are present in character resources.
- TileSet resources load.
- Parallax resources load.
- VFX resources load.

Manual checks:

- Contact sheet review.
- Import-test scene review.
- Movement room review.
- Combat room review.
- Screen-fill review.
- Reduced-motion review.

## Open Questions

- Final derived asset folder convention.
- Whether Aseprite cleanup is required before or after first Godot import.
- Which final fonts are approved for UI.
- Which title and menu UI elements need custom art.
- How much generated or edited art is acceptable for missing animation frames.
