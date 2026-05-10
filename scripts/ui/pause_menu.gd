extends Control
class_name PauseMenu

signal resume_requested
signal settings_requested
signal save_requested
signal quit_to_title_requested

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	%ResumeButton.pressed.connect(func() -> void: resume_requested.emit())
	%SettingsButton.pressed.connect(func() -> void: settings_requested.emit())
	%SaveButton.pressed.connect(func() -> void: save_requested.emit())
	%QuitButton.pressed.connect(func() -> void: quit_to_title_requested.emit())
	%ResumeButton.grab_focus()
