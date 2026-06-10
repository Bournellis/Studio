class_name FootballBot
extends "res://gameplay/combat/combatant_3d.gd"

signal kick_requested(origin: Vector3, direction: Vector3, force: float, lift: float)
signal arcade_dash_started(direction: Vector3)
signal arcade_flip_started(direction: Vector3)

const STATE_KICKOFF: StringName = &"kickoff"
const STATE_CHASE_BALL: StringName = &"chase_ball"
const STATE_ATTACK_GOAL: StringName = &"attack_goal"
const STATE_DEFEND_GOAL: StringName = &"defend_goal"
const STATE_KICK_WINDUP: StringName = &"kick_windup"
const STATE_RECOVER: StringName = &"recover"
const STATE_CELEBRATE: StringName = &"celebrate"
const ARCADE_DASH_SPEED: float = 13.4
const ARCADE_DASH_DURATION: float = 0.22
const ARCADE_DASH_BASE_COOLDOWN: float = 1.65
const ARCADE_FLIP_VERTICAL_VELOCITY: float = 4.1
const ARCADE_FLIP_HORIZONTAL_SPEED: float = 6.8

@export var move_speed: float = 8.2
@export var turn_speed: float = 9.0
@export var kick_range: float = 1.85
@export var kick_force: float = 15.5
@export var clear_force: float = 18.0
@export var kick_lift: float = 1.6
@export var kick_cooldown: float = 0.78
@export var kick_windup_duration: float = 0.16
@export var aim_error_radius: float = 0.42
@export var defend_goal_distance: float = 9.0
@export var approach_offset_distance: float = 1.35
@export var jump_velocity: float = 5.4
@export var jump_cooldown: float = 0.85
@export var prediction_time: float = 0.45
@export var boost_speed_multiplier: float = 1.32
@export var boost_duration: float = 0.42
@export var boost_cooldown: float = 1.35
@export var bot_boost_enabled: bool = true

var ball
var own_goal_position: Vector3 = Vector3(0.0, 0.0, -19.0)
var opponent_goal_position: Vector3 = Vector3(0.0, 0.0, 19.0)
var field_half_width: float = 19.0
var field_half_length: float = 27.0
var current_state: StringName = STATE_KICKOFF
var kick_cooldown_remaining: float = 0.0
var windup_remaining: float = 0.0
var jump_cooldown_remaining: float = 0.0
var boost_cooldown_remaining: float = 0.0
var boost_remaining: float = 0.0
var arcade_dash_remaining: float = 0.0
var arcade_dash_cooldown_remaining: float = 0.0
var arcade_dash_cooldown: float = ARCADE_DASH_BASE_COOLDOWN
var arcade_dash_direction: Vector3 = Vector3.FORWARD
var arcade_dash_count: int = 0
var arcade_flip_available: bool = true
var arcade_flip_count: int = 0
var arcade_stun_remaining: float = 0.0
var arcade_flip_boost_velocity: Vector3 = Vector3.ZERO
var vertical_velocity: float = 0.0
var aim_cycle: int = 0
var kick_count: int = 0
var last_kick_direction: Vector3 = Vector3.FORWARD
var last_move_target: Vector3 = Vector3.ZERO
var last_predicted_ball_position: Vector3 = Vector3.ZERO
var last_approach_label: StringName = &"none"
var windup_is_defensive: bool = false
var difficulty_id: StringName = &"normal"
var boost_pad_targets: Array[Node3D] = []
var boost_pad_collect_count: int = 0

func _ready() -> void:
	super._ready()
	configure_combatant(&"football_bot", 100.0, Color(0.94, 0.2, 0.16, 1.0))

func configure(next_ball: Node3D, next_own_goal_position: Vector3, next_opponent_goal_position: Vector3, next_field_half_width: float = 19.0, next_field_half_length: float = 27.0) -> void:
	ball = next_ball
	own_goal_position = next_own_goal_position
	opponent_goal_position = next_opponent_goal_position
	field_half_width = next_field_half_width
	field_half_length = next_field_half_length
	current_state = STATE_CHASE_BALL
	kick_cooldown_remaining = 0.0
	windup_remaining = 0.0
	jump_cooldown_remaining = 0.0
	boost_cooldown_remaining = 0.0
	boost_remaining = 0.0
	arcade_dash_remaining = 0.0
	arcade_dash_cooldown_remaining = 0.0
	arcade_dash_direction = Vector3.FORWARD
	arcade_dash_count = 0
	arcade_flip_available = true
	arcade_flip_count = 0
	arcade_stun_remaining = 0.0
	arcade_flip_boost_velocity = Vector3.ZERO
	vertical_velocity = 0.0
	aim_cycle = 0
	kick_count = 0
	windup_is_defensive = false
	last_kick_direction = (opponent_goal_position - global_position).normalized()
	last_move_target = global_position
	last_approach_label = &"kickoff"
	boost_pad_collect_count = 0
	clear_movement_impulses()

func set_boost_pad_targets(next_targets: Array[Node3D]) -> void:
	boost_pad_targets = next_targets

func set_difficulty(next_difficulty_id: StringName) -> void:
	difficulty_id = next_difficulty_id
	match difficulty_id:
		&"easy":
			move_speed = 6.7
			kick_force = 13.4
			clear_force = 16.0
			kick_cooldown = 1.08
			aim_error_radius = 0.9
			prediction_time = 0.18
			boost_speed_multiplier = 1.0
			bot_boost_enabled = false
			arcade_dash_cooldown = 2.25
		&"hard":
			move_speed = 10.1
			kick_force = 17.6
			clear_force = 20.2
			kick_cooldown = 0.54
			aim_error_radius = 0.14
			prediction_time = 0.82
			boost_speed_multiplier = 1.46
			bot_boost_enabled = true
			arcade_dash_cooldown = 1.12
		_:
			difficulty_id = &"normal"
			move_speed = 8.2
			kick_force = 15.5
			clear_force = 18.0
			kick_cooldown = 0.78
			aim_error_radius = 0.42
			prediction_time = 0.45
			boost_speed_multiplier = 1.32
			bot_boost_enabled = true
			arcade_dash_cooldown = ARCADE_DASH_BASE_COOLDOWN

func set_celebrating(is_celebrating: bool) -> void:
	current_state = STATE_CELEBRATE if is_celebrating else STATE_CHASE_BALL
	velocity = Vector3.ZERO
	windup_remaining = 0.0
	windup_is_defensive = false

func clear_movement_impulses() -> void:
	velocity = Vector3.ZERO
	knockback_velocity = Vector3.ZERO
	vertical_velocity = 0.0
	arcade_dash_remaining = 0.0
	arcade_flip_boost_velocity = Vector3.ZERO

func notify_boost_pad_collected(full_pad: bool) -> void:
	boost_pad_collect_count += 1
	boost_cooldown_remaining = 0.0
	if full_pad:
		boost_remaining = maxf(boost_remaining, boost_duration)

func apply_jump_pad_launch(launch_velocity: Vector3) -> void:
	vertical_velocity = maxf(vertical_velocity, launch_velocity.y)
	arcade_flip_boost_velocity = Vector3(launch_velocity.x, 0.0, launch_velocity.z)
	arcade_flip_available = true

func apply_arcade_stun(duration: float) -> void:
	arcade_stun_remaining = maxf(arcade_stun_remaining, duration)
	boost_remaining = 0.0
	arcade_dash_remaining = 0.0
	current_state = STATE_RECOVER

func debug_get_state() -> StringName:
	return current_state

func debug_get_kick_count() -> int:
	return kick_count

func debug_get_last_kick_direction() -> Vector3:
	return last_kick_direction

func debug_get_last_move_target() -> Vector3:
	return last_move_target

func debug_get_last_predicted_ball_position() -> Vector3:
	return last_predicted_ball_position

func debug_get_last_approach_label() -> StringName:
	return last_approach_label

func debug_get_boost_pad_collect_count() -> int:
	return boost_pad_collect_count

func debug_get_vertical_velocity() -> float:
	return vertical_velocity

func debug_get_difficulty_id() -> StringName:
	return difficulty_id

func debug_is_boosting() -> bool:
	return boost_remaining > 0.0

func debug_is_arcade_dashing() -> bool:
	return arcade_dash_remaining > 0.0

func debug_get_arcade_dash_count() -> int:
	return arcade_dash_count

func debug_get_arcade_flip_count() -> int:
	return arcade_flip_count

func debug_get_arcade_stun_remaining() -> float:
	return arcade_stun_remaining

func debug_get_arcade_dash_direction() -> Vector3:
	return arcade_dash_direction

func debug_get_aim_error_radius() -> float:
	return aim_error_radius

func _physics_process(delta: float) -> void:
	if ball == null or current_state == STATE_CELEBRATE:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	kick_cooldown_remaining = maxf(0.0, kick_cooldown_remaining - delta)
	jump_cooldown_remaining = maxf(0.0, jump_cooldown_remaining - delta)
	boost_cooldown_remaining = maxf(0.0, boost_cooldown_remaining - delta)
	boost_remaining = maxf(0.0, boost_remaining - delta)
	arcade_dash_cooldown_remaining = maxf(0.0, arcade_dash_cooldown_remaining - delta)
	arcade_stun_remaining = maxf(0.0, arcade_stun_remaining - delta)
	_apply_gravity(delta)
	if arcade_stun_remaining > 0.0:
		var stun_knockback := consume_knockback(delta, is_on_floor())
		velocity = Vector3(stun_knockback.x, stun_knockback.y, stun_knockback.z)
		move_and_slide()
		return

	if current_state == STATE_KICK_WINDUP:
		_handle_windup(delta)
	else:
		_handle_ball_state()
		_move_toward_target(delta)

	move_and_slide()
	if is_on_floor() and vertical_velocity < 0.0:
		vertical_velocity = -0.1
	if is_on_floor():
		arcade_flip_available = true
	_face_ball(delta)

func _handle_ball_state() -> void:
	var ball_position := _get_predicted_ball_position()
	var distance_to_ball: float = _flat_distance(global_position, ball_position)
	if _flat_distance(global_position, ball.global_position) <= kick_range and kick_cooldown_remaining <= 0.0:
		windup_is_defensive = _flat_distance(ball.global_position, own_goal_position) <= defend_goal_distance
		current_state = STATE_KICK_WINDUP
		windup_remaining = kick_windup_duration
		velocity = Vector3.ZERO
		return

	var own_goal_distance: float = _flat_distance(ball_position, own_goal_position)
	if own_goal_distance <= defend_goal_distance:
		current_state = STATE_DEFEND_GOAL
		last_move_target = _build_defend_target(ball_position)
		last_approach_label = &"defend"
		return

	var opponent_goal_distance: float = _flat_distance(ball_position, opponent_goal_position)
	if opponent_goal_distance < own_goal_distance:
		current_state = STATE_ATTACK_GOAL
		last_move_target = _build_ball_approach_target(opponent_goal_position, approach_offset_distance, ball_position)
		last_approach_label = &"attack_setup"
	else:
		current_state = STATE_CHASE_BALL
		last_move_target = _build_ball_approach_target(opponent_goal_position, approach_offset_distance * 0.72, ball_position)
		last_approach_label = &"chase_setup"

func _handle_windup(delta: float) -> void:
	windup_remaining = maxf(0.0, windup_remaining - delta)
	velocity = Vector3(0.0, vertical_velocity, 0.0)
	if windup_remaining > 0.0:
		return
	if _flat_distance(global_position, ball.global_position) <= kick_range + 0.55:
		_emit_kick()
	current_state = STATE_RECOVER
	windup_is_defensive = false
	kick_cooldown_remaining = kick_cooldown

func _emit_kick() -> void:
	var target: Vector3 = opponent_goal_position
	if windup_is_defensive:
		target = opponent_goal_position + Vector3(_aim_pattern(aim_cycle).x * 2.5, 0.0, 0.0)
	var direction: Vector3 = target - ball.global_position
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		direction = global_transform.basis.z
	direction = _apply_aim_error(direction.normalized())
	last_kick_direction = direction
	kick_count += 1
	aim_cycle += 1
	var force := clear_force if windup_is_defensive else kick_force
	kick_requested.emit(global_position + Vector3.UP * 0.9, direction, force, kick_lift)

func _move_toward_target(delta: float) -> void:
	var target := last_move_target
	var boost_pad_target: Node3D = _get_route_boost_pad_target(target)
	if boost_pad_target != null:
		target = boost_pad_target.global_position
		last_move_target = target
		last_approach_label = &"boost_pad"
	target.y = global_position.y
	var to_target := target - global_position
	to_target.y = 0.0
	var desired := Vector3.ZERO
	if to_target.length_squared() > 0.05:
		if _should_start_arcade_dash(to_target.length()):
			_start_arcade_dash(to_target)
		if _should_start_boost(to_target.length()):
			boost_remaining = boost_duration
			boost_cooldown_remaining = boost_cooldown
		var speed := move_speed * (boost_speed_multiplier if boost_remaining > 0.0 else 1.0)
		desired = to_target.normalized() * speed
	if ball.global_position.y > global_position.y + 1.0 and _flat_distance(global_position, ball.global_position) < 3.1:
		_try_jump()
		_try_arcade_flip()
	velocity = desired
	var dash_velocity := _consume_arcade_dash(delta)
	if dash_velocity.length_squared() > 0.0001:
		velocity = dash_velocity
	velocity += _consume_arcade_flip_boost(delta)
	velocity.y = vertical_velocity

func _build_defend_target(ball_position: Vector3) -> Vector3:
	var goal_to_ball: Vector3 = ball_position - own_goal_position
	goal_to_ball.y = 0.0
	if goal_to_ball.length_squared() <= 0.0001:
		goal_to_ball = Vector3.FORWARD
	var target := own_goal_position + goal_to_ball.normalized() * 4.2
	target.x = clampf(target.x, -field_half_width + 1.8, field_half_width - 1.8)
	target.z = clampf(target.z, -field_half_length + 1.8, field_half_length - 1.8)
	return target

func _build_ball_approach_target(goal_position: Vector3, offset_distance: float, ball_position: Vector3) -> Vector3:
	var ball_to_goal: Vector3 = goal_position - ball_position
	ball_to_goal.y = 0.0
	if ball_to_goal.length_squared() <= 0.0001:
		ball_to_goal = Vector3.FORWARD
	var target := ball_position - ball_to_goal.normalized() * maxf(0.0, offset_distance)
	target.x = clampf(target.x, -field_half_width + 1.6, field_half_width - 1.6)
	target.z = clampf(target.z, -field_half_length + 1.8, field_half_length - 1.8)
	return target

func _get_predicted_ball_position() -> Vector3:
	var ball_velocity := Vector3.ZERO
	if ball != null:
		ball_velocity = ball.linear_velocity
	last_predicted_ball_position = ball.global_position + ball_velocity * prediction_time
	last_predicted_ball_position.x = clampf(last_predicted_ball_position.x, -field_half_width + 0.8, field_half_width - 0.8)
	last_predicted_ball_position.z = clampf(last_predicted_ball_position.z, -field_half_length + 0.8, field_half_length - 0.8)
	return last_predicted_ball_position

func _should_start_boost(flat_distance_to_target: float) -> bool:
	if not bot_boost_enabled or boost_remaining > 0.0 or boost_cooldown_remaining > 0.0:
		return false
	if flat_distance_to_target < 5.2:
		return false
	return current_state == STATE_ATTACK_GOAL or current_state == STATE_CHASE_BALL or current_state == STATE_DEFEND_GOAL

func _get_route_boost_pad_target(route_target: Vector3) -> Node3D:
	var best_pad: Node3D = null
	var best_distance: float = INF
	for pad: Node3D in boost_pad_targets:
		if pad == null or not bool(pad.get_meta("active", true)):
			continue
		var pad_position: Vector3 = pad.global_position
		var distance_to_bot: float = _flat_distance(global_position, pad_position)
		if distance_to_bot > 7.5:
			continue
		var route_distance: float = _distance_point_to_segment_2d(pad_position, global_position, route_target)
		if route_distance > 2.0:
			continue
		if distance_to_bot < best_distance:
			best_distance = distance_to_bot
			best_pad = pad
	return best_pad

func _distance_point_to_segment_2d(point: Vector3, start: Vector3, end: Vector3) -> float:
	var p: Vector2 = Vector2(point.x, point.z)
	var a: Vector2 = Vector2(start.x, start.z)
	var b: Vector2 = Vector2(end.x, end.z)
	var ab: Vector2 = b - a
	var ab_length_sq: float = ab.length_squared()
	if ab_length_sq <= 0.0001:
		return p.distance_to(a)
	var t: float = clampf((p - a).dot(ab) / ab_length_sq, 0.0, 1.0)
	return p.distance_to(a + ab * t)

func _should_start_arcade_dash(flat_distance_to_target: float) -> bool:
	if arcade_dash_remaining > 0.0 or arcade_dash_cooldown_remaining > 0.0 or current_state != STATE_DEFEND_GOAL:
		return false
	if flat_distance_to_target < kick_range + 1.2:
		return false
	var ball_velocity: Vector3 = ball.linear_velocity if ball != null else Vector3.ZERO
	var ball_to_goal: Vector3 = own_goal_position - ball.global_position
	ball_to_goal.y = 0.0
	var threat_speed: float = Vector3(ball_velocity.x, 0.0, ball_velocity.z).dot(ball_to_goal.normalized()) if ball_to_goal.length_squared() > 0.0001 else 0.0
	return _flat_distance(ball.global_position, own_goal_position) <= defend_goal_distance + 4.5 or threat_speed > 3.5

func _start_arcade_dash(direction: Vector3) -> bool:
	var flat: Vector3 = Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.0001:
		return false
	arcade_dash_direction = flat.normalized()
	arcade_dash_remaining = ARCADE_DASH_DURATION
	arcade_dash_cooldown_remaining = arcade_dash_cooldown
	arcade_dash_count += 1
	arcade_dash_started.emit(arcade_dash_direction)
	return true

func _consume_arcade_dash(delta: float) -> Vector3:
	if arcade_dash_remaining <= 0.0:
		return Vector3.ZERO
	arcade_dash_remaining = maxf(0.0, arcade_dash_remaining - delta)
	return arcade_dash_direction * ARCADE_DASH_SPEED

func _try_arcade_flip() -> void:
	if is_on_floor() or not arcade_flip_available:
		return
	var direction: Vector3 = ball.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		direction = -global_transform.basis.z
	vertical_velocity = maxf(vertical_velocity, ARCADE_FLIP_VERTICAL_VELOCITY)
	arcade_flip_boost_velocity = direction.normalized() * ARCADE_FLIP_HORIZONTAL_SPEED
	arcade_flip_available = false
	arcade_flip_count += 1
	arcade_flip_started.emit(direction.normalized())

func _consume_arcade_flip_boost(delta: float) -> Vector3:
	var current: Vector3 = arcade_flip_boost_velocity
	arcade_flip_boost_velocity = arcade_flip_boost_velocity.move_toward(Vector3.ZERO, 5.4 * delta)
	return current

func _apply_aim_error(direction: Vector3) -> Vector3:
	var pattern := _aim_pattern(aim_cycle)
	var side := Vector3(direction.z, 0.0, -direction.x).normalized()
	var with_error := direction + side * pattern.x * aim_error_radius + Vector3.FORWARD * pattern.y * aim_error_radius * 0.35
	with_error.y = 0.0
	return with_error.normalized() if with_error.length_squared() > 0.0001 else direction

func _aim_pattern(index: int) -> Vector2:
	const PATTERN: Array[Vector2] = [
		Vector2(0.0, 0.0),
		Vector2(0.7, -0.2),
		Vector2(-0.45, 0.35),
		Vector2(0.28, 0.18),
		Vector2(-0.72, -0.12)
	]
	return PATTERN[index % PATTERN.size()]

func _try_jump() -> void:
	if jump_cooldown_remaining > 0.0 or not is_on_floor():
		return
	vertical_velocity = jump_velocity
	jump_cooldown_remaining = jump_cooldown

func _apply_gravity(delta: float) -> void:
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	elif vertical_velocity < 0.0:
		vertical_velocity = -0.1

func _face_ball(delta: float) -> void:
	var target: Vector3 = ball.global_position
	target.y = global_position.y
	var to_ball: Vector3 = target - global_position
	if to_ball.length_squared() <= 0.001:
		return
	var desired_yaw := atan2(-to_ball.x, -to_ball.z)
	rotation.y = lerp_angle(rotation.y, desired_yaw, clampf(turn_speed * delta, 0.0, 1.0))

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
