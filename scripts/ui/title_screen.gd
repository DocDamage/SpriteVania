extends Control
class_name TitleScreen

signal new_game_requested
signal continue_requested
signal settings_requested
signal load_game_requested
signal accessibility_requested
signal extras_requested
signal credits_requested
signal quit_requested

@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	%NewGameButton.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	%SettingsButton.pressed.connect(_on_settings_pressed)
	%LoadGameButton.pressed.connect(_on_load_game_pressed)
	%AccessibilityButton.pressed.connect(_on_accessibility_pressed)
	%ExtrasButton.pressed.connect(_on_extras_pressed)
	%CreditsButton.pressed.connect(_on_credits_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)

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


func _on_load_game_pressed() -> void:
	load_game_requested.emit()


func _on_accessibility_pressed() -> void:
	accessibility_requested.emit()


func _on_extras_pressed() -> void:
	extras_requested.emit()


func _on_credits_pressed() -> void:
	credits_requested.emit()


func _on_quit_pressed() -> void:
	quit_requested.emit()
