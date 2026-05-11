extends Node2D
class_name PlayerFamiliar

signal stats_changed(status: Dictionary)

@export var follow_offset := Vector2(-28, -30)
@export var follow_speed := 8.0
@export var max_follow_distance := 180.0
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
const VISUAL_STATES := {
	"spark": {
		"glow_color": Color(0.35, 0.85, 1.0, 0.72),
		"core_color": Color(0.95, 1.0, 1.0, 1.0),
		"tail_color": Color(0.18, 0.72, 0.88, 0.5),
		"ring_color": Color(0.35, 0.85, 1.0, 0.0),
		"body_color": Color(0.82, 0.92, 1.0, 0.92),
		"glow_scale": Vector2(0.85, 0.85),
		"core_scale": Vector2(0.52, 0.52),
		"body_scale": Vector2(0.16, 0.16),
		"tail_scale": Vector2(0.35, 0.2),
		"tail_offset": Vector2(-8, 5),
		"ring_visible": false,
	},
	"wisp": {
		"glow_color": Color(0.3, 0.95, 1.0, 0.82),
		"core_color": Color(0.88, 1.0, 1.0, 1.0),
		"tail_color": Color(0.1, 0.8, 0.95, 0.58),
		"ring_color": Color(0.38, 0.95, 1.0, 0.28),
		"body_color": Color(0.92, 1.0, 1.0, 1.0),
		"glow_scale": Vector2(1.0, 1.0),
		"core_scale": Vector2(0.58, 0.58),
		"body_scale": Vector2(0.18, 0.18),
		"tail_scale": Vector2(0.42, 0.24),
		"tail_offset": Vector2(-9, 6),
		"ring_visible": true,
	},
	"sprite": {
		"glow_color": Color(0.56, 1.0, 0.72, 0.86),
		"core_color": Color(0.96, 1.0, 0.7, 1.0),
		"tail_color": Color(0.22, 0.9, 0.64, 0.62),
		"ring_color": Color(0.75, 1.0, 0.46, 0.34),
		"body_color": Color(0.9, 1.0, 0.84, 1.0),
		"glow_scale": Vector2(1.16, 1.16),
		"core_scale": Vector2(0.66, 0.66),
		"body_scale": Vector2(0.2, 0.2),
		"tail_scale": Vector2(0.5, 0.28),
		"tail_offset": Vector2(-10, 7),
		"ring_visible": true,
	},
	"guardian": {
		"glow_color": Color(1.0, 0.82, 0.42, 0.9),
		"core_color": Color(1.0, 0.97, 0.52, 1.0),
		"tail_color": Color(1.0, 0.58, 0.28, 0.66),
		"ring_color": Color(1.0, 0.77, 0.24, 0.46),
		"body_color": Color(1.0, 0.94, 0.72, 1.0),
		"glow_scale": Vector2(1.32, 1.32),
		"core_scale": Vector2(0.76, 0.76),
		"body_scale": Vector2(0.22, 0.22),
		"tail_scale": Vector2(0.58, 0.32),
		"tail_offset": Vector2(-11, 8),
		"ring_visible": true,
	},
}

var target: Node2D
var level := 1
var xp := 0
var evolution_stage := "spark"
var ability_points := 0
var ability_levels: Dictionary = {}
var _bob_time := 0.0
var _attack_cooldown_remaining := 0.0
@onready var _glow_sprite := get_node_or_null("Glow") as Sprite2D
@onready var _core_sprite := get_node_or_null("Core") as Sprite2D
@onready var _tail_sprite := get_node_or_null("Tail") as Sprite2D
@onready var _stage_ring := get_node_or_null("StageRing") as Sprite2D
@onready var _body_sprite := get_node_or_null("BodySprite") as Sprite2D

func _ready() -> void:
	top_level = true
	target = get_parent() as Node2D
	if target != null:
		global_position = target.global_position + follow_offset
	_sync_visuals()

func _physics_process(delta: float) -> void:
	_attack_cooldown_remaining = maxf(0.0, _attack_cooldown_remaining - delta)
	_animate_visuals(delta)
	if target == null or not is_instance_valid(target):
		return

	_bob_time += delta * bob_speed
	var bob := Vector2(0.0, sin(_bob_time) * bob_amplitude)
	var desired_position := target.global_position + _oriented_offset() + bob
	if global_position.distance_to(target.global_position) > max_follow_distance:
		global_position = target.global_position + _oriented_offset()
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

func effective_attack_range() -> float:
	var stage_bonus := 0.0
	match evolution_stage:
		"wisp":
			stage_bonus = 12.0
		"sprite":
			stage_bonus = 28.0
		"guardian":
			stage_bonus = 44.0
	return attack_range + stage_bonus

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
	level = clampi(int(data.get("level", 1)), 1, XP_THRESHOLDS.size())
	xp = max(0, int(data.get("xp", 0)))
	ability_points = max(0, int(data.get("ability_points", 0)))
	var loaded_abilities: Variant = data.get("ability_levels", {})
	ability_levels = {}
	if loaded_abilities is Dictionary:
		for ability_id: String in KNOWN_ABILITIES:
			ability_levels[ability_id] = max(0, int(loaded_abilities.get(ability_id, 0)))
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

func get_visual_status() -> Dictionary:
	_resolve_visual_nodes()
	return {
		"stage": evolution_stage,
		"glow_scale_x": _glow_sprite.scale.x if _glow_sprite != null else 0.0,
		"ring_visible": _stage_ring.visible if _stage_ring != null else false,
		"core_color": str(_core_sprite.modulate) if _core_sprite != null else "",
		"body_texture": _body_sprite.texture.resource_path if _body_sprite != null and _body_sprite.texture != null else "",
	}

func _oriented_offset() -> Vector2:
	var facing := 1.0
	if target != null and is_instance_valid(target) and "facing_direction" in target:
		facing = float(target.get("facing_direction"))
	if is_zero_approx(facing):
		facing = 1.0
	return Vector2(-absf(follow_offset.x) * signf(facing), follow_offset.y)

func _find_nearest_enemy() -> Node2D:
	if not is_inside_tree():
		return null
	var nearest: Node2D = null
	var nearest_distance := INF
	var reach := effective_attack_range()
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node2D
		if enemy == null or not is_instance_valid(enemy) or not enemy.is_inside_tree() or enemy.is_queued_for_deletion() or not enemy.has_method("take_damage"):
			continue
		var distance := global_position.distance_to(enemy.global_position)
		if distance <= reach and distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest

func _spawn_attack_flash(target_position: Vector2) -> void:
	if not is_inside_tree():
		return
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
	if parent == null or not is_instance_valid(parent):
		bolt.queue_free()
		return
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
	_sync_visuals()

func _grant_ability_level(ability_id: String) -> void:
	ability_levels[ability_id] = int(ability_levels.get(ability_id, 0)) + 1
	stats_changed.emit(get_status())

func _sync_visuals() -> void:
	_resolve_visual_nodes()
	var state := VISUAL_STATES.get(evolution_stage, VISUAL_STATES["spark"]) as Dictionary
	if _glow_sprite != null:
		_glow_sprite.modulate = state["glow_color"]
		_glow_sprite.scale = state["glow_scale"]
	if _core_sprite != null:
		_core_sprite.modulate = state["core_color"]
		_core_sprite.scale = state["core_scale"]
	if _tail_sprite != null:
		_tail_sprite.modulate = state["tail_color"]
		_tail_sprite.scale = state["tail_scale"]
		_tail_sprite.position = state["tail_offset"]
	if _body_sprite != null:
		_body_sprite.modulate = state["body_color"]
		_body_sprite.scale = state["body_scale"]
	if _stage_ring != null:
		_stage_ring.modulate = state["ring_color"]
		_stage_ring.visible = bool(state["ring_visible"])
		_stage_ring.scale = Vector2(1.0, 1.0) * maxf(float(state["glow_scale"].x), float(state["glow_scale"].y))

func _animate_visuals(delta: float) -> void:
	if _tail_sprite != null:
		_tail_sprite.rotation = sin(_bob_time * 0.8) * 0.12
	if _stage_ring != null and _stage_ring.visible:
		_stage_ring.rotation += delta * 0.7
	if _body_sprite != null:
		_body_sprite.rotation = sin(_bob_time * 0.55) * 0.035

func _resolve_visual_nodes() -> void:
	if _glow_sprite == null:
		_glow_sprite = get_node_or_null("Glow") as Sprite2D
	if _core_sprite == null:
		_core_sprite = get_node_or_null("Core") as Sprite2D
	if _tail_sprite == null:
		_tail_sprite = get_node_or_null("Tail") as Sprite2D
	if _stage_ring == null:
		_stage_ring = get_node_or_null("StageRing") as Sprite2D
	if _body_sprite == null:
		_body_sprite = get_node_or_null("BodySprite") as Sprite2D
