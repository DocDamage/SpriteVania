extends SceneTree

const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const MINIBOSS_SCENE := preload("res://scenes/enemies/SwampMiniBoss.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_crawler_reverses_at_patrol_bounds()
	if _failed:
		return
	await _assert_crawler_aggro_stays_inside_patrol_route()
	if _failed:
		return
	await _assert_crawler_attacks_nearby_player_then_returns_to_patrol()
	if _failed:
		return
	await _assert_crawler_attack_damages_player_without_body_overlap()
	if _failed:
		return
	await _assert_crawler_shows_aggro_feedback_while_chasing()
	if _failed:
		return
	await _assert_crawler_shows_attack_window_feedback()
	if _failed:
		return
	await _assert_enemy_shows_hurt_feedback_when_damaged()
	if _failed:
		return
	await _assert_enemy_death_keeps_xp_signal_and_exposes_drop()
	if _failed:
		return
	await _assert_miniboss_leap_resets_cooldown_and_velocity()
	if _failed:
		return
	await _assert_miniboss_patterns_are_deterministic()
	if _failed:
		return
	await _assert_miniboss_slam_damages_and_knocks_back_target_in_range()
	if _failed:
		return
	await _assert_miniboss_slam_hits_each_target_once_per_window()
	if _failed:
		return
	print("PASS: enemy behavior")
	quit(0)

func _assert_crawler_reverses_at_patrol_bounds() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as CharacterBody2D
	crawler.global_position = Vector2(100, 100)
	crawler.set("patrol_left", -16.0)
	crawler.set("patrol_right", 16.0)
	root.add_child(crawler)
	await process_frame

	crawler.global_position = Vector2(116, 100)
	crawler.set("direction", 1.0)
	crawler.call("_update_patrol_direction")
	var right_bound_direction: float = crawler.get("direction")
	if right_bound_direction >= 0.0:
		_fail("Crawler should reverse left when it reaches the right patrol bound.")
		return

	crawler.global_position = Vector2(84, 100)
	crawler.set("direction", -1.0)
	crawler.call("_update_patrol_direction")
	var left_bound_direction: float = crawler.get("direction")
	if left_bound_direction <= 0.0:
		_fail("Crawler should reverse right when it reaches the left patrol bound.")
		return

	crawler.queue_free()
	await process_frame

func _assert_crawler_aggro_stays_inside_patrol_route() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as CharacterBody2D
	var player := Node2D.new()
	player.name = "PlayerProbe"
	player.add_to_group("player")
	crawler.global_position = Vector2(100, 100)
	crawler.set("patrol_left", -20.0)
	crawler.set("patrol_right", 20.0)
	crawler.set("aggro_range", 240.0)
	player.global_position = Vector2(220, 100)
	root.add_child(crawler)
	root.add_child(player)
	await process_frame

	crawler.global_position = Vector2(121, 100)
	crawler.set("direction", 1.0)
	crawler.call("_physics_process", 0.016)
	if crawler.velocity.x > 0.0:
		_fail("Crawler should not chase beyond its right patrol route.")
		return
	if str(crawler.get("behavior_state")) != "recover":
		_fail("Crawler should pause in recover when aggro would pull it outside its route.")
		return
	if not bool(crawler.get("is_aggro_alert")):
		_fail("Crawler should expose aggro alert feedback while reacting to a blocked chase.")
		return

	crawler.queue_free()
	player.queue_free()
	await process_frame

func _assert_crawler_attacks_nearby_player_then_returns_to_patrol() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as CharacterBody2D
	var player := Node2D.new()
	player.name = "PlayerProbe"
	player.add_to_group("player")
	crawler.global_position = Vector2(100, 100)
	player.global_position = Vector2(118, 100)
	root.add_child(crawler)
	root.add_child(player)
	await process_frame

	crawler.call("_physics_process", 0.016)
	if str(crawler.get("behavior_state")) != "attack":
		_fail("Crawler should enter an explicit attack window when a player is in attack range.")
		return
	if not bool(crawler.get("is_attack_active")):
		_fail("Crawler attack window should be marked active.")
		return

	player.global_position = Vector2(400, 100)
	crawler.call("_physics_process", float(crawler.get("attack_duration")) + 0.01)
	if str(crawler.get("behavior_state")) != "patrol":
		_fail("Crawler should return to patrol after its attack window when the player is gone.")
		return
	if bool(crawler.get("is_attack_active")):
		_fail("Crawler attack window should end before returning to patrol.")
		return

	crawler.queue_free()
	player.queue_free()
	await process_frame

func _assert_crawler_attack_damages_player_without_body_overlap() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as CharacterBody2D
	var player := _DamageProbe.new()
	player.name = "DamageProbe"
	player.add_to_group("player")
	crawler.global_position = Vector2(100, 100)
	player.global_position = Vector2(138, 100)
	root.add_child(crawler)
	root.add_child(player)
	await process_frame

	crawler.call("_physics_process", 0.016)
	if player.damage_taken <= 0:
		_fail("Crawler attack should damage a nearby player during its explicit attack, not only on body overlap.")
		return
	if player.knockback_source != crawler.global_position:
		_fail("Crawler attack should apply knockback from the crawler position.")
		return

	crawler.queue_free()
	player.queue_free()
	await process_frame

func _assert_crawler_shows_aggro_feedback_while_chasing() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as CharacterBody2D
	crawler.set_physics_process(false)
	var player := Node2D.new()
	player.name = "AggroFeedbackProbe"
	player.add_to_group("player")
	crawler.global_position = Vector2(100, 100)
	player.global_position = Vector2(180, 100)
	root.add_child(crawler)
	root.add_child(player)
	await process_frame

	var aggro_indicator := crawler.get_node_or_null("%AggroIndicator") as ColorRect
	if aggro_indicator == null:
		_fail("Crawler scene should include AggroIndicator so chase state is readable.")
		return
	if aggro_indicator.visible:
		_fail("AggroIndicator should stay hidden while the crawler is not chasing.")
		return
	crawler.call("_physics_process", 0.016)
	if str(crawler.get("behavior_state")) != "aggro":
		_fail("Crawler should enter aggro state when a player is within chase range but outside attack range.")
		return
	if not bool(crawler.get("is_aggro_alert")) or not aggro_indicator.visible:
		_fail("AggroIndicator should show while the crawler is actively chasing.")
		return
	player.global_position = Vector2(500, 100)
	crawler.call("_physics_process", 0.016)
	if bool(crawler.get("is_aggro_alert")) or aggro_indicator.visible:
		_fail("AggroIndicator should hide after the crawler loses the player.")
		return

	crawler.queue_free()
	player.queue_free()
	await process_frame

func _assert_crawler_shows_attack_window_feedback() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as CharacterBody2D
	var player := Node2D.new()
	player.name = "AttackFlashProbe"
	player.add_to_group("player")
	crawler.global_position = Vector2(100, 100)
	root.add_child(crawler)
	await process_frame

	var attack_flash := crawler.get_node_or_null("%AttackFlash") as Line2D
	if attack_flash == null:
		_fail("Crawler scene should include AttackFlash so monster attacks are readable.")
		return
	if attack_flash.visible:
		_fail("Crawler AttackFlash should stay hidden until an attack starts.")
		return
	player.global_position = Vector2(126, 100)
	root.add_child(player)
	await process_frame
	crawler.call("_physics_process", 0.016)
	if not attack_flash.visible:
		_fail("Crawler AttackFlash should show during the active attack window.")
		return
	crawler.call("_physics_process", float(crawler.get("attack_duration")) + 0.01)
	if attack_flash.visible:
		_fail("Crawler AttackFlash should hide after the active attack window.")
		return

	crawler.queue_free()
	player.queue_free()
	await process_frame

func _assert_enemy_shows_hurt_feedback_when_damaged() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(crawler)
	await process_frame

	var hurt_flash := crawler.get_node_or_null("%HurtFlash") as ColorRect
	if hurt_flash == null:
		_fail("Enemy scene should include HurtFlash so successful hits are visible.")
		return
	if hurt_flash.visible:
		_fail("HurtFlash should stay hidden until the enemy takes damage.")
		return
	crawler.take_damage(1)
	if not hurt_flash.visible:
		_fail("HurtFlash should show immediately when the enemy takes damage.")
		return
	crawler.call("_process", 0.2)
	if hurt_flash.visible:
		_fail("HurtFlash should hide after its short feedback window.")
		return

	crawler.queue_free()
	await process_frame

func _assert_enemy_death_keeps_xp_signal_and_exposes_drop() -> void:
	var crawler := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(crawler)
	await process_frame

	crawler.set("enemy_id", "drop_test_crawler")
	crawler.set("drop_id", "mire_ichor")
	crawler.set("drop_amount", 2)
	var died_payload: Array = []
	var drop_payload: Array = []
	crawler.died.connect(func(enemy_id: String, xp_reward: int) -> void:
		died_payload.append_array([enemy_id, xp_reward])
	)
	crawler.dropped.connect(func(enemy_id: String, drop_id: String, drop_amount: int) -> void:
		drop_payload.append_array([enemy_id, drop_id, drop_amount])
	)

	crawler.take_damage(999)
	await process_frame

	if died_payload != ["drop_test_crawler", 25]:
		_fail("Enemy death should keep emitting died(enemy_id, xp_reward).")
		return
	if drop_payload != ["drop_test_crawler", "mire_ichor", 2]:
		_fail("Enemy death should emit optional deterministic drop data when configured.")
		return

func _assert_miniboss_leap_resets_cooldown_and_velocity() -> void:
	var miniboss := MINIBOSS_SCENE.instantiate() as CharacterBody2D
	root.add_child(miniboss)
	await process_frame

	miniboss.set("leap_cooldown", 1.25)
	miniboss.set("cooldown_remaining", 0.0)
	miniboss.call("_start_leap", -1.0)

	var cooldown_remaining: float = miniboss.get("cooldown_remaining")
	if not is_equal_approx(cooldown_remaining, 1.25):
		_fail("Miniboss leap should reset the cooldown to the configured value.")
		return
	if not is_equal_approx(miniboss.velocity.x, -120.0):
		_fail("Miniboss leap should use the requested horizontal direction.")
		return
	if not is_equal_approx(miniboss.velocity.y, -260.0):
		_fail("Miniboss leap should apply the configured upward velocity.")
		return

	miniboss.queue_free()
	await process_frame

func _assert_miniboss_patterns_are_deterministic() -> void:
	var miniboss := MINIBOSS_SCENE.instantiate() as CharacterBody2D
	root.add_child(miniboss)
	await process_frame

	miniboss.set("pattern_state", "idle")
	miniboss.set("_pattern_index", 0)
	miniboss.call("_begin_next_pattern")
	if str(miniboss.get("pattern_state")) != "telegraph_leap":
		_fail("Miniboss first pattern should telegraph a leap.")
		return
	miniboss.call("_finish_telegraph")
	if str(miniboss.get("pattern_state")) != "leap":
		_fail("Miniboss leap telegraph should advance into leap state.")
		return

	miniboss.call("_complete_pattern")
	miniboss.call("_begin_next_pattern")
	if str(miniboss.get("pattern_state")) != "telegraph_slam":
		_fail("Miniboss second pattern should deterministically telegraph a slam.")
		return
	miniboss.call("_finish_telegraph")
	if str(miniboss.get("pattern_state")) != "slam":
		_fail("Miniboss slam telegraph should advance into slam state.")
		return
	if not bool(miniboss.get("is_slam_active")):
		_fail("Miniboss slam state should expose an active slam window.")
		return

	miniboss.queue_free()
	await process_frame

func _assert_miniboss_slam_damages_and_knocks_back_target_in_range() -> void:
	var miniboss := MINIBOSS_SCENE.instantiate() as CharacterBody2D
	var player := _DamageProbe.new()
	player.name = "SlamDamageProbe"
	player.add_to_group("player")
	miniboss.global_position = Vector2(100, 100)
	player.global_position = Vector2(132, 100)
	root.add_child(miniboss)
	root.add_child(player)
	await process_frame

	miniboss.call("_start_slam")
	miniboss.call("_physics_process", 0.016)
	if player.damage_taken <= 0:
		_fail("Miniboss slam should damage a player in range during the active slam window.")
		return
	if player.knockback_source != miniboss.global_position:
		_fail("Miniboss slam should apply knockback from the miniboss position.")
		return

	miniboss.queue_free()
	player.queue_free()
	await process_frame

func _assert_miniboss_slam_hits_each_target_once_per_window() -> void:
	var miniboss := MINIBOSS_SCENE.instantiate() as CharacterBody2D
	var player := _DamageProbe.new()
	player.name = "SlamOneHitProbe"
	player.add_to_group("player")
	miniboss.global_position = Vector2(100, 100)
	player.global_position = Vector2(132, 100)
	root.add_child(miniboss)
	root.add_child(player)
	await process_frame

	miniboss.call("_start_slam")
	miniboss.call("_physics_process", 0.016)
	var damage_after_first_tick := player.damage_taken
	miniboss.call("_physics_process", 0.016)
	if player.damage_taken != damage_after_first_tick:
		_fail("Miniboss slam should damage each target at most once per active slam window.")
		return

	miniboss.queue_free()
	player.queue_free()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)

class _DamageProbe:
	extends Node2D

	var damage_taken := 0
	var knockback_source := Vector2.INF

	func take_damage(amount: int) -> void:
		damage_taken += amount

	func apply_knockback(source_position: Vector2, _strength := 0.0) -> void:
		knockback_source = source_position
