extends RefCounted
class_name CC2DRecipe

const SCHEMA_VERSION := 5

var schema_version: int = SCHEMA_VERSION
var recipe_id: String = ""
var display_name: String = ""
var content_pack_id: String = "base_fantasy"
var export_profile_id: String = "base_fantasy"
var parts: Dictionary = {}
var palettes: Dictionary = {}
var morphs: Dictionary = {}
var tags: Array[String] = []
var favorite_part_paths: Array[String] = []
var generated_spriteframes_path: String = ""
var outfit_sets: Dictionary = {}
var active_outfit_id: String = ""
var custom_export_sets: Dictionary = {}
var equipment_sockets: Dictionary = {}
var pivot_overrides: Dictionary = {}

func to_dictionary() -> Dictionary:
	return {
		"schema_version": schema_version,
		"recipe_id": recipe_id,
		"display_name": display_name,
		"content_pack_id": content_pack_id,
		"export_profile_id": export_profile_id,
		"parts": parts,
		"palettes": palettes,
		"morphs": morphs,
		"tags": tags,
		"favorite_part_paths": favorite_part_paths,
		"generated_spriteframes_path": generated_spriteframes_path,
		"outfit_sets": outfit_sets,
		"active_outfit_id": active_outfit_id,
		"custom_export_sets": custom_export_sets,
		"equipment_sockets": equipment_sockets,
		"pivot_overrides": pivot_overrides,
	}

static func from_dictionary(data: Dictionary):
	var recipe = (load("res://scripts/character_creator/cc2d_recipe.gd") as GDScript).new()
	recipe.schema_version = int(data.get("schema_version", SCHEMA_VERSION))
	recipe.recipe_id = str(data.get("recipe_id", ""))
	recipe.display_name = str(data.get("display_name", ""))
	recipe.content_pack_id = str(data.get("content_pack_id", "base_fantasy"))
	recipe.export_profile_id = str(data.get("export_profile_id", "base_fantasy"))
	var loaded_parts: Variant = data.get("parts", {})
	recipe.parts = (loaded_parts as Dictionary).duplicate(true) if loaded_parts is Dictionary else {}
	var loaded_palettes: Variant = data.get("palettes", {})
	recipe.palettes = (loaded_palettes as Dictionary).duplicate(true) if loaded_palettes is Dictionary else {}
	var loaded_morphs: Variant = data.get("morphs", {})
	recipe.morphs = (loaded_morphs as Dictionary).duplicate(true) if loaded_morphs is Dictionary else {}
	recipe.tags = _string_array(data.get("tags", []))
	recipe.favorite_part_paths = _string_array(data.get("favorite_part_paths", []))
	recipe.generated_spriteframes_path = str(data.get("generated_spriteframes_path", ""))
	var loaded_outfit_sets: Variant = data.get("outfit_sets", {})
	recipe.outfit_sets = (loaded_outfit_sets as Dictionary).duplicate(true) if loaded_outfit_sets is Dictionary else {}
	recipe.active_outfit_id = str(data.get("active_outfit_id", ""))
	var loaded_custom_export_sets: Variant = data.get("custom_export_sets", {})
	recipe.custom_export_sets = (loaded_custom_export_sets as Dictionary).duplicate(true) if loaded_custom_export_sets is Dictionary else {}
	var loaded_equipment_sockets: Variant = data.get("equipment_sockets", {})
	recipe.equipment_sockets = (loaded_equipment_sockets as Dictionary).duplicate(true) if loaded_equipment_sockets is Dictionary else {}
	var loaded_pivot_overrides: Variant = data.get("pivot_overrides", {})
	recipe.pivot_overrides = (loaded_pivot_overrides as Dictionary).duplicate(true) if loaded_pivot_overrides is Dictionary else {}
	return recipe

static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result
