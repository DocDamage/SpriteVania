extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const SaveManager := preload("res://scripts/core/save_manager.gd")

func _init() -> void:
	var manager := SaveManager.new()
	manager.save_path = "user://test_spritevania_save.json"
	manager.delete_save()
	for stale_slot_id: String in ["slot_a", "slot_b", "slot_c"]:
		var stale_slot_path := manager.call("_slot_save_path", stale_slot_id) as String
		if FileAccess.file_exists(stale_slot_path):
			DirAccess.remove_absolute(stale_slot_path)

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
	state.discovered_rooms = ["RoomStart", "RoomCheckpoint"]
	state.familiar_state = {
		"level": 3,
		"xp": 180,
		"evolution_stage": "wisp",
		"ability_points": 1,
		"ability_levels": {
			"sting": 2,
		},
	}
	state.party_roster = {
		"ronin": {
			"character_id": "ronin",
			"character_name": "Akio",
			"class_id": "warden",
		},
		"black_witch": {
			"character_id": "black_witch",
			"character_name": "Mira",
			"class_id": "hexbinder",
		},
	}
	state.active_party_ids = ["ronin", "black_witch"]
	state.active_party_index = 1
	state.momentum = 75
	state.world_break_state = "post_break"
	state.world_break_triggered = true
	state.zone_states = {
		"sakuramori_court": {
			"variant": "damaged",
			"safe_hub": true,
		},
	}
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
	var saved_dictionary := state.to_dictionary()
	if not saved_dictionary.has("version"):
		push_error("Serialized save data should include a version field")
		quit(1)
		return
	var older_save := saved_dictionary.duplicate(true)
	older_save.erase("version")
	var loaded_older: GameState = GameState.from_dictionary(older_save)
	if loaded_older == null or loaded_older.selected_class != "warden" or loaded_older.level != 3:
		push_error("Older save data without version should still load")
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
	if not loaded.discovered_rooms.has("RoomStart") or not loaded.discovered_rooms.has("RoomCheckpoint"):
		push_error("Discovered rooms did not persist")
		quit(1)
		return
	if int(loaded.familiar_state.get("level", 0)) != 3:
		push_error("Familiar level did not persist")
		quit(1)
		return
	if str(loaded.familiar_state.get("evolution_stage", "")) != "wisp":
		push_error("Familiar evolution did not persist")
		quit(1)
		return
	if int(loaded.familiar_state.get("ability_points", -1)) != 1:
		push_error("Familiar ability points did not persist")
		quit(1)
		return
	var ability_levels := loaded.familiar_state.get("ability_levels", {}) as Dictionary
	if int(ability_levels.get("sting", 0)) != 2:
		push_error("Familiar ability levels did not persist")
		quit(1)
		return
	if loaded.active_party_ids != ["ronin", "black_witch"]:
		push_error("Active party ids did not persist")
		quit(1)
		return
	if int(loaded.active_party_index) != 1 or int(loaded.momentum) != 75:
		push_error("Active party index or Momentum did not persist")
		quit(1)
		return
	if loaded.world_break_state != "post_break" or not loaded.world_break_triggered:
		push_error("World Break state did not persist")
		quit(1)
		return
	var sakuramori_state := loaded.zone_states.get("sakuramori_court", {}) as Dictionary
	if str(sakuramori_state.get("variant", "")) != "damaged" or not bool(sakuramori_state.get("safe_hub", false)):
		push_error("Zone state variants did not persist")
		quit(1)
		return
	var loaded_witch := loaded.party_roster.get("black_witch", {}) as Dictionary
	if str(loaded_witch.get("character_name", "")) != "Mira" or str(loaded_witch.get("class_id", "")) != "hexbinder":
		push_error("Party roster state did not persist")
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
	for method_name: String in ["scan_save_slots", "read_save_slot_metadata", "resolve_latest_valid_save_slot", "load_latest_valid_game"]:
		if not manager.has_method(method_name):
			push_error("Save manager should expose %s()" % method_name)
			quit(1)
			return
	if not manager.has_method("_temporary_save_path"):
		push_error("Save manager should write through a temporary save path before replacing a slot.")
		quit(1)
		return
	var default_temp_path := manager.call("_temporary_save_path", manager.save_path) as String
	if FileAccess.file_exists(default_temp_path):
		push_error("Successful default save should not leave a temporary save file behind.")
		quit(1)
		return
	var hostile_slot_path := manager.call("_slot_save_path", " ../bad:slot\\name ") as String
	var hostile_slot_file := hostile_slot_path.get_file()
	if hostile_slot_file.contains("..") or hostile_slot_file.contains(":") or hostile_slot_file.contains("/") or hostile_slot_file.contains("\\"):
		push_error("Slot save paths should sanitize traversal and platform-unsafe characters.")
		quit(1)
		return
	var slot_metadata: Array = manager.call("scan_save_slots", ["default", "slot_a", "slot_b"])
	if slot_metadata.size() != 3:
		push_error("Save manager should scan requested save slots")
		quit(1)
		return
	var default_metadata := slot_metadata[0] as Dictionary
	var slot_a_metadata := slot_metadata[1] as Dictionary
	var slot_b_metadata := slot_metadata[2] as Dictionary
	if not bool(default_metadata.get("valid", false)) or str(default_metadata.get("slot_id", "")) != "default":
		push_error("Default save metadata should report a valid default slot")
		quit(1)
		return
	if str(default_metadata.get("selected_class", "")) != "warden" or int(default_metadata.get("level", 0)) != 3:
		push_error("Default save metadata should include summary fields")
		quit(1)
		return
	if str(default_metadata.get("world_break_state", "")) != "post_break":
		push_error("Save metadata should include the World Break state for title/menu variants")
		quit(1)
		return
	if not bool(slot_a_metadata.get("valid", false)) or str(slot_a_metadata.get("selected_class", "")) != "gunslinger":
		push_error("Slot metadata should include valid slot summary fields")
		quit(1)
		return
	if bool(slot_b_metadata.get("exists", true)) or bool(slot_b_metadata.get("valid", true)):
		push_error("Missing slot metadata should be empty and invalid")
		quit(1)
		return

	var corrupt_path := manager.call("_slot_save_path", "slot_b") as String
	var corrupt_file := FileAccess.open(corrupt_path, FileAccess.WRITE)
	if corrupt_file == null:
		push_error("Could not write corrupt test save")
		quit(1)
		return
	corrupt_file.store_string("{not valid json")
	corrupt_file = null
	var corrupt_metadata := (manager.call("read_save_slot_metadata", "slot_b") as Dictionary)
	if not bool(corrupt_metadata.get("exists", false)) or bool(corrupt_metadata.get("valid", true)):
		push_error("Corrupt slot metadata should exist but be invalid")
		quit(1)
		return
	if str(corrupt_metadata.get("status", "")) != "Corrupt":
		push_error("Corrupt slot metadata should expose corrupt status")
		quit(1)
		return

	var latest_state := GameState.new()
	latest_state.selected_class = "hexbinder"
	latest_state.current_room = "RoomMiniBoss"
	latest_state.level = 7
	if not manager.save_game_to_slot("slot_c", latest_state):
		push_error("Latest slot save failed")
		quit(1)
		return
	var latest_slot := str(manager.call("resolve_latest_valid_save_slot", ["default", "slot_a", "slot_b", "slot_c"]))
	if latest_slot != "slot_c":
		push_error("Latest valid slot resolver should skip corrupt slots and pick the newest valid slot")
		quit(1)
		return
	var latest_loaded: GameState = manager.call("load_latest_valid_game", ["default", "slot_a", "slot_b", "slot_c"])
	if latest_loaded == null or latest_loaded.selected_class != "hexbinder":
		push_error("Latest valid save load should return the newest valid state")
		quit(1)
		return
	latest_state.world_break_state = "breaking"
	latest_state.world_break_triggered = true
	if not manager.save_game_to_slot("slot_c", latest_state):
		push_error("Latest World Break slot save failed")
		quit(1)
		return
	if not manager.has_method("resolve_latest_title_variant"):
		push_error("Save manager should expose resolve_latest_title_variant() for World Break title variants.")
		quit(1)
		return
	var title_variant := manager.call("resolve_latest_title_variant", ["default", "slot_a", "slot_b", "slot_c"]) as Dictionary
	if str(title_variant.get("world_break_state", "")) != "breaking" or str(title_variant.get("title_variant", "")) != "world_break":
		push_error("Title variant resolver should use the latest valid World Break save state.")
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
