extends RefCounted
class_name CC2DManifest

const DEFAULT_MANIFEST_PATH := "res://resources/character_creator_2d/base_fantasy_manifest.json"

var manifest_path := DEFAULT_MANIFEST_PATH
var _data: Dictionary = {}

func load_manifest(path := DEFAULT_MANIFEST_PATH) -> bool:
	manifest_path = path
	if not FileAccess.file_exists(manifest_path):
		_data = {}
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not parsed is Dictionary:
		_data = {}
		return false
	_data = parsed
	return true

func is_loaded() -> bool:
	return not _data.is_empty()

func copied_asset_count() -> int:
	return int(_data.get("copied_asset_count", 0))

func content_pack_report(available_pack_ids := []) -> Dictionary:
	var pack_id := _content_pack_id()
	var dependencies := _dependencies()
	var migration_ids := _migration_ids()
	var available := _string_array(available_pack_ids)
	if available.is_empty():
		available.append(pack_id)
	return {
		"pack_id": pack_id,
		"version": _content_pack_version(),
		"display_name": str(_data.get("display_name", pack_id.replace("_", " ").capitalize())),
		"source_package": str(_data.get("source_package", "")),
		"manifest_path": manifest_path,
		"dependencies": dependencies,
		"migration_ids": migration_ids,
		"asset_counts": {
			"entries": int(_data.get("entry_count", entries().size())),
			"copied": copied_asset_count(),
			"with_payload": _payload_entry_count(),
		},
		"categories": (_data.get("category_counts", {}) as Dictionary).duplicate(true),
		"extensions": (_data.get("extension_counts", {}) as Dictionary).duplicate(true),
		"conflict_hints": _conflict_hints(),
		"missing_dependency_warnings": _missing_dependency_warnings(dependencies, available),
	}

func entries() -> Array:
	return _data.get("entries", []) as Array

func entries_by_category(category: String) -> Array[Dictionary]:
	var matches: Array[Dictionary] = []
	for entry: Dictionary in entries():
		if str(entry.get("category", "")) == category:
			matches.append(entry)
	return matches

func entries_by_extension(extension: String) -> Array[Dictionary]:
	var normalized := extension.to_lower()
	var matches: Array[Dictionary] = []
	for entry: Dictionary in entries():
		if str(entry.get("extension", "")).to_lower() == normalized:
			matches.append(entry)
	return matches

func entry_for_relative_path(relative_path: String) -> Dictionary:
	var normalized := relative_path.replace("\\", "/")
	for entry: Dictionary in entries():
		if str(entry.get("relative_path", "")).replace("\\", "/") == normalized:
			return entry.duplicate(true)
	return {}

func sprite_paths_containing(path_fragment: String) -> Array[String]:
	var matches: Array[String] = []
	for entry: Dictionary in entries_by_extension(".png"):
		var relative_path := str(entry.get("relative_path", ""))
		var godot_path := str(entry.get("godot_path", ""))
		if relative_path.find(path_fragment) >= 0 and not godot_path.is_empty():
			matches.append(_project_path(godot_path))
	return matches

func first_sprite_path(path_fragment: String) -> String:
	var matches := sprite_paths_containing(path_fragment)
	return matches[0] if not matches.is_empty() else ""

func project_path(path: String) -> String:
	return _project_path(path)

func _project_path(path: String) -> String:
	var normalized := path.replace("\\", "/")
	var marker := "SpriteVania Assets/"
	var marker_index := normalized.find(marker)
	if marker_index >= 0:
		return "res://" + normalized.substr(marker_index)
	if normalized.begins_with("res://"):
		return normalized
	return normalized

func _content_pack_id() -> String:
	for key: String in ["pack_id", "content_pack_id", "id"]:
		var value := str(_data.get(key, "")).strip_edges()
		if not value.is_empty():
			return value
	var basename := manifest_path.get_file().get_basename()
	if basename.ends_with("_manifest"):
		basename = basename.substr(0, basename.length() - "_manifest".length())
	return basename if not basename.is_empty() else "base_fantasy"

func _content_pack_version() -> String:
	for key: String in ["version", "pack_version", "content_version"]:
		var value := str(_data.get(key, "")).strip_edges()
		if not value.is_empty():
			return value
	var source_package := str(_data.get("source_package", ""))
	var version_index := source_package.find("v")
	if version_index >= 0:
		var version_text := source_package.substr(version_index).get_basename()
		if not version_text.is_empty():
			return version_text
	return "%s:%d" % [manifest_path.get_file().get_basename(), copied_asset_count()]

func _dependencies() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var source: Variant = _data.get("dependencies", _data.get("content_dependencies", []))
	if source is Array:
		for item: Variant in source:
			if item is Dictionary:
				var dependency := (item as Dictionary).duplicate(true)
				dependency["pack_id"] = str(dependency.get("pack_id", dependency.get("id", "")))
				dependency["required"] = bool(dependency.get("required", true))
				result.append(dependency)
			else:
				result.append({
					"pack_id": str(item),
					"required": true,
				})
	return result

func _migration_ids() -> Array[String]:
	var result: Array[String] = []
	var source: Variant = _data.get("migration_ids", _data.get("migrations", []))
	if source is Array:
		for item: Variant in source:
			result.append(str(item))
	elif source is Dictionary:
		for key: String in (source as Dictionary).keys():
			result.append(key)
	result.sort()
	return result

func _payload_entry_count() -> int:
	var count := 0
	for entry: Dictionary in entries():
		if bool(entry.get("has_payload", false)):
			count += 1
	return count

func _conflict_hints() -> Array[String]:
	var hints: Array[String] = []
	hints.append_array(_duplicate_entry_hints("relative_path", "relative paths"))
	hints.append_array(_duplicate_entry_hints("godot_path", "Godot output paths"))
	hints.append_array(_duplicate_entry_hints("guid", "Unity GUIDs"))
	return hints

func _duplicate_entry_hints(field_id: String, label: String) -> Array[String]:
	var seen := {}
	var duplicates := {}
	for entry: Dictionary in entries():
		var value := str(entry.get(field_id, "")).strip_edges()
		if value.is_empty():
			continue
		if seen.has(value):
			duplicates[value] = int(duplicates.get(value, 1)) + 1
		else:
			seen[value] = true
	var hints: Array[String] = []
	for value: String in duplicates.keys():
		hints.append("Duplicate %s: %s (%d entries)." % [label, value, int(duplicates.get(value, 0))])
	hints.sort()
	return hints

func _missing_dependency_warnings(dependencies: Array[Dictionary], available_pack_ids: Array[String]) -> Array[String]:
	var warnings: Array[String] = []
	for dependency: Dictionary in dependencies:
		if not bool(dependency.get("required", true)):
			continue
		var dependency_id := str(dependency.get("pack_id", "")).strip_edges()
		if dependency_id.is_empty() or available_pack_ids.has(dependency_id):
			continue
		warnings.append("Missing required content pack dependency: %s." % dependency_id)
	return warnings

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result
