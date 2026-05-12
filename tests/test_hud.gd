extends SceneTree

const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var container := Node2D.new()
	container.name = "HUDTestRoot"
	root.add_child(container)
	container.add_child(HUD_SCENE.instantiate())
	container.add_child(PLAYER_SCENE.instantiate())
	await process_frame

	var hud := container.get_child(0) as CanvasLayer
	var player := container.get_child(1) as Player
	player.setup(WARDEN_DATA, "")
	hud.call("bind_player", player)

	_assert_equal("Level 1", hud.get_node("%LevelLabel").text, "HUD should display the starting level.")
	if _failed:
		return
	_assert_equal("140 / 140", hud.get_node("%HealthValueLabel").text, "HUD should display starting health.")
	if _failed:
		return
	_assert_equal("40 / 40", hud.get_node("%ResourceValueLabel").text, "HUD should display starting resource.")
	if _failed:
		return
	_assert_equal("0 / 100 XP", hud.get_node("%XPValueLabel").text, "HUD should display XP progress to the next level.")
	if _failed:
		return
	_assert_equal("Attack J / X  Combo taps  Dive S+J / Down+X  Dash Shift / B", hud.get_node("%ControlsHintLabel").text, "HUD should make attack, combo, dive, and dash controls visible during play.")
	if _failed:
		return
	if not hud.has_method("show_attack_prompt"):
		_fail("HUD should expose show_attack_prompt so rooms can trigger an attack tutorial hook.")
		return
	hud.call("show_attack_prompt")
	_assert_equal("Attack J / X  Tap for combo  Hold Down+Attack to dive", hud.get_node("%ControlsHintLabel").text, "Attack prompt hook should surface melee combo and dive input.")
	if _failed:
		return
	hud.call("apply_settings", {"controller_prompt_style": "PlayStation"})
	_assert_equal("Attack J / Square  Tap for combo  Hold Down+Attack to dive", hud.get_node("%ControlsHintLabel").text, "HUD should support PlayStation controller prompt fallback text.")
	if _failed:
		return
	hud.call("clear_controls_prompt")
	_assert_equal("Attack J / Square  Combo taps  Dive S+J / Down+Square  Dash Shift / Circle", hud.get_node("%ControlsHintLabel").text, "HUD should restore its default controls prompt using the selected controller style.")
	if _failed:
		return
	_assert_equal("Familiar Lv 1 - Spark", hud.get_node("%FamiliarLabel").text, "HUD should display the familiar starting level and evolution.")
	if _failed:
		return
	hud.call("set_party_status", {
		"active_party_ids": ["ronin", "black_witch", "shadow"],
		"active_party_index": 1,
		"momentum": 75,
		"party_roster": {
			"black_witch": {"is_ko": true},
		},
	})
	_assert_equal("Party Ronin / *Black Witch KO / Shadow  Momentum 75", hud.get_node("%PartyLabel").text, "HUD should show active slot, Momentum, and KO state in party status.")
	if _failed:
		return

	var discovered_rooms: Array[String] = ["RoomStart", "RoomCheckpoint"]
	hud.call("set_map_context", "swamp_outskirts", "RoomCheckpoint", discovered_rooms)
	_assert_equal("Swamp Outskirts - Shrine Hollow", hud.get_node("%RoomLabel").text, "HUD should display the current area and room.")
	if _failed:
		return
	_assert_equal("Map 2 / 8", hud.get_node("%DiscoveryLabel").text, "HUD should display discovered room count.")
	if _failed:
		return

	player.take_damage(20)
	_assert_equal("126 / 140", hud.get_node("%HealthValueLabel").text, "HUD should update when the player takes damage.")
	if _failed:
		return

	player.gain_xp(100)
	_assert_equal("Level 2", hud.get_node("%LevelLabel").text, "HUD should update after leveling up.")
	if _failed:
		return
	_assert_equal("150 / 150", hud.get_node("%HealthValueLabel").text, "HUD should reflect level-up max health restore.")
	if _failed:
		return
	_assert_equal("0 / 150 XP", hud.get_node("%XPValueLabel").text, "HUD should reset XP progress inside the new level band.")
	if _failed:
		return

	var familiar := player.get_node("Familiar") as Node
	familiar.call("gain_xp", 120)
	hud.call("set_familiar_status", familiar.call("get_status"))
	_assert_equal("Familiar Lv 2 - Wisp", hud.get_node("%FamiliarLabel").text, "HUD should update familiar level and evolution.")
	if _failed:
		return

	hud.call("show_upgrade_feedback", "Traversal unlocked", "Armored Dash")
	_assert_equal(true, hud.get_node("%UpgradeToast").visible, "HUD should show upgrade feedback.")
	if _failed:
		return
	_assert_equal("Traversal unlocked", hud.get_node("%UpgradeTitleLabel").text, "HUD should display upgrade feedback title.")
	if _failed:
		return
	_assert_equal("Armored Dash", hud.get_node("%UpgradeDetailLabel").text, "HUD should display upgrade feedback detail.")
	if _failed:
		return

	hud.call("apply_settings", {
		"large_text": true,
		"high_contrast": true,
		"controller_prompt_style": "Generic",
	})
	if int(hud.get_node("%ControlsHintLabel").get_theme_font_size("font_size")) < 14:
		_fail("HUD large text setting should increase hint label font size.")
		return
	if hud.get_node("Root").modulate != Color(1.0, 1.0, 1.0, 1.0):
		_fail("HUD high contrast should force full opacity.")
		return

	hud.call("apply_settings", {
		"large_text": false,
		"high_contrast": false,
		"controller_prompt_style": "Xbox",
	})
	if int(hud.get_node("%ControlsHintLabel").get_theme_font_size("font_size")) != 11:
		_fail("HUD should restore default hint label font size when large text is disabled.")
		return
	_assert_equal("Attack J / X  Combo taps  Dive S+J / Down+X  Dash Shift / B", hud.get_node("%ControlsHintLabel").text, "HUD should switch back to Xbox-style prompt labels.")
	if _failed:
		return

	container.queue_free()
	await process_frame
	print("PASS: hud")
	quit(0)

func _assert_equal(expected: Variant, actual: Variant, message: String) -> void:
	if expected == actual:
		return

	_fail("%s Expected: %s Actual: %s" % [message, str(expected), str(actual)])

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
