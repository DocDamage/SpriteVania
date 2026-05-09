extends "res://scripts/enemies/enemy.gd"
class_name SwampCrawler

@export var patrol_speed: float = 45.0

var direction := -1.0

func _physics_process(_delta: float) -> void:
	velocity.x = direction * patrol_speed
	move_and_slide()
