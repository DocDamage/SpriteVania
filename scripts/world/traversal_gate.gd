extends Area2D
class_name TraversalGate

@export var next_room: String = ""
@export var required_traversal: String = ""

func _ready() -> void:
	if not next_room.is_empty():
		set_meta("next_room", next_room)
	if not required_traversal.is_empty():
		set_meta("required_traversal", required_traversal)
