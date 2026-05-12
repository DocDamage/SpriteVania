extends Node2D
class_name PlayableImportTestScene

## Temporary Black Keep playable-candidate import-test arena.
##
## Purpose:
## - Test candidate sprite scale/readability without replacing current playable classes.
## - Provide a consistent traversal/combat layout for SWAT_1, player/samurai,
##   Witch_3, and player_generic.
## - Expose simple candidate coverage data to the editor/debugger.
##
## This scene intentionally does not implement the party system and does not
## replace any current player class. It is a dev/test scene only.

const REPORT_PATH := "res://docs/black_keep/playable_import_test_results.md"
const TILE := 32.0

const CANDIDATES := [
	{
		"id": "arc_gunner_swat_1",
		"title": "The Arc-Gunner",
		"source": "res://SpriteVania Assets/craft pix characters/SWAT_1",
		"expected_mode": "craftpix_128_sheet",
		"expected_assets": {
			"idle": ["Idle.png"],
			"run": ["Run.png"],
			"walk": ["Walk.png"],
			"jump": ["Jump.png"],
			"attack": ["Shot_1.png", "Shot_2.png"],
			"special": ["Special.png", "Recharge.png"],
			"hurt": ["Hurt.png"],
			"death": ["Dead.png"],
		},
		"prototype_decision": "prototype_approved",
		"prototype_notes": "Best current Arc-Gunner read. Needs arc-magic muzzle/VFX pass and projectile-origin tuning.",
	},
	{
		"id": "ronin_player_samurai",
		"title": "The Ronin",
		"source": "res://SpriteVania Assets/player/samurai",
		"expected_mode": "numbered_120_frames",
		"expected_assets": {
			"frame_sequence": ["PNG", "Character color 2/PNG"],
			"sheet": ["Character color 2/Character 120x120.png"],
		},
		"prototype_decision": "prototype_approved",
		"prototype_notes": "Strong Ronin identity. Needs frame-range mapping before production use.",
	},
	{
		"id": "black_witch_witch_3",
		"title": "The Black Witch of Ash",
		"source": "res://SpriteVania Assets/craft pix characters/Witch_3",
		"expected_mode": "craftpix_128_sheet_with_64_charge_exception",
		"expected_assets": {
			"idle": ["Idle.png", "Idle_2.png"],
			"run": ["Run.png"],
			"walk": ["Walk.png"],
			"jump": ["Jump.png"],
			"attack": ["Attack_1.png", "Attack_2.png"],
			"special": ["Special.png", "Charge.png"],
			"hurt": ["Hurt.png"],
			"death": ["Dead.png"],
		},
		"prototype_decision": "prototype_approved",
		"prototype_notes": "Strong Witch candidate. Needs ash VFX overlay; Charge.png may need custom 64px slicing.",
	},
	{
		"id": "iron_knight_player_generic",
		"title": "The Iron Knight technical prototype",
		"source": "res://SpriteVania Assets/player/player_generic",
		"expected_mode": "foldered_128x96_frames",
		"expected_assets": {
			"idle": ["PNG/Idle"],
			"run": ["PNG/Run"],
			"jump": ["PNG/Jump"],
			"attack": ["PNG/Attacks"],
			"climb": ["PNG/Climb"],
			"roll_dash": ["PNG/Roll"],
			"shield": ["PNG/Shield Block"],
			"hurt": ["PNG/Hit"],
			"death": ["PNG/Dead"],
		},
		"prototype_decision": "technical_prototype_only",
		"prototype_notes": "Best technical melee coverage. Reads agile sword/shield more than final Iron Knight; retheme likely required.",
	},
]

@export var write_markdown_report := false
@export var candidate_spacing := 190.0
@export var preview_scale := 1.0

var candidate_results: Array[Dictionary] = []

func _ready() -> void:
	_build_test_arena()
	_build_targets()
	_build_candidate_previews()
	candidate_results = _scan_all_candidates()
	_print_candidate_summary()
	if write_markdown_report:
		_write_markdown_report()

func _build_test_arena() -> void:
	var terrain_root := Node2D.new()
	terrain_root.name = "TraversalAndScaleTests"
	add_child(terrain_root)

	# Flat ground.
	_add_solid_rect(terrain_root, "FlatGround", Vector2(0, 360), Vector2(640, 32), Color(0.18, 0.16, 0.13, 1.0))

	# Jump gap.
	_add_solid_rect(terrain_root, "GapPlatformLeft", Vector2(700, 360), Vector2(160, 32), Color(0.18, 0.16, 0.13, 1.0))
	_add_solid_rect(terrain_root, "GapPlatformRight", Vector2(980, 360), Vector2(200, 32), Color(0.18, 0.16, 0.13, 1.0))
	_add_marker_line(terrain_root, "JumpGapMeasure", Vector2(860, 348), Vector2(980, 348), Color(0.85, 0.62, 0.2, 0.9))

	# Ledge / step-up test.
	_add_solid_rect(terrain_root, "StepLedgeLow", Vector2(1260, 360), Vector2(160, 32), Color(0.18, 0.16, 0.13, 1.0))
	_add_solid_rect(terrain_root, "StepLedgeHigh", Vector2(1420, 296), Vector2(220, 96), Color(0.16, 0.14, 0.12, 1.0))

	# Wall / vertical ascent test.
	_add_solid_rect(terrain_root, "VerticalAscentWall", Vector2(1760, 168), Vector2(36, 224), Color(0.13, 0.14, 0.17, 1.0))
	_add_marker_line(terrain_root, "VerticalAscentMeasure", Vector2(1810, 360), Vector2(1810, 168), Color(0.45, 0.74, 1.0, 0.9))

	# Low ceiling / slide test.
	_add_solid_rect(terrain_root, "SlideFloor", Vector2(2020, 360), Vector2(360, 32), Color(0.18, 0.16, 0.13, 1.0))
	_add_solid_rect(terrain_root, "LowCeiling", Vector2(2140, 272), Vector2(240, 32), Color(0.13, 0.14, 0.17, 1.0))
	_add_marker_line(terrain_root, "SlideClearanceMeasure", Vector2(2140, 344), Vector2(2380, 344), Color(0.9, 0.2, 0.2, 0.9))

	# Camera framing reference.
	var camera := Camera2D.new()
	camera.name = "CameraReference"
	camera.position = Vector2(320, 220)
	camera.zoom = Vector2(1, 1)
	camera.enabled = true
	add_child(camera)

func _build_targets() -> void:
	var target_root := Node2D.new()
	target_root.name = "CombatTargetTests"
	add_child(target_root)

	_add_dummy_target(target_root, "DummyTarget", Vector2(460, 300), Color(0.75, 0.18, 0.18, 1.0))
	_add_dummy_target(target_root, "MovingTargetStart", Vector2(560, 300), Color(0.18, 0.5, 0.85, 1.0))
	_add_marker_line(target_root, "MovingTargetPath", Vector2(520, 340), Vector2(680, 340), Color(0.18, 0.5, 0.85, 0.6))

func _build_candidate_previews() -> void:
	var preview_root := Node2D.new()
	preview_root.name = "CandidatePreviewSlots"
	preview_root.position = Vector2(80, 245)
	add_child(preview_root)

	for index in range(CANDIDATES.size()):
		var candidate: Dictionary = CANDIDATES[index]
		var slot := Node2D.new()
		slot.name = str(candidate["id"])
		slot.position = Vector2(index * candidate_spacing, 0)
		preview_root.add_child(slot)

		var marker := Polygon2D.new()
		marker.name = "ScaleBox"
		marker.polygon = PackedVector2Array([
			Vector2(-32, -96), Vector2(32, -96), Vector2(32, 0), Vector2(-32, 0)
		])
		marker.color = Color(1.0, 1.0, 1.0, 0.06)
		slot.add_child(marker)

		var sprite := Sprite2D.new()
		sprite.name = "PreviewSprite"
		sprite.texture = _find_preview_texture(candidate)
		sprite.centered = true
		sprite.scale = Vector2.ONE * preview_scale
		sprite.position = Vector2(0, -48)
		slot.add_child(sprite)

		if sprite.texture == null:
			var fallback := Polygon2D.new()
			fallback.name = "MissingPreviewFallback"
			fallback.polygon = PackedVector2Array([
				Vector2(-20, -70), Vector2(20, -70), Vector2(20, 0), Vector2(-20, 0)
			])
			fallback.color = Color(0.8, 0.2, 0.2, 0.35)
			slot.add_child(fallback)

func _add_solid_rect(parent: Node, node_name: String, position: Vector2, size: Vector2, color: Color) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = position
	parent.add_child(body)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = size * 0.5
	body.add_child(collision)

	var visual := Polygon2D.new()
	visual.name = "Visual"
	visual.polygon = PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)])
	visual.color = color
	body.add_child(visual)

func _add_marker_line(parent: Node, node_name: String, start: Vector2, end: Vector2, color: Color) -> void:
	var line := Line2D.new()
	line.name = node_name
	line.points = PackedVector2Array([start, end])
	line.width = 2.0
	line.default_color = color
	parent.add_child(line)

func _add_dummy_target(parent: Node, node_name: String, position: Vector2, color: Color) -> void:
	var body := CharacterBody2D.new()
	body.name = node_name
	body.position = position
	parent.add_child(body)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(34, 58)
	collision.shape = shape
	collision.position = Vector2(0, -29)
	body.add_child(collision)

	var visual := Polygon2D.new()
	visual.name = "Visual"
	visual.polygon = PackedVector2Array([Vector2(-17, -58), Vector2(17, -58), Vector2(17, 0), Vector2(-17, 0)])
	visual.color = color
	body.add_child(visual)

func _scan_all_candidates() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for candidate: Dictionary in CANDIDATES:
		results.append(_scan_candidate(candidate))
	return results

func _scan_candidate(candidate: Dictionary) -> Dictionary:
	var source := str(candidate["source"])
	var result := {
		"id": str(candidate["id"]),
		"title": str(candidate["title"]),
		"source": source,
		"source_exists": DirAccess.dir_exists_absolute(source),
		"expected_mode": str(candidate["expected_mode"]),
		"prototype_decision": str(candidate["prototype_decision"]),
		"prototype_notes": str(candidate["prototype_notes"]),
		"coverage": {},
	}

	var expected_assets: Dictionary = candidate["expected_assets"]
	for coverage_key: String in expected_assets.keys():
		var found := false
		var entries: Array = expected_assets[coverage_key]
		for entry: Variant in entries:
			var entry_path := source.path_join(str(entry))
			if ResourceLoader.exists(entry_path) or DirAccess.dir_exists_absolute(entry_path) or FileAccess.file_exists(entry_path):
				found = true
				break
		(result["coverage"] as Dictionary)[coverage_key] = found
	return result

func _find_preview_texture(candidate: Dictionary) -> Texture2D:
	var source := str(candidate["source"])
	var expected_assets: Dictionary = candidate["expected_assets"]
	for entries: Array in expected_assets.values():
		for entry: Variant in entries:
			var path := source.path_join(str(entry))
			if ResourceLoader.exists(path):
				return load(path) as Texture2D
			if DirAccess.dir_exists_absolute(path):
				var dir := DirAccess.open(path)
				if dir == null:
					continue
				dir.list_dir_begin()
				var file_name := dir.get_next()
				while not file_name.is_empty():
					if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
						var frame_path := path.path_join(file_name)
						if ResourceLoader.exists(frame_path):
							return load(frame_path) as Texture2D
					file_name = dir.get_next()
				dir.list_dir_end()
	return null

func _print_candidate_summary() -> void:
	print("Playable import-test candidate scan:")
	for result: Dictionary in candidate_results:
		print("- %s (%s): %s" % [result["title"], result["id"], result["prototype_decision"]])
		print("  source exists: %s" % str(result["source_exists"]))
		print("  coverage: %s" % str(result["coverage"]))

func _write_markdown_report() -> void:
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write playable import-test report: " + REPORT_PATH)
		return
	file.store_string(_markdown_report_text())

func _markdown_report_text() -> String:
	var lines: Array[String] = []
	lines.append("# Playable Import Test Results")
	lines.append("")
	lines.append("Generated by `PlayableImportTestScene`.")
	lines.append("")
	lines.append("| Candidate | Source Exists | Decision | Notes |")
	lines.append("|---|---:|---|---|")
	for result: Dictionary in candidate_results:
		lines.append("| %s | %s | %s | %s |" % [
			str(result["title"]),
			"yes" if bool(result["source_exists"]) else "no",
			str(result["prototype_decision"]),
			str(result["prototype_notes"]).replace("|", "/"),
		])
	lines.append("")
	lines.append("## Coverage")
	for result: Dictionary in candidate_results:
		lines.append("")
		lines.append("### %s" % str(result["title"]))
		lines.append("")
		lines.append("| Expected asset group | Found |")
		lines.append("|---|---:|")
		var coverage: Dictionary = result["coverage"]
		for key: String in coverage.keys():
			lines.append("| %s | %s |" % [key, "yes" if bool(coverage[key]) else "no"])
	return "\n".join(lines) + "\n"
