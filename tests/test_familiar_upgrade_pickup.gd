extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const FAMILIAR_PICKUP_ID := "swamp_familiar_sting"
const FAMILIAR_ABILITY_ID := "sting"

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save_manager := root.get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.set("save_path", "user://test_familiar_upgrade_pickup_save.json")
		save_manager.call("delete_save")

	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	await physics_frame

	world.call("load_room", "RoomUpgrade")
	await process_frame
	await physics_frame

	var pickup := _find_familiar_pickup(world.get("current_room") as Node)
	if pickup == null:
		_fail("RoomUpgrade should contain a familiar_ability pickup for sting.")
		return

	var player := world.get("player") as Player
	var familiar := player.get_node("Familiar") as Node
	var damage_before := int(familiar.call("attack_damage"))
	pickup.body_entered.emit(player)
	await process_frame
	await physics_frame

	var ability_levels := familiar.get("ability_levels") as Dictionary
	if int(ability_levels.get(FAMILIAR_ABILITY_ID, 0)) != 1:
		_fail("Collecting a familiar ability pickup should upgrade the active familiar ability.")
		return
	if int(familiar.call("attack_damage")) <= damage_before:
		_fail("Collecting the sting pickup should improve familiar damage.")
		return

	var state := world.get("state") as GameState
	if state == null or not state.collected_pickups.has(FAMILIAR_PICKUP_ID):
		_fail("Collecting a familiar ability pickup should persist its pickup id.")
		return
	var saved_ability_levels := state.familiar_state.get("ability_levels", {}) as Dictionary
	if int(saved_ability_levels.get(FAMILIAR_ABILITY_ID, 0)) != 1:
		_fail("Collecting a familiar ability pickup should persist familiar ability levels.")
		return

	var hud := world.get("hud") as CanvasLayer
	if hud == null or hud.get_node("%UpgradeTitleLabel").text != "Familiar ability upgraded":
		_fail("Collecting a familiar ability pickup should show familiar upgrade feedback.")
		return

	if save_manager != null:
		var loaded := save_manager.call("load_game") as GameState
		var loaded_levels := loaded.familiar_state.get("ability_levels", {}) as Dictionary if loaded != null else {}
		if int(loaded_levels.get(FAMILIAR_ABILITY_ID, 0)) != 1:
			_fail("Saved state should include familiar ability upgrades.")
			return

	world.call("load_room", "RoomUpgrade")
	await process_frame
	await physics_frame
	if _find_familiar_pickup(world.get("current_room") as Node) != null:
		_fail("Reloading RoomUpgrade after collection should remove the collected familiar pickup.")
		return

	if save_manager != null:
		save_manager.call("delete_save")
	world.queue_free()
	await process_frame
	print("PASS: familiar upgrade pickup")
	quit(0)

func _find_familiar_pickup(root_node: Node) -> Area2D:
	if root_node == null:
		return null
	if root_node is Area2D and str(root_node.get("pickup_id")) == FAMILIAR_PICKUP_ID:
		return root_node as Area2D
	for child: Node in root_node.get_children():
		var match := _find_familiar_pickup(child)
		if match != null:
			return match
	return null

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
