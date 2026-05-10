extends "res://scripts/enemies/enemy.gd"
class_name SwampCrawler

@export var patrol_speed: float = 45.0
@export var patrol_left: float = -96.0
@export var patrol_right: float = 96.0

var direction := -1.0
var _patrol_origin_x := 0.0

func _ready() -> void:
	super()
	_patrol_origin_x = global_position.x

func _physics_process(_delta: float) -> void:
	_update_patrol_direction()
	velocity.x = direction * patrol_speed
	move_and_slide()
	if is_on_wall():
		_reverse_direction()

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
