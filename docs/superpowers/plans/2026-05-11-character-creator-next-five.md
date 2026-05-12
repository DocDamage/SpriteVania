# Character Creator Next Five Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the next five CharacterCreator2D production baselines: compatibility validation, pivot/frame-bound inspection, portrait/avatar/icon exports, visual regression coverage, and equipment socket metadata.

**Architecture:** Keep the existing `CC2DCreatorManager` as the shared API used by Character Studio, the in-game creator, and the CLI. Add narrow helper/report methods rather than replacing the current baker. Character Studio should expose report data visibly, while tests assert manager/studio behavior through headless Godot.

**Tech Stack:** Godot 4.6 GDScript, headless Godot tests under `tests/test_*.gd`, JSON recipe/export reports, PNG bake outputs, `SpriteFrames` resources.

---

### Task 1: Compatibility And Constraint Validation

**Files:**
- Modify: `scripts/character_creator/cc2d_creator_manager.gd`
- Test: `tests/test_character_creator2d_recipe.gd`
- Docs: `docs/character_creator_2d_godot_tool_roadmap.md`, `docs/character_creator_2d_port.md`

- [x] Add failing tests that call `manager.compatibility_report(recipe, "movement")` and assert it returns warning categories for clipping, weapon alignment, silhouette readability, frame bounds, camera zoom, and hitbox compatibility.
- [x] Add failing tests that `validate_recipe()` includes a `constraints` dictionary with the same categories.
- [x] Implement `compatibility_report(recipe, set_id := "first_slice_player") -> Dictionary`.
- [x] Wire `validate_recipe()` to include the report under `constraints` and append high-severity messages to warnings.
- [x] Run `godot --headless --path . --script tests/test_character_creator2d_recipe.gd`.

### Task 2: Pivot And Frame-Bound Inspector

**Files:**
- Modify: `scripts/character_creator/character_studio.gd`
- Modify: `scenes/tools/CharacterStudio.tscn`
- Test: `tests/test_character_creator2d_recipe.gd`
- Docs: `docs/character_creator_2d_godot_tool_roadmap.md`, `docs/character_creator_2d_port.md`

- [x] Add failing tests that Character Studio exposes `inspect_current_frame_bounds()`.
- [x] Add failing tests for visible `%FrameBoundsLabel`, `%PivotXSpin`, `%PivotYSpin`, and `%ApplyPivotOverrideButton`.
- [x] Implement `inspect_current_frame_bounds()` returning frame rect, pivot, opaque bounds, cropped flag, and wasted padding estimate.
- [x] Add pivot override controls that update the active preview pivot and frame bounds label.
- [x] Run `godot --headless --path . --script tests/test_character_creator2d_recipe.gd`.

### Task 3: Portrait Avatar Icon Export Targets

**Files:**
- Modify: `scripts/character_creator/cc2d_creator_manager.gd`
- Modify: `tools/cc2d_export_cli.gd`
- Test: `tests/test_character_creator2d_recipe.gd`
- Docs: `docs/character_creator_2d_godot_tool_roadmap.md`, `docs/character_creator_2d_port.md`

- [x] Add failing tests for `manager.bake_export_target(recipe, path, "portrait")`, `"avatar"`, and `"icon"`.
- [x] Add failing CLI coverage for `--portrait`, `--avatar`, and `--icon`.
- [x] Implement a target-size map: portrait `256x256`, avatar `128x128`, icon `64x64`.
- [x] Compose a single transparent PNG for each target using the current recipe frame pipeline.
- [x] Add output paths to CLI `cc2d_export_summary`.
- [x] Run `godot --headless --path . --script tests/test_character_creator2d_recipe.gd`.

### Task 4: Canonical Visual Regression Baseline

**Files:**
- Create: `tests/test_character_creator2d_visual_regression.gd`
- Modify: `scripts/character_creator/cc2d_creator_manager.gd` only if a tiny checksum helper is needed
- Docs: `docs/character_creator_2d_godot_tool_roadmap.md`

- [x] Add a new headless test that bakes the default recipe contact sheet with deterministic settings.
- [x] Compute a stable lightweight signature from dimensions, opaque pixel count, and sampled pixels.
- [x] Assert the signature is non-empty and stable across two bakes in the same run.
- [x] Assert a family variant or palette change produces a different signature.
- [x] Run `godot --headless --path . --script tests/test_character_creator2d_visual_regression.gd`.

### Task 5: Equipment Socket Attachment Metadata

**Files:**
- Modify: `scripts/character_creator/cc2d_recipe.gd`
- Modify: `scripts/character_creator/cc2d_creator_manager.gd`
- Test: `tests/test_character_creator2d_recipe.gd`
- Docs: `docs/character_creator_2d_godot_tool_roadmap.md`, `docs/character_creator_2d_port.md`

- [x] Add failing recipe round-trip tests for `equipment_sockets`.
- [x] Add failing manager tests for `socket_report_for_recipe(recipe, "idle")`.
- [x] Add schema data for default sockets: `main_hand`, `off_hand`, `head`, `chest`, `back`.
- [x] Include per-socket slot, anchor, offset, compatible tags, and optional sampled animation offset.
- [x] Include socket metadata in export plan provenance/report data.
- [x] Run `godot --headless --path . --script tests/test_character_creator2d_recipe.gd`.

### Integration

- [x] Run `godot --headless --path . --script tests/test_character_creator2d_recipe.gd`.
- [x] Run `godot --headless --path . --script tests/test_character_creation.gd`.
- [x] Run `godot --headless --path . --script tests/test_character_creator2d_import.gd`.
- [x] Run all `tests/test_*.gd` with the project headless sweep.
- [x] Run `git diff --check`.
