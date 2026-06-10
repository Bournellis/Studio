class_name FootballBall3D
extends RigidBody3D

@export var ball_radius: float = 0.48
@export var max_horizontal_speed: float = 26.0
@export var max_vertical_speed: float = 9.0
@export var anti_stuck_height: float = -3.0

var spawn_position: Vector3 = Vector3(0.0, 0.58, 0.0)
var last_kick_force: float = 0.0
var kick_count: int = 0
var dribble_control_count: int = 0
var reset_count: int = 0

func _ready() -> void:
	gravity_scale = 1.0
	linear_damp = 0.55
	angular_damp = 0.72
	contact_monitor = true
	max_contacts_reported = 8
	can_sleep = false
	_ensure_ball_nodes()

func _physics_process(_delta: float) -> void:
	_clamp_velocity()
	if global_position.y < anti_stuck_height:
		reset_to_center()

func configure(next_spawn_position: Vector3) -> void:
	spawn_position = next_spawn_position
	reset_to_center()

func kick(direction: Vector3, force: float, lift: float = 0.0) -> void:
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.0001:
		flat = Vector3.FORWARD
	var impulse := flat.normalized() * maxf(0.0, force) + Vector3.UP * maxf(0.0, lift)
	linear_velocity += impulse
	angular_velocity += Vector3(-flat.z, 0.0, flat.x).normalized() * clampf(force * 0.18, 0.0, 8.0)
	last_kick_force = force
	kick_count += 1
	_clamp_velocity()

func apply_dribble_control(direction: Vector3, target_speed: float, blend: float) -> void:
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.0001:
		return
	var desired_flat := flat.normalized() * clampf(target_speed, 0.0, max_horizontal_speed)
	var current_flat := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	var next_flat := current_flat.lerp(desired_flat, clampf(blend, 0.0, 0.7))
	linear_velocity = Vector3(next_flat.x, linear_velocity.y, next_flat.z)
	angular_velocity += Vector3(-flat.z, 0.0, flat.x).normalized() * clampf(target_speed * 0.04, 0.0, 1.2)
	dribble_control_count += 1
	_clamp_velocity()

func reset_to_center() -> void:
	global_position = spawn_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false
	reset_count += 1

func debug_get_last_kick_force() -> float:
	return last_kick_force

func debug_get_kick_count() -> int:
	return kick_count

func debug_get_dribble_control_count() -> int:
	return dribble_control_count

func debug_get_reset_count() -> int:
	return reset_count

func _clamp_velocity() -> void:
	var flat := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	if flat.length() > max_horizontal_speed:
		flat = flat.normalized() * max_horizontal_speed
	linear_velocity = Vector3(
		flat.x,
		clampf(linear_velocity.y, -max_vertical_speed, max_vertical_speed),
		flat.z
	)

func _ensure_ball_nodes() -> void:
	if get_node_or_null("CollisionShape3D") == null:
		var collision := CollisionShape3D.new()
		collision.name = "CollisionShape3D"
		var sphere_shape := SphereShape3D.new()
		sphere_shape.radius = ball_radius
		collision.shape = sphere_shape
		add_child(collision)

	if get_node_or_null("BallMesh") == null:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "BallMesh"
		var mesh := SphereMesh.new()
		mesh.radius = ball_radius
		mesh.height = ball_radius * 2.0
		mesh.radial_segments = 24
		mesh.rings = 12
		mesh_instance.mesh = mesh
		mesh_instance.material_override = _build_ball_material()
		add_child(mesh_instance)

func _build_ball_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.96, 0.97, 0.92, 1.0)
	material.roughness = 0.48
	material.emission_enabled = true
	material.emission = Color(0.28, 0.62, 1.0, 1.0)
	material.emission_energy_multiplier = 0.08
	return material
