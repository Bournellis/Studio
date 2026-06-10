class_name PlayerAvatar3D
extends Node3D

const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")

@export var local_first_person: bool = false

var appearance = AvatarCatalogScript.get_default_appearance()
var part_root: Node3D
var part_meshes: Dictionary = {}
var part_pivots: Dictionary = {}
var animation_state: StringName = &"idle"
var animation_timer: float = 0.0
var stride_time: float = 0.0
var last_move_speed: float = 0.0
var last_grounded: bool = true
var last_vertical_velocity: float = 0.0
var boost_trail_particles: GPUParticles3D
var skid_dust_particles: GPUParticles3D

func _ready() -> void:
	_build_avatar()
	apply_appearance(appearance)

func _process(delta: float) -> void:
	stride_time += delta * (2.4 + minf(last_move_speed, 9.0) * 0.24)
	if animation_timer > 0.0:
		animation_timer = maxf(0.0, animation_timer - delta)
		if animation_timer <= 0.0:
			_update_state_from_motion()
	_apply_animation()

func apply_appearance(next_appearance) -> void:
	if next_appearance == null:
		appearance = AvatarCatalogScript.get_default_appearance()
	else:
		appearance = next_appearance.duplicate_appearance()
	if part_root == null:
		return
	var skin_color: Color = AvatarCatalogScript.get_skin_color(appearance.skin_tone_id)
	var shirt_primary: Color = AvatarCatalogScript.get_kit_primary_color(appearance.country_kit_id)
	var shirt_secondary: Color = AvatarCatalogScript.get_kit_secondary_color(appearance.country_kit_id)
	var shorts_color: Color = AvatarCatalogScript.get_kit_shorts_color(appearance.country_kit_id)
	var socks_color: Color = AvatarCatalogScript.get_kit_socks_color(appearance.country_kit_id)
	_set_part_material(&"head", skin_color, 0.06)
	_set_part_material(&"neck", skin_color, 0.06)
	_set_part_material(&"left_hand", skin_color, 0.06)
	_set_part_material(&"right_hand", skin_color, 0.06)
	_set_part_material(&"torso", shirt_primary, 0.11)
	_set_part_material(&"chest_stripe", shirt_secondary, 0.18)
	_set_part_material(&"left_upper_arm", shirt_primary, 0.10)
	_set_part_material(&"right_upper_arm", shirt_primary, 0.10)
	_set_part_material(&"left_lower_arm", skin_color, 0.06)
	_set_part_material(&"right_lower_arm", skin_color, 0.06)
	_set_part_material(&"shorts", shorts_color, 0.10)
	_set_part_material(&"left_upper_leg", shorts_color, 0.08)
	_set_part_material(&"right_upper_leg", shorts_color, 0.08)
	_set_part_material(&"left_lower_leg", socks_color, 0.08)
	_set_part_material(&"right_lower_leg", socks_color, 0.08)
	_set_part_material(&"left_foot", Color(0.04, 0.045, 0.05, 1.0), 0.04)
	_set_part_material(&"right_foot", Color(0.04, 0.045, 0.05, 1.0), 0.04)

func set_move_state(move_speed: float, grounded: bool, vertical_velocity: float = 0.0) -> void:
	last_move_speed = move_speed
	last_grounded = grounded
	last_vertical_velocity = vertical_velocity
	if animation_timer > 0.0:
		return
	_update_state_from_motion()

func play_kick(strong: bool = false) -> void:
	animation_state = &"strong_kick" if strong else &"kick"
	animation_timer = 0.34 if strong else 0.26
	_apply_animation()

func play_celebrate() -> void:
	animation_state = &"celebrate"
	animation_timer = 1.25
	_apply_animation()

func play_hit() -> void:
	animation_state = &"hit"
	animation_timer = 0.22
	_apply_animation()

func set_boost_trail_active(is_active: bool) -> void:
	if boost_trail_particles != null:
		boost_trail_particles.emitting = is_active

func set_skid_dust_active(is_active: bool) -> void:
	if skid_dust_particles != null:
		skid_dust_particles.emitting = is_active

func debug_get_part_count() -> int:
	return part_meshes.size()

func debug_has_part(part_name: StringName) -> bool:
	return part_meshes.has(part_name)

func debug_get_animation_state() -> StringName:
	return animation_state

func debug_get_skin_tone_id() -> StringName:
	return appearance.skin_tone_id

func debug_get_country_kit_id() -> StringName:
	return appearance.country_kit_id

func debug_get_skin_color() -> Color:
	return AvatarCatalogScript.get_skin_color(appearance.skin_tone_id)

func debug_get_shirt_primary_color() -> Color:
	return AvatarCatalogScript.get_kit_primary_color(appearance.country_kit_id)

func debug_get_part_albedo_color(part_id: StringName) -> Color:
	var mesh_instance := part_meshes.get(part_id) as MeshInstance3D
	if mesh_instance == null:
		return Color.TRANSPARENT
	var material := mesh_instance.material_override as StandardMaterial3D
	if material == null:
		return Color.TRANSPARENT
	return material.albedo_color

func debug_has_persistent_vfx() -> bool:
	return boost_trail_particles != null and skid_dust_particles != null

func debug_is_boost_trail_emitting() -> bool:
	return boost_trail_particles != null and boost_trail_particles.emitting

func debug_is_skid_dust_emitting() -> bool:
	return skid_dust_particles != null and skid_dust_particles.emitting

func _build_avatar() -> void:
	if part_root != null:
		return
	part_root = Node3D.new()
	part_root.name = "AvatarParts"
	add_child(part_root)

	_add_box_part(&"torso", part_root, Vector3(0.0, 1.00, 0.0), Vector3(0.72, 0.72, 0.36))
	_add_box_part(&"chest_stripe", part_root, Vector3(0.0, 1.08, -0.19), Vector3(0.62, 0.18, 0.025))
	_add_box_part(&"shorts", part_root, Vector3(0.0, 0.55, 0.0), Vector3(0.62, 0.28, 0.34))
	_add_box_part(&"neck", part_root, Vector3(0.0, 1.39, 0.0), Vector3(0.22, 0.16, 0.20))
	_add_sphere_part(&"head", part_root, Vector3(0.0, 1.63, 0.0), 0.25)

	_add_limb(&"left", Vector3(-0.47, 1.22, 0.0), -0.10)
	_add_limb(&"right", Vector3(0.47, 1.22, 0.0), 0.10)
	_add_leg(&"left", Vector3(-0.19, 0.42, 0.0))
	_add_leg(&"right", Vector3(0.19, 0.42, 0.0))
	_build_persistent_vfx()
	_apply_first_person_visibility()

func _add_limb(side_id: StringName, pivot_position: Vector3, side_bias: float) -> void:
	var pivot := Node3D.new()
	pivot.name = "%sArmPivot" % str(side_id).capitalize()
	pivot.position = pivot_position
	part_root.add_child(pivot)
	part_pivots[StringName("%s_arm" % side_id)] = pivot
	_add_box_part(StringName("%s_upper_arm" % side_id), pivot, Vector3(side_bias, -0.22, 0.0), Vector3(0.18, 0.44, 0.18))
	_add_box_part(StringName("%s_lower_arm" % side_id), pivot, Vector3(side_bias, -0.58, 0.0), Vector3(0.16, 0.34, 0.16))
	_add_box_part(StringName("%s_hand" % side_id), pivot, Vector3(side_bias, -0.82, -0.01), Vector3(0.18, 0.14, 0.18))

func _add_leg(side_id: StringName, pivot_position: Vector3) -> void:
	var pivot := Node3D.new()
	pivot.name = "%sLegPivot" % str(side_id).capitalize()
	pivot.position = pivot_position
	part_root.add_child(pivot)
	part_pivots[StringName("%s_leg" % side_id)] = pivot
	_add_box_part(StringName("%s_upper_leg" % side_id), pivot, Vector3(0.0, -0.20, 0.0), Vector3(0.22, 0.42, 0.22))
	_add_box_part(StringName("%s_lower_leg" % side_id), pivot, Vector3(0.0, -0.58, 0.0), Vector3(0.19, 0.36, 0.19))
	_add_box_part(StringName("%s_foot" % side_id), pivot, Vector3(0.0, -0.84, -0.08), Vector3(0.22, 0.13, 0.34))

func _add_box_part(part_id: StringName, parent: Node, part_position: Vector3, box_size: Vector3) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = _part_node_name(part_id)
	mesh_instance.position = part_position
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	parent.add_child(mesh_instance)
	part_meshes[part_id] = mesh_instance
	return mesh_instance

func _add_sphere_part(part_id: StringName, parent: Node, part_position: Vector3, radius: float) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = _part_node_name(part_id)
	mesh_instance.position = part_position
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 1.45
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh_instance.mesh = mesh
	parent.add_child(mesh_instance)
	part_meshes[part_id] = mesh_instance
	return mesh_instance

func _set_part_material(part_id: StringName, color: Color, emission_energy: float) -> void:
	var mesh_instance := part_meshes.get(part_id) as MeshInstance3D
	if mesh_instance == null:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	mesh_instance.material_override = material

func _apply_first_person_visibility() -> void:
	if not local_first_person:
		return
	var head_mesh := part_meshes.get(&"head") as MeshInstance3D
	if head_mesh != null:
		head_mesh.visible = false
	var neck_mesh := part_meshes.get(&"neck") as MeshInstance3D
	if neck_mesh != null:
		neck_mesh.visible = false

func _update_state_from_motion() -> void:
	if not last_grounded:
		animation_state = &"jump" if last_vertical_velocity > 0.0 else &"fall"
	elif last_move_speed > 0.55:
		animation_state = &"move"
	else:
		animation_state = &"idle"

func _apply_animation() -> void:
	if part_root == null:
		return
	var move_swing := sin(stride_time * TAU) * clampf(last_move_speed / 8.0, 0.0, 1.0)
	var arm_swing := move_swing * 0.46
	var leg_swing := move_swing * 0.54
	_reset_pose()

	if animation_state == &"move":
		_rotate_pivot(&"left_arm", Vector3(arm_swing, 0.0, -0.08))
		_rotate_pivot(&"right_arm", Vector3(-arm_swing, 0.0, 0.08))
		_rotate_pivot(&"left_leg", Vector3(-leg_swing, 0.0, 0.0))
		_rotate_pivot(&"right_leg", Vector3(leg_swing, 0.0, 0.0))
	elif animation_state == &"jump":
		_rotate_pivot(&"left_arm", Vector3(-0.38, 0.0, -0.28))
		_rotate_pivot(&"right_arm", Vector3(-0.38, 0.0, 0.28))
		_rotate_pivot(&"left_leg", Vector3(0.24, 0.0, 0.0))
		_rotate_pivot(&"right_leg", Vector3(-0.22, 0.0, 0.0))
	elif animation_state == &"fall":
		_rotate_pivot(&"left_arm", Vector3(0.26, 0.0, -0.18))
		_rotate_pivot(&"right_arm", Vector3(0.26, 0.0, 0.18))
		_rotate_pivot(&"left_leg", Vector3(-0.12, 0.0, 0.0))
		_rotate_pivot(&"right_leg", Vector3(-0.12, 0.0, 0.0))
	elif animation_state == &"kick" or animation_state == &"strong_kick":
		var strength := 1.0 if animation_state == &"kick" else 1.35
		_rotate_pivot(&"right_leg", Vector3(-0.92 * strength, 0.0, 0.02))
		_rotate_pivot(&"left_leg", Vector3(0.18, 0.0, -0.02))
		_rotate_pivot(&"left_arm", Vector3(0.32, 0.0, -0.24))
		_rotate_pivot(&"right_arm", Vector3(-0.26, 0.0, 0.24))
	elif animation_state == &"celebrate":
		var wave := sin(stride_time * TAU * 0.7) * 0.18
		_rotate_pivot(&"left_arm", Vector3(-1.24 + wave, 0.0, -0.34))
		_rotate_pivot(&"right_arm", Vector3(-1.24 - wave, 0.0, 0.34))
		part_root.position.y = 0.04 + absf(wave) * 0.08
	elif animation_state == &"hit":
		_rotate_pivot(&"left_arm", Vector3(0.42, 0.0, -0.18))
		_rotate_pivot(&"right_arm", Vector3(0.42, 0.0, 0.18))
		part_root.rotation.x = 0.08

func _build_persistent_vfx() -> void:
	if boost_trail_particles == null:
		boost_trail_particles = _create_persistent_particles(
			"BoostTrailParticles",
			Vector3(0.0, 0.32, 0.58),
			Color(0.3, 0.92, 1.0, 1.0),
			54,
			0.26,
			Vector3(0.0, 0.05, 1.0),
			1.25,
			0.04
		)
		part_root.add_child(boost_trail_particles)
	if skid_dust_particles == null:
		skid_dust_particles = _create_persistent_particles(
			"SkidDustParticles",
			Vector3(0.0, 0.08, 0.02),
			Color(0.72, 0.84, 0.68, 0.82),
			28,
			0.28,
			Vector3(0.0, 0.7, 0.12),
			0.75,
			0.055
		)
		part_root.add_child(skid_dust_particles)

func _create_persistent_particles(node_name: String, local_position: Vector3, color: Color, amount: int, lifetime: float, direction: Vector3, speed: float, radius: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = node_name
	particles.position = local_position
	particles.amount = amount
	particles.lifetime = lifetime
	particles.emitting = false
	particles.local_coords = true
	particles.explosiveness = 0.0
	particles.randomness = 0.48
	var process_material := ParticleProcessMaterial.new()
	process_material.gravity = Vector3(0.0, -1.6, 0.0)
	process_material.direction = direction.normalized() if direction.length_squared() > 0.0001 else Vector3.UP
	process_material.initial_velocity_min = speed * 0.35
	process_material.initial_velocity_max = speed
	process_material.spread = 42.0
	process_material.scale_min = 0.18
	process_material.scale_max = 0.5
	particles.process_material = process_material
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = _build_vfx_material(color)
	particles.draw_pass_1 = mesh
	return particles

func _build_vfx_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.35
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _reset_pose() -> void:
	part_root.position = Vector3.ZERO
	part_root.rotation = Vector3.ZERO
	for pivot_id: StringName in part_pivots.keys():
		var pivot := part_pivots.get(pivot_id) as Node3D
		if pivot != null:
			pivot.rotation = Vector3.ZERO

func _rotate_pivot(pivot_id: StringName, radians_rotation: Vector3) -> void:
	var pivot := part_pivots.get(pivot_id) as Node3D
	if pivot == null:
		return
	pivot.rotation = radians_rotation

func _part_node_name(part_id: StringName) -> String:
	var chunks := str(part_id).split("_", false)
	for index: int in range(chunks.size()):
		chunks[index] = chunks[index].capitalize()
	return "".join(chunks)
