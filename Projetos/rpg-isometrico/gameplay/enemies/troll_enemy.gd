class_name TrollEnemy
extends "res://gameplay/combat/combat_body_3d.gd"

var target

var attack_damage: float = 12.0
var attack_range: float = 1.8
var attack_cooldown: float = 1.15
var attack_cooldown_remaining: float = 0.0
var attack_windup: float = 0.56
var attack_windup_remaining: float = 0.0
var attack_recovery: float = 0.42
var attack_recovery_remaining: float = 0.0
var preferred_distance_min: float = 1.2
var preferred_distance_max: float = 2.2
var orbit_direction_sign: float = 1.0

func _ready() -> void:
	body_color = Color(0.72, 0.44, 0.28, 1.0)
	super._ready()

func configure(next_enemy_id: StringName, context, next_target, config: Dictionary = {}) -> void:
	combatant_id = next_enemy_id
	target = next_target
	body_color = config.get("body_color", Color(0.72, 0.44, 0.28, 1.0))
	configure_base(
		context,
		float(config.get("max_health", 62.0)),
		float(config.get("move_speed", 3.2))
	)
	attack_damage = float(config.get("attack_damage", 12.0))
	attack_range = float(config.get("attack_range", 1.8))
	attack_cooldown = float(config.get("attack_cooldown", 1.15))
	attack_windup = float(config.get("attack_windup", 0.56))
	attack_recovery = float(config.get("attack_recovery", 0.42))
	preferred_distance_min = float(config.get("preferred_distance_min", 1.15))
	preferred_distance_max = float(config.get("preferred_distance_max", 2.25))
	attack_cooldown_remaining = 0.0
	attack_windup_remaining = 0.0
	attack_recovery_remaining = 0.0
	orbit_direction_sign = 1.0 if int(config.get("orbit_sign", 1)) >= 0 else -1.0
	scale = Vector3.ONE * float(config.get("body_scale", 1.12))
	_update_visual_state()

func set_target(next_target) -> void:
	target = next_target

func get_attack_range() -> float:
	return attack_range

func is_attack_winding_up() -> bool:
	return attack_windup_remaining > 0.0

func get_intent_label() -> String:
	if is_dead:
		return "abatido"
	if target == null or target.is_dead:
		return "sem alvo"
	if attack_windup_remaining > 0.0:
		return "martelada em %.1fs" % attack_windup_remaining
	if attack_recovery_remaining > 0.0:
		return "reagrupando"
	var distance_to_target: float = global_position.distance_to(target.global_position)
	if distance_to_target > attack_range:
		return "avancando"
	if attack_cooldown_remaining > 0.0:
		return "pressionando"
	return "pronto para golpear"

func get_runtime_snapshot() -> Dictionary:
	return {
		"enemy_id": String(combatant_id),
		"combat": build_combat_snapshot(),
		"config": _serialize_variant(_build_runtime_config()),
		"attack_cooldown_remaining": attack_cooldown_remaining,
		"attack_windup_remaining": attack_windup_remaining,
		"attack_recovery_remaining": attack_recovery_remaining,
		"orbit_direction_sign": orbit_direction_sign
	}

func restore_runtime_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	restore_combat_snapshot(Dictionary(snapshot.get("combat", {})))
	attack_cooldown_remaining = maxf(0.0, float(snapshot.get("attack_cooldown_remaining", 0.0)))
	attack_windup_remaining = maxf(0.0, float(snapshot.get("attack_windup_remaining", 0.0)))
	attack_recovery_remaining = maxf(0.0, float(snapshot.get("attack_recovery_remaining", 0.0)))
	orbit_direction_sign = -1.0 if float(snapshot.get("orbit_direction_sign", orbit_direction_sign)) < 0.0 else 1.0

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
	attack_recovery_remaining = maxf(0.0, attack_recovery_remaining - delta)

	var chase_vector: Vector3 = target.global_position - global_position
	chase_vector.y = 0.0
	var distance_to_target: float = chase_vector.length()

	if distance_to_target > 0.15:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)

	if attack_windup_remaining > 0.0:
		attack_windup_remaining = maxf(0.0, attack_windup_remaining - delta)
		velocity = Vector3.ZERO
		if attack_windup_remaining == 0.0:
			_resolve_attack()
		move_and_slide()
		return

	if distance_to_target > preferred_distance_max:
		velocity = chase_vector.normalized() * move_speed
	elif attack_cooldown_remaining == 0.0 and distance_to_target <= attack_range:
		velocity = Vector3.ZERO
		attack_windup_remaining = attack_windup
		set_telegraph(Color(1.0, 0.38, 0.24, 1.0), attack_windup)
	else:
		velocity = _build_pressure_velocity(chase_vector, distance_to_target)

	move_and_slide()

func _resolve_attack() -> void:
	clear_telegraph()
	attack_cooldown_remaining = attack_cooldown
	attack_recovery_remaining = attack_recovery
	orbit_direction_sign *= -1.0
	if target == null or target.is_dead:
		return
	if global_position.distance_to(target.global_position) > attack_range + 0.3:
		return

	trigger_action_pulse(Color(1.0, 0.56, 0.32, 1.0), 0.2)
	target.take_damage(attack_damage, combatant_id)
	if game_context != null:
		game_context.register_action(combatant_id, "enemy_attack", "Martelada troll")

func _build_pressure_velocity(chase_vector: Vector3, distance_to_target: float) -> Vector3:
	if chase_vector.length_squared() <= 0.0001:
		return Vector3.ZERO

	var forward: Vector3 = chase_vector.normalized()
	var lateral: Vector3 = Vector3(-forward.z, 0.0, forward.x) * orbit_direction_sign
	var radial: Vector3 = Vector3.ZERO
	if distance_to_target < preferred_distance_min:
		radial = -forward * 0.92
	elif attack_recovery_remaining > 0.0:
		radial = -forward * 0.38
	elif distance_to_target > preferred_distance_max:
		radial = forward * 0.7

	var blended: Vector3 = lateral * 0.52 + radial
	if blended.length_squared() <= 0.0001:
		blended = forward
	return blended.normalized() * move_speed

func _build_runtime_config() -> Dictionary:
	return {
		"body_color": body_color,
		"max_health": max_health,
		"move_speed": move_speed,
		"attack_damage": attack_damage,
		"attack_range": attack_range,
		"attack_cooldown": attack_cooldown,
		"attack_windup": attack_windup,
		"attack_recovery": attack_recovery,
		"preferred_distance_min": preferred_distance_min,
		"preferred_distance_max": preferred_distance_max,
		"orbit_sign": -1 if orbit_direction_sign < 0.0 else 1,
		"body_scale": scale.x
	}
