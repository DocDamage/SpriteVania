# SpriteVania / The Black Keep

Godot action RPG / Metroidvania prototype evolving into **The Black Keep**.

The repo currently contains the playable SpriteVania systems foundation:

- title, continue, load, settings, and character creation flow,
- three starter classes,
- room transitions, hazards, checkpoints, upgrades, enemies, shortcuts, and boss gates,
- save/load state with migration coverage,
- HUD, familiar progression, party groundwork, and headless tests.

Primary planning docs live in [docs/black_keep/README.md](docs/black_keep/README.md).

## Character Creator Direction

The project is adding a complete Godot-native port of CharacterCreator2D as both:

- an in-game character creator, and
- a separate Godot Character Studio app for production authoring.

Unity is **not** part of the production pipeline. The Unity package is treated only as source/reference data while the tool is rebuilt in Godot.

Key docs:

- [CharacterCreator2D Port](docs/character_creator_2d_port.md)
- [Godot CharacterCreator2D Tool Roadmap](docs/character_creator_2d_godot_tool_roadmap.md)
- [Character Creation Spec](docs/black_keep/character_creation_spec.md)
- [Art Pipeline](docs/black_keep/art_pipeline.md)

The target creator supports recipes, layered rigs, palettes, morphing, checklist-driven bulk animation export, direct `SpriteFrames` generation, validation reports, and reusable content packs.

## Tests

Use the tiered test runner for normal development:

```powershell
.\tools\run_tests.ps1 -Suite fast
.\tools\run_tests.ps1 -Suite creator-fast
.\tools\run_tests.ps1 -Suite creator
.\tools\run_tests.ps1 -Suite full
```

`fast` skips the slow CharacterCreator2D bake/visual tests. `creator-fast` runs the in-game creator, importer, and non-bake recipe slices. `creator` adds the heavier bake, studio, and visual regression coverage. Focused CC2D slices are also available as `creator-recipe`, `creator-manager`, `creator-bake`, `creator-studio`, and `creator-metadata`.

To preview what a tier will run or execute specific files:

```powershell
.\tools\run_tests.ps1 -Suite creator-fast -List
.\tools\run_tests.ps1 -Tests tests/test_character_creation.gd,tests/test_save_manager.gd
```

Python tooling syntax check:

```powershell
python -m py_compile tools/extract_unitypackage.py tools/build_cc2d_export_profile.py tools/import_cc2d_bulk_export.py
```
