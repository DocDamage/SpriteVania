extends "res://scripts/world/upgrade_pickup.gd"
class_name RisingToriiSeal

func _ready() -> void:
	if pickup_id.is_empty():
		pickup_id = "rising_torii_seal"
	upgrade_id = "vertical_ascent"
	upgrade_type = "traversal"
	super()
