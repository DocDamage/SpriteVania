extends Area2D
class_name LoreTablet

@export var tablet_id: String = ""
@export var dialogue_resource: DialogueResource
@export var cue: String = "start"
@export var prompt_text: String = "E"

@onready var prompt_label: Label = get_node_or_null("PromptLabel") as Label

var _player_in_range := false
var _dialogue_active := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label != null:
		prompt_label.text = prompt_text
		prompt_label.visible = false
	if Engine.has_singleton("DialogueManager"):
		var dialogue_manager: Node = Engine.get_singleton("DialogueManager")
		if not dialogue_manager.dialogue_ended.is_connected(_on_dialogue_ended):
			dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if not _player_in_range or _dialogue_active:
		return
	if Input.is_action_just_pressed("interact"):
		_start_dialogue()

func _start_dialogue() -> void:
	if dialogue_resource == null or not Engine.has_singleton("DialogueManager"):
		return

	_dialogue_active = true
	if prompt_label != null:
		prompt_label.visible = false
	var dialogue_manager: Node = Engine.get_singleton("DialogueManager")
	dialogue_manager.show_dialogue_balloon(dialogue_resource, cue)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player_in_range = true
		if prompt_label != null and not _dialogue_active:
			prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body is Player:
		_player_in_range = false
		if prompt_label != null:
			prompt_label.visible = false

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource != dialogue_resource:
		return
	_dialogue_active = false
	if prompt_label != null and _player_in_range:
		prompt_label.visible = true
