class_name FpsCombatant3D
extends CharacterBody3D

signal damaged(amount: float, remaining_health: float)
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
var knockback_decay: float = 18.0

func _ready() -> void:
	_ensure_body_nodes()
	_update_visual_state()

func configure_combatant(next_id: StringName, next_max_health: float, next_color: Color) -> void:
	combatant_id = next_id
	max_health = maxf(1.0, next_max_health)
	health = max_health
	body_color = next_color
	is_dead = false
	knockback_velocity = Vector3.ZERO
	_update_visual_state()

func take_damage(amount: float, _source_id: StringName = &"") -> void:
	if is_dead:
		return
	var applied := maxf(0.0, amount)
	if applied <= 0.0:
		return
	health = maxf(0.0, health - applied)
	damaged.emit(applied, health)
	_update_visual_state()
	if health <= 0.0:
		is_dead = true
		died.emit()

func apply_knockback(direction: Vector3, force: float) -> void:
	if is_dead or force <= 0.0:
		return
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.0001:
		flat = -global_transform.basis.z
	var impulse := (flat.normalized() + Vector3.UP * 0.18).normalized() * force
	knockback_velocity += impulse

func consume_knockback(delta: float) -> Vector3:
	var current := knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)
	return current

func health_fraction() -> float:
	return health / maxf(1.0, max_health)

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
		add_child(mesh_instance)

func _update_visual_state() -> void:
	var mesh_instance := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_instance == null:
		return
	var color := body_color
	if is_dead:
		color = Color(0.18, 0.2, 0.24, 1.0)
	elif health_fraction() < 0.35:
		color = body_color.lerp(Color(1.0, 0.22, 0.16, 1.0), 0.55)
	mesh_instance.material_override = _build_material(color)

func _build_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.18
	return material
