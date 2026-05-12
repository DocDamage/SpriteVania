extends CanvasLayer
class_name HUD

const MapRegistry := preload("res://scripts/world/map_registry.gd")
const DEFAULT_CONTROLS_HINT_FONT_SIZE := 11
const LARGE_CONTROLS_HINT_FONT_SIZE := 15
const DEFAULT_CONTROLLER_STYLE := "Xbox"
const PROMPT_LABELS := {
	"Generic": {"attack": "Face Left", "dash": "Face Right"},
	"Xbox": {"attack": "X", "dash": "B"},
	"PlayStation": {"attack": "Square", "dash": "Circle"},
	"Switch": {"attack": "Y", "dash": "A"},
}

@onready var root_control: Control = $Root
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_value_label: Label = %HealthValueLabel
@onready var resource_bar: ProgressBar = %ResourceBar
@onready var resource_value_label: Label = %ResourceValueLabel
@onready var level_label: Label = %LevelLabel
@onready var familiar_label: Label = %FamiliarLabel
@onready var party_label: Label = %PartyLabel
@onready var room_label: Label = %RoomLabel
@onready var discovery_label: Label = %DiscoveryLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var xp_value_label: Label = %XPValueLabel
@onready var upgrade_toast: PanelContainer = %UpgradeToast
@onready var upgrade_title_label: Label = %UpgradeTitleLabel
@onready var upgrade_detail_label: Label = %UpgradeDetailLabel
@onready var upgrade_toast_timer: Timer = %UpgradeToastTimer

var player: Player
var _controller_prompt_style := DEFAULT_CONTROLLER_STYLE
var _showing_attack_prompt := false

func _ready() -> void:
	upgrade_toast_timer.timeout.connect(_on_upgrade_toast_timer_timeout)
	clear_controls_prompt()

func apply_settings(settings: Dictionary) -> void:
	var large_text := bool(settings.get("large_text", false))
	var high_contrast := bool(settings.get("high_contrast", false))
	_controller_prompt_style = _normalize_controller_style(str(settings.get("controller_prompt_style", _controller_prompt_style)))
	var hint_size := LARGE_CONTROLS_HINT_FONT_SIZE if large_text else DEFAULT_CONTROLS_HINT_FONT_SIZE
	%ControlsHintLabel.add_theme_font_size_override("font_size", hint_size)
	root_control.modulate = Color(1.0, 1.0, 1.0, 1.0) if high_contrast else Color(1.0, 1.0, 1.0, 0.92)
	_update_controls_prompt_text()

func bind_player(next_player: Player) -> void:
	if player != null and player.stats_changed.is_connected(_on_player_stats_changed):
		player.stats_changed.disconnect(_on_player_stats_changed)

	player = next_player
	if player == null:
		return

	if not player.stats_changed.is_connected(_on_player_stats_changed):
		player.stats_changed.connect(_on_player_stats_changed)
	_on_player_stats_changed(player.get_stats())
	var familiar := player.get_node_or_null("Familiar")
	if familiar != null and familiar.has_method("get_status"):
		set_familiar_status(familiar.call("get_status"))

func show_attack_prompt() -> void:
	_showing_attack_prompt = true
	_update_controls_prompt_text()

func clear_controls_prompt() -> void:
	_showing_attack_prompt = false
	_update_controls_prompt_text()

func _update_controls_prompt_text() -> void:
	if %ControlsHintLabel == null:
		return
	var labels := PROMPT_LABELS.get(_controller_prompt_style, PROMPT_LABELS[DEFAULT_CONTROLLER_STYLE]) as Dictionary
	var attack_label := str(labels.get("attack", "X"))
	var dash_label := str(labels.get("dash", "B"))
	if _showing_attack_prompt:
		%ControlsHintLabel.text = "Attack J / %s  Tap for combo  Hold Down+Attack to dive" % attack_label
	else:
		%ControlsHintLabel.text = "Attack J / %s  Combo taps  Dive S+J / Down+%s  Dash Shift / %s" % [attack_label, attack_label, dash_label]

func _normalize_controller_style(style: String) -> String:
	if PROMPT_LABELS.has(style):
		return style
	return DEFAULT_CONTROLLER_STYLE

func _on_player_stats_changed(stats: Dictionary) -> void:
	var health: int = int(stats.get("health", 0))
	var max_health: int = max(1, int(stats.get("max_health", 1)))
	var resource: int = int(stats.get("resource", 0))
	var max_resource: int = max(1, int(stats.get("max_resource", 1)))
	var level: int = int(stats.get("level", 1))
	var xp_progress: int = int(stats.get("xp_progress", 0))
	var xp_required: int = max(1, int(stats.get("xp_required", 1)))

	health_bar.max_value = max_health
	health_bar.value = clampi(health, 0, max_health)
	health_value_label.text = "%d / %d" % [health, max_health]

	resource_bar.max_value = max_resource
	resource_bar.value = clampi(resource, 0, max_resource)
	resource_value_label.text = "%d / %d" % [resource, max_resource]

	level_label.text = "Level %d" % level
	xp_bar.max_value = xp_required
	xp_bar.value = clampi(xp_progress, 0, xp_required)
	xp_value_label.text = "%d / %d XP" % [xp_progress, xp_required]

func set_familiar_status(status: Dictionary) -> void:
	var familiar_level := int(status.get("level", 1))
	var evolution_stage := str(status.get("evolution_stage", "spark")).capitalize()
	familiar_label.text = "Familiar Lv %d - %s" % [familiar_level, evolution_stage]

func set_party_status(status: Dictionary) -> void:
	var active_ids: Array = status.get("active_party_ids", []) as Array
	var active_index := int(status.get("active_party_index", 0))
	var momentum := int(status.get("momentum", 0))
	var roster := status.get("party_roster", {}) as Dictionary
	var labels: Array[String] = []
	for index: int in active_ids.size():
		var character_id := str(active_ids[index])
		var marker := "*" if index == active_index else ""
		var ko_marker := " KO" if bool((roster.get(character_id, {}) as Dictionary).get("is_ko", false)) else ""
		labels.append("%s%s%s" % [marker, character_id.replace("_", " ").capitalize(), ko_marker])
	party_label.text = "Party %s  Momentum %d" % [" / ".join(labels), momentum]

func show_upgrade_feedback(title: String, detail: String) -> void:
	upgrade_title_label.text = title
	upgrade_detail_label.text = detail
	upgrade_toast.visible = true
	upgrade_toast_timer.start()

func set_map_context(area_id: String, room_id: String, discovered_rooms: Array[String]) -> void:
	var area_label := MapRegistry.get_area_label(area_id)
	var current_room_label := MapRegistry.get_room_label(area_id, room_id)
	var room_count := MapRegistry.get_room_count(area_id)
	room_label.text = "%s - %s" % [area_label, current_room_label]
	discovery_label.text = "Map %d / %d" % [discovered_rooms.size(), room_count]

func _on_upgrade_toast_timer_timeout() -> void:
	upgrade_toast.visible = false
