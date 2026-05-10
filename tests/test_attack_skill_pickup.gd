extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const ATTACK_SKILL_ID := "guard_counter"
const ATTACK_SKILL_PICKUP_ID := "swamp_guard_counter"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_manager := root.get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.set("save_path", "user://test_attack_skill_pickup_save.json")
		save_manager.call("delete_save")

	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	await physics_frame

	world.call("load_room", "RoomUpgrade")
	await process_frame
	await physics_frame

	var pickup := _find_attack_skill_pickup(world.get("current_room") as Node)
	if pickup == null:
		_fail("RoomUpgrade should contain an attack_skill pickup for guard_counter.")
		return

	var player := world.get("player") as CharacterBody2D
	pickup.body_entered.emit(player)
	await process_frame
	await physics_frame

	var state := world.get("state") as GameState
	if state == null or not state.learned_attack_skills.has(ATTACK_SKILL_ID):
		_fail("Collecting the attack skill pickup should add guard_counter to learned attack skills.")
		return
	if not state.collected_pickups.has(ATTACK_SKILL_PICKUP_ID):
		_fail("Collecting the attack skill pickup should persist its pickup id.")
		return

	if save_manager != null:
		var loaded := save_manager.call("load_game") as GameState
		if loaded == null or not loaded.learned_attack_skills.has(ATTACK_SKILL_ID):
			_fail("Saved state should include the learned attack skill.")
			return
		if not loaded.collected_pickups.has(ATTACK_SKILL_PICKUP_ID):
			_fail("Saved state should include the collected attack skill pickup id.")
			return

	world.call("load_room", "RoomUpgrade")
	await process_frame
	await physics_frame

	if _find_attack_skill_pickup(world.get("current_room") as Node) != null:
		_fail("Reloading RoomUpgrade after collection should remove the collected attack skill pickup.")
		return

	if save_manager != null:
		save_manager.call("delete_save")
	world.free()
	print("PASS: attack skill pickup")
	quit(0)

func _find_attack_skill_pickup(root_node: Node) -> Area2D:
	if root_node == null:
		return null
	if root_node is Area2D and str(root_node.get("pickup_id")) == ATTACK_SKILL_PICKUP_ID:
		return root_node as Area2D
	for child: Node in root_node.get_children():
		var match := _find_attack_skill_pickup(child)
		if match != null:
			return match
	return null

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
