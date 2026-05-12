extends RefCounted
class_name PartyManager

const CharacterRegistry := preload("res://scripts/characters/character_registry.gd")
const DEFAULT_MOMENTUM := 100
const SWAP_MOMENTUM_COST := 25

func initialize_starter(state: GameState, starter_id: String, character_name: String) -> void:
	if state == null:
		return
	var resolved_id := starter_id if not starter_id.is_empty() else state.selected_class
	var display_name := resolved_id.capitalize()
	var class_id := state.selected_class
	var baseline_skills: Array[String] = []
	var definition := CharacterRegistry.get_definition(resolved_id)
	if definition != null:
		display_name = str(definition.get("display_name"))
		class_id = str(definition.get("class_id"))
		baseline_skills = _string_array(definition.get("baseline_skills"))
	elif class_id.is_empty():
		class_id = resolved_id
	state.party_roster[resolved_id] = _runtime_state(resolved_id, display_name, character_name, class_id, 1, 0, 0, 0, baseline_skills)
	state.unlocked_character_ids = [resolved_id]
	state.active_party_ids = [resolved_id]
	state.reserve_character_ids = []
	state.active_party_index = 0
	state.current_visible_character_id = resolved_id
	state.party_order_version += 1
	state.momentum = DEFAULT_MOMENTUM

func ensure_legacy_party_state(state: GameState) -> void:
	if state == null:
		return
	if state.active_party_ids.is_empty():
		initialize_starter(state, state.selected_starter_id if not state.selected_starter_id.is_empty() else state.selected_class, state.player_name)
		return
	_sync_party_lists(state)
	var active_id := active_character_id(state)
	if state.current_visible_character_id.is_empty() and not active_id.is_empty():
		state.current_visible_character_id = active_id

func unlock_character(state: GameState, character_id: String, character_name := "") -> bool:
	if state == null or character_id.is_empty() or state.party_roster.has(character_id):
		return false
	var definition := CharacterRegistry.get_definition(character_id)
	if definition == null:
		return false
	var resolved_name := character_name.strip_edges()
	if resolved_name.is_empty():
		resolved_name = str(definition.get("default_name"))
	state.party_roster[character_id] = _runtime_state(
		character_id,
		str(definition.get("display_name")),
		resolved_name,
		str(definition.get("class_id")),
		1,
		0,
		0,
		0,
		_string_array(definition.get("baseline_skills"))
	)
	_add_unlocked_id(state, character_id)
	if not state.active_party_ids.has(character_id) and state.active_party_ids.size() < 3:
		state.active_party_ids.append(character_id)
	state.party_order_version += 1
	_sync_party_lists(state)
	return true

func recruit_character(state: GameState, character_id: String, character_name: String) -> bool:
	if state == null or character_id.is_empty() or state.party_roster.has(character_id):
		return false
	var definition := CharacterRegistry.get_definition(character_id)
	if definition == null or not bool(definition.get("recruitable")):
		return false
	var resolved_name := character_name.strip_edges()
	if resolved_name.is_empty():
		resolved_name = str(definition.get("default_name"))
	state.party_roster[character_id] = _runtime_state(
		character_id,
		str(definition.get("display_name")),
		resolved_name,
		str(definition.get("class_id")),
		1,
		0,
		0,
		0,
		_string_array(definition.get("baseline_skills"))
	)
	_add_unlocked_id(state, character_id)
	if not state.active_party_ids.has(character_id) and state.active_party_ids.size() < 3:
		state.active_party_ids.append(character_id)
	state.party_order_version += 1
	_sync_party_lists(state)
	state.momentum = max(state.momentum, DEFAULT_MOMENTUM)
	return true

func set_active_party(state: GameState, party_ids: Array) -> bool:
	if not can_set_active_party(state, party_ids):
		return false
	var normalized: Array[String] = []
	for item: Variant in party_ids:
		normalized.append(str(item))
	var previous_visible := active_character_id(state)
	state.active_party_ids = normalized
	state.active_party_index = state.active_party_ids.find(previous_visible)
	if state.active_party_index < 0:
		state.active_party_index = 0
	state.party_order_version += 1
	_sync_party_lists(state)
	_apply_active_identity(state)
	return true

func can_set_active_party(state: GameState, party_ids: Array) -> bool:
	if state == null or party_ids.is_empty() or party_ids.size() > 3:
		return false
	var normalized: Array[String] = []
	for item: Variant in party_ids:
		var character_id := str(item)
		if character_id.is_empty() or normalized.has(character_id):
			return false
		if not state.party_roster.has(character_id):
			return false
		normalized.append(character_id)
	return true

func rename_character(state: GameState, character_id: String, character_name: String) -> bool:
	if state == null or not state.party_roster.has(character_id):
		return false
	var resolved_name := character_name.strip_edges()
	if resolved_name.is_empty():
		return false
	var runtime := state.party_roster[character_id] as Dictionary
	runtime["character_name"] = resolved_name
	state.party_roster[character_id] = runtime
	if active_character_id(state) == character_id:
		state.player_name = resolved_name
	return true

func can_swap_to(state: GameState, slot_index: int) -> bool:
	if state == null:
		return false
	if slot_index < 0 or slot_index >= state.active_party_ids.size():
		return false
	if slot_index == state.active_party_index:
		return false
	return state.momentum >= SWAP_MOMENTUM_COST

func swap_to(state: GameState, slot_index: int) -> bool:
	if not can_swap_to(state, slot_index):
		return false
	return force_swap_to(state, slot_index, SWAP_MOMENTUM_COST)

func force_swap_to(state: GameState, slot_index: int, momentum_cost := 0) -> bool:
	if state == null or slot_index < 0 or slot_index >= state.active_party_ids.size():
		return false
	state.active_party_index = slot_index
	state.momentum = max(0, state.momentum - momentum_cost)
	_apply_active_identity(state)
	return true

func active_character_id(state: GameState) -> String:
	if state == null or state.active_party_ids.is_empty():
		return ""
	var index := clampi(state.active_party_index, 0, state.active_party_ids.size() - 1)
	return state.active_party_ids[index]

func store_active_runtime(state: GameState, health: int, resource: int, level: int, xp: int) -> void:
	var active_id := active_character_id(state)
	if state == null or active_id.is_empty() or not state.party_roster.has(active_id):
		return
	var runtime := state.party_roster[active_id] as Dictionary
	runtime["current_health"] = health
	runtime["current_resource"] = resource
	runtime["level"] = level
	runtime["xp"] = xp
	state.party_roster[active_id] = runtime

func mark_active_ko(state: GameState) -> void:
	var active_id := active_character_id(state)
	if state == null or active_id.is_empty() or not state.party_roster.has(active_id):
		return
	var runtime := state.party_roster[active_id] as Dictionary
	runtime["is_ko"] = true
	runtime["current_health"] = 0
	state.party_roster[active_id] = runtime

func next_living_slot(state: GameState) -> int:
	if state == null or state.active_party_ids.size() <= 1:
		return -1
	for offset: int in range(1, state.active_party_ids.size() + 1):
		var index := (state.active_party_index + offset) % state.active_party_ids.size()
		var character_id := state.active_party_ids[index]
		var runtime := state.party_roster.get(character_id, {}) as Dictionary
		if not bool(runtime.get("is_ko", false)):
			return index
	return -1

func party_status(state: GameState) -> Dictionary:
	if state == null:
		return {}
	return {
		"active_party_ids": state.active_party_ids.duplicate(),
		"reserve_character_ids": state.reserve_character_ids.duplicate(),
		"unlocked_character_ids": state.unlocked_character_ids.duplicate(),
		"active_party_index": state.active_party_index,
		"current_visible_character_id": active_character_id(state),
		"party_order_version": state.party_order_version,
		"momentum": state.momentum,
		"party_roster": state.party_roster.duplicate(true),
	}

func _runtime_state(character_id: String, display_name: String, character_name: String, class_id: String, level: int, xp: int, health: int, resource: int, learned_attack_skills: Array[String]) -> Dictionary:
	return {
		"character_id": character_id,
		"display_name": display_name,
		"character_name": character_name,
		"class_id": class_id,
		"level": level,
		"xp": xp,
		"current_health": health,
		"current_resource": resource,
		"learned_attack_skills": learned_attack_skills.duplicate(),
	}

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			result.append(str(item))
	return result

func _add_unlocked_id(state: GameState, character_id: String) -> void:
	if not state.unlocked_character_ids.has(character_id):
		state.unlocked_character_ids.append(character_id)

func _sync_party_lists(state: GameState) -> void:
	for character_id: String in state.party_roster.keys():
		_add_unlocked_id(state, character_id)
	var active: Array[String] = []
	for character_id: String in state.active_party_ids:
		if state.party_roster.has(character_id) and not active.has(character_id) and active.size() < 3:
			active.append(character_id)
	state.active_party_ids = active
	state.reserve_character_ids = []
	for character_id: String in state.unlocked_character_ids:
		if state.party_roster.has(character_id) and not state.active_party_ids.has(character_id) and not state.reserve_character_ids.has(character_id):
			state.reserve_character_ids.append(character_id)
	if state.active_party_ids.is_empty():
		state.active_party_index = 0
	else:
		state.active_party_index = clampi(state.active_party_index, 0, state.active_party_ids.size() - 1)

func _apply_active_identity(state: GameState) -> void:
	var active_id := active_character_id(state)
	if active_id.is_empty():
		return
	var runtime := state.party_roster.get(active_id, {}) as Dictionary
	state.current_visible_character_id = active_id
	state.selected_starter_id = active_id
	state.player_name = str(runtime.get("character_name", state.player_name))
	state.selected_class = str(runtime.get("class_id", state.selected_class))
	state.learned_attack_skills = _string_array(runtime.get("learned_attack_skills", state.learned_attack_skills))
