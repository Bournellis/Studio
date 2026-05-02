extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")

func after_each() -> void:
	var profile_store = get_node_or_null("/root/ProfileStore")
	if profile_store != null:
		profile_store.clear_profile()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_tutorial_completion_updates_profile_and_keeps_blacksmith_rewards() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	get_node("/root/ProfileStore").clear_profile()
	var tutorial_scene: PackedScene = load("res://modes/tutorial/tutorial.tscn")
	assert_not_null(tutorial_scene)

	var tutorial = tutorial_scene.instantiate()
	add_child_autofree(tutorial)
	await get_tree().process_frame

	var title_label: Label = tutorial.get_node("OverlayLayer/OverlayPanel/TitleLabel")
	assert_eq(title_label.text, "Campanha do Troll - Missao 1")

	tutorial.debug_complete_tutorial_for_test()
	var profile = get_node("/root/ProfileStore").load_profile()
	assert_true(profile.tutorial_completed)
	assert_true(profile.is_skill_unlocked(ProgressionResolver.TUTORIAL_SKILL_ID))
	assert_true(profile.is_potion_unlocked(ProgressionResolver.TUTORIAL_POTION_ID))
	assert_no_new_orphans()
