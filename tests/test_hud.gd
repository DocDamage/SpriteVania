extends SceneTree

const HUD_SCENE := preload("res://scenes/ui/HUD.tscn")
const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const WARDEN_DATA := preload("res://data/classes/warden.tres")

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
	_assert_equal("140 / 140", hud.get_node("%HealthValueLabel").text, "HUD should display starting health.")
	_assert_equal("40 / 40", hud.get_node("%ResourceValueLabel").text, "HUD should display starting resource.")
	_assert_equal("0 / 100 XP", hud.get_node("%XPValueLabel").text, "HUD should display XP progress to the next level.")

	player.take_damage(20)
	_assert_equal("126 / 140", hud.get_node("%HealthValueLabel").text, "HUD should update when the player takes damage.")

	player.gain_xp(100)
	_assert_equal("Level 2", hud.get_node("%LevelLabel").text, "HUD should update after leveling up.")
	_assert_equal("150 / 150", hud.get_node("%HealthValueLabel").text, "HUD should reflect level-up max health restore.")
	_assert_equal("0 / 150 XP", hud.get_node("%XPValueLabel").text, "HUD should reset XP progress inside the new level band.")

	hud.call("show_upgrade_feedback", "Traversal unlocked", "Armored Dash")
	_assert_equal(true, hud.get_node("%UpgradeToast").visible, "HUD should show upgrade feedback.")
	_assert_equal("Traversal unlocked", hud.get_node("%UpgradeTitleLabel").text, "HUD should display upgrade feedback title.")
	_assert_equal("Armored Dash", hud.get_node("%UpgradeDetailLabel").text, "HUD should display upgrade feedback detail.")

	container.free()
	quit(0)

func _assert_equal(expected: Variant, actual: Variant, message: String) -> void:
	if expected == actual:
		return

	push_error("%s Expected: %s Actual: %s" % [message, str(expected), str(actual)])
	quit(1)
