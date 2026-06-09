class_name BasicDuelBot
extends "res://gameplay/combat/combatant_3d.gd"

signal shot_fired()
signal shot_windup_started(origin: Vector3, target_position: Vector3, duration: float)
signal shot_feedback_requested(origin: Vector3, target_position: Vector3)

@export var move_speed: float = 4.4
@export var preferred_distance: float = 9.0
@export var shoot_range: float = 18.0
@export var shoot_damage: float = 9.0
@export var shoot_knockback: float = 3.6
@export var shoot_cooldown: float = 0.75
@export var shot_tell_duration: float = 0.18

var target
var shoot_cooldown_remaining: float = 0.0
var vertical_velocity: float = 0.0
var shot_tell_remaining: float = 0.0
var is_telegraphing: bool = false

func _ready() -> void:
	super._ready()
	configure_combatant(&"bot", 100.0, Color(1.0, 0.34, 0.22, 1.0))

func configure(next_target) -> void:
	target = next_target
	configure_combatant(&"bot", 100.0, Color(1.0, 0.34, 0.22, 1.0))
	shoot_cooldown_remaining = 0.2
	vertical_velocity = 0.0
	_cancel_windup()

func force_fire() -> void:
	_cancel_windup()
	_fire()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	shoot_cooldown_remaining = maxf(0.0, shoot_cooldown_remaining - delta)
	_handle_movement(delta)
	_handle_shot_flow(delta)
	move_and_slide()
	if is_on_floor() and vertical_velocity < 0.0:
		vertical_velocity = -0.1

func _handle_movement(delta: float) -> void:
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	if not is_on_floor():
		vertical_velocity -= gravity * delta

	if target == null or target.is_dead:
		velocity = Vector3(0.0, vertical_velocity, 0.0)
		return

	var to_target: Vector3 = target.global_position - global_position
	to_target.y = 0.0
	var distance: float = to_target.length()
	if distance > 0.05:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)

	var desired := Vector3.ZERO
	if distance > preferred_distance:
		desired = to_target.normalized()
	elif distance < preferred_distance * 0.65:
		desired = -to_target.normalized()
	else:
		var lateral := Vector3(-to_target.z, 0.0, to_target.x)
		if lateral.length_squared() > 0.0001:
			desired = lateral.normalized() * 0.6

	var knockback := consume_knockback(delta)
	velocity = desired * move_speed + Vector3(knockback.x, 0.0, knockback.z)
	velocity.y = vertical_velocity + knockback.y

func _try_fire() -> void:
	if target == null or target.is_dead:
		return
	if shoot_cooldown_remaining > 0.0:
		return
	if global_position.distance_to(target.global_position) > shoot_range:
		return
	is_telegraphing = true
	shot_tell_remaining = shot_tell_duration
	shot_windup_started.emit(_get_shot_origin(), _get_target_position(), shot_tell_duration)

func _handle_shot_flow(delta: float) -> void:
	if is_telegraphing:
		if target == null or target.is_dead:
			_cancel_windup()
			return
		shot_tell_remaining = maxf(0.0, shot_tell_remaining - delta)
		if shot_tell_remaining <= 0.0:
			_cancel_windup()
			_fire()
		return
	_try_fire()

func _fire() -> void:
	if target == null or target.is_dead:
		return
	shoot_cooldown_remaining = shoot_cooldown
	var origin := _get_shot_origin()
	var target_position := _get_target_position()
	var direction: Vector3 = target_position - origin
	direction.y = 0.0
	target.take_damage(shoot_damage, combatant_id)
	target.apply_knockback(direction, shoot_knockback)
	shot_feedback_requested.emit(origin, target_position)
	shot_fired.emit()

func _cancel_windup() -> void:
	is_telegraphing = false
	shot_tell_remaining = 0.0

func _get_shot_origin() -> Vector3:
	return get_body_center() + Vector3.UP * 0.2

func _get_target_position() -> Vector3:
	if target != null and target.has_method("get_body_center"):
		return target.get_body_center()
	if target != null:
		return target.global_position + Vector3.UP * 0.8
	return global_position
