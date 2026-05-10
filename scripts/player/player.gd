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
const MELEE_RANGE := Vector2(86, 42)
const MELEE_OFFSET := Vector2(48, -8)
const PROJECTILE_OFFSET := Vector2(22, -12)
const PROJECTILE_LIFETIME := 1.15
const PROJECTILE_SPEED := 430.0
const PIERCING_PROJECTILE_SPEED := 520.0
const BASE_DASH_DISTANCE := 92.0
const ARMORED_DASH_DISTANCE := 86.0
const DASH_DURATION := 0.14
const WALL_JUMP_HORIZONTAL_SPEED := 210.0
const WALL_HANG_FALL_SPEED := 28.0
const SLIDE_ATTACK_RANGE := Vector2(190, 34)
const SLIDE_ATTACK_OFFSET := Vector2(-43, -4)
const DIVE_BOMB_RANGE := Vector2(54, 76)
const DIVE_BOMB_OFFSET := Vector2(0, 36)
const DIVE_BOMB_BOUNCE_VELOCITY := -320.0
const HOOKSHOT_PULL_DISTANCE := 112.0
const HOOKSHOT_LIFT := 20.0
const COMBO_WINDOW := 0.55
const COMBO_MULTIPLIERS := [1.0, 1.35, 1.75]
const SKILL_COSTS := {
	"armored_dash": 8,
	"combat_slide": 6,
	"hookshot": 8,
	"recoil_jump": 8,
	"blink": 8,
	"float_fall": 6,
	"phase_barrier": 10,
	"guard_counter": 12,
	"piercing_shot": 10,
	"binding_sigil": 18,
}
const SKILL_COOLDOWNS := {
	"armored_dash": 0.45,
	"combat_slide": 0.35,
	"hookshot": 0.55,
	"recoil_jump": 0.45,
	"blink": 0.55,
	"float_fall": 0.4,
	"phase_barrier": 0.7,
	"guard_counter": 0.75,
	"piercing_shot": 0.45,
	"binding_sigil": 0.8,
}

@export var invulnerability_duration := 0.45
@export var hit_flash_duration := 0.12
@export var knockback_strength := 220.0
@export var max_air_jumps := 1
@export var dash_cooldown := 0.28

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
var learned_attack_skills: Array[String] = []
var is_invulnerable := false
var is_hit_flashing := false
var is_wall_hanging := false
var is_dashing := false

var _invulnerability_time_remaining := 0.0
var _hit_flash_time_remaining := 0.0
var _skill_cooldowns: Dictionary = {}
var _air_jumps_remaining := 1
var _dash_cooldown_remaining := 0.0
var _dash_time_remaining := 0.0
var _dash_direction := 1.0
var _dash_speed := 0.0
var _combo_step := 0
var _combo_time_remaining := 0.0
var _wall_direction := 0.0
var _is_dead := false

func _ready() -> void:
	add_to_group("player")

func setup(data: ClassData, sprite_path: String) -> void:
	class_data = data
	if class_data == null:
		return

	xp_curve.thresholds = class_data.xp_curve.duplicate()
	current_health = class_data.max_health
	current_resource = class_data.max_resource
	_is_dead = false
	_load_sprite(sprite_path)
	_setup_class_controller(class_data)
	_clear_damage_feedback()
	emit_stats_changed()

func _process(delta: float) -> void:
	_tick_damage_feedback(delta)
	_tick_skill_cooldowns(delta)
	_dash_cooldown_remaining = maxf(0.0, _dash_cooldown_remaining - delta)
	_combo_time_remaining = maxf(0.0, _combo_time_remaining - delta)
	if _combo_time_remaining <= 0.0:
		_combo_step = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing_direction = signf(direction)

	if is_dashing:
		_dash_time_remaining = maxf(0.0, _dash_time_remaining - delta)
		velocity.x = _dash_direction * _dash_speed
		velocity.y = 0.0
		if _dash_time_remaining <= 0.0:
			is_dashing = false
			velocity.x = direction * _move_speed()
	elif not is_wall_hanging:
		velocity.x = direction * _move_speed()
	if is_on_floor():
		_air_jumps_remaining = max_air_jumps
		_stop_wall_hang()
	elif not is_dashing and _should_wall_hang(direction):
		start_wall_hang(signf(direction))

	if is_wall_hanging:
		velocity.x = 0.0
		velocity.y = minf(velocity.y, WALL_HANG_FALL_SPEED)
	elif not is_on_floor() and not is_dashing:
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump"):
		perform_jump()
	if InputMap.has_action("dash") and Input.is_action_just_pressed("dash"):
		perform_dash()

	move_and_slide()
	_update_animation()

	if class_controller == null:
		return
	if Input.is_action_just_pressed("attack"):
		if _should_dive_bomb():
			perform_dive_bomb(class_data.base_attack if class_data != null else 10)
		else:
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
	if _is_dead:
		return
	if is_invulnerable:
		return

	current_health -= _mitigated_damage(amount)
	_start_damage_feedback()
	emit_stats_changed()
	if current_health <= 0:
		_is_dead = true
		died.emit()

func restore_resource(amount: int) -> void:
	if amount <= 0:
		return
	var restored_resource := clampi(current_resource + amount, 0, _max_resource())
	if restored_resource == current_resource:
		return
	current_resource = restored_resource
	emit_stats_changed()

func restore_vitals_to_max() -> void:
	current_health = _max_health()
	current_resource = _max_resource()
	_is_dead = false
	_clear_damage_feedback()
	emit_stats_changed()

func perform_jump() -> void:
	if is_wall_hanging:
		var launch_direction := -_wall_direction
		_stop_wall_hang()
		velocity.x = launch_direction * WALL_JUMP_HORIZONTAL_SPEED
		velocity.y = _jump_velocity()
		facing_direction = launch_direction
		_air_jumps_remaining = max_air_jumps
		return
	if is_on_floor():
		velocity.y = _jump_velocity()
		_air_jumps_remaining = max_air_jumps
		return
	if _air_jumps_remaining <= 0:
		return
	_air_jumps_remaining -= 1
	velocity.y = _jump_velocity()

func perform_dash() -> void:
	if _dash_cooldown_remaining > 0.0:
		return
	_start_dash(BASE_DASH_DISTANCE, dash_cooldown)

func set_traversal_unlocks(unlocks: Array[String]) -> void:
	traversal_unlocks = unlocks.duplicate()

func has_traversal_unlock(unlock_id: String) -> bool:
	return traversal_unlocks.has(unlock_id)

func set_learned_attack_skills(skills: Array[String]) -> void:
	learned_attack_skills = skills.duplicate()

func has_attack_skill(skill_id: String) -> bool:
	return learned_attack_skills.has(skill_id)

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
	var combo_damage := _combo_damage(damage)
	_advance_combo()
	for target: Node in _query_attack_targets(MELEE_RANGE, MELEE_OFFSET):
		target.call("take_damage", combo_damage)

func perform_guard_counter() -> void:
	if not _try_use_attack_skill("guard_counter"):
		return
	_play_action_animation("shoot")
	is_invulnerable = true
	_invulnerability_time_remaining = maxf(_invulnerability_time_remaining, 0.3)
	for target: Node in _query_attack_targets(Vector2(62, 42), Vector2(34, -8)):
		target.call("take_damage", class_data.base_attack * 2 if class_data != null else 20)

func apply_knockback(source_position: Vector2, strength := knockback_strength) -> void:
	var knockback_direction := signf(global_position.x - source_position.x)
	if knockback_direction == 0.0:
		knockback_direction = -facing_direction
	velocity.x = knockback_direction * strength
	velocity.y = minf(velocity.y, -strength * 0.35)

func start_blocking() -> void:
	pass

func perform_armored_dash() -> void:
	if not has_traversal_unlock("armored_dash"):
		return
	if not _try_use_unlocked_skill("armored_dash"):
		return
	_start_dash(ARMORED_DASH_DISTANCE, float(SKILL_COOLDOWNS.get("armored_dash", dash_cooldown)))

func fire_projectile(damage: int) -> void:
	_spawn_projectile(damage, PROJECTILE_SPEED, PROJECTILE_LIFETIME, Color(0.9, 0.82, 0.35, 1.0))

func fire_piercing_shot(damage: int) -> void:
	if not _try_use_attack_skill("piercing_shot"):
		return
	_spawn_projectile(damage, PIERCING_PROJECTILE_SPEED, PROJECTILE_LIFETIME * 1.25, Color(0.95, 0.55, 0.22, 1.0), true)

func perform_slide() -> void:
	if not has_traversal_unlock("combat_slide"):
		return
	if not _try_use_unlocked_skill("combat_slide"):
		return
	global_position.x += ARMORED_DASH_DISTANCE * facing_direction
	velocity.x = 0.0
	_play_action_animation("run")
	var damage := class_data.base_attack if class_data != null else 10
	for target: Node in _query_attack_targets(SLIDE_ATTACK_RANGE, SLIDE_ATTACK_OFFSET):
		target.call("take_damage", damage)

func perform_dive_bomb(damage: int) -> void:
	if damage <= 0:
		return
	_play_action_animation("shoot")
	velocity.y = maxf(velocity.y, 520.0)
	var hit_targets := _query_attack_targets(DIVE_BOMB_RANGE, DIVE_BOMB_OFFSET)
	if hit_targets.is_empty():
		return
	var dive_damage := int(roundi(float(damage) * 1.5))
	for target: Node in hit_targets:
		target.call("take_damage", dive_damage)
	velocity.y = DIVE_BOMB_BOUNCE_VELOCITY
	_air_jumps_remaining = max_air_jumps

func start_wall_hang(wall_direction: float) -> void:
	if is_zero_approx(wall_direction):
		return
	_wall_direction = signf(wall_direction)
	is_wall_hanging = true
	velocity.x = 0.0
	velocity.y = minf(velocity.y, 0.0)

func _stop_wall_hang() -> void:
	is_wall_hanging = false
	_wall_direction = 0.0

func perform_hookshot() -> void:
	if not has_traversal_unlock("hookshot"):
		return
	if not _try_use_unlocked_skill("hookshot"):
		return
	global_position += Vector2(HOOKSHOT_PULL_DISTANCE * facing_direction, -HOOKSHOT_LIFT)
	velocity = Vector2.ZERO

func perform_recoil_jump() -> void:
	if not has_traversal_unlock("recoil_jump"):
		return
	if not _try_use_unlocked_skill("recoil_jump"):
		return
	global_position += Vector2(-36.0 * facing_direction, -44.0)
	velocity = Vector2(-180.0 * facing_direction, -220.0)

func fire_spell(damage: int) -> void:
	_spawn_projectile(damage, PROJECTILE_SPEED * 0.85, PROJECTILE_LIFETIME, Color(0.55, 0.35, 0.95, 1.0))

func cast_binding_sigil() -> void:
	if not _try_use_attack_skill("binding_sigil"):
		return
	_play_action_animation("shoot")
	for target: Node in _query_attack_targets(Vector2(78, 48), Vector2(40, -8)):
		target.call("take_damage", class_data.base_attack + 4 if class_data != null else 16)

func perform_blink() -> void:
	if not has_traversal_unlock("blink"):
		return
	if not _try_use_unlocked_skill("blink"):
		return
	global_position.x += 48.0 * facing_direction

func perform_float_fall() -> void:
	if not has_traversal_unlock("float_fall"):
		return
	if not _try_use_unlocked_skill("float_fall"):
		return
	velocity.y = minf(velocity.y, 60.0)

func perform_phase_barrier() -> void:
	if not has_traversal_unlock("phase_barrier"):
		return
	if not _try_use_unlocked_skill("phase_barrier"):
		return
	is_invulnerable = true
	_invulnerability_time_remaining = maxf(_invulnerability_time_remaining, 0.35)

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

func _should_wall_hang(input_direction: float) -> bool:
	if is_on_floor() or not is_on_wall_only() or input_direction == 0.0:
		return false
	var wall_normal := get_wall_normal()
	if wall_normal == Vector2.ZERO:
		return false
	return signf(input_direction) == -signf(wall_normal.x)

func _update_animation() -> void:
	if animated_sprite == null:
		return

	animated_sprite.flip_h = facing_direction < 0.0
	var next_animation := "idle"
	if is_wall_hanging:
		next_animation = "fall"
	elif not is_on_floor():
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

func _start_dash(distance: float, cooldown: float) -> void:
	_dash_direction = signf(facing_direction)
	if is_zero_approx(_dash_direction):
		_dash_direction = 1.0
	_dash_speed = distance / DASH_DURATION
	_dash_time_remaining = DASH_DURATION
	is_dashing = true
	is_wall_hanging = false
	velocity.x = _dash_direction * _dash_speed
	velocity.y = 0.0
	_dash_cooldown_remaining = cooldown

func _combo_damage(base_damage: int) -> int:
	var multiplier_index := mini(_combo_step, COMBO_MULTIPLIERS.size() - 1)
	return max(1, int(round(float(base_damage) * float(COMBO_MULTIPLIERS[multiplier_index]))))

func _advance_combo() -> void:
	_combo_step = (_combo_step + 1) % COMBO_MULTIPLIERS.size()
	_combo_time_remaining = COMBO_WINDOW

func _should_dive_bomb() -> bool:
	if is_on_floor() or not InputMap.has_action("move_down"):
		return false
	return Input.is_action_pressed("move_down")

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
	projectile.piercing = piercing
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

func _mitigated_damage(amount: int) -> int:
	var damage_after_defense: int = max(1, amount - _base_defense())
	var familiar: Node = get_node_or_null("Familiar")
	if familiar != null and familiar.has_method("reduce_incoming_damage"):
		return int(familiar.call("reduce_incoming_damage", damage_after_defense))
	return damage_after_defense

func _start_damage_feedback() -> void:
	_invulnerability_time_remaining = maxf(0.0, invulnerability_duration)
	_hit_flash_time_remaining = maxf(0.0, hit_flash_duration)
	is_invulnerable = _invulnerability_time_remaining > 0.0
	is_hit_flashing = _hit_flash_time_remaining > 0.0

func _tick_damage_feedback(delta: float) -> void:
	if _invulnerability_time_remaining > 0.0:
		_invulnerability_time_remaining = maxf(0.0, _invulnerability_time_remaining - delta)
		is_invulnerable = _invulnerability_time_remaining > 0.0
	if _hit_flash_time_remaining > 0.0:
		_hit_flash_time_remaining = maxf(0.0, _hit_flash_time_remaining - delta)
		is_hit_flashing = _hit_flash_time_remaining > 0.0

func _clear_damage_feedback() -> void:
	_invulnerability_time_remaining = 0.0
	_hit_flash_time_remaining = 0.0
	is_invulnerable = false
	is_hit_flashing = false

func _try_use_attack_skill(skill_id: String) -> bool:
	if not has_attack_skill(skill_id):
		return false
	return _try_use_unlocked_skill(skill_id)

func _try_use_unlocked_skill(skill_id: String) -> bool:
	if float(_skill_cooldowns.get(skill_id, 0.0)) > 0.0:
		return false
	var cost := int(SKILL_COSTS.get(skill_id, 0))
	if current_resource < cost:
		return false
	current_resource -= cost
	_skill_cooldowns[skill_id] = float(SKILL_COOLDOWNS.get(skill_id, 0.0))
	emit_stats_changed()
	return true

func _tick_skill_cooldowns(delta: float) -> void:
	var expired: Array[String] = []
	for skill_id: String in _skill_cooldowns.keys():
		var remaining := maxf(0.0, float(_skill_cooldowns[skill_id]) - delta)
		if remaining <= 0.0:
			expired.append(skill_id)
		else:
			_skill_cooldowns[skill_id] = remaining
	for skill_id: String in expired:
		_skill_cooldowns.erase(skill_id)
