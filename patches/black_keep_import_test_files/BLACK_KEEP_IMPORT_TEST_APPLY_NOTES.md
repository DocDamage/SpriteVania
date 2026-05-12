# Black Keep Import-Test Files — Apply Notes

Copy these files into the repo root:

```text
scenes/dev/PlayableImportTestScene.tscn
scripts/dev/playable_import_test_scene.gd
docs/black_keep/playable_import_test_results.md
```

Then merge the contents of:

```text
docs/black_keep/asset_audit_results_import_test_addendum.md
```

into:

```text
docs/black_keep/asset_audit_results.md
```

after the existing `Import-Test Shortlist` section.

## Important Limits

This package prepares the import-test scene and documents the approved prototype decisions. It does not claim final in-engine import results yet. The scene must be opened/run in Godot to confirm actual source paths, slicing, animation playback, collision scale, and visual readability.

## Do Not Do Yet

- Do not replace current playable classes.
- Do not implement the party system.
- Do not lock final character art.
- Do not remove existing Warden/Gunslinger/Hexbinder placeholder systems.
