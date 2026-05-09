extends "res://scripts/player/player_class_controller.gd"
class_name GunslingerController

func handle_attack() -> void:
	player.fire_projectile(class_data.base_attack)

func handle_special_attack() -> void:
	player.fire_piercing_shot(class_data.base_attack * 2)

func handle_class_action() -> void:
	player.perform_slide()
