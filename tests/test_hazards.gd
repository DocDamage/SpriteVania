extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_hazards_damage_player()
	print("PASS: hazards")
	quit(0)

func _assert_hazards_damage_player() -> void:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	world.call("load_room", "RoomHazard")
	await process_frame

	var player := world.get("player") as Node
	var room := world.get("current_room") as Node2D
	var swamp_water := room.get_node_or_null("Hazards/SwampWaterHazard") as Area2D
	var spikes := room.get_node_or_null("Hazards/SpikeHazard") as Area2D
	if player == null or swamp_water == null or spikes == null:
		_fail("RoomHazard should expose a player and both hazard areas.")
		return

	var starting_health := int(player.get("current_health"))
	world.call("_on_hazard_body_entered", player, swamp_water)
	if int(player.get("current_health")) >= starting_health:
		_fail("Swamp water should damage the player.")
		return

	var after_swamp := int(player.get("current_health"))
	world.call("_on_hazard_body_entered", player, swamp_water)
	if int(player.get("current_health")) != after_swamp:
		_fail("Hazard cooldown should prevent immediate repeat damage from the same hazard type.")
		return

	world.call("_on_hazard_body_entered", player, spikes)
	if int(player.get("current_health")) != after_swamp:
		_fail("Player invulnerability should prevent immediate damage from a different hazard type.")
		return

	var recovery_time := maxf(float(player.get("invulnerability_duration")), 0.6)
	player.call("_process", recovery_time)
	world.call("_process", recovery_time)
	world.call("_on_hazard_body_entered", player, spikes)
	if int(player.get("current_health")) >= after_swamp:
		_fail("A different hazard type should damage the player after invulnerability expires.")
		return

	world.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
