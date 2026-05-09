extends Node2D
class_name Room

@export var room_id: String = ""
@export var next_rooms: Dictionary = {}
@export var enemy_spawn_ids: Array[String] = []

var defeated_enemy_ids: Array[String] = []
var defeated_persistent_ids: Array[String] = []

func enter_room() -> void:
	reset_temporary_state_for_reentry()

func mark_enemy_defeated(enemy_id: String) -> void:
	if not defeated_enemy_ids.has(enemy_id):
		defeated_enemy_ids.append(enemy_id)

func mark_persistent_defeated(entity_id: String) -> void:
	if not defeated_persistent_ids.has(entity_id):
		defeated_persistent_ids.append(entity_id)

func reset_temporary_state_for_reentry() -> void:
	defeated_enemy_ids.clear()
