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
	if not select.has_method("get_selected_appearance") or not select.has_method("get_appearance_slot_ids") or not select.has_method("get_current_recipe") or not select.has_method("randomize_current_recipe") or not select.has_method("filter_part_browser") or not select.has_method("set_part_favorite"):
		_fail("CharacterSelect should expose CharacterCreator2D appearance and recipe helpers.")
		return
	var appearance_slot_ids: Array = select.call("get_appearance_slot_ids")
	if not appearance_slot_ids.has("Base/Body Skin") or not appearance_slot_ids.has("Base/Hair") or not appearance_slot_ids.has("Fantasy/Armor"):
		_fail("CharacterSelect should expose imported CharacterCreator2D body, hair, and armor slots.")
		return
	var appearance: Dictionary = select.call("get_selected_appearance")
	if not (appearance.get("Base/Hair", {}) as Dictionary).has("path"):
		_fail("CharacterSelect should produce a saved appearance dictionary with sprite paths.")
		return
	var recipe: RefCounted = select.call("get_current_recipe")
	if recipe == null or str(recipe.get("recipe_id")) == "":
		_fail("CharacterSelect should maintain a portable CharacterCreator2D recipe.")
		return
	if not select.has_method("get_preview_state") or not select.has_method("refresh_preview"):
		_fail("CharacterSelect should expose in-game creator preview helpers.")
		return
	var preview_state: Dictionary = select.call("get_preview_state")
	if int(preview_state.get("part_count", 0)) <= 0 or (preview_state.get("rendered_part_paths", []) as Array).size() < 3:
		_fail("CharacterSelect should render a layered in-game creator preview.")
		return
	var preview_layer := select.get_node_or_null("%LayeredPreview") as Control
	if preview_layer == null or preview_layer.get_child_count() < 3:
		_fail("CharacterSelect should include a populated LayeredPreview control.")
		return
	var before_paths := (preview_state.get("rendered_part_paths", []) as Array).duplicate()
	if not bool(select.call("select_appearance_option", "Base/Hair", 1)):
		_fail("CharacterSelect should allow changing a creator part option.")
		return
	var after_preview := select.call("get_preview_state") as Dictionary
	if before_paths == (after_preview.get("rendered_part_paths", []) as Array):
		_fail("CharacterSelect preview should update after changing a creator part.")
		return
	var randomize_button := select.get_node_or_null("%RandomizeButton") as Button
	var tag_edit := select.get_node_or_null("%RandomTagEdit") as LineEdit
	var lock_edit := select.get_node_or_null("%RandomLockEdit") as LineEdit
	if randomize_button == null or tag_edit == null or lock_edit == null:
		_fail("CharacterSelect should include visible randomizer controls.")
		return
	var part_search_edit := select.get_node_or_null("%PartSearchEdit") as LineEdit
	var part_tag_edit := select.get_node_or_null("%PartTagFilterEdit") as LineEdit
	var favorite_check := select.get_node_or_null("%FavoriteOnlyCheck") as CheckBox
	if part_search_edit == null or part_tag_edit == null or favorite_check == null:
		_fail("CharacterSelect should include visible part search, tag filter, and favorite controls.")
		return
	var all_count := int(select.call("filter_part_browser", "", []))
	part_search_edit.text = "14"
	part_tag_edit.text = "starter_safe"
	var filtered_count := int(select.call("filter_part_browser", "14", ["starter_safe"]))
	if filtered_count <= 0 or filtered_count >= all_count:
		_fail("CharacterSelect part filters should reduce visible part options.")
		return
	select.call("filter_part_browser", "", [])
	if not bool(select.call("set_part_favorite", "Base/Hair", 0, true)):
		_fail("CharacterSelect should allow marking visible creator parts as favorites.")
		return
	var favorite_count := int(select.call("filter_part_browser", "", [], true))
	if favorite_count != 1:
		_fail("CharacterSelect favorites-only filter should show favorited parts.")
		return
	select.call("filter_part_browser", "", [], false)
	var locked_hair := str(((select.call("get_current_recipe") as RefCounted).get("parts") as Dictionary).get("Base/Hair", {}).get("path", ""))
	var random_report := select.call("randomize_current_recipe", ["Base/Hair"], ["starter_safe"], 13) as Dictionary
	if not (random_report.get("locked_slots", []) as Array).has("Base/Hair"):
		_fail("CharacterSelect randomizer should report locked slots.")
		return
	var randomized_recipe := select.call("get_current_recipe") as RefCounted
	if str(((randomized_recipe.get("parts") as Dictionary).get("Base/Hair", {}) as Dictionary).get("path", "")) != locked_hair:
		_fail("CharacterSelect randomizer should preserve locked slots.")
		return
	var before_random_paths := (select.call("get_preview_state") as Dictionary).get("rendered_part_paths", []) as Array
	var button_locked_hair := str(((select.call("get_current_recipe") as RefCounted).get("parts") as Dictionary).get("Base/Hair", {}).get("path", ""))
	tag_edit.text = "starter_safe"
	lock_edit.text = "Base/Hair"
	randomize_button.pressed.emit()
	var after_random_paths := (select.call("get_preview_state") as Dictionary).get("rendered_part_paths", []) as Array
	if before_random_paths == after_random_paths:
		_fail("CharacterSelect randomize button should refresh preview selections.")
		return
	var button_randomized_recipe := select.call("get_current_recipe") as RefCounted
	if str(((button_randomized_recipe.get("parts") as Dictionary).get("Base/Hair", {}) as Dictionary).get("path", "")) != button_locked_hair:
		_fail("CharacterSelect randomize button should honor visible locked-slot input.")
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
		var selected_recipe := select.call("get_current_recipe") as RefCounted
		selected_recipe.set("generated_spriteframes_path", "res://resources/animations/swamp_thing_frames.tres")
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
		if loaded.character_recipe_id.is_empty() or loaded.character_recipe.is_empty():
			_fail("Initial save should persist a portable CharacterCreator2D recipe payload.")
			return
		if str(loaded.character_recipe.get("recipe_id", "")) != loaded.character_recipe_id:
			_fail("Initial save should keep recipe id and embedded recipe data in sync.")
			return
		if loaded.character_creator_content_versions.is_empty():
			_fail("Initial save should record CharacterCreator2D content versions for migrations.")
			return
		if loaded.character_spriteframes_path != "res://resources/animations/swamp_thing_frames.tres":
			_fail("Initial save should preserve generated CharacterCreator2D SpriteFrames paths from the active recipe.")
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
