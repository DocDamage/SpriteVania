extends SceneTree

const GAME_WORLD_SCENE := preload("res://scenes/world/GameWorld.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _assert_shortcut_starts_closed()
	await _assert_shortcut_opens_from_back_side()
	await _assert_open_shortcut_stays_open()
	print("PASS: shortcuts")
	quit(0)

func _assert_shortcut_starts_closed() -> void:
	var world := _new_world_in_room("RoomShortcut")
	var room := world.get("current_room") as Node2D
	if room.get_node_or_null("OneWayShortcutGate") == null:
		_fail("Shortcut gate should be closed before the shortcut is opened.")
		return
	world.free()
	await process_frame

func _assert_shortcut_opens_from_back_side() -> void:
	var world := _new_world_in_room("RoomMiniBoss")
	var room := world.get("current_room") as Node2D
	var left_exit := room.get_node_or_null("Entrances/LeftEntrance") as Area2D
	var player := world.get("player") as CharacterBody2D
	left_exit.body_entered.emit(player)
	await physics_frame
	await process_frame

	var shortcut_room := world.get("current_room") as Node2D
	var state := world.get("state") as GameState
	if shortcut_room == null or shortcut_room.name != "RoomShortcut":
		_fail("MiniBoss left exit should enter RoomShortcut.")
		return
	if state == null or not state.opened_shortcuts.has("swamp_checkpoint_shortcut"):
		_fail("Entering RoomShortcut from MiniBoss should persist the shortcut id.")
		return
	if shortcut_room.get_node_or_null("OneWayShortcutGate") != null:
		_fail("Shortcut gate should be removed when opened from the back side.")
		return
	world.free()
	await process_frame

func _assert_open_shortcut_stays_open() -> void:
	var world := _new_world_in_room("RoomShortcut")
	var state := world.get("state") as GameState
	state.opened_shortcuts.append("swamp_checkpoint_shortcut")
	world.call("load_room", "RoomShortcut")
	await process_frame

	var room := world.get("current_room") as Node2D
	if room.get_node_or_null("OneWayShortcutGate") != null:
		_fail("Previously opened shortcut gate should stay removed on room reload.")
		return
	world.free()
	await process_frame

func _new_world_in_room(room_id: String) -> Node2D:
	var world := GAME_WORLD_SCENE.instantiate() as Node2D
	root.add_child(world)
	world.call("start_new_game", "warden", "")
	world.call("load_room", room_id)
	return world

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
