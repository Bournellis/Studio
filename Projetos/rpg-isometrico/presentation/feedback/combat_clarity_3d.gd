class_name CombatClarity3D
extends Node3D

const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")

var player
var bot
var arena_camera: Camera3D

var player_attack_ring: MeshInstance3D
var player_dash_ring: MeshInstance3D
var bot_threat_ring: MeshInstance3D
var aim_marker: MeshInstance3D
var projectile_preview: MeshInstance3D
var leap_preview: MeshInstance3D

func _ready() -> void:
	_ensure_nodes()

func bind(next_player, next_bot, next_camera: Camera3D) -> void:
	player = next_player
	bot = next_bot
	arena_camera = next_camera
	_ensure_nodes()

func _process(delta: float) -> void:
	if player == null or bot == null or arena_camera == null:
		visible = false
		return

	visible = true
	var aim_state: Dictionary = _build_aim_state()
	var preview_focus: String = _resolve_preview_focus(aim_state)
	_update_player_attack_ring(delta, preview_focus)
	_update_player_dash_ring(delta, preview_focus)
	_update_bot_threat_ring(delta)
	_update_projectile_preview(delta, aim_state, preview_focus)
	_update_leap_preview(delta, aim_state, preview_focus)
	_update_aim_marker(aim_state, preview_focus)

func _ensure_nodes() -> void:
	if get_node_or_null("PlayerAttackRange") == null:
		player_attack_ring = MeshInstance3D.new()
		player_attack_ring.name = "PlayerAttackRange"
		player_attack_ring.mesh = _build_ring_mesh(0.9, 1.0)
		player_attack_ring.position = Vector3(0.0, 0.03, 0.0)
		player_attack_ring.material_override = _create_ring_material(Color(0.94, 0.8, 0.52, 1.0), 0.14)
		add_child(player_attack_ring)
	else:
		player_attack_ring = get_node("PlayerAttackRange")

	if get_node_or_null("PlayerDashRange") == null:
		player_dash_ring = MeshInstance3D.new()
		player_dash_ring.name = "PlayerDashRange"
		player_dash_ring.mesh = _build_ring_mesh(0.92, 1.0)
		player_dash_ring.position = Vector3(0.0, 0.025, 0.0)
		player_dash_ring.material_override = _create_ring_material(Color(0.46, 0.82, 1.0, 1.0), 0.08)
		add_child(player_dash_ring)
	else:
		player_dash_ring = get_node("PlayerDashRange")

	if get_node_or_null("BotThreatRange") == null:
		bot_threat_ring = MeshInstance3D.new()
		bot_threat_ring.name = "BotThreatRange"
		bot_threat_ring.mesh = _build_ring_mesh(0.91, 1.0)
		bot_threat_ring.position = Vector3(0.0, 0.035, 0.0)
		bot_threat_ring.material_override = _create_ring_material(Color(1.0, 0.42, 0.24, 1.0), 0.1)
		add_child(bot_threat_ring)
	else:
		bot_threat_ring = get_node("BotThreatRange")

	if get_node_or_null("AimMarker") == null:
		aim_marker = MeshInstance3D.new()
		aim_marker.name = "AimMarker"
		aim_marker.mesh = _build_marker_mesh()
		aim_marker.position = Vector3(0.0, 0.04, 0.0)
		aim_marker.material_override = _create_ring_material(Color(0.86, 0.92, 1.0, 1.0), 0.34)
		add_child(aim_marker)
	else:
		aim_marker = get_node("AimMarker")

	if get_node_or_null("ProjectileImpactPreview") == null:
		projectile_preview = MeshInstance3D.new()
		projectile_preview.name = "ProjectileImpactPreview"
		projectile_preview.mesh = _build_ring_mesh(0.84, 1.0)
		projectile_preview.position = Vector3(0.0, 0.045, 0.0)
		projectile_preview.material_override = _create_ring_material(Color(1.0, 0.76, 0.46, 1.0), 0.12)
		add_child(projectile_preview)
	else:
		projectile_preview = get_node("ProjectileImpactPreview")

	if get_node_or_null("LeapLandingPreview") == null:
		leap_preview = MeshInstance3D.new()
		leap_preview.name = "LeapLandingPreview"
		leap_preview.mesh = _build_ring_mesh(0.86, 1.0)
		leap_preview.position = Vector3(0.0, 0.05, 0.0)
		leap_preview.material_override = _create_ring_material(Color(0.7, 0.88, 1.0, 1.0), 0.12)
		add_child(leap_preview)
	else:
		leap_preview = get_node("LeapLandingPreview")

func _update_player_attack_ring(delta: float, preview_focus: String) -> void:
	var radius: float = maxf(0.8, player.get_basic_attack_range())
	player_attack_ring.global_position = Vector3(player.global_position.x, 0.03, player.global_position.z)
	player_attack_ring.scale = Vector3(radius, 1.0, radius)

	var target_in_range: bool = player.target != null and not player.target.is_dead and player.global_position.distance_to(player.target.global_position) <= player.get_basic_attack_range()
	var ready: bool = player.get_basic_attack_cooldown() <= 0.0
	var ring_material: StandardMaterial3D = player_attack_ring.material_override
	var target_energy: float = 0.04
	var target_color: Color = Color(0.88, 0.74, 0.44, 0.12)
	if target_in_range and ready:
		target_energy = 0.28
		target_color = Color(1.0, 0.88, 0.58, 0.32)
	elif ready:
		target_energy = 0.1
		target_color = Color(0.9, 0.8, 0.56, 0.18)
	if preview_focus != "":
		target_energy *= 0.6
		target_color.a *= 0.6
	ring_material.emission_energy_multiplier = lerpf(ring_material.emission_energy_multiplier, target_energy, minf(1.0, delta * 6.5))
	ring_material.albedo_color = ring_material.albedo_color.lerp(target_color, minf(1.0, delta * 6.5))
	ring_material.emission = ring_material.albedo_color

func _update_player_dash_ring(delta: float, preview_focus: String) -> void:
	var radius: float = maxf(1.0, player.get_dash_distance())
	player_dash_ring.global_position = Vector3(player.global_position.x, 0.025, player.global_position.z)
	player_dash_ring.scale = Vector3(radius, 1.0, radius)

	var ready: bool = player.get_dash_cooldown() <= 0.0
	var moving: bool = false
	var velocity_value: Variant = player.get("velocity")
	if velocity_value is Vector3:
		moving = (velocity_value as Vector3).length() > 0.16
	var ring_material: StandardMaterial3D = player_dash_ring.material_override
	var target_energy: float = 0.02
	var target_color: Color = Color(0.48, 0.78, 1.0, 0.04)
	if ready:
		target_energy = 0.05
		target_color = Color(0.58, 0.88, 1.0, 0.08)
		if moving and preview_focus == "":
			target_energy = 0.1
			target_color = Color(0.62, 0.9, 1.0, 0.12)
	if preview_focus != "":
		target_energy *= 0.7
		target_color.a *= 0.8
	ring_material.emission_energy_multiplier = lerpf(ring_material.emission_energy_multiplier, target_energy, minf(1.0, delta * 5.0))
	ring_material.albedo_color = ring_material.albedo_color.lerp(target_color, minf(1.0, delta * 5.0))
	ring_material.emission = ring_material.albedo_color

func _update_bot_threat_ring(delta: float) -> void:
	var radius: float = maxf(0.8, bot.get_attack_range())
	bot_threat_ring.global_position = Vector3(bot.global_position.x, 0.035, bot.global_position.z)
	bot_threat_ring.scale = Vector3(radius, 1.0, radius)

	var distance_to_player: float = bot.global_position.distance_to(player.global_position)
	var close_to_player: bool = distance_to_player <= bot.get_attack_range() + 0.35
	var ring_material: StandardMaterial3D = bot_threat_ring.material_override
	var target_energy: float = 0.0
	var target_color: Color = Color(0.92, 0.42, 0.28, 0.0)
	if bot.is_attack_winding_up():
		var pulse: float = 0.46 + sin(Time.get_ticks_msec() * 0.024) * 0.12
		target_energy = pulse
		target_color = Color(1.0, 0.48, 0.3, 0.34)
	elif close_to_player:
		target_energy = 0.16
		target_color = Color(0.96, 0.46, 0.28, 0.14)
	elif distance_to_player <= bot.get_attack_range() + 2.2:
		target_energy = 0.05
		target_color = Color(0.92, 0.42, 0.28, 0.06)
	ring_material.emission_energy_multiplier = lerpf(ring_material.emission_energy_multiplier, target_energy, minf(1.0, delta * 7.0))
	ring_material.albedo_color = ring_material.albedo_color.lerp(target_color, minf(1.0, delta * 7.0))
	ring_material.emission = ring_material.albedo_color

func _update_projectile_preview(delta: float, aim_state: Dictionary, preview_focus: String) -> void:
	var preview: Dictionary = aim_state.get("projectile", {})
	if preview.is_empty() or preview_focus != "projectile":
		projectile_preview.visible = false
		return

	projectile_preview.visible = true
	projectile_preview.global_position = Vector3(preview.get("impact_point", Vector3.ZERO).x, 0.045, preview.get("impact_point", Vector3.ZERO).z)
	var hit_radius: float = maxf(0.55, float(preview.get("hit_radius", 1.0)))
	projectile_preview.scale = Vector3(hit_radius, 1.0, hit_radius)

	var ring_material: StandardMaterial3D = projectile_preview.material_override
	var ready: bool = bool(preview.get("ready", false))
	var in_range: bool = bool(preview.get("in_range", false))
	var can_hit: bool = bool(preview.get("can_hit", false))
	var target_color: Color = Color(0.58, 0.66, 0.78, 0.12)
	var target_energy: float = 0.08
	if ready and can_hit:
		target_color = Color(0.5, 1.0, 0.64, 0.26)
		target_energy = 0.42
	elif ready and in_range:
		target_color = Color(1.0, 0.78, 0.46, 0.18)
		target_energy = 0.2
	elif ready:
		target_color = Color(1.0, 0.4, 0.34, 0.18)
		target_energy = 0.18
	ring_material.emission_energy_multiplier = lerpf(ring_material.emission_energy_multiplier, target_energy, minf(1.0, delta * 8.0))
	ring_material.albedo_color = ring_material.albedo_color.lerp(target_color, minf(1.0, delta * 8.0))
	ring_material.emission = ring_material.albedo_color

func _update_leap_preview(delta: float, aim_state: Dictionary, preview_focus: String) -> void:
	var preview: Dictionary = aim_state.get("leap", {})
	if preview.is_empty() or preview_focus != "leap":
		leap_preview.visible = false
		return

	leap_preview.visible = true
	leap_preview.global_position = Vector3(preview.get("impact_point", Vector3.ZERO).x, 0.05, preview.get("impact_point", Vector3.ZERO).z)
	var hit_radius: float = maxf(0.8, float(preview.get("hit_radius", 2.0)))
	leap_preview.scale = Vector3(hit_radius, 1.0, hit_radius)

	var ring_material: StandardMaterial3D = leap_preview.material_override
	var ready: bool = bool(preview.get("ready", false))
	var in_range: bool = bool(preview.get("in_range", false))
	var can_hit: bool = bool(preview.get("can_hit", false))
	var target_color: Color = Color(0.56, 0.68, 0.84, 0.14)
	var target_energy: float = 0.1
	if ready and can_hit:
		target_color = Color(0.52, 0.98, 0.72, 0.28)
		target_energy = 0.46
	elif ready and in_range:
		target_color = Color(0.64, 0.88, 1.0, 0.18)
		target_energy = 0.22
	elif ready:
		target_color = Color(1.0, 0.42, 0.34, 0.18)
		target_energy = 0.18
	ring_material.emission_energy_multiplier = lerpf(ring_material.emission_energy_multiplier, target_energy, minf(1.0, delta * 8.0))
	ring_material.albedo_color = ring_material.albedo_color.lerp(target_color, minf(1.0, delta * 8.0))
	ring_material.emission = ring_material.albedo_color

func _update_aim_marker(aim_state: Dictionary, preview_focus: String) -> void:
	if bool(aim_state.get("has_ground_point", false)) == false:
		aim_marker.visible = false
		return

	aim_marker.visible = true
	var raw_point: Vector3 = aim_state.get("raw_point", Vector3.ZERO)
	aim_marker.global_position = Vector3(raw_point.x, 0.04, raw_point.z)
	var distance_to_player: float = float(aim_state.get("raw_distance", 0.0))
	var attack_range: float = player.get_basic_attack_range()
	var within_range: bool = distance_to_player <= attack_range
	var marker_material: StandardMaterial3D = aim_marker.material_override
	var marker_color: Color = Color(0.78, 0.9, 1.0, 0.34)
	var marker_energy: float = 0.24
	if bool(aim_state.get("any_skill_can_hit", false)):
		marker_color = Color(0.54, 1.0, 0.7, 0.62)
		marker_energy = 0.64
	elif bool(aim_state.get("any_skill_out_of_range", false)):
		marker_color = Color(1.0, 0.44, 0.36, 0.58)
		marker_energy = 0.58
	elif bool(aim_state.get("any_skill_ready", false)):
		marker_color = Color(1.0, 0.84, 0.54, 0.54)
		marker_energy = 0.48
	elif within_range:
		marker_color = Color(1.0, 0.86, 0.56, 0.52)
		marker_energy = 0.46
	if preview_focus != "":
		marker_color.a *= 0.72
		marker_energy *= 0.78
	marker_material.albedo_color = marker_color
	marker_material.emission = marker_color
	marker_material.emission_energy_multiplier = marker_energy

func _resolve_preview_focus(aim_state: Dictionary) -> String:
	var projectile_preview_state: Dictionary = aim_state.get("projectile", {})
	var leap_preview_state: Dictionary = aim_state.get("leap", {})
	var projectile_ready: bool = bool(projectile_preview_state.get("ready", false))
	var leap_ready: bool = bool(leap_preview_state.get("ready", false))
	if not projectile_ready and not leap_ready:
		return ""
	if projectile_ready and not leap_ready:
		return "projectile"
	if leap_ready and not projectile_ready:
		return "leap"
	if bool(projectile_preview_state.get("can_hit", false)):
		return "projectile"
	if bool(leap_preview_state.get("can_hit", false)):
		return "leap"

	var projectile_range: float = float(projectile_preview_state.get("range", 0.0))
	var raw_distance: float = float(aim_state.get("raw_distance", 0.0))
	if raw_distance <= projectile_range + 0.4:
		return "projectile"
	return "leap"

func _build_aim_state() -> Dictionary:
	var hit_point: Variant = _project_mouse_to_ground()
	if hit_point == null:
		return {"has_ground_point": false}

	var raw_point: Vector3 = Vector3(hit_point.x, player.global_position.y, hit_point.z)
	var raw_distance: float = player.global_position.distance_to(raw_point)
	var projectile_preview_state: Dictionary = _build_skill_preview_state(SkillDefinitionResource.SkillKind.PROJECTILE, raw_point, raw_distance)
	var leap_preview_state: Dictionary = _build_skill_preview_state(SkillDefinitionResource.SkillKind.LEAP_STRIKE, raw_point, raw_distance)

	return {
		"has_ground_point": true,
		"raw_point": raw_point,
		"raw_distance": raw_distance,
		"projectile": projectile_preview_state,
		"leap": leap_preview_state,
		"any_skill_ready": bool(projectile_preview_state.get("ready", false)) or bool(leap_preview_state.get("ready", false)),
		"any_skill_can_hit": bool(projectile_preview_state.get("can_hit", false)) or bool(leap_preview_state.get("can_hit", false)),
		"any_skill_out_of_range": bool(projectile_preview_state.get("ready", false) and not projectile_preview_state.get("in_range", true)) or bool(leap_preview_state.get("ready", false) and not leap_preview_state.get("in_range", true))
	}

func _build_skill_preview_state(skill_kind: int, raw_point: Vector3, raw_distance: float) -> Dictionary:
	if player == null or not player.has_method("get_skill_index_by_kind"):
		return {}

	var skill_index: int = int(player.get_skill_index_by_kind(skill_kind))
	if skill_index < 0:
		return {}

	var range_value: float = float(player.get_skill_range(skill_index))
	var hit_radius: float = float(player.get_skill_hit_radius(skill_index))
	var ready: bool = bool(player.is_skill_ready(skill_index))
	var in_range: bool = raw_distance <= range_value
	var impact_point: Vector3 = raw_point
	if player.has_method("clamp_skill_aim_point"):
		impact_point = player.clamp_skill_aim_point(raw_point, range_value)
	var can_hit: bool = _target_inside_radius(impact_point, hit_radius)

	return {
		"ready": ready,
		"in_range": in_range,
		"can_hit": ready and can_hit and in_range,
		"impact_point": impact_point,
		"hit_radius": hit_radius,
		"range": range_value
	}

func _target_inside_radius(center_point: Vector3, radius: float) -> bool:
	if player == null or player.target == null or player.target.is_dead:
		return false

	var flat_target: Vector3 = Vector3(player.target.global_position.x, center_point.y, player.target.global_position.z)
	return center_point.distance_to(flat_target) <= radius

func _project_mouse_to_ground() -> Variant:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = arena_camera.project_ray_origin(mouse_position)
	var ray_normal: Vector3 = arena_camera.project_ray_normal(mouse_position)
	if absf(ray_normal.y) < 0.001:
		return null

	var distance: float = -ray_origin.y / ray_normal.y
	if distance <= 0.0:
		return null

	return ray_origin + ray_normal * distance

func _build_ring_mesh(inner_radius: float, outer_radius: float, segments: int = 48) -> ArrayMesh:
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

func _build_marker_mesh() -> CylinderMesh:
	var marker: CylinderMesh = CylinderMesh.new()
	marker.top_radius = 0.22
	marker.bottom_radius = 0.28
	marker.height = 0.04
	return marker

func _create_ring_material(base_color: Color, alpha: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(base_color.r, base_color.g, base_color.b, alpha)
	material.emission_enabled = true
	material.emission = Color(base_color.r, base_color.g, base_color.b, alpha)
	material.emission_energy_multiplier = 0.22
	return material
