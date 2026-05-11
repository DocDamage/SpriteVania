extends Control
class_name CharacterSelect

signal character_confirmed(starter_id: String, character_name: String)
signal cancel_requested

const CharacterRegistry := preload("res://scripts/characters/character_registry.gd")
const CC2DAppearance := preload("res://scripts/character_creator/cc2d_appearance.gd")

var _starters: Array = []
var _appearance_catalog := CC2DAppearance.new()
var _appearance_buttons: Dictionary = {}


func _ready() -> void:
	%ClassOption.item_selected.connect(_on_starter_selected)
	%NameEdit.text_changed.connect(_on_name_changed)
	%ConfirmButton.pressed.connect(confirm_selection)
	%BackButton.pressed.connect(_on_back_pressed)

	_load_starters()
	_populate_starter_options()
	_populate_appearance_options()
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

func get_selected_appearance() -> Dictionary:
	var selected := {}
	for slot_id: String in _appearance_buttons.keys():
		var option_button := _appearance_buttons[slot_id] as OptionButton
		if option_button == null or option_button.item_count == 0:
			continue
		var selected_index: int = max(0, option_button.selected)
		selected[slot_id] = option_button.get_item_metadata(selected_index)
	return selected

func get_appearance_slot_ids() -> Array[String]:
	var ids: Array[String] = []
	for slot_id: String in _appearance_buttons.keys():
		ids.append(slot_id)
	ids.sort()
	return ids

func select_appearance_option(slot_id: String, option_index: int) -> bool:
	var option_button := _appearance_buttons.get(slot_id, null) as OptionButton
	if option_button == null or option_index < 0 or option_index >= option_button.item_count:
		return false
	option_button.select(option_index)
	return true


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

func _populate_appearance_options() -> void:
	if not has_node("%AppearanceOptions"):
		return
	var container := %AppearanceOptions as VBoxContainer
	for child: Node in container.get_children():
		child.queue_free()
	_appearance_buttons.clear()
	if not _appearance_catalog.load_catalog():
		return
	for slot_id: String in _appearance_catalog.slot_ids():
		var options: Array = _appearance_catalog.options_for_slot(slot_id)
		if options.is_empty():
			continue
		var row := HBoxContainer.new()
		row.name = slot_id.replace("/", "_")
		row.custom_minimum_size = Vector2(0, 34)
		container.add_child(row)

		var label := Label.new()
		label.custom_minimum_size = Vector2(140, 0)
		label.text = _appearance_catalog.slot_label(slot_id)
		row.add_child(label)

		var option_button := OptionButton.new()
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for index: int in options.size():
			var option: Dictionary = options[index]
			option_button.add_item(str(option.get("label", "")), index)
			option_button.set_item_metadata(index, option)
		row.add_child(option_button)
		_appearance_buttons[slot_id] = option_button


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
