class_name SkillFeedback3D
extends Node3D

const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")

const PROJECTILE_COLOR: Color = Color(1.0, 0.8, 0.46, 1.0)
const BUFF_COLOR: Color = Color(0.42, 0.94, 0.62, 1.0)
const BURST_COLOR: Color = Color(1.0, 0.48, 0.28, 1.0)
const LEAP_COLOR: Color = Color(0.68, 0.88, 1.0, 1.0)
const GROUND_EFFECT_Y: float = 0.02

var player
var effect_serial: int = 0
var active_effects: Array[Dictionary] = []

var projectile_effects: Node3D
var buff_effects: Node3D
var burst_effects: Node3D
var leap_effects: Node3D

func _ready() -> void:
	_ensure_roots()

func _exit_tree() -> void:
	_disconnect_player()

func bind(next_player) -> void:
	if player == next_player:
		return

	_disconnect_player()
	player = next_player
	_ensure_roots()
	if player != null:
		player.skill_used.connect(_on_player_skill_used)

func _process(delta: float) -> void:
	for index: int in range(active_effects.size() - 1, -1, -1):
		var effect: Dictionary = active_effects[index]
		var age: float = float(effect.get("age", 0.0)) + delta
		var duration: float = maxf(0.01, float(effect.get("duration", 0.35)))
		var progress: float = clampf(age / duration, 0.0, 1.0)
		effect["age"] = age
		match String(effect.get("kind", "")):
			"projectile":
				_update_projectile(effect, progress)
			"buff":
				_update_buff(effect, progress)
			"burst":
				_update_burst(effect, progress)
			"leap":
				_update_leap(effect, progress)
		active_effects[index] = effect
		if age >= duration:
			var root: Node3D = effect.get("root") as Node3D
			if is_instance_valid(root):
				root.queue_free()
			active_effects.remove_at(index)

func _ensure_roots() -> void:
	projectile_effects = _ensure_root("ProjectileEffects")
	buff_effects = _ensure_root("BuffEffects")
	burst_effects = _ensure_root("BurstEffects")
	leap_effects = _ensure_root("LeapEffects")

func _ensure_root(node_name: String) -> Node3D:
	var existing := get_node_or_null(node_name) as Node3D
	if existing != null:
		return existing

	var root := Node3D.new()
	root.name = node_name
	add_child(root)
	return root

func _disconnect_player() -> void:
	if player != null and player.skill_used.is_connected(_on_player_skill_used):
		player.skill_used.disconnect(_on_player_skill_used)

func _on_player_skill_used(effect: Dictionary) -> void:
	var skill_kind: int = int(effect.get("skill_kind", -1))
	match skill_kind:
		SkillDefinitionResource.SkillKind.PROJECTILE:
			_spawn_projectile_feedback(effect)
		SkillDefinitionResource.SkillKind.SELF_BUFF:
			_spawn_buff_feedback(effect)
		SkillDefinitionResource.SkillKind.AREA_BURST:
			_spawn_burst_feedback(effect)
		SkillDefinitionResource.SkillKind.LEAP_STRIKE:
			_spawn_leap_feedback(effect)

func _spawn_projectile_feedback(effect: Dictionary) -> void:
	var origin: Vector3 = _ground_point(effect.get("origin_position", Vector3.ZERO))
	var impact: Vector3 = _ground_point(effect.get("impact_position", origin))
	var root: Node3D = _create_effect_root(projectile_effects, "ProjectileCast")
	root.global_position = impact
	var travel_direction: Vector3 = impact - origin
	travel_direction.y = 0.0
	if travel_direction.length_squared() > 0.0001:
		root.look_at(impact + travel_direction.normalized(), Vector3.UP, true)
	var beam := MeshInstance3D.new()
	beam.name = "Beam"
	beam.mesh = _create_box_mesh(Vector3(0.14, 0.08, minf(1.1, maxf(0.35, origin.distance_to(impact)))))
	beam.material_override = _create_material(PROJECTILE_COLOR, 0.48, 0.76)
	root.add_child(beam)

	var impact_ring := MeshInstance3D.new()
	impact_ring.name = "ImpactRing"
	impact_ring.mesh = _create_ring_mesh(0.84, 1.0)
	impact_ring.position = Vector3(0.0, 0.04, 0.0)
	impact_ring.material_override = _create_material(PROJECTILE_COLOR, 0.24, 0.58)
	root.add_child(impact_ring)

	var flare := MeshInstance3D.new()
	flare.name = "ImpactFlare"
	flare.mesh = _create_disc_mesh(0.42, 0.08)
	flare.position = Vector3(0.0, 0.08, 0.0)
	flare.material_override = _create_material(PROJECTILE_COLOR.lightened(0.1), 0.58, 1.1)
	root.add_child(flare)

	beam.position = Vector3(0.0, 0.12, minf(0.55, maxf(0.18, origin.distance_to(impact) * 0.35)))
	active_effects.append({
		"kind": "projectile",
		"root": root,
		"beam": beam,
		"ring": impact_ring,
		"flare": flare,
		"hit_confirmed": bool(effect.get("hit_confirmed", false)),
		"duration": 0.28,
		"age": 0.0
	})

func _spawn_buff_feedback(effect: Dictionary) -> void:
	var origin: Vector3 = _ground_point(effect.get("origin_position", Vector3.ZERO))
	var root: Node3D = _create_effect_root(buff_effects, "BuffAura")
	root.global_position = origin

	var aura_ring := MeshInstance3D.new()
	aura_ring.name = "AuraRing"
	aura_ring.mesh = _create_ring_mesh(0.84, 1.0)
	aura_ring.position = Vector3(0.0, 0.04, 0.0)
	aura_ring.material_override = _create_material(BUFF_COLOR, 0.22, 0.48)
	root.add_child(aura_ring)

	var aura_column := MeshInstance3D.new()
	aura_column.name = "AuraColumn"
	aura_column.mesh = _create_disc_mesh(0.62, 2.1)
	aura_column.position = Vector3(0.0, 1.05, 0.0)
	aura_column.material_override = _create_material(BUFF_COLOR.lightened(0.08), 0.06, 0.14)
	root.add_child(aura_column)

	active_effects.append({
		"kind": "buff",
		"root": root,
		"ring": aura_ring,
		"column": aura_column,
		"duration": maxf(float(effect.get("duration", 0.0)), 3.0),
		"age": 0.0
	})

func _spawn_burst_feedback(effect: Dictionary) -> void:
	var origin: Vector3 = _ground_point(effect.get("origin_position", Vector3.ZERO))
	var range_value: float = maxf(1.4, float(effect.get("range", 2.0)))
	var root: Node3D = _create_effect_root(burst_effects, "BurstWave")
	root.global_position = origin

	var burst_ring := MeshInstance3D.new()
	burst_ring.name = "BurstRing"
	burst_ring.mesh = _create_ring_mesh(0.84, 1.0)
	burst_ring.position = Vector3(0.0, 0.05, 0.0)
	burst_ring.material_override = _create_material(BURST_COLOR, 0.22, 0.58)
	root.add_child(burst_ring)

	var burst_core := MeshInstance3D.new()
	burst_core.name = "BurstCore"
	burst_core.mesh = _create_disc_mesh(0.56, 0.18)
	burst_core.position = Vector3(0.0, 0.12, 0.0)
	burst_core.material_override = _create_material(BURST_COLOR.lightened(0.1), 0.06, 0.12)
	root.add_child(burst_core)

	active_effects.append({
		"kind": "burst",
		"root": root,
		"ring": burst_ring,
		"core": burst_core,
		"range": range_value,
		"duration": 0.42,
		"age": 0.0
	})

func _spawn_leap_feedback(effect: Dictionary) -> void:
	var origin: Vector3 = _ground_point(effect.get("origin_position", Vector3.ZERO))
	var impact: Vector3 = _ground_point(effect.get("impact_position", origin))
	var root: Node3D = _create_effect_root(leap_effects, "LeapImpact")
	root.global_position = impact
	var travel_direction: Vector3 = impact - origin
	travel_direction.y = 0.0
	if travel_direction.length_squared() > 0.0001:
		root.look_at(impact + travel_direction.normalized(), Vector3.UP, true)
	var trail := MeshInstance3D.new()
	trail.name = "LeapTrail"
	trail.mesh = _create_box_mesh(Vector3(0.2, 0.08, minf(1.35, maxf(0.4, origin.distance_to(impact) * 0.45))))
	trail.material_override = _create_material(LEAP_COLOR, 0.34, 0.64)
	root.add_child(trail)

	var landing_ring := MeshInstance3D.new()
	landing_ring.name = "LandingRing"
	landing_ring.mesh = _create_ring_mesh(0.84, 1.0)
	landing_ring.position = Vector3(0.0, 0.04, 0.0)
	landing_ring.material_override = _create_material(LEAP_COLOR, 0.24, 0.6)
	root.add_child(landing_ring)

	var landing_flash := MeshInstance3D.new()
	landing_flash.name = "StartFlash"
	landing_flash.mesh = _create_disc_mesh(0.3, 0.08)
	landing_flash.position = Vector3(0.0, 0.08, 0.0)
	landing_flash.material_override = _create_material(LEAP_COLOR.lightened(0.12), 0.22, 0.42)
	root.add_child(landing_flash)

	trail.position = Vector3(0.0, 0.12, minf(0.62, maxf(0.2, origin.distance_to(impact) * 0.25)))
	active_effects.append({
		"kind": "leap",
		"root": root,
		"trail": trail,
		"ring": landing_ring,
		"flash": landing_flash,
		"hit_confirmed": bool(effect.get("hit_confirmed", false)),
		"duration": 0.38,
		"age": 0.0
	})

func _update_projectile(effect: Dictionary, progress: float) -> void:
	var beam: MeshInstance3D = effect.get("beam") as MeshInstance3D
	var ring: MeshInstance3D = effect.get("ring") as MeshInstance3D
	var flare: MeshInstance3D = effect.get("flare") as MeshInstance3D
	var hit_confirmed: bool = bool(effect.get("hit_confirmed", false))
	var beam_material: StandardMaterial3D = beam.material_override as StandardMaterial3D
	var ring_material: StandardMaterial3D = ring.material_override as StandardMaterial3D
	var flare_material: StandardMaterial3D = flare.material_override as StandardMaterial3D
	var fade: float = 1.0 - progress
	var energy_scale: float = 1.0 if hit_confirmed else 0.72

	beam.scale = Vector3(1.0, 1.0 + sin(progress * PI) * 0.35, 1.0)
	_apply_material_state(beam_material, PROJECTILE_COLOR, 0.48 * fade, 0.76 * fade * energy_scale)

	ring.scale = Vector3(0.55 + progress * 1.35, 1.0, 0.55 + progress * 1.35)
	_apply_material_state(ring_material, PROJECTILE_COLOR.lightened(progress * 0.1), 0.28 * fade, 0.62 * fade * energy_scale)

	flare.scale = Vector3.ONE * (0.85 + progress * 1.5)
	_apply_material_state(flare_material, PROJECTILE_COLOR.lightened(0.18), 0.24 * fade, 0.52 * fade * energy_scale)

func _update_buff(effect: Dictionary, progress: float) -> void:
	var root: Node3D = effect.get("root") as Node3D
	var ring: MeshInstance3D = effect.get("ring") as MeshInstance3D
	var column: MeshInstance3D = effect.get("column") as MeshInstance3D
	var ring_material: StandardMaterial3D = ring.material_override as StandardMaterial3D
	var column_material: StandardMaterial3D = column.material_override as StandardMaterial3D
	var pulse: float = 0.75 + sin(progress * TAU * 4.0) * 0.12
	if player != null:
		root.global_position = _ground_point(player.global_position)

	ring.scale = Vector3.ONE * (1.15 + pulse * 0.18)
	_apply_material_state(ring_material, BUFF_COLOR.lightened(0.04), 0.16 + pulse * 0.05, 0.34 + pulse * 0.14)

	column.scale = Vector3(1.0 + pulse * 0.06, 0.86 + (1.0 - progress) * 0.18, 1.0 + pulse * 0.06)
	_apply_material_state(column_material, BUFF_COLOR.lightened(0.1), 0.02 + pulse * 0.015, 0.05 + pulse * 0.04)

func _update_burst(effect: Dictionary, progress: float) -> void:
	var ring: MeshInstance3D = effect.get("ring") as MeshInstance3D
	var core: MeshInstance3D = effect.get("core") as MeshInstance3D
	var ring_material: StandardMaterial3D = ring.material_override as StandardMaterial3D
	var core_material: StandardMaterial3D = core.material_override as StandardMaterial3D
	var range_value: float = float(effect.get("range", 2.0))
	var fade: float = 1.0 - progress

	ring.scale = Vector3.ONE * lerpf(0.25, range_value, progress)
	_apply_material_state(ring_material, BURST_COLOR.lightened(progress * 0.12), 0.24 * fade, 0.56 * fade)

	core.scale = Vector3.ONE * lerpf(0.55, 1.0, progress)
	_apply_material_state(core_material, BURST_COLOR.lightened(0.08), 0.04 * fade, 0.12 * fade)

func _update_leap(effect: Dictionary, progress: float) -> void:
	var trail: MeshInstance3D = effect.get("trail") as MeshInstance3D
	var ring: MeshInstance3D = effect.get("ring") as MeshInstance3D
	var flash: MeshInstance3D = effect.get("flash") as MeshInstance3D
	var hit_confirmed: bool = bool(effect.get("hit_confirmed", false))
	var trail_material: StandardMaterial3D = trail.material_override as StandardMaterial3D
	var ring_material: StandardMaterial3D = ring.material_override as StandardMaterial3D
	var flash_material: StandardMaterial3D = flash.material_override as StandardMaterial3D
	var fade: float = 1.0 - progress
	var energy_scale: float = 1.08 if hit_confirmed else 0.82

	trail.scale = Vector3(1.0, 1.0 + sin(progress * PI) * 0.25, 1.0)
	_apply_material_state(trail_material, LEAP_COLOR.lightened(progress * 0.08), 0.34 * fade, 0.64 * fade * energy_scale)

	ring.scale = Vector3.ONE * (0.62 + progress * 1.7)
	_apply_material_state(ring_material, LEAP_COLOR.lightened(0.1), 0.26 * fade, 0.62 * fade * energy_scale)

	flash.scale = Vector3.ONE * (1.0 + progress * 0.9)
	_apply_material_state(flash_material, LEAP_COLOR.lightened(0.16), 0.16 * fade, 0.32 * fade)

func _create_effect_root(container: Node3D, prefix: String) -> Node3D:
	effect_serial += 1
	var root := Node3D.new()
	root.name = "%s%d" % [prefix, effect_serial]
	container.add_child(root)
	return root

func _position_segment_root(root: Node3D, segment: MeshInstance3D, start: Vector3, finish: Vector3, height: float) -> void:
	var travel: Vector3 = finish - start
	var distance: float = maxf(0.01, travel.length())
	root.global_position = start
	if distance > 0.02:
		root.look_at(finish, Vector3.UP, true)
	var segment_mesh := segment.mesh as BoxMesh
	if segment_mesh != null:
		segment_mesh.size = Vector3(segment_mesh.size.x, segment_mesh.size.y, distance)
	segment.position = Vector3(0.0, height, -distance * 0.5)
	for child in root.get_children():
		var mesh_child := child as MeshInstance3D
		if mesh_child == null or mesh_child == segment:
			continue
		mesh_child.position.z = -distance

func _create_box_mesh(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh

func _create_ring_mesh(inner_radius: float, outer_radius: float, segments: int = 48) -> ArrayMesh:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index: int in range(segments):
		var angle_a: float = TAU * float(index) / float(segments)
		var angle_b: float = TAU * float(index + 1) / float(segments)
		var outer_a: Vector3 = Vector3(cos(angle_a) * outer_radius, 0.0, sin(angle_a) * outer_radius)
		var outer_b: Vector3 = Vector3(cos(angle_b) * outer_radius, 0.0, sin(angle_b) * outer_radius)
		var inner_a: Vector3 = Vector3(cos(angle_a) * inner_radius, 0.0, sin(angle_a) * inner_radius)
		var inner_b: Vector3 = Vector3(cos(angle_b) * inner_radius, 0.0, sin(angle_b) * inner_radius)

		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(outer_a)
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(outer_b)
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(inner_b)

		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(outer_a)
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(inner_b)
		surface_tool.set_normal(Vector3.UP)
		surface_tool.add_vertex(inner_a)
	return surface_tool.commit()

func _create_disc_mesh(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	return mesh

func _create_material(base_color: Color, alpha: float, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(base_color.r, base_color.g, base_color.b, alpha)
	material.emission_enabled = true
	material.emission = Color(base_color.r, base_color.g, base_color.b, alpha)
	material.emission_energy_multiplier = energy
	return material

func _apply_material_state(material: StandardMaterial3D, base_color: Color, alpha: float, energy: float) -> void:
	var color: Color = Color(base_color.r, base_color.g, base_color.b, clampf(alpha, 0.0, 1.0))
	material.albedo_color = color
	material.emission = color
	material.emission_energy_multiplier = maxf(0.0, energy)

func _ground_point(world_point: Vector3) -> Vector3:
	return Vector3(world_point.x, GROUND_EFFECT_Y, world_point.z)
