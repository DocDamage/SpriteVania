extends SceneTree

const CC2DRecipe := preload("res://scripts/character_creator/cc2d_recipe.gd")
const CC2DCreatorManager := preload("res://scripts/character_creator/cc2d_creator_manager.gd")
const DEFAULT_CONTACT_SHEET_SIGNATURE := "2048x2560:1604385:584919648"

var _failed := false

func _init() -> void:
	_assert_canonical_contact_sheet_signature_is_stable()
	if _failed:
		return
	print("PASS: character creator 2d visual regression")
	quit(0)

func _assert_canonical_contact_sheet_signature_is_stable() -> void:
	var manager := CC2DCreatorManager.new()
	if not manager.load_content():
		_fail("Creator manager should load CharacterCreator2D content.")
		return
	if not manager.has_method("bake_contact_sheet"):
		_fail("Creator manager should expose bake_contact_sheet().")
		return
	if not manager.has_method("contact_sheet_signature"):
		_fail("Creator manager should expose contact_sheet_signature().")
		return

	var first_recipe: CC2DRecipe = manager.default_recipe("visual_regression_default")
	var first_signature := _bake_contact_sheet_signature(
		manager,
		first_recipe,
		"user://test_cc2d_visual_regression_default_a.png"
	)
	if first_signature.is_empty():
		return
	if first_signature != DEFAULT_CONTACT_SHEET_SIGNATURE:
		_fail("Default contact sheet signature changed. Expected %s but got %s." % [DEFAULT_CONTACT_SHEET_SIGNATURE, first_signature])
		return

	var second_recipe: CC2DRecipe = manager.default_recipe("visual_regression_default")
	var second_signature := _bake_contact_sheet_signature(
		manager,
		second_recipe,
		"user://test_cc2d_visual_regression_default_b.png"
	)
	if second_signature.is_empty():
		return
	if first_signature != second_signature:
		_fail("Default contact sheet bake signature should be stable across repeated bakes.")
		return

	var changed_recipe: CC2DRecipe = manager.default_recipe("visual_regression_changed")
	changed_recipe.parts.erase("Base/Hair")
	changed_recipe.parts.erase("Fantasy/Armor")
	changed_recipe.parts.erase("Fantasy/Weapon")
	var changed_signature := _bake_contact_sheet_signature(
		manager,
		changed_recipe,
		"user://test_cc2d_visual_regression_changed.png"
	)
	if changed_signature.is_empty():
		return
	if changed_signature == first_signature:
		_fail("Changed recipe contact sheet signature should differ from the default signature.")
		return

func _bake_contact_sheet_signature(manager: CC2DCreatorManager, recipe: CC2DRecipe, path: String) -> String:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var report := manager.call("bake_contact_sheet", recipe, path, "movement", 2) as Dictionary
	if not bool(report.get("ok", false)):
		_fail("Contact sheet bake should succeed: " + str(report.get("errors", [])))
		return ""
	if not FileAccess.file_exists(path):
		_fail("Contact sheet bake should write a PNG: " + path)
		return ""
	var signature := manager.contact_sheet_signature(path) as Dictionary
	if not bool(signature.get("ok", false)):
		_fail("Contact sheet signature should be available: " + str(signature.get("errors", [])))
		return ""
	return str(signature.get("signature", ""))

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
