extends Control
class_name TitleScreen

signal new_game_requested
signal continue_requested
signal settings_requested


func _ready() -> void:
	%NewGameButton.pressed.connect(_on_new_game_pressed)
	%ContinueButton.pressed.connect(_on_continue_pressed)
	%SettingsButton.pressed.connect(_on_settings_pressed)

	%ContinueButton.disabled = not SaveManager.has_save()


func _on_new_game_pressed() -> void:
	new_game_requested.emit()


func _on_continue_pressed() -> void:
	continue_requested.emit()


func _on_settings_pressed() -> void:
	settings_requested.emit()
