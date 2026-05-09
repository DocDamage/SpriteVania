extends Control
class_name SettingsMenu

signal closed

const MIN_VOLUME_LINEAR := 0.001


func _ready() -> void:
	%BackButton.pressed.connect(_on_back_pressed)
	%VolumeSlider.value_changed.connect(_on_volume_changed)
	%WindowModeButton.toggled.connect(_on_window_mode_toggled)

	%WindowModeButton.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


func _on_back_pressed() -> void:
	closed.emit()


func _on_volume_changed(value: float) -> void:
	var master_bus_index := AudioServer.get_bus_index("Master")
	var volume_db := -80.0 if value <= 0.0 else linear_to_db(maxf(value, MIN_VOLUME_LINEAR))
	AudioServer.set_bus_volume_db(master_bus_index, volume_db)


func _on_window_mode_toggled(toggled_on: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
