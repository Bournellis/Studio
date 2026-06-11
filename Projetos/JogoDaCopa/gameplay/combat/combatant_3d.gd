class_name FpsCombatant3D
extends CharacterBody3D

const RenderProfileScript = preload("res://autoloads/render_profile.gd")

signal damaged(amount: float, remaining_health: float)
signal healed(amount: float, current_health: float)
signal died()

const BODY_HEIGHT: float = 1.65
const BODY_RADIUS: float = 0.38
const BODY_CENTER_Y: float = BODY_HEIGHT * 0.5

var combatant_id: StringName = &"combatant"
var max_health: float = 100.0
var health: float = 100.0
var body_color: Color = Color(0.8, 0.86, 0.95, 1.0)
var is_dead: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay: float = 12.5
var knockback_air_decay_multiplier: float = 0.62
var knockback_lift_ratio: float = 0.22
var knockback_min_lift: float = 1.05
var knockback_max_lift: float = 2.8
var knockback_max_horizontal_speed: float = 12.0
var knockback_max_vertical_speed: float = 4.4
var last_knockback_impulse: Vector3 = Vector3.ZERO
var knockback_event_count: int = 0
var damage_flash_time: float = 0.0
var damage_flash_duration: float = 0.14
var visual_body_visible: bool = true

func _ready() -> void:
	_ensure_body_nodes()
	_update_visual_state()

func _process(delta: float) -> void:
	if damage_flash_time <= 0.0:
		return
	damage_flash_time = maxf(0.0, damage_flash_time - delta)
	_update_visual_state()

func configure_combatant(next_id: StringName, next_max_health: float, next_color: Color) -> void:
	combatant_id = next_id
	max_health = maxf(1.0, next_max_health)
	health = max_health
	body_color = next_color
	is_dead = false
	knockback_velocity = Vector3.ZERO
	last_knockback_impulse = Vector3.ZERO
	knockback_event_count = 0
	damage_flash_time = 0.0
	_update_visual_state()

func take_damage(amount: float, _source_id: StringName = &"") -> void:
	if is_dead:
		return
	var applied := maxf(0.0, amount)
	if applied <= 0.0:
		return
	health = maxf(0.0, health - applied)
	damaged.emit(applied, health)
	damage_flash_time = damage_flash_duration
	_update_visual_state()
	if health <= 0.0:
		is_dead = true
		damage_flash_time = 0.0
		_update_visual_state()
		died.emit()

func heal(amount: float) -> float:
	if is_dead:
		return 0.0
	var applied := minf(maxf(0.0, amount), maxf(0.0, max_health - health))
	if applied <= 0.0:
		return 0.0
	health += applied
	healed.emit(applied, health)
	_update_visual_state()
	return applied

func apply_knockback(direction: Vector3, force: float, lift_force: float = -1.0) -> void:
	if is_dead or force <= 0.0:
		return
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.0001:
		flat = -global_transform.basis.z
	var normalized_direction := direction.normalized() if direction.length_squared() > 0.0001 else flat.normalized()
	var lift := lift_force
	if lift < 0.0:
		var vertical_bias := normalized_direction.y * force * 0.24
		lift = clampf(force * knockback_lift_ratio + vertical_bias, knockback_min_lift, knockback_max_lift)
	var impulse := flat.normalized() * force + Vector3.UP * lift
	last_knockback_impulse = impulse
	knockback_event_count += 1
	knockback_velocity += impulse
	knockback_velocity = _clamp_knockback_velocity(knockback_velocity)

func consume_knockback(delta: float, grounded: bool = false) -> Vector3:
	var current := knockback_velocity
	var decay_multiplier := 1.0 if grounded else knockback_air_decay_multiplier
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * decay_multiplier * delta)
	return current

func health_fraction() -> float:
	return health / maxf(1.0, max_health)

func get_body_center() -> Vector3:
	return global_position + Vector3.UP * BODY_CENTER_Y

func debug_get_last_knockback_impulse() -> Vector3:
	return last_knockback_impulse

func debug_get_knockback_event_count() -> int:
	return knockback_event_count

func debug_get_knockback_horizontal_speed() -> float:
	return Vector3(knockback_velocity.x, 0.0, knockback_velocity.z).length()

func set_combatant_body_visible(is_visible: bool) -> void:
	visual_body_visible = is_visible
	var mesh_instance := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_instance != null:
		mesh_instance.visible = visual_body_visible

func debug_is_combatant_body_visible() -> bool:
	var mesh_instance := get_node_or_null("MeshInstance3D") as MeshInstance3D
	return mesh_instance != null and mesh_instance.visible

func _clamp_knockback_velocity(next_velocity: Vector3) -> Vector3:
	var flat := Vector3(next_velocity.x, 0.0, next_velocity.z)
	if flat.length() > knockback_max_horizontal_speed:
		flat = flat.normalized() * knockback_max_horizontal_speed
	return Vector3(
		flat.x,
		clampf(next_velocity.y, -knockback_max_vertical_speed, knockback_max_vertical_speed),
		flat.z
	)

func _ensure_body_nodes() -> void:
	if get_node_or_null("CollisionShape3D") == null:
		var collider := CollisionShape3D.new()
		collider.name = "CollisionShape3D"
		collider.position = Vector3(0.0, BODY_CENTER_Y, 0.0)
		var capsule := CapsuleShape3D.new()
		capsule.height = BODY_HEIGHT
		capsule.radius = BODY_RADIUS
		collider.shape = capsule
		add_child(collider)

	if get_node_or_null("MeshInstance3D") == null:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		var mesh := CapsuleMesh.new()
		mesh.height = BODY_HEIGHT
		mesh.radius = BODY_RADIUS
		mesh_instance.mesh = mesh
		mesh_instance.position = Vector3(0.0, BODY_CENTER_Y, 0.0)
		mesh_instance.material_override = _build_material(body_color)
		mesh_instance.visible = visual_body_visible
		add_child(mesh_instance)

func _update_visual_state() -> void:
	var mesh_instance := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_instance == null:
		return
	var color := body_color
	if is_dead:
		color = Color(0.18, 0.2, 0.24, 1.0)
	elif damage_flash_time > 0.0:
		var flash_weight := clampf(damage_flash_time / maxf(0.01, damage_flash_duration), 0.0, 1.0)
		color = body_color.lerp(Color(1.0, 0.96, 0.72, 1.0), flash_weight)
	elif health_fraction() < 0.35:
		color = body_color.lerp(Color(1.0, 0.22, 0.16, 1.0), 0.55)
	mesh_instance.material_override = _build_material(color)
	mesh_instance.visible = visual_body_visible

func _build_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = RenderProfileScript.adjust_emission_energy(0.18, RenderProfileScript.ROLE_CHARACTER)
	return material
