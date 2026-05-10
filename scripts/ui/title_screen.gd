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
const MOON_LAYER_OVERSCAN_PIXELS := 48.0
const STAR_COUNT := 34
const RAIN_COUNT := 30
const PETAL_COUNT := 14
const FOG_COUNT := 6
const WEATHER_BASE_SIZE := Vector2(960.0, 540.0)

@export var parallax_enabled := true

@onready var background: TextureRect = $Background
@onready var moon_sky_layer: TextureRect = $MoonSkyLayer
@onready var weather_layer: Control = $WeatherLayer
@onready var polish_layer: Control = $PolishLayer
@onready var continue_button: Button = %ContinueButton

var _title_time := 0.0
var _title_parallax_offset := Vector2.ZERO
var _rain_particles: Array[ColorRect] = []
var _rain_base_positions: Array[Vector2] = []
var _star_particles: Array[ColorRect] = []
var _petal_particles: Array[ColorRect] = []
var _petal_base_positions: Array[Vector2] = []
var _fog_particles: Array[ColorRect] = []
var _fog_base_positions: Array[Vector2] = []


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
	_build_weather_layers()
	_build_polish_layers()
	_sync_build_label()
	_apply_title_parallax()


func _process(delta: float) -> void:
	if not parallax_enabled:
		return
	_title_time += delta
	_apply_title_parallax()


func get_title_parallax_offset() -> Vector2:
	return _title_parallax_offset


func get_title_weather_sample_position() -> Vector2:
	if _rain_particles.is_empty():
		return Vector2.ZERO
	return _rain_particles[0].position


func get_title_polish_sample_position() -> Vector2:
	if _petal_particles.is_empty():
		return Vector2.ZERO
	return _petal_particles[0].position


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

	var moon_offset := (_title_parallax_offset * 0.35).round()
	moon_sky_layer.offset_left = -MOON_LAYER_OVERSCAN_PIXELS + moon_offset.x
	moon_sky_layer.offset_top = -MOON_LAYER_OVERSCAN_PIXELS + moon_offset.y
	moon_sky_layer.offset_right = MOON_LAYER_OVERSCAN_PIXELS + moon_offset.x
	moon_sky_layer.offset_bottom = MOON_LAYER_OVERSCAN_PIXELS + moon_offset.y
	_update_weather_motion()
	_update_polish_motion()


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


func _build_weather_layers() -> void:
	_rain_particles.clear()
	_rain_base_positions.clear()
	_star_particles.clear()
	for child: Node in weather_layer.get_children():
		child.queue_free()

	var star_layer := Control.new()
	star_layer.name = "StarLayer"
	star_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	weather_layer.add_child(star_layer)

	var rain_layer := Control.new()
	rain_layer.name = "RainLayer"
	rain_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rain_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	weather_layer.add_child(rain_layer)

	for index in STAR_COUNT:
		var star := ColorRect.new()
		star.name = "Star%02d" % index
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star.size = Vector2(2.0 if index % 7 == 0 else 1.0, 1.0)
		star.position = Vector2(
			float((index * 83 + 41) % int(WEATHER_BASE_SIZE.x)),
			float((index * 47 + 24) % 230 + 12)
		)
		star.color = Color(0.78, 0.9, 1.0, 0.28 + float(index % 4) * 0.07)
		star_layer.add_child(star)
		_star_particles.append(star)

	for index in RAIN_COUNT:
		var rain := ColorRect.new()
		rain.name = "Rain%02d" % index
		rain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rain.size = Vector2(1.0, 18.0 + float(index % 5) * 3.0)
		rain.rotation = deg_to_rad(-13.0)
		rain.color = Color(0.52, 0.72, 1.0, 0.12)
		var base_position := Vector2(
			float((index * 97 + 19) % int(WEATHER_BASE_SIZE.x + 160.0)) - 80.0,
			float((index * 53 + 31) % int(WEATHER_BASE_SIZE.y + 160.0)) - 80.0
		)
		rain.position = base_position
		rain_layer.add_child(rain)
		_rain_particles.append(rain)
		_rain_base_positions.append(base_position)


func _build_polish_layers() -> void:
	_petal_particles.clear()
	_petal_base_positions.clear()
	_fog_particles.clear()
	_fog_base_positions.clear()
	for child: Node in polish_layer.get_children():
		child.queue_free()

	var fog_layer := Control.new()
	fog_layer.name = "FogLayer"
	fog_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fog_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	polish_layer.add_child(fog_layer)

	var petal_layer := Control.new()
	petal_layer.name = "PetalLayer"
	petal_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	petal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	polish_layer.add_child(petal_layer)

	for index in FOG_COUNT:
		var fog := ColorRect.new()
		fog.name = "Fog%02d" % index
		fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fog.size = Vector2(190.0 + float(index % 3) * 34.0, 16.0 + float(index % 2) * 8.0)
		fog.color = Color(0.48, 0.56, 0.68, 0.055)
		var base_position := Vector2(
			float((index * 173 + 45) % int(WEATHER_BASE_SIZE.x)),
			WEATHER_BASE_SIZE.y - 128.0 + float((index * 31) % 96)
		)
		fog.position = base_position
		fog_layer.add_child(fog)
		_fog_particles.append(fog)
		_fog_base_positions.append(base_position)

	for index in PETAL_COUNT:
		var petal := ColorRect.new()
		petal.name = "Petal%02d" % index
		petal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		petal.size = Vector2(3.0, 2.0)
		petal.rotation = deg_to_rad(float((index * 37) % 160) - 80.0)
		petal.color = Color(1.0, 0.42, 0.55, 0.22)
		var base_position := Vector2(
			float((index * 89 + 120) % int(WEATHER_BASE_SIZE.x + 180.0)) - 90.0,
			float((index * 71 + 30) % int(WEATHER_BASE_SIZE.y + 120.0)) - 60.0
		)
		petal.position = base_position
		petal_layer.add_child(petal)
		_petal_particles.append(petal)
		_petal_base_positions.append(base_position)


func _update_weather_motion() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = WEATHER_BASE_SIZE

	for index in _star_particles.size():
		var star := _star_particles[index]
		var pulse := 0.7 + sin(_title_time * 1.35 + float(index) * 0.61) * 0.3
		star.modulate = Color(1.0, 1.0, 1.0, pulse)

	var wrap_x := viewport_size.x + 180.0
	var wrap_y := viewport_size.y + 180.0
	var rain_travel := Vector2(_title_time * -34.0, _title_time * 96.0)
	for index in _rain_particles.size():
		var position := _rain_base_positions[index] + rain_travel
		position.x = fposmod(position.x + 90.0, wrap_x) - 90.0
		position.y = fposmod(position.y + 90.0, wrap_y) - 90.0
		_rain_particles[index].position = position.round()


func _update_polish_motion() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = WEATHER_BASE_SIZE

	var wrap_x := viewport_size.x + 180.0
	var wrap_y := viewport_size.y + 140.0
	for index in _petal_particles.size():
		var drift := Vector2(_title_time * -18.0, _title_time * 32.0)
		var sway := sin(_title_time * 1.4 + float(index) * 0.8) * 18.0
		var position := _petal_base_positions[index] + drift + Vector2(sway, 0.0)
		position.x = fposmod(position.x + 90.0, wrap_x) - 90.0
		position.y = fposmod(position.y + 70.0, wrap_y) - 70.0
		_petal_particles[index].position = position.round()

	for index in _fog_particles.size():
		var position := _fog_base_positions[index] + Vector2(_title_time * (8.0 + float(index)), sin(_title_time * 0.6 + float(index)) * 5.0)
		position.x = fposmod(position.x, viewport_size.x + 260.0) - 130.0
		_fog_particles[index].position = position.round()


func _sync_build_label() -> void:
	var version := str(ProjectSettings.get_setting("application/config/version", "dev"))
	%VersionLabel.text = "build %s" % version
