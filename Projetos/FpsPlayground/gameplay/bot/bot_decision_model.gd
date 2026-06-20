class_name BotDecisionModel
extends RefCounted

const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")


static func should_prioritize_map_route(context: Dictionary) -> bool:
	if bool(context.get("jump_pad_commitment_active", false)):
		return true
	if bool(context.get("health_pickup_available", false)) and float(context.get("health_fraction", 1.0)) <= float(context.get("low_health_pickup_threshold", 0.42)):
		return true
	if bool(context.get("overcharge_pickup_available", false)) and should_seek_overcharge_pickup(context):
		return true
	return float(context.get("reposition_cooldown_remaining", 0.0)) <= 0.0 and not bool(context.get("is_telegraphing", false))


static func should_commit_nearby_health_pickup(context: Dictionary) -> bool:
	if float(context.get("health_fraction", 1.0)) >= float(context.get("useful_health_pickup_threshold", 0.98)):
		return false
	return float(context.get("health_pickup_distance", 1000000.0)) <= float(context.get("nearby_health_commit_distance", 2.4))


static func should_commit_nearby_overcharge_pickup(context: Dictionary) -> bool:
	if bool(context.get("has_overcharge", false)):
		return false
	return float(context.get("overcharge_pickup_distance", 1000000.0)) <= float(context.get("nearby_overcharge_commit_distance", 2.6))


static func should_seek_health_pickup(context: Dictionary) -> bool:
	var health_ratio := float(context.get("health_fraction", 1.0))
	var pickup_interest_distance := float(context.get("pickup_interest_distance", 17.0))
	if health_ratio > float(context.get("low_health_pickup_threshold", 0.42)) and float(context.get("health_pickup_distance", 1000000.0)) > pickup_interest_distance * 0.55:
		return false
	var target_in_pressure_range := bool(context.get("last_has_line_of_sight", false)) and float(context.get("target_distance", 1000000.0)) <= float(context.get("shoot_range", 18.0))
	if health_ratio <= float(context.get("critical_health_pickup_threshold", 0.22)):
		return true
	return not target_in_pressure_range or float(context.get("shoot_cooldown_remaining", 0.0)) > float(context.get("shoot_cooldown", 0.76)) * 0.45 or float(context.get("reaction_remaining", 0.0)) > 0.0 or bool(context.get("is_cooldown_state", false))


static func should_seek_overcharge_pickup(context: Dictionary) -> bool:
	if bool(context.get("has_overcharge", false)):
		return false
	if float(context.get("health_fraction", 1.0)) >= float(context.get("healthy_overcharge_priority_threshold", 0.7)):
		return true
	return not bool(context.get("last_has_line_of_sight", false)) or float(context.get("shoot_cooldown_remaining", 0.0)) > float(context.get("shoot_cooldown", 0.76)) * 0.45


static func can_take_health_route(context: Dictionary) -> bool:
	return float(context.get("objective_route_cooldown_remaining", 0.0)) <= 0.0 or float(context.get("health_fraction", 1.0)) <= float(context.get("critical_health_pickup_threshold", 0.22))


static func choose_reposition_decision(candidate_entries: Array[Dictionary], context: Dictionary) -> Dictionary:
	var best_score := -1000000.0
	var best_point: Vector3 = context.get("bot_position", Vector3.ZERO)
	var best_label: StringName = &"fallback"
	var best_reason: StringName = &"fallback"
	var best_route_key: StringName = &"fallback"
	var best_is_high := false
	for index in range(candidate_entries.size()):
		var entry: Dictionary = candidate_entries[index]
		var point := clamp_arena_point(entry.get("position", context.get("bot_position", Vector3.ZERO)), context)
		var role: StringName = entry.get("role", classify_route_point(point, context))
		var route_key: StringName = entry.get("route", role)
		var is_high := is_high_route_point(point) or role == BotTacticalContextScript.ROLE_HIGH_GROUND or role == BotTacticalContextScript.ROLE_JUMP_PAD_LANDING
		var score := score_tactical_point(entry, index, candidate_entries.size(), context)
		if score > best_score:
			best_score = score
			best_point = point
			best_label = label_for_tactical_role(role, point, context)
			best_reason = role
			best_route_key = route_key
			best_is_high = is_high
	return {
		"position": best_point,
		"label": best_label,
		"reason": best_reason,
		"route_key": best_route_key,
		"score": best_score,
		"is_high": best_is_high
	}


static func score_tactical_point(entry: Dictionary, index: int, total_count: int, context: Dictionary) -> float:
	var point := clamp_arena_point(entry.get("position", context.get("bot_position", Vector3.ZERO)), context)
	var role: StringName = entry.get("role", BotTacticalContextScript.ROLE_FALLBACK)
	var route_key: StringName = entry.get("route", role)
	var target_distance := flat_distance_between(point, context.get("target_position", Vector3.ZERO))
	var travel_distance := flat_distance_between(context.get("bot_position", Vector3.ZERO), point)
	var weight := float(entry.get("weight", 1.0))
	var distance_score := -absf(target_distance - float(context.get("preferred_distance", 8.8))) * 0.48
	var travel_score := -travel_distance * 0.07
	var cycle_score := 0.04 * float((index + int(context.get("reposition_cycle_index", 0))) % maxi(1, total_count))
	var height_score := clampf(point.y - (context.get("bot_position", Vector3.ZERO) as Vector3).y, -1.0, 4.0) * 0.34
	var score := distance_score + travel_score + cycle_score + height_score
	score += score_tactical_role(role, point, target_distance, travel_distance, context)
	score -= recent_route_penalty(route_key, point, context)
	return score * maxf(0.2, weight)


static func score_tactical_role(role: StringName, point: Vector3, target_distance: float, travel_distance: float, context: Dictionary) -> float:
	var health_ratio := float(context.get("health_fraction", 1.0))
	var target_health := float(context.get("target_health_fraction", 1.0))
	var pressure_ready := bool(context.get("last_has_line_of_sight", false)) and float(context.get("shoot_cooldown_remaining", 0.0)) <= float(context.get("shoot_cooldown", 0.76)) * 0.48
	match role:
		BotTacticalContextScript.ROLE_HEALTH:
			if health_ratio <= float(context.get("critical_health_pickup_threshold", 0.22)):
				return 10.0
			if health_ratio <= float(context.get("low_health_pickup_threshold", 0.42)):
				return 7.0
			if health_ratio < float(context.get("useful_health_pickup_threshold", 0.98)) and travel_distance <= float(context.get("pickup_interest_distance", 17.0)) * 0.55:
				return 2.4
			return -5.5
		BotTacticalContextScript.ROLE_OVERCHARGE:
			if bool(context.get("has_overcharge", false)):
				return -5.0
			var score := 1.2
			if health_ratio >= float(context.get("healthy_overcharge_priority_threshold", 0.7)):
				score += 4.2
			elif health_ratio <= float(context.get("low_health_pickup_threshold", 0.42)):
				score -= 2.6
			if not bool(context.get("last_has_line_of_sight", false)):
				score += 2.6
			if float(context.get("shoot_cooldown_remaining", 0.0)) > float(context.get("shoot_cooldown", 0.76)) * 0.45:
				score += 1.4
			return score
		BotTacticalContextScript.ROLE_RETREAT:
			var score := 0.4
			if health_ratio <= float(context.get("critical_health_pickup_threshold", 0.22)):
				score += float(context.get("retreat_route_bonus", 3.4)) + 2.2
			elif health_ratio <= float(context.get("low_health_pickup_threshold", 0.42)):
				score += float(context.get("retreat_route_bonus", 3.4))
			if float(context.get("target_distance", 1000000.0)) < float(context.get("preferred_distance", 8.8)) * 0.65:
				score += 2.0
			if bool(context.get("last_has_line_of_sight", false)) and float(context.get("shoot_cooldown_remaining", 0.0)) > float(context.get("shoot_cooldown", 0.76)) * 0.55:
				score += 0.8
			return score
		BotTacticalContextScript.ROLE_COVER:
			var score := float(context.get("cover_route_bonus", 1.8)) * 0.72
			if not bool(context.get("last_has_line_of_sight", false)):
				score += 0.9
			if float(context.get("shoot_cooldown_remaining", 0.0)) > float(context.get("shoot_cooldown", 0.76)) * 0.45:
				score += 0.55
			if health_ratio <= float(context.get("low_health_pickup_threshold", 0.42)):
				score += 1.4
			return score
		BotTacticalContextScript.ROLE_FLANK:
			var score := float(context.get("flank_route_bonus", 1.35))
			if not bool(context.get("last_has_line_of_sight", false)):
				score += 1.8
			if target_distance <= float(context.get("shoot_range", 18.0)):
				score += 0.65
			if pressure_ready:
				score += 0.45
			return score
		BotTacticalContextScript.ROLE_PRESSURE:
			var score := float(context.get("pressure_route_bonus", 2.2))
			if bool(context.get("last_has_line_of_sight", false)):
				score += 1.5
			if target_distance <= float(context.get("shoot_range", 18.0)):
				score += 0.9
			if target_health <= 0.42:
				score += 1.3
			if health_ratio <= float(context.get("low_health_pickup_threshold", 0.42)):
				score -= 2.0
			if travel_distance > float(context.get("shoot_range", 18.0)):
				score -= 1.0
			return score
		BotTacticalContextScript.ROLE_HIGH_GROUND, BotTacticalContextScript.ROLE_JUMP_PAD_LANDING:
			var score := float(context.get("high_route_score_bonus", 1.1)) + 1.2
			if not bool(context.get("last_has_line_of_sight", false)):
				score += 2.4
			if target_distance <= float(context.get("shoot_range", 18.0)):
				score += 0.8
			if float(context.get("vertical_route_cooldown_remaining", 0.0)) > 0.0:
				score -= float(context.get("recent_high_route_penalty", 3.2))
			return score
		BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY:
			var score := 1.35
			if float(context.get("vertical_route_cooldown_remaining", 0.0)) <= 0.0:
				score += 2.25
			if not bool(context.get("last_has_line_of_sight", false)):
				score += 1.4
			return score
		_:
			return 0.0


static func label_for_tactical_role(role: StringName, point: Vector3, context: Dictionary) -> StringName:
	match role:
		BotTacticalContextScript.ROLE_PRESSURE:
			return &"pressure"
		BotTacticalContextScript.ROLE_FLANK:
			return &"flank"
		BotTacticalContextScript.ROLE_COVER:
			return &"cover"
		BotTacticalContextScript.ROLE_RETREAT:
			return &"retreat"
		BotTacticalContextScript.ROLE_HEALTH:
			return &"health"
		BotTacticalContextScript.ROLE_OVERCHARGE:
			return &"overcharge"
		BotTacticalContextScript.ROLE_HIGH_GROUND, BotTacticalContextScript.ROLE_JUMP_PAD_LANDING:
			return &"high"
		BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY:
			return &"jump_pad"
		_:
			return classify_route_point(point, context)


static func recent_route_penalty(route_key: StringName, point: Vector3, context: Dictionary) -> float:
	var penalty := 0.0
	if is_route_temporarily_blocked(route_key, context):
		penalty += float(context.get("route_repeat_penalty", 2.6)) * 5.0
	var recent_route_keys: Array = context.get("recent_route_keys", [])
	for index in range(recent_route_keys.size()):
		if recent_route_keys[index] == route_key:
			var recency := float(recent_route_keys.size() - index)
			penalty += float(context.get("route_repeat_penalty", 2.6)) * recency / maxf(1.0, float(recent_route_keys.size()))
	if flat_distance_between(context.get("bot_position", Vector3.ZERO), point) <= float(context.get("reposition_arrival_distance", 1.05)) * 1.35:
		penalty += float(context.get("route_repeat_penalty", 2.6)) * 0.6
	return penalty


static func select_tactical_objective_destination(role: StringName, fallback_position: Vector3, tactical_points: Array[Dictionary], context: Dictionary) -> Vector3:
	var best_position := fallback_position
	var best_score := -1000000.0
	for index in range(tactical_points.size()):
		var entry: Dictionary = tactical_points[index]
		if entry.get("role", BotTacticalContextScript.ROLE_FALLBACK) != role:
			continue
		if not bool(entry.get("available", true)):
			continue
		var score := score_tactical_point(entry, index, tactical_points.size(), context)
		if score > best_score:
			best_score = score
			best_position = entry.get("position", fallback_position)
	return best_position


static func should_hold_current_route(context: Dictionary) -> bool:
	if not bool(context.get("is_reposition_state", false)):
		return false
	var last_route_label: StringName = context.get("last_route_label", &"")
	if last_route_label == &"health":
		if not bool(context.get("health_pickup_available", false)):
			return false
		if float(context.get("health_fraction", 1.0)) < float(context.get("useful_health_pickup_threshold", 0.98)) and float(context.get("health_pickup_distance", 1000000.0)) <= float(context.get("nearby_health_commit_distance", 2.4)) * 1.2:
			return true
		return float(context.get("health_fraction", 1.0)) <= float(context.get("low_health_pickup_threshold", 0.42))
	if last_route_label == &"overcharge":
		if not bool(context.get("overcharge_pickup_available", false)) or bool(context.get("has_overcharge", false)):
			return false
		if float(context.get("overcharge_pickup_distance", 1000000.0)) <= float(context.get("nearby_overcharge_commit_distance", 2.6)) * 1.2:
			return true
		return should_seek_overcharge_pickup(context)
	if last_route_label == &"jump_pad" or last_route_label == &"high":
		return bool(context.get("jump_pad_commitment_active", false)) or float(context.get("distance_to_reposition_destination", 0.0)) > float(context.get("reposition_arrival_distance", 1.05)) * 1.5
	return false


static func clamp_arena_point(point: Vector3, context: Dictionary) -> Vector3:
	var arena_half_extent := float(context.get("arena_half_extent", 11.2))
	return Vector3(
		clampf(point.x, -arena_half_extent, arena_half_extent),
		point.y,
		clampf(point.z, -arena_half_extent, arena_half_extent)
	)


static func is_high_route_point(point: Vector3) -> bool:
	return point.y > 2.0


static func classify_route_point(point: Vector3, context: Dictionary) -> StringName:
	var arena_half_extent := float(context.get("arena_half_extent", 11.2))
	if is_high_route_point(point):
		return &"high"
	if absf(point.x) > arena_half_extent * 0.78:
		return &"flank"
	if absf(point.x) < 4.5 and absf(point.z) < 7.2:
		return &"center"
	return &"ground"


static func is_route_temporarily_blocked(route_key: StringName, context: Dictionary) -> bool:
	if route_key == &"":
		return false
	var blocked_route_timers: Dictionary = context.get("blocked_route_timers", {})
	return blocked_route_timers.has(route_key) and float(blocked_route_timers.get(route_key, 0.0)) > 0.0


static func flat_distance_between(first_point: Vector3, second_point: Vector3) -> float:
	var delta := first_point - second_point
	delta.y = 0.0
	return delta.length()
