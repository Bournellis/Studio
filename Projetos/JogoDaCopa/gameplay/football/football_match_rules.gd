extends RefCounted

const MATCH_MODE_GOALS: StringName = &"goals"
const MATCH_MODE_TIMER: StringName = &"timer"
const TEAM_PLAYER: StringName = &"player"
const TEAM_BOT: StringName = &"bot"
const TEAM_NONE: StringName = &"none"
const PERIOD_FIRST_HALF: StringName = &"first_half"
const PERIOD_SECOND_HALF: StringName = &"second_half"
const PERIOD_GOLDEN_GOAL: StringName = &"golden_goal"
const PERIOD_REGULAR: StringName = &"regular"

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
	return closest.distance_to(ball_position) <= ball_radius + 0.45

static func get_kick_assist(
	origin: Vector3,
	direction: Vector3,
	ball_position: Vector3,
	ball_radius: float,
	kick_reach: float,
	assist_radius: float
) -> Dictionary:
	if can_reach_ball(origin, direction, ball_position, ball_radius, kick_reach):
		return {"connected": true, "assist_strength": 0.0}
	var flat_direction := _flatten_normalized(direction)
	if flat_direction.length_squared() <= 0.0001:
		return {"connected": false, "assist_strength": 0.0}
	var flat_delta := Vector3(ball_position.x - origin.x, 0.0, ball_position.z - origin.z)
	var distance := flat_delta.length()
	if distance > assist_radius or distance <= 0.0001:
		return {"connected": false, "assist_strength": 0.0}
	var forward_dot := flat_delta.normalized().dot(flat_direction)
	if forward_dot < -0.08:
		return {"connected": false, "assist_strength": 0.0}
	var projected := clampf(flat_delta.dot(flat_direction), 0.0, assist_radius)
	var closest := flat_direction * projected
	var side_distance := closest.distance_to(flat_delta)
	var side_limit := ball_radius + 0.72
	if side_distance > side_limit:
		return {"connected": false, "assist_strength": 0.0}
	var distance_strength := 1.0 - clampf((distance - kick_reach) / maxf(0.01, assist_radius - kick_reach), 0.0, 1.0)
	var side_strength := 1.0 - clampf(side_distance / side_limit, 0.0, 1.0)
	return {
		"connected": true,
		"assist_strength": clampf((distance_strength * 0.55 + side_strength * 0.45), 0.0, 1.0)
	}

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
		blended = (blended * 0.92 + flat_to_ball.normalized() * 0.08).normalized()
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

static func get_player_possession_state(
	player_position: Vector3,
	player_forward: Vector3,
	_player_velocity: Vector3,
	ball_position: Vector3,
	contact_radius: float,
	reach_radius: float
) -> Dictionary:
	var flat_forward := _flatten_normalized(player_forward)
	if flat_forward.length_squared() <= 0.0001:
		flat_forward = Vector3.FORWARD
	var player_center := player_position + Vector3.UP * 0.48
	var flat_delta := Vector3(ball_position.x - player_center.x, 0.0, ball_position.z - player_center.z)
	var distance := flat_delta.length()
	if distance <= 0.0001:
		return {
			"state": &"contact",
			"strength": 1.0,
			"direction": flat_forward
		}
	var ball_direction := flat_delta.normalized()
	var forward_dot := ball_direction.dot(flat_forward)
	var reachable := distance <= reach_radius and forward_dot >= -0.12
	var touching := distance <= contact_radius
	var state: StringName = &"free"
	if touching:
		state = &"contact"
	elif reachable:
		state = &"reachable"
	var dribble_direction := flat_forward
	var proximity_strength := 1.0 - clampf(distance / maxf(0.01, reach_radius), 0.0, 1.0)
	var facing_strength := clampf((forward_dot + 0.12) / 1.12, 0.0, 1.0)
	return {
		"state": state,
		"strength": clampf(proximity_strength * 0.62 + facing_strength * 0.38, 0.0, 1.0),
		"direction": dribble_direction
	}

static func detect_goal(ball_position: Vector3, goal_half_width: float, north_goal_line: float, south_goal_line: float, goal_height: float = 999.0) -> int:
	if absf(ball_position.x) > goal_half_width:
		return 0
	if ball_position.y > goal_height:
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

static func apply_goal_score_for_mode(
	player_score: int,
	bot_score: int,
	player_scored: bool,
	goal_limit: int,
	match_mode: StringName,
	time_remaining: float,
	double_goal_window: float,
	golden_goal_active: bool
) -> Dictionary:
	var goal_value := get_goal_value(match_mode, time_remaining, double_goal_window, golden_goal_active)
	if match_mode == MATCH_MODE_GOALS:
		var goal_score := apply_goal_score(player_score, bot_score, player_scored, goal_limit)
		goal_score["goal_value"] = 1
		goal_score["double_goal"] = false
		goal_score["golden_goal"] = false
		return goal_score

	var next_player_score := player_score
	var next_bot_score := bot_score
	if player_scored:
		next_player_score += goal_value
	else:
		next_bot_score += goal_value
	var player_won := player_scored if golden_goal_active else false
	return {
		"player_score": next_player_score,
		"bot_score": next_bot_score,
		"match_over": golden_goal_active,
		"player_won": player_won,
		"goal_value": goal_value,
		"double_goal": goal_value == 2,
		"golden_goal": golden_goal_active
	}

static func get_goal_value(match_mode: StringName, time_remaining: float, double_goal_window: float, golden_goal_active: bool) -> int:
	if match_mode != MATCH_MODE_TIMER or golden_goal_active:
		return 1
	if time_remaining > 0.0 and time_remaining <= double_goal_window:
		return 2
	return 1

static func resolve_timer_state(player_score: int, bot_score: int, time_remaining: float, match_mode: StringName, golden_goal_active: bool) -> Dictionary:
	if match_mode != MATCH_MODE_TIMER or golden_goal_active or time_remaining > 0.0:
		return {
			"match_over": false,
			"golden_goal_active": golden_goal_active,
			"player_won": false,
			"event": &"none"
		}
	if player_score == bot_score:
		return {
			"match_over": false,
			"golden_goal_active": true,
			"player_won": false,
			"event": &"golden_goal"
		}
	return {
		"match_over": true,
		"golden_goal_active": false,
		"player_won": player_score > bot_score,
		"event": &"timer_end"
	}

static func build_empty_match_stats() -> Dictionary:
	return {
		"player_goals_first_half": 0,
		"bot_goals_first_half": 0,
		"player_goals_second_half": 0,
		"bot_goals_second_half": 0,
		"player_goals_golden_goal": 0,
		"bot_goals_golden_goal": 0,
		"player_goals_regular": 0,
		"bot_goals_regular": 0,
		"player_goals_total": 0,
		"bot_goals_total": 0,
		"player_shots": 0,
		"bot_shots": 0,
		"player_supers": 0,
		"bot_supers": 0,
		"player_touches": 0,
		"bot_touches": 0,
		"current_touch_team": TEAM_NONE,
		"current_touch_streak": 0,
		"longest_touch_team": TEAM_NONE,
		"longest_touch_streak": 0
	}

static func get_match_period(match_mode: StringName, time_remaining: float, match_duration: float, golden_goal_active: bool) -> StringName:
	if golden_goal_active:
		return PERIOD_GOLDEN_GOAL
	if match_mode != MATCH_MODE_TIMER:
		return PERIOD_REGULAR
	var safe_duration := maxf(1.0, match_duration)
	var elapsed := clampf(safe_duration - maxf(0.0, time_remaining), 0.0, safe_duration)
	return PERIOD_FIRST_HALF if elapsed < safe_duration * 0.5 else PERIOD_SECOND_HALF

static func record_goal_stat(
	stats: Dictionary,
	player_scored: bool,
	goal_value: int,
	match_mode: StringName,
	time_remaining: float,
	match_duration: float,
	golden_goal_active: bool
) -> Dictionary:
	var next_stats := _duplicate_match_stats(stats)
	var prefix := "player" if player_scored else "bot"
	var period := get_match_period(match_mode, time_remaining, match_duration, golden_goal_active)
	var scored_value := maxi(1, goal_value)
	var period_key := "%s_goals_%s" % [prefix, str(period)]
	var total_key := "%s_goals_total" % prefix
	next_stats[period_key] = int(next_stats.get(period_key, 0)) + scored_value
	next_stats[total_key] = int(next_stats.get(total_key, 0)) + scored_value
	return next_stats

static func record_shot_stat(stats: Dictionary, team: StringName, super_used: bool) -> Dictionary:
	var normalized_team := _normalize_team(team)
	if normalized_team == TEAM_NONE:
		return _duplicate_match_stats(stats)
	var next_stats := _duplicate_match_stats(stats)
	var prefix := _team_prefix(normalized_team)
	next_stats["%s_shots" % prefix] = int(next_stats.get("%s_shots" % prefix, 0)) + 1
	if super_used:
		next_stats["%s_supers" % prefix] = int(next_stats.get("%s_supers" % prefix, 0)) + 1
	return next_stats

static func record_touch_stat(stats: Dictionary, team: StringName) -> Dictionary:
	var normalized_team := _normalize_team(team)
	if normalized_team == TEAM_NONE:
		return _duplicate_match_stats(stats)
	var next_stats := _duplicate_match_stats(stats)
	var prefix := _team_prefix(normalized_team)
	next_stats["%s_touches" % prefix] = int(next_stats.get("%s_touches" % prefix, 0)) + 1
	var current_team := StringName(str(next_stats.get("current_touch_team", TEAM_NONE)))
	var next_streak := 1
	if current_team == normalized_team:
		next_streak = int(next_stats.get("current_touch_streak", 0)) + 1
	next_stats["current_touch_team"] = normalized_team
	next_stats["current_touch_streak"] = next_streak
	if next_streak > int(next_stats.get("longest_touch_streak", 0)):
		next_stats["longest_touch_streak"] = next_streak
		next_stats["longest_touch_team"] = normalized_team
	return next_stats

static func build_match_stats_summary(stats: Dictionary) -> Dictionary:
	var safe_stats := _duplicate_match_stats(stats)
	var player_touches := int(safe_stats.get("player_touches", 0))
	var bot_touches := int(safe_stats.get("bot_touches", 0))
	var total_touches := player_touches + bot_touches
	var player_possession := 50
	if total_touches > 0:
		player_possession = int(round(float(player_touches) * 100.0 / float(total_touches)))
	var bot_possession := 100 - player_possession
	return {
		"player_goals_first_half": int(safe_stats.get("player_goals_first_half", 0)),
		"bot_goals_first_half": int(safe_stats.get("bot_goals_first_half", 0)),
		"player_goals_second_half": int(safe_stats.get("player_goals_second_half", 0)),
		"bot_goals_second_half": int(safe_stats.get("bot_goals_second_half", 0)),
		"player_goals_golden_goal": int(safe_stats.get("player_goals_golden_goal", 0)),
		"bot_goals_golden_goal": int(safe_stats.get("bot_goals_golden_goal", 0)),
		"player_goals_regular": int(safe_stats.get("player_goals_regular", 0)),
		"bot_goals_regular": int(safe_stats.get("bot_goals_regular", 0)),
		"player_goals_total": int(safe_stats.get("player_goals_total", 0)),
		"bot_goals_total": int(safe_stats.get("bot_goals_total", 0)),
		"player_shots": int(safe_stats.get("player_shots", 0)),
		"bot_shots": int(safe_stats.get("bot_shots", 0)),
		"total_shots": int(safe_stats.get("player_shots", 0)) + int(safe_stats.get("bot_shots", 0)),
		"player_supers": int(safe_stats.get("player_supers", 0)),
		"bot_supers": int(safe_stats.get("bot_supers", 0)),
		"player_touches": player_touches,
		"bot_touches": bot_touches,
		"total_touches": total_touches,
		"player_possession_percent": player_possession,
		"bot_possession_percent": bot_possession,
		"longest_touch_team": StringName(str(safe_stats.get("longest_touch_team", TEAM_NONE))),
		"longest_touch_streak": int(safe_stats.get("longest_touch_streak", 0))
	}

static func _flatten_normalized(vector: Vector3) -> Vector3:
	var flat := Vector3(vector.x, 0.0, vector.z)
	if flat.length_squared() <= 0.0001:
		return Vector3.ZERO
	return flat.normalized()

static func _duplicate_match_stats(stats: Dictionary) -> Dictionary:
	var next_stats := build_empty_match_stats()
	for key in stats.keys():
		next_stats[key] = stats[key]
	return next_stats

static func _normalize_team(team: StringName) -> StringName:
	if team == TEAM_PLAYER:
		return TEAM_PLAYER
	if team == TEAM_BOT:
		return TEAM_BOT
	return TEAM_NONE

static func _team_prefix(team: StringName) -> String:
	return "bot" if team == TEAM_BOT else "player"
