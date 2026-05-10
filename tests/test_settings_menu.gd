extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const SaveManager := preload("res://scripts/core/save_manager.gd")
const SETTINGS_MENU_SCENE := preload("res://scenes/ui/SettingsMenu.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_settings_menu_persists_updates()
	await _assert_settings_menu_does_not_create_blank_save()
	print("PASS: settings menu")
	quit(0)

func _assert_settings_menu_persists_updates() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_save.json"
	save_manager.delete_save()

	var seeded_state := GameState.new()
	seeded_state.selected_class = "warden"
	seeded_state.current_room = "RoomCheckpoint"
	save_manager.save_game(seeded_state)

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	if not menu.has_method("set_save_manager"):
		_fail("Settings menu should expose set_save_manager().")
		return
	menu.call("set_save_manager", save_manager)

	var changes: Array[Dictionary] = []
	menu.connect("settings_changed", func(settings: Dictionary) -> void:
		changes.append(settings.duplicate())
	)

	menu.call("set_master_volume", 0.35)
	menu.call("set_fullscreen_enabled", false)

	var loaded := save_manager.load_game()
	if loaded == null:
		_fail("Settings updates should keep a loadable save.")
		return
	if loaded.selected_class != "warden" or loaded.current_room != "RoomCheckpoint":
		_fail("Settings persistence should preserve existing save fields.")
		return
	if not is_equal_approx(float(loaded.settings.get("master_volume", -1.0)), 0.35):
		_fail("Master volume should persist in GameState.settings.")
		return
	if bool(loaded.settings.get("fullscreen", true)) != false:
		_fail("Fullscreen state should persist in GameState.settings.")
		return
	if changes.size() != 2:
		_fail("Settings menu should emit settings_changed for each update.")
		return

	var current_settings := menu.call("get_settings_state") as Dictionary
	if not is_equal_approx(float(current_settings.get("master_volume", -1.0)), 0.35):
		_fail("Settings menu should expose current master volume.")
		return
	if bool(current_settings.get("fullscreen", true)) != false:
		_fail("Settings menu should expose current fullscreen state.")
		return

	menu.queue_free()
	save_manager.delete_save()
	save_manager.free()
	await process_frame
	await process_frame
	await physics_frame

func _assert_settings_menu_does_not_create_blank_save() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_empty_save.json"
	save_manager.delete_save()

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame
	menu.call("set_save_manager", save_manager)
	menu.call("set_master_volume", 0.5)

	if save_manager.has_save():
		_fail("Changing settings without an existing save should not create a blank continue save.")
		return

	menu.queue_free()
	save_manager.free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
