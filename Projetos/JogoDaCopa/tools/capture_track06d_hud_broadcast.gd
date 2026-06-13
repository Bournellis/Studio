extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-06d"
const CAPTURE_SCENE_META_KEY: String = "jogodacopa_capture_scene"
const NIGHT_SKY_MAX_LUMA_255: float = 90.0
const SKY_SAMPLE_TOP_RATIO: float = 0.04
const SKY_SAMPLE_BOTTOM_RATIO: float = 0.28
const SKY_SAMPLE_LEFT_RATIO: float = 0.62
const SKY_SAMPLE_RIGHT_RATIO: float = 0.96

const CAPTURE_SIZES: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
]

const SHOTS: Array[Dictionary] = [
	{"id": &"kickoff", "capture_scene": &"kickoff", "frames": 28},
	{"id": &"goal", "capture_scene": &"goal", "frames": 24},
	{"id": &"super", "capture_scene": &"play", "frames": 24},
	{"id": &"result", "capture_scene": &"result", "frames": 36},
]

var luma_rows: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_track06d()
	quit(exit_code)

func _capture_track06d() -> int:
	if DisplayServer.get_name().to_lower().contains("headless"):
		printerr("[track06d-capture] run without --headless to render screenshots")
		return 1

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[track06d-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	for capture_size in CAPTURE_SIZES:
		_set_window_size(capture_size)
		await _drain_frames(4)
		for shot in SHOTS:
			await _capture_football_shot(output_dir_absolute, capture_size, shot)
	_write_luma_report(output_dir_absolute)
	return 0

func _capture_football_shot(output_dir_absolute: String, capture_size: Vector2i, shot: Dictionary) -> void:
	var shot_id := StringName(str(shot["id"]))
	var capture_scene_id := StringName(str(shot["capture_scene"]))
	root.set_meta(CAPTURE_SCENE_META_KEY, capture_scene_id)
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(int(shot["frames"]))
	if shot_id == &"super":
		_prepare_super_shot(football)
		await _drain_frames(8)
	_assert_night_environment_config(football, str(shot_id))
	_clear_football_fade(football)
	await _drain_frames(6)
	var file_name := "hud-broadcast-%s-%dx%d.png" % [
		str(shot_id),
		capture_size.x,
		capture_size.y,
	]
	var image := _save_capture(output_dir_absolute, file_name)
	var luma := _assert_night_capture_luminance(image, str(shot_id), file_name)
	luma_rows.append({
		"shot": str(shot_id),
		"resolution": "%dx%d" % [capture_size.x, capture_size.y],
		"luma": snappedf(luma, 0.1),
		"file": file_name,
	})
	football.queue_free()
	await _drain_frames(4)

func _prepare_super_shot(football: Node3D) -> void:
	if football.has_method("debug_set_player_super_meter"):
		football.call("debug_set_player_super_meter", 999.0)
	if football.has_method("debug_force_ball_position") and football.has_method("debug_get_player"):
		var player := football.call("debug_get_player") as Node3D
		if player != null:
			football.call("debug_force_ball_position", player.global_position + (-player.global_transform.basis.z * 1.4) + Vector3.UP * 0.55)
	var hud := football.get_node_or_null("FootballHud")
	if hud != null and hud.has_method("update_snapshot") and football.has_method("debug_build_hud_snapshot"):
		hud.call("update_snapshot", football.call("debug_build_hud_snapshot"))
		if hud.has_method("show_announcement"):
			hud.call("show_announcement", "SUPER PRONTO", 0.9, &"super_ready")

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
	print("[track06d-capture] %s" % output_path)
	return image

func _assert_night_environment_config(football: Node3D, capture_scene_label: String) -> void:
	var world_environment := football.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null:
		push_error("[track06d-capture] %s missing WorldEnvironment" % capture_scene_label)
		quit(1)
		return
	var environment := world_environment.environment
	if environment == null:
		push_error("[track06d-capture] %s missing Environment resource" % capture_scene_label)
		quit(1)
		return
	if environment.tonemap_mode != Environment.TONE_MAPPER_ACES:
		push_error("[track06d-capture] %s environment tonemap is not ACES" % capture_scene_label)
		quit(1)
	if environment.background_mode != Environment.BG_SKY:
		push_error("[track06d-capture] %s environment background is not BG_SKY" % capture_scene_label)
		quit(1)
	var sky_material: ProceduralSkyMaterial = null
	if environment.sky != null:
		sky_material = environment.sky.sky_material as ProceduralSkyMaterial
	if sky_material == null:
		push_error("[track06d-capture] %s sky material is missing" % capture_scene_label)
		quit(1)
		return
	var sky_luma := _color_luma_255(sky_material.sky_top_color)
	print("[track06d-capture] %s configured sky_top_luma=%.1f" % [capture_scene_label, sky_luma])
	if sky_luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track06d-capture] %s configured sky top is too bright: %.1f" % [capture_scene_label, sky_luma])
		quit(1)

func _assert_night_capture_luminance(image: Image, capture_scene_label: String, file_name: String) -> float:
	var luma := _sample_sky_region_luma_255(image)
	print("[track06d-capture] %s captured sky_luma=%.1f file=%s" % [capture_scene_label, luma, file_name])
	if luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track06d-capture] %s captured sky luma %.1f exceeds night gate %.1f for %s" % [
			capture_scene_label,
			luma,
			NIGHT_SKY_MAX_LUMA_255,
			file_name,
		])
		quit(1)
	return luma

func _sample_sky_region_luma_255(image: Image) -> float:
	var width := image.get_width()
	var height := image.get_height()
	var x_start := int(round(float(width) * SKY_SAMPLE_LEFT_RATIO))
	var x_end := int(round(float(width) * SKY_SAMPLE_RIGHT_RATIO))
	var y_start := int(round(float(height) * SKY_SAMPLE_TOP_RATIO))
	var y_end := int(round(float(height) * SKY_SAMPLE_BOTTOM_RATIO))
	var total := 0.0
	var count := 0
	for y in range(y_start, y_end, 6):
		for x in range(x_start, x_end, 6):
			total += _color_luma_255(image.get_pixel(x, y))
			count += 1
	if count <= 0:
		return 255.0
	return total / float(count)

func _color_luma_255(color: Color) -> float:
	return ((0.2126 * color.r) + (0.7152 * color.g) + (0.0722 * color.b)) * 255.0

func _clear_football_fade(football: Node3D) -> void:
	var hud := football.get_node_or_null("FootballHud")
	if hud != null and hud.has_method("_set_fade_alpha_immediate"):
		hud.call("_set_fade_alpha_immediate", 0.0)

func _write_luma_report(output_dir_absolute: String) -> void:
	var output_path := "%s/hud-broadcast-luma.json" % output_dir_absolute
	var file := FileAccess.open(output_path, FileAccess.WRITE)
	if file == null:
		push_error("[track06d-capture] failed to write luma report: %s" % output_path)
		quit(1)
		return
	file.store_string(JSON.stringify(luma_rows, "\t"))
	file.close()
	print("[track06d-capture] %s" % output_path)

func _drain_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
