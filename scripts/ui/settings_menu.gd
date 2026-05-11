extends Control
class_name SettingsMenu

signal closed
signal settings_changed(settings: Dictionary)

const MIN_VOLUME_LINEAR := 0.001
const GameStateScript := preload("res://scripts/core/game_state.gd")
const GlobalSettingsScript := preload("res://scripts/core/global_settings.gd")
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
const COLORBLIND_MODES := GlobalSettingsScript.COLORBLIND_MODES

var _settings := GlobalSettingsScript.default_settings()
var _save_manager: Node
var _default_action_events: Dictionary = {}
var _global_settings_path := GlobalSettingsScript.DEFAULT_SETTINGS_PATH

func _ready() -> void:
	_capture_default_action_events()
	_populate_colorblind_modes()
	%BackButton.pressed.connect(_on_back_pressed)
	%VolumeSlider.value_changed.connect(_on_volume_changed)
	%MusicVolumeSlider.value_changed.connect(_on_music_volume_changed)
	%SfxVolumeSlider.value_changed.connect(_on_sfx_volume_changed)
	%WindowModeButton.toggled.connect(_on_window_mode_toggled)
	%VsyncButton.toggled.connect(_on_vsync_toggled)
	%ScreenShakeSlider.value_changed.connect(_on_screen_shake_changed)
	%TextSpeedSlider.value_changed.connect(_on_text_speed_changed)
	%ReducedMotionButton.toggled.connect(_on_reduced_motion_toggled)
	%HighContrastButton.toggled.connect(_on_high_contrast_toggled)
	%LargeTextButton.toggled.connect(_on_large_text_toggled)
	%ColorblindModeButton.item_selected.connect(_on_colorblind_mode_selected)
	%ResetAllBindingsButton.pressed.connect(reset_all_bindings)
	%ResetDefaultsButton.pressed.connect(reset_settings_to_defaults)

	_settings.fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_settings.vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	_sync_controls()

func set_save_manager(save_manager: Node) -> void:
	_save_manager = save_manager
	_load_persisted_settings()
	_apply_all_settings()
	_sync_controls()

func set_global_settings_path(path: String) -> void:
	_global_settings_path = path
	if is_node_ready():
		_load_persisted_settings()
		_apply_all_settings()
		_sync_controls()

func set_master_volume(value: float) -> void:
	_settings.master_volume = clampf(value, 0.0, 1.0)
	_apply_bus_volume("Master", float(_settings.master_volume))
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_music_volume(value: float) -> void:
	_settings.music_volume = clampf(value, 0.0, 1.0)
	_apply_bus_volume("Music", float(_settings.music_volume))
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_sfx_volume(value: float) -> void:
	_settings.sfx_volume = clampf(value, 0.0, 1.0)
	_apply_bus_volume("SFX", float(_settings.sfx_volume))
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_fullscreen_enabled(enabled: bool) -> void:
	_settings.fullscreen = enabled
	_apply_fullscreen_enabled(enabled)
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_vsync_enabled(enabled: bool) -> void:
	_settings.vsync = enabled
	_apply_vsync_enabled(enabled)
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_screen_shake(value: float) -> void:
	_settings.screen_shake = clampf(value, 0.0, 1.0)
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_text_speed(value: float) -> void:
	_settings.text_speed = clampf(value, 0.25, 1.0)
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_reduced_motion_enabled(enabled: bool) -> void:
	_settings.reduced_motion = enabled
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_high_contrast_enabled(enabled: bool) -> void:
	_settings.high_contrast = enabled
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_large_text_enabled(enabled: bool) -> void:
	_settings.large_text = enabled
	_persist_settings()
	settings_changed.emit(get_settings_state())

func set_colorblind_mode(mode: String) -> void:
	_settings.colorblind_mode = mode if COLORBLIND_MODES.has(mode) else "Off"
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
	tabs.current_tab = 0

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

func reset_all_bindings() -> bool:
	for action_name: String in REBINDABLE_ACTIONS:
		if not _default_action_events.has(action_name):
			continue
		InputMap.action_erase_events(action_name)
		for event: InputEvent in _default_action_events[action_name]:
			InputMap.action_add_event(action_name, event)
	_sync_binding_labels()
	settings_changed.emit(get_settings_state())
	return true

func reset_settings_to_defaults() -> void:
	_settings = GlobalSettingsScript.default_settings()
	_apply_all_settings()
	_sync_controls()
	_persist_settings()
	settings_changed.emit(get_settings_state())

func _capture_default_action_events() -> void:
	for action_name: String in REBINDABLE_ACTIONS:
		if InputMap.has_action(action_name):
			_default_action_events[action_name] = InputMap.action_get_events(action_name)

func _on_back_pressed() -> void:
	closed.emit()


func _on_volume_changed(value: float) -> void:
	set_master_volume(value)


func _on_music_volume_changed(value: float) -> void:
	set_music_volume(value)


func _on_sfx_volume_changed(value: float) -> void:
	set_sfx_volume(value)


func _on_window_mode_toggled(toggled_on: bool) -> void:
	set_fullscreen_enabled(toggled_on)

func _on_vsync_toggled(toggled_on: bool) -> void:
	set_vsync_enabled(toggled_on)

func _on_screen_shake_changed(value: float) -> void:
	set_screen_shake(value)

func _on_text_speed_changed(value: float) -> void:
	set_text_speed(value)

func _on_reduced_motion_toggled(toggled_on: bool) -> void:
	set_reduced_motion_enabled(toggled_on)

func _on_high_contrast_toggled(toggled_on: bool) -> void:
	set_high_contrast_enabled(toggled_on)

func _on_large_text_toggled(toggled_on: bool) -> void:
	set_large_text_enabled(toggled_on)

func _on_colorblind_mode_selected(index: int) -> void:
	if index >= 0 and index < COLORBLIND_MODES.size():
		set_colorblind_mode(COLORBLIND_MODES[index])

func _load_persisted_settings() -> void:
	if GlobalSettingsScript.has_settings(_global_settings_path):
		_settings = GlobalSettingsScript.load_settings(_global_settings_path)
		return
	if _save_manager == null or not _save_manager.has_method("load_game"):
		return
	var state := _save_manager.call("load_game") as GameStateScript
	if state == null:
		return
	_settings = GlobalSettingsScript.normalize_settings(state.settings)

func _persist_settings() -> void:
	GlobalSettingsScript.save_settings(_settings, _global_settings_path)
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
	_apply_bus_volume("Master", float(_settings.master_volume))
	_apply_bus_volume("Music", float(_settings.music_volume))
	_apply_bus_volume("SFX", float(_settings.sfx_volume))
	_apply_fullscreen_enabled(bool(_settings.fullscreen))
	_apply_vsync_enabled(bool(_settings.vsync))

func _apply_bus_volume(bus_name: String, value: float) -> void:
	var master_bus_index := AudioServer.get_bus_index(bus_name)
	if master_bus_index < 0:
		return
	var volume_db := -80.0 if value <= 0.0 else linear_to_db(maxf(value, MIN_VOLUME_LINEAR))
	AudioServer.set_bus_volume_db(master_bus_index, volume_db)

func _apply_fullscreen_enabled(enabled: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)

func _apply_vsync_enabled(enabled: bool) -> void:
	var mode := DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)

func _sync_controls() -> void:
	if not is_node_ready():
		return
	%VolumeSlider.set_value_no_signal(float(_settings.master_volume))
	%MusicVolumeSlider.set_value_no_signal(float(_settings.music_volume))
	%SfxVolumeSlider.set_value_no_signal(float(_settings.sfx_volume))
	%WindowModeButton.set_pressed_no_signal(bool(_settings.fullscreen))
	%VsyncButton.set_pressed_no_signal(bool(_settings.vsync))
	%ScreenShakeSlider.set_value_no_signal(float(_settings.screen_shake))
	%TextSpeedSlider.set_value_no_signal(float(_settings.text_speed))
	%ReducedMotionButton.set_pressed_no_signal(bool(_settings.reduced_motion))
	%HighContrastButton.set_pressed_no_signal(bool(_settings.high_contrast))
	%LargeTextButton.set_pressed_no_signal(bool(_settings.large_text))
	%ColorblindModeButton.select(COLORBLIND_MODES.find(str(_settings.colorblind_mode)))
	_sync_binding_labels()

func _populate_colorblind_modes() -> void:
	var button := %ColorblindModeButton as OptionButton
	button.clear()
	for mode: String in COLORBLIND_MODES:
		button.add_item(mode)

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
