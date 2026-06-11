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

func test_real_avatar_idle_pose_stays_upright_after_one_full_loop() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	assert_true(avatar.debug_has_animation(&"Idle"))
	var animation_player := avatar.get_node_or_null("AvatarParts/RealCharacterModel/RealAnimationPlayer") as AnimationPlayer
	var skeleton := avatar.get_node_or_null("AvatarParts/RealCharacterModel/Armature/Skeleton3D") as Skeleton3D
	assert_not_null(animation_player)
	assert_not_null(skeleton)
	if animation_player == null or skeleton == null:
		return

	avatar.set_move_state(0.0, true, 0.0)
	await get_tree().process_frame
	var idle_animation := animation_player.get_animation(&"Idle")
	assert_not_null(idle_animation)
	if idle_animation == null:
		return
	await get_tree().create_timer(idle_animation.length + 0.05).timeout
	await get_tree().process_frame
	skeleton.force_update_all_bone_transforms()

	var head_position := _get_bone_position_in_avatar_space(avatar, skeleton, &"spine_03")
	var pelvis_position := _get_bone_position_in_avatar_space(avatar, skeleton, &"pelvis")
	assert_gt(head_position.y, pelvis_position.y)
	assert_gt(pelvis_position.y, 0.5)
	for bone_name in [&"spine_03", &"pelvis", &"hand_l", &"hand_r", &"foot_l", &"foot_r"]:
		var bone_position := _get_bone_position_in_avatar_space(avatar, skeleton, bone_name)
		assert_gte(bone_position.y, -0.05, "%s should not be below the avatar base" % bone_name)
	var skeleton_up := skeleton.global_transform.basis.y.normalized()
	assert_gt(skeleton_up.dot(Vector3.UP), cos(deg_to_rad(15.0)))
	assert_no_new_orphans()

func test_real_avatar_strips_root_motion_and_does_not_accumulate_drift() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	assert_true(avatar.debug_has_animation(&"RESET"))
	for animation_name in [&"Idle", &"Jog_Fwd", &"Sprint", &"Roll", &"Hit_Chest", &"Push", &"Jump_Start", &"Jump", &"Jump_Land", &"Dance", &"Idle_Talking"]:
		assert_true(avatar.debug_animation_has_stripped_root_motion(animation_name), "Root bone tracks should be removed for %s" % animation_name)
	var animation_player := avatar.get_node_or_null("AvatarParts/RealCharacterModel/RealAnimationPlayer") as AnimationPlayer
	assert_not_null(animation_player)
	if animation_player == null:
		return
	assert_true(_animation_has_non_uniform_bone_keys(animation_player, &"Jog_Fwd", &"pelvis"))

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

func _get_bone_position_in_avatar_space(avatar: Node3D, skeleton: Skeleton3D, bone_name: StringName) -> Vector3:
	var bone_index := skeleton.find_bone(str(bone_name))
	assert_gte(bone_index, 0, "Missing avatar bone: %s" % bone_name)
	if bone_index < 0:
		return Vector3.ZERO
	var bone_global_transform := skeleton.global_transform * skeleton.get_bone_global_pose(bone_index)
	return avatar.to_local(bone_global_transform.origin)

func _animation_has_non_uniform_bone_keys(animation_player: AnimationPlayer, animation_name: StringName, bone_name: StringName) -> bool:
	var animation := animation_player.get_animation(animation_name)
	if animation == null:
		return false
	for track_index in range(animation.get_track_count()):
		if _get_bone_name_from_track_path(animation.track_get_path(track_index)) != bone_name:
			continue
		if animation.track_get_key_count(track_index) < 2:
			continue
		var first_value: Variant = animation.track_get_key_value(track_index, 0)
		for key_index in range(1, animation.track_get_key_count(track_index)):
			var next_value: Variant = animation.track_get_key_value(track_index, key_index)
			if _animation_key_values_are_different(first_value, next_value):
				return true
	return false

func _get_bone_name_from_track_path(track_path: NodePath) -> StringName:
	var path_text := str(track_path)
	var separator_index := path_text.rfind(":")
	if separator_index < 0:
		return &""
	return StringName(path_text.substr(separator_index + 1).to_lower())

func _animation_key_values_are_different(first_value: Variant, next_value: Variant) -> bool:
	if first_value is Vector3 and next_value is Vector3:
		var first_vector: Vector3 = first_value
		var next_vector: Vector3 = next_value
		return first_vector.distance_to(next_vector) > 0.001
	if first_value is Quaternion and next_value is Quaternion:
		var first_rotation: Quaternion = first_value
		var next_rotation: Quaternion = next_value
		return first_rotation.get_euler().distance_to(next_rotation.get_euler()) > 0.001
	return first_value != next_value

func _assert_avatar_has_no_animation_drift(avatar, model_spawn_position: Vector3, skeleton_spawn_position: Vector3) -> void:
	assert_lt(avatar.debug_get_model_instance_local_position().distance_to(model_spawn_position), 0.05)
	assert_lt(avatar.debug_get_skeleton_local_position().distance_to(skeleton_spawn_position), 0.05)
	assert_almost_eq(avatar.debug_get_model_instance_local_rotation().y, 0.0, 0.01)
	assert_almost_eq(avatar.debug_get_skeleton_local_rotation().y, 0.0, 0.01)
