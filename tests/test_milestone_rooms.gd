extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

const MILESTONE_ROUTE: Array[String] = [
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
	"SakuramoriCourt_PartyShrine",
	"SakuramoriCourt_TrainingYard",
	"SakuramoriCourt_MoonpetalPassage",
]
const REQUIRED_ENEMY_SPAWNS := {
	"SamuraiCastle_PatrolHall": ["cursed_samurai_patrol"],
	"SamuraiCastle_Watchpost": ["watch_sentinel"],
	"SamuraiCastle_AlarmEscape": ["oni_brute_escape"],
}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var world := GAME_WORLD_SCENE.instantiate()
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	await process_frame
	await physics_frame

	for room_id: String in MILESTONE_ROUTE:
		if not world.ROOM_SCENES.has(room_id):
			_fail("Milestone room should be registered in GameWorld. Missing: " + room_id)
			return
		world.call("load_room", room_id)
		await process_frame
		var room := world.get("current_room") as Node2D
		if room == null or room.name != room_id:
			_fail("Loading %s should instantiate a same-named room scene." % room_id)
			return
		if not room.has_method("get_room_bounds"):
			_fail(room_id + " should expose room bounds.")
			return
		var bounds: Rect2 = room.call("get_room_bounds")
		if bounds.size.x < 640.0 or bounds.size.y < 360.0:
			_fail(room_id + " should define playable camera-safe bounds.")
			return
		if room.get_node_or_null("PlayerStart") == null:
			_fail(room_id + " should include a PlayerStart marker.")
			return
		if room.get_node_or_null("Entrances") == null:
			_fail(room_id + " should include an Entrances container.")
			return
		if _exit_targets(room).is_empty() and room_id != MILESTONE_ROUTE[MILESTONE_ROUTE.size() - 1]:
			_fail(room_id + " should expose at least one room exit.")
			return
		if REQUIRED_ENEMY_SPAWNS.has(room_id):
			for enemy_id: String in REQUIRED_ENEMY_SPAWNS[room_id]:
				if _find_enemy_spawn(room, enemy_id) == null:
					_fail("%s should include required prototype enemy spawn %s." % [room_id, enemy_id])
					return

	await _assert_route_exits_are_registered(world)
	if not world.get("state").discovered_rooms.has("SakuramoriCourt_Entrance"):
		_fail("The milestone route should reach Sakuramori Court.")
		return
	if not world.get("state").discovered_rooms.has("SakuramoriCourt_MoonpetalPassage"):
		_fail("Sakuramori Court side services should be reachable from the hub route.")
		return

	world.queue_free()
	await process_frame
	print("PASS: milestone rooms")
	quit(0)

func _assert_route_exits_are_registered(world: Node) -> void:
	for room_id: String in MILESTONE_ROUTE:
		world.call("load_room", room_id)
		await process_frame
		var room := world.get("current_room") as Node2D
		for target: String in _exit_targets(room):
			if not world.ROOM_SCENES.has(target):
				_fail("%s has an exit to unregistered room %s." % [room_id, target])
				return

func _exit_targets(root_node: Node) -> Array[String]:
	var targets: Array[String] = []
	if root_node == null:
		return targets
	if root_node is Area2D:
		var target := str(root_node.get_meta("next_room", ""))
		if not target.is_empty():
			targets.append(target)
	for child: Node in root_node.get_children():
		targets.append_array(_exit_targets(child))
	return targets

func _find_enemy_spawn(root_node: Node, enemy_id: String) -> Node:
	if root_node == null:
		return null
	if str(root_node.get("enemy_id")) == enemy_id:
		return root_node
	for child: Node in root_node.get_children():
		var match := _find_enemy_spawn(child, enemy_id)
		if match != null:
			return match
	return null

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
