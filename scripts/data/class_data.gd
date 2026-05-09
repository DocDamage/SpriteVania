extends Resource
class_name ClassData

@export var class_id: String
@export var display_name: String
@export_multiline var description: String
@export var max_health: int = 100
@export var max_resource: int = 50
@export var base_attack: int = 10
@export var base_defense: int = 0
@export var move_speed: float = 160.0
@export var jump_velocity: float = -360.0
@export var controller_script: Script
@export var sprite_options: Array[String] = []
@export var traversal_unlocks: Array[String] = []
@export var attack_skills: Array[String] = []
@export var xp_curve: Array[int] = [0, 100, 250, 450, 700]
