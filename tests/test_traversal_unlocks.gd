extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")
const GUNSLINGER_DATA := preload("res://data/classes/gunslinger.tres")
const HEXBINDER_DATA := preload("res://data/classes/hexbinder.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_warden_dash_unlock()
	await _assert_gunslinger_hookshot_unlock()
	await _assert_hexbinder_blink_unlock()
	await _assert_world_resolves_first_traversal_tool()
	print("PASS: traversal unlocks")
	quit(0)

func _assert_warden_dash_unlock() -> void:
	var player := _spawn_player(WARDEN_DATA)
	var start_x := player.global_position.x
	player.class_controller.call("handle_class_action")
	if player.global_position.x != start_x:
		_fail("Warden armored dash should be locked until learned.")
		return

	player.set_traversal_unlocks(["armored_dash"])
	player.class_controller.call("handle_class_action")
	if player.global_position.x <= start_x:
		_fail("Warden armored dash should move forward after unlock.")
	player.free()

func _assert_gunslinger_hookshot_unlock() -> void:
	var player := _spawn_player(GUNSLINGER_DATA)
	var start_position := player.global_position
	player.class_controller.call("handle_class_action")
	if player.global_position != start_position:
		_fail("Gunslinger hookshot should be locked until learned.")
		return

	player.set_traversal_unlocks(["hookshot"])
	player.class_controller.call("handle_class_action")
	if player.global_position.x <= start_position.x or player.global_position.y >= start_position.y:
		_fail("Gunslinger hookshot should pull forward and upward after unlock.")
	player.free()

func _assert_hexbinder_blink_unlock() -> void:
	var player := _spawn_player(HEXBINDER_DATA)
	var start_x := player.global_position.x
	player.class_controller.call("handle_class_action")
	if player.global_position.x != start_x:
		_fail("Hexbinder blink should be locked until learned.")
		return

	player.set_traversal_unlocks(["blink"])
	player.class_controller.call("handle_class_action")
	if player.global_position.x <= start_x:
		_fail("Hexbinder blink should move forward after unlock.")
	player.free()

func _assert_world_resolves_first_traversal_tool() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "hexbinder", "")
	await process_frame

	world.call("_on_upgrade_collected", "test_pickup", "first_traversal_tool", "traversal")
	var state := world.get("state") as GameState
	var player := world.get("player") as Player
	if state == null or not state.traversal_unlocks.has("blink"):
		_fail("First traversal pickup should resolve to the selected class's first traversal unlock.")
		return
	if player == null or not player.has_traversal_unlock("blink"):
		_fail("Player should receive traversal unlocks immediately after pickup collection.")
	world.free()

func _spawn_player(class_data: Resource) -> Player:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.setup(class_data, "")
	player.global_position = Vector2(100, 100)
	player.facing_direction = 1.0
	return player

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
