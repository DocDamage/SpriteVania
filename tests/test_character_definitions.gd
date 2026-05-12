extends SceneTree

const CHARACTER_REGISTRY_PATH := "res://scripts/characters/character_registry.gd"

func _init() -> void:
	var registry_script := load(CHARACTER_REGISTRY_PATH) as GDScript
	if registry_script == null:
		_fail("Missing character registry script.")
		return

	var all_definitions: Array = registry_script.get_all_definitions()
	if all_definitions.size() != 5:
		_fail("Character registry should load exactly five Black Keep character definitions.")
		return

	for expected_id: String in ["ronin", "arc_gunner", "iron_knight", "black_witch", "shadow"]:
		var definition: Resource = registry_script.get_definition(expected_id)
		if definition == null:
			_fail("Missing character definition: " + expected_id)
			return
		if definition.character_id != expected_id:
			_fail("Character definition ID mismatch for " + expected_id)
			return
		if definition.display_name.is_empty() or definition.role_summary.is_empty():
			_fail("Character definition identity is incomplete for " + expected_id)
			return
		if definition.default_name.is_empty():
			_fail("Character definition should include a default name for " + expected_id)
			return
		if definition.combat_role.is_empty():
			_fail("Character definition should include combat role for " + expected_id)
			return

	var starter_definitions: Array = registry_script.get_starter_definitions()
	var starter_ids: Array[String] = []
	for definition in starter_definitions:
		starter_ids.append(definition.character_id)
	if starter_ids != ["ronin", "arc_gunner", "iron_knight"]:
		_fail("Starter definitions should be Ronin, Arc-Gunner, and Iron Knight only.")
		return

	if registry_script.get_definition("black_witch").starter_selectable:
		_fail("Black Witch should not be starter-selectable.")
		return
	if registry_script.get_definition("shadow").starter_selectable:
		_fail("Shadow should not be starter-selectable.")
		return

	print("PASS: character definitions")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
