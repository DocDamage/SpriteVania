# SpriteVania Vertical Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first playable Godot vertical slice: title flow, class/sprite selection, save/continue, XP leveling, checkpoint respawn, room enemy respawns, and a Swamp Outskirts prototype loop.

**Architecture:** Use Godot scenes for UI/world composition and small GDScript services/resources for state. Keep class behavior data-driven through `ClassData` resources and class-specific ability controllers so Warden, Gunslinger, and Hexbinder can diverge without one large player script.

**Tech Stack:** Godot 4.6, GDScript, Godot `Resource` data files, JSON save data under `user://`, headless GDScript verification scripts.

---

## File Structure

- Create `scripts/core/game_state.gd`: runtime save-state container and helper methods.
- Create `scripts/core/save_manager.gd`: save/load/delete current save and settings.
- Create `scripts/core/xp_curve.gd`: level thresholds and XP calculations.
- Create `scripts/data/class_data.gd`: `Resource` type for class stats, sprite choices, traversal unlocks, attack skills, and XP tuning.
- Create `data/classes/warden.tres`: Warden class data.
- Create `data/classes/gunslinger.tres`: Gunslinger class data.
- Create `data/classes/hexbinder.tres`: Hexbinder class data.
- Create `scripts/ui/main.gd`: root screen flow.
- Create `scenes/Main.tscn`: root scene.
- Create `scripts/ui/title_screen.gd`: title menu actions.
- Create `scenes/ui/TitleScreen.tscn`: New Game, Continue, Settings UI.
- Create `scripts/ui/character_select.gd`: class and sprite selection.
- Create `scenes/ui/CharacterSelect.tscn`: class/sprite selection UI.
- Create `scripts/ui/settings_menu.gd`: audio/display settings UI.
- Create `scenes/ui/SettingsMenu.tscn`: settings panel.
- Create `scripts/player/player.gd`: shared player body, stats, health/resources, XP, death, and class controller wiring.
- Create `scripts/player/player_class_controller.gd`: base class controller interface.
- Create `scripts/player/warden_controller.gd`: Warden movement/combat hooks.
- Create `scripts/player/gunslinger_controller.gd`: Gunslinger movement/combat hooks.
- Create `scripts/player/hexbinder_controller.gd`: Hexbinder movement/combat hooks.
- Create `scenes/player/Player.tscn`: shared player scene.
- Create `scripts/world/game_world.gd`: current run state, room loading, checkpoint respawn.
- Create `scenes/world/GameWorld.tscn`: world host scene.
- Create `scripts/world/room.gd`: room state, spawn points, room enter/exit lifecycle.
- Create `scripts/world/checkpoint_shrine.gd`: checkpoint activation and save interaction.
- Create `scenes/world/CheckpointShrine.tscn`: checkpoint shrine scene.
- Create `scripts/world/upgrade_pickup.gd`: traversal/attack skill pickup.
- Create `scenes/world/UpgradePickup.tscn`: pickup scene.
- Create `scripts/enemies/enemy.gd`: base enemy health, XP reward, death.
- Create `scripts/enemies/swamp_crawler.gd`: first normal enemy behavior.
- Create `scenes/enemies/SwampCrawler.tscn`: first normal enemy.
- Create `scripts/enemies/swamp_miniboss.gd`: first mini-boss behavior.
- Create `scenes/enemies/SwampMiniBoss.tscn`: first mini-boss.
- Create `scenes/world/swamp_outskirts/RoomStart.tscn`: safe start room.
- Create `scenes/world/swamp_outskirts/RoomMovement.tscn`: movement room.
- Create `scenes/world/swamp_outskirts/RoomEnemy.tscn`: enemy room.
- Create `scenes/world/swamp_outskirts/RoomHazard.tscn`: hazard room.
- Create `scenes/world/swamp_outskirts/RoomCheckpoint.tscn`: checkpoint room.
- Create `scenes/world/swamp_outskirts/RoomUpgrade.tscn`: first upgrade room.
- Create `scenes/world/swamp_outskirts/RoomShortcut.tscn`: return shortcut.
- Create `scenes/world/swamp_outskirts/RoomMiniBoss.tscn`: mini-boss room.
- Create `tests/test_save_manager.gd`: headless save/load verification.
- Create `tests/test_class_data.gd`: headless class data verification.
- Create `tests/test_xp_curve.gd`: headless XP/level verification.
- Create `tests/test_room_respawn.gd`: headless room respawn-state verification.
- Modify `project.godot`: set `application/run/main_scene`, add input actions, add SaveManager autoload if using autoload.

## Verification Commands

Use these commands from the project root:

```powershell
godot --headless --path . --script tests/test_class_data.gd
godot --headless --path . --script tests/test_xp_curve.gd
godot --headless --path . --script tests/test_save_manager.gd
godot --headless --path . --script tests/test_room_respawn.gd
```

Expected for each command: process exits with code `0` and prints a `PASS:` line.

---

### Task 1: Project Bootstrap And Inputs

**Files:**
- Modify: `project.godot`
- Create: `scenes/Main.tscn`
- Create: `scripts/ui/main.gd`

- [ ] **Step 1: Add the root scene script**

Create `scripts/ui/main.gd`:

```gdscript
extends Control
class_name Main

const TITLE_SCREEN := preload("res://scenes/ui/TitleScreen.tscn")
const CHARACTER_SELECT := preload("res://scenes/ui/CharacterSelect.tscn")
const SETTINGS_MENU := preload("res://scenes/ui/SettingsMenu.tscn")
const GAME_WORLD := preload("res://scenes/world/GameWorld.tscn")

var current_screen: Node

func _ready() -> void:
	show_title()

func _replace_screen(scene: PackedScene) -> Node:
	if current_screen:
		current_screen.queue_free()
	current_screen = scene.instantiate()
	add_child(current_screen)
	return current_screen

func show_title() -> void:
	var title := _replace_screen(TITLE_SCREEN)
	title.new_game_requested.connect(show_character_select)
	title.continue_requested.connect(_continue_game)
	title.settings_requested.connect(show_settings)

func show_character_select() -> void:
	var select := _replace_screen(CHARACTER_SELECT)
	select.cancel_requested.connect(show_title)
	select.character_confirmed.connect(_start_new_game)

func show_settings() -> void:
	var settings := _replace_screen(SETTINGS_MENU)
	settings.closed.connect(show_title)

func _start_new_game(class_id: String, sprite_id: String) -> void:
	var world := _replace_screen(GAME_WORLD)
	world.start_new_game(class_id, sprite_id)

func _continue_game() -> void:
	var world := _replace_screen(GAME_WORLD)
	world.continue_game()
```

- [ ] **Step 2: Create `scenes/Main.tscn`**

Create a `Control` root named `Main`, attach `res://scripts/ui/main.gd`, set anchors to full rect, and save as `scenes/Main.tscn`.

- [ ] **Step 3: Set project main scene and input actions**

Use Godot Project Settings or a short editor script to set:

```gdscript
ProjectSettings.set_setting("application/run/main_scene", "res://scenes/Main.tscn")
```

Add these input actions with keyboard defaults:

```text
move_left: A, Left
move_right: D, Right
jump: Space
attack: J
special_attack: K
class_action: L
interact: E
pause: Escape
```

- [ ] **Step 4: Run project parse check**

Run:

```powershell
godot --headless --path . --quit
```

Expected: exits with code `0`.

- [ ] **Step 5: Commit**

```powershell
git add project.godot scenes/Main.tscn scripts/ui/main.gd
git commit -m "feat: add root scene and inputs"
```

---

### Task 2: Class Data Resources

**Files:**
- Create: `scripts/data/class_data.gd`
- Create: `data/classes/warden.tres`
- Create: `data/classes/gunslinger.tres`
- Create: `data/classes/hexbinder.tres`
- Create: `tests/test_class_data.gd`

- [ ] **Step 1: Write the failing class-data test**

Create `tests/test_class_data.gd`:

```gdscript
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
			push_error("Missing class data: " + path)
			quit(1)
			return
		if data.class_id.is_empty() or data.display_name.is_empty():
			push_error("Class identity is incomplete: " + path)
			quit(1)
			return
		if data.max_health <= 0 or data.base_attack <= 0:
			push_error("Class stats are invalid: " + path)
			quit(1)
			return
		if data.sprite_options.size() < 1:
			push_error("Class needs at least one sprite option: " + path)
			quit(1)
			return
		if data.attack_skills.size() < 1:
			push_error("Class needs at least one attack skill: " + path)
			quit(1)
			return
	print("PASS: class data")
	quit(0)
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
godot --headless --path . --script tests/test_class_data.gd
```

Expected: FAIL because the class resources do not exist yet.

- [ ] **Step 3: Create `ClassData` resource type**

Create `scripts/data/class_data.gd`:

```gdscript
extends Resource
class_name ClassData

@export var class_id: String
@export var display_name: String
@export_multiline var description: String
@export var max_health: int = 100
@export var max_resource: int = 50
@export var base_attack: int = 10
@export var base_defense: int = 0
@export var move_speed: float = 160.0
@export var jump_velocity: float = -360.0
@export var controller_script: Script
@export var sprite_options: Array[String] = []
@export var traversal_unlocks: Array[String] = []
@export var attack_skills: Array[String] = []
@export var xp_curve: Array[int] = [0, 100, 250, 450, 700]
```

- [ ] **Step 4: Create the three class resources**

Create `data/classes/warden.tres` as a `ClassData` resource with:

```text
class_id = "warden"
display_name = "Warden"
max_health = 140
max_resource = 40
base_attack = 14
base_defense = 6
move_speed = 135.0
jump_velocity = -335.0
sprite_options = ["res://SpriteVania Assets/player/Knight/Knight_A.png", "res://SpriteVania Assets/player/Knight/Knight_B.png"]
traversal_unlocks = ["armored_dash", "shield_bash", "wall_brace"]
attack_skills = ["guard_counter", "ground_slam", "shield_throw", "charged_cleave"]
xp_curve = [0, 100, 250, 450, 700]
```

Create `data/classes/gunslinger.tres` with:

```text
class_id = "gunslinger"
display_name = "Gunslinger"
max_health = 100
max_resource = 60
base_attack = 11
base_defense = 2
move_speed = 175.0
jump_velocity = -370.0
sprite_options = ["res://SpriteVania Assets/player/Boy/Boy_Adventure A.png", "res://SpriteVania Assets/player/Boy/Boy_Adventure B.png"]
traversal_unlocks = ["hookshot", "combat_slide", "recoil_jump"]
attack_skills = ["piercing_shot", "ricochet_shot", "fan_fire", "explosive_round"]
xp_curve = [0, 100, 250, 450, 700]
```

Create `data/classes/hexbinder.tres` with:

```text
class_id = "hexbinder"
display_name = "Hexbinder"
max_health = 85
max_resource = 100
base_attack = 12
base_defense = 1
move_speed = 155.0
jump_velocity = -350.0
sprite_options = ["res://SpriteVania Assets/player/magic_cliffs_player/Sprites/idle/idle-1.png"]
traversal_unlocks = ["blink", "float_fall", "phase_barrier"]
attack_skills = ["curse_bolt", "binding_sigil", "hex_mine", "void_lance"]
xp_curve = [0, 100, 250, 450, 700]
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```powershell
godot --headless --path . --script tests/test_class_data.gd
```

Expected: `PASS: class data`.

- [ ] **Step 6: Commit**

```powershell
git add scripts/data/class_data.gd data/classes tests/test_class_data.gd
git commit -m "feat: add class data resources"
```

---

### Task 3: XP And Leveling Core

**Files:**
- Create: `scripts/core/xp_curve.gd`
- Create: `tests/test_xp_curve.gd`

- [ ] **Step 1: Write the failing XP test**

Create `tests/test_xp_curve.gd`:

```gdscript
extends SceneTree

const XPCurve := preload("res://scripts/core/xp_curve.gd")

func _init() -> void:
	var curve := XPCurve.new()
	curve.thresholds = [0, 100, 250, 450]
	if curve.level_for_xp(0) != 1:
		push_error("0 XP should be level 1")
		quit(1)
		return
	if curve.level_for_xp(100) != 2:
		push_error("100 XP should be level 2")
		quit(1)
		return
	if curve.level_for_xp(449) != 3:
		push_error("449 XP should be level 3")
		quit(1)
		return
	if curve.xp_to_next_level(250) != 200:
		push_error("250 XP should need 200 XP to next level")
		quit(1)
		return
	print("PASS: xp curve")
	quit(0)
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
godot --headless --path . --script tests/test_xp_curve.gd
```

Expected: FAIL because `scripts/core/xp_curve.gd` does not exist.

- [ ] **Step 3: Create XP curve implementation**

Create `scripts/core/xp_curve.gd`:

```gdscript
extends Resource
class_name XPCurve

@export var thresholds: Array[int] = [0, 100, 250, 450, 700]

func level_for_xp(xp: int) -> int:
	var level := 1
	for index: int in thresholds.size():
		if xp >= thresholds[index]:
			level = index + 1
	return level

func xp_to_next_level(xp: int) -> int:
	var current_level := level_for_xp(xp)
	if current_level >= thresholds.size():
		return 0
	return max(0, thresholds[current_level] - xp)
```

- [ ] **Step 4: Run test to verify it passes**

Run:

```powershell
godot --headless --path . --script tests/test_xp_curve.gd
```

Expected: `PASS: xp curve`.

- [ ] **Step 5: Commit**

```powershell
git add scripts/core/xp_curve.gd tests/test_xp_curve.gd
git commit -m "feat: add xp leveling core"
```

---

### Task 4: Save State And Save Manager

**Files:**
- Create: `scripts/core/game_state.gd`
- Create: `scripts/core/save_manager.gd`
- Create: `tests/test_save_manager.gd`
- Modify: `project.godot` if using autoload

- [ ] **Step 1: Write the failing save/load test**

Create `tests/test_save_manager.gd`:

```gdscript
extends SceneTree

const GameState := preload("res://scripts/core/game_state.gd")
const SaveManager := preload("res://scripts/core/save_manager.gd")

func _init() -> void:
	var manager := SaveManager.new()
	manager.save_path = "user://test_spritevania_save.json"
	manager.delete_save()

	var state := GameState.new()
	state.selected_class = "warden"
	state.selected_sprite = "res://SpriteVania Assets/player/Knight/Knight_A.png"
	state.current_area = "swamp_outskirts"
	state.current_room = "RoomCheckpoint"
	state.checkpoint_id = "swamp_shrine_01"
	state.level = 3
	state.xp = 260
	state.learned_attack_skills = ["guard_counter"]
	state.traversal_unlocks = ["armored_dash"]
	state.opened_shortcuts = ["swamp_shortcut_01"]

	if not manager.save_game(state):
		push_error("Save failed")
		quit(1)
		return

	var loaded := manager.load_game()
	if loaded == null:
		push_error("Load returned null")
		quit(1)
		return
	if loaded.selected_class != "warden" or loaded.level != 3:
		push_error("Loaded state does not match saved state")
		quit(1)
		return
	if not loaded.opened_shortcuts.has("swamp_shortcut_01"):
		push_error("Opened shortcut did not persist")
		quit(1)
		return

	manager.delete_save()
	print("PASS: save manager")
	quit(0)
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
godot --headless --path . --script tests/test_save_manager.gd
```

Expected: FAIL because `GameState` and `SaveManager` do not exist.

- [ ] **Step 3: Create `GameState`**

Create `scripts/core/game_state.gd`:

```gdscript
extends RefCounted
class_name GameState

var selected_class: String = ""
var selected_sprite: String = ""
var current_area: String = "swamp_outskirts"
var current_room: String = "RoomStart"
var checkpoint_id: String = ""
var checkpoint_position: Vector2 = Vector2.ZERO
var level: int = 1
var xp: int = 0
var skill_points: int = 0
var current_health: int = 100
var current_resource: int = 50
var learned_attack_skills: Array[String] = []
var traversal_unlocks: Array[String] = []
var defeated_bosses: Array[String] = []
var opened_shortcuts: Array[String] = []
var collected_pickups: Array[String] = []
var settings: Dictionary = {"master_volume": 1.0, "window_mode": "windowed"}

func to_dictionary() -> Dictionary:
	return {
		"selected_class": selected_class,
		"selected_sprite": selected_sprite,
		"current_area": current_area,
		"current_room": current_room,
		"checkpoint_id": checkpoint_id,
		"checkpoint_position": {"x": checkpoint_position.x, "y": checkpoint_position.y},
		"level": level,
		"xp": xp,
		"skill_points": skill_points,
		"current_health": current_health,
		"current_resource": current_resource,
		"learned_attack_skills": learned_attack_skills,
		"traversal_unlocks": traversal_unlocks,
		"defeated_bosses": defeated_bosses,
		"opened_shortcuts": opened_shortcuts,
		"collected_pickups": collected_pickups,
		"settings": settings,
	}

static func from_dictionary(data: Dictionary) -> GameState:
	var state := GameState.new()
	state.selected_class = data.get("selected_class", "")
	state.selected_sprite = data.get("selected_sprite", "")
	state.current_area = data.get("current_area", "swamp_outskirts")
	state.current_room = data.get("current_room", "RoomStart")
	state.checkpoint_id = data.get("checkpoint_id", "")
	var pos: Dictionary = data.get("checkpoint_position", {"x": 0.0, "y": 0.0})
	state.checkpoint_position = Vector2(float(pos.get("x", 0.0)), float(pos.get("y", 0.0)))
	state.level = int(data.get("level", 1))
	state.xp = int(data.get("xp", 0))
	state.skill_points = int(data.get("skill_points", 0))
	state.current_health = int(data.get("current_health", 100))
	state.current_resource = int(data.get("current_resource", 50))
	state.learned_attack_skills.assign(data.get("learned_attack_skills", []))
	state.traversal_unlocks.assign(data.get("traversal_unlocks", []))
	state.defeated_bosses.assign(data.get("defeated_bosses", []))
	state.opened_shortcuts.assign(data.get("opened_shortcuts", []))
	state.collected_pickups.assign(data.get("collected_pickups", []))
	state.settings = data.get("settings", {"master_volume": 1.0, "window_mode": "windowed"})
	return state
```

- [ ] **Step 4: Create `SaveManager`**

Create `scripts/core/save_manager.gd`:

```gdscript
extends Node
class_name SaveManager

const GameState := preload("res://scripts/core/game_state.gd")

@export var save_path: String = "user://spritevania_save.json"

func has_save() -> bool:
	return FileAccess.file_exists(save_path)

func save_game(state: GameState) -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(state.to_dictionary()))
	return true

func load_game() -> GameState:
	if not has_save():
		return null
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	return GameState.from_dictionary(parsed)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
```

- [ ] **Step 5: Run test to verify it passes**

Run:

```powershell
godot --headless --path . --script tests/test_save_manager.gd
```

Expected: `PASS: save manager`.

- [ ] **Step 6: Add autoload**

In Godot Project Settings, add autoload:

```text
Name: SaveManager
Path: res://scripts/core/save_manager.gd
```

Expected `project.godot` includes:

```text
[autoload]
SaveManager="*res://scripts/core/save_manager.gd"
```

- [ ] **Step 7: Commit**

```powershell
git add project.godot scripts/core/game_state.gd scripts/core/save_manager.gd tests/test_save_manager.gd
git commit -m "feat: add save manager"
```

---

### Task 5: Title, Settings, And Character Selection UI

**Files:**
- Create: `scripts/ui/title_screen.gd`
- Create: `scenes/ui/TitleScreen.tscn`
- Create: `scripts/ui/settings_menu.gd`
- Create: `scenes/ui/SettingsMenu.tscn`
- Create: `scripts/ui/character_select.gd`
- Create: `scenes/ui/CharacterSelect.tscn`

- [ ] **Step 1: Create title screen script**

Create `scripts/ui/title_screen.gd`:

```gdscript
extends Control
class_name TitleScreen

signal new_game_requested
signal continue_requested
signal settings_requested

@onready var continue_button: Button = %ContinueButton

func _ready() -> void:
	%NewGameButton.pressed.connect(func() -> void: new_game_requested.emit())
	continue_button.pressed.connect(func() -> void: continue_requested.emit())
	%SettingsButton.pressed.connect(func() -> void: settings_requested.emit())
	if SaveManager:
		continue_button.disabled = not SaveManager.has_save()
```

- [ ] **Step 2: Create title screen scene**

Create `scenes/ui/TitleScreen.tscn` as a `Control` with:

```text
TitleScreen (Control, script title_screen.gd)
  CenterContainer
    VBoxContainer
      TitleLabel (Label, text "SpriteVania")
      NewGameButton (Button, unique_name_in_owner true, text "New Game")
      ContinueButton (Button, unique_name_in_owner true, text "Continue")
      SettingsButton (Button, unique_name_in_owner true, text "Settings")
```

- [ ] **Step 3: Create settings script**

Create `scripts/ui/settings_menu.gd`:

```gdscript
extends Control
class_name SettingsMenu

signal closed

func _ready() -> void:
	%BackButton.pressed.connect(func() -> void: closed.emit())
	%VolumeSlider.value_changed.connect(_on_volume_changed)
	%WindowModeButton.toggled.connect(_on_window_mode_toggled)

func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_window_mode_toggled(fullscreen: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
```

- [ ] **Step 4: Create settings scene**

Create `scenes/ui/SettingsMenu.tscn` as a `Control` with:

```text
SettingsMenu (Control, script settings_menu.gd)
  CenterContainer
    VBoxContainer
      HeaderLabel (Label, text "Settings")
      VolumeSlider (HSlider, unique_name_in_owner true, min 0.0, max 1.0, step 0.05, value 1.0)
      WindowModeButton (CheckButton, unique_name_in_owner true, text "Fullscreen")
      BackButton (Button, unique_name_in_owner true, text "Back")
```

- [ ] **Step 5: Create character selection script**

Create `scripts/ui/character_select.gd`:

```gdscript
extends Control
class_name CharacterSelect

signal character_confirmed(class_id: String, sprite_id: String)
signal cancel_requested

const CLASS_DATA := [
	preload("res://data/classes/warden.tres"),
	preload("res://data/classes/gunslinger.tres"),
	preload("res://data/classes/hexbinder.tres"),
]

var selected_class_index := 0
var selected_sprite_index := 0

func _ready() -> void:
	%ClassOption.item_selected.connect(_on_class_selected)
	%SpriteOption.item_selected.connect(_on_sprite_selected)
	%ConfirmButton.pressed.connect(_confirm)
	%BackButton.pressed.connect(func() -> void: cancel_requested.emit())
	for data: ClassData in CLASS_DATA:
		%ClassOption.add_item(data.display_name)
	_refresh_sprite_options()

func _on_class_selected(index: int) -> void:
	selected_class_index = index
	selected_sprite_index = 0
	_refresh_sprite_options()

func _on_sprite_selected(index: int) -> void:
	selected_sprite_index = index

func _refresh_sprite_options() -> void:
	var data: ClassData = CLASS_DATA[selected_class_index]
	%DescriptionLabel.text = data.description
	%SpriteOption.clear()
	for sprite_path: String in data.sprite_options:
		%SpriteOption.add_item(sprite_path.get_file())

func _confirm() -> void:
	var data: ClassData = CLASS_DATA[selected_class_index]
	character_confirmed.emit(data.class_id, data.sprite_options[selected_sprite_index])
```

- [ ] **Step 6: Create character selection scene**

Create `scenes/ui/CharacterSelect.tscn` as a `Control` with:

```text
CharacterSelect (Control, script character_select.gd)
  CenterContainer
    VBoxContainer
      HeaderLabel (Label, text "Choose Character")
      ClassOption (OptionButton, unique_name_in_owner true)
      SpriteOption (OptionButton, unique_name_in_owner true)
      DescriptionLabel (Label, unique_name_in_owner true, autowrap enabled)
      ConfirmButton (Button, unique_name_in_owner true, text "Begin")
      BackButton (Button, unique_name_in_owner true, text "Back")
```

- [ ] **Step 7: Run scene parse check**

Run:

```powershell
godot --headless --path . --quit
```

Expected: exits with code `0`.

- [ ] **Step 8: Commit**

```powershell
git add scenes/ui scripts/ui
git commit -m "feat: add title and character selection flow"
```

---

### Task 6: Player Scene And Class Controllers

**Files:**
- Create: `scripts/player/player_class_controller.gd`
- Create: `scripts/player/warden_controller.gd`
- Create: `scripts/player/gunslinger_controller.gd`
- Create: `scripts/player/hexbinder_controller.gd`
- Create: `scripts/player/player.gd`
- Create: `scenes/player/Player.tscn`
- Modify: `data/classes/*.tres`

- [ ] **Step 1: Create class controller base**

Create `scripts/player/player_class_controller.gd`:

```gdscript
extends Node
class_name PlayerClassController

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
```

- [ ] **Step 2: Create Warden controller**

Create `scripts/player/warden_controller.gd`:

```gdscript
extends PlayerClassController
class_name WardenController

func handle_attack() -> void:
	player.perform_melee_attack(class_data.base_attack)

func handle_special_attack() -> void:
	player.perform_guard_counter()

func handle_class_action() -> void:
	player.start_blocking()
```

- [ ] **Step 3: Create Gunslinger controller**

Create `scripts/player/gunslinger_controller.gd`:

```gdscript
extends PlayerClassController
class_name GunslingerController

func handle_attack() -> void:
	player.fire_projectile(class_data.base_attack)

func handle_special_attack() -> void:
	player.fire_piercing_shot(class_data.base_attack * 2)

func handle_class_action() -> void:
	player.perform_slide()
```

- [ ] **Step 4: Create Hexbinder controller**

Create `scripts/player/hexbinder_controller.gd`:

```gdscript
extends PlayerClassController
class_name HexbinderController

func handle_attack() -> void:
	player.fire_spell(class_data.base_attack)

func handle_special_attack() -> void:
	player.cast_binding_sigil()

func handle_class_action() -> void:
	player.perform_blink()
```

- [ ] **Step 5: Create shared player script**

Create `scripts/player/player.gd` with movement, health, XP, and controller dispatch. Include methods named by the class controllers:

```gdscript
extends CharacterBody2D
class_name Player

signal died
signal leveled_up(new_level: int)

const GRAVITY := 980.0
const XPCurve := preload("res://scripts/core/xp_curve.gd")

@onready var sprite: Sprite2D = %Sprite2D

var class_data: ClassData
var class_controller: PlayerClassController
var xp_curve := XPCurve.new()
var current_health := 100
var current_resource := 50
var xp := 0
var level := 1

func setup(data: ClassData, sprite_path: String) -> void:
	class_data = data
	xp_curve.thresholds = data.xp_curve
	current_health = data.max_health
	current_resource = data.max_resource
	var texture := load(sprite_path)
	if texture:
		sprite.texture = texture
	class_controller = data.controller_script.new()
	add_child(class_controller)
	class_controller.setup(self, data)

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * class_data.move_speed
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = class_data.jump_velocity
	move_and_slide()
	if Input.is_action_just_pressed("attack"):
		class_controller.handle_attack()
	if Input.is_action_just_pressed("special_attack"):
		class_controller.handle_special_attack()
	if Input.is_action_just_pressed("class_action"):
		class_controller.handle_class_action()

func gain_xp(amount: int) -> void:
	xp += amount
	var next_level := xp_curve.level_for_xp(xp)
	if next_level > level:
		level = next_level
		current_health = class_data.max_health + ((level - 1) * 10)
		leveled_up.emit(level)

func take_damage(amount: int) -> void:
	current_health -= max(1, amount - class_data.base_defense)
	if current_health <= 0:
		died.emit()

func perform_melee_attack(_damage: int) -> void:
	pass

func perform_guard_counter() -> void:
	pass

func start_blocking() -> void:
	pass

func fire_projectile(_damage: int) -> void:
	pass

func fire_piercing_shot(_damage: int) -> void:
	pass

func perform_slide() -> void:
	pass

func fire_spell(_damage: int) -> void:
	pass

func cast_binding_sigil() -> void:
	pass

func perform_blink() -> void:
	position.x += 48.0 * signf(velocity.x if velocity.x != 0 else 1.0)
```

- [ ] **Step 6: Create player scene**

Create `scenes/player/Player.tscn`:

```text
Player (CharacterBody2D, script player.gd)
  CollisionShape2D
  Sprite2D (unique_name_in_owner true)
  Camera2D
```

Set `CollisionShape2D.shape` to a rectangle roughly `16x28`.

- [ ] **Step 7: Assign controller scripts in class resources**

Set:

```text
warden.controller_script = res://scripts/player/warden_controller.gd
gunslinger.controller_script = res://scripts/player/gunslinger_controller.gd
hexbinder.controller_script = res://scripts/player/hexbinder_controller.gd
```

- [ ] **Step 8: Run class data test**

Run:

```powershell
godot --headless --path . --script tests/test_class_data.gd
```

Expected: `PASS: class data`.

- [ ] **Step 9: Commit**

```powershell
git add scripts/player scenes/player data/classes
git commit -m "feat: add player class controllers"
```

---

### Task 7: World Host, Rooms, Checkpoints, And Respawn

**Files:**
- Create: `scripts/world/game_world.gd`
- Create: `scenes/world/GameWorld.tscn`
- Create: `scripts/world/room.gd`
- Create: `scripts/world/checkpoint_shrine.gd`
- Create: `scenes/world/CheckpointShrine.tscn`
- Create: `tests/test_room_respawn.gd`

- [ ] **Step 1: Write room respawn test**

Create `tests/test_room_respawn.gd`:

```gdscript
extends SceneTree

const Room := preload("res://scripts/world/room.gd")

func _init() -> void:
	var room := Room.new()
	room.enemy_spawn_ids = ["crawler_a", "crawler_b"]
	room.mark_enemy_defeated("crawler_a")
	if not room.defeated_enemy_ids.has("crawler_a"):
		push_error("Enemy defeat was not tracked")
		quit(1)
		return
	room.reset_temporary_state_for_reentry()
	if room.defeated_enemy_ids.size() != 0:
		push_error("Normal enemies should reset on room re-entry")
		quit(1)
		return
	room.defeated_persistent_ids = ["miniboss"]
	room.reset_temporary_state_for_reentry()
	if not room.defeated_persistent_ids.has("miniboss"):
		push_error("Persistent defeated state should not reset")
		quit(1)
		return
	print("PASS: room respawn")
	quit(0)
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```powershell
godot --headless --path . --script tests/test_room_respawn.gd
```

Expected: FAIL because `room.gd` does not exist.

- [ ] **Step 3: Create room script**

Create `scripts/world/room.gd`:

```gdscript
extends Node2D
class_name Room

@export var room_id: String = ""
@export var next_rooms: Dictionary = {}
@export var enemy_spawn_ids: Array[String] = []

var defeated_enemy_ids: Array[String] = []
var defeated_persistent_ids: Array[String] = []

func enter_room() -> void:
	reset_temporary_state_for_reentry()

func mark_enemy_defeated(enemy_id: String) -> void:
	if not defeated_enemy_ids.has(enemy_id):
		defeated_enemy_ids.append(enemy_id)

func mark_persistent_defeated(entity_id: String) -> void:
	if not defeated_persistent_ids.has(entity_id):
		defeated_persistent_ids.append(entity_id)

func reset_temporary_state_for_reentry() -> void:
	defeated_enemy_ids.clear()
```

- [ ] **Step 4: Create checkpoint shrine script**

Create `scripts/world/checkpoint_shrine.gd`:

```gdscript
extends Area2D
class_name CheckpointShrine

signal checkpoint_activated(checkpoint_id: String, checkpoint_position: Vector2)

@export var checkpoint_id: String = "checkpoint"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		checkpoint_activated.emit(checkpoint_id, global_position)
```

- [ ] **Step 5: Create checkpoint scene**

Create `scenes/world/CheckpointShrine.tscn`:

```text
CheckpointShrine (Area2D, script checkpoint_shrine.gd)
  CollisionShape2D
  Sprite2D
```

- [ ] **Step 6: Create world host script**

Create `scripts/world/game_world.gd` with `start_new_game`, `continue_game`, checkpoint handling, player spawning, death handling, and save calls:

```gdscript
extends Node2D
class_name GameWorld

const GameState := preload("res://scripts/core/game_state.gd")
const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const CLASS_DATA := {
	"warden": preload("res://data/classes/warden.tres"),
	"gunslinger": preload("res://data/classes/gunslinger.tres"),
	"hexbinder": preload("res://data/classes/hexbinder.tres"),
}

var state: GameState
var player: Player

func start_new_game(class_id: String, sprite_id: String) -> void:
	state = GameState.new()
	state.selected_class = class_id
	state.selected_sprite = sprite_id
	state.current_area = "swamp_outskirts"
	state.current_room = "RoomStart"
	_spawn_player(Vector2(64, 64))

func continue_game() -> void:
	state = SaveManager.load_game()
	if state == null:
		state = GameState.new()
	_spawn_player(state.checkpoint_position if state.checkpoint_position != Vector2.ZERO else Vector2(64, 64))

func _spawn_player(spawn_position: Vector2) -> void:
	if player:
		player.queue_free()
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = spawn_position
	player.setup(CLASS_DATA[state.selected_class], state.selected_sprite)
	player.died.connect(_on_player_died)

func activate_checkpoint(checkpoint_id: String, checkpoint_position: Vector2) -> void:
	state.checkpoint_id = checkpoint_id
	state.checkpoint_position = checkpoint_position
	state.current_health = player.current_health
	state.current_resource = player.current_resource
	state.level = player.level
	state.xp = player.xp
	SaveManager.save_game(state)

func _on_player_died() -> void:
	_spawn_player(state.checkpoint_position if state.checkpoint_position != Vector2.ZERO else Vector2(64, 64))
```

- [ ] **Step 7: Create world scene**

Create `scenes/world/GameWorld.tscn`:

```text
GameWorld (Node2D, script game_world.gd)
  Rooms (Node2D)
  PlayerSpawn (Marker2D)
```

- [ ] **Step 8: Run room respawn test**

Run:

```powershell
godot --headless --path . --script tests/test_room_respawn.gd
```

Expected: `PASS: room respawn`.

- [ ] **Step 9: Commit**

```powershell
git add scripts/world scenes/world tests/test_room_respawn.gd
git commit -m "feat: add world rooms and checkpoints"
```

---

### Task 8: Enemies, XP Rewards, And Mini-Boss Foundation

**Files:**
- Create: `scripts/enemies/enemy.gd`
- Create: `scripts/enemies/swamp_crawler.gd`
- Create: `scenes/enemies/SwampCrawler.tscn`
- Create: `scripts/enemies/swamp_miniboss.gd`
- Create: `scenes/enemies/SwampMiniBoss.tscn`

- [ ] **Step 1: Create base enemy**

Create `scripts/enemies/enemy.gd`:

```gdscript
extends CharacterBody2D
class_name Enemy

signal died(enemy_id: String, xp_reward: int)

@export var enemy_id: String = ""
@export var max_health: int = 30
@export var damage: int = 10
@export var xp_reward: int = 25

var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		died.emit(enemy_id, xp_reward)
		queue_free()
```

- [ ] **Step 2: Create swamp crawler script**

Create `scripts/enemies/swamp_crawler.gd`:

```gdscript
extends Enemy
class_name SwampCrawler

@export var patrol_speed: float = 45.0
var direction := -1.0

func _physics_process(_delta: float) -> void:
	velocity.x = direction * patrol_speed
	move_and_slide()
```

- [ ] **Step 3: Create swamp crawler scene**

Create `scenes/enemies/SwampCrawler.tscn`:

```text
SwampCrawler (CharacterBody2D, script swamp_crawler.gd)
  CollisionShape2D
  Sprite2D
```

Set defaults:

```text
enemy_id = "swamp_crawler"
max_health = 30
damage = 10
xp_reward = 25
```

- [ ] **Step 4: Create mini-boss script**

Create `scripts/enemies/swamp_miniboss.gd`:

```gdscript
extends Enemy
class_name SwampMiniBoss

@export var leap_cooldown: float = 2.0
var cooldown_remaining := 0.0

func _ready() -> void:
	super()
	xp_reward = 150

func _physics_process(delta: float) -> void:
	cooldown_remaining -= delta
	if cooldown_remaining <= 0.0:
		velocity.y = -260.0
		velocity.x = 120.0 * signf(randf() - 0.5)
		cooldown_remaining = leap_cooldown
	velocity.y += 700.0 * delta
	move_and_slide()
```

- [ ] **Step 5: Create mini-boss scene**

Create `scenes/enemies/SwampMiniBoss.tscn`:

```text
SwampMiniBoss (CharacterBody2D, script swamp_miniboss.gd)
  CollisionShape2D
  Sprite2D
```

Set defaults:

```text
enemy_id = "swamp_miniboss"
max_health = 180
damage = 18
xp_reward = 150
```

- [ ] **Step 6: Wire enemy death to player XP in room/world code**

In `scripts/world/game_world.gd`, add a method:

```gdscript
func register_enemy(enemy: Enemy) -> void:
	enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy_id: String, xp_reward: int) -> void:
	if player:
		player.gain_xp(xp_reward)
```

- [ ] **Step 7: Run parse check**

Run:

```powershell
godot --headless --path . --quit
```

Expected: exits with code `0`.

- [ ] **Step 8: Commit**

```powershell
git add scripts/enemies scenes/enemies scripts/world/game_world.gd
git commit -m "feat: add swamp enemies and xp rewards"
```

---

### Task 9: Upgrade Pickup And Persistent Progress

**Files:**
- Create: `scripts/world/upgrade_pickup.gd`
- Create: `scenes/world/UpgradePickup.tscn`
- Modify: `scripts/world/game_world.gd`
- Modify: `scripts/core/game_state.gd`

- [ ] **Step 1: Create upgrade pickup script**

Create `scripts/world/upgrade_pickup.gd`:

```gdscript
extends Area2D
class_name UpgradePickup

signal upgrade_collected(pickup_id: String, upgrade_id: String, upgrade_type: String)

@export var pickup_id: String = ""
@export var upgrade_id: String = ""
@export_enum("traversal", "attack_skill", "optional") var upgrade_type: String = "traversal"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		upgrade_collected.emit(pickup_id, upgrade_id, upgrade_type)
		queue_free()
```

- [ ] **Step 2: Create pickup scene**

Create `scenes/world/UpgradePickup.tscn`:

```text
UpgradePickup (Area2D, script upgrade_pickup.gd)
  CollisionShape2D
  Sprite2D
```

- [ ] **Step 3: Add persistent pickup handling**

In `scripts/world/game_world.gd`, add:

```gdscript
func register_upgrade_pickup(pickup: UpgradePickup) -> void:
	if state.collected_pickups.has(pickup.pickup_id):
		pickup.queue_free()
		return
	pickup.upgrade_collected.connect(_on_upgrade_collected)

func _on_upgrade_collected(pickup_id: String, upgrade_id: String, upgrade_type: String) -> void:
	if not state.collected_pickups.has(pickup_id):
		state.collected_pickups.append(pickup_id)
	if upgrade_type == "traversal" and not state.traversal_unlocks.has(upgrade_id):
		state.traversal_unlocks.append(upgrade_id)
	if upgrade_type == "attack_skill" and not state.learned_attack_skills.has(upgrade_id):
		state.learned_attack_skills.append(upgrade_id)
	SaveManager.save_game(state)
```

- [ ] **Step 4: Run save manager test**

Run:

```powershell
godot --headless --path . --script tests/test_save_manager.gd
```

Expected: `PASS: save manager`.

- [ ] **Step 5: Commit**

```powershell
git add scripts/world/upgrade_pickup.gd scenes/world/UpgradePickup.tscn scripts/world/game_world.gd scripts/core/game_state.gd
git commit -m "feat: add persistent upgrade pickups"
```

---

### Task 10: Swamp Outskirts Greybox Rooms

**Files:**
- Create: `scenes/world/swamp_outskirts/RoomStart.tscn`
- Create: `scenes/world/swamp_outskirts/RoomMovement.tscn`
- Create: `scenes/world/swamp_outskirts/RoomEnemy.tscn`
- Create: `scenes/world/swamp_outskirts/RoomHazard.tscn`
- Create: `scenes/world/swamp_outskirts/RoomCheckpoint.tscn`
- Create: `scenes/world/swamp_outskirts/RoomUpgrade.tscn`
- Create: `scenes/world/swamp_outskirts/RoomShortcut.tscn`
- Create: `scenes/world/swamp_outskirts/RoomMiniBoss.tscn`
- Modify: `scripts/world/game_world.gd`

- [ ] **Step 1: Create room scene pattern**

Each room scene should use this node pattern:

```text
RoomName (Node2D, script room.gd)
  Ground (StaticBody2D)
    CollisionShape2D
    Sprite2D or Polygon2D
  Entrances (Node2D)
    LeftEntrance (Area2D)
    RightEntrance (Area2D)
  EnemySpawns (Node2D)
  Pickups (Node2D)
```

Set each root `room_id` to its file name without extension.

- [ ] **Step 2: Create the safe start room**

Create `RoomStart.tscn` with a flat platform, a `Marker2D` named `PlayerStart`, and a right exit to `RoomMovement`.

- [ ] **Step 3: Create movement room**

Create `RoomMovement.tscn` with basic jumps and platforms. It should have left exit to `RoomStart` and right exit to `RoomEnemy`.

- [ ] **Step 4: Create enemy room**

Create `RoomEnemy.tscn` with two `SwampCrawler` instances. It should have left exit to `RoomMovement` and right exit to `RoomHazard`.

- [ ] **Step 5: Create hazard room**

Create `RoomHazard.tscn` with damage areas representing swamp water or spikes. It should have left exit to `RoomEnemy` and right exit to `RoomCheckpoint`.

- [ ] **Step 6: Create checkpoint room**

Create `RoomCheckpoint.tscn` with one `CheckpointShrine` instance named `SwampShrine01`. It should have left exit to `RoomHazard` and right exit to `RoomUpgrade`.

- [ ] **Step 7: Create upgrade room**

Create `RoomUpgrade.tscn` with one `UpgradePickup` instance. Use class-agnostic pickup id:

```text
pickup_id = "swamp_first_upgrade"
upgrade_id = "first_traversal_tool"
upgrade_type = "traversal"
```

The implementation can map `first_traversal_tool` to armored dash, hookshot, or blink based on current class.

- [ ] **Step 8: Create shortcut room**

Create `RoomShortcut.tscn` with a one-way gate or opened shortcut state. It should connect back toward `RoomCheckpoint` and forward to `RoomMiniBoss`.

- [ ] **Step 9: Create mini-boss room**

Create `RoomMiniBoss.tscn` with one `SwampMiniBoss` instance and an exit that opens only after mini-boss defeat.

- [ ] **Step 10: Add room loading map**

In `scripts/world/game_world.gd`, add:

```gdscript
const ROOM_SCENES := {
	"RoomStart": preload("res://scenes/world/swamp_outskirts/RoomStart.tscn"),
	"RoomMovement": preload("res://scenes/world/swamp_outskirts/RoomMovement.tscn"),
	"RoomEnemy": preload("res://scenes/world/swamp_outskirts/RoomEnemy.tscn"),
	"RoomHazard": preload("res://scenes/world/swamp_outskirts/RoomHazard.tscn"),
	"RoomCheckpoint": preload("res://scenes/world/swamp_outskirts/RoomCheckpoint.tscn"),
	"RoomUpgrade": preload("res://scenes/world/swamp_outskirts/RoomUpgrade.tscn"),
	"RoomShortcut": preload("res://scenes/world/swamp_outskirts/RoomShortcut.tscn"),
	"RoomMiniBoss": preload("res://scenes/world/swamp_outskirts/RoomMiniBoss.tscn"),
}
```

Add `load_room(room_id: String)` that frees the current room, instantiates the new one, calls `enter_room()`, and registers enemies, checkpoints, and pickups.

- [ ] **Step 11: Run parse check**

Run:

```powershell
godot --headless --path . --quit
```

Expected: exits with code `0`.

- [ ] **Step 12: Commit**

```powershell
git add scenes/world/swamp_outskirts scripts/world/game_world.gd
git commit -m "feat: add swamp outskirts greybox"
```

---

### Task 11: Save/Continue Integration

**Files:**
- Modify: `scripts/ui/title_screen.gd`
- Modify: `scripts/world/game_world.gd`
- Modify: `scripts/core/game_state.gd`
- Modify: `tests/test_save_manager.gd`

- [ ] **Step 1: Extend save test for continue-critical data**

Update `tests/test_save_manager.gd` to assert these fields survive save/load:

```gdscript
if loaded.current_room != "RoomCheckpoint":
	push_error("Current room did not persist")
	quit(1)
	return
if loaded.checkpoint_id != "swamp_shrine_01":
	push_error("Checkpoint id did not persist")
	quit(1)
	return
if not loaded.learned_attack_skills.has("guard_counter"):
	push_error("Learned attack skill did not persist")
	quit(1)
	return
```

- [ ] **Step 2: Run test**

Run:

```powershell
godot --headless --path . --script tests/test_save_manager.gd
```

Expected: `PASS: save manager`.

- [ ] **Step 3: Ensure title screen updates Continue button after saves**

In `scripts/ui/title_screen.gd`, add:

```gdscript
func refresh_continue_state() -> void:
	continue_button.disabled = not SaveManager.has_save()
```

Call `refresh_continue_state()` from `_ready()`.

- [ ] **Step 4: Ensure checkpoint saves current room**

In `scripts/world/game_world.gd`, ensure `activate_checkpoint` sets:

```gdscript
state.current_room = get_current_room_id()
```

Add:

```gdscript
func get_current_room_id() -> String:
	var room := get_node_or_null("Rooms").get_child(0) if get_node_or_null("Rooms") and get_node("Rooms").get_child_count() > 0 else null
	return room.room_id if room and room is Room else state.current_room
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/ui/title_screen.gd scripts/world/game_world.gd scripts/core/game_state.gd tests/test_save_manager.gd
git commit -m "feat: integrate continue save flow"
```

---

### Task 12: End-To-End Manual Playtest

**Files:**
- Modify only files needed to fix issues found during playtest.

- [ ] **Step 1: Run all headless checks**

Run:

```powershell
godot --headless --path . --script tests/test_class_data.gd
godot --headless --path . --script tests/test_xp_curve.gd
godot --headless --path . --script tests/test_save_manager.gd
godot --headless --path . --script tests/test_room_respawn.gd
```

Expected: all print `PASS:` and exit code `0`.

- [ ] **Step 2: Launch the game**

Run:

```powershell
godot --path .
```

Expected: title screen appears with New Game, Continue, and Settings.

- [ ] **Step 3: Verify New Game flow for Warden**

Manual actions:

```text
New Game -> Warden -> first sprite -> Begin
Move through RoomStart and RoomMovement.
Fight at least one SwampCrawler.
Activate checkpoint shrine.
Quit to title.
Continue.
```

Expected: Continue returns to the saved checkpoint state with Warden selected.

- [ ] **Step 4: Verify New Game flow for Gunslinger**

Manual actions:

```text
New Game -> Gunslinger -> first sprite -> Begin
Use regular attack and special attack.
Gain XP from one enemy.
Leave and re-enter RoomEnemy.
```

Expected: Gunslinger attacks work, XP increases, and normal enemies respawn after room re-entry.

- [ ] **Step 5: Verify New Game flow for Hexbinder**

Manual actions:

```text
New Game -> Hexbinder -> first sprite -> Begin
Use regular attack and special attack.
Take lethal damage after activating a checkpoint.
```

Expected: Hexbinder respawns at the active checkpoint and keeps XP/level progress.

- [ ] **Step 6: Verify mini-boss persistence**

Manual actions:

```text
Beat SwampMiniBoss.
Save at checkpoint.
Quit to title.
Continue.
Return to RoomMiniBoss.
```

Expected: mini-boss remains defeated while normal room enemies continue to respawn.

- [ ] **Step 7: Commit final fixes**

```powershell
git add .
git commit -m "fix: stabilize vertical slice playthrough"
```

---

## Execution Notes

- Keep asset use minimal in the first pass. Prefer greybox collision and temporary sprites before spending time on tile polish.
- Do not commit `.superpowers/`, `.godot/`, `.summer/local/`, or generated editor cache files.
- Commit the large `SpriteVania Assets` folder only after deciding whether Git LFS is needed.
- The first implementation milestone is working game structure. Visual polish comes after all verification targets pass.
