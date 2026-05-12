extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_save_shrine_saves_heals_and_clears_ko()
	await _assert_continue_from_hub_save_loads_safely()
	await _assert_party_shrine_opens_and_cancels_without_mutation()
	await _assert_party_shrine_commits_party_order_and_rename()
	await _assert_party_shrine_rejects_invalid_commit_without_mutation()
	await _assert_party_shrine_rejects_invalid_rename_without_mutation()
	await _assert_training_dummy_takes_damage_without_progression_reward()
	await _assert_moonpetal_passage_is_locked_placeholder()
	print("PASS: sakuramori services")
	quit(0)

func _assert_save_shrine_saves_heals_and_clears_ko() -> void:
	var save_manager := root.get_node_or_null("/root/SaveManager")
	if save_manager != null:
		save_manager.set("save_path", "user://test_sakuramori_services_save.json")
		save_manager.call("delete_save")

	var world := _new_world_in_room("SakuramoriCourt_SaveShrine")
	var state := world.get("state") as GameState
	var player := world.get("player") as Player
	player.current_health = 12
	player.current_resource = 3
	state.party_roster[state.active_party_ids[0]]["is_ko"] = true
	state.party_roster[state.active_party_ids[0]]["current_health"] = 0

	var shrine := _find_node_with_method(world.get("current_room"), "activate_save_service")
	if shrine == null:
		_fail("Sakuramori Save Shrine should expose activate_save_service.")
		return
	if not bool(shrine.call("activate_save_service", world)):
		_fail("Sakuramori Save Shrine should save successfully.")
		return
	if state.checkpoint_id != "checkpoint_sakuramori_court" or state.checkpoint_room != "SakuramoriCourt_SaveShrine":
		_fail("Sakuramori Save Shrine should set the hub checkpoint.")
		return
	if player.current_health <= 12 or player.current_resource <= 3:
		_fail("Sakuramori Save Shrine should restore active player vitals.")
		return
	var runtime := state.party_roster[state.active_party_ids[0]] as Dictionary
	if bool(runtime.get("is_ko", false)):
		_fail("Sakuramori Save Shrine should clear KO state.")
		return
	if save_manager != null and not save_manager.has_save():
		_fail("Sakuramori Save Shrine should write a save file.")
		return
	await _free_world(world)

func _assert_continue_from_hub_save_loads_safely() -> void:
	var save_manager := root.get_node_or_null("/root/SaveManager")
	if save_manager == null:
		return
	save_manager.set("save_path", "user://test_sakuramori_services_continue.json")
	save_manager.call("delete_save")

	var world := _new_world_in_room("SakuramoriCourt_SaveShrine")
	var shrine := _find_node_with_method(world.get("current_room"), "activate_save_service")
	shrine.call("activate_save_service", world)
	await process_frame
	await _free_world(world)

	var continued := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(continued)
	continued.call("continue_game")
	await process_frame
	await physics_frame
	var state := continued.get("state") as GameState
	if state == null or state.current_room != "SakuramoriCourt_SaveShrine":
		_fail("Continue after hub save should reload the Sakuramori save shrine.")
		return
	if continued.get("player") == null or continued.get("current_room") == null:
		_fail("Continue after hub save should restore player and active room.")
		return
	await _free_world(continued)
	save_manager.call("delete_save")

func _assert_party_shrine_opens_and_cancels_without_mutation() -> void:
	var world := _new_world_in_room("SakuramoriCourt_PartyShrine")
	var state := world.get("state") as GameState
	var before := state.to_dictionary()
	var shrine := _find_node_with_method(world.get("current_room"), "open_party_service")
	if shrine == null:
		_fail("Sakuramori Party Shrine should expose open_party_service.")
		return
	if not bool(shrine.call("open_party_service", world)):
		_fail("Sakuramori Party Shrine should open its service shell.")
		return
	if not bool(shrine.get("is_open")):
		_fail("Sakuramori Party Shrine should track open state.")
		return
	shrine.call("cancel_party_service")
	if bool(shrine.get("is_open")):
		_fail("Sakuramori Party Shrine should close cleanly on cancel.")
		return
	if state.to_dictionary() != before:
		_fail("Cancelling Party Shrine should not mutate party save state.")
		return
	await _free_world(world)

func _assert_party_shrine_commits_party_order_and_rename() -> void:
	var world := _new_world_in_room("SakuramoriCourt_PartyShrine")
	var state := world.get("state") as GameState
	var manager := world.get("party_manager") as PartyManager
	manager.recruit_character(state, "black_witch", "Mira")
	manager.recruit_character(state, "shadow", "Ren")
	manager.unlock_character(state, "arc_gunner", "Vale")
	var shrine := _find_node_with_method(world.get("current_room"), "commit_party_service")
	if shrine == null:
		_fail("Sakuramori Party Shrine should expose commit_party_service for hub roster management.")
		return
	if not bool(shrine.call("open_party_service", world)):
		_fail("Sakuramori Party Shrine should open before committing party changes.")
		return
	if not bool(shrine.call("commit_party_service", world, ["black_witch", "shadow", "arc_gunner"], {"black_witch": "Sable"})):
		_fail("Sakuramori Party Shrine should commit a valid active party reorder and rename.")
		return
	if state.active_party_ids != ["black_witch", "shadow", "arc_gunner"]:
		_fail("Party Shrine should replace the active party with the committed unlocked order.")
		return
	if state.reserve_character_ids != ["warden"]:
		_fail("Party Shrine should keep unlocked non-active characters in reserve order.")
		return
	var witch_runtime := state.party_roster.get("black_witch", {}) as Dictionary
	if str(witch_runtime.get("character_name", "")) != "Sable":
		_fail("Party Shrine should persist character rename requests.")
		return
	if bool(shrine.get("is_open")):
		_fail("Party Shrine should close after a successful commit.")
		return
	await _free_world(world)

func _assert_party_shrine_rejects_invalid_commit_without_mutation() -> void:
	var world := _new_world_in_room("SakuramoriCourt_PartyShrine")
	var state := world.get("state") as GameState
	var manager := world.get("party_manager") as PartyManager
	manager.recruit_character(state, "black_witch", "Mira")
	var before := state.to_dictionary().duplicate(true)
	var shrine := _find_node_with_method(world.get("current_room"), "commit_party_service")
	shrine.call("open_party_service", world)
	if bool(shrine.call("commit_party_service", world, ["black_witch", "missing_recruit"], {"black_witch": "Sable"})):
		_fail("Party Shrine should reject a party containing locked or missing characters.")
		return
	if state.to_dictionary() != before:
		_fail("Rejected Party Shrine commits should not rename or reorder anything.")
		return
	await _free_world(world)

func _assert_party_shrine_rejects_invalid_rename_without_mutation() -> void:
	var world := _new_world_in_room("SakuramoriCourt_PartyShrine")
	var state := world.get("state") as GameState
	var manager := world.get("party_manager") as PartyManager
	manager.recruit_character(state, "black_witch", "Mira")
	manager.recruit_character(state, "shadow", "Ren")
	var before := state.to_dictionary().duplicate(true)
	var shrine := _find_node_with_method(world.get("current_room"), "commit_party_service")
	shrine.call("open_party_service", world)
	if bool(shrine.call("commit_party_service", world, ["warden", "black_witch", "shadow"], {"black_witch": ""})):
		_fail("Party Shrine should reject blank rename requests.")
		return
	if state.to_dictionary() != before:
		_fail("Rejected Party Shrine rename requests should not reorder or rename anything.")
		return
	if bool(shrine.call("commit_party_service", world, ["warden", "black_witch", "shadow"], {"missing_recruit": "Sable"})):
		_fail("Party Shrine should reject rename requests for locked or missing characters.")
		return
	if state.to_dictionary() != before:
		_fail("Rejected Party Shrine missing-character rename requests should not mutate party state.")
		return
	await _free_world(world)

func _assert_training_dummy_takes_damage_without_progression_reward() -> void:
	var world := _new_world_in_room("SakuramoriCourt_TrainingYard")
	var state := world.get("state") as GameState
	var dummy := _find_node_with_method(world.get("current_room"), "take_damage")
	if dummy == null:
		_fail("Sakuramori Training Yard should contain a damageable training dummy.")
		return
	var starting_xp := state.xp
	dummy.call("take_damage", 999)
	await process_frame
	if int(dummy.get("current_health")) <= 0:
		_fail("Training dummy should reset instead of dying.")
		return
	if state.xp != starting_xp or not state.defeated_bosses.is_empty():
		_fail("Training dummy damage should not award progression rewards.")
		return
	await _free_world(world)

func _assert_moonpetal_passage_is_locked_placeholder() -> void:
	var world := _new_world_in_room("SakuramoriCourt_MoonpetalPassage")
	var placeholder := _find_node_with_method(world.get("current_room"), "is_locked")
	if placeholder == null:
		_fail("Moonpetal Passage should contain a locked placeholder service.")
		return
	if not bool(placeholder.call("is_locked")):
		_fail("Moonpetal Passage should be locked in the milestone pass.")
		return
	await _free_world(world)

func _new_world_in_room(room_id: String) -> Node2D:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	world.call("load_room", room_id)
	return world

func _find_node_with_method(root_node: Node, method_name: String) -> Node:
	if root_node == null:
		return null
	if root_node.has_method(method_name):
		return root_node
	for child: Node in root_node.get_children():
		var match := _find_node_with_method(child, method_name)
		if match != null:
			return match
	return null

func _free_world(world: Node) -> void:
	world.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
