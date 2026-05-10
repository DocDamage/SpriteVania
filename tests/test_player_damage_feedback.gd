extends SceneTree

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_invulnerability_blocks_repeat_damage()
	if _failed:
		return
	await _assert_familiar_guard_reduces_incoming_damage()
	if _failed:
		return
	await _assert_lethal_damage_emits_died_after_invulnerability()
	if _failed:
		return
	await _assert_death_only_emits_once_until_restored()
	if _failed:
		return
	print("PASS: player damage feedback")
	quit(0)

func _assert_invulnerability_blocks_repeat_damage() -> void:
	var player := _spawn_player()
	player.set("invulnerability_duration", 0.1)
	player.set("hit_flash_duration", 0.05)

	var stats_changed_count := [0]
	player.stats_changed.connect(func(_stats: Dictionary) -> void:
		stats_changed_count[0] += 1
	)

	player.take_damage(20)
	var health_after_first_hit := player.current_health
	if health_after_first_hit != 126:
		_fail("First real hit should damage the Warden after defense. Expected 126, got %s." % player.current_health)
		return
	if stats_changed_count[0] != 1:
		_fail("First real hit should emit stats_changed once. Expected 1, got %s." % stats_changed_count[0])
		return
	if player.get("is_invulnerable") != true:
		_fail("Player should expose invulnerability state immediately after a real hit.")
		return
	if player.get("is_hit_flashing") != true:
		_fail("Player should expose hit flash state immediately after a real hit.")
		return

	player.take_damage(20)
	if player.current_health != health_after_first_hit:
		_fail("Immediate second hit should be ignored while invulnerable.")
		return
	if stats_changed_count[0] != 1:
		_fail("Ignored damage should not emit stats_changed. Expected 1, got %s." % stats_changed_count[0])
		return

	await _tick_feedback(player, 0.06)
	if player.get("is_hit_flashing") != false:
		_fail("Hit flash state should end after hit_flash_duration.")
		return
	if player.get("is_invulnerable") != true:
		_fail("Player should stay invulnerable after only the flash duration elapses.")
		return

	await _tick_feedback(player, 0.05)
	if player.get("is_invulnerable") != false:
		_fail("Invulnerability should end after invulnerability_duration.")
		return

	player.take_damage(20)
	if player.current_health != 112:
		_fail("Damage should apply again after invulnerability ends. Expected 112, got %s." % player.current_health)
		return
	if stats_changed_count[0] != 2:
		_fail("Second real hit should emit stats_changed. Expected 2, got %s." % stats_changed_count[0])
		return

	player.queue_free()
	await process_frame

func _assert_familiar_guard_reduces_incoming_damage() -> void:
	var player := _spawn_player()
	player.set("invulnerability_duration", 0.05)
	var familiar := player.get_node("Familiar") as Node
	familiar.call("grant_ability_upgrade", "guard")
	familiar.call("grant_ability_upgrade", "guard")

	player.take_damage(20)
	if player.current_health != 130:
		_fail("Two familiar guard levels should reduce a 20 damage hit to 10 after Warden defense. Expected 130, got %s." % player.current_health)
		return

	player.queue_free()
	await process_frame

func _assert_lethal_damage_emits_died_after_invulnerability() -> void:
	var player := _spawn_player()
	player.set("invulnerability_duration", 0.05)
	player.set("hit_flash_duration", 0.02)

	var died_count := [0]
	var stats_changed_count := [0]
	player.died.connect(func() -> void:
		died_count[0] += 1
	)
	player.stats_changed.connect(func(_stats: Dictionary) -> void:
		stats_changed_count[0] += 1
	)

	player.take_damage(20)
	await _tick_feedback(player, 0.06)
	player.take_damage(999)

	if died_count[0] != 1:
		_fail("Lethal damage should emit died when the player is no longer invulnerable. Expected 1, got %s." % died_count[0])
		return
	if stats_changed_count[0] != 2:
		_fail("Lethal real damage should still emit stats_changed. Expected 2, got %s." % stats_changed_count[0])
		return

	player.queue_free()
	await process_frame

func _assert_death_only_emits_once_until_restored() -> void:
	var player := _spawn_player()
	player.set("invulnerability_duration", 0.01)
	var died_count := [0]
	var stats_changed_count := [0]
	player.died.connect(func() -> void:
		died_count[0] += 1
	)
	player.stats_changed.connect(func(_stats: Dictionary) -> void:
		stats_changed_count[0] += 1
	)

	player.take_damage(999)
	await _tick_feedback(player, 0.02)
	player.take_damage(999)
	if died_count[0] != 1:
		_fail("Player death should only emit once until restored. Expected 1, got %s." % died_count[0])
		return
	if stats_changed_count[0] != 1:
		_fail("Damage after death should be ignored until restored. Expected one stats update, got %s." % stats_changed_count[0])
		return

	player.restore_vitals_to_max()
	await _tick_feedback(player, 0.02)
	player.take_damage(999)
	if died_count[0] != 2:
		_fail("Restoring vitals should allow the player to die again. Expected 2 deaths, got %s." % died_count[0])
		return

	player.queue_free()
	await process_frame

func _spawn_player() -> Player:
	var player := PLAYER_SCENE.instantiate() as Player
	root.add_child(player)
	player.setup(WARDEN_DATA, "")
	return player

func _tick_feedback(player: Player, delta: float) -> void:
	player.call("_process", delta)
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
