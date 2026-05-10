extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")

var failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_manual_death_respawns_at_checkpoint_room_with_full_vitals()
	if failed:
		return
	await _assert_lethal_hazard_respawns_at_checkpoint()
	if failed:
		return
	await _assert_lethal_enemy_contact_respawns_at_checkpoint()
	if failed:
		return
	print("PASS: player respawn")
	quit(0)

func _assert_manual_death_respawns_at_checkpoint_room_with_full_vitals() -> void:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await _activate_swamp_checkpoint(world)

	world.call("load_room", "RoomHazard")
	var player := world.get("player") as Node2D
	player.set("current_health", 1)
	player.set("current_resource", 1)
	world.call("_store_player_state")
	world.call("_on_player_died")
	await _settle_scene()

	if not _assert_respawned_at_checkpoint(world, "Manual death"):
		return

	world.queue_free()
	await _settle_scene()

func _assert_lethal_hazard_respawns_at_checkpoint() -> void:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await _activate_swamp_checkpoint(world)

	world.call("load_room", "RoomHazard")
	await process_frame
	var player := world.get("player") as Node2D
	var room := world.get("current_room") as Node2D
	var spikes := room.get_node_or_null("Hazards/SpikeHazard") as Area2D
	if player == null or spikes == null:
		_fail("Hazard respawn test needs player and spikes.")
		return
	player.set("current_health", 1)
	world.call("_on_hazard_body_entered", player, spikes)
	await _settle_scene()

	if not _assert_respawned_at_checkpoint(world, "Lethal hazard"):
		return

	world.queue_free()
	await _settle_scene()

func _assert_lethal_enemy_contact_respawns_at_checkpoint() -> void:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await _activate_swamp_checkpoint(world)

	world.call("load_room", "RoomEnemy")
	await _settle_scene()
	var player := world.get("player") as Node2D
	var room := world.get("current_room") as Node2D
	var enemy := room.get_node_or_null("EnemySpawns/SwampCrawlerA") as Node2D
	if player == null or enemy == null:
		_fail("Enemy respawn test needs player and crawler.")
		return
	player.set("current_health", 1)
	enemy.call("_on_contact_body_entered", player)
	await _settle_scene()

	if not _assert_respawned_at_checkpoint(world, "Lethal enemy contact"):
		return

	world.queue_free()
	await _settle_scene()

func _activate_swamp_checkpoint(world: Node2D) -> void:
	world.call("load_room", "RoomCheckpoint")
	await process_frame

	world.call("activate_checkpoint", "swamp_shrine_01", _checkpoint_position())
	var state := world.get("state") as Object
	if state == null or str(state.get("checkpoint_room")) != "RoomCheckpoint":
		_fail("Checkpoint activation should remember the checkpoint room.")

func _assert_respawned_at_checkpoint(world: Node2D, context: String) -> bool:
	var player := world.get("player") as Node2D
	var state := world.get("state") as Object
	if str(world.call("get_current_room_id")) != "RoomCheckpoint":
		_fail(context + " should reload the checkpoint room.")
		return false
	if player.global_position.distance_to(_checkpoint_position()) > 8.0:
		_fail(context + " should respawn the player near the checkpoint position.")
		return false
	if int(player.get("current_health")) != int(WARDEN_DATA.max_health):
		_fail(context + " should restore health to max.")
		return false
	if int(player.get("current_resource")) != int(WARDEN_DATA.max_resource):
		_fail(context + " should restore resource to max.")
		return false
	if state == null or int(state.get("current_health")) != int(WARDEN_DATA.max_health):
		_fail(context + " should save restored health.")
		return false
	if int(state.get("current_resource")) != int(WARDEN_DATA.max_resource):
		_fail(context + " should save restored resource.")
		return false
	return true

func _fail(message: String) -> void:
	failed = true
	push_error(message)
	quit(1)

func _checkpoint_position() -> Vector2:
	return Vector2(480, 484)

func _settle_scene() -> void:
	for _i: int in range(4):
		await process_frame
		await physics_frame
