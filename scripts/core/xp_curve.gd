extends Resource
class_name XPCurve

@export var thresholds: Array[int] = [0, 100, 250, 450, 700]

func level_for_xp(xp: int) -> int:
	var level := 1
	for index: int in thresholds.size():
		if xp >= thresholds[index]:
			level = index + 1
	return level

func xp_to_next_level(xp: int) -> int:
	var current_level := level_for_xp(xp)
	if current_level >= thresholds.size():
		return 0
	return max(0, thresholds[current_level] - xp)
