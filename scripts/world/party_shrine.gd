extends Node2D
class_name PartyShrine

const PartyManagerScript := preload("res://scripts/core/party_manager.gd")

var is_open := false
var last_party_status: Dictionary = {}

func open_party_service(world: Node) -> bool:
	var state := world.get("state") as GameState if world != null else null
	if state == null:
		return false
	is_open = true
	last_party_status = {
		"active_party_ids": state.active_party_ids.duplicate(),
		"active_party_index": state.active_party_index,
		"momentum": state.momentum,
		"party_roster": state.party_roster.duplicate(true),
	}
	return true

func cancel_party_service() -> void:
	is_open = false

func commit_party_service(world: Node, active_party_ids: Array, rename_requests := {}) -> bool:
	var state := world.get("state") as GameState if world != null else null
	if state == null:
		return false
	var manager := world.get("party_manager") as PartyManager if world.get("party_manager") != null else PartyManagerScript.new()
	if not manager.can_set_active_party(state, active_party_ids):
		return false
	if rename_requests is Dictionary:
		for character_id: String in rename_requests.keys():
			manager.rename_character(state, character_id, str(rename_requests[character_id]))
	if not manager.set_active_party(state, active_party_ids):
		return false
	last_party_status = manager.party_status(state)
	is_open = false
	if world.has_method("_update_party_hud"):
		world.call("_update_party_hud")
	if world.has_method("_save_game_state"):
		world.call("_save_game_state")
	return true
