# CharacterCreator2D Base Fantasy Port

The `Base Fantasy v1.99.unitypackage` payload is preserved in full and split into two Godot-facing areas:

- `res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/`
  - Godot-loadable runtime assets: PNG sprites, FBX meshes, PDF/TXT reference files.
  - These files are imported by Godot and can be loaded with `ResourceLoader`.
- `res://SpriteVania Assets/character_creator_2d/base_fantasy_raw/`
  - Unity-only source/reference payloads: scripts, anims, prefabs, materials, controllers, Unity metadata, and preview images.
  - This folder contains `.gdignore` so Godot does not try to import Unity binary resources.
- `res://resources/character_creator_2d/base_fantasy_manifest.json`
  - Generated manifest for all package entries. Each payload records its Unity path, project path, category, extension, and `import_role`.
- `res://resources/character_creator_2d/base_fantasy_export_profile.json`
  - Generated export profile for the Godot-native creator/exporter, including every base-layer and aim-layer animation state plus gameplay aliases.
- `res://resources/character_creator_2d/base_fantasy_bulk_export_sets.json`
  - Checklist presets for exporting groups of sprite sheets in one pass, such as first-slice player, movement, and combat sets.

Use `tools/extract_unitypackage.py` to regenerate the port:

```powershell
python tools\extract_unitypackage.py `
  --package "SpriteVania Assets\Base Fantasy v1.99.unitypackage" `
  --out-dir "SpriteVania Assets\character_creator_2d\base_fantasy_runtime" `
  --raw-out-dir "SpriteVania Assets\character_creator_2d\base_fantasy_raw" `
  --manifest "resources\character_creator_2d\base_fantasy_manifest.json" `
  --clean
```

Godot integration lives in:

- `res://scripts/character_creator/cc2d_manifest.gd`
- `res://scripts/character_creator/cc2d_appearance.gd`
- `res://scripts/character_creator/cc2d_recipe.gd`
- `res://scripts/character_creator/cc2d_creator_manager.gd`
- `res://scripts/character_creator/cc2d_export_profile.gd`
- `res://scripts/character_creator/cc2d_bulk_export_sets.gd`
- `res://scenes/ui/CharacterSelect.tscn`
- `res://scenes/tools/CharacterStudio.tscn`
- `tools/import_cc2d_bulk_export.py`
  - Godot-side importer that converts checked CC2D sheet exports into a `SpriteFrames` `.tres` plus an import manifest.
- `tools/cc2d_export_cli.gd`
  - Headless Godot export entry point for CI/batch generation of recipes, recipe bundles, sheets, `SpriteFrames`, contact sheets, portrait/avatar/icon PNGs, and validation reports. Successful runs print a `cc2d_export_summary=` JSON line for automation.

New games now persist selected CharacterCreator2D appearance parts into
`GameState.character_appearance` and a portable recipe payload in
`GameState.character_recipe`. `GameWorld` passes the appearance dictionary into
the spawned `Player`, keeping the legacy `selected_sprite` field reserved for
older class sprite IDs.

Recipes can also be exported as shareable bundle JSON files. A bundle contains
the recipe plus provenance, validation, and export-plan data, then can be
imported back into the shared manager or Character Studio.

Recipe schema version 4 adds outfit/loadout sets, recipe-owned custom export
sets, and equipment socket metadata. A recipe can store named
snapshots of parts, palettes, morphs, and tags, mark an active outfit ID, and
apply those snapshots back onto the current character for combat, town, NPC, or
faction variants. It can also store custom animation checklists for one-off
gameplay, portrait, icon, or review exports. Default recipes include main-hand,
off-hand, head, chest, and back sockets with anchors, offsets, and compatible
equipment tags.

Morph production scope is intentionally limited to safe transforms for now:
part scale, offset, rotation, pivot-style alignment, selected palette/tint
changes, and small proportion edits that survive preview and baked export
without warping the pixel art. Full lattice/mesh deformation is deferred as an
advanced milestone, not a current port requirement. Only promote it if a later
visual requirement cannot be satisfied through safe transforms, part swaps,
palette/tint changes, overlays, or equipment sockets, and only after defining
the target parts, animation coverage, authoring workflow, export cost budget,
artifact tolerance, and visual regression tests.

`CharacterSelect.tscn` now uses the shared creator manager for the in-game
creator path. It maintains a live `CC2DRecipe`, exposes validation and preview
state helpers, and renders the selected PNG parts as a nearest-filtered layered
preview that updates when the player changes a part option. It also exposes the
same manager-backed randomizer baseline as Character Studio, including required
tag filtering and visible locked-slot input. Its part rows can also be filtered
by search text and required tags using the same shared manager API as the
external studio. Favorite part paths are stored on the recipe and can drive a
favorites-only part list. Its preview state and visible labels now include
accessibility, performance, compatibility, and equipment socket readiness from
the same manager reports used by Character Studio and the export CLI.

The shared `CC2DCreatorManager` is the core service for both the in-game creator
and the separate Character Studio scene. It can:

- build default recipes from the imported Base Fantasy catalog,
- convert selected appearance parts into a versioned recipe,
- create seeded random recipes with locked slots and required tag filters,
- create controlled family/NPC variants from a base recipe,
- compare two recipes and report changed parts, palettes, morphs, tags, outfits, custom export sets, and generated SpriteFrames paths,
- filter part options by search text, required tags, and recipe favorites,
- mark and query recipe favorite parts,
- save/apply named outfit sets on recipes,
- save/list recipe-owned custom export sets and use them for validation, export plans, baking, and bundles,
- report recipe equipment sockets for an animation, including sampled offsets for attachment consumers,
- apply safe transform morphs in preview and baked exports while keeping lattice/mesh deformation out of the current baseline,
- validate recipes against checklist export sets, including palette contrast warnings, estimated export memory/pixel budgets, and baseline compatibility constraints for clipping, weapon alignment, silhouette readability, frame bounds, camera zoom, and hitbox compatibility,
- bake a first transparent PNG sheet set plus `source_spec.json` from a recipe,
- create a loadable Godot `SpriteFrames` `.tres` from a baked sheet report,
- sample imported Unity rig curves during baking so exported animation sheets contain distinct per-frame part motion,
- create contact sheet PNGs from selected export sets for quick visual review,
- bake single-frame portrait, avatar, and icon PNG export targets,
- write validation report JSON files with recipe, checklist, and export-plan data,
- export and import recipe bundle JSON files with provenance and validation data,
- repair missing part selections with compatible fallbacks,
- save and load recipe JSON files, and
- build export plans with recipe provenance, animation checklists, and socket metadata.

`CharacterStudio.tscn` is now a functional external-editor shell. It creates
part browser controls from the imported catalog, exposes palette and safe morph
editing controls, supports checklist export-set selection, includes visible
recipe save/load and bundle import/export controls, and displays validation plus
preview state from the active recipe. Its first visual preview stacks selected PNG parts as
nearest-filtered layers so recipe edits visibly update the character. It has
visible randomizer controls backed by the shared manager's seeded, tag-aware,
locked-slot randomization API, and visible outfit controls for saving and
applying named loadout snapshots. It also has visible custom export-set controls
for saving recipe-owned animation checklists and selecting them for export
plans. It also exposes animation state selection, a
visible locked-slot randomizer field, a searchable/tag/favorites-filtered part browser, frame scrubber, frame stepping, playback
speed, playback advancement, horizontal flip, preview offset/scale alignment
state, and first-pass frame metadata with source rects and pivots applied to
preview layers. Character Studio can also bake the current recipe/export set to
transparent PNG sheets, a `source_spec.json` for the existing SpriteFrames
importer, a Godot `SpriteFrames` `.tres`, a contact sheet PNG, and validation
report JSON directly from the studio UI. The
clip timing now comes from the imported Unity `.anim` files referenced by the
export profile. The manager parses `m_SampleRate` and `m_StopTime` so preview
frame counts use real CC2D clip durations. It also parses Unity sprite `.meta`
files for selected parts, including named sprite rects and normalized pivots,
and the studio prefers those imported part rects when building preview frame
metadata. Imported Unity rig curve bindings are also parsed from animation
clips, mapped to readable part names such as Body and Head, and sampled per
preview/export frame so the baker can apply part visibility, position, scale,
and nearest-neighbor pixel rotation from real source rig motion. The external
studio also exposes `inspect_current_frame_bounds()` plus visible frame-bound
and pivot override controls so the active frame can report source rect, pivot,
opaque bounds, crop risk, padding waste, and frame size.

## Godot-Native Port Direction

The target is a Godot-native CharacterCreator2D port. Unity should not be part of the game pipeline. The Unity package is treated as source data only: sprites, metadata, animation names, palettes, and original scripts for reference while rebuilding the creator in Godot.

The Godot creator/exporter must support:

- a single PNG frame,
- a transparent PNG sequence,
- combined sprite sheets,
- base-layer animation plus optional aim-layer animation,
- configurable FPS, output size, position, scale, and scale mode.

For SpriteVania, use the export profile as the contract between the Godot creator app and the game:

- design the character in the Godot creator,
- select a bulk export checklist, such as `first_slice_player`, `movement`, or `combat`,
- export transparent PNG sequences/sheets for the checked animations from Godot,
- run `tools/import_cc2d_bulk_export.py` to build a Godot `SpriteFrames` resource and import manifest or use Character Studio's direct SpriteFrames bake,
- assign the generated `SpriteFrames` to the player scene/class.

At runtime, `GameState.character_spriteframes_path` can point at a generated `SpriteFrames` resource. `GameWorld` passes that path to `Player.apply_spriteframes_path()`, which swaps the `AnimatedSprite2D` frames onto the player.

Example Godot import command after the Godot creator writes `idle_sheet.png`, `run_sheet.png`, and the other checked outputs:

```powershell
python tools\import_cc2d_bulk_export.py `
  --export-root "SpriteVania Assets\character_creator_2d\exports\my_character" `
  --profile "resources\character_creator_2d\base_fantasy_export_profile.json" `
  --sets "resources\character_creator_2d\base_fantasy_bulk_export_sets.json" `
  --set-id "first_slice_player" `
  --out "resources\animations\my_character_frames.tres" `
  --manifest "resources\character_creator_2d\my_character_import_manifest.json" `
  --res-root "."
```

Example direct headless Godot export:

```powershell
godot --headless --path . --script tools/cc2d_export_cli.gd -- `
  --recipe-out "user://my_character_recipe.json" `
  --bundle-out "user://my_character_bundle.json" `
  --output-root "user://my_character_export" `
  --spriteframes "user://my_character_frames.tres" `
  --contact-sheet "user://my_character_contact.png" `
  --portrait "user://my_character_portrait.png" `
  --avatar "user://my_character_avatar.png" `
  --icon "user://my_character_icon.png" `
  --validation-report "user://my_character_validation.json" `
  --set-id "movement" `
  --max-frames 2
```

Use `--recipe PATH` to export from a saved recipe JSON, or `--bundle-in PATH`
to export from a shareable recipe bundle.

Gameplay aliases:

- `idle` -> `Idle`
- `run` -> `Run`
- `dash` -> `Sprint`
- `jump` -> `Jump`
- `fall` -> `Fall`
- `hurt` -> `Hit`
- `death` -> `Die`
- `melee_1`/`melee_2`/`melee_3` -> `Attack Main Hand 1/2/3`
- `heavy` -> `Attack Two Handed 1`
- `cast` -> `Cast 1`
- `shoot` -> base `Idle` plus aim `Shot Main Hand`

Bulk export should stay checklist-driven. A set is just an ordered list of game animation IDs, and each ID resolves through `base_fantasy_export_profile.json` to the CC2D base/aim animation states. This keeps the UI flexible: the creator can expose all available animations, but default to the subset needed for the current playable slice.

The full animation inventory is not limited to those gameplay aliases. `base_fantasy_export_profile.json` also contains `all_animation_exports`, with `base:*` and `aim:*` IDs for every animation listed by the CC2D package. The `all_base` and `all_aim` checklist presets expose those complete sets.
