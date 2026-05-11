extends CanvasLayer
class_name HUD

const MapRegistry := preload("res://scripts/world/map_registry.gd")
const DEFAULT_CONTROLS_HINT_FONT_SIZE := 11
const LARGE_CONTROLS_HINT_FONT_SIZE := 15

@onready var root_control: Control = $Root
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_value_label: Label = %HealthValueLabel
@onready var resource_bar: ProgressBar = %ResourceBar
@onready var resource_value_label: Label = %ResourceValueLabel
@onready var level_label: Label = %LevelLabel
@onready var familiar_label: Label = %FamiliarLabel
@onready var room_label: Label = %RoomLabel
@onready var discovery_label: Label = %DiscoveryLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var xp_value_label: Label = %XPValueLabel
@onready var upgrade_toast: PanelContainer = %UpgradeToast
@onready var upgrade_title_label: Label = %UpgradeTitleLabel
@onready var upgrade_detail_label: Label = %UpgradeDetailLabel
@onready var upgrade_toast_timer: Timer = %UpgradeToastTimer

var player: Player

func _ready() -> void:
	upgrade_toast_timer.timeout.connect(_on_upgrade_toast_timer_timeout)

func apply_settings(settings: Dictionary) -> void:
	var large_text := bool(settings.get("large_text", false))
	var high_contrast := bool(settings.get("high_contrast", false))
	var hint_size := LARGE_CONTROLS_HINT_FONT_SIZE if large_text else DEFAULT_CONTROLS_HINT_FONT_SIZE
	%ControlsHintLabel.add_theme_font_size_override("font_size", hint_size)
	root_control.modulate = Color(1.0, 1.0, 1.0, 1.0) if high_contrast else Color(1.0, 1.0, 1.0, 0.92)

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
