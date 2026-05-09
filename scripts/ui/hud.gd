extends CanvasLayer
class_name HUD

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_value_label: Label = %HealthValueLabel
@onready var resource_bar: ProgressBar = %ResourceBar
@onready var resource_value_label: Label = %ResourceValueLabel
@onready var level_label: Label = %LevelLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var xp_value_label: Label = %XPValueLabel

var player: Player

func bind_player(next_player: Player) -> void:
	if player != null and player.stats_changed.is_connected(_on_player_stats_changed):
		player.stats_changed.disconnect(_on_player_stats_changed)

	player = next_player
	if player == null:
		return

	if not player.stats_changed.is_connected(_on_player_stats_changed):
		player.stats_changed.connect(_on_player_stats_changed)
	_on_player_stats_changed(player.get_stats())

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
