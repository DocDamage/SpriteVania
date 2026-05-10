extends SceneTree

const TITLE_SCREEN_SCENE := preload("res://scenes/ui/TitleScreen.tscn")
const TITLE_IMAGE_PATH := "res://SpriteVania Assets/title_screen_black_keep.png"
const TITLE_IMAGE_IMPORT_PATH := "res://SpriteVania Assets/title_screen_black_keep.png.import"
const MENU_LABELS := [
	"Continue",
	"New Game",
	"Load Game",
	"Settings",
	"Accessibility",
	"Extras",
	"Credits",
	"Quit",
]
const PLACEHOLDER_SIGNALS := [
	"load_game_requested",
	"accessibility_requested",
	"extras_requested",
	"credits_requested",
	"quit_requested",
]

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var screen := TITLE_SCREEN_SCENE.instantiate() as Control
	root.add_child(screen)
	await process_frame

	_assert_background_uses_black_keep_art(screen)
	_assert_black_keep_art_import_is_pixel_safe()
	_assert_left_gradient_title_and_menu(screen)
	_assert_title_screen_signals(screen)

	screen.queue_free()
	await process_frame

	if _failed:
		return
	print("PASS: title screen")
	quit(0)

func _assert_background_uses_black_keep_art(screen: Control) -> void:
	var background := screen.get_node_or_null("Background") as TextureRect
	if background == null:
		_fail("Title screen should have a full-screen Background TextureRect.")
		return
	if not is_equal_approx(background.anchor_right, 1.0) or not is_equal_approx(background.anchor_bottom, 1.0):
		_fail("Title screen background should fill the viewport.")
		return
	if background.texture == null or background.texture.resource_path != TITLE_IMAGE_PATH:
		_fail("Title screen background should use %s." % TITLE_IMAGE_PATH)
		return
	if background.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_COVERED:
		_fail("Title screen background should cover the viewport without distortion.")
		return
	if background.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
		_fail("Title screen background should use nearest texture filtering.")
		return

func _assert_black_keep_art_import_is_pixel_safe() -> void:
	if not FileAccess.file_exists(TITLE_IMAGE_IMPORT_PATH):
		_fail("Title art should include import metadata at %s." % TITLE_IMAGE_IMPORT_PATH)
		return
	var import_settings := FileAccess.get_file_as_string(TITLE_IMAGE_IMPORT_PATH)
	if import_settings.find("compress/mode=0") == -1:
		_fail("Title art import should use lossless compression.")
		return
	if import_settings.find("mipmaps/generate=false") == -1:
		_fail("Title art import should disable mipmaps for pixel art.")
		return

func _assert_left_gradient_title_and_menu(screen: Control) -> void:
	var panel := screen.get_node_or_null("LeftGradientPanel") as TextureRect
	if panel == null:
		_fail("Title screen should include a dark left-side gradient panel.")
		return
	if panel.texture == null or not panel.texture is GradientTexture2D:
		_fail("LeftGradientPanel should use a GradientTexture2D.")
		return

	var title_label := screen.get_node_or_null("%TitleLabel") as Label
	if title_label == null or title_label.text != "THE BLACK KEEP":
		_fail("Title screen title should read THE BLACK KEEP.")
		return

	var menu_stack := screen.get_node_or_null("%MenuStack") as VBoxContainer
	if menu_stack == null:
		_fail("Title screen should expose a MenuStack VBoxContainer.")
		return
	var actual_labels: Array[String] = []
	for child: Node in menu_stack.get_children():
		if child is Button:
			actual_labels.append((child as Button).text)
	if actual_labels != MENU_LABELS:
		_fail("Title menu button order should be %s, got %s." % [MENU_LABELS, actual_labels])
		return

func _assert_title_screen_signals(screen: Control) -> void:
	for signal_name: String in PLACEHOLDER_SIGNALS:
		if not screen.has_signal(signal_name):
			_fail("Title screen should expose %s." % signal_name)
			return

	var emitted := {
		"new_game": false,
		"continue": false,
		"settings": false,
		"load_game": false,
		"accessibility": false,
		"extras": false,
		"credits": false,
		"quit": false,
	}
	screen.new_game_requested.connect(func() -> void: emitted.new_game = true)
	screen.continue_requested.connect(func() -> void: emitted.continue = true)
	screen.settings_requested.connect(func() -> void: emitted.settings = true)
	screen.load_game_requested.connect(func() -> void: emitted.load_game = true)
	screen.accessibility_requested.connect(func() -> void: emitted.accessibility = true)
	screen.extras_requested.connect(func() -> void: emitted.extras = true)
	screen.credits_requested.connect(func() -> void: emitted.credits = true)
	screen.quit_requested.connect(func() -> void: emitted.quit = true)

	screen.get_node("%NewGameButton").pressed.emit()
	screen.get_node("%ContinueButton").pressed.emit()
	screen.get_node("%SettingsButton").pressed.emit()
	screen.get_node("%LoadGameButton").pressed.emit()
	screen.get_node("%AccessibilityButton").pressed.emit()
	screen.get_node("%ExtrasButton").pressed.emit()
	screen.get_node("%CreditsButton").pressed.emit()
	screen.get_node("%QuitButton").pressed.emit()

	for signal_name: String in emitted.keys():
		if not bool(emitted[signal_name]):
			_fail("Title screen did not emit %s signal." % signal_name)
			return

func _fail(message: String) -> void:
	_failed = true
	push_error(message)
	quit(1)
