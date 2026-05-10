extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_boss_exit_requires_defeat()
	await _assert_boss_death_persists_and_removes_respawn()
	print("PASS: boss gated exits")
	quit(0)

func _assert_boss_exit_requires_defeat() -> void:
	var world := _new_world_in_room("RoomMiniBoss")
	var exit := Area2D.new()
	exit.set_meta("requires_defeat", "swamp_miniboss")
	world.add_child(exit)

	if bool(world.call("_can_use_room_exit", exit)):
		_fail("Boss-gated exit should stay locked before the boss is defeated.")
		return

	var state := world.get("state") as GameState
	state.defeated_bosses.append("swamp_miniboss")
	if not bool(world.call("_can_use_room_exit", exit)):
		_fail("Boss-gated exit should open after the boss is defeated.")
		return

	await _free_world(world)

func _assert_boss_death_persists_and_removes_respawn() -> void:
	var world := _new_world_in_room("RoomMiniBoss")
	world.call("_on_enemy_died", "swamp_miniboss", 150)
	await process_frame

	var state := world.get("state") as GameState
	if state == null or not state.defeated_bosses.has("swamp_miniboss"):
		_fail("Boss death should persist defeated boss id.")
		return

	world.call("load_room", "RoomMiniBoss")
	await process_frame
	var room := world.get("current_room") as Node2D
	if room.get_node_or_null("EnemySpawns/SwampMiniBoss") != null:
		_fail("Defeated boss should not respawn after room reload.")
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
