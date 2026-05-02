extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const GameContext = preload("res://gameplay/simulation/game_context.gd")
const PlayerController = preload("res://gameplay/player/player_controller.gd")
const CampaignCatalogResource = preload("res://modes/campaign/campaign_catalog_resource.gd")
const CampaignRouteDefinitionResource = preload("res://modes/campaign/campaign_route_definition_resource.gd")
const CampaignStageReferenceResource = preload("res://modes/campaign/campaign_stage_reference_resource.gd")
const CampaignStageManager = preload("res://modes/campaign/campaign_stage_manager.gd")

func after_each() -> void:
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_stage_manager_resolves_generated_campaign_route_metadata() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var runtime_root: Node3D = _build_runtime_root()
	var stage_manager := CampaignStageManager.new()
	stage_manager.name = "StageManager"
	runtime_root.add_child(stage_manager)
	stage_manager.configure(
		runtime_root,
		runtime_root.get_node("GameContext"),
		runtime_root.get_node("Player"),
		&"blacksmith_campaign",
		&"easy"
	)

	assert_eq(stage_manager.campaign_display_name, "Campanha do Troll")
	assert_eq(stage_manager.difficulty_label, "Classic - Easy")
	assert_eq(stage_manager.get_stage_count(), 5)
	assert_true(stage_manager.load_stage(0))
	assert_eq(stage_manager.get_current_stage_scene().stage_id, "mission_01")
	assert_false(stage_manager.is_current_stage_boss())
	assert_true(stage_manager.load_stage(4))
	assert_eq(stage_manager.get_current_stage_scene().stage_id, "mission_05")
	assert_true(stage_manager.is_current_stage_boss())
	assert_no_new_orphans()

func test_campaign_catalog_returns_easy_normal_then_free_for_blacksmith_campaign() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var catalog: CampaignCatalogResource = CampaignCatalogResource.load_generated()
	assert_not_null(catalog)

	var routes: Array[CampaignRouteDefinitionResource] = catalog.get_routes_for_campaign(&"blacksmith_campaign")
	assert_eq(routes.size(), 3)
	assert_eq(String(routes[0].difficulty_id), "easy")
	assert_eq(String(routes[1].difficulty_id), "normal")
	assert_eq(String(routes[2].difficulty_id), "free")
	assert_eq(routes[1].difficulty_label, "Classic - Normal")
	assert_eq(routes[2].difficulty_label, "Livre")

func test_stage_manager_accepts_synthetic_catalog_route_order() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var synthetic_catalog := CampaignCatalogResource.new()
	var synthetic_route := CampaignRouteDefinitionResource.new()
	synthetic_route.campaign_id = &"synthetic_campaign"
	synthetic_route.difficulty_id = &"debug"
	synthetic_route.campaign_display_name = "Campanha Sintetica"
	synthetic_route.difficulty_label = "Debug"
	synthetic_route.stage_references = [
		_build_stage_reference("mission_01", "res://modes/campaign/stages/campaign_mission_01.tscn", false),
		_build_stage_reference("mission_03", "res://modes/campaign/stages/campaign_mission_03.tscn", false),
		_build_stage_reference("mission_02", "res://modes/campaign/stages/campaign_mission_02.tscn", false),
		_build_stage_reference("mission_04", "res://modes/campaign/stages/campaign_mission_04.tscn", false),
		_build_stage_reference("mission_05", "res://modes/campaign/stages/campaign_mission_05.tscn", true),
	]
	synthetic_catalog.entries = [synthetic_route]

	var runtime_root: Node3D = _build_runtime_root()
	var stage_manager := CampaignStageManager.new()
	stage_manager.name = "StageManager"
	runtime_root.add_child(stage_manager)
	stage_manager.configure(
		runtime_root,
		runtime_root.get_node("GameContext"),
		runtime_root.get_node("Player"),
		&"synthetic_campaign",
		&"debug",
		synthetic_catalog
	)

	assert_eq(stage_manager.get_stage_count(), 5)
	assert_eq(str(stage_manager.get_hud_snapshot().get("campaign_name", "")), "Campanha Sintetica")
	assert_eq(str(stage_manager.get_hud_snapshot().get("difficulty_label", "")), "Debug")
	for stage_index: int in range(5):
		assert_true(stage_manager.load_stage(stage_index))
		assert_eq(
			stage_manager.get_current_stage_scene().stage_id,
			String(synthetic_route.stage_references[stage_index].stage_id)
		)
		assert_eq(stage_manager.is_current_stage_boss(), synthetic_route.stage_references[stage_index].is_boss_stage)
	assert_no_new_orphans()

func _build_runtime_root() -> Node3D:
	var runtime_root := Node3D.new()
	runtime_root.name = "RuntimeRoot"
	add_child_autofree(runtime_root)

	var game_context := GameContext.new()
	game_context.name = "GameContext"
	runtime_root.add_child(game_context)
	game_context.reset_round()

	var player := PlayerController.new()
	player.name = "Player"
	runtime_root.add_child(player)
	player.configure(_build_valid_loadout(), game_context)
	return runtime_root

func _build_stage_reference(stage_id: String, scene_path: String, is_boss_stage: bool) -> CampaignStageReferenceResource:
	var stage_reference := CampaignStageReferenceResource.new()
	stage_reference.stage_id = StringName(stage_id)
	stage_reference.scene_path = scene_path
	stage_reference.is_boss_stage = is_boss_stage
	return stage_reference

func _build_valid_loadout():
	var library = get_node("/root/ContentLibrary")
	library.reload()
	var races = library.get_races()
	assert_eq(races.size(), 1)

	var race = races[0]
	var weapon = library.get_weapons_for_race(race.id)[0]
	var skills = library.get_skills_for_weapon(race.id, weapon.id)
	var potions = library.get_potions_for_race(race.id)
	return library.build_loadout_from_ids(
		race.id,
		weapon.id,
		PackedStringArray([
			String(skills[0].id),
			String(skills[1].id),
			String(skills[2].id),
			String(skills[3].id)
		]),
		PackedStringArray([
			String(potions[0].id),
			String(potions[1].id)
		])
	)
