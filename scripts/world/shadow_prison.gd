extends Area2D
class_name ShadowPrison

signal shadow_recruited(character_id: String, character_name: String)

@export var character_id := "shadow"
@export var character_name := "Ren"

var _recruited := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _recruited or body == null or not body.is_in_group("player"):
		return
	var world := _find_game_world()
	if world == null or not world.has_method("recruit_shadow"):
		return
	if bool(world.call("recruit_shadow", character_name)):
		_recruited = true
		shadow_recruited.emit(character_id, character_name)

func _find_game_world() -> Node:
	var current := get_parent()
	while current != null:
		if current is GameWorld:
			return current
		current = current.get_parent()
	return null
