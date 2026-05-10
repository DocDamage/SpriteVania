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
	state.checkpoint_room = "RoomCheckpoint"
	state.level = 3
	state.xp = 260
	state.learned_attack_skills = ["guard_counter"]
	state.traversal_unlocks = ["armored_dash"]
	state.defeated_bosses = ["swamp_miniboss"]
	state.opened_shortcuts = ["swamp_shortcut_01"]
	state.completed_areas = ["swamp_outskirts_complete"]
	state.settings = {
		"master_volume": 0.4,
		"fullscreen": false,
	}

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
	if loaded.checkpoint_room != "RoomCheckpoint":
		push_error("Checkpoint room did not persist")
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
	if not loaded.defeated_bosses.has("swamp_miniboss"):
		push_error("Defeated boss did not persist")
		quit(1)
		return
	if not loaded.opened_shortcuts.has("swamp_shortcut_01"):
		push_error("Opened shortcut did not persist")
		quit(1)
		return
	if not loaded.completed_areas.has("swamp_outskirts_complete"):
		push_error("Completed area did not persist")
		quit(1)
		return
	if loaded.settings.get("master_volume", -1.0) != 0.4:
		push_error("Master volume setting did not persist")
		quit(1)
		return
	if loaded.settings.get("fullscreen", true) != false:
		push_error("Fullscreen setting did not persist")
		quit(1)
		return

	var slot_state := GameState.new()
	slot_state.selected_class = "gunslinger"
	slot_state.current_room = "RoomEnemy"
	slot_state.level = 5
	if not manager.save_game_to_slot("slot_a", slot_state):
		push_error("Slot save failed")
		quit(1)
		return
	if not manager.has_save_in_slot("slot_a"):
		push_error("Saved slot should be reported as present")
		quit(1)
		return
	var loaded_slot: GameState = manager.load_game_from_slot("slot_a")
	if loaded_slot == null or loaded_slot.selected_class != "gunslinger" or loaded_slot.level != 5:
		push_error("Slot load did not return the requested slot state")
		quit(1)
		return
	var default_loaded := manager.load_game()
	if default_loaded == null or default_loaded.selected_class != "warden" or default_loaded.level != 3:
		push_error("Slot save should not overwrite the default save")
		quit(1)
		return

	manager.delete_save()
	manager.free()
	print("PASS: save manager")
	quit(0)
