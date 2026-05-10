extends "res://scripts/player/player_class_controller.gd"
class_name HexbinderController

func handle_attack() -> void:
	player.fire_spell(class_data.base_attack)

func handle_special_attack() -> void:
	player.cast_binding_sigil()

func handle_class_action() -> void:
	if player.has_traversal_unlock("blink"):
		player.perform_blink()
	elif player.has_traversal_unlock("float_fall"):
		player.perform_float_fall()
	else:
		player.perform_phase_barrier()
