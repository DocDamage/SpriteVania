extends RefCounted
class_name GlobalSettings

const DEFAULT_SETTINGS_PATH := "user://black_keep_settings.json"
const COLORBLIND_MODES := ["Off", "Deuteranopia", "Protanopia", "Tritanopia"]

static func default_settings() -> Dictionary:
	return {
		"master_volume": 1.0,
		"music_volume": 1.0,
		"sfx_volume": 1.0,
		"fullscreen": false,
		"vsync": false,
		"screen_shake": 1.0,
		"text_speed": 0.65,
		"reduced_motion": false,
		"high_contrast": false,
		"large_text": false,
		"colorblind_mode": "Off",
	}

static func has_settings(path := DEFAULT_SETTINGS_PATH) -> bool:
	return FileAccess.file_exists(path)

static func load_settings(path := DEFAULT_SETTINGS_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return default_settings()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open global settings file for reading: %s" % path)
		return default_settings()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_error("Global settings file is corrupt: %s" % path)
		return default_settings()
	return normalize_settings(parsed)

static func save_settings(settings: Dictionary, path := DEFAULT_SETTINGS_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open global settings file for writing: %s" % path)
		return false
	file.store_string(JSON.stringify(normalize_settings(settings)))
	return true

static func normalize_settings(settings: Dictionary) -> Dictionary:
	var normalized := default_settings()
	for key: String in normalized.keys():
		if not settings.has(key):
			continue
		var value: Variant = settings[key]
		match key:
			"master_volume", "music_volume", "sfx_volume", "screen_shake":
				normalized[key] = clampf(float(value), 0.0, 1.0)
			"text_speed":
				normalized[key] = clampf(float(value), 0.25, 1.0)
			"colorblind_mode":
				normalized[key] = str(value) if COLORBLIND_MODES.has(str(value)) else "Off"
			_:
				normalized[key] = _normalized_bool(value)
	return normalized

static func _normalized_bool(value: Variant) -> bool:
	match typeof(value):
		TYPE_BOOL:
			return value
		TYPE_INT, TYPE_FLOAT:
			return float(value) != 0.0
		TYPE_STRING, TYPE_STRING_NAME:
			var normalized := str(value).strip_edges().to_lower()
			if ["false", "0", "off", "no", "disabled"].has(normalized):
				return false
			if ["true", "1", "on", "yes", "enabled"].has(normalized):
				return true
		TYPE_NIL:
			return false
	return true
