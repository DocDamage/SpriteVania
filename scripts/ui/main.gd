extends Control
class_name Main

const TITLE_SCREEN_PATH := "res://scenes/ui/TitleScreen.tscn"
const CHARACTER_SELECT_PATH := "res://scenes/ui/CharacterSelect.tscn"
const SETTINGS_MENU_PATH := "res://scenes/ui/SettingsMenu.tscn"
const GAME_WORLD_PATH := "res://scenes/world/GameWorld.tscn"

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
	if title.has_signal("new_game_requested"):
		title.connect("new_game_requested", show_character_select)
	if title.has_signal("continue_requested"):
		title.connect("continue_requested", _continue_game)
	if title.has_signal("load_game_requested"):
		title.connect("load_game_requested", _continue_game)
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
	if select.has_signal("cancel_requested"):
		select.connect("cancel_requested", show_title)
	if select.has_signal("character_confirmed"):
		select.connect("character_confirmed", _start_new_game)


func show_settings() -> void:
	var settings := _replace_screen(SETTINGS_MENU_PATH)
	if settings.has_method("set_save_manager"):
		settings.call("set_save_manager", _get_save_manager())
	if settings.has_signal("closed"):
		settings.connect("closed", show_title)


func show_accessibility() -> void:
	_show_placeholder_menu("AccessibilityScreen", "Accessibility")


func show_extras() -> void:
	_show_placeholder_menu("ExtrasScreen", "Extras")


func show_credits() -> void:
	_show_placeholder_menu("CreditsScreen", "Credits")


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

func _show_placeholder_menu(screen_name: String, title_text: String) -> void:
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
	body.text = "Coming soon."
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(body)

	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(180, 40)
	back_button.pressed.connect(show_title)
	stack.add_child(back_button)

	current_screen = screen
	add_child(current_screen)

func _connect_world_navigation(world: Node) -> void:
	if world.has_signal("settings_requested"):
		world.connect("settings_requested", show_settings)
	if world.has_signal("quit_to_title_requested"):
		world.connect("quit_to_title_requested", show_title)

func _get_save_manager() -> Node:
	return get_tree().root.get_node_or_null("SaveManager")


func _quit_game() -> void:
	get_tree().quit()
