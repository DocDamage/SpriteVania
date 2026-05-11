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
	await _assert_familiar_visuals_track_evolution()
	if _failed:
		return
	await _assert_familiar_state_sanitizes_invalid_saved_data()
	if _failed:
		return
	await _assert_familiar_handles_missing_target_and_invalid_enemies()
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
	if not ("max_follow_distance" in familiar):
		_fail("Familiar should expose max_follow_distance to stabilize long-distance follow.")
		return
	familiar.global_position = Vector2(-1000, 100)
	player.global_position = Vector2(200, 100)
	familiar.call("_physics_process", 0.016)
	var max_follow_distance := float(familiar.get("max_follow_distance"))
	if familiar.global_position.distance_to(player.global_position) > max_follow_distance:
		_fail("Familiar should snap back inside max_follow_distance when it falls too far behind.")
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
	var far_enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(player)
	await process_frame
	var familiar := player.get_node("Familiar") as Node2D
	familiar.set_physics_process(false)
	root.add_child(enemy)
	root.add_child(far_enemy)
	player.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(132, 100)
	far_enemy.global_position = Vector2(182, 100)
	await process_frame

	familiar.global_position = Vector2(110, 100)
	var starting_health := enemy.current_health
	var far_starting_health := far_enemy.current_health
	familiar.call("try_attack")
	if enemy.current_health >= starting_health:
		_fail("Familiar should damage a nearby enemy when attacking.")
		return
	if far_enemy.current_health != far_starting_health:
		_fail("Familiar target selection should attack the nearest enemy first.")
		return

	player.queue_free()
	enemy.queue_free()
	far_enemy.queue_free()
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

func _assert_familiar_visuals_track_evolution() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	await process_frame
	var familiar := player.get_node("Familiar") as Node2D
	if not familiar.has_method("get_visual_status"):
		_fail("Familiar should expose visual status for verifying evolution polish.")
		return

	var spark_status := familiar.call("get_visual_status") as Dictionary
	if str(spark_status.get("stage", "")) != "spark":
		_fail("Familiar visuals should start in the spark stage.")
		return
	if str(spark_status.get("body_texture", "")) != "res://SpriteVania Assets/familiar_owl_idle.png":
		_fail("Familiar should use the imported owl sprite texture, not only procedural glow.")
		return
	if bool(spark_status.get("ring_visible", true)):
		_fail("Spark familiar should not show its evolved stage ring.")
		return

	familiar.call("gain_xp", 520)
	var sprite_status := familiar.call("get_visual_status") as Dictionary
	if str(sprite_status.get("stage", "")) != "sprite":
		_fail("Familiar visual status should track sprite evolution.")
		return
	if not bool(sprite_status.get("ring_visible", false)):
		_fail("Sprite evolution should enable the familiar stage ring.")
		return
	if float(sprite_status.get("glow_scale_x", 0.0)) <= float(spark_status.get("glow_scale_x", 0.0)):
		_fail("Familiar glow should grow as it evolves.")
		return

	familiar.call("gain_xp", 1320)
	var guardian_status := familiar.call("get_visual_status") as Dictionary
	if str(guardian_status.get("stage", "")) != "guardian":
		_fail("Familiar visual status should track guardian evolution.")
		return
	if str(guardian_status.get("core_color", "")) == str(sprite_status.get("core_color", "")):
		_fail("Guardian familiar should have a distinct core color from sprite.")
		return

	player.queue_free()
	await process_frame

func _assert_familiar_state_sanitizes_invalid_saved_data() -> void:
	var familiar := FAMILIAR_SCRIPT.new() as Node2D
	root.add_child(familiar)
	await process_frame

	familiar.call("apply_state", {
		"level": -3,
		"xp": -5,
		"ability_points": -2,
		"ability_levels": {
			"sting": -99,
			"focus": 2.7,
			"unknown": 7,
		},
	})
	if int(familiar.get("level")) != 1 or int(familiar.get("xp")) != 0 or int(familiar.get("ability_points")) != 0:
		_fail("Familiar apply_state should clamp negative level, XP, and ability points.")
		return
	var ability_levels := familiar.get("ability_levels") as Dictionary
	if ability_levels.has("unknown") or int(ability_levels.get("sting", -1)) != 0 or int(ability_levels.get("focus", 0)) != 2:
		_fail("Familiar apply_state should keep only known, non-negative ability levels.")
		return
	if str(familiar.get("evolution_stage")) != "spark":
		_fail("Familiar apply_state should derive evolution from sanitized level.")
		return

	familiar.queue_free()
	await process_frame

func _assert_familiar_handles_missing_target_and_invalid_enemies() -> void:
	var familiar := FAMILIAR_SCRIPT.new() as Node2D
	root.add_child(familiar)
	await process_frame
	familiar.call("_physics_process", 0.016)

	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(enemy)
	enemy.global_position = familiar.global_position
	enemy.queue_free()
	await process_frame
	if bool(familiar.call("try_attack")):
		_fail("Familiar should ignore enemies that have already left the scene tree.")
		return

	familiar.queue_free()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
