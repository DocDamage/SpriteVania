extends SceneTree

const TILE_SIZE := Vector2i(16, 16)
const ROOM_WIDTH_TILES := 60
const FLOOR_ROW := 31
const TILESET_PATH := "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Evironment/tileset.png"
const BACKGROUND_PATH := "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Evironment/background.png"
const MID_LAYER_1_PATH := "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Evironment/mid-layer-01.png"
const MID_LAYER_2_PATH := "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Evironment/mid-layer-02.png"
const TREES_PATH := "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Evironment/trees.png"
const PROPS_PATH := "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Evironment/props.png"
const TILESET_RESOURCE_PATH := "res://resources/tilesets/swamp_tileset.tres"
const PLAYER_FRAMES_PATH := "res://resources/animations/player_swamp_frames.tres"
const SPIDER_FRAMES_PATH := "res://resources/animations/swamp_spider_frames.tres"
const THING_FRAMES_PATH := "res://resources/animations/swamp_thing_frames.tres"
const FIRE_FRAMES_PATH := "res://resources/animations/swamp_fire_frames.tres"

const ROOM_PATHS := [
	"res://scenes/world/swamp_outskirts/RoomStart.tscn",
	"res://scenes/world/swamp_outskirts/RoomMovement.tscn",
	"res://scenes/world/swamp_outskirts/RoomEnemy.tscn",
	"res://scenes/world/swamp_outskirts/RoomHazard.tscn",
	"res://scenes/world/swamp_outskirts/RoomUpgrade.tscn",
	"res://scenes/world/swamp_outskirts/RoomCheckpoint.tscn",
	"res://scenes/world/swamp_outskirts/RoomShortcut.tscn",
	"res://scenes/world/swamp_outskirts/RoomMiniBoss.tscn",
]

const ROOM_PLATFORMS := {
	"RoomStart": [[18, 23, 8]],
	"RoomMovement": [[12, 24, 8], [35, 19, 10]],
	"RoomEnemy": [[7, 24, 9], [40, 24, 9]],
	"RoomHazard": [[14, 22, 8], [30, 18, 7], [45, 24, 8]],
	"RoomUpgrade": [[24, 21, 12]],
	"RoomCheckpoint": [[8, 24, 8], [44, 24, 8]],
	"RoomShortcut": [[18, 25, 7], [34, 20, 9]],
	"RoomMiniBoss": [[8, 25, 8], [45, 25, 8]],
}

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://resources/tilesets"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://resources/animations"))
	_create_swamp_tileset()
	_create_animation_resources()
	_update_player_scene()
	_update_enemy_scene("res://scenes/enemies/SwampCrawler.tscn", SPIDER_FRAMES_PATH, "walk", Vector2(0, -3), Vector2(1.5, 1.5))
	_update_enemy_scene("res://scenes/enemies/SwampMiniBoss.tscn", THING_FRAMES_PATH, "walk", Vector2(0, -8), Vector2(2.0, 2.0))
	for room_path: String in ROOM_PATHS:
		_update_room_scene(room_path)
	print("Generated swamp tiles, animated sprites, and tiled room scenes.")
	quit()

func _create_swamp_tileset() -> void:
	var texture := load(TILESET_PATH) as Texture2D
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = TILE_SIZE
	var columns := texture.get_width() / TILE_SIZE.x
	var rows := texture.get_height() / TILE_SIZE.y
	for y in range(rows):
		for x in range(columns):
			source.create_tile(Vector2i(x, y))
	tile_set.add_source(source, 0)
	ResourceSaver.save(tile_set, TILESET_RESOURCE_PATH)

func _create_animation_resources() -> void:
	var player_frames := SpriteFrames.new()
	_add_animation(player_frames, "idle", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Player/Sprites/idle", "idle", 6, 8.0, true)
	_add_animation(player_frames, "run", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Player/Sprites/run", "run", 14, 14.0, true)
	_add_animation(player_frames, "jump", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Player/Sprites/jump", "jump", 2, 8.0, false)
	_add_animation(player_frames, "fall", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Player/Sprites/fall", "fall", 2, 8.0, true)
	_add_animation(player_frames, "shoot", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Player/Sprites/shoot", "shoot", 3, 10.0, false)
	_add_animation(player_frames, "hurt", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Player/Sprites/hurt", "Hurt", 2, 8.0, false)
	ResourceSaver.save(player_frames, PLAYER_FRAMES_PATH)

	var spider_frames := SpriteFrames.new()
	_add_animation(spider_frames, "walk", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Spider/walk", "spider", 4, 8.0, true)
	ResourceSaver.save(spider_frames, SPIDER_FRAMES_PATH)

	var thing_frames := SpriteFrames.new()
	_add_animation(thing_frames, "walk", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Thing/walk thing", "thing", 4, 6.0, true)
	ResourceSaver.save(thing_frames, THING_FRAMES_PATH)

	var fire_frames := SpriteFrames.new()
	_add_animation(fire_frames, "burn", "res://SpriteVania Assets/tile sets/Gothicvania Swamp files/Sprites/Fire/fire", "fire", 2, 8.0, true)
	ResourceSaver.save(fire_frames, FIRE_FRAMES_PATH)

func _add_animation(frames: SpriteFrames, animation: String, folder: String, prefix: String, count: int, speed: float, loop: bool) -> void:
	if not frames.has_animation(animation):
		frames.add_animation(animation)
	frames.set_animation_speed(animation, speed)
	frames.set_animation_loop(animation, loop)
	for index in range(frames.get_frame_count(animation) - 1, -1, -1):
		frames.remove_frame(animation, index)
	for number in range(1, count + 1):
		var texture_path := "%s/%s%d.png" % [folder, prefix, number]
		if ResourceLoader.exists(texture_path):
			frames.add_frame(animation, load(texture_path))

func _update_player_scene() -> void:
	var packed := load("res://scenes/player/Player.tscn") as PackedScene
	var root := packed.instantiate()
	_remove_node(root, "Sprite2D")
	var animated := root.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if animated == null:
		animated = AnimatedSprite2D.new()
		animated.name = "AnimatedSprite2D"
		root.add_child(animated)
		animated.owner = root
	animated.unique_name_in_owner = true
	animated.sprite_frames = load(PLAYER_FRAMES_PATH)
	animated.animation = "idle"
	animated.play()
	animated.position = Vector2(0, -12)
	animated.scale = Vector2(1.15, 1.15)
	_set_scene_owner(root, root)
	_save_scene(root, "res://scenes/player/Player.tscn")

func _update_enemy_scene(scene_path: String, frames_path: String, animation: String, offset: Vector2, scale: Vector2) -> void:
	var packed := load(scene_path) as PackedScene
	var root := packed.instantiate()
	_remove_node(root, "Sprite2D")
	var animated := root.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if animated == null:
		animated = AnimatedSprite2D.new()
		animated.name = "AnimatedSprite2D"
		root.add_child(animated)
		animated.owner = root
	animated.sprite_frames = load(frames_path)
	animated.animation = animation
	animated.play()
	animated.position = offset
	animated.scale = scale
	_set_scene_owner(root, root)
	_save_scene(root, scene_path)

func _update_room_scene(scene_path: String) -> void:
	var packed := load(scene_path) as PackedScene
	var root := packed.instantiate()
	_remove_node(root, "SwampBackdrop")
	_remove_node(root, "SwampTileLayer")
	_remove_node(root, "SwampDecor")
	_hide_placeholder_sprites(root)
	_add_backdrop(root)
	_add_tile_layer(root)
	_add_decor(root)
	_set_scene_owner(root, root)
	_save_scene(root, scene_path)

func _add_backdrop(root: Node2D) -> void:
	var backdrop := Node2D.new()
	backdrop.name = "SwampBackdrop"
	backdrop.z_index = -100
	root.add_child(backdrop)
	backdrop.owner = root
	_add_scaled_sprite(backdrop, "Background", BACKGROUND_PATH, Vector2(480, 270), Vector2(10.0, 2.2), -120, root)
	_add_scaled_sprite(backdrop, "MidLayer02", MID_LAYER_2_PATH, Vector2(500, 285), Vector2(5.0, 2.1), -110, root)
	_add_scaled_sprite(backdrop, "MidLayer01", MID_LAYER_1_PATH, Vector2(470, 300), Vector2(5.1, 2.1), -105, root)
	_add_scaled_sprite(backdrop, "Trees", TREES_PATH, Vector2(480, 382), Vector2(2.8, 2.8), -95, root)

func _add_scaled_sprite(parent: Node, node_name: String, texture_path: String, position: Vector2, scale: Vector2, z_index: int, owner: Node) -> void:
	var sprite := Sprite2D.new()
	sprite.name = node_name
	sprite.texture = load(texture_path)
	sprite.centered = true
	sprite.position = position
	sprite.scale = scale
	sprite.z_index = z_index
	parent.add_child(sprite)
	sprite.owner = owner

func _add_tile_layer(root: Node2D) -> void:
	var layer := TileMapLayer.new()
	layer.name = "SwampTileLayer"
	layer.tile_set = load(TILESET_RESOURCE_PATH)
	layer.z_index = -10
	root.add_child(layer)
	layer.owner = root
	for x in range(ROOM_WIDTH_TILES):
		var surface := Vector2i((x % 7), 0)
		layer.set_cell(Vector2i(x, FLOOR_ROW), 0, surface)
		layer.set_cell(Vector2i(x, FLOOR_ROW + 1), 0, Vector2i(1 + (x % 5), 1))
		layer.set_cell(Vector2i(x, FLOOR_ROW + 2), 0, Vector2i(1 + (x % 5), 2))
	for platform_data: Array in ROOM_PLATFORMS.get(root.name, []):
		_paint_platform(layer, platform_data[0], platform_data[1], platform_data[2])

func _paint_platform(layer: TileMapLayer, start_x: int, y: int, width: int) -> void:
	for x in range(start_x, start_x + width):
		layer.set_cell(Vector2i(x, y), 0, Vector2i((x - start_x) % 7, 0))
		layer.set_cell(Vector2i(x, y + 1), 0, Vector2i(1 + ((x - start_x) % 5), 1))

func _add_decor(root: Node2D) -> void:
	var decor := Node2D.new()
	decor.name = "SwampDecor"
	decor.z_index = -5
	root.add_child(decor)
	decor.owner = root
	for index in range(5):
		var sprite := Sprite2D.new()
		sprite.name = "Prop%d" % (index + 1)
		sprite.texture = load(PROPS_PATH)
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 64, 64, 48)
		sprite.position = Vector2(128 + (index * 170), 470 + (index % 2) * 8)
		sprite.scale = Vector2(0.9, 0.9)
		decor.add_child(sprite)
		sprite.owner = root

func _hide_placeholder_sprites(node: Node) -> void:
	for child in node.get_children():
		if child is Sprite2D and child.name == "Sprite2D":
			child.visible = false
		_hide_placeholder_sprites(child)

func _remove_node(root: Node, node_name: String) -> void:
	var node := root.get_node_or_null(node_name)
	if node != null:
		node.get_parent().remove_child(node)
		node.queue_free()

func _set_scene_owner(node: Node, owner: Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_set_scene_owner(child, owner)

func _save_scene(root: Node, path: String) -> void:
	var packed := PackedScene.new()
	var result := packed.pack(root)
	if result != OK:
		push_error("Could not pack " + path)
		return
	result = ResourceSaver.save(packed, path)
	if result != OK:
		push_error("Could not save " + path)
