extends RefCounted
class_name CC2DBulkExportSets

const DEFAULT_SETS_PATH := "res://resources/character_creator_2d/base_fantasy_bulk_export_sets.json"
const CC2DExportProfile := preload("res://scripts/character_creator/cc2d_export_profile.gd")

var sets_path := DEFAULT_SETS_PATH
var _data: Dictionary = {}

func load_sets(path := DEFAULT_SETS_PATH) -> bool:
	sets_path = path
	if not FileAccess.file_exists(sets_path):
		_data = {}
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(sets_path))
	if not parsed is Dictionary:
		_data = {}
		return false
	_data = parsed
	return true

func default_set_id() -> String:
	return str(_data.get("default_set", ""))

func set_ids() -> Array[String]:
	var ids: Array[String] = []
	var sets := _sets()
	for set_id: String in sets.keys():
		ids.append(set_id)
	ids.sort()
	return ids

func set_data(set_id: String) -> Dictionary:
	return (_sets().get(set_id, {}) as Dictionary).duplicate(true)

func animation_ids(set_id: String) -> Array[String]:
	var ids: Array[String] = []
	for animation_id: Variant in set_data(set_id).get("animations", []):
		ids.append(str(animation_id))
	return ids

func checklist_for_set(set_id: String, profile: CC2DExportProfile) -> Array[Dictionary]:
	var checklist: Array[Dictionary] = []
	if profile == null:
		return checklist
	for animation_id: String in animation_ids(set_id):
		var export := profile.export_for_game_animation(animation_id)
		checklist.append({
			"id": animation_id,
			"checked": bool(export.get("available", false)),
			"available": bool(export.get("available", false)),
			"base": str(export.get("base", "")),
			"aim": str(export.get("aim", "None")),
			"loop": bool(export.get("loop", false)),
		})
	return checklist

func _sets() -> Dictionary:
	return _data.get("sets", {}) as Dictionary
