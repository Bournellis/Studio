class_name BossRoot
extends Node3D

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const PlayerController = preload("res://gameplay/player/player_controller.gd")
const BossTrollController = preload("res://gameplay/boss/boss_troll_controller.gd")
const BossTremorZone = preload("res://gameplay/boss/boss_tremor_zone.gd")
const GameContext = preload("res://gameplay/simulation/game_context.gd")
const BossSessionManager = preload("res://modes/boss/boss_session_manager.gd")
const BossGameLoop = preload("res://modes/boss/boss_game_loop.gd")
const CombatHud = preload("res://presentation/hud/combat_hud.gd")
const SkillFeedback3D = preload("res://presentation/feedback/skill_feedback_3d.gd")
const CombatFeedbackLayer = preload("res://presentation/feedback/combat_feedback_layer.gd")
const ResultOverlay = preload("res://presentation/results/result_overlay.gd")

const FLOOR_SIZE: Vector3 = Vector3(38.0, 1.0, 38.0)
const ARENA_RADIUS: float = 14.8
const WALL_HEIGHT: float = 2.8
const WALL_THICKNESS: float = 1.25
const CAMERA_OFFSET: Vector3 = Vector3(8.4, 18.8, 8.4)
const CAMERA_BASE_SIZE: float = 15.2
const PLAYER_SPAWN_POSITION: Vector3 = Vector3(0.0, 1.05, 9.8)
const BOSS_SPAWN_POSITION: Vector3 = Vector3(0.0, 1.05, 0.0)

var world_environment: WorldEnvironment
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var mode_floor: StaticBody3D
var floor_collider: CollisionShape3D
var floor_mesh: MeshInstance3D
var arena_ring: MeshInstance3D
var mode_camera: Camera3D
var runtime_root: Node3D
var combat_readability_root: Node3D
var presentation_root: Node
var boundary_root: Node3D
var decoration_root: Node3D

var launch_request
var game_context
var session_manager
var game_loop
var player
var boss
var combat_hud
var combat_feedback_layer

var camera_basis: Basis = Basis.IDENTITY
var fixed_camera_size: float = CAMERA_BASE_SIZE
var run_state: Dictionary = {}
var resume_from_suspended_run: bool = false
var close_handling_active: bool = false

func _ready() -> void:
	if not _launch_context().has_pending_mode_launch(LocalModeCatalog.BOSS_MODE_ID):
		get_tree().change_scene_to_file(LocalModeCatalog.FRONTEND_SCENE_PATH)
		return

	launch_request = _launch_context().consume_pending_mode_launch()
	_content_library().ensure_loaded()
	run_state = _resolve_run_state()
	resume_from_suspended_run = _has_saved_runtime_state()
	_configure_close_handling()
	_ensure_scene_scaffold()
	_configure_world()
	_build_runtime()
	session_manager.start_session()

func _exit_tree() -> void:
	_restore_close_handling()

func _process(_delta: float) -> void:
	_update_camera()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_back"):
		_suspend_and_return_to_menu()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_suspend_and_quit_application()

func _ensure_scene_scaffold() -> void:
	world_environment = _ensure_world_environment("WorldEnvironment")
	key_light = _ensure_directional_light("KeyLight")
	fill_light = _ensure_fill_light("FillLight")
	mode_floor = _ensure_floor("ModeFloor")
	floor_collider = _ensure_collision_shape(mode_floor, "CollisionShape3D")
	floor_mesh = _ensure_floor_mesh(mode_floor, "FloorMesh")
	arena_ring = _ensure_mesh_instance("ArenaRing")
	mode_camera = _ensure_camera("ModeCamera")
	runtime_root = _ensure_node3d("RuntimeRoot")
	combat_readability_root = _ensure_node3d("CombatReadabilityRoot")
	presentation_root = _ensure_node("PresentationRoot")
	boundary_root = _ensure_node3d("BoundaryRoot")
	decoration_root = _ensure_node3d("DecorationRoot")

func _configure_world() -> void:
	var environment_resource: Environment = Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color(0.08, 0.06, 0.07, 1.0)
	environment_resource.ambient_light_color = Color(0.94, 0.86, 0.82, 1.0)
	environment_resource.ambient_light_energy = 1.0
	world_environment.environment = environment_resource

	key_light.rotation_degrees = Vector3(-58.0, -34.0, 0.0)
	key_light.light_energy = 2.7
	key_light.shadow_enabled = true

	fill_light.position = Vector3(0.0, 7.8, 0.0)
	fill_light.light_energy = 1.8
	fill_light.omni_range = 42.0

	mode_floor.position = Vector3(0.0, -0.5, 0.0)
	var floor_shape: BoxShape3D = BoxShape3D.new()
	floor_shape.size = FLOOR_SIZE
	floor_collider.shape = floor_shape

	var floor_box: BoxMesh = BoxMesh.new()
	floor_box.size = FLOOR_SIZE
	floor_mesh.mesh = floor_box
	var floor_material: StandardMaterial3D = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.2, 0.18, 0.19, 1.0)
	floor_material.roughness = 0.92
	floor_material.emission_enabled = true
	floor_material.emission = Color(0.14, 0.08, 0.07, 1.0)
	floor_material.emission_energy_multiplier = 0.16
	floor_mesh.material_override = floor_material

	arena_ring.mesh = _build_ring_mesh(ARENA_RADIUS * 0.94, ARENA_RADIUS)
	arena_ring.position = Vector3(0.0, 0.03, 0.0)
	var ring_material: StandardMaterial3D = StandardMaterial3D.new()
	ring_material.albedo_color = Color(0.72, 0.52, 0.34, 1.0)
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.emission_enabled = true
	ring_material.emission = Color(0.56, 0.28, 0.16, 1.0)
	ring_material.emission_energy_multiplier = 0.14
	arena_ring.material_override = ring_material

	mode_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	mode_camera.size = CAMERA_BASE_SIZE
	mode_camera.global_position = CAMERA_OFFSET
	mode_camera.look_at(Vector3.ZERO, Vector3.UP)
	camera_basis = mode_camera.global_basis
	fixed_camera_size = mode_camera.size
	mode_camera.current = true

	_configure_boundary_walls()
	_configure_torches()
	_configure_rubble()

func _build_runtime() -> void:
	game_context = GameContext.new()
	game_context.name = "GameContext"
	runtime_root.add_child(game_context)
	game_context.reset_round()

	session_manager = BossSessionManager.new()
	session_manager.name = "SessionManager"
	runtime_root.add_child(session_manager)

	player = PlayerController.new()
	player.name = "Player"
	player.position = PLAYER_SPAWN_POSITION
	runtime_root.add_child(player)
	player.configure(_build_runtime_loadout(), game_context)
	player.arena_camera = mode_camera

	boss = BossTrollController.new()
	boss.name = "Boss"
	boss.position = BOSS_SPAWN_POSITION
	runtime_root.add_child(boss)
	boss.configure(launch_request.get_boss_id(), game_context, player)

	player.target = boss
	player.set_additional_targets([boss])

	game_loop = BossGameLoop.new()
	game_loop.name = "GameLoop"
	runtime_root.add_child(game_loop)
	game_loop.bind(launch_request, player, boss, game_context, session_manager)
	session_manager.bind(game_context, game_loop)

	player.impact_registered.connect(func(health_damage: float, absorbed_amount: float, is_lethal: bool): _on_combatant_impact(&"player", health_damage, absorbed_amount, is_lethal))
	boss.impact_registered.connect(func(health_damage: float, absorbed_amount: float, is_lethal: bool): _on_combatant_impact(boss.combatant_id, health_damage, absorbed_amount, is_lethal))

	var skill_feedback_layer = SkillFeedback3D.new()
	skill_feedback_layer.name = "SkillFeedback3D"
	combat_readability_root.add_child(skill_feedback_layer)
	skill_feedback_layer.bind(player)

	combat_hud = CombatHud.new()
	combat_hud.name = "CombatHud"
	presentation_root.add_child(combat_hud)
	combat_hud.bind(player, session_manager, game_context, game_loop)

	combat_feedback_layer = CombatFeedbackLayer.new()
	combat_feedback_layer.name = "CombatFeedbackLayer"
	presentation_root.add_child(combat_feedback_layer)
	combat_feedback_layer.bind(player, null, game_context, mode_camera)
	combat_feedback_layer.register_combatant(boss.combatant_id, boss)

	var result_overlay = ResultOverlay.new()
	result_overlay.name = "ResultOverlay"
	presentation_root.add_child(result_overlay)
	result_overlay.bind(session_manager)
	if not session_manager.session_ended.is_connected(_on_session_ended):
		session_manager.session_ended.connect(_on_session_ended)

	_apply_resumed_run_state_if_needed()
	_update_camera()

func _update_camera() -> void:
	if mode_camera == null or player == null:
		return

	var focus: Vector3 = player.global_position + Vector3(0.0, 0.4, 0.0)
	mode_camera.size = fixed_camera_size
	mode_camera.global_basis = camera_basis
	mode_camera.global_position = focus + CAMERA_OFFSET

func _on_combatant_impact(_combatant_id: StringName, health_damage: float, absorbed_amount: float, is_lethal: bool) -> void:
	var pause_duration: float = 0.0
	if is_lethal:
		pause_duration = 0.09
	elif health_damage > 0.0:
		pause_duration = 0.04
	elif absorbed_amount > 0.0:
		pause_duration = 0.02

	if pause_duration <= 0.0:
		return

	if player != null:
		player.request_motion_pause(pause_duration)
	if boss != null:
		boss.request_motion_pause(pause_duration)

func _on_session_ended(_result: Dictionary) -> void:
	if combat_hud != null:
		combat_hud.visible = false
	_profile_store().clear_suspended_run(_get_boss_run_key())

func _configure_boundary_walls() -> void:
	var segment_count: int = 10
	for index: int in range(segment_count):
		var angle: float = TAU * float(index) / float(segment_count)
		var wall_position: Vector3 = Vector3(cos(angle) * ARENA_RADIUS, WALL_HEIGHT * 0.5, sin(angle) * ARENA_RADIUS)
		_configure_wall_segment(
			"WallSegment%d" % index,
			wall_position,
			Vector3(ARENA_RADIUS * 0.62, WALL_HEIGHT, WALL_THICKNESS),
			rad_to_deg(angle) + 90.0
		)

func _configure_torches() -> void:
	var torch_angles: Array[float] = [0.0, PI * 0.5, PI, PI * 1.5]
	for index: int in range(torch_angles.size()):
		var angle: float = torch_angles[index]
		var torch_root: Node3D = _ensure_decoration_node("Torch%d" % index)
		torch_root.position = Vector3(cos(angle) * (ARENA_RADIUS - 1.3), 0.0, sin(angle) * (ARENA_RADIUS - 1.3))
		torch_root.rotation.y = angle

		var base_mesh: MeshInstance3D = _ensure_child_mesh(torch_root, "BaseMesh")
		var base_box: BoxMesh = BoxMesh.new()
		base_box.size = Vector3(0.68, 1.4, 0.68)
		base_mesh.mesh = base_box
		base_mesh.position = Vector3(0.0, 0.7, 0.0)
		base_mesh.material_override = _build_emissive_material(
			Color(0.34, 0.3, 0.28, 1.0),
			Color(0.08, 0.06, 0.05, 1.0),
			0.06
		)

		var flame_mesh: MeshInstance3D = _ensure_child_mesh(torch_root, "FlameMesh")
		var flame_cylinder: CylinderMesh = CylinderMesh.new()
		flame_cylinder.top_radius = 0.2
		flame_cylinder.bottom_radius = 0.3
		flame_cylinder.height = 0.5
		flame_mesh.mesh = flame_cylinder
		flame_mesh.position = Vector3(0.0, 1.65, 0.0)
		flame_mesh.material_override = _build_emissive_material(
			Color(1.0, 0.58, 0.24, 0.88),
			Color(1.0, 0.46, 0.18, 0.9),
			0.85,
			true
		)

		var torch_light: OmniLight3D = torch_root.get_node_or_null("TorchLight") as OmniLight3D
		if torch_light == null:
			torch_light = OmniLight3D.new()
			torch_light.name = "TorchLight"
			torch_root.add_child(torch_light)
		torch_light.position = Vector3(0.0, 1.8, 0.0)
		torch_light.light_color = Color(1.0, 0.54, 0.2, 1.0)
		torch_light.light_energy = 0.95
		torch_light.omni_range = 8.0

func _configure_rubble() -> void:
	var rubble_positions: Array[Vector3] = [
		Vector3(6.8, 0.45, 10.5),
		Vector3(-6.6, 0.45, 10.2),
		Vector3(9.8, 0.45, -6.8),
		Vector3(-9.4, 0.45, -6.6)
	]
	for index: int in range(rubble_positions.size()):
		var rubble: StaticBody3D = _ensure_static_body(decoration_root, "Rubble%d" % index)
		rubble.position = rubble_positions[index]
		rubble.rotation.y = deg_to_rad(18.0 * index)
		var collider: CollisionShape3D = _ensure_collision_shape(rubble, "CollisionShape3D")
		var mesh_instance: MeshInstance3D = _ensure_floor_mesh(rubble, "Mesh")
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = Vector3(2.4, 0.8, 1.6)
		collider.shape = shape
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = shape.size
		mesh_instance.mesh = mesh
		mesh_instance.material_override = _build_emissive_material(
			Color(0.26, 0.24, 0.24, 1.0),
			Color(0.08, 0.05, 0.05, 1.0),
			0.05
		)

func _configure_wall_segment(node_name: String, world_position: Vector3, size: Vector3, rotation_y_degrees: float) -> void:
	var segment: StaticBody3D = _ensure_static_body(boundary_root, node_name)
	segment.position = world_position
	segment.rotation_degrees = Vector3(0.0, rotation_y_degrees, 0.0)
	var collision_shape: CollisionShape3D = _ensure_collision_shape(segment, "CollisionShape3D")
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = size
	collision_shape.shape = box_shape
	var mesh_instance: MeshInstance3D = _ensure_floor_mesh(segment, "Mesh")
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = _build_emissive_material(
		Color(0.3, 0.26, 0.26, 1.0),
		Color(0.12, 0.08, 0.08, 1.0),
		0.08
	)

func _build_emissive_material(albedo: Color, emission: Color, energy: float, transparent: bool = false) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.9
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if transparent else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = energy
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _build_ring_mesh(inner_radius: float, outer_radius: float, segments: int = 72) -> ArrayMesh:
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

func _launch_context() -> Node:
	return get_node("/root/LaunchContext")

func _profile_store() -> Node:
	return get_node("/root/ProfileStore")

func _content_library() -> Node:
	return get_node("/root/ContentLibrary")

func _suspend_and_return_to_menu() -> void:
	_persist_suspended_run_if_possible("menu")
	_restore_close_handling()
	get_tree().change_scene_to_file(LocalModeCatalog.FRONTEND_SCENE_PATH)

func _suspend_and_quit_application() -> void:
	_persist_suspended_run_if_possible("quit")
	_restore_close_handling()
	get_tree().quit()

func _save_run_state() -> void:
	run_state["loadout"] = _build_runtime_loadout_payload()
	run_state["boss_id"] = String(launch_request.get_boss_id())
	run_state["player"] = {} if player == null else player.get_runtime_snapshot()
	run_state["boss"] = {} if boss == null else boss.get_runtime_snapshot()
	_profile_store().save_suspended_run(_get_boss_run_key(), run_state)

func _persist_suspended_run_if_possible(suspend_origin: String = "") -> bool:
	if session_manager == null or session_manager.state == session_manager.SessionState.SESSION_END:
		return false
	run_state["suspend_origin"] = suspend_origin
	_save_run_state()
	return true

func _resolve_run_state() -> Dictionary:
	var saved_run: Dictionary = {}
	if launch_request.should_resume_suspended_run():
		saved_run = _profile_store().get_suspended_run(_get_boss_run_key())
	if saved_run.is_empty():
		return _build_fresh_run_state()
	var resolved_run_state: Dictionary = _sanitize_run_state(saved_run)
	if launch_request.should_resume_suspended_run():
		resolved_run_state["suspend_origin"] = ""
	return resolved_run_state

func _build_fresh_run_state() -> Dictionary:
	return _sanitize_run_state({
		"mode_id": String(LocalModeCatalog.BOSS_MODE_ID),
		"boss_id": String(launch_request.get_boss_id()),
		"loadout": launch_request.loadout.to_id_payload(),
		"player": {},
		"boss": {},
		"suspend_origin": ""
	})

func _sanitize_run_state(payload: Dictionary) -> Dictionary:
	return {
		"mode_id": str(payload.get("mode_id", String(LocalModeCatalog.BOSS_MODE_ID))),
		"boss_id": str(payload.get("boss_id", String(launch_request.get_boss_id()))),
		"loadout": Dictionary(payload.get("loadout", {})).duplicate(true),
		"player": Dictionary(payload.get("player", {})).duplicate(true),
		"boss": Dictionary(payload.get("boss", {})).duplicate(true),
		"suspend_origin": str(payload.get("suspend_origin", ""))
	}

func _has_saved_runtime_state() -> bool:
	return not Dictionary(run_state.get("player", {})).is_empty() or not Dictionary(run_state.get("boss", {})).is_empty()

func _build_runtime_loadout():
	var resumed_loadout = _build_loadout_from_payload(Dictionary(run_state.get("loadout", {})))
	if resumed_loadout != null and resumed_loadout.is_valid():
		return resumed_loadout
	return launch_request.loadout

func _build_runtime_loadout_payload() -> Dictionary:
	if player != null and player.loadout != null and player.loadout.is_valid():
		return player.loadout.to_id_payload()
	if launch_request != null and launch_request.loadout != null and launch_request.loadout.is_valid():
		return launch_request.loadout.to_id_payload()
	return Dictionary(run_state.get("loadout", {})).duplicate(true)

func _build_loadout_from_payload(payload: Dictionary):
	var race_id: StringName = StringName(str(payload.get("race_id", "")))
	var weapon_id: StringName = StringName(str(payload.get("weapon_id", "")))
	var skill_ids: PackedStringArray = PackedStringArray(_extract_string_array(payload.get("skill_ids", [])))
	var potion_ids: PackedStringArray = PackedStringArray(_extract_string_array(payload.get("potion_ids", [])))
	return _content_library().build_loadout_from_ids(race_id, weapon_id, skill_ids, potion_ids)

func _apply_resumed_run_state_if_needed() -> void:
	if not resume_from_suspended_run:
		return

	player.restore_runtime_snapshot(Dictionary(run_state.get("player", {})))
	var boss_snapshot: Dictionary = Dictionary(run_state.get("boss", {}))
	boss.restore_runtime_snapshot(boss_snapshot)
	_restore_boss_tremor_zone(Dictionary(boss_snapshot.get("tremor_zone", {})))
	player.target = boss
	player.set_additional_targets([boss])

func _restore_boss_tremor_zone(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	var tremor_zone := BossTremorZone.new()
	tremor_zone.name = "BossTremorZone"
	runtime_root.add_child(tremor_zone)
	tremor_zone.restore_runtime_snapshot(player, snapshot)
	boss.attach_restored_tremor_zone(tremor_zone)

func _extract_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			result.append(str(entry))
	return result

func _get_boss_run_key() -> StringName:
	return ProgressionResolver.build_boss_run_key(launch_request.get_boss_id())

func debug_save_suspended_run() -> void:
	_save_run_state()

func debug_get_run_state() -> Dictionary:
	return run_state.duplicate(true)

func _configure_close_handling() -> void:
	if close_handling_active:
		return
	var tree := get_tree()
	if tree != null:
		tree.auto_accept_quit = false
	close_handling_active = true

func _restore_close_handling() -> void:
	if not close_handling_active:
		return
	var tree := get_tree()
	if tree != null:
		tree.auto_accept_quit = true
	close_handling_active = false

func _ensure_world_environment(node_name: String) -> WorldEnvironment:
	var existing: WorldEnvironment = get_node_or_null(node_name) as WorldEnvironment
	if existing != null:
		return existing
	var created := WorldEnvironment.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_directional_light(node_name: String) -> DirectionalLight3D:
	var existing: DirectionalLight3D = get_node_or_null(node_name) as DirectionalLight3D
	if existing != null:
		return existing
	var created := DirectionalLight3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_fill_light(node_name: String) -> OmniLight3D:
	var existing: OmniLight3D = get_node_or_null(node_name) as OmniLight3D
	if existing != null:
		return existing
	var created := OmniLight3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_floor(node_name: String) -> StaticBody3D:
	var existing: StaticBody3D = get_node_or_null(node_name) as StaticBody3D
	if existing != null:
		return existing
	var created := StaticBody3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_collision_shape(parent: Node, node_name: String) -> CollisionShape3D:
	var existing: CollisionShape3D = parent.get_node_or_null(node_name) as CollisionShape3D
	if existing != null:
		return existing
	var created := CollisionShape3D.new()
	created.name = node_name
	parent.add_child(created)
	return created

func _ensure_floor_mesh(parent: Node, node_name: String) -> MeshInstance3D:
	var existing: MeshInstance3D = parent.get_node_or_null(node_name) as MeshInstance3D
	if existing != null:
		return existing
	var created := MeshInstance3D.new()
	created.name = node_name
	parent.add_child(created)
	return created

func _ensure_mesh_instance(node_name: String) -> MeshInstance3D:
	var existing: MeshInstance3D = get_node_or_null(node_name) as MeshInstance3D
	if existing != null:
		return existing
	var created := MeshInstance3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_camera(node_name: String) -> Camera3D:
	var existing: Camera3D = get_node_or_null(node_name) as Camera3D
	if existing != null:
		return existing
	var created := Camera3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_node3d(node_name: String) -> Node3D:
	var existing: Node3D = get_node_or_null(node_name) as Node3D
	if existing != null:
		return existing
	var created := Node3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_node(node_name: String) -> Node:
	var existing: Node = get_node_or_null(node_name)
	if existing != null:
		return existing
	var created := Node.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_static_body(parent: Node3D, node_name: String) -> StaticBody3D:
	var existing: StaticBody3D = parent.get_node_or_null(node_name) as StaticBody3D
	if existing != null:
		return existing
	var created := StaticBody3D.new()
	created.name = node_name
	parent.add_child(created)
	return created

func _ensure_decoration_node(node_name: String) -> Node3D:
	var existing: Node3D = decoration_root.get_node_or_null(node_name) as Node3D
	if existing != null:
		return existing
	var created := Node3D.new()
	created.name = node_name
	decoration_root.add_child(created)
	return created

func _ensure_child_mesh(parent: Node3D, node_name: String) -> MeshInstance3D:
	var existing: MeshInstance3D = parent.get_node_or_null(node_name) as MeshInstance3D
	if existing != null:
		return existing
	var created := MeshInstance3D.new()
	created.name = node_name
	parent.add_child(created)
	return created
