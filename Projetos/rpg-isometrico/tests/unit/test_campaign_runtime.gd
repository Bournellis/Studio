extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const ModeAvailabilityResolver = preload("res://gameplay/profile/mode_availability_resolver.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

func after_each() -> void:
	var launch_context = get_node_or_null("/root/LaunchContext")
	if launch_context != null:
		launch_context.clear_pending_mode_launch()
	var profile_store = get_node_or_null("/root/ProfileStore")
	if profile_store != null:
		profile_store.clear_profile()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_campaign_runtime_unlocks_progression_through_five_maps_and_finishes_with_boss_unlock() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var loadout = _build_valid_loadout()
	var launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		loadout,
		{
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy"
		}
	)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))

	var scene: PackedScene = load(LocalModeCatalog.get_scene_path(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_not_null(scene)

	var root: Node3D = scene.instantiate()
	add_child_autofree(root)
	await get_tree().process_frame
	await get_tree().process_frame

	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	var stage_manager = root.get_node("RuntimeRoot/StageManager")
	var player = root.get_node("RuntimeRoot/Player")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	assert_true(await _wait_for_flow_kind(root, "stage_briefing", 2.0))
	var briefing_overlay: CanvasLayer = root.get_node("PresentationRoot/CampaignFlowOverlay")
	var briefing_eyebrow_label: Label = briefing_overlay.find_child("EyebrowLabel", true, false)
	var briefing_body_label: Label = briefing_overlay.find_child("BodyLabel", true, false)
	assert_not_null(briefing_eyebrow_label)
	assert_not_null(briefing_body_label)
	assert_eq(briefing_eyebrow_label.text, "CAMPANHA CLASSICA")
	assert_string_contains(briefing_body_label.text, "Etapa 1/5")
	assert_string_contains(briefing_body_label.text, "nao precisa montar um kit completo")
	assert_true(root.debug_continue_flow_overlay())
	assert_true(await _wait_for_flow_kind(root, "tutorial_skill", 2.0))
	assert_true(root.debug_trigger_prompt_action())
	await get_tree().process_frame
	assert_eq(root.debug_get_active_flow_kind(), "")

	var profile = profile_store.load_profile()
	assert_true(profile.is_skill_unlocked(ProgressionResolver.TUTORIAL_SKILL_ID))

	player.take_damage(player.max_health * 0.45, &"test")
	await get_tree().process_frame
	assert_true(await _wait_for_flow_kind(root, "tutorial_potion", 2.0))
	assert_true(root.debug_trigger_prompt_action())
	await get_tree().process_frame
	assert_eq(root.debug_get_active_flow_kind(), "")

	profile = profile_store.load_profile()
	assert_true(profile.is_potion_unlocked(ProgressionResolver.TUTORIAL_POTION_ID))

	assert_true(await _clear_campaign_stage(stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(root, "reward", 2.0))
	var pending_reward_payload: Dictionary = Dictionary(root.debug_get_run_state().get("reward_payload", {}))
	var flow_overlay: CanvasLayer = root.get_node("PresentationRoot/CampaignFlowOverlay")
	var reward_body_label: Label = flow_overlay.find_child("BodyLabel", true, false)
	var reward_eyebrow_label: Label = flow_overlay.find_child("EyebrowLabel", true, false)
	var footer_hint_label: Label = flow_overlay.find_child("FooterHintLabel", true, false)
	assert_eq(str(pending_reward_payload.get("reward_id", "")), "blacksmith_campaign:easy:mission_01")
	assert_eq(str(pending_reward_payload.get("title", "")), "Missao 1 defendida")
	assert_eq(int(pending_reward_payload.get("next_level", 0)), 2)
	assert_true(bool(pending_reward_payload.get("marks_tutorial_completed", false)))
	assert_eq(
		Array(pending_reward_payload.get("permanent_skill_unlock_ids", [])),
		[String(ProgressionResolver.SECOND_SKILL_ID)]
	)
	assert_eq(
		Array(pending_reward_payload.get("menu_unlock_mode_ids", [])),
		[String(LocalModeCatalog.SURVIVAL_MODE_ID)]
	)
	assert_true(flow_overlay.visible)
	assert_not_null(reward_body_label)
	assert_not_null(reward_eyebrow_label)
	assert_not_null(footer_hint_label)
	assert_eq(reward_eyebrow_label.text, "AVANCO DA CAMPANHA")
	assert_string_contains(reward_body_label.text, "Nivel 2")
	assert_string_contains(reward_body_label.text, "Brado dos Imortais")
	assert_string_contains(reward_body_label.text, "Survival")
	assert_string_contains(footer_hint_label.text, "Continue")
	assert_true(root.debug_continue_flow_overlay())
	assert_true(await _wait_for_flow_kind(root, "level_up", 2.0))
	assert_true(root.debug_apply_first_level_up_option())
	await get_tree().process_frame
	assert_eq(int(root.debug_get_run_state().get("current_level", 0)), 2)
	assert_eq(int(root.debug_get_run_state().get("current_stage_index", -1)), 1)

	assert_true(await _clear_campaign_stage(stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(root, "reward", 2.0))
	assert_true(root.debug_continue_flow_overlay())
	assert_true(await _wait_for_flow_kind(root, "level_up", 2.0))
	assert_true(root.debug_apply_first_level_up_option())
	await get_tree().process_frame
	assert_eq(int(root.debug_get_run_state().get("current_level", 0)), 3)
	assert_eq(int(root.debug_get_run_state().get("current_stage_index", -1)), 2)

	assert_true(await _clear_campaign_stage(stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(root, "reward", 2.0))
	assert_true(root.debug_continue_flow_overlay())
	assert_true(await _wait_for_flow_kind(root, "level_up", 2.0))
	assert_true(root.debug_apply_first_level_up_option())
	await get_tree().process_frame
	assert_eq(int(root.debug_get_run_state().get("current_level", 0)), 4)
	assert_eq(int(root.debug_get_run_state().get("current_stage_index", -1)), 3)

	assert_true(await _clear_campaign_stage(stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(root, "reward", 2.0))
	assert_true(root.debug_continue_flow_overlay())
	assert_true(await _wait_for_flow_kind(root, "level_up", 2.0))
	assert_true(root.debug_apply_first_level_up_option())
	await get_tree().process_frame
	assert_eq(int(root.debug_get_run_state().get("current_level", 0)), 5)
	assert_eq(int(root.debug_get_run_state().get("current_stage_index", -1)), 4)
	assert_eq(Array(root.debug_get_run_state().get("equipped_potion_ids", []))[1], String(ProgressionResolver.BARRIER_POTION_ID))

	assert_true(await _clear_campaign_stage(stage_manager, 8.0))
	assert_true(await wait_for_signal(session_manager.session_ended, 5.0))
	await get_tree().process_frame

	profile = profile_store.load_profile()
	assert_true(profile.tutorial_completed)
	assert_true(profile.is_skill_unlocked(ProgressionResolver.SECOND_SKILL_ID))
	assert_true(profile.is_skill_unlocked(ProgressionResolver.THIRD_SKILL_ID))
	assert_true(profile.is_skill_unlocked(ProgressionResolver.FOURTH_SKILL_ID))
	assert_true(profile.is_potion_unlocked(ProgressionResolver.BARRIER_POTION_ID))
	assert_true(profile.has_applied_reward("blacksmith_campaign:easy:mission_01"))
	assert_true(profile.has_applied_reward("blacksmith_campaign:easy:mission_02"))
	assert_true(profile.has_applied_reward("blacksmith_campaign:easy:mission_03"))
	assert_true(profile.has_applied_reward("blacksmith_campaign:easy:mission_04"))
	assert_true(profile.has_completed_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy"))
	var boss_state: Dictionary = ModeAvailabilityResolver.get_local_mode_state(profile, LocalModeCatalog.BOSS_MODE_ID)
	assert_true(bool(boss_state.get("unlocked", false)))

	var overlay = root.get_node("PresentationRoot/ResultOverlay")
	assert_true((overlay as CanvasLayer).visible)
	assert_eq(str(overlay.eyebrow_label.text), "RESULTADO DA CAMPANHA")
	assert_eq(str(overlay.return_button.text), "Voltar a Campanha e Extras")
	assert_string_contains(str(overlay.details_label.text), "Campanha do Troll:")
	assert_string_contains(str(overlay.details_label.text), "Boss")
	assert_string_contains(str(overlay.details_label.text), "extras abertos pelo progresso")
	assert_no_new_orphans()

func test_campaign_stage_one_reward_equips_tutorial_potion_even_without_damage_prompt() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var loadout = _build_valid_loadout()
	var root: Node3D = await _boot_campaign_root(loadout)
	assert_not_null(root)

	var stage_manager = root.get_node("RuntimeRoot/StageManager")
	assert_true(await _wait_for_flow_kind(root, "tutorial_skill", 2.0))
	assert_true(root.debug_trigger_prompt_action())
	await get_tree().process_frame
	assert_eq(root.debug_get_active_flow_kind(), "")
	assert_eq(Array(root.debug_get_run_state().get("equipped_potion_ids", []))[0], "")

	assert_true(await _clear_campaign_stage(stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(root, "reward", 2.0))

	var profile = profile_store.load_profile()
	assert_true(profile.tutorial_completed)
	assert_true(profile.is_potion_unlocked(ProgressionResolver.TUTORIAL_POTION_ID))
	assert_eq(
		Array(root.debug_get_run_state().get("equipped_potion_ids", []))[0],
		String(ProgressionResolver.TUTORIAL_POTION_ID)
	)
	assert_no_new_orphans()

func test_campaign_reward_overlay_rebuilds_from_payload_on_resume() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var loadout = _build_valid_loadout()
	var launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		loadout,
		{
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy"
		}
	)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))

	var scene: PackedScene = load(LocalModeCatalog.get_scene_path(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_not_null(scene)

	var first_root: Node3D = scene.instantiate()
	add_child_autofree(first_root)
	await get_tree().process_frame
	await get_tree().process_frame

	var first_session_manager = first_root.get_node("RuntimeRoot/SessionManager")
	var first_stage_manager = first_root.get_node("RuntimeRoot/StageManager")
	var player = first_root.get_node("RuntimeRoot/Player")
	assert_true(await wait_for_signal(first_session_manager.session_started, 1.5))
	await _continue_stage_briefing_if_present(first_root)
	assert_true(await _wait_for_flow_kind(first_root, "tutorial_skill", 2.0))
	assert_true(first_root.debug_trigger_prompt_action())
	await get_tree().process_frame

	player.take_damage(player.max_health * 0.45, &"test")
	await get_tree().process_frame
	assert_true(await _wait_for_flow_kind(first_root, "tutorial_potion", 2.0))
	assert_true(first_root.debug_trigger_prompt_action())
	await get_tree().process_frame

	assert_true(await _clear_campaign_stage(first_stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(first_root, "reward", 2.0))
	assert_true(first_root._persist_suspended_run_if_possible("menu"))

	var suspended_run: Dictionary = profile_store.get_suspended_run(
		ProgressionResolver.build_campaign_run_key(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy")
	)
	assert_true(suspended_run.has("reward_payload"))
	assert_false(suspended_run.has("reward_lines"))
	assert_eq(
		str(Dictionary(suspended_run.get("reward_payload", {})).get("reward_id", "")),
		"blacksmith_campaign:easy:mission_01"
	)

	first_root.queue_free()
	await get_tree().process_frame

	var resume_launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		loadout,
		{
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy",
			"resume_suspended_run": true
		}
	)
	assert_true(bool(resume_launch_result.get("ok", false)), str(resume_launch_result.get("message", "")))

	var second_root: Node3D = scene.instantiate()
	add_child_autofree(second_root)
	await get_tree().process_frame
	await get_tree().process_frame

	var second_session_manager = second_root.get_node("RuntimeRoot/SessionManager")
	var reward_overlay: CanvasLayer = second_root.get_node("PresentationRoot/CampaignFlowOverlay")
	var reward_body_label: Label = reward_overlay.find_child("BodyLabel", true, false)
	assert_true(await wait_for_signal(second_session_manager.session_started, 1.5))
	assert_true(await _wait_for_flow_kind(second_root, "reward", 2.0))
	assert_true(reward_overlay.visible)
	assert_not_null(reward_body_label)
	assert_string_contains(reward_body_label.text, "Nivel 2")
	assert_string_contains(reward_body_label.text, "Brado dos Imortais")
	assert_string_contains(reward_body_label.text, "Survival")
	assert_no_new_orphans()

func test_campaign_resume_keeps_stage_reward_grants_idempotent() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var loadout = _build_valid_loadout()
	var first_root: Node3D = await _boot_campaign_root(loadout)
	assert_not_null(first_root)

	var first_stage_manager = first_root.get_node("RuntimeRoot/StageManager")
	assert_true(await _advance_campaign_to_stage_one_reward(first_root, first_stage_manager, 8.0))

	var run_key: StringName = ProgressionResolver.build_campaign_run_key(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy"
	)
	var profile_before_resume = profile_store.load_profile()
	var unlocked_skills_before_resume: Array[String] = profile_before_resume.unlocked_skill_ids.duplicate()
	var unlocked_potions_before_resume: Array[String] = profile_before_resume.unlocked_potion_ids.duplicate()
	var applied_reward_ids_before_resume: Array[String] = profile_before_resume.applied_reward_ids.duplicate()
	var reward_payload_before_resume: Dictionary = Dictionary(
		first_root.debug_get_run_state().get("reward_payload", {})
	).duplicate(true)

	assert_true(first_root._persist_suspended_run_if_possible("menu"))
	first_root.queue_free()
	await get_tree().process_frame

	var second_root: Node3D = await _boot_campaign_root(loadout, true)
	assert_not_null(second_root)
	assert_true(await _wait_for_flow_kind(second_root, "reward", 2.0))

	var profile_after_resume = profile_store.load_profile()
	assert_eq(profile_after_resume.unlocked_skill_ids, unlocked_skills_before_resume)
	assert_eq(profile_after_resume.unlocked_potion_ids, unlocked_potions_before_resume)
	assert_eq(profile_after_resume.applied_reward_ids, applied_reward_ids_before_resume)

	var suspended_run_after_resume: Dictionary = profile_store.get_suspended_run(run_key)
	assert_eq(
		Dictionary(suspended_run_after_resume.get("reward_payload", {})),
		reward_payload_before_resume
	)

	assert_true(second_root.debug_continue_flow_overlay())
	assert_true(await _wait_for_flow_kind(second_root, "level_up", 2.0))
	assert_true(second_root.debug_apply_first_level_up_option())
	await get_tree().process_frame

	var profile_after_level_up = profile_store.load_profile()
	assert_eq(profile_after_level_up.unlocked_skill_ids, unlocked_skills_before_resume)
	assert_eq(profile_after_level_up.unlocked_potion_ids, unlocked_potions_before_resume)
	assert_eq(profile_after_level_up.applied_reward_ids, applied_reward_ids_before_resume)
	assert_no_new_orphans()

func test_campaign_abandon_and_replay_do_not_duplicate_persisted_stage_rewards() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var loadout = _build_valid_loadout()
	var first_root: Node3D = await _boot_campaign_root(loadout)
	assert_not_null(first_root)

	var first_stage_manager = first_root.get_node("RuntimeRoot/StageManager")
	assert_true(await _advance_campaign_to_stage_one_reward(first_root, first_stage_manager, 8.0))

	var run_key: StringName = ProgressionResolver.build_campaign_run_key(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy"
	)
	var profile_after_first_reward = profile_store.load_profile()
	var unlocked_skills_after_first_reward: Array[String] = profile_after_first_reward.unlocked_skill_ids.duplicate()
	var unlocked_potions_after_first_reward: Array[String] = profile_after_first_reward.unlocked_potion_ids.duplicate()
	var applied_reward_ids_after_first_reward: Array[String] = profile_after_first_reward.applied_reward_ids.duplicate()

	assert_true(first_root._persist_suspended_run_if_possible("menu"))
	first_root.queue_free()
	await get_tree().process_frame

	profile_store.clear_suspended_run(run_key)
	assert_false(profile_store.has_suspended_run(run_key))

	var replay_root: Node3D = await _boot_campaign_root(loadout)
	assert_not_null(replay_root)

	var replay_stage_manager = replay_root.get_node("RuntimeRoot/StageManager")
	assert_true(await _clear_campaign_stage(replay_stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(replay_root, "reward", 2.0))

	var profile_after_replay = profile_store.load_profile()
	assert_eq(profile_after_replay.unlocked_skill_ids, unlocked_skills_after_first_reward)
	assert_eq(profile_after_replay.unlocked_potion_ids, unlocked_potions_after_first_reward)
	assert_eq(profile_after_replay.applied_reward_ids, applied_reward_ids_after_first_reward)
	assert_eq(profile_after_replay.unlocked_skill_ids.size(), unlocked_skills_after_first_reward.size())
	assert_eq(profile_after_replay.unlocked_potion_ids.size(), unlocked_potions_after_first_reward.size())
	assert_no_new_orphans()

func test_campaign_suspend_keys_are_route_specific_between_easy_and_normal() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var loadout = _build_valid_loadout()
	var easy_root: Node3D = await _boot_campaign_root(loadout, false, &"easy")
	assert_true(easy_root._persist_suspended_run_if_possible("menu"))
	easy_root.queue_free()
	await get_tree().process_frame

	var normal_root: Node3D = await _boot_campaign_root(loadout, false, &"normal")
	assert_true(normal_root._persist_suspended_run_if_possible("menu"))
	normal_root.queue_free()
	await get_tree().process_frame

	var easy_key: StringName = ProgressionResolver.build_campaign_run_key(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy"
	)
	var normal_key: StringName = ProgressionResolver.build_campaign_run_key(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"normal"
	)
	assert_true(profile_store.has_suspended_run(easy_key))
	assert_true(profile_store.has_suspended_run(normal_key))
	assert_eq(
		str(profile_store.get_suspended_run(easy_key).get("difficulty_id", "")),
		"easy"
	)
	assert_eq(
		str(profile_store.get_suspended_run(normal_key).get("difficulty_id", "")),
		"normal"
	)

	profile_store.clear_campaign_suspended_run(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"normal")
	assert_true(profile_store.has_suspended_run(easy_key))
	assert_false(profile_store.has_suspended_run(normal_key))

func test_campaign_free_replay_uses_launch_kit_and_does_not_grant_persistent_rewards() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	profile_store.complete_mandatory_tutorial()
	profile_store.complete_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy")

	var profile_before = profile_store.load_profile()
	var unlocked_skills_before: Array[String] = profile_before.unlocked_skill_ids.duplicate()
	var unlocked_potions_before: Array[String] = profile_before.unlocked_potion_ids.duplicate()
	var applied_reward_ids_before: Array[String] = profile_before.applied_reward_ids.duplicate()

	var loadout = _build_valid_loadout()
	var root: Node3D = await _boot_campaign_root(
		loadout,
		false,
		ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID
	)
	assert_not_null(root)

	var run_state: Dictionary = root.debug_get_run_state()
	assert_eq(str(run_state.get("difficulty_id", "")), "free")
	assert_eq(Array(run_state.get("equipped_skill_ids", [])), Array(loadout.get_skill_ids()))
	assert_eq(Array(run_state.get("equipped_potion_ids", [])), Array(loadout.get_potion_ids()))

	var stage_manager = root.get_node("RuntimeRoot/StageManager")
	assert_true(await _clear_campaign_stage(stage_manager, 8.0))
	assert_true(await _wait_for_flow_kind(root, "reward", 2.0))

	var pending_reward_payload: Dictionary = Dictionary(root.debug_get_run_state().get("reward_payload", {}))
	var flow_overlay: CanvasLayer = root.get_node("PresentationRoot/CampaignFlowOverlay")
	var reward_body_label: Label = flow_overlay.find_child("BodyLabel", true, false)
	var reward_eyebrow_label: Label = flow_overlay.find_child("EyebrowLabel", true, false)
	assert_not_null(reward_body_label)
	assert_not_null(reward_eyebrow_label)
	assert_eq(str(pending_reward_payload.get("reward_id", "")), "replay:blacksmith_campaign:free:mission_01")
	assert_eq(Array(pending_reward_payload.get("permanent_skill_unlock_ids", [])), [])
	assert_eq(Array(pending_reward_payload.get("permanent_potion_unlock_ids", [])), [])
	assert_eq(Array(pending_reward_payload.get("menu_unlock_mode_ids", [])), [])
	assert_eq(int(pending_reward_payload.get("pending_level_increase", 0)), 0)
	assert_eq(int(pending_reward_payload.get("pending_skill_points", 0)), 0)
	assert_eq(reward_eyebrow_label.text, "REPLAY LIVRE")
	assert_string_contains(reward_body_label.text, "Nenhuma recompensa permanente")

	var profile_after = profile_store.load_profile()
	assert_eq(profile_after.unlocked_skill_ids, unlocked_skills_before)
	assert_eq(profile_after.unlocked_potion_ids, unlocked_potions_before)
	assert_eq(profile_after.applied_reward_ids, applied_reward_ids_before)
	assert_false(profile_after.has_applied_reward("replay:blacksmith_campaign:free:mission_01"))
	assert_no_new_orphans()

func test_campaign_resume_migrates_legacy_easy_suspend_key() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()

	var loadout = _build_valid_loadout()
	var legacy_key: StringName = ProgressionResolver.build_legacy_campaign_run_key(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID
	)
	var easy_key: StringName = ProgressionResolver.build_campaign_run_key(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy"
	)
	profile_store.save_suspended_run(
		legacy_key,
		{
			"campaign_id": "blacksmith_campaign",
			"current_stage_index": 0,
			"current_level": 1,
			"equipped_skill_ids": ["blacksmith_hammer_throw", "", "", ""],
			"equipped_potion_ids": ["vital_flask", ""],
			"loadout": loadout.to_id_payload(),
			"suspend_origin": "menu"
		}
	)

	var root: Node3D = await _boot_campaign_root(loadout, true, &"easy")
	assert_not_null(root)
	assert_true(profile_store.has_suspended_run(easy_key))
	assert_false(profile_store.has_suspended_run(legacy_key))
	assert_eq(str(root.debug_get_run_state().get("difficulty_id", "")), "easy")
	assert_eq(str(root.debug_get_run_state().get("campaign_id", "")), "blacksmith_campaign")
	assert_eq(root.debug_get_active_flow_kind(), "")

func _wait_for_flow_kind(root: Node, expected_kind: String, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if root.debug_get_active_flow_kind() == expected_kind:
			return true
		await get_tree().process_frame
	return false

func _boot_campaign_root(loadout, resume_suspended_run: bool = false, difficulty_id: StringName = &"easy") -> Node3D:
	var parameters: Dictionary = {
		"campaign_id": "blacksmith_campaign",
		"difficulty_id": String(difficulty_id)
	}
	if resume_suspended_run:
		parameters["resume_suspended_run"] = true

	var launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		loadout,
		parameters
	)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))

	var scene: PackedScene = load(LocalModeCatalog.get_scene_path(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_not_null(scene)

	var root: Node3D = scene.instantiate()
	add_child_autofree(root)
	await get_tree().process_frame
	await get_tree().process_frame

	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	await _continue_stage_briefing_if_present(root)
	return root

func _continue_stage_briefing_if_present(root: Node3D) -> void:
	var has_briefing: bool = await _wait_for_flow_kind(root, "stage_briefing", 0.25)
	if has_briefing:
		assert_true(root.debug_continue_flow_overlay())
		await get_tree().process_frame

func _advance_campaign_to_stage_one_reward(root: Node3D, stage_manager, timeout_seconds: float) -> bool:
	var player = root.get_node("RuntimeRoot/Player")
	assert_true(await _wait_for_flow_kind(root, "tutorial_skill", 2.0))
	assert_true(root.debug_trigger_prompt_action())
	await get_tree().process_frame

	player.take_damage(player.max_health * 0.45, &"test")
	await get_tree().process_frame
	assert_true(await _wait_for_flow_kind(root, "tutorial_potion", 2.0))
	assert_true(root.debug_trigger_prompt_action())
	await get_tree().process_frame

	assert_true(await _clear_campaign_stage(stage_manager, timeout_seconds))
	return await _wait_for_flow_kind(root, "reward", 2.0)

func _clear_campaign_stage(stage_manager, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		var active_enemies: Array = stage_manager.get_active_enemies()
		if active_enemies.is_empty():
			await get_tree().process_frame
			continue
		for enemy in active_enemies:
			if enemy != null and is_instance_valid(enemy):
				enemy.take_damage(999999.0, &"test")
		await get_tree().process_frame
		await get_tree().process_frame
		if stage_manager.get_active_enemies().is_empty():
			return true
	return false

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
