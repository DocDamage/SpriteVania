extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const SaveManager := preload("res://scripts/core/save_manager.gd")
const SETTINGS_MENU_SCENE := preload("res://scenes/ui/SettingsMenu.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_settings_menu_persists_global_settings_without_game_save()
	if _failed:
		return
	await _assert_settings_menu_clamps_invalid_global_settings()
	if _failed:
		return
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
	await _assert_settings_menu_exposes_full_tab_set()
	if _failed:
		return
	await _assert_expanded_settings_persist_updates()
	if _failed:
		return
	await _assert_settings_menu_can_reset_all_bindings()
	if _failed:
		return
	await _assert_settings_menu_clamps_invalid_persisted_values()
	if _failed:
		return
	await _assert_settings_menu_resets_defaults_and_syncs_controls()
	if _failed:
		return
	print("PASS: settings menu")
	quit(0)

func _assert_settings_menu_persists_global_settings_without_game_save() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_global_save.json"
	save_manager.delete_save()
	var global_settings_path := "user://test_black_keep_settings.json"
	_delete_user_file(global_settings_path)

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	if not menu.has_method("set_global_settings_path"):
		_fail("Settings menu should expose set_global_settings_path().")
		return
	menu.call("set_global_settings_path", global_settings_path)
	menu.call("set_save_manager", save_manager)
	menu.call("set_master_volume", 0.42)
	menu.call("set_reduced_motion_enabled", true)

	if save_manager.has_save():
		_fail("Global settings should persist without creating a game save.")
		return
	if not FileAccess.file_exists(global_settings_path):
		_fail("Global settings should write a settings file.")
		return

	var second_menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(second_menu)
	await process_frame
	second_menu.call("set_global_settings_path", global_settings_path)
	second_menu.call("set_save_manager", save_manager)
	var settings := second_menu.call("get_settings_state") as Dictionary
	if not is_equal_approx(float(settings.master_volume), 0.42):
		_fail("Global settings should reload persisted master volume.")
		return
	if not bool(settings.reduced_motion):
		_fail("Global settings should reload persisted reduced motion.")
		return

	menu.queue_free()
	second_menu.queue_free()
	_delete_user_file(global_settings_path)
	save_manager.free()
	await process_frame

func _assert_settings_menu_clamps_invalid_global_settings() -> void:
	var global_settings_path := "user://test_black_keep_invalid_settings.json"
	_delete_user_file(global_settings_path)
	var file := FileAccess.open(global_settings_path, FileAccess.WRITE)
	if file == null:
		_fail("Test could not create invalid global settings file.")
		return
	file.store_string(JSON.stringify({
		"master_volume": 9.0,
		"music_volume": -4.0,
		"sfx_volume": 2.0,
		"screen_shake": -1.0,
		"text_speed": 8.0,
		"colorblind_mode": "NotARealMode",
		"fullscreen": "false",
		"reduced_motion": "true",
		"high_contrast": "0",
		"large_text": true,
	}))
	file = null

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame
	menu.call("set_global_settings_path", global_settings_path)
	var save_manager := SaveManager.new()
	menu.call("set_save_manager", save_manager)

	var settings := menu.call("get_settings_state") as Dictionary
	if not is_equal_approx(float(settings.master_volume), 1.0):
		_fail("Global master volume should clamp high.")
		return
	if not is_equal_approx(float(settings.music_volume), 0.0):
		_fail("Global music volume should clamp low.")
		return
	if not is_equal_approx(float(settings.sfx_volume), 1.0):
		_fail("Global SFX volume should clamp high.")
		return
	if not is_equal_approx(float(settings.screen_shake), 0.0):
		_fail("Global screen shake should clamp low.")
		return
	if not is_equal_approx(float(settings.text_speed), 1.0):
		_fail("Global text speed should clamp high.")
		return
	if str(settings.colorblind_mode) != "Off":
		_fail("Global colorblind mode should fall back to Off.")
		return
	if bool(settings.fullscreen):
		_fail("String false values in persisted settings should normalize to false.")
		return
	if not bool(settings.reduced_motion):
		_fail("String true values in persisted settings should normalize to true.")
		return
	if bool(settings.high_contrast):
		_fail("String zero values in persisted settings should normalize to false.")
		return
	if not bool(settings.large_text):
		_fail("Valid global booleans should still load.")
		return

	menu.queue_free()
	_delete_user_file(global_settings_path)
	save_manager.free()
	await process_frame

func _assert_settings_menu_persists_updates() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_save.json"
	save_manager.delete_save()
	var global_settings_path := "user://test_settings_menu_legacy_global.json"
	_delete_user_file(global_settings_path)

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
	menu.call("set_global_settings_path", global_settings_path)
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
	_delete_user_file(global_settings_path)
	save_manager.free()
	await process_frame
	await process_frame
	await physics_frame

func _assert_settings_menu_does_not_create_blank_save() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_empty_save.json"
	save_manager.delete_save()
	var global_settings_path := "user://test_settings_menu_empty_global.json"
	_delete_user_file(global_settings_path)

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame
	menu.call("set_global_settings_path", global_settings_path)
	menu.call("set_save_manager", save_manager)
	menu.call("set_master_volume", 0.5)

	if save_manager.has_save():
		_fail("Changing settings without an existing save should not create a blank continue save.")
		return

	menu.queue_free()
	_delete_user_file(global_settings_path)
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
		"MoveLeftBindingLabel",
		"MoveRightBindingLabel",
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
	menu.call("select_settings_tab", "DoesNotExist")
	if str(menu.call("get_selected_settings_tab")) != "General":
		_fail("Unknown settings tabs should fall back to General.")
		return

	if menu.get_node_or_null("%ReducedMotionButton") == null:
		_fail("Accessibility tab should expose reduced motion control.")
		return
	if menu.get_node_or_null("%HighContrastButton") == null:
		_fail("Accessibility tab should expose high contrast control.")
		return

	menu.queue_free()
	await process_frame

func _assert_settings_menu_exposes_full_tab_set() -> void:
	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	var tabs := menu.get_node_or_null("%SettingsTabs") as TabContainer
	if tabs == null:
		_fail("Settings menu should expose SettingsTabs.")
		return
	var tab_titles: Array[String] = []
	for index: int in tabs.get_tab_count():
		tab_titles.append(tabs.get_tab_title(index))
	for expected: String in ["General", "Audio", "Video", "Gameplay", "Controls", "Accessibility"]:
		if not tab_titles.has(expected):
			_fail("Settings menu should include %s tab." % expected)
			return

	for node_name: String in [
		"MusicVolumeSlider",
		"SfxVolumeSlider",
		"VsyncButton",
		"ScreenShakeSlider",
		"TextSpeedSlider",
		"ResetAllBindingsButton",
		"LargeTextButton",
		"ColorblindModeButton",
		"ResetDefaultsButton",
	]:
		if menu.get_node_or_null("%" + node_name) == null:
			_fail("Settings menu is missing control: " + node_name)
			return

	menu.queue_free()
	await process_frame

func _assert_expanded_settings_persist_updates() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_expanded_save.json"
	save_manager.delete_save()
	var global_settings_path := "user://test_settings_menu_expanded_global.json"
	_delete_user_file(global_settings_path)

	var seeded_state := GameState.new()
	seeded_state.selected_class = "warden"
	seeded_state.current_room = "RoomCheckpoint"
	save_manager.save_game(seeded_state)

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame
	menu.call("set_global_settings_path", global_settings_path)
	menu.call("set_save_manager", save_manager)

	menu.call("set_music_volume", 0.25)
	menu.call("set_sfx_volume", 0.65)
	menu.call("set_vsync_enabled", true)
	menu.call("set_screen_shake", 0.2)
	menu.call("set_text_speed", 0.85)
	menu.call("set_large_text_enabled", true)
	menu.call("set_colorblind_mode", "Deuteranopia")

	var loaded := save_manager.load_game()
	if loaded == null:
		_fail("Expanded settings updates should keep a loadable save.")
		return
	var settings := loaded.settings
	if not is_equal_approx(float(settings.get("music_volume", -1.0)), 0.25):
		_fail("Music volume should persist.")
		return
	if not is_equal_approx(float(settings.get("sfx_volume", -1.0)), 0.65):
		_fail("SFX volume should persist.")
		return
	if bool(settings.get("vsync", false)) != true:
		_fail("VSync setting should persist.")
		return
	if not is_equal_approx(float(settings.get("screen_shake", -1.0)), 0.2):
		_fail("Screen shake setting should persist.")
		return
	if not is_equal_approx(float(settings.get("text_speed", -1.0)), 0.85):
		_fail("Text speed setting should persist.")
		return
	if bool(settings.get("large_text", false)) != true:
		_fail("Large text setting should persist.")
		return
	if str(settings.get("colorblind_mode", "")) != "Deuteranopia":
		_fail("Colorblind mode should persist.")
		return

	menu.queue_free()
	save_manager.delete_save()
	_delete_user_file(global_settings_path)
	save_manager.free()
	await process_frame

func _assert_settings_menu_can_reset_all_bindings() -> void:
	var original_jump_events := InputMap.action_get_events("jump")
	var original_dash_events := InputMap.action_get_events("dash")
	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame

	menu.call("rebind_action_to_key", "jump", KEY_L)
	menu.call("rebind_action_to_key", "dash", KEY_Q)
	if not bool(menu.call("reset_all_bindings")):
		_fail("Settings menu should reset all bindings.")
		return
	if InputMap.action_get_events("jump").size() != original_jump_events.size():
		_fail("Reset all should restore jump bindings.")
		return
	if InputMap.action_get_events("dash").size() != original_dash_events.size():
		_fail("Reset all should restore dash bindings.")
		return

	InputMap.action_erase_events("jump")
	for event: InputEvent in original_jump_events:
		InputMap.action_add_event("jump", event)
	InputMap.action_erase_events("dash")
	for event: InputEvent in original_dash_events:
		InputMap.action_add_event("dash", event)
	menu.queue_free()
	await process_frame

func _assert_settings_menu_clamps_invalid_persisted_values() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_invalid_save.json"
	save_manager.delete_save()
	var global_settings_path := "user://test_settings_menu_invalid_legacy_global.json"
	_delete_user_file(global_settings_path)

	var seeded_state := GameState.new()
	seeded_state.settings = {
		"master_volume": 4.0,
		"music_volume": -2.0,
		"sfx_volume": 2.5,
		"screen_shake": -1.0,
		"text_speed": 4.0,
		"colorblind_mode": "Impossible",
		"high_contrast": true,
	}
	save_manager.save_game(seeded_state)

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame
	menu.call("set_global_settings_path", global_settings_path)
	menu.call("set_save_manager", save_manager)

	var settings := menu.call("get_settings_state") as Dictionary
	if not is_equal_approx(float(settings.master_volume), 1.0):
		_fail("Invalid persisted master volume should clamp high.")
		return
	if not is_equal_approx(float(settings.music_volume), 0.0):
		_fail("Invalid persisted music volume should clamp low.")
		return
	if not is_equal_approx(float(settings.sfx_volume), 1.0):
		_fail("Invalid persisted SFX volume should clamp high.")
		return
	if not is_equal_approx(float(settings.screen_shake), 0.0):
		_fail("Invalid persisted screen shake should clamp low.")
		return
	if not is_equal_approx(float(settings.text_speed), 1.0):
		_fail("Invalid persisted text speed should clamp high.")
		return
	if str(settings.colorblind_mode) != "Off":
		_fail("Invalid persisted colorblind mode should fall back to Off.")
		return
	if not bool(settings.high_contrast):
		_fail("Valid persisted booleans should still load.")
		return

	menu.queue_free()
	save_manager.delete_save()
	_delete_user_file(global_settings_path)
	save_manager.free()
	await process_frame

func _assert_settings_menu_resets_defaults_and_syncs_controls() -> void:
	var save_manager := SaveManager.new()
	save_manager.save_path = "user://test_settings_menu_reset_defaults_save.json"
	save_manager.delete_save()
	var global_settings_path := "user://test_settings_menu_reset_defaults_global.json"
	_delete_user_file(global_settings_path)
	var seeded_state := GameState.new()
	save_manager.save_game(seeded_state)

	var menu := SETTINGS_MENU_SCENE.instantiate() as Control
	root.add_child(menu)
	await process_frame
	menu.call("set_global_settings_path", global_settings_path)
	menu.call("set_save_manager", save_manager)

	menu.call("set_music_volume", 0.2)
	menu.call("set_sfx_volume", 0.3)
	menu.call("set_reduced_motion_enabled", true)
	menu.call("set_high_contrast_enabled", true)
	menu.call("set_large_text_enabled", true)
	menu.call("set_colorblind_mode", "Tritanopia")
	menu.call("reset_settings_to_defaults")

	var settings := menu.call("get_settings_state") as Dictionary
	if not is_equal_approx(float(settings.music_volume), 1.0) or not is_equal_approx(float(settings.sfx_volume), 1.0):
		_fail("Reset defaults should restore audio sliders.")
		return
	if bool(settings.reduced_motion) or bool(settings.high_contrast) or bool(settings.large_text):
		_fail("Reset defaults should clear accessibility toggles.")
		return
	if str(settings.colorblind_mode) != "Off":
		_fail("Reset defaults should restore colorblind mode.")
		return
	var music_slider := menu.get_node("%MusicVolumeSlider") as HSlider
	if not is_equal_approx(music_slider.value, 1.0):
		_fail("Reset defaults should sync music slider.")
		return
	var colorblind_button := menu.get_node("%ColorblindModeButton") as OptionButton
	if colorblind_button.get_item_text(colorblind_button.selected) != "Off":
		_fail("Reset defaults should sync colorblind option.")
		return

	menu.queue_free()
	save_manager.delete_save()
	_delete_user_file(global_settings_path)
	save_manager.free()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)

func _delete_user_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
