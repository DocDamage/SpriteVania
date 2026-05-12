extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_air_dash_is_limited_until_landing()
	if _failed:
		return
	await _assert_dash_stops_on_wall_collision()
	if _failed:
		return
	await _assert_double_jump_is_limited_until_landing()
	if _failed:
		return
	print("PASS: player movement")
	quit(0)

func _assert_air_dash_is_limited_until_landing() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.setup(WARDEN_DATA, "")
	player.global_position = Vector2(100, 100)
	player.facing_direction = 1.0
	player.velocity = Vector2.ZERO

	player.perform_dash()
	if not bool(player.get("is_dashing")):
		_fail("Player should be able to dash while airborne.")
		return
	for _i in range(24):
		player._process(1.0 / 60.0)
		player._physics_process(1.0 / 60.0)
	if bool(player.get("is_dashing")):
		_fail("Air dash should finish after its active dash window.")
		return

	var x_after_first_dash := player.global_position.x
	player.perform_dash()
	if bool(player.get("is_dashing")) or player.global_position.x > x_after_first_dash:
		_fail("Player should not be able to air dash again before landing.")
		return

	var floor := StaticBody2D.new()
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(220, 20)
	floor_shape.shape = rectangle
	floor.add_child(floor_shape)
	floor.global_position = Vector2(player.global_position.x, player.global_position.y + 30.0)
	root.add_child(floor)
	player.velocity = Vector2(0, 260)
	for _i in range(20):
		player._process(1.0 / 60.0)
		player._physics_process(1.0 / 60.0)
	if not player.is_on_floor():
		_fail("Movement test setup should land the player on the floor.")
		return

	player.perform_dash()
	if not bool(player.get("is_dashing")):
		_fail("Landing should reset the air dash budget.")
		return

	player.free()
	floor.free()

func _assert_dash_stops_on_wall_collision() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.setup(WARDEN_DATA, "")
	player.global_position = Vector2(100, 100)
	player.facing_direction = 1.0
	player.velocity = Vector2.ZERO

	var wall := _make_static_rect(Vector2(20, 90), Vector2(142, 100))
	root.add_child(wall)
	await process_frame

	player.perform_dash()
	if not bool(player.get("is_dashing")):
		_fail("Player should begin dash before reaching a wall.")
		return
	for _i in range(12):
		player._process(1.0 / 60.0)
		player._physics_process(1.0 / 60.0)
		if not bool(player.get("is_dashing")):
			break
	if bool(player.get("is_dashing")):
		_fail("Dash should end immediately when colliding with a wall.")
		return
	if player.global_position.x > 132.0:
		_fail("Dash should not carry the player through wall collision.")
		return

	player.free()
	wall.free()

func _assert_double_jump_is_limited_until_landing() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.setup(WARDEN_DATA, "")
	player.global_position = Vector2(100, 100)
	player.velocity = Vector2(0, 80)

	player.perform_jump()
	if player.velocity.y >= 0.0:
		_fail("Player should be able to spend one double jump while airborne.")
		return
	var first_jump_velocity := player.velocity.y
	player.velocity.y = 40.0
	player.perform_jump()
	if player.velocity.y != 40.0:
		_fail("Player should not be able to double jump twice before landing.")
		return

	var floor := _make_static_rect(Vector2(220, 20), Vector2(player.global_position.x, player.global_position.y + 30.0))
	root.add_child(floor)
	player.velocity = Vector2(0, 260)
	for _i in range(20):
		player._process(1.0 / 60.0)
		player._physics_process(1.0 / 60.0)
	if not player.is_on_floor():
		_fail("Double jump test setup should land the player on the floor.")
		return

	player.velocity = Vector2(0, 80)
	player.perform_jump()
	if player.velocity.y != first_jump_velocity:
		_fail("Landing should reset the double jump budget.")
		return

	player.free()
	floor.free()

func _make_static_rect(size: Vector2, position: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	body.add_child(shape)
	body.global_position = position
	return body

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
