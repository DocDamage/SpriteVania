extends RefCounted
class_name CC2DCreatorManager

const CC2DAppearance := preload("res://scripts/character_creator/cc2d_appearance.gd")
const CC2DBulkExportSets := preload("res://scripts/character_creator/cc2d_bulk_export_sets.gd")
const CC2DExportProfile := preload("res://scripts/character_creator/cc2d_export_profile.gd")
const CC2DManifest := preload("res://scripts/character_creator/cc2d_manifest.gd")
const CC2DRecipe := preload("res://scripts/character_creator/cc2d_recipe.gd")

const EXPORT_TARGET_SIZES := {
	"portrait": Vector2i(256, 256),
	"avatar": Vector2i(128, 128),
	"icon": Vector2i(64, 64),
}

var _manifest := CC2DManifest.new()
var _appearance := CC2DAppearance.new()
var _export_profile := CC2DExportProfile.new()
var _bulk_sets := CC2DBulkExportSets.new()
var _loaded := false
var _clip_metadata_cache: Dictionary = {}
var _sprite_metadata_cache: Dictionary = {}
const COMPATIBILITY_CATEGORIES := [
	"clipping",
	"weapon_alignment",
	"silhouette_readability",
	"frame_bounds",
	"camera_zoom",
	"hitbox_compatibility",
]

func load_content() -> bool:
	var manifest_loaded := _manifest.load_manifest()
	var appearance_loaded := _appearance.load_catalog()
	var profile_loaded := _export_profile.load_profile()
	var sets_loaded := _bulk_sets.load_sets()
	_loaded = manifest_loaded and appearance_loaded and profile_loaded and sets_loaded
	return _loaded

func is_loaded() -> bool:
	return _loaded

func content_version() -> String:
	if not _manifest.is_loaded():
		return ""
	return "%s:%d" % [_manifest.manifest_path.get_file().get_basename(), _manifest.copied_asset_count()]

func slot_ids() -> Array[String]:
	_ensure_loaded()
	return _appearance.slot_ids()

func slot_label(slot_id: String) -> String:
	_ensure_loaded()
	return _appearance.slot_label(slot_id)

func options_for_slot(slot_id: String) -> Array:
	_ensure_loaded()
	return _appearance.options_for_slot(slot_id)

func filtered_options_for_slot(slot_id: String, query := "", required_tags := [], favorite_paths := [], favorites_only := false) -> Array:
	_ensure_loaded()
	var normalized_query := str(query).strip_edges().to_lower()
	var tags := _string_array(required_tags)
	var favorites := _string_array(favorite_paths)
	var matches: Array = []
	for option: Dictionary in _appearance.options_for_slot(slot_id):
		if not _option_matches_query(option, slot_id, normalized_query):
			continue
		if not _option_matches_required_tags(option, tags):
			continue
		if bool(favorites_only) and not favorites.has(str(option.get("path", ""))):
			continue
		matches.append(option)
	return matches

func export_set_ids() -> Array[String]:
	_ensure_loaded()
	return _bulk_sets.set_ids()

func custom_export_set_ids(recipe: CC2DRecipe) -> Array[String]:
	var ids: Array[String] = []
	if recipe == null:
		return ids
	for set_id: String in recipe.custom_export_sets.keys():
		ids.append(set_id)
	ids.sort()
	return ids

func game_animation_ids() -> Array[String]:
	_ensure_loaded()
	var ids: Array[String] = []
	for animation_id: String in _export_profile.game_animation_exports().keys():
		if _export_profile.has_available_game_animation(animation_id):
			ids.append(animation_id)
	ids.sort()
	return ids

func clip_metadata_for_animation(animation_id: String) -> Dictionary:
	_ensure_loaded()
	if _clip_metadata_cache.has(animation_id):
		return (_clip_metadata_cache.get(animation_id, {}) as Dictionary).duplicate(true)
	var export := _export_profile.export_for_game_animation(animation_id)
	var source_path := _source_path_for_export(animation_id, export)
	var clip_path := _clip_file_path(source_path)
	var metadata := {
		"animation_id": animation_id,
		"source_path": source_path,
		"clip_path": clip_path,
		"sample_rate": int(_export_profile.default_export().get("target_fps", 12)),
		"stop_time": 0.0,
		"frame_count": 1,
		"curve_bindings": [],
		"available": false,
	}
	if clip_path.is_empty() or not FileAccess.file_exists(clip_path):
		_clip_metadata_cache[animation_id] = metadata
		return metadata.duplicate(true)
	var parsed := _parse_unity_anim_file(clip_path)
	var sample_rate := int(parsed.get("sample_rate", metadata.sample_rate))
	var stop_time := float(parsed.get("stop_time", 0.0))
	metadata.sample_rate = sample_rate
	metadata.stop_time = stop_time
	metadata.frame_count = max(1, int(round(float(sample_rate) * stop_time)))
	metadata.curve_bindings = parsed.get("curve_bindings", [])
	metadata.available = true
	_clip_metadata_cache[animation_id] = metadata
	return metadata.duplicate(true)

func sprite_metadata_for_part(part: Dictionary) -> Dictionary:
	_ensure_loaded()
	var relative_path := str(part.get("relative_path", "")).replace("\\", "/")
	if relative_path.is_empty():
		return _empty_sprite_metadata("")
	if _sprite_metadata_cache.has(relative_path):
		return (_sprite_metadata_cache.get(relative_path, {}) as Dictionary).duplicate(true)
	var entry := _manifest.entry_for_relative_path(relative_path)
	var meta_path := _manifest.project_path(str(entry.get("meta_path", "")))
	var metadata := _empty_sprite_metadata(meta_path)
	if meta_path.is_empty() or not FileAccess.file_exists(meta_path):
		_sprite_metadata_cache[relative_path] = metadata
		return metadata.duplicate(true)
	metadata.sprites = _parse_unity_sprite_meta(meta_path)
	metadata.available = not (metadata.sprites as Array).is_empty()
	_sprite_metadata_cache[relative_path] = metadata
	return metadata.duplicate(true)

func default_recipe(recipe_id := "default") -> CC2DRecipe:
	_ensure_loaded()
	var recipe := CC2DRecipe.new()
	recipe.recipe_id = _safe_recipe_id(recipe_id)
	recipe.display_name = recipe.recipe_id.replace("_", " ").capitalize()
	recipe.content_pack_id = "base_fantasy"
	recipe.export_profile_id = "base_fantasy"
	recipe.parts = _appearance.default_appearance()
	recipe.palettes = _default_palettes()
	recipe.morphs = _default_morphs()
	recipe.tags = ["starter_safe"]
	recipe.equipment_sockets = _default_equipment_sockets()
	return recipe

func recipe_from_appearance(recipe_id: String, display_name: String, appearance: Dictionary) -> CC2DRecipe:
	_ensure_loaded()
	var recipe := default_recipe(recipe_id)
	recipe.display_name = display_name.strip_edges() if not display_name.strip_edges().is_empty() else recipe.display_name
	if not appearance.is_empty():
		recipe.parts = appearance.duplicate(true)
	repair_recipe(recipe)
	return recipe

func random_recipe(recipe_id: String, display_name: String, locked_parts := {}, required_tags := [], seed := 0) -> CC2DRecipe:
	_ensure_loaded()
	var recipe := default_recipe(recipe_id)
	recipe.display_name = display_name.strip_edges() if not display_name.strip_edges().is_empty() else recipe.display_name
	if locked_parts is Dictionary:
		recipe.parts = (locked_parts as Dictionary).duplicate(true)
	randomize_recipe(recipe, [], required_tags, seed)
	return recipe

func randomize_recipe(recipe: CC2DRecipe, locked_slots := [], required_tags := [], seed := 0) -> Dictionary:
	_ensure_loaded()
	if recipe == null:
		return {
			"changed_slots": [],
			"locked_slots": [],
			"required_tags": [],
		}
	var locked_slot_ids := _string_array(locked_slots)
	var tags := _string_array(required_tags)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(seed) if int(seed) != 0 else Time.get_ticks_usec()
	var changed_slots: Array[String] = []
	for slot_id: String in _appearance.slot_ids():
		if locked_slot_ids.has(slot_id):
			continue
		var options := _appearance.options_for_slot(slot_id)
		var candidates := _options_matching_tags(options, tags)
		if candidates.is_empty():
			candidates = options
		if candidates.is_empty():
			continue
		var selected := (candidates[rng.randi_range(0, candidates.size() - 1)] as Dictionary).duplicate(true)
		var previous := recipe.parts.get(slot_id, {}) as Dictionary
		recipe.parts[slot_id] = selected
		if str(previous.get("path", "")) != str(selected.get("path", "")):
			changed_slots.append(slot_id)
	for tag: String in tags:
		if not recipe.tags.has(tag):
			recipe.tags.append(tag)
	return {
		"changed_slots": changed_slots,
		"locked_slots": locked_slot_ids,
		"required_tags": tags,
	}

func set_part_favorite(recipe: CC2DRecipe, part: Dictionary, favorite: bool) -> bool:
	if recipe == null:
		return false
	var path := str(part.get("path", ""))
	if path.is_empty():
		return false
	if favorite:
		if not recipe.favorite_part_paths.has(path):
			recipe.favorite_part_paths.append(path)
	else:
		recipe.favorite_part_paths.erase(path)
	return true

func is_part_favorite(recipe: CC2DRecipe, part: Dictionary) -> bool:
	if recipe == null:
		return false
	return recipe.favorite_part_paths.has(str(part.get("path", "")))

func save_recipe(recipe: CC2DRecipe, path: String) -> bool:
	if recipe == null or path.is_empty():
		return false
	var base_dir := path.get_base_dir()
	if not base_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(base_dir)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(recipe.to_dictionary(), "\t"))
	return true

func load_recipe(path: String) -> CC2DRecipe:
	_ensure_loaded()
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return null
	var recipe: CC2DRecipe = CC2DRecipe.from_dictionary(parsed)
	repair_recipe(recipe)
	return recipe

func export_recipe_bundle(recipe: CC2DRecipe, path: String, set_id := "first_slice_player") -> Dictionary:
	_ensure_loaded()
	if recipe == null or path.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Recipe and bundle path are required."],
		}
	var validation := validate_recipe(recipe, set_id)
	var bundle := {
		"bundle_schema_version": 1,
		"recipe": recipe.to_dictionary(),
		"provenance": {
			"content_pack_id": recipe.content_pack_id,
			"content_version": content_version(),
			"export_profile_id": recipe.export_profile_id,
			"set_id": set_id,
		},
		"validation": validation,
		"export_plan": export_plan_for_recipe(recipe, set_id),
	}
	var base_dir := path.get_base_dir()
	if not base_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(base_dir)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"errors": ["Could not write recipe bundle: %s" % path],
		}
	file.store_string(JSON.stringify(bundle, "\t"))
	return {
		"ok": true,
		"errors": [],
		"bundle_path": path,
		"validation": validation,
	}

func import_recipe_bundle(path: String) -> CC2DRecipe:
	_ensure_loaded()
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		return null
	var bundle := parsed as Dictionary
	var recipe_data: Variant = bundle.get("recipe", {})
	if not recipe_data is Dictionary:
		return null
	var recipe: CC2DRecipe = CC2DRecipe.from_dictionary(recipe_data as Dictionary)
	repair_recipe(recipe)
	return recipe

func save_outfit_set(recipe: CC2DRecipe, outfit_id: String, label := "", tags := []) -> Dictionary:
	if recipe == null or outfit_id.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Recipe and outfit id are required."],
		}
	var normalized_id := _safe_recipe_id(outfit_id)
	recipe.outfit_sets[normalized_id] = {
		"label": label if not str(label).strip_edges().is_empty() else normalized_id.capitalize(),
		"parts": recipe.parts.duplicate(true),
		"palettes": recipe.palettes.duplicate(true),
		"morphs": recipe.morphs.duplicate(true),
		"tags": _string_array(tags),
	}
	recipe.active_outfit_id = normalized_id
	return {
		"ok": true,
		"errors": [],
		"outfit_id": normalized_id,
	}

func apply_outfit_set(recipe: CC2DRecipe, outfit_id: String) -> Dictionary:
	if recipe == null or outfit_id.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Recipe and outfit id are required."],
		}
	var normalized_id := _safe_recipe_id(outfit_id)
	var outfit := recipe.outfit_sets.get(normalized_id, {}) as Dictionary
	if outfit.is_empty():
		return {
			"ok": false,
			"errors": ["Unknown outfit set: %s" % normalized_id],
		}
	var parts := outfit.get("parts", {}) as Dictionary
	var palettes := outfit.get("palettes", {}) as Dictionary
	var morphs := outfit.get("morphs", {}) as Dictionary
	if not parts.is_empty():
		recipe.parts = parts.duplicate(true)
	if not palettes.is_empty():
		recipe.palettes = palettes.duplicate(true)
	if not morphs.is_empty():
		recipe.morphs = morphs.duplicate(true)
	recipe.active_outfit_id = normalized_id
	repair_recipe(recipe)
	return {
		"ok": true,
		"errors": [],
		"outfit_id": normalized_id,
	}

func family_variant_recipe(base_recipe: CC2DRecipe, recipe_id: String, display_name := "", locked_slots := [], seed := 0) -> CC2DRecipe:
	_ensure_loaded()
	if base_recipe == null:
		return null
	var variant: CC2DRecipe = CC2DRecipe.from_dictionary(base_recipe.to_dictionary())
	variant.recipe_id = _safe_recipe_id(recipe_id)
	variant.display_name = str(display_name) if not str(display_name).strip_edges().is_empty() else variant.recipe_id.capitalize()
	var required_tags: Array[String] = []
	if base_recipe.tags.has("starter_safe"):
		required_tags.append("starter_safe")
	randomize_recipe(variant, locked_slots, required_tags, seed)
	if not variant.tags.has("family_variant"):
		variant.tags.append("family_variant")
	return variant

func save_custom_export_set(recipe: CC2DRecipe, set_id: String, animation_ids := [], label := "", target := "gameplay") -> Dictionary:
	_ensure_loaded()
	if recipe == null or set_id.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Recipe and export set id are required."],
		}
	var normalized_id := _safe_recipe_id(set_id)
	var animations := _string_array(animation_ids)
	if animations.is_empty():
		return {
			"ok": false,
			"errors": ["Custom export set requires at least one animation."],
		}
	recipe.custom_export_sets[normalized_id] = {
		"label": str(label) if not str(label).strip_edges().is_empty() else normalized_id.capitalize(),
		"animations": animations,
		"target": str(target) if not str(target).strip_edges().is_empty() else "gameplay",
	}
	return {
		"ok": true,
		"errors": [],
		"set_id": normalized_id,
		"animations": animations,
	}

func diff_recipes(left: CC2DRecipe, right: CC2DRecipe) -> Dictionary:
	var changed_parts := _changed_part_slots(left.parts if left != null else {}, right.parts if right != null else {})
	var changed_palettes := _changed_keys(left.palettes if left != null else {}, right.palettes if right != null else {})
	var changed_morphs := _changed_keys(left.morphs if left != null else {}, right.morphs if right != null else {})
	var left_tags := left.tags if left != null else []
	var right_tags := right.tags if right != null else []
	return {
		"left_recipe_id": left.recipe_id if left != null else "",
		"right_recipe_id": right.recipe_id if right != null else "",
		"changed_parts": changed_parts,
		"changed_palettes": changed_palettes,
		"changed_morphs": changed_morphs,
		"tags_added": _array_difference(right_tags, left_tags),
		"tags_removed": _array_difference(left_tags, right_tags),
		"outfit_sets_added": _array_difference(_dictionary_keys(right.outfit_sets if right != null else {}), _dictionary_keys(left.outfit_sets if left != null else {})),
		"outfit_sets_removed": _array_difference(_dictionary_keys(left.outfit_sets if left != null else {}), _dictionary_keys(right.outfit_sets if right != null else {})),
		"custom_export_sets_added": _array_difference(_dictionary_keys(right.custom_export_sets if right != null else {}), _dictionary_keys(left.custom_export_sets if left != null else {})),
		"custom_export_sets_removed": _array_difference(_dictionary_keys(left.custom_export_sets if left != null else {}), _dictionary_keys(right.custom_export_sets if right != null else {})),
		"generated_spriteframes_changed": (left.generated_spriteframes_path if left != null else "") != (right.generated_spriteframes_path if right != null else ""),
	}

func validate_recipe(recipe: CC2DRecipe, set_id := "first_slice_player") -> Dictionary:
	_ensure_loaded()
	var errors: Array[String] = []
	var warnings: Array[String] = []
	var constraints := compatibility_report(recipe, set_id)
	if recipe == null:
		return {
			"valid": false,
			"errors": ["Recipe is null."],
			"warnings": warnings,
			"constraints": constraints,
			"coverage": {},
		}
	if recipe.recipe_id.is_empty():
		errors.append("Recipe id is required.")
	if recipe.parts.is_empty():
		errors.append("Recipe must select at least one part.")
	for slot_id: String in recipe.parts.keys():
		var part := recipe.parts.get(slot_id, {}) as Dictionary
		var path := str(part.get("path", ""))
		if path.is_empty():
			errors.append("%s is missing a part path." % slot_id)
		elif not FileAccess.file_exists(path):
			errors.append("%s points at a missing part: %s" % [slot_id, path])
	var checklist := _checklist_for_recipe_set(recipe, set_id)
	var checked_count := 0
	var missing_animations: Array[String] = []
	for item: Dictionary in checklist:
		if bool(item.get("checked", false)):
			checked_count += 1
		if not bool(item.get("available", false)):
			missing_animations.append(str(item.get("id", "")))
	if checklist.is_empty():
		errors.append("Export set is empty or unknown: %s" % set_id)
	if not missing_animations.is_empty():
		errors.append("Missing animation exports: %s" % ", ".join(missing_animations))
	warnings.append_array(_palette_accessibility_warnings(recipe))
	for category_id: String in COMPATIBILITY_CATEGORIES:
		var category := constraints.get(category_id, {}) as Dictionary
		if str(category.get("severity", "")) != "high":
			continue
		for message: String in _string_array(category.get("messages", [])):
			warnings.append("%s: %s" % [category_id, message])
	var budget := _export_budget_for_checklist(checklist)
	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings,
		"constraints": constraints,
		"budget": budget,
		"coverage": {
			"set_id": set_id,
			"checked": checked_count,
			"total": checklist.size(),
		},
	}

func compatibility_report(recipe: CC2DRecipe, set_id := "first_slice_player") -> Dictionary:
	_ensure_loaded()
	var checklist := _checklist_for_recipe_set(recipe, set_id)
	var export_settings := _export_profile.default_export()
	var frame_width := int(export_settings.get("width", 512))
	var frame_height := int(export_settings.get("height", 512))
	var part_count := recipe.parts.size() if recipe != null else 0
	var checked_count := 0
	var checked_ids: Array[String] = []
	for item: Dictionary in checklist:
		if bool(item.get("checked", false)):
			checked_count += 1
			checked_ids.append(str(item.get("id", "")))
	var part_summary := _compatibility_part_summary(recipe, frame_width, frame_height)
	var palette_warnings := _palette_accessibility_warnings(recipe)
	var report := {}
	report.clipping = _constraint_entry(
		"medium" if int(part_summary.get("clipping_risk_count", 0)) >= 3 else "low",
		[
			"%d selected parts carry overlap risk across %d checked animations." % [int(part_summary.get("clipping_risk_count", 0)), checked_count],
			"Layer order uses %d selected parts for deterministic preview/export checks." % part_count,
		]
	)
	var has_weapon := bool(part_summary.get("has_weapon", false))
	var has_weapon_animation := _animation_ids_include_any(checked_ids, ["melee", "attack", "bow", "shoot", "weapon"])
	var weapon_message := "No weapon part selected; alignment baseline is not active."
	if has_weapon:
		var coverage_label := "found" if has_weapon_animation else "no"
		weapon_message = "Weapon slot selected; %s weapon-oriented animation coverage in set '%s'." % [coverage_label, set_id]
	report.weapon_alignment = _constraint_entry(
		"low" if has_weapon and not has_weapon_animation else "ok",
		[weapon_message]
	)
	report.silhouette_readability = _constraint_entry(
		"medium" if not palette_warnings.is_empty() else "ok",
		palette_warnings if not palette_warnings.is_empty() else ["Palette contrast baseline passes for selected recipe colors."]
	)
	var max_part_width := int(part_summary.get("max_part_width", 0))
	var max_part_height := int(part_summary.get("max_part_height", 0))
	var bounds_severity := "ok"
	if max_part_width > int(float(frame_width) * 0.95) or max_part_height > int(float(frame_height) * 0.95):
		bounds_severity = "high"
	elif max_part_width > int(float(frame_width) * 0.80) or max_part_height > int(float(frame_height) * 0.80):
		bounds_severity = "medium"
	report.frame_bounds = _constraint_entry(
		bounds_severity,
		["Largest parsed part rect is %dx%d inside %dx%d export frames." % [max_part_width, max_part_height, frame_width, frame_height]]
	)
	var camera_severity := "ok"
	if frame_height < 128 or frame_width < 128:
		camera_severity = "high"
	elif frame_height < 192 or frame_width < 192:
		camera_severity = "medium"
	report.camera_zoom = _constraint_entry(
		camera_severity,
		["Export frame size %dx%d is used as the camera readability baseline." % [frame_width, frame_height]]
	)
	var hitbox_severity := "medium" if int(part_summary.get("hitbox_risk_count", 0)) >= 2 else "ok"
	report.hitbox_compatibility = _constraint_entry(
		hitbox_severity,
		["%d selected parts may extend beyond a standard player hitbox silhouette." % int(part_summary.get("hitbox_risk_count", 0))]
	)
	return report

func repair_recipe(recipe: CC2DRecipe) -> Dictionary:
	_ensure_loaded()
	var warnings: Array[String] = []
	if recipe == null:
		return {
			"changed": false,
			"warnings": ["Recipe is null."],
		}
	for slot_id: String in _appearance.slot_ids():
		var options := _appearance.options_for_slot(slot_id)
		if options.is_empty():
			continue
		var selected := recipe.parts.get(slot_id, {}) as Dictionary
		var path := str(selected.get("path", ""))
		if path.is_empty() or not FileAccess.file_exists(path):
			recipe.parts[slot_id] = (options[0] as Dictionary).duplicate(true)
			warnings.append("%s repaired with fallback part." % slot_id)
	var socket_repair := _backfill_equipment_sockets(recipe.equipment_sockets)
	if bool(socket_repair.get("changed", false)):
		recipe.equipment_sockets = socket_repair.get("sockets", {}) as Dictionary
		warnings.append("Equipment sockets repaired with default attachment metadata.")
	return {
		"changed": not warnings.is_empty(),
		"warnings": warnings,
	}

func export_plan_for_recipe(recipe: CC2DRecipe, set_id := "first_slice_player") -> Dictionary:
	_ensure_loaded()
	var checklist := _checklist_for_recipe_set(recipe, set_id)
	var socket_report := socket_report_for_recipe(recipe)
	return {
		"recipe": recipe.to_dictionary() if recipe != null else {},
		"set_id": set_id,
		"default_export": _export_profile.default_export(),
		"animations": checklist,
		"sockets": socket_report.get("sockets", {}),
		"provenance": {
			"recipe_id": recipe.recipe_id if recipe != null else "",
			"content_pack_id": recipe.content_pack_id if recipe != null else "",
			"content_version": content_version(),
			"export_profile_id": recipe.export_profile_id if recipe != null else "",
			"sockets": socket_report.get("sockets", {}),
		},
	}

func socket_report_for_recipe(recipe: CC2DRecipe, animation_id := "idle") -> Dictionary:
	_ensure_loaded()
	var sockets := {}
	if recipe != null:
		sockets = recipe.equipment_sockets.duplicate(true)
	sockets = (_backfill_equipment_sockets(sockets).get("sockets", {}) as Dictionary).duplicate(true)
	var transforms := {}
	var clip_metadata := clip_metadata_for_animation(animation_id)
	var curve_samples := _sample_curve_bindings_for_frame(
		clip_metadata.get("curve_bindings", []) as Array,
		0,
		int(clip_metadata.get("frame_count", 1)),
		float(clip_metadata.get("stop_time", 0.0))
	)
	transforms = _part_transforms_from_curve_samples(curve_samples)
	var socket_entries := {}
	for socket_id: String in sockets.keys():
		var socket := sockets.get(socket_id, {}) as Dictionary
		var anchor := str(socket.get("anchor", ""))
		var offset := _vector2_from_socket_offset(socket.get("offset", Vector2.ZERO))
		var sampled_offset := offset + _sampled_anchor_offset(anchor, transforms)
		socket_entries[socket_id] = {
			"slot": str(socket.get("slot", socket_id)),
			"anchor": anchor,
			"offset": _socket_offset_dictionary(offset),
			"compatible_tags": _string_array(socket.get("compatible_tags", [])),
			"sampled_offset": _socket_offset_dictionary(sampled_offset),
		}
	return {
		"animation_id": animation_id,
		"sockets": socket_entries,
	}

func write_validation_report(recipe: CC2DRecipe, report_path: String, set_id := "first_slice_player") -> Dictionary:
	if recipe == null or report_path.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Recipe and report path are required."],
		}
	var validation := validate_recipe(recipe, set_id)
	var export_plan := export_plan_for_recipe(recipe, set_id)
	var report := {
		"ok": bool(validation.get("valid", false)),
		"recipe_id": recipe.recipe_id,
		"display_name": recipe.display_name,
		"set_id": set_id,
		"content_version": content_version(),
		"validation": validation,
		"export_plan": export_plan,
	}
	var global_path := ProjectSettings.globalize_path(report_path)
	DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file == null:
		return {
			"ok": false,
			"errors": ["Could not write validation report: %s" % report_path],
		}
	file.store_string(JSON.stringify(report, "\t"))
	report.report_path = report_path
	return report

func bake_export_sheets(recipe: CC2DRecipe, output_root: String, set_id := "first_slice_player", max_frames_per_animation := 1) -> Dictionary:
	_ensure_loaded()
	if recipe == null or output_root.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Recipe and output root are required."],
			"animations": [],
		}
	var errors: Array[String] = []
	var animations: Array[Dictionary] = []
	var export_settings := _export_profile.default_export()
	var frame_width := int(export_settings.get("width", 512))
	var frame_height := int(export_settings.get("height", 512))
	var target_fps := float(export_settings.get("target_fps", 12))
	var columns := int(_export_profile.godot_sheet_target().get("columns", 8))
	columns = max(1, columns)
	var global_output_root := ProjectSettings.globalize_path(output_root)
	DirAccess.make_dir_recursive_absolute(global_output_root)
	for item: Dictionary in _checklist_for_recipe_set(recipe, set_id):
		if not bool(item.get("available", false)):
			continue
		var animation_id := str(item.get("id", ""))
		var clip_metadata := clip_metadata_for_animation(animation_id)
		var clip_frame_count := int(clip_metadata.get("frame_count", 1))
		var frame_count := clampi(clip_frame_count, 1, max(1, int(max_frames_per_animation)))
		var sheet_path := "%s/%s_sheet.png" % [output_root.rstrip("/"), animation_id]
		var baked := _bake_animation_sheet(recipe, sheet_path, frame_width, frame_height, frame_count, columns, clip_metadata)
		if not bool(baked.get("ok", false)):
			errors.append_array(baked.get("errors", []) as Array)
			continue
		animations.append({
			"id": animation_id,
			"sheet": sheet_path,
			"frame_width": frame_width,
			"frame_height": frame_height,
			"frame_count": frame_count,
			"columns": columns,
			"loop": bool(item.get("loop", false)),
			"fps": target_fps,
			"uses_rig_motion": bool(baked.get("uses_rig_motion", false)),
			"rig_sample_count": int(baked.get("rig_sample_count", 0)),
			"uses_pixel_rotation": bool(baked.get("uses_pixel_rotation", false)),
			"pixel_rotation_count": int(baked.get("pixel_rotation_count", 0)),
		})
	var source_spec_path := "%s/source_spec.json" % output_root.rstrip("/")
	var source_spec := {
		"recipe_id": recipe.recipe_id,
		"set_id": set_id,
		"animations": animations,
	}
	var spec_file := FileAccess.open(source_spec_path, FileAccess.WRITE)
	if spec_file == null:
		errors.append("Could not write source spec: %s" % source_spec_path)
	else:
		spec_file.store_string(JSON.stringify(source_spec, "\t"))
	return {
		"ok": errors.is_empty() and not animations.is_empty(),
		"errors": errors,
		"output_root": output_root,
		"source_spec": source_spec_path,
		"set_id": set_id,
		"animations": animations,
	}

func bake_export_spriteframes(recipe: CC2DRecipe, output_root: String, spriteframes_path: String, set_id := "first_slice_player", max_frames_per_animation := 1) -> Dictionary:
	var report := bake_export_sheets(recipe, output_root, set_id, max_frames_per_animation)
	if not bool(report.get("ok", false)):
		return report
	if spriteframes_path.strip_edges().is_empty():
		var errors := report.get("errors", []) as Array
		errors.append("SpriteFrames output path is required.")
		report.errors = errors
		report.ok = false
		return report
	var spriteframes := _spriteframes_from_bake_report(report)
	if spriteframes == null:
		var errors := report.get("errors", []) as Array
		errors.append("Could not create SpriteFrames from baked sheets.")
		report.errors = errors
		report.ok = false
		return report
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(spriteframes_path).get_base_dir())
	if FileAccess.file_exists(spriteframes_path):
		DirAccess.remove_absolute(spriteframes_path)
	var save_error := ResourceSaver.save(spriteframes, spriteframes_path)
	if save_error != OK:
		var errors := report.get("errors", []) as Array
		errors.append("Could not save SpriteFrames: %s" % spriteframes_path)
		report.errors = errors
		report.ok = false
		return report
	recipe.generated_spriteframes_path = spriteframes_path
	report.spriteframes = spriteframes_path
	return report

func bake_contact_sheet(recipe: CC2DRecipe, contact_sheet_path: String, set_id := "first_slice_player", max_frames_per_animation := 2) -> Dictionary:
	if contact_sheet_path.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Contact sheet output path is required."],
			"frames": 0,
		}
	var sheet_output_root := "%s_sheets" % contact_sheet_path.get_basename()
	var report := bake_export_sheets(recipe, sheet_output_root, set_id, max_frames_per_animation)
	if not bool(report.get("ok", false)):
		return report
	var animations := report.get("animations", []) as Array
	var frame_entries: Array[Dictionary] = []
	for animation: Dictionary in animations:
		var sheet_path := str(animation.get("sheet", ""))
		if sheet_path.is_empty() or not FileAccess.file_exists(sheet_path):
			continue
		var frame_count := int(animation.get("frame_count", 0))
		for frame_index: int in frame_count:
			frame_entries.append({
				"sheet": sheet_path,
				"frame_index": frame_index,
				"frame_width": int(animation.get("frame_width", 0)),
				"frame_height": int(animation.get("frame_height", 0)),
				"columns": int(animation.get("columns", 1)),
			})
	if frame_entries.is_empty():
		return {
			"ok": false,
			"errors": ["No frames available for contact sheet."],
			"frames": 0,
		}
	var frame_width := int(frame_entries[0].get("frame_width", 512))
	var frame_height := int(frame_entries[0].get("frame_height", 512))
	var columns := mini(4, max(1, frame_entries.size()))
	var rows := int(ceil(float(frame_entries.size()) / float(columns)))
	var contact_sheet := Image.create(frame_width * columns, frame_height * rows, false, Image.FORMAT_RGBA8)
	contact_sheet.fill(Color(0, 0, 0, 0))
	var source_cache := {}
	for index: int in frame_entries.size():
		var entry := frame_entries[index] as Dictionary
		var sheet_path := str(entry.get("sheet", ""))
		var source := source_cache.get(sheet_path, null) as Image
		if source == null:
			source = Image.new()
			if source.load(sheet_path) != OK:
				continue
			source_cache[sheet_path] = source
		var source_columns: int = max(1, int(entry.get("columns", 1)))
		var source_frame_index := int(entry.get("frame_index", 0))
		var source_rect := Rect2i(
			Vector2i((source_frame_index % source_columns) * frame_width, int(source_frame_index / source_columns) * frame_height),
			Vector2i(frame_width, frame_height)
		)
		var destination := Vector2i((index % columns) * frame_width, int(index / columns) * frame_height)
		contact_sheet.blend_rect(source, source_rect, destination)
	var global_path := ProjectSettings.globalize_path(contact_sheet_path)
	DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
	var save_error := contact_sheet.save_png(contact_sheet_path)
	if save_error != OK:
		return {
			"ok": false,
			"errors": ["Could not save contact sheet: %s" % contact_sheet_path],
			"frames": frame_entries.size(),
		}
	return {
		"ok": true,
		"errors": [],
		"contact_sheet": contact_sheet_path,
		"frames": frame_entries.size(),
		"columns": columns,
		"rows": rows,
		"source_report": report,
	}

func bake_export_target(recipe: CC2DRecipe, output_path: String, target_id := "portrait") -> Dictionary:
	_ensure_loaded()
	var normalized_target := str(target_id).strip_edges().to_lower()
	if recipe == null or output_path.strip_edges().is_empty():
		return {
			"ok": false,
			"errors": ["Recipe and output path are required."],
			"target": normalized_target,
			"path": output_path,
			"width": 0,
			"height": 0,
		}
	if not EXPORT_TARGET_SIZES.has(normalized_target):
		return {
			"ok": false,
			"errors": ["Unknown export target: %s" % normalized_target],
			"target": normalized_target,
			"path": output_path,
			"width": 0,
			"height": 0,
		}
	var target_size := EXPORT_TARGET_SIZES.get(normalized_target, Vector2i(256, 256)) as Vector2i
	var frame := _compose_recipe_frame(recipe, target_size)
	if frame == null:
		return {
			"ok": false,
			"errors": ["Could not compose %s export target for %s." % [normalized_target, recipe.recipe_id]],
			"target": normalized_target,
			"path": output_path,
			"width": target_size.x,
			"height": target_size.y,
		}
	var global_path := ProjectSettings.globalize_path(output_path)
	DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
	var save_error := frame.save_png(output_path)
	if save_error != OK:
		return {
			"ok": false,
			"errors": ["Could not save %s export target: %s" % [normalized_target, output_path]],
			"target": normalized_target,
			"path": output_path,
			"width": target_size.x,
			"height": target_size.y,
		}
	return {
		"ok": true,
		"errors": [],
		"target": normalized_target,
		"path": output_path,
		"width": target_size.x,
		"height": target_size.y,
	}

func _ensure_loaded() -> void:
	if not _loaded:
		load_content()

func _safe_recipe_id(value: String) -> String:
	var safe := value.strip_edges().to_lower().replace(" ", "_")
	if safe.is_empty():
		return "default"
	return safe

func _default_palettes() -> Dictionary:
	return {
		"skin": "e8b98cff",
		"hair": "2a1b16ff",
		"cloth_primary": "31384aff",
		"cloth_secondary": "8f2d37ff",
		"metal": "b8bcc8ff",
	}

func _default_morphs() -> Dictionary:
	return {
		"body_height": 0.0,
		"body_width": 0.0,
		"head_size": 0.0,
		"weapon_scale": 0.0,
	}

func _default_equipment_sockets() -> Dictionary:
	return {
		"main_hand": {
			"slot": "main_hand",
			"anchor": "hand_r",
			"offset": {"x": 8.0, "y": -4.0},
			"compatible_tags": ["weapon", "melee", "ranged"],
		},
		"off_hand": {
			"slot": "off_hand",
			"anchor": "hand_l",
			"offset": {"x": -8.0, "y": -4.0},
			"compatible_tags": ["shield", "offhand", "weapon"],
		},
		"head": {
			"slot": "head",
			"anchor": "head",
			"offset": {"x": 0.0, "y": -18.0},
			"compatible_tags": ["helmet", "hat", "hair"],
		},
		"chest": {
			"slot": "chest",
			"anchor": "body",
			"offset": {"x": 0.0, "y": -4.0},
			"compatible_tags": ["armor", "shirt", "accessory"],
		},
		"back": {
			"slot": "back",
			"anchor": "back",
			"offset": {"x": 0.0, "y": -8.0},
			"compatible_tags": ["cape", "cloak", "backpack"],
		},
	}

func _backfill_equipment_sockets(existing_sockets: Dictionary) -> Dictionary:
	var sockets := existing_sockets.duplicate(true)
	var changed := false
	for socket_id: String in _default_equipment_sockets().keys():
		if not sockets.has(socket_id):
			sockets[socket_id] = (_default_equipment_sockets().get(socket_id, {}) as Dictionary).duplicate(true)
			changed = true
			continue
		var socket := sockets.get(socket_id, {}) as Dictionary
		var default_socket := _default_equipment_sockets().get(socket_id, {}) as Dictionary
		for key: String in ["slot", "anchor", "offset", "compatible_tags"]:
			if not socket.has(key):
				socket[key] = default_socket.get(key)
				changed = true
		sockets[socket_id] = socket
	return {
		"changed": changed,
		"sockets": sockets,
	}

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result

func _vector2_from_socket_offset(value: Variant) -> Vector2:
	if value is Vector2:
		return value as Vector2
	if value is Vector2i:
		var vector := value as Vector2i
		return Vector2(vector.x, vector.y)
	if value is Dictionary:
		var dictionary := value as Dictionary
		return Vector2(float(dictionary.get("x", 0.0)), float(dictionary.get("y", 0.0)))
	if value is Array:
		var array := value as Array
		if array.size() >= 2:
			return Vector2(float(array[0]), float(array[1]))
	return Vector2.ZERO

func _socket_offset_dictionary(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}

func _sampled_anchor_offset(anchor: String, part_transforms: Dictionary) -> Vector2:
	var normalized_anchor := _normalize_curve_part_name(anchor.replace("_", " "))
	for target_name: String in _curve_part_targets_for_socket_anchor(normalized_anchor):
		var normalized_target := _normalize_curve_part_name(target_name)
		if part_transforms.has(normalized_target):
			var transform := part_transforms.get(normalized_target, {}) as Dictionary
			return transform.get("offset", Vector2.ZERO) as Vector2
	return Vector2.ZERO

func _curve_part_targets_for_socket_anchor(anchor: String) -> Array[String]:
	match anchor:
		"hand r", "main hand":
			return ["Hand R", "Lower Arm R", "Upper Arm R", "Body", "Hip"]
		"hand l", "off hand":
			return ["Hand L", "Lower Arm L", "Upper Arm L", "Body", "Hip"]
		"head":
			return ["Head", "Neck", "Body", "Hip"]
		"body", "chest":
			return ["Body", "Hip"]
		"back":
			return ["Cape", "Cape 1 M", "Body", "Hip"]
		_:
			return [anchor, "Body", "Hip"]

func _dictionary_keys(value: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for key: String in value.keys():
		result.append(key)
	result.sort()
	return result

func _array_difference(left: Array, right: Array) -> Array[String]:
	var result: Array[String] = []
	var right_strings := _string_array(right)
	for item: String in _string_array(left):
		if not right_strings.has(item):
			result.append(item)
	result.sort()
	return result

func _changed_keys(left: Dictionary, right: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var seen: Dictionary = {}
	for key: String in left.keys():
		seen[key] = true
	for key: String in right.keys():
		seen[key] = true
	for key: String in seen.keys():
		if left.get(key, null) != right.get(key, null):
			result.append(key)
	result.sort()
	return result

func _changed_part_slots(left: Dictionary, right: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var seen: Dictionary = {}
	for slot_id: String in left.keys():
		seen[slot_id] = true
	for slot_id: String in right.keys():
		seen[slot_id] = true
	for slot_id: String in seen.keys():
		var left_part := left.get(slot_id, {}) as Dictionary
		var right_part := right.get(slot_id, {}) as Dictionary
		if str(left_part.get("path", "")) != str(right_part.get("path", "")):
			result.append(slot_id)
	result.sort()
	return result

func _checklist_for_recipe_set(recipe: CC2DRecipe, set_id: String) -> Array[Dictionary]:
	if recipe != null and recipe.custom_export_sets.has(set_id):
		var set_data := recipe.custom_export_sets.get(set_id, {}) as Dictionary
		return _checklist_for_animation_ids(_string_array(set_data.get("animations", [])))
	return _bulk_sets.checklist_for_set(set_id, _export_profile)

func _checklist_for_animation_ids(animation_ids: Array[String]) -> Array[Dictionary]:
	var checklist: Array[Dictionary] = []
	for animation_id: String in animation_ids:
		var export := _export_profile.export_for_game_animation(animation_id)
		checklist.append({
			"id": animation_id,
			"checked": bool(export.get("available", false)),
			"available": bool(export.get("available", false)),
			"base": str(export.get("base", "")),
			"aim": str(export.get("aim", "None")),
			"loop": bool(export.get("loop", false)),
		})
	return checklist

func _options_matching_tags(options: Array, required_tags: Array[String]) -> Array:
	if required_tags.is_empty():
		return options
	var matches: Array = []
	for option: Dictionary in options:
		if _option_matches_required_tags(option, required_tags):
			matches.append(option)
	return matches

func _option_matches_required_tags(option: Dictionary, required_tags: Array[String]) -> bool:
	if required_tags.is_empty():
		return true
	var option_tags := _string_array(option.get("tags", []))
	for tag: String in required_tags:
		if not option_tags.has(tag):
			return false
	return true

func _option_matches_query(option: Dictionary, slot_id: String, normalized_query: String) -> bool:
	if normalized_query.is_empty():
		return true
	var searchable := "%s %s %s %s %s" % [
		slot_id,
		str(option.get("label", "")),
		str(option.get("relative_path", "")),
		str(option.get("category", "")),
		" ".join(_string_array(option.get("tags", []))),
	]
	return searchable.to_lower().contains(normalized_query)

func _constraint_entry(severity: String, messages: Array) -> Dictionary:
	return {
		"severity": severity,
		"messages": messages,
	}

func _compatibility_part_summary(recipe: CC2DRecipe, frame_width: int, frame_height: int) -> Dictionary:
	var summary := {
		"clipping_risk_count": 0,
		"hitbox_risk_count": 0,
		"has_weapon": false,
		"max_part_width": 0,
		"max_part_height": 0,
	}
	if recipe == null:
		return summary
	for slot_id: String in recipe.parts.keys():
		var part := recipe.parts.get(slot_id, {}) as Dictionary
		var searchable := "%s %s %s %s" % [
			slot_id,
			str(part.get("label", "")),
			str(part.get("relative_path", "")),
			" ".join(_string_array(part.get("tags", []))),
		]
		var normalized := searchable.to_lower()
		if normalized.contains("weapon"):
			summary.has_weapon = true
		if _text_contains_any(normalized, ["cape", "skirt", "helmet", "armor", "weapon", "hair"]):
			summary.clipping_risk_count = int(summary.clipping_risk_count) + 1
		if _text_contains_any(normalized, ["cape", "skirt", "armor", "weapon"]):
			summary.hitbox_risk_count = int(summary.hitbox_risk_count) + 1
		var metadata := sprite_metadata_for_part(part)
		for sprite: Dictionary in metadata.get("sprites", []) as Array:
			var rect := sprite.get("rect", Rect2(Vector2.ZERO, Vector2(frame_width, frame_height))) as Rect2
			summary.max_part_width = maxi(int(summary.max_part_width), int(rect.size.x))
			summary.max_part_height = maxi(int(summary.max_part_height), int(rect.size.y))
	return summary

func _animation_ids_include_any(animation_ids: Array[String], needles: Array[String]) -> bool:
	for animation_id: String in animation_ids:
		var normalized := animation_id.to_lower()
		if _text_contains_any(normalized, needles):
			return true
	return false

func _text_contains_any(text: String, needles: Array[String]) -> bool:
	for needle: String in needles:
		if text.contains(needle):
			return true
	return false

func _palette_accessibility_warnings(recipe: CC2DRecipe) -> Array[String]:
	var warnings: Array[String] = []
	if recipe == null:
		return warnings
	var palette_ids := recipe.palettes.keys()
	for left_index: int in palette_ids.size():
		for right_index: int in range(left_index + 1, palette_ids.size()):
			var left_id := str(palette_ids[left_index])
			var right_id := str(palette_ids[right_index])
			var left_color: Variant = _color_from_palette_value(recipe.palettes.get(left_id, ""))
			var right_color: Variant = _color_from_palette_value(recipe.palettes.get(right_id, ""))
			if left_color == null or right_color == null:
				continue
			var contrast := _contrast_ratio(left_color as Color, right_color as Color)
			if contrast < 1.25:
				warnings.append("Low palette contrast between %s and %s." % [left_id, right_id])
	return warnings

func _color_from_palette_value(value: Variant) -> Variant:
	var text := str(value)
	if not text.is_valid_html_color():
		return null
	return Color.html(text)

func _contrast_ratio(left: Color, right: Color) -> float:
	var left_luminance := _relative_luminance(left)
	var right_luminance := _relative_luminance(right)
	var lighter := maxf(left_luminance, right_luminance)
	var darker := minf(left_luminance, right_luminance)
	return (lighter + 0.05) / (darker + 0.05)

func _relative_luminance(color: Color) -> float:
	return 0.2126 * _linear_channel(color.r) + 0.7152 * _linear_channel(color.g) + 0.0722 * _linear_channel(color.b)

func _linear_channel(value: float) -> float:
	if value <= 0.03928:
		return value / 12.92
	return pow((value + 0.055) / 1.055, 2.4)

func _export_budget_for_checklist(checklist: Array) -> Dictionary:
	var export_settings: Dictionary = _export_profile.default_export()
	var frame_width := int(export_settings.get("width", 512))
	var frame_height := int(export_settings.get("height", 512))
	var total_frames := 0
	for item: Dictionary in checklist:
		if bool(item.get("available", false)):
			var clip_metadata := clip_metadata_for_animation(str(item.get("id", "")))
			total_frames += max(1, int(clip_metadata.get("frame_count", 1)))
	var estimated_pixels: int = frame_width * frame_height * max(1, total_frames)
	return {
		"frame_width": frame_width,
		"frame_height": frame_height,
		"estimated_frames": total_frames,
		"estimated_pixels": estimated_pixels,
		"estimated_bytes": estimated_pixels * 4,
	}

func _bake_animation_sheet(recipe: CC2DRecipe, sheet_path: String, frame_width: int, frame_height: int, frame_count: int, columns: int, clip_metadata: Dictionary) -> Dictionary:
	var rows := int(ceil(float(frame_count) / float(max(1, columns))))
	var sheet := Image.create(frame_width * columns, frame_height * rows, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))
	var rig_sample_count := 0
	var pixel_rotation_count := 0
	for frame_index: int in frame_count:
		var samples := _sample_curve_bindings_for_frame(clip_metadata.get("curve_bindings", []) as Array, frame_index, frame_count, float(clip_metadata.get("stop_time", 0.0)))
		rig_sample_count += samples.size()
		var composite_report := {}
		var composite := _compose_recipe_frame(recipe, Vector2i(frame_width, frame_height), samples, composite_report)
		pixel_rotation_count += int(composite_report.get("pixel_rotation_count", 0))
		if composite == null:
			return {
				"ok": false,
				"errors": ["Could not compose recipe frame for %s." % recipe.recipe_id],
			}
		var column := frame_index % columns
		var row := int(frame_index / columns)
		sheet.blend_rect(composite, Rect2i(Vector2i.ZERO, composite.get_size()), Vector2i(column * frame_width, row * frame_height))
	var global_path := ProjectSettings.globalize_path(sheet_path)
	DirAccess.make_dir_recursive_absolute(global_path.get_base_dir())
	var error := sheet.save_png(sheet_path)
	if error != OK:
		return {
			"ok": false,
			"errors": ["Could not save baked sheet: %s" % sheet_path],
		}
	return {
		"ok": true,
		"errors": [],
		"uses_rig_motion": rig_sample_count > 0,
		"rig_sample_count": rig_sample_count,
		"uses_pixel_rotation": pixel_rotation_count > 0,
		"pixel_rotation_count": pixel_rotation_count,
	}

func _spriteframes_from_bake_report(report: Dictionary) -> SpriteFrames:
	var frames := SpriteFrames.new()
	for existing_animation: StringName in frames.get_animation_names():
		frames.remove_animation(existing_animation)
	for entry: Dictionary in report.get("animations", []) as Array:
		var animation_id := str(entry.get("id", ""))
		var sheet_path := str(entry.get("sheet", ""))
		if animation_id.is_empty() or sheet_path.is_empty() or not FileAccess.file_exists(sheet_path):
			continue
		var image := Image.new()
		if image.load(sheet_path) != OK:
			continue
		var texture := ImageTexture.create_from_image(image)
		if texture == null:
			continue
		frames.add_animation(animation_id)
		frames.set_animation_loop(animation_id, bool(entry.get("loop", false)))
		frames.set_animation_speed(animation_id, float(entry.get("fps", 12.0)))
		var frame_width: int = int(entry.get("frame_width", image.get_width()))
		var frame_height: int = int(entry.get("frame_height", image.get_height()))
		var columns: int = max(1, int(entry.get("columns", 1)))
		var frame_count: int = max(1, int(entry.get("frame_count", 1)))
		for frame_index: int in frame_count:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			var column: int = frame_index % columns
			var row: int = int(frame_index / columns)
			atlas.region = Rect2(column * frame_width, row * frame_height, frame_width, frame_height)
			frames.add_frame(animation_id, atlas)
	return frames

func _compose_recipe_frame(recipe: CC2DRecipe, frame_size: Vector2i, curve_samples := [], report := {}) -> Image:
	var frame := Image.create(frame_size.x, frame_size.y, false, Image.FORMAT_RGBA8)
	frame.fill(Color(0, 0, 0, 0))
	var part_transforms := _part_transforms_from_curve_samples(curve_samples)
	var pixel_rotation_count := 0
	for slot_id: String in _preview_slot_order_for_recipe(recipe):
		var part := recipe.parts.get(slot_id, {}) as Dictionary
		var source := _image_for_part_preview(part)
		if source == null:
			continue
		var transform := _transform_for_slot(slot_id, part_transforms)
		if not bool(transform.get("visible", true)):
			continue
		var scaled := source.duplicate() as Image
		var max_width: int = max(1, int(float(frame_size.x) * 0.62))
		var max_height: int = max(1, int(float(frame_size.y) * 0.62))
		var base_scale: float = min(float(max_width) / float(max(1, scaled.get_width())), float(max_height) / float(max(1, scaled.get_height())))
		var part_scale := transform.get("scale", Vector2.ONE) as Vector2
		var scale_x: float = base_scale * maxf(0.05, absf(part_scale.x))
		var scale_y: float = base_scale * maxf(0.05, absf(part_scale.y))
		if scale_x < 1.0 or scale_y < 1.0 or not is_equal_approx(scale_x, 1.0) or not is_equal_approx(scale_y, 1.0):
			scaled.resize(max(1, int(round(float(scaled.get_width()) * scale_x))), max(1, int(round(float(scaled.get_height()) * scale_y))), Image.INTERPOLATE_NEAREST)
		var rotation_degrees := float(transform.get("rotation_degrees", 0.0))
		if not is_zero_approx(wrapf(rotation_degrees, -180.0, 180.0)):
			scaled = _rotate_image_nearest(scaled, rotation_degrees)
			pixel_rotation_count += 1
		var offset := transform.get("offset", Vector2.ZERO) as Vector2
		var destination := Vector2i(
			int((frame_size.x - scaled.get_width()) / 2 + offset.x),
			int(frame_size.y - scaled.get_height() - frame_size.y * 0.12 - offset.y)
		)
		frame.blend_rect(scaled, Rect2i(Vector2i.ZERO, scaled.get_size()), destination)
	report.pixel_rotation_count = pixel_rotation_count
	return frame

func _rotate_image_nearest(source: Image, degrees: float) -> Image:
	if source == null:
		return null
	var normalized_degrees: float = wrapf(degrees, -180.0, 180.0)
	if is_zero_approx(normalized_degrees):
		return source.duplicate()
	var radians: float = deg_to_rad(normalized_degrees)
	var cos_angle: float = cos(radians)
	var sin_angle: float = sin(radians)
	var source_width: int = source.get_width()
	var source_height: int = source.get_height()
	var rotated_width: int = max(1, int(ceil(absf(float(source_width) * cos_angle) + absf(float(source_height) * sin_angle))))
	var rotated_height: int = max(1, int(ceil(absf(float(source_width) * sin_angle) + absf(float(source_height) * cos_angle))))
	var rotated := Image.create(rotated_width, rotated_height, false, Image.FORMAT_RGBA8)
	rotated.fill(Color(0, 0, 0, 0))
	var source_center := Vector2((float(source_width) - 1.0) * 0.5, (float(source_height) - 1.0) * 0.5)
	var rotated_center := Vector2((float(rotated_width) - 1.0) * 0.5, (float(rotated_height) - 1.0) * 0.5)
	for y: int in rotated_height:
		for x: int in rotated_width:
			var destination_offset := Vector2(float(x), float(y)) - rotated_center
			var source_offset := Vector2(
				cos_angle * destination_offset.x + sin_angle * destination_offset.y,
				-sin_angle * destination_offset.x + cos_angle * destination_offset.y
			)
			var source_position := source_center + source_offset
			var source_x := int(round(source_position.x))
			var source_y := int(round(source_position.y))
			if source_x < 0 or source_y < 0 or source_x >= source_width or source_y >= source_height:
				continue
			rotated.set_pixel(x, y, source.get_pixel(source_x, source_y))
	return rotated

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

func _part_transforms_from_curve_samples(samples: Array) -> Dictionary:
	var transforms := {}
	for sample: Dictionary in samples:
		var part_name := _normalize_curve_part_name(str(sample.get("part_name", "")))
		if part_name.is_empty():
			continue
		var transform := transforms.get(part_name, {
			"offset": Vector2.ZERO,
			"rotation_degrees": 0.0,
			"scale": Vector2.ONE,
			"visible": true,
		}) as Dictionary
		var attribute := str(sample.get("attribute", ""))
		var value: Variant = sample.get("value", 0.0)
		if value is Vector3:
			var vector_value := value as Vector3
			if attribute == "m_LocalPosition":
				transform.offset = Vector2(vector_value.x, vector_value.y)
			elif attribute == "m_LocalScale":
				transform.scale = Vector2(vector_value.x, vector_value.y)
			else:
				transform.rotation_degrees = vector_value.z
		elif attribute == "m_IsActive":
			transform.visible = float(value) > 0.5
		elif attribute.begins_with("m_LocalPosition."):
			var offset := transform.get("offset", Vector2.ZERO) as Vector2
			if attribute.ends_with(".x"):
				offset.x = float(value)
			elif attribute.ends_with(".y"):
				offset.y = float(value)
			transform.offset = offset
		elif attribute.begins_with("m_LocalScale."):
			var scale := transform.get("scale", Vector2.ONE) as Vector2
			if attribute.ends_with(".x"):
				scale.x = float(value)
			elif attribute.ends_with(".y"):
				scale.y = float(value)
			transform.scale = scale
		elif attribute.begins_with("localEulerAnglesRaw."):
			if attribute.ends_with(".z"):
				transform.rotation_degrees = float(value)
		transforms[part_name] = transform
	for part_name: String in transforms.keys():
		var transform := transforms.get(part_name, {}) as Dictionary
		var offset := transform.get("offset", Vector2.ZERO) as Vector2
		var rotation_degrees := float(transform.get("rotation_degrees", 0.0))
		if not is_zero_approx(rotation_degrees):
			offset += Vector2(sin(deg_to_rad(rotation_degrees)), -cos(deg_to_rad(rotation_degrees))) * 3.0
		transform.offset = offset
		transforms[part_name] = transform
	return transforms

func _transform_for_slot(slot_id: String, part_transforms: Dictionary) -> Dictionary:
	var target_names := _curve_part_targets_for_slot(slot_id)
	var combined := {
		"offset": Vector2.ZERO,
		"rotation_degrees": 0.0,
		"scale": Vector2.ONE,
		"visible": true,
	}
	var matched := false
	for target_name: String in target_names:
		var normalized := _normalize_curve_part_name(target_name)
		if part_transforms.has(normalized):
			var transform := part_transforms.get(normalized, {}) as Dictionary
			combined.offset = (combined.offset as Vector2) + (transform.get("offset", Vector2.ZERO) as Vector2)
			combined.rotation_degrees = float(combined.rotation_degrees) + float(transform.get("rotation_degrees", 0.0))
			var combined_scale := combined.scale as Vector2
			var transform_scale := transform.get("scale", Vector2.ONE) as Vector2
			combined.scale = Vector2(combined_scale.x * transform_scale.x, combined_scale.y * transform_scale.y)
			combined.visible = bool(combined.visible) and bool(transform.get("visible", true))
			matched = true
	if matched:
		return combined
	return combined

func _curve_part_targets_for_slot(slot_id: String) -> Array[String]:
	if slot_id.contains("Hair") or slot_id.contains("Helmet") or slot_id.contains("Ear") or slot_id.contains("Eye") or slot_id.contains("Eyebrow") or slot_id.contains("Mouth") or slot_id.contains("Nose") or slot_id.contains("Facial Hair"):
		return ["Head", "Neck", "Body", "Hip"]
	if slot_id.contains("Weapon") or slot_id.contains("Gloves"):
		return ["Hand R", "Lower Arm R", "Upper Arm R", "Body", "Hip"]
	if slot_id.contains("Boot"):
		return ["Foot R", "Foot L", "Upper Leg R", "Upper Leg L", "Hip"]
	if slot_id.contains("Pants"):
		return ["Upper Leg R", "Upper Leg L", "Hip"]
	if slot_id.contains("Skirt"):
		return ["Skirt 1 M", "Skirt T", "Hip"]
	if slot_id.contains("Cape"):
		return ["Cape 1 M", "Cape", "Body", "Hip"]
	return ["Body", "Hip"]

func _normalize_curve_part_name(value: String) -> String:
	var normalized := value.replace("_", " ").strip_edges().to_lower()
	var pieces := normalized.split(" ", false)
	return " ".join(pieces)

func _image_for_part_preview(part: Dictionary) -> Image:
	var path := str(part.get("path", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var texture := load(path) as Texture2D
	if texture == null:
		return null
	var image := texture.get_image()
	if image == null:
		return null
	var metadata := sprite_metadata_for_part(part)
	var sprites := metadata.get("sprites", []) as Array
	if not sprites.is_empty():
		var sprite := sprites[0] as Dictionary
		var rect := sprite.get("rect", Rect2(Vector2.ZERO, image.get_size())) as Rect2
		var crop_rect := Rect2i(Vector2i(int(rect.position.x), int(rect.position.y)), Vector2i(int(rect.size.x), int(rect.size.y)))
		if crop_rect.size.x > 0 and crop_rect.size.y > 0:
			return image.get_region(crop_rect)
	return image

func _preview_slot_order_for_recipe(recipe: CC2DRecipe) -> Array[String]:
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
		if recipe.parts.has(slot_id):
			ordered.append(slot_id)
	for slot_id: String in recipe.parts.keys():
		if not ordered.has(slot_id):
			ordered.append(slot_id)
	return ordered

func _clip_file_path(source_path: String) -> String:
	if source_path.is_empty():
		return ""
	var raw_dir := _export_profile.raw_source_dir().replace("\\", "/")
	var normalized_source := source_path.replace("\\", "/")
	if raw_dir.is_empty():
		return _manifest.project_path(normalized_source)
	return _manifest.project_path("%s/%s" % [raw_dir, normalized_source])

func _parse_unity_anim_file(path: String) -> Dictionary:
	var data := {
		"sample_rate": 0,
		"stop_time": 0.0,
		"curve_bindings": [],
	}
	var text := FileAccess.get_file_as_string(path)
	var curve_bindings: Array[Dictionary] = []
	var current_curve: Dictionary = {}
	var current_keyframe: Dictionary = {}
	var current_curve_section := ""
	var path_can_continue := false
	for raw_line: String in text.split("\n"):
		var line := raw_line.strip_edges()
		if line.begins_with("m_SampleRate:"):
			data.sample_rate = int(line.get_slice(":", 1).strip_edges())
		elif line.begins_with("m_StopTime:"):
			data.stop_time = float(line.get_slice(":", 1).strip_edges())
		elif line.begins_with("m_EulerCurves:"):
			current_curve_section = "euler"
		elif line.begins_with("m_PositionCurves:"):
			current_curve_section = "position"
		elif line.begins_with("m_ScaleCurves:"):
			current_curve_section = "scale"
		elif line.begins_with("m_FloatCurves:"):
			current_curve_section = "float"
		elif line == "- curve:":
			_append_curve_binding(curve_bindings, current_curve)
			current_curve = {
				"attribute": _attribute_for_curve_section(current_curve_section),
				"path": "",
				"part_name": "",
				"keyframes": [],
			}
			current_keyframe = {}
			path_can_continue = false
		elif current_curve.is_empty():
			continue
		elif line.begins_with("attribute:"):
			current_curve.attribute = line.get_slice(":", 1).strip_edges()
			path_can_continue = false
		elif line.begins_with("path:"):
			current_curve.path = line.get_slice(":", 1).strip_edges()
			path_can_continue = true
		elif path_can_continue and not line.is_empty() and not line.begins_with("-") and line.find(":") < 0:
			current_curve.path = "%s %s" % [str(current_curve.get("path", "")).strip_edges(), line]
		elif line.begins_with("time:"):
			if not current_keyframe.is_empty():
				(current_curve.keyframes as Array).append(current_keyframe)
			current_keyframe = {
				"time": float(line.get_slice(":", 1).strip_edges()),
			}
			path_can_continue = false
		elif line.begins_with("value:") and not current_keyframe.is_empty():
			current_keyframe.value = _parse_curve_value(line.get_slice(":", 1).strip_edges())
			path_can_continue = false
		elif line.begins_with("inSlope:") or line.begins_with("outSlope:") or line.begins_with("tangentMode:"):
			path_can_continue = false
	if not current_keyframe.is_empty() and not current_curve.is_empty():
		(current_curve.keyframes as Array).append(current_keyframe)
	_append_curve_binding(curve_bindings, current_curve)
	data.curve_bindings = curve_bindings
	return data

func _attribute_for_curve_section(section: String) -> String:
	if section == "euler":
		return "localEulerAnglesRaw"
	if section == "position":
		return "m_LocalPosition"
	if section == "scale":
		return "m_LocalScale"
	return ""

func _append_curve_binding(curve_bindings: Array[Dictionary], curve: Dictionary) -> void:
	if curve.is_empty():
		return
	var path := str(curve.get("path", "")).strip_edges()
	var keyframes := curve.get("keyframes", []) as Array
	if path.is_empty() or keyframes.is_empty():
		return
	curve.path = path
	curve.part_name = _part_name_for_curve_path(path)
	curve_bindings.append(curve.duplicate(true))

func _parse_curve_value(text: String) -> Variant:
	var stripped := text.strip_edges()
	if stripped.begins_with("{"):
		return _parse_inline_vector3(stripped)
	return float(stripped)

func _empty_sprite_metadata(meta_path: String) -> Dictionary:
	return {
		"meta_path": meta_path,
		"available": false,
		"sprites": [],
	}

func _parse_unity_sprite_meta(path: String) -> Array[Dictionary]:
	var sprites: Array[Dictionary] = []
	var current: Dictionary = {}
	var in_rect := false
	for raw_line: String in FileAccess.get_file_as_string(path).split("\n"):
		var line := raw_line.strip_edges()
		if line.begins_with("- serializedVersion:"):
			if current.has("name") and current.has("rect"):
				sprites.append(current)
			current = {}
			in_rect = false
		elif line.begins_with("name:") and not current.has("name"):
			current.name = line.get_slice(":", 1).strip_edges()
		elif line == "rect:":
			in_rect = true
			current["_rect_values"] = {}
		elif in_rect and (line.begins_with("x:") or line.begins_with("y:") or line.begins_with("width:") or line.begins_with("height:")):
			var key := line.get_slice(":", 0).strip_edges()
			var rect_values := current.get("_rect_values", {}) as Dictionary
			rect_values[key] = float(line.get_slice(":", 1).strip_edges())
			current["_rect_values"] = rect_values
			if rect_values.has("x") and rect_values.has("y") and rect_values.has("width") and rect_values.has("height"):
				current.rect = Rect2(float(rect_values.x), float(rect_values.y), float(rect_values.width), float(rect_values.height))
		elif line.begins_with("pivot:"):
			current.pivot = _parse_inline_vector2(line.substr("pivot:".length()).strip_edges())
			in_rect = false
		elif line.begins_with("border:") or line.begins_with("outline:"):
			in_rect = false
	if current.has("name") and current.has("rect"):
		sprites.append(current)
	for sprite: Dictionary in sprites:
		sprite.erase("_rect_values")
	return sprites

func _parse_inline_vector2(text: String) -> Vector2:
	var stripped := text.strip_edges().trim_prefix("{").trim_suffix("}")
	var values := {}
	for piece: String in stripped.split(",", false):
		var key := piece.get_slice(":", 0).strip_edges()
		values[key] = float(piece.get_slice(":", 1).strip_edges())
	return Vector2(float(values.get("x", 0.0)), float(values.get("y", 0.0)))

func _parse_inline_vector3(text: String) -> Vector3:
	var stripped := text.strip_edges().trim_prefix("{").trim_suffix("}")
	var values := {}
	for piece: String in stripped.split(",", false):
		var key := piece.get_slice(":", 0).strip_edges()
		values[key] = float(piece.get_slice(":", 1).strip_edges())
	return Vector3(float(values.get("x", 0.0)), float(values.get("y", 0.0)), float(values.get("z", 0.0)))

func _part_name_for_curve_path(path: String) -> String:
	var normalized := path.replace("Bone _", "Bone_")
	var segments := normalized.split("/", false)
	for offset: int in segments.size():
		var index := segments.size() - 1 - offset
		var segment := segments[index].strip_edges()
		if segment.begins_with("Bone_"):
			return segment.trim_prefix("Bone_").strip_edges()
		if segment.begins_with("Bone "):
			return segment.trim_prefix("Bone ").strip_edges()
	return segments[segments.size() - 1].strip_edges() if not segments.is_empty() else ""

func _source_path_for_export(animation_id: String, export: Dictionary) -> String:
	var direct_source := str(export.get("source_path", ""))
	if not direct_source.is_empty():
		return direct_source
	var target_base := str(export.get("base", ""))
	var target_aim := str(export.get("aim", "None"))
	var all_exports := _export_profile.all_animation_exports()
	for native_id: String in all_exports.keys():
		var native := all_exports.get(native_id, {}) as Dictionary
		if str(native.get("base", "")) == target_base and str(native.get("aim", "None")) == target_aim:
			return str(native.get("source_path", ""))
	for native_id: String in all_exports.keys():
		var native := all_exports.get(native_id, {}) as Dictionary
		if str(native.get("base", "")) == target_base:
			return str(native.get("source_path", ""))
	return ""
