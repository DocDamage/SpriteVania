extends Node2D
class_name SakuramoriSaveShrine

@export var checkpoint_id := "checkpoint_sakuramori_court"

func activate_save_service(world: Node) -> bool:
	if world == null or not world.has_method("activate_checkpoint"):
		return false
	var player := world.get("player") as Node
	if player != null and player.has_method("restore_vitals_to_max"):
		player.call("restore_vitals_to_max")
	var state := world.get("state") as GameState
	if state != null:
		_clear_party_ko_state(state)
	world.call("activate_checkpoint", checkpoint_id, global_position)
	if world.has_method("_store_player_state"):
		world.call("_store_player_state")
	if world.has_method("_save_game_state"):
		world.call("_save_game_state")
	return true

func _clear_party_ko_state(state: GameState) -> void:
	for character_id: String in state.party_roster.keys():
		var runtime := state.party_roster.get(character_id, {}) as Dictionary
		runtime["is_ko"] = false
		if int(runtime.get("current_health", 0)) <= 0:
			runtime["current_health"] = 1
		state.party_roster[character_id] = runtime
