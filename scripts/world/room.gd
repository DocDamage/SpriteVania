extends Node2D
class_name Room

@export var room_id: String = ""
@export var next_rooms: Dictionary = {}
@export var enemy_spawn_ids: Array[String] = []
@export var room_bounds := Rect2(0, 0, 960, 540)

var defeated_enemy_ids: Array[String] = []
var defeated_persistent_ids: Array[String] = []

func enter_room() -> void:
	reset_temporary_state_for_reentry()
	_spawn_room_enemies()

func get_room_bounds() -> Rect2:
	return room_bounds

func mark_enemy_defeated(enemy_id: String) -> void:
	if not defeated_enemy_ids.has(enemy_id):
		defeated_enemy_ids.append(enemy_id)

func mark_persistent_defeated(entity_id: String) -> void:
	if not defeated_persistent_ids.has(entity_id):
		defeated_persistent_ids.append(entity_id)

func reset_temporary_state_for_reentry() -> void:
	defeated_enemy_ids.clear()

func _spawn_room_enemies() -> void:
	for spawn: Node in _enemy_spawn_markers(self):
		if spawn.has_method("spawn_enemy"):
			spawn.call("spawn_enemy")

func _enemy_spawn_markers(root: Node) -> Array[Node]:
	var markers: Array[Node] = []
	if root == null:
		return markers
	if root.has_method("spawn_enemy"):
		markers.append(root)
	for child: Node in root.get_children():
		markers.append_array(_enemy_spawn_markers(child))
	return markers
