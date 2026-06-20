class_name BotMovementExecutor


static func build_landing_commit_move(bot_position: Vector3, landing_target: Vector3) -> Vector3:
	var to_landing := landing_target - bot_position
	to_landing.y = 0.0
	if to_landing.length_squared() <= 0.0001:
		return Vector3.ZERO
	return to_landing.normalized()


static func build_reposition_move(bot_position: Vector3, navigation_target: Vector3, distance_management_move: Vector3, route_label: StringName, approach_lock_active: bool) -> Vector3:
	var to_destination := navigation_target - bot_position
	to_destination.y = 0.0
	if to_destination.length_squared() <= 0.0001:
		return distance_management_move
	if approach_lock_active:
		return to_destination.normalized()
	var route_weight := 0.16
	if route_label == &"health" or route_label == &"overcharge" or route_label == &"jump_pad" or route_label == &"high":
		route_weight = 0.0
	var desired := to_destination.normalized() + distance_management_move * route_weight
	if desired.length_squared() <= 0.0001:
		return Vector3.ZERO
	return desired.normalized()


static func build_strafe_move(to_target: Vector3, strafe_direction: float, distance_management_move: Vector3) -> Vector3:
	if to_target.length_squared() <= 0.0001:
		return Vector3.ZERO
	var lateral := Vector3(-to_target.z, 0.0, to_target.x).normalized() * strafe_direction
	var desired := lateral * 0.9 + distance_management_move * 0.65
	if desired.length_squared() <= 0.0001:
		return lateral
	return desired.normalized()


static func build_distance_management_move(
	to_target: Vector3,
	health_fraction: float,
	shoot_cooldown_remaining: float,
	shoot_cooldown: float,
	has_overcharge: bool,
	has_line_of_sight: bool,
	preferred_distance: float,
	critical_health_threshold: float,
	low_health_threshold: float
) -> Vector3:
	var distance := to_target.length()
	if distance <= 0.05:
		return Vector3.ZERO
	var forward := to_target.normalized()
	if health_fraction <= critical_health_threshold and distance < preferred_distance * 1.35:
		return -forward
	if health_fraction <= low_health_threshold and shoot_cooldown_remaining > shoot_cooldown * 0.5 and distance < preferred_distance:
		return -forward
	if has_overcharge and has_line_of_sight and distance > preferred_distance * 0.78:
		return forward
	if distance > preferred_distance + 1.25:
		return forward
	if distance < preferred_distance * 0.68:
		return -forward
	return Vector3.ZERO


static func build_speed_multiplier(
	is_reposition_state: bool,
	is_windup_state: bool,
	jump_pad_flight_active: bool,
	is_telegraphing: bool,
	jump_pad_air_steer_speed_multiplier: float,
	route_shot_speed_multiplier: float
) -> float:
	var speed_multiplier := 1.0
	if is_reposition_state:
		speed_multiplier = 1.05
	elif is_windup_state:
		speed_multiplier = 0.45
	if jump_pad_flight_active:
		speed_multiplier = minf(speed_multiplier, jump_pad_air_steer_speed_multiplier)
	if is_telegraphing and not is_windup_state:
		speed_multiplier = minf(speed_multiplier, route_shot_speed_multiplier)
	return speed_multiplier


static func build_velocity(desired_move: Vector3, move_speed: float, speed_multiplier: float, vertical_velocity: float, knockback: Vector3, launch_boost: Vector3) -> Vector3:
	var horizontal := desired_move
	if horizontal.length_squared() > 1.0:
		horizontal = horizontal.normalized()
	return horizontal * move_speed * speed_multiplier + Vector3(knockback.x, vertical_velocity + knockback.y, knockback.z) + launch_boost


static func resolve_navigation_target(
	bot_position: Vector3,
	destination: Vector3,
	jump_pad_routes: Array,
	blocked_route_timers: Dictionary,
	jump_height_goal_threshold: float,
	vertical_route_low_height_tolerance: float,
	jump_pad_route_distance: float
) -> Vector3:
	if destination.y <= bot_position.y + jump_height_goal_threshold:
		return destination
	var best_route := select_jump_pad_route_for_destination(bot_position, destination, jump_pad_routes, blocked_route_timers)
	if best_route.is_empty():
		return destination
	var best_pad: Vector3 = best_route.get("position", destination)
	var best_target: Vector3 = best_route.get("target", destination)
	if bot_position.y < best_target.y - vertical_route_low_height_tolerance:
		return best_pad
	if flat_distance_between(bot_position, best_target) > jump_pad_route_distance and destination.y > bot_position.y + jump_height_goal_threshold:
		return best_target
	return destination


static func select_jump_pad_landing_target(bot_position: Vector3, destination: Vector3, launch_velocity: Vector3, jump_pad_routes: Array, blocked_route_timers: Dictionary, jump_pad_route_distance: float) -> Vector3:
	var route := select_jump_pad_route_for_destination(bot_position, destination, jump_pad_routes, blocked_route_timers)
	if not route.is_empty():
		return route.get("target", destination)
	var horizontal_launch := Vector3(launch_velocity.x, 0.0, launch_velocity.z)
	if horizontal_launch.length_squared() <= 0.0001:
		horizontal_launch = Vector3.FORWARD
	var fallback := bot_position + horizontal_launch.normalized() * jump_pad_route_distance
	fallback.y = bot_position.y
	return fallback


static func select_jump_pad_route_for_destination(bot_position: Vector3, destination: Vector3, jump_pad_routes: Array, blocked_route_timers: Dictionary) -> Dictionary:
	if jump_pad_routes.is_empty():
		return {}
	var best_route: Dictionary = {}
	var best_score := 1000000.0
	for route: Dictionary in jump_pad_routes:
		var pad_position: Vector3 = route.get("position", Vector3.ZERO)
		var target_position: Vector3 = route.get("target", pad_position)
		var route_id: StringName = route.get("id", &"")
		var target_score := target_position.distance_to(destination) + bot_position.distance_to(pad_position) * 0.22
		if is_route_temporarily_blocked(route_id, blocked_route_timers):
			target_score += 1000.0
		if target_score < best_score:
			best_score = target_score
			best_route = route
	return best_route


static func destination_requires_jump_pad_route(
	bot_position: Vector3,
	destination: Vector3,
	jump_pad_routes: Array,
	blocked_route_timers: Dictionary,
	jump_height_goal_threshold: float,
	vertical_route_low_height_tolerance: float
) -> bool:
	if destination.y <= bot_position.y + jump_height_goal_threshold:
		return false
	var route := select_jump_pad_route_for_destination(bot_position, destination, jump_pad_routes, blocked_route_timers)
	if route.is_empty():
		return false
	var target_position: Vector3 = route.get("target", destination)
	return bot_position.y < target_position.y - vertical_route_low_height_tolerance


static func should_jump_toward_height_goal(
	is_reposition_state: bool,
	bot_position: Vector3,
	reposition_destination: Vector3,
	destination_requires_jump_pad: bool,
	jump_height_goal_threshold: float,
	jump_height_goal_distance: float
) -> bool:
	if not is_reposition_state:
		return false
	if destination_requires_jump_pad:
		return false
	var height_delta := reposition_destination.y - bot_position.y
	if height_delta < jump_height_goal_threshold:
		return false
	var flat_delta := reposition_destination - bot_position
	flat_delta.y = 0.0
	return flat_delta.length() <= jump_height_goal_distance


static func is_high_route_point(point: Vector3) -> bool:
	return point.y > 2.0


static func classify_route_point(point: Vector3, arena_half_extent: float) -> StringName:
	if is_high_route_point(point):
		return &"high"
	if absf(point.x) > arena_half_extent * 0.78:
		return &"flank"
	if absf(point.x) < 4.5 and absf(point.z) < 7.2:
		return &"center"
	return &"ground"


static func is_route_temporarily_blocked(route_key: StringName, blocked_route_timers: Dictionary) -> bool:
	if route_key == &"":
		return false
	return blocked_route_timers.has(route_key) and float(blocked_route_timers.get(route_key, 0.0)) > 0.0


static func flat_distance_between(first_point: Vector3, second_point: Vector3) -> float:
	var delta := first_point - second_point
	delta.y = 0.0
	return delta.length()
