extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_party_manager_recruits_witch_once()
	if _failed:
		return
	await _assert_game_world_recruits_and_swaps_witch()
	if _failed:
		return
	await _assert_damaged_shrine_triggers_witch_recruitment()
	if _failed:
		return
	print("PASS: witch recruitment")
	quit(0)

func _assert_party_manager_recruits_witch_once() -> void:
	if not ResourceLoader.exists("res://scripts/core/party_manager.gd"):
		_fail("Party manager script should exist for recruitment and swap state.")
		return
	var party_manager_script := load("res://scripts/core/party_manager.gd") as Script
	var state := GameState.new()
	var manager := party_manager_script.new() as Object
	if not manager.has_method("initialize_starter"):
		_fail("Party manager should initialize starter party state.")
		return
	manager.call("initialize_starter", state, "ronin", "Akio")
	if state.active_party_ids != ["ronin"]:
		_fail("Initial party should contain only the selected starter.")
		return
	if not manager.has_method("recruit_character"):
		_fail("Party manager should recruit characters into party state.")
		return
	if not bool(manager.call("recruit_character", state, "black_witch", "Mira")):
		_fail("Witch recruitment should succeed the first time.")
		return
	if bool(manager.call("recruit_character", state, "black_witch", "Mira")):
		_fail("Witch recruitment should not duplicate an existing recruit.")
		return
	if state.active_party_ids != ["ronin", "black_witch"]:
		_fail("Witch recruitment should add Witch to active slot 2.")
		return
	var witch_state := state.party_roster.get("black_witch", {}) as Dictionary
	if str(witch_state.get("character_name", "")) != "Mira":
		_fail("Witch recruitment should store the recruited name.")
		return
	if not (witch_state.get("learned_attack_skills", []) as Array).has("ashen_hexburst"):
		_fail("Witch recruitment should grant Ashen Hexburst placeholder skill.")
		return

func _assert_game_world_recruits_and_swaps_witch() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame

	var state := world.get("state") as GameState
	if state == null:
		_fail("GameWorld should create state for recruitment.")
		return
	if not state.active_party_ids.has("warden"):
		_fail("Legacy new game should initialize starter party state from selected class.")
		return
	if not world.has_method("recruit_witch"):
		_fail("GameWorld should expose recruit_witch().")
		return
	if not bool(world.call("recruit_witch", "Mira")):
		_fail("GameWorld should recruit Witch once.")
		return
	if bool(world.call("recruit_witch", "Mira")):
		_fail("GameWorld should ignore repeat Witch recruitment.")
		return
	if state.active_party_ids.size() != 2 or state.active_party_ids[1] != "black_witch":
		_fail("Witch should occupy active party slot 2 after recruitment.")
		return
	if int(state.get("momentum")) <= 0:
		_fail("Recruitment should initialize Momentum for swapping.")
		return
	var player_before := world.get("player") as Player
	var swap_position := player_before.global_position
	if not world.has_method("swap_active_party_slot"):
		_fail("GameWorld should expose swap_active_party_slot().")
		return
	if not bool(world.call("swap_active_party_slot", 1)):
		_fail("Player should be able to swap to Witch in active slot 2.")
		return
	await process_frame
	if state.selected_class != "hexbinder" or state.selected_starter_id != "black_witch":
		_fail("Swapping to Witch should update active class identity.")
		return
	var swapped_player := world.get("player") as Player
	if swapped_player == null or swapped_player.global_position.distance_to(swap_position) > 12.0:
		_fail("Party swap should keep the player in place. Expected %s, got %s." % [str(swap_position), str(swapped_player.global_position if swapped_player != null else Vector2.INF)])
		return
	if int(state.get("momentum")) >= 100:
		_fail("Party swap should spend Momentum.")
		return
	var hud := world.get("hud") as HUD
	if hud == null or not hud.has_method("set_party_status"):
		_fail("HUD should expose party status for active party and Momentum ring.")
		return

	world.queue_free()
	await process_frame

func _assert_damaged_shrine_triggers_witch_recruitment() -> void:
	if not ResourceLoader.exists("res://scenes/world/DamagedShrine.tscn"):
		_fail("Damaged Shrine scene should exist for Witch recruitment.")
		return
	var shrine_scene := load("res://scenes/world/DamagedShrine.tscn") as PackedScene
	var shrine := shrine_scene.instantiate()
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	world.add_child(shrine)
	if not shrine.has_signal("witch_recruited"):
		_fail("Damaged Shrine should emit witch_recruited when activated.")
		return
	var player := world.get("player") as Player
	shrine.call("_on_body_entered", player)
	await process_frame
	var state := world.get("state") as GameState
	if state == null or not state.active_party_ids.has("black_witch"):
		_fail("Damaged Shrine activation should recruit Witch through GameWorld.")
		return
	shrine.call("_on_body_entered", player)
	if state.active_party_ids.count("black_witch") != 1:
		_fail("Damaged Shrine activation should not recruit Witch more than once.")
		return
	world.queue_free()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
