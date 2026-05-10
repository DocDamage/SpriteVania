extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_world_applies_and_stores_familiar_state()
	if _failed:
		return
	await _assert_enemy_xp_also_trains_familiar()
	if _failed:
		return
	await _assert_enemy_defeat_restores_player_resource_without_skipping_xp()
	if _failed:
		return
	print("PASS: familiar world persistence")
	quit(0)

func _assert_world_applies_and_stores_familiar_state() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame

	var state := world.get("state") as GameState
	state.familiar_state = {
		"level": 2,
		"xp": 120,
		"evolution_stage": "wisp",
		"ability_points": 1,
		"ability_levels": {
			"sting": 1,
		},
	}
	world.call("_spawn_player", Vector2(80, 80))
	await process_frame

	var player := world.get("player") as Player
	var familiar := player.get_node("Familiar") as Node
	if int(familiar.get("level")) != 2:
		_fail("GameWorld should apply saved familiar level to spawned player familiar.")
		return
	if int((familiar.get("ability_levels") as Dictionary).get("sting", 0)) != 1:
		_fail("GameWorld should apply saved familiar ability levels.")
		return

	familiar.call("gain_xp", 60)
	world.call("_store_player_state")
	if int(state.familiar_state.get("xp", 0)) != int(familiar.get("xp")):
		_fail("GameWorld should store familiar XP with player state.")
		return

	await _free_world(world)

func _assert_enemy_xp_also_trains_familiar() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame

	var player := world.get("player") as Player
	var familiar := player.get_node("Familiar") as Node
	world.call("_on_enemy_died", "test_crawler", 25)
	if int(familiar.get("xp")) <= 0:
		_fail("Enemy XP should also train the active familiar.")
		return

	await _free_world(world)

func _assert_enemy_defeat_restores_player_resource_without_skipping_xp() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame

	var player := world.get("player") as Player
	var familiar := player.get_node("Familiar") as Node
	var max_resource := int(player.get_stats().get("max_resource", 0))
	player.current_resource = max_resource - 1
	var starting_player_xp := int(player.get("xp"))
	var starting_familiar_xp := int(familiar.get("xp"))

	world.call("_on_enemy_died", "test_crawler", 25)
	if int(player.get("current_resource")) != max_resource:
		_fail("Enemy defeats should restore player resource without exceeding max resource.")
		return
	if int(player.get("xp")) <= starting_player_xp:
		_fail("Enemy defeats should still grant player XP when restoring resource.")
		return
	if int(familiar.get("xp")) <= starting_familiar_xp:
		_fail("Enemy defeats should still grant familiar XP when restoring resource.")
		return

	await _free_world(world)

func _free_world(world: Node) -> void:
	world.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
