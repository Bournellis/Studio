class_name RuntimePrimitiveFactory
extends RefCounted

const RenderProfileScript = preload("res://autoloads/render_profile.gd")

static var _standard_material_cache: Dictionary = {}
static var _glass_material_cache: Dictionary = {}
static var _box_mesh_cache: Dictionary = {}

static func add_static_box(
	parent: Node,
	node_name: String,
	box_position: Vector3,
	box_size: Vector3,
	color: Color,
	box_rotation_degrees: Vector3 = Vector3.ZERO,
	emission_energy: float = 0.05,
	roughness: float = 0.84,
	mesh_name: String = "MeshInstance3D",
	collision_name: String = "CollisionShape3D",
	physics_friction: float = 0.82,
	physics_bounce: float = 0.0,
	metallic: float = 0.0,
	rim_strength: float = 0.0,
	clearcoat_strength: float = 0.0,
	render_profile_role: StringName = &"default"
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = box_position
	body.rotation_degrees = box_rotation_degrees
	body.physics_material_override = build_physics_material(physics_friction, physics_bounce)
	parent.add_child(body)

	var collider := CollisionShape3D.new()
	collider.name = collision_name
	var shape := BoxShape3D.new()
	shape.size = box_size
	collider.shape = shape
	body.add_child(collider)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = mesh_name
	mesh_instance.mesh = _get_box_mesh(box_size)
	mesh_instance.material_override = build_material(color, emission_energy, roughness, false, metallic, rim_strength, clearcoat_strength, render_profile_role)
	body.add_child(mesh_instance)
	return body

static func add_visual_box(
	parent: Node,
	node_name: String,
	box_position: Vector3,
	box_size: Vector3,
	color: Color,
	box_rotation_degrees: Vector3 = Vector3.ZERO,
	emission_energy: float = 0.18,
	roughness: float = 0.84,
	metallic: float = 0.0,
	rim_strength: float = 0.0,
	clearcoat_strength: float = 0.0,
	render_profile_role: StringName = &"default"
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = box_position
	mesh_instance.rotation_degrees = box_rotation_degrees
	mesh_instance.mesh = _get_box_mesh(box_size)
	mesh_instance.material_override = build_material(color, emission_energy, roughness, false, metallic, rim_strength, clearcoat_strength, render_profile_role)
	parent.add_child(mesh_instance)
	return mesh_instance

static func _get_box_mesh(box_size: Vector3) -> BoxMesh:
	var cache_key := _vector3_key(box_size)
	if _box_mesh_cache.has(cache_key):
		return _box_mesh_cache[cache_key]
	var mesh := BoxMesh.new()
	mesh.size = box_size
	_box_mesh_cache[cache_key] = mesh
	return mesh

static func build_material(
	color: Color,
	emission_energy: float = 0.05,
	roughness: float = 0.84,
	unshaded: bool = false,
	metallic: float = 0.0,
	rim_strength: float = 0.0,
	clearcoat_strength: float = 0.0,
	render_profile_role: StringName = &"default"
) -> StandardMaterial3D:
	var cache_key := _build_material_cache_key(color, emission_energy, roughness, unshaded, metallic, rim_strength, clearcoat_strength, render_profile_role)
	if _standard_material_cache.has(cache_key):
		return _standard_material_cache[cache_key]
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = clampf(metallic, 0.0, 1.0)
	material.metallic_specular = 0.55
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = RenderProfileScript.adjust_emission_energy(emission_energy, render_profile_role)
	if rim_strength > 0.0:
		material.rim_enabled = true
		material.rim = clampf(rim_strength, 0.0, 1.0)
		material.rim_tint = 0.62
	if clearcoat_strength > 0.0:
		material.clearcoat_enabled = true
		material.clearcoat = clampf(clearcoat_strength, 0.0, 1.0)
		material.clearcoat_roughness = 0.18
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if color.a < 0.99:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	_standard_material_cache[cache_key] = material
	return material

static func build_glass_material(
	color: Color,
	emission_energy: float = 0.72,
	roughness: float = 0.1
) -> StandardMaterial3D:
	var cache_key := _build_material_cache_key(color, emission_energy, roughness, false, 0.0, 0.7, 0.82, RenderProfileScript.ROLE_GLASS) + "|glass"
	if _glass_material_cache.has(cache_key):
		return _glass_material_cache[cache_key]
	var material := build_material(color, emission_energy, roughness, false, 0.0, 0.7, 0.82, RenderProfileScript.ROLE_GLASS).duplicate(true) as StandardMaterial3D
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_glass_material_cache[cache_key] = material
	return material

static func build_physics_material(friction: float = 0.82, bounce: float = 0.0) -> PhysicsMaterial:
	var material := PhysicsMaterial.new()
	material.friction = clampf(friction, 0.0, 1.0)
	material.bounce = clampf(bounce, 0.0, 1.0)
	return material

static func _build_material_cache_key(
	color: Color,
	emission_energy: float,
	roughness: float,
	unshaded: bool,
	metallic: float,
	rim_strength: float,
	clearcoat_strength: float,
	render_profile_role: StringName
) -> String:
	return "%s|e=%.4f|r=%.4f|u=%s|m=%.4f|rim=%.4f|coat=%.4f|profile=%s|role=%s" % [
		_color_key(color),
		emission_energy,
		roughness,
		str(unshaded),
		metallic,
		rim_strength,
		clearcoat_strength,
		str(RenderProfileScript.get_active_profile_id()),
		str(render_profile_role),
	]

static func _color_key(color: Color) -> String:
	return "%.4f,%.4f,%.4f,%.4f" % [color.r, color.g, color.b, color.a]

static func _vector3_key(value: Vector3) -> String:
	return "%.4f,%.4f,%.4f" % [value.x, value.y, value.z]
