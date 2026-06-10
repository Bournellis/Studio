class_name FootballChaseCamera
extends Node3D

@export var follow_distance: float = 7.4
@export var follow_height: float = 3.15
@export var look_ahead_distance: float = 2.35
@export var ball_focus_weight: float = 0.28
@export var far_ball_focus_weight: float = 0.44
@export var far_ball_focus_distance: float = 15.0
@export var position_smoothing: float = 10.0

var target: Node3D
var ball: Node3D
var camera: Camera3D
var last_focus_position: Vector3 = Vector3.ZERO
var last_desired_position: Vector3 = Vector3.ZERO
var last_ball_focus_weight: float = 0.0

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

func debug_is_configured() -> bool:
	return target != null and ball != null and camera != null

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
	camera.fov = 78.0
	camera.near = 0.04
	camera.far = 220.0
	add_child(camera)

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
