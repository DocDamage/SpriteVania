extends Control
class_name CharacterSelect

signal character_confirmed(starter_id: String, character_name: String)
signal cancel_requested

const CharacterRegistry := preload("res://scripts/characters/character_registry.gd")

var _starters: Array = []


func _ready() -> void:
	%ClassOption.item_selected.connect(_on_starter_selected)
	%NameEdit.text_changed.connect(_on_name_changed)
	%ConfirmButton.pressed.connect(confirm_selection)
	%BackButton.pressed.connect(_on_back_pressed)

	_load_starters()
	_populate_starter_options()
	_refresh_selected_starter()
	_sync_confirm_state()


func get_starter_ids() -> Array[String]:
	var ids: Array[String] = []
	for starter: Resource in _starters:
		ids.append(str(starter.get("character_id")))
	return ids


func select_starter_by_id(starter_id: String) -> bool:
	for index: int in _starters.size():
		if str(_starters[index].get("character_id")) == starter_id:
			%ClassOption.select(index)
			_refresh_selected_starter()
			return true
	return false


func set_character_name(character_name: String) -> void:
	%NameEdit.text = character_name
	_sync_confirm_state()


func is_name_valid() -> bool:
	return _normalized_character_name().length() > 0


func confirm_selection() -> void:
	var starter := _get_selected_starter()
	if starter == null or not is_name_valid():
		return
	character_confirmed.emit(str(starter.get("character_id")), _normalized_character_name())


func _load_starters() -> void:
	_starters = CharacterRegistry.get_starter_definitions()


func _populate_starter_options() -> void:
	%ClassOption.clear()
	for index: int in _starters.size():
		var starter: Resource = _starters[index]
		%ClassOption.add_item(str(starter.get("display_name")), index)


func _refresh_selected_starter() -> void:
	var starter := _get_selected_starter()
	if starter == null:
		%DescriptionLabel.text = ""
		%SpriteOption.clear()
		return

	%DescriptionLabel.text = str(starter.get("role_summary"))
	%SpriteOption.clear()
	%SpriteOption.add_item(str(starter.get("combat_role")).capitalize(), 0)
	%NameEdit.placeholder_text = str(starter.get("default_name"))
	if _normalized_character_name().is_empty():
		%NameEdit.text = str(starter.get("default_name"))
	_sync_confirm_state()


func _get_selected_starter() -> Resource:
	var index: int = %ClassOption.selected
	if index < 0 or index >= _starters.size():
		return null
	return _starters[index]


func _normalized_character_name() -> String:
	return str(%NameEdit.text).strip_edges()


func _sync_confirm_state() -> void:
	%ConfirmButton.disabled = _starters.is_empty() or not is_name_valid()


func _on_starter_selected(_index: int) -> void:
	_refresh_selected_starter()


func _on_name_changed(_new_text: String) -> void:
	_sync_confirm_state()


func _on_back_pressed() -> void:
	cancel_requested.emit()
