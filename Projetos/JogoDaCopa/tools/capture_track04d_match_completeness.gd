extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-04d-match-completeness-v1"
const DESKTOP_SIZE: Vector2i = Vector2i(1920, 1080)
const HD_SIZE: Vector2i = Vector2i(1280, 720)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_track04d()
	quit(exit_code)

func _capture_track04d() -> int:
	if DisplayServer.get_name().to_lower().contains("headless"):
		printerr("[track04d-capture] run without --headless to render screenshots")
		return 1

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[track04d-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	await _capture_menu_hero(DESKTOP_SIZE, output_dir_absolute, "hero-menu-1920x1080.png")
	await _capture_menu_hero(HD_SIZE, output_dir_absolute, "hero-menu-1280x720.png")
	await _capture_pause_menu(DESKTOP_SIZE, output_dir_absolute)
	await _capture_result_with_stats(DESKTOP_SIZE, output_dir_absolute)
	await _capture_fade_sequence(DESKTOP_SIZE, output_dir_absolute)
	return 0

func _capture_menu_hero(capture_size: Vector2i, output_dir_absolute: String, file_name: String) -> void:
	_set_window_size(capture_size)
	var menu := _instantiate_menu()
	root.add_child(menu)
	await _drain_frames(8)
	_clear_menu_fade(menu)
	await _drain_frames(8)
	_save_capture(output_dir_absolute, file_name)
	menu.queue_free()
	await _drain_frames(3)

func _capture_pause_menu(capture_size: Vector2i, output_dir_absolute: String) -> void:
	_set_window_size(capture_size)
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(12)
	_clear_football_fade(football)
	football.debug_start_match()
	football._set_menu_open(true)
	_clear_football_fade(football)
	await _drain_frames(10)
	_save_capture(output_dir_absolute, "pause-menu-1920x1080.png")
	football.queue_free()
	await _drain_frames(3)

func _capture_result_with_stats(capture_size: Vector2i, output_dir_absolute: String) -> void:
	_set_window_size(capture_size)
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(12)
	_clear_football_fade(football)
	football.debug_set_match_mode(&"goals")
	football.debug_start_match()
	football._record_goal_stat(true, 1)
	football._record_goal_stat(false, 1)
	football._record_goal_stat(true, 1)
	football._notify_ball_touched_by(&"player")
	football._notify_ball_touched_by(&"player")
	football._notify_ball_touched_by(&"bot")
	football._notify_ball_touched_by(&"player")
	football._record_shot_stat(&"player", true)
	football._record_shot_stat(&"player", false)
	football._record_shot_stat(&"player", false)
	football._record_shot_stat(&"player", false)
	football._record_shot_stat(&"bot", false)
	football._record_shot_stat(&"bot", false)
	football.debug_set_score(2, 1)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()
	await _drain_frames(18)
	_save_capture(output_dir_absolute, "result-stats-simulated-match-1920x1080.png")
	football.queue_free()
	await _drain_frames(3)

func _capture_fade_sequence(capture_size: Vector2i, output_dir_absolute: String) -> void:
	_set_window_size(capture_size)
	var football := _instantiate_football()
	root.add_child(football)
	await _drain_frames(12)
	var hud := football.get_node("FootballHud") as FootballHud
	_clear_football_fade(football)
	await _drain_frames(2)
	_save_capture(output_dir_absolute, "fade-frame-01-start.png")
	hud.call("_set_fade_alpha_immediate", 1.0)
	await _drain_frames(2)
	_save_capture(output_dir_absolute, "fade-frame-02-black.png")
	hud.call("_set_fade_alpha_immediate", 0.0)
	await _drain_frames(2)
	_save_capture(output_dir_absolute, "fade-frame-03-clear.png")
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

func _save_capture(output_dir_absolute: String, file_name: String) -> void:
	var output_path := "%s/%s" % [output_dir_absolute, file_name]
	root.get_texture().get_image().save_png(output_path)
	print("[track04d-capture] %s" % output_path)

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
