extends SceneTree

const CLASS_PATHS := [
	"res://data/classes/warden.tres",
	"res://data/classes/gunslinger.tres",
	"res://data/classes/hexbinder.tres",
]

func _init() -> void:
	for path: String in CLASS_PATHS:
		var data := load(path)
		if data == null:
			_fail("Missing class data: " + path)
			return
		if data.class_id.is_empty() or data.display_name.is_empty():
			_fail("Class identity is incomplete: " + path)
			return
		if data.max_health <= 0 or data.base_attack <= 0:
			_fail("Class stats are invalid: " + path)
			return
		if data.sprite_options.size() < 1:
			_fail("Class needs at least one sprite option: " + path)
			return
		for sprite_path: String in data.sprite_options:
			if not ResourceLoader.exists(sprite_path):
				_fail("Class sprite option is missing: " + sprite_path)
				return
		if data.attack_skills.size() < 1:
			_fail("Class needs at least one attack skill: " + path)
			return
	print("PASS: class data")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
