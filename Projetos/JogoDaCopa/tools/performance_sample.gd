extends SceneTree

# Representative performance methodology:
# - Run without `--headless` so the renderer rasterizes a real window.
# - Keep the sample windowed at 1920x1080 and leave vsync disabled.
# - Treat headless or minimized/window-size-unknown runs as sanity checks only, not FPS baselines.

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const MEASUREMENT_RESOLUTION: Vector2i = Vector2i(1920, 1080)
const WARMUP_FRAMES: int = 90
const SAMPLE_FRAMES: int = 360
const MIN_TARGET_FPS: float = 60.0

var _label: String = "sample"

func _initialize() -> void:
	_parse_command_line()
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_sample()
	quit(exit_code)

func _run_sample() -> int:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(MEASUREMENT_RESOLUTION)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	print("[perf] methodology: real window, target resolution %dx%d, vsync off; headless is not a baseline" % [
		MEASUREMENT_RESOLUTION.x,
		MEASUREMENT_RESOLUTION.y
	])

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[perf] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var packed_scene := load(FOOTBALL_SCENE_PATH) as PackedScene
	if packed_scene == null:
		printerr("[perf] failed to load %s" % FOOTBALL_SCENE_PATH)
		return 1

	var football := packed_scene.instantiate()
	root.add_child(football)
	await process_frame
	if football.has_method("debug_start_match"):
		football.debug_start_match()
	if football.has_method("debug_finish_kickoff_countdown"):
		football.debug_finish_kickoff_countdown()

	for _frame in range(WARMUP_FRAMES):
		await process_frame

	var total_fps: float = 0.0
	var min_fps: float = INF
	var below_target: int = 0
	var last_ticks: int = Time.get_ticks_usec()
	for _frame in range(SAMPLE_FRAMES):
		await process_frame
		var now_ticks: int = Time.get_ticks_usec()
		var frame_seconds: float = maxf(float(now_ticks - last_ticks) / 1000000.0, 0.000001)
		last_ticks = now_ticks
		var fps: float = 1.0 / frame_seconds
		total_fps += fps
		min_fps = minf(min_fps, fps)
		if fps < MIN_TARGET_FPS:
			below_target += 1

	var average_fps := total_fps / float(SAMPLE_FRAMES)
	var window_size := DisplayServer.window_get_size() if DisplayServer.get_name() != "headless" else Vector2i.ZERO
	var window_mode := DisplayServer.window_get_mode() if DisplayServer.get_name() != "headless" else DisplayServer.WINDOW_MODE_WINDOWED
	print("[perf] %s: average %.1ffps, min warmed instant %.1ffps, %d/%d frames below %.0f, display=%s, window=%dx%d, mode=%s" % [
		_label,
		average_fps,
		min_fps,
		below_target,
		SAMPLE_FRAMES,
		MIN_TARGET_FPS,
		DisplayServer.get_name(),
		window_size.x,
		window_size.y,
		_window_mode_label(window_mode)
	])
	return 0 if below_target == 0 else 1

func _window_mode_label(mode: int) -> String:
	match mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			return "windowed"
		DisplayServer.WINDOW_MODE_MINIMIZED:
			return "minimized"
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			return "maximized"
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			return "fullscreen"
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			return "exclusive_fullscreen"
		_:
			return str(mode)

func _parse_command_line() -> void:
	for arg: String in _collect_command_line_args():
		if arg.begins_with("--label="):
			_label = arg.get_slice("=", 1).strip_edges()

func _collect_command_line_args() -> Array[String]:
	var args: Array[String] = []
	for arg: String in OS.get_cmdline_args():
		args.append(arg)
	for arg: String in OS.get_cmdline_user_args():
		args.append(arg)
	return args
