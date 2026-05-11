extends Resource
class_name CharacterDefinition

@export var character_id: String = ""
@export var display_name: String = ""
@export_multiline var role_summary: String = ""
@export var default_name: String = ""
@export var combat_role: String = ""
@export var starter_selectable := false
@export var recruitable := true
@export var class_id: String = ""
@export var preview_asset_path: String = ""
@export var baseline_skills: Array[String] = []
