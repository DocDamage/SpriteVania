extends "res://scripts/player/player_class_controller.gd"
class_name GunslingerController

func handle_attack() -> void:
	player.fire_projectile(class_data.base_attack)

func handle_special_attack() -> void:
	player.fire_piercing_shot(class_data.base_attack * 2)

func handle_class_action() -> void:
	if player.has_traversal_unlock("hookshot"):
		player.perform_hookshot()
	elif player.has_traversal_unlock("combat_slide"):
		player.perform_slide()
	else:
		player.perform_recoil_jump()
