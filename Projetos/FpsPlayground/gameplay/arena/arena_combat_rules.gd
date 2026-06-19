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

static func calculate_overcharged_value(base_value: float, multiplier: float, overcharged: bool) -> float:
	return base_value * (multiplier if overcharged else 1.0)

static func calculate_sustained_damage_rate(damage: float, cooldown: float) -> float:
	return damage / maxf(0.001, cooldown)

static func calculate_blast_falloff(
	impact_position: Vector3,
	target_position: Vector3,
	blast_radius: float
) -> float:
	var safe_radius := maxf(0.001, blast_radius)
	var distance := impact_position.distance_to(target_position)
	if distance > safe_radius:
		return 0.0
	return clampf(1.0 - distance / safe_radius, 0.0, 1.0)

static func calculate_blast_damage(
	impact_position: Vector3,
	target_position: Vector3,
	blast_radius: float,
	max_damage: float,
	min_damage_fraction: float
) -> float:
	var falloff := calculate_blast_falloff(impact_position, target_position, blast_radius)
	if falloff <= 0.0:
		return 0.0
	var safe_minimum := clampf(min_damage_fraction, 0.0, 1.0)
	var damage_fraction := lerpf(safe_minimum, 1.0, falloff)
	return max_damage * damage_fraction
