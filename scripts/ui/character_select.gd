extends Control
class_name CharacterSelect

signal character_confirmed(class_id: String, sprite_id: String)
signal cancel_requested

const CLASS_RESOURCE_PATHS: Array[String] = [
	"res://data/classes/warden.tres",
	"res://data/classes/gunslinger.tres",
	"res://data/classes/hexbinder.tres",
]

var _classes: Array[Resource] = []


func _ready() -> void:
	%ClassOption.item_selected.connect(_on_class_selected)
	%ConfirmButton.pressed.connect(_on_confirm_pressed)
	%BackButton.pressed.connect(_on_back_pressed)

	_load_classes()
	_populate_class_options()
	_refresh_selected_class()


func _load_classes() -> void:
	_classes.clear()

	for path: String in CLASS_RESOURCE_PATHS:
		var class_data := load(path) as Resource
		if class_data:
			_classes.append(class_data)
		else:
			push_warning("Could not load class data: %s" % path)


func _populate_class_options() -> void:
	%ClassOption.clear()

	for index: int in _classes.size():
		var class_data := _classes[index]
		%ClassOption.add_item(str(class_data.get("display_name")), index)

	%ConfirmButton.disabled = _classes.is_empty()


func _refresh_selected_class() -> void:
	var class_data := _get_selected_class()
	if class_data == null:
		%SpriteOption.clear()
		%DescriptionLabel.text = ""
		return

	%DescriptionLabel.text = str(class_data.get("description"))
	_refresh_sprite_options(class_data)


func _refresh_sprite_options(class_data: Resource) -> void:
	%SpriteOption.clear()

	var sprite_options: Array = class_data.get("sprite_options")
	for index: int in sprite_options.size():
		var sprite_path := str(sprite_options[index])
		%SpriteOption.add_item(_sprite_label(sprite_path), index)

	%ConfirmButton.disabled = sprite_options.is_empty()


func _sprite_label(sprite_path: String) -> String:
	var file_name := sprite_path.get_file().get_basename()
	return file_name.replace("_", " ")


func _get_selected_class() -> Resource:
	var index: int = %ClassOption.selected
	if index < 0 or index >= _classes.size():
		return null

	return _classes[index]


func _on_class_selected(_index: int) -> void:
	_refresh_selected_class()


func _on_confirm_pressed() -> void:
	var class_data := _get_selected_class()
	if class_data == null:
		return

	var sprite_options: Array = class_data.get("sprite_options")
	var sprite_index: int = %SpriteOption.selected
	if sprite_index < 0 or sprite_index >= sprite_options.size():
		return

	character_confirmed.emit(str(class_data.get("class_id")), str(sprite_options[sprite_index]))


func _on_back_pressed() -> void:
	cancel_requested.emit()
