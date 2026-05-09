extends "res://scripts/enemies/enemy.gd"
class_name SwampMiniBoss

@export var leap_cooldown: float = 2.0

var cooldown_remaining := 0.0

func _ready() -> void:
	super()
	xp_reward = 150

func _physics_process(delta: float) -> void:
	cooldown_remaining -= delta
	if cooldown_remaining <= 0.0:
		velocity.y = -260.0
		velocity.x = 120.0 * _random_horizontal_direction()
		cooldown_remaining = leap_cooldown
	velocity.y += 700.0 * delta
	move_and_slide()

func _random_horizontal_direction() -> float:
	if randf() < 0.5:
		return -1.0
	return 1.0
