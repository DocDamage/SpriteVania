extends Node2D
class_name PlayerFamiliar

signal stats_changed(status: Dictionary)

@export var follow_offset := Vector2(-28, -30)
@export var follow_speed := 8.0
@export var bob_amplitude := 3.0
@export var bob_speed := 4.0
@export var attack_range := 96.0
@export var base_attack_damage := 4
@export var base_attack_cooldown := 1.1

const XP_THRESHOLDS := [0, 100, 260, 520, 880, 1320]
const EVOLUTION_LEVELS := {
	1: "spark",
	2: "wisp",
	4: "sprite",
	6: "guardian",
}
const KNOWN_ABILITIES := ["sting", "focus", "guard"]

var target: Node2D
var level := 1
var xp := 0
var evolution_stage := "spark"
var ability_points := 0
var ability_levels: Dictionary = {}
var _bob_time := 0.0
var _attack_cooldown_remaining := 0.0

func _ready() -> void:
	top_level = true
	target = get_parent() as Node2D
	if target != null:
		global_position = target.global_position + follow_offset

func _physics_process(delta: float) -> void:
	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)
	if target == null or not is_instance_valid(target):
		return

	_bob_time += delta * bob_speed
	var bob := Vector2(0.0, sin(_bob_time) * bob_amplitude)
	var desired_position := target.global_position + _oriented_offset() + bob
	var weight := clampf(follow_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(desired_position, weight)
	try_attack()

func gain_xp(amount: int) -> void:
	if amount <= 0:
		return
	xp += amount
	var next_level := _level_for_xp(xp)
	while level < next_level:
		level += 1
		ability_points += 1
	_update_evolution_stage()
	stats_changed.emit(get_status())

func upgrade_ability(ability_id: String) -> bool:
	if ability_points <= 0 or not KNOWN_ABILITIES.has(ability_id):
		return false
	ability_points -= 1
	_grant_ability_level(ability_id)
	return true

func grant_ability_upgrade(ability_id: String) -> bool:
	if not KNOWN_ABILITIES.has(ability_id):
		return false
	_grant_ability_level(ability_id)
	return true

func attack_damage() -> int:
	var stage_bonus := 0
	match evolution_stage:
		"wisp":
			stage_bonus = 1
		"sprite":
			stage_bonus = 3
		"guardian":
			stage_bonus = 6
	return base_attack_damage + level + stage_bonus + (int(ability_levels.get("sting", 0)) * 3)

func attack_cooldown() -> float:
	return maxf(0.35, base_attack_cooldown - (float(ability_levels.get("focus", 0)) * 0.12))

func reduce_incoming_damage(amount: int) -> int:
	var guard_reduction := int(ability_levels.get("guard", 0)) * 2
	return max(1, amount - guard_reduction)

func try_attack() -> bool:
	if _attack_cooldown_remaining > 0.0:
		return false
	var enemy := _find_nearest_enemy()
	if enemy == null:
		return false
	enemy.call("take_damage", attack_damage())
	_spawn_attack_flash(enemy.global_position)
	_attack_cooldown_remaining = attack_cooldown()
	return true

func to_dictionary() -> Dictionary:
	return {
		"level": level,
		"xp": xp,
		"evolution_stage": evolution_stage,
		"ability_points": ability_points,
		"ability_levels": ability_levels.duplicate(),
	}

func apply_state(data: Dictionary) -> void:
	level = max(1, int(data.get("level", 1)))
	xp = max(0, int(data.get("xp", 0)))
	ability_points = max(0, int(data.get("ability_points", 0)))
	var loaded_abilities: Variant = data.get("ability_levels", {})
	ability_levels = loaded_abilities.duplicate() if loaded_abilities is Dictionary else {}
	_update_evolution_stage()
	stats_changed.emit(get_status())

func get_status() -> Dictionary:
	return {
		"level": level,
		"xp": xp,
		"evolution_stage": evolution_stage,
		"ability_points": ability_points,
		"ability_levels": ability_levels.duplicate(),
	}

func _oriented_offset() -> Vector2:
	var facing := 1.0
	if "facing_direction" in target:
		facing = float(target.get("facing_direction"))
	return Vector2(-absf(follow_offset.x) * signf(facing), follow_offset.y)

func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := INF
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node2D
		if enemy == null or not enemy.has_method("take_damage"):
			continue
		var distance := global_position.distance_to(enemy.global_position)
		if distance <= attack_range and distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest

func _spawn_attack_flash(target_position: Vector2) -> void:
	var bolt_scene := load("res://scenes/player/FamiliarBolt.tscn") as PackedScene
	if bolt_scene == null:
		return
	var bolt := bolt_scene.instantiate() as Node2D
	if bolt == null:
		return
	bolt.global_position = target_position
	var parent := get_tree().current_scene
	if parent == null:
		parent = get_parent()
	parent.add_child(bolt)

func _level_for_xp(value: int) -> int:
	var resolved_level := 1
	for index: int in XP_THRESHOLDS.size():
		if value >= XP_THRESHOLDS[index]:
			resolved_level = index + 1
	return resolved_level

func _update_evolution_stage() -> void:
	evolution_stage = "spark"
	if level >= 6:
		evolution_stage = "guardian"
	elif level >= 4:
		evolution_stage = "sprite"
	elif level >= 2:
		evolution_stage = "wisp"

func _grant_ability_level(ability_id: String) -> void:
	ability_levels[ability_id] = int(ability_levels.get(ability_id, 0)) + 1
	stats_changed.emit(get_status())
