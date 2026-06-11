class_name FootballBall3D
extends RigidBody3D

const BallPanelShader = preload("res://assets/football/football_ball_panels.gdshader")
const FIREBALL_ON_SPEED: float = 24.0
const FIREBALL_OFF_SPEED: float = 21.0

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
var toon_outline_mesh_instance: MeshInstance3D
var trail_particles: GPUParticles3D
var fireball_particles: GPUParticles3D
var squash_timer: float = 0.0
var speed_trail_active: bool = false
var fireball_active: bool = false
var toon_render_enabled: bool = false
var toon_outline_material: StandardMaterial3D

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
	teleport_to_spawn(next_spawn_position)

func teleport_to_spawn(next_spawn_position: Vector3) -> void:
	spawn_position = next_spawn_position
	reset_to_center()

func set_toon_render_enabled(is_enabled: bool) -> void:
	toon_render_enabled = is_enabled
	_sync_toon_outline_node()
	_update_fireball_material()

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
	freeze = true
	var next_transform := Transform3D(Basis(), spawn_position)
	global_transform = next_transform
	if is_inside_tree():
		PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM, next_transform)
		PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
		PhysicsServer3D.body_set_state(get_rid(), PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = true
	squash_timer = 0.0
	speed_trail_active = false
	fireball_active = false
	if trail_particles != null:
		trail_particles.emitting = false
	if fireball_particles != null:
		fireball_particles.emitting = false
	_update_fireball_material()
	if ball_mesh_instance != null:
		ball_mesh_instance.scale = Vector3.ONE
	reset_count += 1
	call_deferred("_finish_safe_reset")

func _finish_safe_reset() -> void:
	freeze = false
	sleeping = false

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

func debug_is_speed_trail_emitting() -> bool:
	return trail_particles != null and trail_particles.emitting

func debug_is_fireball_active() -> bool:
	return fireball_active

func debug_has_fireball_particles() -> bool:
	return fireball_particles != null

func debug_is_toon_render_enabled() -> bool:
	return toon_render_enabled

func debug_has_toon_outline() -> bool:
	return toon_outline_mesh_instance != null and toon_outline_mesh_instance.visible

func debug_get_ball_mesh_scale() -> Vector3:
	return ball_mesh_instance.scale if ball_mesh_instance != null else Vector3.ONE

func debug_update_visual_asset(delta: float) -> void:
	_update_visual_asset(delta)

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
	_sync_toon_outline_node()

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

	if get_node_or_null("BallFireTrail") == null:
		fireball_particles = GPUParticles3D.new()
		fireball_particles.name = "BallFireTrail"
		fireball_particles.amount = 56
		fireball_particles.lifetime = 0.22
		fireball_particles.emitting = false
		fireball_particles.local_coords = false
		fireball_particles.explosiveness = 0.0
		fireball_particles.randomness = 0.42
		var fire_mesh := SphereMesh.new()
		fire_mesh.radius = 0.06
		fire_mesh.height = 0.12
		fire_mesh.radial_segments = 8
		fire_mesh.rings = 4
		fire_mesh.material = _build_fireball_particle_material()
		fireball_particles.draw_pass_1 = fire_mesh
		var fire_process := ParticleProcessMaterial.new()
		fire_process.gravity = Vector3(0.0, 0.25, 0.0)
		fire_process.initial_velocity_min = 0.15
		fire_process.initial_velocity_max = 0.7
		fire_process.scale_min = 0.2
		fire_process.scale_max = 0.72
		fireball_particles.process_material = fire_process
		add_child(fireball_particles)
	fireball_particles = get_node_or_null("BallFireTrail") as GPUParticles3D

func _build_ball_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = BallPanelShader
	return material

func _update_visual_asset(delta: float) -> void:
	if trail_particles != null:
		var ball_speed := linear_velocity.length()
		if ball_speed > 10.5:
			speed_trail_active = true
		elif ball_speed < 9.0:
			speed_trail_active = false
		trail_particles.emitting = speed_trail_active
		if ball_speed > FIREBALL_ON_SPEED:
			fireball_active = true
		elif ball_speed < FIREBALL_OFF_SPEED:
			fireball_active = false
	if fireball_particles != null:
		fireball_particles.emitting = fireball_active
	_update_fireball_material()
	if ball_mesh_instance == null:
		return
	squash_timer = maxf(0.0, squash_timer - delta)
	var squash_strength := clampf(squash_timer / 0.18, 0.0, 1.0) * clampf(linear_velocity.length() / 24.0, 0.0, 1.0)
	ball_mesh_instance.scale = Vector3(1.0 + squash_strength * 0.08, 1.0 - squash_strength * 0.13, 1.0 + squash_strength * 0.08)

func _update_fireball_material() -> void:
	if ball_mesh_instance == null or not ball_mesh_instance.material_override is ShaderMaterial:
		return
	var material := ball_mesh_instance.material_override as ShaderMaterial
	material.set_shader_parameter("fireball_intensity", 1.0 if fireball_active else 0.0)
	material.set_shader_parameter("toon_intensity", 1.0 if toon_render_enabled else 0.0)

func _sync_toon_outline_node() -> void:
	if ball_mesh_instance == null:
		return
	toon_outline_mesh_instance = ball_mesh_instance.get_node_or_null("BallToonOutline") as MeshInstance3D
	if toon_outline_mesh_instance == null and toon_render_enabled:
		toon_outline_mesh_instance = MeshInstance3D.new()
		toon_outline_mesh_instance.name = "BallToonOutline"
		toon_outline_mesh_instance.mesh = ball_mesh_instance.mesh
		toon_outline_mesh_instance.scale = Vector3.ONE * 1.075
		toon_outline_mesh_instance.material_override = _get_toon_outline_material()
		toon_outline_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ball_mesh_instance.add_child(toon_outline_mesh_instance)
	if toon_outline_mesh_instance != null:
		toon_outline_mesh_instance.visible = toon_render_enabled
		toon_outline_mesh_instance.mesh = ball_mesh_instance.mesh
		toon_outline_mesh_instance.material_override = _get_toon_outline_material()

func _get_toon_outline_material() -> StandardMaterial3D:
	if toon_outline_material != null:
		return toon_outline_material
	toon_outline_material = StandardMaterial3D.new()
	toon_outline_material.albedo_color = Color(0.012, 0.016, 0.022, 1.0)
	toon_outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	toon_outline_material.cull_mode = BaseMaterial3D.CULL_FRONT
	return toon_outline_material

func _build_fireball_particle_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.36, 0.08, 0.82)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.28, 0.04, 1.0)
	material.emission_energy_multiplier = 1.8
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _build_physics_material() -> PhysicsMaterial:
	var material := PhysicsMaterial.new()
	material.friction = clampf(surface_friction, 0.0, 1.0)
	material.bounce = clampf(floor_wall_bounce, 0.0, 1.0)
	return material
