extends Node2D
class_name PlayerFamiliar

@export var follow_offset := Vector2(-28, -30)
@export var follow_speed := 8.0
@export var bob_amplitude := 3.0
@export var bob_speed := 4.0

var target: Node2D
var _bob_time := 0.0

func _ready() -> void:
	top_level = true
	target = get_parent() as Node2D
	if target != null:
		global_position = target.global_position + follow_offset

func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	_bob_time += delta * bob_speed
	var bob := Vector2(0.0, sin(_bob_time) * bob_amplitude)
	var desired_position := target.global_position + _oriented_offset() + bob
	var weight := clampf(follow_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(desired_position, weight)

func _oriented_offset() -> Vector2:
	var facing := 1.0
	if "facing_direction" in target:
		facing = float(target.get("facing_direction"))
	return Vector2(-absf(follow_offset.x) * signf(facing), follow_offset.y)
