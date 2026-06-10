class_name RuntimePrimitiveFactory
extends RefCounted

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
	physics_bounce: float = 0.0
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
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = build_material(color, emission_energy, roughness)
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
	roughness: float = 0.84
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = box_position
	mesh_instance.rotation_degrees = box_rotation_degrees
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = build_material(color, emission_energy, roughness)
	parent.add_child(mesh_instance)
	return mesh_instance

static func build_material(
	color: Color,
	emission_energy: float = 0.05,
	roughness: float = 0.84,
	unshaded: bool = false
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if color.a < 0.99:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	return material

static func build_physics_material(friction: float = 0.82, bounce: float = 0.0) -> PhysicsMaterial:
	var material := PhysicsMaterial.new()
	material.friction = clampf(friction, 0.0, 1.0)
	material.bounce = clampf(bounce, 0.0, 1.0)
	return material
