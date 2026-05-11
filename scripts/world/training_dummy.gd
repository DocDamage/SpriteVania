extends Node2D
class_name TrainingDummy

@export var max_health := 120

var current_health := 120

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	current_health -= amount
	if current_health <= 0:
		current_health = max_health
