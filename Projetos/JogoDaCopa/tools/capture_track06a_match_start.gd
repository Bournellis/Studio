extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-06a"
const CAPTURE_SIZE: Vector2i = Vector2i(1920, 1080)
const NIGHT_SKY_MAX_LUMA_255: float = 90.0
const SKY_SAMPLE_TOP_RATIO: float = 0.04
const SKY_SAMPLE_BOTTOM_RATIO: float = 0.28
const SKY_SAMPLE_LEFT_RATIO: float = 0.62
const SKY_SAMPLE_RIGHT_RATIO: float = 0.96

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_track06a()
	quit(exit_code)

func _capture_track06a() -> int:
	if DisplayServer.get_name().to_lower().contains("headless"):
		printerr("[track06a-capture] run without --headless to render screenshots")
		return 1

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[track06a-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	_set_window_size(CAPTURE_SIZE)
	await _capture_menu(output_dir_absolute)
	await _capture_match_sequence(output_dir_absolute)
	return 0

func _capture_menu(output_dir_absolute: String) -> void:
	var menu := _instantiate_menu()
	root.add_child(menu)
	await _drain_frames(12)
	_clear_menu_fade(menu)
	await _drain_frames(8)
	_save_capture(output_dir_absolute, "menu.png")
	menu.queue_free()
	await _drain_frames(4)

func _capture_match_sequence(output_dir_absolute: String) -> void:
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(18)
	_assert_night_environment_config(football, "match")
	_clear_football_fade(football)
	football.debug_start_match_with_countdown()
	await _drain_frames(6)
	var camera := _build_match_camera(football)
	_position_camera_for_kickoff(camera)
	await _drain_frames(8)
	var image := _save_capture(output_dir_absolute, "kickoff-facing-hud-clean.png")
	_assert_night_capture_luminance(image, "kickoff-facing-hud-clean.png")
	image = _save_capture(output_dir_absolute, "hud-no-hints-no-crosshair.png")
	_assert_night_capture_luminance(image, "hud-no-hints-no-crosshair.png")

	football.debug_finish_kickoff_countdown()
	football.debug_release_bot_kickoff_hold()
	await _capture_run_sequence(football, camera, output_dir_absolute)
	await _capture_kick(football, camera, output_dir_absolute)
	await _capture_goal(football, camera, output_dir_absolute)
	football.queue_free()
	await _drain_frames(4)

func _capture_run_sequence(football: Node3D, camera: Camera3D, output_dir_absolute: String) -> void:
	var player := football.debug_get_player() as Node3D
	var avatar = football.debug_get_player_avatar()
	if player == null or avatar == null:
		return
	var frame_positions: Array[Vector3] = [
		Vector3(-1.8, 0.05, 15.4),
		Vector3(-1.1, 0.05, 14.6),
		Vector3(-0.35, 0.05, 13.75),
		Vector3(0.35, 0.05, 12.9),
	]
	for index in range(frame_positions.size()):
		player.global_position = frame_positions[index]
		player.velocity = Vector3(4.2, 0.0, -5.4)
		football._update_avatar_states(0.15)
		_position_camera_for_player(camera, player.global_position)
		await _drain_frames(9)
		_save_capture(output_dir_absolute, "run-frame-%02d.png" % [index + 1])

func _capture_kick(football: Node3D, camera: Camera3D, output_dir_absolute: String) -> void:
	var player := football.debug_get_player() as Node3D
	if player == null:
		return
	player.global_position = Vector3(0.0, 0.05, 14.0)
	player.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO
	football._update_avatar_states(0.15)
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0)
	_position_camera_for_player(camera, player.global_position)
	await _drain_frames(8)
	_save_capture(output_dir_absolute, "kick-moment.png")

func _capture_goal(football: Node3D, camera: Camera3D, output_dir_absolute: String) -> void:
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()
	football.goal_reset_timer = 4.0
	_position_camera_for_goal(camera)
	await _drain_frames(54)
	var image := _save_capture(output_dir_absolute, "goal.png")
	_assert_night_capture_luminance(image, "goal.png")

func _instantiate_menu() -> Control:
	var packed_scene := load(MENU_SCENE_PATH) as PackedScene
	return packed_scene.instantiate() as Control

func _instantiate_football() -> Node3D:
	var packed_scene := load(FOOTBALL_SCENE_PATH) as PackedScene
	return packed_scene.instantiate() as Node3D

func _build_match_camera(football: Node3D) -> Camera3D:
	var camera := Camera3D.new()
	camera.name = "Track06ACaptureCamera"
	camera.fov = 46.0
	camera.near = 0.04
	camera.current = true
	football.add_child(camera)
	return camera

func _position_camera_for_kickoff(camera: Camera3D) -> void:
	camera.fov = 46.0
	camera.global_position = Vector3(0.0, 3.3, 30.5)
	camera.look_at(Vector3(0.0, 1.35, 4.0), Vector3.UP)

func _position_camera_for_player(camera: Camera3D, player_position: Vector3) -> void:
	camera.fov = 40.0
	camera.global_position = player_position + Vector3(2.6, 1.65, 7.2)
	camera.look_at(player_position + Vector3(0.0, 1.08, -1.2), Vector3.UP)

func _position_camera_for_goal(camera: Camera3D) -> void:
	camera.fov = 50.0
	camera.global_position = Vector3(-29.0, 13.2, -34.0)
	camera.look_at(Vector3(0.0, 1.9, -1.5), Vector3.UP)

func _set_window_size(capture_size: Vector2i) -> void:
	DisplayServer.window_set_size(capture_size)
	root.size = capture_size

func _save_capture(output_dir_absolute: String, file_name: String) -> Image:
	var output_path := "%s/%s" % [output_dir_absolute, file_name]
	var image := root.get_texture().get_image()
	image.save_png(output_path)
	print("[track06a-capture] %s" % output_path)
	return image

func _assert_night_environment_config(football: Node3D, capture_scene_label: String) -> void:
	var world_environment := football.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null:
		push_error("[track06a-capture] %s missing WorldEnvironment" % capture_scene_label)
		quit(1)
		return
	var environment := world_environment.environment
	if environment == null:
		push_error("[track06a-capture] %s missing Environment resource" % capture_scene_label)
		quit(1)
		return
	if environment.tonemap_mode != Environment.TONE_MAPPER_ACES:
		push_error("[track06a-capture] %s environment tonemap is not ACES" % capture_scene_label)
		quit(1)
	if environment.background_mode != Environment.BG_SKY:
		push_error("[track06a-capture] %s environment background is not BG_SKY" % capture_scene_label)
		quit(1)
	var sky_material: ProceduralSkyMaterial = null
	if environment.sky != null:
		sky_material = environment.sky.sky_material as ProceduralSkyMaterial
	if sky_material == null:
		push_error("[track06a-capture] %s sky material is missing" % capture_scene_label)
		quit(1)
		return
	var sky_luma := _color_luma_255(sky_material.sky_top_color)
	print("[track06a-capture] %s configured sky_top_luma=%.1f" % [capture_scene_label, sky_luma])
	if sky_luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track06a-capture] %s configured sky top is too bright: %.1f" % [capture_scene_label, sky_luma])
		quit(1)

func _assert_night_capture_luminance(image: Image, file_name: String) -> void:
	var luma := _sample_sky_region_luma_255(image)
	print("[track06a-capture] captured sky_luma=%.1f file=%s" % [luma, file_name])
	if luma >= NIGHT_SKY_MAX_LUMA_255:
		push_error("[track06a-capture] captured sky luma %.1f exceeds night gate %.1f for %s" % [
			luma,
			NIGHT_SKY_MAX_LUMA_255,
			file_name,
		])
		quit(1)

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
