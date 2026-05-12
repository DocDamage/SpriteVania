extends RefCounted
class_name CC2DAppearance

const CC2DManifest := preload("res://scripts/character_creator/cc2d_manifest.gd")

var _manifest := CC2DManifest.new()
var _slots: Dictionary = {}

func load_catalog() -> bool:
	if not _manifest.load_manifest():
		_slots = {}
		return false
	_slots.clear()
	for entry: Dictionary in _manifest.entries_by_extension(".png"):
		if str(entry.get("import_role", "")) != "runtime":
			continue
		var relative_path := str(entry.get("relative_path", ""))
		var parts := relative_path.split("/", false)
		if parts.size() < 4 or parts[0] != "Sprites":
			continue
		var slot_id := "%s/%s" % [parts[1], parts[2]]
		var options: Array = _slots.get(slot_id, [])
		options.append({
			"label": _label_from_filename(parts[parts.size() - 1]),
			"path": _manifest.project_path(str(entry.get("godot_path", ""))),
			"relative_path": relative_path,
			"slot_id": slot_id,
			"category": parts[1],
			"tags": _tags_for_option(slot_id, relative_path),
		})
		_slots[slot_id] = options
	for slot_id: String in _slots.keys():
		var options: Array = _slots[slot_id]
		options.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return str(a.get("relative_path", "")) < str(b.get("relative_path", ""))
		)
	return true

func slot_ids() -> Array[String]:
	var ids: Array[String] = []
	for slot_id: String in _slots.keys():
		ids.append(slot_id)
	ids.sort()
	return ids

func slot_label(slot_id: String) -> String:
	return slot_id.replace("/", " ").capitalize()

func options_for_slot(slot_id: String) -> Array:
	return _slots.get(slot_id, []) as Array

func default_appearance() -> Dictionary:
	var appearance := {}
	for slot_id: String in slot_ids():
		var options := options_for_slot(slot_id)
		if not options.is_empty():
			appearance[slot_id] = options[0]
	return appearance

func _label_from_filename(file_name: String) -> String:
	var label := file_name.get_basename().replace("_", " ").strip_edges()
	return label if not label.is_empty() else file_name

func _tags_for_option(slot_id: String, relative_path: String) -> Array[String]:
	var tags: Array[String] = ["starter_safe"]
	var source := "%s/%s" % [slot_id, relative_path.get_file().get_basename()]
	for token: String in source.replace("\\", "/").replace("_", " ").replace("-", " ").replace(".", " ").split("/", false):
		for piece: String in token.split(" ", false):
			var normalized := piece.strip_edges().to_lower()
			if normalized.length() >= 2 and not tags.has(normalized):
				tags.append(normalized)
	return tags
