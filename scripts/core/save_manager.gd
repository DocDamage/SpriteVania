extends Node

const GameStateScript := preload("res://scripts/core/game_state.gd")

@export var save_path: String = "user://spritevania_save.json"

func has_save() -> bool:
	return FileAccess.file_exists(save_path)

func save_game(state: GameStateScript) -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing: %s" % save_path)
		return false

	file.store_string(JSON.stringify(state.to_dictionary()))
	return true

func load_game() -> GameStateScript:
	if not has_save():
		return null

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_error("Could not open save file for reading: %s" % save_path)
		return null

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("Save file is corrupt: %s" % save_path)
		return null

	return GameStateScript.from_dictionary(parsed)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(save_path)
