extends RefCounted
class_name MapRegistry

const SWAMP_AREA_ID := "swamp_outskirts"
const CASTLE_AREA_ID := "castle_gate"

const AREAS := {
	SWAMP_AREA_ID: {
		"label": "Swamp Outskirts",
		"rooms": {
			"RoomStart": {
				"label": "Mire Gate",
				"adjacent": ["RoomMovement"],
			},
			"RoomMovement": {
				"label": "Sinking Steps",
				"adjacent": ["RoomStart", "RoomEnemy"],
			},
			"RoomEnemy": {
				"label": "Crawler Fen",
				"adjacent": ["RoomMovement", "RoomHazard"],
			},
			"RoomHazard": {
				"label": "Blight Pools",
				"adjacent": ["RoomEnemy", "RoomCheckpoint"],
			},
			"RoomCheckpoint": {
				"label": "Shrine Hollow",
				"adjacent": ["RoomHazard", "RoomUpgrade"],
			},
			"RoomUpgrade": {
				"label": "Relic Root",
				"adjacent": ["RoomCheckpoint", "RoomShortcut"],
			},
			"RoomShortcut": {
				"label": "Sunken Sluice",
				"adjacent": ["RoomUpgrade", "RoomMiniBoss", "RoomCheckpoint"],
			},
			"RoomMiniBoss": {
				"label": "Bogheart Nest",
				"adjacent": ["RoomShortcut"],
			},
		},
	},
	CASTLE_AREA_ID: {
		"label": "Castle Gate",
		"rooms": {
			"CastleGateStart": {
				"label": "Moonlit Causeway",
				"adjacent": ["CastleBattlements"],
			},
			"CastleBattlements": {
				"label": "Outer Battlements",
				"adjacent": ["CastleGateStart"],
			},
		},
	},
}

static func get_area_label(area_id: String) -> String:
	var area: Dictionary = AREAS.get(area_id, {})
	return str(area.get("label", _format_id(area_id)))

static func get_room_label(area_id: String, room_id: String) -> String:
	var room := _get_room(area_id, room_id)
	return str(room.get("label", _format_id(room_id)))

static func get_adjacent_rooms(area_id: String, room_id: String) -> Array[String]:
	var result: Array[String] = []
	var room := _get_room(area_id, room_id)
	var adjacent: Variant = room.get("adjacent", [])
	if adjacent is Array:
		for adjacent_room: Variant in adjacent:
			result.append(str(adjacent_room))
	return result

static func get_room_count(area_id: String) -> int:
	var area: Dictionary = AREAS.get(area_id, {})
	var rooms: Dictionary = area.get("rooms", {})
	return rooms.size()

static func _get_room(area_id: String, room_id: String) -> Dictionary:
	var area: Dictionary = AREAS.get(area_id, {})
	var rooms: Dictionary = area.get("rooms", {})
	return rooms.get(room_id, {})

static func _format_id(value: String) -> String:
	var words := value.replace("_", " ").split(" ", false)
	for index: int in words.size():
		words[index] = words[index].capitalize()
	return " ".join(words)
