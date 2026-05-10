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
	if title.has_signal("settings_requested"):
		title.connect("settings_requested", show_settings)


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


func _start_new_game(class_id: String, sprite_id: String) -> void:
	var world := _replace_screen(GAME_WORLD_PATH)
	if world.has_method("start_new_game"):
		world.start_new_game(class_id, sprite_id)


func _continue_game() -> void:
	var world := _replace_screen(GAME_WORLD_PATH)
	if world.has_method("continue_game"):
		world.continue_game()

func _get_save_manager() -> Node:
	return get_tree().root.get_node_or_null("SaveManager")
