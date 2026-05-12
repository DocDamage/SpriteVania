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
	await _assert_character_select_enforces_name_rules_and_controller_actions()
	if _failed:
		return
	await _assert_character_select_applies_accessibility_settings()
	if _failed:
		return
	await _assert_character_creation_save_failure_stays_in_creator()
	if _failed:
		return
	await _assert_character_creation_requires_overwrite_confirmation()
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
	if _confirmed_starter_id != "" or not bool(select.call("is_confirmation_pending")):
		_fail("CharacterSelect should enter a confirmation review state before committing.")
		return
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
	if not select.has_method("get_preview_state") or not select.has_method("refresh_preview") or not select.has_method("accessibility_preview") or not select.has_method("performance_budget_report") or not select.has_method("compatibility_report") or not select.has_method("socket_report_for_recipe"):
		_fail("CharacterSelect should expose in-game creator preview helpers.")
		return
	var preview_state: Dictionary = select.call("get_preview_state")
	if int(preview_state.get("part_count", 0)) <= 0 or (preview_state.get("rendered_part_paths", []) as Array).size() < 3:
		_fail("CharacterSelect should render a layered in-game creator preview.")
		return
	if (preview_state.get("constraints", {}) as Dictionary).is_empty() or int(preview_state.get("socket_count", 0)) < 5:
		_fail("CharacterSelect preview state should include compatibility constraints and equipment socket count.")
		return
	var preview_layer := select.get_node_or_null("%LayeredPreview") as Control
	if preview_layer == null or preview_layer.get_child_count() < 3:
		_fail("CharacterSelect should include a populated LayeredPreview control.")
		return
	var accessibility_label := select.get_node_or_null("%AccessibilityPreviewLabel") as Label
	var budget_label := select.get_node_or_null("%PerformanceBudgetLabel") as Label
	var compatibility_label := select.get_node_or_null("%CompatibilityPreviewLabel") as Label
	var socket_label := select.get_node_or_null("%SocketPreviewLabel") as Label
	if accessibility_label == null or accessibility_label.text.is_empty() or budget_label == null or budget_label.text.is_empty() or compatibility_label == null or compatibility_label.text.is_empty() or socket_label == null or socket_label.text.is_empty():
		_fail("CharacterSelect should include visible accessibility, budget, compatibility, and socket preview labels.")
		return
	var performance_report := select.call("performance_budget_report") as Dictionary
	if not performance_report.has("ok") or (performance_report.get("targets", []) as Array).is_empty():
		_fail("CharacterSelect should expose target performance budget reports.")
		return
	var compatibility_report := select.call("compatibility_report") as Dictionary
	if not compatibility_report.has("frame_bounds") or not compatibility_report.has("hitbox_compatibility"):
		_fail("CharacterSelect should expose compatibility reports for in-game creator readability.")
		return
	var socket_report := select.call("socket_report_for_recipe", "idle") as Dictionary
	if ((socket_report.get("sockets", {}) as Dictionary).get("main_hand", {}) as Dictionary).is_empty():
		_fail("CharacterSelect should expose equipment socket reports for the active recipe.")
		return
	if not select.has_method("set_palette_color") or not select.has_method("set_morph_value"):
		_fail("CharacterSelect should expose lightweight palette and morph edit helpers.")
		return
	var palette_controls := select.get_node_or_null("%PaletteControls") as VBoxContainer
	var morph_controls := select.get_node_or_null("%MorphControls") as VBoxContainer
	if palette_controls == null or morph_controls == null:
		_fail("CharacterSelect should include visible palette inputs and safe morph sliders.")
		return
	var hair_palette_edit := palette_controls.find_child("HairPaletteEdit", true, false) as LineEdit
	var head_size_slider := morph_controls.find_child("HeadSizeMorphSlider", true, false) as HSlider
	if hair_palette_edit == null or head_size_slider == null:
		_fail("CharacterSelect should build visible palette inputs and safe morph sliders from the active recipe.")
		return
	var hair_layer := preview_layer.get_node_or_null("Base_Hair") as TextureRect
	if hair_layer == null:
		_fail("CharacterSelect preview should include a named hair layer for palette and morph edits.")
		return
	var original_hair_scale := hair_layer.scale
	hair_palette_edit.text = "ff3366ff"
	hair_palette_edit.text_changed.emit(hair_palette_edit.text)
	var palette_recipe := select.call("get_current_recipe") as RefCounted
	if str((palette_recipe.get("palettes") as Dictionary).get("hair", "")) != "ff3366ff":
		_fail("CharacterSelect palette edits should update the active recipe.")
		return
	hair_layer = preview_layer.get_node_or_null("Base_Hair") as TextureRect
	if hair_layer == null or hair_layer.modulate != Color.html("ff3366ff"):
		_fail("CharacterSelect palette edits should update preview modulation.")
		return
	select.call("set_palette_color", "cloth_primary", "ff3366ff")
	var accessibility_report := select.call("accessibility_preview") as Dictionary
	if bool(accessibility_report.get("ok", true)) or int((accessibility_report.get("summary", {}) as Dictionary).get("failing_palette_pairs", 0)) <= 0:
		_fail("CharacterSelect accessibility preview should flag low-contrast palette edits.")
		return
	if not accessibility_label.text.contains("Review"):
		_fail("CharacterSelect accessibility label should update after palette accessibility changes.")
		return
	head_size_slider.value = 0.5
	head_size_slider.value_changed.emit(head_size_slider.value)
	var morph_recipe := select.call("get_current_recipe") as RefCounted
	if not is_equal_approx(float((morph_recipe.get("morphs") as Dictionary).get("head_size", 0.0)), 0.5):
		_fail("CharacterSelect morph edits should update the active recipe.")
		return
	hair_layer = preview_layer.get_node_or_null("Base_Hair") as TextureRect
	if hair_layer == null or hair_layer.scale == original_hair_scale:
		_fail("CharacterSelect morph edits should update preview transforms.")
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

func _assert_character_select_enforces_name_rules_and_controller_actions() -> void:
	var select := CHARACTER_SELECT_SCENE.instantiate() as CharacterSelect
	root.add_child(select)
	await process_frame

	for method_name: String in ["normalize_character_name", "get_name_validation_error", "handle_creator_action", "append_name_character", "backspace_character_name"]:
		if not select.has_method(method_name):
			_fail("CharacterSelect should expose " + method_name + " for creator validation and controller flow.")
			return
	var keyboard := select.get_node_or_null("%OnScreenKeyboard") as GridContainer
	if keyboard == null:
		_fail("CharacterSelect should include an on-screen keyboard for controller name entry.")
		return
	select.call("set_character_name", "")
	select.call("append_name_character", "A")
	select.call("append_name_character", "k")
	select.call("append_name_character", "!")
	if str((select.get_node("%NameEdit") as LineEdit).text) != "Ak":
		_fail("On-screen keyboard helpers should append only allowed name characters.")
		return
	select.call("backspace_character_name")
	if str((select.get_node("%NameEdit") as LineEdit).text) != "A":
		_fail("On-screen keyboard helpers should support controller backspace.")
		return
	if str(select.call("normalize_character_name", "  Vale   Cross  ")) != "Vale Cross":
		_fail("CharacterSelect should trim and collapse repeated internal whitespace.")
		return
	select.call("set_character_name", "ThisNameIsFarTooLong")
	if bool(select.call("is_name_valid")) or str(select.call("get_name_validation_error")) != "too_long":
		_fail("CharacterSelect should reject names over 16 visible characters.")
		return
	select.call("set_character_name", "Bad\u0007Name")
	if bool(select.call("is_name_valid")) or str(select.call("get_name_validation_error")) != "invalid_characters":
		_fail("CharacterSelect should reject control characters.")
		return
	select.call("set_character_name", "Mira!")
	if bool(select.call("is_name_valid")) or str(select.call("get_name_validation_error")) != "invalid_characters":
		_fail("CharacterSelect should only allow letters, numbers, spaces, apostrophes, hyphens, and underscores.")
		return
	select.call("set_character_name", "Vale_Cross-2")
	if not bool(select.call("is_name_valid")):
		_fail("CharacterSelect should accept underscores, hyphens, and numbers.")
		return
	if not select.has_method("reset_name_to_default"):
		_fail("CharacterSelect should expose reset_name_to_default().")
		return
	var reset_button := select.get_node_or_null("%ResetNameButton") as Button
	if reset_button == null:
		_fail("CharacterSelect should include a visible reset-to-default name button.")
		return
	select.call("select_starter_by_id", "iron_knight")
	select.call("set_character_name", "Custom")
	reset_button.pressed.emit()
	if str(select.call("normalize_character_name", (select.get_node("%NameEdit") as LineEdit).text)) != "Rowan":
		_fail("Reset name should restore the selected starter default name.")
		return
	select.call("set_character_name", "Vale_Cross-2")
	_confirmed_starter_id = ""
	_confirmed_name = ""
	select.connect("character_confirmed", _on_character_confirmed)
	if not bool(select.call("handle_creator_action", "ui_accept")):
		_fail("CharacterSelect should handle controller confirm through ui_accept.")
		return
	if not bool(select.call("handle_creator_action", "ui_accept")):
		_fail("CharacterSelect should handle controller start-game confirmation through ui_accept.")
		return
	if _confirmed_name != "Vale_Cross-2":
		_fail("Controller confirm should emit the normalized accepted name.")
		return
	var cancelled := {"ok": false}
	select.connect("cancel_requested", func() -> void:
		cancelled["ok"] = true
	)
	if not bool(select.call("handle_creator_action", "ui_cancel")):
		_fail("CharacterSelect should handle controller back through ui_cancel.")
		return
	if not bool(cancelled["ok"]):
		_fail("Controller back should emit cancel_requested.")
		return
	select.queue_free()
	await process_frame

func _assert_character_select_applies_accessibility_settings() -> void:
	var select := CHARACTER_SELECT_SCENE.instantiate() as CharacterSelect
	root.add_child(select)
	await process_frame
	if not select.has_method("apply_settings"):
		_fail("CharacterSelect should apply accessibility settings.")
		return
	var header := select.get_node_or_null("CenterContainer/VBoxContainer/HeaderLabel") as Label
	var preview := select.get_node_or_null("%LayeredPreview") as Control
	if header == null or preview == null:
		_fail("CharacterSelect accessibility test requires header and preview controls.")
		return
	select.call("apply_settings", {"font_scale": 1.5, "reduced_motion": true})
	if int(header.get_theme_font_size("font_size")) < 48:
		_fail("CharacterSelect should scale creator text for accessibility font scale.")
		return
	if preview.visible:
		_fail("CharacterSelect should simplify or disable layered sprite preview when reduced motion is enabled.")
		return
	select.call("apply_settings", {"font_scale": 1.0, "reduced_motion": false})
	if not preview.visible:
		_fail("CharacterSelect should restore preview when reduced motion is disabled.")
		return
	select.queue_free()
	await process_frame

func _assert_character_creation_save_failure_stays_in_creator() -> void:
	var save_manager := root.get_node("SaveManager")
	var previous_path := str(save_manager.get("save_path"))
	var previous_report_save_errors := bool(save_manager.get("report_save_errors"))
	var blocker_path := "user://character_creation_save_blocker"
	var blocker := FileAccess.open(blocker_path, FileAccess.WRITE)
	if blocker == null:
		_fail("Character creation save failure test could not create blocker file.")
		return
	blocker.store_string("not a directory")
	blocker = null
	save_manager.set("save_path", "%s/character_creation.json" % blocker_path)
	save_manager.set("report_save_errors", false)
	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame
	var title := main.get("current_screen") as TitleScreen
	title.get_node("%NewGameButton").pressed.emit()
	await process_frame
	var select := main.get("current_screen") as CharacterSelect
	select.call("select_starter_by_id", "ronin")
	select.call("set_character_name", "Akio")
	_confirm_character_select(select)
	await process_frame
	if not main.has_method("get_last_new_game_error"):
		_fail("Main should expose character creation save errors.")
		return
	if not (main.get("current_screen") is CharacterSelect):
		_fail("Character creation should remain in the creator when initial save fails.")
		return
	if str(main.call("get_last_new_game_error")) != "save_failed":
		_fail("Character creation should report save_failed when initial save cannot be written.")
		return
	if str((main.get("current_screen") as CharacterSelect).call("get_creator_error")) != "save_failed":
		_fail("CharacterSelect should expose the save failure to the creator UI.")
		return
	main.queue_free()
	save_manager.set("save_path", previous_path)
	save_manager.set("report_save_errors", previous_report_save_errors)
	DirAccess.remove_absolute(blocker_path)
	await process_frame

func _assert_character_creation_requires_overwrite_confirmation() -> void:
	var save_manager := root.get_node("SaveManager")
	save_manager.save_path = "user://test_character_creation_overwrite.json"
	save_manager.delete_save()
	var existing := GameState.new()
	existing.selected_starter_id = "ronin"
	existing.player_name = "Existing"
	existing.selected_class = "warden"
	if not save_manager.save_game(existing):
		_fail("Character creation overwrite test could not seed an occupied save.")
		return

	var main := MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	await process_frame
	var title := main.get("current_screen") as TitleScreen
	title.get_node("%NewGameButton").pressed.emit()
	await process_frame
	var select := main.get("current_screen") as CharacterSelect
	select.call("select_starter_by_id", "arc_gunner")
	select.call("set_character_name", "Vale")
	_confirm_character_select(select)
	await process_frame
	if not (main.get("current_screen") is CharacterSelect):
		_fail("Occupied saves should keep character creation open until overwrite is confirmed.")
		return
	if str(main.call("get_last_new_game_error")) != "overwrite_required":
		_fail("Occupied saves should report overwrite_required before writing.")
		return
	if str(select.call("get_creator_error")) != "overwrite_required":
		_fail("CharacterSelect should expose overwrite_required to the creator UI.")
		return
	var loaded_existing: GameState = save_manager.load_game()
	if loaded_existing == null or loaded_existing.player_name != "Existing":
		_fail("First overwrite prompt should not mutate the existing save.")
		return

	select.call("select_starter_by_id", "iron_knight")
	select.call("set_character_name", "Rowan")
	_confirm_character_select(select)
	await process_frame
	if not (main.get("current_screen") is CharacterSelect):
		_fail("Changing character creation details after an overwrite prompt should require a fresh overwrite confirmation.")
		return
	loaded_existing = save_manager.load_game()
	if loaded_existing == null or loaded_existing.player_name != "Existing":
		_fail("Stale overwrite confirmation should not write a changed character.")
		return

	_confirm_character_select(select)
	await process_frame
	if not (main.get("current_screen") is GameWorld):
		_fail("Second confirmation should overwrite the occupied save and enter the game.")
		return
	var overwritten: GameState = save_manager.load_game()
	if overwritten == null or overwritten.selected_starter_id != "iron_knight" or overwritten.player_name != "Rowan":
		_fail("Overwrite confirmation should write the newly created character.")
		return
	main.queue_free()
	save_manager.delete_save()
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
	var expected_vitals := {
		"ronin": {"health": 140, "resource": 40},
		"arc_gunner": {"health": 100, "resource": 60},
		"iron_knight": {"health": 140, "resource": 40},
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
		select.call("set_palette_color", "hair", "ff3366ff")
		select.call("set_morph_value", "head_size", 0.4)
		selected_recipe.set("generated_spriteframes_path", "res://resources/animations/swamp_thing_frames.tres")
		_confirm_character_select(select)
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
		if str((loaded.character_recipe.get("palettes", {}) as Dictionary).get("hair", "")) != "ff3366ff":
			_fail("Initial save should persist in-game palette edits in the recipe payload.")
			return
		if not is_equal_approx(float((loaded.character_recipe.get("morphs", {}) as Dictionary).get("head_size", 0.0)), 0.4):
			_fail("Initial save should persist in-game morph edits in the recipe payload.")
			return
		if loaded.character_creator_content_versions.is_empty():
			_fail("Initial save should record CharacterCreator2D content versions for migrations.")
			return
		if str(loaded.character_definitions_version).is_empty():
			_fail("Initial save should record the character definitions version.")
			return
		if loaded.created_timestamp <= 0 or loaded.last_saved_timestamp <= 0:
			_fail("Initial save should record created and last-saved timestamps.")
			return
		if not bool(loaded.character_creation_flags.get("starter_selected", false)) or not bool(loaded.character_creation_flags.get("starter_named", false)) or not bool(loaded.character_creation_flags.get("new_game_committed", false)):
			_fail("Initial save should mark character creation progress flags.")
			return
		if str(loaded.player_character_names.get(starter_id, "")) != loaded.player_name:
			_fail("Initial save should store the accepted player name by starter id.")
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
		if loaded.checkpoint_id != "checkpoint_modern_start" or loaded.checkpoint_room != "RoomStart":
			_fail("Initial save should set the opening checkpoint.")
			return
		if loaded.current_health != int(expected_vitals[starter_id].health) or loaded.current_resource != int(expected_vitals[starter_id].resource):
			_fail("Initial save should start the selected character at class max vitals.")
			return
		if loaded.unlocked_character_ids != [starter_id] or loaded.current_visible_character_id != starter_id:
			_fail("Initial save should persist unlocked and visible starter party fields.")
			return
		var starter_runtime := loaded.party_roster.get(starter_id, {}) as Dictionary
		if int(starter_runtime.get("current_health", 0)) != int(expected_vitals[starter_id].health):
			_fail("Initial party roster should store starter runtime health.")
			return
		if int(starter_runtime.get("current_resource", 0)) != int(expected_vitals[starter_id].resource):
			_fail("Initial party roster should store starter runtime resource.")
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

func _confirm_character_select(select: CharacterSelect) -> void:
	select.call("confirm_selection")
	select.call("confirm_selection")
