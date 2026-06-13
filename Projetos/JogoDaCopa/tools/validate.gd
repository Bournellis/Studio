extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const PROFILE_FULL: String = "full"
const PROFILE_QUICK: String = "quick"
const PROFILE_STRUCTURE: String = "structure"
const UTF8_BOM_BYTE_0: int = 0xEF
const UTF8_BOM_BYTE_1: int = 0xBB
const UTF8_BOM_BYTE_2: int = 0xBF
const WEB_BUILD_GZIP_TRANSFER_LIMIT_BYTES: int = 50 * 1024 * 1024

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
	print("[validate] generating JogoDaCopa scenes")
	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[validate] %s" % str(scene_result.get("message", "Scene generation failed.")))
		return 1

	print("[validate] checking project resources and settings")
	_check_core_project_contract()
	if _profile == PROFILE_FULL:
		_check_documentation_contract()
	_check_generated_scenes()
	_check_script_and_shader_integrity()

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
	_check_project_setting("application/config/name", "Copa Arena Futebol")
	_check_project_setting("application/run/main_scene", "res://modes/menu/main_menu.tscn")
	_check_project_setting("autoload/AppBootstrap", "*res://autoloads/app_bootstrap.gd")
	_check_project_setting("autoload/GameSettings", "*res://autoloads/game_settings.gd")
	_check_project_setting("autoload/RenderProfile", "*res://autoloads/render_profile.gd")
	_check_resource("res://assets/branding/copa_arena_icon.svg")
	_check_resource("res://assets/branding/copa_arena_splash.png")
	_check_resource("res://export_presets.cfg")
	_check_resource("res://modes/menu/main_menu.tscn")
	_check_resource("res://autoloads/game_settings.gd")
	_check_resource("res://autoloads/render_profile.gd")
	_check_resource("res://modes/menu/main_menu_root.gd")
	_check_resource("res://modes/football/football.tscn")
	_check_resource("res://modes/football/football_root.gd")
	_check_resource("res://modes/football/football_field_builder.gd")
	_check_resource("res://modes/shared/runtime_primitive_factory.gd")
	_check_resource("res://gameplay/avatar/avatar_appearance.gd")
	_check_resource("res://gameplay/avatar/avatar_catalog.gd")
	_check_resource("res://gameplay/avatar/player_avatar_3d.gd")
	_check_resource("res://gameplay/combat/combatant_3d.gd")
	_check_resource("res://gameplay/player/fps_player_controller.gd")
	_check_resource("res://gameplay/football/football_ball.gd")
	_check_resource("res://gameplay/football/football_bot.gd")
	_check_resource("res://gameplay/football/football_match_rules.gd")
	_check_resource("res://presentation/hud/football_hud.gd")
	_check_resource("res://presentation/camera/football_chase_camera.gd")
	_check_resource("res://presentation/feedback/fps_feedback_controller.gd")
	_check_resource("res://tools/bootstrap_scene_generator.gd")
	_check_resource("res://addons/gut/plugin.cfg")
	_check_resource("res://.gutconfig.json")
	_check_web_export_contract()
	_check_web_build_size_gate()

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
	_check_resource("res://docs/avatar-visual-contract.md")

func _check_generated_scenes() -> void:
	var menu_scene := load("res://modes/menu/main_menu.tscn") as PackedScene
	if menu_scene == null:
		_failures.append("Generated main menu scene did not load.")
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	if football_scene == null:
		_failures.append("Generated football scene did not load.")

func _check_script_and_shader_integrity() -> void:
	var files: Array[String] = []
	_collect_integrity_files("res://", files)
	var checked_count := 0
	for path in files:
		if _source_has_utf8_bom(path):
			_failures.append("Source file has UTF-8 BOM: %s" % path)
			continue
		var resource := load(path)
		if resource == null:
			_failures.append("Failed to load source resource: %s" % path)
			continue
		if path.ends_with(".gd") and not (resource is Script):
			_failures.append("Expected script resource: %s" % path)
			continue
		if path.ends_with(".gdshader") and not (resource is Shader):
			_failures.append("Expected shader resource: %s" % path)
			continue
		checked_count += 1
	print("[validate] source integrity checked: %d .gd/.gdshader files" % checked_count)

func _source_has_utf8_bom(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("Failed to open source file for BOM check: %s" % path)
		return false
	if file.get_length() < 3:
		return false
	var prefix := file.get_buffer(3)
	return (
		prefix.size() == 3
		and int(prefix[0]) == UTF8_BOM_BYTE_0
		and int(prefix[1]) == UTF8_BOM_BYTE_1
		and int(prefix[2]) == UTF8_BOM_BYTE_2
	)

func _collect_integrity_files(directory_path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		_failures.append("Failed to open source directory: %s" % directory_path)
		return
	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry.is_empty():
			break
		if entry.begins_with("."):
			continue
		var path := directory_path.path_join(entry)
		if directory.current_is_dir():
			if path == "res://addons":
				continue
			_collect_integrity_files(path, output)
		elif path.ends_with(".gd") or path.ends_with(".gdshader"):
			output.append(path)
	directory.list_dir_end()

func _check_project_setting(key: String, expected: Variant) -> void:
	var actual: Variant = ProjectSettings.get_setting(key)
	if actual != expected:
		_failures.append("%s expected %s, got %s" % [key, expected, actual])

func _check_resource(path: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append("Missing resource: %s" % path)

func _check_web_export_contract() -> void:
	var file := FileAccess.open("res://export_presets.cfg", FileAccess.READ)
	if file == null:
		_failures.append("Missing export presets for Web contract.")
		return
	var text := file.get_as_text()
	var required_fragments: PackedStringArray = [
		"name=\"Web\"",
		"platform=\"Web\"",
		"export_path=\"builds/web/index.html\"",
		"variant/extensions_support=false",
		"variant/thread_support=false",
		"progressive_web_app/enabled=false",
		"progressive_web_app/ensure_cross_origin_isolation_headers=false",
		"threads/emscripten_pool_size=0",
		"threads/godot_pool_size=0",
	]
	for fragment: String in required_fragments:
		if not text.contains(fragment):
			_failures.append("Web export contract missing: %s" % fragment)

func _check_web_build_size_gate() -> void:
	if not FileAccess.file_exists("res://builds/web/index.wasm") or not FileAccess.file_exists("res://builds/web/index.pck"):
		print("[validate] web build size gate skipped: builds/web/index.wasm or index.pck not present")
		return
	var exported_files: PackedStringArray = []
	_collect_web_build_files("res://builds/web", exported_files)
	var raw_total := 0
	var gzip_total := 0
	for path: String in exported_files:
		var bytes := FileAccess.get_file_as_bytes(path)
		raw_total += bytes.size()
		gzip_total += bytes.compress(FileAccess.COMPRESSION_GZIP).size()
	print("[validate] web build gzip transfer size: %s / %s raw=%s files=%d" % [
		_format_mib(gzip_total),
		_format_mib(WEB_BUILD_GZIP_TRANSFER_LIMIT_BYTES),
		_format_mib(raw_total),
		exported_files.size(),
	])
	if gzip_total > WEB_BUILD_GZIP_TRANSFER_LIMIT_BYTES:
		_failures.append("Web build gzip transfer exceeds %s: %s" % [
			_format_mib(WEB_BUILD_GZIP_TRANSFER_LIMIT_BYTES),
			_format_mib(gzip_total),
		])

func _collect_web_build_files(directory_path: String, output: PackedStringArray) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		_failures.append("Failed to open Web build directory: %s" % directory_path)
		return
	directory.list_dir_begin()
	while true:
		var entry := directory.get_next()
		if entry.is_empty():
			break
		if entry.begins_with("."):
			continue
		var path := directory_path.path_join(entry)
		if directory.current_is_dir():
			_collect_web_build_files(path, output)
		elif not path.ends_with(".import"):
			output.append(path)
	directory.list_dir_end()

func _format_mib(byte_count: int) -> String:
	return "%.2f MiB" % (float(byte_count) / 1048576.0)

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
