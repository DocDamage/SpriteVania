extends SceneTree

const CC2DRecipe := preload("res://scripts/character_creator/cc2d_recipe.gd")
const CC2DCreatorManager := preload("res://scripts/character_creator/cc2d_creator_manager.gd")
const GameState := preload("res://scripts/core/game_state.gd")
const CHARACTER_STUDIO_SCENE_PATH := "res://scenes/tools/CharacterStudio.tscn"
const CC2D_EXPORT_CLI_PATH := "res://tools/cc2d_export_cli.gd"

var _failed := false

func _init() -> void:
	_assert_recipe_round_trips_with_schema_version()
	_assert_recipe_round_trips_outfit_sets()
	_assert_recipe_round_trips_custom_export_sets()
	_assert_recipe_round_trips_equipment_sockets()
	_assert_manager_builds_valid_default_recipe()
	_assert_manager_saves_and_loads_recipe_files()
	_assert_manager_exports_and_imports_recipe_bundles()
	_assert_manager_applies_outfit_sets()
	_assert_manager_creates_family_variants()
	_assert_manager_reports_recipe_diffs()
	_assert_manager_uses_recipe_custom_export_sets()
	_assert_manager_repairs_missing_parts()
	_assert_manager_reports_export_readiness()
	_assert_manager_reports_equipment_sockets()
	_assert_manager_reports_accessibility_and_budget_warnings()
	_assert_manager_writes_validation_reports()
	_assert_manager_bakes_export_sheet_source_spec()
	_assert_manager_bakes_export_target_images()
	_assert_manager_rotates_baked_parts()
	_assert_manager_bakes_contact_sheet()
	_assert_headless_export_cli_writes_batch_outputs()
	_assert_manager_randomizes_recipes_with_locks_and_tags()
	_assert_manager_filters_part_options_by_search_and_tags()
	_assert_manager_parses_imported_clip_metadata()
	_assert_manager_parses_part_sprite_metadata()
	_assert_external_character_studio_shell_uses_manager()
	_assert_external_character_studio_bakes_export_sheets()
	_assert_external_character_studio_edits_recipe()
	_assert_external_character_studio_filters_part_browser()
	_assert_external_character_studio_saves_and_loads_recipe()
	_assert_external_character_studio_randomizes_recipe()
	_assert_external_character_studio_renders_layered_preview()
	_assert_external_character_studio_animation_preview_controls()
	_assert_external_character_studio_frame_metadata_preview()
	_assert_game_state_preserves_recipe_payload()

	if _failed:
		return
	print("PASS: character creator 2d recipe")
	quit(0)

func _assert_recipe_round_trips_with_schema_version() -> void:
	var recipe := CC2DRecipe.new()
	recipe.recipe_id = "ronin_custom_001"
	recipe.display_name = "Ash Ronin"
	recipe.content_pack_id = "base_fantasy"
	recipe.export_profile_id = "base_fantasy"
	recipe.parts = {
		"Base/Body Skin": {
			"path": "res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Base/Body Skin/Bodyset Male.png",
			"relative_path": "Sprites/Base/Body Skin/Bodyset Male.png",
		},
	}
	recipe.palettes = {"skin": Color(0.9, 0.7, 0.55, 1.0).to_html()}
	recipe.morphs = {"body_height": 0.1}
	recipe.tags = ["starter_safe", "ronin"]
	recipe.favorite_part_paths = ["res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Base/Hair/14.png"]
	recipe.generated_spriteframes_path = "res://resources/animations/generated/ash_ronin_frames.tres"

	var loaded: CC2DRecipe = CC2DRecipe.from_dictionary(recipe.to_dictionary())
	if loaded.schema_version != CC2DRecipe.SCHEMA_VERSION:
		_fail("Recipe schema version should survive round trip.")
		return
	if loaded.recipe_id != recipe.recipe_id or loaded.display_name != recipe.display_name:
		_fail("Recipe identity fields should survive round trip.")
		return
	if loaded.parts.is_empty() or str((loaded.parts.get("Base/Body Skin", {}) as Dictionary).get("relative_path", "")) == "":
		_fail("Recipe parts should survive round trip.")
		return
	if loaded.generated_spriteframes_path != recipe.generated_spriteframes_path:
		_fail("Recipe generated SpriteFrames path should survive round trip.")
		return
	if loaded.favorite_part_paths != recipe.favorite_part_paths:
		_fail("Recipe favorite part paths should survive round trip.")
		return

func _assert_recipe_round_trips_outfit_sets() -> void:
	var recipe := CC2DRecipe.new()
	recipe.recipe_id = "outfit_recipe"
	recipe.parts = {
		"Base/Hair": {"path": "res://hair_a.png"},
	}
	recipe.outfit_sets = {
		"town": {
			"label": "Town",
			"parts": {
				"Base/Hair": {"path": "res://hair_b.png"},
			},
			"tags": ["town"],
		},
	}
	recipe.active_outfit_id = "town"
	var loaded: CC2DRecipe = CC2DRecipe.from_dictionary(recipe.to_dictionary())
	if loaded.active_outfit_id != "town" or not loaded.outfit_sets.has("town"):
		_fail("Recipe outfit sets should survive dictionary round trip.")
		return
	var town := loaded.outfit_sets.get("town", {}) as Dictionary
	if not (town.get("tags", []) as Array).has("town"):
		_fail("Recipe outfit set tags should survive dictionary round trip.")
		return

func _assert_recipe_round_trips_custom_export_sets() -> void:
	var recipe := CC2DRecipe.new()
	recipe.recipe_id = "custom_export_recipe"
	recipe.custom_export_sets = {
		"duel": {
			"label": "Duel",
			"animations": ["idle", "run", "melee_1"],
			"target": "gameplay",
		},
	}
	var loaded: CC2DRecipe = CC2DRecipe.from_dictionary(recipe.to_dictionary())
	if not loaded.custom_export_sets.has("duel"):
		_fail("Recipe custom export sets should survive dictionary round trip.")
		return
	var duel := loaded.custom_export_sets.get("duel", {}) as Dictionary
	if not (duel.get("animations", []) as Array).has("melee_1") or str(duel.get("target", "")) != "gameplay":
		_fail("Recipe custom export set metadata should survive dictionary round trip.")
		return

func _assert_recipe_round_trips_equipment_sockets() -> void:
	var recipe := CC2DRecipe.new()
	recipe.recipe_id = "socket_recipe"
	recipe.set("equipment_sockets", {
		"main_hand": {
			"slot": "main_hand",
			"anchor": "hand_r",
			"offset": {"x": 7.0, "y": -4.0},
			"compatible_tags": ["weapon", "melee"],
		},
		"off_hand": {
			"slot": "off_hand",
			"anchor": "hand_l",
			"offset": {"x": -6.0, "y": -3.0},
			"compatible_tags": ["shield"],
		},
		"head": {
			"slot": "head",
			"anchor": "head",
			"offset": {"x": 0.0, "y": -18.0},
			"compatible_tags": ["helmet"],
		},
	})
	var loaded: CC2DRecipe = CC2DRecipe.from_dictionary(recipe.to_dictionary())
	var sockets := loaded.get("equipment_sockets") as Dictionary
	if not sockets.has("main_hand") or not sockets.has("off_hand") or not sockets.has("head"):
		_fail("Recipe equipment sockets should survive dictionary round trip.")
		return
	var main_hand := sockets.get("main_hand", {}) as Dictionary
	if str(main_hand.get("anchor", "")) != "hand_r" or not (main_hand.get("compatible_tags", []) as Array).has("melee"):
		_fail("Recipe equipment socket metadata should survive dictionary round trip.")
		return

func _assert_manager_builds_valid_default_recipe() -> void:
	var manager := CC2DCreatorManager.new()
	if not manager.load_content():
		_fail("Creator manager should load CC2D content manifests and export profiles.")
		return
	var recipe: CC2DRecipe = manager.default_recipe("ronin")
	if recipe == null:
		_fail("Creator manager should build a default recipe.")
		return
	if recipe.recipe_id.is_empty() or recipe.parts.is_empty():
		_fail("Default recipe should include an id and selected parts.")
		return
	var sockets := recipe.get("equipment_sockets") as Dictionary
	for socket_id: String in ["main_hand", "off_hand", "head", "chest", "back"]:
		if not sockets.has(socket_id):
			_fail("Default recipe should include equipment socket: " + socket_id)
			return
	var report := manager.validate_recipe(recipe, "first_slice_player")
	if not bool(report.get("valid", false)):
		_fail("Default recipe should validate for the first-slice export set: " + str(report.get("errors", [])))
		return
	if int((report.get("coverage", {}) as Dictionary).get("checked", 0)) < 10:
		_fail("Validation report should include useful animation coverage.")
		return

func _assert_manager_saves_and_loads_recipe_files() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	var recipe: CC2DRecipe = manager.default_recipe("file_round_trip")
	recipe.display_name = "File Round Trip"
	recipe.morphs["weapon_scale"] = 0.2
	var path := "user://test_cc2d_recipe.json"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if not manager.save_recipe(recipe, path):
		_fail("Creator manager should save recipe JSON files.")
		return
	var loaded: CC2DRecipe = manager.load_recipe(path)
	if loaded == null:
		_fail("Creator manager should load recipe JSON files.")
		return
	if loaded.recipe_id != recipe.recipe_id or loaded.display_name != recipe.display_name:
		_fail("Loaded recipe should preserve identity fields.")
		return
	if float(loaded.morphs.get("weapon_scale", 0.0)) != 0.2:
		_fail("Loaded recipe should preserve morph values.")
		return
	DirAccess.remove_absolute(path)

func _assert_manager_exports_and_imports_recipe_bundles() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("export_recipe_bundle") or not manager.has_method("import_recipe_bundle"):
		_fail("Creator manager should expose recipe bundle import/export.")
		return
	var recipe: CC2DRecipe = manager.default_recipe("bundle_recipe")
	recipe.display_name = "Bundle Recipe"
	var bundle_path := "user://test_cc2d_recipe_bundle.json"
	var export_report := manager.call("export_recipe_bundle", recipe, bundle_path, "movement") as Dictionary
	if not bool(export_report.get("ok", false)):
		_fail("Creator manager should export recipe bundles: " + str(export_report.get("errors", [])))
		return
	if not FileAccess.file_exists(bundle_path):
		_fail("Recipe bundle export should write a JSON file.")
		return
	var imported: CC2DRecipe = manager.call("import_recipe_bundle", bundle_path)
	if imported == null or imported.recipe_id != recipe.recipe_id or imported.display_name != recipe.display_name:
		_fail("Recipe bundle import should restore the embedded recipe.")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(bundle_path))
	if not parsed is Dictionary or not (parsed as Dictionary).has("provenance") or not (parsed as Dictionary).has("validation"):
		_fail("Recipe bundles should include provenance and validation data.")
		return

func _assert_manager_applies_outfit_sets() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("save_outfit_set") or not manager.has_method("apply_outfit_set"):
		_fail("Creator manager should expose outfit set helpers.")
		return
	var recipe: CC2DRecipe = manager.default_recipe("outfit_sets")
	var original_hair := (recipe.parts.get("Base/Hair", {}) as Dictionary).duplicate(true)
	manager.randomize_recipe(recipe, ["Base/Body Skin"], ["starter_safe"], 101)
	var changed_hair := (recipe.parts.get("Base/Hair", {}) as Dictionary).duplicate(true)
	var save_report := manager.call("save_outfit_set", recipe, "combat", "Combat", ["combat"]) as Dictionary
	if not bool(save_report.get("ok", false)) or not recipe.outfit_sets.has("combat"):
		_fail("Creator manager should save the active parts as an outfit set.")
		return
	recipe.parts["Base/Hair"] = original_hair
	var apply_report := manager.call("apply_outfit_set", recipe, "combat") as Dictionary
	if not bool(apply_report.get("ok", false)) or recipe.active_outfit_id != "combat":
		_fail("Creator manager should apply outfit sets and mark the active outfit.")
		return
	if str((recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", "")) != str(changed_hair.get("path", "")):
		_fail("Applying an outfit set should restore its saved part selections.")
		return

func _assert_manager_creates_family_variants() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("family_variant_recipe"):
		_fail("Creator manager should expose family_variant_recipe().")
		return
	var base: CC2DRecipe = manager.default_recipe("family_base")
	var variant: CC2DRecipe = manager.call("family_variant_recipe", base, "family_variant", "Cousin", ["Base/Hair"], 404) as CC2DRecipe
	if variant == null or variant.recipe_id != "family_variant" or variant.display_name != "Cousin":
		_fail("Family variant should produce a renamed recipe clone.")
		return
	if str((variant.parts.get("Base/Hair", {}) as Dictionary).get("path", "")) != str((base.parts.get("Base/Hair", {}) as Dictionary).get("path", "")):
		_fail("Family variant should preserve locked family-defining slots.")
		return
	if not variant.tags.has("family_variant"):
		_fail("Family variant should tag derived recipes.")
		return

func _assert_manager_reports_recipe_diffs() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("diff_recipes"):
		_fail("Creator manager should expose diff_recipes().")
		return
	var left: CC2DRecipe = manager.default_recipe("diff_left")
	var right: CC2DRecipe = CC2DRecipe.from_dictionary(left.to_dictionary())
	right.recipe_id = "diff_right"
	var left_hair_path := str((left.parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	right.parts["Base/Hair"] = {
		"path": "%s.variant" % left_hair_path,
		"relative_path": "Sprites/Base/Hair/DiffVariant.png",
	}
	right.palettes["hair"] = "112233ff"
	right.morphs["weapon_scale"] = 0.5
	right.tags.append("rival")
	var diff := manager.call("diff_recipes", left, right) as Dictionary
	if not (diff.get("changed_parts", []) as Array).has("Base/Hair"):
		_fail("Recipe diff should report changed part slots.")
		return
	if not (diff.get("changed_palettes", []) as Array).has("hair"):
		_fail("Recipe diff should report changed palettes.")
		return
	if not (diff.get("changed_morphs", []) as Array).has("weapon_scale"):
		_fail("Recipe diff should report changed morphs.")
		return
	if not (diff.get("tags_added", []) as Array).has("rival"):
		_fail("Recipe diff should report added tags.")
		return

func _assert_manager_uses_recipe_custom_export_sets() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("save_custom_export_set") or not manager.has_method("custom_export_set_ids"):
		_fail("Creator manager should expose custom export set helpers.")
		return
	var recipe: CC2DRecipe = manager.default_recipe("custom_export")
	var save_report := manager.call("save_custom_export_set", recipe, "duel", ["idle", "run", "melee_1"], "Duel", "gameplay") as Dictionary
	if not bool(save_report.get("ok", false)) or not recipe.custom_export_sets.has("duel"):
		_fail("Creator manager should save recipe-owned custom export sets.")
		return
	if not (manager.call("custom_export_set_ids", recipe) as Array).has("duel"):
		_fail("Creator manager should list recipe-owned custom export sets.")
		return
	var plan := manager.export_plan_for_recipe(recipe, "duel")
	var animations := plan.get("animations", []) as Array
	if str(plan.get("set_id", "")) != "duel" or animations.size() != 3:
		_fail("Export plans should resolve recipe-owned custom export sets.")
		return
	var validation := manager.validate_recipe(recipe, "duel")
	if not bool(validation.get("valid", false)) or int((validation.get("coverage", {}) as Dictionary).get("checked", 0)) != 3:
		_fail("Validation should use recipe-owned custom export sets.")
		return

func _assert_manager_repairs_missing_parts() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	var recipe: CC2DRecipe = manager.default_recipe("broken")
	recipe.parts["Base/Hair"] = {
		"path": "res://missing/hair.png",
		"relative_path": "Sprites/Base/Hair/Missing.png",
	}
	var repair_report := manager.repair_recipe(recipe)
	if not bool(repair_report.get("changed", false)):
		_fail("Repair should replace missing selected parts with compatible fallbacks.")
		return
	var hair := recipe.parts.get("Base/Hair", {}) as Dictionary
	if str(hair.get("path", "")).find("res://") != 0 or not FileAccess.file_exists(str(hair.get("path", ""))):
		_fail("Repair should leave the recipe with a loadable fallback hair part.")
		return
	if not (repair_report.get("warnings", []) as Array).any(func(item: Variant) -> bool: return str(item).contains("Base/Hair")):
		_fail("Repair report should identify the repaired slot.")
		return

func _assert_manager_reports_export_readiness() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	var recipe: CC2DRecipe = manager.default_recipe("export_ready")
	var plan := manager.export_plan_for_recipe(recipe, "movement")
	if str(plan.get("set_id", "")) != "movement":
		_fail("Export plan should preserve the requested set id.")
		return
	if (plan.get("animations", []) as Array).size() < 5:
		_fail("Export plan should include checklist animations.")
		return
	if not (plan.get("provenance", {}) as Dictionary).has("recipe_id"):
		_fail("Export plan should include recipe provenance.")
		return
	if not plan.has("sockets"):
		_fail("Export plan should include socket metadata for export consumers.")
		return

func _assert_manager_reports_equipment_sockets() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("socket_report_for_recipe"):
		_fail("Creator manager should expose socket_report_for_recipe().")
		return
	var recipe: CC2DRecipe = manager.default_recipe("socket_report")
	var report := manager.call("socket_report_for_recipe", recipe, "run") as Dictionary
	if str(report.get("animation_id", "")) != "run":
		_fail("Socket report should preserve the requested animation id.")
		return
	var sockets := report.get("sockets", {}) as Dictionary
	for socket_id: String in ["main_hand", "off_hand", "head", "chest", "back"]:
		if not sockets.has(socket_id):
			_fail("Socket report should include socket: " + socket_id)
			return
		var socket := sockets.get(socket_id, {}) as Dictionary
		for key: String in ["slot", "anchor", "offset", "compatible_tags", "sampled_offset"]:
			if not socket.has(key):
				_fail("Socket report entries should include " + key + ".")
				return
	var partial_recipe: CC2DRecipe = manager.default_recipe("partial_socket_report")
	partial_recipe.equipment_sockets = {
		"main_hand": {
			"slot": "Fantasy/Weapon",
			"anchor": "weapon",
			"offset": {"x": 9.0, "y": -3.0},
			"compatible_tags": ["weapon"],
		},
	}
	var partial_report := manager.call("socket_report_for_recipe", partial_recipe, "idle") as Dictionary
	var repaired_sockets := partial_report.get("sockets", {}) as Dictionary
	for socket_id: String in ["main_hand", "off_hand", "head", "chest", "back"]:
		if not repaired_sockets.has(socket_id):
			_fail("Socket reports should backfill missing default sockets for partial recipes.")
			return
	if float(((repaired_sockets.get("main_hand", {}) as Dictionary).get("offset", {}) as Dictionary).get("x", 0.0)) != 9.0:
		_fail("Socket report should preserve explicit partial socket metadata while backfilling defaults.")
		return

func _assert_manager_reports_accessibility_and_budget_warnings() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	var recipe: CC2DRecipe = manager.default_recipe("warnings")
	recipe.palettes["hair"] = "111111ff"
	recipe.palettes["cloth_primary"] = "121212ff"
	var report := manager.validate_recipe(recipe, "movement")
	var warnings := report.get("warnings", []) as Array
	if not warnings.any(func(item: Variant) -> bool: return str(item).contains("contrast")):
		_fail("Validation should warn about low-contrast palette choices.")
		return
	var budget := report.get("budget", {}) as Dictionary
	if int(budget.get("estimated_pixels", 0)) <= 0 or int(budget.get("estimated_bytes", 0)) <= 0:
		_fail("Validation should include export memory budget estimates.")
		return
	if not manager.has_method("compatibility_report"):
		_fail("Creator manager should expose compatibility_report().")
		return
	var compatibility := manager.call("compatibility_report", recipe, "movement") as Dictionary
	var expected_categories := [
		"clipping",
		"weapon_alignment",
		"silhouette_readability",
		"frame_bounds",
		"camera_zoom",
		"hitbox_compatibility",
	]
	for category_id: String in expected_categories:
		if not compatibility.has(category_id) or not compatibility.get(category_id) is Dictionary:
			_fail("Compatibility report should include category dictionary: " + category_id)
			return
		var category := compatibility.get(category_id) as Dictionary
		if not category.has("severity") or not category.has("messages"):
			_fail("Compatibility category should include severity and messages: " + category_id)
			return
	var constraints := report.get("constraints", {}) as Dictionary
	for category_id: String in expected_categories:
		if not constraints.has(category_id) or not constraints.get(category_id) is Dictionary:
			_fail("Validation should include constraint category dictionary: " + category_id)
			return

func _assert_manager_writes_validation_reports() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("write_validation_report"):
		_fail("Creator manager should expose write_validation_report().")
		return
	var recipe: CC2DRecipe = manager.default_recipe("validation_report")
	var report_path := "user://test_cc2d_validation_report.json"
	var report := manager.call("write_validation_report", recipe, report_path, "movement") as Dictionary
	if not bool(report.get("ok", false)):
		_fail("Creator manager should write validation reports: " + str(report.get("errors", [])))
		return
	if not FileAccess.file_exists(report_path):
		_fail("Validation report should write a JSON file.")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(report_path))
	if not parsed is Dictionary:
		_fail("Validation report should be JSON object data.")
		return
	var parsed_report := parsed as Dictionary
	if not parsed_report.has("validation") or not parsed_report.has("export_plan") or str(parsed_report.get("recipe_id", "")) != recipe.recipe_id:
		_fail("Validation report should include recipe id, validation, and export plan data.")
		return

func _assert_manager_bakes_export_sheet_source_spec() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("bake_export_sheets"):
		_fail("Creator manager should expose bake_export_sheets().")
		return
	var recipe: CC2DRecipe = manager.default_recipe("bake_ready")
	var output_root := "user://test_cc2d_bake_manager"
	var report := manager.bake_export_sheets(recipe, output_root, "movement", 2)
	if not bool(report.get("ok", false)):
		_fail("Creator manager should bake export sheets: " + str(report.get("errors", [])))
		return
	var animations := report.get("animations", []) as Array
	if animations.size() < 5:
		_fail("Baked export report should include movement animations.")
		return
	var first_animation := animations[0] as Dictionary
	var sheet_path := str(first_animation.get("sheet", ""))
	if sheet_path.is_empty() or not FileAccess.file_exists(sheet_path):
		_fail("Baked export should write animation sheet PNG files.")
		return
	var image := Image.new()
	if image.load(sheet_path) != OK or image.get_width() <= 0 or image.get_height() <= 0:
		_fail("Baked animation sheet should be a loadable PNG image.")
		return
	var source_spec_path := str(report.get("source_spec", ""))
	if source_spec_path.is_empty() or not FileAccess.file_exists(source_spec_path):
		_fail("Baked export should write a source_spec.json for the SpriteFrames importer.")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(source_spec_path))
	if not parsed is Dictionary or (parsed as Dictionary).get("animations", []) == []:
		_fail("Baked source_spec.json should list exported animations.")
		return
	var run_animation := _animation_report_by_id(animations, "run")
	if run_animation.is_empty() or not bool(run_animation.get("uses_rig_motion", false)) or int(run_animation.get("rig_sample_count", 0)) <= 0:
		_fail("Baked run report should include sampled imported rig motion.")
		return
	if not bool(run_animation.get("uses_pixel_rotation", false)) or int(run_animation.get("pixel_rotation_count", 0)) <= 0:
		_fail("Baked run report should include pixel-rotated rig parts.")
		return
	var run_sheet := Image.new()
	if run_sheet.load(str(run_animation.get("sheet", ""))) != OK:
		_fail("Baked run sheet should load for frame comparison.")
		return
	var run_frame_width := int(run_animation.get("frame_width", 0))
	var run_frame_height := int(run_animation.get("frame_height", 0))
	if _image_regions_equal(
		run_sheet,
		Rect2i(0, 0, run_frame_width, run_frame_height),
		Rect2i(run_frame_width, 0, run_frame_width, run_frame_height)
	):
		_fail("Baked run sheet should contain distinct rig-sampled frames.")
		return
	var spriteframes_path := "user://test_cc2d_bake_manager_frames_%d.tres" % Time.get_ticks_usec()
	var frames_report := manager.bake_export_spriteframes(recipe, output_root, spriteframes_path, "movement", 1)
	if not bool(frames_report.get("ok", false)):
		_fail("Creator manager should bake SpriteFrames resources: " + str(frames_report.get("errors", [])))
		return
	if recipe.generated_spriteframes_path != spriteframes_path:
		_fail("Baking SpriteFrames should record the generated path on the recipe.")
		return
	var frames := load(spriteframes_path) as SpriteFrames
	if frames == null or not frames.has_animation("idle") or not frames.has_animation("run"):
		_fail("Baked SpriteFrames should load with exported animations.")
		return
	if frames.get_frame_count("idle") <= 0:
		_fail("Baked SpriteFrames animations should include frames.")
		return

func _assert_manager_bakes_export_target_images() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("bake_export_target"):
		_fail("Creator manager should expose bake_export_target().")
		return
	var recipe: CC2DRecipe = manager.default_recipe("target_bake")
	var targets := {
		"portrait": 256,
		"avatar": 128,
		"icon": 64,
	}
	for target_id: String in targets.keys():
		var output_path := "user://test_cc2d_%s.png" % target_id
		if FileAccess.file_exists(output_path):
			DirAccess.remove_absolute(output_path)
		var report := manager.call("bake_export_target", recipe, output_path, target_id) as Dictionary
		if not bool(report.get("ok", false)):
			_fail("Creator manager should bake %s export target: %s" % [target_id, str(report.get("errors", []))])
			return
		if str(report.get("target", "")) != target_id or str(report.get("path", "")) != output_path:
			_fail("Baked target report should identify the target and output path.")
			return
		if int(report.get("width", 0)) != int(targets[target_id]) or int(report.get("height", 0)) != int(targets[target_id]):
			_fail("Baked target report should include %s dimensions." % target_id)
			return
		if not FileAccess.file_exists(output_path):
			_fail("Baked %s export target should write a PNG file." % target_id)
			return
		var image := Image.new()
		if image.load(output_path) != OK or image.get_width() != int(targets[target_id]) or image.get_height() != int(targets[target_id]):
			_fail("Baked %s export target should be a %dx%d PNG." % [target_id, int(targets[target_id]), int(targets[target_id])])
			return

func _assert_manager_rotates_baked_parts() -> void:
	var manager := CC2DCreatorManager.new()
	if not manager.has_method("_rotate_image_nearest"):
		_fail("Creator manager should expose nearest-neighbor image rotation for baked rig parts.")
		return
	var source := Image.create(3, 5, false, Image.FORMAT_RGBA8)
	source.fill(Color(0, 0, 0, 0))
	source.set_pixel(1, 0, Color.WHITE)
	source.set_pixel(1, 1, Color.WHITE)
	source.set_pixel(1, 2, Color.WHITE)
	var rotated := manager.call("_rotate_image_nearest", source, 90.0) as Image
	if rotated == null:
		_fail("Nearest-neighbor rotation should return an Image.")
		return
	if rotated.get_width() <= source.get_width() or rotated.get_height() >= source.get_height():
		_fail("A 90 degree rotation should swap the visible image orientation.")
		return
	if _opaque_pixel_count(rotated) != 3:
		_fail("Nearest-neighbor rotation should preserve opaque source pixels.")
		return

func _assert_manager_bakes_contact_sheet() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("bake_contact_sheet"):
		_fail("Creator manager should expose bake_contact_sheet().")
		return
	var recipe: CC2DRecipe = manager.default_recipe("contact_sheet")
	var contact_sheet_path := "user://test_cc2d_contact_sheet.png"
	var report := manager.call("bake_contact_sheet", recipe, contact_sheet_path, "movement", 2) as Dictionary
	if not bool(report.get("ok", false)):
		_fail("Creator manager should bake contact sheets: " + str(report.get("errors", [])))
		return
	if not FileAccess.file_exists(contact_sheet_path):
		_fail("Contact sheet bake should write a PNG file.")
		return
	var image := Image.new()
	if image.load(contact_sheet_path) != OK or image.get_width() <= 512 or image.get_height() <= 512:
		_fail("Contact sheet PNG should include multiple animation frames.")
		return
	if int(report.get("frames", 0)) < 4:
		_fail("Contact sheet report should count exported preview frames.")
		return

func _assert_headless_export_cli_writes_batch_outputs() -> void:
	if not ResourceLoader.exists(CC2D_EXPORT_CLI_PATH):
		_fail("Headless CC2D export CLI script should exist.")
		return
	var output_root := "user://test_cc2d_cli_export"
	var spriteframes_path := "user://test_cc2d_cli_frames.tres"
	var contact_sheet_path := "user://test_cc2d_cli_contact.png"
	var validation_report_path := "user://test_cc2d_cli_validation.json"
	var recipe_path := "user://test_cc2d_cli_recipe.json"
	var bundle_path := "user://test_cc2d_cli_bundle.json"
	var portrait_path := "user://test_cc2d_cli_portrait.png"
	var avatar_path := "user://test_cc2d_cli_avatar.png"
	var icon_path := "user://test_cc2d_cli_icon.png"
	var output: Array = []
	var exit_code := OS.execute(
		"godot",
		[
			"--headless",
			"--path",
			ProjectSettings.globalize_path("res://"),
			"--script",
			ProjectSettings.globalize_path(CC2D_EXPORT_CLI_PATH),
			"--",
			"--recipe-out",
			recipe_path,
			"--bundle-out",
			bundle_path,
			"--output-root",
			output_root,
			"--spriteframes",
			spriteframes_path,
			"--contact-sheet",
			contact_sheet_path,
			"--portrait",
			portrait_path,
			"--avatar",
			avatar_path,
			"--icon",
			icon_path,
			"--validation-report",
			validation_report_path,
			"--set-id",
			"movement",
			"--max-frames",
			"2",
		],
		output,
		true
	)
	if exit_code != 0:
		_fail("Headless CC2D export CLI should exit successfully: " + "\n".join(_string_array(output)))
		return
	if not FileAccess.file_exists(recipe_path) or not FileAccess.file_exists("%s/source_spec.json" % output_root):
		_fail("Headless CC2D export CLI should write recipe and source spec outputs.")
		return
	if not FileAccess.file_exists(bundle_path):
		_fail("Headless CC2D export CLI should write recipe bundle outputs.")
		return
	if not FileAccess.file_exists(contact_sheet_path) or not FileAccess.file_exists(validation_report_path):
		_fail("Headless CC2D export CLI should write contact sheet and validation report outputs.")
		return
	if not FileAccess.file_exists(portrait_path) or not FileAccess.file_exists(avatar_path) or not FileAccess.file_exists(icon_path):
		_fail("Headless CC2D export CLI should write portrait, avatar, and icon outputs.")
		return
	var frames := load(spriteframes_path) as SpriteFrames
	if frames == null or not frames.has_animation("run"):
		_fail("Headless CC2D export CLI should write loadable SpriteFrames.")
		return
	var output_text := "\n".join(_string_array(output))
	if output_text.find("cc2d_export_summary=") < 0:
		_fail("Headless CC2D export CLI should print a machine-readable summary.")
		return
	if output_text.find("\"portrait\"") < 0 or output_text.find("\"avatar\"") < 0 or output_text.find("\"icon\"") < 0:
		_fail("Headless CC2D export CLI summary should include portrait, avatar, and icon outputs.")
		return

func _assert_manager_randomizes_recipes_with_locks_and_tags() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("randomize_recipe") or not manager.has_method("random_recipe"):
		_fail("Creator manager should expose random recipe helpers.")
		return
	var recipe: CC2DRecipe = manager.default_recipe("randomized")
	var locked_hair := (recipe.parts.get("Base/Hair", {}) as Dictionary).duplicate(true)
	var report := manager.randomize_recipe(recipe, ["Base/Hair"], ["starter_safe"], 42)
	if not (report.get("locked_slots", []) as Array).has("Base/Hair"):
		_fail("Randomizer report should include locked slots.")
		return
	if str((recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", "")) != str(locked_hair.get("path", "")):
		_fail("Randomizer should preserve locked slot selections.")
		return
	if not recipe.tags.has("starter_safe"):
		_fail("Randomizer should preserve required tags on the recipe.")
		return
	var armor := recipe.parts.get("Fantasy/Armor", {}) as Dictionary
	if not (_string_array(armor.get("tags", [])).has("starter_safe")):
		_fail("Randomizer should choose options carrying required tags when available.")
		return
	var first: CC2DRecipe = manager.random_recipe("seeded_a", "Seeded", {}, ["starter_safe"], 777)
	var second: CC2DRecipe = manager.random_recipe("seeded_b", "Seeded", {}, ["starter_safe"], 777)
	if str((first.parts.get("Base/Hair", {}) as Dictionary).get("path", "")) != str((second.parts.get("Base/Hair", {}) as Dictionary).get("path", "")):
		_fail("Seeded random recipes should be deterministic.")
		return

func _assert_manager_filters_part_options_by_search_and_tags() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("filtered_options_for_slot"):
		_fail("Creator manager should expose filtered_options_for_slot().")
		return
	var all_hair := manager.filtered_options_for_slot("Base/Hair", "", [])
	var numbered_hair := manager.filtered_options_for_slot("Base/Hair", "14", ["starter_safe"])
	if all_hair.size() <= numbered_hair.size():
		_fail("Part option search should reduce matching options for a useful query.")
		return
	if numbered_hair.is_empty():
		_fail("Part option search should find matching hair options.")
		return
	for option: Dictionary in numbered_hair:
		var text := "%s %s" % [str(option.get("label", "")), str(option.get("relative_path", ""))]
		if not text.to_lower().contains("14"):
			_fail("Part option search should only return query-matching options.")
			return
		if not _string_array(option.get("tags", [])).has("starter_safe"):
			_fail("Part option tag filtering should only return matching tags.")
			return
	var favorite_hair := numbered_hair[0] as Dictionary
	var recipe: CC2DRecipe = manager.default_recipe("favorites")
	if not manager.set_part_favorite(recipe, favorite_hair, true):
		_fail("Creator manager should mark part options as favorites on recipes.")
		return
	if not manager.is_part_favorite(recipe, favorite_hair):
		_fail("Creator manager should identify favorite part options.")
		return
	var favorite_matches := manager.filtered_options_for_slot("Base/Hair", "", [], recipe.favorite_part_paths, true)
	if favorite_matches.size() != 1 or str((favorite_matches[0] as Dictionary).get("path", "")) != str(favorite_hair.get("path", "")):
		_fail("Part option filtering should support favorites-only mode.")
		return

func _assert_manager_parses_imported_clip_metadata() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("clip_metadata_for_animation"):
		_fail("Creator manager should expose clip_metadata_for_animation().")
		return
	var run_clip := manager.call("clip_metadata_for_animation", "run") as Dictionary
	if str(run_clip.get("animation_id", "")) != "run":
		_fail("Clip metadata should preserve the requested animation id.")
		return
	if str(run_clip.get("source_path", "")).find("Data/Animations/Base/Run.anim") < 0:
		_fail("Run clip metadata should resolve the imported Unity source animation path.")
		return
	if int(run_clip.get("sample_rate", 0)) != 60:
		_fail("Run clip metadata should parse m_SampleRate from the imported Unity animation.")
		return
	if not is_equal_approx(float(run_clip.get("stop_time", 0.0)), 0.75):
		_fail("Run clip metadata should parse m_StopTime from the imported Unity animation.")
		return
	if int(run_clip.get("frame_count", 0)) < 40:
		_fail("Run clip metadata should derive frame count from sample rate and stop time.")
		return
	var curve_bindings := run_clip.get("curve_bindings", []) as Array
	if curve_bindings.size() < 10:
		_fail("Run clip metadata should parse imported Unity transform curve bindings.")
		return
	var body_binding := {}
	var saw_position_curve := false
	var saw_euler_curve := false
	for binding: Dictionary in curve_bindings:
		if str(binding.get("attribute", "")) == "m_LocalPosition":
			saw_position_curve = true
		if str(binding.get("attribute", "")) == "localEulerAnglesRaw":
			saw_euler_curve = true
		if str(binding.get("part_name", "")) == "Body":
			body_binding = binding
	if not saw_position_curve or not saw_euler_curve:
		_fail("Run clip metadata should preserve vector transform curve attributes.")
		return
	if body_binding.is_empty():
		_fail("Run clip metadata should map Unity bone paths to readable part names.")
		return
	var body_keyframes := body_binding.get("keyframes", []) as Array
	if body_keyframes.is_empty() or not (body_keyframes[0] as Dictionary).has("time"):
		_fail("Run clip curve bindings should include timed keyframes.")
		return
	if not (body_keyframes[0] as Dictionary).has("value"):
		_fail("Run clip curve keyframes should include imported transform values.")
		return

func _assert_manager_parses_part_sprite_metadata() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	if not manager.has_method("sprite_metadata_for_part"):
		_fail("Creator manager should expose sprite_metadata_for_part().")
		return
	var body_part := {
		"path": "res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Base/Body Skin/Bodyset Male.png",
		"relative_path": "Sprites/Base/Body Skin/Bodyset Male.png",
	}
	var metadata := manager.call("sprite_metadata_for_part", body_part) as Dictionary
	if str(metadata.get("meta_path", "")).find("Bodyset Male.png.meta") < 0:
		_fail("Part sprite metadata should resolve the Unity .meta path for the selected part.")
		return
	var sprites := metadata.get("sprites", []) as Array
	if sprites.size() < 10:
		_fail("Bodyset sprite metadata should parse multiple named sprites.")
		return
	var first_sprite := sprites[0] as Dictionary
	if str(first_sprite.get("name", "")) != "Head":
		_fail("Sprite metadata should preserve Unity sprite names.")
		return
	if first_sprite.get("rect") != Rect2(88, 796, 140, 208):
		_fail("Sprite metadata should parse Unity sprite rects.")
		return
	if first_sprite.get("pivot") != Vector2(0.5, 0.5):
		_fail("Sprite metadata should parse Unity sprite pivots.")
		return

func _assert_external_character_studio_shell_uses_manager() -> void:
	if not ResourceLoader.exists(CHARACTER_STUDIO_SCENE_PATH):
		_fail("External Character Studio scene should exist.")
		return
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("get_current_recipe") or not studio.has_method("build_export_plan"):
		_fail("External Character Studio should expose recipe and export-plan helpers.")
		return
	var recipe: CC2DRecipe = studio.call("get_current_recipe")
	if recipe == null or recipe.parts.is_empty():
		_fail("External Character Studio should initialize a manager-backed recipe.")
		return
	var plan := studio.call("build_export_plan", "first_slice_player") as Dictionary
	if (plan.get("animations", []) as Array).is_empty():
		_fail("External Character Studio should build checklist export plans.")
		return
	studio.queue_free()

func _assert_external_character_studio_bakes_export_sheets() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("bake_current_export") or not studio.has_method("bake_current_spriteframes") or not studio.has_method("bake_current_contact_sheet") or not studio.has_method("write_current_validation_report"):
		_fail("External Character Studio should expose bake export helpers.")
		return
	var root_edit := studio.get_node_or_null("%ExportRootEdit") as LineEdit
	var bake_button := studio.get_node_or_null("%BakeExportButton") as Button
	var spriteframes_edit := studio.get_node_or_null("%SpriteFramesPathEdit") as LineEdit
	var bake_frames_button := studio.get_node_or_null("%BakeSpriteFramesButton") as Button
	var contact_sheet_edit := studio.get_node_or_null("%ContactSheetPathEdit") as LineEdit
	var bake_contact_button := studio.get_node_or_null("%BakeContactSheetButton") as Button
	var validation_report_edit := studio.get_node_or_null("%ValidationReportPathEdit") as LineEdit
	var write_report_button := studio.get_node_or_null("%WriteValidationReportButton") as Button
	if root_edit == null or bake_button == null or spriteframes_edit == null or bake_frames_button == null or contact_sheet_edit == null or bake_contact_button == null or validation_report_edit == null or write_report_button == null:
		_fail("External Character Studio should include visible bake export controls.")
		return
	var output_root := "user://test_cc2d_bake_studio"
	root_edit.text = output_root
	bake_button.pressed.emit()
	var source_spec_path := "%s/source_spec.json" % output_root
	if not FileAccess.file_exists(source_spec_path):
		_fail("External Character Studio bake button should write source_spec.json.")
		return
	var report := studio.call("bake_current_export", output_root, "movement", 1) as Dictionary
	if not bool(report.get("ok", false)):
		_fail("External Character Studio should bake current export sheets.")
		return
	var animations := report.get("animations", []) as Array
	if animations.is_empty() or not FileAccess.file_exists(str((animations[0] as Dictionary).get("sheet", ""))):
		_fail("External Character Studio bake report should include sheet PNG files.")
		return
	var spriteframes_path := "user://test_cc2d_bake_studio_frames.tres"
	spriteframes_edit.text = spriteframes_path
	bake_frames_button.pressed.emit()
	var frames := load(spriteframes_path) as SpriteFrames
	if frames == null or not frames.has_animation("idle"):
		_fail("External Character Studio bake frames button should write loadable SpriteFrames.")
		return
	var contact_sheet_path := "user://test_cc2d_bake_studio_contact.png"
	contact_sheet_edit.text = contact_sheet_path
	bake_contact_button.pressed.emit()
	if not FileAccess.file_exists(contact_sheet_path):
		_fail("External Character Studio contact button should write a contact sheet PNG.")
		return
	var contact_report := studio.call("bake_current_contact_sheet", contact_sheet_path, "movement", 2) as Dictionary
	if not bool(contact_report.get("ok", false)) or int(contact_report.get("frames", 0)) < 4:
		_fail("External Character Studio should report contact sheet preview frames.")
		return
	var validation_report_path := "user://test_cc2d_bake_studio_validation.json"
	validation_report_edit.text = validation_report_path
	write_report_button.pressed.emit()
	if not FileAccess.file_exists(validation_report_path):
		_fail("External Character Studio report button should write validation JSON.")
		return
	var validation_report := studio.call("write_current_validation_report", validation_report_path, "movement") as Dictionary
	if not bool(validation_report.get("ok", false)) or not validation_report.has("validation"):
		_fail("External Character Studio should report validation data.")
		return
	studio.queue_free()

func _assert_external_character_studio_edits_recipe() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("get_editable_slot_ids") or not studio.has_method("select_part_option"):
		_fail("External Character Studio should expose part-browser edit helpers.")
		return
	if not studio.has_method("set_palette_color") or not studio.has_method("set_morph_value"):
		_fail("External Character Studio should expose palette and morph edit helpers.")
		return
	if not studio.has_method("select_export_set") or not studio.has_method("get_preview_state"):
		_fail("External Character Studio should expose export-set and preview helpers.")
		return
	if not studio.has_method("save_current_custom_export_set"):
		_fail("External Character Studio should expose custom export-set helpers.")
		return
	if not studio.has_method("save_current_outfit_set") or not studio.has_method("apply_outfit_set"):
		_fail("External Character Studio should expose outfit set helpers.")
		return
	var slot_ids: Array = studio.call("get_editable_slot_ids")
	if not slot_ids.has("Base/Hair") or not slot_ids.has("Fantasy/Armor"):
		_fail("External Character Studio should create editable part slots from the CC2D catalog.")
		return
	var before_recipe: CC2DRecipe = studio.call("get_current_recipe")
	var before_hair := str((before_recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	if not bool(studio.call("select_part_option", "Base/Hair", 1)):
		_fail("External Character Studio should allow changing a part option by slot.")
		return
	var after_recipe: CC2DRecipe = studio.call("get_current_recipe")
	var after_hair := str((after_recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	if before_hair == after_hair:
		_fail("Changing a studio part option should update the current recipe.")
		return
	studio.call("set_palette_color", "hair", "ff3366ff")
	studio.call("set_morph_value", "head_size", 0.25)
	if str(after_recipe.palettes.get("hair", "")) != "ff3366ff":
		_fail("Palette edits should update the current recipe.")
		return
	if not is_equal_approx(float(after_recipe.morphs.get("head_size", 0.0)), 0.25):
		_fail("Morph edits should update the current recipe.")
		return
	var outfit_id_edit := studio.get_node_or_null("%OutfitIdEdit") as LineEdit
	var outfit_label_edit := studio.get_node_or_null("%OutfitLabelEdit") as LineEdit
	var outfit_tag_edit := studio.get_node_or_null("%OutfitTagEdit") as LineEdit
	var save_outfit_button := studio.get_node_or_null("%SaveOutfitButton") as Button
	var apply_outfit_button := studio.get_node_or_null("%ApplyOutfitButton") as Button
	if outfit_id_edit == null or outfit_label_edit == null or outfit_tag_edit == null or save_outfit_button == null or apply_outfit_button == null:
		_fail("External Character Studio should include visible outfit save/apply controls.")
		return
	outfit_id_edit.text = "combat"
	outfit_label_edit.text = "Combat"
	outfit_tag_edit.text = "combat,starter_safe"
	save_outfit_button.pressed.emit()
	studio.call("select_part_option", "Base/Hair", 0)
	apply_outfit_button.pressed.emit()
	var outfit_recipe: CC2DRecipe = studio.call("get_current_recipe")
	if outfit_recipe.active_outfit_id != "combat":
		_fail("Applying a studio outfit set should update active_outfit_id.")
		return
	var outfit_hair := str((outfit_recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	if outfit_hair != after_hair:
		_fail("Applying a studio outfit set should restore saved part selections.")
		return
	var custom_set_id_edit := studio.get_node_or_null("%CustomExportSetIdEdit") as LineEdit
	var custom_set_label_edit := studio.get_node_or_null("%CustomExportSetLabelEdit") as LineEdit
	var custom_set_animation_edit := studio.get_node_or_null("%CustomExportAnimationsEdit") as LineEdit
	var save_custom_set_button := studio.get_node_or_null("%SaveCustomExportSetButton") as Button
	if custom_set_id_edit == null or custom_set_label_edit == null or custom_set_animation_edit == null or save_custom_set_button == null:
		_fail("External Character Studio should include visible custom export-set controls.")
		return
	custom_set_id_edit.text = "duel"
	custom_set_label_edit.text = "Duel"
	custom_set_animation_edit.text = "idle,run,melee_1"
	save_custom_set_button.pressed.emit()
	if not bool(studio.call("select_export_set", "duel")):
		_fail("External Character Studio should allow selecting saved custom export sets.")
		return
	var custom_plan := studio.call("build_export_plan") as Dictionary
	if str(custom_plan.get("set_id", "")) != "duel" or (custom_plan.get("animations", []) as Array).size() != 3:
		_fail("External Character Studio export plans should use saved custom export sets.")
		return
	if not bool(studio.call("select_export_set", "movement")):
		_fail("External Character Studio should allow selecting a checklist export set.")
		return
	var plan := studio.call("build_export_plan") as Dictionary
	if str(plan.get("set_id", "")) != "movement":
		_fail("Export plan should use the selected studio export set.")
		return
	var preview := studio.call("get_preview_state") as Dictionary
	if int(preview.get("part_count", 0)) <= 0 or str(preview.get("active_animation", "")) == "":
		_fail("Preview state should expose recipe part count and active animation.")
		return
	var validation_label := studio.get_node_or_null("%ValidationLabel") as Label
	if validation_label == null or validation_label.text.is_empty():
		_fail("External Character Studio should show validation status.")
		return
	studio.queue_free()

func _assert_external_character_studio_filters_part_browser() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("filter_part_browser") or not studio.has_method("set_part_favorite"):
		_fail("External Character Studio should expose filter_part_browser().")
		return
	var search_edit := studio.get_node_or_null("%PartSearchEdit") as LineEdit
	var tag_edit := studio.get_node_or_null("%PartTagFilterEdit") as LineEdit
	var favorite_check := studio.get_node_or_null("%FavoriteOnlyCheck") as CheckBox
	if search_edit == null or tag_edit == null or favorite_check == null:
		_fail("External Character Studio should include visible part search, tag filter, and favorite controls.")
		return
	var all_count := int(studio.call("filter_part_browser", "", []))
	search_edit.text = "14"
	tag_edit.text = "starter_safe"
	var filtered_count := int(studio.call("filter_part_browser", "14", ["starter_safe"]))
	if filtered_count <= 0 or filtered_count >= all_count:
		_fail("External Character Studio part filters should reduce visible part options.")
		return
	if not bool(studio.call("select_part_option", "Base/Hair", 0)):
		_fail("Filtered Character Studio part browser should still allow selecting catalog parts.")
		return
	if not bool(studio.call("set_part_favorite", "Base/Hair", 0, true)):
		_fail("External Character Studio should allow marking visible parts as favorites.")
		return
	var favorite_count := int(studio.call("filter_part_browser", "", [], true))
	if favorite_count != 1:
		_fail("External Character Studio favorites-only filter should show favorited parts.")
		return
	studio.queue_free()

func _assert_external_character_studio_saves_and_loads_recipe() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("save_current_recipe") or not studio.has_method("load_recipe_from_path") or not studio.has_method("export_current_recipe_bundle") or not studio.has_method("import_recipe_bundle_from_path"):
		_fail("External Character Studio should expose recipe save/load helpers.")
		return
	var path_edit := studio.get_node_or_null("%RecipePathEdit") as LineEdit
	var save_button := studio.get_node_or_null("%SaveRecipeButton") as Button
	var load_button := studio.get_node_or_null("%LoadRecipeButton") as Button
	var bundle_edit := studio.get_node_or_null("%BundlePathEdit") as LineEdit
	var export_bundle_button := studio.get_node_or_null("%ExportBundleButton") as Button
	var import_bundle_button := studio.get_node_or_null("%ImportBundleButton") as Button
	if path_edit == null or save_button == null or load_button == null or bundle_edit == null or export_bundle_button == null or import_bundle_button == null:
		_fail("External Character Studio should include visible recipe save/load controls.")
		return
	studio.call("set_palette_color", "hair", "112233ff")
	studio.call("set_morph_value", "weapon_scale", 0.35)
	studio.call("select_part_option", "Base/Hair", 1)
	var before_recipe: CC2DRecipe = studio.call("get_current_recipe")
	var before_hair := str((before_recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	var path := "user://test_character_studio_recipe.json"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	path_edit.text = path
	save_button.pressed.emit()
	if not FileAccess.file_exists(path):
		_fail("External Character Studio save button should write the active recipe JSON.")
		return
	studio.call("set_palette_color", "hair", "ffffffff")
	studio.call("set_morph_value", "weapon_scale", -0.5)
	studio.call("select_part_option", "Base/Hair", 0)
	load_button.pressed.emit()
	var loaded_recipe: CC2DRecipe = studio.call("get_current_recipe")
	if str(loaded_recipe.palettes.get("hair", "")) != "112233ff":
		_fail("Loaded studio recipe should restore palette edits.")
		return
	if not is_equal_approx(float(loaded_recipe.morphs.get("weapon_scale", 0.0)), 0.35):
		_fail("Loaded studio recipe should restore morph edits.")
		return
	var loaded_hair := str((loaded_recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	if loaded_hair != before_hair:
		_fail("Loaded studio recipe should restore selected parts.")
		return
	var preview := studio.call("get_preview_state") as Dictionary
	if (preview.get("rendered_part_paths", []) as Array).is_empty():
		_fail("Loading a studio recipe should refresh the layered preview.")
		return
	var bundle_path := "user://test_character_studio_bundle.json"
	bundle_edit.text = bundle_path
	export_bundle_button.pressed.emit()
	if not FileAccess.file_exists(bundle_path):
		_fail("External Character Studio bundle export button should write bundle JSON.")
		return
	studio.call("set_palette_color", "hair", "000000ff")
	import_bundle_button.pressed.emit()
	var bundled_recipe: CC2DRecipe = studio.call("get_current_recipe")
	if str(bundled_recipe.palettes.get("hair", "")) != "112233ff":
		_fail("External Character Studio bundle import should restore the embedded recipe.")
		return
	DirAccess.remove_absolute(path)
	DirAccess.remove_absolute(bundle_path)
	studio.queue_free()

func _assert_external_character_studio_randomizes_recipe() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("randomize_current_recipe"):
		_fail("External Character Studio should expose randomize_current_recipe().")
		return
	var tag_edit := studio.get_node_or_null("%RandomTagEdit") as LineEdit
	var lock_edit := studio.get_node_or_null("%RandomLockEdit") as LineEdit
	var seed_spin := studio.get_node_or_null("%RandomSeedSpin") as SpinBox
	var randomize_button := studio.get_node_or_null("%RandomizeButton") as Button
	if tag_edit == null or lock_edit == null or seed_spin == null or randomize_button == null:
		_fail("External Character Studio should include visible randomizer controls.")
		return
	var before_recipe: CC2DRecipe = studio.call("get_current_recipe")
	var locked_hair := str((before_recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	var report := studio.call("randomize_current_recipe", ["Base/Hair"], ["starter_safe"], 99) as Dictionary
	if not (report.get("locked_slots", []) as Array).has("Base/Hair"):
		_fail("Studio randomizer should return locked slot information.")
		return
	var after_recipe: CC2DRecipe = studio.call("get_current_recipe")
	if str((after_recipe.parts.get("Base/Hair", {}) as Dictionary).get("path", "")) != locked_hair:
		_fail("Studio randomizer should preserve locked slot selections.")
		return
	tag_edit.text = "starter_safe"
	lock_edit.text = "Base/Hair"
	seed_spin.value = 1002
	var before_hair_path := str(((studio.call("get_current_recipe") as CC2DRecipe).parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	randomize_button.pressed.emit()
	var after_preview := studio.call("get_preview_state") as Dictionary
	if (after_preview.get("rendered_part_paths", []) as Array).is_empty():
		_fail("Studio randomize button should refresh the preview with new part selections.")
		return
	var after_hair_path := str(((studio.call("get_current_recipe") as CC2DRecipe).parts.get("Base/Hair", {}) as Dictionary).get("path", ""))
	if after_hair_path != before_hair_path:
		_fail("Studio randomize button should honor visible locked-slot input.")
		return
	studio.queue_free()

func _assert_external_character_studio_renders_layered_preview() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("refresh_preview"):
		_fail("External Character Studio should expose refresh_preview for layered rig rendering.")
		return
	studio.call("refresh_preview")
	var preview_layer := studio.get_node_or_null("%LayeredPreview") as Control
	if preview_layer == null:
		_fail("External Character Studio should include a LayeredPreview control.")
		return
	if preview_layer.get_child_count() < 3:
		_fail("Layered preview should render multiple selected recipe parts.")
		return
	var preview := studio.call("get_preview_state") as Dictionary
	var rendered_paths := preview.get("rendered_part_paths", []) as Array
	if rendered_paths.size() < 3:
		_fail("Preview state should list rendered part paths.")
		return
	for child: Node in preview_layer.get_children():
		if not child is TextureRect:
			continue
		var texture_rect := child as TextureRect
		if texture_rect.texture == null:
			_fail("Layered preview TextureRects should load selected part textures.")
			return
		if texture_rect.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
			_fail("Layered preview should use nearest filtering for pixel-art parts.")
			return
	var before_paths := rendered_paths.duplicate()
	studio.call("select_part_option", "Base/Hair", 1)
	var after_preview := studio.call("get_preview_state") as Dictionary
	var after_paths := after_preview.get("rendered_part_paths", []) as Array
	if before_paths == after_paths:
		_fail("Layered preview should update rendered paths after part edits.")
		return
	studio.queue_free()

func _assert_external_character_studio_animation_preview_controls() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	for method_name: String in ["get_available_animation_ids", "select_animation", "step_preview_frame", "set_preview_frame", "set_preview_playing", "set_preview_speed", "set_preview_flipped", "advance_preview_time", "set_preview_alignment"]:
		if not studio.has_method(method_name):
			_fail("External Character Studio should expose animation preview helper: " + method_name)
			return
	if studio.get_node_or_null("%FrameScrubber") == null or studio.get_node_or_null("%PlaybackSpeedSpin") == null or studio.get_node_or_null("%FlipPreviewCheck") == null:
		_fail("External Character Studio should include scrubber, speed, and flip preview controls.")
		return
	var animation_ids: Array = studio.call("get_available_animation_ids")
	if not animation_ids.has("idle") or not animation_ids.has("run"):
		_fail("Animation preview should expose available game animation ids.")
		return
	if not bool(studio.call("select_animation", "run")):
		_fail("Animation preview should allow selecting an available animation.")
		return
	var preview := studio.call("get_preview_state") as Dictionary
	if str(preview.get("active_animation", "")) != "run":
		_fail("Preview state should track the selected animation.")
		return
	if int(preview.get("frame_index", -1)) != 0:
		_fail("Selecting an animation should reset the preview frame index.")
		return
	studio.call("step_preview_frame", 1)
	preview = studio.call("get_preview_state") as Dictionary
	if int(preview.get("frame_index", -1)) != 1:
		_fail("Frame stepping should advance the preview frame index.")
		return
	studio.call("set_preview_frame", 3)
	preview = studio.call("get_preview_state") as Dictionary
	if int(preview.get("frame_index", -1)) != 3:
		_fail("Frame scrubber helper should set the preview frame index.")
		return
	studio.call("set_preview_speed", 24.0)
	studio.call("set_preview_flipped", true)
	preview = studio.call("get_preview_state") as Dictionary
	if not is_equal_approx(float(preview.get("preview_fps", 0.0)), 24.0):
		_fail("Preview state should expose playback speed.")
		return
	if not bool(preview.get("flipped", false)):
		_fail("Preview state should expose horizontal flip state.")
		return
	studio.call("set_preview_playing", true)
	studio.call("advance_preview_time", 1.0)
	preview = studio.call("get_preview_state") as Dictionary
	if not bool(preview.get("playing", false)) or int(preview.get("frame_index", -1)) <= 1:
		_fail("Playback should advance frames while marked playing.")
		return
	studio.call("set_preview_alignment", Vector2(12, -8), 1.5)
	preview = studio.call("get_preview_state") as Dictionary
	if preview.get("alignment_offset", Vector2.ZERO) != Vector2(12, -8):
		_fail("Preview state should expose the alignment offset.")
		return
	if not is_equal_approx(float(preview.get("preview_scale", 0.0)), 1.5):
		_fail("Preview state should expose preview scale.")
		return
	var preview_layer := studio.get_node_or_null("%LayeredPreview") as Control
	if preview_layer == null or preview_layer.get_child_count() == 0:
		_fail("Animation preview needs rendered preview layers.")
		return
	var first_layer := preview_layer.get_child(0) as TextureRect
	if first_layer == null or first_layer.position != Vector2(12, -8) or not is_equal_approx(first_layer.scale.x, -1.5):
		_fail("Alignment controls should apply offset and scale to rendered preview layers.")
		return
	studio.call("set_preview_flipped", true)
	if not is_equal_approx(first_layer.scale.x, -1.5):
		_fail("Flip controls should mirror rendered preview layers horizontally.")
		return
	studio.queue_free()

func _assert_external_character_studio_frame_metadata_preview() -> void:
	var scene := load(CHARACTER_STUDIO_SCENE_PATH) as PackedScene
	var studio := scene.instantiate() as Control
	root.add_child(studio)
	if not studio.has_method("frame_metadata_for_animation"):
		_fail("External Character Studio should expose frame_metadata_for_animation for frame-accurate preview work.")
		return
	if not studio.has_method("inspect_current_frame_bounds"):
		_fail("External Character Studio should expose inspect_current_frame_bounds for pivot and frame-bound inspection.")
		return
	var frame_bounds_label := studio.get_node_or_null("%FrameBoundsLabel") as Label
	var pivot_x_spin := studio.get_node_or_null("%PivotXSpin") as SpinBox
	var pivot_y_spin := studio.get_node_or_null("%PivotYSpin") as SpinBox
	var apply_pivot_button := studio.get_node_or_null("%ApplyPivotOverrideButton") as Button
	if frame_bounds_label == null or pivot_x_spin == null or pivot_y_spin == null or apply_pivot_button == null:
		_fail("External Character Studio should include visible frame-bound inspector and pivot override controls.")
		return
	if not frame_bounds_label.visible or not pivot_x_spin.visible or not pivot_y_spin.visible or not apply_pivot_button.visible:
		_fail("External Character Studio frame-bound inspector controls should be visible.")
		return
	if not bool(studio.call("select_animation", "run")):
		_fail("Frame metadata preview should allow selecting run.")
		return
	var metadata := studio.call("frame_metadata_for_animation", "run") as Dictionary
	if int(metadata.get("frame_count", 0)) < 2:
		_fail("Run frame metadata should expose multiple frames.")
		return
	if int(metadata.get("sample_rate", 0)) != 60:
		_fail("Studio frame metadata should include imported clip sample rate.")
		return
	if not is_equal_approx(float(metadata.get("stop_time", 0.0)), 0.75):
		_fail("Studio frame metadata should include imported clip stop time.")
		return
	if not bool(metadata.get("uses_imported_part_rects", false)):
		_fail("Studio frame metadata should prefer imported part sprite rects when available.")
		return
	var curve_bindings := metadata.get("curve_bindings", []) as Array
	var frame_curve_samples := metadata.get("frame_curve_samples", []) as Array
	if curve_bindings.size() < 10:
		_fail("Studio frame metadata should include imported rig curve bindings.")
		return
	if frame_curve_samples.size() != int(metadata.get("frame_count", 0)):
		_fail("Studio frame metadata should include sampled rig curves for each frame.")
		return
	var first_samples := frame_curve_samples[0] as Array
	if first_samples.is_empty() or not (first_samples[0] as Dictionary).has("part_name"):
		_fail("Studio frame metadata should expose readable per-frame rig samples.")
		return
	var frame_rects := metadata.get("frame_rects", []) as Array
	var pivots := metadata.get("pivots", []) as Array
	if frame_rects.size() != int(metadata.get("frame_count", 0)) or pivots.size() != int(metadata.get("frame_count", 0)):
		_fail("Frame metadata should include a rect and pivot for each frame.")
		return
	if not frame_rects[0] is Rect2 or not pivots[0] is Vector2:
		_fail("Frame metadata should use Rect2 source rects and Vector2 pivots.")
		return
	studio.call("step_preview_frame", 1)
	var preview := studio.call("get_preview_state") as Dictionary
	if not preview.has("source_rect") or not preview.get("source_rect") is Rect2:
		_fail("Preview state should expose the active frame source rect.")
		return
	if not preview.has("pivot") or not preview.get("pivot") is Vector2:
		_fail("Preview state should expose the active frame pivot.")
		return
	if not preview.has("curve_samples") or (preview.get("curve_samples", []) as Array).is_empty():
		_fail("Preview state should expose active imported rig curve samples.")
		return
	var preview_layer := studio.get_node_or_null("%LayeredPreview") as Control
	if preview_layer == null or preview_layer.get_child_count() == 0:
		_fail("Frame metadata preview needs rendered layers.")
		return
	var first_layer := preview_layer.get_child(0) as TextureRect
	if first_layer == null:
		_fail("Frame metadata preview should render TextureRect layers.")
		return
	var source_rect := preview.get("source_rect") as Rect2
	if first_layer.region_rect != source_rect:
		_fail("Rendered preview layers should use the active frame source rect.")
		return
	var pivot := preview.get("pivot") as Vector2
	if first_layer.pivot_offset != pivot:
		_fail("Rendered preview layers should use the active frame pivot.")
		return
	var bounds := studio.call("inspect_current_frame_bounds") as Dictionary
	for key: String in ["source_rect", "pivot", "opaque_bounds", "cropped", "wasted_padding_pixels", "frame_width", "frame_height"]:
		if not bounds.has(key):
			_fail("Frame-bound inspector should include " + key + ".")
			return
	if not bounds.get("source_rect") is Rect2 or not bounds.get("pivot") is Vector2 or not bounds.get("opaque_bounds") is Rect2:
		_fail("Frame-bound inspector should use typed source rect, pivot, and opaque bounds.")
		return
	if int(bounds.get("frame_width", 0)) <= 0 or int(bounds.get("frame_height", 0)) <= 0:
		_fail("Frame-bound inspector should expose positive frame dimensions.")
		return
	pivot_x_spin.value = 7.0
	pivot_y_spin.value = 9.0
	apply_pivot_button.pressed.emit()
	var pivot_preview := studio.call("get_preview_state") as Dictionary
	if pivot_preview.get("pivot") != Vector2(7, 9):
		_fail("Applying a pivot override should update the active preview pivot.")
		return
	if first_layer.pivot_offset != Vector2(7, 9):
		_fail("Applying a pivot override should update rendered preview layer pivots.")
		return
	var overridden_bounds := studio.call("inspect_current_frame_bounds") as Dictionary
	if overridden_bounds.get("pivot") != Vector2(7, 9) or frame_bounds_label.text.is_empty():
		_fail("Applying a pivot override should refresh frame-bound inspector output.")
		return
	studio.queue_free()

func _assert_game_state_preserves_recipe_payload() -> void:
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	var recipe: CC2DRecipe = manager.default_recipe("save_payload")
	var state := GameState.new()
	state.character_recipe_id = recipe.recipe_id
	state.character_recipe = recipe.to_dictionary()
	state.character_creator_content_versions = {
		"base_fantasy": manager.content_version(),
	}
	var loaded: GameState = GameState.from_dictionary(state.to_dictionary())
	if loaded.character_recipe_id != recipe.recipe_id:
		_fail("GameState should preserve character_recipe_id.")
		return
	if str(loaded.character_recipe.get("recipe_id", "")) != recipe.recipe_id:
		_fail("GameState should preserve embedded character recipe data.")
		return
	if str(loaded.character_creator_content_versions.get("base_fantasy", "")) == "":
		_fail("GameState should preserve creator content versions.")
		return

func _animation_report_by_id(animations: Array, animation_id: String) -> Dictionary:
	for animation: Dictionary in animations:
		if str(animation.get("id", "")) == animation_id:
			return animation
	return {}

func _image_regions_equal(image: Image, first_rect: Rect2i, second_rect: Rect2i) -> bool:
	if first_rect.size.x <= 0 or first_rect.size.y <= 0 or second_rect.size.x <= 0 or second_rect.size.y <= 0:
		return false
	if first_rect.position.x + first_rect.size.x > image.get_width() or second_rect.position.x + second_rect.size.x > image.get_width():
		return false
	if first_rect.position.y + first_rect.size.y > image.get_height() or second_rect.position.y + second_rect.size.y > image.get_height():
		return false
	var first := image.get_region(first_rect)
	var second := image.get_region(second_rect)
	return first.get_data() == second.get_data()

func _opaque_pixel_count(image: Image) -> int:
	var count := 0
	for y: int in image.get_height():
		for x: int in image.get_width():
			if image.get_pixel(x, y).a > 0.01:
				count += 1
	return count

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result
