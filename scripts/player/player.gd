extends CharacterBody2D
class_name Player

signal died
signal leveled_up(new_level: int)
signal stats_changed(stats: Dictionary)

const GRAVITY := 980.0
const ClassData := preload("res://scripts/data/class_data.gd")
const XPCurve := preload("res://scripts/core/xp_curve.gd")
const PlayerProjectile := preload("res://scripts/player/player_projectile.gd")
const DEFAULT_MOVE_SPEED := 160.0
const DEFAULT_JUMP_VELOCITY := -360.0
const MELEE_RANGE := Vector2(46, 34)
const MELEE_OFFSET := Vector2(30, -8)
const PROJECTILE_OFFSET := Vector2(22, -12)
const PROJECTILE_LIFETIME := 1.15
const PROJECTILE_SPEED := 430.0
const PIERCING_PROJECTILE_SPEED := 520.0
const ARMORED_DASH_DISTANCE := 86.0
const HOOKSHOT_PULL_DISTANCE := 112.0
const HOOKSHOT_LIFT := 20.0

@onready var sprite: Sprite2D = get_node_or_null("%Sprite2D") as Sprite2D
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("%AnimatedSprite2D") as AnimatedSprite2D

var class_data: ClassData
var class_controller: Node
var xp_curve: XPCurve = XPCurve.new()
var current_health := 100
var current_resource := 50
var xp := 0
var level := 1
var facing_direction := 1.0
var traversal_unlocks: Array[String] = []

func _ready() -> void:
	add_to_group("player")

func setup(data: ClassData, sprite_path: String) -> void:
	class_data = data
	if class_data == null:
		return

	xp_curve.thresholds = class_data.xp_curve.duplicate()
	current_health = class_data.max_health
	current_resource = class_data.max_resource
	_load_sprite(sprite_path)
	_setup_class_controller(class_data)
	emit_stats_changed()

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing_direction = signf(direction)

	velocity.x = direction * _move_speed()
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = _jump_velocity()

	move_and_slide()
	_update_animation()

	if class_controller == null:
		return
	if Input.is_action_just_pressed("attack"):
		class_controller.call("handle_attack")
	if Input.is_action_just_pressed("special_attack"):
		class_controller.call("handle_special_attack")
	if Input.is_action_just_pressed("class_action"):
		class_controller.call("handle_class_action")

func gain_xp(amount: int) -> void:
	if amount <= 0:
		return

	xp += amount
	var next_level := xp_curve.level_for_xp(xp)
	if next_level > level:
		level = next_level
		current_health = _max_health()
		leveled_up.emit(level)
	emit_stats_changed()

func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	current_health -= max(1, amount - _base_defense())
	emit_stats_changed()
	if current_health <= 0:
		died.emit()

func set_traversal_unlocks(unlocks: Array[String]) -> void:
	traversal_unlocks = unlocks.duplicate()

func has_traversal_unlock(unlock_id: String) -> bool:
	return traversal_unlocks.has(unlock_id)

func get_stats() -> Dictionary:
	var max_health := _max_health()
	var max_resource := _max_resource()
	var xp_for_current_level := _xp_for_level(level)
	var xp_for_next_level := _xp_for_level(level + 1)
	return {
		"health": clampi(current_health, 0, max_health),
		"max_health": max_health,
		"resource": clampi(current_resource, 0, max_resource),
		"max_resource": max_resource,
		"level": level,
		"xp": xp,
		"xp_progress": max(0, xp - xp_for_current_level),
		"xp_required": max(1, xp_for_next_level - xp_for_current_level),
	}

func emit_stats_changed() -> void:
	stats_changed.emit(get_stats())

func perform_melee_attack(damage: int) -> void:
	if damage <= 0:
		return
	_play_action_animation("shoot")
	for target: Node in _query_attack_targets(MELEE_RANGE, MELEE_OFFSET):
		target.call("take_damage", damage)

func perform_guard_counter() -> void:
	pass

func start_blocking() -> void:
	pass

func perform_armored_dash() -> void:
	if not has_traversal_unlock("armored_dash"):
		return
	global_position.x += ARMORED_DASH_DISTANCE * facing_direction
	velocity.x = 0.0

func fire_projectile(damage: int) -> void:
	_spawn_projectile(damage, PROJECTILE_SPEED, PROJECTILE_LIFETIME, Color(0.9, 0.82, 0.35, 1.0))

func fire_piercing_shot(damage: int) -> void:
	_spawn_projectile(damage, PIERCING_PROJECTILE_SPEED, PROJECTILE_LIFETIME * 1.25, Color(0.95, 0.55, 0.22, 1.0), true)

func perform_slide() -> void:
	if not has_traversal_unlock("combat_slide"):
		return
	global_position.x += ARMORED_DASH_DISTANCE * facing_direction
	velocity.x = 0.0

func perform_hookshot() -> void:
	if not has_traversal_unlock("hookshot"):
		return
	global_position += Vector2(HOOKSHOT_PULL_DISTANCE * facing_direction, -HOOKSHOT_LIFT)
	velocity = Vector2.ZERO

func fire_spell(damage: int) -> void:
	_spawn_projectile(damage, PROJECTILE_SPEED * 0.85, PROJECTILE_LIFETIME, Color(0.55, 0.35, 0.95, 1.0))

func cast_binding_sigil() -> void:
	for target: Node in _query_attack_targets(Vector2(78, 48), Vector2(40, -8)):
		target.call("take_damage", 4)

func perform_blink() -> void:
	if not has_traversal_unlock("blink"):
		return
	global_position.x += 48.0 * facing_direction

func _load_sprite(sprite_path: String) -> void:
	if sprite_path.is_empty() or not ResourceLoader.exists(sprite_path):
		return

	var texture := load(sprite_path)
	if texture == null:
		return

	var target_sprite := _sprite_node()
	if target_sprite != null:
		target_sprite.texture = texture

func _setup_class_controller(data: ClassData) -> void:
	if class_controller != null:
		class_controller.queue_free()
		class_controller = null
	if data.controller_script == null:
		return

	var controller_node: Object = data.controller_script.new()
	if not controller_node is Node or not controller_node.has_method("setup"):
		push_warning("Controller script is not a PlayerClassController: " + data.controller_script.resource_path)
		if controller_node is Node:
			controller_node.queue_free()
		return

	class_controller = controller_node
	add_child(class_controller)
	class_controller.call("setup", self, data)

func _sprite_node() -> Sprite2D:
	if sprite != null:
		return sprite
	return get_node_or_null("%Sprite2D") as Sprite2D

func _update_animation() -> void:
	if animated_sprite == null:
		return

	animated_sprite.flip_h = facing_direction < 0.0
	var next_animation := "idle"
	if not is_on_floor():
		if velocity.y < 0.0:
			next_animation = "jump"
		else:
			next_animation = "fall"
	elif absf(velocity.x) > 1.0:
		next_animation = "run"

	if animated_sprite.animation != next_animation:
		animated_sprite.play(next_animation)
	elif not animated_sprite.is_playing():
		animated_sprite.play()

func _play_action_animation(animation_name: String) -> void:
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)

func _query_attack_targets(size: Vector2, offset: Vector2) -> Array[Node]:
	var shape := RectangleShape2D.new()
	shape.size = size
	var parameters := PhysicsShapeQueryParameters2D.new()
	parameters.shape = shape
	parameters.transform = Transform2D(0.0, global_position + Vector2(offset.x * facing_direction, offset.y))
	parameters.exclude = [get_rid()]
	parameters.collide_with_areas = false
	parameters.collide_with_bodies = true

	var targets: Array[Node] = []
	for hit: Dictionary in get_world_2d().direct_space_state.intersect_shape(parameters, 16):
		var collider := hit.get("collider") as Node
		if collider == null or collider == self or not collider.has_method("take_damage"):
			continue
		if targets.has(collider):
			continue
		targets.append(collider)
	return targets

func _spawn_projectile(damage: int, speed: float, lifetime: float, color: Color, piercing := false) -> void:
	if damage <= 0:
		return
	_play_action_animation("shoot")
	var projectile := PlayerProjectile.new()
	projectile.damage = damage
	projectile.speed = speed
	projectile.lifetime = lifetime
	projectile.direction = Vector2(facing_direction, 0.0)
	projectile.global_position = global_position + Vector2(PROJECTILE_OFFSET.x * facing_direction, PROJECTILE_OFFSET.y)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0 if not piercing else 4.0
	shape.shape = circle
	projectile.add_child(shape)

	var sprite := ColorRect.new()
	sprite.color = color
	sprite.size = Vector2(12, 5) if not piercing else Vector2(18, 4)
	sprite.position = -sprite.size * 0.5
	projectile.add_child(sprite)

	var projectile_parent := get_tree().current_scene
	if projectile_parent == null:
		projectile_parent = get_parent()
	projectile_parent.add_child(projectile)

func _move_speed() -> float:
	if class_data == null:
		return DEFAULT_MOVE_SPEED
	return class_data.move_speed

func _jump_velocity() -> float:
	if class_data == null:
		return DEFAULT_JUMP_VELOCITY
	return class_data.jump_velocity

func _max_health() -> int:
	if class_data == null:
		return current_health
	return class_data.max_health + ((level - 1) * 10)

func _max_resource() -> int:
	if class_data == null:
		return current_resource
	return class_data.max_resource

func _xp_for_level(target_level: int) -> int:
	if target_level <= 1 or xp_curve.thresholds.is_empty():
		return 0
	if target_level > xp_curve.thresholds.size():
		return xp_curve.thresholds[xp_curve.thresholds.size() - 1]
	return xp_curve.thresholds[target_level - 1]

func _base_defense() -> int:
	if class_data == null:
		return 0
	return class_data.base_defense
