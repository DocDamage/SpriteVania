extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_party_manager_recruits_shadow_as_slot_three()
	if _failed:
		return
	await _assert_world_recruits_shadow_and_swaps_three_characters()
	if _failed:
		return
	await _assert_shadow_prison_triggers_shadow_recruitment()
	if _failed:
		return
	await _assert_ko_auto_switch_selects_living_character()
	if _failed:
		return
	print("PASS: shadow recruitment")
	quit(0)

func _assert_party_manager_recruits_shadow_as_slot_three() -> void:
	var party_manager_script := load("res://scripts/core/party_manager.gd") as Script
	var state := GameState.new()
	var manager := party_manager_script.new() as Object
	manager.call("initialize_starter", state, "ronin", "Akio")
	manager.call("recruit_character", state, "black_witch", "Mira")
	if not bool(manager.call("recruit_character", state, "shadow", "Ren")):
		_fail("Shadow recruitment should succeed after Witch.")
		return
	if bool(manager.call("recruit_character", state, "shadow", "Ren")):
		_fail("Shadow recruitment should not duplicate an existing recruit.")
		return
	if state.active_party_ids != ["ronin", "black_witch", "shadow"]:
		_fail("Shadow recruitment should add Shadow to active slot 3.")
		return
	var shadow_state := state.party_roster.get("shadow", {}) as Dictionary
	if str(shadow_state.get("character_name", "")) != "Ren":
		_fail("Shadow recruitment should store the recruited name.")
		return
	if not (shadow_state.get("learned_attack_skills", []) as Array).has("silent_arrowfall"):
		_fail("Shadow recruitment should grant Silent Arrowfall placeholder skill.")
		return

func _assert_world_recruits_shadow_and_swaps_three_characters() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	if not bool(world.call("recruit_witch", "Mira")):
		_fail("Witch setup should succeed before Shadow recruitment.")
		return
	if not world.has_method("recruit_shadow"):
		_fail("GameWorld should expose recruit_shadow().")
		return
	if not bool(world.call("recruit_shadow", "Ren")):
		_fail("GameWorld should recruit Shadow once.")
		return
	if bool(world.call("recruit_shadow", "Ren")):
		_fail("GameWorld should ignore repeat Shadow recruitment.")
		return
	var state := world.get("state") as GameState
	if state.active_party_ids != ["warden", "black_witch", "shadow"]:
		_fail("Shadow should occupy active party slot 3.")
		return
	if not bool(world.call("swap_active_party_slot", 2)):
		_fail("Player should be able to swap to Shadow in active slot 3.")
		return
	await process_frame
	if state.selected_class != "gunslinger" or state.selected_starter_id != "shadow":
		_fail("Swapping to Shadow should update active class identity.")
		return
	state.momentum = 100
	if not bool(world.call("swap_active_party_slot", 0)):
		_fail("Three-character party should allow swapping back to slot 1.")
		return
	await process_frame
	if state.active_party_index != 0:
		_fail("Swapping back to slot 1 should update active party index.")
		return
	world.queue_free()
	await process_frame

func _assert_shadow_prison_triggers_shadow_recruitment() -> void:
	if not ResourceLoader.exists("res://scenes/world/ShadowPrison.tscn"):
		_fail("Shadow Prison scene should exist for Shadow recruitment.")
		return
	var prison_scene := load("res://scenes/world/ShadowPrison.tscn") as PackedScene
	var prison := prison_scene.instantiate()
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	world.call("recruit_witch", "Mira")
	world.add_child(prison)
	if not prison.has_signal("shadow_recruited"):
		_fail("Shadow Prison should emit shadow_recruited when activated.")
		return
	var player := world.get("player") as Player
	prison.call("_on_body_entered", player)
	await process_frame
	var state := world.get("state") as GameState
	if state == null or not state.active_party_ids.has("shadow"):
		_fail("Shadow Prison activation should recruit Shadow through GameWorld.")
		return
	prison.call("_on_body_entered", player)
	if state.active_party_ids.count("shadow") != 1:
		_fail("Shadow Prison activation should not recruit Shadow more than once.")
		return
	world.queue_free()
	await process_frame

func _assert_ko_auto_switch_selects_living_character() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	world.call("recruit_witch", "Mira")
	world.call("recruit_shadow", "Ren")
	var state := world.get("state") as GameState
	state.momentum = 100
	if not bool(world.call("swap_active_party_slot", 1)):
		_fail("Test setup should allow swapping to Witch before KO.")
		return
	state.momentum = 0
	if not world.has_method("auto_switch_on_ko"):
		_fail("GameWorld should expose auto_switch_on_ko().")
		return
	if not bool(world.call("auto_switch_on_ko")):
		_fail("KO auto-switch should select another active party member without Momentum.")
		return
	if state.active_party_index == 1:
		_fail("KO auto-switch should leave the KO'd active slot.")
		return
	world.queue_free()
	await process_frame

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
