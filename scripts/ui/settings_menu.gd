extends Control
class_name SettingsMenu

signal closed
signal settings_changed(settings: Dictionary)

const MIN_VOLUME_LINEAR := 0.001
const GameStateScript := preload("res://scripts/core/game_state.gd")

var _settings := {
	"master_volume": 1.0,
	"fullscreen": false,
}
var _save_manager: Node

func _ready() -> void:
	%BackButton.pressed.connect(_on_back_pressed)
	%VolumeSlider.value_changed.connect(_on_volume_changed)
	%WindowModeButton.toggled.connect(_on_window_mode_toggled)

	_settings.fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_sync_controls()

func set_save_manager(save_manager: Node) -> void:
	_save_manager = save_manager
	_load_persisted_settings()
	_apply_all_settings()
	_sync_controls()

func set_master_volume(value: float) -> void:
	_settings.master_volume = clampf(value, 0.0, 1.0)
	_apply_master_volume(float(_settings.master_volume))
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_fullscreen_enabled(enabled: bool) -> void:
	_settings.fullscreen = enabled
	_apply_fullscreen_enabled(enabled)
	_persist_settings()
	settings_changed.emit(get_settings_state())

func get_settings_state() -> Dictionary:
	return _settings.duplicate()


func _on_back_pressed() -> void:
	closed.emit()


func _on_volume_changed(value: float) -> void:
	set_master_volume(value)


func _on_window_mode_toggled(toggled_on: bool) -> void:
	set_fullscreen_enabled(toggled_on)

func _load_persisted_settings() -> void:
	if _save_manager == null or not _save_manager.has_method("load_game"):
		return
	var state := _save_manager.call("load_game") as GameStateScript
	if state == null:
		return
	var loaded_settings := state.settings
	if loaded_settings.has("master_volume"):
		_settings.master_volume = clampf(float(loaded_settings.master_volume), 0.0, 1.0)
	if loaded_settings.has("fullscreen"):
		_settings.fullscreen = bool(loaded_settings.fullscreen)

func _persist_settings() -> void:
	if _save_manager == null or not _save_manager.has_method("save_game"):
		return
	if _save_manager.has_method("has_save") and not bool(_save_manager.call("has_save")):
		return

	var state := _save_manager.call("load_game") as GameStateScript
	if state == null:
		return
	state.settings = get_settings_state()
	_save_manager.call("save_game", state)

func _apply_all_settings() -> void:
	_apply_master_volume(float(_settings.master_volume))
	_apply_fullscreen_enabled(bool(_settings.fullscreen))

func _apply_master_volume(value: float) -> void:
	var master_bus_index := AudioServer.get_bus_index("Master")
	var volume_db := -80.0 if value <= 0.0 else linear_to_db(maxf(value, MIN_VOLUME_LINEAR))
	AudioServer.set_bus_volume_db(master_bus_index, volume_db)

func _apply_fullscreen_enabled(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _sync_controls() -> void:
	if not is_node_ready():
		return
	%VolumeSlider.set_value_no_signal(float(_settings.master_volume))
	%WindowModeButton.set_pressed_no_signal(bool(_settings.fullscreen))
