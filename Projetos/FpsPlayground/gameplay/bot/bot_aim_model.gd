extends RefCounted

static func build_aim_position(
	base_target_position: Vector3,
	shot_origin: Vector3,
	shoot_range: float,
	close_range_error_radius: float,
	far_error_radius: float,
	pattern: Vector2
) -> Vector3:
	var to_target := base_target_position - shot_origin
	var flat := Vector3(to_target.x, 0.0, to_target.z)
	var distance := flat.length()
	var distance_factor := clampf(distance / maxf(1.0, shoot_range), 0.0, 1.0)
	var error_radius := lerpf(close_range_error_radius, far_error_radius, distance_factor)
	var right := Vector3.RIGHT
	if flat.length_squared() > 0.0001:
		var forward := flat.normalized()
		right = Vector3(-forward.z, 0.0, forward.x).normalized()
	return base_target_position + right * pattern.x * error_radius + Vector3.UP * pattern.y * error_radius

static func pattern_for_index(index: int) -> Vector2:
	match index % 6:
		0:
			return Vector2(0.12, 0.04)
		1:
			return Vector2(-0.28, 0.12)
		2:
			return Vector2(0.46, -0.05)
		3:
			return Vector2(-0.56, 0.16)
		4:
			return Vector2(0.72, 0.1)
		_:
			return Vector2(-0.18, -0.08)
