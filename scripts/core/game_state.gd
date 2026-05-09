extends RefCounted
class_name GameState

var selected_class: String = ""
var selected_sprite: String = ""
var current_area: String = ""
var current_room: String = ""
var checkpoint_id: String = ""
var checkpoint_position: Vector2 = Vector2.ZERO
var level: int = 1
var xp: int = 0
var skill_points: int = 0
var current_health: int = 0
var current_resource: int = 0
var learned_attack_skills: Array[String] = []
var traversal_unlocks: Array[String] = []
var defeated_bosses: Array[String] = []
var opened_shortcuts: Array[String] = []
var collected_pickups: Array[String] = []
var settings: Dictionary = {}

func to_dictionary() -> Dictionary:
	return {
		"selected_class": selected_class,
		"selected_sprite": selected_sprite,
		"current_area": current_area,
		"current_room": current_room,
		"checkpoint_id": checkpoint_id,
		"checkpoint_position": {
			"x": checkpoint_position.x,
			"y": checkpoint_position.y,
		},
		"level": level,
		"xp": xp,
		"skill_points": skill_points,
		"current_health": current_health,
		"current_resource": current_resource,
		"learned_attack_skills": learned_attack_skills,
		"traversal_unlocks": traversal_unlocks,
		"defeated_bosses": defeated_bosses,
		"opened_shortcuts": opened_shortcuts,
		"collected_pickups": collected_pickups,
		"settings": settings,
	}

static func from_dictionary(data: Dictionary):
	var state = (load("res://scripts/core/game_state.gd") as GDScript).new()
	state.selected_class = str(data.get("selected_class", ""))
	state.selected_sprite = str(data.get("selected_sprite", ""))
	state.current_area = str(data.get("current_area", ""))
	state.current_room = str(data.get("current_room", ""))
	state.checkpoint_id = str(data.get("checkpoint_id", ""))
	state.checkpoint_position = _vector2_from_dictionary(data.get("checkpoint_position", {}))
	state.level = int(data.get("level", 1))
	state.xp = int(data.get("xp", 0))
	state.skill_points = int(data.get("skill_points", 0))
	state.current_health = int(data.get("current_health", 0))
	state.current_resource = int(data.get("current_resource", 0))
	state.learned_attack_skills = _string_array(data.get("learned_attack_skills", []))
	state.traversal_unlocks = _string_array(data.get("traversal_unlocks", []))
	state.defeated_bosses = _string_array(data.get("defeated_bosses", []))
	state.opened_shortcuts = _string_array(data.get("opened_shortcuts", []))
	state.collected_pickups = _string_array(data.get("collected_pickups", []))
	var loaded_settings: Variant = data.get("settings", {})
	state.settings = loaded_settings if loaded_settings is Dictionary else {}
	return state

static func _vector2_from_dictionary(value: Variant) -> Vector2:
	if value is Dictionary:
		return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
	return Vector2.ZERO

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result
