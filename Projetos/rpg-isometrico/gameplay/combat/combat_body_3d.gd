class_name CombatBody3D
extends CharacterBody3D

const GameContext = preload("res://gameplay/simulation/game_context.gd")

signal damaged(amount: float, remaining_health: float)
signal died()
signal impact_registered(health_damage: float, absorbed_amount: float, is_lethal: bool)

var combatant_id: StringName = &"combatant"
var game_context
var max_health: float = 100.0
var health: float = 100.0
var barrier_amount: float = 0.0
var barrier_time_remaining: float = 0.0
var move_speed: float = 5.0
var is_dead: bool = false
var body_color: Color = Color(0.85, 0.85, 0.9, 1.0)
var damage_flash_remaining: float = 0.0
var action_pulse_remaining: float = 0.0
var action_pulse_duration: float = 0.0
var action_pulse_color: Color = Color(1.0, 0.92, 0.76, 1.0)
var impact_pulse_remaining: float = 0.0
var impact_pulse_duration: float = 0.0
var impact_pulse_color: Color = Color(1.0, 0.8, 0.58, 1.0)
var impact_pulse_strength: float = 0.0
var motion_pause_remaining: float = 0.0
var telegraph_remaining: float = 0.0
var telegraph_duration: float = 0.0
var telegraph_color: Color = Color(1.0, 0.42, 0.22, 1.0)

const DAMAGE_FLASH_DURATION: float = 0.16

func _ready() -> void:
	_ensure_visual_nodes()
	_update_visual_state()

func _process(delta: float) -> void:
	if barrier_time_remaining > 0.0:
		barrier_time_remaining = maxf(0.0, barrier_time_remaining - delta)
		if barrier_time_remaining == 0.0:
			barrier_amount = 0.0

	if damage_flash_remaining > 0.0:
		damage_flash_remaining = maxf(0.0, damage_flash_remaining - delta)

	if action_pulse_remaining > 0.0:
		action_pulse_remaining = maxf(0.0, action_pulse_remaining - delta)

	if impact_pulse_remaining > 0.0:
		impact_pulse_remaining = maxf(0.0, impact_pulse_remaining - delta)

	if motion_pause_remaining > 0.0:
		motion_pause_remaining = maxf(0.0, motion_pause_remaining - delta)

	if telegraph_remaining > 0.0:
		telegraph_remaining = maxf(0.0, telegraph_remaining - delta)

	_update_visual_state()

func configure_base(context, next_max_health: float, next_move_speed: float) -> void:
	game_context = context
	max_health = next_max_health
	health = next_max_health
	move_speed = next_move_speed
	barrier_amount = 0.0
	barrier_time_remaining = 0.0
	is_dead = false
	damage_flash_remaining = 0.0
	action_pulse_remaining = 0.0
	action_pulse_duration = 0.0
	impact_pulse_remaining = 0.0
	impact_pulse_duration = 0.0
	impact_pulse_strength = 0.0
	motion_pause_remaining = 0.0
	telegraph_remaining = 0.0
	telegraph_duration = 0.0

func heal(amount: float) -> void:
	if is_dead:
		return
	var previous_health: float = health
	health = minf(max_health, health + amount)
	var recovered_amount: float = health - previous_health
	if recovered_amount > 0.0:
		trigger_action_pulse(Color(0.44, 0.96, 0.62, 1.0), 0.22)
		if game_context != null:
			game_context.register_heal(combatant_id, recovered_amount, health)

func apply_barrier(amount: float, duration: float) -> void:
	if is_dead:
		return
	var previous_barrier: float = barrier_amount
	barrier_amount = maxf(barrier_amount, amount)
	barrier_time_remaining = maxf(barrier_time_remaining, duration)
	var granted_amount: float = maxf(0.0, barrier_amount - previous_barrier)
	trigger_action_pulse(Color(0.58, 0.92, 1.0, 1.0), 0.2)
	if game_context != null:
		game_context.register_barrier(combatant_id, granted_amount, barrier_time_remaining)

func take_damage(amount: float, source_id: StringName = &"") -> void:
	if is_dead:
		return

	var remaining: float = amount
	var absorbed_amount: float = 0.0
	if barrier_amount > 0.0:
		absorbed_amount = minf(barrier_amount, remaining)
		barrier_amount -= absorbed_amount
		remaining -= absorbed_amount

	if remaining > 0.0:
		health = maxf(0.0, health - remaining)
		damage_flash_remaining = DAMAGE_FLASH_DURATION
		var impact_strength: float = clampf(0.38 + remaining / maxf(24.0, max_health * 0.28), 0.38, 1.0)
		var lethal: bool = health <= 0.0
		trigger_impact_pulse(Color(1.0, 0.82, 0.62, 1.0), 0.16 if not lethal else 0.24, impact_strength)
		impact_registered.emit(remaining, absorbed_amount, lethal)
	else:
		trigger_action_pulse(Color(0.58, 0.92, 1.0, 1.0), 0.18)
		if absorbed_amount > 0.0:
			trigger_impact_pulse(Color(0.66, 0.94, 1.0, 1.0), 0.12, clampf(0.28 + absorbed_amount / 36.0, 0.28, 0.62))
			impact_registered.emit(0.0, absorbed_amount, false)

	damaged.emit(remaining, health)
	if game_context != null:
		game_context.register_damage(source_id, combatant_id, amount, remaining, absorbed_amount, health)

	if health <= 0.0:
		is_dead = true
		died.emit()
		if game_context != null:
			game_context.emit_death(combatant_id)

func health_fraction() -> float:
	if max_health <= 0.0:
		return 0.0
	return health / max_health

func get_barrier_amount() -> float:
	return barrier_amount

func get_barrier_time_remaining() -> float:
	return barrier_time_remaining

func trigger_action_pulse(color: Color, duration: float = 0.18) -> void:
	action_pulse_color = color
	action_pulse_duration = maxf(0.01, duration)
	action_pulse_remaining = action_pulse_duration

func trigger_impact_pulse(color: Color, duration: float, strength: float) -> void:
	impact_pulse_color = color
	impact_pulse_duration = maxf(0.01, duration)
	impact_pulse_remaining = impact_pulse_duration
	impact_pulse_strength = clampf(strength, 0.0, 1.0)

func request_motion_pause(duration: float) -> void:
	motion_pause_remaining = maxf(motion_pause_remaining, maxf(0.0, duration))

func clear_motion_pause() -> void:
	motion_pause_remaining = 0.0

func is_motion_paused() -> bool:
	return motion_pause_remaining > 0.0

func set_telegraph(color: Color, duration: float) -> void:
	telegraph_color = color
	telegraph_duration = maxf(0.01, duration)
	telegraph_remaining = telegraph_duration

func clear_telegraph() -> void:
	telegraph_remaining = 0.0
	telegraph_duration = 0.0

func build_combat_snapshot() -> Dictionary:
	return {
		"position": _serialize_variant(global_position),
		"rotation": _serialize_variant(rotation),
		"velocity": _serialize_variant(velocity),
		"max_health": max_health,
		"health": health,
		"barrier_amount": barrier_amount,
		"barrier_time_remaining": barrier_time_remaining,
		"move_speed": move_speed,
		"is_dead": is_dead,
		"motion_pause_remaining": motion_pause_remaining,
		"telegraph_remaining": telegraph_remaining,
		"telegraph_duration": telegraph_duration,
		"telegraph_color": _serialize_variant(telegraph_color)
	}

func restore_combat_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	global_position = _deserialize_variant(snapshot.get("position", ""), global_position)
	rotation = _deserialize_variant(snapshot.get("rotation", ""), rotation)
	velocity = _deserialize_variant(snapshot.get("velocity", ""), Vector3.ZERO)
	max_health = maxf(1.0, float(snapshot.get("max_health", max_health)))
	health = clampf(float(snapshot.get("health", health)), 0.0, max_health)
	barrier_amount = maxf(0.0, float(snapshot.get("barrier_amount", barrier_amount)))
	barrier_time_remaining = maxf(0.0, float(snapshot.get("barrier_time_remaining", barrier_time_remaining)))
	move_speed = maxf(0.0, float(snapshot.get("move_speed", move_speed)))
	is_dead = bool(snapshot.get("is_dead", false)) and health <= 0.0
	motion_pause_remaining = maxf(0.0, float(snapshot.get("motion_pause_remaining", 0.0)))
	telegraph_remaining = maxf(0.0, float(snapshot.get("telegraph_remaining", 0.0)))
	telegraph_duration = maxf(0.0, float(snapshot.get("telegraph_duration", 0.0)))
	telegraph_color = _deserialize_variant(snapshot.get("telegraph_color", ""), telegraph_color)
	damage_flash_remaining = 0.0
	action_pulse_remaining = 0.0
	action_pulse_duration = 0.0
	impact_pulse_remaining = 0.0
	impact_pulse_duration = 0.0
	impact_pulse_strength = 0.0
	_update_visual_state()

func _ensure_visual_nodes() -> void:
	if get_node_or_null("CollisionShape3D") == null:
		var collider: CollisionShape3D = CollisionShape3D.new()
		collider.name = "CollisionShape3D"
		var capsule: CapsuleShape3D = CapsuleShape3D.new()
		capsule.height = 1.2
		capsule.radius = 0.45
		collider.shape = capsule
		add_child(collider)

	if get_node_or_null("MeshInstance3D") == null:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		var mesh: CapsuleMesh = CapsuleMesh.new()
		mesh.height = 1.2
		mesh.radius = 0.45
		mesh_instance.mesh = mesh
		mesh_instance.position = Vector3(0.0, 0.6, 0.0)
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = body_color
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		material.emission = body_color
		material.emission_energy_multiplier = 0.55
		mesh_instance.material_override = material
		add_child(mesh_instance)

	if get_node_or_null("GroundShadow") == null:
		var shadow_mesh: MeshInstance3D = MeshInstance3D.new()
		shadow_mesh.name = "GroundShadow"
		var shadow: CylinderMesh = CylinderMesh.new()
		shadow.top_radius = 0.62
		shadow.bottom_radius = 0.76
		shadow.height = 0.02
		shadow_mesh.mesh = shadow
		shadow_mesh.position = Vector3(0.0, 0.01, 0.0)
		var shadow_material: StandardMaterial3D = StandardMaterial3D.new()
		shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		shadow_material.albedo_color = Color(0.0, 0.0, 0.0, 0.28)
		shadow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		shadow_mesh.material_override = shadow_material
		add_child(shadow_mesh)

	if get_node_or_null("SelectionRing") == null:
		var ring_mesh: MeshInstance3D = MeshInstance3D.new()
		ring_mesh.name = "SelectionRing"
		var ring: CylinderMesh = CylinderMesh.new()
		ring.top_radius = 0.85
		ring.bottom_radius = 0.95
		ring.height = 0.08
		ring_mesh.mesh = ring
		ring_mesh.position = Vector3(0.0, 0.04, 0.0)
		var ring_material: StandardMaterial3D = StandardMaterial3D.new()
		ring_material.albedo_color = body_color
		ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring_material.emission_enabled = true
		ring_material.emission = body_color
		ring_material.emission_energy_multiplier = 0.35
		ring_mesh.material_override = ring_material
		add_child(ring_mesh)

	if get_node_or_null("ImpactHalo") == null:
		var halo_mesh: MeshInstance3D = MeshInstance3D.new()
		halo_mesh.name = "ImpactHalo"
		var halo: CylinderMesh = CylinderMesh.new()
		halo.top_radius = 0.68
		halo.bottom_radius = 0.82
		halo.height = 0.03
		halo_mesh.mesh = halo
		halo_mesh.position = Vector3(0.0, 0.02, 0.0)
		var halo_material: StandardMaterial3D = StandardMaterial3D.new()
		halo_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		halo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		halo_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		halo_material.albedo_color = Color(1.0, 0.82, 0.62, 0.0)
		halo_material.emission_enabled = true
		halo_material.emission = Color(1.0, 0.82, 0.62, 0.0)
		halo_material.emission_energy_multiplier = 0.0
		halo_mesh.material_override = halo_material
		add_child(halo_mesh)

func _update_visual_state() -> void:
	var flash_alpha: float = 0.0
	if DAMAGE_FLASH_DURATION > 0.0:
		flash_alpha = damage_flash_remaining / DAMAGE_FLASH_DURATION
	var action_alpha: float = 0.0
	if action_pulse_duration > 0.0:
		action_alpha = action_pulse_remaining / action_pulse_duration
	var impact_alpha: float = 0.0
	if impact_pulse_duration > 0.0:
		impact_alpha = impact_pulse_remaining / impact_pulse_duration
	var telegraph_alpha: float = 0.0
	if telegraph_duration > 0.0:
		telegraph_alpha = telegraph_remaining / telegraph_duration

	var mesh_instance: MeshInstance3D = get_node_or_null("MeshInstance3D")
	if mesh_instance != null:
		var mesh_material: StandardMaterial3D = mesh_instance.material_override
		if mesh_material != null:
			var mesh_color: Color = body_color
			if is_dead:
				mesh_color = mesh_color.darkened(0.58)
			elif flash_alpha > 0.0:
				mesh_color = body_color.lerp(Color(1.0, 0.96, 0.9, 1.0), 0.62 + impact_alpha * 0.22)
			elif action_alpha > 0.0:
				mesh_color = body_color.lerp(action_pulse_color, 0.48 * action_alpha)

			if impact_alpha > 0.0:
				mesh_color = mesh_color.lerp(impact_pulse_color, 0.32 * impact_alpha)
			mesh_material.albedo_color = mesh_color
			mesh_material.emission = mesh_color.lerp(impact_pulse_color, impact_alpha * 0.38).lerp(action_pulse_color, action_alpha * 0.28)
			mesh_material.emission_energy_multiplier = 0.42 + flash_alpha * 0.9 + action_alpha * 0.35 + impact_alpha * 0.65 + telegraph_alpha * 0.25

		mesh_instance.scale = Vector3.ONE * (1.0 + flash_alpha * 0.08 + action_alpha * 0.04 + impact_alpha * 0.1 * impact_pulse_strength)

	var ring_instance: MeshInstance3D = get_node_or_null("SelectionRing")
	if ring_instance != null:
		var ring_material: StandardMaterial3D = ring_instance.material_override
		if ring_material != null:
			var ring_color: Color = body_color
			if barrier_amount > 0.0:
				ring_color = ring_color.lerp(Color(0.66, 0.94, 1.0, 1.0), 0.55)
			if telegraph_alpha > 0.0:
				ring_color = ring_color.lerp(telegraph_color, 0.72 * telegraph_alpha)
			if action_alpha > 0.0:
				ring_color = ring_color.lerp(action_pulse_color, 0.48 * action_alpha)
			if impact_alpha > 0.0:
				ring_color = ring_color.lerp(impact_pulse_color, 0.54 * impact_alpha)
			if is_dead:
				ring_color = ring_color.darkened(0.5)

			ring_material.albedo_color = ring_color
			ring_material.emission = ring_color
			ring_material.emission_energy_multiplier = 0.28 + flash_alpha * 0.55 + action_alpha * 0.4 + impact_alpha * 0.68 + telegraph_alpha * 0.75 + (0.18 if barrier_amount > 0.0 else 0.0)
		ring_instance.scale = Vector3.ONE * (1.0 + telegraph_alpha * 0.3 + action_alpha * 0.12 + impact_alpha * 0.18 * impact_pulse_strength)

	var shadow_instance: MeshInstance3D = get_node_or_null("GroundShadow")
	if shadow_instance != null:
		var shadow_material: StandardMaterial3D = shadow_instance.material_override
		if shadow_material != null:
			var shadow_alpha: float = 0.28
			if is_dead:
				shadow_alpha = 0.14
			shadow_material.albedo_color = Color(0.0, 0.0, 0.0, shadow_alpha)

	var impact_halo: MeshInstance3D = get_node_or_null("ImpactHalo")
	if impact_halo != null:
		var halo_material: StandardMaterial3D = impact_halo.material_override
		if halo_material != null:
			var halo_alpha: float = 0.22 * impact_alpha * impact_pulse_strength
			var halo_color: Color = Color(impact_pulse_color.r, impact_pulse_color.g, impact_pulse_color.b, halo_alpha)
			halo_material.albedo_color = halo_color
			halo_material.emission = halo_color
			halo_material.emission_energy_multiplier = impact_alpha * (0.32 + impact_pulse_strength * 0.58)
		var expansion: float = (1.0 - impact_alpha) * (0.42 + impact_pulse_strength * 0.36)
		impact_halo.scale = Vector3.ONE * (1.0 + expansion)

func _serialize_variant(value: Variant) -> String:
	return var_to_str(value)

func _deserialize_variant(value: Variant, fallback: Variant) -> Variant:
	if value is String and str(value) != "":
		var parsed: Variant = str_to_var(str(value))
		if parsed != null:
			return parsed
	return fallback
