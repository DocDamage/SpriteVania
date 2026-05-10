extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const MapRegistry := preload("res://scripts/world/map_registry.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_assert_registry_describes_swamp_route()
	_assert_registry_describes_castle_gate()
	await _assert_starting_room_is_discovered()
	await _assert_room_transition_discovers_destination()
	await _assert_pause_menu_receives_discovered_rooms()
	print("PASS: map discovery")
	quit(0)

func _assert_registry_describes_swamp_route() -> void:
	var label := str(MapRegistry.get_room_label("swamp_outskirts", "RoomStart"))
	if label != "Mire Gate":
		_fail("Map registry should expose player-facing room labels.")
		return

	var adjacent: Array[String] = MapRegistry.get_adjacent_rooms("swamp_outskirts", "RoomMovement")
	if not adjacent.has("RoomStart") or not adjacent.has("RoomEnemy"):
		_fail("Map registry should expose Swamp room adjacency.")
		return

func _assert_registry_describes_castle_gate() -> void:
	var area_label := str(MapRegistry.get_area_label("castle_gate"))
	if area_label != "Castle Gate":
		_fail("Map registry should expose the Castle Gate area label.")
		return
	var room_label := str(MapRegistry.get_room_label("castle_gate", "CastleGateStart"))
	if room_label != "Moonlit Causeway":
		_fail("Map registry should expose the Castle Gate starting room label.")
		return
	var adjacent: Array[String] = MapRegistry.get_adjacent_rooms("castle_gate", "CastleGateStart")
	if not adjacent.has("CastleBattlements"):
		_fail("Castle Gate starting room should connect to CastleBattlements.")
		return

func _assert_starting_room_is_discovered() -> void:
	var world := _new_world()
	var state := world.get("state") as GameState
	if state == null or not state.discovered_rooms.has("RoomStart"):
		_fail("Starting a new game should mark RoomStart discovered.")
		return
	await _free_world(world)

func _assert_room_transition_discovers_destination() -> void:
	var world := _new_world()
	var start_room := world.get("current_room") as Node2D
	var right_exit := start_room.get_node("Entrances/RightEntrance") as Area2D
	var player := world.get("player") as CharacterBody2D
	right_exit.body_entered.emit(player)
	await physics_frame

	var state := world.get("state") as GameState
	if state == null or not state.discovered_rooms.has("RoomMovement"):
		_fail("Entering a room should mark the destination room discovered.")
		return
	if state.discovered_rooms.count("RoomMovement") != 1:
		_fail("Room discovery should not store duplicate room ids.")
		return
	await _free_world(world)

func _assert_pause_menu_receives_discovered_rooms() -> void:
	var world := _new_world()
	var start_room := world.get("current_room") as Node2D
	var right_exit := start_room.get_node("Entrances/RightEntrance") as Area2D
	var player := world.get("player") as CharacterBody2D
	right_exit.body_entered.emit(player)
	await physics_frame

	world.call("open_pause_menu")
	await process_frame
	var menu := world.get("pause_menu") as Control
	if menu == null:
		_fail("Opening pause should create a pause menu.")
		return
	if menu.get_node("%MapDiscoveredLabel").text.find("Sinking Steps") == -1:
		_fail("Pause menu map should receive discovered room labels from GameWorld.")
		return
	world.call("close_pause_menu")
	await _free_world(world)

func _new_world() -> Node2D:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	return world

func _free_world(world: Node) -> void:
	world.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
