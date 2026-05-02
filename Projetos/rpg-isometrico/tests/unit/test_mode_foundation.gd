extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
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
	"potion_2",
	"ui_back"
]

func before_each() -> void:
	_release_gameplay_actions()

func after_each() -> void:
	_release_gameplay_actions()
	var launch_context = get_node_or_null("/root/LaunchContext")
	if launch_context != null:
		launch_context.clear_pending_mode_launch()
	var profile_store = get_node_or_null("/root/ProfileStore")
	if profile_store != null:
		profile_store.clear_profile()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_campaign_runtime_boots_from_shared_launch_context() -> void:
	var root = await _instantiate_mode(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		{
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy"
		}
	)
	assert_not_null(root.get_node_or_null("WorldEnvironment"))
	assert_not_null(root.get_node_or_null("FillLight"))
	assert_not_null(root.get_node_or_null("ModeCamera"))
	assert_not_null(root.get_node_or_null("CombatReadabilityRoot"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/GameContext"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/SessionManager"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/StageManager"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/GameLoop"))
	assert_not_null(root.get_node_or_null("PresentationRoot/CombatHud"))
	assert_not_null(root.get_node_or_null("PresentationRoot/CombatFeedbackLayer"))
	assert_not_null(root.get_node_or_null("PresentationRoot/ResultOverlay"))
	var mode_camera: Camera3D = root.get_node("ModeCamera") as Camera3D
	assert_true(mode_camera.current)
	var player = root.get_node("RuntimeRoot/Player")
	player.global_position = Vector3(9.0, 1.05, -11.0)

	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	var stage_manager = root.get_node("RuntimeRoot/StageManager")
	assert_not_null(root.get_node_or_null("RuntimeRoot/ActiveCampaignStage"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/ActiveCampaignStage/Floor"))
	assert_true(await _wait_for_stage_enemy_count(stage_manager, 1, 2.5))
	var stage_scene = stage_manager.get_current_stage_scene()
	assert_lt(player.global_position.distance_to(stage_scene.get_player_spawn_position()), 0.001)
	var game_loop = root.get_node("RuntimeRoot/GameLoop")
	assert_eq(String(game_loop.get_hud_snapshot().get("campaign_id", "")), "blacksmith_campaign")
	var initial_camera_position: Vector3 = mode_camera.global_position
	var initial_camera_basis: Basis = mode_camera.global_basis
	player.position += Vector3(3.5, 0.0, 2.2)
	root._update_camera()
	var moved_expected_camera_position: Vector3 = player.global_position + stage_manager.get_current_camera_offset() + Vector3(0.0, 0.45, 0.0)
	assert_gt(mode_camera.global_position.distance_to(initial_camera_position), 0.001)
	assert_lt(mode_camera.global_position.distance_to(moved_expected_camera_position), 0.001)
	assert_eq(str(mode_camera.global_basis), str(initial_camera_basis))
	player.take_damage(999.0, &"test")
	assert_true(await wait_for_signal(session_manager.session_ended, 3.0))
	assert_true((root.get_node("PresentationRoot/ResultOverlay") as CanvasLayer).visible)
	assert_no_new_orphans()

func test_survival_runtime_boots_from_shared_launch_context() -> void:
	var root = await _instantiate_mode(LocalModeCatalog.SURVIVAL_MODE_ID, {"start_wave": 3})
	assert_not_null(root.get_node_or_null("WorldEnvironment"))
	assert_not_null(root.get_node_or_null("FillLight"))
	assert_not_null(root.get_node_or_null("ModeFloor"))
	assert_not_null(root.get_node_or_null("ModeCamera"))
	assert_not_null(root.get_node_or_null("BoundaryRoot"))
	assert_not_null(root.get_node_or_null("RuinsRoot"))
	assert_not_null(root.get_node_or_null("CombatReadabilityRoot"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/GameContext"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/SessionManager"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/SpawnController"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/WaveManager"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/GameLoop"))
	assert_not_null(root.get_node_or_null("PresentationRoot/CombatHud"))
	assert_not_null(root.get_node_or_null("PresentationRoot/CombatFeedbackLayer"))
	assert_not_null(root.get_node_or_null("PresentationRoot/ResultOverlay"))
	var mode_camera: Camera3D = root.get_node("ModeCamera") as Camera3D
	assert_true(mode_camera.current)
	var player = root.get_node("RuntimeRoot/Player")
	player.global_position = Vector3(14.0, 1.05, 14.0)
	root._enforce_pre_match_spawn_lock()
	assert_lt(player.global_position.distance_to(root.PLAYER_SPAWN_POSITION), 0.001)

	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	var spawn_controller = root.get_node("RuntimeRoot/SpawnController")
	assert_true(await _wait_for_enemy_count(spawn_controller, 1, 2.5))
	await get_tree().create_timer(root.POST_START_SPAWN_GUARD_DURATION + 0.1).timeout
	var game_loop = root.get_node("RuntimeRoot/GameLoop")
	assert_eq(int(game_loop.get_hud_snapshot().get("wave_number", 0)), 3)
	var initial_camera_position: Vector3 = mode_camera.global_position
	var initial_camera_basis: Basis = mode_camera.global_basis
	player.position += Vector3(4.0, 0.0, 3.0)
	root._update_camera()
	var moved_expected_camera_position: Vector3 = player.global_position + root.CAMERA_OFFSET + Vector3(0.0, 0.45, 0.0)
	assert_gt(mode_camera.global_position.distance_to(initial_camera_position), 0.001)
	assert_lt(mode_camera.global_position.distance_to(moved_expected_camera_position), 0.001)
	assert_eq(str(mode_camera.global_basis), str(initial_camera_basis))
	player.take_damage(999.0, &"test")
	assert_true(await wait_for_signal(session_manager.session_ended, 3.0))
	assert_true((root.get_node("PresentationRoot/ResultOverlay") as CanvasLayer).visible)
	assert_no_new_orphans()

func test_survival_post_start_spawn_guard_keeps_entry_stable() -> void:
	var root = await _instantiate_mode(LocalModeCatalog.SURVIVAL_MODE_ID, {"start_wave": 1})
	var player = root.get_node("RuntimeRoot/Player")
	var session_manager = root.get_node("RuntimeRoot/SessionManager")

	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	player.global_position = Vector3(12.0, 1.05, 12.0)
	root._tick_post_start_spawn_guard(0.0)
	assert_lt(player.global_position.distance_to(root.PLAYER_SPAWN_POSITION), 0.001)

	assert_gt(root.post_start_spawn_guard_remaining, 0.0)
	await get_tree().create_timer(root.POST_START_SPAWN_GUARD_DURATION + 0.1).timeout
	player.global_position = Vector3(3.0, 1.05, 0.0)
	root._tick_post_start_spawn_guard(0.0)
	assert_gt(player.global_position.distance_to(root.PLAYER_SPAWN_POSITION), 0.05)
	assert_no_new_orphans()

func test_boss_runtime_boots_from_shared_launch_context() -> void:
	var root = await _instantiate_mode(LocalModeCatalog.BOSS_MODE_ID, {"boss_id": "boss_troll"})
	assert_not_null(root.get_node_or_null("WorldEnvironment"))
	assert_not_null(root.get_node_or_null("FillLight"))
	assert_not_null(root.get_node_or_null("ModeFloor"))
	assert_not_null(root.get_node_or_null("ArenaRing"))
	assert_not_null(root.get_node_or_null("ModeCamera"))
	assert_not_null(root.get_node_or_null("CombatReadabilityRoot"))
	assert_not_null(root.get_node_or_null("BoundaryRoot"))
	assert_not_null(root.get_node_or_null("DecorationRoot"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/GameContext"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/SessionManager"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/Boss"))
	assert_not_null(root.get_node_or_null("RuntimeRoot/GameLoop"))
	assert_not_null(root.get_node_or_null("PresentationRoot/CombatHud"))
	assert_not_null(root.get_node_or_null("PresentationRoot/CombatFeedbackLayer"))
	assert_not_null(root.get_node_or_null("PresentationRoot/ResultOverlay"))
	var mode_camera: Camera3D = root.get_node("ModeCamera") as Camera3D
	assert_true(mode_camera.current)

	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	var initial_camera_position: Vector3 = mode_camera.global_position
	var initial_camera_basis: Basis = mode_camera.global_basis
	var initial_camera_size: float = mode_camera.size
	var player = root.get_node("RuntimeRoot/Player")
	player.position += Vector3(5.0, 0.0, -4.0)
	await get_tree().create_timer(1.2).timeout
	var boss = root.get_node("RuntimeRoot/Boss")
	boss.position += Vector3(-3.5, 0.0, 2.0)
	await get_tree().process_frame
	var moved_expected_camera_position: Vector3 = player.global_position + root.CAMERA_OFFSET + Vector3(0.0, 0.4, 0.0)
	assert_gt(mode_camera.global_position.distance_to(initial_camera_position), 0.001)
	assert_lt(mode_camera.global_position.distance_to(moved_expected_camera_position), 0.001)
	assert_eq(str(mode_camera.global_basis), str(initial_camera_basis))
	assert_eq(mode_camera.size, initial_camera_size)
	boss.take_damage(999999.0, &"test")
	assert_true(await wait_for_signal(session_manager.session_ended, 5.0))
	assert_true((root.get_node("PresentationRoot/ResultOverlay") as CanvasLayer).visible)
	assert_no_new_orphans()

func test_survival_runtime_resumes_suspended_run_state() -> void:
	var root = await _instantiate_mode(LocalModeCatalog.SURVIVAL_MODE_ID, {"start_wave": 2})
	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	var spawn_controller = root.get_node("RuntimeRoot/SpawnController")
	assert_true(await _wait_for_enemy_count(spawn_controller, 1, 2.5))
	await get_tree().create_timer(root.POST_START_SPAWN_GUARD_DURATION + 0.1).timeout

	var player = root.get_node("RuntimeRoot/Player")
	var wave_manager = root.get_node("RuntimeRoot/WaveManager")
	var expected_position: Vector3 = Vector3(4.5, 1.05, -3.0)
	player.take_damage(28.0, &"test")
	player.apply_barrier(18.0, 4.5)
	player.global_position = expected_position
	await get_tree().process_frame

	var expected_health: float = player.health
	var expected_wave: int = int(wave_manager.get_hud_snapshot().get("wave_number", 0))
	root.debug_save_suspended_run()
	assert_true(get_node("/root/ProfileStore").has_suspended_run(ProgressionResolver.build_survival_run_key()))

	root.queue_free()
	await get_tree().process_frame

	var resumed_root = await _instantiate_mode(
		LocalModeCatalog.SURVIVAL_MODE_ID,
		{
			"start_wave": 1,
			"resume_suspended_run": true
		}
	)
	var resumed_session_manager = resumed_root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(resumed_session_manager.session_started, 1.5))
	var resumed_player = resumed_root.get_node("RuntimeRoot/Player")
	var resumed_wave_manager = resumed_root.get_node("RuntimeRoot/WaveManager")
	var resumed_spawn_controller = resumed_root.get_node("RuntimeRoot/SpawnController")

	assert_eq(int(resumed_wave_manager.get_hud_snapshot().get("wave_number", 0)), expected_wave)
	assert_eq(int(round(resumed_player.health)), int(round(expected_health)))
	assert_gt(resumed_player.get_barrier_amount(), 0.0)
	assert_lt(resumed_player.global_position.distance_to(expected_position), 0.05)
	assert_true(resumed_spawn_controller.get_enemy_count() > 0 or resumed_spawn_controller.get_pending_spawn_count() > 0)
	assert_no_new_orphans()

func test_boss_runtime_resumes_suspended_run_state() -> void:
	var root = await _instantiate_mode(LocalModeCatalog.BOSS_MODE_ID, {"boss_id": "boss_troll"})
	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))

	var player = root.get_node("RuntimeRoot/Player")
	var boss = root.get_node("RuntimeRoot/Boss")
	var expected_player_position: Vector3 = Vector3(0.0, 1.05, 13.8)
	var expected_boss_position: Vector3 = Vector3(-1.5, 1.05, -2.0)
	player.take_damage(24.0, &"test")
	player.apply_barrier(20.0, 5.0)
	player.global_position = expected_player_position
	boss.take_damage(640.0, &"test")
	boss.global_position = expected_boss_position
	boss.state = boss.BossState.DORMANT
	boss.active_attack = boss.BossAttack.NONE
	boss.state_time_remaining = 0.0
	boss.attack_cooldown_remaining = 0.0
	boss.roar_camp_time = 0.0
	boss.velocity = Vector3.ZERO
	await get_tree().process_frame

	var expected_player_health: float = player.health
	var expected_boss_health: float = boss.health
	var expected_boss_phase: int = boss.get_phase_number()
	root.debug_save_suspended_run()
	assert_true(get_node("/root/ProfileStore").has_suspended_run(ProgressionResolver.build_boss_run_key(&"boss_troll")))

	root.queue_free()
	await get_tree().process_frame

	var resumed_root = await _instantiate_mode(
		LocalModeCatalog.BOSS_MODE_ID,
		{
			"boss_id": "boss_troll",
			"resume_suspended_run": true
		}
	)
	var resumed_session_manager = resumed_root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(resumed_session_manager.session_started, 1.5))
	var resumed_player = resumed_root.get_node("RuntimeRoot/Player")
	var resumed_boss = resumed_root.get_node("RuntimeRoot/Boss")

	assert_eq(int(round(resumed_player.health)), int(round(expected_player_health)))
	assert_eq(int(round(resumed_boss.health)), int(round(expected_boss_health)))
	assert_eq(resumed_boss.get_phase_number(), expected_boss_phase)
	assert_gt(resumed_player.get_barrier_amount(), 0.0)
	assert_lt(resumed_player.global_position.distance_to(expected_player_position), 0.05)
	assert_no_new_orphans()

func _instantiate_mode(mode_id: StringName, parameters: Dictionary) -> Node3D:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var loadout = _build_valid_loadout()
	var launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(mode_id, loadout, parameters)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))

	var scene: PackedScene = load(LocalModeCatalog.get_scene_path(mode_id))
	assert_not_null(scene)

	var root: Node3D = scene.instantiate()
	add_child_autofree(root)
	await get_tree().process_frame
	await get_tree().process_frame
	return root

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

func _wait_for_enemy_count(spawn_controller, minimum_count: int, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if int(spawn_controller.get_enemy_count()) >= minimum_count:
			return true
		await get_tree().process_frame
	return false

func _wait_for_stage_enemy_count(stage_manager, minimum_count: int, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if int(stage_manager.get_enemy_count()) >= minimum_count:
			return true
		await get_tree().process_frame
	return false

func _release_gameplay_actions() -> void:
	for action_name: String in GAMEPLAY_ACTIONS:
		Input.action_release(action_name)
