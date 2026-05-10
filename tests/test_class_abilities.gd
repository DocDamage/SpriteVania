extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")
const GUNSLINGER_DATA := preload("res://data/classes/gunslinger.tres")
const HEXBINDER_DATA := preload("res://data/classes/hexbinder.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_locked_attack_skills_do_not_fire()
	await _assert_warden_guard_counter_consumes_resource_and_cooldown()
	await _assert_gunslinger_piercing_shot_hits_multiple_targets()
	await _assert_hexbinder_binding_sigil_damages_nearby_targets()
	await _assert_traversal_skills_consume_resource_and_cooldown()
	print("PASS: class abilities")
	quit(0)

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
