extends Control
class_name CharacterSelect

signal character_confirmed(starter_id: String, character_name: String)
signal cancel_requested

const CharacterRegistry := preload("res://scripts/characters/character_registry.gd")
const CC2DCreatorManager := preload("res://scripts/character_creator/cc2d_creator_manager.gd")
const CC2DPreviewLayer := preload("res://scripts/character_creator/cc2d_preview_layer.gd")
const CC2DRecipe := preload("res://scripts/character_creator/cc2d_recipe.gd")
const ON_SCREEN_KEYS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'-_"

var _starters: Array = []
var _creator_manager := CC2DCreatorManager.new()
var _current_recipe: CC2DRecipe
var _appearance_buttons: Dictionary = {}
var _rendered_part_paths: Array[String] = []
var _part_filter_query := ""
var _part_filter_tags: Array[String] = []
var _part_filter_favorites_only := false
var _name_validation_error := ""
var _creator_error := ""
var _confirmation_pending := false
var _applied_settings: Dictionary = {}


func _ready() -> void:
	%ClassOption.item_selected.connect(_on_starter_selected)
	%NameEdit.text_changed.connect(_on_name_changed)
	%ConfirmButton.pressed.connect(confirm_selection)
	%BackButton.pressed.connect(_on_back_pressed)
	if has_node("%ResetNameButton"):
		%ResetNameButton.pressed.connect(reset_name_to_default)
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
	_populate_on_screen_keyboard()
	_populate_appearance_options()
	_build_palette_controls()
	_build_morph_controls()
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

func reset_name_to_default() -> void:
	var starter := _get_selected_starter()
	if starter == null:
		return
	%NameEdit.text = str(starter.get("default_name"))
	_creator_error = ""
	_sync_confirm_state()

func append_name_character(character: String) -> bool:
	if character.length() != 1 or not _is_allowed_name_character(character):
		return false
	var next_name := str(%NameEdit.text) + character
	%NameEdit.text = next_name
	_creator_error = ""
	_sync_confirm_state()
	return is_name_valid()

func backspace_character_name() -> bool:
	var current := str(%NameEdit.text)
	if current.is_empty():
		return false
	%NameEdit.text = current.substr(0, current.length() - 1)
	_creator_error = ""
	_sync_confirm_state()
	return true


func is_name_valid() -> bool:
	return get_name_validation_error().is_empty()

func normalize_character_name(character_name: String) -> String:
	var normalized := ""
	var previous_was_space := false
	for index: int in str(character_name).length():
		var character := str(character_name)[index]
		if character == " " or character == "\t" or character == "\n" or character == "\r":
			if not previous_was_space:
				normalized += " "
			previous_was_space = true
		else:
			normalized += character
			previous_was_space = false
	return normalized.strip_edges()

func get_name_validation_error() -> String:
	_name_validation_error = _validate_character_name(%NameEdit.text)
	return _name_validation_error

func set_creator_error(error_code: String) -> void:
	_creator_error = error_code
	_sync_preview_label()

func get_creator_error() -> String:
	return _creator_error

func is_confirmation_pending() -> bool:
	return _confirmation_pending

func apply_settings(settings: Dictionary) -> void:
	_applied_settings = settings.duplicate(true)
	var font_scale := clampf(float(settings.get("font_scale", 1.0)), 0.75, 2.0)
	_apply_font_scale(font_scale)
	var reduced_motion := bool(settings.get("reduced_motion", false))
	var preview := get_node_or_null("%LayeredPreview") as Control
	if preview != null:
		preview.visible = not reduced_motion
	_sync_preview_label()

func handle_creator_action(action_name: String) -> bool:
	if action_name == "ui_accept":
		confirm_selection()
		return true
	if action_name == "ui_cancel":
		_on_back_pressed()
		return true
	return false

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

func accessibility_preview() -> Dictionary:
	_ensure_creator_ready()
	return _creator_manager.accessibility_preview(_current_recipe, "first_slice_player")

func performance_budget_report() -> Dictionary:
	_ensure_creator_ready()
	return _creator_manager.performance_budget_report(_current_recipe, "first_slice_player")

func compatibility_report() -> Dictionary:
	_ensure_creator_ready()
	return _creator_manager.compatibility_report(_current_recipe, "first_slice_player")

func socket_report_for_recipe(animation_id := "idle") -> Dictionary:
	_ensure_creator_ready()
	return _creator_manager.socket_report_for_recipe(_current_recipe, animation_id)

func get_preview_state() -> Dictionary:
	_ensure_creator_ready()
	var accessibility_report := accessibility_preview()
	var performance_report := performance_budget_report()
	var compatibility := compatibility_report()
	var socket_report := socket_report_for_recipe("idle")
	return {
		"recipe_id": _current_recipe.recipe_id,
		"part_count": _current_recipe.parts.size(),
		"rendered_part_paths": _rendered_part_paths.duplicate(),
		"valid": bool(validate_current_recipe().get("valid", false)),
		"accessibility_ok": bool(accessibility_report.get("ok", false)),
		"accessibility_summary": (accessibility_report.get("summary", {}) as Dictionary).duplicate(true),
		"performance_ok": bool(performance_report.get("ok", false)),
		"performance_summary": (performance_report.get("summary", {}) as Dictionary).duplicate(true),
		"constraints": compatibility.duplicate(true),
		"socket_count": (socket_report.get("sockets", {}) as Dictionary).size(),
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

func set_palette_color(palette_id: String, color_html: String) -> bool:
	_ensure_creator_ready()
	var normalized := str(color_html).strip_edges()
	if not normalized.is_valid_html_color():
		return false
	_current_recipe.palettes[palette_id] = normalized
	_sync_palette_controls_to_recipe()
	refresh_preview()
	return true

func set_morph_value(morph_id: String, value: float) -> bool:
	_ensure_creator_ready()
	if not _current_recipe.morphs.has(morph_id):
		return false
	_current_recipe.morphs[morph_id] = clampf(value, -1.0, 1.0)
	_sync_morph_controls_to_recipe()
	refresh_preview()
	return true

func refresh_preview() -> void:
	_ensure_creator_ready()
	_rendered_part_paths.clear()
	var preview := get_node_or_null("%LayeredPreview") as Control
	if preview == null:
		return
	for child: Node in preview.get_children():
		preview.remove_child(child)
		child.free()
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
		layer.modulate = _creator_manager.palette_modulate_for_slot(_current_recipe, slot_id)
		var transform := _creator_manager.preview_transform_for_slot(_current_recipe, slot_id)
		layer.recipe_offset = transform.get("offset", Vector2.ZERO) as Vector2
		layer.recipe_scale = transform.get("scale", Vector2.ONE) as Vector2
		layer.recipe_rotation_degrees = float(transform.get("rotation_degrees", 0.0))
		layer.position = layer.recipe_offset
		layer.scale = layer.recipe_scale
		layer.rotation_degrees = layer.recipe_rotation_degrees
		preview.add_child(layer)
		_rendered_part_paths.append(path)
	_sync_preview_label()


func confirm_selection() -> void:
	var starter := _get_selected_starter()
	if starter == null or not is_name_valid():
		return
	if not _confirmation_pending:
		_confirmation_pending = true
		_creator_error = ""
		_sync_confirm_state()
		return
	_confirmation_pending = false
	character_confirmed.emit(str(starter.get("character_id")), _normalized_character_name())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		handle_creator_action("ui_accept")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		handle_creator_action("ui_cancel")
		get_viewport().set_input_as_handled()


func _load_starters() -> void:
	_starters = CharacterRegistry.get_starter_definitions()


func _populate_starter_options() -> void:
	%ClassOption.clear()
	for index: int in _starters.size():
		var starter: Resource = _starters[index]
		%ClassOption.add_item(str(starter.get("display_name")), index)

func _populate_on_screen_keyboard() -> void:
	var keyboard := get_node_or_null("%OnScreenKeyboard") as GridContainer
	if keyboard == null or keyboard.get_child_count() > 0:
		return
	for index: int in ON_SCREEN_KEYS.length():
		var key := ON_SCREEN_KEYS[index]
		var button := Button.new()
		button.name = "Key%s" % key.unicode_at(0)
		button.text = key
		button.custom_minimum_size = Vector2(34, 30)
		button.pressed.connect(func() -> void:
			append_name_character(key)
		)
		keyboard.add_child(button)
	var space_button := Button.new()
	space_button.name = "KeySpace"
	space_button.text = "Space"
	space_button.custom_minimum_size = Vector2(74, 30)
	space_button.pressed.connect(func() -> void:
		append_name_character(" ")
	)
	keyboard.add_child(space_button)
	var backspace_button := Button.new()
	backspace_button.name = "KeyBackspace"
	backspace_button.text = "Back"
	backspace_button.custom_minimum_size = Vector2(74, 30)
	backspace_button.pressed.connect(backspace_character_name)
	keyboard.add_child(backspace_button)

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

func _build_palette_controls() -> void:
	var container := get_node_or_null("%PaletteControls") as VBoxContainer
	if container == null:
		return
	_ensure_creator_ready()
	for child: Node in container.get_children():
		child.queue_free()
	for palette_id: String in _current_recipe.palettes.keys():
		var row := HBoxContainer.new()
		row.name = "%sPaletteRow" % _pascal_case(palette_id)
		row.custom_minimum_size = Vector2(0, 30)
		container.add_child(row)

		var label := Label.new()
		label.custom_minimum_size = Vector2(118, 0)
		label.text = palette_id.replace("_", " ").capitalize()
		row.add_child(label)

		var edit := LineEdit.new()
		edit.name = "%sPaletteEdit" % _pascal_case(palette_id)
		edit.unique_name_in_owner = true
		edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		edit.text = str(_current_recipe.palettes.get(palette_id, ""))
		edit.text_changed.connect(func(new_text: String) -> void:
			set_palette_color(palette_id, new_text)
		)
		row.add_child(edit)

func _build_morph_controls() -> void:
	var container := get_node_or_null("%MorphControls") as VBoxContainer
	if container == null:
		return
	_ensure_creator_ready()
	for child: Node in container.get_children():
		child.queue_free()
	for morph_id: String in _current_recipe.morphs.keys():
		var row := HBoxContainer.new()
		row.name = "%sMorphRow" % _pascal_case(morph_id)
		row.custom_minimum_size = Vector2(0, 30)
		container.add_child(row)

		var label := Label.new()
		label.custom_minimum_size = Vector2(118, 0)
		label.text = morph_id.replace("_", " ").capitalize()
		row.add_child(label)

		var slider := HSlider.new()
		slider.name = "%sMorphSlider" % _pascal_case(morph_id)
		slider.unique_name_in_owner = true
		slider.min_value = -1.0
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = float(_current_recipe.morphs.get(morph_id, 0.0))
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.value_changed.connect(func(value: float) -> void:
			set_morph_value(morph_id, value)
		)
		row.add_child(slider)


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
	return normalize_character_name(%NameEdit.text)


func _sync_confirm_state() -> void:
	%ConfirmButton.disabled = _starters.is_empty() or not is_name_valid()
	%ConfirmButton.text = "Start Game" if _confirmation_pending else "Confirm"
	_sync_preview_label()

func _validate_character_name(character_name: String) -> String:
	var normalized := normalize_character_name(character_name)
	if normalized.is_empty():
		return "empty"
	if normalized.length() > 16:
		return "too_long"
	for index: int in normalized.length():
		var code := normalized.unicode_at(index)
		if code < 32 or code == 127:
			return "invalid_characters"
		var character := normalized[index]
		if not _is_allowed_name_character(character):
			return "invalid_characters"
	return ""

func _is_allowed_name_character(character: String) -> bool:
	if character == " " or character == "'" or character == "-" or character == "_":
		return true
	var code := character.unicode_at(0)
	return (code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122)

func _sync_preview_label() -> void:
	var preview_label := get_node_or_null("%PreviewLabel") as Label
	if preview_label == null or _current_recipe == null:
		return
	if bool(_applied_settings.get("reduced_motion", false)):
		preview_label.text = "Preview disabled"
		return
	if not _creator_error.is_empty():
		preview_label.text = _creator_error.replace("_", " ").capitalize()
		return
	if _confirmation_pending:
		var starter := _get_selected_starter()
		preview_label.text = "%s | %s | Ready" % [
			_normalized_character_name(),
			str(starter.get("display_name")) if starter != null else "Starter",
		]
		return
	var report := validate_current_recipe()
	preview_label.text = "%s | Parts %d | %s" % [
		_current_recipe.display_name,
		_current_recipe.parts.size(),
		"Valid" if bool(report.get("valid", false)) else "Needs repair",
	]
	_sync_accessibility_preview_label()

func _sync_accessibility_preview_label() -> void:
	var accessibility_label := get_node_or_null("%AccessibilityPreviewLabel") as Label
	if accessibility_label == null or _current_recipe == null:
		return
	var report := accessibility_preview()
	var summary := report.get("summary", {}) as Dictionary
	accessibility_label.text = "Accessibility %s | Contrast issues %d | Small-scale risks %d" % [
		"OK" if bool(report.get("ok", false)) else "Review",
		int(summary.get("failing_palette_pairs", 0)),
		int(summary.get("high_scale_risks", 0)),
	]
	_sync_performance_budget_label()

func _sync_performance_budget_label() -> void:
	var budget_label := get_node_or_null("%PerformanceBudgetLabel") as Label
	if budget_label == null or _current_recipe == null:
		return
	var report := performance_budget_report()
	var summary := report.get("summary", {}) as Dictionary
	budget_label.text = "Budget %s | Frames %d | Memory %.2f MB" % [
		"OK" if bool(report.get("ok", false)) else "Review",
		int(summary.get("estimated_frames", 0)),
		float(summary.get("estimated_bytes", 0)) / 1048576.0,
	]
	_sync_compatibility_preview_label()

func _sync_compatibility_preview_label() -> void:
	var compatibility_label := get_node_or_null("%CompatibilityPreviewLabel") as Label
	if compatibility_label == null or _current_recipe == null:
		return
	var report := compatibility_report()
	var review_count := 0
	for category_id: String in report.keys():
		var category := report.get(category_id, {}) as Dictionary
		var severity := str(category.get("severity", "ok"))
		if severity != "ok" and severity != "low":
			review_count += 1
	compatibility_label.text = "Compatibility %s | Review categories %d" % [
		"OK" if review_count == 0 else "Review",
		review_count,
	]
	_sync_socket_preview_label()

func _sync_socket_preview_label() -> void:
	var socket_label := get_node_or_null("%SocketPreviewLabel") as Label
	if socket_label == null or _current_recipe == null:
		return
	var report := socket_report_for_recipe("idle")
	var sockets := report.get("sockets", {}) as Dictionary
	socket_label.text = "Sockets %d | Idle anchors ready" % sockets.size()

func _sync_appearance_buttons_to_recipe() -> void:
	for slot_id: String in _appearance_buttons.keys():
		var option_button := _appearance_buttons.get(slot_id, null) as OptionButton
		if option_button == null:
			continue
		_select_current_option_if_visible(slot_id, option_button)

func _sync_palette_controls_to_recipe() -> void:
	var container := get_node_or_null("%PaletteControls") as VBoxContainer
	if container == null or _current_recipe == null:
		return
	for palette_id: String in _current_recipe.palettes.keys():
		var edit := container.find_child("%sPaletteEdit" % _pascal_case(palette_id), true, false) as LineEdit
		if edit != null and edit.text != str(_current_recipe.palettes.get(palette_id, "")):
			edit.text = str(_current_recipe.palettes.get(palette_id, ""))

func _sync_morph_controls_to_recipe() -> void:
	var container := get_node_or_null("%MorphControls") as VBoxContainer
	if container == null or _current_recipe == null:
		return
	for morph_id: String in _current_recipe.morphs.keys():
		var slider := container.find_child("%sMorphSlider" % _pascal_case(morph_id), true, false) as HSlider
		if slider != null and not is_equal_approx(slider.value, float(_current_recipe.morphs.get(morph_id, 0.0))):
			slider.value = float(_current_recipe.morphs.get(morph_id, 0.0))

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
	_confirmation_pending = false
	_refresh_selected_starter()


func _on_name_changed(_new_text: String) -> void:
	_confirmation_pending = false
	_creator_error = ""
	_sync_confirm_state()


func _on_back_pressed() -> void:
	if _confirmation_pending:
		_confirmation_pending = false
		_sync_confirm_state()
		return
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

func _pascal_case(value: String) -> String:
	var result := ""
	for piece: String in value.split("_", false):
		result += piece.capitalize().replace(" ", "")
	return result

func _apply_font_scale(font_scale: float) -> void:
	var base_sizes := {
		"HeaderLabel": 36,
		"DescriptionLabel": 16,
		"PreviewLabel": 16,
		"AccessibilityPreviewLabel": 14,
		"PerformanceBudgetLabel": 14,
		"CompatibilityPreviewLabel": 14,
		"SocketPreviewLabel": 14,
	}
	for node_name: String in base_sizes.keys():
		var label := find_child(node_name, true, false) as Label
		if label != null:
			label.add_theme_font_size_override("font_size", int(round(float(base_sizes[node_name]) * font_scale)))
	for button_name: String in ["ConfirmButton", "BackButton", "ResetNameButton", "RandomizeButton"]:
		var button := find_child(button_name, true, false) as Button
		if button != null:
			button.add_theme_font_size_override("font_size", int(round(16.0 * font_scale)))
