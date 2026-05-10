extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")
const GUNSLINGER_DATA := preload("res://data/classes/gunslinger.tres")
const HEXBINDER_DATA := preload("res://data/classes/hexbinder.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_player_has_baseline_double_jump_and_dash()
	await _assert_player_has_baseline_wall_hang_and_wall_jump()
	await _assert_slide_attack_damages_enemy()
	await _assert_locked_attack_skills_do_not_fire()
	await _assert_warden_guard_counter_consumes_resource_and_cooldown()
	await _assert_gunslinger_piercing_shot_hits_multiple_targets()
	await _assert_hexbinder_binding_sigil_damages_nearby_targets()
	await _assert_traversal_skills_consume_resource_and_cooldown()
	print("PASS: class abilities")
	quit(0)

func _assert_player_has_baseline_double_jump_and_dash() -> void:
	var player := _spawn_player(WARDEN_DATA)
	player.velocity = Vector2(0, 120)
	player.set("_air_jumps_remaining", 1)
	player.perform_jump()
	if player.velocity.y >= 0.0:
		_fail("Player should be able to spend an air jump for a double jump.")
		return
	if int(player.get("_air_jumps_remaining")) != 0:
		_fail("Double jump should consume the available air jump.")
		return

	player.global_position = Vector2(100, 100)
	player.facing_direction = 1.0
	player.velocity = Vector2(0, -80)
	var dash_trail := player.get_node_or_null("%DashTrail") as Line2D
	if dash_trail == null:
		_fail("Player scene should include a DashTrail visual so dash reads as motion.")
		return
	if dash_trail.visible:
		_fail("DashTrail should stay hidden until a dash starts.")
		return
	player.perform_dash()
	if player.global_position.x != 100.0:
		_fail("Dash should begin as a velocity-driven burst, not an instant teleport.")
		return
	if player.velocity.y != 0.0:
		_fail("Dash should flatten vertical velocity for readable ground and air movement.")
		return
	if not bool(player.get("is_dashing")):
		_fail("Player should expose an active dash state while the burst is in progress.")
		return
	if not dash_trail.visible:
		_fail("DashTrail should become visible during the active dash burst.")
		return
	player._physics_process(1.0 / 60.0)
	if player.global_position.x <= 100.0:
		_fail("Player should move forward during the active dash frames.")
		return
	for _i in range(12):
		player._physics_process(1.0 / 60.0)
	if bool(player.get("is_dashing")) or dash_trail.visible:
		_fail("DashTrail should hide again when the dash burst finishes.")
		return
	player.free()

func _assert_player_has_baseline_wall_hang_and_wall_jump() -> void:
	var player := _spawn_player(WARDEN_DATA)
	player.velocity = Vector2(0, 220)
	player.facing_direction = 1.0
	player.call("start_wall_hang", 1.0)
	if not bool(player.get("is_wall_hanging")):
		_fail("Player should expose a wall hang state.")
		return
	if player.velocity.y > 0.0:
		_fail("Wall hang should stop downward fall speed.")
		return

	player.perform_jump()
	if bool(player.get("is_wall_hanging")):
		_fail("Wall jump should leave the wall hang state.")
		return
	if player.velocity.y >= 0.0 or player.velocity.x >= 0.0:
		_fail("Wall jump should launch upward and away from the wall.")
		return
	player.free()

func _assert_slide_attack_damages_enemy() -> void:
	var player := _spawn_player(GUNSLINGER_DATA)
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(enemy)
	enemy.global_position = player.global_position + Vector2(56, 0)
	player.set_traversal_unlocks(["combat_slide"])
	player.current_resource = 60
	await physics_frame

	var starting_health := enemy.current_health
	player.perform_slide()
	await physics_frame
	if enemy.current_health >= starting_health:
		_fail("Slide attack should damage an enemy in the slide path.")
		return
	if player.current_resource != 54:
		_fail("Slide attack should consume the combat slide resource cost.")
		return
	player.free()
	enemy.free()

func _assert_locked_attack_skills_do_not_fire() -> void:
	var player := _spawn_player(GUNSLINGER_DATA)
	player.current_resource = 60
	player.class_controller.call("handle_special_attack")
	await physics_frame
	if _projectile_count() != 0:
		_fail("Gunslinger piercing shot should not fire before piercing_shot is learned.")
		return
	if player.current_resource != 60:
		_fail("Locked attack skills should not consume resource.")
		return
	player.free()

func _assert_warden_guard_counter_consumes_resource_and_cooldown() -> void:
	var player := _spawn_player(WARDEN_DATA)
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(enemy)
	enemy.global_position = player.global_position + Vector2(26, 0)
	player.set_learned_attack_skills(["guard_counter"])
	player.current_resource = 40
	await physics_frame

	var starting_health := enemy.current_health
	player.class_controller.call("handle_special_attack")
	await physics_frame
	if enemy.current_health >= starting_health:
		_fail("Warden guard counter should damage an enemy after unlock.")
		return
	if player.current_resource != 28:
		_fail("Warden guard counter should consume 12 resource.")
		return

	var health_after_first := enemy.current_health
	player.class_controller.call("handle_special_attack")
	await physics_frame
	if enemy.current_health != health_after_first:
		_fail("Warden guard counter should respect cooldown.")
		return
	player.free()
	enemy.free()

func _assert_gunslinger_piercing_shot_hits_multiple_targets() -> void:
	var player := _spawn_player(GUNSLINGER_DATA)
	var first := CRAWLER_SCENE.instantiate() as Enemy
	var second := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(first)
	root.add_child(second)
	first.global_position = player.global_position + Vector2(60, -12)
	second.global_position = player.global_position + Vector2(98, -12)
	player.set_learned_attack_skills(["piercing_shot"])
	player.current_resource = 60
	await physics_frame

	var first_start := first.current_health
	var second_start := second.current_health
	player.class_controller.call("handle_special_attack")
	for _i in range(18):
		await physics_frame
	if first.current_health >= first_start or second.current_health >= second_start:
		_fail("Piercing shot should damage multiple targets in its path.")
		return
	if player.current_resource != 50:
		_fail("Piercing shot should consume 10 resource.")
		return
	player.free()
	first.free()
	second.free()

func _assert_hexbinder_binding_sigil_damages_nearby_targets() -> void:
	var player := _spawn_player(HEXBINDER_DATA)
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(enemy)
	enemy.global_position = player.global_position + Vector2(42, 0)
	player.set_learned_attack_skills(["binding_sigil"])
	player.current_resource = 100
	await physics_frame

	var starting_health := enemy.current_health
	player.class_controller.call("handle_special_attack")
	await physics_frame
	if enemy.current_health >= starting_health:
		_fail("Hexbinder binding sigil should damage a nearby target after unlock.")
		return
	if player.current_resource != 82:
		_fail("Binding sigil should consume 18 resource.")
		return
	player.free()
	enemy.free()

func _assert_traversal_skills_consume_resource_and_cooldown() -> void:
	var player := _spawn_player(HEXBINDER_DATA)
	player.set_traversal_unlocks(["blink"])
	player.current_resource = 100
	var start_x := player.global_position.x
	player.class_controller.call("handle_class_action")
	if player.global_position.x <= start_x:
		_fail("Hexbinder blink should move forward after unlock.")
		return
	if player.current_resource != 92:
		_fail("Hexbinder blink should consume 8 resource.")
		return
	var x_after_first := player.global_position.x
	player.class_controller.call("handle_class_action")
	if player.global_position.x != x_after_first:
		_fail("Hexbinder blink should respect traversal cooldown.")
		return
	player.free()

func _spawn_player(class_data: Resource) -> Player:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.setup(class_data, "")
	player.global_position = Vector2(100, 100)
	player.facing_direction = 1.0
	return player

func _projectile_count() -> int:
	var count := 0
	for child: Node in root.get_children():
		if child is PlayerProjectile:
			count += 1
	return count

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
