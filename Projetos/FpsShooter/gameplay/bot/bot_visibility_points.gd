extends RefCounted

static func build_target_points(
	target,
	fallback_target_position: Vector3,
	head_height: float,
	upper_height: float,
	center_height: float,
	lower_height: float
) -> Array[Vector3]:
	var points: Array[Vector3] = []
	if target == null:
		return points
	if target.has_method("get_shot_origin"):
		append_unique_point(points, target.get_shot_origin())
	var target_base: Vector3 = target.global_position
	append_unique_point(points, target_base + Vector3.UP * head_height)
	append_unique_point(points, target_base + Vector3.UP * upper_height)
	append_unique_point(points, fallback_target_position)
	append_unique_point(points, target_base + Vector3.UP * center_height)
	append_unique_point(points, target_base + Vector3.UP * lower_height)
	return points

static func append_unique_point(points: Array[Vector3], target_point: Vector3) -> void:
	for existing_point: Vector3 in points:
		if existing_point.distance_squared_to(target_point) <= 0.0001:
			return
	points.append(target_point)
