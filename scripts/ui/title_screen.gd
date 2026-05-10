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

const PARALLAX_OVERSCAN_PIXELS := 32.0
const PARALLAX_IDLE_PIXELS := Vector2(6.0, 4.0)
const PARALLAX_POINTER_PIXELS := Vector2(10.0, 6.0)
const PARALLAX_IDLE_SPEED := Vector2(0.35, 0.27)

@export var parallax_enabled := true

@onready var background: TextureRect = $Background
@onready var continue_button: Button = %ContinueButton

var _title_time := 0.0
var _title_parallax_offset := Vector2.ZERO


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
	_apply_title_parallax()


func _process(delta: float) -> void:
	if not parallax_enabled:
		return
	_title_time += delta
	_apply_title_parallax()


func get_title_parallax_offset() -> Vector2:
	return _title_parallax_offset


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


func _apply_title_parallax() -> void:
	var idle_offset := Vector2(
		sin(_title_time * PARALLAX_IDLE_SPEED.x) * PARALLAX_IDLE_PIXELS.x,
		cos(_title_time * PARALLAX_IDLE_SPEED.y) * PARALLAX_IDLE_PIXELS.y
	)
	var pointer_offset := _get_pointer_parallax_offset()
	_title_parallax_offset = (idle_offset + pointer_offset).round()
	background.offset_left = -PARALLAX_OVERSCAN_PIXELS + _title_parallax_offset.x
	background.offset_top = -PARALLAX_OVERSCAN_PIXELS + _title_parallax_offset.y
	background.offset_right = PARALLAX_OVERSCAN_PIXELS + _title_parallax_offset.x
	background.offset_bottom = PARALLAX_OVERSCAN_PIXELS + _title_parallax_offset.y


func _get_pointer_parallax_offset() -> Vector2:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Vector2.ZERO

	var pointer_position := get_viewport().get_mouse_position()
	var pointer_ratio := Vector2(
		clampf(pointer_position.x / viewport_size.x, 0.0, 1.0) - 0.5,
		clampf(pointer_position.y / viewport_size.y, 0.0, 1.0) - 0.5
	)
	return Vector2(
		pointer_ratio.x * PARALLAX_POINTER_PIXELS.x,
		pointer_ratio.y * PARALLAX_POINTER_PIXELS.y
	)
