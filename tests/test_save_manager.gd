extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const SaveManager := preload("res://scripts/core/save_manager.gd")

func _init() -> void:
	var manager := SaveManager.new()
	manager.save_path = "user://test_spritevania_save.json"
	manager.delete_save()

	var state := GameState.new()
	state.selected_class = "warden"
	state.selected_sprite = "res://SpriteVania Assets/player/Knight/Knight_A.png"
	state.current_area = "swamp_outskirts"
	state.current_room = "RoomCheckpoint"
	state.checkpoint_id = "swamp_shrine_01"
	state.level = 3
	state.xp = 260
	state.learned_attack_skills = ["guard_counter"]
	state.traversal_unlocks = ["armored_dash"]
	state.opened_shortcuts = ["swamp_shortcut_01"]

	if not manager.save_game(state):
		push_error("Save failed")
		quit(1)
		return

	var loaded := manager.load_game()
	if loaded == null:
		push_error("Load returned null")
		quit(1)
		return
	if loaded.selected_class != "warden" or loaded.level != 3:
		push_error("Loaded state does not match saved state")
		quit(1)
		return
	if loaded.current_room != "RoomCheckpoint":
		push_error("Current room did not persist")
		quit(1)
		return
	if loaded.checkpoint_id != "swamp_shrine_01":
		push_error("Checkpoint id did not persist")
		quit(1)
		return
	if not loaded.learned_attack_skills.has("guard_counter"):
		push_error("Learned attack skill did not persist")
		quit(1)
		return
	if not loaded.traversal_unlocks.has("armored_dash"):
		push_error("Traversal unlock did not persist")
		quit(1)
		return
	if not loaded.opened_shortcuts.has("swamp_shortcut_01"):
		push_error("Opened shortcut did not persist")
		quit(1)
		return

	manager.delete_save()
	manager.free()
	print("PASS: save manager")
	quit(0)
