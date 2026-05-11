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

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
