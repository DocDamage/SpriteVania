extends SceneTree

const CC2DManifest := preload("res://scripts/character_creator/cc2d_manifest.gd")
const CC2DCreatorManager := preload("res://scripts/character_creator/cc2d_creator_manager.gd")
const CC2DExportProfile := preload("res://scripts/character_creator/cc2d_export_profile.gd")
const CC2DBulkExportSets := preload("res://scripts/character_creator/cc2d_bulk_export_sets.gd")
const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const MANIFEST_PATH := "res://resources/character_creator_2d/base_fantasy_manifest.json"
const EXPORT_PROFILE_PATH := "res://resources/character_creator_2d/base_fantasy_export_profile.json"
const TEST_BULK_FRAMES_PATH := "res://resources/character_creator_2d/test_bulk_export_frames.tres"
const TEST_BULK_MANIFEST_PATH := "res://resources/character_creator_2d/test_bulk_export_manifest.json"
const GODOT_TOOL_ROADMAP_PATH := "res://docs/character_creator_2d_godot_tool_roadmap.md"
const REQUIRED_RUNTIME_FILES := [
	"res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Base/Body Skin/Bodyset Male.png",
	"res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Base/Body Skin/Bodyset Female.png",
	"res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Base/Hair/00.png",
	"res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Fantasy/Armor/Fantasy 00 Male.png",
]
const REQUIRED_RAW_PATHS := [
	"Data/Animations/Base/Run.anim",
	"Creator UI/Scripts/UICreator/UICreator.cs",
]

var _failed := false

func _initialize() -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		_fail("CharacterCreator2D Base Fantasy manifest should be generated.")
		return

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if not parsed is Dictionary:
		_fail("CharacterCreator2D Base Fantasy manifest should be valid JSON.")
		return
	var manifest := parsed as Dictionary
	if int(manifest.get("copied_asset_count", 0)) < 1200:
		_fail("CharacterCreator2D import should copy the full package payload, not only selected sprites.")
		return

	var extension_counts := manifest.get("extension_counts", {}) as Dictionary
	for extension: String in [".png", ".cs", ".anim", ".asset", ".prefab"]:
		if int(extension_counts.get(extension, 0)) <= 0:
			_fail("CharacterCreator2D import should include " + extension + " payloads.")
			return

	for file_path: String in REQUIRED_RUNTIME_FILES:
		if not FileAccess.file_exists(file_path):
			_fail("CharacterCreator2D runtime import is missing required file: " + file_path)
			return
		if not ResourceLoader.exists(file_path):
			_fail("CharacterCreator2D sprite should be imported as a Godot texture: " + file_path)
			return

	for raw_path: String in REQUIRED_RAW_PATHS:
		if not _has_raw_reference(manifest, raw_path):
			_fail("CharacterCreator2D import is missing raw Unity reference payload: " + raw_path)
			return

	var loader := CC2DManifest.new()
	if not loader.load_manifest():
		_fail("CC2DManifest should load the generated Base Fantasy manifest.")
		return
	if loader.copied_asset_count() < 1200:
		_fail("CC2DManifest should expose copied asset count.")
		return
	if loader.entries_by_category("Sprites").size() < 500:
		_fail("CC2DManifest should expose sprite category entries.")
		return
	if loader.entries_by_extension(".cs").size() < 90:
		_fail("CC2DManifest should expose Unity script entries for full-port reference.")
		return
	if loader.first_sprite_path("Sprites/Base/Hair/00.png") != "res://SpriteVania Assets/character_creator_2d/base_fantasy_runtime/Sprites/Base/Hair/00.png":
		_fail("CC2DManifest should resolve extracted sprite paths to res:// paths.")
		return
	if not loader.has_method("content_pack_report"):
		_fail("CC2DManifest should expose content_pack_report().")
		return
	var pack_report := loader.call("content_pack_report") as Dictionary
	if str(pack_report.get("pack_id", "")) != "base_fantasy":
		_fail("Content pack report should default the Base Fantasy pack id.")
		return
	if str(pack_report.get("version", "")).is_empty():
		_fail("Content pack report should include a version.")
		return
	if int((pack_report.get("asset_counts", {}) as Dictionary).get("copied", 0)) < 1200:
		_fail("Content pack report should include copied asset counts.")
		return
	if int((pack_report.get("categories", {}) as Dictionary).get("Sprites", 0)) < 400:
		_fail("Content pack report should include category counts.")
		return
	if int((pack_report.get("extensions", {}) as Dictionary).get(".png", 0)) < 500:
		_fail("Content pack report should include extension counts.")
		return
	if not pack_report.get("dependencies", []) is Array or not pack_report.get("migration_ids", []) is Array:
		_fail("Content pack report should include dependency and migration id arrays.")
		return
	if not pack_report.get("conflict_hints", []) is Array or not pack_report.get("missing_dependency_warnings", []) is Array:
		_fail("Content pack report should include conflict hints and missing dependency warnings.")
		return
	_assert_synthetic_content_pack_report_handles_dependencies_and_conflicts()
	if _failed:
		return
	var manager := CC2DCreatorManager.new()
	if not manager.load_content():
		_fail("CC2DCreatorManager should load content before reporting content packs.")
		return
	if not manager.has_method("content_pack_report"):
		_fail("CC2DCreatorManager should expose content_pack_report().")
		return
	var manager_pack_report := manager.call("content_pack_report") as Dictionary
	if str(manager_pack_report.get("pack_id", "")) != str(pack_report.get("pack_id", "")) or int((manager_pack_report.get("asset_counts", {}) as Dictionary).get("entries", 0)) != int((pack_report.get("asset_counts", {}) as Dictionary).get("entries", 0)):
		_fail("Manager content pack report should forward manifest metadata.")
		return
	if not FileAccess.file_exists(EXPORT_PROFILE_PATH):
		_fail("CharacterCreator2D export profile should be generated.")
		return
	var export_profile := CC2DExportProfile.new()
	if not export_profile.load_profile():
		_fail("CC2DExportProfile should load the generated export profile.")
		return
	if export_profile.base_layer_states().size() < 50 or export_profile.aim_layer_states().size() < 10:
		_fail("CC2DExportProfile should expose the Unity base and aim animation export states.")
		return
	if export_profile.all_animation_exports().size() < 68:
		_fail("CC2DExportProfile should expose every CC2D base/aim animation export, not only gameplay aliases.")
		return
	for animation_id: String in ["base:attack_both_hand_3", "base:idle_relaxed", "aim:rapid_shot_rifle", "aim:shot_bow"]:
		if not export_profile.has_available_game_animation(animation_id):
			_fail("CC2DExportProfile should expose complete native animation export: " + animation_id)
			return
	var default_export := export_profile.default_export()
	if int(default_export.get("target_fps", 0)) != 12 or str(default_export.get("export_mode", "")) != "PNGSequence":
		_fail("CC2DExportProfile should preserve the creator's default PNG sequence export shape.")
		return
	for animation_id: String in ["idle", "walk", "run", "jump", "fall", "hurt", "death", "melee_1", "shoot"]:
		if not export_profile.has_available_game_animation(animation_id):
			_fail("CC2DExportProfile should map game animation export: " + animation_id)
			return
	var bulk_sets := CC2DBulkExportSets.new()
	if not bulk_sets.load_sets():
		_fail("CC2DBulkExportSets should load bulk export checklist presets.")
		return
	var first_slice_checklist := bulk_sets.checklist_for_set("first_slice_player", export_profile)
	if first_slice_checklist.size() < 10:
		_fail("First slice bulk export set should include a useful animation checklist.")
		return
	for item: Dictionary in first_slice_checklist:
		if not bool(item.get("available", false)):
			_fail("First slice bulk export item should map to an available CC2D animation: " + str(item.get("id", "")))
			return
	if bulk_sets.checklist_for_set("all_base", export_profile).size() < 54:
		_fail("Bulk export sets should include an all-base checklist.")
		return
	if bulk_sets.checklist_for_set("all_aim", export_profile).size() < 14:
		_fail("Bulk export sets should include an all-aim checklist.")
		return
	if not ResourceLoader.exists(TEST_BULK_FRAMES_PATH):
		_fail("CC2D bulk export importer should generate a loadable SpriteFrames resource.")
		return
	var sprite_frames := load(TEST_BULK_FRAMES_PATH) as SpriteFrames
	if sprite_frames == null:
		_fail("Generated CC2D SpriteFrames fixture should load as SpriteFrames.")
		return
	for animation_id: String in ["idle", "run", "jump"]:
		if not sprite_frames.has_animation(animation_id) or sprite_frames.get_frame_count(animation_id) != 1:
			_fail("Generated CC2D SpriteFrames fixture should include animation: " + animation_id)
			return
	if not FileAccess.file_exists(TEST_BULK_MANIFEST_PATH):
		_fail("CC2D bulk export importer should generate an import manifest.")
		return
	if not FileAccess.file_exists(GODOT_TOOL_ROADMAP_PATH):
		_fail("Godot-native CC2D tool roadmap should exist.")
		return
	var roadmap := FileAccess.get_file_as_string(GODOT_TOOL_ROADMAP_PATH)
	for required_text: String in ["Godot-native runtime rig", "Morphing", "Headless export CLI", "Visual regression tests"]:
		if roadmap.find(required_text) < 0:
			_fail("Godot-native CC2D tool roadmap should include: " + required_text)
			return
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	if not bool(player.call("apply_spriteframes_path", TEST_BULK_FRAMES_PATH)):
		_fail("Player should accept generated CC2D SpriteFrames resources.")
		return
	if player.animated_sprite == null or player.animated_sprite.sprite_frames == null or not player.animated_sprite.sprite_frames.has_animation("idle"):
		_fail("Player should install generated CC2D SpriteFrames on its AnimatedSprite2D.")
		return
	player.queue_free()

	print("PASS: character creator 2d import")
	quit(0)

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)

func _assert_synthetic_content_pack_report_handles_dependencies_and_conflicts() -> void:
	var path := "user://test_cc2d_content_pack_manifest.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_fail("Synthetic content pack manifest should be writable.")
		return
	file.store_string(JSON.stringify({
		"pack_id": "test_pack",
		"version": "2.0.0",
		"dependencies": [{"pack_id": "base_core", "required": true}],
		"migration_ids": ["legacy_test_pack"],
		"entry_count": 2,
		"copied_asset_count": 2,
		"extension_counts": {".png": 2},
		"category_counts": {"Sprites": 2},
		"entries": [
			{
				"guid": "duplicate-guid",
				"relative_path": "Sprites/Test/Dupe.png",
				"godot_path": "SpriteVania Assets/test_pack/Sprites/Test/Dupe.png",
				"extension": ".png",
				"category": "Sprites",
				"has_payload": true,
			},
			{
				"guid": "duplicate-guid",
				"relative_path": "Sprites/Test/Dupe.png",
				"godot_path": "SpriteVania Assets/test_pack/Sprites/Test/Dupe.png",
				"extension": ".png",
				"category": "Sprites",
				"has_payload": true,
			},
		],
	}))
	file = null
	var manifest_loader := CC2DManifest.new()
	if not manifest_loader.load_manifest(path):
		_fail("Synthetic content pack manifest should load.")
		return
	var missing_report := manifest_loader.content_pack_report(["test_pack"])
	if (missing_report.get("missing_dependency_warnings", []) as Array).is_empty():
		_fail("Content pack report should warn about missing required dependencies.")
		return
	if (missing_report.get("conflict_hints", []) as Array).is_empty():
		_fail("Content pack report should include duplicate/conflict hints.")
		return
	if not (missing_report.get("migration_ids", []) as Array).has("legacy_test_pack"):
		_fail("Content pack report should preserve migration ids.")
		return
	var satisfied_report := manifest_loader.content_pack_report(["test_pack", "base_core"])
	if not (satisfied_report.get("missing_dependency_warnings", []) as Array).is_empty():
		_fail("Content pack report should clear dependency warnings for available packs.")
		return

func _has_raw_reference(manifest: Dictionary, relative_path: String) -> bool:
	for entry: Dictionary in manifest.get("entries", []) as Array:
		if str(entry.get("relative_path", "")) == relative_path and str(entry.get("import_role", "")) == "unity_raw":
			return str(entry.get("godot_path", "")).find("base_fantasy_raw") >= 0
	return false
