extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const FAMILIAR_SCRIPT := preload("res://scripts/player/player_familiar.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
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
	print("PASS: familiar")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
