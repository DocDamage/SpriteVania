extends SceneTree

const CC2DCreatorManager := preload("res://scripts/character_creator/cc2d_creator_manager.gd")
const CC2DRecipe := preload("res://scripts/character_creator/cc2d_recipe.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var raw_args := OS.get_cmdline_user_args()
	if raw_args.is_empty():
		raw_args = OS.get_cmdline_args()
	var args := _parse_args(raw_args)
	if bool(args.get("help", false)):
		_print_usage()
		quit(0)
		return
	var manager := CC2DCreatorManager.new()
	manager.load_content()
	var recipe: CC2DRecipe = manager.default_recipe(str(args.get("recipe_id", "cli_character")))
	var recipe_in := str(args.get("recipe", ""))
	if not recipe_in.is_empty():
		recipe = manager.load_recipe(recipe_in)
		if recipe == null:
			push_error("Could not load recipe: %s" % recipe_in)
			quit(1)
			return
	var bundle_in := str(args.get("bundle_in", ""))
	if not bundle_in.is_empty():
		recipe = manager.import_recipe_bundle(bundle_in)
		if recipe == null:
			push_error("Could not import recipe bundle: %s" % bundle_in)
			quit(1)
			return
	var set_id: String = str(args.get("set_id", "first_slice_player"))
	var max_frames: int = max(1, int(args.get("max_frames", 1)))
	var failed: bool = false
	var summary := {
		"ok": false,
		"recipe_id": recipe.recipe_id,
		"set_id": set_id,
		"outputs": {},
	}
	var recipe_out := str(args.get("recipe_out", ""))
	if not recipe_out.is_empty() and not manager.save_recipe(recipe, recipe_out):
		push_error("Could not save recipe: %s" % recipe_out)
		failed = true
	elif not recipe_out.is_empty():
		(summary.outputs as Dictionary).recipe = recipe_out
	var bundle_out := str(args.get("bundle_out", ""))
	if not bundle_out.is_empty():
		var bundle_report: Dictionary = manager.export_recipe_bundle(recipe, bundle_out, set_id)
		if not bool(bundle_report.get("ok", false)):
			push_error("Could not export recipe bundle: %s" % str(bundle_report.get("errors", [])))
			failed = true
		else:
			(summary.outputs as Dictionary).bundle = bundle_out
	var output_root := str(args.get("output_root", ""))
	if not output_root.is_empty():
		var sheet_report: Dictionary = manager.bake_export_sheets(recipe, output_root, set_id, max_frames)
		if not bool(sheet_report.get("ok", false)):
			push_error("Sheet bake failed: %s" % str(sheet_report.get("errors", [])))
			failed = true
		else:
			(summary.outputs as Dictionary).sheets = output_root
			(summary.outputs as Dictionary).source_spec = str(sheet_report.get("source_spec", ""))
	var spriteframes_path := str(args.get("spriteframes", ""))
	if not spriteframes_path.is_empty():
		if output_root.is_empty():
			output_root = "%s_sheets" % spriteframes_path.get_basename()
		var frames_report: Dictionary = manager.bake_export_spriteframes(recipe, output_root, spriteframes_path, set_id, max_frames)
		if not bool(frames_report.get("ok", false)):
			push_error("SpriteFrames bake failed: %s" % str(frames_report.get("errors", [])))
			failed = true
		else:
			(summary.outputs as Dictionary).spriteframes = spriteframes_path
	var contact_sheet_path := str(args.get("contact_sheet", ""))
	if not contact_sheet_path.is_empty():
		var contact_report: Dictionary = manager.bake_contact_sheet(recipe, contact_sheet_path, set_id, max_frames)
		if not bool(contact_report.get("ok", false)):
			push_error("Contact sheet bake failed: %s" % str(contact_report.get("errors", [])))
			failed = true
		else:
			(summary.outputs as Dictionary).contact_sheet = contact_sheet_path
	for target_id: String in ["portrait", "avatar", "icon"]:
		var target_path := str(args.get(target_id, ""))
		if target_path.is_empty():
			continue
		var target_report: Dictionary = manager.bake_export_target(recipe, target_path, target_id)
		if not bool(target_report.get("ok", false)):
			push_error("%s bake failed: %s" % [target_id.capitalize(), str(target_report.get("errors", []))])
			failed = true
		else:
			(summary.outputs as Dictionary)[target_id] = target_path
	var validation_report_path := str(args.get("validation_report", ""))
	if not validation_report_path.is_empty():
		var validation_report: Dictionary = manager.write_validation_report(recipe, validation_report_path, set_id)
		if not bool(validation_report.get("ok", false)):
			push_error("Validation report failed: %s" % str(validation_report.get("errors", [])))
			failed = true
		else:
			(summary.outputs as Dictionary).validation_report = validation_report_path
	if output_root.is_empty() and spriteframes_path.is_empty() and contact_sheet_path.is_empty() and validation_report_path.is_empty() and recipe_out.is_empty() and bundle_out.is_empty() and str(args.get("portrait", "")).is_empty() and str(args.get("avatar", "")).is_empty() and str(args.get("icon", "")).is_empty():
		push_error("No outputs requested.")
		_print_usage()
		quit(1)
		return
	summary.ok = not failed
	print("cc2d_export_summary=" + JSON.stringify(summary))
	quit(1 if failed else 0)

func _parse_args(raw_args: PackedStringArray) -> Dictionary:
	var parsed := {
		"recipe": "",
		"bundle_in": "",
		"recipe_id": "cli_character",
		"recipe_out": "",
		"bundle_out": "",
		"output_root": "",
		"spriteframes": "",
		"contact_sheet": "",
		"portrait": "",
		"avatar": "",
		"icon": "",
		"validation_report": "",
		"set_id": "first_slice_player",
		"max_frames": 1,
		"help": false,
	}
	var args: Array[String] = []
	var after_separator := raw_args.find("--") < 0
	for raw_arg: String in raw_args:
		if raw_arg == "--":
			after_separator = true
			continue
		if after_separator or raw_arg.begins_with("--"):
			args.append(raw_arg)
	var index: int = 0
	while index < args.size():
		var key := args[index]
		if key == "--help" or key == "-h":
			parsed.help = true
			index += 1
			continue
		if index + 1 >= args.size():
			break
		var value := args[index + 1]
		match key:
			"--recipe":
				parsed.recipe = value
			"--bundle-in":
				parsed.bundle_in = value
			"--recipe-id":
				parsed.recipe_id = value
			"--recipe-out":
				parsed.recipe_out = value
			"--bundle-out":
				parsed.bundle_out = value
			"--output-root":
				parsed.output_root = value
			"--spriteframes":
				parsed.spriteframes = value
			"--contact-sheet":
				parsed.contact_sheet = value
			"--portrait":
				parsed.portrait = value
			"--avatar":
				parsed.avatar = value
			"--icon":
				parsed.icon = value
			"--validation-report":
				parsed.validation_report = value
			"--set-id":
				parsed.set_id = value
			"--max-frames":
				parsed.max_frames = max(1, int(value))
		index += 2
	return parsed

func _print_usage() -> void:
	print("Usage: godot --headless --path . --script tools/cc2d_export_cli.gd -- [options]")
	print("Options: --recipe PATH --bundle-in PATH --recipe-id ID --recipe-out PATH --bundle-out PATH --output-root DIR --spriteframes PATH --contact-sheet PATH --portrait PATH --avatar PATH --icon PATH --validation-report PATH --set-id ID --max-frames N")
