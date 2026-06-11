extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const OUTPUT_DIR: String = "res://docs/screenshots/track-03l-arena"
const CAPTURE_SIZE: Vector2i = Vector2i(1920, 1080)
const MOVEMENT_FRAME_DELTA: float = 1.0 / 60.0
const CURVE_CAPTURE_INTERVAL_SECONDS: float = 0.15

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

const CURVE_CAPTURES: Array[Dictionary] = [
	{
		"name": "facing-curve-frame-01.png",
		"player_position": Vector3(-3.2, 0.05, 10.4),
		"velocity": Vector3(4.8, 0.0, -1.8),
	},
	{
		"name": "facing-curve-frame-02.png",
		"player_position": Vector3(-2.35, 0.05, 9.75),
		"velocity": Vector3(4.0, 0.0, -3.6),
	},
	{
		"name": "facing-curve-frame-03.png",
		"player_position": Vector3(-1.35, 0.05, 8.9),
		"velocity": Vector3(2.1, 0.0, -5.0),
	},
	{
		"name": "facing-curve-frame-04.png",
		"player_position": Vector3(-0.25, 0.05, 7.95),
		"velocity": Vector3(0.3, 0.0, -5.9),
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
	if football.has_method("debug_start_match"):
		football.call("debug_start_match")
	await _drain_frames(4)
	_hide_overlay_nodes(football)
	_prepare_capture_subjects(football)

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
		_save_capture(output_dir_absolute, str(capture.get("name", "capture.png")))
	await _capture_curve_sequence(football, camera, output_dir_absolute)
	await _capture_stopped_forward_pose(football, camera, output_dir_absolute)
	await _capture_old_gap_ball_rebound(football, camera, output_dir_absolute)
	football.queue_free()
	await process_frame
	return 0

func _prepare_capture_subjects(football: Node3D) -> void:
	var player := football.call("debug_get_player") as Node3D
	if player != null:
		player.rotation.y = 0.0
	var bot := football.call("debug_get_bot") as Node3D
	if bot != null:
		bot.visible = false
	var ball := football.call("debug_get_ball") as RigidBody3D
	if ball != null:
		ball.visible = false
		ball.global_position = Vector3(0.0, 0.68, 2.5)
		ball.linear_velocity = Vector3.ZERO
		ball.angular_velocity = Vector3.ZERO

func _capture_curve_sequence(football: Node3D, camera: Camera3D, output_dir_absolute: String) -> void:
	camera.fov = 43.0
	camera.global_position = Vector3(5.8, 2.8, 14.4)
	for capture: Dictionary in CURVE_CAPTURES:
		var player_position: Vector3 = capture.get("player_position", Vector3.ZERO)
		var velocity: Vector3 = capture.get("velocity", Vector3.FORWARD)
		_pose_player_for_capture(football, player_position, velocity, CURVE_CAPTURE_INTERVAL_SECONDS)
		camera.look_at(player_position + Vector3(0.0, 1.15, -0.25), Vector3.UP)
		await _drain_frames(int(round(CURVE_CAPTURE_INTERVAL_SECONDS / MOVEMENT_FRAME_DELTA)))
		_save_capture(output_dir_absolute, str(capture.get("name", "curve.png")))

func _capture_stopped_forward_pose(football: Node3D, camera: Camera3D, output_dir_absolute: String) -> void:
	var player_position := Vector3(0.0, 0.05, 9.0)
	_pose_player_for_capture(football, player_position, Vector3.FORWARD * 6.0, 0.45)
	_pose_player_for_capture(football, player_position + Vector3(0.0, 0.0, -0.8), Vector3.ZERO, 0.2)
	camera.fov = 39.0
	camera.global_position = Vector3(0.0, 2.05, 14.0)
	camera.look_at(player_position + Vector3(0.0, 1.05, -0.8), Vector3.UP)
	await _drain_frames(8)
	_save_capture(output_dir_absolute, "facing-stopped-forward-back-to-camera.png")

func _capture_old_gap_ball_rebound(football: Node3D, camera: Camera3D, output_dir_absolute: String) -> void:
	var ball := football.call("debug_get_ball") as RigidBody3D
	if ball == null:
		return
	ball.visible = true
	ball.global_position = Vector3(16.7, 7.72, -5.0)
	ball.linear_velocity = Vector3(34.0, 1.2, 0.0)
	ball.angular_velocity = Vector3(0.0, 0.0, -18.0)
	for _frame_index in range(60):
		await physics_frame
		if ball.linear_velocity.x < -2.0 and ball.global_position.x > 15.5:
			break
	camera.fov = 34.0
	camera.global_position = ball.global_position + Vector3(-3.2, 0.35, -2.6)
	camera.look_at(ball.global_position + Vector3(0.0, -0.15, 0.0), Vector3.UP)
	await _drain_frames(8)
	_save_capture(output_dir_absolute, "ball-old-gap-upper-wall-rebound.png")

func _hide_overlay_nodes(football: Node3D) -> void:
	var hud := football.get_node_or_null("FootballHud") as CanvasLayer
	if hud != null:
		hud.visible = false
	var feedback := football.get_node_or_null("FeedbackController") as Node3D
	if feedback != null:
		feedback.visible = false

func _pose_player_for_capture(football: Node3D, player_position: Vector3, horizontal_velocity: Vector3, duration_seconds: float) -> void:
	var player := football.call("debug_get_player") as Node3D
	var avatar = football.call("debug_get_player_avatar")
	if player == null or avatar == null:
		return
	player.global_position = player_position
	player.rotation.y = 0.0
	if player.get("velocity") is Vector3:
		player.set("velocity", horizontal_velocity)
	var frame_count := maxi(1, int(round(duration_seconds / MOVEMENT_FRAME_DELTA)))
	for _frame_index in range(frame_count):
		avatar.update_visual_movement_facing(horizontal_velocity, player.rotation.y, MOVEMENT_FRAME_DELTA)
	avatar.set_move_state(horizontal_velocity.length(), true, 0.0)
	if avatar.has_method("set_boost_trail_active"):
		avatar.call("set_boost_trail_active", horizontal_velocity.length() > 0.5)
	if avatar.has_method("set_skid_dust_active"):
		avatar.call("set_skid_dust_active", horizontal_velocity.length() > 0.5)

func _save_capture(output_dir_absolute: String, file_name: String) -> void:
	var output_path := "%s/%s" % [output_dir_absolute, file_name]
	root.get_texture().get_image().save_png(output_path)
	print("[track03l-capture] %s" % output_path)

func _drain_frames(count: int) -> void:
	for _index in range(count):
		await process_frame
