extends Control
class_name Main

const TITLE_SCREEN_PATH := "res://scenes/ui/TitleScreen.tscn"
const CHARACTER_SELECT_PATH := "res://scenes/ui/CharacterSelect.tscn"
const SETTINGS_MENU_PATH := "res://scenes/ui/SettingsMenu.tscn"
const GAME_WORLD_PATH := "res://scenes/world/GameWorld.tscn"
const LOAD_SLOTS := [
	{"id": "default", "label": "Continue", "button": "DefaultSlotButton"},
	{"id": "slot_a", "label": "Slot A", "button": "SlotAButton"},
	{"id": "slot_b", "label": "Slot B", "button": "SlotBButton"},
	{"id": "slot_c", "label": "Slot C", "button": "SlotCButton"},
]

var current_screen: Node


func _ready() -> void:
	show_title()


func _replace_screen(scene_path: String) -> Node:
	if current_screen:
		current_screen.queue_free()

	if not ResourceLoader.exists(scene_path):
		current_screen = Control.new()
		current_screen.name = "MissingScreen"
	else:
		var scene := load(scene_path) as PackedScene
		current_screen = scene.instantiate()

	add_child(current_screen)
	return current_screen


func show_title() -> void:
	var title := _replace_screen(TITLE_SCREEN_PATH)
	_apply_persisted_settings_to_screen(title)
	if title.has_signal("new_game_requested"):
		title.connect("new_game_requested", show_character_select)
	if title.has_signal("continue_requested"):
		title.connect("continue_requested", _continue_game)
	if title.has_signal("load_game_requested"):
		title.connect("load_game_requested", show_load_game)
	if title.has_signal("settings_requested"):
		title.connect("settings_requested", show_settings)
	if title.has_signal("accessibility_requested"):
		title.connect("accessibility_requested", show_accessibility)
	if title.has_signal("extras_requested"):
		title.connect("extras_requested", show_extras)
	if title.has_signal("credits_requested"):
		title.connect("credits_requested", show_credits)
	if title.has_signal("quit_requested"):
		title.connect("quit_requested", _quit_game)


func show_character_select() -> void:
	var select := _replace_screen(CHARACTER_SELECT_PATH)
	_apply_persisted_settings_to_screen(select)
	if select.has_signal("cancel_requested"):
		select.connect("cancel_requested", show_title)
	if select.has_signal("character_confirmed"):
		select.connect("character_confirmed", _start_new_game)


func show_settings(tab_name := "General") -> void:
	var settings := _replace_screen(SETTINGS_MENU_PATH)
	if settings.has_method("set_save_manager"):
		settings.call("set_save_manager", _get_save_manager())
	if settings.has_method("select_settings_tab"):
		settings.call("select_settings_tab", tab_name)
	if settings.has_signal("settings_changed"):
		settings.connect("settings_changed", _on_settings_changed)
	if settings.has_signal("closed"):
		settings.connect("closed", show_title)


func show_load_game() -> void:
	var screen := _create_panel_screen("LoadGameScreen", "Load Game")
	var stack := screen.get_node("Panel/MarginContainer/VBoxContainer") as VBoxContainer
	var save_manager := _get_save_manager()
	for slot_data: Dictionary in LOAD_SLOTS:
		var slot_id := str(slot_data.id)
		var button := Button.new()
		button.name = str(slot_data.button)
		button.unique_name_in_owner = true
		button.custom_minimum_size = Vector2(260, 40)
		button.text = "%s - %s" % [slot_data.label, _slot_status_text(save_manager, slot_id)]
		button.disabled = not _has_slot_save(save_manager, slot_id)
		button.pressed.connect(func() -> void: _load_game_from_slot(slot_id))
		stack.add_child(button)
		stack.move_child(button, max(1, stack.get_child_count() - 2))
	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(180, 40)
	back_button.pressed.connect(show_title)
	stack.add_child(back_button)


func show_accessibility() -> void:
	show_settings("Accessibility")


func show_extras() -> void:
	_show_info_menu("ExtrasScreen", "Extras", "Unlocked modes, lore, music, and art will live here as the game grows.")


func show_credits() -> void:
	_show_info_menu("CreditsScreen", "Credits", "SpriteVania is built from the project asset library, Godot, and custom game code.")


func _start_new_game(class_id: String, sprite_id: String) -> void:
	var world := _replace_screen(GAME_WORLD_PATH)
	_connect_world_navigation(world)
	if world.has_method("start_new_game"):
		world.start_new_game(class_id, sprite_id)


func _continue_game() -> void:
	var world := _replace_screen(GAME_WORLD_PATH)
	_connect_world_navigation(world)
	if world.has_method("continue_game"):
		world.continue_game()

func _load_game_from_slot(slot_id: String) -> void:
	var world := _replace_screen(GAME_WORLD_PATH)
	_connect_world_navigation(world)
	if slot_id == "default" and world.has_method("continue_game"):
		world.continue_game()
	elif world.has_method("continue_game_from_slot"):
		world.continue_game_from_slot(slot_id)

func _show_info_menu(screen_name: String, title_text: String, body_text: String) -> void:
	var screen := _create_panel_screen(screen_name, title_text, body_text)
	var stack := screen.get_node("Panel/MarginContainer/VBoxContainer") as VBoxContainer
	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(180, 40)
	back_button.pressed.connect(show_title)
	stack.add_child(back_button)

func _create_panel_screen(screen_name: String, title_text: String, body_text := "") -> Control:
	if current_screen:
		current_screen.queue_free()

	var screen := Control.new()
	screen.name = screen_name
	screen.layout_mode = 3
	screen.anchors_preset = Control.PRESET_FULL_RECT
	screen.anchor_right = 1.0
	screen.anchor_bottom = 1.0
	screen.grow_horizontal = Control.GROW_DIRECTION_BOTH
	screen.grow_vertical = Control.GROW_DIRECTION_BOTH

	var panel := Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(360, 220)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -180.0
	panel.offset_top = -110.0
	panel.offset_right = 180.0
	panel.offset_bottom = 110.0
	screen.add_child(panel)

	var margins := MarginContainer.new()
	margins.name = "MarginContainer"
	margins.set_anchors_preset(Control.PRESET_FULL_RECT)
	margins.add_theme_constant_override("margin_left", 24)
	margins.add_theme_constant_override("margin_top", 24)
	margins.add_theme_constant_override("margin_right", 24)
	margins.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margins)

	var stack := VBoxContainer.new()
	stack.name = "VBoxContainer"
	stack.add_theme_constant_override("separation", 18)
	margins.add_child(stack)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	stack.add_child(title)

	var body := Label.new()
	body.name = "BodyLabel"
	body.text = body_text
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(body)

	current_screen = screen
	add_child(current_screen)
	return screen

func _has_slot_save(save_manager: Node, slot_id: String) -> bool:
	if save_manager == null:
		return false
	if slot_id == "default" and save_manager.has_method("has_save"):
		return bool(save_manager.call("has_save"))
	if save_manager.has_method("has_save_in_slot"):
		return bool(save_manager.call("has_save_in_slot", slot_id))
	return false

func _slot_status_text(save_manager: Node, slot_id: String) -> String:
	return "Saved" if _has_slot_save(save_manager, slot_id) else "Empty"

func _connect_world_navigation(world: Node) -> void:
	_apply_persisted_settings_to_screen(world)
	if world.has_signal("settings_requested"):
		world.connect("settings_requested", show_settings)
	if world.has_signal("quit_to_title_requested"):
		world.connect("quit_to_title_requested", show_title)

func _get_save_manager() -> Node:
	return get_tree().root.get_node_or_null("SaveManager")


func _get_persisted_settings() -> Dictionary:
	var save_manager := _get_save_manager()
	if save_manager == null or not save_manager.has_method("load_game"):
		return {}
	var state: Variant = save_manager.call("load_game")
	if state == null:
		return {}
	var settings: Variant = state.get("settings")
	return settings if settings is Dictionary else {}


func _apply_persisted_settings_to_screen(screen: Node) -> void:
	if screen != null and screen.has_method("apply_settings"):
		screen.call("apply_settings", _get_persisted_settings())


func _on_settings_changed(settings: Dictionary) -> void:
	if current_screen != null and current_screen.has_method("apply_settings"):
		current_screen.call("apply_settings", settings)


func _quit_game() -> void:
	get_tree().quit()
