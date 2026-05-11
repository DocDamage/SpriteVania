extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const MAIN_SCENE := preload("res://scenes/Main.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_load_game_opens_slot_screen_and_loads_slots()
	if _failed:
		return
	await _assert_accessibility_routes_to_settings_tab()
	if _failed:
		return
	await _assert_extras_and_credits_are_real_screens()
	if _failed:
		return
	await _assert_title_applies_persisted_reduced_motion()
	if _failed:
		return
	await _assert_main_applies_persisted_runtime_settings()
	if _failed:
		return
	print("PASS: main title menu")
	quit(0)

func _assert_load_game_opens_slot_screen_and_loads_slots() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_main_title_menu_save.json"
	save_manager.delete_save()

	var state := GameState.new()
	state.selected_class = "warden"
	state.current_room = "RoomCheckpoint"
	var slot_state := GameState.new()
	slot_state.selected_class = "gunslinger"
	slot_state.current_room = "RoomEnemy"
	if not save_manager.save_game(state) or not save_manager.save_game_to_slot("slot_a", slot_state):
		_fail("Main title menu test could not create saves.")
		return

	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame

	var title := main.get("current_screen") as Control
	title.get_node("%LoadGameButton").pressed.emit()
	await process_frame

	var load_screen := main.get("current_screen") as Control
	if load_screen == null or load_screen.name != "LoadGameScreen":
		_fail("Load Game should open a save-slot screen.")
		return
	var slot_a_button := load_screen.get_node_or_null("Panel/MarginContainer/VBoxContainer/SlotAButton") as Button
	if slot_a_button == null or slot_a_button.disabled:
		_fail("Load screen should expose enabled buttons for occupied save slots.")
		return
	slot_a_button.pressed.emit()
	await process_frame

	var world := main.get("current_screen") as GameWorld
	if world == null:
		_fail("Choosing a load slot should enter GameWorld.")
		return
	if world.state == null or world.state.selected_class != "gunslinger" or world.state.current_room != "RoomEnemy":
		_fail("Choosing a load slot should use the selected saved GameState.")
		return

	main.queue_free()
	save_manager.delete_save()
	await process_frame

func _assert_accessibility_routes_to_settings_tab() -> void:
	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame

	var title := main.get("current_screen") as Control
	title.get_node("%AccessibilityButton").pressed.emit()
	await process_frame

	var settings := main.get("current_screen") as SettingsMenu
	if settings == null:
		_fail("Accessibility should open SettingsMenu.")
		return
	if str(settings.call("get_selected_settings_tab")) != "Accessibility":
		_fail("Accessibility should select the Accessibility settings tab.")
		return

	settings.get_node("%BackButton").pressed.emit()
	await process_frame
	if not main.get("current_screen") is TitleScreen:
		_fail("Settings BackButton should return to title after Accessibility routing.")
		return

	main.queue_free()
	await process_frame

func _assert_extras_and_credits_are_real_screens() -> void:
	var entries := {
		"ExtrasButton": "ExtrasScreen",
		"CreditsButton": "CreditsScreen",
	}
	for button_name: String in entries.keys():
		var main := MAIN_SCENE.instantiate() as Main
		root.add_child(main)
		await process_frame

		var title := main.get("current_screen") as Control
		title.get_node("%" + button_name).pressed.emit()
		await process_frame

		var placeholder := main.get("current_screen") as Control
		if placeholder == null or placeholder.name != entries[button_name]:
			_fail("%s should open %s." % [button_name, entries[button_name]])
			return

		var body_label := placeholder.get_node_or_null("Panel/MarginContainer/VBoxContainer/BodyLabel") as Label
		if body_label == null or body_label.text == "Coming soon.":
			_fail("%s should include real screen copy, not placeholder copy." % entries[button_name])
			return
		var back_button := placeholder.get_node_or_null("Panel/MarginContainer/VBoxContainer/BackButton") as Button
		if back_button == null:
			_fail("%s should include a BackButton." % entries[button_name])
			return
		back_button.pressed.emit()
		await process_frame

		var returned_title := main.get("current_screen") as TitleScreen
		if returned_title == null:
			_fail("%s BackButton should return to the title screen." % entries[button_name])
			return

		main.queue_free()
		await process_frame

func _assert_title_applies_persisted_reduced_motion() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_main_title_reduced_motion_save.json"
	save_manager.delete_save()

	var state := GameState.new()
	state.settings = {
		"reduced_motion": true,
	}
	save_manager.save_game(state)

	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame

	var title := main.get("current_screen") as TitleScreen
	if title == null:
		_fail("Main should start on the title screen.")
		return
	if bool(title.get("parallax_enabled")):
		_fail("Title screen should disable parallax when reduced motion is persisted.")
		return

	main.queue_free()
	save_manager.delete_save()
	await process_frame

func _assert_main_applies_persisted_runtime_settings() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_main_runtime_settings_save.json"
	save_manager.delete_save()

	var master_bus_index := AudioServer.get_bus_index("Master")
	var original_volume_db := AudioServer.get_bus_volume_db(master_bus_index)
	AudioServer.set_bus_volume_db(master_bus_index, 0.0)

	var state := GameState.new()
	state.settings = {
		"master_volume": 0.25,
	}
	save_manager.save_game(state)

	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame

	var expected_db := linear_to_db(0.25)
	var actual_db := AudioServer.get_bus_volume_db(master_bus_index)
	if not is_equal_approx(actual_db, expected_db):
		_fail("Main should apply persisted master volume on startup.")
		return

	main.queue_free()
	save_manager.delete_save()
	AudioServer.set_bus_volume_db(master_bus_index, original_volume_db)
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
