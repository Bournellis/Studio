extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const PROFILE_FULL: String = "full"
const PROFILE_QUICK: String = "quick"
const PROFILE_STRUCTURE: String = "structure"

var _failures: Array[String] = []
var _profile: String = PROFILE_FULL
var _list_profiles_requested: bool = false

func _initialize() -> void:
	_parse_command_line()
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_validation()
	quit(exit_code)

func _run_validation() -> int:
	if _list_profiles_requested:
		_print_profiles()
		return 0
	if not _is_supported_profile(_profile):
		printerr("[validate] unsupported profile: %s" % _profile)
		_print_profiles()
		return 1

	print("[validate] profile: %s" % _profile)
	print("[validate] generating FpsPlayground scenes")
	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[validate] %s" % str(scene_result.get("message", "Scene generation failed.")))
		return 1

	print("[validate] checking project resources and settings")
	_check_core_project_contract()
	if _profile == PROFILE_FULL:
		_check_documentation_contract()
	_check_generated_scenes()

	if _failures.is_empty():
		if _profile == PROFILE_STRUCTURE:
			print("[validate] structure checks passed")
			return 0
		print("[validate] running GUT")
		var gut_exit_code := await _run_gut()
		if gut_exit_code != 0:
			printerr("[validate] GUT failed with exit code %d." % gut_exit_code)
			return gut_exit_code
		print("[validate] manual editor smoke: res://docs/validation.md")
		print("[validate] success")
		return 0

	for failure: String in _failures:
		printerr("[validate] %s" % failure)
	return 1

func _parse_command_line() -> void:
	for arg: String in _collect_command_line_args():
		if arg == "--list-profiles":
			_list_profiles_requested = true
		elif arg.begins_with("--profile="):
			_profile = arg.get_slice("=", 1).strip_edges().to_lower()

func _collect_command_line_args() -> Array[String]:
	var args: Array[String] = []
	for arg: String in OS.get_cmdline_args():
		args.append(arg)
	for arg: String in OS.get_cmdline_user_args():
		args.append(arg)
	return args

func _is_supported_profile(profile: String) -> bool:
	return profile == PROFILE_FULL or profile == PROFILE_QUICK or profile == PROFILE_STRUCTURE

func _print_profiles() -> void:
	print("[validate] available profiles:")
	print("[validate]   full      - scene generation, resources, docs, generated scene load and GUT")
	print("[validate]   quick     - scene generation, core resources, generated scene load and GUT")
	print("[validate]   structure - scene generation, core resources and generated scene load only")

func _check_core_project_contract() -> void:
	_check_project_setting("application/config/name", "FpsPlayground")
	_check_project_setting("application/run/main_scene", "res://modes/menu/main_menu.tscn")
	_check_project_setting("autoload/AppBootstrap", "*res://autoloads/app_bootstrap.gd")
	_check_resource("res://modes/menu/main_menu.tscn")
	_check_resource("res://modes/menu/main_menu_root.gd")
	_check_resource("res://modes/arena/arena.tscn")
	_check_resource("res://modes/arena/arena_root.gd")
	_check_resource("res://modes/arena/arena_duel_pit_layout_builder.gd")
	_check_resource("res://modes/shared/runtime_primitive_factory.gd")
	_check_resource("res://gameplay/arena/arena_combat_rules.gd")
	_check_resource("res://gameplay/combat/combatant_3d.gd")
	_check_resource("res://gameplay/player/fps_player_controller.gd")
	_check_resource("res://gameplay/bot/basic_duel_bot.gd")
	_check_resource("res://gameplay/bot/bot_aim_model.gd")
	_check_resource("res://gameplay/bot/bot_visibility_points.gd")
	_check_resource("res://presentation/hud/arena_hud.gd")
	_check_resource("res://presentation/feedback/fps_feedback_controller.gd")
	_check_resource("res://tools/bootstrap_scene_generator.gd")
	_check_resource("res://addons/gut/plugin.cfg")
	_check_resource("res://.gutconfig.json")

func _check_documentation_contract() -> void:
	_check_resource("res://README.md")
	_check_resource("res://AGENTS.md")
	_check_resource("res://implementation/current-status.md")
	_check_resource("res://docs/documentation-index.md")
	_check_resource("res://docs/architecture-overview.md")
	_check_resource("res://docs/work-plan.md")
	_check_resource("res://docs/reuse-map.md")
	_check_resource("res://docs/validation.md")
	_check_resource("res://docs/mode-contract.md")
	_check_resource("res://docs/bot-contract.md")
	_check_resource("res://docs/tuning-guide.md")
	_check_resource("res://docs/validation-profiles.md")
	_check_resource("res://docs/publication-readiness.md")
	_check_resource("res://docs/codebase-audit-track05.md")

func _check_generated_scenes() -> void:
	var menu_scene := load("res://modes/menu/main_menu.tscn") as PackedScene
	if menu_scene == null:
		_failures.append("Generated main menu scene did not load.")
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	if arena_scene == null:
		_failures.append("Generated arena scene did not load.")

func _check_project_setting(key: String, expected: Variant) -> void:
	var actual: Variant = ProjectSettings.get_setting(key)
	if actual != expected:
		_failures.append("%s expected %s, got %s" % [key, expected, actual])

func _check_resource(path: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append("Missing resource: %s" % path)

func _run_gut() -> int:
	var gut_config_script: Script = load("res://addons/gut/gut_config.gd")
	if gut_config_script == null or not gut_config_script.can_instantiate():
		printerr("[validate] GUT is not ready. Run a one-time headless editor import, then validate again.")
		return 1

	var gut_config = gut_config_script.new()
	var load_result: int = int(gut_config.load_options("res://.gutconfig.json"))
	if load_result == -1:
		printerr("[validate] Failed to load res://.gutconfig.json.")
		return 1

	gut_config.options.should_exit = false
	gut_config.options.should_exit_on_success = false

	var gut_script: Script = load("res://addons/gut/gut.gd")
	if gut_script == null or not gut_script.can_instantiate():
		printerr("[validate] Failed to instantiate GUT runner.")
		return 1

	var gut = gut_script.new()
	gut.name = "ValidationGut"
	root.add_child(gut)
	gut_config.apply_options(gut)
	gut.ignore_pause_before_teardown = true

	var completed: Array[bool] = [false]
	var exit_code: Array[int] = [0]
	gut.end_run.connect(func() -> void:
		exit_code[0] = 1 if gut.get_fail_count() > 0 else 0
		completed[0] = true
	)

	gut.test_scripts(gut.unit_test_name == "")
	while not completed[0]:
		await process_frame

	gut.queue_free()
	await _drain_frames(8)
	return exit_code[0]

func _drain_frames(count: int) -> void:
	for _index: int in range(count):
		await process_frame
