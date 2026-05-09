extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")
const GUNSLINGER_DATA := preload("res://data/classes/gunslinger.tres")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_melee_attack_damages_enemy()
	await _assert_projectile_attack_damages_enemy()
	await _assert_enemy_death_signal_grants_xp()
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
