class_name FootballBot
extends "res://gameplay/combat/combatant_3d.gd"

signal kick_requested(origin: Vector3, direction: Vector3, force: float, lift: float)

const STATE_KICKOFF: StringName = &"kickoff"
const STATE_CHASE_BALL: StringName = &"chase_ball"
const STATE_ATTACK_GOAL: StringName = &"attack_goal"
const STATE_DEFEND_GOAL: StringName = &"defend_goal"
const STATE_KICK_WINDUP: StringName = &"kick_windup"
const STATE_RECOVER: StringName = &"recover"
const STATE_CELEBRATE: StringName = &"celebrate"

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
@export var jump_velocity: float = 5.4
@export var jump_cooldown: float = 0.85

var ball: FootballBall3D
var own_goal_position: Vector3 = Vector3(0.0, 0.0, -19.0)
var opponent_goal_position: Vector3 = Vector3(0.0, 0.0, 19.0)
var current_state: StringName = STATE_KICKOFF
var kick_cooldown_remaining: float = 0.0
var windup_remaining: float = 0.0
var jump_cooldown_remaining: float = 0.0
var vertical_velocity: float = 0.0
var aim_cycle: int = 0
var kick_count: int = 0
var last_kick_direction: Vector3 = Vector3.FORWARD
var last_move_target: Vector3 = Vector3.ZERO
var windup_is_defensive: bool = false

func _ready() -> void:
	super._ready()
	configure_combatant(&"football_bot", 100.0, Color(0.94, 0.2, 0.16, 1.0))

func configure(next_ball: FootballBall3D, next_own_goal_position: Vector3, next_opponent_goal_position: Vector3) -> void:
	ball = next_ball
	own_goal_position = next_own_goal_position
	opponent_goal_position = next_opponent_goal_position
	current_state = STATE_CHASE_BALL
	kick_cooldown_remaining = 0.0
	windup_remaining = 0.0
	jump_cooldown_remaining = 0.0
	vertical_velocity = 0.0
	aim_cycle = 0
	kick_count = 0
	windup_is_defensive = false
	last_kick_direction = (opponent_goal_position - global_position).normalized()
	last_move_target = global_position
	clear_movement_impulses()

func set_celebrating(is_celebrating: bool) -> void:
	current_state = STATE_CELEBRATE if is_celebrating else STATE_CHASE_BALL
	velocity = Vector3.ZERO
	windup_remaining = 0.0
	windup_is_defensive = false

func clear_movement_impulses() -> void:
	velocity = Vector3.ZERO
	knockback_velocity = Vector3.ZERO
	vertical_velocity = 0.0

func debug_get_state() -> StringName:
	return current_state

func debug_get_kick_count() -> int:
	return kick_count

func debug_get_last_kick_direction() -> Vector3:
	return last_kick_direction

func debug_get_last_move_target() -> Vector3:
	return last_move_target

func _physics_process(delta: float) -> void:
	if ball == null or current_state == STATE_CELEBRATE:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	kick_cooldown_remaining = maxf(0.0, kick_cooldown_remaining - delta)
	jump_cooldown_remaining = maxf(0.0, jump_cooldown_remaining - delta)
	_apply_gravity(delta)

	if current_state == STATE_KICK_WINDUP:
		_handle_windup(delta)
	else:
		_handle_ball_state()
		_move_toward_target(delta)

	move_and_slide()
	if is_on_floor() and vertical_velocity < 0.0:
		vertical_velocity = -0.1
	_face_ball(delta)

func _handle_ball_state() -> void:
	var ball_position := ball.global_position
	var distance_to_ball := _flat_distance(global_position, ball_position)
	if distance_to_ball <= kick_range and kick_cooldown_remaining <= 0.0:
		windup_is_defensive = _flat_distance(ball_position, own_goal_position) <= defend_goal_distance
		current_state = STATE_KICK_WINDUP
		windup_remaining = kick_windup_duration
		velocity = Vector3.ZERO
		return

	var own_goal_distance := _flat_distance(ball_position, own_goal_position)
	if own_goal_distance <= defend_goal_distance:
		current_state = STATE_DEFEND_GOAL
		last_move_target = _build_defend_target()
		return

	var opponent_goal_distance := _flat_distance(ball_position, opponent_goal_position)
	if opponent_goal_distance < own_goal_distance:
		current_state = STATE_ATTACK_GOAL
	else:
		current_state = STATE_CHASE_BALL
	last_move_target = ball_position

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
	var target := opponent_goal_position
	if windup_is_defensive:
		target = opponent_goal_position + Vector3(_aim_pattern(aim_cycle).x * 2.5, 0.0, 0.0)
	var direction := target - ball.global_position
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
	target.y = global_position.y
	var to_target := target - global_position
	to_target.y = 0.0
	var desired := Vector3.ZERO
	if to_target.length_squared() > 0.05:
		desired = to_target.normalized() * move_speed
	if ball.global_position.y > global_position.y + 1.0 and _flat_distance(global_position, ball.global_position) < 3.1:
		_try_jump()
	velocity = desired
	velocity.y = vertical_velocity

func _build_defend_target() -> Vector3:
	var ball_position := ball.global_position
	var goal_to_ball := ball_position - own_goal_position
	goal_to_ball.y = 0.0
	if goal_to_ball.length_squared() <= 0.0001:
		goal_to_ball = Vector3.FORWARD
	return own_goal_position + goal_to_ball.normalized() * 4.2

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
	var target := ball.global_position
	target.y = global_position.y
	var to_ball := target - global_position
	if to_ball.length_squared() <= 0.001:
		return
	var desired_yaw := atan2(-to_ball.x, -to_ball.z)
	rotation.y = lerp_angle(rotation.y, desired_yaw, clampf(turn_speed * delta, 0.0, 1.0))

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
