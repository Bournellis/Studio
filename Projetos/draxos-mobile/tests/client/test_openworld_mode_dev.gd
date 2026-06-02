extends GutTest

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")
const RegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const RouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const PLAYER_RADIUS := 20.0

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
	assert_eq(payload.get("ruleset_id"), "openworld_forest_ruleset_v1")
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
	assert_false((screen.find_child("OpenworldVirtualJoystick", true, false) as Control).visible)
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
		assert_true(_action_has_keycode_event(action_name), "%s should have web keycode fallback" % action_name)
		assert_true(_action_has_physical_key_event(action_name), "%s should have physical key fallback" % action_name)

func test_openworld_wasd_moves_player_without_touching_ui() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var before := screen.get_player_position()
	_send_key_event(screen, KEY_D, true)
	await wait_seconds(0.16)
	_send_key_event(screen, KEY_D, false)
	await get_tree().process_frame
	assert_gt(screen.get_player_position().x, before.x)

func test_openworld_arrow_key_event_moves_player_without_action_press() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var before := screen.get_player_position()
	_send_key_event(screen, KEY_UP, true)
	await wait_seconds(0.16)
	_send_key_event(screen, KEY_UP, false)
	await get_tree().process_frame
	assert_lt(screen.get_player_position().y, before.y)

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
	for object_id: String in ["chest_home", "tree_large_mid", "rock_large_path"]:
		await _expect_obstacle_blocks(screen, object_id, Vector2.RIGHT)
		await _expect_obstacle_blocks(screen, object_id, Vector2.LEFT)
		await _expect_obstacle_blocks(screen, object_id, Vector2.DOWN)
		await _expect_obstacle_blocks(screen, object_id, Vector2.UP)

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
	screen.set_player_position_for_tests(Vector2(220, 24))
	screen.set_debug_joystick_vector(Vector2.UP)
	await wait_seconds(0.30)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_gte(screen.get_player_position().y, 19.0)
	screen.set_player_position_for_tests(Vector2(220, 1376))
	screen.set_debug_joystick_vector(Vector2.DOWN)
	await wait_seconds(0.30)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_lte(screen.get_player_position().y, 1381.0)

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
	var joystick := screen.find_child("OpenworldVirtualJoystick", true, false) as Control
	assert_not_null(joystick)
	assert_false(joystick.visible)
	_send_mouse_button(screen, Vector2(210, 420), true)
	assert_true(bool(screen.call("is_free_joystick_active_for_tests")))
	assert_true(joystick.visible)
	assert_almost_eq((joystick.position + joystick.size * 0.5).x, 210.0, 1.0)
	assert_almost_eq((joystick.position + joystick.size * 0.5).y, 420.0, 1.0)
	_send_mouse_motion(screen, Vector2(275, 420))
	assert_gt(screen.get_joystick_vector_for_tests().x, 0.5)
	assert_lte(screen.get_joystick_vector_for_tests().length(), 1.0)
	_send_mouse_button(screen, Vector2(275, 420), false)
	assert_eq(screen.get_joystick_vector_for_tests(), Vector2.ZERO)
	assert_false(bool(screen.call("is_free_joystick_active_for_tests")))
	assert_false(joystick.visible)

func test_openworld_pointer_over_hud_does_not_activate_free_joystick() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	_send_mouse_button(screen, Vector2(24, 24), true)
	assert_eq(screen.get_joystick_vector_for_tests(), Vector2.ZERO)
	assert_false(bool(screen.call("is_free_joystick_active_for_tests")))

func test_openworld_pointer_over_inventory_sheet_does_not_activate_free_joystick() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var inventory := screen.find_child("OpenworldInventoryButton", true, false) as Button
	assert_not_null(inventory)
	inventory.pressed.emit()
	await get_tree().process_frame
	var sheet := screen.find_child("OpenworldInventorySheet", true, false) as Control
	assert_not_null(sheet)
	_send_mouse_button(screen, sheet.get_global_rect().get_center(), true)
	assert_eq(screen.get_joystick_vector_for_tests(), Vector2.ZERO)
	assert_false(bool(screen.call("is_free_joystick_active_for_tests")))

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
	var direction := movement_direction.normalized()
	var obstacle_center: Vector2 = world.call("obstacle_collision_center", object_id)
	var obstacle_shape := str(world.call("obstacle_collision_shape", object_id))
	var obstacle_size: Vector2 = world.call("obstacle_collision_size", object_id)
	var obstacle_radius: float = float(world.call("obstacle_collision_radius", object_id))
	var support_distance := _obstacle_support_distance(obstacle_shape, obstacle_size, obstacle_radius, direction)
	var start := obstacle_center - direction * (support_distance + PLAYER_RADIUS + 70.0)
	screen.set_player_position_for_tests(start)
	await get_tree().process_frame
	screen.set_debug_joystick_vector(direction)
	await _wait_physics_frames(48)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	var final_projection: float = (screen.get_player_position() - obstacle_center).dot(direction)
	var minimum_projection: float = -(support_distance + PLAYER_RADIUS - 2.0)
	assert_lte(final_projection, minimum_projection, "%s should block from %s" % [object_id, str(direction)])

func _obstacle_support_distance(shape: String, size: Vector2, radius: float, direction: Vector2) -> float:
	if shape == "rectangle":
		return absf(direction.x) * size.x * 0.5 + absf(direction.y) * size.y * 0.5
	return radius

func _send_key_event(screen, keycode: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	screen.call("_input", event)

func _send_mouse_button(screen, position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	screen.call("_input", event)

func _send_mouse_motion(screen, position: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	screen.call("_input", event)

func _action_has_keycode_event(action_name: String) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey and (event as InputEventKey).keycode != 0:
			return true
	return false

func _action_has_physical_key_event(action_name: String) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey and (event as InputEventKey).physical_keycode != 0:
			return true
	return false

func _wait_physics_frames(frames: int) -> void:
	for _frame in frames:
		await get_tree().physics_frame
