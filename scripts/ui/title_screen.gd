extends Control
class_name TitleScreen

signal new_game_requested
signal continue_requested
signal settings_requested

@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	%NewGameButton.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	%SettingsButton.pressed.connect(_on_settings_pressed)

	refresh_continue_state()


func refresh_continue_state() -> void:
	var save_manager := get_tree().root.get_node_or_null("SaveManager")
	continue_button.disabled = save_manager == null or not save_manager.has_save()


func _on_new_game_pressed() -> void:
	new_game_requested.emit()


func _on_continue_pressed() -> void:
	continue_requested.emit()


func _on_settings_pressed() -> void:
	settings_requested.emit()
