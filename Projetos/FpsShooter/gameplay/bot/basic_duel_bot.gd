class_name BasicDuelBot
extends "res://gameplay/combat/combatant_3d.gd"

signal shot_fired()
signal shot_windup_started(origin: Vector3, target_position: Vector3, duration: float)
signal shot_feedback_requested(origin: Vector3, target_position: Vector3)
signal shot_resolution_requested(origin: Vector3, direction: Vector3, damage: float, knockback: float)

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
@export var shoot_cooldown: float = 0.82
@export var shot_tell_duration: float = 0.18
@export var reaction_time: float = 0.2
@export var aim_error_radius: float = 0.48
@export var close_range_aim_error_radius: float = 0.16
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
@export var low_health_pickup_threshold: float = 0.48
@export var pickup_interest_distance: float = 17.0
@export var overcharge_interest_distance: float = 14.0
@export var overcharge_damage_multiplier: float = 1.25
@export var overcharge_knockback_multiplier: float = 1.18
@export var projectile_dodge_radius: float = 3.2
@export var projectile_dodge_strength: float = 1.2

var target
var shoot_cooldown_remaining: float = 0.0
var vertical_velocity: float = 0.0
var shot_tell_remaining: float = 0.0
var is_telegraphing: bool = false
var current_state: StringName = STATE_IDLE
var state_time_remaining: float = 0.0
var reaction_remaining: float = 0.0
var reposition_cooldown_remaining: float = 0.0
var strafe_direction: float = 1.0
var reposition_points: Array[Vector3] = []
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
	_cancel_windup(STATE_ENGAGE)

func set_reposition_points(points: Array[Vector3]) -> void:
	reposition_points = points.duplicate()

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

func _physics_process(delta: float) -> void:
	if is_dead:
		_cancel_windup(STATE_DEAD)
		current_state = STATE_DEAD
		velocity = Vector3.ZERO
		move_and_slide()
		return

	shoot_cooldown_remaining = maxf(0.0, shoot_cooldown_remaining - delta)
	reposition_cooldown_remaining = maxf(0.0, reposition_cooldown_remaining - delta)
	state_time_remaining = maxf(0.0, state_time_remaining - delta)
	reaction_remaining = maxf(0.0, reaction_remaining - delta)
	_apply_gravity(delta)

	var before_position := global_position
	last_has_line_of_sight = _refresh_target_visibility()
	last_desired_move = _handle_duel_state(delta)
	last_desired_move = _apply_projectile_dodge(last_desired_move)
	velocity = _build_velocity(last_desired_move, delta)
	move_and_slide()
	_update_grounded_vertical_velocity()
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
	if _try_start_pickup_reposition():
		return _movement_toward_reposition()
	if not last_has_line_of_sight:
		_start_reposition()
		return _movement_toward_reposition()
	if _can_start_windup():
		_start_windup()
		return Vector3.ZERO
	if reposition_cooldown_remaining <= 0.0:
		_start_strafe()
		return _strafe_movement()
	return _distance_management_movement()

func _handle_strafe() -> Vector3:
	if _try_start_pickup_reposition():
		return _movement_toward_reposition()
	if not last_has_line_of_sight:
		_start_reposition()
		return _movement_toward_reposition()
	if _can_start_windup():
		_start_windup()
		return Vector3.ZERO
	if state_time_remaining <= 0.0:
		_set_state(STATE_ENGAGE)
	return _strafe_movement()

func _handle_reposition() -> Vector3:
	if _distance_to_reposition_destination() <= reposition_arrival_distance:
		reposition_cooldown_remaining = reposition_interval
		_start_strafe()
		return _strafe_movement()
	if state_time_remaining <= 0.0:
		reposition_cooldown_remaining = reposition_interval * 0.55
		_start_strafe()
		return _strafe_movement()
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
	if state_time_remaining <= 0.0:
		if not last_has_line_of_sight:
			_start_reposition()
			return _movement_toward_reposition()
		_start_strafe()
	return _strafe_movement()

func _can_start_windup() -> bool:
	if shoot_cooldown_remaining > 0.0:
		return false
	if reaction_remaining > 0.0:
		return false
	if target == null or target.is_dead:
		return false
	if _distance_to_target() > shoot_range:
		return false
	return last_has_line_of_sight

func _start_windup() -> void:
	is_telegraphing = true
	shot_tell_remaining = shot_tell_duration
	windup_line_of_sight_grace_remaining = lost_line_of_sight_grace
	last_aim_position = _build_aim_position(last_visible_target_position)
	pending_shot_direction = (last_aim_position - _get_shot_origin()).normalized()
	_set_state(STATE_WINDUP, shot_tell_duration)
	shot_windup_started.emit(_get_shot_origin(), last_aim_position, shot_tell_duration)

func _start_strafe() -> void:
	strafe_direction *= -1.0
	_set_state(STATE_STRAFE, strafe_duration)

func _start_reposition() -> void:
	_choose_reposition_destination()
	_set_state(STATE_REPOSITION, maxf(0.8, preferred_distance / maxf(0.1, move_speed)))

func _start_reposition_to(destination: Vector3) -> void:
	reposition_destination = _clamp_arena_point(destination)
	_set_state(STATE_REPOSITION, maxf(0.8, global_position.distance_to(reposition_destination) / maxf(0.1, move_speed)))

func _try_start_pickup_reposition() -> bool:
	if current_state == STATE_REPOSITION or current_state == STATE_WINDUP:
		return false
	if health_pickup_available and health_fraction() <= low_health_pickup_threshold:
		if _flat_distance_to(health_pickup_position) <= pickup_interest_distance:
			_start_reposition_to(health_pickup_position)
			return true
	var can_contest_overcharge := not last_has_line_of_sight or shoot_cooldown_remaining > shoot_cooldown * 0.45
	if overcharge_pickup_available and not has_overcharge_charge() and can_contest_overcharge:
		if _flat_distance_to(overcharge_pickup_position) <= overcharge_interest_distance:
			_start_reposition_to(overcharge_pickup_position)
			return true
	return false

func _fire_requested_shot() -> void:
	if target == null or target.is_dead:
		_cancel_windup(STATE_IDLE)
		return
	var origin := _get_shot_origin()
	var direction := pending_shot_direction
	if direction.length_squared() <= 0.0001:
		direction = (last_aim_position - origin).normalized()
	is_telegraphing = false
	shot_tell_remaining = 0.0
	shoot_cooldown_remaining = shoot_cooldown
	reaction_remaining = reaction_time
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
	var points: Array[Vector3] = []
	if target == null:
		return points
	if target.has_method("get_shot_origin"):
		_append_unique_visibility_point(points, target.get_shot_origin())
	var target_base: Vector3 = target.global_position
	_append_unique_visibility_point(points, target_base + Vector3.UP * target_head_visibility_height)
	_append_unique_visibility_point(points, target_base + Vector3.UP * target_upper_visibility_height)
	_append_unique_visibility_point(points, _get_target_position())
	_append_unique_visibility_point(points, target_base + Vector3.UP * target_center_visibility_height)
	_append_unique_visibility_point(points, target_base + Vector3.UP * target_lower_visibility_height)
	return points

func _append_unique_visibility_point(points: Array[Vector3], target_point: Vector3) -> void:
	for existing_point in points:
		if existing_point.distance_squared_to(target_point) <= 0.0001:
			return
	points.append(target_point)

func _has_clear_visibility_to_point(target_point: Vector3) -> bool:
	var origin := _get_shot_origin()
	var query := PhysicsRayQueryParameters3D.create(origin, target_point)
	query.exclude = [get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.get("collider", null) == target

func _build_aim_position(base_target_position: Vector3) -> Vector3:
	var target_position := base_target_position
	var to_target := target_position - _get_shot_origin()
	var flat := Vector3(to_target.x, 0.0, to_target.z)
	var distance := flat.length()
	var distance_factor := clampf(distance / maxf(1.0, shoot_range), 0.0, 1.0)
	var error_radius := lerpf(close_range_aim_error_radius, aim_error_radius, distance_factor)
	var right := Vector3.RIGHT
	if flat.length_squared() > 0.0001:
		var forward := flat.normalized()
		right = Vector3(-forward.z, 0.0, forward.x).normalized()
	var pattern := _aim_pattern(aim_cycle_index)
	aim_cycle_index += 1
	return target_position + right * pattern.x * error_radius + Vector3.UP * pattern.y * error_radius

func _aim_pattern(index: int) -> Vector2:
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

func _choose_reposition_destination() -> void:
	var candidate_points := reposition_points
	if candidate_points.is_empty():
		candidate_points = _fallback_reposition_points()
	var best_score := -1000000.0
	var best_point := global_position
	for index in range(candidate_points.size()):
		var point := _clamp_arena_point(candidate_points[index])
		var target_distance := point.distance_to(_get_target_position())
		var distance_score := -absf(target_distance - preferred_distance)
		var travel_score := global_position.distance_to(point) * 0.12
		var cycle_score := 0.01 * float((index + reposition_cycle_index) % maxi(1, candidate_points.size()))
		var score := distance_score + travel_score + cycle_score
		if score > best_score:
			best_score = score
			best_point = point
	reposition_cycle_index += 1
	reposition_destination = best_point

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
	var to_destination := reposition_destination - global_position
	to_destination.y = 0.0
	if to_destination.length_squared() <= 0.0001:
		return _distance_management_movement()
	return (to_destination.normalized() + _distance_management_movement() * 0.3).normalized()

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
	return horizontal * move_speed * speed_multiplier + Vector3(knockback.x, vertical_velocity + knockback.y, knockback.z)

func _apply_projectile_dodge(desired_move: Vector3) -> Vector3:
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

func _clamp_arena_point(point: Vector3) -> Vector3:
	return Vector3(
		clampf(point.x, -arena_half_extent, arena_half_extent),
		global_position.y,
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
