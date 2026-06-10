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

func test_avatar_animation_states_are_presentation_only() -> void:
	var avatar = PlayerAvatarScript.new()
	add_child_autofree(avatar)
	await get_tree().process_frame

	avatar.set_move_state(0.0, true, 0.0)
	assert_eq(avatar.debug_get_animation_state(), &"idle")
	avatar.set_move_state(4.0, true, 0.0)
	assert_eq(avatar.debug_get_animation_state(), &"move")
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
	assert_no_new_orphans()

func test_local_first_person_avatar_hides_head_and_neck() -> void:
	var avatar = PlayerAvatarScript.new()
	avatar.local_first_person = true
	add_child_autofree(avatar)
	await get_tree().process_frame

	var head := avatar.get_node("AvatarParts/Head") as MeshInstance3D
	var neck := avatar.get_node("AvatarParts/Neck") as MeshInstance3D
	assert_false(head.visible)
	assert_false(neck.visible)
	assert_no_new_orphans()
