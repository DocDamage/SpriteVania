extends SceneTree

const Room := preload("res://scripts/world/room.gd")

func _init() -> void:
	var room := Room.new()
	room.enemy_spawn_ids = ["crawler_a", "crawler_b"]
	room.mark_enemy_defeated("crawler_a")
	if not room.defeated_enemy_ids.has("crawler_a"):
		push_error("Enemy defeat was not tracked")
		room.free()
		quit(1)
		return
	room.reset_temporary_state_for_reentry()
	if room.defeated_enemy_ids.size() != 0:
		push_error("Normal enemies should reset on room re-entry")
		room.free()
		quit(1)
		return
	room.defeated_persistent_ids = ["miniboss"]
	room.reset_temporary_state_for_reentry()
	if not room.defeated_persistent_ids.has("miniboss"):
		push_error("Persistent defeated state should not reset")
		room.free()
		quit(1)
		return
	room.free()
	print("PASS: room respawn")
	quit(0)
