extends Node
class_name PlayerClassController

const ClassData := preload("res://scripts/data/class_data.gd")

var player: CharacterBody2D
var class_data: ClassData

func setup(owner_player: CharacterBody2D, data: ClassData) -> void:
	player = owner_player
	class_data = data

func handle_attack() -> void:
	pass

func handle_special_attack() -> void:
	pass

func handle_class_action() -> void:
	pass
