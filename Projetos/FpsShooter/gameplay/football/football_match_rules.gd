extends RefCounted

static func can_reach_ball(
	origin: Vector3,
	direction: Vector3,
	ball_position: Vector3,
	ball_radius: float,
	kick_reach: float
) -> bool:
	var shot_direction := direction.normalized()
	if shot_direction.length_squared() <= 0.0001:
		return false
	var to_ball := ball_position - origin
	if to_ball.length() > kick_reach + 0.7:
		return false
	var projected := to_ball.dot(shot_direction)
	if projected < -0.15 or projected > kick_reach + 0.85:
		return false
	var closest := origin + shot_direction * projected
	return closest.distance_to(ball_position) <= ball_radius + 0.75

static func build_kick_direction(
	origin: Vector3,
	direction: Vector3,
	ball_position: Vector3,
	fallback_forward: Vector3
) -> Vector3:
	var camera_direction := direction.normalized()
	var to_ball := ball_position - origin
	var flat_to_ball := Vector3(to_ball.x, 0.0, to_ball.z)
	var flat_camera := Vector3(camera_direction.x, 0.0, camera_direction.z)
	if flat_camera.length_squared() <= 0.0001:
		flat_camera = fallback_forward
		flat_camera.y = 0.0
	var blended := flat_camera.normalized()
	if flat_to_ball.length_squared() > 0.0001:
		blended = (blended * 0.82 + flat_to_ball.normalized() * 0.18).normalized()
	return blended

static func get_player_contact_kick(
	player_position: Vector3,
	player_velocity: Vector3,
	ball_position: Vector3,
	touch_radius: float,
	minimum_touch_speed: float
) -> Dictionary:
	var player_center := player_position + Vector3.UP * 0.5
	var delta := ball_position - player_center
	var flat_delta := Vector3(delta.x, 0.0, delta.z)
	if flat_delta.length() > touch_radius:
		return {"connected": false, "direction": Vector3.ZERO}
	var flat_velocity := Vector3(player_velocity.x, 0.0, player_velocity.z)
	if flat_velocity.length() < minimum_touch_speed:
		return {"connected": false, "direction": Vector3.ZERO}
	var contact_direction := (flat_delta.normalized() + flat_velocity.normalized() * 0.6).normalized()
	return {"connected": true, "direction": contact_direction}

static func detect_goal(ball_position: Vector3, goal_half_width: float, north_goal_line: float, south_goal_line: float) -> int:
	if absf(ball_position.x) > goal_half_width:
		return 0
	if ball_position.z <= north_goal_line:
		return 1
	if ball_position.z >= south_goal_line:
		return -1
	return 0

static func apply_goal_score(player_score: int, bot_score: int, player_scored: bool, goal_limit: int) -> Dictionary:
	var next_player_score := player_score
	var next_bot_score := bot_score
	if player_scored:
		next_player_score += 1
	else:
		next_bot_score += 1
	var player_won := next_player_score >= goal_limit
	var bot_won := next_bot_score >= goal_limit
	return {
		"player_score": next_player_score,
		"bot_score": next_bot_score,
		"match_over": player_won or bot_won,
		"player_won": player_won
	}
