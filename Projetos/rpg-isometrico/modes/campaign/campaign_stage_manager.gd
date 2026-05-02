class_name CampaignStageManager
extends Node

const TrollEnemy = preload("res://gameplay/enemies/troll_enemy.gd")
const BossTrollController = preload("res://gameplay/boss/boss_troll_controller.gd")
const CampaignStageScene = preload("res://modes/campaign/campaign_stage_scene.gd")
const CampaignCatalogResource = preload("res://modes/campaign/campaign_catalog_resource.gd")
const CampaignRouteDefinitionResource = preload("res://modes/campaign/campaign_route_definition_resource.gd")
const CampaignStageReferenceResource = preload("res://modes/campaign/campaign_stage_reference_resource.gd")

signal enemy_spawned(enemy)
signal enemy_defeated(enemy_id: StringName, enemy)
signal stage_loaded(stage_number: int, stage_scene: CampaignStageScene)
signal stage_cleared(stage_number: int)
signal campaign_cleared()

const BLACKSMITH_CAMPAIGN_ID: StringName = &"blacksmith_campaign"
const EASY_DIFFICULTY_ID: StringName = &"easy"

var runtime_root: Node3D
var game_context
var player
var campaign_id: StringName = BLACKSMITH_CAMPAIGN_ID
var difficulty_id: StringName = EASY_DIFFICULTY_ID
var campaign_display_name: String = "Campanha do Troll"
var difficulty_label: String = "Classic - Easy"
var campaign_catalog: CampaignCatalogResource
var active_route: CampaignRouteDefinitionResource
var stage_references: Array[CampaignStageReferenceResource] = []
var active_stage_scene: CampaignStageScene
var active_stage_index: int = -1
var active_enemies: Dictionary = {}
var enemy_defeated_count: int = 0
var enemy_serial: int = 0
var current_objective_text: String = ""
var stage_clear_emitted: bool = false

static func load_generated_catalog() -> CampaignCatalogResource:
	return CampaignCatalogResource.load_generated()

static func resolve_route_definition(
	route_campaign_id: StringName,
	route_difficulty_id: StringName,
	catalog_override: CampaignCatalogResource = null
) -> CampaignRouteDefinitionResource:
	var resolved_catalog: CampaignCatalogResource = catalog_override if catalog_override != null else load_generated_catalog()
	if resolved_catalog == null:
		return null
	return resolved_catalog.find_route(route_campaign_id, route_difficulty_id)

static func get_route_stage_count(
	route_campaign_id: StringName,
	route_difficulty_id: StringName,
	catalog_override: CampaignCatalogResource = null
) -> int:
	var route: CampaignRouteDefinitionResource = resolve_route_definition(
		route_campaign_id,
		route_difficulty_id,
		catalog_override
	)
	return route.get_stage_count() if route != null else 0

func configure(
	next_runtime_root: Node3D,
	context,
	next_player,
	next_campaign_id: StringName,
	next_difficulty_id: StringName,
	next_campaign_catalog: CampaignCatalogResource = null
) -> void:
	runtime_root = next_runtime_root
	game_context = context
	player = next_player
	campaign_id = next_campaign_id if next_campaign_id != &"" else BLACKSMITH_CAMPAIGN_ID
	difficulty_id = next_difficulty_id if next_difficulty_id != &"" else EASY_DIFFICULTY_ID
	campaign_catalog = next_campaign_catalog if next_campaign_catalog != null else load_generated_catalog()
	active_route = resolve_route_definition(campaign_id, difficulty_id, campaign_catalog)
	stage_references.clear()
	if active_route != null:
		campaign_display_name = active_route.campaign_display_name if active_route.campaign_display_name != "" else "Campanha"
		difficulty_label = active_route.difficulty_label if active_route.difficulty_label != "" else "Dificuldade local"
		for stage_reference: CampaignStageReferenceResource in active_route.stage_references:
			if stage_reference != null:
				stage_references.append(stage_reference)
	else:
		campaign_display_name = "Campanha do Troll" if campaign_id == BLACKSMITH_CAMPAIGN_ID else "Campanha"
		difficulty_label = "Classic - Easy" if difficulty_id == EASY_DIFFICULTY_ID else "Dificuldade local"
	active_stage_scene = null
	active_stage_index = -1
	active_enemies.clear()
	enemy_defeated_count = 0
	enemy_serial = 0
	current_objective_text = ""
	stage_clear_emitted = false

func load_stage(stage_index: int) -> bool:
	clear_runtime()
	var stage_reference: CampaignStageReferenceResource = _get_stage_reference(stage_index)
	if stage_reference == null:
		return false

	var stage_scene_resource: PackedScene = load(stage_reference.scene_path)
	if stage_scene_resource == null:
		return false

	active_stage_scene = stage_scene_resource.instantiate() as CampaignStageScene
	if active_stage_scene == null:
		return false
	if active_stage_scene.stage_id != String(stage_reference.stage_id):
		active_stage_scene.queue_free()
		active_stage_scene = null
		return false
	if active_stage_scene.is_boss_stage != stage_reference.is_boss_stage:
		active_stage_scene.queue_free()
		active_stage_scene = null
		return false

	active_stage_index = stage_index
	active_stage_scene.name = "ActiveCampaignStage"
	runtime_root.add_child(active_stage_scene)
	current_objective_text = active_stage_scene.objective_text
	stage_clear_emitted = false
	enemy_serial = 0

	if player != null:
		player.global_position = active_stage_scene.get_player_spawn_position()
		player.reset_runtime_motion()

	_spawn_stage_enemies(active_stage_scene.get_enemy_specs())
	stage_loaded.emit(get_current_stage_number(), active_stage_scene)
	return true

func tick(_delta: float) -> void:
	_cleanup_stale_enemies()
	if active_stage_scene == null or stage_clear_emitted:
		return
	if get_enemy_count() > 0:
		return

	stage_clear_emitted = true
	var cleared_stage_number: int = get_current_stage_number()
	stage_cleared.emit(cleared_stage_number)
	if cleared_stage_number >= get_stage_count():
		campaign_cleared.emit()

func get_active_enemies() -> Array:
	_cleanup_stale_enemies()
	var enemies: Array = []
	for enemy: Variant in active_enemies.values():
		if is_instance_valid(enemy) and not enemy.is_dead:
			enemies.append(enemy)
	return enemies

func get_enemy_count() -> int:
	return get_active_enemies().size()

func get_stage_count() -> int:
	return stage_references.size()

func get_current_stage_index() -> int:
	return active_stage_index

func get_current_stage_number() -> int:
	return active_stage_index + 1 if active_stage_index >= 0 else 0

func get_current_stage_scene() -> CampaignStageScene:
	return active_stage_scene

func get_current_camera_offset() -> Vector3:
	return active_stage_scene.get_camera_offset() if active_stage_scene != null else Vector3(8.4, 18.8, 8.4)

func get_current_camera_size() -> float:
	return active_stage_scene.get_camera_size() if active_stage_scene != null else 15.6

func is_current_stage_boss() -> bool:
	var stage_reference: CampaignStageReferenceResource = _get_stage_reference(active_stage_index)
	if stage_reference != null:
		return stage_reference.is_boss_stage
	return active_stage_scene != null and active_stage_scene.is_boss_stage

func get_hud_snapshot() -> Dictionary:
	return {
		"campaign_id": String(campaign_id),
		"campaign_name": campaign_display_name,
		"difficulty_id": String(difficulty_id),
		"difficulty_label": difficulty_label,
		"stage_number": clampi(get_current_stage_number(), 1, maxi(1, get_stage_count())),
		"target_stage_count": get_stage_count(),
		"enemy_defeated_count": enemy_defeated_count,
		"enemies_alive": get_enemy_count(),
		"objective_text": current_objective_text,
		"state_label": "combate ativo",
		"stage_name": "" if active_stage_scene == null else active_stage_scene.display_name
	}

func clear_runtime() -> void:
	for enemy in get_active_enemies():
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()
	if active_stage_scene != null and is_instance_valid(active_stage_scene):
		active_stage_scene.queue_free()
	active_stage_scene = null
	stage_clear_emitted = false

func _spawn_stage_enemies(enemy_specs: Array[Dictionary]) -> void:
	for enemy_spec_variant: Variant in enemy_specs:
		var enemy_spec: Dictionary = Dictionary(enemy_spec_variant)
		var enemy_type: String = str(enemy_spec.get("enemy_type", "troll"))
		match enemy_type:
			"boss_troll":
				_spawn_boss_enemy(enemy_spec)
			_:
				_spawn_troll_enemy(enemy_spec)

func _spawn_troll_enemy(enemy_spec: Dictionary) -> void:
	var enemy_id: StringName = StringName("campaign_enemy_%d" % enemy_serial)
	enemy_serial += 1
	var enemy := TrollEnemy.new()
	enemy.name = "CampaignEnemy%d" % enemy_serial
	runtime_root.add_child(enemy)
	var spawn_position: Vector3 = enemy_spec.get("position", Vector3.ZERO)
	enemy.global_position = spawn_position
	enemy.configure(
		enemy_id,
		game_context,
		player,
		Dictionary(enemy_spec.get("config", {})).duplicate(true)
	)
	enemy.died.connect(_on_enemy_died.bind(enemy_id, enemy))
	active_enemies[String(enemy_id)] = enemy
	enemy_spawned.emit(enemy)

func _spawn_boss_enemy(enemy_spec: Dictionary) -> void:
	var boss_id: StringName = StringName(str(enemy_spec.get("boss_id", "boss_troll")))
	var boss := BossTrollController.new()
	boss.name = "CampaignBoss"
	runtime_root.add_child(boss)
	var spawn_position: Vector3 = enemy_spec.get("position", Vector3.ZERO)
	boss.global_position = spawn_position
	boss.configure(boss_id, game_context, player)
	boss.died.connect(_on_enemy_died.bind(boss_id, boss))
	active_enemies[String(boss_id)] = boss
	enemy_spawned.emit(boss)

func _on_enemy_died(enemy_id: StringName, enemy) -> void:
	active_enemies.erase(String(enemy_id))
	enemy_defeated_count += 1
	enemy_defeated.emit(enemy_id, enemy)
	if is_instance_valid(enemy):
		enemy.queue_free()

func _cleanup_stale_enemies() -> void:
	var stale_keys: Array[String] = []
	for key: Variant in active_enemies.keys():
		var enemy = active_enemies[key]
		if not is_instance_valid(enemy) or enemy.is_dead:
			stale_keys.append(str(key))
	for key: String in stale_keys:
		active_enemies.erase(key)

func _get_stage_reference(stage_index: int) -> CampaignStageReferenceResource:
	if stage_index < 0 or stage_index >= stage_references.size():
		return null
	return stage_references[stage_index]
