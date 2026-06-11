extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-04e-web-spike"
const DESKTOP_SIZE: Vector2i = Vector2i(1920, 1080)
const CAPTURE_SCENE_META_KEY: String = "jogodacopa_capture_scene"
const NIGHT_SKY_MAX_LUMA_255: float = 90.0
const SKY_SAMPLE_TOP_RATIO: float = 0.04
const SKY_SAMPLE_BOTTOM_RATIO: float = 0.28
const SKY_SAMPLE_LEFT_RATIO: float = 0.62
const SKY_SAMPLE_RIGHT_RATIO: float = 0.96

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_track04e()
	quit(exit_code)

func _capture_track04e() -> int:
	if DisplayServer.get_name().to_lower().contains("headless"):
		printerr("[track04e-capture] run without --headless to render screenshots")
		return 1

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[track04e-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	await _capture_menu_hero(output_dir_absolute)
	await _capture_football_scene(&"kickoff", output_dir_absolute, "desktop-kickoff-1920x1080.png", 24)
	await _capture_football_scene(&"goal", output_dir_absolute, "desktop-goal-1920x1080.png", 14)
	await _capture_football_scene(&"result", output_dir_absolute, "desktop-result-1920x1080.png", 24)
	await _capture_football_scene(&"play", output_dir_absolute, "desktop-play-1920x1080.png", 40)
	return 0

func _capture_menu_hero(output_dir_absolute: String) -> void:
	_set_window_size(DESKTOP_SIZE)
	var menu := _instantiate_menu()
	root.add_child(menu)
	await _drain_frames(8)
	_clear_menu_fade(menu)
	await _drain_frames(8)
	_save_capture(output_dir_absolute, "desktop-menu-hero-1920x1080.png")
	menu.queue_free()
	await _drain_frames(3)

func _capture_football_scene(capture_scene_id: StringName, output_dir_absolute: String, file_name: String, frame_count: int) -> void:
	_set_window_size(DESKTOP_SIZE)
	root.set_meta(CAPTURE_SCENE_META_KEY, capture_scene_id)
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(frame_count)
	_assert_night_environment_config(football, str(capture_scene_id))
	_log_active_camera(football, str(capture_scene_id))
	_clear_football_fade(football)
	await _drain_frames(6)
	var image := _save_capture(output_dir_absolute, file_name)
	_assert_night_capture_luminance(image, str(capture_scene_id), file_name)
	football.queue_free()
	await _drain_frames(3)

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
	print("[track04e-capture] %s" % output_path)
	return image

func _assert_night_environment_config(football: Node3D, capture_scene_label: String) -> void:
	var world_environment := football.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null:
		push_error("[track04e-capture] %s missing WorldEnvironment" % capture_scene_label)
		quit(1)
		return
	var environment := world_environment.environment
	if environment == null:
		push_error("[track04e-capture] %s missing Environment resource" % capture_scene_label)
		quit(1)
		return
	if environment.tonemap_mode != Environment.TONE_MAPPER_ACES:
		push_error("[track04e-capture] %s environment tonemap is not ACES" % capture_scene_label)
		quit(1)
	if environment.background_mode != Environment.BG_SKY:
		push_error("[track04e-capture] %s environment background is not BG_SKY" % capture_scene_label)
		quit(1)
	if environment.sky == null or environment.sky.sky_material == null:
		push_error("[track04e-capture] %s environment sky material is missing" % capture_scene_label)
		quit(1)
		return
	var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
	if sky_material == null:
		push_error("[track04e-capture] %s sky material is not ProceduralSkyMaterial" % capture_scene_label)
		quit(1)
		return
	var sky_luma := _color_luma_255(sky_material.sky_top_color)
	print("[track04e-capture] %s configured sky_top_luma=%.1f" % [capture_scene_label, sky_luma])
	if sky_luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track04e-capture] %s configured sky top is too bright: %.1f" % [capture_scene_label, sky_luma])
		quit(1)

func _assert_night_capture_luminance(image: Image, capture_scene_label: String, file_name: String) -> void:
	var luma := _sample_sky_region_luma_255(image)
	print("[track04e-capture] %s captured sky_luma=%.1f file=%s" % [capture_scene_label, luma, file_name])
	if luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track04e-capture] %s captured sky luma %.1f exceeds night gate %.1f" % [
			capture_scene_label,
			luma,
			NIGHT_SKY_MAX_LUMA_255,
		])
		quit(1)

func _log_active_camera(football: Node3D, capture_scene_label: String) -> void:
	var viewport := football.get_viewport()
	var camera := viewport.get_camera_3d() if viewport != null else null
	if camera == null:
		print("[track04e-capture] %s active camera=<none>" % capture_scene_label)
		return
	print("[track04e-capture] %s active camera=%s fov=%.1f pos=%s rot=%s" % [
		capture_scene_label,
		str(camera.get_path()),
		camera.fov,
		str(camera.global_position),
		str(camera.global_rotation_degrees),
	])

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

func _clear_menu_fade(menu: Control) -> void:
	if menu != null and menu.has_method("_set_fade_alpha_immediate"):
		menu.call("_set_fade_alpha_immediate", 0.0)

func _clear_football_fade(football: Node3D) -> void:
	var hud := football.get_node_or_null("FootballHud")
	if hud != null and hud.has_method("_set_fade_alpha_immediate"):
		hud.call("_set_fade_alpha_immediate", 0.0)

func _drain_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
