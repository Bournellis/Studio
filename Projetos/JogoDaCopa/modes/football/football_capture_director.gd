class_name FootballCaptureDirector
extends RefCounted

const CAPTURE_SCENE_META_KEY: String = "jogodacopa_capture_scene"
const CAPTURE_SCENE_KICKOFF: StringName = &"kickoff"
const CAPTURE_SCENE_GOAL: StringName = &"goal"
const CAPTURE_SCENE_RESULT: StringName = &"result"
const CAPTURE_SCENE_PLAY: StringName = &"play"
const CAPTURE_KICKOFF_COUNTDOWN_SECONDS: float = 2.8
const CAPTURE_GOAL_HOLD_SECONDS: float = 30.0
const CAPTURE_CAMERA_NAME: String = "Track04ECaptureCamera"
const CAPTURE_CAMERA_FOV: float = 50.0
const CAPTURE_CAMERA_NEAR: float = 0.04
const CAPTURE_CAMERA_FAR: float = 220.0
const CAPTURE_CAMERA_KICKOFF_POSITION: Vector3 = Vector3(29.0, 13.2, 34.0)
const CAPTURE_CAMERA_KICKOFF_TARGET: Vector3 = Vector3(0.0, 1.9, 1.5)
const CAPTURE_CAMERA_GOAL_POSITION: Vector3 = Vector3(-29.0, 13.2, -34.0)
const CAPTURE_CAMERA_GOAL_TARGET: Vector3 = Vector3(0.0, 1.9, -1.5)
const CAPTURE_CAMERA_RESULT_POSITION: Vector3 = Vector3(-31.0, 13.4, 31.0)
const CAPTURE_CAMERA_RESULT_TARGET: Vector3 = Vector3(0.0, 2.0, -2.0)
const CAPTURE_CAMERA_PLAY_POSITION: Vector3 = Vector3(29.0, 13.2, 34.0)
const CAPTURE_CAMERA_PLAY_TARGET: Vector3 = Vector3(0.0, 1.9, 1.5)
const CAPTURE_CAMERA_POSES: Dictionary = {
	CAPTURE_SCENE_KICKOFF: {
		"position": CAPTURE_CAMERA_KICKOFF_POSITION,
		"target": CAPTURE_CAMERA_KICKOFF_TARGET,
	},
	CAPTURE_SCENE_GOAL: {
		"position": CAPTURE_CAMERA_GOAL_POSITION,
		"target": CAPTURE_CAMERA_GOAL_TARGET,
	},
	CAPTURE_SCENE_RESULT: {
		"position": CAPTURE_CAMERA_RESULT_POSITION,
		"target": CAPTURE_CAMERA_RESULT_TARGET,
	},
	CAPTURE_SCENE_PLAY: {
		"position": CAPTURE_CAMERA_PLAY_POSITION,
		"target": CAPTURE_CAMERA_PLAY_TARGET,
	},
}


static func apply_from_meta(root: Node3D, tree: SceneTree) -> void:
	if tree == null or tree.root == null or not tree.root.has_meta(CAPTURE_SCENE_META_KEY):
		return
	var capture_scene_id := StringName(str(tree.root.get_meta(CAPTURE_SCENE_META_KEY)))
	tree.root.remove_meta(CAPTURE_SCENE_META_KEY)
	if not is_capture_scene_supported(capture_scene_id):
		push_error("Unsupported JogoDaCopa capture scene in FootballRoot: %s" % str(capture_scene_id))
		return
	root.capture_scene_active = true
	match capture_scene_id:
		CAPTURE_SCENE_KICKOFF:
			_apply_kickoff_capture_scene(root)
		CAPTURE_SCENE_GOAL:
			_apply_goal_capture_scene(root)
		CAPTURE_SCENE_RESULT:
			_apply_result_capture_scene(root)
		CAPTURE_SCENE_PLAY:
			_apply_play_capture_scene(root)
	_clear_capture_fade(root)
	_apply_evidence_capture_camera(root, capture_scene_id)


static func is_capture_scene_supported(capture_scene_id: StringName) -> bool:
	return (
		capture_scene_id == CAPTURE_SCENE_KICKOFF
		or capture_scene_id == CAPTURE_SCENE_GOAL
		or capture_scene_id == CAPTURE_SCENE_RESULT
		or capture_scene_id == CAPTURE_SCENE_PLAY
	)


static func _prepare_capture_scene(root: Node3D) -> void:
	root.set_bot_difficulty(&"normal")
	root.set_match_mode(root.MATCH_MODE_GOALS)
	root._set_intro_open(false)
	root._set_menu_open(false)
	if root.hud != null:
		root.hud.reset_feedback()


static func _apply_kickoff_capture_scene(root: Node3D) -> void:
	_prepare_capture_scene(root)
	root.debug_start_match_with_countdown()
	root.kickoff_countdown_remaining = CAPTURE_KICKOFF_COUNTDOWN_SECONDS
	root.countdown_last_number = 3


static func _apply_goal_capture_scene(root: Node3D) -> void:
	_prepare_capture_scene(root)
	root.debug_start_match()
	root._notify_ball_touched_by(&"player")
	root.debug_force_ball_position(Vector3(0.0, 0.68, root.GOAL_LINE_NORTH - 0.35))
	root._process_goal_detection()
	root.goal_slowmo_remaining = 0.0
	Engine.time_scale = 1.0
	if root.hud != null and root.hud.has_method("_set_fade_alpha_immediate"):
		root.hud.call("_set_fade_alpha_immediate", 0.0)
	root.goal_reset_timer = CAPTURE_GOAL_HOLD_SECONDS


static func _apply_result_capture_scene(root: Node3D) -> void:
	_prepare_capture_scene(root)
	root.debug_start_match()
	root._record_goal_stat(true, 1)
	root._record_goal_stat(false, 1)
	root._record_goal_stat(true, 1)
	root._notify_ball_touched_by(&"player")
	root._notify_ball_touched_by(&"bot")
	root._notify_ball_touched_by(&"player")
	root._record_shot_stat(&"player", true)
	root._record_shot_stat(&"player", false)
	root._record_shot_stat(&"bot", false)
	root.debug_set_score(2, 1)
	root.debug_force_ball_position(Vector3(0.0, 0.68, root.GOAL_LINE_NORTH - 0.35))
	root._process_goal_detection()


static func _apply_play_capture_scene(root: Node3D) -> void:
	_prepare_capture_scene(root)
	root.debug_start_match()
	if root.PerfProbeScript.is_scenario_enabled(root):
		root._start_perf_scenario()


static func _apply_evidence_capture_camera(root: Node3D, capture_scene_id: StringName) -> void:
	if not CAPTURE_CAMERA_POSES.has(capture_scene_id):
		push_error("Missing Track04E capture camera pose for scene: %s" % str(capture_scene_id))
		return
	var pose: Dictionary = CAPTURE_CAMERA_POSES[capture_scene_id]
	var camera := root.get_node_or_null(CAPTURE_CAMERA_NAME) as Camera3D
	if camera == null:
		camera = Camera3D.new()
		camera.name = CAPTURE_CAMERA_NAME
		root.add_child(camera)
	var gameplay_camera: Camera3D = null
	if root.chase_camera != null and root.chase_camera.has_method("debug_get_camera"):
		gameplay_camera = root.chase_camera.call("debug_get_camera") as Camera3D
	if gameplay_camera != null:
		gameplay_camera.current = false
	camera.fov = CAPTURE_CAMERA_FOV
	camera.near = CAPTURE_CAMERA_NEAR
	camera.far = CAPTURE_CAMERA_FAR
	camera.global_position = pose["position"]
	camera.look_at(pose["target"], Vector3.UP)
	camera.current = true
	print("[jdc_capture] scene=%s camera=%s fov=%.1f pos=%s target=%s" % [
		str(capture_scene_id),
		CAPTURE_CAMERA_NAME,
		camera.fov,
		str(camera.global_position),
		str(pose["target"]),
	])


static func _clear_capture_fade(root: Node3D) -> void:
	if root.hud != null and root.hud.has_method("_set_fade_alpha_immediate"):
		root.hud.call("_set_fade_alpha_immediate", 0.0)
