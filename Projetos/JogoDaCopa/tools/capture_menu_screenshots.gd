extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-03i-menu"
const CAPTURE_SIZES: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_menu()
	quit(exit_code)

func _capture_menu() -> int:
	if DisplayServer.get_name() == "headless":
		printerr("[menu-capture] run without --headless to render screenshots")
		return 1

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[menu-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	for capture_size: Vector2i in CAPTURE_SIZES:
		var output_path := "%s/menu-%dx%d.png" % [output_dir_absolute, capture_size.x, capture_size.y]
		await _capture_size(capture_size, output_path)
		print("[menu-capture] %s" % output_path)
	return 0

func _capture_size(capture_size: Vector2i, output_path: String) -> void:
	DisplayServer.window_set_size(capture_size)
	root.size = capture_size
	await process_frame

	var packed_scene := load(MENU_SCENE_PATH) as PackedScene
	var menu := packed_scene.instantiate() as Control
	root.add_child(menu)
	for _frame in range(24):
		await process_frame
	var image := root.get_texture().get_image()
	image.save_png(output_path)
	menu.queue_free()
	await process_frame
