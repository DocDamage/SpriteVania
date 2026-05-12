extends Control
class_name CharacterSelect

signal character_confirmed(starter_id: String, character_name: String)
signal cancel_requested

const CharacterRegistry := preload("res://scripts/characters/character_registry.gd")
const CC2DCreatorManager := preload("res://scripts/character_creator/cc2d_creator_manager.gd")
const CC2DPreviewLayer := preload("res://scripts/character_creator/cc2d_preview_layer.gd")
const CC2DRecipe := preload("res://scripts/character_creator/cc2d_recipe.gd")

var _starters: Array = []
var _creator_manager := CC2DCreatorManager.new()
var _current_recipe: CC2DRecipe
var _appearance_buttons: Dictionary = {}
var _rendered_part_paths: Array[String] = []
var _part_filter_query := ""
var _part_filter_tags: Array[String] = []
var _part_filter_favorites_only := false


func _ready() -> void:
	%ClassOption.item_selected.connect(_on_starter_selected)
	%NameEdit.text_changed.connect(_on_name_changed)
	%ConfirmButton.pressed.connect(confirm_selection)
	%BackButton.pressed.connect(_on_back_pressed)
	if has_node("%RandomizeButton"):
		%RandomizeButton.pressed.connect(_on_randomize_pressed)
	if has_node("%PartSearchEdit"):
		%PartSearchEdit.text_changed.connect(_on_part_search_changed)
	if has_node("%PartTagFilterEdit"):
		%PartTagFilterEdit.text_changed.connect(_on_part_tag_filter_changed)
	if has_node("%FavoriteOnlyCheck"):
		%FavoriteOnlyCheck.toggled.connect(_on_favorite_only_toggled)

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
	_ensure_creator_ready()
	var selected := {}
	for slot_id: String in _appearance_buttons.keys():
		var option_button := _appearance_buttons[slot_id] as OptionButton
		if option_button == null or option_button.item_count == 0:
			continue
		var selected_index: int = max(0, option_button.selected)
		selected[slot_id] = option_button.get_item_metadata(selected_index)
	return selected

func get_current_recipe() -> CC2DRecipe:
	_ensure_creator_ready()
	return _current_recipe

func validate_current_recipe() -> Dictionary:
	_ensure_creator_ready()
	return _creator_manager.validate_recipe(_current_recipe, "first_slice_player")

func get_preview_state() -> Dictionary:
	_ensure_creator_ready()
	return {
		"recipe_id": _current_recipe.recipe_id,
		"part_count": _current_recipe.parts.size(),
		"rendered_part_paths": _rendered_part_paths.duplicate(),
		"valid": bool(validate_current_recipe().get("valid", false)),
	}

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
	_current_recipe.parts[slot_id] = (option_button.get_item_metadata(option_index) as Dictionary).duplicate(true)
	refresh_preview()
	return true

func randomize_current_recipe(locked_slots := [], required_tags := [], seed := 0) -> Dictionary:
	_ensure_creator_ready()
	var report := _creator_manager.randomize_recipe(_current_recipe, locked_slots, required_tags, seed)
	_sync_appearance_buttons_to_recipe()
	refresh_preview()
	return report

func filter_part_browser(query := "", required_tags := [], favorites_only := false) -> int:
	_ensure_creator_ready()
	_part_filter_query = str(query)
	_part_filter_tags = _string_array(required_tags)
	_part_filter_favorites_only = bool(favorites_only)
	return _populate_appearance_options()

func set_part_favorite(slot_id: String, option_index: int, favorite: bool) -> bool:
	_ensure_creator_ready()
	var options := _creator_manager.filtered_options_for_slot(slot_id, _part_filter_query, _part_filter_tags, _current_recipe.favorite_part_paths, _part_filter_favorites_only)
	if option_index < 0 or option_index >= options.size():
		return false
	var changed := _creator_manager.set_part_favorite(_current_recipe, options[option_index] as Dictionary, favorite)
	if changed and _part_filter_favorites_only:
		_populate_appearance_options()
	return changed

func is_part_favorite(slot_id: String, option_index: int) -> bool:
	_ensure_creator_ready()
	var options := _creator_manager.filtered_options_for_slot(slot_id, _part_filter_query, _part_filter_tags, _current_recipe.favorite_part_paths, _part_filter_favorites_only)
	if option_index < 0 or option_index >= options.size():
		return false
	return _creator_manager.is_part_favorite(_current_recipe, options[option_index] as Dictionary)

func refresh_preview() -> void:
	_ensure_creator_ready()
	_rendered_part_paths.clear()
	var preview := get_node_or_null("%LayeredPreview") as Control
	if preview == null:
		return
	for child: Node in preview.get_children():
		child.queue_free()
	for slot_id: String in _preview_slot_order():
		var part := _current_recipe.parts.get(slot_id, {}) as Dictionary
		var path := str(part.get("path", ""))
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture == null:
			continue
		var layer := CC2DPreviewLayer.new()
		layer.name = slot_id.replace("/", "_")
		layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		layer.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		layer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.texture = texture
		layer.modulate = _palette_modulate_for_slot(slot_id)
		preview.add_child(layer)
		_rendered_part_paths.append(path)
	_sync_preview_label()


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

func _populate_appearance_options() -> int:
	if not has_node("%AppearanceOptions"):
		return 0
	_ensure_creator_ready()
	var container := %AppearanceOptions as VBoxContainer
	for child: Node in container.get_children():
		child.queue_free()
	_appearance_buttons.clear()
	var visible_option_count := 0
	for slot_id: String in _creator_manager.slot_ids():
		var options: Array = _creator_manager.filtered_options_for_slot(slot_id, _part_filter_query, _part_filter_tags, _current_recipe.favorite_part_paths, _part_filter_favorites_only)
		if options.is_empty():
			continue
		visible_option_count += options.size()
		var row := HBoxContainer.new()
		row.name = slot_id.replace("/", "_")
		row.custom_minimum_size = Vector2(0, 34)
		container.add_child(row)

		var label := Label.new()
		label.custom_minimum_size = Vector2(140, 0)
		label.text = _creator_manager.slot_label(slot_id)
		row.add_child(label)

		var option_button := OptionButton.new()
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for index: int in options.size():
			var option: Dictionary = options[index]
			option_button.add_item(str(option.get("label", "")), index)
			option_button.set_item_metadata(index, option)
		option_button.item_selected.connect(func(index: int) -> void:
			_select_appearance_option_metadata(slot_id, option_button.get_item_metadata(index) as Dictionary)
		)
		row.add_child(option_button)
		_appearance_buttons[slot_id] = option_button
		_select_current_option_if_visible(slot_id, option_button)
	refresh_preview()
	return visible_option_count


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
	_sync_preview_label()

func _sync_preview_label() -> void:
	var preview_label := get_node_or_null("%PreviewLabel") as Label
	if preview_label == null or _current_recipe == null:
		return
	var report := validate_current_recipe()
	preview_label.text = "%s | Parts %d | %s" % [
		_current_recipe.display_name,
		_current_recipe.parts.size(),
		"Valid" if bool(report.get("valid", false)) else "Needs repair",
	]

func _sync_appearance_buttons_to_recipe() -> void:
	for slot_id: String in _appearance_buttons.keys():
		var option_button := _appearance_buttons.get(slot_id, null) as OptionButton
		if option_button == null:
			continue
		_select_current_option_if_visible(slot_id, option_button)

func _select_appearance_option_metadata(slot_id: String, option: Dictionary) -> bool:
	if option.is_empty():
		return false
	_current_recipe.parts[slot_id] = option.duplicate(true)
	refresh_preview()
	return true

func _select_current_option_if_visible(slot_id: String, option_button: OptionButton) -> void:
	var selected := _current_recipe.parts.get(slot_id, {}) as Dictionary
	var selected_path := str(selected.get("path", ""))
	for index: int in option_button.item_count:
		var option := option_button.get_item_metadata(index) as Dictionary
		if str(option.get("path", "")) == selected_path:
			option_button.select(index)
			break


func _on_starter_selected(_index: int) -> void:
	_refresh_selected_starter()


func _on_name_changed(_new_text: String) -> void:
	_sync_confirm_state()


func _on_back_pressed() -> void:
	cancel_requested.emit()

func _on_randomize_pressed() -> void:
	var tag_edit := get_node_or_null("%RandomTagEdit") as LineEdit
	var lock_edit := get_node_or_null("%RandomLockEdit") as LineEdit
	var tags: Array[String] = []
	if tag_edit != null:
		for tag: String in tag_edit.text.split(",", false):
			var normalized := tag.strip_edges().to_lower()
			if not normalized.is_empty():
				tags.append(normalized)
	var locked_slots: Array[String] = []
	if lock_edit != null:
		for slot_id: String in lock_edit.text.split(",", false):
			var normalized_slot := slot_id.strip_edges()
			if not normalized_slot.is_empty():
				locked_slots.append(normalized_slot)
	randomize_current_recipe(locked_slots, tags, 0)

func _on_part_search_changed(new_text: String) -> void:
	var tag_edit := get_node_or_null("%PartTagFilterEdit") as LineEdit
	var favorite_check := get_node_or_null("%FavoriteOnlyCheck") as CheckBox
	filter_part_browser(new_text, _tags_from_filter_edit(tag_edit), favorite_check.button_pressed if favorite_check != null else false)

func _on_part_tag_filter_changed(_new_text: String) -> void:
	var search_edit := get_node_or_null("%PartSearchEdit") as LineEdit
	var tag_edit := get_node_or_null("%PartTagFilterEdit") as LineEdit
	var favorite_check := get_node_or_null("%FavoriteOnlyCheck") as CheckBox
	filter_part_browser(search_edit.text if search_edit != null else "", _tags_from_filter_edit(tag_edit), favorite_check.button_pressed if favorite_check != null else false)

func _on_favorite_only_toggled(toggled: bool) -> void:
	var search_edit := get_node_or_null("%PartSearchEdit") as LineEdit
	var tag_edit := get_node_or_null("%PartTagFilterEdit") as LineEdit
	filter_part_browser(search_edit.text if search_edit != null else "", _tags_from_filter_edit(tag_edit), toggled)

func _ensure_creator_ready() -> void:
	if not _creator_manager.is_loaded():
		_creator_manager.load_content()
	if _current_recipe == null:
		_current_recipe = _creator_manager.default_recipe("player_custom")

func _preview_slot_order() -> Array[String]:
	var preferred := [
		"Base/Body Skin",
		"Base/Ear",
		"Base/Eyebrow",
		"Base/Eyes",
		"Base/Mouth",
		"Base/Facial Hair",
		"Base/Hair",
		"Fantasy/Underwear",
		"Fantasy/Pants",
		"Fantasy/Shirt",
		"Fantasy/Armor",
		"Fantasy/Helmet",
		"Fantasy/Weapon",
	]
	var ordered: Array[String] = []
	for slot_id: String in preferred:
		if _current_recipe.parts.has(slot_id):
			ordered.append(slot_id)
	for slot_id: String in _current_recipe.parts.keys():
		if not ordered.has(slot_id):
			ordered.append(slot_id)
	return ordered

func _palette_modulate_for_slot(slot_id: String) -> Color:
	var palette_id := ""
	if slot_id.contains("Hair"):
		palette_id = "hair"
	elif slot_id.contains("Body Skin"):
		palette_id = "skin"
	elif slot_id.contains("Armor") or slot_id.contains("Helmet"):
		palette_id = "metal"
	elif slot_id.contains("Shirt") or slot_id.contains("Pants") or slot_id.contains("Underwear"):
		palette_id = "cloth_primary"
	if palette_id.is_empty() or _current_recipe == null:
		return Color.WHITE
	var color_text := str(_current_recipe.palettes.get(palette_id, ""))
	return Color.html(color_text) if color_text.is_valid_html_color() else Color.WHITE

func _tags_from_filter_edit(tag_edit: LineEdit) -> Array[String]:
	var tags: Array[String] = []
	if tag_edit == null:
		return tags
	for tag: String in tag_edit.text.split(",", false):
		var normalized := tag.strip_edges().to_lower()
		if not normalized.is_empty():
			tags.append(normalized)
	return tags

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result
