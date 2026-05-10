extends "res://scripts/enemies/enemy.gd"
class_name SwampMiniBoss

@export var leap_cooldown: float = 2.0
@export var leap_horizontal_speed: float = 120.0
@export var leap_vertical_speed: float = 260.0
@export var telegraph_duration: float = 0.45
@export var slam_duration: float = 0.4
@export var slam_downward_speed: float = 340.0
@export var slam_range: float = 72.0

var cooldown_remaining := 0.0
var pattern_state := "idle"
var is_slam_active := false
var _pattern_index := 0
var _pattern_timer := 0.0
var _pending_pattern := "leap"
var _slam_hit_targets: Dictionary = {}

func _ready() -> void:
	super()
	xp_reward = 150

func _physics_process(delta: float) -> void:
	_update_pattern(delta)
	velocity.y += 700.0 * delta
	move_and_slide()
	if is_slam_active:
		_try_apply_slam_damage()

func _update_pattern(delta: float) -> void:
	if pattern_state == "idle":
		cooldown_remaining -= delta
		if cooldown_remaining <= 0.0:
			_begin_next_pattern()
		return

	if pattern_state == "telegraph_leap" or pattern_state == "telegraph_slam":
		_pattern_timer -= delta
		velocity.x = 0.0
		if _pattern_timer <= 0.0:
			_finish_telegraph()
		return

	if pattern_state == "slam":
		_pattern_timer -= delta
		if _pattern_timer <= 0.0:
			_complete_pattern()

func _start_leap(horizontal_direction: float) -> void:
	pattern_state = "leap"
	is_slam_active = false
	velocity.y = -leap_vertical_speed
	velocity.x = leap_horizontal_speed * sign(horizontal_direction)
	cooldown_remaining = leap_cooldown

func _begin_next_pattern() -> void:
	if _pattern_index % 2 == 0:
		_pending_pattern = "leap"
		pattern_state = "telegraph_leap"
	else:
		_pending_pattern = "slam"
		pattern_state = "telegraph_slam"
	_pattern_index += 1
	_pattern_timer = telegraph_duration
	velocity.x = 0.0
	is_slam_active = false

func _finish_telegraph() -> void:
	if _pending_pattern == "slam":
		_start_slam()
	else:
		_start_leap(_target_horizontal_direction())

func _start_slam() -> void:
	pattern_state = "slam"
	is_slam_active = true
	_slam_hit_targets.clear()
	_pattern_timer = slam_duration
	velocity.x = 0.0
	velocity.y = slam_downward_speed

func _complete_pattern() -> void:
	pattern_state = "idle"
	is_slam_active = false
	_slam_hit_targets.clear()
	cooldown_remaining = leap_cooldown
	velocity.x = 0.0

func _target_horizontal_direction() -> float:
	var nearest: Node2D = null
	var nearest_distance := INF
	for node: Node in get_tree().get_nodes_in_group("player"):
		var candidate := node as Node2D
		if candidate == null:
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	if nearest == null:
		return -1.0
	var horizontal_direction: float = sign(nearest.global_position.x - global_position.x)
	if is_zero_approx(horizontal_direction):
		return -1.0
	return horizontal_direction

func _try_apply_slam_damage() -> void:
	for node: Node in get_tree().get_nodes_in_group("player"):
		var target := node as Node2D
		if target == null or not _is_damageable_player(target):
			continue
		var target_id := target.get_instance_id()
		if _slam_hit_targets.has(target_id):
			continue
		if global_position.distance_to(target.global_position) > slam_range:
			continue
		target.call("take_damage", damage)
		if target.has_method("apply_knockback"):
			target.call("apply_knockback", global_position)
		_slam_hit_targets[target_id] = true
