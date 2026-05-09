extends "res://scripts/player/player_class_controller.gd"
class_name WardenController

func handle_attack() -> void:
	player.perform_melee_attack(class_data.base_attack)

func handle_special_attack() -> void:
	player.perform_guard_counter()

func handle_class_action() -> void:
	player.start_blocking()
