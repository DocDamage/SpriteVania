extends "res://scripts/player/player_class_controller.gd"
class_name HexbinderController

func handle_attack() -> void:
	player.fire_spell(class_data.base_attack)

func handle_special_attack() -> void:
	player.cast_binding_sigil()

func handle_class_action() -> void:
	player.perform_blink()
