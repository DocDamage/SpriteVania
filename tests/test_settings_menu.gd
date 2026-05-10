extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const SaveManager := preload("res://scripts/core/save_manager.gd")
const SETTINGS_MENU_SCENE := preload("res://scenes/ui/SettingsMenu.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_settings_menu_persists_updates()
	if _failed:
		return
	await _assert_settings_menu_does_not_create_blank_save()
	if _failed:
		return
	await _assert_settings_menu_can_rebind_one_action_and_restore_default()
	if _failed:
		return
	await _assert_settings_menu_lists_core_controller_bindings()
	if _failed:
		return
	await _assert_settings_menu_exposes_accessibility_tab()
	if _failed:
		return
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

func _assert_settings_menu_can_rebind_one_action_and_restore_default() -> void:
	var original_events := InputMap.action_get_events("jump")
	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	var default_label := str(menu.call("get_action_binding_label", "jump"))
	if default_label.is_empty():
		_fail("Settings menu should describe the current jump binding.")
		return

	if not bool(menu.call("rebind_action_to_key", "jump", KEY_L)):
		_fail("Settings menu should rebind jump to a requested key.")
		return
	var rebound_label := str(menu.call("get_action_binding_label", "jump"))
	if not rebound_label.contains("L"):
		_fail("Settings menu should describe the rebound jump key.")
		return

	menu.call("reset_action_binding", "jump")
	var restored_events := InputMap.action_get_events("jump")
	if restored_events.size() != original_events.size():
		_fail("Resetting a binding should restore the default event count.")
		return

	InputMap.action_erase_events("jump")
	for event: InputEvent in original_events:
		InputMap.action_add_event("jump", event)
	menu.queue_free()
	await process_frame

func _assert_settings_menu_lists_core_controller_bindings() -> void:
	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	for label_name: String in [
		"JumpBindingLabel",
		"DashBindingLabel",
		"AttackBindingLabel",
		"SpecialAttackBindingLabel",
		"ClassActionBindingLabel",
		"InteractBindingLabel",
		"PauseBindingLabel",
	]:
		var label := menu.get_node_or_null("%" + label_name) as Label
		if label == null:
			_fail("Settings menu is missing binding label: " + label_name)
			return
		if label.text.find("Joypad") == -1:
			_fail("Settings binding label should include controller input: " + label_name)
			return

	var original_events := InputMap.action_get_events("dash")
	if not bool(menu.call("rebind_action_to_key", "dash", KEY_Q)):
		_fail("Settings menu should rebind dash now that dash is a core action.")
		return
	menu.call("reset_action_binding", "dash")
	var restored_events := InputMap.action_get_events("dash")
	if restored_events.size() != original_events.size():
		_fail("Resetting dash should restore keyboard and controller defaults.")
		return

	InputMap.action_erase_events("dash")
	for event: InputEvent in original_events:
		InputMap.action_add_event("dash", event)
	menu.queue_free()
	await process_frame

func _assert_settings_menu_exposes_accessibility_tab() -> void:
	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	if not menu.has_method("select_settings_tab") or not menu.has_method("get_selected_settings_tab"):
		_fail("Settings menu should expose tab selection helpers.")
		return
	menu.call("select_settings_tab", "Accessibility")
	if str(menu.call("get_selected_settings_tab")) != "Accessibility":
		_fail("Settings menu should select the Accessibility tab by name.")
		return

	if menu.get_node_or_null("%ReducedMotionButton") == null:
		_fail("Accessibility tab should expose reduced motion control.")
		return
	if menu.get_node_or_null("%HighContrastButton") == null:
		_fail("Accessibility tab should expose high contrast control.")
		return

	menu.queue_free()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
