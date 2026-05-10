extends "res://scripts/enemies/enemy.gd"
class_name SwampCrawler

@export var patrol_speed: float = 45.0
@export var patrol_left: float = -96.0
@export var patrol_right: float = 96.0
@export var aggro_range: float = 220.0
@export var attack_range: float = 48.0
@export var attack_duration: float = 0.35
@export var attack_recovery: float = 0.25

var direction := -1.0
var behavior_state := "patrol"
var is_attack_active := false
var _patrol_origin_x := 0.0
var _attack_timer := 0.0
var _recovery_timer := 0.0
var _target: Node2D
var _attack_hit_targets: Array[int] = []

func _ready() -> void:
	super()
	_patrol_origin_x = global_position.x

func _physics_process(delta: float) -> void:
	_update_behavior(delta)
	move_and_slide()
	if behavior_state == "patrol" and is_on_wall():
		_reverse_direction()

func _update_behavior(delta: float) -> void:
	if behavior_state == "attack":
		_attack_timer -= delta
		velocity.x = 0.0
		_try_apply_attack_damage(_target)
		if _attack_timer <= 0.0:
			is_attack_active = false
			if _find_nearest_player() == null:
				behavior_state = "patrol"
			else:
				_recovery_timer = attack_recovery
				behavior_state = "recover"
		return

	if behavior_state == "recover":
		_recovery_timer -= delta
		velocity.x = 0.0
		if _recovery_timer <= 0.0:
			behavior_state = "patrol"
		return

	_target = _find_nearest_player()
	if _target != null:
		var distance := global_position.distance_to(_target.global_position)
		if distance <= attack_range:
			_start_attack(_target)
			return
		if distance <= aggro_range:
			behavior_state = "aggro"
			direction = sign(_target.global_position.x - global_position.x)
			if is_zero_approx(direction):
				direction = 1.0
			velocity.x = direction * patrol_speed
			return

	behavior_state = "patrol"
	_update_patrol_direction()
	velocity.x = direction * patrol_speed

func _start_attack(target: Node2D) -> void:
	behavior_state = "attack"
	is_attack_active = true
	_attack_timer = attack_duration
	_attack_hit_targets.clear()
	var attack_direction: float = sign(target.global_position.x - global_position.x)
	if not is_zero_approx(attack_direction):
		direction = attack_direction
	velocity.x = 0.0
	_try_apply_attack_damage(target)

func _try_apply_attack_damage(target: Node) -> void:
	var target_2d := target as Node2D
	if target_2d == null or not target_2d.has_method("take_damage"):
		return
	if not target_2d.is_in_group("player"):
		return
	if _attack_hit_targets.has(target_2d.get_instance_id()):
		return
	if global_position.distance_to(target_2d.global_position) > attack_range + 8.0:
		return
	target_2d.call("take_damage", damage)
	_attack_hit_targets.append(target_2d.get_instance_id())

func _find_nearest_player() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := INF
	for node: Node in get_tree().get_nodes_in_group("player"):
		var candidate := node as Node2D
		if candidate == null:
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance < nearest_distance and distance <= aggro_range:
			nearest = candidate
			nearest_distance = distance
	return nearest

func _update_patrol_direction() -> void:
	var bounds := _get_patrol_bounds()
	if direction > 0.0 and global_position.x >= bounds.y:
		_reverse_direction()
	elif direction < 0.0 and global_position.x <= bounds.x:
		_reverse_direction()

func _get_patrol_bounds() -> Vector2:
	var left: float = min(patrol_left, patrol_right)
	var right: float = max(patrol_left, patrol_right)
	return Vector2(_patrol_origin_x + left, _patrol_origin_x + right)

func _reverse_direction() -> void:
	direction *= -1.0
