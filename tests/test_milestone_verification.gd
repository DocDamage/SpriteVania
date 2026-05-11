extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")
const TITLE_SCREEN_SCENE := preload("res://scenes/ui/TitleScreen.tscn")

const KEYBOARD_ROUTE: Array[String] = [
	"RoomStart",
	"RoomMovement",
	"RoomEnemy",
	"RoomHazard",
	"RoomUpgrade",
	"RoomCheckpoint",
	"RoomShortcut",
	"RoomMiniBoss",
	"Swamp_CastleExit",
	"CastleGate_Causeway",
	"CastleGate_BrokenPortcullis",
	"CastleGate_DamagedShrineApproach",
	"CastleGate_DamagedShrine",
	"CastleGate_TagTutorial",
	"SamuraiCastle_OuterWall",
	"SamuraiCastle_PatrolHall",
	"SamuraiCastle_Watchpost",
	"SamuraiCastle_PrisonApproach",
	"SamuraiCastle_ShadowPrison",
	"SamuraiCastle_AlarmEscape",
	"SamuraiCastle_BossAntechamber",
	"SamuraiCastle_MasakiroArena",
	"SamuraiCastle_RisingToriiSeal",
	"SamuraiCastle_AscentTest",
	"SakuramoriCourt_Entrance",
	"SakuramoriCourt_SaveShrine",
]

const CONTROLLER_ACTIONS := [
	"move_left",
	"move_right",
	"jump",
	"dash",
	"attack",
	"special_attack",
	"class_action",
	"interact",
	"pause",
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_keyboard_route_reaches_hub_save()
	_assert_controller_route_actions_are_bound()
	await _assert_reduced_motion_route_applies_to_title_and_world()
	await _assert_save_continue_from_every_checkpoint()
	print("PASS: milestone verification")
	quit(0)

func _assert_keyboard_route_reaches_hub_save() -> void:
	var world := _new_world()
	var state := world.get("state") as GameState
	state.defeated_bosses.append("swamp_miniboss")
	state.defeated_bosses.append("masakiro")
	state.traversal_unlocks.append("vertical_ascent")
	for room_id: String in KEYBOARD_ROUTE:
		world.call("load_room", room_id)
		await process_frame
		var room := world.get("current_room") as Node2D
		if room == null or room.name != room_id:
			_fail("Keyboard route should load " + room_id)
			return
		var player := world.get("player") as CharacterBody2D
		var bounds: Rect2 = room.call("get_room_bounds")
		if player == null or not bounds.has_point(player.global_position):
			_fail("Keyboard route player should remain inside bounds in " + room_id)
			return
	if state.current_room != "SakuramoriCourt_SaveShrine":
		_fail("Keyboard route should reach the Sakuramori save shrine.")
		return
	await _free_world(world)

func _assert_controller_route_actions_are_bound() -> void:
	for action_name: String in CONTROLLER_ACTIONS:
		if not InputMap.has_action(action_name):
			_fail("Controller route requires action: " + action_name)
			return
		if not _has_controller_event(action_name):
			_fail("Controller route action should have a joypad binding: " + action_name)
			return

func _assert_reduced_motion_route_applies_to_title_and_world() -> void:
	var title := TITLE_SCREEN_SCENE.instantiate() as Control
	root.add_child(title)
	await process_frame
	title.call("apply_settings", {"reduced_motion": true})
	if bool(title.get("parallax_enabled")):
		_fail("Reduced motion should disable title parallax.")
		return
	title.queue_free()

	var world := _new_world()
	world.call("apply_settings", {
		"reduced_motion": true,
		"large_text": true,
		"high_contrast": true,
	})
	var hud := world.get("hud") as CanvasLayer
	if hud == null:
		_fail("Reduced motion route should keep HUD available.")
		return
	await _free_world(world)

func _assert_save_continue_from_every_checkpoint() -> void:
	var save_manager := root.get_node_or_null("/root/SaveManager")
	if save_manager == null:
		_fail("Save/continue checkpoint verification requires SaveManager autoload.")
		return
	save_manager.set("save_path", "user://test_milestone_checkpoint_continue.json")
	save_manager.call("delete_save")

	for checkpoint: Dictionary in _checkpoint_cases():
		var world := _new_world()
		world.call("load_room", str(checkpoint.room_id))
		await process_frame
		var node := _find_checkpoint(world.get("current_room"), str(checkpoint.checkpoint_id))
		if node == null:
			_fail("Checkpoint node missing: %s in %s" % [checkpoint.checkpoint_id, checkpoint.room_id])
			return
		world.call("activate_checkpoint", checkpoint.checkpoint_id, node.global_position)
		await process_frame
		await _free_world(world)

		var continued := GAME_WORLD_SCENE.instantiate() as Node2D
		root.add_child(continued)
		continued.call("continue_game")
		await process_frame
		await physics_frame
		var state := continued.get("state") as GameState
		if state == null or state.current_room != str(checkpoint.room_id) or state.checkpoint_id != str(checkpoint.checkpoint_id):
			_fail("Continue should restore checkpoint %s in %s." % [checkpoint.checkpoint_id, checkpoint.room_id])
			return
		if continued.get("player") == null or continued.get("current_room") == null:
			_fail("Continue should restore player and room for checkpoint " + str(checkpoint.checkpoint_id))
			return
		await _free_world(continued)
		save_manager.call("delete_save")

func _checkpoint_cases() -> Array[Dictionary]:
	return [
		{"room_id": "RoomCheckpoint", "checkpoint_id": "swamp_shrine_01"},
		{"room_id": "CastleGate_DamagedShrine", "checkpoint_id": "checkpoint_castle_gate"},
		{"room_id": "SamuraiCastle_OuterWall", "checkpoint_id": "checkpoint_samurai_castle"},
		{"room_id": "SamuraiCastle_BossAntechamber", "checkpoint_id": "checkpoint_masakiro"},
		{"room_id": "SakuramoriCourt_SaveShrine", "checkpoint_id": "checkpoint_sakuramori_court"},
	]

func _new_world() -> Node2D:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	return world

func _find_checkpoint(root_node: Node, checkpoint_id: String) -> Area2D:
	if root_node == null:
		return null
	if root_node is Area2D and root_node.has_signal("checkpoint_activated") and str(root_node.get("checkpoint_id")) == checkpoint_id:
		return root_node as Area2D
	for child: Node in root_node.get_children():
		var match := _find_checkpoint(child, checkpoint_id)
		if match != null:
			return match
	return null

func _has_controller_event(action_name: String) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventJoypadButton or event is InputEventJoypadMotion:
			return true
	return false

func _free_world(world: Node) -> void:
	world.queue_free()
	await process_frame
	await process_frame
	await physics_frame

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
