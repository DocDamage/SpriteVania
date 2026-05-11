extends Node2D
class_name PartyShrine

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
