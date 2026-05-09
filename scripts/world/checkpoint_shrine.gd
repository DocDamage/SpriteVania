extends Area2D
class_name CheckpointShrine

signal checkpoint_activated(checkpoint_id: String, checkpoint_position: Vector2)

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")

@export var checkpoint_id: String = "checkpoint"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.get_script() == PLAYER_SCRIPT:
		checkpoint_activated.emit(checkpoint_id, global_position)
