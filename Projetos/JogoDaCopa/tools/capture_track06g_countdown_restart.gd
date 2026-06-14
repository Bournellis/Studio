extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")

const OUTPUT_DIR: String = "res://docs/screenshots/track-06g-countdown-restart-flow-v1"
const CAPTURE_SIZES: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
]
const MIN_CAPTURE_LUMINANCE: float = 0.025

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_track06g()
	quit(exit_code)

func _capture_track06g() -> int:
	if DisplayServer.get_name().to_lower().contains("headless"):
		printerr("[track06g-capture] run without --headless to render screenshots")
		return 1
	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[track06g-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1
	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	for capture_size: Vector2i in CAPTURE_SIZES:
		await _capture_size(capture_size, output_dir_absolute)
	return 0

func _capture_size(capture_size: Vector2i, output_dir_absolute: String) -> void:
	_set_window_size(capture_size)
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	if football_scene == null:
		push_error("[track06g-capture] missing football scene")
		return
	var football := football_scene.instantiate() as Node3D
	root.add_child(football)
	await _drain_frames(12)
	football.debug_start_match()
	football.debug_finish_kickoff_countdown()
	football._set_menu_open(true)
	await _drain_frames(6)
	var hud := football.get_node("FootballHud") as FootballHud
	if hud != null and hud.has_method("_set_fade_alpha_immediate"):
		hud.call("_set_fade_alpha_immediate", 0.0)
	hud.debug_show_pause_section(&"controls")
	await _drain_frames(4)
	var image := _save_capture(output_dir_absolute, "pause-controls-no-r-%dx%d.png" % [capture_size.x, capture_size.y])
	_assert_capture_luminance(image, "controls", capture_size)

	hud.debug_show_pause_section(&"audio")
	var restart_button := hud.get_node("HudRoot/PauseMenuCenter/PauseMenuPanel/PauseMenuMargin/PauseMenuBox/RestartMatchButton") as Button
	restart_button.pressed.emit()
	await _drain_frames(4)
	image = _save_capture(output_dir_absolute, "pause-restart-confirm-%dx%d.png" % [capture_size.x, capture_size.y])
	_assert_capture_luminance(image, "restart-confirm", capture_size)
	football.queue_free()
	await _drain_frames(4)

func _set_window_size(capture_size: Vector2i) -> void:
	DisplayServer.window_set_size(capture_size)
	root.size = capture_size

func _drain_frames(frame_count: int) -> void:
	for _index in range(frame_count):
		await process_frame

func _save_capture(output_dir_absolute: String, file_name: String) -> Image:
	var output_path := "%s/%s" % [output_dir_absolute, file_name]
	var image := root.get_texture().get_image()
	image.save_png(output_path)
	print("[track06g-capture] %s" % output_path)
	return image

func _assert_capture_luminance(image: Image, capture_label: String, capture_size: Vector2i) -> void:
	var luminance := _average_luminance(image, 28)
	print("[track06g-capture] %s %dx%d luma=%.4f" % [capture_label, capture_size.x, capture_size.y, luminance])
	if luminance < MIN_CAPTURE_LUMINANCE:
		push_error("[track06g-capture] %s %dx%d luminance %.4f below %.4f" % [capture_label, capture_size.x, capture_size.y, luminance, MIN_CAPTURE_LUMINANCE])

func _average_luminance(image: Image, sample_step: int) -> float:
	if image == null or image.is_empty():
		return 0.0
	var total := 0.0
	var count := 0
	var step := maxi(1, sample_step)
	var y := 0
	while y < image.get_height():
		var x := 0
		while x < image.get_width():
			var color := image.get_pixel(x, y)
			total += color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			count += 1
			x += step
		y += step
	return total / maxf(1.0, float(count))
