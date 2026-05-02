extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const ProfileStoreScript = preload("res://autoloads/profile_store.gd")
const ModeAvailabilityResolver = preload("res://gameplay/profile/mode_availability_resolver.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const CampaignRewardPayload = preload("res://gameplay/profile/campaign_reward_payload.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

func after_each() -> void:
	var profile_store = get_node_or_null("/root/ProfileStore")
	if profile_store != null:
		profile_store.clear_profile()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_default_profile_opens_campaign_and_arena_bot_while_keeping_survival_and_boss_locked() -> void:
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var profile = profile_store.load_profile()
	assert_false(profile.tutorial_completed)

	var campaign_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.CAMPAIGN_MODE_ID)
	var survival_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.SURVIVAL_MODE_ID)
	var boss_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.BOSS_MODE_ID)
	var arena_bot_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.ARENA_BOT_MODE_ID)
	var arena_pvp_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.ARENA_PVP_MODE_ID)
	assert_true(bool(campaign_state.get("unlocked", false)))
	assert_false(bool(survival_state.get("unlocked", false)))
	assert_false(bool(boss_state.get("unlocked", false)))
	assert_true(bool(arena_bot_state.get("unlocked", false)))
	assert_false(bool(arena_pvp_state.get("unlocked", false)))
	assert_true(LocalModeCatalog.is_public_menu_mode(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_true(LocalModeCatalog.is_public_menu_mode(LocalModeCatalog.ARENA_BOT_MODE_ID))
	assert_false(LocalModeCatalog.is_public_menu_mode(LocalModeCatalog.ARENA_PVP_MODE_ID))
	assert_false(LocalModeCatalog.get_public_menu_mode_ids().has(String(LocalModeCatalog.ARENA_PVP_MODE_ID)))
	assert_string_contains(str(survival_state.get("reason", "")), "Missao 1/tutorial")
	assert_eq(String(ModeAvailabilityResolver.get_first_available_local_mode_id(profile)), String(LocalModeCatalog.CAMPAIGN_MODE_ID))

	var dev_pvp_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(
		profile,
		LocalModeCatalog.ARENA_PVP_MODE_ID,
		true
	)
	assert_false(bool(dev_pvp_state.get("unlocked", false)))
	assert_string_contains(str(dev_pvp_state.get("reason", "")), "experimental")

func test_completing_tutorial_persists_unlocks_and_opens_survival() -> void:
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var profile = profile_store.complete_mandatory_tutorial()
	assert_true(profile.tutorial_completed)
	assert_true(profile.unlocked_race_ids.has("heroic"))
	assert_true(profile.unlocked_weapon_ids.has("heroic_hammer"))
	assert_true(profile.is_skill_unlocked(ProgressionResolver.TUTORIAL_SKILL_ID))
	assert_true(profile.is_skill_unlocked(ProgressionResolver.SECOND_SKILL_ID))
	assert_true(profile.is_potion_unlocked(ProgressionResolver.TUTORIAL_POTION_ID))

	var campaign_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.CAMPAIGN_MODE_ID)
	var survival_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.SURVIVAL_MODE_ID)
	var boss_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.BOSS_MODE_ID)
	assert_true(bool(campaign_state.get("unlocked", false)))
	assert_true(bool(survival_state.get("unlocked", false)))
	assert_false(bool(boss_state.get("unlocked", false)))
	assert_eq(String(ModeAvailabilityResolver.get_first_available_local_mode_id(profile)), String(LocalModeCatalog.CAMPAIGN_MODE_ID))

func test_campaign_completion_unlocks_boss_mode() -> void:
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	profile_store.complete_mandatory_tutorial()

	var profile = profile_store.complete_campaign(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy"
	)
	assert_true(profile.has_completed_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy"))

	var boss_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.BOSS_MODE_ID)
	assert_true(bool(boss_state.get("unlocked", false)))

func test_campaign_secondary_routes_stay_locked_until_easy_completion() -> void:
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	var profile = profile_store.load_profile()

	var easy_state: Dictionary = ModeAvailabilityResolver.get_campaign_route_state(
		profile,
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy"
	)
	var normal_state: Dictionary = ModeAvailabilityResolver.get_campaign_route_state(
		profile,
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"normal"
	)
	var free_state: Dictionary = ModeAvailabilityResolver.get_campaign_route_state(
		profile,
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID
	)
	assert_true(bool(easy_state.get("unlocked", false)))
	assert_false(bool(normal_state.get("unlocked", false)))
	assert_false(bool(free_state.get("unlocked", false)))
	assert_string_contains(str(normal_state.get("reason", "")), "Easy")
	assert_string_contains(str(free_state.get("reason", "")), "Classic - Easy")

	profile_store.complete_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy")
	var unlocked_profile = profile_store.load_profile()
	normal_state = ModeAvailabilityResolver.get_campaign_route_state(
		unlocked_profile,
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"normal"
	)
	free_state = ModeAvailabilityResolver.get_campaign_route_state(
		unlocked_profile,
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID
	)
	assert_true(bool(normal_state.get("unlocked", false)))
	assert_true(bool(free_state.get("unlocked", false)))
	assert_eq(str(free_state.get("tag", "")), "Replay livre")

func test_completing_normal_does_not_unlock_boss_without_easy() -> void:
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	profile_store.complete_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"normal")

	var profile = profile_store.load_profile()
	assert_true(profile.has_completed_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"normal"))
	assert_false(profile.has_completed_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy"))

	var boss_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.BOSS_MODE_ID)
	assert_false(bool(boss_state.get("unlocked", false)))

func test_campaign_stage_reward_payload_is_built_from_stage_scene_authorship() -> void:
	_generate_resources()
	var reward_payload: CampaignRewardPayload = _build_stage_reward_payload(1, 1)

	assert_eq(reward_payload.reward_id, "blacksmith_campaign:easy:mission_01")
	assert_eq(reward_payload.stage_number, 1)
	assert_eq(reward_payload.title, "Missao 1 defendida")
	assert_eq(reward_payload.next_level, 2)
	assert_eq(reward_payload.pending_level_increase, 1)
	assert_eq(reward_payload.pending_skill_points, 1)
	assert_eq(reward_payload.permanent_skill_unlock_ids, [String(ProgressionResolver.SECOND_SKILL_ID)])
	assert_eq(reward_payload.menu_unlock_mode_ids, [String(LocalModeCatalog.SURVIVAL_MODE_ID)])
	assert_eq(reward_payload.permanent_potion_unlock_ids, [])
	assert_true(reward_payload.marks_tutorial_completed)

	var overlay_lines: Array[String] = reward_payload.build_overlay_lines()
	assert_eq(overlay_lines[0], "Nivel 2 preparado para a proxima etapa da Campanha Classica.")
	assert_string_contains(overlay_lines[1], "habilidade")
	assert_string_contains(overlay_lines[2], "Survival")

func test_campaign_reward_payload_application_is_idempotent_by_reward_id() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var reward_payload: CampaignRewardPayload = _build_stage_reward_payload(1, 1)
	var profile = profile_store.apply_campaign_stage_completion(reward_payload)
	assert_true(profile.tutorial_completed)
	assert_true(profile.has_applied_reward(reward_payload.reward_id))
	assert_eq(profile.applied_reward_ids, [reward_payload.reward_id])

	var applied_again = profile_store.apply_campaign_stage_completion(reward_payload)
	assert_eq(applied_again.applied_reward_ids, [reward_payload.reward_id])
	assert_eq(applied_again.unlocked_skill_ids, profile.unlocked_skill_ids)
	assert_eq(applied_again.unlocked_potion_ids, profile.unlocked_potion_ids)
	assert_true(applied_again.tutorial_completed)

func test_campaign_normal_stage_rewards_keep_permanent_unlock_arrays_empty() -> void:
	_generate_resources()
	var stage_scene: PackedScene = load("res://modes/campaign/stages/campaign_mission_01_normal.tscn")
	assert_not_null(stage_scene)
	var stage_root = stage_scene.instantiate()
	assert_not_null(stage_root)
	add_child_autofree(stage_root)

	var reward_payload: CampaignRewardPayload = stage_root.build_reward_payload(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"normal",
		1
	)
	assert_eq(reward_payload.reward_id, "blacksmith_campaign:normal:mission_01")
	assert_false(reward_payload.marks_tutorial_completed)
	assert_eq(reward_payload.permanent_skill_unlock_ids, [])
	assert_eq(reward_payload.permanent_potion_unlock_ids, [])
	assert_eq(reward_payload.menu_unlock_mode_ids, [])

func _generate_resources() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

func _build_stage_reward_payload(stage_number: int, current_level: int) -> CampaignRewardPayload:
	var stage_scene: PackedScene = load("res://modes/campaign/stages/campaign_mission_%02d.tscn" % stage_number)
	assert_not_null(stage_scene)
	var stage_root = stage_scene.instantiate()
	assert_not_null(stage_root)
	add_child_autofree(stage_root)
	return stage_root.build_reward_payload(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy",
		current_level
	)
