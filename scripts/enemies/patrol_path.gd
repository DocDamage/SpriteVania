extends Node2D
class_name PatrolPath

func local_bounds() -> Vector2:
	var has_marker := false
	var left := 0.0
	var right := 0.0
	for child: Node in get_children():
		var marker := child as Node2D
		if marker == null:
			continue
		var marker_x := marker.position.x
		if not has_marker:
			left = marker_x
			right = marker_x
			has_marker = true
		else:
			left = minf(left, marker_x)
			right = maxf(right, marker_x)
	return Vector2(left, right)
