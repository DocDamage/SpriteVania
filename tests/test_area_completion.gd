extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_completion_exit_requires_boss_defeat()
	await _assert_completion_exit_persists_area()
	await _assert_swamp_completion_enters_castle_gate()
	print("PASS: area completion")
	quit(0)

func _assert_completion_exit_requires_boss_defeat() -> void:
	var world := _new_world_in_room("RoomMiniBoss")
	var room := world.get("current_room") as Node2D
	var exit := room.get_node_or_null("Entrances/RightEntrance") as Area2D
	if exit == null:
		_fail("RoomMiniBoss should expose the completion exit.")
		return
	if not world.get_signal_connection_list("area_completed").is_empty():
		_fail("Completion signal should start disconnected in this test.")
		return
	if bool(world.call("_can_use_room_exit", exit)):
		_fail("Completion exit should require the miniboss defeat.")
		return

	await _free_world(world)

func _assert_completion_exit_persists_area() -> void:
	var world := _new_world_in_room("RoomMiniBoss")
	var completed_area: Array[String] = [""]
	world.area_completed.connect(func(area_id: String) -> void:
		completed_area[0] = area_id
	)

	var state := world.get("state") as GameState
	state.defeated_bosses.append("swamp_miniboss")
	var room := world.get("current_room") as Node2D
	var exit := room.get_node("Entrances/RightEntrance") as Area2D
	var player := world.get("player") as CharacterBody2D
	world.call("_on_room_exit_body_entered", player, exit)
	await physics_frame

	if completed_area[0] != "swamp_outskirts_complete":
		_fail("Completion exit should emit the completed area id.")
		return
	if not state.completed_areas.has("swamp_outskirts_complete"):
		_fail("Completion exit should persist completed area id.")
		return
	var hud := world.get("hud") as CanvasLayer
	if hud == null or hud.get_node("%UpgradeTitleLabel").text != "Area complete":
		_fail("Completion exit should show HUD completion feedback.")
		return

	await _free_world(world)

func _assert_swamp_completion_enters_castle_gate() -> void:
	var world := _new_world_in_room("RoomMiniBoss")
	var state := world.get("state") as GameState
	state.defeated_bosses.append("swamp_miniboss")
	var room := world.get("current_room") as Node2D
	var exit := room.get_node("Entrances/RightEntrance") as Area2D
	var player := world.get("player") as CharacterBody2D
	world.call("_on_room_exit_body_entered", player, exit)
	await physics_frame

	if state.current_area != "castle_gate":
		_fail("Swamp completion should move the playable area to Castle Gate.")
		return
	if state.current_room != "CastleGateStart":
		_fail("Swamp completion should load the Castle Gate starting room.")
		return
	if not state.discovered_rooms.has("CastleGateStart"):
		_fail("Entering Castle Gate should discover its starting room.")
		return

	await _free_world(world)

func _new_world_in_room(room_id: String) -> Node2D:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	world.call("load_room", room_id)
	return world

func _free_world(world: Node) -> void:
	world.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
