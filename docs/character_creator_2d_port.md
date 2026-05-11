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
- `res://scripts/character_creator/cc2d_export_profile.gd`
- `res://scripts/character_creator/cc2d_bulk_export_sets.gd`
- `res://scenes/ui/CharacterSelect.tscn`
- `tools/import_cc2d_bulk_export.py`
  - Godot-side importer that converts checked CC2D sheet exports into a `SpriteFrames` `.tres` plus an import manifest.

New games now persist selected CharacterCreator2D appearance parts into `GameState.character_appearance`. `GameWorld` passes that dictionary into the spawned `Player`, keeping the legacy `selected_sprite` field reserved for older class sprite IDs.

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
- run `tools/import_cc2d_bulk_export.py` to build a Godot `SpriteFrames` resource and import manifest,
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
