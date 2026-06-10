extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-03e-toon"
const CAPTURE_SIZE: Vector2i = Vector2i(1280, 720)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_pair()
	quit(exit_code)

func _capture_pair() -> int:
	if DisplayServer.get_name() == "headless":
		printerr("[toon-capture] run without --headless to render screenshots")
		return 1

	DisplayServer.window_set_size(CAPTURE_SIZE)
	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[toon-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)

	var off_path := await _capture_variant(false, "%s/track-03e-toon-off.png" % output_dir_absolute)
	var on_path := await _capture_variant(true, "%s/track-03e-toon-on.png" % output_dir_absolute)
	print("[toon-capture] OFF %s" % off_path)
	print("[toon-capture] ON  %s" % on_path)
	return 0

func _capture_variant(toon_enabled: bool, output_path: String) -> String:
	var packed_scene := load(FOOTBALL_SCENE_PATH) as PackedScene
	var football := packed_scene.instantiate()
	root.add_child(football)
	await process_frame
	football.debug_set_toon_render_enabled(toon_enabled)
	football.debug_start_match()
	football.debug_finish_kickoff_countdown()
	football.debug_force_ball_position(Vector3(0.0, 0.68, 3.0))
	for _frame in range(18):
		await process_frame
	var image := root.get_texture().get_image()
	image.save_png(output_path)
	football.queue_free()
	await process_frame
	return output_path
