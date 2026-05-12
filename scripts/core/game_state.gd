extends RefCounted
class_name GameState

const SAVE_VERSION := 1

var version: int = SAVE_VERSION
var selected_starter_id: String = ""
var player_name: String = ""
var selected_class: String = ""
var selected_sprite: String = ""
var character_appearance: Dictionary = {}
var character_recipe_id: String = ""
var character_recipe: Dictionary = {}
var character_creator_content_versions: Dictionary = {}
var character_spriteframes_path: String = ""
var current_area: String = ""
var current_room: String = ""
var checkpoint_id: String = ""
var checkpoint_room: String = ""
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
var completed_areas: Array[String] = []
var discovered_rooms: Array[String] = []
var familiar_state: Dictionary = {}
var party_roster: Dictionary = {}
var active_party_ids: Array[String] = []
var active_party_index: int = 0
var momentum: int = 100
var world_break_state: String = "pre_break"
var world_break_triggered: bool = false
var zone_states: Dictionary = {}
var settings: Dictionary = {}

func to_dictionary() -> Dictionary:
	return {
		"version": version,
		"selected_starter_id": selected_starter_id,
		"player_name": player_name,
		"selected_class": selected_class,
		"selected_sprite": selected_sprite,
		"character_appearance": character_appearance,
		"character_recipe_id": character_recipe_id,
		"character_recipe": character_recipe,
		"character_creator_content_versions": character_creator_content_versions,
		"character_spriteframes_path": character_spriteframes_path,
		"current_area": current_area,
		"current_room": current_room,
		"checkpoint_id": checkpoint_id,
		"checkpoint_room": checkpoint_room,
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
		"completed_areas": completed_areas,
		"discovered_rooms": discovered_rooms,
		"familiar_state": familiar_state,
		"party_roster": party_roster,
		"active_party_ids": active_party_ids,
		"active_party_index": active_party_index,
		"momentum": momentum,
		"world_break_state": world_break_state,
		"world_break_triggered": world_break_triggered,
		"zone_states": zone_states,
		"settings": settings,
	}

static func from_dictionary(data: Dictionary):
	var state = (load("res://scripts/core/game_state.gd") as GDScript).new()
	state.version = int(data.get("version", SAVE_VERSION))
	state.selected_starter_id = str(data.get("selected_starter_id", ""))
	state.player_name = str(data.get("player_name", ""))
	state.selected_class = str(data.get("selected_class", ""))
	state.selected_sprite = str(data.get("selected_sprite", ""))
	var loaded_character_appearance: Variant = data.get("character_appearance", {})
	state.character_appearance = loaded_character_appearance if loaded_character_appearance is Dictionary else {}
	state.character_recipe_id = str(data.get("character_recipe_id", ""))
	var loaded_character_recipe: Variant = data.get("character_recipe", {})
	state.character_recipe = loaded_character_recipe if loaded_character_recipe is Dictionary else {}
	var loaded_creator_versions: Variant = data.get("character_creator_content_versions", {})
	state.character_creator_content_versions = loaded_creator_versions if loaded_creator_versions is Dictionary else {}
	state.character_spriteframes_path = str(data.get("character_spriteframes_path", ""))
	state.current_area = str(data.get("current_area", ""))
	state.current_room = str(data.get("current_room", ""))
	state.checkpoint_id = str(data.get("checkpoint_id", ""))
	state.checkpoint_room = str(data.get("checkpoint_room", ""))
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
	state.completed_areas = _string_array(data.get("completed_areas", []))
	state.discovered_rooms = _string_array(data.get("discovered_rooms", []))
	var loaded_familiar_state: Variant = data.get("familiar_state", {})
	state.familiar_state = loaded_familiar_state if loaded_familiar_state is Dictionary else {}
	var loaded_party_roster: Variant = data.get("party_roster", {})
	state.party_roster = loaded_party_roster if loaded_party_roster is Dictionary else {}
	state.active_party_ids = _string_array(data.get("active_party_ids", []))
	state.active_party_index = int(data.get("active_party_index", 0))
	state.momentum = int(data.get("momentum", 100))
	state.world_break_state = _normalize_world_break_state(data.get("world_break_state", "pre_break"))
	state.world_break_triggered = bool(data.get("world_break_triggered", state.world_break_state != "pre_break"))
	var loaded_zone_states: Variant = data.get("zone_states", {})
	state.zone_states = loaded_zone_states if loaded_zone_states is Dictionary else {}
	var loaded_settings: Variant = data.get("settings", {})
	state.settings = loaded_settings if loaded_settings is Dictionary else {}
	return state

func mark_room_discovered(room_id: String) -> void:
	if room_id.is_empty() or discovered_rooms.has(room_id):
		return
	discovered_rooms.append(room_id)

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

static func _normalize_world_break_state(value: Variant) -> String:
	var state := str(value)
	if ["pre_break", "breaking", "post_break", "restoration"].has(state):
		return state
	return "pre_break"
