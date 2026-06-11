class_name FootballChaseCamera
extends Node3D

@export var follow_distance: float = 8.4
@export var follow_height: float = 3.55
@export var look_ahead_distance: float = 3.1
@export var ball_focus_weight: float = 0.08
@export var far_ball_focus_weight: float = 0.1
@export var far_ball_focus_distance: float = 15.0
@export var position_smoothing: float = 10.0
@export var collision_margin: float = 0.34
@export var collision_mask: int = 0xFFFFFFFF

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
var dash_fov_time: float = 0.0
var dash_fov_duration: float = 0.0
var dash_fov_fraction: float = 0.0
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

func debug_get_dash_fov_fraction() -> float:
	return _get_dash_fov_fraction()

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

func play_dash_fov_kick(fraction: float = 0.5, duration: float = 0.22) -> void:
	dash_fov_fraction = clampf(fraction, 0.0, 1.0)
	dash_fov_duration = maxf(0.01, duration)
	dash_fov_time = maxf(dash_fov_time, dash_fov_duration)

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
	desired = _get_collision_clamped_position(focus, desired)
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
	var effective_fov_fraction := maxf(boost_fov_fraction, _get_dash_fov_fraction())
	camera.fov = lerpf(base_fov, 89.0, effective_fov_fraction) + goal_focus_boost
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
	dash_fov_time = maxf(0.0, dash_fov_time - delta)
	goal_focus_time = maxf(0.0, goal_focus_time - delta)

func _get_dash_fov_fraction() -> float:
	if dash_fov_time <= 0.0 or dash_fov_duration <= 0.0:
		return 0.0
	var alpha := dash_fov_time / dash_fov_duration
	return dash_fov_fraction * smoothstep(0.0, 1.0, alpha)

func _get_target_forward() -> Vector3:
	if target == null:
		return Vector3.FORWARD
	var forward := -target.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		return Vector3.FORWARD
	return forward.normalized()

func _get_collision_clamped_position(focus: Vector3, desired: Vector3) -> Vector3:
	if not is_inside_tree() or get_world_3d() == null:
		return desired
	if focus.distance_squared_to(desired) <= 0.0001:
		return desired
	var query := PhysicsRayQueryParameters3D.create(focus, desired)
	query.collision_mask = collision_mask
	query.hit_from_inside = true
	query.hit_back_faces = true
	var excluded: Array[RID] = []
	if target != null and target is CollisionObject3D:
		excluded.append((target as CollisionObject3D).get_rid())
	if ball != null and ball is CollisionObject3D:
		excluded.append((ball as CollisionObject3D).get_rid())
	query.exclude = excluded
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return desired
	var hit_position: Vector3 = hit.get("position", desired)
	var hit_normal: Vector3 = hit.get("normal", (focus - desired).normalized())
	return hit_position + hit_normal.normalized() * collision_margin

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
