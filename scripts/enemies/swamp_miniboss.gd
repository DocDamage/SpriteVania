extends "res://scripts/enemies/enemy.gd"
class_name SwampMiniBoss

@export var leap_cooldown: float = 2.0
@export var leap_horizontal_speed: float = 120.0
@export var leap_vertical_speed: float = 260.0

var cooldown_remaining := 0.0

func _ready() -> void:
	super()
	xp_reward = 150

func _physics_process(delta: float) -> void:
	cooldown_remaining -= delta
	if cooldown_remaining <= 0.0:
		_start_leap(_random_horizontal_direction())
	velocity.y += 700.0 * delta
	move_and_slide()

func _start_leap(horizontal_direction: float) -> void:
	velocity.y = -leap_vertical_speed
	velocity.x = leap_horizontal_speed * sign(horizontal_direction)
	cooldown_remaining = leap_cooldown

func _random_horizontal_direction() -> float:
	if randf() < 0.5:
		return -1.0
	return 1.0
