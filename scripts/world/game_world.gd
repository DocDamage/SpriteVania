extends Node2D
class_name GameWorld

const GameStateScript := preload("res://scripts/core/game_state.gd")
const CHECKPOINT_SHRINE_SCRIPT := preload("res://scripts/world/checkpoint_shrine.gd")
const UPGRADE_PICKUP_SCRIPT := preload("res://scripts/world/upgrade_pickup.gd")
const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const DEFAULT_SPAWN_POSITION := Vector2(64, 64)
const DEFAULT_CLASS_ID := "warden"
const DEFAULT_AREA_ID := "swamp_outskirts"
const DEFAULT_ROOM_ID := "RoomStart"
const ROOM_SCENES := {
	"RoomStart": preload("res://scenes/world/swamp_outskirts/RoomStart.tscn"),
	"RoomMovement": preload("res://scenes/world/swamp_outskirts/RoomMovement.tscn"),
	"RoomEnemy": preload("res://scenes/world/swamp_outskirts/RoomEnemy.tscn"),
	"RoomHazard": preload("res://scenes/world/swamp_outskirts/RoomHazard.tscn"),
	"RoomCheckpoint": preload("res://scenes/world/swamp_outskirts/RoomCheckpoint.tscn"),
	"RoomUpgrade": preload("res://scenes/world/swamp_outskirts/RoomUpgrade.tscn"),
	"RoomShortcut": preload("res://scenes/world/swamp_outskirts/RoomShortcut.tscn"),
	"RoomMiniBoss": preload("res://scenes/world/swamp_outskirts/RoomMiniBoss.tscn"),
}
const CLASS_DATA := {
	"warden": preload("res://data/classes/warden.tres"),
	"gunslinger": preload("res://data/classes/gunslinger.tres"),
	"hexbinder": preload("res://data/classes/hexbinder.tres"),
}

var state: GameStateScript
var player: CharacterBody2D
var current_room: Node2D

func _ready() -> void:
	register_checkpoints_in(self)
	register_enemies_in(self)
	register_upgrade_pickups_in(self)

func start_new_game(class_id: String, sprite_id: String) -> void:
	state = GameStateScript.new()
	state.selected_class = _valid_class_id(class_id)
	state.selected_sprite = _valid_sprite_id(state.selected_class, sprite_id)
	state.current_area = DEFAULT_AREA_ID
	state.current_room = DEFAULT_ROOM_ID
	load_room(state.current_room)
	_spawn_player(DEFAULT_SPAWN_POSITION)

func continue_game() -> void:
	state = SaveManager.load_game()
	if state == null:
		state = GameStateScript.new()

	_ensure_valid_selected_class()
	_ensure_valid_world_position()
	var spawn_position := state.checkpoint_position
	if spawn_position == Vector2.ZERO:
		spawn_position = DEFAULT_SPAWN_POSITION
	load_room(state.current_room)
	_spawn_player(spawn_position)

func load_room(room_id: String) -> Node2D:
	var resolved_room_id := room_id
	if resolved_room_id.is_empty() or not ROOM_SCENES.has(resolved_room_id):
		resolved_room_id = DEFAULT_ROOM_ID

	var rooms := _get_rooms_container()
	for child: Node in rooms.get_children():
		rooms.remove_child(child)
		child.queue_free()

	current_room = ROOM_SCENES[resolved_room_id].instantiate() as Node2D
	rooms.add_child(current_room)
	if current_room.has_method("enter_room"):
		current_room.call("enter_room")

	if state == null:
		state = GameStateScript.new()
	state.current_area = DEFAULT_AREA_ID
	state.current_room = resolved_room_id

	register_checkpoints_in(current_room)
	register_enemies_in(current_room)
	register_upgrade_pickups_in(current_room)
	return current_room

func get_current_room_id() -> String:
	if state == null:
		return DEFAULT_ROOM_ID
	if state.current_room.is_empty() or not ROOM_SCENES.has(state.current_room):
		return DEFAULT_ROOM_ID
	return state.current_room

func register_checkpoint(checkpoint: Area2D) -> void:
	if checkpoint == null or checkpoint.get_script() != CHECKPOINT_SHRINE_SCRIPT:
		return
	if not checkpoint.has_signal("checkpoint_activated"):
		return

	var callback := Callable(self, "activate_checkpoint")
	if not checkpoint.is_connected("checkpoint_activated", callback):
		checkpoint.connect("checkpoint_activated", callback)

func register_checkpoints_in(root: Node) -> void:
	if root == null:
		return
	if root is Area2D:
		register_checkpoint(root)
	for child: Node in root.get_children():
		register_checkpoints_in(child)

func register_enemy(enemy: Node) -> void:
	if enemy == null:
		return
	if not enemy.has_signal("died"):
		return

	var callback := Callable(self, "_on_enemy_died")
	if not enemy.is_connected("died", callback):
		enemy.connect("died", callback)

func register_enemies_in(root: Node) -> void:
	if root == null:
		return
	if root.has_method("take_damage") and root.has_signal("died"):
		register_enemy(root)
	for child: Node in root.get_children():
		register_enemies_in(child)

func register_upgrade_pickup(pickup: Area2D) -> void:
	if pickup == null or pickup.get_script() != UPGRADE_PICKUP_SCRIPT:
		return
	if state != null and state.collected_pickups.has(pickup.pickup_id):
		pickup.queue_free()
		return

	var callback := Callable(self, "_on_upgrade_collected")
	if not pickup.is_connected("upgrade_collected", callback):
		pickup.connect("upgrade_collected", callback)

func register_upgrade_pickups_in(root: Node) -> void:
	if root == null:
		return
	if root is Area2D and root.get_script() == UPGRADE_PICKUP_SCRIPT:
		register_upgrade_pickup(root)
	for child: Node in root.get_children():
		register_upgrade_pickups_in(child)

func activate_checkpoint(checkpoint_id: String, checkpoint_position: Vector2) -> void:
	if state == null:
		state = GameStateScript.new()
		_ensure_valid_selected_class()
		_ensure_valid_world_position()

	state.checkpoint_id = checkpoint_id
	state.checkpoint_position = checkpoint_position
	if player != null:
		state.current_health = int(player.get("current_health"))
		state.current_resource = int(player.get("current_resource"))
		state.level = int(player.get("level"))
		state.xp = int(player.get("xp"))
	SaveManager.save_game(state)

func _spawn_player(spawn_position: Vector2) -> void:
	if player != null:
		player.queue_free()
		player = null

	_ensure_valid_selected_class()
	player = PLAYER_SCENE.instantiate() as CharacterBody2D
	add_child(player)
	player.global_position = spawn_position
	player.call("setup", CLASS_DATA[state.selected_class], state.selected_sprite)
	if state.current_health > 0:
		player.set("current_health", state.current_health)
	if state.current_resource > 0:
		player.set("current_resource", state.current_resource)
	player.set("level", max(1, state.level))
	player.set("xp", max(0, state.xp))
	if player.has_signal("died"):
		player.connect("died", _on_player_died)

func _on_player_died() -> void:
	var respawn_position := state.checkpoint_position if state != null else Vector2.ZERO
	if respawn_position == Vector2.ZERO:
		respawn_position = DEFAULT_SPAWN_POSITION
	_spawn_player(respawn_position)

func _on_enemy_died(_enemy_id: String, xp_reward: int) -> void:
	if player != null:
		player.call("gain_xp", xp_reward)

func _on_upgrade_collected(pickup_id: String, upgrade_id: String, upgrade_type: String) -> void:
	if state == null:
		state = GameStateScript.new()
		_ensure_valid_selected_class()
		_ensure_valid_world_position()

	if not pickup_id.is_empty() and not state.collected_pickups.has(pickup_id):
		state.collected_pickups.append(pickup_id)
	if upgrade_type == "traversal" and not upgrade_id.is_empty() and not state.traversal_unlocks.has(upgrade_id):
		state.traversal_unlocks.append(upgrade_id)
	if upgrade_type == "attack_skill" and not upgrade_id.is_empty() and not state.learned_attack_skills.has(upgrade_id):
		state.learned_attack_skills.append(upgrade_id)
	SaveManager.save_game(state)

func _ensure_valid_selected_class() -> void:
	if state == null:
		return
	state.selected_class = _valid_class_id(state.selected_class)
	state.selected_sprite = _valid_sprite_id(state.selected_class, state.selected_sprite)

func _ensure_valid_world_position() -> void:
	if state == null:
		return
	if state.current_area.is_empty():
		state.current_area = DEFAULT_AREA_ID
	if state.current_room.is_empty() or not ROOM_SCENES.has(state.current_room):
		state.current_room = DEFAULT_ROOM_ID

func _get_rooms_container() -> Node2D:
	var rooms := get_node_or_null("Rooms") as Node2D
	if rooms == null:
		rooms = Node2D.new()
		rooms.name = "Rooms"
		add_child(rooms)
	return rooms

func _valid_class_id(class_id: String) -> String:
	if CLASS_DATA.has(class_id):
		return class_id
	return DEFAULT_CLASS_ID

func _valid_sprite_id(class_id: String, sprite_id: String) -> String:
	if not CLASS_DATA.has(class_id):
		class_id = DEFAULT_CLASS_ID

	var class_data: Resource = CLASS_DATA[class_id]
	if class_data != null and class_data.sprite_options.has(sprite_id):
		return sprite_id
	if class_data != null and not class_data.sprite_options.is_empty():
		return class_data.sprite_options[0]
	return ""
