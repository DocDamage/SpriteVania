# Asset Audit Results — Import-Test Conclusions Addendum

Add this section to `docs/black_keep/asset_audit_results.md` after the existing `Import-Test Shortlist` section.

## Import-Test Conclusions — Prototype Milestone

The user approved prototype-quality playable sprites for milestone one, as long as final-art risks are documented.

A temporary import-test arena package has been prepared:

```text
scenes/dev/PlayableImportTestScene.tscn
scripts/dev/playable_import_test_scene.gd
docs/black_keep/playable_import_test_results.md
```

The scene creates a flat ground, jump gap, ledge, wall/vertical-ascent test, low-ceiling/slide test, dummy target, moving-target path marker, camera reference, candidate preview slots, and a runtime asset-coverage scan.

### Current Candidate Results

| Candidate | Intended role | Result | Conclusion |
|---|---|---|---|
| `SpriteVania Assets/craft pix characters/SWAT_1` | The Arc-Gunner | Prototype-approved | Use for first Arc-Gunner import test; needs magical gun/VFX and palette pass before final art. |
| `SpriteVania Assets/player/samurai` | The Ronin | Prototype-approved | Use for first Ronin import test; needs manual frame-range mapping and scale check. |
| `SpriteVania Assets/craft pix characters/Witch_3` | The Black Witch of Ash | Prototype-approved | Use for first Witch import test; needs ash VFX overlay and custom handling for 64px charge sheet. |
| `SpriteVania Assets/player/player_generic` | The Iron Knight | Technical prototype only | Use to prove melee/guard/roll/climb pipeline; do not lock as final Iron Knight art without retheme. |

### Deferred Candidates

| Candidate | Reason |
|---|---|
| `SpriteVania Assets/player/magic_cliffs_player` | Motion coverage is useful, but visual identity does not currently read as The Shadow. |
| `SpriteVania Assets/craft pix characters/Scientists_1` | Strong Gadgeteer/scientist identity, but attack/jump coverage needs a custom solution. |

### Next Required Step

Run the import-test scene inside Godot and update `docs/black_keep/playable_import_test_results.md` with true in-engine findings, screenshots, animation coverage, and final pass/prototype/defer/reject decisions.
