extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

func after_each() -> void:
	var launch_context = get_node_or_null("/root/LaunchContext")
	if launch_context != null:
		launch_context.clear_pending_mode_launch()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_launch_context_sanitizes_mode_specific_parameters() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var loadout = _build_valid_loadout()
	var launch_context = get_node("/root/LaunchContext")
	var launch_result: Dictionary = launch_context.set_pending_mode_launch(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		loadout,
		{
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy",
			"ignored_key": "should_not_survive"
		}
	)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))
	assert_true(launch_context.has_pending_mode_launch(LocalModeCatalog.CAMPAIGN_MODE_ID))

	var request = launch_context.consume_pending_mode_launch()
	assert_not_null(request)
	assert_eq(String(request.mode_id), String(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_eq(request.scene_path, LocalModeCatalog.get_scene_path(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_eq(String(request.get_campaign_id()), "blacksmith_campaign")
	assert_eq(String(request.get_campaign_difficulty_id()), "easy")
	assert_false(request.parameters.has("ignored_key"))
	assert_no_new_orphans()

func test_launch_context_consumes_sequential_mode_requests_without_stale_parameters() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var loadout = _build_valid_loadout()
	var launch_context = get_node("/root/LaunchContext")

	var campaign_launch: Dictionary = launch_context.set_pending_mode_launch(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		loadout,
		{
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy"
		}
	)
	assert_true(bool(campaign_launch.get("ok", false)), str(campaign_launch.get("message", "")))
	var campaign_request = launch_context.consume_pending_mode_launch()
	assert_not_null(campaign_request)
	assert_eq(String(campaign_request.mode_id), String(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_eq(String(campaign_request.get_campaign_id()), "blacksmith_campaign")
	assert_eq(String(campaign_request.get_campaign_difficulty_id()), "easy")
	assert_false(campaign_request.parameters.has("start_wave"))
	assert_false(campaign_request.parameters.has("boss_id"))
	assert_false(campaign_request.parameters.has("opponent_id"))
	assert_false(launch_context.has_pending_mode_launch())

	var survival_launch: Dictionary = launch_context.set_pending_mode_launch(
		LocalModeCatalog.SURVIVAL_MODE_ID,
		loadout,
		{"start_wave": 3}
	)
	assert_true(bool(survival_launch.get("ok", false)), str(survival_launch.get("message", "")))
	var survival_request = launch_context.consume_pending_mode_launch()
	assert_not_null(survival_request)
	assert_eq(String(survival_request.mode_id), String(LocalModeCatalog.SURVIVAL_MODE_ID))
	assert_eq(survival_request.get_survival_start_wave(), 3)
	assert_false(survival_request.parameters.has("opponent_id"))
	assert_false(survival_request.parameters.has("boss_id"))
	assert_false(survival_request.parameters.has("campaign_id"))
	assert_false(launch_context.has_pending_mode_launch())

	var boss_launch: Dictionary = launch_context.set_pending_mode_launch(
		LocalModeCatalog.BOSS_MODE_ID,
		loadout,
		{"boss_id": "boss_troll"}
	)
	assert_true(bool(boss_launch.get("ok", false)), str(boss_launch.get("message", "")))
	var boss_request = launch_context.consume_pending_mode_launch()
	assert_not_null(boss_request)
	assert_eq(String(boss_request.mode_id), String(LocalModeCatalog.BOSS_MODE_ID))
	assert_eq(String(boss_request.get_boss_id()), "boss_troll")
	assert_false(boss_request.parameters.has("opponent_id"))
	assert_false(boss_request.parameters.has("start_wave"))
	assert_false(boss_request.parameters.has("campaign_id"))
	assert_false(launch_context.has_pending_mode_launch())
	assert_no_new_orphans()

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
