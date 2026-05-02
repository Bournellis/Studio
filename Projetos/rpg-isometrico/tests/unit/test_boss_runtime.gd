extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const BossTrollController = preload("res://gameplay/boss/boss_troll_controller.gd")

func after_each() -> void:
	var launch_context = get_node_or_null("/root/LaunchContext")
	if launch_context != null:
		launch_context.clear_pending_mode_launch()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_boss_transitions_to_phase_2_after_threshold_damage() -> void:
	var root = await _instantiate_boss_mode()
	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))

	var boss: BossTrollController = root.get_node("RuntimeRoot/Boss")
	assert_true(await _wait_until_boss_not_invulnerable(boss, 3.0))
	boss.take_damage(3600.0, &"test")

	assert_true(await _wait_for_boss_phase(boss, 2, 1.5))
	assert_eq(boss.get_phase_number(), 2)
	assert_eq(boss.get_current_regen(), 25.0)

	var game_loop = root.get_node("RuntimeRoot/GameLoop")
	assert_eq(int(game_loop.get_hud_snapshot().get("phase_number", 0)), 2)
	var shell_snapshot: Dictionary = game_loop.get_shell_snapshot()
	assert_true(str(shell_snapshot.get("module_title", "")).contains("Boss Troll: Fase 2 | vida"))
	assert_true(str(shell_snapshot.get("module_detail", "")).contains("rugido"))
	assert_no_new_orphans()

func test_boss_victory_returns_boss_summary_through_shared_result_flow() -> void:
	var root = await _instantiate_boss_mode()
	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	var captured_results: Array[Dictionary] = []
	session_manager.session_ended.connect(func(result: Dictionary): captured_results.append(result.duplicate(true)), CONNECT_ONE_SHOT)

	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	var boss: BossTrollController = root.get_node("RuntimeRoot/Boss")
	assert_true(await _wait_until_boss_not_invulnerable(boss, 3.0))
	boss.take_damage(999999.0, &"test")

	assert_true(await wait_for_signal(session_manager.session_ended, 5.0))
	assert_true((root.get_node("PresentationRoot/ResultOverlay") as CanvasLayer).visible)
	var captured_result: Dictionary = {} if captured_results.is_empty() else captured_results[0]
	assert_eq(str(captured_result.get("title", "")), "Boss vencido!")
	var boss_summary: Dictionary = captured_result.get("round_summary", {}).get("boss", {})
	var extra_summary: Dictionary = captured_result.get("round_summary", {}).get("extra_mode", {})
	assert_eq(str(boss_summary.get("boss_name", "")), "Boss Troll")
	assert_eq(int(boss_summary.get("phase_number", 0)), 1)
	assert_eq(float(boss_summary.get("remaining_health", -1.0)), 0.0)
	assert_eq(str(extra_summary.get("role", "")), "Pratica de maestria")
	assert_false(bool(extra_summary.get("grants_permanent_progress", true)))
	var overlay = root.get_node("PresentationRoot/ResultOverlay")
	assert_eq(str(overlay.eyebrow_label.text), "RESULTADO DO EXTRA")
	assert_string_contains(overlay.details_label.text, "Funcao: Pratica de maestria")
	assert_string_contains(overlay.details_label.text, "Progressao permanente: sem alteracao")
	assert_no_new_orphans()

func _instantiate_boss_mode() -> Node3D:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var loadout = _build_valid_loadout()
	var launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(
		LocalModeCatalog.BOSS_MODE_ID,
		loadout,
		{"boss_id": "boss_troll"}
	)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))

	var scene: PackedScene = load(LocalModeCatalog.get_scene_path(LocalModeCatalog.BOSS_MODE_ID))
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

func _wait_until_boss_not_invulnerable(boss: BossTrollController, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if boss != null and is_instance_valid(boss) and not bool(boss.get_runtime_snapshot().get("invulnerable", true)):
			return true
		await get_tree().process_frame
	return false

func _wait_for_boss_phase(boss: BossTrollController, expected_phase: int, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if boss != null and is_instance_valid(boss) and boss.get_phase_number() == expected_phase:
			return true
		await get_tree().process_frame
	return false
