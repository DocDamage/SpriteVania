extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const FAMILIAR_SCRIPT := preload("res://scripts/player/player_familiar.gd")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_familiar_follows_player()
	if _failed:
		return
	await _assert_familiar_levels_evolves_and_upgrades_abilities()
	if _failed:
		return
	await _assert_familiar_attacks_nearby_enemies()
	if _failed:
		return
	await _assert_evolution_extends_familiar_attack_reach()
	if _failed:
		return
	print("PASS: familiar")
	quit(0)

func _assert_familiar_follows_player() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.global_position = Vector2(100, 100)
	await process_frame

	var familiar := player.get_node_or_null("Familiar") as Node2D
	if familiar == null:
		_fail("Player scene should include a familiar follower.")
		return
	if familiar.get_script() != FAMILIAR_SCRIPT:
		_fail("Player familiar should use the familiar follower script.")
		return

	familiar.global_position = Vector2(40, 100)
	player.global_position = Vector2(160, 100)
	familiar.call("_physics_process", 0.25)
	if familiar.global_position.x <= 40.0:
		_fail("Familiar should move toward the player over time.")
		return

	player.queue_free()
	await process_frame

func _assert_familiar_levels_evolves_and_upgrades_abilities() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	await process_frame
	var familiar := player.get_node("Familiar") as Node2D

	familiar.call("gain_xp", 120)
	if int(familiar.get("level")) != 2:
		_fail("Familiar should level up from XP.")
		return
	if str(familiar.get("evolution_stage")) != "wisp":
		_fail("Familiar should evolve at level 2.")
		return
	if int(familiar.get("ability_points")) < 1:
		_fail("Familiar should earn ability points when leveling.")
		return

	var damage_before := int(familiar.call("attack_damage"))
	if not bool(familiar.call("upgrade_ability", "sting")):
		_fail("Familiar should upgrade a known ability when it has ability points.")
		return
	if int(familiar.call("attack_damage")) <= damage_before:
		_fail("Upgrading sting should improve familiar attack damage.")
		return

	player.queue_free()
	await process_frame

func _assert_familiar_attacks_nearby_enemies() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(player)
	root.add_child(enemy)
	player.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(132, 100)
	await process_frame

	var familiar := player.get_node("Familiar") as Node2D
	familiar.global_position = Vector2(110, 100)
	var starting_health := enemy.current_health
	familiar.call("try_attack")
	if enemy.current_health >= starting_health:
		_fail("Familiar should damage a nearby enemy when attacking.")
		return

	player.queue_free()
	enemy.queue_free()
	await process_frame

func _assert_evolution_extends_familiar_attack_reach() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(player)
	player.global_position = Vector2(100, 100)
	await process_frame

	var familiar := player.get_node("Familiar") as Node2D
	familiar.global_position = Vector2(100, 100)
	enemy.global_position = familiar.global_position + Vector2(float(familiar.get("attack_range")) + 20.0, 0.0)
	root.add_child(enemy)
	var starting_health := enemy.current_health
	if bool(familiar.call("try_attack")):
		_fail("Base familiar should not attack outside its base range.")
		return
	if enemy.current_health != starting_health:
		_fail("Base familiar should not damage enemies outside base range.")
		return

	familiar.call("gain_xp", 520)
	if str(familiar.get("evolution_stage")) != "sprite":
		_fail("Familiar should evolve to sprite at level 4 before testing extended reach.")
		return
	if not bool(familiar.call("try_attack")):
		_fail("Sprite evolution should extend familiar attack reach beyond the base range. Distance: %.1f, reach: %.1f, enemies: %d." % [familiar.global_position.distance_to(enemy.global_position), float(familiar.call("effective_attack_range")), familiar.get_tree().get_nodes_in_group("enemies").size()])
		return
	if enemy.current_health >= starting_health:
		_fail("Sprite evolution should damage enemies inside its extended reach.")
		return

	player.queue_free()
	enemy.queue_free()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
