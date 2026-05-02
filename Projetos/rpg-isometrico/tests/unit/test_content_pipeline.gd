extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const RaceCatalogResource = preload("res://gameplay/content/race_catalog_resource.gd")
const WeaponCatalogResource = preload("res://gameplay/content/weapon_catalog_resource.gd")
const SkillCatalogResource = preload("res://gameplay/content/skill_catalog_resource.gd")
const PotionCatalogResource = preload("res://gameplay/content/potion_catalog_resource.gd")
const CampaignCatalogResource = preload("res://modes/campaign/campaign_catalog_resource.gd")
const CampaignStageScene = preload("res://modes/campaign/campaign_stage_scene.gd")

func after_each() -> void:
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_generation_builds_catalogs_and_bootstrap_scenes() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var race_catalog: RaceCatalogResource = load("res://resources/generated/catalogs/race_catalog.tres")
	var weapon_catalog: WeaponCatalogResource = load("res://resources/generated/catalogs/weapon_catalog.tres")
	var skill_catalog: SkillCatalogResource = load("res://resources/generated/catalogs/skill_catalog.tres")
	var potion_catalog: PotionCatalogResource = load("res://resources/generated/catalogs/potion_catalog.tres")
	var campaign_catalog: CampaignCatalogResource = load("res://resources/generated/catalogs/campaign_catalog.tres")

	assert_not_null(race_catalog)
	assert_not_null(weapon_catalog)
	assert_not_null(skill_catalog)
	assert_not_null(potion_catalog)
	assert_not_null(campaign_catalog)

	assert_eq(race_catalog.entries.size(), 1)
	assert_eq(weapon_catalog.entries.size(), 1)
	assert_eq(skill_catalog.entries.size(), 5)
	assert_eq(potion_catalog.entries.size(), 2)
	assert_eq(campaign_catalog.entries.size(), 3)

	_assert_campaign_route(
		campaign_catalog.find_route(&"blacksmith_campaign", &"easy"),
		"Classic - Easy",
		"campaign_mission_%02d.tscn"
	)
	_assert_campaign_route(
		campaign_catalog.find_route(&"blacksmith_campaign", &"normal"),
		"Classic - Normal",
		"campaign_mission_%02d_normal.tscn"
	)
	_assert_campaign_route(
		campaign_catalog.find_route(&"blacksmith_campaign", &"free"),
		"Livre",
		"campaign_mission_%02d.tscn"
	)

	var boot_scene: PackedScene = load("res://modes/boot/boot.tscn")
	var frontend_scene: PackedScene = load("res://modes/frontend/frontend.tscn")
	var tutorial_scene: PackedScene = load("res://modes/tutorial/tutorial.tscn")
	var campaign_scene: PackedScene = load("res://modes/campaign/campaign.tscn")
	var arena_scene: PackedScene = load("res://modes/arena/arena.tscn")
	var survival_scene: PackedScene = load("res://modes/survival/survival.tscn")
	var boss_scene: PackedScene = load("res://modes/boss/boss.tscn")
	assert_not_null(boot_scene)
	assert_not_null(frontend_scene)
	assert_not_null(tutorial_scene)
	assert_not_null(campaign_scene)
	assert_not_null(arena_scene)
	assert_not_null(survival_scene)
	assert_not_null(boss_scene)

	var boot: Node = boot_scene.instantiate()
	var frontend: Node = frontend_scene.instantiate()
	var tutorial: Node = tutorial_scene.instantiate()
	var campaign: Node = campaign_scene.instantiate()
	var arena: Node = arena_scene.instantiate()
	var survival: Node = survival_scene.instantiate()
	var boss: Node = boss_scene.instantiate()
	add_child_autofree(tutorial)
	await get_tree().process_frame
	assert_eq(boot.name, "Boot")
	assert_eq(frontend.name, "Frontend")
	assert_eq(tutorial.name, "Tutorial")
	assert_eq(campaign.name, "Campaign")
	assert_eq(arena.name, "Arena")
	assert_eq(survival.name, "Survival")
	assert_eq(boss.name, "Boss")
	assert_not_null(boot.get_node_or_null("StatusLabel"))
	assert_not_null(frontend.get_node_or_null("PageMargin/MainLayout/InfoPanel"))
	assert_not_null(frontend.get_node_or_null("PageMargin/MainLayout/LoadoutPanel"))
	assert_not_null(frontend.get_node_or_null("PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/ActionRow"))
	assert_not_null(frontend.get_node_or_null("PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SelectionScroll"))
	assert_not_null(tutorial.get_node_or_null("WorldEnvironment"))
	assert_not_null(tutorial.get_node_or_null("RuntimeRoot"))
	assert_not_null(tutorial.get_node_or_null("OverlayLayer/OverlayPanel/TitleLabel"))
	assert_not_null(arena.get_node_or_null("WorldEnvironment"))
	assert_not_null(arena.get_node_or_null("ArenaFloor"))
	assert_not_null(arena.get_node_or_null("ArenaCamera"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot"))
	assert_not_null(arena.get_node_or_null("PresentationRoot"))
	boot.free()
	frontend.free()
	campaign.free()
	arena.free()
	survival.free()
	boss.free()
	assert_no_new_orphans()

func _assert_campaign_route(route, expected_difficulty_label: String, scene_pattern: String) -> void:
	assert_not_null(route)
	assert_eq(route.campaign_display_name, "Campanha do Troll")
	assert_eq(route.difficulty_label, expected_difficulty_label)
	assert_eq(route.stage_references.size(), 5)
	for stage_index: int in range(5):
		var stage_reference = route.stage_references[stage_index]
		assert_eq(String(stage_reference.stage_id), "mission_%02d" % (stage_index + 1))
		assert_eq(
			stage_reference.scene_path,
			"res://modes/campaign/stages/%s" % (scene_pattern % (stage_index + 1))
		)
		assert_eq(stage_reference.is_boss_stage, stage_index == 4)
		var stage_scene_resource: PackedScene = load(stage_reference.scene_path)
		assert_not_null(stage_scene_resource)
		var stage_scene: CampaignStageScene = stage_scene_resource.instantiate() as CampaignStageScene
		assert_not_null(stage_scene)
		assert_eq(stage_scene.stage_id, String(stage_reference.stage_id))
		assert_eq(stage_scene.is_boss_stage, stage_reference.is_boss_stage)
		stage_scene.free()
