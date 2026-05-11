extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const ROOM_SCRIPT := preload("res://scripts/world/room.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_room_owned_spawn_marker_creates_enemy()

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
	if not start_room.has_method("get_room_bounds"):
		_fail("Rooms should expose room bounds for player and camera clamping.")
		return
	var start_bounds: Rect2 = start_room.call("get_room_bounds")
	if start_bounds.position.x > 0.0:
		_fail("RoomStart bounds should keep the first screen left edge at or before x=0.")
		return
	var player := world.get("player") as CharacterBody2D
	if not world.has_method("_apply_room_constraints"):
		_fail("GameWorld should expose room constraints for tests and runtime clamping.")
		return
	player.global_position = Vector2(start_bounds.position.x - 140.0, 80.0)
	world.call("_apply_room_constraints")
	if player.global_position.x < start_bounds.position.x:
		_fail("Room bounds should prevent the player from disappearing past the first screen left edge.")
		return
	var player_camera := player.get_node_or_null("Camera2D") as Camera2D
	if player_camera == null:
		_fail("Player should have a camera to clamp to room bounds.")
		return
	if player_camera.limit_left != int(start_bounds.position.x) or player_camera.limit_right != int(start_bounds.position.x + start_bounds.size.x):
		_fail("Player camera limits should match the active room bounds.")
		return

	var right_exit := start_room.get_node_or_null("Entrances/RightEntrance") as Area2D
	if right_exit == null:
		_fail("RoomStart should expose a right-side room exit.")
		return

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

	world.call("load_room", "RoomEnemy")
	var enemy_room := world.get("current_room") as Node2D
	var first_crawler := _find_enemy(enemy_room, "swamp_crawler_a")
	if first_crawler == null:
		_fail("RoomEnemy should create room-owned enemy spawns on entry.")
		return
	first_crawler.call("take_damage", 999)
	await process_frame
	if _find_enemy(enemy_room, "swamp_crawler_a") != null:
		_fail("Killed room enemies should leave the active room.")
		return
	world.call("load_room", "RoomMovement")
	world.call("load_room", "RoomEnemy")
	var reentered_room := world.get("current_room") as Node2D
	if _find_enemy(reentered_room, "swamp_crawler_a") == null:
		_fail("Temporary room enemies should respawn when re-entering the room.")
		return

	if save_manager != null:
		save_manager.call("delete_save")
	world.free()
	print("PASS: room transitions")
	quit(0)

func _assert_room_owned_spawn_marker_creates_enemy() -> void:
	if not ResourceLoader.exists("res://scripts/world/enemy_spawn.gd"):
		_fail("Room-owned enemy spawns should use an EnemySpawn marker script.")
		return
	var spawn_script := load("res://scripts/world/enemy_spawn.gd") as Script
	var room := ROOM_SCRIPT.new()
	room.name = "SpawnMarkerRoom"
	var spawns := Node2D.new()
	spawns.name = "EnemySpawns"
	room.add_child(spawns)
	var spawn := spawn_script.new() as Node2D
	spawn.name = "CrawlerSpawn"
	spawn.set("enemy_scene", CRAWLER_SCENE)
	spawn.set("enemy_id", "spawned_crawler")
	spawn.position = Vector2(220, 480)
	spawns.add_child(spawn)
	root.add_child(room)

	room.call("enter_room")
	await process_frame

	var spawned := _find_enemy(room, "spawned_crawler")
	if spawned == null:
		_fail("Room enter should instantiate enemies from EnemySpawn markers.")
		return
	if (spawned as Node2D).global_position.distance_to(spawn.global_position) > 8.0:
		_fail("Room-owned enemies should spawn at their marker position. Expected %s, got %s." % [str(spawn.global_position), str((spawned as Node2D).global_position)])
		return

	room.queue_free()
	await process_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

func _find_enemy(root_node: Node, enemy_id: String) -> Node:
	if root_node == null:
		return null
	if root_node.has_method("take_damage") and str(root_node.get("enemy_id")) == enemy_id:
		return root_node
	for child: Node in root_node.get_children():
		var match := _find_enemy(child, enemy_id)
		if match != null:
			return match
	return null
