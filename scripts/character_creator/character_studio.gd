extends Control
class_name CharacterStudio

const CC2DCreatorManager := preload("res://scripts/character_creator/cc2d_creator_manager.gd")
const CC2DPreviewLayer := preload("res://scripts/character_creator/cc2d_preview_layer.gd")
const CC2DRecipe := preload("res://scripts/character_creator/cc2d_recipe.gd")

var _manager := CC2DCreatorManager.new()
var _current_recipe: CC2DRecipe
var _part_option_buttons: Dictionary = {}
var _export_set_id := "first_slice_player"
var _active_animation := "idle"
var _rendered_part_paths: Array[String] = []
var _frame_index := 0
var _frame_count := 1
var _playing := false
var _preview_fps := 12.0
var _playback_accumulator := 0.0
var _alignment_offset := Vector2.ZERO
var _preview_scale := 1.0
var _preview_flipped := false
var _active_source_rect := Rect2(Vector2.ZERO, Vector2.ZERO)
var _active_pivot := Vector2.ZERO
var _active_curve_samples: Array = []
var _recipe_file_controls_wired := false
var _part_filter_query := ""
var _part_filter_tags: Array[String] = []
var _part_filter_favorites_only := false
var _last_operation_report: Dictionary = {}

func _enter_tree() -> void:
	_wire_recipe_file_controls()

func _ready() -> void:
	_ensure_ready()
	_build_editor_controls()
	_sync_summary()

func get_current_recipe() -> CC2DRecipe:
	_ensure_ready()
	return _current_recipe

func get_last_operation_report() -> Dictionary:
	return _last_operation_report.duplicate(true)

func set_current_recipe(recipe: CC2DRecipe) -> void:
	_ensure_ready()
	if recipe == null:
		return
	_current_recipe = recipe
	_manager.repair_recipe(_current_recipe)
	_sync_part_option_buttons_to_recipe()
	_sync_palette_controls_to_recipe()
	_sync_morph_controls_to_recipe()
	refresh_preview()
	_sync_summary()

func save_current_recipe(path: String) -> bool:
	_ensure_ready()
	var ok := _manager.save_recipe(_current_recipe, path)
	_set_operation_report("save_recipe", ok, path, "" if ok else "Save failed")
	return ok

func load_recipe_from_path(path: String) -> bool:
	_ensure_ready()
	var recipe: CC2DRecipe = _manager.load_recipe(path)
	if recipe == null:
		_set_operation_report("load_recipe", false, path, "Load failed")
		return false
	set_current_recipe(recipe)
	_set_operation_report("load_recipe", true, path)
	return true

func export_current_recipe_bundle(path: String, set_id := "first_slice_player") -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	var report := _manager.export_recipe_bundle(_current_recipe, path, requested_set)
	_set_operation_report("export_bundle", bool(report.get("ok", false)), path, _joined_errors(report))
	return report

func import_recipe_bundle_from_path(path: String) -> bool:
	_ensure_ready()
	var recipe: CC2DRecipe = _manager.import_recipe_bundle(path)
	if recipe == null:
		_set_operation_report("import_bundle", false, path, "Import failed")
		return false
	set_current_recipe(recipe)
	_set_operation_report("import_bundle", true, path)
	return true

func save_current_outfit_set(outfit_id: String, label := "", tags := []) -> Dictionary:
	_ensure_ready()
	var report := _manager.save_outfit_set(_current_recipe, outfit_id, label, tags)
	_sync_summary()
	return report

func apply_outfit_set(outfit_id: String) -> Dictionary:
	_ensure_ready()
	var report := _manager.apply_outfit_set(_current_recipe, outfit_id)
	if bool(report.get("ok", false)):
		_sync_part_option_buttons_to_recipe()
		_sync_palette_controls_to_recipe()
		_sync_morph_controls_to_recipe()
		_update_active_frame_metadata()
		refresh_preview()
	_sync_summary()
	return report

func save_current_custom_export_set(set_id: String, animation_ids := [], label := "", target := "gameplay") -> Dictionary:
	_ensure_ready()
	var report := _manager.save_custom_export_set(_current_recipe, set_id, animation_ids, label, target)
	if bool(report.get("ok", false)):
		_build_export_controls()
	_sync_summary()
	return report

func randomize_current_recipe(locked_slots := [], required_tags := [], seed := 0) -> Dictionary:
	_ensure_ready()
	var report := _manager.randomize_recipe(_current_recipe, locked_slots, required_tags, seed)
	_sync_part_option_buttons_to_recipe()
	refresh_preview()
	_sync_summary()
	return report

func filter_part_browser(query := "", required_tags := [], favorites_only := false) -> int:
	_ensure_ready()
	_part_filter_query = str(query)
	_part_filter_tags = _string_array(required_tags)
	_part_filter_favorites_only = bool(favorites_only)
	return _build_part_browser()

func set_part_favorite(slot_id: String, option_index: int, favorite: bool) -> bool:
	_ensure_ready()
	var options := _manager.filtered_options_for_slot(slot_id, _part_filter_query, _part_filter_tags, _current_recipe.favorite_part_paths, _part_filter_favorites_only)
	if option_index < 0 or option_index >= options.size():
		return false
	var changed := _manager.set_part_favorite(_current_recipe, options[option_index] as Dictionary, favorite)
	if changed and _part_filter_favorites_only:
		_build_part_browser()
	_sync_summary()
	return changed

func is_part_favorite(slot_id: String, option_index: int) -> bool:
	_ensure_ready()
	var options := _manager.filtered_options_for_slot(slot_id, _part_filter_query, _part_filter_tags, _current_recipe.favorite_part_paths, _part_filter_favorites_only)
	if option_index < 0 or option_index >= options.size():
		return false
	return _manager.is_part_favorite(_current_recipe, options[option_index] as Dictionary)

func build_export_plan(set_id := "first_slice_player") -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	return _manager.export_plan_for_recipe(_current_recipe, requested_set)

func bake_current_export(output_root: String, set_id := "first_slice_player", max_frames_per_animation := 1) -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	var report := _manager.bake_export_sheets(_current_recipe, output_root, requested_set, max_frames_per_animation)
	_set_operation_report("bake_export", bool(report.get("ok", false)), output_root, _joined_errors(report))
	return report

func bake_current_spriteframes(output_root: String, spriteframes_path: String, set_id := "first_slice_player", max_frames_per_animation := 1) -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	var report := _manager.bake_export_spriteframes(_current_recipe, output_root, spriteframes_path, requested_set, max_frames_per_animation)
	_set_operation_report("bake_spriteframes", bool(report.get("ok", false)), spriteframes_path, _joined_errors(report))
	return report

func bake_current_contact_sheet(contact_sheet_path: String, set_id := "first_slice_player", max_frames_per_animation := 2) -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	var report := _manager.bake_contact_sheet(_current_recipe, contact_sheet_path, requested_set, max_frames_per_animation)
	_set_operation_report("bake_contact_sheet", bool(report.get("ok", false)), contact_sheet_path, _joined_errors(report))
	return report

func compare_contact_sheets(left_path: String, right_path: String, frame_width := 512, frame_height := 512) -> Dictionary:
	_ensure_ready()
	var report := _manager.diff_contact_sheet_images(left_path, right_path, frame_width, frame_height)
	var message := _joined_errors(report)
	if message.is_empty():
		message = "Contact sheets differ in %d frames" % int(report.get("changed_frame_count", 0)) if bool(report.get("different", false)) else "Contact sheets match"
	_set_operation_report("compare_contact_sheets", bool(report.get("ok", false)), "%s -> %s" % [left_path, right_path], message)
	return report

func write_current_validation_report(report_path: String, set_id := "first_slice_player") -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	var report := _manager.write_validation_report(_current_recipe, report_path, requested_set)
	_set_operation_report("write_validation_report", bool(report.get("ok", false)), report_path, _joined_errors(report))
	return report

func content_pack_report() -> Dictionary:
	_ensure_ready()
	var report := _manager.content_pack_report()
	_set_operation_report("content_pack_report", true, str(report.get("pack_id", "")), "Content pack report ready")
	return report

func preview_equipment_for_socket(socket_id: String, tags := [], label := "Preview Equipment", animation_id := "idle") -> Dictionary:
	_ensure_ready()
	var candidate := {
		"label": label,
		"relative_path": "Equipment/%s.png" % str(label).replace(" ", "_"),
		"tags": _string_array(tags),
	}
	var report := _manager.preview_equipment_for_socket(_current_recipe, socket_id, candidate, animation_id)
	_set_operation_report("equipment_preview", bool(report.get("ok", false)), socket_id, _joined_errors(report))
	return report

func generate_faction_batch(faction_id: String, count: int, seed := 1, required_tags := [], palette_overrides := {}) -> Dictionary:
	_ensure_ready()
	var rules := {
		"seed": seed,
		"required_tags": _string_array(required_tags),
		"palette_overrides": palette_overrides if palette_overrides is Dictionary else {},
	}
	var report := _manager.generate_faction_batch(faction_id, count, rules)
	_set_operation_report("generate_faction_batch", bool(report.get("ok", false)), faction_id, _joined_errors(report))
	return report

func animation_coverage_heatmap(set_id := "first_slice_player") -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	var report := _manager.animation_coverage_heatmap(_current_recipe, requested_set)
	_set_operation_report("animation_coverage_heatmap", bool(report.get("ok", false)), requested_set, _joined_errors(report))
	return report

func accessibility_preview(set_id := "first_slice_player") -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	return _manager.accessibility_preview(_current_recipe, requested_set)

func performance_budget_report(set_id := "first_slice_player") -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	return _manager.performance_budget_report(_current_recipe, requested_set)

func validate_current_recipe(set_id := "first_slice_player") -> Dictionary:
	_ensure_ready()
	var requested_set := _export_set_id if str(set_id) == "first_slice_player" else str(set_id)
	return _manager.validate_recipe(_current_recipe, requested_set)

func get_editable_slot_ids() -> Array[String]:
	_ensure_ready()
	return _manager.slot_ids()

func select_part_option(slot_id: String, option_index: int) -> bool:
	_ensure_ready()
	var options := _manager.options_for_slot(slot_id)
	if option_index < 0 or option_index >= options.size():
		return false
	_current_recipe.parts[slot_id] = (options[option_index] as Dictionary).duplicate(true)
	var option_button := _part_option_buttons.get(slot_id, null) as OptionButton
	if option_button != null:
		option_button.select(option_index)
	refresh_preview()
	_sync_summary()
	return true

func set_palette_color(palette_id: String, color_html: String) -> void:
	_ensure_ready()
	_current_recipe.palettes[palette_id] = color_html
	refresh_preview()
	_sync_summary()

func set_morph_value(morph_id: String, value: float) -> void:
	_ensure_ready()
	_current_recipe.morphs[morph_id] = clampf(value, -1.0, 1.0)
	_sync_summary()

func select_export_set(set_id: String) -> bool:
	_ensure_ready()
	if not _manager.export_set_ids().has(set_id) and not _manager.custom_export_set_ids(_current_recipe).has(set_id):
		return false
	_export_set_id = set_id
	var export_button := get_node_or_null("%ExportSetOption") as OptionButton
	if export_button != null:
		for index: int in export_button.item_count:
			if str(export_button.get_item_metadata(index)) == set_id:
				export_button.select(index)
				break
	_sync_summary()
	return true

func get_preview_state() -> Dictionary:
	_ensure_ready()
	return {
		"recipe_id": _current_recipe.recipe_id,
		"part_count": _current_recipe.parts.size(),
		"active_animation": _active_animation,
		"export_set_id": _export_set_id,
		"palette_count": _current_recipe.palettes.size(),
		"morph_count": _current_recipe.morphs.size(),
		"rendered_part_paths": _rendered_part_paths.duplicate(),
		"frame_index": _frame_index,
		"frame_count": _frame_count,
		"playing": _playing,
		"alignment_offset": _alignment_offset,
		"preview_scale": _preview_scale,
		"preview_fps": _preview_fps,
		"flipped": _preview_flipped,
		"source_rect": _active_source_rect,
		"pivot": _active_pivot,
		"has_pivot_override": _has_pivot_override(_active_animation, _frame_index),
		"curve_samples": _active_curve_samples.duplicate(true),
	}

func inspect_current_frame_bounds() -> Dictionary:
	_ensure_ready()
	var source_rect := _active_source_rect
	if source_rect.size.x <= 0.0 or source_rect.size.y <= 0.0:
		_update_active_frame_metadata()
		source_rect = _active_source_rect
	var frame_width := int(maxf(0.0, source_rect.size.x))
	var frame_height := int(maxf(0.0, source_rect.size.y))
	var opaque_rect := _opaque_bounds_for_source_rect(source_rect)
	var cropped := false
	if opaque_rect.size.x > 0.0 and opaque_rect.size.y > 0.0 and frame_width > 0 and frame_height > 0:
		cropped = (
			opaque_rect.position.x <= 0.0
			or opaque_rect.position.y <= 0.0
			or opaque_rect.position.x + opaque_rect.size.x >= float(frame_width)
			or opaque_rect.position.y + opaque_rect.size.y >= float(frame_height)
		)
	var frame_area := frame_width * frame_height
	var opaque_area := int(maxf(0.0, opaque_rect.size.x) * maxf(0.0, opaque_rect.size.y))
	return {
		"source_rect": source_rect,
		"pivot": _active_pivot,
		"opaque_bounds": opaque_rect,
		"cropped": cropped,
		"wasted_padding_pixels": max(0, frame_area - opaque_area),
		"frame_width": frame_width,
		"frame_height": frame_height,
	}

func frame_metadata_for_animation(animation_id: String) -> Dictionary:
	_ensure_ready()
	var clip_metadata: Dictionary = _manager.clip_metadata_for_animation(animation_id)
	var frame_count: int = max(1, int(clip_metadata.get("frame_count", _frame_count_for_animation(animation_id))))
	var texture_size := _first_preview_texture_size()
	var frame_size := texture_size
	if frame_count > 1 and texture_size.x >= frame_count:
		frame_size.x = floor(texture_size.x / float(frame_count))
	var frame_rects: Array[Rect2] = []
	var pivots: Array[Vector2] = []
	var curve_bindings := clip_metadata.get("curve_bindings", []) as Array
	var frame_curve_samples: Array = []
	var imported_sprites := _first_imported_part_sprites()
	for frame: int in frame_count:
		if not imported_sprites.is_empty():
			var sprite := imported_sprites[frame % imported_sprites.size()] as Dictionary
			var rect := sprite.get("rect", Rect2(Vector2(frame_size.x * float(frame), 0.0), frame_size)) as Rect2
			var normalized_pivot := sprite.get("pivot", Vector2(0.5, 0.5)) as Vector2
			frame_rects.append(rect)
			pivots.append(_pivot_for_animation_frame(animation_id, frame, Vector2(rect.size.x * normalized_pivot.x, rect.size.y * normalized_pivot.y)))
		else:
			frame_rects.append(Rect2(Vector2(frame_size.x * float(frame), 0.0), frame_size))
			pivots.append(_pivot_for_animation_frame(animation_id, frame, Vector2(frame_size.x * 0.5, frame_size.y)))
		frame_curve_samples.append(_sample_curve_bindings_for_frame(curve_bindings, frame, frame_count, float(clip_metadata.get("stop_time", 0.0))))
	return {
		"animation_id": animation_id,
		"frame_count": frame_count,
		"frame_rects": frame_rects,
		"pivots": pivots,
		"curve_bindings": curve_bindings,
		"frame_curve_samples": frame_curve_samples,
		"uses_imported_part_rects": not imported_sprites.is_empty(),
		"sample_rate": int(clip_metadata.get("sample_rate", 0)),
		"stop_time": float(clip_metadata.get("stop_time", 0.0)),
		"source_path": str(clip_metadata.get("source_path", "")),
		"clip_path": str(clip_metadata.get("clip_path", "")),
	}

func get_available_animation_ids() -> Array[String]:
	_ensure_ready()
	return _manager.game_animation_ids()

func select_animation(animation_id: String) -> bool:
	_ensure_ready()
	if not _manager.game_animation_ids().has(animation_id):
		return false
	_active_animation = animation_id
	_frame_index = 0
	_frame_count = _frame_count_for_animation(animation_id)
	_playback_accumulator = 0.0
	_sync_animation_option()
	refresh_preview()
	_sync_playback_controls()
	return true

func step_preview_frame(delta_frames: int) -> void:
	_frame_count = max(1, _frame_count)
	_frame_index = posmod(_frame_index + delta_frames, _frame_count)
	_update_active_frame_metadata()
	_apply_preview_alignment()
	_sync_playback_controls()
	_sync_summary()

func set_preview_frame(frame_index: int) -> void:
	_frame_count = max(1, _frame_count)
	_frame_index = clampi(frame_index, 0, _frame_count - 1)
	_update_active_frame_metadata()
	_apply_preview_alignment()
	_sync_playback_controls()
	_sync_summary()

func set_preview_playing(playing: bool) -> void:
	_playing = playing
	_sync_summary()

func set_preview_speed(fps: float) -> void:
	_preview_fps = clampf(fps, 1.0, 60.0)
	_sync_playback_controls()
	_sync_summary()

func set_preview_flipped(flipped: bool) -> void:
	_preview_flipped = flipped
	_apply_preview_alignment()
	_sync_playback_controls()
	_sync_summary()

func advance_preview_time(delta: float) -> void:
	if not _playing:
		return
	_playback_accumulator += maxf(0.0, delta) * _preview_fps
	var whole_frames := int(floor(_playback_accumulator))
	if whole_frames <= 0:
		return
	_playback_accumulator -= float(whole_frames)
	step_preview_frame(whole_frames)

func set_preview_alignment(offset: Vector2, scale_value: float) -> void:
	_alignment_offset = offset
	_preview_scale = clampf(scale_value, 0.25, 4.0)
	_apply_preview_alignment()
	_sync_summary()

func refresh_preview() -> void:
	_ensure_ready()
	_rendered_part_paths.clear()
	_update_active_frame_metadata()
	var preview := get_node_or_null("%LayeredPreview") as Control
	if preview == null:
		return
	for child: Node in preview.get_children():
		child.queue_free()
	for slot_id: String in _preview_slot_order():
		var part := _current_recipe.parts.get(slot_id, {}) as Dictionary
		var path := str(part.get("path", ""))
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture == null:
			continue
		var layer := CC2DPreviewLayer.new()
		layer.name = slot_id.replace("/", "_")
		layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		layer.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		layer.region_rect = _active_source_rect
		layer.pivot_offset = _active_pivot
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.texture = texture
		layer.modulate = _manager.palette_modulate_for_slot(_current_recipe, slot_id)
		var transform := _manager.preview_transform_for_slot(_current_recipe, slot_id)
		layer.recipe_offset = transform.get("offset", Vector2.ZERO) as Vector2
		layer.recipe_scale = transform.get("scale", Vector2.ONE) as Vector2
		layer.recipe_rotation_degrees = float(transform.get("rotation_degrees", 0.0))
		preview.add_child(layer)
		_rendered_part_paths.append(path)
	_apply_preview_alignment()
	_sync_summary()

func _ensure_ready() -> void:
	if not _manager.is_loaded():
		_manager.load_content()
	if _current_recipe == null:
		_current_recipe = _manager.default_recipe("studio_default")

func _build_editor_controls() -> void:
	if not is_inside_tree():
		return
	_wire_recipe_file_controls()
	_build_part_browser()
	_build_palette_controls()
	_build_morph_controls()
	_build_export_controls()
	_build_animation_controls()
	_build_playback_controls()
	refresh_preview()

func _wire_recipe_file_controls() -> void:
	if _recipe_file_controls_wired:
		return
	var path_edit := get_node_or_null("%RecipePathEdit") as LineEdit
	var save_button := get_node_or_null("%SaveRecipeButton") as Button
	var load_button := get_node_or_null("%LoadRecipeButton") as Button
	var export_bundle_button := get_node_or_null("%ExportBundleButton") as Button
	var import_bundle_button := get_node_or_null("%ImportBundleButton") as Button
	var save_outfit_button := get_node_or_null("%SaveOutfitButton") as Button
	var apply_outfit_button := get_node_or_null("%ApplyOutfitButton") as Button
	var save_custom_export_set_button := get_node_or_null("%SaveCustomExportSetButton") as Button
	var randomize_button := get_node_or_null("%RandomizeButton") as Button
	var bake_button := get_node_or_null("%BakeExportButton") as Button
	var bake_spriteframes_button := get_node_or_null("%BakeSpriteFramesButton") as Button
	var compare_contact_sheets_button := get_node_or_null("%CompareContactSheetsButton") as Button
	var content_pack_report_button := get_node_or_null("%ContentPackReportButton") as Button
	var equipment_preview_button := get_node_or_null("%EquipmentPreviewButton") as Button
	var faction_batch_button := get_node_or_null("%FactionBatchButton") as Button
	var animation_coverage_button := get_node_or_null("%AnimationCoverageButton") as Button
	var apply_pivot_override_button := get_node_or_null("%ApplyPivotOverrideButton") as Button
	if path_edit == null:
		return
	if save_button != null:
		var save_callable := Callable(self, "_on_save_recipe_button_pressed")
		if not save_button.pressed.is_connected(save_callable):
			save_button.pressed.connect(save_callable)
	if load_button != null:
		var load_callable := Callable(self, "_on_load_recipe_button_pressed")
		if not load_button.pressed.is_connected(load_callable):
			load_button.pressed.connect(load_callable)
	if export_bundle_button != null:
		var export_bundle_callable := Callable(self, "_on_export_bundle_button_pressed")
		if not export_bundle_button.pressed.is_connected(export_bundle_callable):
			export_bundle_button.pressed.connect(export_bundle_callable)
	if import_bundle_button != null:
		var import_bundle_callable := Callable(self, "_on_import_bundle_button_pressed")
		if not import_bundle_button.pressed.is_connected(import_bundle_callable):
			import_bundle_button.pressed.connect(import_bundle_callable)
	if save_outfit_button != null:
		var save_outfit_callable := Callable(self, "_on_save_outfit_button_pressed")
		if not save_outfit_button.pressed.is_connected(save_outfit_callable):
			save_outfit_button.pressed.connect(save_outfit_callable)
	if apply_outfit_button != null:
		var apply_outfit_callable := Callable(self, "_on_apply_outfit_button_pressed")
		if not apply_outfit_button.pressed.is_connected(apply_outfit_callable):
			apply_outfit_button.pressed.connect(apply_outfit_callable)
	if save_custom_export_set_button != null:
		var save_custom_export_set_callable := Callable(self, "_on_save_custom_export_set_button_pressed")
		if not save_custom_export_set_button.pressed.is_connected(save_custom_export_set_callable):
			save_custom_export_set_button.pressed.connect(save_custom_export_set_callable)
	if randomize_button != null:
		var randomize_callable := Callable(self, "_on_randomize_button_pressed")
		if not randomize_button.pressed.is_connected(randomize_callable):
			randomize_button.pressed.connect(randomize_callable)
	if bake_button != null:
		var bake_callable := Callable(self, "_on_bake_export_button_pressed")
		if not bake_button.pressed.is_connected(bake_callable):
			bake_button.pressed.connect(bake_callable)
	if bake_spriteframes_button != null:
		var bake_spriteframes_callable := Callable(self, "_on_bake_spriteframes_button_pressed")
		if not bake_spriteframes_button.pressed.is_connected(bake_spriteframes_callable):
			bake_spriteframes_button.pressed.connect(bake_spriteframes_callable)
	if compare_contact_sheets_button != null:
		var compare_contact_sheets_callable := Callable(self, "_on_compare_contact_sheets_button_pressed")
		if not compare_contact_sheets_button.pressed.is_connected(compare_contact_sheets_callable):
			compare_contact_sheets_button.pressed.connect(compare_contact_sheets_callable)
	if content_pack_report_button != null:
		var content_pack_report_callable := Callable(self, "_on_content_pack_report_button_pressed")
		if not content_pack_report_button.pressed.is_connected(content_pack_report_callable):
			content_pack_report_button.pressed.connect(content_pack_report_callable)
	if equipment_preview_button != null:
		var equipment_preview_callable := Callable(self, "_on_equipment_preview_button_pressed")
		if not equipment_preview_button.pressed.is_connected(equipment_preview_callable):
			equipment_preview_button.pressed.connect(equipment_preview_callable)
	if faction_batch_button != null:
		var faction_batch_callable := Callable(self, "_on_faction_batch_button_pressed")
		if not faction_batch_button.pressed.is_connected(faction_batch_callable):
			faction_batch_button.pressed.connect(faction_batch_callable)
	if animation_coverage_button != null:
		var animation_coverage_callable := Callable(self, "_on_animation_coverage_button_pressed")
		if not animation_coverage_button.pressed.is_connected(animation_coverage_callable):
			animation_coverage_button.pressed.connect(animation_coverage_callable)
	if apply_pivot_override_button != null:
		var apply_pivot_callable := Callable(self, "_on_apply_pivot_override_button_pressed")
		if not apply_pivot_override_button.pressed.is_connected(apply_pivot_callable):
			apply_pivot_override_button.pressed.connect(apply_pivot_callable)
	_recipe_file_controls_wired = true

func _build_part_browser() -> int:
	var container := get_node_or_null("%PartBrowser") as VBoxContainer
	if container == null:
		return 0
	for child: Node in container.get_children():
		child.queue_free()
	_part_option_buttons.clear()
	var visible_option_count := 0
	for slot_id: String in _manager.slot_ids():
		var options := _manager.filtered_options_for_slot(slot_id, _part_filter_query, _part_filter_tags, _current_recipe.favorite_part_paths, _part_filter_favorites_only)
		if options.is_empty():
			continue
		visible_option_count += options.size()
		var row := HBoxContainer.new()
		row.name = slot_id.replace("/", "_")
		row.custom_minimum_size = Vector2(0, 32)
		container.add_child(row)

		var label := Label.new()
		label.custom_minimum_size = Vector2(150, 0)
		label.text = _manager.slot_label(slot_id)
		row.add_child(label)

		var option_button := OptionButton.new()
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for index: int in options.size():
			var option: Dictionary = options[index]
			option_button.add_item(str(option.get("label", "")), index)
			option_button.set_item_metadata(index, option)
		option_button.item_selected.connect(func(index: int) -> void:
			_select_part_option_metadata(slot_id, option_button.get_item_metadata(index) as Dictionary)
		)
		row.add_child(option_button)
		_part_option_buttons[slot_id] = option_button
		_select_current_option_if_visible(slot_id, option_button)
	return visible_option_count

func _build_palette_controls() -> void:
	var container := get_node_or_null("%PaletteControls") as VBoxContainer
	if container == null:
		return
	for child: Node in container.get_children():
		child.queue_free()
	for palette_id: String in _current_recipe.palettes.keys():
		var row := HBoxContainer.new()
		row.name = palette_id.capitalize().replace(" ", "")
		container.add_child(row)
		var label := Label.new()
		label.custom_minimum_size = Vector2(150, 0)
		label.text = palette_id.replace("_", " ").capitalize()
		row.add_child(label)
		var value := LineEdit.new()
		value.text = str(_current_recipe.palettes.get(palette_id, ""))
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value.text_submitted.connect(func(new_text: String) -> void:
			set_palette_color(palette_id, new_text)
		)
		row.add_child(value)

func _build_morph_controls() -> void:
	var container := get_node_or_null("%MorphControls") as VBoxContainer
	if container == null:
		return
	for child: Node in container.get_children():
		child.queue_free()
	for morph_id: String in _current_recipe.morphs.keys():
		var row := HBoxContainer.new()
		row.name = morph_id.capitalize().replace(" ", "")
		container.add_child(row)
		var label := Label.new()
		label.custom_minimum_size = Vector2(150, 0)
		label.text = morph_id.replace("_", " ").capitalize()
		row.add_child(label)
		var slider := HSlider.new()
		slider.min_value = -1.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = float(_current_recipe.morphs.get(morph_id, 0.0))
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.value_changed.connect(func(value: float) -> void:
			set_morph_value(morph_id, value)
		)
		row.add_child(slider)

func _build_export_controls() -> void:
	var export_button := get_node_or_null("%ExportSetOption") as OptionButton
	if export_button == null:
		return
	export_button.clear()
	for index: int in _manager.export_set_ids().size():
		var set_id := _manager.export_set_ids()[index]
		export_button.add_item(set_id.replace("_", " ").capitalize(), index)
		export_button.set_item_metadata(index, set_id)
	for set_id: String in _manager.custom_export_set_ids(_current_recipe):
		var custom_index := export_button.item_count
		export_button.add_item("%s*" % set_id.replace("_", " ").capitalize(), custom_index)
		export_button.set_item_metadata(custom_index, set_id)
	export_button.item_selected.connect(func(index: int) -> void:
		select_export_set(str(export_button.get_item_metadata(index)))
	)

func _build_animation_controls() -> void:
	var animation_button := get_node_or_null("%AnimationOption") as OptionButton
	if animation_button == null:
		return
	animation_button.clear()
	var animation_ids := _manager.game_animation_ids()
	for index: int in animation_ids.size():
		var animation_id := animation_ids[index]
		animation_button.add_item(animation_id.replace("_", " ").capitalize(), index)
		animation_button.set_item_metadata(index, animation_id)
		if animation_id == _active_animation:
			animation_button.select(index)
	animation_button.item_selected.connect(func(index: int) -> void:
		select_animation(str(animation_button.get_item_metadata(index)))
	)

func _build_playback_controls() -> void:
	var scrubber := get_node_or_null("%FrameScrubber") as HSlider
	if scrubber != null:
		scrubber.value_changed.connect(func(value: float) -> void:
			set_preview_frame(int(round(value)))
		)
	var speed_spin := get_node_or_null("%PlaybackSpeedSpin") as SpinBox
	if speed_spin != null:
		speed_spin.value_changed.connect(func(value: float) -> void:
			set_preview_speed(value)
		)
	var flip_check := get_node_or_null("%FlipPreviewCheck") as CheckBox
	if flip_check != null:
		flip_check.toggled.connect(func(toggled: bool) -> void:
			set_preview_flipped(toggled)
		)
	var part_search_edit := get_node_or_null("%PartSearchEdit") as LineEdit
	var part_tag_edit := get_node_or_null("%PartTagFilterEdit") as LineEdit
	var favorite_check := get_node_or_null("%FavoriteOnlyCheck") as CheckBox
	if part_search_edit != null:
		part_search_edit.text_changed.connect(func(new_text: String) -> void:
			filter_part_browser(new_text, _tags_from_filter_edit(part_tag_edit), favorite_check.button_pressed if favorite_check != null else false)
		)
	if part_tag_edit != null:
		part_tag_edit.text_changed.connect(func(_new_text: String) -> void:
			filter_part_browser(part_search_edit.text if part_search_edit != null else "", _tags_from_filter_edit(part_tag_edit), favorite_check.button_pressed if favorite_check != null else false)
		)
	if favorite_check != null:
		favorite_check.toggled.connect(func(toggled: bool) -> void:
			filter_part_browser(part_search_edit.text if part_search_edit != null else "", _tags_from_filter_edit(part_tag_edit), toggled)
		)
	_sync_playback_controls()
	_sync_frame_bounds_controls()

func _sync_summary() -> void:
	if not is_inside_tree():
		return
	var summary := get_node_or_null("%RecipeSummary") as Label
	var validation := get_node_or_null("%ValidationLabel") as Label
	var preview := get_node_or_null("%PreviewLabel") as Label
	var accessibility := get_node_or_null("%AccessibilityPreviewLabel") as Label
	var budget_label := get_node_or_null("%PerformanceBudgetLabel") as Label
	if _current_recipe == null:
		return
	var report := validate_current_recipe(_export_set_id)
	var coverage := report.get("coverage", {}) as Dictionary
	var accessibility_report := accessibility_preview(_export_set_id)
	var accessibility_summary := accessibility_report.get("summary", {}) as Dictionary
	var performance_report := performance_budget_report(_export_set_id)
	var performance_summary := performance_report.get("summary", {}) as Dictionary
	if summary != null:
		summary.text = "%s | Parts %d | Animations %d/%d" % [
			_current_recipe.display_name,
			_current_recipe.parts.size(),
			int(coverage.get("checked", 0)),
			int(coverage.get("total", 0)),
		]
	if validation != null:
		if not _last_operation_report.is_empty() and not bool(_last_operation_report.get("ok", true)):
			validation.text = str(_last_operation_report.get("message", "Operation failed"))
		else:
			validation.text = "Valid" if bool(report.get("valid", false)) else "Needs repair: %s" % ", ".join(report.get("errors", []) as Array)
	if preview != null:
		preview.text = "Preview %s | Frame %d/%d | %d parts | %s" % [
			_active_animation,
			_frame_index + 1,
			_frame_count,
			_current_recipe.parts.size(),
			_export_set_id,
		]
	if accessibility != null:
		accessibility.text = "Accessibility %s | Contrast issues %d | Small-scale risks %d" % [
			"OK" if bool(accessibility_report.get("ok", false)) else "Review",
			int(accessibility_summary.get("failing_palette_pairs", 0)),
			int(accessibility_summary.get("high_scale_risks", 0)),
		]
	if budget_label != null:
		budget_label.text = "Budget %s | Frames %d | Memory %.2f MB | Risks %d/%d" % [
			"OK" if bool(performance_report.get("ok", false)) else "Review",
			int(performance_summary.get("estimated_frames", 0)),
			float(performance_summary.get("estimated_bytes", 0)) / 1048576.0,
			int(performance_summary.get("high_risks", 0)),
			int(performance_summary.get("medium_risks", 0)),
		]
	_sync_frame_bounds_controls()

func _sync_animation_option() -> void:
	var animation_button := get_node_or_null("%AnimationOption") as OptionButton
	if animation_button == null:
		return
	for index: int in animation_button.item_count:
		if str(animation_button.get_item_metadata(index)) == _active_animation:
			animation_button.select(index)
			return

func _sync_playback_controls() -> void:
	var scrubber := get_node_or_null("%FrameScrubber") as HSlider
	if scrubber != null:
		scrubber.max_value = max(0, _frame_count - 1)
		scrubber.set_value_no_signal(float(_frame_index))
	var speed_spin := get_node_or_null("%PlaybackSpeedSpin") as SpinBox
	if speed_spin != null:
		speed_spin.set_value_no_signal(_preview_fps)
	var flip_check := get_node_or_null("%FlipPreviewCheck") as CheckBox
	if flip_check != null:
		flip_check.set_pressed_no_signal(_preview_flipped)

func _sync_frame_bounds_controls() -> void:
	var pivot_x_spin := get_node_or_null("%PivotXSpin") as SpinBox
	var pivot_y_spin := get_node_or_null("%PivotYSpin") as SpinBox
	if pivot_x_spin != null:
		pivot_x_spin.set_value_no_signal(_active_pivot.x)
	if pivot_y_spin != null:
		pivot_y_spin.set_value_no_signal(_active_pivot.y)
	_refresh_frame_bounds_label()

func _refresh_frame_bounds_label() -> void:
	var frame_bounds_label := get_node_or_null("%FrameBoundsLabel") as Label
	if frame_bounds_label == null:
		return
	var bounds := inspect_current_frame_bounds()
	var opaque_bounds := bounds.get("opaque_bounds", Rect2()) as Rect2
	frame_bounds_label.text = "Frame %dx%d | Pivot %.0f, %.0f | Opaque %.0f,%.0f %.0fx%.0f | Waste %d | %s" % [
		int(bounds.get("frame_width", 0)),
		int(bounds.get("frame_height", 0)),
		_active_pivot.x,
		_active_pivot.y,
		opaque_bounds.position.x,
		opaque_bounds.position.y,
		opaque_bounds.size.x,
		opaque_bounds.size.y,
		int(bounds.get("wasted_padding_pixels", 0)),
		"Cropped" if bool(bounds.get("cropped", false)) else "Clear",
	]

func _sync_part_option_buttons_to_recipe() -> void:
	for slot_id: String in _part_option_buttons.keys():
		var option_button := _part_option_buttons.get(slot_id, null) as OptionButton
		if option_button == null:
			continue
		_select_current_option_if_visible(slot_id, option_button)

func _select_part_option_metadata(slot_id: String, option: Dictionary) -> bool:
	if option.is_empty():
		return false
	_current_recipe.parts[slot_id] = option.duplicate(true)
	refresh_preview()
	_sync_summary()
	return true

func _select_current_option_if_visible(slot_id: String, option_button: OptionButton) -> void:
	var selected := _current_recipe.parts.get(slot_id, {}) as Dictionary
	var selected_path := str(selected.get("path", ""))
	for index: int in option_button.item_count:
		var option := option_button.get_item_metadata(index) as Dictionary
		if str(option.get("path", "")) == selected_path:
			option_button.select(index)
			break

func _tags_from_filter_edit(tag_edit: LineEdit) -> Array[String]:
	var tags: Array[String] = []
	if tag_edit == null:
		return tags
	for tag: String in tag_edit.text.split(",", false):
		var normalized := tag.strip_edges().to_lower()
		if not normalized.is_empty():
			tags.append(normalized)
	return tags

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result

func _set_operation_report(operation: String, ok: bool, path := "", message := "") -> void:
	var resolved_message := str(message)
	if resolved_message.is_empty():
		resolved_message = "%s complete" % operation.replace("_", " ").capitalize()
	_last_operation_report = {
		"operation": operation,
		"ok": ok,
		"path": path,
		"message": resolved_message,
	}
	var validation := get_node_or_null("%ValidationLabel") as Label
	if validation != null:
		validation.text = resolved_message
	_sync_summary()

func _joined_errors(report: Dictionary) -> String:
	var errors := report.get("errors", []) as Array
	if errors.is_empty():
		return ""
	return ", ".join(errors)

func _sync_palette_controls_to_recipe() -> void:
	var container := get_node_or_null("%PaletteControls") as VBoxContainer
	if container == null:
		return
	for row: Node in container.get_children():
		for child: Node in row.get_children():
			if child is LineEdit:
				var palette_id := row.name.to_snake_case()
				(child as LineEdit).text = str(_current_recipe.palettes.get(palette_id, ""))

func _sync_morph_controls_to_recipe() -> void:
	var container := get_node_or_null("%MorphControls") as VBoxContainer
	if container == null:
		return
	for row: Node in container.get_children():
		for child: Node in row.get_children():
			if child is HSlider:
				var morph_id := row.name.to_snake_case()
				(child as HSlider).value = float(_current_recipe.morphs.get(morph_id, 0.0))

func _apply_preview_alignment() -> void:
	var preview := get_node_or_null("%LayeredPreview") as Control
	if preview == null:
		return
	for child: Node in preview.get_children():
		if child is TextureRect:
			var recipe_offset := Vector2.ZERO
			var recipe_scale := Vector2.ONE
			var recipe_rotation_degrees := 0.0
			if child is CC2DPreviewLayer:
				recipe_offset = (child as CC2DPreviewLayer).recipe_offset
				recipe_scale = (child as CC2DPreviewLayer).recipe_scale
				recipe_rotation_degrees = (child as CC2DPreviewLayer).recipe_rotation_degrees
			(child as TextureRect).position = _alignment_offset + recipe_offset
			(child as TextureRect).scale = Vector2(
				(-_preview_scale if _preview_flipped else _preview_scale) * recipe_scale.x,
				_preview_scale * recipe_scale.y
			)
			(child as TextureRect).rotation_degrees = -recipe_rotation_degrees if _preview_flipped else recipe_rotation_degrees
			(child as TextureRect).pivot_offset = _active_pivot
			if child is CC2DPreviewLayer:
				(child as CC2DPreviewLayer).region_rect = _active_source_rect

func _frame_count_for_animation(animation_id: String) -> int:
	if animation_id == "idle":
		return 4
	if animation_id in ["run", "walk", "dash"]:
		return 8
	if animation_id.begins_with("melee") or animation_id in ["hurt", "death", "jump", "fall"]:
		return 6
	return 4

func _update_active_frame_metadata() -> void:
	var metadata := frame_metadata_for_animation(_active_animation)
	var frame_rects := metadata.get("frame_rects", []) as Array
	var pivots := metadata.get("pivots", []) as Array
	_frame_count = max(1, int(metadata.get("frame_count", _frame_count)))
	_frame_index = clampi(_frame_index, 0, _frame_count - 1)
	_active_source_rect = frame_rects[_frame_index] if _frame_index < frame_rects.size() else Rect2(Vector2.ZERO, Vector2.ZERO)
	_active_pivot = pivots[_frame_index] if _frame_index < pivots.size() else Vector2.ZERO
	var frame_curve_samples := metadata.get("frame_curve_samples", []) as Array
	_active_curve_samples = frame_curve_samples[_frame_index].duplicate(true) if _frame_index < frame_curve_samples.size() else []
	_sync_frame_bounds_controls()

func _pivot_for_animation_frame(animation_id: String, frame_index: int, fallback: Vector2) -> Vector2:
	if _current_recipe == null:
		return fallback
	var animation_overrides := _current_recipe.pivot_overrides.get(animation_id, {}) as Dictionary
	var stored: Variant = animation_overrides.get(str(frame_index), null)
	if stored is Dictionary:
		var data := stored as Dictionary
		return Vector2(float(data.get("x", fallback.x)), float(data.get("y", fallback.y)))
	if stored is Vector2:
		return stored as Vector2
	return fallback

func _has_pivot_override(animation_id: String, frame_index: int) -> bool:
	if _current_recipe == null:
		return false
	var animation_overrides := _current_recipe.pivot_overrides.get(animation_id, {}) as Dictionary
	return animation_overrides.has(str(frame_index))

func _set_pivot_override(animation_id: String, frame_index: int, pivot: Vector2) -> void:
	if _current_recipe == null:
		return
	var animation_overrides := _current_recipe.pivot_overrides.get(animation_id, {}) as Dictionary
	animation_overrides[str(frame_index)] = {
		"x": pivot.x,
		"y": pivot.y,
	}
	_current_recipe.pivot_overrides[animation_id] = animation_overrides

func _opaque_bounds_for_source_rect(source_rect: Rect2) -> Rect2:
	var frame_width := int(maxf(0.0, source_rect.size.x))
	var frame_height := int(maxf(0.0, source_rect.size.y))
	if frame_width <= 0 or frame_height <= 0:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	var min_x := frame_width
	var min_y := frame_height
	var max_x := -1
	var max_y := -1
	for slot_id: String in _preview_slot_order():
		var part := _current_recipe.parts.get(slot_id, {}) as Dictionary
		var path := str(part.get("path", ""))
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture == null:
			continue
		var image := texture.get_image()
		if image == null:
			continue
		var start_x := clampi(int(source_rect.position.x), 0, image.get_width())
		var start_y := clampi(int(source_rect.position.y), 0, image.get_height())
		var end_x := clampi(int(source_rect.position.x + source_rect.size.x), 0, image.get_width())
		var end_y := clampi(int(source_rect.position.y + source_rect.size.y), 0, image.get_height())
		for y: int in range(start_y, end_y):
			for x: int in range(start_x, end_x):
				if image.get_pixel(x, y).a <= 0.01:
					continue
				var local_x := x - int(source_rect.position.x)
				var local_y := y - int(source_rect.position.y)
				min_x = mini(min_x, local_x)
				min_y = mini(min_y, local_y)
				max_x = maxi(max_x, local_x)
				max_y = maxi(max_y, local_y)
	if max_x < min_x or max_y < min_y:
		return Rect2(Vector2.ZERO, Vector2.ZERO)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x + 1, max_y - min_y + 1))

func _first_preview_texture_size() -> Vector2:
	for slot_id: String in _preview_slot_order():
		var part := _current_recipe.parts.get(slot_id, {}) as Dictionary
		var path := str(part.get("path", ""))
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture != null:
			return texture.get_size()
	return Vector2(64, 64)

func _first_imported_part_sprites() -> Array:
	for slot_id: String in _preview_slot_order():
		var part := _current_recipe.parts.get(slot_id, {}) as Dictionary
		var metadata := _manager.sprite_metadata_for_part(part)
		var sprites := metadata.get("sprites", []) as Array
		if not sprites.is_empty():
			return sprites
	return []

func _sample_curve_bindings_for_frame(curve_bindings: Array, frame_index: int, frame_count: int, stop_time: float) -> Array:
	var samples: Array[Dictionary] = []
	if curve_bindings.is_empty():
		return samples
	var target_time := 0.0
	if frame_count > 1:
		target_time = stop_time * (float(frame_index) / float(frame_count - 1))
	for binding: Dictionary in curve_bindings:
		var keyframes := binding.get("keyframes", []) as Array
		if keyframes.is_empty():
			continue
		var nearest := _nearest_keyframe_for_time(keyframes, target_time)
		if nearest.is_empty():
			continue
		samples.append({
			"path": str(binding.get("path", "")),
			"attribute": str(binding.get("attribute", "")),
			"part_name": str(binding.get("part_name", "")),
			"time": float(nearest.get("time", 0.0)),
			"value": nearest.get("value", 0.0),
		})
	return samples

func _nearest_keyframe_for_time(keyframes: Array, target_time: float) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for keyframe: Dictionary in keyframes:
		var distance := absf(float(keyframe.get("time", 0.0)) - target_time)
		if distance < best_distance:
			best = keyframe
			best_distance = distance
	return best

func _preview_slot_order() -> Array[String]:
	var preferred := [
		"Base/Body Skin",
		"Base/Ear",
		"Base/Eyebrow",
		"Base/Eyes",
		"Base/Mouth",
		"Base/Facial Hair",
		"Base/Hair",
		"Fantasy/Underwear",
		"Fantasy/Pants",
		"Fantasy/Shirt",
		"Fantasy/Armor",
		"Fantasy/Helmet",
		"Fantasy/Weapon",
	]
	var ordered: Array[String] = []
	for slot_id: String in preferred:
		if _current_recipe.parts.has(slot_id):
			ordered.append(slot_id)
	for slot_id: String in _current_recipe.parts.keys():
		if not ordered.has(slot_id):
			ordered.append(slot_id)
	return ordered

func _on_save_recipe_button_pressed() -> void:
	var path_edit := get_node_or_null("%RecipePathEdit") as LineEdit
	if path_edit == null:
		return
	save_current_recipe(path_edit.text)
	_sync_summary()

func _on_load_recipe_button_pressed() -> void:
	var path_edit := get_node_or_null("%RecipePathEdit") as LineEdit
	if path_edit == null:
		return
	load_recipe_from_path(path_edit.text)
	_sync_summary()

func _on_export_bundle_button_pressed() -> void:
	var bundle_edit := get_node_or_null("%BundlePathEdit") as LineEdit
	if bundle_edit == null:
		return
	export_current_recipe_bundle(bundle_edit.text, _export_set_id)
	_sync_summary()

func _on_import_bundle_button_pressed() -> void:
	var bundle_edit := get_node_or_null("%BundlePathEdit") as LineEdit
	if bundle_edit == null:
		return
	import_recipe_bundle_from_path(bundle_edit.text)
	_sync_summary()

func _on_save_outfit_button_pressed() -> void:
	var outfit_edit := get_node_or_null("%OutfitIdEdit") as LineEdit
	var label_edit := get_node_or_null("%OutfitLabelEdit") as LineEdit
	var tag_edit := get_node_or_null("%OutfitTagEdit") as LineEdit
	if outfit_edit == null:
		return
	save_current_outfit_set(
		outfit_edit.text,
		label_edit.text if label_edit != null else "",
		_tags_from_filter_edit(tag_edit)
	)

func _on_apply_outfit_button_pressed() -> void:
	var outfit_edit := get_node_or_null("%OutfitIdEdit") as LineEdit
	if outfit_edit == null:
		return
	apply_outfit_set(outfit_edit.text)

func _on_save_custom_export_set_button_pressed() -> void:
	var set_id_edit := get_node_or_null("%CustomExportSetIdEdit") as LineEdit
	var label_edit := get_node_or_null("%CustomExportSetLabelEdit") as LineEdit
	var animation_edit := get_node_or_null("%CustomExportAnimationsEdit") as LineEdit
	if set_id_edit == null or animation_edit == null:
		return
	save_current_custom_export_set(
		set_id_edit.text,
		_tags_from_filter_edit(animation_edit),
		label_edit.text if label_edit != null else "",
		"gameplay"
	)

func _on_randomize_button_pressed() -> void:
	var tag_edit := get_node_or_null("%RandomTagEdit") as LineEdit
	var lock_edit := get_node_or_null("%RandomLockEdit") as LineEdit
	var seed_spin := get_node_or_null("%RandomSeedSpin") as SpinBox
	var tags: Array[String] = []
	if tag_edit != null:
		for tag: String in tag_edit.text.split(",", false):
			var normalized := tag.strip_edges().to_lower()
			if not normalized.is_empty():
				tags.append(normalized)
	var locked_slots: Array[String] = []
	if lock_edit != null:
		for slot_id: String in lock_edit.text.split(",", false):
			var normalized_slot := slot_id.strip_edges()
			if not normalized_slot.is_empty():
				locked_slots.append(normalized_slot)
	var seed := int(seed_spin.value) if seed_spin != null else 0
	randomize_current_recipe(locked_slots, tags, seed)

func _on_bake_export_button_pressed() -> void:
	var root_edit := get_node_or_null("%ExportRootEdit") as LineEdit
	if root_edit == null:
		return
	bake_current_export(root_edit.text, _export_set_id, 1)
	_sync_summary()

func _on_bake_spriteframes_button_pressed() -> void:
	var root_edit := get_node_or_null("%ExportRootEdit") as LineEdit
	var spriteframes_edit := get_node_or_null("%SpriteFramesPathEdit") as LineEdit
	if root_edit == null or spriteframes_edit == null:
		return
	bake_current_spriteframes(root_edit.text, spriteframes_edit.text, _export_set_id, 1)
	_sync_summary()

func _on_apply_pivot_override_button_pressed() -> void:
	var pivot_x_spin := get_node_or_null("%PivotXSpin") as SpinBox
	var pivot_y_spin := get_node_or_null("%PivotYSpin") as SpinBox
	if pivot_x_spin == null or pivot_y_spin == null:
		return
	_active_pivot = Vector2(pivot_x_spin.value, pivot_y_spin.value)
	_set_pivot_override(_active_animation, _frame_index, _active_pivot)
	_apply_preview_alignment()
	_refresh_frame_bounds_label()
	_sync_summary()

func _on_bake_contact_sheet_button_pressed() -> void:
	var contact_sheet_edit := get_node_or_null("%ContactSheetPathEdit") as LineEdit
	if contact_sheet_edit == null:
		return
	bake_current_contact_sheet(contact_sheet_edit.text, _export_set_id, 1)
	_sync_summary()

func _on_compare_contact_sheets_button_pressed() -> void:
	var left_edit := get_node_or_null("%ContactSheetLeftEdit") as LineEdit
	var right_edit := get_node_or_null("%ContactSheetRightEdit") as LineEdit
	if left_edit == null or right_edit == null:
		return
	compare_contact_sheets(left_edit.text, right_edit.text, 512, 512)
	_sync_contact_sheet_diff_label()
	_sync_summary()

func _sync_contact_sheet_diff_label() -> void:
	var label := get_node_or_null("%ContactSheetDiffLabel") as Label
	if label == null:
		return
	if str(_last_operation_report.get("operation", "")) != "compare_contact_sheets":
		return
	label.text = str(_last_operation_report.get("message", "Contact sheet diff ready"))

func _on_write_validation_report_button_pressed() -> void:
	var report_edit := get_node_or_null("%ValidationReportPathEdit") as LineEdit
	if report_edit == null:
		return
	write_current_validation_report(report_edit.text, _export_set_id)
	_sync_summary()

func _on_content_pack_report_button_pressed() -> void:
	content_pack_report()
	_sync_summary()

func _on_equipment_preview_button_pressed() -> void:
	var socket_edit := get_node_or_null("%EquipmentSocketEdit") as LineEdit
	var tag_edit := get_node_or_null("%EquipmentTagEdit") as LineEdit
	if socket_edit == null or tag_edit == null:
		return
	preview_equipment_for_socket(socket_edit.text, _tags_from_filter_edit(tag_edit), "Studio Preview Equipment", _active_animation)
	_sync_summary()

func _on_faction_batch_button_pressed() -> void:
	var faction_edit := get_node_or_null("%FactionIdEdit") as LineEdit
	var count_spin := get_node_or_null("%FactionCountSpin") as SpinBox
	if faction_edit == null or count_spin == null:
		return
	generate_faction_batch(faction_edit.text, int(count_spin.value), 1001, ["starter_safe"], {"cloth_primary": "31384aff"})
	_sync_summary()

func _on_animation_coverage_button_pressed() -> void:
	animation_coverage_heatmap(_export_set_id)
	_sync_summary()
