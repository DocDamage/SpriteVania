extends Area2D
class_name UpgradePickup

signal upgrade_collected(pickup_id: String, upgrade_id: String, upgrade_type: String)

const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")

@export var pickup_id: String = ""
@export var upgrade_id: String = ""
@export_enum("traversal", "attack_skill", "familiar_ability", "optional") var upgrade_type: String = "traversal"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.get_script() == PLAYER_SCRIPT:
		upgrade_collected.emit(pickup_id, upgrade_id, upgrade_type)
		queue_free()
