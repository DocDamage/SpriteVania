extends Control
class_name SettingsMenu

signal closed
signal settings_changed(settings: Dictionary)

const MIN_VOLUME_LINEAR := 0.001
const GameStateScript := preload("res://scripts/core/game_state.gd")
const REBINDABLE_ACTIONS := [
	"move_left",
	"move_right",
	"jump",
	"dash",
	"attack",
	"special_attack",
	"class_action",
	"interact",
	"pause",
]

var _settings := {
	"master_volume": 1.0,
	"fullscreen": false,
	"reduced_motion": false,
	"high_contrast": false,
}
var _save_manager: Node
var _default_action_events: Dictionary = {}

func _ready() -> void:
	_capture_default_action_events()
	%BackButton.pressed.connect(_on_back_pressed)
	%VolumeSlider.value_changed.connect(_on_volume_changed)
	%WindowModeButton.toggled.connect(_on_window_mode_toggled)
	%ReducedMotionButton.toggled.connect(_on_reduced_motion_toggled)
	%HighContrastButton.toggled.connect(_on_high_contrast_toggled)

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

func select_settings_tab(tab_name: String) -> void:
	if not is_node_ready():
		await ready
	var tabs := %SettingsTabs as TabContainer
	for index: int in tabs.get_tab_count():
		if tabs.get_tab_title(index) == tab_name:
			tabs.current_tab = index
			return

func get_selected_settings_tab() -> String:
	if not is_node_ready():
		return ""
	var tabs := %SettingsTabs as TabContainer
	return tabs.get_tab_title(tabs.current_tab)

func get_action_binding_label(action_name: String) -> String:
	var events := InputMap.action_get_events(action_name)
	var labels: Array[String] = []
	for event: InputEvent in events:
		labels.append(event.as_text().trim_suffix(" (Physical)"))
	return ", ".join(labels)

func rebind_action_to_key(action_name: String, keycode: Key) -> bool:
	if not InputMap.has_action(action_name):
		return false

	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	_sync_binding_labels()
	settings_changed.emit(get_settings_state())
	return true

func reset_action_binding(action_name: String) -> bool:
	if not _default_action_events.has(action_name):
		return false

	InputMap.action_erase_events(action_name)
	for event: InputEvent in _default_action_events[action_name]:
		InputMap.action_add_event(action_name, event)
	_sync_binding_labels()
	settings_changed.emit(get_settings_state())
	return true

func _capture_default_action_events() -> void:
	for action_name: String in REBINDABLE_ACTIONS:
		if InputMap.has_action(action_name):
			_default_action_events[action_name] = InputMap.action_get_events(action_name)

func _on_back_pressed() -> void:
	closed.emit()


func _on_volume_changed(value: float) -> void:
	set_master_volume(value)


func _on_window_mode_toggled(toggled_on: bool) -> void:
	set_fullscreen_enabled(toggled_on)

func _on_reduced_motion_toggled(toggled_on: bool) -> void:
	_settings.reduced_motion = toggled_on
	_persist_settings()
	settings_changed.emit(get_settings_state())

func _on_high_contrast_toggled(toggled_on: bool) -> void:
	_settings.high_contrast = toggled_on
	_persist_settings()
	settings_changed.emit(get_settings_state())

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
	if loaded_settings.has("reduced_motion"):
		_settings.reduced_motion = bool(loaded_settings.reduced_motion)
	if loaded_settings.has("high_contrast"):
		_settings.high_contrast = bool(loaded_settings.high_contrast)

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
	%ReducedMotionButton.set_pressed_no_signal(bool(_settings.reduced_motion))
	%HighContrastButton.set_pressed_no_signal(bool(_settings.high_contrast))
	_sync_binding_labels()

func _sync_binding_labels() -> void:
	if not is_node_ready():
		return
	for action_name: String in REBINDABLE_ACTIONS:
		var label := get_node_or_null("%%%sBindingLabel" % _action_label_prefix(action_name)) as Label
		if label != null:
			label.text = "%s: %s" % [_format_action_name(action_name), get_action_binding_label(action_name)]

func _action_label_prefix(action_name: String) -> String:
	var words := action_name.split("_", false)
	for index: int in words.size():
		words[index] = words[index].capitalize()
	return "".join(words)

func _format_action_name(action_name: String) -> String:
	return " ".join(action_name.split("_", false)).capitalize()
