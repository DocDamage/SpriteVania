extends Node2D
class_name LockedServicePlaceholder

@export var service_id := ""
@export var locked_message := "Locked"

func is_locked() -> bool:
	return true

func service_status() -> Dictionary:
	return {
		"service_id": service_id,
		"locked": true,
		"message": locked_message,
	}
