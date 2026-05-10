extends Node2D

func _ready() -> void:
	var timer := get_node_or_null("LifeTimer") as Timer
	if timer != null:
		timer.timeout.connect(queue_free)
