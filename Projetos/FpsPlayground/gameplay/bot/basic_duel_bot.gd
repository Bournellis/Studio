class_name BasicDuelBot
extends "res://gameplay/combat/combatant_3d.gd"

signal shot_fired()
signal shot_windup_started(origin: Vector3, target_position: Vector3, duration: float)
signal shot_feedback_requested(origin: Vector3, target_position: Vector3)
signal shot_resolution_requested(origin: Vector3, direction: Vector3, damage: float, knockback: float)

const BotAimModelScript = preload("res://gameplay/bot/bot_aim_model.gd")
const BotDecisionModelScript = preload("res://gameplay/bot/bot_decision_model.gd")
const BotVisibilityPointsScript = preload("res://gameplay/bot/bot_visibility_points.gd")
const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")

const STATE_IDLE: StringName = &"idle"
const STATE_ENGAGE: StringName = &"engage"
const STATE_STRAFE: StringName = &"strafe"
const STATE_REPOSITION: StringName = &"reposition"
const STATE_WINDUP: StringName = &"windup"
const STATE_COOLDOWN: StringName = &"cooldown"
const STATE_DEAD: StringName = &"dead"

@export var move_speed: float = 4.7
@export var preferred_distance: float = 8.8
@export var shoot_range: float = 18.0
@export var shoot_damage: float = 9.0
@export var shoot_knockback: float = 3.6
@export var shoot_cooldown: float = 0.76
@export var shot_tell_duration: float = 0.18
@export var reaction_time: float = 0.18
@export var aim_error_radius: float = 0.42
@export var close_range_aim_error_radius: float = 0.14
@export var strafe_duration: float = 0.72
@export var reposition_interval: float = 2.25
@export var reposition_arrival_distance: float = 1.05
@export var lost_line_of_sight_grace: float = 0.08
@export var stuck_switch_time: float = 0.35
@export var arena_half_extent: float = 11.2
@export var target_head_visibility_height: float = 1.52
@export var target_upper_visibility_height: float = 1.18
@export var target_center_visibility_height: float = 0.82
@export var target_lower_visibility_height: float = 0.42
@export var low_health_pickup_threshold: float = 0.42
@export var critical_health_pickup_threshold: float = 0.22
@export var pickup_interest_distance: float = 17.0
@export var overcharge_interest_distance: float = 14.0
@export var nearby_health_commit_distance: float = 2.4
@export var nearby_overcharge_commit_distance: float = 2.6
@export var useful_health_pickup_threshold: float = 0.98
@export var overcharge_damage_multiplier: float = 1.25
@export var overcharge_knockback_multiplier: float = 1.18
@export var projectile_dodge_radius: float = 3.2
@export var projectile_dodge_strength: float = 1.2
@export var jump_velocity: float = 5.4
@export var jump_cooldown: float = 0.72
@export var jump_height_goal_threshold: float = 0.42
@export var jump_height_goal_distance: float = 4.8
@export var jump_probe_distance: float = 0.78
@export var jump_pad_route_distance: float = 3.2
@export var jump_pad_flight_commit_time: float = 1.85
@export var jump_pad_landing_recovery_time: float = 0.55
@export var jump_pad_landing_commit_distance: float = 2.6
@export var jump_pad_approach_lock_distance: float = 2.8
@export var jump_pad_air_steer_speed_multiplier: float = 0.45
@export var vertical_route_low_height_tolerance: float = 1.15
@export var jump_overhead_clearance: float = 1.35
@export var vertical_route_cooldown: float = 2.8
@export var blocked_route_cooldown: float = 2.6
@export var high_route_score_bonus: float = 1.1
@export var recent_high_route_penalty: float = 3.2
@export var objective_route_min_interval: float = 1.4
@export var route_repeat_penalty: float = 2.6
@export var pressure_route_bonus: float = 2.2
@export var retreat_route_bonus: float = 3.4
@export var cover_route_bonus: float = 1.8
@export var flank_route_bonus: float = 1.35
@export var healthy_overcharge_priority_threshold: float = 0.7
@export var route_shot_speed_multiplier: float = 0.92

var target
var shoot_cooldown_remaining: float = 0.0
var vertical_velocity: float = 0.0
var launch_boost_velocity: Vector3 = Vector3.ZERO
var jump_cooldown_remaining: float = 0.0
var vertical_route_cooldown_remaining: float = 0.0
var objective_route_cooldown_remaining: float = 0.0
var jump_count: int = 0
var jump_pad_launch_count: int = 0
var shot_tell_remaining: float = 0.0
var is_telegraphing: bool = false
var current_state: StringName = STATE_IDLE
var state_time_remaining: float = 0.0
var reaction_remaining: float = 0.0
var reposition_cooldown_remaining: float = 0.0
var strafe_direction: float = 1.0
var reposition_points: Array[Vector3] = []
var tactical_points: Array[Dictionary] = []
var tactical_context_label: StringName = &"legacy"
var recent_route_keys: Array[StringName] = []
var reposition_destination: Vector3 = Vector3.ZERO
var reposition_cycle_index: int = 0
var aim_cycle_index: int = 0
var last_aim_position: Vector3 = Vector3.ZERO
var pending_shot_direction: Vector3 = Vector3.ZERO
var windup_line_of_sight_grace_remaining: float = 0.0
var last_has_line_of_sight: bool = false
var last_visible_target_position: Vector3 = Vector3.ZERO
var stuck_time: float = 0.0
var last_desired_move: Vector3 = Vector3.ZERO
var health_pickup_position: Vector3 = Vector3.ZERO
var health_pickup_available: bool = false
var overcharge_pickup_position: Vector3 = Vector3.ZERO
var overcharge_pickup_available: bool = false
var projectile_threat_active: bool = false
var projectile_threat_position: Vector3 = Vector3.ZERO
var projectile_threat_velocity: Vector3 = Vector3.ZERO
var overcharge_shots_remaining: int = 0
var jump_pad_routes: Array[Dictionary] = []
var blocked_route_timers: Dictionary = {}
var last_navigation_target: Vector3 = Vector3.ZERO
var jump_pad_landing_target: Vector3 = Vector3.ZERO
var jump_pad_flight_commit_remaining: float = 0.0
var jump_pad_landing_recovery_remaining: float = 0.0
var last_route_label: StringName = &"idle"
var active_route_key: StringName = &"idle"
var last_decision_reason: StringName = &"idle"
var last_reposition_score: float = 0.0
var last_reposition_is_high_route: bool = false

func _ready() -> void:
	super._ready()
	configure_combatant(&"bot", 100.0, Color(1.0, 0.34, 0.22, 1.0))
	_set_state(STATE_IDLE)

func _process(delta: float) -> void:
	super._process(delta)
	_update_bot_state_visual()

func configure(next_target) -> void:
	target = next_target
	configure_combatant(&"bot", 100.0, Color(1.0, 0.34, 0.22, 1.0))
	shoot_cooldown_remaining = 0.24
	vertical_velocity = 0.0
	launch_boost_velocity = Vector3.ZERO
	jump_cooldown_remaining = 0.0
	vertical_route_cooldown_remaining = 0.0
	objective_route_cooldown_remaining = 0.0
	jump_count = 0
	jump_pad_launch_count = 0
	reaction_remaining = reaction_time
	reposition_cooldown_remaining = 0.65
	strafe_direction = 1.0
	reposition_destination = Vector3.ZERO
	last_aim_position = _get_target_position()
	last_visible_target_position = last_aim_position
	last_has_line_of_sight = false
	pending_shot_direction = Vector3.ZERO
	stuck_time = 0.0
	projectile_threat_active = false
	overcharge_shots_remaining = 0
	last_navigation_target = global_position
	jump_pad_landing_target = Vector3.ZERO
	jump_pad_flight_commit_remaining = 0.0
	jump_pad_landing_recovery_remaining = 0.0
	last_route_label = &"engage"
	active_route_key = &"engage"
	last_decision_reason = &"engage"
	last_reposition_score = 0.0
	last_reposition_is_high_route = false
	recent_route_keys.clear()
	blocked_route_timers.clear()
	_cancel_windup(STATE_ENGAGE)

func set_reposition_points(points: Array[Vector3]) -> void:
	reposition_points = points.duplicate()

func set_tactical_context(context: Dictionary) -> void:
	tactical_context_label = context.get("label", &"arena")
	tactical_points = BotTacticalContextScript.get_points(context)
	var context_jump_routes := BotTacticalContextScript.get_jump_pad_routes(context)
	jump_pad_routes = context_jump_routes
	reposition_points.clear()
	for entry: Dictionary in tactical_points:
		var role: StringName = entry.get("role", BotTacticalContextScript.ROLE_FALLBACK)
		if BotTacticalContextScript.is_reposition_role(role):
			reposition_points.append(entry.get("position", Vector3.ZERO))

func set_jump_pad_routes(routes: Array[Dictionary]) -> void:
	jump_pad_routes = routes.duplicate(true)

func force_fire() -> void:
	_cancel_windup(STATE_ENGAGE)
	_force_fire_direct()

func set_pickup_awareness(next_health_position: Vector3, next_health_available: bool, next_overcharge_position: Vector3, next_overcharge_available: bool) -> void:
	health_pickup_position = next_health_position
	health_pickup_available = next_health_available
	overcharge_pickup_position = next_overcharge_position
	overcharge_pickup_available = next_overcharge_available

func set_projectile_threat(threat_position: Vector3, threat_velocity: Vector3, active: bool) -> void:
	projectile_threat_position = threat_position
	projectile_threat_velocity = threat_velocity
	projectile_threat_active = active

func grant_overcharge() -> void:
	if is_dead:
		return
	overcharge_shots_remaining = 1

func has_overcharge_charge() -> bool:
	return overcharge_shots_remaining > 0

func debug_get_state() -> StringName:
	return current_state

func debug_get_target():
	return target

func debug_has_line_of_sight() -> bool:
	return _refresh_target_visibility()

func debug_get_reposition_destination() -> Vector3:
	return reposition_destination

func debug_get_reposition_point_count() -> int:
	return reposition_points.size()

func debug_get_last_aim_position() -> Vector3:
	return last_aim_position

func debug_get_visible_target_position() -> Vector3:
	return last_visible_target_position

func debug_is_projectile_dodging() -> bool:
	return _projectile_dodge_movement().length_squared() > 0.01

func debug_get_jump_count() -> int:
	return jump_count

func debug_get_vertical_velocity() -> float:
	return vertical_velocity

func debug_get_jump_pad_launch_count() -> int:
	return jump_pad_launch_count

func debug_get_jump_pad_route_count() -> int:
	return jump_pad_routes.size()

func debug_get_route_label() -> StringName:
	return last_route_label

func debug_get_decision_reason() -> StringName:
	return last_decision_reason

func debug_get_tactical_context_label() -> StringName:
	return tactical_context_label

func debug_get_tactical_point_count() -> int:
	return tactical_points.size()

func debug_get_recent_route_count() -> int:
	return recent_route_keys.size()

func debug_get_last_reposition_score() -> float:
	return last_reposition_score

func debug_is_high_route_active() -> bool:
	return current_state == STATE_REPOSITION and last_reposition_is_high_route

func debug_get_last_navigation_target() -> Vector3:
	return last_navigation_target

func debug_get_jump_pad_landing_target() -> Vector3:
	return jump_pad_landing_target

func debug_is_jump_pad_commitment_active() -> bool:
	return _is_jump_pad_commitment_active()

func debug_is_combat_overlay_active() -> bool:
	return is_telegraphing

func debug_get_active_route_key() -> StringName:
	return active_route_key

func debug_get_blocked_route_count() -> int:
	return blocked_route_timers.size()

func apply_jump_pad_launch(launch_velocity: Vector3) -> void:
	if is_dead:
		return
	vertical_velocity = maxf(vertical_velocity, launch_velocity.y)
	launch_boost_velocity = Vector3(launch_velocity.x, 0.0, launch_velocity.z)
	jump_cooldown_remaining = jump_cooldown
	vertical_route_cooldown_remaining = maxf(vertical_route_cooldown_remaining, vertical_route_cooldown * 0.65)
	jump_pad_landing_target = _select_jump_pad_landing_target(reposition_destination, launch_velocity)
	jump_pad_flight_commit_remaining = jump_pad_flight_commit_time
	jump_pad_landing_recovery_remaining = 0.0
	last_route_label = &"jump_pad"
	active_route_key = &"jump_pad"
	last_decision_reason = &"jump_pad"
	_set_state(STATE_REPOSITION, maxf(state_time_remaining, jump_pad_flight_commit_time + jump_pad_landing_recovery_time))
	jump_pad_launch_count += 1

func clear_movement_impulses() -> void:
	vertical_velocity = 0.0
	launch_boost_velocity = Vector3.ZERO
	velocity = Vector3.ZERO
	knockback_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if is_dead:
		_cancel_windup(STATE_DEAD)
		current_state = STATE_DEAD
		velocity = Vector3.ZERO
		move_and_slide()
		return

	shoot_cooldown_remaining = maxf(0.0, shoot_cooldown_remaining - delta)
	jump_cooldown_remaining = maxf(0.0, jump_cooldown_remaining - delta)
	vertical_route_cooldown_remaining = maxf(0.0, vertical_route_cooldown_remaining - delta)
	objective_route_cooldown_remaining = maxf(0.0, objective_route_cooldown_remaining - delta)
	reposition_cooldown_remaining = maxf(0.0, reposition_cooldown_remaining - delta)
	jump_pad_flight_commit_remaining = maxf(0.0, jump_pad_flight_commit_remaining - delta)
	jump_pad_landing_recovery_remaining = maxf(0.0, jump_pad_landing_recovery_remaining - delta)
	_update_blocked_route_timers(delta)
	state_time_remaining = maxf(0.0, state_time_remaining - delta)
	reaction_remaining = maxf(0.0, reaction_remaining - delta)
	_apply_gravity(delta)

	var before_position := global_position
	last_has_line_of_sight = _refresh_target_visibility()
	last_desired_move = _handle_duel_state(delta)
	_update_combat_overlay(delta)
	last_desired_move = _apply_projectile_dodge(last_desired_move)
	_maybe_jump_for_navigation(last_desired_move)
	velocity = _build_velocity(last_desired_move, delta)
	move_and_slide()
	_update_grounded_vertical_velocity()
	_update_jump_pad_commitment_after_move()
	_update_stuck_state(delta, before_position)

func _handle_duel_state(delta: float) -> Vector3:
	if target == null or target.is_dead:
		_cancel_windup(STATE_IDLE)
		return Vector3.ZERO

	_face_target()
	match current_state:
		STATE_WINDUP:
			return _handle_windup(delta)
		STATE_COOLDOWN:
			return _handle_cooldown()
		STATE_REPOSITION:
			return _handle_reposition()
		STATE_STRAFE:
			return _handle_strafe()
		STATE_IDLE:
			_set_state(STATE_ENGAGE)
			return _handle_engage()
		_:
			return _handle_engage()

func _handle_engage() -> Vector3:
	_maybe_start_combat_overlay()
	if not last_has_line_of_sight:
		if _try_start_pickup_reposition():
			return _movement_toward_reposition()
		_start_reposition()
		return _movement_toward_reposition()
	if _try_start_pickup_reposition():
		return _movement_toward_reposition()
	if _should_prioritize_map_route():
		_start_reposition()
		return _movement_toward_reposition()
	if reposition_cooldown_remaining <= 0.0:
		_start_reposition()
		return _movement_toward_reposition()
	return _distance_management_movement()

func _handle_strafe() -> Vector3:
	_maybe_start_combat_overlay()
	if not last_has_line_of_sight:
		if _try_start_pickup_reposition():
			return _movement_toward_reposition()
		_start_reposition()
		return _movement_toward_reposition()
	if _try_start_pickup_reposition():
		return _movement_toward_reposition()
	if state_time_remaining <= 0.0:
		_set_state(STATE_ENGAGE)
	return _strafe_movement()

func _handle_reposition() -> Vector3:
	_maybe_start_combat_overlay()
	if _distance_to_reposition_destination() <= reposition_arrival_distance and not _is_jump_pad_commitment_active():
		reposition_cooldown_remaining = reposition_interval
		_set_state(STATE_ENGAGE)
		return _distance_management_movement()
	if state_time_remaining <= 0.0 and not _should_hold_current_route():
		reposition_cooldown_remaining = reposition_interval * 0.55
		_set_state(STATE_ENGAGE)
		return _distance_management_movement()
	return _movement_toward_reposition()

func _handle_windup(delta: float) -> Vector3:
	if target == null or target.is_dead:
		_cancel_windup(STATE_IDLE)
		return Vector3.ZERO
	if last_has_line_of_sight:
		windup_line_of_sight_grace_remaining = lost_line_of_sight_grace
	else:
		windup_line_of_sight_grace_remaining -= delta
		if windup_line_of_sight_grace_remaining <= 0.0:
			_cancel_windup(STATE_COOLDOWN)
			state_time_remaining = reaction_time
			reposition_cooldown_remaining = 0.0
			return _strafe_movement() * 0.4
	shot_tell_remaining = maxf(0.0, shot_tell_remaining - delta)
	if shot_tell_remaining <= 0.0:
		_fire_requested_shot()
		return _strafe_movement() * 0.35
	return _strafe_movement() * 0.18

func _handle_cooldown() -> Vector3:
	_maybe_start_combat_overlay()
	if _try_start_pickup_reposition():
		return _movement_toward_reposition()
	if state_time_remaining <= 0.0:
		if not last_has_line_of_sight:
			_start_reposition()
			return _movement_toward_reposition()
		_set_state(STATE_ENGAGE)
	return _distance_management_movement()

func _should_prioritize_map_route() -> bool:
	return BotDecisionModelScript.should_prioritize_map_route(_build_decision_context())

func _can_start_windup() -> bool:
	if is_telegraphing:
		return false
	if shoot_cooldown_remaining > 0.0:
		return false
	if reaction_remaining > 0.0:
		return false
	if target == null or target.is_dead:
		return false
	if _distance_to_target() > shoot_range:
		return false
	return last_has_line_of_sight

func _maybe_start_combat_overlay() -> void:
	if _can_start_windup():
		_start_windup()

func _start_windup() -> void:
	is_telegraphing = true
	shot_tell_remaining = shot_tell_duration
	windup_line_of_sight_grace_remaining = lost_line_of_sight_grace
	last_aim_position = _build_aim_position(last_visible_target_position)
	pending_shot_direction = (last_aim_position - _get_shot_origin()).normalized()
	if current_state == STATE_IDLE:
		_set_state(STATE_ENGAGE)
	shot_windup_started.emit(_get_shot_origin(), last_aim_position, shot_tell_duration)

func _update_combat_overlay(delta: float) -> void:
	if not is_telegraphing:
		return
	if target == null or target.is_dead:
		_cancel_windup(current_state)
		return
	if last_has_line_of_sight:
		windup_line_of_sight_grace_remaining = lost_line_of_sight_grace
	else:
		windup_line_of_sight_grace_remaining -= delta
		if windup_line_of_sight_grace_remaining <= 0.0:
			_cancel_windup(current_state)
			return
	shot_tell_remaining = maxf(0.0, shot_tell_remaining - delta)
	if shot_tell_remaining <= 0.0:
		_fire_requested_shot()

func _start_strafe() -> void:
	strafe_direction *= -1.0
	_set_state(STATE_STRAFE, strafe_duration)

func _start_reposition() -> void:
	_choose_reposition_destination()
	_set_state(STATE_REPOSITION, maxf(0.8, preferred_distance / maxf(0.1, move_speed)))

func _start_reposition_to(destination: Vector3, route_label: StringName = &"objective") -> void:
	reposition_destination = _clamp_arena_point(destination)
	last_route_label = route_label
	active_route_key = route_label
	last_decision_reason = route_label
	last_reposition_score = 0.0
	last_reposition_is_high_route = _is_high_route_point(reposition_destination)
	if last_reposition_is_high_route:
		vertical_route_cooldown_remaining = vertical_route_cooldown
	if route_label == &"health" or route_label == &"overcharge":
		objective_route_cooldown_remaining = objective_route_min_interval
	_remember_route_key(route_label)
	_set_state(STATE_REPOSITION, maxf(0.8, global_position.distance_to(reposition_destination) / maxf(0.1, move_speed)))

func _try_start_pickup_reposition() -> bool:
	if current_state == STATE_WINDUP:
		return false
	if health_pickup_available and _should_commit_nearby_health_pickup():
		_start_reposition_to(health_pickup_position, &"health")
		return true
	if overcharge_pickup_available and _should_commit_nearby_overcharge_pickup():
		_start_reposition_to(overcharge_pickup_position, &"overcharge")
		return true
	if current_state == STATE_REPOSITION:
		return false
	if health_pickup_available and _should_seek_health_pickup():
		if BotDecisionModelScript.can_take_health_route(_build_decision_context()) and _flat_distance_to(health_pickup_position) <= pickup_interest_distance:
			_start_reposition_to(_select_tactical_objective_destination(BotTacticalContextScript.ROLE_HEALTH, health_pickup_position), &"health")
			return true
	if overcharge_pickup_available and _should_seek_overcharge_pickup() and objective_route_cooldown_remaining <= 0.0:
		if _flat_distance_to(overcharge_pickup_position) <= overcharge_interest_distance:
			_start_reposition_to(_select_tactical_objective_destination(BotTacticalContextScript.ROLE_OVERCHARGE, overcharge_pickup_position), &"overcharge")
			return true
	return false

func _should_commit_nearby_health_pickup() -> bool:
	return BotDecisionModelScript.should_commit_nearby_health_pickup(_build_decision_context())

func _should_commit_nearby_overcharge_pickup() -> bool:
	return BotDecisionModelScript.should_commit_nearby_overcharge_pickup(_build_decision_context())

func _should_seek_health_pickup() -> bool:
	return BotDecisionModelScript.should_seek_health_pickup(_build_decision_context())

func _should_seek_overcharge_pickup() -> bool:
	return BotDecisionModelScript.should_seek_overcharge_pickup(_build_decision_context())

func _fire_requested_shot() -> void:
	if target == null or target.is_dead:
		_cancel_windup(STATE_IDLE)
		return
	var preserve_route_state := current_state == STATE_REPOSITION or current_state == STATE_STRAFE
	var origin := _get_shot_origin()
	var direction := pending_shot_direction
	if direction.length_squared() <= 0.0001:
		direction = (last_aim_position - origin).normalized()
	is_telegraphing = false
	shot_tell_remaining = 0.0
	shoot_cooldown_remaining = shoot_cooldown
	reaction_remaining = reaction_time
	if preserve_route_state:
		state_time_remaining = maxf(state_time_remaining, reaction_time)
	else:
		_set_state(STATE_COOLDOWN, reaction_time)
	var was_overcharged := _consume_overcharge()
	var damage := shoot_damage * (overcharge_damage_multiplier if was_overcharged else 1.0)
	var knockback := shoot_knockback * (overcharge_knockback_multiplier if was_overcharged else 1.0)
	shot_resolution_requested.emit(origin, direction, damage, knockback)
	shot_fired.emit()

func _force_fire_direct() -> void:
	if target == null or target.is_dead:
		return
	shoot_cooldown_remaining = shoot_cooldown
	reaction_remaining = reaction_time
	var origin := _get_shot_origin()
	var target_position := _get_target_position()
	last_aim_position = target_position
	var direction: Vector3 = target_position - origin
	var was_overcharged := _consume_overcharge()
	var damage := shoot_damage * (overcharge_damage_multiplier if was_overcharged else 1.0)
	var knockback := shoot_knockback * (overcharge_knockback_multiplier if was_overcharged else 1.0)
	target.take_damage(damage, combatant_id)
	target.apply_knockback(direction, knockback)
	shot_feedback_requested.emit(origin, target_position)
	shot_fired.emit()
	_set_state(STATE_COOLDOWN, reaction_time)

func _cancel_windup(next_state: StringName = STATE_ENGAGE) -> void:
	is_telegraphing = false
	shot_tell_remaining = 0.0
	pending_shot_direction = Vector3.ZERO
	if next_state != current_state:
		_set_state(next_state)

func _set_state(next_state: StringName, duration: float = 0.0) -> void:
	current_state = next_state
	state_time_remaining = duration

func _refresh_target_visibility() -> bool:
	if target == null or target.is_dead:
		last_visible_target_position = _get_target_position()
		return false
	for target_point in _get_target_visibility_points():
		if _has_clear_visibility_to_point(target_point):
			last_visible_target_position = target_point
			return true
	last_visible_target_position = _get_target_position()
	return false

func _get_target_visibility_points() -> Array[Vector3]:
	return BotVisibilityPointsScript.build_target_points(
		target,
		_get_target_position(),
		target_head_visibility_height,
		target_upper_visibility_height,
		target_center_visibility_height,
		target_lower_visibility_height
	)

func _append_unique_visibility_point(points: Array[Vector3], target_point: Vector3) -> void:
	BotVisibilityPointsScript.append_unique_point(points, target_point)

func _has_clear_visibility_to_point(target_point: Vector3) -> bool:
	var origin := _get_shot_origin()
	var query := PhysicsRayQueryParameters3D.create(origin, target_point)
	query.exclude = [get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.get("collider", null) == target

func _build_aim_position(base_target_position: Vector3) -> Vector3:
	var pattern := BotAimModelScript.pattern_for_index(aim_cycle_index)
	aim_cycle_index += 1
	return BotAimModelScript.build_aim_position(
		base_target_position,
		_get_shot_origin(),
		shoot_range,
		close_range_aim_error_radius,
		aim_error_radius,
		pattern
	)

func _aim_pattern(index: int) -> Vector2:
	return BotAimModelScript.pattern_for_index(index)

func _choose_reposition_destination() -> void:
	var candidate_entries := _get_reposition_candidate_entries()
	var decision := BotDecisionModelScript.choose_reposition_decision(candidate_entries, _build_decision_context())
	reposition_cycle_index += 1
	reposition_destination = decision.get("position", global_position)
	last_route_label = decision.get("label", &"fallback")
	active_route_key = decision.get("route_key", &"fallback")
	last_decision_reason = decision.get("reason", &"fallback")
	last_reposition_score = float(decision.get("score", 0.0))
	last_reposition_is_high_route = bool(decision.get("is_high", false))
	_remember_route_key(active_route_key)
	if last_reposition_is_high_route:
		vertical_route_cooldown_remaining = vertical_route_cooldown

func _get_reposition_candidate_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry: Dictionary in tactical_points:
		var role: StringName = entry.get("role", BotTacticalContextScript.ROLE_FALLBACK)
		if not BotTacticalContextScript.is_reposition_role(role):
			continue
		if not bool(entry.get("available", true)):
			continue
		entries.append(entry.duplicate(true))
	if not entries.is_empty():
		return entries
	for point: Vector3 in reposition_points:
		var role := _classify_route_point(point)
		entries.append(BotTacticalContextScript.make_point(point, role, 1.0, role))
	if not entries.is_empty():
		return entries
	for point: Vector3 in _fallback_reposition_points():
		entries.append(BotTacticalContextScript.make_point(point, BotTacticalContextScript.ROLE_FALLBACK, 1.0, &"fallback"))
	return entries

func _build_decision_context() -> Dictionary:
	return {
		"bot_position": global_position,
		"target_position": _get_target_position(),
		"target_distance": _distance_to_target(),
		"distance_to_reposition_destination": _distance_to_reposition_destination(),
		"health_fraction": health_fraction(),
		"target_health_fraction": _target_health_fraction(),
		"has_overcharge": has_overcharge_charge(),
		"last_has_line_of_sight": last_has_line_of_sight,
		"is_telegraphing": is_telegraphing,
		"is_cooldown_state": current_state == STATE_COOLDOWN,
		"is_reposition_state": current_state == STATE_REPOSITION,
		"is_windup_state": current_state == STATE_WINDUP,
		"shoot_cooldown_remaining": shoot_cooldown_remaining,
		"shoot_cooldown": shoot_cooldown,
		"reaction_remaining": reaction_remaining,
		"preferred_distance": preferred_distance,
		"shoot_range": shoot_range,
		"reposition_cooldown_remaining": reposition_cooldown_remaining,
		"objective_route_cooldown_remaining": objective_route_cooldown_remaining,
		"reposition_cycle_index": reposition_cycle_index,
		"reposition_arrival_distance": reposition_arrival_distance,
		"vertical_route_cooldown_remaining": vertical_route_cooldown_remaining,
		"jump_pad_commitment_active": _is_jump_pad_commitment_active(),
		"health_pickup_available": health_pickup_available,
		"health_pickup_distance": _flat_distance_to(health_pickup_position),
		"overcharge_pickup_available": overcharge_pickup_available,
		"overcharge_pickup_distance": _flat_distance_to(overcharge_pickup_position),
		"low_health_pickup_threshold": low_health_pickup_threshold,
		"critical_health_pickup_threshold": critical_health_pickup_threshold,
		"useful_health_pickup_threshold": useful_health_pickup_threshold,
		"pickup_interest_distance": pickup_interest_distance,
		"overcharge_interest_distance": overcharge_interest_distance,
		"nearby_health_commit_distance": nearby_health_commit_distance,
		"nearby_overcharge_commit_distance": nearby_overcharge_commit_distance,
		"healthy_overcharge_priority_threshold": healthy_overcharge_priority_threshold,
		"retreat_route_bonus": retreat_route_bonus,
		"cover_route_bonus": cover_route_bonus,
		"flank_route_bonus": flank_route_bonus,
		"pressure_route_bonus": pressure_route_bonus,
		"high_route_score_bonus": high_route_score_bonus,
		"recent_high_route_penalty": recent_high_route_penalty,
		"route_repeat_penalty": route_repeat_penalty,
		"arena_half_extent": arena_half_extent,
		"last_route_label": last_route_label,
		"recent_route_keys": recent_route_keys.duplicate(),
		"blocked_route_timers": blocked_route_timers.duplicate()
	}

func _score_tactical_point(entry: Dictionary, index: int, total_count: int) -> float:
	return BotDecisionModelScript.score_tactical_point(entry, index, total_count, _build_decision_context())

func _score_tactical_role(role: StringName, point: Vector3, target_distance: float, travel_distance: float) -> float:
	return BotDecisionModelScript.score_tactical_role(role, point, target_distance, travel_distance, _build_decision_context())

func _label_for_tactical_role(role: StringName, point: Vector3) -> StringName:
	return BotDecisionModelScript.label_for_tactical_role(role, point, _build_decision_context())

func _recent_route_penalty(route_key: StringName, point: Vector3) -> float:
	return BotDecisionModelScript.recent_route_penalty(route_key, point, _build_decision_context())

func _remember_route_key(route_key: StringName) -> void:
	if route_key == &"":
		return
	recent_route_keys.append(route_key)
	while recent_route_keys.size() > 4:
		recent_route_keys.remove_at(0)

func _select_tactical_objective_destination(role: StringName, fallback_position: Vector3) -> Vector3:
	return BotDecisionModelScript.select_tactical_objective_destination(role, fallback_position, tactical_points, _build_decision_context())

func _should_hold_current_route() -> bool:
	return BotDecisionModelScript.should_hold_current_route(_build_decision_context())

func _fallback_reposition_points() -> Array[Vector3]:
	return [
		Vector3(-7.0, global_position.y, 0.0),
		Vector3(7.0, global_position.y, 0.0),
		Vector3(0.0, global_position.y, -6.0),
		Vector3(0.0, global_position.y, 6.0),
		Vector3(-5.5, global_position.y, -5.5),
		Vector3(5.5, global_position.y, 5.5)
	]

func _movement_toward_reposition() -> Vector3:
	if _is_jump_pad_commitment_active():
		last_navigation_target = jump_pad_landing_target
		var to_landing := jump_pad_landing_target - global_position
		to_landing.y = 0.0
		if to_landing.length_squared() <= 0.0001:
			return Vector3.ZERO
		return to_landing.normalized()
	last_navigation_target = _resolve_navigation_target(reposition_destination)
	var to_destination := last_navigation_target - global_position
	to_destination.y = 0.0
	if to_destination.length_squared() <= 0.0001:
		return _distance_management_movement()
	if _is_jump_pad_approach_lock_active():
		return to_destination.normalized()
	var route_weight := 0.16
	if last_route_label == &"health" or last_route_label == &"overcharge" or last_route_label == &"jump_pad" or last_route_label == &"high":
		route_weight = 0.0
	return (to_destination.normalized() + _distance_management_movement() * route_weight).normalized()

func _strafe_movement() -> Vector3:
	var to_target := _flat_to_target()
	if to_target.length_squared() <= 0.0001:
		return Vector3.ZERO
	var lateral := Vector3(-to_target.z, 0.0, to_target.x).normalized() * strafe_direction
	var distance_move := _distance_management_movement()
	var desired := lateral * 0.9 + distance_move * 0.65
	if desired.length_squared() <= 0.0001:
		return lateral
	return desired.normalized()

func _distance_management_movement() -> Vector3:
	var to_target := _flat_to_target()
	var distance := to_target.length()
	if distance <= 0.05:
		return Vector3.ZERO
	var forward := to_target.normalized()
	if health_fraction() <= critical_health_pickup_threshold and distance < preferred_distance * 1.35:
		return -forward
	if health_fraction() <= low_health_pickup_threshold and shoot_cooldown_remaining > shoot_cooldown * 0.5 and distance < preferred_distance:
		return -forward
	if has_overcharge_charge() and last_has_line_of_sight and distance > preferred_distance * 0.78:
		return forward
	if distance > preferred_distance + 1.25:
		return forward
	if distance < preferred_distance * 0.68:
		return -forward
	return Vector3.ZERO

func _build_velocity(desired_move: Vector3, delta: float) -> Vector3:
	var knockback := consume_knockback(delta, is_on_floor())
	var horizontal := desired_move
	if horizontal.length_squared() > 1.0:
		horizontal = horizontal.normalized()
	var speed_multiplier := 1.0
	if current_state == STATE_REPOSITION:
		speed_multiplier = 1.05
	elif current_state == STATE_WINDUP:
		speed_multiplier = 0.45
	if _is_jump_pad_flight_active():
		speed_multiplier = minf(speed_multiplier, jump_pad_air_steer_speed_multiplier)
	if is_telegraphing and current_state != STATE_WINDUP:
		speed_multiplier = minf(speed_multiplier, route_shot_speed_multiplier)
	var launch_boost := _consume_launch_boost(delta)
	return horizontal * move_speed * speed_multiplier + Vector3(knockback.x, vertical_velocity + knockback.y, knockback.z) + launch_boost

func _consume_launch_boost(delta: float) -> Vector3:
	var current := launch_boost_velocity
	launch_boost_velocity = launch_boost_velocity.move_toward(Vector3.ZERO, 5.2 * delta)
	return current

func _maybe_jump_for_navigation(desired_move: Vector3) -> void:
	if jump_cooldown_remaining > 0.0:
		return
	if _is_jump_pad_flight_active():
		return
	if not _has_jump_ground_contact():
		return
	if current_state == STATE_WINDUP or current_state == STATE_IDLE or current_state == STATE_DEAD:
		return
	var flat_move := Vector3(desired_move.x, 0.0, desired_move.z)
	if flat_move.length_squared() <= 0.01:
		return
	if _should_jump_toward_height_goal() or _should_jump_over_low_obstacle(flat_move.normalized()):
		_trigger_jump()

func _resolve_navigation_target(destination: Vector3) -> Vector3:
	if destination.y <= global_position.y + jump_height_goal_threshold:
		return destination
	var best_route := _select_jump_pad_route_for_destination(destination)
	if best_route.is_empty():
		return destination
	var best_pad: Vector3 = best_route.get("position", destination)
	var best_target: Vector3 = best_route.get("target", destination)
	if global_position.y < best_target.y - vertical_route_low_height_tolerance:
		return best_pad
	if _flat_distance_to(best_target) > jump_pad_route_distance and destination.y > global_position.y + jump_height_goal_threshold:
		return best_target
	return destination

func _select_jump_pad_landing_target(destination: Vector3, launch_velocity: Vector3) -> Vector3:
	var route := _select_jump_pad_route_for_destination(destination)
	if not route.is_empty():
		return route.get("target", destination)
	var horizontal_launch := Vector3(launch_velocity.x, 0.0, launch_velocity.z)
	if horizontal_launch.length_squared() <= 0.0001:
		horizontal_launch = Vector3.FORWARD
	var fallback := global_position + horizontal_launch.normalized() * jump_pad_route_distance
	fallback.y = global_position.y
	return fallback

func _is_jump_pad_commitment_active() -> bool:
	return jump_pad_flight_commit_remaining > 0.0 or jump_pad_landing_recovery_remaining > 0.0

func _is_jump_pad_flight_active() -> bool:
	return jump_pad_flight_commit_remaining > 0.0

func _update_jump_pad_commitment_after_move() -> void:
	if jump_pad_flight_commit_remaining <= 0.0:
		return
	if not _has_jump_ground_contact():
		return
	if _flat_distance_to(jump_pad_landing_target) > jump_pad_landing_commit_distance:
		return
	jump_pad_flight_commit_remaining = 0.0
	jump_pad_landing_recovery_remaining = jump_pad_landing_recovery_time

func _select_jump_pad_route_for_destination(destination: Vector3) -> Dictionary:
	if jump_pad_routes.is_empty():
		return {}
	var best_route: Dictionary = {}
	var best_score := 1000000.0
	for route: Dictionary in jump_pad_routes:
		var pad_position: Vector3 = route.get("position", Vector3.ZERO)
		var target_position: Vector3 = route.get("target", pad_position)
		var route_id: StringName = route.get("id", &"")
		var target_score := target_position.distance_to(destination) + global_position.distance_to(pad_position) * 0.22
		if _is_route_temporarily_blocked(route_id):
			target_score += 1000.0
		if target_score < best_score:
			best_score = target_score
			best_route = route
	return best_route

func _is_high_route_point(point: Vector3) -> bool:
	return point.y > 2.0

func _classify_route_point(point: Vector3) -> StringName:
	if _is_high_route_point(point):
		return &"high"
	if absf(point.x) > arena_half_extent * 0.78:
		return &"flank"
	if absf(point.x) < 4.5 and absf(point.z) < 7.2:
		return &"center"
	return &"ground"

func _should_jump_toward_height_goal() -> bool:
	if current_state != STATE_REPOSITION:
		return false
	if _destination_requires_jump_pad_route(reposition_destination):
		return false
	var height_delta := reposition_destination.y - global_position.y
	if height_delta < jump_height_goal_threshold:
		return false
	var flat_delta := reposition_destination - global_position
	flat_delta.y = 0.0
	return flat_delta.length() <= jump_height_goal_distance

func _should_jump_over_low_obstacle(flat_direction: Vector3) -> bool:
	if not _has_jump_overhead_clearance(flat_direction):
		return false
	var low_origin := global_position + Vector3.UP * 0.36
	var low_result := _raycast_navigation_probe(low_origin, low_origin + flat_direction * jump_probe_distance)
	if low_result.is_empty():
		return false
	var low_collider: Object = low_result.get("collider", null)
	if low_collider == target:
		return false
	var high_origin := global_position + Vector3.UP * 1.32
	var high_result := _raycast_navigation_probe(high_origin, high_origin + flat_direction * jump_probe_distance)
	if high_result.is_empty():
		return true
	return high_result.get("collider", null) == target

func _destination_requires_jump_pad_route(destination: Vector3) -> bool:
	if destination.y <= global_position.y + jump_height_goal_threshold:
		return false
	var route := _select_jump_pad_route_for_destination(destination)
	if route.is_empty():
		return false
	var target_position: Vector3 = route.get("target", destination)
	return global_position.y < target_position.y - vertical_route_low_height_tolerance

func _has_jump_overhead_clearance(flat_direction: Vector3) -> bool:
	var head_origin := global_position + Vector3.UP * 1.05
	var head_top := head_origin + Vector3.UP * jump_overhead_clearance
	var vertical_result := _raycast_navigation_probe(head_origin, head_top)
	if not vertical_result.is_empty() and vertical_result.get("collider", null) != target:
		return false
	var forward_result := _raycast_navigation_probe(head_top, head_top + flat_direction * jump_probe_distance)
	return forward_result.is_empty() or forward_result.get("collider", null) == target

func _has_jump_ground_contact() -> bool:
	if is_on_floor():
		return true
	if vertical_velocity > 0.05:
		return false
	var probe_origin := global_position + Vector3.UP * 0.24
	var probe_result := _raycast_navigation_probe(probe_origin, probe_origin - Vector3.UP * 0.5)
	return not probe_result.is_empty()

func _raycast_navigation_probe(start_position: Vector3, end_position: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(start_position, end_position)
	query.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query)

func _trigger_jump() -> void:
	vertical_velocity = jump_velocity
	jump_cooldown_remaining = jump_cooldown
	jump_count += 1

func _apply_projectile_dodge(desired_move: Vector3) -> Vector3:
	if _is_jump_pad_flight_active() or _is_jump_pad_approach_lock_active():
		return desired_move
	var dodge := _projectile_dodge_movement()
	if dodge.length_squared() <= 0.0001:
		return desired_move
	var dodge_weight := 0.45 if current_state == STATE_WINDUP else projectile_dodge_strength
	var combined := desired_move + dodge * dodge_weight
	if combined.length_squared() <= 0.0001:
		return dodge
	return combined.normalized()

func _projectile_dodge_movement() -> Vector3:
	if not projectile_threat_active or is_dead:
		return Vector3.ZERO
	var to_threat := projectile_threat_position - global_position
	to_threat.y = 0.0
	if to_threat.length() > projectile_dodge_radius:
		return Vector3.ZERO
	var travel := Vector3(projectile_threat_velocity.x, 0.0, projectile_threat_velocity.z)
	if travel.length_squared() <= 0.0001:
		return -to_threat.normalized()
	var travel_direction := travel.normalized()
	var to_bot := -to_threat
	if to_bot.length_squared() > 0.0001 and travel_direction.dot(to_bot.normalized()) < -0.18:
		return Vector3.ZERO
	var lateral := Vector3(-travel_direction.z, 0.0, travel_direction.x).normalized()
	var side := 1.0
	if to_bot.length_squared() > 0.0001:
		side = signf(lateral.dot(to_bot.normalized()))
	if is_zero_approx(side):
		side = strafe_direction
	return lateral * side

func _is_jump_pad_approach_lock_active() -> bool:
	if current_state != STATE_REPOSITION:
		return false
	if _is_jump_pad_commitment_active():
		return false
	if not _destination_requires_jump_pad_route(reposition_destination):
		return false
	return _flat_distance_to(last_navigation_target) <= jump_pad_approach_lock_distance

func _apply_gravity(delta: float) -> void:
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	if not is_on_floor():
		vertical_velocity -= gravity * delta

func _update_grounded_vertical_velocity() -> void:
	if is_on_floor() and vertical_velocity < 0.0:
		vertical_velocity = -0.1

func _update_stuck_state(delta: float, before_position: Vector3) -> void:
	var moved := global_position.distance_to(before_position)
	if current_state != STATE_REPOSITION and current_state != STATE_STRAFE:
		stuck_time = 0.0
		return
	if last_desired_move.length_squared() <= 0.01 or moved > 0.015:
		stuck_time = 0.0
		return
	stuck_time += delta
	if stuck_time < stuck_switch_time:
		return
	stuck_time = 0.0
	strafe_direction *= -1.0
	_block_current_route()
	if current_state == STATE_REPOSITION:
		_choose_reposition_destination()
	else:
		_set_state(STATE_ENGAGE)

func _face_target() -> void:
	if target == null:
		return
	var look_position := Vector3(target.global_position.x, global_position.y, target.global_position.z)
	if global_position.distance_squared_to(look_position) > 0.0001:
		look_at(look_position, Vector3.UP, true)

func _flat_to_target() -> Vector3:
	if target == null:
		return Vector3.ZERO
	var to_target: Vector3 = target.global_position - global_position
	to_target.y = 0.0
	return to_target

func _distance_to_target() -> float:
	return _flat_to_target().length()

func _distance_to_reposition_destination() -> float:
	var to_destination := reposition_destination - global_position
	to_destination.y = 0.0
	return to_destination.length()

func _flat_distance_to(point: Vector3) -> float:
	var delta := point - global_position
	delta.y = 0.0
	return delta.length()

func _flat_distance_between(first_point: Vector3, second_point: Vector3) -> float:
	var delta := first_point - second_point
	delta.y = 0.0
	return delta.length()

func _block_current_route() -> void:
	var route_key := active_route_key
	if route_key == &"":
		route_key = last_route_label
	if route_key == &"":
		return
	blocked_route_timers[route_key] = blocked_route_cooldown

func _is_route_temporarily_blocked(route_key: StringName) -> bool:
	if route_key == &"":
		return false
	return blocked_route_timers.has(route_key) and float(blocked_route_timers.get(route_key, 0.0)) > 0.0

func _update_blocked_route_timers(delta: float) -> void:
	if blocked_route_timers.is_empty():
		return
	var expired_keys: Array[StringName] = []
	for route_key in blocked_route_timers.keys():
		var remaining := maxf(0.0, float(blocked_route_timers.get(route_key, 0.0)) - delta)
		if remaining <= 0.0:
			expired_keys.append(route_key)
		else:
			blocked_route_timers[route_key] = remaining
	for route_key: StringName in expired_keys:
		blocked_route_timers.erase(route_key)

func _target_health_fraction() -> float:
	if target == null:
		return 1.0
	if target.has_method("health_fraction"):
		return target.health_fraction()
	if target.get("max_health") != null:
		return float(target.get("health")) / maxf(1.0, float(target.get("max_health")))
	return 1.0

func _clamp_arena_point(point: Vector3) -> Vector3:
	return Vector3(
		clampf(point.x, -arena_half_extent, arena_half_extent),
		point.y,
		clampf(point.z, -arena_half_extent, arena_half_extent)
	)

func _get_shot_origin() -> Vector3:
	return get_body_center() + Vector3.UP * 0.2

func _get_target_position() -> Vector3:
	if target != null and target.has_method("get_body_center"):
		return target.get_body_center()
	if target != null:
		return target.global_position + Vector3.UP * 0.8
	return global_position

func _update_bot_state_visual() -> void:
	if is_dead or damage_flash_time > 0.0:
		return
	var mesh_instance := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_instance == null:
		return
	var color := body_color
	match current_state:
		STATE_REPOSITION:
			color = Color(0.82, 0.4, 1.0, 1.0)
		STATE_STRAFE:
			color = Color(1.0, 0.48, 0.26, 1.0)
		STATE_WINDUP:
			color = Color(1.0, 0.74, 0.22, 1.0)
		STATE_COOLDOWN:
			color = Color(0.82, 0.25, 0.2, 1.0)
		STATE_IDLE:
			color = Color(0.55, 0.58, 0.64, 1.0)
	if health_fraction() < 0.35:
		color = color.lerp(Color(1.0, 0.12, 0.08, 1.0), 0.42)
	if has_overcharge_charge():
		color = color.lerp(Color(0.32, 0.95, 1.0, 1.0), 0.38)
	mesh_instance.material_override = _build_material(color)

func _consume_overcharge() -> bool:
	if overcharge_shots_remaining <= 0:
		return false
	overcharge_shots_remaining -= 1
	return true
