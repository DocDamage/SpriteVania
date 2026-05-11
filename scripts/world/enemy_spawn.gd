extends Marker2D
class_name EnemySpawn

@export var enemy_scene: PackedScene
@export var enemy_id: String = ""

var spawned_enemy: Node2D

func spawn_enemy() -> Node2D:
	if enemy_scene == null:
		return null
	if spawned_enemy != null and is_instance_valid(spawned_enemy):
		return spawned_enemy
	spawned_enemy = enemy_scene.instantiate() as Node2D
	if spawned_enemy == null:
		return null
	if not enemy_id.is_empty():
		spawned_enemy.set("enemy_id", enemy_id)
	var target_parent := get_parent()
	if target_parent == null:
		target_parent = self
	target_parent.add_child(spawned_enemy)
	spawned_enemy.global_position = global_position
	return spawned_enemy
