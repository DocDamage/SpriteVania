# Godot CharacterCreator2D Tool Roadmap

## Goal

Build a complete Godot-native CharacterCreator2D port as both:

- an in-game SpriteVania character creator, and
- a separate Godot Character Studio app for production authoring and batch export.

Unity is not part of the production pipeline. The Unity package is source/reference data only.

## Core Architecture

- Source data: imported CC2D sprites, metadata, animation lists, palettes, and reference scripts.
- Source of truth: character recipes plus a Godot-native layered rig.
- Build artifact: baked PNG sequences, sprite sheets, and Godot `SpriteFrames`.
- Runtime game use: lightweight baked frames by default, optional layered rig for previews and special runtime customization screens.

## Required Creator Features

- Full part browser with search, filtering, categories, tags, favorites, and compatibility warnings.
- Full color and palette editing for skin, hair, cloth, leather, metal, eyes, effects, overlays, scars, tattoos, and faction palettes.
- Character recipe save/load with schema versioning.
- Randomizer with lockable slots and tag-aware generation.
- Outfit/loadout sets for combat, town, damaged, upgraded, faction, and NPC variants.
- Live animation preview with scrubber, playback speed, flip, frame stepping, and in-game scale preview.
- Checklist-driven bulk export for any combination of animations.
- Custom export sets plus built-in sets like `first_slice_player`, `movement`, `combat`, `all_base`, and `all_aim`.
- Direct generation of Godot `SpriteFrames`, import manifests, and optional preview/contact sheets.
- Export targets for gameplay sheets, portraits, dialogue busts, menu avatars, icons, and marketing/contact sheets.

## Serious Production Improvements

- Godot-native runtime rig with layered body parts, equipment slots, attachment points, color masks, and weapon sockets.
- Deterministic sheet baking from the rig: same recipe plus same export profile must produce stable outputs.
- Animation retargeting layer so CC2D states map cleanly to SpriteVania animation names.
- Recipe diff and migration system for old saves and changing content packs.
- Visual regression tests for canonical recipes and animation frames.
- In-game constraint validation for collision fit, weapon alignment, silhouette readability, frame bounds, camera zoom, and hitbox compatibility.
- Semantic part tagging for faction, material, class fantasy, clipping risk, rarity, NPC use, starter-safe use, and biome identity.
- Modular DLC/content pack system with manifests, dependencies, previews, migration IDs, conflict detection, and missing-part fallbacks.
- Headless export CLI for CI and batch generation.
- Build reports that list missing required animations, invalid recipes, oversized frames, or non-transparent exports.

## Morphing

Morphing is recipe-driven and rig-driven, not destructive editing of source sprites.

### Morph Recipe Fields

Examples:

- body height
- body width
- head size
- arm length
- leg length
- shoulder width
- waist width
- hand size
- foot size
- posture lean
- weapon scale
- cape volume
- facial proportion offsets

### Morph Implementation

- Simple morphs use part scale, offset, rotation, and pivot adjustments.
- Larger morphs use per-part mesh/lattice deformation.
- Color/material morphs use masks and shaders.
- Morphs are previewed live on the layered rig.
- Final gameplay output is baked into SpriteFrames to keep runtime cheap and stable.

### Morph Limits

- Safe: color, part scale, part offsets, small proportion changes, overlays, weapon sizing, armor tinting.
- Risky: extreme body deformation, large pixel-art warps, anatomy changes that reveal missing pixels, pose-breaking cloth/hair deformation.

## Additional Improvements

- Recipe provenance: every exported sheet records recipe ID, content pack versions, morph values, palette IDs, export settings, and source part IDs.
- Auto-repair: if a part disappears, choose a compatible fallback and mark the recipe degraded instead of failing silently.
- Clone/family tools: derive NPC variants from a base recipe by controlled random deltas.
- Faction generators: create batches of visually coherent NPCs from tag rules and palette constraints.
- Equipment preview hooks: preview weapons/armor earned in the game before committing to a recipe.
- Animation coverage heatmap: show which selected recipe parts have clipping or readability risks per animation.
- Sheet diff viewer: compare two exports frame-by-frame to catch accidental rig or palette changes.
- Pivot/anchor editor with per-animation overrides and bottom-center defaults.
- Frame-bound inspector that highlights cropped pixels and wasted padding.
- Performance budgets per export target, including max texture size, max frames, and memory estimate.
- Importable/exportable recipe bundles so character packs can be shared independently from the game project.
- Accessibility previews for color contrast and small-scale readability.

## First Implementation Milestones

1. Godot-native data model: recipes, slots, parts, palettes, tags, morph values, and export profiles.
2. Layered rig preview scene: assemble selected parts and colors in Godot.
3. Animation inventory and retarget map: expose all CC2D base/aim states plus SpriteVania aliases.
4. Bulk export checklist UI: any selected set can export sheets.
5. Godot sheet baker: render rig frames to PNG sheets and `SpriteFrames`.
6. Recipe save/load and migration baseline.
7. Morph controls for safe transform-based morphs.
8. Validation reports and contact sheets.
9. Separate Character Studio app shell.
10. In-game creator integration.
