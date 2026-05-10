extends CharacterBody2D
class_name Enemy

signal died(enemy_id: String, xp_reward: int)
signal dropped(enemy_id: String, drop_id: String, drop_amount: int)

@export var enemy_id: String = ""
@export var max_health: int = 30
@export var damage: int = 10
@export var contact_damage_cooldown := 0.8
@export var xp_reward: int = 25
@export var drop_id: String = ""
@export var drop_amount: int = 0

var current_health: int
var _is_dead := false
var _contact_hitbox: Area2D
var _contact_bodies: Dictionary = {}
var _contact_cooldowns: Dictionary = {}

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	_ensure_contact_hitbox()

func _process(delta: float) -> void:
	_tick_contact_damage(delta)

func take_damage(amount: int) -> void:
	if amount <= 0 or _is_dead:
		return

	current_health -= amount
	if current_health <= 0:
		_is_dead = true
		_emit_drop_if_configured()
		died.emit(enemy_id, xp_reward)
		queue_free()

func _emit_drop_if_configured() -> void:
	if drop_id.is_empty() or drop_amount <= 0:
		return
	dropped.emit(enemy_id, drop_id, drop_amount)

func _ensure_contact_hitbox() -> void:
	_contact_hitbox = get_node_or_null("ContactHitbox") as Area2D
	if _contact_hitbox != null:
		return

	var hitbox := Area2D.new()
	hitbox.name = "ContactHitbox"
	hitbox.collision_layer = 0
	hitbox.collision_mask = self.collision_mask
	hitbox.monitoring = true
	hitbox.monitorable = false
	hitbox.body_entered.connect(_on_contact_body_entered)
	hitbox.body_exited.connect(_on_contact_body_exited)

	for child: Node in get_children():
		if not child is CollisionShape2D:
			continue
		var source_shape := child as CollisionShape2D
		if source_shape.shape == null:
			continue
		var contact_shape := CollisionShape2D.new()
		contact_shape.position = source_shape.position
		contact_shape.rotation = source_shape.rotation
		contact_shape.scale = source_shape.scale
		contact_shape.disabled = source_shape.disabled
		contact_shape.shape = source_shape.shape.duplicate()
		hitbox.add_child(contact_shape)

	add_child(hitbox)
	_contact_hitbox = hitbox

func _on_contact_body_entered(body: Node) -> void:
	if not _is_damageable_player(body):
		return
	_contact_bodies[body.get_instance_id()] = body
	_apply_contact_damage(body)

func _on_contact_body_exited(body: Node) -> void:
	var body_id := body.get_instance_id()
	_contact_bodies.erase(body_id)
	_contact_cooldowns.erase(body_id)

func _tick_contact_damage(delta: float) -> void:
	if _is_dead:
		return
	_sync_overlapping_contact_bodies()

	for body_id: int in _contact_cooldowns.keys():
		_contact_cooldowns[body_id] = max(0.0, float(_contact_cooldowns[body_id]) - delta)

	for body_id: int in _contact_bodies.keys():
		var body := _contact_bodies[body_id] as Node
		if not is_instance_valid(body) or not _is_damageable_player(body):
			_contact_bodies.erase(body_id)
			_contact_cooldowns.erase(body_id)
			continue
		_apply_contact_damage(body)

func _is_damageable_player(body: Node) -> bool:
	return body != null and body.is_in_group("player") and body.has_method("take_damage")

func _apply_contact_damage(body: Node) -> void:
	var body_id := body.get_instance_id()
	if float(_contact_cooldowns.get(body_id, 0.0)) > 0.0:
		return
	body.call("take_damage", damage)
	if body.has_method("apply_knockback"):
		body.call("apply_knockback", global_position)
	_contact_cooldowns[body_id] = contact_damage_cooldown

func _sync_overlapping_contact_bodies() -> void:
	if _contact_hitbox == null:
		return
	for body: Node2D in _contact_hitbox.get_overlapping_bodies():
		_on_contact_body_entered(body)
