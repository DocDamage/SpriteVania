extends SceneTree

var _failed := false

func _init() -> void:
	_assert_action_has_joypad_button("jump", JOY_BUTTON_A)
	_assert_action_has_joypad_button("dash", JOY_BUTTON_B)
	_assert_action_has_joypad_button("attack", JOY_BUTTON_X)
	_assert_action_has_joypad_button("special_attack", JOY_BUTTON_Y)
	_assert_action_has_joypad_button("class_action", JOY_BUTTON_RIGHT_SHOULDER)
	_assert_action_has_joypad_button("interact", JOY_BUTTON_LEFT_SHOULDER)
	_assert_action_has_joypad_button("pause", JOY_BUTTON_START)
	_assert_action_has_joypad_motion("move_left", JOY_AXIS_LEFT_X, -1.0)
	_assert_action_has_joypad_motion("move_right", JOY_AXIS_LEFT_X, 1.0)
	_assert_action_has_joypad_motion("move_down", JOY_AXIS_LEFT_Y, 1.0)
	_assert_action_has_joypad_button("move_left", JOY_BUTTON_DPAD_LEFT)
	_assert_action_has_joypad_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_assert_action_has_joypad_button("move_down", JOY_BUTTON_DPAD_DOWN)
	if _failed:
		quit(1)
		return
	print("PASS: controller input map")
	quit(0)

func _assert_action_has_joypad_button(action_name: String, button_index: int) -> void:
	if not InputMap.has_action(action_name):
		_fail("Missing input action: " + action_name)
		return
	for event: InputEvent in InputMap.action_get_events(action_name):
		var button := event as InputEventJoypadButton
		if button != null and button.button_index == button_index:
			return
	_fail("%s should include joypad button %d." % [action_name, button_index])

func _assert_action_has_joypad_motion(action_name: String, axis: int, axis_value: float) -> void:
	if not InputMap.has_action(action_name):
		_fail("Missing input action: " + action_name)
		return
	for event: InputEvent in InputMap.action_get_events(action_name):
		var motion := event as InputEventJoypadMotion
		if motion != null and motion.axis == axis and signf(motion.axis_value) == signf(axis_value):
			return
	_fail("%s should include joypad axis %d value %s." % [action_name, axis, axis_value])

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
