extends Node

const GameStateScript := preload("res://scripts/core/game_state.gd")

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
	return _load_state_from_path(_slot_save_path(slot_id))

func has_save_in_slot(slot_id: String) -> bool:
	return FileAccess.file_exists(_slot_save_path(slot_id))

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(save_path)

func _save_state_to_path(path: String, state: GameStateScript) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: %s" % path)
		return false

	file.store_string(JSON.stringify(state.to_dictionary()))
	return true

func _load_state_from_path(path: String) -> GameStateScript:
	if not FileAccess.file_exists(path):
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading: %s" % path)
		return null

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("Save file is corrupt: %s" % path)
		return null

	return GameStateScript.from_dictionary(parsed)

func _slot_save_path(slot_id: String) -> String:
	var safe_slot_id := slot_id.strip_edges().replace("/", "_").replace("\\", "_")
	if safe_slot_id.is_empty():
		safe_slot_id = "default"

	var extension := save_path.get_extension()
	var base_path := save_path
	if not extension.is_empty():
		base_path = save_path.substr(0, save_path.length() - extension.length() - 1)
		return "%s_slot_%s.%s" % [base_path, safe_slot_id, extension]
	return "%s_slot_%s" % [base_path, safe_slot_id]
