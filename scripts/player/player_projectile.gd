extends Area2D
class_name PlayerProjectile

@export var damage := 1
@export var damage_source := "player"
@export var speed := 420.0
@export var lifetime := 1.1
@export var direction := Vector2.RIGHT
@export var piercing := false

var _elapsed := 0.0
var _hit_targets: Array[Node] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _hit_targets.has(body):
		return
	if body.has_method("take_damage"):
		_hit_targets.append(body)
		body.call("take_damage", damage, damage_source)
		if not piercing:
			queue_free()
