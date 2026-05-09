extends SceneTree

func _init() -> void:
	_assert_resource("res://resources/tilesets/swamp_tileset.tres", TileSet)
	_assert_sprite_frames("res://resources/animations/player_swamp_frames.tres", {
		"idle": 6,
		"run": 14,
		"jump": 2,
		"fall": 2,
		"shoot": 3,
		"hurt": 2,
	})
	_assert_sprite_frames("res://resources/animations/swamp_spider_frames.tres", {"walk": 4})
	_assert_sprite_frames("res://resources/animations/swamp_thing_frames.tres", {"walk": 4})
	_assert_room_tiles("res://scenes/world/swamp_outskirts/RoomStart.tscn")
	_assert_room_tiles("res://scenes/world/swamp_outskirts/RoomEnemy.tscn")
	print("PASS: asset integration")
	quit(0)

func _assert_resource(path: String, expected_type: Variant) -> void:
	var resource := load(path)
	if not is_instance_of(resource, expected_type):
		push_error(path + " did not load as expected resource type")
		quit(1)

func _assert_sprite_frames(path: String, expected_counts: Dictionary) -> void:
	var frames := load(path) as SpriteFrames
	if frames == null:
		push_error(path + " did not load as SpriteFrames")
		quit(1)
	for animation: String in expected_counts:
		if not frames.has_animation(animation):
			push_error(path + " is missing animation " + animation)
			quit(1)
		if frames.get_frame_count(animation) != expected_counts[animation]:
			push_error("%s animation %s expected %d frames, got %d" % [path, animation, expected_counts[animation], frames.get_frame_count(animation)])
			quit(1)

func _assert_room_tiles(path: String) -> void:
	var scene := load(path) as PackedScene
	if scene == null:
		push_error(path + " did not load as a PackedScene")
		quit(1)
	var room := scene.instantiate()
	var tile_layer := room.get_node_or_null("SwampTileLayer") as TileMapLayer
	if tile_layer == null:
		push_error(path + " is missing SwampTileLayer")
		room.free()
		quit(1)
	if tile_layer.get_used_cells().size() < 100:
		push_error(path + " has too few laid tiles")
		room.free()
		quit(1)
	if room.get_node_or_null("SwampBackdrop") == null:
		push_error(path + " is missing SwampBackdrop")
		room.free()
		quit(1)
	room.free()
