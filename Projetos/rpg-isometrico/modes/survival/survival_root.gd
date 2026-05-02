class_name SurvivalRoot
extends Node3D

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const PlayerController = preload("res://gameplay/player/player_controller.gd")
const GameContext = preload("res://gameplay/simulation/game_context.gd")
const SurvivalSessionManager = preload("res://modes/survival/survival_session_manager.gd")
const SurvivalGameLoop = preload("res://modes/survival/survival_game_loop.gd")
const SurvivalWaveManager = preload("res://modes/survival/survival_wave_manager.gd")
const SurvivalSpawnController = preload("res://modes/survival/survival_spawn_controller.gd")
const CombatHud = preload("res://presentation/hud/combat_hud.gd")
const SkillFeedback3D = preload("res://presentation/feedback/skill_feedback_3d.gd")
const CombatFeedbackLayer = preload("res://presentation/feedback/combat_feedback_layer.gd")
const ResultOverlay = preload("res://presentation/results/result_overlay.gd")
const GAMEPLAY_ACTIONS: PackedStringArray = [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"basic_attack",
	"dash",
	"skill_1",
	"skill_2",
	"skill_3",
	"skill_4",
	"potion_1",
	"potion_2"
]

const FLOOR_SIZE: Vector3 = Vector3(40.0, 1.0, 40.0)
const CAMERA_OFFSET: Vector3 = Vector3(8.4, 18.8, 8.4)
const CAMERA_SIZE: float = 15.2
const PLAYER_SPAWN_POSITION: Vector3 = Vector3(0.0, 1.05, 0.0)
const SPAWN_MARGIN: float = 3.2
const POST_START_SPAWN_GUARD_DURATION: float = 0.3

var world_environment: WorldEnvironment
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var mode_floor: StaticBody3D
var floor_collider: CollisionShape3D
var floor_mesh: MeshInstance3D
var mode_camera: Camera3D
var camera_basis: Basis = Basis.IDENTITY
var runtime_root: Node3D
var combat_readability_root: Node3D
var presentation_root: Node
var boundary_root: Node3D
var ruins_root: Node3D

var launch_request
var game_context
var session_manager
var game_loop
var spawn_controller
var wave_manager
var player
var combat_hud
var combat_feedback_layer
var pre_match_spawn_lock_active: bool = true
var post_start_spawn_guard_remaining: float = 0.0
var pre_match_locked_position: Vector3 = PLAYER_SPAWN_POSITION
var resume_from_suspended_run: bool = false
var run_state: Dictionary = {}
var close_handling_active: bool = false

func _ready() -> void:
	if not _launch_context().has_pending_mode_launch(LocalModeCatalog.SURVIVAL_MODE_ID):
		get_tree().change_scene_to_file(LocalModeCatalog.FRONTEND_SCENE_PATH)
		return

	launch_request = _launch_context().consume_pending_mode_launch()
	pre_match_spawn_lock_active = true
	post_start_spawn_guard_remaining = 0.0
	pre_match_locked_position = PLAYER_SPAWN_POSITION
	_clear_gameplay_inputs()
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

func _process(delta: float) -> void:
	_enforce_pre_match_spawn_lock()
	_tick_post_start_spawn_guard(delta)
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
	fill_light = _ensure_omni_light("FillLight")
	mode_floor = _ensure_floor("ModeFloor")
	floor_collider = _ensure_collision_shape(mode_floor, "CollisionShape3D")
	floor_mesh = _ensure_floor_mesh(mode_floor, "FloorMesh")
	mode_camera = _ensure_camera("ModeCamera")
	runtime_root = _ensure_node3d("RuntimeRoot")
	combat_readability_root = _ensure_node3d("CombatReadabilityRoot")
	presentation_root = _ensure_node("PresentationRoot")
	boundary_root = _ensure_node3d("BoundaryRoot")
	ruins_root = _ensure_node3d("RuinsRoot")

func _configure_world() -> void:
	var environment_resource: Environment = Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color(0.05, 0.07, 0.09, 1.0)
	environment_resource.ambient_light_color = Color(0.92, 0.94, 0.88, 1.0)
	environment_resource.ambient_light_energy = 1.12
	world_environment.environment = environment_resource

	key_light.rotation_degrees = Vector3(-56.0, -36.0, 0.0)
	key_light.light_energy = 2.45
	key_light.shadow_enabled = true

	fill_light.position = Vector3(0.0, 7.0, 0.0)
	fill_light.light_energy = 1.75
	fill_light.omni_range = 42.0

	mode_floor.position = Vector3(0.0, -0.5, 0.0)
	var floor_shape: BoxShape3D = BoxShape3D.new()
	floor_shape.size = FLOOR_SIZE
	floor_collider.shape = floor_shape

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = FLOOR_SIZE
	floor_mesh.mesh = mesh
	var floor_material: StandardMaterial3D = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.18, 0.21, 0.18, 1.0)
	floor_material.roughness = 0.92
	floor_material.emission_enabled = true
	floor_material.emission = Color(0.09, 0.12, 0.08, 1.0)
	floor_material.emission_energy_multiplier = 0.14
	floor_mesh.material_override = floor_material

	mode_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	mode_camera.size = CAMERA_SIZE
	mode_camera.global_position = CAMERA_OFFSET
	mode_camera.look_at(Vector3.ZERO, Vector3.UP)
	camera_basis = mode_camera.global_basis
	mode_camera.current = true

	_configure_boundary_walls()
	_configure_ruins()

func _build_runtime() -> void:
	game_context = GameContext.new()
	game_context.name = "GameContext"
	runtime_root.add_child(game_context)
	game_context.reset_round()

	session_manager = SurvivalSessionManager.new()
	session_manager.name = "SessionManager"
	runtime_root.add_child(session_manager)

	player = PlayerController.new()
	player.name = "Player"
	player.position = PLAYER_SPAWN_POSITION
	runtime_root.add_child(player)
	player.configure(_build_runtime_loadout(), game_context)
	player.arena_camera = mode_camera

	spawn_controller = SurvivalSpawnController.new()
	spawn_controller.name = "SpawnController"
	runtime_root.add_child(spawn_controller)
	spawn_controller.configure(runtime_root, game_context, player, _build_spawn_points())

	wave_manager = SurvivalWaveManager.new()
	wave_manager.name = "WaveManager"
	runtime_root.add_child(wave_manager)
	wave_manager.bind(spawn_controller)

	game_loop = SurvivalGameLoop.new()
	game_loop.name = "GameLoop"
	runtime_root.add_child(game_loop)
	game_loop.bind(launch_request, player, game_context, session_manager, wave_manager, spawn_controller)
	session_manager.bind(game_context, game_loop)

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

	spawn_controller.enemy_spawned.connect(_on_enemy_spawned)
	spawn_controller.enemy_defeated.connect(_on_enemy_defeated)

	var result_overlay = ResultOverlay.new()
	result_overlay.name = "ResultOverlay"
	presentation_root.add_child(result_overlay)
	result_overlay.bind(session_manager)
	if not session_manager.session_ended.is_connected(_on_session_ended):
		session_manager.session_ended.connect(_on_session_ended)
	if not session_manager.session_started.is_connected(_on_session_started):
		session_manager.session_started.connect(_on_session_started)

	_apply_resumed_run_state_if_needed()
	_update_camera()

func _update_camera() -> void:
	if mode_camera == null or player == null:
		return

	var desired_focus: Vector3 = player.global_position + Vector3(0.0, 0.45, 0.0)
	mode_camera.global_basis = camera_basis
	mode_camera.global_position = desired_focus + CAMERA_OFFSET

func _on_enemy_spawned(enemy) -> void:
	if combat_feedback_layer != null and enemy != null:
		combat_feedback_layer.register_combatant(enemy.combatant_id, enemy)

func _on_enemy_defeated(enemy_id: StringName, _enemy) -> void:
	if combat_feedback_layer != null:
		combat_feedback_layer.unregister_combatant(enemy_id)

func _on_session_started() -> void:
	_clear_gameplay_inputs()
	_enforce_pre_match_spawn_lock()
	pre_match_spawn_lock_active = false
	if resume_from_suspended_run:
		post_start_spawn_guard_remaining = 0.0
		return
	post_start_spawn_guard_remaining = POST_START_SPAWN_GUARD_DURATION
	if player != null:
		player.request_motion_pause(POST_START_SPAWN_GUARD_DURATION)

func _on_session_ended(_result: Dictionary) -> void:
	if combat_hud != null:
		combat_hud.visible = false
	_profile_store().clear_suspended_run(_get_survival_run_key())

func _enforce_pre_match_spawn_lock() -> void:
	if not pre_match_spawn_lock_active or player == null:
		return

	player.global_position = pre_match_locked_position
	player.reset_runtime_motion()

func _tick_post_start_spawn_guard(delta: float) -> void:
	if post_start_spawn_guard_remaining <= 0.0 or player == null:
		return

	post_start_spawn_guard_remaining = maxf(0.0, post_start_spawn_guard_remaining - delta)
	player.global_position = PLAYER_SPAWN_POSITION
	player.reset_runtime_motion()

func _clear_gameplay_inputs() -> void:
	for action_name: String in GAMEPLAY_ACTIONS:
		Input.action_release(action_name)

func _configure_boundary_walls() -> void:
	var half_floor: float = FLOOR_SIZE.x * 0.5
	var wall_y: float = 1.2
	var span: float = FLOOR_SIZE.x + 4.0
	_configure_box_structure(
		boundary_root,
		"NorthWall",
		Vector3(0.0, wall_y, -half_floor - 0.55),
		Vector3(span, 2.4, 1.2),
		Color(0.18, 0.2, 0.22, 1.0),
		Color(0.04, 0.05, 0.06, 1.0)
	)
	_configure_box_structure(
		boundary_root,
		"SouthWall",
		Vector3(0.0, wall_y, half_floor + 0.55),
		Vector3(span, 2.4, 1.2),
		Color(0.18, 0.2, 0.22, 1.0),
		Color(0.04, 0.05, 0.06, 1.0)
	)
	_configure_box_structure(
		boundary_root,
		"WestWall",
		Vector3(-half_floor - 0.55, wall_y, 0.0),
		Vector3(1.2, 2.4, span),
		Color(0.18, 0.2, 0.22, 1.0),
		Color(0.04, 0.05, 0.06, 1.0)
	)
	_configure_box_structure(
		boundary_root,
		"EastWall",
		Vector3(half_floor + 0.55, wall_y, 0.0),
		Vector3(1.2, 2.4, span),
		Color(0.18, 0.2, 0.22, 1.0),
		Color(0.04, 0.05, 0.06, 1.0)
	)

func _configure_ruins() -> void:
	var positions: Array[Vector3] = [
		Vector3(-5.2, 0.85, -5.2),
		Vector3(-5.2, 0.85, 5.2),
		Vector3(5.2, 0.85, -5.2),
		Vector3(5.2, 0.85, 5.2)
	]
	for index: int in range(positions.size()):
		_configure_box_structure(
			ruins_root,
			"RuinColumn%d" % index,
			positions[index],
			Vector3(1.5, 1.7, 1.5),
			Color(0.34, 0.36, 0.32, 1.0),
			Color(0.08, 0.09, 0.08, 1.0)
		)

func _configure_box_structure(parent: Node3D, node_name: String, world_position: Vector3, size: Vector3, albedo: Color, emission: Color) -> void:
	var body: StaticBody3D = parent.get_node_or_null(node_name) as StaticBody3D
	if body == null:
		body = StaticBody3D.new()
		body.name = node_name
		parent.add_child(body)

	var collider: CollisionShape3D = _ensure_collision_shape(body, "CollisionShape3D")
	var mesh_node: MeshInstance3D = _ensure_floor_mesh(body, "Mesh")
	body.position = world_position
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.92
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = 0.08
	mesh_node.material_override = material

func _build_spawn_points() -> Array[Vector3]:
	var half_floor: float = FLOOR_SIZE.x * 0.5 + SPAWN_MARGIN
	return [
		Vector3(0.0, 0.0, -half_floor),
		Vector3(half_floor * 0.72, 0.0, -half_floor * 0.72),
		Vector3(half_floor, 0.0, 0.0),
		Vector3(half_floor * 0.72, 0.0, half_floor * 0.72),
		Vector3(0.0, 0.0, half_floor),
		Vector3(-half_floor * 0.72, 0.0, half_floor * 0.72),
		Vector3(-half_floor, 0.0, 0.0),
		Vector3(-half_floor * 0.72, 0.0, -half_floor * 0.72)
	]

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
	run_state["player"] = {} if player == null else player.get_runtime_snapshot()
	run_state["wave_manager"] = {} if wave_manager == null else wave_manager.get_runtime_snapshot()
	run_state["spawn_controller"] = {} if spawn_controller == null else spawn_controller.get_runtime_snapshot()
	_profile_store().save_suspended_run(_get_survival_run_key(), run_state)

func _persist_suspended_run_if_possible(suspend_origin: String = "") -> bool:
	if session_manager == null or session_manager.state == session_manager.SessionState.SESSION_END:
		return false
	run_state["suspend_origin"] = suspend_origin
	_save_run_state()
	return true

func _resolve_run_state() -> Dictionary:
	var saved_run: Dictionary = {}
	if launch_request.should_resume_suspended_run():
		saved_run = _profile_store().get_suspended_run(_get_survival_run_key())
	if saved_run.is_empty():
		return _build_fresh_run_state()
	var resolved_run_state: Dictionary = _sanitize_run_state(saved_run)
	if launch_request.should_resume_suspended_run():
		resolved_run_state["suspend_origin"] = ""
	return resolved_run_state

func _build_fresh_run_state() -> Dictionary:
	return _sanitize_run_state({
		"mode_id": String(LocalModeCatalog.SURVIVAL_MODE_ID),
		"loadout": launch_request.loadout.to_id_payload(),
		"start_wave": launch_request.get_survival_start_wave(),
		"player": {},
		"wave_manager": {},
		"spawn_controller": {},
		"suspend_origin": ""
	})

func _sanitize_run_state(payload: Dictionary) -> Dictionary:
	return {
		"mode_id": str(payload.get("mode_id", String(LocalModeCatalog.SURVIVAL_MODE_ID))),
		"loadout": Dictionary(payload.get("loadout", {})).duplicate(true),
		"start_wave": maxi(1, int(payload.get("start_wave", launch_request.get_survival_start_wave()))),
		"player": Dictionary(payload.get("player", {})).duplicate(true),
		"wave_manager": Dictionary(payload.get("wave_manager", {})).duplicate(true),
		"spawn_controller": Dictionary(payload.get("spawn_controller", {})).duplicate(true),
		"suspend_origin": str(payload.get("suspend_origin", ""))
	}

func _has_saved_runtime_state() -> bool:
	return (
		not Dictionary(run_state.get("player", {})).is_empty()
		or not Dictionary(run_state.get("wave_manager", {})).is_empty()
		or not Dictionary(run_state.get("spawn_controller", {})).is_empty()
	)

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
	spawn_controller.restore_runtime_snapshot(Dictionary(run_state.get("spawn_controller", {})))
	wave_manager.restore_runtime_snapshot(Dictionary(run_state.get("wave_manager", {})))
	game_loop.mark_runtime_started_from_resume()
	pre_match_locked_position = player.global_position

func _extract_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			result.append(str(entry))
	return result

func _get_survival_run_key() -> StringName:
	return ProgressionResolver.build_survival_run_key()

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

func _ensure_omni_light(node_name: String) -> OmniLight3D:
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
