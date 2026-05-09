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
const CLASS_DATA := {
	"warden": preload("res://data/classes/warden.tres"),
	"gunslinger": preload("res://data/classes/gunslinger.tres"),
	"hexbinder": preload("res://data/classes/hexbinder.tres"),
}

var state: GameStateScript
var player: CharacterBody2D

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
	register_upgrade_pickups_in(self)
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
	register_upgrade_pickups_in(self)
	_spawn_player(spawn_position)

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

func register_upgrade_pickup(pickup: UpgradePickup) -> void:
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
	if state.current_room.is_empty():
		state.current_room = DEFAULT_ROOM_ID

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
