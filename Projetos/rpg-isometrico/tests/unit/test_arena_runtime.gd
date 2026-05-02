extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
func after_each() -> void:
	get_node("/root/LaunchContext").set_pending_loadout(null)
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_arena_scene_boots_with_camera_and_named_runtime_nodes() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var library = get_node("/root/ContentLibrary")
	library.reload()
	var races = library.get_races()
	assert_eq(races.size(), 1)

	var race = races[0]
	var weapon = library.get_weapons_for_race(race.id)[0]
	var skills = library.get_skills_for_weapon(race.id, weapon.id)
	var potions = library.get_potions_for_race(race.id)
	var loadout = library.build_loadout_from_ids(
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

	get_node("/root/LaunchContext").set_pending_loadout(loadout)
	var arena_scene: PackedScene = load("res://modes/arena/arena.tscn")
	assert_not_null(arena_scene)

	var arena: Node3D = arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().process_frame

	var session_manager = arena.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(session_manager.session_started, 1.5))

	var camera: Camera3D = arena.get_node_or_null("ArenaCamera")
	assert_not_null(camera)
	assert_true(camera.current)
	assert_ne(str(camera.global_basis), str(Basis.IDENTITY))

	assert_not_null(arena.get_node_or_null("ArenaFloor"))
	assert_not_null(arena.get_node_or_null("ArenaRing"))
	assert_not_null(arena.get_node_or_null("ArenaWalls"))
	assert_not_null(arena.get_node_or_null("ArenaBlocks"))
	assert_not_null(arena.get_node_or_null("CombatReadabilityRoot"))
	assert_not_null(arena.get_node_or_null("PlayerSpawn"))
	assert_not_null(arena.get_node_or_null("BotSpawn"))
	assert_not_null(arena.get_node_or_null("CombatReadabilityRoot/CombatClarity3D"))
	assert_not_null(arena.get_node_or_null("CombatReadabilityRoot/SkillFeedback3D"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Bot"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/GameContext"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/SessionManager"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/GameLoop"))
	assert_not_null(arena.get_node_or_null("PresentationRoot/CombatHud"))
	assert_not_null(arena.get_node_or_null("PresentationRoot/CombatFeedbackLayer"))
	assert_not_null(arena.get_node_or_null("PresentationRoot/ResultOverlay"))

	var player: Node3D = arena.get_node("RuntimeRoot/Player")
	assert_not_null(player.get_node_or_null("MeshInstance3D"))
	assert_not_null(player.get_node_or_null("GroundShadow"))
	var walls_root: Node3D = arena.get_node("ArenaWalls")
	var blocks_root: Node3D = arena.get_node("ArenaBlocks")
	assert_eq(walls_root.get_child_count(), 4)
	assert_eq(blocks_root.get_child_count(), 4)
	assert_gt(camera.size, 12.0)
	var expected_camera_position: Vector3 = player.global_position + arena.CAMERA_OFFSET + Vector3(0.0, 0.4, 0.0)
	assert_lt(camera.global_position.distance_to(expected_camera_position), 0.001)
	var initial_camera_position: Vector3 = camera.global_position
	player.position += Vector3(3.0, 0.0, -2.0)
	arena.get_node("RuntimeRoot/Bot").position += Vector3(-2.0, 0.0, 2.5)
	await get_tree().process_frame
	var moved_expected_camera_position: Vector3 = player.global_position + arena.CAMERA_OFFSET + Vector3(0.0, 0.4, 0.0)
	assert_gt(camera.global_position.distance_to(initial_camera_position), 0.001)
	assert_lt(camera.global_position.distance_to(moved_expected_camera_position), 0.001)
	assert_no_new_orphans()
