extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")
const GUNSLINGER_DATA := preload("res://data/classes/gunslinger.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_melee_attack_damages_enemy()
	await _assert_melee_attack_has_playable_reach()
	await _assert_projectile_attack_damages_enemy()
	await _assert_enemy_death_signal_grants_xp()
	await _assert_restore_resource_caps_at_max_and_emits_stats()
	print("PASS: player combat")
	quit(0)

func _assert_melee_attack_damages_enemy() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(player)
	root.add_child(enemy)
	player.setup(WARDEN_DATA, "")
	player.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(126, 100)
	await process_frame
	await physics_frame
	var starting_health := enemy.current_health
	player.perform_melee_attack(10)
	await physics_frame
	if enemy.current_health >= starting_health:
		push_error("Melee attack should damage an enemy inside the attack box")
		quit(1)
	player.free()
	enemy.free()

func _assert_melee_attack_has_playable_reach() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(player)
	root.add_child(enemy)
	player.setup(WARDEN_DATA, "")
	player.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(160, 100)
	await process_frame
	await physics_frame
	var starting_health := enemy.current_health
	player.perform_melee_attack(10)
	await physics_frame
	if enemy.current_health >= starting_health:
		push_error("Melee attack should reach a monster at normal play spacing.")
		quit(1)
	player.free()
	enemy.free()

func _assert_projectile_attack_damages_enemy() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(player)
	root.add_child(enemy)
	player.setup(GUNSLINGER_DATA, "")
	player.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(160, 88)
	await process_frame
	await physics_frame
	var starting_health := enemy.current_health
	player.fire_projectile(10)
	for _i in range(12):
		await physics_frame
	if enemy.current_health >= starting_health:
		push_error("Projectile attack should damage an enemy in front of the player")
		quit(1)
	player.free()
	enemy.free()

func _assert_enemy_death_signal_grants_xp() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	var enemy := CRAWLER_SCENE.instantiate() as Enemy
	root.add_child(player)
	root.add_child(enemy)
	player.setup(WARDEN_DATA, "")
	enemy.died.connect(func(_enemy_id: String, xp_reward: int) -> void:
		player.gain_xp(xp_reward)
	)
	player.global_position = Vector2(100, 100)
	enemy.global_position = Vector2(126, 100)
	await process_frame
	await physics_frame
	player.perform_melee_attack(999)
	await physics_frame
	if player.xp <= 0:
		push_error("Enemy death signal should grant XP through the connected game-world path")
		quit(1)
	player.free()

func _assert_restore_resource_caps_at_max_and_emits_stats() -> void:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.setup(WARDEN_DATA, "")
	var max_resource := int(player.get_stats().get("max_resource", 0))
	player.current_resource = max_resource - 2
	var stats_events := {"count": 0}
	player.stats_changed.connect(func(_stats: Dictionary) -> void:
		stats_events["count"] = int(stats_events["count"]) + 1
	)
	if not player.has_method("restore_resource"):
		push_error("Player should expose restore_resource for enemy defeat rewards.")
		quit(1)
		return
	player.restore_resource(10)
	if player.current_resource != max_resource:
		push_error("restore_resource should restore resource without exceeding max resource.")
		quit(1)
	if int(stats_events["count"]) <= 0:
		push_error("restore_resource should emit stats_changed so HUD resource bars update.")
		quit(1)
	player.free()
