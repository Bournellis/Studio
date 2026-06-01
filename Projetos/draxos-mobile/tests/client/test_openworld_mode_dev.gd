extends GutTest

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")
const RegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const RouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")

func test_openworld_registry_points_to_official_screen() -> void:
	assert_true(RegistryScript.is_registered("openworld"))
	assert_eq(RegistryScript.normalize_mode_id("openworld_bosque"), "openworld")
	assert_eq(RegistryScript.screen_path("openworld"), "res://modes/openworld/openworld_forest_screen.gd")

func test_mode_shell_is_fullscreen_without_app_chrome() -> void:
	assert_true(RouteContractScript.is_fullscreen_gameplay("mode_shell"))
	assert_false(RouteContractScript.shows_app_chrome("mode_shell"))

func test_collection_cancels_when_player_moves() -> void:
	var model = ModelScript.new()
	var start := model.start_collection("galho")
	assert_true(bool(start.get("ok", false)))
	var cancel := model.advance_collection(0.2, true)
	assert_true(bool(cancel.get("cancelled", false)))
	assert_true(model.active_collection.is_empty())

func test_pocket_full_blocks_collection() -> void:
	var model = ModelScript.new()
	for _index in 20:
		model.add_to_pocket("pedra_pequena")
	assert_gt(model.pocket_weight(), model.capacity() - 0.1)
	var result := model.start_collection("pedra")
	assert_false(bool(result.get("ok", true)))
	assert_eq(result.get("reason"), "pocket_full")

func test_deposit_moves_pocket_to_chest() -> void:
	var model = ModelScript.new()
	model.add_to_pocket("galho", 2)
	model.add_to_pocket("folha", 3)
	var result := model.deposit_all()
	assert_true(bool(result.get("ok", false)))
	assert_true(model.pocket.is_empty())
	assert_eq(int(model.chest.get("galho", 0)), 2)
	assert_eq(int(model.chest.get("folha", 0)), 3)

func test_crafting_consumes_local_materials_and_sets_upgrade() -> void:
	var model = ModelScript.new()
	model.chest = {"galho": 4, "folha": 3, "resina": 1}
	assert_true(model.can_craft("bolsa_simples_1"))
	var result := model.craft("bolsa_simples_1")
	assert_true(bool(result.get("ok", false)))
	assert_true(model.has_upgrade("bolsa_simples_1"))
	assert_eq(model.capacity(), 25.0)
	assert_eq(int(model.chest.get("galho", 0)), 0)

func test_result_payload_is_preview_local_only() -> void:
	var model = ModelScript.new()
	model.chest = {"galho": 3, "cinzas_preview": 2}
	var payload := model.result_payload(12.5)
	assert_eq(payload.get("mode_id"), "openworld")
	assert_eq(payload.get("ruleset_id"), "openworld_forest_ruleset_v0")
	assert_true(int(payload.get("activity_score", 0)) > 0)
	assert_true(Dictionary(payload.get("deposited_items", {})).has("cinzas_preview"))

func test_visual_screen_instantiates_fullscreen_with_joystick_hud_and_sheet() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	assert_eq(screen.name, "OpenworldForestScreen")
	assert_true(screen is Control)
	assert_true(screen.find_child("OpenworldForestWorldView", true, false) is SubViewportContainer)
	assert_true(screen.find_child("OpenworldForestSubViewport", true, false) is SubViewport)
	assert_true(screen.find_child("OpenworldForestWorld2D", true, false) is Node2D)
	assert_true(screen.find_child("OpenworldPlayer", true, false) is CharacterBody2D)
	assert_true(screen.find_child("OpenworldBoundaryWalls", true, false) is StaticBody2D)
	assert_not_null(screen.find_child("OpenworldVirtualJoystick", true, false))
	assert_not_null(screen.find_child("OpenworldHudTop", true, false))
	assert_not_null(screen.find_child("OpenworldInventoryButton", true, false))
	assert_not_null(screen.find_child("OpenworldBackButton", true, false))
	assert_null(screen.find_child("OpenworldForestBoard", true, false))

func test_visual_screen_debug_joystick_moves_player_for_smoke_tests() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var before := screen.get_player_position()
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await wait_seconds(0.12)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_gt(screen.get_player_position().x, before.x)

func test_openworld_input_map_registers_wasd_and_arrow_actions() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	for action_name: String in [
		"openworld_move_left",
		"openworld_move_right",
		"openworld_move_up",
		"openworld_move_down",
	]:
		assert_true(InputMap.has_action(action_name), "%s should exist" % action_name)

func test_openworld_wasd_moves_player_without_touching_ui() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var before := screen.get_player_position()
	Input.action_press("openworld_move_right")
	await wait_seconds(0.16)
	Input.action_release("openworld_move_right")
	await get_tree().process_frame
	assert_gt(screen.get_player_position().x, before.x)

func test_openworld_diagonal_input_is_limited_to_unit_speed() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.set_player_position_for_tests(Vector2(360, 360))
	var origin := screen.get_player_position()
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await wait_seconds(0.20)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	var right_distance := screen.get_player_position().distance_to(origin)
	screen.set_player_position_for_tests(Vector2(360, 360))
	await get_tree().process_frame
	screen.set_debug_joystick_vector(Vector2(1, 1))
	await wait_seconds(0.20)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	var diagonal_distance := screen.get_player_position().distance_to(Vector2(360, 360))
	assert_lte(diagonal_distance, right_distance + 4.0)

func test_openworld_player_collides_with_chest_tree_and_rock() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	await _expect_obstacle_blocks(screen, "chest_home", Vector2.RIGHT)
	await _expect_obstacle_blocks(screen, "tree_large_mid", Vector2.RIGHT)
	await _expect_obstacle_blocks(screen, "rock_large_path", Vector2.RIGHT)

func test_openworld_world_borders_keep_player_inside_forest_bounds() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.set_player_position_for_tests(Vector2(24, 330))
	screen.set_debug_joystick_vector(Vector2.LEFT)
	await wait_seconds(0.30)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_gte(screen.get_player_position().x, 19.0)
	screen.set_player_position_for_tests(Vector2(936, 330))
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await wait_seconds(0.30)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_lte(screen.get_player_position().x, 941.0)

func test_openworld_resources_are_pass_through_and_still_collectible() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var world = screen.call("get_openworld_world_2d")
	var resource_position: Vector2 = world.call("resource_position", "galho")
	screen.set_player_position_for_tests(resource_position + Vector2(-90, 0))
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await wait_seconds(0.80)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_gt(screen.get_player_position().x, resource_position.x + 18.0)
	screen.set_player_position_for_tests(resource_position)
	await wait_seconds(1.45)
	assert_true(Dictionary(screen.get_model().pocket).has("galho"))

func test_openworld_moving_during_collection_cancels_collection() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.set_player_position_for_tests(Vector2(410, 510))
	await wait_seconds(0.20)
	assert_false(Dictionary(screen.get_model().active_collection).is_empty())
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await wait_seconds(0.12)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_true(Dictionary(screen.get_model().active_collection).is_empty())

func test_openworld_chest_blocks_body_but_deposit_area_is_larger() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var world = screen.call("get_openworld_world_2d")
	var chest_interaction_radius: float = world.call("chest_interaction_radius")
	var chest_collision_radius: float = world.call("chest_collision_radius")
	assert_gt(chest_interaction_radius, chest_collision_radius)
	screen.get_model().add_to_pocket("galho", 2)
	screen.set_player_position_for_tests(Vector2(220, 250) + Vector2(chest_collision_radius + 24.0, 0))
	await get_tree().process_frame
	screen.call("_deposit_near_chest")
	await get_tree().process_frame
	assert_true(Dictionary(screen.get_model().pocket).is_empty())
	assert_eq(int(Dictionary(screen.get_model().chest).get("galho", 0)), 2)

func test_openworld_free_joystick_activates_anywhere_drags_and_resets() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.begin_free_joystick_for_tests(Vector2(210, 420))
	screen.drag_free_joystick_for_tests(Vector2(275, 420))
	assert_gt(screen.get_joystick_vector_for_tests().x, 0.5)
	assert_lte(screen.get_joystick_vector_for_tests().length(), 1.0)
	screen.end_free_joystick_for_tests()
	assert_eq(screen.get_joystick_vector_for_tests(), Vector2.ZERO)

func test_openworld_pointer_over_hud_does_not_activate_free_joystick() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(24, 24)
	screen.call("_on_world_gui_input", press)
	assert_eq(screen.get_joystick_vector_for_tests(), Vector2.ZERO)

func test_technical_details_start_hidden_in_inventory_sheet() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var inventory := screen.find_child("OpenworldInventoryButton", true, false) as Button
	assert_not_null(inventory)
	inventory.pressed.emit()
	await get_tree().process_frame
	assert_not_null(screen.find_child("OpenworldInventorySheet", true, false))
	assert_null(screen.find_child("OpenworldTechnicalDetails", true, false))

func _expect_obstacle_blocks(screen, object_id: String, movement_direction: Vector2) -> void:
	var world = screen.call("get_openworld_world_2d")
	var obstacle_position: Vector2 = world.call("obstacle_position", object_id)
	var obstacle_radius: float = world.call("obstacle_collision_radius", object_id)
	var start := obstacle_position - movement_direction.normalized() * (obstacle_radius + 44.0)
	screen.set_player_position_for_tests(start)
	await get_tree().process_frame
	screen.set_debug_joystick_vector(movement_direction)
	await wait_seconds(0.48)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	var final_distance: float = screen.get_player_position().distance_to(obstacle_position)
	assert_gte(final_distance, obstacle_radius + 18.0, "%s should block player body" % object_id)
