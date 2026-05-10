extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_enemy_overlap_damages_player()
	await _assert_enemy_contact_damages_player()
	print("PASS: enemy contact damage")
	quit(0)

func _assert_enemy_overlap_damages_player() -> void:
	var player := PLAYER_SCENE.instantiate() as Node2D
	var enemy := CRAWLER_SCENE.instantiate() as Node2D
	player.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(100, 100)
	root.add_child(player)
	root.add_child(enemy)
	player.call("setup", WARDEN_DATA, "")
	await process_frame
	for _i: int in range(4):
		await physics_frame
		await process_frame

	if int(player.get("current_health")) >= int(WARDEN_DATA.max_health):
		_fail("Enemy contact hitbox should damage the player through real overlap detection.")
		return

	player.queue_free()
	enemy.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _assert_enemy_contact_damages_player() -> void:
	var player := PLAYER_SCENE.instantiate() as Node
	var enemy := CRAWLER_SCENE.instantiate() as Node
	player.set("global_position", Vector2(100, 100))
	enemy.set("global_position", Vector2(300, 100))
	root.add_child(player)
	root.add_child(enemy)
	player.call("setup", WARDEN_DATA, "")
	await process_frame
	await physics_frame

	if not player.is_in_group("player"):
		_fail("Player should be registered in the player group.")
		return
	if enemy.get_node_or_null("ContactHitbox") == null:
		_fail("Enemy should create a contact damage hitbox.")
		return

	var starting_health := int(player.get("current_health"))
	enemy.call("_on_contact_body_entered", player)
	enemy.call("_tick_contact_damage", 0.016)
	if int(player.get("current_health")) >= starting_health:
		_fail("Enemy contact should damage the player.")
		return

	var after_contact := int(player.get("current_health"))
	enemy.call("_tick_contact_damage", 0.016)
	if int(player.get("current_health")) != after_contact:
		_fail("Enemy contact cooldown should prevent immediate repeat damage.")
		return

	enemy.call("_tick_contact_damage", float(enemy.get("contact_damage_cooldown")))
	if int(player.get("current_health")) >= after_contact:
		_fail("Enemy contact should damage again after the cooldown expires.")
		return

	player.queue_free()
	enemy.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
