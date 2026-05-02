class_name TutorialRoot
extends Node3D

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const GameContext = preload("res://gameplay/simulation/game_context.gd")
const PlayerController = preload("res://gameplay/player/player_controller.gd")
const TrollEnemy = preload("res://gameplay/enemies/troll_enemy.gd")

const HEROIC_RACE_ID: StringName = &"heroic"
const HEROIC_WEAPON_ID: StringName = &"heroic_hammer"
const TUTORIAL_SKILL_ID: StringName = &"blacksmith_hammer_throw"

const FLOOR_SIZE: Vector3 = Vector3(30.0, 1.0, 24.0)
const CAMERA_OFFSET: Vector3 = Vector3(7.8, 16.4, 7.8)
const CAMERA_SIZE: float = 12.4
const PLAYER_SPAWN_POSITION: Vector3 = Vector3(-6.0, 1.05, 0.0)

var world_environment: WorldEnvironment
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var tutorial_floor: StaticBody3D
var floor_collider: CollisionShape3D
var floor_mesh: MeshInstance3D
var tutorial_camera: Camera3D
var runtime_root: Node3D
var overlay_layer: CanvasLayer
var overlay_panel: PanelContainer
var title_label: Label
var body_label: Label

var game_context: GameContext
var player: PlayerController
var tutorial_loadout: LoadoutData
var tutorial_enemies: Array[TrollEnemy] = []
var skill_unlocked: bool = false
var tutorial_completed: bool = false
var return_after_completion_remaining: float = -1.0

func _ready() -> void:
	if not _profile_store().is_mandatory_tutorial_pending():
		get_tree().change_scene_to_file(LocalModeCatalog.FRONTEND_SCENE_PATH)
		return

	_content_library().ensure_loaded()
	_ensure_scene_scaffold()
	_configure_world()
	_build_runtime()
	_set_overlay_copy(
		"Campanha do Troll - Missao 1",
		"A forja foi invadida. Use WASD e clique esquerdo para afastar os trolls. Esta abertura authored apresenta combate, primeira habilidade e primeira pocao."
	)

func _process(delta: float) -> void:
	_update_camera()
	if return_after_completion_remaining <= 0.0:
		return

	return_after_completion_remaining = maxf(0.0, return_after_completion_remaining - delta)
	if return_after_completion_remaining == 0.0:
		get_tree().change_scene_to_file(LocalModeCatalog.FRONTEND_SCENE_PATH)

func complete_tutorial(perform_scene_change: bool = true) -> void:
	if tutorial_completed:
		return

	tutorial_completed = true
	_profile_store().complete_mandatory_tutorial()
	_set_overlay_copy(
		"Missao 1 concluida",
		"Survival agora fica liberado no menu. A Campanha do Troll continua aberta para a proxima etapa, e Boss segue bloqueado ate o fim da rota."
	)

	if perform_scene_change:
		return_after_completion_remaining = 1.2

func debug_complete_tutorial_for_test() -> void:
	complete_tutorial(false)

func _ensure_scene_scaffold() -> void:
	world_environment = _ensure_world_environment("WorldEnvironment")
	key_light = _ensure_directional_light("KeyLight")
	fill_light = _ensure_omni_light("FillLight")
	tutorial_floor = _ensure_floor("TutorialFloor")
	floor_collider = _ensure_collision_shape(tutorial_floor, "CollisionShape3D")
	floor_mesh = _ensure_mesh_instance(tutorial_floor, "FloorMesh")
	tutorial_camera = _ensure_camera("TutorialCamera")
	runtime_root = _ensure_node3d("RuntimeRoot")
	overlay_layer = _ensure_canvas_layer("OverlayLayer")
	overlay_panel = _ensure_panel(overlay_layer, "OverlayPanel")
	title_label = _ensure_label(overlay_panel, "TitleLabel")
	body_label = _ensure_label(overlay_panel, "BodyLabel")

func _configure_world() -> void:
	var environment_resource: Environment = Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color(0.07, 0.06, 0.05, 1.0)
	environment_resource.ambient_light_color = Color(0.92, 0.88, 0.8, 1.0)
	environment_resource.ambient_light_energy = 1.08
	world_environment.environment = environment_resource

	key_light.rotation_degrees = Vector3(-54.0, -38.0, 0.0)
	key_light.light_energy = 2.35
	key_light.shadow_enabled = true

	fill_light.position = Vector3(0.0, 6.0, 0.0)
	fill_light.light_energy = 1.45
	fill_light.omni_range = 30.0

	tutorial_floor.position = Vector3(0.0, -0.5, 0.0)
	var floor_shape: BoxShape3D = BoxShape3D.new()
	floor_shape.size = FLOOR_SIZE
	floor_collider.shape = floor_shape

	var tutorial_mesh: BoxMesh = BoxMesh.new()
	tutorial_mesh.size = FLOOR_SIZE
	floor_mesh.mesh = tutorial_mesh
	var floor_material: StandardMaterial3D = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.22, 0.18, 0.14, 1.0)
	floor_material.roughness = 0.9
	floor_material.emission_enabled = true
	floor_material.emission = Color(0.08, 0.05, 0.03, 1.0)
	floor_material.emission_energy_multiplier = 0.14
	floor_mesh.material_override = floor_material

	tutorial_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	tutorial_camera.size = CAMERA_SIZE
	tutorial_camera.global_position = CAMERA_OFFSET
	tutorial_camera.look_at(Vector3(0.0, 0.3, 0.0), Vector3.UP)
	tutorial_camera.current = true

	overlay_panel.anchor_left = 0.0
	overlay_panel.anchor_top = 0.0
	overlay_panel.anchor_right = 0.0
	overlay_panel.anchor_bottom = 0.0
	overlay_panel.offset_left = 24.0
	overlay_panel.offset_top = 24.0
	overlay_panel.offset_right = 440.0
	overlay_panel.offset_bottom = 188.0
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.09, 0.92)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.78, 0.46, 0.22, 0.38)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.corner_radius_bottom_left = 12
	overlay_panel.add_theme_stylebox_override("panel", panel_style)

	title_label.position = Vector2(18.0, 16.0)
	title_label.size = Vector2(396.0, 28.0)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.modulate = Color(0.98, 0.86, 0.72, 1.0)

	body_label.position = Vector2(18.0, 56.0)
	body_label.size = Vector2(396.0, 110.0)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.modulate = Color(0.9, 0.9, 0.92, 1.0)

func _build_runtime() -> void:
	game_context = GameContext.new()
	game_context.name = "GameContext"
	runtime_root.add_child(game_context)
	game_context.reset_round()

	tutorial_loadout = _build_tutorial_loadout()

	player = PlayerController.new()
	player.name = "Player"
	player.position = PLAYER_SPAWN_POSITION
	runtime_root.add_child(player)
	player.configure(tutorial_loadout, game_context)
	player.arena_camera = tutorial_camera

	_spawn_tutorial_enemy(&"tutorial_troll_a", Vector3(2.8, 1.05, -2.0), 32.0, 8.0, 2.9)
	_spawn_tutorial_enemy(&"tutorial_troll_b", Vector3(5.2, 1.05, 2.4), 46.0, 10.0, 3.0)
	_refresh_player_targets()

func _spawn_tutorial_enemy(enemy_id: StringName, spawn_position: Vector3, max_health: float, attack_damage: float, move_speed: float) -> void:
	var enemy := TrollEnemy.new()
	enemy.name = String(enemy_id).capitalize()
	enemy.position = spawn_position
	runtime_root.add_child(enemy)
	enemy.configure(enemy_id, game_context, player, {
		"max_health": max_health,
		"attack_damage": attack_damage,
		"move_speed": move_speed,
		"attack_cooldown": 1.35,
		"attack_windup": 0.64,
		"attack_recovery": 0.48,
		"body_scale": 1.0
	})
	enemy.died.connect(_on_tutorial_enemy_died.bind(enemy))
	tutorial_enemies.append(enemy)

func _on_tutorial_enemy_died(_enemy: TrollEnemy) -> void:
	_refresh_player_targets()
	var alive_count: int = _count_alive_enemies()
	if not skill_unlocked and alive_count == 1:
		_unlock_first_skill()
		return

	if alive_count == 0:
		complete_tutorial()

func _unlock_first_skill() -> void:
	if skill_unlocked:
		return

	skill_unlocked = true
	var hammer_throw: SkillDefinitionResource = _content_library().get_skill(TUTORIAL_SKILL_ID)
	if hammer_throw != null:
		tutorial_loadout.skills.append(hammer_throw)
	_set_overlay_copy(
		"Arremesso de Martelo liberado",
		"O ferreiro recuperou seu primeiro poder. Pressione Q para arremessar o martelo e terminar de defender a forja."
	)

func _build_tutorial_loadout() -> LoadoutData:
	var loadout := LoadoutData.new()
	loadout.race = _content_library().get_race(HEROIC_RACE_ID)

	var base_weapon: WeaponDefinitionResource = _content_library().get_weapon(HEROIC_WEAPON_ID)
	if base_weapon != null:
		var tutorial_weapon = base_weapon.duplicate(true)
		if tutorial_weapon is WeaponDefinitionResource:
			tutorial_weapon.display_name = "Martelo do Ferreiro"
			tutorial_weapon.dash_distance = 0.0
			tutorial_weapon.dash_cooldown = 99.0
			loadout.weapon = tutorial_weapon

	loadout.skills = []
	loadout.potions = []
	return loadout

func _refresh_player_targets() -> void:
	var first_alive_enemy: TrollEnemy = null
	var additional_targets: Array = []
	for enemy: TrollEnemy in tutorial_enemies:
		if enemy == null or not is_instance_valid(enemy) or enemy.is_dead:
			continue
		if first_alive_enemy == null:
			first_alive_enemy = enemy
		else:
			additional_targets.append(enemy)

	player.target = first_alive_enemy
	player.set_additional_targets(additional_targets)

func _count_alive_enemies() -> int:
	var alive_count: int = 0
	for enemy: TrollEnemy in tutorial_enemies:
		if enemy != null and is_instance_valid(enemy) and not enemy.is_dead:
			alive_count += 1
	return alive_count

func _set_overlay_copy(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body

func _update_camera() -> void:
	if tutorial_camera == null or player == null:
		return

	var desired_focus: Vector3 = player.global_position + Vector3(0.0, 0.35, 0.0)
	tutorial_camera.global_position = desired_focus + CAMERA_OFFSET
	tutorial_camera.look_at(desired_focus, Vector3.UP)

func _content_library() -> Node:
	return get_node("/root/ContentLibrary")

func _profile_store() -> Node:
	return get_node("/root/ProfileStore")

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

func _ensure_mesh_instance(parent: Node, node_name: String) -> MeshInstance3D:
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

func _ensure_canvas_layer(node_name: String) -> CanvasLayer:
	var existing: CanvasLayer = get_node_or_null(node_name) as CanvasLayer
	if existing != null:
		return existing
	var created := CanvasLayer.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_panel(parent: Node, node_name: String) -> PanelContainer:
	var existing: PanelContainer = parent.get_node_or_null(node_name) as PanelContainer
	if existing != null:
		return existing
	var created := PanelContainer.new()
	created.name = node_name
	parent.add_child(created)
	return created

func _ensure_label(parent: Node, node_name: String) -> Label:
	var existing: Label = parent.get_node_or_null(node_name) as Label
	if existing != null:
		return existing
	var created := Label.new()
	created.name = node_name
	parent.add_child(created)
	return created
