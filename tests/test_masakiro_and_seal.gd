extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const MASAKIRO_SCENE_PATH := "res://scenes/enemies/Masakiro.tscn"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_masakiro_has_phase_behavior()
	await _assert_boss_defeat_unlocks_seal_route()
	await _assert_rising_torii_seal_unlocks_ascent_route()
	print("PASS: masakiro and seal")
	quit(0)

func _assert_masakiro_has_phase_behavior() -> void:
	var masakiro_scene := load(MASAKIRO_SCENE_PATH) as PackedScene
	if masakiro_scene == null:
		_fail("Masakiro boss scene should exist.")
		return
	var masakiro := masakiro_scene.instantiate()
	root.add_child(masakiro)
	await process_frame

	var starting_phase := int(masakiro.get("phase"))
	masakiro.call("take_damage", 80)
	await process_frame
	if int(masakiro.get("phase")) <= starting_phase:
		_fail("Masakiro should enter a later phase after enough damage.")
		return
	masakiro.call("_begin_next_pattern")
	if str(masakiro.get("pattern_state")).is_empty() or str(masakiro.get("pattern_state")) == "idle":
		_fail("Masakiro should expose active phase pattern behavior.")
		return
	masakiro.queue_free()
	await process_frame

func _assert_boss_defeat_unlocks_seal_route() -> void:
	var world := _new_world_in_room("SamuraiCastle_MasakiroArena")
	var room := world.get("current_room") as Node2D
	var boss := _find_enemy(room, "masakiro")
	if boss == null:
		_fail("Masakiro Arena should spawn the Masakiro boss.")
		return
	var right_exit := room.get_node_or_null("Entrances/RightEntrance") as Area2D
	if right_exit == null:
		_fail("Masakiro Arena should expose a right exit toward the seal room.")
		return
	if bool(world.call("_can_use_room_exit", right_exit)):
		_fail("Masakiro Arena right exit should stay locked until Masakiro is defeated.")
		return

	world.call("_on_enemy_died", "masakiro", 250)
	await process_frame
	var state := world.get("state") as GameState
	if state == null or not state.defeated_bosses.has("masakiro"):
		_fail("Masakiro defeat should persist the masakiro boss flag.")
		return
	if not bool(world.call("_can_use_room_exit", right_exit)):
		_fail("Masakiro Arena right exit should open after Masakiro is defeated.")
		return

	world.call("load_room", "SamuraiCastle_MasakiroArena")
	await process_frame
	room = world.get("current_room") as Node2D
	if _find_enemy(room, "masakiro") != null:
		_fail("Defeated Masakiro should not respawn after arena reload.")
		return
	await _free_world(world)

func _assert_rising_torii_seal_unlocks_ascent_route() -> void:
	var world := _new_world_in_room("SamuraiCastle_RisingToriiSeal")
	var room := world.get("current_room") as Node2D
	var right_exit := room.get_node_or_null("Entrances/RightEntrance") as Area2D
	if right_exit == null:
		_fail("Rising Torii Seal room should expose an ascent exit.")
		return
	if bool(world.call("_can_use_room_exit", right_exit)):
		_fail("Ascent exit should stay locked before the Rising Torii Seal is collected.")
		return

	var seal := room.get_node_or_null("Pickups/RisingToriiSeal") as Area2D
	if seal == null:
		_fail("Rising Torii Seal room should contain the seal pickup.")
		return
	world.call("_on_upgrade_collected", seal.get("pickup_id"), seal.get("upgrade_id"), seal.get("upgrade_type"))
	await process_frame

	var state := world.get("state") as GameState
	var player := world.get("player") as Player
	if state == null or not state.traversal_unlocks.has("vertical_ascent"):
		_fail("Rising Torii Seal should persist the vertical_ascent traversal unlock.")
		return
	if player == null or not player.has_traversal_unlock("vertical_ascent"):
		_fail("Rising Torii Seal should apply vertical_ascent to the active player.")
		return
	if not bool(world.call("_can_use_room_exit", right_exit)):
		_fail("Ascent exit should open after vertical_ascent is unlocked.")
		return
	await _free_world(world)

func _new_world_in_room(room_id: String) -> Node2D:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	world.call("load_room", room_id)
	return world

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

func _free_world(world: Node) -> void:
	world.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
