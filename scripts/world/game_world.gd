extends Node2D
class_name GameWorld

signal area_completed(area_id: String)
signal settings_requested
signal quit_to_title_requested

const GameStateScript := preload("res://scripts/core/game_state.gd")
const CHECKPOINT_SHRINE_SCRIPT := preload("res://scripts/world/checkpoint_shrine.gd")
const UPGRADE_PICKUP_SCRIPT := preload("res://scripts/world/upgrade_pickup.gd")
const PLAYER_SCRIPT := preload("res://scripts/player/player.gd")
const FAMILIAR_SCRIPT := preload("res://scripts/player/player_familiar.gd")
const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const PAUSE_MENU_SCENE := preload("res://scenes/ui/PauseMenu.tscn")
const DEFAULT_SPAWN_POSITION := Vector2(64, 64)
const EXIT_SPAWN_OFFSET := 72.0
const HAZARD_DAMAGE := {
	"swamp_water": 8,
	"spikes": 14,
}
const HAZARD_COOLDOWN := 0.6
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
var hud: CanvasLayer
var pause_menu: Control
var is_transitioning_rooms := false
var hazard_cooldowns: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_hud()
	register_checkpoints_in(self)
	register_enemies_in(self)
	register_upgrade_pickups_in(self)
	register_room_exits_in(self)
	register_hazards_in(self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_pause_menu_open():
			close_pause_menu()
		else:
			open_pause_menu()
		get_viewport().set_input_as_handled()

func start_new_game(class_id: String, sprite_id: String) -> void:
	state = GameStateScript.new()
	state.selected_class = _valid_class_id(class_id)
	state.selected_sprite = _valid_sprite_id(state.selected_class, sprite_id)
	state.current_area = DEFAULT_AREA_ID
	state.current_room = DEFAULT_ROOM_ID
	load_room(state.current_room)
	_spawn_player(DEFAULT_SPAWN_POSITION)

func continue_game() -> void:
	var manager := _get_save_manager()
	if manager != null:
		state = manager.call("load_game") as GameStateScript
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

	hazard_cooldowns.clear()
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
	state.mark_room_discovered(resolved_room_id)

	register_checkpoints_in(current_room)
	register_enemies_in(current_room)
	register_upgrade_pickups_in(current_room)
	register_room_exits_in(current_room)
	register_hazards_in(current_room)
	_apply_open_shortcuts(current_room)
	_update_hud_map_context()
	return current_room

func _process(delta: float) -> void:
	if get_tree().paused and is_pause_menu_open():
		return
	for key: String in hazard_cooldowns.keys():
		hazard_cooldowns[key] = max(0.0, float(hazard_cooldowns[key]) - delta)

func open_pause_menu() -> void:
	if is_pause_menu_open():
		return
	pause_menu = PAUSE_MENU_SCENE.instantiate() as Control
	add_child(pause_menu)
	pause_menu.resume_requested.connect(close_pause_menu)
	pause_menu.settings_requested.connect(_on_pause_settings_requested)
	pause_menu.save_requested.connect(save_from_pause)
	pause_menu.quit_to_title_requested.connect(_on_pause_quit_to_title_requested)
	get_tree().paused = true

func close_pause_menu() -> void:
	if pause_menu != null:
		pause_menu.queue_free()
		pause_menu = null
	get_tree().paused = false

func is_pause_menu_open() -> bool:
	return pause_menu != null and is_instance_valid(pause_menu)

func save_from_pause() -> void:
	if state == null:
		return
	_store_player_state()
	_save_game_state()

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
	var enemy_id := str(enemy.get("enemy_id"))
	if state != null and not enemy_id.is_empty() and state.defeated_bosses.has(enemy_id):
		enemy.queue_free()
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

func register_room_exit(exit: Area2D) -> void:
	if exit == null:
		return
	var next_room := str(exit.get_meta("next_room", ""))
	if next_room.is_empty() or (not ROOM_SCENES.has(next_room) and not _is_completion_target(next_room)):
		return

	var callback := Callable(self, "_on_room_exit_body_entered").bind(exit)
	if not exit.body_entered.is_connected(callback):
		exit.body_entered.connect(callback)

func register_room_exits_in(root: Node) -> void:
	if root == null:
		return
	if root is Area2D:
		register_room_exit(root as Area2D)
	for child: Node in root.get_children():
		register_room_exits_in(child)

func register_hazard(hazard: Area2D) -> void:
	if hazard == null:
		return
	var hazard_type := str(hazard.get_meta("hazard_type", ""))
	if hazard_type.is_empty() or not HAZARD_DAMAGE.has(hazard_type):
		return

	var callback := Callable(self, "_on_hazard_body_entered").bind(hazard)
	if not hazard.body_entered.is_connected(callback):
		hazard.body_entered.connect(callback)

func register_hazards_in(root: Node) -> void:
	if root == null:
		return
	if root is Area2D:
		register_hazard(root as Area2D)
	for child: Node in root.get_children():
		register_hazards_in(child)

func activate_checkpoint(checkpoint_id: String, checkpoint_position: Vector2) -> void:
	if state == null:
		state = GameStateScript.new()
		_ensure_valid_selected_class()
		_ensure_valid_world_position()

	state.checkpoint_id = checkpoint_id
	state.checkpoint_room = get_current_room_id()
	state.checkpoint_position = checkpoint_position
	state.current_room = get_current_room_id()
	if player != null:
		state.current_health = int(player.get("current_health"))
		state.current_resource = int(player.get("current_resource"))
		state.level = int(player.get("level"))
		state.xp = int(player.get("xp"))
		var familiar := _get_active_familiar()
		if familiar != null:
			state.familiar_state = familiar.call("to_dictionary")
	_save_game_state()

func _spawn_player(spawn_position: Vector2) -> void:
	if player != null:
		player.queue_free()
		player = null

	_ensure_valid_selected_class()
	player = PLAYER_SCENE.instantiate() as CharacterBody2D
	add_child(player)
	player.global_position = spawn_position
	player.call("setup", CLASS_DATA[state.selected_class], state.selected_sprite)
	player.call("set_traversal_unlocks", state.traversal_unlocks)
	if player.has_method("set_learned_attack_skills"):
		player.call("set_learned_attack_skills", state.learned_attack_skills)
	_apply_familiar_state()
	if state.current_health > 0:
		player.set("current_health", state.current_health)
	if state.current_resource > 0:
		player.set("current_resource", state.current_resource)
	player.set("level", max(1, state.level))
	player.set("xp", max(0, state.xp))
	if player.has_signal("died"):
		player.connect("died", _on_player_died)
	_bind_hud_to_player()
	if player.has_method("emit_stats_changed"):
		player.call("emit_stats_changed")

func _on_player_died() -> void:
	if state == null:
		state = GameStateScript.new()
		_ensure_valid_selected_class()
		_ensure_valid_world_position()

	var respawn_room_id := _respawn_room_id()
	var respawn_position := state.checkpoint_position if state != null else Vector2.ZERO
	if respawn_position == Vector2.ZERO:
		respawn_position = DEFAULT_SPAWN_POSITION
	load_room(respawn_room_id)
	_spawn_player(respawn_position)
	if player != null and player.has_method("restore_vitals_to_max"):
		player.call("restore_vitals_to_max")
	_store_player_state()
	_save_game_state()

func _on_enemy_died(enemy_id: String, xp_reward: int) -> void:
	if player != null:
		player.call("gain_xp", xp_reward)
	var familiar := _get_active_familiar()
	if familiar != null:
		familiar.call("gain_xp", xp_reward)
	if state != null and not enemy_id.is_empty() and _room_has_defeat_gate_for(current_room, enemy_id):
		if not state.defeated_bosses.has(enemy_id):
			state.defeated_bosses.append(enemy_id)
		if current_room != null and current_room.has_method("mark_persistent_defeated"):
			current_room.call("mark_persistent_defeated", enemy_id)
		_save_game_state()

func _on_upgrade_collected(pickup_id: String, upgrade_id: String, upgrade_type: String) -> void:
	if state == null:
		state = GameStateScript.new()
		_ensure_valid_selected_class()
		_ensure_valid_world_position()

	if not pickup_id.is_empty() and not state.collected_pickups.has(pickup_id):
		state.collected_pickups.append(pickup_id)
	if upgrade_type == "traversal":
		var traversal_id := _resolve_traversal_upgrade_id(upgrade_id)
		if not traversal_id.is_empty() and not state.traversal_unlocks.has(traversal_id):
			state.traversal_unlocks.append(traversal_id)
			if player != null and player.has_method("set_traversal_unlocks"):
				player.call("set_traversal_unlocks", state.traversal_unlocks)
			_show_upgrade_feedback("Traversal unlocked", _format_upgrade_name(traversal_id))
	if upgrade_type == "attack_skill" and not upgrade_id.is_empty() and not state.learned_attack_skills.has(upgrade_id):
		state.learned_attack_skills.append(upgrade_id)
		if player != null and player.has_method("set_learned_attack_skills"):
			player.call("set_learned_attack_skills", state.learned_attack_skills)
		_show_upgrade_feedback("Attack skill learned", _format_upgrade_name(upgrade_id))
	_save_game_state()

func _on_room_exit_body_entered(body: Node, exit: Area2D) -> void:
	if is_transitioning_rooms or player == null or body != player:
		return

	var next_room := str(exit.get_meta("next_room", ""))
	if next_room.is_empty() or (not ROOM_SCENES.has(next_room) and not _is_completion_target(next_room)):
		return
	if not _can_use_room_exit(exit):
		return

	is_transitioning_rooms = true
	var previous_room_id := get_current_room_id()
	_store_player_state()
	if _is_completion_target(next_room):
		_complete_area(next_room)
		await get_tree().physics_frame
		is_transitioning_rooms = false
		return

	load_room(next_room)
	_update_shortcuts_for_room_entry(current_room, previous_room_id)
	player.global_position = _resolve_room_spawn_position(previous_room_id, exit)
	player.velocity = Vector2.ZERO
	if state != null:
		_save_game_state()
	await get_tree().physics_frame
	is_transitioning_rooms = false

func _on_hazard_body_entered(body: Node, hazard: Area2D) -> void:
	if player == null or body != player:
		return

	var hazard_type := str(hazard.get_meta("hazard_type", ""))
	if not HAZARD_DAMAGE.has(hazard_type) or not _can_apply_hazard(hazard_type):
		return

	hazard_cooldowns[hazard_type] = HAZARD_COOLDOWN
	player.call("take_damage", int(HAZARD_DAMAGE[hazard_type]))

func _can_apply_hazard(hazard_type: String) -> bool:
	return float(hazard_cooldowns.get(hazard_type, 0.0)) <= 0.0

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
	if not state.checkpoint_room.is_empty() and not ROOM_SCENES.has(state.checkpoint_room):
		state.checkpoint_room = ""

func _get_rooms_container() -> Node2D:
	var rooms := get_node_or_null("Rooms") as Node2D
	if rooms == null:
		rooms = Node2D.new()
		rooms.name = "Rooms"
		add_child(rooms)
	return rooms

func _respawn_room_id() -> String:
	if state == null:
		return DEFAULT_ROOM_ID
	if not state.checkpoint_room.is_empty() and ROOM_SCENES.has(state.checkpoint_room):
		return state.checkpoint_room
	return get_current_room_id()

func _ensure_hud() -> void:
	if hud != null:
		return
	hud = HUD_SCENE.instantiate() as CanvasLayer
	add_child(hud)

func _bind_hud_to_player() -> void:
	_ensure_hud()
	if hud != null and player is Player:
		hud.call("bind_player", player)
		_update_hud_map_context()

func _store_player_state() -> void:
	if state == null or player == null:
		return
	state.current_health = int(player.get("current_health"))
	state.current_resource = int(player.get("current_resource"))
	state.level = int(player.get("level"))
	state.xp = int(player.get("xp"))
	var familiar := _get_active_familiar()
	if familiar != null:
		state.familiar_state = familiar.call("to_dictionary")

func _save_game_state() -> void:
	if state == null:
		return
	var manager := _get_save_manager()
	if manager != null:
		manager.call("save_game", state)

func _on_pause_settings_requested() -> void:
	settings_requested.emit()

func _on_pause_quit_to_title_requested() -> void:
	close_pause_menu()
	quit_to_title_requested.emit()

func _show_upgrade_feedback(title: String, detail: String) -> void:
	_ensure_hud()
	if hud != null and hud.has_method("show_upgrade_feedback"):
		hud.call("show_upgrade_feedback", title, detail)

func _update_hud_map_context() -> void:
	_ensure_hud()
	if hud == null or state == null or not hud.has_method("set_map_context"):
		return
	hud.call("set_map_context", state.current_area, state.current_room, state.discovered_rooms)

func _get_save_manager() -> Node:
	return get_tree().root.get_node_or_null("SaveManager")

func _get_active_familiar() -> Node:
	if player == null:
		return null
	var familiar := player.get_node_or_null("Familiar")
	if familiar == null or familiar.get_script() != FAMILIAR_SCRIPT:
		return null
	return familiar

func _apply_familiar_state() -> void:
	if state == null or state.familiar_state.is_empty():
		return
	var familiar := _get_active_familiar()
	if familiar != null and familiar.has_method("apply_state"):
		familiar.call("apply_state", state.familiar_state)

func _resolve_room_spawn_position(previous_room_id: String, _source_exit: Area2D) -> Vector2:
	var matching_exit := _find_exit_to_room(current_room, previous_room_id)
	if matching_exit != null:
		return matching_exit.global_position + _entry_offset_for_exit(matching_exit)

	var player_start := current_room.get_node_or_null("PlayerStart") as Marker2D
	if player_start != null:
		return player_start.global_position
	return DEFAULT_SPAWN_POSITION

func _find_exit_to_room(root: Node, room_id: String) -> Area2D:
	if root == null:
		return null
	if root is Area2D and str(root.get_meta("next_room", "")) == room_id:
		return root as Area2D
	for child: Node in root.get_children():
		var match := _find_exit_to_room(child, room_id)
		if match != null:
			return match
	return null

func _entry_offset_for_exit(exit: Area2D) -> Vector2:
	var name_lower := exit.name.to_lower()
	if name_lower.contains("left"):
		return Vector2(EXIT_SPAWN_OFFSET, 0.0)
	if name_lower.contains("right"):
		return Vector2(-EXIT_SPAWN_OFFSET, 0.0)
	if name_lower.contains("top"):
		return Vector2(0.0, EXIT_SPAWN_OFFSET)
	if name_lower.contains("bottom"):
		return Vector2(0.0, -EXIT_SPAWN_OFFSET)
	return Vector2.ZERO

func _can_use_room_exit(exit: Area2D) -> bool:
	if state == null:
		return true

	var required_traversal := str(exit.get_meta("required_traversal", ""))
	if not required_traversal.is_empty():
		if not state.traversal_unlocks.has(_resolve_traversal_upgrade_id(required_traversal)):
			return false

	var requires_defeat := str(exit.get_meta("requires_defeat", ""))
	if not requires_defeat.is_empty() and not state.defeated_bosses.has(requires_defeat):
		return false

	return true

func _room_has_defeat_gate_for(root: Node, enemy_id: String) -> bool:
	if root == null or enemy_id.is_empty():
		return false
	if root.has_meta("requires_defeat") and str(root.get_meta("requires_defeat", "")) == enemy_id:
		return true
	for child: Node in root.get_children():
		if _room_has_defeat_gate_for(child, enemy_id):
			return true
	return false

func _is_completion_target(target_id: String) -> bool:
	return target_id.ends_with("_complete")

func _complete_area(completion_id: String) -> void:
	if state == null:
		return
	if not state.completed_areas.has(completion_id):
		state.completed_areas.append(completion_id)
	state.current_room = get_current_room_id()
	_show_upgrade_feedback("Area complete", _format_upgrade_name(completion_id))
	_save_game_state()
	area_completed.emit(completion_id)

func _update_shortcuts_for_room_entry(room: Node, previous_room_id: String) -> void:
	if state == null or room == null:
		return

	for gate: Node in _find_shortcut_gates(room):
		var shortcut_id := str(gate.get_meta("shortcut_id", ""))
		var opens_from := str(gate.get_meta("opens_from", ""))
		if shortcut_id.is_empty():
			continue
		if state.opened_shortcuts.has(shortcut_id):
			_open_shortcut_gate(gate)
			continue
		if opens_from == previous_room_id:
			state.opened_shortcuts.append(shortcut_id)
			_open_shortcut_gate(gate)
			_save_game_state()

func _apply_open_shortcuts(room: Node) -> void:
	if state == null or room == null:
		return

	for gate: Node in _find_shortcut_gates(room):
		var shortcut_id := str(gate.get_meta("shortcut_id", ""))
		if not shortcut_id.is_empty() and state.opened_shortcuts.has(shortcut_id):
			_open_shortcut_gate(gate)

func _find_shortcut_gates(root: Node) -> Array[Node]:
	var gates: Array[Node] = []
	if root == null:
		return gates
	if root.has_meta("shortcut_id"):
		gates.append(root)
	for child: Node in root.get_children():
		gates.append_array(_find_shortcut_gates(child))
	return gates

func _open_shortcut_gate(gate: Node) -> void:
	gate.queue_free()

func _format_upgrade_name(upgrade_id: String) -> String:
	var words := upgrade_id.replace("_", " ").split(" ", false)
	for index: int in words.size():
		words[index] = words[index].capitalize()
	return " ".join(words)

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

func _resolve_traversal_upgrade_id(upgrade_id: String) -> String:
	if upgrade_id != "first_traversal_tool":
		return upgrade_id
	if state == null or not CLASS_DATA.has(state.selected_class):
		return upgrade_id

	var class_data: Resource = CLASS_DATA[state.selected_class]
	if class_data != null and not class_data.traversal_unlocks.is_empty():
		return class_data.traversal_unlocks[0]
	return upgrade_id
