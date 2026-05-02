class_name ArenaRoot
extends Node3D

const PlayerController = preload("res://gameplay/player/player_controller.gd")
const SimpleBotController = preload("res://gameplay/bot/simple_bot_controller.gd")
const GameContext = preload("res://gameplay/simulation/game_context.gd")
const ArenaSessionManager = preload("res://modes/arena/arena_session_manager.gd")
const ArenaGameLoop = preload("res://modes/arena/arena_game_loop.gd")
const CombatHud = preload("res://presentation/hud/combat_hud.gd")
const CombatClarity3D = preload("res://presentation/feedback/combat_clarity_3d.gd")
const SkillFeedback3D = preload("res://presentation/feedback/skill_feedback_3d.gd")
const CombatFeedbackLayer = preload("res://presentation/feedback/combat_feedback_layer.gd")
const ResultOverlay = preload("res://presentation/results/result_overlay.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

const FRONTEND_SCENE_PATH: String = LocalModeCatalog.FRONTEND_SCENE_PATH

const CAMERA_OFFSET: Vector3 = Vector3(8.4, 18.8, 8.4)
const CAMERA_SIZE: float = 15.2
const FLOOR_SIZE: Vector3 = Vector3(40.0, 1.0, 40.0)
const ARENA_RING_INNER_RADIUS: float = 15.7
const ARENA_RING_OUTER_RADIUS: float = 16.35
const WALL_HEIGHT: float = 2.8
const WALL_THICKNESS: float = 1.1
const INNER_BLOCK_HEIGHT: float = 2.3

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var key_light: DirectionalLight3D = $KeyLight
@onready var fill_light: OmniLight3D = $FillLight
@onready var arena_floor: StaticBody3D = $ArenaFloor
@onready var arena_floor_collider: CollisionShape3D = $ArenaFloor/CollisionShape3D
@onready var arena_floor_mesh: MeshInstance3D = $ArenaFloor/FloorMesh
@onready var arena_ring: MeshInstance3D = $ArenaRing
@onready var arena_markers: Node3D = $ArenaMarkers
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var bot_spawn: Marker3D = $BotSpawn
@onready var arena_camera: Camera3D = $ArenaCamera
@onready var combat_readability_root: Node3D = $CombatReadabilityRoot
@onready var runtime_root: Node3D = $RuntimeRoot
@onready var presentation_root: Node = $PresentationRoot

var loadout
var player
var bot
var game_context
var session_manager
var game_loop
var combat_hud
var result_overlay
var fixed_camera_basis: Basis = Basis.IDENTITY

func _ready() -> void:
	if not _launch_context().has_pending_mode_launch(LocalModeCatalog.ARENA_MODE_ID):
		get_tree().change_scene_to_file(FRONTEND_SCENE_PATH)
		return

	var launch_request = _launch_context().consume_pending_mode_launch()
	loadout = launch_request.loadout
	_configure_world_nodes()
	_build_runtime()
	session_manager.start_session()

func _process(_delta: float) -> void:
	_update_camera()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_back"):
		get_tree().change_scene_to_file(FRONTEND_SCENE_PATH)

func _configure_world_nodes() -> void:
	var env_resource: Environment = Environment.new()
	env_resource.background_mode = Environment.BG_COLOR
	env_resource.background_color = Color(0.08, 0.1, 0.14, 1.0)
	env_resource.ambient_light_color = Color(0.94, 0.92, 0.88, 1.0)
	env_resource.ambient_light_energy = 1.2
	world_environment.environment = env_resource

	key_light.rotation_degrees = Vector3(-55.0, -45.0, 0.0)
	key_light.light_energy = 2.6
	key_light.shadow_enabled = true

	fill_light.position = Vector3(0.0, 8.0, 0.0)
	fill_light.light_energy = 2.05
	fill_light.omni_range = 48.0

	arena_floor.position = Vector3(0.0, -0.5, 0.0)
	var floor_shape: BoxShape3D = BoxShape3D.new()
	floor_shape.size = FLOOR_SIZE
	arena_floor_collider.shape = floor_shape

	var floor_box: BoxMesh = BoxMesh.new()
	floor_box.size = FLOOR_SIZE
	arena_floor_mesh.mesh = floor_box
	var floor_material: StandardMaterial3D = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.22, 0.28, 0.34, 1.0)
	floor_material.roughness = 0.88
	floor_material.emission_enabled = true
	floor_material.emission = Color(0.08, 0.11, 0.14, 1.0)
	floor_material.emission_energy_multiplier = 0.15
	arena_floor_mesh.material_override = floor_material

	arena_ring.mesh = _build_arena_ring_mesh(ARENA_RING_INNER_RADIUS, ARENA_RING_OUTER_RADIUS)
	arena_ring.position = Vector3(0.0, 0.02, 0.0)
	var ring_material: StandardMaterial3D = StandardMaterial3D.new()
	ring_material.albedo_color = Color(0.72, 0.58, 0.42, 1.0)
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.emission_enabled = true
	ring_material.emission = Color(0.58, 0.42, 0.24, 1.0)
	ring_material.emission_energy_multiplier = 0.11
	arena_ring.material_override = ring_material

	var marker_positions: Array[Vector3] = [
		Vector3(-12.2, 0.12, -12.2),
		Vector3(-12.2, 0.12, 12.2),
		Vector3(12.2, 0.12, -12.2),
		Vector3(12.2, 0.12, 12.2)
	]
	for index: int in range(arena_markers.get_child_count()):
		var marker := arena_markers.get_child(index) as MeshInstance3D
		if marker == null:
			continue
		var marker_mesh: BoxMesh = BoxMesh.new()
		marker_mesh.size = Vector3(0.55, 0.24, 0.55)
		marker.mesh = marker_mesh
		marker.position = marker_positions[index]
		var marker_material: StandardMaterial3D = StandardMaterial3D.new()
		marker_material.albedo_color = Color(0.85, 0.82, 0.72, 1.0)
		marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		marker_material.emission_enabled = true
		marker_material.emission = Color(0.6, 0.56, 0.42, 1.0)
		marker_material.emission_energy_multiplier = 0.28
		marker.material_override = marker_material

	player_spawn.position = Vector3(-5.0, 1.05, 2.4)
	bot_spawn.position = Vector3(5.2, 1.05, -2.1)

	_configure_arena_walls()
	_configure_arena_blocks()

	arena_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	arena_camera.size = CAMERA_SIZE
	arena_camera.global_position = CAMERA_OFFSET
	arena_camera.look_at(Vector3(0.0, 0.4, 0.0), Vector3.UP)
	fixed_camera_basis = arena_camera.global_basis
	arena_camera.current = true

func _build_runtime() -> void:
	game_context = GameContext.new()
	game_context.name = "GameContext"
	runtime_root.add_child(game_context)
	game_context.reset_round()

	session_manager = ArenaSessionManager.new()
	session_manager.name = "SessionManager"
	runtime_root.add_child(session_manager)

	game_loop = ArenaGameLoop.new()
	game_loop.name = "GameLoop"
	runtime_root.add_child(game_loop)

	player = PlayerController.new()
	player.name = "Player"
	player.position = player_spawn.position
	runtime_root.add_child(player)
	player.configure(loadout, game_context)
	player.arena_camera = arena_camera

	bot = SimpleBotController.new()
	bot.name = "Bot"
	bot.position = bot_spawn.position
	runtime_root.add_child(bot)
	bot.configure(game_context, player)

	player.target = bot
	player.impact_registered.connect(_on_combatant_impact.bind(&"player"))
	bot.impact_registered.connect(_on_combatant_impact.bind(&"bot"))

	game_loop.bind(player, bot, game_context, session_manager)
	session_manager.bind(game_context, game_loop)

	var clarity_layer = CombatClarity3D.new()
	clarity_layer.name = "CombatClarity3D"
	combat_readability_root.add_child(clarity_layer)
	clarity_layer.bind(player, bot, arena_camera)

	var skill_feedback_layer = SkillFeedback3D.new()
	skill_feedback_layer.name = "SkillFeedback3D"
	combat_readability_root.add_child(skill_feedback_layer)
	skill_feedback_layer.bind(player)

	combat_hud = CombatHud.new()
	combat_hud.name = "CombatHud"
	presentation_root.add_child(combat_hud)
	combat_hud.bind(player, session_manager, game_context, game_loop)

	var feedback_layer = CombatFeedbackLayer.new()
	feedback_layer.name = "CombatFeedbackLayer"
	presentation_root.add_child(feedback_layer)
	feedback_layer.bind(player, bot, game_context, arena_camera)

	result_overlay = ResultOverlay.new()
	result_overlay.name = "ResultOverlay"
	presentation_root.add_child(result_overlay)
	result_overlay.bind(session_manager)
	if not session_manager.session_ended.is_connected(_on_session_ended):
		session_manager.session_ended.connect(_on_session_ended)

	_update_camera()

func _launch_context() -> Node:
	return get_node("/root/LaunchContext")

func _update_camera() -> void:
	if arena_camera == null or player == null:
		return

	var desired_focus: Vector3 = player.global_position + Vector3(0.0, 0.4, 0.0)
	arena_camera.global_basis = fixed_camera_basis
	arena_camera.global_position = desired_focus + CAMERA_OFFSET

func _on_combatant_impact(_combatant_id: StringName, health_damage: float, absorbed_amount: float, is_lethal: bool) -> void:
	var pause_duration: float = 0.0
	if is_lethal:
		pause_duration = 0.08
	elif health_damage > 0.0:
		pause_duration = 0.04
	elif absorbed_amount > 0.0:
		pause_duration = 0.02

	if pause_duration <= 0.0:
		return

	if player != null:
		player.request_motion_pause(pause_duration)
	if bot != null:
		bot.request_motion_pause(pause_duration)

func _on_session_ended(_result: Dictionary) -> void:
	if combat_hud != null:
		combat_hud.visible = false

func _configure_arena_walls() -> void:
	var walls_root: Node3D = _ensure_layout_root("ArenaWalls")
	var half_floor: float = FLOOR_SIZE.x * 0.5
	var wall_y: float = WALL_HEIGHT * 0.5
	var span: float = FLOOR_SIZE.x - 3.0

	_configure_box_structure(
		walls_root,
		"NorthWall",
		Vector3(0.0, wall_y, -half_floor + WALL_THICKNESS * 0.5),
		Vector3(span, WALL_HEIGHT, WALL_THICKNESS),
		Color(0.34, 0.4, 0.46, 1.0),
		Color(0.12, 0.14, 0.18, 1.0)
	)
	_configure_box_structure(
		walls_root,
		"SouthWall",
		Vector3(0.0, wall_y, half_floor - WALL_THICKNESS * 0.5),
		Vector3(span, WALL_HEIGHT, WALL_THICKNESS),
		Color(0.34, 0.4, 0.46, 1.0),
		Color(0.12, 0.14, 0.18, 1.0)
	)
	_configure_box_structure(
		walls_root,
		"WestWall",
		Vector3(-half_floor + WALL_THICKNESS * 0.5, wall_y, 0.0),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, span),
		Color(0.34, 0.4, 0.46, 1.0),
		Color(0.12, 0.14, 0.18, 1.0)
	)
	_configure_box_structure(
		walls_root,
		"EastWall",
		Vector3(half_floor - WALL_THICKNESS * 0.5, wall_y, 0.0),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, span),
		Color(0.34, 0.4, 0.46, 1.0),
		Color(0.12, 0.14, 0.18, 1.0)
	)

func _configure_arena_blocks() -> void:
	var blocks_root: Node3D = _ensure_layout_root("ArenaBlocks")
	var block_color: Color = Color(0.3, 0.35, 0.42, 1.0)
	var block_emission: Color = Color(0.1, 0.12, 0.16, 1.0)
	var block_y: float = INNER_BLOCK_HEIGHT * 0.5

	# Keep the central approach open so the simple bot can navigate naturally.
	_configure_box_structure(
		blocks_root,
		"BlockWestNorth",
		Vector3(-9.0, block_y, -6.4),
		Vector3(1.35, INNER_BLOCK_HEIGHT, 5.4),
		block_color,
		block_emission
	)
	_configure_box_structure(
		blocks_root,
		"BlockEastSouth",
		Vector3(9.0, block_y, 6.4),
		Vector3(1.35, INNER_BLOCK_HEIGHT, 5.4),
		block_color,
		block_emission
	)
	_configure_box_structure(
		blocks_root,
		"BlockEastNorth",
		Vector3(7.4, block_y, -10.0),
		Vector3(5.2, INNER_BLOCK_HEIGHT, 1.35),
		block_color,
		block_emission
	)
	_configure_box_structure(
		blocks_root,
		"BlockWestSouth",
		Vector3(-7.4, block_y, 10.0),
		Vector3(5.2, INNER_BLOCK_HEIGHT, 1.35),
		block_color,
		block_emission
	)

func _ensure_layout_root(node_name: String) -> Node3D:
	var existing_root: Node3D = get_node_or_null(node_name) as Node3D
	if existing_root != null:
		return existing_root

	var root: Node3D = Node3D.new()
	root.name = node_name
	add_child(root)
	return root

func _configure_box_structure(
	parent: Node3D,
	node_name: String,
	world_position: Vector3,
	size: Vector3,
	albedo: Color,
	emission: Color,
	rotation_y_degrees: float = 0.0
) -> void:
	var structure: StaticBody3D = parent.get_node_or_null(node_name) as StaticBody3D
	if structure == null:
		structure = StaticBody3D.new()
		structure.name = node_name
		parent.add_child(structure)

	structure.position = world_position
	structure.rotation_degrees = Vector3(0.0, rotation_y_degrees, 0.0)

	var collision_shape: CollisionShape3D = structure.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision_shape == null:
		collision_shape = CollisionShape3D.new()
		collision_shape.name = "CollisionShape3D"
		structure.add_child(collision_shape)
	var box_shape: BoxShape3D = collision_shape.shape as BoxShape3D
	if box_shape == null:
		box_shape = BoxShape3D.new()
		collision_shape.shape = box_shape
	box_shape.size = size

	var mesh_instance: MeshInstance3D = structure.get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "MeshInstance3D"
		structure.add_child(mesh_instance)
	var box_mesh: BoxMesh = mesh_instance.mesh as BoxMesh
	if box_mesh == null:
		box_mesh = BoxMesh.new()
		mesh_instance.mesh = box_mesh
	box_mesh.size = size

	var material: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		material.roughness = 0.86
		material.emission_enabled = true
		mesh_instance.material_override = material
	material.albedo_color = albedo
	material.emission = emission
	material.emission_energy_multiplier = 0.08

func _build_arena_ring_mesh(inner_radius: float, outer_radius: float, segments: int = 96) -> ArrayMesh:
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
