extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_manager := root.get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.set("save_path", "user://test_room_transition_save.json")
		save_manager.call("delete_save")

	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	await physics_frame

	var start_room := world.get("current_room") as Node2D
	if start_room == null or start_room.name != "RoomStart":
		_fail("New games should start in RoomStart.")
		return

	var right_exit := start_room.get_node_or_null("Entrances/RightEntrance") as Area2D
	if right_exit == null:
		_fail("RoomStart should expose a right-side room exit.")
		return

	var player := world.get("player") as CharacterBody2D
	right_exit.body_entered.emit(player)
	await physics_frame

	var movement_room := world.get("current_room") as Node2D
	if movement_room == null or movement_room.name != "RoomMovement":
		_fail("Using RoomStart's right exit should load RoomMovement.")
		return

	var expected_spawn: Vector2 = movement_room.get_node("Entrances/LeftEntrance").global_position + Vector2(72, 0)
	if player.global_position.distance_to(expected_spawn) > 8.0:
		_fail("Player should spawn just inside the destination room's matching entrance.")
		return

	world.call("load_room", "CastleGateStart")
	var castle_start := world.get("current_room") as Node2D
	var castle_right_exit := castle_start.get_node_or_null("Entrances/RightEntrance") as Area2D
	if castle_right_exit == null:
		_fail("CastleGateStart should expose a right-side room exit.")
		return
	castle_right_exit.body_entered.emit(player)
	await physics_frame

	var battlement_room := world.get("current_room") as Node2D
	if battlement_room == null or battlement_room.name != "CastleBattlements":
		_fail("Using CastleGateStart's right exit should load CastleBattlements.")
		return
	var castle_state := world.get("state") as GameState
	if castle_state == null or castle_state.current_area != "castle_gate" or not castle_state.discovered_rooms.has("CastleBattlements"):
		_fail("Castle transition should keep Castle Gate area and discover CastleBattlements.")
		return

	if save_manager != null:
		save_manager.call("delete_save")
	world.free()
	print("PASS: room transitions")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
