extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const MAIN_SCENE := preload("res://scenes/Main.tscn")
const CHARACTER_SELECT_SCENE := preload("res://scenes/ui/CharacterSelect.tscn")

var _failed := false
var _confirmed_starter_id := ""
var _confirmed_name := ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_character_select_lists_only_starters_and_validates_name()
	if _failed:
		return
	await _assert_each_starter_creates_save_and_continue_loads_it()
	if _failed:
		return
	print("PASS: character creation")
	quit(0)

func _assert_character_select_lists_only_starters_and_validates_name() -> void:
	var select := CHARACTER_SELECT_SCENE.instantiate() as CharacterSelect
	root.add_child(select)
	await process_frame

	if not select.has_method("get_starter_ids"):
		_fail("CharacterSelect should expose get_starter_ids().")
		return
	var starter_ids: Array = select.call("get_starter_ids")
	if starter_ids != ["ronin", "arc_gunner", "iron_knight"]:
		_fail("CharacterSelect should list exactly the three starter characters.")
		return

	if not select.has_method("set_character_name") or not select.has_method("is_name_valid"):
		_fail("CharacterSelect should expose name input helpers.")
		return
	select.call("set_character_name", "  ")
	if bool(select.call("is_name_valid")):
		_fail("Blank character names should be invalid.")
		return
	select.call("set_character_name", "Mina")
	if not bool(select.call("is_name_valid")):
		_fail("Nonblank character names should be valid.")
		return

	_confirmed_starter_id = ""
	_confirmed_name = ""
	select.connect("character_confirmed", _on_character_confirmed)
	select.call("select_starter_by_id", "arc_gunner")
	select.call("set_character_name", " Vale ")
	select.call("confirm_selection")
	if _confirmed_starter_id != "arc_gunner" or _confirmed_name != "Vale":
		_fail("CharacterSelect should emit selected starter ID and trimmed name.")
		return
	if not select.has_method("get_selected_appearance") or not select.has_method("get_appearance_slot_ids"):
		_fail("CharacterSelect should expose CharacterCreator2D appearance helpers.")
		return
	var appearance_slot_ids: Array = select.call("get_appearance_slot_ids")
	if not appearance_slot_ids.has("Base/Body Skin") or not appearance_slot_ids.has("Base/Hair") or not appearance_slot_ids.has("Fantasy/Armor"):
		_fail("CharacterSelect should expose imported CharacterCreator2D body, hair, and armor slots.")
		return
	var appearance: Dictionary = select.call("get_selected_appearance")
	if not (appearance.get("Base/Hair", {}) as Dictionary).has("path"):
		_fail("CharacterSelect should produce a saved appearance dictionary with sprite paths.")
		return

	select.queue_free()
	await process_frame

func _assert_each_starter_creates_save_and_continue_loads_it() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_character_creation_save.json"
	save_manager.delete_save()

	var expected_classes := {
		"ronin": "warden",
		"arc_gunner": "gunslinger",
		"iron_knight": "warden",
	}
	for starter_id: String in ["ronin", "arc_gunner", "iron_knight"]:
		save_manager.delete_save()
		var main := MAIN_SCENE.instantiate() as Main
		root.add_child(main)
		await process_frame

		var title := main.get("current_screen") as TitleScreen
		title.get_node("%NewGameButton").pressed.emit()
		await process_frame

		var select := main.get("current_screen") as CharacterSelect
		if select == null:
			_fail("New Game should open character creation.")
			return
		select.call("select_starter_by_id", starter_id)
		select.call("set_character_name", "Test " + starter_id)
		select.call("confirm_selection")
		await process_frame

		var world := main.get("current_screen") as GameWorld
		if world == null:
			_fail("Confirming character creation should enter GameWorld.")
			return
		var loaded: GameState = save_manager.load_game()
		if loaded == null:
			_fail("Character creation should write an initial save.")
			return
		if loaded.selected_starter_id != starter_id:
			_fail("Initial save should store selected starter ID.")
			return
		if loaded.player_name != "Test " + starter_id:
			_fail("Initial save should store the player-entered name.")
			return
		if loaded.selected_class != str(expected_classes[starter_id]):
			_fail("Initial save should map starter to a playable class.")
			return
		if loaded.character_appearance.is_empty() or not loaded.character_appearance.has("Base/Body Skin"):
			_fail("Initial save should persist CharacterCreator2D appearance selections.")
			return
		var player: Node = world.get("player")
		if player == null or not player.has_method("get_character_appearance") or (player.call("get_character_appearance") as Dictionary).is_empty():
			_fail("GameWorld should pass saved CharacterCreator2D appearance selections into the player runtime.")
			return
		if loaded.current_room != "RoomStart" or loaded.current_area != "swamp_outskirts":
			_fail("Initial save should start in the opening room.")
			return

		main.queue_free()
		await process_frame

	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame
	var title := main.get("current_screen") as TitleScreen
	title.get_node("%ContinueButton").pressed.emit()
	await process_frame
	var continued_world := main.get("current_screen") as GameWorld
	if continued_world == null or continued_world.state == null or continued_world.state.selected_starter_id != "iron_knight":
		_fail("Continue should load the save created by character creation.")
		return

	main.queue_free()
	save_manager.delete_save()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)

func _on_character_confirmed(starter_id: String, character_name: String) -> void:
	_confirmed_starter_id = starter_id
	_confirmed_name = character_name
