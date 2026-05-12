extends Node2D
class_name TrainingDummy

@export var max_health := 120

var current_health := 120
var last_damage_source := ""

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int, source_id := "") -> void:
	if amount <= 0:
		return
	last_damage_source = source_id
	current_health -= amount
	if current_health <= 0:
		current_health = max_health
