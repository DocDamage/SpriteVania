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
	await _assert_miniboss_leap_resets_cooldown_and_velocity()
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

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
