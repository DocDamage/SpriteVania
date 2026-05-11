extends "res://scripts/enemies/enemy.gd"
class_name Masakiro

@export var phase_two_health_ratio := 0.75
@export var phase_three_health_ratio := 0.35
@export var pattern_cooldown := 1.0
@export var slash_duration := 0.28
@export var slam_duration := 0.38
@export var slash_range := 76.0
@export var slam_range := 104.0

var phase := 1
var pattern_state := "idle"
var is_slash_active := false
var is_slam_active := false
var _pattern_index := 0
var _pattern_timer := 0.0
var _hit_targets: Dictionary = {}

func _ready() -> void:
	super()
	enemy_id = "masakiro" if enemy_id.is_empty() else enemy_id
	xp_reward = 250
	_update_phase()

func _physics_process(delta: float) -> void:
	_update_pattern(delta)
	move_and_slide()
	if is_slash_active or is_slam_active:
		_try_apply_pattern_damage()

func take_damage(amount: int) -> void:
	super.take_damage(amount)
	if not _is_dead:
		_update_phase()

func _update_phase() -> void:
	var health_ratio := float(current_health) / float(max(1, max_health))
	if health_ratio <= phase_three_health_ratio:
		phase = 3
	elif health_ratio <= phase_two_health_ratio:
		phase = 2
	else:
		phase = 1

func _update_pattern(delta: float) -> void:
	if pattern_state == "idle":
		_pattern_timer -= delta
		if _pattern_timer <= 0.0:
			_begin_next_pattern()
		return

	_pattern_timer -= delta
	if _pattern_timer <= 0.0:
		_complete_pattern()

func _begin_next_pattern() -> void:
	_hit_targets.clear()
	if phase >= 2 and _pattern_index % 2 == 1:
		_start_slam()
	else:
		_start_slash()
	_pattern_index += 1

func _start_slash() -> void:
	pattern_state = "slash"
	is_slash_active = true
	is_slam_active = false
	_pattern_timer = slash_duration
	velocity.x = 0.0

func _start_slam() -> void:
	pattern_state = "slam"
	is_slash_active = false
	is_slam_active = true
	_pattern_timer = slam_duration
	velocity.x = 0.0

func _complete_pattern() -> void:
	pattern_state = "idle"
	is_slash_active = false
	is_slam_active = false
	_hit_targets.clear()
	_pattern_timer = max(0.2, pattern_cooldown / float(phase))
	velocity.x = 0.0

func _try_apply_pattern_damage() -> void:
	var range := slam_range if is_slam_active else slash_range
	var amount := damage + (phase - 1) * 4
	for node: Node in get_tree().get_nodes_in_group("player"):
		var target := node as Node2D
		if target == null or not _is_damageable_player(target):
			continue
		var target_id := target.get_instance_id()
		if _hit_targets.has(target_id):
			continue
		if global_position.distance_to(target.global_position) > range:
			continue
		target.call("take_damage", amount)
		if target.has_method("apply_knockback"):
			target.call("apply_knockback", global_position, 170.0 + phase * 25.0)
		_hit_targets[target_id] = true
