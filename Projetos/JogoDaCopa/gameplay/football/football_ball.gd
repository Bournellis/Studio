class_name FootballBall3D
extends RigidBody3D

const BallPanelShader = preload("res://assets/football/football_ball_panels.gdshader")

@export var ball_radius: float = 0.48
@export var max_horizontal_speed: float = 34.0
@export var max_vertical_speed: float = 18.0
@export var anti_stuck_height: float = -3.0
@export var floor_wall_bounce: float = 0.86
@export var surface_friction: float = 0.38
@export var ground_roll_drag_per_second: float = 1.45
@export var ground_contact_height_margin: float = 0.18
@export var ground_drag_vertical_speed_limit: float = 1.2

var spawn_position: Vector3 = Vector3(0.0, 0.58, 0.0)
var last_kick_force: float = 0.0
var kick_count: int = 0
var dribble_control_count: int = 0
var reset_count: int = 0
var ball_mesh_instance: MeshInstance3D
var trail_particles: GPUParticles3D
var squash_timer: float = 0.0

func _ready() -> void:
	mass = 0.74
	gravity_scale = 1.0
	linear_damp = 0.05
	angular_damp = 0.46
	physics_material_override = _build_physics_material()
	contact_monitor = true
	max_contacts_reported = 8
	can_sleep = false
	_ensure_ball_nodes()

func _physics_process(delta: float) -> void:
	_apply_ground_roll_drag(delta)
	_clamp_velocity()
	_update_visual_asset(delta)
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
	sleeping = false
	linear_velocity += impulse
	angular_velocity += Vector3(-flat.z, 0.0, flat.x).normalized() * clampf(force * 0.18, 0.0, 8.0)
	last_kick_force = force
	kick_count += 1
	squash_timer = 0.18
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
	squash_timer = 0.0
	if ball_mesh_instance != null:
		ball_mesh_instance.scale = Vector3.ONE
	reset_count += 1

func debug_get_last_kick_force() -> float:
	return last_kick_force

func debug_get_kick_count() -> int:
	return kick_count

func debug_get_dribble_control_count() -> int:
	return dribble_control_count

func debug_get_reset_count() -> int:
	return reset_count

func debug_is_ground_rolling() -> bool:
	return _is_ground_rolling()

func debug_apply_ground_roll_drag(delta: float) -> void:
	_apply_ground_roll_drag(delta)

func debug_has_panel_asset_material() -> bool:
	return ball_mesh_instance != null and ball_mesh_instance.material_override is ShaderMaterial

func debug_has_speed_trail() -> bool:
	return trail_particles != null

func debug_get_ball_mesh_scale() -> Vector3:
	return ball_mesh_instance.scale if ball_mesh_instance != null else Vector3.ONE

func _clamp_velocity() -> void:
	var flat := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	if flat.length() > max_horizontal_speed:
		flat = flat.normalized() * max_horizontal_speed
	linear_velocity = Vector3(
		flat.x,
		clampf(linear_velocity.y, -max_vertical_speed, max_vertical_speed),
		flat.z
	)

func _apply_ground_roll_drag(delta: float) -> void:
	if not _is_ground_rolling():
		return
	var flat := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	if flat.length_squared() <= 0.0001:
		return
	var drag_factor := clampf(1.0 - ground_roll_drag_per_second * delta, 0.0, 1.0)
	var next_flat := flat * drag_factor
	linear_velocity = Vector3(next_flat.x, linear_velocity.y, next_flat.z)

func _is_ground_rolling() -> bool:
	return global_position.y <= ball_radius + ground_contact_height_margin and absf(linear_velocity.y) <= ground_drag_vertical_speed_limit

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
		mesh.radial_segments = 40
		mesh.rings = 20
		mesh_instance.mesh = mesh
		mesh_instance.material_override = _build_ball_material()
		add_child(mesh_instance)
	ball_mesh_instance = get_node_or_null("BallMesh") as MeshInstance3D

	if get_node_or_null("BallSpeedTrail") == null:
		trail_particles = GPUParticles3D.new()
		trail_particles.name = "BallSpeedTrail"
		trail_particles.amount = 42
		trail_particles.lifetime = 0.28
		trail_particles.emitting = false
		trail_particles.local_coords = false
		trail_particles.explosiveness = 0.0
		trail_particles.randomness = 0.35
		var trail_mesh := SphereMesh.new()
		trail_mesh.radius = 0.045
		trail_mesh.height = 0.09
		trail_mesh.radial_segments = 8
		trail_mesh.rings = 4
		trail_particles.draw_pass_1 = trail_mesh
		var process_material := ParticleProcessMaterial.new()
		process_material.gravity = Vector3.ZERO
		process_material.initial_velocity_min = 0.05
		process_material.initial_velocity_max = 0.25
		process_material.scale_min = 0.18
		process_material.scale_max = 0.54
		trail_particles.process_material = process_material
		add_child(trail_particles)
	trail_particles = get_node_or_null("BallSpeedTrail") as GPUParticles3D

func _build_ball_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = BallPanelShader
	return material

func _update_visual_asset(delta: float) -> void:
	if trail_particles != null:
		trail_particles.emitting = linear_velocity.length() > 10.5
	if ball_mesh_instance == null:
		return
	squash_timer = maxf(0.0, squash_timer - delta)
	var squash_strength := clampf(squash_timer / 0.18, 0.0, 1.0) * clampf(linear_velocity.length() / 24.0, 0.0, 1.0)
	ball_mesh_instance.scale = Vector3(1.0 + squash_strength * 0.08, 1.0 - squash_strength * 0.13, 1.0 + squash_strength * 0.08)

func _build_physics_material() -> PhysicsMaterial:
	var material := PhysicsMaterial.new()
	material.friction = clampf(surface_friction, 0.0, 1.0)
	material.bounce = clampf(floor_wall_bounce, 0.0, 1.0)
	return material
