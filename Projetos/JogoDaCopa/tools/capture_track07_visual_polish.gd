extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")

const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-07-visual-polish-web-safe"
const CAPTURE_SCENE_META_KEY: String = "jogodacopa_capture_scene"
const NIGHT_SKY_MAX_LUMA_255: float = 90.0
const MIN_CAPTURE_LUMINANCE: float = 0.025
const SKY_SAMPLE_TOP_RATIO: float = 0.04
const SKY_SAMPLE_BOTTOM_RATIO: float = 0.28
const SKY_SAMPLE_LEFT_RATIO: float = 0.62
const SKY_SAMPLE_RIGHT_RATIO: float = 0.96

const CAPTURE_SIZES: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
]

const FOOTBALL_SHOTS: Array[Dictionary] = [
	{"id": &"kickoff", "capture_scene": &"kickoff", "frames": 28},
	{"id": &"goal", "capture_scene": &"goal", "frames": 24},
	{"id": &"result", "capture_scene": &"result", "frames": 36},
	{"id": &"play", "capture_scene": &"play", "frames": 28},
]

var report_rows: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_track07()
	quit(exit_code)

func _capture_track07() -> int:
	if DisplayServer.get_name().to_lower().contains("headless"):
		printerr("[track07-capture] run without --headless to render screenshots")
		return 1

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[track07-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	for capture_size: Vector2i in CAPTURE_SIZES:
		_set_window_size(capture_size)
		await _drain_frames(4)
		await _capture_menu(output_dir_absolute, capture_size)
		for shot: Dictionary in FOOTBALL_SHOTS:
			await _capture_football_shot(output_dir_absolute, capture_size, shot)
		await _capture_pause_flow(output_dir_absolute, capture_size)
	_write_report(output_dir_absolute)
	return 0

func _capture_menu(output_dir_absolute: String, capture_size: Vector2i) -> void:
	var menu := _instantiate_menu()
	root.add_child(menu)
	await _drain_frames(10)
	_clear_menu_fade(menu)
	await _drain_frames(8)
	var file_name := "track07-menu-hero-%dx%d.png" % [capture_size.x, capture_size.y]
	var image := _save_capture(output_dir_absolute, file_name)
	_record_average_luminance(image, "menu", capture_size, file_name)
	menu.queue_free()
	await _drain_frames(4)

func _capture_football_shot(output_dir_absolute: String, capture_size: Vector2i, shot: Dictionary) -> void:
	var shot_id := StringName(str(shot["id"]))
	var capture_scene_id := StringName(str(shot["capture_scene"]))
	root.set_meta(CAPTURE_SCENE_META_KEY, capture_scene_id)
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(int(shot["frames"]))
	_assert_night_environment_config(football, str(shot_id))
	_clear_football_fade(football)
	await _drain_frames(6)
	var file_name := "track07-%s-%dx%d.png" % [str(shot_id), capture_size.x, capture_size.y]
	var image := _save_capture(output_dir_absolute, file_name)
	var sky_luma := _assert_night_capture_luminance(image, str(shot_id), file_name)
	report_rows.append({
		"shot": str(shot_id),
		"resolution": "%dx%d" % [capture_size.x, capture_size.y],
		"sky_luma_255": snappedf(sky_luma, 0.1),
		"file": file_name,
	})
	football.queue_free()
	root.remove_meta(CAPTURE_SCENE_META_KEY)
	await _drain_frames(4)

func _capture_pause_flow(output_dir_absolute: String, capture_size: Vector2i) -> void:
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(12)
	if football.has_method("debug_start_match"):
		football.call("debug_start_match")
	if football.has_method("_set_menu_open"):
		football.call("_set_menu_open", true)
	await _drain_frames(6)
	var hud := football.get_node_or_null("FootballHud")
	if hud != null and hud.has_method("_set_fade_alpha_immediate"):
		hud.call("_set_fade_alpha_immediate", 0.0)
	if hud != null and hud.has_method("debug_show_pause_section"):
		hud.call("debug_show_pause_section", &"controls")
	await _drain_frames(4)
	var controls_file := "track07-pause-controls-%dx%d.png" % [capture_size.x, capture_size.y]
	var controls_image := _save_capture(output_dir_absolute, controls_file)
	_record_average_luminance(controls_image, "pause-controls", capture_size, controls_file)

	if hud != null and hud.has_method("debug_show_pause_section"):
		hud.call("debug_show_pause_section", &"audio")
	var restart_button := football.get_node_or_null("FootballHud/HudRoot/PauseMenuCenter/PauseMenuPanel/PauseMenuMargin/PauseMenuBox/RestartMatchButton") as Button
	if restart_button != null:
		restart_button.pressed.emit()
	await _drain_frames(4)
	var confirm_file := "track07-pause-restart-confirm-%dx%d.png" % [capture_size.x, capture_size.y]
	var confirm_image := _save_capture(output_dir_absolute, confirm_file)
	_record_average_luminance(confirm_image, "pause-restart-confirm", capture_size, confirm_file)
	football.queue_free()
	await _drain_frames(4)

func _instantiate_menu() -> Control:
	var packed_scene := load(MENU_SCENE_PATH) as PackedScene
	return packed_scene.instantiate() as Control

func _instantiate_football() -> Node3D:
	var packed_scene := load(FOOTBALL_SCENE_PATH) as PackedScene
	return packed_scene.instantiate() as Node3D

func _set_window_size(capture_size: Vector2i) -> void:
	DisplayServer.window_set_size(capture_size)
	root.size = capture_size

func _save_capture(output_dir_absolute: String, file_name: String) -> Image:
	var output_path := "%s/%s" % [output_dir_absolute, file_name]
	var image := root.get_texture().get_image()
	image.save_png(output_path)
	print("[track07-capture] %s" % output_path)
	return image

func _assert_night_environment_config(football: Node3D, capture_scene_label: String) -> void:
	var world_environment := football.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null:
		push_error("[track07-capture] %s missing WorldEnvironment" % capture_scene_label)
		quit(1)
		return
	var environment := world_environment.environment
	if environment == null:
		push_error("[track07-capture] %s missing Environment resource" % capture_scene_label)
		quit(1)
		return
	if environment.tonemap_mode != Environment.TONE_MAPPER_ACES:
		push_error("[track07-capture] %s environment tonemap is not ACES" % capture_scene_label)
		quit(1)
	if environment.background_mode != Environment.BG_SKY:
		push_error("[track07-capture] %s environment background is not BG_SKY" % capture_scene_label)
		quit(1)
	var sky_material: ProceduralSkyMaterial = null
	if environment.sky != null:
		sky_material = environment.sky.sky_material as ProceduralSkyMaterial
	if sky_material == null:
		push_error("[track07-capture] %s sky material is missing" % capture_scene_label)
		quit(1)
		return
	var sky_luma := _color_luma_255(sky_material.sky_top_color)
	print("[track07-capture] %s configured sky_top_luma=%.1f" % [capture_scene_label, sky_luma])
	if sky_luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track07-capture] %s configured sky top is too bright: %.1f" % [capture_scene_label, sky_luma])
		quit(1)

func _assert_night_capture_luminance(image: Image, capture_scene_label: String, file_name: String) -> float:
	var luma := _sample_sky_region_luma_255(image)
	print("[track07-capture] %s captured sky_luma=%.1f file=%s" % [capture_scene_label, luma, file_name])
	if luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track07-capture] %s captured sky luma %.1f exceeds night gate %.1f for %s" % [
			capture_scene_label,
			luma,
			NIGHT_SKY_MAX_LUMA_255,
			file_name,
		])
		quit(1)
	return luma

func _record_average_luminance(image: Image, shot_id: String, capture_size: Vector2i, file_name: String) -> void:
	var luminance := _average_luminance(image, 28)
	print("[track07-capture] %s %dx%d luma=%.4f file=%s" % [shot_id, capture_size.x, capture_size.y, luminance, file_name])
	if luminance < MIN_CAPTURE_LUMINANCE:
		push_error("[track07-capture] %s %dx%d luminance %.4f below %.4f" % [shot_id, capture_size.x, capture_size.y, luminance, MIN_CAPTURE_LUMINANCE])
	report_rows.append({
		"shot": shot_id,
		"resolution": "%dx%d" % [capture_size.x, capture_size.y],
		"average_luma": snappedf(luminance, 0.001),
		"file": file_name,
	})

func _sample_sky_region_luma_255(image: Image) -> float:
	var width := image.get_width()
	var height := image.get_height()
	var x_start := int(round(float(width) * SKY_SAMPLE_LEFT_RATIO))
	var x_end := int(round(float(width) * SKY_SAMPLE_RIGHT_RATIO))
	var y_start := int(round(float(height) * SKY_SAMPLE_TOP_RATIO))
	var y_end := int(round(float(height) * SKY_SAMPLE_BOTTOM_RATIO))
	var total := 0.0
	var count := 0
	for y: int in range(y_start, y_end, 6):
		for x: int in range(x_start, x_end, 6):
			total += _color_luma_255(image.get_pixel(x, y))
			count += 1
	if count <= 0:
		return 255.0
	return total / float(count)

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

func _color_luma_255(color: Color) -> float:
	return ((0.2126 * color.r) + (0.7152 * color.g) + (0.0722 * color.b)) * 255.0

func _clear_menu_fade(menu: Control) -> void:
	if menu != null and menu.has_method("_set_fade_alpha_immediate"):
		menu.call("_set_fade_alpha_immediate", 0.0)

func _clear_football_fade(football: Node3D) -> void:
	var hud := football.get_node_or_null("FootballHud")
	if hud != null and hud.has_method("_set_fade_alpha_immediate"):
		hud.call("_set_fade_alpha_immediate", 0.0)

func _write_report(output_dir_absolute: String) -> void:
	var output_path := "%s/track07-visual-polish-report.json" % output_dir_absolute
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("[track07-capture] failed to write report: %s" % output_path)
		quit(1)
		return
	file.store_string(JSON.stringify(report_rows, "\t"))
	file.close()
	print("[track07-capture] %s" % output_path)

func _drain_frames(frame_count: int) -> void:
	for _index: int in range(frame_count):
		await process_frame
