extends Control
class_name PauseMenu

signal resume_requested
signal settings_requested
signal save_requested
signal quit_to_title_requested
signal familiar_upgrade_requested(ability_id: String)

const FAMILIAR_ABILITIES := {
	"sting": "Sting",
	"focus": "Focus",
	"guard": "Guard",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	%ResumeButton.pressed.connect(func() -> void: resume_requested.emit())
	%SettingsButton.pressed.connect(func() -> void: settings_requested.emit())
	%SaveButton.pressed.connect(func() -> void: save_requested.emit())
	%QuitButton.pressed.connect(func() -> void: quit_to_title_requested.emit())
	%StingUpgradeButton.pressed.connect(func() -> void: familiar_upgrade_requested.emit("sting"))
	%FocusUpgradeButton.pressed.connect(func() -> void: familiar_upgrade_requested.emit("focus"))
	%GuardUpgradeButton.pressed.connect(func() -> void: familiar_upgrade_requested.emit("guard"))
	%ResumeButton.grab_focus()

func set_familiar_status(status: Dictionary) -> void:
	var familiar_level := int(status.get("level", 1))
	var evolution_stage := str(status.get("evolution_stage", "spark")).capitalize()
	var ability_points := int(status.get("ability_points", 0))
	var ability_levels := status.get("ability_levels", {}) as Dictionary

	%FamiliarStatusLabel.text = "Familiar Lv %d - %s" % [familiar_level, evolution_stage]
	%FamiliarPointsLabel.text = "Ability Points: %d" % ability_points
	_update_upgrade_button(%StingUpgradeButton, "sting", ability_points, ability_levels)
	_update_upgrade_button(%FocusUpgradeButton, "focus", ability_points, ability_levels)
	_update_upgrade_button(%GuardUpgradeButton, "guard", ability_points, ability_levels)

func set_map_status(status: Dictionary) -> void:
	var current_room_label := str(status.get("current_room_label", "Unknown"))
	var discovered_room_labels := _string_array(status.get("discovered_room_labels", []))
	var completed_area_labels := _string_array(status.get("completed_area_labels", []))

	%MapCurrentRoomLabel.text = "Current: %s" % current_room_label
	%MapDiscoveredLabel.text = "Discovered: %s" % _format_label_list(discovered_room_labels, "None")
	%MapCompletionLabel.text = "Completed: %s" % _format_label_list(completed_area_labels, "None")

func _update_upgrade_button(button: Button, ability_id: String, ability_points: int, ability_levels: Dictionary) -> void:
	var label := str(FAMILIAR_ABILITIES.get(ability_id, ability_id.capitalize()))
	var ability_level := int(ability_levels.get(ability_id, 0))
	button.text = "%s Lv %d" % [label, ability_level]
	button.disabled = ability_points <= 0

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result

func _format_label_list(labels: Array[String], empty_label: String) -> String:
	if labels.is_empty():
		return empty_label
	return ", ".join(labels)
