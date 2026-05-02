extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")

func after_each() -> void:
	var profile_store = get_node_or_null("/root/ProfileStore")
	if profile_store != null:
		profile_store.clear_profile()

func test_boot_routes_to_frontend_when_profile_is_missing() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	get_node("/root/ProfileStore").clear_profile()
	var boot_scene: PackedScene = load("res://modes/boot/boot.tscn")
	assert_not_null(boot_scene)

	var boot = boot_scene.instantiate()
	assert_eq(boot.resolve_initial_scene_path(), "res://modes/frontend/frontend.tscn")
	boot.free()
	assert_no_new_orphans()

func test_boot_routes_to_frontend_after_tutorial_completion() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	get_node("/root/ProfileStore").complete_mandatory_tutorial()
	var boot_scene: PackedScene = load("res://modes/boot/boot.tscn")
	assert_not_null(boot_scene)

	var boot = boot_scene.instantiate()
	assert_eq(boot.resolve_initial_scene_path(), "res://modes/frontend/frontend.tscn")
	boot.free()
	assert_no_new_orphans()
