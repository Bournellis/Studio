extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-03l-arena"
const CAPTURE_SIZE: Vector2i = Vector2i(1920, 1080)

const CAPTURES: Array[Dictionary] = [
	{
		"name": "upper-perimeter-sealed.png",
		"position": Vector3(25.0, 10.6, -4.0),
		"target": Vector3(18.6, 8.1, -4.0),
	},
	{
		"name": "goal-front-top-panel.png",
		"position": Vector3(0.0, 7.4, -18.0),
		"target": Vector3(0.0, 5.4, -27.0),
	},
	{
		"name": "simple-corner-no-ramp.png",
		"position": Vector3(24.0, 8.2, 32.0),
		"target": Vector3(17.2, 0.6, 26.2),
	},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _capture_arena()
	quit(exit_code)

func _capture_arena() -> int:
	if DisplayServer.get_name() == "headless":
		printerr("[track03l-capture] run without --headless to render screenshots")
		return 1

	var scene_result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[track03l-capture] scene generation failed: %s" % str(scene_result.get("message", "")))
		return 1

	DisplayServer.window_set_size(CAPTURE_SIZE)
	root.size = CAPTURE_SIZE
	await process_frame

	var packed_scene := load(FOOTBALL_SCENE_PATH) as PackedScene
	if packed_scene == null:
		printerr("[track03l-capture] missing football scene")
		return 1
	var football := packed_scene.instantiate() as Node3D
	root.add_child(football)
	await _drain_frames(12)
	_hide_overlay_nodes(football)

	var camera := Camera3D.new()
	camera.name = "Track03LCaptureCamera"
	camera.fov = 58.0
	camera.near = 0.04
	camera.current = true
	football.add_child(camera)

	var output_dir_absolute := ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir_absolute)
	for capture: Dictionary in CAPTURES:
		camera.global_position = capture.get("position", Vector3.ZERO)
		camera.look_at(capture.get("target", Vector3.ZERO), Vector3.UP)
		await _drain_frames(8)
		var output_path := "%s/%s" % [output_dir_absolute, str(capture.get("name", "capture.png"))]
		root.get_texture().get_image().save_png(output_path)
		print("[track03l-capture] %s" % output_path)
	football.queue_free()
	await process_frame
	return 0

func _hide_overlay_nodes(football: Node3D) -> void:
	var hud := football.get_node_or_null("FootballHud") as CanvasLayer
	if hud != null:
		hud.visible = false
	var feedback := football.get_node_or_null("FeedbackController") as Node3D
	if feedback != null:
		feedback.visible = false

func _drain_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
