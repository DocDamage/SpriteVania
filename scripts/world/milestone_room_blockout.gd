extends "res://scripts/world/room.gd"
class_name MilestoneRoomBlockout

const CHECKPOINT_SCENE := preload("res://scenes/world/CheckpointShrine.tscn")
const CRAWLER_SCENE := preload("res://scenes/enemies/SwampCrawler.tscn")
const CURSED_SAMURAI_SCENE := preload("res://scenes/enemies/CursedSamurai.tscn")
const WATCH_SENTINEL_SCENE := preload("res://scenes/enemies/WatchSentinel.tscn")
const ONI_BRUTE_SCENE := preload("res://scenes/enemies/OniBrute.tscn")
const MASAKIRO_SCENE := preload("res://scenes/enemies/Masakiro.tscn")
const DAMAGED_SHRINE_SCENE := preload("res://scenes/world/DamagedShrine.tscn")
const SHADOW_PRISON_SCENE := preload("res://scenes/world/ShadowPrison.tscn")
const ENEMY_SPAWN_SCRIPT := preload("res://scripts/world/enemy_spawn.gd")
const RISING_TORII_SEAL_SCRIPT := preload("res://scripts/world/rising_torii_seal.gd")
const SAKURAMORI_SAVE_SHRINE_SCRIPT := preload("res://scripts/world/sakuramori_save_shrine.gd")
const PARTY_SHRINE_SCRIPT := preload("res://scripts/world/party_shrine.gd")
const TRAINING_DUMMY_SCRIPT := preload("res://scripts/world/training_dummy.gd")
const LOCKED_SERVICE_PLACEHOLDER_SCRIPT := preload("res://scripts/world/locked_service_placeholder.gd")
const CASTLE_ZONE_TEXTURE := preload("res://SpriteVania Assets/Hardcore Gandalf/GandalfHardcore FREE Platformer Assets/GandalfHardcore Background layers/Normal BG/Background Castle .png")
const SAMURAI_ZONE_TEXTURE := preload("res://SpriteVania Assets/Feudal Japan Background/1 (2).png")
const SAKURAMORI_ZONE_TEXTURE := preload("res://SpriteVania Assets/parallax/Demon Woods Parallax/parallax_demon_woods_pack/layers/parallax-demon-woods-bg.png")

const GROUND_HEIGHT := 72.0
const EXIT_SIZE := Vector2(40, 180)
const HAZARD_SIZE := Vector2(120, 24)

@export var zone_theme: String = "castle_gate"

var _built := false

func _ready() -> void:
	_ensure_blockout()

func enter_room() -> void:
	_ensure_blockout()
	super.enter_room()

func _ensure_blockout() -> void:
	if _built:
		return
	_built = true
	if room_id.is_empty():
		room_id = name
	_create_ground()
	_create_zone_art()
	_create_player_start()
	_create_exits()
	_create_room_features()

func _create_ground() -> void:
	if get_node_or_null("Ground") != null:
		return
	var ground := StaticBody2D.new()
	ground.name = "Ground"
	ground.position = Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, room_bounds.position.y + room_bounds.size.y - GROUND_HEIGHT * 0.5)
	add_child(ground)

	var shape := CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(room_bounds.size.x, GROUND_HEIGHT)
	shape.shape = rectangle
	ground.add_child(shape)

	var ground_visual := Polygon2D.new()
	ground_visual.name = "GroundVisual"
	ground_visual.color = _ground_color()
	ground_visual.polygon = PackedVector2Array([
		Vector2(room_bounds.position.x, room_bounds.position.y + room_bounds.size.y - GROUND_HEIGHT),
		Vector2(room_bounds.position.x + room_bounds.size.x, room_bounds.position.y + room_bounds.size.y - GROUND_HEIGHT),
		Vector2(room_bounds.position.x + room_bounds.size.x, room_bounds.position.y + room_bounds.size.y),
		Vector2(room_bounds.position.x, room_bounds.position.y + room_bounds.size.y),
	])
	add_child(ground_visual)

	var backdrop := Polygon2D.new()
	backdrop.name = "Backdrop"
	backdrop.color = _backdrop_color()
	backdrop.z_index = -20
	backdrop.polygon = PackedVector2Array([
		room_bounds.position,
		Vector2(room_bounds.position.x + room_bounds.size.x, room_bounds.position.y),
		room_bounds.position + room_bounds.size,
		Vector2(room_bounds.position.x, room_bounds.position.y + room_bounds.size.y),
	])
	add_child(backdrop)

func _create_player_start() -> void:
	if get_node_or_null("PlayerStart") != null:
		return
	var start := Marker2D.new()
	start.name = "PlayerStart"
	start.position = Vector2(room_bounds.position.x + 96.0, _floor_y() - 64.0)
	add_child(start)

func _create_zone_art() -> void:
	if get_node_or_null("ZoneArt") != null:
		return
	var texture := _zone_art_texture()
	if texture == null:
		return
	var sprite := Sprite2D.new()
	sprite.name = "ZoneArt"
	sprite.texture = texture
	sprite.centered = true
	sprite.z_index = -15
	sprite.modulate = Color(0.72, 0.74, 0.76, 0.82)
	sprite.position = Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, room_bounds.position.y + room_bounds.size.y * 0.44)
	var texture_size := texture.get_size()
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		var scale_x := room_bounds.size.x / texture_size.x
		var scale_y := room_bounds.size.y / texture_size.y
		sprite.scale = Vector2(scale_x, scale_y) * 0.82
	add_child(sprite)

func _create_exits() -> void:
	if get_node_or_null("Entrances") != null:
		return
	var entrances := Node2D.new()
	entrances.name = "Entrances"
	add_child(entrances)

	for direction: String in next_rooms.keys():
		var target := str(next_rooms[direction])
		if target.is_empty():
			continue
		var exit := Area2D.new()
		exit.name = _exit_name(direction)
		exit.position = _exit_position(direction)
		exit.set_meta("next_room", target)
		entrances.add_child(exit)

		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = _exit_shape_size(direction)
		shape.shape = rectangle
		exit.add_child(shape)

func _create_room_features() -> void:
	match room_id:
		"CastleGate_DamagedShrine":
			_add_scene_feature("DamagedShrine", DAMAGED_SHRINE_SCENE, Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() - 36.0))
			_add_checkpoint("checkpoint_castle_gate", Vector2(room_bounds.position.x + 150.0, _floor_y() - 36.0))
		"SamuraiCastle_ShadowPrison":
			_add_scene_feature("ShadowPrison", SHADOW_PRISON_SCENE, Vector2(room_bounds.position.x + room_bounds.size.x * 0.55, _floor_y() - 36.0))
		"SakuramoriCourt_SaveShrine":
			_add_checkpoint("checkpoint_sakuramori_court", Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() - 36.0))
			_add_sakuramori_save_shrine(Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() - 36.0))
		"SakuramoriCourt_Entrance":
			_add_checkpoint("checkpoint_sakuramori_court", Vector2(room_bounds.position.x + 160.0, _floor_y() - 36.0))
			_add_locked_placeholder("MarketPlaceholder", "market_shop", Vector2(room_bounds.position.x + room_bounds.size.x * 0.7, _floor_y() - 48.0))
		"SakuramoriCourt_PartyShrine":
			_add_party_shrine(Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() - 36.0))
		"SakuramoriCourt_TrainingYard":
			_add_training_dummy(Vector2(room_bounds.position.x + room_bounds.size.x * 0.55, _floor_y()))
		"SakuramoriCourt_MoonpetalPassage":
			_add_locked_placeholder("MoonpetalPassage", "moonpetal_passage", Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() - 48.0))
		"SamuraiCastle_MasakiroArena":
			_set_exit_defeat_gate("RightEntrance", "masakiro")
			_add_enemy_spawn("masakiro", Vector2(room_bounds.position.x + room_bounds.size.x * 0.58, _floor_y()), MASAKIRO_SCENE)
		"SamuraiCastle_RisingToriiSeal":
			_set_exit_traversal_gate("RightEntrance", "vertical_ascent")
			_add_rising_torii_seal(Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() - 42.0))
		"SamuraiCastle_AscentTest":
			_set_exit_traversal_gate("RightEntrance", "vertical_ascent")

	if room_id == "CastleGate_TagTutorial":
		_add_enemy_spawn(room_id.to_snake_case() + "_crawler", Vector2(room_bounds.position.x + room_bounds.size.x * 0.62, _floor_y() - 40.0), CRAWLER_SCENE)
	if room_id == "SamuraiCastle_PatrolHall":
		_add_enemy_spawn("cursed_samurai_patrol", Vector2(room_bounds.position.x + room_bounds.size.x * 0.62, _floor_y()), CURSED_SAMURAI_SCENE)
	if room_id == "SamuraiCastle_Watchpost":
		_add_enemy_spawn("watch_sentinel", Vector2(room_bounds.position.x + room_bounds.size.x * 0.58, _floor_y()), WATCH_SENTINEL_SCENE)
	if room_id == "SamuraiCastle_AlarmEscape":
		_add_enemy_spawn("oni_brute_escape", Vector2(room_bounds.position.x + room_bounds.size.x * 0.62, _floor_y()), ONI_BRUTE_SCENE)
	if room_id in ["SamuraiCastle_Watchpost", "SamuraiCastle_AlarmEscape"]:
		_add_spike_hazard(Vector2(room_bounds.position.x + room_bounds.size.x * 0.45, _floor_y() - 12.0))
	if room_id == "SamuraiCastle_BossAntechamber":
		_add_checkpoint("checkpoint_masakiro", Vector2(room_bounds.position.x + room_bounds.size.x * 0.35, _floor_y() - 36.0))
	if room_id == "SamuraiCastle_OuterWall":
		_add_checkpoint("checkpoint_samurai_castle", Vector2(room_bounds.position.x + 160.0, _floor_y() - 36.0))

func _add_checkpoint(checkpoint_id: String, position: Vector2) -> void:
	if get_node_or_null("Checkpoints/" + checkpoint_id) != null:
		return
	var checkpoints := _ensure_container("Checkpoints")
	var checkpoint := CHECKPOINT_SCENE.instantiate() as Area2D
	checkpoint.name = checkpoint_id
	checkpoint.set("checkpoint_id", checkpoint_id)
	checkpoint.position = position
	checkpoints.add_child(checkpoint)

func _add_scene_feature(feature_name: String, scene: PackedScene, position: Vector2) -> void:
	if get_node_or_null(feature_name) != null:
		return
	var feature := scene.instantiate() as Node2D
	feature.name = feature_name
	feature.position = position
	add_child(feature)

func _add_enemy_spawn(enemy_id: String, position: Vector2, enemy_scene: PackedScene) -> void:
	var spawns := _ensure_container("EnemySpawns")
	if spawns.get_node_or_null(enemy_id) != null:
		return
	var spawn := ENEMY_SPAWN_SCRIPT.new() as Marker2D
	spawn.name = enemy_id
	spawn.set("enemy_scene", enemy_scene)
	spawn.set("enemy_id", enemy_id)
	spawn.position = position
	spawns.add_child(spawn)

func _add_rising_torii_seal(position: Vector2) -> void:
	var pickups := _ensure_container("Pickups")
	if pickups.get_node_or_null("RisingToriiSeal") != null:
		return
	var seal := RISING_TORII_SEAL_SCRIPT.new() as Area2D
	seal.name = "RisingToriiSeal"
	seal.set("pickup_id", "rising_torii_seal")
	seal.position = position
	pickups.add_child(seal)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 22.0
	shape.shape = circle
	seal.add_child(shape)

	var visual := Polygon2D.new()
	visual.name = "SealVisual"
	visual.color = Color(0.95, 0.42, 0.18, 0.9)
	visual.polygon = PackedVector2Array([
		Vector2(0, -28),
		Vector2(10, -8),
		Vector2(28, 0),
		Vector2(10, 8),
		Vector2(0, 28),
		Vector2(-10, 8),
		Vector2(-28, 0),
		Vector2(-10, -8),
	])
	seal.add_child(visual)

func _add_sakuramori_save_shrine(position: Vector2) -> void:
	if get_node_or_null("SakuramoriSaveShrine") != null:
		return
	var shrine := SAKURAMORI_SAVE_SHRINE_SCRIPT.new() as Node2D
	shrine.name = "SakuramoriSaveShrine"
	shrine.position = position
	add_child(shrine)

func _add_party_shrine(position: Vector2) -> void:
	if get_node_or_null("PartyShrine") != null:
		return
	var shrine := PARTY_SHRINE_SCRIPT.new() as Node2D
	shrine.name = "PartyShrine"
	shrine.position = position
	add_child(shrine)

func _add_training_dummy(position: Vector2) -> void:
	var services := _ensure_container("Services")
	if services.get_node_or_null("TrainingDummy") != null:
		return
	var dummy := TRAINING_DUMMY_SCRIPT.new() as Node2D
	dummy.name = "TrainingDummy"
	dummy.position = position
	services.add_child(dummy)

func _add_locked_placeholder(node_name: String, service_id: String, position: Vector2) -> void:
	var services := _ensure_container("Services")
	if services.get_node_or_null(node_name) != null:
		return
	var placeholder := LOCKED_SERVICE_PLACEHOLDER_SCRIPT.new() as Node2D
	placeholder.name = node_name
	placeholder.set("service_id", service_id)
	placeholder.position = position
	services.add_child(placeholder)

func _set_exit_defeat_gate(exit_name: String, boss_id: String) -> void:
	var exit := get_node_or_null("Entrances/" + exit_name) as Area2D
	if exit != null:
		exit.set_meta("requires_defeat", boss_id)

func _set_exit_traversal_gate(exit_name: String, traversal_id: String) -> void:
	var exit := get_node_or_null("Entrances/" + exit_name) as Area2D
	if exit != null:
		exit.set_meta("required_traversal", traversal_id)

func _add_spike_hazard(position: Vector2) -> void:
	var hazards := _ensure_container("Hazards")
	if hazards.get_node_or_null("SpikeHazard") != null:
		return
	var hazard := Area2D.new()
	hazard.name = "SpikeHazard"
	hazard.position = position
	hazard.set_meta("hazard_type", "spikes")
	hazards.add_child(hazard)

	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = HAZARD_SIZE
	shape.shape = rectangle
	hazard.add_child(shape)

	var visual := Polygon2D.new()
	visual.name = "SpikeVisual"
	visual.color = Color(0.72, 0.15, 0.12, 1.0)
	visual.polygon = PackedVector2Array([
		Vector2(-60, 12),
		Vector2(-30, -12),
		Vector2(0, 12),
		Vector2(30, -12),
		Vector2(60, 12),
	])
	hazard.add_child(visual)

func _ensure_container(container_name: String) -> Node2D:
	var existing := get_node_or_null(container_name) as Node2D
	if existing != null:
		return existing
	var container := Node2D.new()
	container.name = container_name
	add_child(container)
	return container

func _exit_name(direction: String) -> String:
	match direction:
		"left":
			return "LeftEntrance"
		"right":
			return "RightEntrance"
		"top":
			return "TopEntrance"
		"bottom":
			return "BottomEntrance"
		"interior":
			return "InteriorEntrance"
		_:
			return direction.capitalize().replace(" ", "") + "Entrance"

func _exit_position(direction: String) -> Vector2:
	match direction:
		"left":
			return Vector2(room_bounds.position.x + 12.0, _floor_y() - 90.0)
		"right":
			return Vector2(room_bounds.position.x + room_bounds.size.x - 12.0, _floor_y() - 90.0)
		"top":
			return Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, room_bounds.position.y + 24.0)
		"bottom":
			return Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() + 20.0)
		"interior":
			return Vector2(room_bounds.position.x + room_bounds.size.x * 0.5, _floor_y() - 90.0)
		_:
			return Vector2(room_bounds.position.x + room_bounds.size.x - 12.0, _floor_y() - 90.0)

func _exit_shape_size(direction: String) -> Vector2:
	if direction in ["top", "bottom"]:
		return Vector2(EXIT_SIZE.y, EXIT_SIZE.x)
	return EXIT_SIZE

func _floor_y() -> float:
	return room_bounds.position.y + room_bounds.size.y - GROUND_HEIGHT

func _ground_color() -> Color:
	match zone_theme:
		"swamp":
			return Color(0.16, 0.29, 0.18, 1.0)
		"samurai_castle":
			return Color(0.31, 0.27, 0.25, 1.0)
		"sakuramori_court":
			return Color(0.25, 0.32, 0.26, 1.0)
		_:
			return Color(0.28, 0.25, 0.22, 1.0)

func _backdrop_color() -> Color:
	match zone_theme:
		"swamp":
			return Color(0.06, 0.12, 0.10, 1.0)
		"samurai_castle":
			return Color(0.09, 0.08, 0.10, 1.0)
		"sakuramori_court":
			return Color(0.11, 0.16, 0.14, 1.0)
		_:
			return Color(0.12, 0.10, 0.09, 1.0)

func _zone_art_texture() -> Texture2D:
	match zone_theme:
		"samurai_castle":
			return SAMURAI_ZONE_TEXTURE
		"sakuramori_court":
			return SAKURAMORI_ZONE_TEXTURE
		"castle_gate":
			return CASTLE_ZONE_TEXTURE
		_:
			return CASTLE_ZONE_TEXTURE
