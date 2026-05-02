extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const SurvivalWaveManager = preload("res://modes/survival/survival_wave_manager.gd")

func after_each() -> void:
	var launch_context = get_node_or_null("/root/LaunchContext")
	if launch_context != null:
		launch_context.clear_pending_mode_launch()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_survival_wave_clears_into_rest_window() -> void:
	var root = await _instantiate_survival_mode({"start_wave": 1})
	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))

	var spawn_controller = root.get_node("RuntimeRoot/SpawnController")
	var wave_manager = root.get_node("RuntimeRoot/WaveManager")
	var game_loop = root.get_node("RuntimeRoot/GameLoop")

	assert_true(await _wait_until_wave_spawn_finishes(spawn_controller, 4.0))
	for enemy in spawn_controller.get_active_enemies():
		enemy.take_damage(999.0, &"test")

	assert_true(await _wait_for_wave_state(wave_manager, SurvivalWaveManager.WaveState.REST, 2.0))
	var snapshot: Dictionary = game_loop.get_hud_snapshot()
	assert_eq(int(snapshot.get("completed_waves", 0)), 1)
	assert_gt(float(snapshot.get("rest_remaining", 0.0)), 0.0)
	var shell_snapshot: Dictionary = game_loop.get_shell_snapshot()
	assert_eq(str(shell_snapshot.get("module_title", "")), "Survival: intervalo antes da onda 2")
	assert_true(str(shell_snapshot.get("module_detail", "")).contains("Folego"))
	game_loop.conclude(game_loop._build_result(true))
	assert_true(await wait_for_signal(session_manager.session_ended, 3.0))
	var overlay = root.get_node("PresentationRoot/ResultOverlay")
	assert_true((overlay as CanvasLayer).visible)
	assert_eq(str(overlay.eyebrow_label.text), "RESULTADO DO EXTRA")
	assert_string_contains(overlay.details_label.text, "Funcao: Prova de resistencia")
	assert_string_contains(overlay.details_label.text, "Progressao permanente: sem alteracao")
	assert_no_new_orphans()

func _instantiate_survival_mode(parameters: Dictionary) -> Node3D:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var loadout = _build_valid_loadout()
	var launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(
		LocalModeCatalog.SURVIVAL_MODE_ID,
		loadout,
		parameters
	)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))

	var scene: PackedScene = load(LocalModeCatalog.get_scene_path(LocalModeCatalog.SURVIVAL_MODE_ID))
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

func _wait_until_wave_spawn_finishes(spawn_controller, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if int(spawn_controller.get_pending_spawn_count()) == 0 and int(spawn_controller.get_enemy_count()) > 0:
			return true
		await get_tree().process_frame
	return false

func _wait_for_wave_state(wave_manager, expected_state: int, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if int(wave_manager.state) == expected_state:
			return true
		await get_tree().process_frame
	return false
