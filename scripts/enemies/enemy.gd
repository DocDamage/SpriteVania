extends CharacterBody2D
class_name Enemy

signal died(enemy_id: String, xp_reward: int)

@export var enemy_id: String = ""
@export var max_health: int = 30
@export var damage: int = 10
@export var xp_reward: int = 25

var current_health: int
var _is_dead := false

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	if amount <= 0 or _is_dead:
		return

	current_health -= amount
	if current_health <= 0:
		_is_dead = true
		died.emit(enemy_id, xp_reward)
		queue_free()
