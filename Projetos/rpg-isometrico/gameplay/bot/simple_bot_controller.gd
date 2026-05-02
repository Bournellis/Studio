class_name SimpleBotController
extends "res://gameplay/combat/combat_body_3d.gd"

var target
var attack_damage: float = 12.0
var attack_range: float = 1.8
var attack_cooldown: float = 1.1
var attack_cooldown_remaining: float = 0.0
var attack_windup_duration: float = 0.32
var attack_windup_remaining: float = 0.0
var reposition_time_remaining: float = 0.0
var orbit_direction_sign: float = 1.0

const PREFERRED_DISTANCE_MIN: float = 1.7
const PREFERRED_DISTANCE_MAX: float = 2.9

func _ready() -> void:
	combatant_id = &"bot"
	body_color = Color(0.95, 0.38, 0.28, 1.0)
	super._ready()

func configure(context, next_target) -> void:
	target = next_target
	configure_base(context, 135.0, 4.6)
	attack_cooldown_remaining = 0.0
	attack_windup_remaining = 0.0
	reposition_time_remaining = 0.0
	orbit_direction_sign = 1.0

func is_attack_winding_up() -> bool:
	return attack_windup_remaining > 0.0

func is_repositioning() -> bool:
	return reposition_time_remaining > 0.0

func get_attack_range() -> float:
	return attack_range

func get_intent_label() -> String:
	if is_dead:
		return "abatido"
	if target == null or target.is_dead:
		return "sem alvo"
	if attack_windup_remaining > 0.0:
		return "golpe em %.1fs" % attack_windup_remaining
	if reposition_time_remaining > 0.0:
		return "reposicionando"
	var distance_to_target: float = global_position.distance_to(target.global_position)
	if distance_to_target > attack_range:
		return "perseguindo"
	if attack_cooldown_remaining > 0.0:
		return "reorganizando"
	return "pressionando"

func _physics_process(delta: float) -> void:
	if is_dead or target == null or target.is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if is_motion_paused():
		velocity = Vector3.ZERO
		move_and_slide()
		return

	attack_cooldown_remaining = maxf(0.0, attack_cooldown_remaining - delta)
	reposition_time_remaining = maxf(0.0, reposition_time_remaining - delta)

	var chase_vector: Vector3 = target.global_position - global_position
	chase_vector.y = 0.0
	var distance_to_target: float = chase_vector.length()

	if distance_to_target > 0.2:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)

	if attack_windup_remaining > 0.0:
		attack_windup_remaining = maxf(0.0, attack_windup_remaining - delta)
		velocity = Vector3.ZERO
		if attack_windup_remaining == 0.0:
			_resolve_attack()
		move_and_slide()
		return

	if distance_to_target > PREFERRED_DISTANCE_MAX:
		velocity = chase_vector.normalized() * move_speed
	else:
		if attack_cooldown_remaining == 0.0 and distance_to_target <= attack_range:
			velocity = Vector3.ZERO
			attack_windup_remaining = attack_windup_duration
			set_telegraph(Color(1.0, 0.42, 0.22, 1.0), attack_windup_duration)
		else:
			velocity = _build_reposition_velocity(chase_vector, distance_to_target)

	move_and_slide()

func _resolve_attack() -> void:
	clear_telegraph()
	attack_cooldown_remaining = attack_cooldown
	reposition_time_remaining = 0.5
	orbit_direction_sign *= -1.0
	if target == null or target.is_dead:
		return
	if global_position.distance_to(target.global_position) > attack_range + 0.25:
		return

	trigger_action_pulse(Color(1.0, 0.62, 0.34, 1.0), 0.2)
	target.take_damage(attack_damage, combatant_id)
	if game_context != null:
		game_context.register_action(combatant_id, "bot_attack", "Golpe pesado")

func _build_reposition_velocity(chase_vector: Vector3, distance_to_target: float) -> Vector3:
	if chase_vector.length_squared() <= 0.0001:
		return Vector3.ZERO

	var forward: Vector3 = chase_vector.normalized()
	var lateral: Vector3 = Vector3(-forward.z, 0.0, forward.x) * orbit_direction_sign
	var radial: Vector3 = Vector3.ZERO
	if distance_to_target < PREFERRED_DISTANCE_MIN:
		radial = -forward * 0.8
	elif distance_to_target > PREFERRED_DISTANCE_MAX:
		radial = forward * 0.55
	elif reposition_time_remaining <= 0.0 and attack_cooldown_remaining > 0.0:
		radial = -forward * 0.2

	var blended: Vector3 = lateral * 0.85 + radial
	if blended.length_squared() <= 0.0001:
		blended = lateral
	return blended.normalized() * move_speed * 0.88
