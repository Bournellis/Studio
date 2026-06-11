extends "res://addons/gut/test.gd"

const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")

func test_avatar_catalog_exposes_default_and_multiple_choices() -> void:
	var appearance = AvatarCatalogScript.get_default_appearance()

	assert_eq(appearance.skin_tone_id, &"tan")
	assert_eq(appearance.country_kit_id, &"brazil")
	assert_gte(AvatarCatalogScript.get_skin_tone_count(), 4)
	assert_gte(AvatarCatalogScript.get_country_kit_count(), 6)
	assert_eq(AvatarCatalogScript.get_next_skin_tone_id(&"dark"), &"light")
	assert_eq(AvatarCatalogScript.get_next_country_kit_id(&"germany"), &"brazil")
	assert_false(AvatarCatalogScript.get_country_kit_label(&"brazil").is_empty())

func test_avatar_instantiates_expected_runtime_parts() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	assert_eq(avatar.debug_get_part_count(), 17)
	assert_true(avatar.debug_has_part(&"head"))
	assert_true(avatar.debug_has_part(&"torso"))
	assert_true(avatar.debug_has_part(&"left_hand"))
	assert_true(avatar.debug_has_part(&"right_foot"))
	assert_not_null(avatar.get_node_or_null("AvatarParts"))
	assert_not_null(avatar.get_node_or_null("AvatarParts/RealCharacterModel"))
	assert_true(avatar.debug_has_real_model())
	assert_gte(avatar.debug_get_real_skeleton_bone_count(), 60)
	assert_true(avatar.debug_has_animation_tree())
	assert_gte(avatar.debug_get_animation_count(), 45)
	assert_true(avatar.debug_has_animation(&"Idle"))
	assert_true(avatar.debug_has_animation(&"Jog_Fwd"))
	assert_true(avatar.debug_has_animation(&"Roll"))
	assert_true(avatar.debug_has_animation(&"JogoDaCopa_Kick"))
	assert_true(avatar.debug_has_persistent_vfx())
	assert_no_new_orphans()

func test_avatar_appearance_updates_skin_and_shirt_materials() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	var next_appearance = AvatarAppearanceScript.new(&"dark", &"france")
	avatar.apply_appearance(next_appearance)

	assert_eq(avatar.debug_get_skin_tone_id(), &"dark")
	assert_eq(avatar.debug_get_country_kit_id(), &"france")
	assert_eq(avatar.debug_get_part_albedo_color(&"head"), AvatarCatalogScript.get_skin_color(&"dark"))
	assert_eq(avatar.debug_get_part_albedo_color(&"torso"), AvatarCatalogScript.get_kit_primary_color(&"france"))
	assert_eq(avatar.debug_get_part_albedo_color(&"chest_stripe"), AvatarCatalogScript.get_kit_secondary_color(&"france"))
	assert_no_new_orphans()

func test_real_avatar_material_tint_preserves_pbr_textures() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	var next_appearance = AvatarAppearanceScript.new(&"tan", &"brazil")
	avatar.apply_appearance(next_appearance)

	assert_gt(avatar.debug_get_textured_surface_count(), 0)
	assert_eq(avatar.debug_get_textured_surface_override_count(), avatar.debug_get_textured_surface_count())
	assert_no_new_orphans()

func test_avatar_animation_states_are_presentation_only() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	avatar.set_move_state(0.0, true, 0.0)
	assert_eq(avatar.debug_get_animation_state(), &"idle")
	avatar.set_move_state(4.0, true, 0.0)
	assert_eq(avatar.debug_get_animation_state(), &"move")
	avatar.set_move_state(11.0, true, 0.0)
	assert_eq(avatar.debug_get_animation_state(), &"sprint")
	avatar.set_move_state(1.0, false, 3.0)
	assert_eq(avatar.debug_get_animation_state(), &"jump")
	avatar.set_move_state(1.0, false, -2.0)
	assert_eq(avatar.debug_get_animation_state(), &"fall")

	avatar.play_kick(false)
	assert_eq(avatar.debug_get_animation_state(), &"kick")
	avatar.play_kick(true)
	assert_eq(avatar.debug_get_animation_state(), &"strong_kick")
	avatar.play_celebrate()
	assert_eq(avatar.debug_get_animation_state(), &"celebrate")
	avatar.play_hit()
	assert_eq(avatar.debug_get_animation_state(), &"hit")
	avatar.play_slide()
	assert_eq(avatar.debug_get_animation_state(), &"slide")
	avatar.play_flip()
	assert_eq(avatar.debug_get_animation_state(), &"flip")
	avatar.play_push()
	assert_eq(avatar.debug_get_animation_state(), &"push")
	avatar.play_emote()
	assert_eq(avatar.debug_get_animation_state(), &"emote")
	assert_no_new_orphans()

func test_real_avatar_strips_root_motion_and_does_not_accumulate_drift() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	assert_true(avatar.debug_has_animation(&"RESET"))
	for animation_name in [&"Idle", &"Jog_Fwd", &"Sprint", &"Roll", &"Hit_Chest", &"Push", &"Jump_Start", &"Jump", &"Jump_Land", &"Dance", &"Idle_Talking"]:
		assert_true(avatar.debug_animation_has_stripped_root_motion(animation_name), "Root motion should be stripped for %s" % animation_name)

	var model_spawn_position := avatar.debug_get_model_instance_local_position()
	var skeleton_spawn_position := avatar.debug_get_skeleton_local_position()
	var actions: Array[StringName] = [
		&"slide",
		&"kick",
		&"hit",
		&"idle",
		&"strong_kick",
		&"push",
		&"flip",
		&"move",
		&"slide",
		&"kick",
		&"hit",
		&"idle",
		&"emote",
		&"celebrate",
		&"flip",
		&"push",
		&"kick",
		&"slide",
		&"hit",
		&"idle",
	]
	for action in actions:
		_play_avatar_debug_action(avatar, action)
		await get_tree().process_frame
		avatar._process(0.5)
		await get_tree().process_frame
		_assert_avatar_has_no_animation_drift(avatar, model_spawn_position, skeleton_spawn_position)
	assert_no_new_orphans()

func test_local_first_person_avatar_hides_head_and_neck() -> void:
	var avatar = PlayerAvatarScript.new()
	avatar.local_first_person = true
	add_child_autofree(avatar)
	await get_tree().process_frame

	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(avatar.get_node("AvatarParts/RealCharacterModel"), meshes)
	assert_gt(meshes.size(), 0)
	for mesh_instance in meshes:
		assert_false(mesh_instance.visible)
	assert_no_new_orphans()

func test_bot_variant_can_use_female_model() -> void:
	var avatar = PlayerAvatarScript.new()
	avatar.set_character_variant(&"female")
	add_child_autofree(avatar)
	await get_tree().process_frame

	assert_eq(avatar.debug_get_character_variant(), &"female")
	assert_true(avatar.debug_has_real_model())
	assert_gte(avatar.debug_get_real_skeleton_bone_count(), 60)
	assert_true(avatar.debug_has_animation_tree())
	assert_no_new_orphans()

func _collect_meshes(node: Node, output: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		output.append(node)
	for child in node.get_children():
		_collect_meshes(child, output)

func _play_avatar_debug_action(avatar, action: StringName) -> void:
	match action:
		&"slide":
			avatar.play_slide()
		&"kick":
			avatar.play_kick(false)
		&"strong_kick":
			avatar.play_kick(true)
		&"hit":
			avatar.play_hit()
		&"push":
			avatar.play_push()
		&"flip":
			avatar.play_flip()
		&"emote":
			avatar.play_emote()
		&"celebrate":
			avatar.play_celebrate()
		&"move":
			avatar.set_move_state(5.0, true, 0.0)
		_:
			avatar.set_move_state(0.0, true, 0.0)

func _assert_avatar_has_no_animation_drift(avatar, model_spawn_position: Vector3, skeleton_spawn_position: Vector3) -> void:
	assert_lt(avatar.debug_get_model_instance_local_position().distance_to(model_spawn_position), 0.05)
	assert_lt(avatar.debug_get_skeleton_local_position().distance_to(skeleton_spawn_position), 0.05)
	assert_almost_eq(avatar.debug_get_model_instance_local_rotation().y, 0.0, 0.01)
	assert_almost_eq(avatar.debug_get_skeleton_local_rotation().y, 0.0, 0.01)
	var root_position: Vector3 = avatar.debug_get_bone_pose_position(&"root")
	var pelvis_position: Vector3 = avatar.debug_get_bone_pose_position(&"pelvis")
	assert_almost_eq(root_position.x, 0.0, 0.05)
	assert_almost_eq(root_position.z, 0.0, 0.05)
	assert_almost_eq(pelvis_position.x, 0.0, 0.05)
	assert_almost_eq(pelvis_position.z, 0.0, 0.05)
	assert_almost_eq(avatar.debug_get_bone_pose_rotation_y(&"root"), 0.0, 0.01)
	assert_almost_eq(avatar.debug_get_bone_pose_rotation_y(&"pelvis"), 0.0, 0.01)
