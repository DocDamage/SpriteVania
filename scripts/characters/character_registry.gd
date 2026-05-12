extends RefCounted
class_name CharacterRegistry

const DEFINITION_PATHS := [
	"res://resources/characters/ronin.tres",
	"res://resources/characters/arc_gunner.tres",
	"res://resources/characters/iron_knight.tres",
	"res://resources/characters/black_witch.tres",
	"res://resources/characters/shadow.tres",
]

static func get_all_definitions() -> Array:
	var definitions: Array = []
	for path: String in DEFINITION_PATHS:
		var definition := load(path)
		if definition != null:
			definitions.append(definition)
	return definitions

static func get_definition(character_id: String) -> Resource:
	for definition: Resource in get_all_definitions():
		if definition.get("character_id") == character_id:
			return definition
	return null

static func get_starter_definitions() -> Array:
	var definitions: Array = []
	for definition: Resource in get_all_definitions():
		if bool(definition.get("starter_selectable")):
			definitions.append(definition)
	return definitions
