# Art Pipeline

The Black Keep can use assets with strong area identities, but all production assets must feel like one coherent game.

## Style Normalization

Normalize:

- Palette.
- Outlines.
- Scale.
- Brightness.
- Contrast.
- Animation timing.
- UI readability.

Higher-resolution painted sprites are acceptable as source material only if they are later pixel-cleaned in Aseprite.

## Playable Sprite Requirements

Playable candidates are chosen by animation completeness first.

Required target animations:

```text
idle
run
jump
fall
attack
hurt
death
special
dash
slide
```

Sprites missing dash, slide, or special animations can still qualify if the missing animations can be faked with VFX/existing frames or generated and cleaned in Aseprite.

## Sprite Pipeline

```text
Candidate sprite selected
-> Check animation completeness
-> Generate missing dash/slide/special/costume frames if needed
-> Clean frame shapes in Aseprite
-> Normalize palette, outline, scale, brightness, contrast
-> Export sprite sheet
-> Import into Godot SpriteFrames
-> Test in motion
```

## Parallax Direction

Parallax should be used in every major area.

Minimum layers:

- Far sky/horizon.
- Distant silhouettes.
- Midground architecture/trees/ruins.
- Gameplay layer.
- Foreground atmosphere.
- Weather/particles.
- World Break overlay variant.

Priority parallax zones:

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

All hubs should support day/night and weather variants.

