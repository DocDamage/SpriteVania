extends SceneTree

const SCENE_PATHS := [
	"res://scenes/Main.tscn",
	"res://scenes/enemies/SwampCrawler.tscn",
	"res://scenes/enemies/SwampMiniBoss.tscn",
	"res://scenes/player/Player.tscn",
	"res://scenes/ui/CharacterSelect.tscn",
	"res://scenes/ui/HUD.tscn",
	"res://scenes/ui/PauseMenu.tscn",
	"res://scenes/ui/SettingsMenu.tscn",
	"res://scenes/ui/TitleScreen.tscn",
	"res://scenes/world/CheckpointShrine.tscn",
	"res://scenes/world/GameWorld.tscn",
	"res://scenes/world/UpgradePickup.tscn",
	"res://scenes/world/swamp_outskirts/RoomCheckpoint.tscn",
	"res://scenes/world/swamp_outskirts/RoomEnemy.tscn",
	"res://scenes/world/swamp_outskirts/RoomHazard.tscn",
	"res://scenes/world/swamp_outskirts/RoomMiniBoss.tscn",
	"res://scenes/world/swamp_outskirts/RoomMovement.tscn",
	"res://scenes/world/swamp_outskirts/RoomShortcut.tscn",
	"res://scenes/world/swamp_outskirts/RoomStart.tscn",
	"res://scenes/world/swamp_outskirts/RoomUpgrade.tscn",
]

func _init() -> void:
	for scene_path: String in SCENE_PATHS:
		_assert_scene_instantiates(scene_path)
	print("PASS: scene instantiation")
	quit(0)

func _assert_scene_instantiates(scene_path: String) -> void:
	var scene := load(scene_path) as PackedScene
	if scene == null:
		push_error(scene_path + " did not load as a PackedScene")
		quit(1)

	var instance := scene.instantiate()
	if instance == null:
		push_error(scene_path + " did not instantiate")
		quit(1)

	instance.free()
