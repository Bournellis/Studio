class_name FootballChaseCamera
extends Node3D

@export var follow_distance: float = 8.4
@export var follow_height: float = 3.55
@export var look_ahead_distance: float = 3.1
@export var ball_focus_weight: float = 0.08
@export var far_ball_focus_weight: float = 0.1
@export var far_ball_focus_distance: float = 15.0
@export var position_smoothing: float = 10.0

var target: Node3D
var ball: Node3D
var camera: Camera3D
var last_focus_position: Vector3 = Vector3.ZERO
var last_desired_position: Vector3 = Vector3.ZERO
var last_ball_focus_weight: float = 0.0
var shake_time: float = 0.0
var shake_duration: float = 0.0
var shake_intensity: float = 0.0
var boost_fov_fraction: float = 0.0
var goal_focus_time: float = 0.0
var goal_focus_duration: float = 0.0

func _ready() -> void:
	_ensure_camera()
	if target != null:
		snap_to_target()

func _physics_process(delta: float) -> void:
	_update_camera(delta, false)

func configure(next_target: Node3D, next_ball: Node3D) -> void:
	target = next_target
	ball = next_ball
	_ensure_camera()
	camera.current = true
	if is_inside_tree():
		snap_to_target()

func snap_to_target() -> void:
	_update_camera(1.0, true)

func debug_get_camera() -> Camera3D:
	_ensure_camera()
	return camera

func debug_get_focus_position() -> Vector3:
	return last_focus_position

func debug_get_desired_position() -> Vector3:
	return last_desired_position

func debug_get_ball_focus_weight() -> float:
	return last_ball_focus_weight

func debug_get_boost_fov_fraction() -> float:
	return boost_fov_fraction

func debug_is_goal_focus_active() -> bool:
	return goal_focus_time > 0.0

func debug_is_configured() -> bool:
	return target != null and ball != null and camera != null

func play_shake(intensity: float, duration: float) -> void:
	shake_intensity = maxf(shake_intensity, intensity)
	shake_duration = maxf(0.01, duration)
	shake_time = maxf(shake_time, duration)

func set_boost_fov_fraction(next_fraction: float) -> void:
	boost_fov_fraction = clampf(next_fraction, 0.0, 1.0)

func focus_goal(duration: float = 0.4) -> void:
	goal_focus_duration = maxf(0.01, duration)
	goal_focus_time = goal_focus_duration

func _update_camera(delta: float, snap: bool) -> void:
	if target == null:
		return
	_ensure_camera()
	var forward := _get_target_forward()
	var target_focus := target.global_position + Vector3.UP * 1.12 + forward * look_ahead_distance
	var focus := target_focus
	if ball != null:
		var ball_focus := ball.global_position + Vector3.UP * 0.45
		var ball_distance := _flat_distance(target.global_position, ball.global_position)
		var distance_factor := clampf(ball_distance / maxf(0.01, far_ball_focus_distance), 0.0, 1.0)
		last_ball_focus_weight = lerpf(ball_focus_weight, far_ball_focus_weight, distance_factor)
		if goal_focus_time > 0.0:
			var goal_focus_alpha := clampf(goal_focus_time / maxf(0.01, goal_focus_duration), 0.0, 1.0)
			last_ball_focus_weight = maxf(last_ball_focus_weight, lerpf(0.32, 0.72, goal_focus_alpha))
		focus = target_focus.lerp(ball_focus, clampf(last_ball_focus_weight, 0.0, 0.75))
	else:
		last_ball_focus_weight = 0.0

	var desired := target.global_position - forward * follow_distance + Vector3.UP * follow_height
	last_focus_position = focus
	last_desired_position = desired

	if snap or global_position == Vector3.ZERO:
		global_position = desired
	else:
		global_position = global_position.lerp(desired, clampf(position_smoothing * delta, 0.0, 1.0))

	if global_position.distance_squared_to(focus) > 0.0001:
		look_at(focus, Vector3.UP)
	_update_camera_fx(delta)

func _update_camera_fx(delta: float) -> void:
	_ensure_camera()
	if camera == null:
		return
	var base_fov := 82.0
	var goal_focus_boost := 3.5 if goal_focus_time > 0.0 else 0.0
	camera.fov = lerpf(base_fov, 89.0, boost_fov_fraction) + goal_focus_boost
	if shake_time > 0.0:
		shake_time = maxf(0.0, shake_time - delta)
		var shake_alpha := shake_time / maxf(0.01, shake_duration)
		var offset := Vector3(
			sin(float(Time.get_ticks_msec()) * 0.041) * shake_intensity * shake_alpha,
			cos(float(Time.get_ticks_msec()) * 0.037) * shake_intensity * shake_alpha,
			0.0
		)
		camera.position = offset
	else:
		shake_intensity = 0.0
		camera.position = Vector3.ZERO
	goal_focus_time = maxf(0.0, goal_focus_time - delta)

func _get_target_forward() -> Vector3:
	if target == null:
		return Vector3.FORWARD
	var forward := -target.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		return Vector3.FORWARD
	return forward.normalized()

func _ensure_camera() -> void:
	camera = get_node_or_null("Camera3D") as Camera3D
	if camera != null:
		return
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = 82.0
	camera.near = 0.04
	camera.far = 220.0
	add_child(camera)

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
