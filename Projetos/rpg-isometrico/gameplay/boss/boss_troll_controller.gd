class_name BossTrollController
extends "res://gameplay/combat/combat_body_3d.gd"

const BossTremorZone = preload("res://gameplay/boss/boss_tremor_zone.gd")

enum BossPhase {
	PHASE_1,
	PHASE_2,
	PHASE_3
}

enum BossState {
	DORMANT,
	WAKING_UP,
	NAVIGATE,
	WINDUP,
	RECOVERY,
	PHASE_TRANSITION,
	DEAD
}

enum BossAttack {
	NONE,
	MARTELADA,
	TREMOR,
	RUGIDO
}

signal phase_changed(phase_number: int)
signal tremor_zone_spawned(zone)

const BOSS_DISPLAY_NAME: String = "Boss Troll"
const MAX_HP: float = 8000.0
const DAMAGE_RESISTANCE: float = 0.10
const AGGRO_RADIUS: float = 12.0
const WAKE_UP_DURATION: float = 1.5
const PHASE_TRANSITION_DURATION: float = 2.0
const PHASE_2_THRESHOLD: float = 0.65
const PHASE_3_THRESHOLD: float = 0.30

const SPEED_PHASE_1: float = 2.5
const SPEED_PHASE_2: float = 3.5
const SPEED_PHASE_3: float = 4.5

const REGEN_PHASE_1: float = 15.0
const REGEN_PHASE_2: float = 25.0
const REGEN_PHASE_3: float = 0.0

const CADENCE_PHASE_1: float = 1.0
const CADENCE_PHASE_2: float = 1.2
const CADENCE_PHASE_3: float = 1.4

const ROAR_CAMP_RANGE: float = 3.0
const ROAR_CAMP_DURATION: float = 3.0
const ROAR_STUN_DURATION: float = 2.0
const ROAR_FOLLOW_UP_DAMAGE: float = 200.0
const ROAR_RADIUS: float = 5.0
const ROAR_RADIUS_PHASE_2_BONUS: float = 1.0
const ROAR_WINDUP: float = 0.5
const ROAR_ACTIVE: float = 0.1
const ROAR_RECOVERY: float = 0.25
const ROAR_COOLDOWN: float = 15.0
const ROAR_COOLDOWN_PHASE_3: float = 10.0

const MARTELADA_DAMAGE: float = 350.0
const MARTELADA_RANGE: float = 3.0
const MARTELADA_TRIGGER_RANGE: float = 4.0
const MARTELADA_CONE_ANGLE: float = 60.0
const MARTELADA_WINDUP_PHASE_1: float = 1.4
const MARTELADA_WINDUP_PHASE_3: float = 1.1
const MARTELADA_ACTIVE: float = 0.2
const MARTELADA_RECOVERY: float = 1.0
const MARTELADA_POST_COOLDOWN: float = 0.8

const TREMOR_WINDUP: float = 0.6
const TREMOR_ACTIVE: float = 0.1
const TREMOR_RECOVERY: float = 0.25
const TREMOR_POST_COOLDOWN: float = 1.4
const TREMOR_ZONE_DURATION: float = 2.5
const TREMOR_TICK_DAMAGE: float = 40.0
const TREMOR_RADIUS_MIN: float = 6.0
const TREMOR_RADIUS_MAX: float = 8.0
const TREMOR_PREFERRED_MIN_RANGE: float = 4.0
const TREMOR_PREFERRED_MAX_RANGE: float = 10.0
const TREMOR_CRACK_COUNT_PHASE_1: int = 7
const TREMOR_CRACK_COUNT_PHASE_2: int = 9

const BOSS_SCALE: float = 2.55
const TARGET_HEIGHT_OFFSET: Vector3 = Vector3(0.0, 0.2, 0.0)
const ROAR_TELEGRAPH_COLOR: Color = Color(1.0, 0.52, 0.2, 1.0)
const MARTELADA_TELEGRAPH_COLOR: Color = Color(1.0, 0.34, 0.2, 1.0)
const TREMOR_TELEGRAPH_COLOR: Color = Color(1.0, 0.26, 0.16, 1.0)
const TRANSITION_TELEGRAPH_COLOR: Color = Color(1.0, 0.18, 0.12, 1.0)

var target
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var state: BossState = BossState.DORMANT
var current_phase: BossPhase = BossPhase.PHASE_1
var active_attack: BossAttack = BossAttack.NONE
var state_time_remaining: float = 0.0
var attack_cooldown_remaining: float = 0.0
var roar_camp_time: float = 0.0
var roar_cooldown_remaining: float = 0.0
var roar_follow_up_time_remaining: float = 0.0
var roar_follow_up_pending: bool = false
var active_tremor_zone: BossTremorZone

func _ready() -> void:
	body_color = Color(0.62, 0.44, 0.38, 1.0)
	rng.randomize()
	super._ready()
	_apply_boss_visuals()

func configure(next_boss_id: StringName, context, next_target) -> void:
	combatant_id = next_boss_id
	target = next_target
	configure_base(context, MAX_HP, SPEED_PHASE_1)
	current_phase = BossPhase.PHASE_1
	state = BossState.DORMANT
	active_attack = BossAttack.NONE
	state_time_remaining = 0.0
	attack_cooldown_remaining = 0.0
	roar_camp_time = 0.0
	roar_cooldown_remaining = 0.0
	roar_follow_up_time_remaining = 0.0
	roar_follow_up_pending = false
	active_tremor_zone = null
	_apply_phase_stats()
	_apply_boss_visuals()
	clear_telegraph()

func take_damage(amount: float, source_id: StringName = &"") -> void:
	if amount <= 0.0 or _is_invulnerable():
		return
	super.take_damage(amount * (1.0 - DAMAGE_RESISTANCE), source_id)

func set_target(next_target) -> void:
	target = next_target

func get_phase_number() -> int:
	return int(current_phase) + 1

func get_phase_label() -> String:
	return "Fase %d" % get_phase_number()

func get_boss_name() -> String:
	return BOSS_DISPLAY_NAME

func get_current_regen() -> float:
	match current_phase:
		BossPhase.PHASE_1:
			return REGEN_PHASE_1
		BossPhase.PHASE_2:
			return REGEN_PHASE_2
		_:
			return REGEN_PHASE_3

func get_current_roar_radius() -> float:
	return ROAR_RADIUS + (ROAR_RADIUS_PHASE_2_BONUS if current_phase != BossPhase.PHASE_1 else 0.0)

func get_intent_label() -> String:
	if is_dead or state == BossState.DEAD:
		return "derrotado"

	match state:
		BossState.DORMANT:
			return "dormente no centro"
		BossState.WAKING_UP:
			return "despertando %.1fs" % state_time_remaining
		BossState.PHASE_TRANSITION:
			return "transicao %.1fs" % state_time_remaining
		BossState.WINDUP:
			return "%s em %.1fs" % [_attack_label(active_attack), state_time_remaining]
		BossState.RECOVERY:
			return "recuperando %.1fs" % state_time_remaining
		_:
			if roar_follow_up_pending:
				return "seguimento do rugido em %.1fs" % roar_follow_up_time_remaining
			if target == null or not is_instance_valid(target) or target.is_dead:
				return "sem alvo"
			var distance_to_target: float = global_position.distance_to(target.global_position)
			if distance_to_target > TREMOR_PREFERRED_MIN_RANGE:
				return "avancando"
			if roar_camp_time > 0.0 and roar_cooldown_remaining <= 0.0:
				return "preparando rugido"
			return "pressionando de perto"

func get_runtime_snapshot() -> Dictionary:
	return {
		"boss_id": String(combatant_id),
		"boss_name": BOSS_DISPLAY_NAME,
		"phase_number": get_phase_number(),
		"phase_label": get_phase_label(),
		"health": health,
		"max_health": max_health,
		"health_ratio": health_fraction(),
		"state_label": _state_label(),
		"intent_label": get_intent_label(),
		"attack_label": _attack_label(active_attack),
		"attack_cooldown_remaining": attack_cooldown_remaining,
		"regen_per_second": get_current_regen(),
		"roar_radius": get_current_roar_radius(),
		"roar_cooldown_remaining": roar_cooldown_remaining,
		"camp_time_remaining": maxf(0.0, ROAR_CAMP_DURATION - roar_camp_time),
		"tremor_active": active_tremor_zone != null and is_instance_valid(active_tremor_zone),
		"invulnerable": _is_invulnerable(),
		"combat": build_combat_snapshot(),
		"current_phase": int(current_phase),
		"state": int(state),
		"active_attack": int(active_attack),
		"state_time_remaining": state_time_remaining,
		"roar_camp_time": roar_camp_time,
		"roar_follow_up_time_remaining": roar_follow_up_time_remaining,
		"roar_follow_up_pending": roar_follow_up_pending,
		"tremor_zone": {} if active_tremor_zone == null or not is_instance_valid(active_tremor_zone) else active_tremor_zone.get_runtime_snapshot()
	}

func restore_runtime_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	current_phase = clampi(int(snapshot.get("current_phase", int(current_phase))), int(BossPhase.PHASE_1), int(BossPhase.PHASE_3))
	_apply_phase_stats()
	restore_combat_snapshot(Dictionary(snapshot.get("combat", {})))
	state = clampi(int(snapshot.get("state", int(state))), int(BossState.DORMANT), int(BossState.DEAD))
	active_attack = clampi(int(snapshot.get("active_attack", int(active_attack))), int(BossAttack.NONE), int(BossAttack.RUGIDO))
	state_time_remaining = maxf(0.0, float(snapshot.get("state_time_remaining", 0.0)))
	attack_cooldown_remaining = maxf(0.0, float(snapshot.get("attack_cooldown_remaining", 0.0)))
	roar_camp_time = maxf(0.0, float(snapshot.get("roar_camp_time", 0.0)))
	roar_cooldown_remaining = maxf(0.0, float(snapshot.get("roar_cooldown_remaining", 0.0)))
	roar_follow_up_time_remaining = maxf(0.0, float(snapshot.get("roar_follow_up_time_remaining", 0.0)))
	roar_follow_up_pending = bool(snapshot.get("roar_follow_up_pending", false))

func attach_restored_tremor_zone(zone: BossTremorZone) -> void:
	if active_tremor_zone != null and is_instance_valid(active_tremor_zone):
		active_tremor_zone.queue_free()
	active_tremor_zone = zone
	if active_tremor_zone != null and not active_tremor_zone.expired.is_connected(_on_tremor_zone_expired):
		active_tremor_zone.expired.connect(_on_tremor_zone_expired)

func _physics_process(delta: float) -> void:
	if is_dead:
		state = BossState.DEAD
		clear_telegraph()
		velocity = Vector3.ZERO
		move_and_slide()
		return

	_tick_shared_timers(delta)
	_update_phase_from_health()
	_apply_regeneration(delta)

	if is_motion_paused():
		velocity = Vector3.ZERO
		move_and_slide()
		return

	match state:
		BossState.DORMANT:
			_tick_dormant()
		BossState.WAKING_UP:
			_tick_wake_up(delta)
		BossState.NAVIGATE:
			_tick_navigation()
		BossState.WINDUP:
			_tick_windup(delta)
		BossState.RECOVERY:
			_tick_recovery(delta)
		BossState.PHASE_TRANSITION:
			_tick_phase_transition(delta)
		BossState.DEAD:
			velocity = Vector3.ZERO

	move_and_slide()

func _tick_shared_timers(delta: float) -> void:
	attack_cooldown_remaining = maxf(0.0, attack_cooldown_remaining - delta)
	roar_cooldown_remaining = maxf(0.0, roar_cooldown_remaining - delta)

	if roar_follow_up_pending:
		roar_follow_up_time_remaining = maxf(0.0, roar_follow_up_time_remaining - delta)
		if roar_follow_up_time_remaining == 0.0:
			_resolve_roar_follow_up()

func _tick_dormant() -> void:
	velocity = Vector3.ZERO
	if _has_live_target() and global_position.distance_to(target.global_position) <= AGGRO_RADIUS:
		state = BossState.WAKING_UP
		state_time_remaining = WAKE_UP_DURATION
		set_telegraph(ROAR_TELEGRAPH_COLOR, WAKE_UP_DURATION)
		trigger_action_pulse(ROAR_TELEGRAPH_COLOR, 0.4)

func _tick_wake_up(delta: float) -> void:
	velocity = Vector3.ZERO
	state_time_remaining = maxf(0.0, state_time_remaining - delta)
	if state_time_remaining == 0.0:
		clear_telegraph()
		state = BossState.NAVIGATE

func _tick_phase_transition(delta: float) -> void:
	velocity = Vector3.ZERO
	state_time_remaining = maxf(0.0, state_time_remaining - delta)
	if state_time_remaining == 0.0:
		clear_telegraph()
		state = BossState.NAVIGATE

func _tick_navigation() -> void:
	if not _has_live_target():
		velocity = Vector3.ZERO
		return

	var to_target: Vector3 = target.global_position - global_position
	to_target.y = 0.0
	var distance_to_target: float = to_target.length()
	if distance_to_target > 0.1:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z) + TARGET_HEIGHT_OFFSET, Vector3.UP, true)

	if distance_to_target <= ROAR_CAMP_RANGE:
		roar_camp_time += get_physics_process_delta_time()
	else:
		roar_camp_time = 0.0

	var desired_attack: BossAttack = _select_attack(distance_to_target)
	if desired_attack != BossAttack.NONE and _is_attack_available(desired_attack) and _is_attack_in_trigger_range(desired_attack, distance_to_target):
		_start_attack(desired_attack)
		return

	if distance_to_target <= 2.4:
		velocity = -to_target.normalized() * move_speed * 0.55
	else:
		velocity = to_target.normalized() * move_speed

func _tick_windup(delta: float) -> void:
	velocity = Vector3.ZERO
	if _has_live_target():
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z) + TARGET_HEIGHT_OFFSET, Vector3.UP, true)
	state_time_remaining = maxf(0.0, state_time_remaining - delta)
	if state_time_remaining == 0.0:
		_resolve_active_attack()
		state = BossState.RECOVERY
		state_time_remaining = _get_attack_recovery_duration(active_attack)
		clear_telegraph()

func _tick_recovery(delta: float) -> void:
	velocity = Vector3.ZERO
	state_time_remaining = maxf(0.0, state_time_remaining - delta)
	if state_time_remaining == 0.0:
		active_attack = BossAttack.NONE
		state = BossState.NAVIGATE

func _start_attack(next_attack: BossAttack) -> void:
	active_attack = next_attack
	state = BossState.WINDUP
	state_time_remaining = _get_attack_windup(next_attack)
	set_telegraph(_attack_color(next_attack), state_time_remaining)
	trigger_action_pulse(_attack_color(next_attack), 0.26)
	if next_attack == BossAttack.RUGIDO:
		roar_cooldown_remaining = _get_current_roar_cooldown()
		roar_camp_time = 0.0
	if game_context != null:
		game_context.register_action(combatant_id, "enemy_attack", _attack_label(next_attack))

func _resolve_active_attack() -> void:
	match active_attack:
		BossAttack.MARTELADA:
			_resolve_martelada()
		BossAttack.TREMOR:
			_spawn_tremor_zone()
		BossAttack.RUGIDO:
			_resolve_roar()
	attack_cooldown_remaining = _get_attack_post_cooldown(active_attack)

func _resolve_martelada() -> void:
	if not _has_live_target():
		return

	var to_target: Vector3 = target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() > MARTELADA_RANGE:
		return

	var forward: Vector3 = -transform.basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		forward = Vector3.FORWARD
	var angle_to_target: float = rad_to_deg(forward.normalized().angle_to(to_target.normalized()))
	if angle_to_target > MARTELADA_CONE_ANGLE * 0.5:
		return

	target.take_damage(MARTELADA_DAMAGE, combatant_id)
	trigger_action_pulse(MARTELADA_TELEGRAPH_COLOR, 0.22)

func _spawn_tremor_zone() -> void:
	if get_parent() == null:
		return

	if active_tremor_zone != null and is_instance_valid(active_tremor_zone):
		active_tremor_zone.queue_free()

	var tremor_zone := BossTremorZone.new()
	tremor_zone.name = "BossTremorZone"
	get_parent().add_child(tremor_zone)
	tremor_zone.global_position = Vector3(global_position.x, 0.04, global_position.z)
	var radius: float = rng.randf_range(TREMOR_RADIUS_MIN, TREMOR_RADIUS_MAX)
	tremor_zone.configure(
		target,
		combatant_id,
		radius,
		TREMOR_ZONE_DURATION,
		TREMOR_TICK_DAMAGE,
		_get_tremor_crack_count(),
		rng
	)
	active_tremor_zone = tremor_zone
	if not tremor_zone.expired.is_connected(_on_tremor_zone_expired):
		tremor_zone.expired.connect(_on_tremor_zone_expired)
	tremor_zone_spawned.emit(tremor_zone)
	trigger_action_pulse(TREMOR_TELEGRAPH_COLOR, 0.26)

func _resolve_roar() -> void:
	if not _has_live_target():
		return

	var distance_to_target: float = global_position.distance_to(target.global_position)
	if distance_to_target > get_current_roar_radius():
		return

	target.request_motion_pause(ROAR_STUN_DURATION)
	roar_follow_up_pending = true
	roar_follow_up_time_remaining = ROAR_STUN_DURATION
	trigger_action_pulse(ROAR_TELEGRAPH_COLOR, 0.24)

func _resolve_roar_follow_up() -> void:
	roar_follow_up_pending = false
	if not _has_live_target():
		return
	target.take_damage(ROAR_FOLLOW_UP_DAMAGE, combatant_id)

func _apply_regeneration(delta: float) -> void:
	if delta <= 0.0 or get_current_regen() <= 0.0 or health <= 0.0 or state == BossState.PHASE_TRANSITION:
		return
	health = minf(max_health, health + get_current_regen() * delta)

func _update_phase_from_health() -> void:
	if state == BossState.PHASE_TRANSITION or is_dead:
		return

	var hp_ratio: float = health_fraction()
	var next_phase: BossPhase = current_phase
	if hp_ratio <= PHASE_3_THRESHOLD:
		next_phase = BossPhase.PHASE_3
	elif hp_ratio <= PHASE_2_THRESHOLD:
		next_phase = BossPhase.PHASE_2

	if next_phase == current_phase:
		return

	current_phase = next_phase
	_apply_phase_stats()
	active_attack = BossAttack.NONE
	state = BossState.PHASE_TRANSITION
	state_time_remaining = PHASE_TRANSITION_DURATION
	roar_camp_time = 0.0
	roar_follow_up_pending = false
	roar_follow_up_time_remaining = 0.0
	set_telegraph(TRANSITION_TELEGRAPH_COLOR, PHASE_TRANSITION_DURATION)
	trigger_action_pulse(TRANSITION_TELEGRAPH_COLOR, 0.36)
	phase_changed.emit(get_phase_number())

func _apply_phase_stats() -> void:
	match current_phase:
		BossPhase.PHASE_1:
			move_speed = SPEED_PHASE_1
		BossPhase.PHASE_2:
			move_speed = SPEED_PHASE_2
		BossPhase.PHASE_3:
			move_speed = SPEED_PHASE_3

func _select_attack(distance_to_target: float) -> BossAttack:
	if roar_cooldown_remaining <= 0.0 and roar_camp_time >= ROAR_CAMP_DURATION and distance_to_target <= ROAR_CAMP_RANGE:
		return BossAttack.RUGIDO
	if distance_to_target < MARTELADA_TRIGGER_RANGE:
		return BossAttack.MARTELADA
	if distance_to_target >= TREMOR_PREFERRED_MIN_RANGE and distance_to_target <= TREMOR_PREFERRED_MAX_RANGE:
		return BossAttack.TREMOR
	if distance_to_target <= TREMOR_PREFERRED_MAX_RANGE:
		return BossAttack.TREMOR
	return BossAttack.NONE

func _is_attack_in_trigger_range(attack: BossAttack, distance_to_target: float) -> bool:
	match attack:
		BossAttack.MARTELADA:
			return distance_to_target <= MARTELADA_TRIGGER_RANGE
		BossAttack.TREMOR:
			return distance_to_target <= TREMOR_PREFERRED_MAX_RANGE
		BossAttack.RUGIDO:
			return distance_to_target <= get_current_roar_radius()
		_:
			return false

func _is_attack_available(attack: BossAttack) -> bool:
	if attack == BossAttack.RUGIDO:
		return roar_cooldown_remaining <= 0.0
	return attack_cooldown_remaining <= 0.0

func _get_attack_windup(attack: BossAttack) -> float:
	match attack:
		BossAttack.MARTELADA:
			return MARTELADA_WINDUP_PHASE_3 if current_phase == BossPhase.PHASE_3 else MARTELADA_WINDUP_PHASE_1
		BossAttack.TREMOR:
			return TREMOR_WINDUP
		BossAttack.RUGIDO:
			return ROAR_WINDUP
		_:
			return 0.0

func _get_attack_recovery_duration(attack: BossAttack) -> float:
	var cadence: float = _get_cadence_multiplier()
	match attack:
		BossAttack.MARTELADA:
			return (MARTELADA_ACTIVE + MARTELADA_RECOVERY) / cadence
		BossAttack.TREMOR:
			return (TREMOR_ACTIVE + TREMOR_RECOVERY) / cadence
		BossAttack.RUGIDO:
			return (ROAR_ACTIVE + ROAR_RECOVERY) / cadence
		_:
			return 0.0

func _get_attack_post_cooldown(attack: BossAttack) -> float:
	var cadence: float = _get_cadence_multiplier()
	match attack:
		BossAttack.MARTELADA:
			return MARTELADA_POST_COOLDOWN / cadence
		BossAttack.TREMOR:
			return TREMOR_POST_COOLDOWN / cadence
		_:
			return 0.0

func _get_current_roar_cooldown() -> float:
	return ROAR_COOLDOWN_PHASE_3 if current_phase == BossPhase.PHASE_3 else ROAR_COOLDOWN

func _get_cadence_multiplier() -> float:
	match current_phase:
		BossPhase.PHASE_2:
			return CADENCE_PHASE_2
		BossPhase.PHASE_3:
			return CADENCE_PHASE_3
		_:
			return CADENCE_PHASE_1

func _get_tremor_crack_count() -> int:
	return TREMOR_CRACK_COUNT_PHASE_2 if current_phase != BossPhase.PHASE_1 else TREMOR_CRACK_COUNT_PHASE_1

func _is_invulnerable() -> bool:
	return state == BossState.WAKING_UP or state == BossState.PHASE_TRANSITION

func _has_live_target() -> bool:
	return target != null and is_instance_valid(target) and not target.is_dead

func _attack_label(attack: BossAttack) -> String:
	match attack:
		BossAttack.MARTELADA:
			return "Grande Martelada"
		BossAttack.TREMOR:
			return "Tremor Rastejante"
		BossAttack.RUGIDO:
			return "Rugido Atordoante"
		_:
			return "Observando"

func _attack_color(attack: BossAttack) -> Color:
	match attack:
		BossAttack.MARTELADA:
			return MARTELADA_TELEGRAPH_COLOR
		BossAttack.TREMOR:
			return TREMOR_TELEGRAPH_COLOR
		BossAttack.RUGIDO:
			return ROAR_TELEGRAPH_COLOR
		_:
			return Color(0.86, 0.62, 0.44, 1.0)

func _state_label() -> String:
	match state:
		BossState.DORMANT:
			return "dormente"
		BossState.WAKING_UP:
			return "despertando"
		BossState.NAVIGATE:
			return "em caca"
		BossState.WINDUP:
			return "windup"
		BossState.RECOVERY:
			return "recuperacao"
		BossState.PHASE_TRANSITION:
			return "transicao"
		BossState.DEAD:
			return "derrotado"
		_:
			return "desconhecido"

func _apply_boss_visuals() -> void:
	scale = Vector3.ONE * BOSS_SCALE
	var collider: CollisionShape3D = get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collider != null:
		var capsule: CapsuleShape3D = collider.shape as CapsuleShape3D
		if capsule == null:
			capsule = CapsuleShape3D.new()
			collider.shape = capsule
		capsule.height = 1.7
		capsule.radius = 0.58

	var mesh_instance: MeshInstance3D = get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_instance != null:
		var capsule_mesh: CapsuleMesh = mesh_instance.mesh as CapsuleMesh
		if capsule_mesh == null:
			capsule_mesh = CapsuleMesh.new()
			mesh_instance.mesh = capsule_mesh
		capsule_mesh.height = 1.7
		capsule_mesh.radius = 0.58
		mesh_instance.position = Vector3(0.0, 0.85, 0.0)

	var shadow: MeshInstance3D = get_node_or_null("GroundShadow") as MeshInstance3D
	if shadow != null:
		var cylinder: CylinderMesh = shadow.mesh as CylinderMesh
		if cylinder != null:
			cylinder.top_radius = 0.84
			cylinder.bottom_radius = 1.02
		shadow.position = Vector3(0.0, 0.015, 0.0)

	var ring: MeshInstance3D = get_node_or_null("SelectionRing") as MeshInstance3D
	if ring != null:
		var ring_mesh: CylinderMesh = ring.mesh as CylinderMesh
		if ring_mesh != null:
			ring_mesh.top_radius = 1.08
			ring_mesh.bottom_radius = 1.18
			ring_mesh.height = 0.09

func _on_tremor_zone_expired() -> void:
	active_tremor_zone = null
