extends Node

const GameStateScript := preload("res://scripts/core/game_state.gd")
const DEFAULT_SLOT_IDS := ["default", "slot_a", "slot_b", "slot_c"]

@export var save_path: String = "user://spritevania_save.json"

func has_save() -> bool:
	return FileAccess.file_exists(save_path)

func save_game(state: GameStateScript) -> bool:
	return _save_state_to_path(save_path, state)

func load_game() -> GameStateScript:
	return _load_state_from_path(save_path)

func save_game_to_slot(slot_id: String, state: GameStateScript) -> bool:
	return _save_state_to_path(_slot_save_path(slot_id), state)

func load_game_from_slot(slot_id: String) -> GameStateScript:
	return _load_state_from_path(_path_for_slot_id(slot_id))

func has_save_in_slot(slot_id: String) -> bool:
	return FileAccess.file_exists(_path_for_slot_id(slot_id))

func read_save_slot_metadata(slot_id: String) -> Dictionary:
	var path := _path_for_slot_id(slot_id)
	var metadata := {
		"slot_id": _safe_slot_id(slot_id),
		"path": path,
		"exists": FileAccess.file_exists(path),
		"valid": false,
		"status": "Empty",
		"modified_time": 0,
		"selected_class": "",
		"current_area": "",
		"current_room": "",
		"level": 0,
	}
	if not bool(metadata.exists):
		return metadata

	metadata.modified_time = FileAccess.get_modified_time(path)
	var state := _load_state_from_path(path, false)
	if state == null:
		metadata.status = "Corrupt"
		return metadata

	metadata.valid = true
	metadata.status = "Saved"
	metadata.selected_class = state.selected_class
	metadata.current_area = state.current_area
	metadata.current_room = state.current_room
	metadata.level = state.level
	return metadata

func scan_save_slots(slot_ids := DEFAULT_SLOT_IDS) -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for slot_id: Variant in slot_ids:
		slots.append(read_save_slot_metadata(str(slot_id)))
	return slots

func resolve_latest_valid_save_slot(slot_ids := DEFAULT_SLOT_IDS) -> String:
	var latest_slot := ""
	var latest_modified_time := -1
	for metadata: Dictionary in scan_save_slots(slot_ids):
		if not bool(metadata.get("valid", false)):
			continue
		var modified_time := int(metadata.get("modified_time", 0))
		if modified_time >= latest_modified_time:
			latest_modified_time = modified_time
			latest_slot = str(metadata.get("slot_id", ""))
	return latest_slot

func has_any_valid_save(slot_ids := DEFAULT_SLOT_IDS) -> bool:
	return not resolve_latest_valid_save_slot(slot_ids).is_empty()

func load_latest_valid_game(slot_ids := DEFAULT_SLOT_IDS) -> GameStateScript:
	var slot_id := resolve_latest_valid_save_slot(slot_ids)
	if slot_id.is_empty():
		return null
	if slot_id == "default":
		return load_game()
	return load_game_from_slot(slot_id)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(save_path)

func _save_state_to_path(path: String, state: GameStateScript) -> bool:
	var base_dir := path.get_base_dir()
	if not base_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(base_dir)

	var temp_path := _temporary_save_path(path)
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: %s" % temp_path)
		return false

	file.store_string(JSON.stringify(state.to_dictionary()))
	file = null

	if FileAccess.file_exists(path):
		var remove_error := DirAccess.remove_absolute(path)
		if remove_error != OK:
			DirAccess.remove_absolute(temp_path)
			push_error("Could not replace save file: %s" % path)
			return false
	var rename_error := DirAccess.rename_absolute(temp_path, path)
	if rename_error != OK:
		DirAccess.remove_absolute(temp_path)
		push_error("Could not finalize save file: %s" % path)
		return false
	return true

func _load_state_from_path(path: String, report_errors := true) -> GameStateScript:
	if not FileAccess.file_exists(path):
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		if report_errors:
			push_error("Could not open save file for reading: %s" % path)
		return null

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		if report_errors:
			push_error("Save file is corrupt: %s" % path)
		return null
	var parsed: Variant = json.data
	if not parsed is Dictionary:
		if report_errors:
			push_error("Save file is corrupt: %s" % path)
		return null

	return GameStateScript.from_dictionary(parsed)

func _path_for_slot_id(slot_id: String) -> String:
	if _safe_slot_id(slot_id) == "default":
		return save_path
	return _slot_save_path(slot_id)

func _slot_save_path(slot_id: String) -> String:
	var safe_slot_id := _safe_slot_id(slot_id)
	if safe_slot_id == "default":
		safe_slot_id = "default"
	var extension := save_path.get_extension()
	var base_path := save_path
	if not extension.is_empty():
		base_path = save_path.substr(0, save_path.length() - extension.length() - 1)
		return "%s_slot_%s.%s" % [base_path, safe_slot_id, extension]
	return "%s_slot_%s" % [base_path, safe_slot_id]

func _safe_slot_id(slot_id: String) -> String:
	var safe_slot_id := ""
	for index: int in slot_id.strip_edges().length():
		var character := slot_id.strip_edges().substr(index, 1)
		if character.to_lower() != character.to_upper() or character.is_valid_int() or character == "_":
			safe_slot_id += character
		else:
			safe_slot_id += "_"
	while safe_slot_id.contains("__"):
		safe_slot_id = safe_slot_id.replace("__", "_")
	safe_slot_id = safe_slot_id.strip_edges()
	while safe_slot_id.begins_with("_"):
		safe_slot_id = safe_slot_id.substr(1)
	while safe_slot_id.ends_with("_"):
		safe_slot_id = safe_slot_id.substr(0, safe_slot_id.length() - 1)
	if safe_slot_id.is_empty():
		safe_slot_id = "default"
	return safe_slot_id

func _temporary_save_path(path: String) -> String:
	return "%s.tmp" % path
