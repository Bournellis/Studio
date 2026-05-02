class_name BossTremorZone
extends Node3D

signal expired()

const CRACK_WIDTH: float = 0.72
const CRACK_THICKNESS: float = 0.06
const RING_THICKNESS: float = 0.08
const DAMAGE_TICK_INTERVAL: float = 0.5

var player
var source_id: StringName = &"boss_troll"
var radius: float = 7.0
var duration: float = 2.5
var damage_per_second: float = 40.0
var crack_count: int = 7

var time_remaining: float = 0.0
var damage_tick_remaining: float = DAMAGE_TICK_INTERVAL
var crack_directions: Array[Vector3] = []
var crack_meshes: Array[MeshInstance3D] = []
var ring_mesh: MeshInstance3D

func configure(next_player, next_source_id: StringName, next_radius: float, next_duration: float, next_damage_per_second: float, next_crack_count: int, rng: RandomNumberGenerator) -> void:
	player = next_player
	source_id = next_source_id
	radius = maxf(1.0, next_radius)
	duration = maxf(0.2, next_duration)
	damage_per_second = maxf(0.0, next_damage_per_second)
	crack_count = maxi(1, next_crack_count)
	time_remaining = duration
	damage_tick_remaining = DAMAGE_TICK_INTERVAL
	_build_visuals(rng)

func _process(delta: float) -> void:
	if time_remaining <= 0.0:
		return

	time_remaining = maxf(0.0, time_remaining - delta)
	damage_tick_remaining = maxf(0.0, damage_tick_remaining - delta)
	_update_visual_state()

	if damage_tick_remaining == 0.0:
		damage_tick_remaining = DAMAGE_TICK_INTERVAL
		_apply_damage_tick()

	if time_remaining == 0.0:
		expired.emit()
		queue_free()

func _apply_damage_tick() -> void:
	if player == null or not is_instance_valid(player) or player.is_dead:
		return
	if not _player_is_touching_crack():
		return

	player.take_damage(damage_per_second * DAMAGE_TICK_INTERVAL, source_id)

func _player_is_touching_crack() -> bool:
	var offset: Vector3 = player.global_position - global_position
	offset.y = 0.0
	if offset.length_squared() <= 0.04:
		return false

	for direction: Vector3 in crack_directions:
		var projection: float = offset.dot(direction)
		if projection < 0.45 or projection > radius:
			continue
		var perpendicular: float = (offset - direction * projection).length()
		if perpendicular <= CRACK_WIDTH:
			return true
	return false

func _build_visuals(rng: RandomNumberGenerator) -> void:
	var base_angle: float = rng.randf_range(0.0, TAU)
	var generated_directions: Array[Vector3] = []
	for index: int in range(crack_count):
		var angle: float = base_angle + TAU * float(index) / float(crack_count) + rng.randf_range(-0.18, 0.18)
		generated_directions.append(Vector3(cos(angle), 0.0, sin(angle)).normalized())
	_build_visuals_from_directions(generated_directions)

func get_runtime_snapshot() -> Dictionary:
	return {
		"source_id": String(source_id),
		"radius": radius,
		"duration": duration,
		"damage_per_second": damage_per_second,
		"crack_count": crack_count,
		"time_remaining": time_remaining,
		"damage_tick_remaining": damage_tick_remaining,
		"position": var_to_str(global_position),
		"crack_directions": var_to_str(crack_directions)
	}

func restore_runtime_snapshot(next_player, snapshot: Dictionary) -> void:
	player = next_player
	source_id = StringName(str(snapshot.get("source_id", "boss_troll")))
	radius = maxf(1.0, float(snapshot.get("radius", radius)))
	duration = maxf(0.2, float(snapshot.get("duration", duration if duration > 0.0 else 2.5)))
	damage_per_second = maxf(0.0, float(snapshot.get("damage_per_second", damage_per_second)))
	crack_count = maxi(1, int(snapshot.get("crack_count", crack_count if crack_count > 0 else 7)))
	time_remaining = maxf(0.0, float(snapshot.get("time_remaining", duration)))
	damage_tick_remaining = maxf(0.0, float(snapshot.get("damage_tick_remaining", DAMAGE_TICK_INTERVAL)))
	global_position = _deserialize_vector3(snapshot.get("position", ""), global_position)
	_build_visuals_from_directions(_deserialize_directions(snapshot.get("crack_directions", "")))

func _create_crack_mesh(direction: Vector3) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Crack%d" % crack_meshes.size()
	var crack_mesh: BoxMesh = BoxMesh.new()
	crack_mesh.size = Vector3(CRACK_WIDTH, CRACK_THICKNESS, radius)
	mesh_instance.mesh = crack_mesh
	mesh_instance.position = Vector3(direction.x, 0.0, direction.z) * (radius * 0.5)
	mesh_instance.position.y = 0.03
	mesh_instance.rotation.y = atan2(direction.x, direction.z)
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.92, 0.28, 0.16, 0.8)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = true
	material.emission = Color(1.0, 0.34, 0.2, 0.82)
	material.emission_energy_multiplier = 0.8
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance

func _update_visual_state() -> void:
	var normalized_time: float = 0.0 if duration <= 0.0 else time_remaining / duration
	var pulse: float = 0.72 + sin(Time.get_ticks_msec() * 0.013) * 0.12
	var crack_alpha: float = clampf(0.28 + normalized_time * 0.52, 0.2, 0.82)

	for crack_mesh: MeshInstance3D in crack_meshes:
		if crack_mesh == null:
			continue
		var material: StandardMaterial3D = crack_mesh.material_override as StandardMaterial3D
		if material == null:
			continue
		material.albedo_color = Color(0.92, 0.28, 0.16, crack_alpha)
		material.emission = Color(1.0, 0.34, 0.2, crack_alpha)
		material.emission_energy_multiplier = pulse

	if ring_mesh != null:
		var ring_material: StandardMaterial3D = ring_mesh.material_override as StandardMaterial3D
		if ring_material != null:
			var ring_alpha: float = clampf(0.12 + normalized_time * 0.14, 0.08, 0.24)
			ring_material.albedo_color = Color(1.0, 0.42, 0.28, ring_alpha)
			ring_material.emission = Color(0.92, 0.28, 0.18, ring_alpha)
			ring_material.emission_energy_multiplier = 0.28 + normalized_time * 0.22

func _clear_visuals() -> void:
	for child: Node in get_children():
		child.queue_free()
	crack_meshes.clear()
	ring_mesh = null

func _build_ring_mesh(inner_radius: float, outer_radius: float, segments: int = 56) -> ArrayMesh:
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

func _build_visuals_from_directions(next_directions: Array[Vector3]) -> void:
	_clear_visuals()
	crack_directions = next_directions.duplicate()
	for direction: Vector3 in crack_directions:
		crack_meshes.append(_create_crack_mesh(direction))

	ring_mesh = MeshInstance3D.new()
	ring_mesh.name = "TremorBoundary"
	ring_mesh.mesh = _build_ring_mesh(radius * 0.88, radius)
	ring_mesh.position = Vector3(0.0, 0.04, 0.0)
	var ring_material: StandardMaterial3D = StandardMaterial3D.new()
	ring_material.albedo_color = Color(1.0, 0.42, 0.28, 0.18)
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = Color(0.92, 0.28, 0.18, 0.28)
	ring_material.emission_energy_multiplier = 0.42
	ring_mesh.material_override = ring_material
	add_child(ring_mesh)

func _deserialize_vector3(value: Variant, fallback: Vector3) -> Vector3:
	if value is String and str(value) != "":
		var parsed: Variant = str_to_var(str(value))
		if parsed is Vector3:
			return parsed
	return fallback

func _deserialize_directions(value: Variant) -> Array[Vector3]:
	if value is String and str(value) != "":
		var parsed: Variant = str_to_var(str(value))
		if parsed is Array:
			var result: Array[Vector3] = []
			for direction: Variant in parsed:
				if direction is Vector3:
					result.append(direction)
			if not result.is_empty():
				return result
	return [Vector3.FORWARD]
