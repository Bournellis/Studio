extends RefCounted

static func build_visual_muzzle_origin(
	origin: Vector3,
	direction: Vector3,
	camera: Camera3D,
	right_offset: float,
	down_offset: float,
	forward_offset: float
) -> Vector3:
	var shot_direction := direction.normalized()
	var fallback_origin := origin + shot_direction * forward_offset
	if camera == null:
		return fallback_origin
	var camera_basis := camera.global_transform.basis
	var visual_origin := origin
	visual_origin += camera_basis.x.normalized() * right_offset
	visual_origin -= camera_basis.y.normalized() * down_offset
	visual_origin += shot_direction * forward_offset
	return visual_origin

static func build_projectile_direction(
	visual_origin: Vector3,
	aim_point: Vector3,
	fallback_direction: Vector3
) -> Vector3:
	var projectile_direction := aim_point - visual_origin
	if projectile_direction.length_squared() <= 0.0001:
		return fallback_direction.normalized()
	return projectile_direction.normalized()

static func get_pickup_respawn_duration(
	pickup_kind: StringName,
	health_respawn: float,
	overcharge_respawn: float
) -> float:
	return health_respawn if pickup_kind == &"health" else overcharge_respawn
