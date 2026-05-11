extends RefCounted
class_name CC2DExportProfile

const DEFAULT_PROFILE_PATH := "res://resources/character_creator_2d/base_fantasy_export_profile.json"

var profile_path := DEFAULT_PROFILE_PATH
var _data: Dictionary = {}

func load_profile(path := DEFAULT_PROFILE_PATH) -> bool:
	profile_path = path
	if not FileAccess.file_exists(profile_path):
		_data = {}
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(profile_path))
	if not parsed is Dictionary:
		_data = {}
		return false
	_data = parsed
	return true

func base_layer_states() -> Array:
	return _data.get("base_layer_states", []) as Array

func aim_layer_states() -> Array:
	return _data.get("aim_layer_states", []) as Array

func default_export() -> Dictionary:
	return (_data.get("default_export", {}) as Dictionary).duplicate(true)

func game_animation_exports() -> Dictionary:
	return (_data.get("game_animation_exports", {}) as Dictionary).duplicate(true)

func all_animation_exports() -> Dictionary:
	return (_data.get("all_animation_exports", {}) as Dictionary).duplicate(true)

func export_for_game_animation(animation_id: String) -> Dictionary:
	var game_exports := game_animation_exports()
	if game_exports.has(animation_id):
		return (game_exports.get(animation_id, {}) as Dictionary).duplicate(true)
	return (all_animation_exports().get(animation_id, {}) as Dictionary).duplicate(true)

func has_available_game_animation(animation_id: String) -> bool:
	return bool(export_for_game_animation(animation_id).get("available", false))
