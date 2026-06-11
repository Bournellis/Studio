extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-04e-web-spike"
const DESKTOP_SIZE: Vector2i = Vector2i(1920, 1080)
const CAPTURE_SCENE_META_KEY: String = "jogodacopa_capture_scene"

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
	_clear_football_fade(football)
	await _drain_frames(6)
	_save_capture(output_dir_absolute, file_name)
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
	print("[track04e-capture] %s" % output_path)

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
