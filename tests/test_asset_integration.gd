extends SceneTree

const SWAMP_ROOM_SCENES := [
	"res://scenes/world/swamp_outskirts/RoomStart.tscn",
	"res://scenes/world/swamp_outskirts/RoomMovement.tscn",
	"res://scenes/world/swamp_outskirts/RoomEnemy.tscn",
	"res://scenes/world/swamp_outskirts/RoomHazard.tscn",
	"res://scenes/world/swamp_outskirts/RoomUpgrade.tscn",
	"res://scenes/world/swamp_outskirts/RoomCheckpoint.tscn",
	"res://scenes/world/swamp_outskirts/RoomShortcut.tscn",
	"res://scenes/world/swamp_outskirts/RoomMiniBoss.tscn",
]

const POLISHED_PRESENTATION_SCENES := [
	"res://scenes/world/UpgradePickup.tscn",
	"res://scenes/world/CheckpointShrine.tscn",
	"res://scenes/player/PlayerFamiliar.tscn",
	"res://scenes/player/FamiliarBolt.tscn",
	"res://scenes/world/castle_gate/CastleGateStart.tscn",
	"res://scenes/world/swamp_outskirts/RoomStart.tscn",
	"res://scenes/world/swamp_outskirts/RoomMovement.tscn",
	"res://scenes/world/swamp_outskirts/RoomEnemy.tscn",
	"res://scenes/world/swamp_outskirts/RoomHazard.tscn",
	"res://scenes/world/swamp_outskirts/RoomUpgrade.tscn",
	"res://scenes/world/swamp_outskirts/RoomCheckpoint.tscn",
	"res://scenes/world/swamp_outskirts/RoomShortcut.tscn",
	"res://scenes/world/swamp_outskirts/RoomMiniBoss.tscn",
]

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
	_assert_sprite_frames("res://resources/animations/swamp_fire_frames.tres", {"burn": 2})
	_assert_player_animated_collision()
	_assert_dialogue_resource()
	for scene_path: String in SWAMP_ROOM_SCENES:
		_assert_swamp_room(scene_path)
	for scene_path: String in POLISHED_PRESENTATION_SCENES:
		if not _has_no_placeholder_texture(scene_path):
			quit(1)
			return
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

func _assert_player_animated_collision() -> void:
	_assert_resource("res://resources/shape_frames/player_collision_frames.tres", Resource)
	var scene := load("res://scenes/player/Player.tscn") as PackedScene
	if scene == null:
		push_error("Player scene did not load")
		quit(1)
	var player := scene.instantiate()
	var animator := player.get_node_or_null("PlayerBodyShapeAnimator")
	if animator == null:
		push_error("Player scene is missing AnimatedShape2D body animator")
		player.free()
		quit(1)
	if animator.get("shape_frames") == null:
		push_error("Player AnimatedShape2D has no ShapeFrames2D resource")
		player.free()
		quit(1)
	player.free()

func _assert_dialogue_resource() -> void:
	var dialogue := load("res://dialogue/swamp_outskirts.dialogue")
	if dialogue == null:
		push_error("Swamp dialogue resource did not load")
		quit(1)
	var cues: Dictionary = dialogue.get("cues")
	if not cues.has("start"):
		push_error("Swamp dialogue should define a start cue")
		quit(1)
	var lines: Dictionary = dialogue.get("lines")
	if lines.size() < 2:
		push_error("Swamp dialogue should compile to multiple dialogue lines")
		quit(1)

func _assert_swamp_room(path: String) -> void:
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
	for required_node: String in ["Entrances", "EnemySpawns", "Pickups", "SwampBackdrop", "SwampDecor"]:
		if room.get_node_or_null(required_node) == null:
			push_error(path + " is missing " + required_node)
			room.free()
			quit(1)
	if room.get_node_or_null("SwampDecor").get_child_count() < 3:
		push_error(path + " has too little swamp decoration")
		room.free()
		quit(1)
	if path.ends_with("RoomStart.tscn") and room.get_node_or_null("PlayerStart") == null:
		push_error(path + " is missing PlayerStart")
		room.free()
		quit(1)
	if path.ends_with("RoomStart.tscn") and room.get_node_or_null("LoreTablet") == null:
		push_error(path + " is missing LoreTablet")
		room.free()
		quit(1)
	if path.ends_with("RoomMovement.tscn"):
		_assert_wall_jump_practice_shaft(room, path)
	_assert_no_hidden_collision_body(room, path)
	room.free()

func _has_no_placeholder_texture(path: String) -> bool:
	var source := FileAccess.get_file_as_string(path)
	if source.contains("PlaceholderTexture2D"):
		push_error(path + " still contains PlaceholderTexture2D")
		return false
	return true

func _assert_wall_jump_practice_shaft(room: Node, path: String) -> void:
	var shaft := room.get_node_or_null("WallJumpShaft")
	if shaft == null:
		push_error(path + " is missing WallJumpShaft")
		quit(1)
	for wall_name: String in ["LeftWall", "RightWall"]:
		var wall := shaft.get_node_or_null(wall_name) as StaticBody2D
		if wall == null:
			push_error(path + " is missing wall jump surface: " + wall_name)
			quit(1)
		if not _has_enabled_collision_shape(wall):
			push_error(path + " wall jump surface has no enabled collision: " + wall_name)
			quit(1)

func _assert_no_hidden_collision_body(root: Node, path: String) -> void:
	if root is CollisionObject2D:
		var collision_object := root as CollisionObject2D
		if collision_object is StaticBody2D and _has_enabled_collision_shape(collision_object) and _has_hidden_or_missing_sprite(collision_object):
			push_error(path + " has an invisible collision body: " + collision_object.name)
			quit(1)
	for child: Node in root.get_children():
		_assert_no_hidden_collision_body(child, path)

func _has_enabled_collision_shape(root: Node) -> bool:
	for child: Node in root.get_children():
		if child is CollisionShape2D and not (child as CollisionShape2D).disabled:
			return true
	return false

func _has_hidden_or_missing_sprite(root: Node) -> bool:
	var has_sprite := false
	for child: Node in root.get_children():
		if child is Sprite2D:
			has_sprite = true
			if not (child as Sprite2D).visible:
				return true
	return not has_sprite and root is StaticBody2D
