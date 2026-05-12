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
- In-game constraint validation for collision fit, weapon alignment, silhouette readability, frame bounds, camera zoom, and hitbox compatibility. Baseline manager reports now cover clipping, weapon alignment, silhouette readability, frame bounds, camera zoom, and hitbox compatibility for validation/export workflows, and the in-game creator surfaces compact compatibility status.
- Semantic part tagging for faction, material, class fantasy, clipping risk, rarity, NPC use, starter-safe use, and biome identity.
- Modular DLC/content pack system with manifests, dependencies, previews, migration IDs, conflict detection, and missing-part fallbacks.
- Headless export CLI for CI and batch generation.
- Build reports that list missing required animations, invalid recipes, oversized frames, or non-transparent exports.
- Headless Godot export CLI for CI and batch generation.

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

- Production scope: safe transform morphs ship now. The supported morph surface is part scale, offset, rotation, pivot-style alignment, selected palette/tint changes, and small proportion changes that keep the source pixel art readable.
- Deferred scope: full per-part lattice/mesh deformation is an advanced milestone, not part of the current production baseline. It should only be scheduled if a later visual requirement cannot be met with safe transforms, part swaps, palette/tint changes, overlays, or socketed equipment.
- Deferred acceptance bar: before implementing lattice/mesh deformation, define target parts, animation states, authoring UI, bake-time sampling, artifact tolerance, visual regression coverage, and runtime/export cost limits.
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
- Equipment preview hooks: preview weapons/armor earned in the game before committing to a recipe. A baseline manager report can now evaluate a candidate against socket compatibility tags and sampled socket metadata without mutating the active recipe, and the in-game creator exposes the active recipe's socket count/readiness.
- Animation coverage heatmap: show which selected recipe parts have clipping or readability risks per animation. A baseline manager/Studio report now summarizes export-set availability, source frame counts, compatibility risks, selected part counts, and socket counts per animation.
- Sheet diff viewer: compare two exports frame-by-frame to catch accidental rig or palette changes. Character Studio now exposes contact-sheet left/right inputs and a diff action backed by the shared frame-level image diff.
- Pivot/anchor editor with per-animation overrides and bottom-center defaults. Studio pivot edits now persist per animation/frame in recipe data and are included in export provenance.
- Frame-bound inspector that highlights cropped pixels and wasted padding.
- Performance budgets per export target, including max texture size, max frames, and memory estimate. A shared budget report now covers gameplay sheets plus portrait/avatar/icon targets and feeds in-game and Studio budget labels.
- Importable/exportable recipe bundles so character packs can be shared independently from the game project.
- Accessibility previews for color contrast and small-scale readability. A shared report now powers in-game and Studio labels with palette contrast pairs, small-target readability risks, and export memory context.

## First Implementation Milestones

1. Godot-native data model: recipes, slots, parts, palettes, tags, morph values, equipment sockets, and export profiles. Initial shared recipe and manager scripts exist and are used by New Game saves, the in-game creator, and the Character Studio shell.
2. Layered rig preview scene: assemble selected parts and colors in Godot. Character Studio now stacks selected PNG parts as nearest-filtered preview layers and exposes animation selection, frame scrubber, frame stepping, playback speed, playback advancement, horizontal flip, preview offset/scale alignment, source rect metadata, pivot metadata, a frame-bound inspector, and compact pivot override controls. Clip timing is parsed from imported Unity `.anim` files, selected part rects/pivots are parsed from Unity sprite `.meta` files, and imported Unity rig curve bindings are mapped to readable part names with per-frame preview samples. The in-game CharacterSelect creator also renders a lightweight layered preview from the same selected recipe parts, using the shared recipe morph and palette transform paths.
3. Animation inventory and retarget map: expose all CC2D base/aim states plus SpriteVania aliases.
4. Bulk export checklist UI: any selected set can export sheets. Character Studio can select export sets and build manager-backed export plans.
5. Godot sheet baker: render rig frames to PNG sheets and `SpriteFrames`. A first Godot-side sheet baker now composites selected recipe parts into transparent PNG sheets, samples imported Unity rig curves per exported frame, applies per-part visibility, position, scale, nearest-neighbor pixel rotation, safe recipe morph transforms, and shared palette tinting, writes a `source_spec.json` compatible with `tools/import_cc2d_bulk_export.py`, creates a loadable Godot `SpriteFrames` `.tres` from those sheets, can emit contact sheet PNGs for review, can bake single-frame portrait, avatar, and icon PNG targets, stores the generated path on the recipe, and is callable from Character Studio. Full lattice/mesh deformation is explicitly deferred unless later visual requirements prove safe transforms insufficient.
6. Recipe save/load and migration baseline. Recipe JSON save/load, schema/content-version migration reports, missing-part fallback repair, and default equipment socket backfill are implemented in the shared manager, and Character Studio has visible save/load controls wired to the active recipe.
7. Morph controls for safe transform-based morphs. Character Studio exposes the first safe morph sliders, writes values into the active recipe, and routes body height, body width, head size, and weapon scale through shared preview/bake transforms.
8. Validation reports and contact sheets. Manager-backed validation JSON reports and contact sheet PNG export are implemented and exposed in Character Studio.
9. Headless export CLI. `tools/cc2d_export_cli.gd` can generate recipes, PNG sheet exports, direct `SpriteFrames`, contact sheets, portrait/avatar/icon targets, and validation reports from the shared manager for CI/batch use.
10. Separate Character Studio app shell. A first `CharacterStudio.tscn` shell exists and initializes from the shared manager.
11. In-game creator integration. New Game now stores a portable recipe payload and content version alongside the existing appearance selections, and CharacterSelect owns a manager-backed recipe plus live layered preview, validation/accessibility/performance labels, compatibility readiness, and equipment socket readiness.
12. Randomizer baseline. The shared manager derives starter-safe/category/filename tags for part options and supports seeded random recipes, required tag filters, and locked slots. Character Studio and CharacterSelect both expose visible randomizer controls, including locked-slot input, backed by the same manager API.
13. Part browser filtering baseline. The shared manager filters part options by search text, required tags, and recipe favorites. Character Studio and CharacterSelect both expose visible search/tag/favorites filter fields and rebuild their part rows from the same manager API while keeping current selections and previews in sync.
14. Favorites baseline. Recipes now serialize favorite part paths under schema version 2. The shared manager can mark and test favorites, and both creator surfaces can show favorites-only part lists.
15. Recipe bundles. The shared manager and Character Studio can export/import bundle JSON files containing the recipe plus provenance, validation, and export-plan data.
16. Outfit/loadout baseline. Recipes now serialize named outfit sets under schema version 4. The shared manager can save/apply outfit snapshots, and Character Studio exposes visible outfit ID, label, tags, save, and apply controls.
17. Family variant baseline. The shared manager can derive a related recipe from a base recipe by preserving locked slots and seeded-randomizing the remaining slots.
18. Validation budget/accessibility/constraint baseline. Validation reports now include low palette contrast warnings, estimated export pixel/byte budgets for the selected export checklist, and deterministic compatibility constraints for clipping, weapon alignment, silhouette readability, frame bounds, camera zoom, and hitbox compatibility. CharacterSelect exposes these constraints through its preview state and compact readiness label.
19. Custom export-set baseline. Recipes now serialize custom animation checklists under schema version 4. The shared manager can save/list custom sets and use them for validation, export plans, baking, bundles, and Character Studio selection.
20. Recipe diff baseline. The shared manager can compare two recipes and report changed part slots, palettes, morphs, tags, outfit sets, custom export sets, and generated SpriteFrames path changes.
21. Equipment socket baseline. Default recipes now include main-hand, off-hand, head, chest, and back attachment sockets. Recipes serialize socket anchor, offset, and compatible-tag metadata, export plans include sampled socket reports for consumers that need attachment points, and the shared manager plus Character Studio expose non-committing equipment preview reports for socket compatibility checks. CharacterSelect also exposes socket reports for the active in-game recipe.
22. Canonical visual regression baseline. A headless test bakes the default CharacterCreator2D contact sheet twice with deterministic settings, compares stable image signatures, and verifies a deterministic part change produces a different signature.
23. Export provenance baseline. Baked `source_spec.json` files now include recipe/content provenance, selected source parts, palette values, morph values, and export settings alongside generated animation sheet metadata.
24. Contact-sheet diff baseline. The shared manager can generate stable contact-sheet signatures and frame-level diff reports between two exported contact sheets for regression review and tooling.
25. Deferred lattice/mesh deformation decision. Production keeps the current safe transform morph pipeline. Full lattice/mesh deformation remains an advanced milestone gated by concrete visual requirements, authoring workflow design, bake/export performance budgets, and visual regression tests.
26. Faction/NPC batch generator baseline. The shared manager and Character Studio can generate deterministic faction batches from tag rules, palette overrides and constrained palette choices, locked slot selections, count, and seed, returning generated recipes plus provenance for batch tooling.
27. Content-pack metadata baseline. The manifest, shared manager, and Character Studio expose a content-pack report with pack id/version, dependencies, migration IDs, asset totals, category/extension counts, duplicate/conflict hints, and missing dependency warnings.
28. Animation coverage heatmap baseline. The shared manager and Character Studio can report per-animation coverage for any selected export set, including missing export warnings, parsed clip frame metadata, selected part/socket counts, and compatibility risk messages for clipping, readability, bounds, zoom, weapon alignment, and hitbox checks.
29. Accessibility preview baseline. The shared manager, in-game CharacterSelect, and external Character Studio expose palette contrast and small-scale readability previews, including failing contrast pairs, icon/avatar density risks, and estimated export memory context.
30. Performance budget baseline. The shared manager, in-game CharacterSelect, and external Character Studio expose per-target export budgets for gameplay sheets and portrait/avatar/icon renders, including frame totals, texture dimensions, estimated memory, configured limits, and severity messages.
31. Studio sheet diff viewer baseline. External Character Studio exposes visible contact-sheet comparison controls that call the shared frame-level contact-sheet diff report and summarize matching or changed frames in the tool UI.
32. Pivot override persistence baseline. Recipes serialize per-animation/per-frame pivot overrides, Character Studio writes and reloads them from the active recipe, preview layers apply them, and baked export provenance records the override map for audit/debugging.
33. Creator test performance cleanup. Contact-sheet diff tests now reuse existing sheets for identical-image comparisons and Studio contact-sheet button bakes use one preview frame per animation, reducing redundant heavy image bakes while preserving diff coverage.
