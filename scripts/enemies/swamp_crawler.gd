extends "res://scripts/enemies/enemy.gd"
class_name SwampCrawler

@export var patrol_speed: float = 45.0
@export var patrol_left: float = -96.0
@export var patrol_right: float = 96.0
@export var patrol_path: NodePath
@export var aggro_range: float = 220.0
@export var leash_range: float = 260.0
@export var attack_range: float = 48.0
@export var alert_duration: float = 0.18
@export var attack_windup: float = 0.18
@export var attack_duration: float = 0.35
@export var attack_recovery: float = 0.25

var direction := -1.0
var behavior_state := "idle"
var is_attack_active := false
var is_aggro_alert := false
var _patrol_origin_x := 0.0
var _leash_origin := Vector2.ZERO
var _state_timer := 0.0
var _attack_timer := 0.0
var _recovery_timer := 0.0
var _target: Node2D
var _attack_hit_targets: Array[int] = []
var _attack_flash: Line2D
var _aggro_indicator: ColorRect

func _ready() -> void:
	super()
	_patrol_origin_x = global_position.x
	_leash_origin = global_position
	_apply_patrol_path()
	_attack_flash = get_node_or_null("%AttackFlash") as Line2D
	_aggro_indicator = get_node_or_null("%AggroIndicator") as ColorRect
	_update_aggro_feedback()

func _physics_process(delta: float) -> void:
	_update_behavior(delta)
	move_and_slide()
	if behavior_state == "patrol" and is_on_wall():
		_reverse_direction()

func _update_behavior(delta: float) -> void:
	if behavior_state == "attack_windup":
		_state_timer -= delta
		velocity.x = 0.0
		_set_aggro_alert(true)
		if _state_timer <= 0.0:
			_enter_attack_active()
		return

	if behavior_state == "attack_active":
		_attack_timer -= delta
		velocity.x = 0.0
		_set_aggro_alert(true)
		_try_apply_attack_damage(_target)
		if _attack_timer <= 0.0:
			_enter_attack_recovery()
		return

	if behavior_state == "attack_recovery":
		_recovery_timer -= delta
		velocity.x = 0.0
		_set_aggro_alert(true)
		if _recovery_timer <= 0.0:
			_target = _find_nearest_player()
			if _target == null:
				_enter_patrol()
			else:
				_enter_alert(_target)
		return

	_target = _find_nearest_player()
	if _target != null:
		if behavior_state == "alert":
			_state_timer -= delta
			velocity.x = 0.0
			_set_aggro_alert(true)
			if _target.global_position.distance_to(_leash_origin) > leash_range:
				_enter_patrol()
			elif _state_timer <= 0.0:
				_enter_chase(_target)
			return

		if behavior_state == "chase":
			_update_chase(delta)
			return

		var distance := global_position.distance_to(_target.global_position)
		if distance <= attack_range:
			_start_attack(_target)
			return
		if distance <= aggro_range:
			_enter_alert(_target)
			return

	_enter_patrol()
	_update_patrol_direction()
	velocity.x = direction * patrol_speed

func _start_attack(target: Node2D) -> void:
	behavior_state = "attack_windup"
	is_attack_active = false
	_set_aggro_alert(true)
	_state_timer = attack_windup
	_attack_hit_targets.clear()
	var attack_direction: float = sign(target.global_position.x - global_position.x)
	if not is_zero_approx(attack_direction):
		direction = attack_direction
	velocity.x = 0.0
	_update_attack_flash()

func _enter_attack_active() -> void:
	behavior_state = "attack_active"
	is_attack_active = true
	_attack_timer = attack_duration
	velocity.x = 0.0
	_update_attack_flash()
	_try_apply_attack_damage(_target)

func _enter_attack_recovery() -> void:
	behavior_state = "attack_recovery"
	is_attack_active = false
	_recovery_timer = attack_recovery
	velocity.x = 0.0
	_update_attack_flash()

func _enter_alert(target: Node2D) -> void:
	_target = target
	behavior_state = "alert"
	_state_timer = alert_duration
	velocity.x = 0.0
	_set_aggro_alert(true)

func _enter_chase(target: Node2D) -> void:
	_target = target
	behavior_state = "chase"
	_set_aggro_alert(true)
	_update_chase(0.0)

func _enter_patrol() -> void:
	behavior_state = "patrol"
	is_attack_active = false
	_update_attack_flash()
	_set_aggro_alert(false)

func _update_chase(delta: float) -> void:
	if _target == null or _target.global_position.distance_to(_leash_origin) > leash_range:
		_enter_patrol()
		return
	var distance := global_position.distance_to(_target.global_position)
	if distance <= attack_range:
		_start_attack(_target)
		return
	var chase_direction: float = sign(_target.global_position.x - global_position.x)
	if is_zero_approx(chase_direction):
		chase_direction = 1.0
	if not _can_chase_inside_patrol_route(chase_direction, delta):
		behavior_state = "attack_recovery"
		_recovery_timer = attack_recovery
		_set_aggro_alert(true)
		direction = -chase_direction
		velocity.x = 0.0
		return
	direction = chase_direction
	velocity.x = direction * patrol_speed

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
	if target_2d.has_method("apply_knockback"):
		target_2d.call("apply_knockback", global_position)
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

func _apply_patrol_path() -> void:
	if patrol_path.is_empty():
		return
	var path := get_node_or_null(patrol_path)
	if path == null or not path.has_method("local_bounds"):
		return
	var bounds: Vector2 = path.call("local_bounds")
	patrol_left = bounds.x
	patrol_right = bounds.y

func _can_chase_inside_patrol_route(chase_direction: float, delta: float) -> bool:
	var bounds := _get_patrol_bounds()
	var projected_x := global_position.x + chase_direction * patrol_speed * delta
	if chase_direction > 0.0:
		return global_position.x < bounds.y and projected_x <= bounds.y
	return global_position.x > bounds.x and projected_x >= bounds.x

func _reverse_direction() -> void:
	direction *= -1.0

func _update_attack_flash() -> void:
	if _attack_flash == null:
		return
	_attack_flash.visible = is_attack_active
	if not is_attack_active:
		return
	_attack_flash.scale.x = direction

func _set_aggro_alert(next_value: bool) -> void:
	if is_aggro_alert == next_value:
		return
	is_aggro_alert = next_value
	_update_aggro_feedback()

func _update_aggro_feedback() -> void:
	if _aggro_indicator == null:
		return
	_aggro_indicator.visible = is_aggro_alert
