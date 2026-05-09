extends CharacterBody2D
class_name Player

signal died
signal leveled_up(new_level: int)

const GRAVITY := 980.0
const ClassData := preload("res://scripts/data/class_data.gd")
const XPCurve := preload("res://scripts/core/xp_curve.gd")
const DEFAULT_MOVE_SPEED := 160.0
const DEFAULT_JUMP_VELOCITY := -360.0

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

func setup(data: ClassData, sprite_path: String) -> void:
	class_data = data
	if class_data == null:
		return

	xp_curve.thresholds = class_data.xp_curve.duplicate()
	current_health = class_data.max_health
	current_resource = class_data.max_resource
	_load_sprite(sprite_path)
	_setup_class_controller(class_data)

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

func take_damage(amount: int) -> void:
	if amount <= 0:
		return

	current_health -= max(1, amount - _base_defense())
	if current_health <= 0:
		died.emit()

func perform_melee_attack(_damage: int) -> void:
	pass

func perform_guard_counter() -> void:
	pass

func start_blocking() -> void:
	pass

func fire_projectile(_damage: int) -> void:
	pass

func fire_piercing_shot(_damage: int) -> void:
	pass

func perform_slide() -> void:
	pass

func fire_spell(_damage: int) -> void:
	pass

func cast_binding_sigil() -> void:
	pass

func perform_blink() -> void:
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

func _base_defense() -> int:
	if class_data == null:
		return 0
	return class_data.base_defense
