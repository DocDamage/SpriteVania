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
