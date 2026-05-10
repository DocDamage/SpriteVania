extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const MAIN_SCENE := preload("res://scenes/Main.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_load_game_uses_continue_flow()
	if _failed:
		return
	await _assert_placeholder_menu_entries_return_to_title()
	if _failed:
		return
	print("PASS: main title menu")
	quit(0)

func _assert_load_game_uses_continue_flow() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_main_title_menu_save.json"
	save_manager.delete_save()

	var state := GameState.new()
	state.selected_class = "warden"
	state.current_room = "RoomCheckpoint"
	if not save_manager.save_game(state):
		_fail("Main title menu test could not create a save.")
		return

	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame

	var title := main.get("current_screen") as Control
	title.get_node("%LoadGameButton").pressed.emit()
	await process_frame
	await process_frame

	var world := main.get("current_screen") as GameWorld
	if world == null:
		_fail("Load Game should continue into GameWorld.")
		return
	if world.state == null or world.state.current_room != "RoomCheckpoint":
		_fail("Load Game should use the saved GameState.")
		return

	main.queue_free()
	save_manager.delete_save()
	await process_frame

func _assert_placeholder_menu_entries_return_to_title() -> void:
	var entries := {
		"AccessibilityButton": "AccessibilityScreen",
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

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
