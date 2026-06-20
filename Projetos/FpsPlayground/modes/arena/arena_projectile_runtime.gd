class_name ArenaProjectileRuntime
extends RefCounted


static func build_player_plasma_bolt(
	root: Node3D,
	origin: Vector3,
	direction: Vector3,
	damage: float,
	knockback: float,
	speed: float,
	radius: float,
	overcharged: bool,
	ttl: float,
	projectile_id: String,
	material: Material
) -> Dictionary:
	if root == null:
		return {}

	var bolt := Node3D.new()
	bolt.name = "PlayerPlasmaBolt"
	root.add_child(bolt)
	bolt.global_position = origin

	var visual_radius := get_visual_radius(radius, overcharged)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PlasmaBoltMesh"
	var mesh := SphereMesh.new()
	mesh.radius = visual_radius
	mesh.height = visual_radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	bolt.add_child(mesh_instance)

	var light := OmniLight3D.new()
	light.name = "PlasmaBoltLight"
	light.light_color = Color(0.78, 0.46, 1.0, 1.0) if overcharged else Color(0.38, 0.98, 1.0, 1.0)
	light.light_energy = 2.5 if overcharged else 1.8
	light.omni_range = 2.8
	bolt.add_child(light)

	return {
		"node": bolt,
		"velocity": direction.normalized() * maxf(1.0, speed),
		"damage": damage,
		"knockback": knockback,
		"radius": visual_radius,
		"ttl": ttl,
		"source": &"player",
		"overcharged": overcharged,
		"projectile_id": projectile_id
	}


static func get_visual_radius(radius: float, overcharged: bool) -> float:
	return radius * (1.12 if overcharged else 1.0)


static func build_projectile_step(entry: Dictionary, delta: float) -> Dictionary:
	var bolt := entry.get("node", null) as Node3D
	if bolt == null or not is_instance_valid(bolt):
		return {"valid": false}

	var ttl := float(entry.get("ttl", 0.0)) - delta
	var velocity: Vector3 = entry.get("velocity", Vector3.ZERO)
	var start_position := bolt.global_position
	var end_position := start_position + velocity * delta
	return {
		"valid": true,
		"node": bolt,
		"ttl": ttl,
		"velocity": velocity,
		"start_position": start_position,
		"end_position": end_position,
		"radius": float(entry.get("radius", 0.0))
	}


static func free_projectile(entry: Dictionary) -> void:
	var bolt := entry.get("node", null) as Node3D
	if bolt != null and is_instance_valid(bolt):
		bolt.queue_free()


static func clear_projectiles(projectiles: Array[Dictionary]) -> void:
	for entry: Dictionary in projectiles:
		free_projectile(entry)
