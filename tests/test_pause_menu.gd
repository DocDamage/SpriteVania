extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const PAUSE_MENU_SCENE := preload("res://scenes/ui/PauseMenu.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_pause_menu_emits_requested_signals()
	if _failed:
		return
	await _assert_pause_menu_exposes_familiar_upgrades()
	if _failed:
		return
	await _assert_pause_menu_exposes_map_status()
	if _failed:
		return
	await _assert_game_world_toggles_pause_and_saves()
	if _failed:
		return
	await _assert_game_world_upgrades_familiar_from_pause()
	if _failed:
		return
	print("PASS: pause menu")
	quit(0)

func _assert_pause_menu_emits_requested_signals() -> void:
	var menu := PAUSE_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	var emitted := {
		"resume": false,
		"settings": false,
		"save": false,
		"quit": false,
	}
	menu.resume_requested.connect(func() -> void: emitted.resume = true)
	menu.settings_requested.connect(func() -> void: emitted.settings = true)
	menu.save_requested.connect(func() -> void: emitted.save = true)
	menu.quit_to_title_requested.connect(func() -> void: emitted.quit = true)

	menu.get_node("%ResumeButton").pressed.emit()
	menu.get_node("%SettingsButton").pressed.emit()
	menu.get_node("%SaveButton").pressed.emit()
	menu.get_node("%QuitButton").pressed.emit()

	for signal_name: String in emitted.keys():
		if not bool(emitted[signal_name]):
			_fail("Pause menu did not emit %s signal." % signal_name)
			return

	menu.queue_free()
	await process_frame

func _assert_pause_menu_exposes_familiar_upgrades() -> void:
	var menu := PAUSE_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	menu.call("set_familiar_status", {
		"level": 2,
		"evolution_stage": "wisp",
		"ability_points": 1,
		"ability_levels": {
			"sting": 0,
			"focus": 1,
			"guard": 0,
		},
	})

	if menu.get_node("%FamiliarStatusLabel").text != "Familiar Lv 2 - Wisp":
		_fail("Pause menu should show familiar level and evolution.")
		return
	if menu.get_node("%FamiliarPointsLabel").text != "Ability Points: 1":
		_fail("Pause menu should show available familiar ability points.")
		return
	if menu.get_node("%FocusUpgradeButton").text.find("Lv 1") == -1:
		_fail("Pause menu should show current familiar ability levels.")
		return

	var requested: Array[String] = []
	menu.connect("familiar_upgrade_requested", func(ability_id: String) -> void:
		requested.append(ability_id)
	)
	menu.get_node("%StingUpgradeButton").pressed.emit()
	if requested != ["sting"]:
		_fail("Pressing a familiar upgrade button should request that ability upgrade.")
		return

	menu.queue_free()
	await process_frame

func _assert_pause_menu_exposes_map_status() -> void:
	var menu := PAUSE_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	menu.call("set_map_status", {
		"current_room_label": "Mire Gate",
		"discovered_room_labels": ["Mire Gate", "Sinking Steps"],
		"completed_area_labels": ["Swamp Outskirts"],
	})

	if menu.get_node("%MapCurrentRoomLabel").text != "Current: Mire Gate":
		_fail("Pause menu should show the current room label in its map section.")
		return
	if menu.get_node("%MapDiscoveredLabel").text.find("Sinking Steps") == -1:
		_fail("Pause menu should list discovered room labels.")
		return
	if menu.get_node("%MapCompletionLabel").text.find("Swamp Outskirts") == -1:
		_fail("Pause menu should list completed areas.")
		return

	menu.queue_free()
	await process_frame

func _assert_game_world_toggles_pause_and_saves() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_pause_menu_save.json"
	save_manager.delete_save()

	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	await process_frame

	var state := GameState.new()
	state.selected_class = "warden"
	state.selected_sprite = "res://SpriteVania Assets/player/Knight/Knight_A.png"
	state.current_area = "swamp_outskirts"
	state.current_room = "RoomCheckpoint"
	state.current_health = 21
	world.set("state", state)

	var pause_event := InputEventAction.new()
	pause_event.action = "pause"
	pause_event.pressed = true
	world._unhandled_input(pause_event)
	await process_frame

	if not bool(world.call("is_pause_menu_open")):
		_fail("GameWorld should open the pause menu from the pause action.")
		return
	if not paused:
		_fail("Opening the pause menu should pause the tree.")
		return
	var menu := world.get("pause_menu") as Control
	if menu == null or menu.get_node("%MapCurrentRoomLabel").text.find("Shrine Hollow") == -1:
		_fail("Opening pause should populate map status from the current world state.")
		return

	world.call("save_from_pause")
	if not save_manager.has_save():
		_fail("Saving from pause should create a save.")
		return
	var loaded: GameState = save_manager.load_game()
	if loaded == null or loaded.current_room != "RoomCheckpoint" or loaded.current_health != 21:
		_fail("Saving from pause should persist the current GameState.")
		return

	world._unhandled_input(pause_event)
	await process_frame
	if bool(world.call("is_pause_menu_open")):
		_fail("GameWorld should close the pause menu from the pause action.")
		return
	if paused:
		_fail("Closing the pause menu should unpause the tree.")
		return

	world.queue_free()
	save_manager.delete_save()
	await process_frame

func _assert_game_world_upgrades_familiar_from_pause() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_pause_menu_familiar_save.json"
	save_manager.delete_save()

	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame

	var player := world.get("player") as Player
	var familiar := player.get_node("Familiar") as Node
	familiar.call("gain_xp", 120)
	world.call("open_pause_menu")
	await process_frame

	var menu := world.get("pause_menu") as Control
	if menu == null:
		_fail("GameWorld should expose the active pause menu.")
		return
	menu.get_node("%StingUpgradeButton").pressed.emit()
	await process_frame

	var ability_levels := familiar.get("ability_levels") as Dictionary
	if int(ability_levels.get("sting", 0)) != 1:
		_fail("Pause menu familiar upgrade should spend a point on the active familiar.")
		return
	if int(familiar.get("ability_points")) != 0:
		_fail("Pause menu familiar upgrade should consume one familiar ability point.")
		return

	var state := world.get("state") as GameState
	var saved_levels := state.familiar_state.get("ability_levels", {}) as Dictionary
	if int(saved_levels.get("sting", 0)) != 1:
		_fail("Pause menu familiar upgrade should persist into GameState.")
		return

	world.call("close_pause_menu")
	world.queue_free()
	save_manager.delete_save()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
