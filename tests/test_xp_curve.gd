extends SceneTree

const XPCurve := preload("res://scripts/core/xp_curve.gd")

func _init() -> void:
	var curve := XPCurve.new()
	curve.thresholds = [0, 100, 250, 450]
	if curve.level_for_xp(0) != 1:
		push_error("0 XP should be level 1")
		quit(1)
		return
	if curve.level_for_xp(100) != 2:
		push_error("100 XP should be level 2")
		quit(1)
		return
	if curve.level_for_xp(449) != 3:
		push_error("449 XP should be level 3")
		quit(1)
		return
	if curve.xp_to_next_level(250) != 200:
		push_error("250 XP should need 200 XP to next level")
		quit(1)
		return
	print("PASS: xp curve")
	quit(0)
