extends GutTest

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")
const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")
const RegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const RouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const PLAYER_RADIUS := 20.0
const TEST_SESSION_ID := "00000000-0000-4000-8000-000000000101"

class FakeOpenworldSupabaseClient:
	extends Node

	var delay_frames := 0
	var state_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var start_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var event_responses: Array[Dictionary] = []
	var state_calls: Array[Dictionary] = []
	var start_calls: Array[Dictionary] = []
	var captured_events: Array[Dictionary] = []

	func enqueue_event_response(response: Dictionary) -> void:
		event_responses.append(response)

	func get_mode_state(mode_id: String, access_token: String) -> Dictionary:
		state_calls.append({
			"mode_id": mode_id,
			"access_token": access_token,
		})
		return state_result

	func start_mode_session(request_id: String, mode_id: String, slice_id: String, access_token: String, request_hash: String) -> Dictionary:
		start_calls.append({
			"request_id": request_id,
			"mode_id": mode_id,
			"slice_id": slice_id,
			"access_token": access_token,
			"request_hash": request_hash,
		})
		return start_result

	func record_mode_session_event(
		request_id: String,
		session_id: String,
		mode_id: String,
		slice_id: String,
		event_type: String,
		expected_revision: int,
		event_payload: Dictionary,
		access_token: String,
		request_hash: String = ""
	) -> Dictionary:
		captured_events.append({
			"request_id": request_id,
			"session_id": session_id,
			"mode_id": mode_id,
			"slice_id": slice_id,
			"event_type": event_type,
			"expected_revision": expected_revision,
			"event_payload": event_payload.duplicate(true),
			"request_hash": request_hash,
		})
		for _frame in delay_frames:
			await get_tree().process_frame
		if event_responses.is_empty():
			return {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
		return event_responses.pop_front()

class FakeOpenworldSessionStore:
	extends Node

	var active_save_type := "normal"
	var access_token := "fake-token"
	var runtime_mutation_allowed := true
	var runtime_block_reason := "Runtime bloqueou mutacao."
	var request_count := 0
	var failed_requests: Array[Dictionary] = []

	func runtime_allows_gameplay_mutation() -> bool:
		return runtime_mutation_allowed

	func runtime_mutation_block_reason() -> String:
		return runtime_block_reason

	func prepare_pending_mutation(endpoint: String, scope_id: String, route_id: String, payload: Dictionary) -> Dictionary:
		request_count += 1
		return {
			"request_id": "00000000-0000-4000-8000-%012d" % request_count,
			"request_hash": "fake:%s:%d" % [endpoint, request_count],
			"endpoint": endpoint,
			"scope_id": scope_id,
			"route_id": route_id,
			"payload": payload.duplicate(true),
		}

	func apply_mode_result(result: Dictionary) -> bool:
		return bool(result.get("ok", false))

	func fail_pending_mutation(request_id: String, body: Dictionary) -> void:
		failed_requests.append({"request_id": request_id, "body": body.duplicate(true)})

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

func test_visit_summary_uses_player_readable_inventory_names() -> void:
	var model = ModelScript.new()
	model.chest = {"galho": 3, "cinzas_preview": 2}
	model.upgrades = {"fogueira_estavel_1": true}
	var summary := model.visit_summary_text(72.0, "Sem recompensa.")
	assert_string_contains(summary, "1m12s")
	assert_string_contains(summary, "Galho x3")
	assert_string_contains(summary, "Cinzas x2")
	assert_string_contains(summary, "Fogueira estavel I")
	assert_string_contains(summary, "Sem recompensa")
	assert_false(summary.contains("{"))

func test_guidance_starts_visible_and_persists_in_snapshot() -> void:
	var model = ModelScript.new()
	assert_true(model.guidance_visible())
	assert_eq(model.guidance_text(), "Explore o Bosque sem pressa.")
	assert_true(model.mark_guidance_step(1))
	assert_eq(int(model.guidance_state().get("current_step", 0)), 2)
	assert_false(model.mark_guidance_step(4))
	model.dismiss_guidance()
	var snapshot := model.snapshot()
	var restored = ModelScript.new()
	restored.apply_snapshot(snapshot)
	assert_false(restored.guidance_visible())
	assert_eq(int(restored.guidance_state().get("current_step", 0)), 2)
	restored.reopen_guidance()
	assert_true(restored.guidance_visible())

func test_ruleset_has_fixed_resources_for_bag_and_stable_campfire_with_slack() -> void:
	var totals: Dictionary = {}
	for node: Dictionary in RulesetScript.resource_fixtures():
		var item_id := str(node.get("item_id", ""))
		totals[item_id] = int(totals.get(item_id, 0)) + int(node.get("quantity", 1))
	assert_gte(int(totals.get("galho", 0)), 7)
	assert_gte(int(totals.get("folha", 0)), 4)
	assert_gte(int(totals.get("resina", 0)), 2)
	assert_gte(int(totals.get("folha_seca", 0)), 3)
	assert_gte(int(totals.get("pedra_pequena", 0)), 2)

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
	assert_not_null(screen.find_child("OpenworldGuidanceBanner", true, false))
	assert_not_null(screen.find_child("OpenworldInventoryButton", true, false))
	assert_not_null(screen.find_child("OpenworldBackButton", true, false))
	var complete := screen.find_child("OpenworldCompleteButton", true, false) as Button
	assert_not_null(complete)
	assert_eq(complete.text, "Encerrar visita")
	assert_null(screen.find_child("OpenworldForestBoard", true, false))

func test_guidance_banner_can_hide_and_reopen_from_session_sheet() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var banner := screen.find_child("OpenworldGuidanceBanner", true, false) as Control
	assert_not_null(banner)
	assert_true(banner.visible)
	var hide := screen.find_child("OpenworldGuidanceHideButton", true, false) as Button
	assert_not_null(hide)
	hide.pressed.emit()
	await get_tree().process_frame
	assert_false(banner.visible)
	screen.get_inventory_sheet().open_sheet("session")
	screen.call("_update_labels")
	await get_tree().process_frame
	var reopen := screen.find_child("OpenworldGuidanceReopenButton", true, false) as Button
	assert_not_null(reopen)
	reopen.pressed.emit()
	await get_tree().process_frame
	assert_true(banner.visible)
	assert_eq(screen.get_model().guidance_text(), "Explore o Bosque sem pressa.")

func test_guidance_advances_after_player_moves() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	assert_eq(int(screen.get_model().guidance_state().get("current_step", 0)), 1)
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await wait_seconds(0.08)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	await get_tree().process_frame
	assert_eq(int(screen.get_model().guidance_state().get("current_step", 0)), 2)

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

func test_stable_campfire_appears_and_blocks_after_upgrade() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var world = screen.call("get_openworld_world_2d")
	assert_false(bool(world.call("structure_visible", "fogueira_estavel_1")))
	assert_false(bool(world.call("structure_collision_enabled", "fogueira_estavel_1")))
	screen.get_model().upgrades["fogueira_estavel_1"] = true
	screen.call("_update_labels")
	await get_tree().process_frame
	assert_true(bool(world.call("structure_visible", "fogueira_estavel_1")))
	assert_true(bool(world.call("structure_collision_enabled", "fogueira_estavel_1")))
	assert_eq(world.call("structure_position", "fogueira_estavel_1"), Vector2(305, 330))
	await _expect_obstacle_blocks(screen, "structure_fogueira_estavel_1", Vector2.RIGHT)

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

func test_deposit_action_requires_near_chest_and_pocket_items() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.set_player_position_for_tests(RulesetScript.chest_position())
	await get_tree().process_frame
	var empty_state: Dictionary = screen.call("_view_state", "")
	assert_false(bool(empty_state.get("deposit_available", true)))
	assert_true(str(empty_state.get("deposit_tooltip", "")).contains("Bolso vazio"))

	screen.get_model().add_to_pocket("galho", 1)
	screen.call("_update_labels")
	await get_tree().process_frame
	var ready_state: Dictionary = screen.call("_view_state", "")
	assert_true(bool(ready_state.get("deposit_available", false)))
	assert_true(str(ready_state.get("status_text", "")).contains("deposito pronto"))

func test_integrated_deposit_updates_local_view_while_pending_and_reconciles_ack() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var chest_position := RulesetScript.chest_position()
	screen.call("_hydrate_integrated_session", _integrated_session(0, chest_position, {"galho": 2}, {}, {}, {}))
	screen.set_player_position_for_tests(chest_position)
	client.delay_frames = 2
	client.enqueue_event_response(_event_ack("deposit_all", 1, {
		"pocket": {},
		"chest": {"galho": 2},
		"last_message": "Bau atualizado.",
	}, chest_position))

	screen.call("_deposit_near_chest")
	await get_tree().process_frame

	assert_true(Dictionary(screen.get_model().pocket).is_empty())
	assert_eq(int(Dictionary(screen.get_model().chest).get("galho", 0)), 2)
	assert_eq(screen.session_state_for_tests(), "pending")
	assert_false(screen.call("_can_complete_integrated"))
	var deposit_event := _captured_event(client, "deposit_all")
	assert_false(deposit_event.is_empty())
	await _wait_process_frames(6)

	assert_eq(screen.session_state_for_tests(), "synced")
	assert_true(Dictionary(screen.get_model().pocket).is_empty())
	assert_eq(int(Dictionary(screen.get_model().chest).get("galho", 0)), 2)
	assert_eq(int(screen.get("_snapshot_revision")), 1)

func test_integrated_back_preserves_pending_deposit_without_blocking_close() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var chest_position := RulesetScript.chest_position()
	screen.call("_hydrate_integrated_session", _integrated_session(0, chest_position, {"galho": 2}, {}, {}, {}))
	screen.set_player_position_for_tests(chest_position)
	client.delay_frames = 4
	client.enqueue_event_response(_event_ack("deposit_all", 1, {
		"pocket": {},
		"chest": {"galho": 2},
		"last_message": "Bau atualizado.",
	}, chest_position))
	var closed := {"value": false}
	screen.close_requested.connect(func() -> void:
		closed["value"] = true
	)

	screen.call("_deposit_near_chest")
	screen.call("_handle_back_requested")
	await get_tree().process_frame

	assert_true(bool(closed.get("value", false)))
	assert_true(str(screen.get_model().last_message).contains("continua salvando"))
	await _wait_process_frames(8)

	assert_true(bool(closed.get("value", false)))
	assert_eq(screen.session_state_for_tests(), "synced")
	assert_eq(int(Dictionary(screen.get_model().chest).get("galho", 0)), 2)

func test_integrated_event_ack_does_not_rollback_player_position() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var start_position := Vector2(220, 330)
	var moved_position := Vector2(520, 760)
	client.delay_frames = 3
	client.enqueue_event_response(_event_ack("move_heartbeat", 1, {
		"last_message": "Movimento salvo."
	}, start_position))
	screen.set_player_position_for_tests(start_position)
	screen.call("_record_integrated_event_deferred", "move_heartbeat", {
		"position": _position_dict(start_position),
		"session_seconds": 1,
	})
	await get_tree().process_frame
	screen.set_player_position_for_tests(moved_position)
	await _wait_process_frames(6)
	assert_eq(screen.get_player_position(), moved_position)
	assert_eq(int(screen.get("_snapshot_revision")), 1)
	var move_event := _captured_event(client, "move_heartbeat")
	assert_false(move_event.is_empty())
	assert_true(Dictionary(move_event.get("event_payload", {})).has("client_position_revision"))

func test_integrated_active_resync_preserves_local_position_and_applies_authoritative_snapshot() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var bridge = screen.call("_ensure_session_bridge")
	var remote_position := Vector2(220, 330)
	var local_position := Vector2(530, 760)
	var node_id := _resource_node_id(screen, "galho")
	var guidance := {
		"version": 1,
		"current_step": 4,
		"completed_steps": [1, 2, 3],
		"dismissed": false,
		"last_seen_at": "2026-06-04T15:00:00Z",
	}
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _integrated_session(8, remote_position, {"folha": 2}, {"galho": 3}, {"bolsa_simples_1": true}, {node_id: true}, TEST_SESSION_ID, guidance),
		},
	}
	screen.set_player_position_for_tests(local_position)
	screen.get_model().active_collection = {"item_id": "galho", "elapsed": 0.3, "duration": 1.0}

	var ok: bool = await bridge.resync_session("Bosque resincronizado.")

	assert_true(ok)
	assert_eq(screen.get_player_position(), local_position)
	assert_eq(int(Dictionary(screen.get_model().pocket).get("folha", 0)), 2)
	assert_eq(int(Dictionary(screen.get_model().chest).get("galho", 0)), 3)
	assert_true(bool(Dictionary(screen.get_model().upgrades).get("bolsa_simples_1", false)))
	assert_eq(int(screen.get_model().guidance_state().get("current_step", 0)), 4)
	assert_true(Dictionary(screen.get_model().active_collection).is_empty())
	assert_true(bool(_resource_node(screen, node_id).get("collected", false)))
	assert_eq(int(screen.get("_snapshot_revision")), 8)

func test_integrated_stale_collection_resync_does_not_rollback_player_position() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var world = screen.call("get_openworld_world_2d")
	var resource_position: Vector2 = world.call("resource_position", "galho")
	var node_id := _resource_node_id(screen, "galho")
	var moved_position := resource_position + Vector2(16, 0)
	client.enqueue_event_response({"ok": false, "body": {"error": {"code": "MODE_SESSION_REVISION_STALE"}}})
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _integrated_session(5, resource_position, {}, {"folha": 2}, {}, {node_id: false}),
		},
	}
	screen.set_player_position_for_tests(resource_position)
	screen.call("_advance_nearby_collection", 0.05)
	await _wait_process_frames(4)
	var active_collection: Dictionary = screen.get_model().active_collection
	active_collection["elapsed"] = float(active_collection.get("duration", 0.1))
	screen.get_model().active_collection = active_collection
	screen.set_player_position_for_tests(moved_position)
	screen.call("_advance_nearby_collection", 0.05)
	await wait_seconds(0.28)
	await _wait_process_frames(8)

	assert_eq(screen.get_player_position(), moved_position)
	assert_eq(int(Dictionary(screen.get_model().chest).get("folha", 0)), 2)
	assert_false(bool(_resource_node(screen, node_id).get("collected", true)))
	assert_false(Dictionary(screen.get("_pending_collected_nodes")).has(node_id))
	assert_eq(int(screen.get("_snapshot_revision")), 5)

func test_integrated_resync_different_session_applies_remote_player_position() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var bridge = screen.call("_ensure_session_bridge")
	var local_position := Vector2(520, 760)
	var remote_position := Vector2(310, 430)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _integrated_session(3, remote_position, {"galho": 1}, {}, {}, {}, "session-new"),
		},
	}
	screen.set_player_position_for_tests(local_position)

	var ok: bool = await bridge.resync_session("Bosque retomado.")

	assert_true(ok)
	assert_eq(bridge.server_session_id(), "session-new")
	assert_eq(screen.get_player_position(), remote_position)
	assert_eq(int(Dictionary(screen.get_model().pocket).get("galho", 0)), 1)

func test_integrated_start_session_applies_remote_player_position() -> void:
	var setup: Dictionary = await _make_integrated_screen_for_manual_bridge()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var bridge = setup.get("bridge")
	var local_position := Vector2(540, 740)
	var remote_position := Vector2(300, 420)
	client.start_result = {
		"ok": true,
		"body": {
			"session": _integrated_session(2, remote_position, {"folha": 1}, {}, {}, {}),
		},
	}
	screen.set_player_position_for_tests(local_position)

	await bridge.start_session()

	assert_eq(screen.get_player_position(), remote_position)
	assert_eq(int(Dictionary(screen.get_model().pocket).get("folha", 0)), 1)
	assert_eq(client.start_calls.size(), 1)

func test_integrated_start_session_uses_live_store_access_token() -> void:
	var setup: Dictionary = await _make_integrated_screen_for_manual_bridge()
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var store: FakeOpenworldSessionStore = setup.get("store")
	var bridge = setup.get("bridge")
	store.access_token = "fresh-token"
	client.start_result = {
		"ok": true,
		"body": {
			"session": _integrated_session(1, Vector2(220, 330), {}, {}, {}, {}),
		},
	}

	await bridge.start_session()

	assert_eq(client.start_calls.size(), 1)
	assert_eq(str(Dictionary(client.start_calls[0]).get("access_token", "")), "fresh-token")

func test_integrated_start_session_blocks_runtime_read_only_mutation() -> void:
	var setup: Dictionary = await _make_integrated_screen_for_manual_bridge()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var store: FakeOpenworldSessionStore = setup.get("store")
	var bridge = setup.get("bridge")
	store.runtime_mutation_allowed = false
	store.runtime_block_reason = "Configuracao remota indisponivel; acoes online de progresso estao pausadas."
	client.start_result = {
		"ok": true,
		"body": {
			"session": _integrated_session(1, Vector2(220, 330), {}, {}, {}, {}),
		},
	}

	await bridge.start_session()

	assert_eq(client.start_calls.size(), 0)
	assert_eq(bridge.session_state(), "blocked")
	assert_true(str(screen.get_model().last_message).contains("pausadas"))

func test_integrated_resume_session_applies_remote_player_position() -> void:
	var setup: Dictionary = await _make_integrated_screen_for_manual_bridge()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var bridge = setup.get("bridge")
	var local_position := Vector2(540, 740)
	var remote_position := Vector2(280, 390)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _integrated_session(4, remote_position, {}, {"galho": 2}, {}, {}),
		},
	}
	screen.set_player_position_for_tests(local_position)

	await bridge.resume_or_start_session()

	assert_eq(screen.get_player_position(), remote_position)
	assert_eq(int(Dictionary(screen.get_model().chest).get("galho", 0)), 2)
	assert_eq(client.start_calls.size(), 0)

func test_integrated_collect_start_stays_local_without_remote_mutation() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var world = screen.call("get_openworld_world_2d")
	var resource_position: Vector2 = world.call("resource_position", "galho")
	screen.set_player_position_for_tests(resource_position)
	screen.call("_advance_nearby_collection", 0.05)
	assert_false(Dictionary(screen.get_model().active_collection).is_empty())
	await _wait_process_frames(6)
	assert_false(Dictionary(screen.get_model().active_collection).is_empty())
	assert_eq(int(screen.get("_snapshot_revision")), 0)
	assert_true(_captured_event(client, "collect_start").is_empty())

func test_integrated_collect_complete_updates_local_pocket_before_batch_ack() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var world = screen.call("get_openworld_world_2d")
	var resource_position: Vector2 = world.call("resource_position", "galho")
	var node_id := _resource_node_id(screen, "galho")
	client.delay_frames = 2
	client.enqueue_event_response(_event_ack("collect_batch", 1, {
		"pocket": {"galho": 1},
		"collected_nodes": {node_id: true},
		"last_message": "+1 Galho no bolso."
	}, resource_position))
	screen.set_player_position_for_tests(resource_position)
	screen.call("_advance_nearby_collection", 0.05)
	var active_collection: Dictionary = screen.get_model().active_collection
	active_collection["elapsed"] = float(active_collection.get("duration", 0.1))
	screen.get_model().active_collection = active_collection
	screen.call("_advance_nearby_collection", 0.05)
	assert_true(Dictionary(screen.get("_pending_collected_nodes")).has(node_id))
	assert_eq(int(Dictionary(screen.get_model().pocket).get("galho", 0)), 1)
	await wait_seconds(0.28)
	await _wait_process_frames(6)
	var batch_event := _captured_event(client, "collect_batch")
	assert_false(batch_event.is_empty())
	assert_eq(Array(Dictionary(batch_event.get("event_payload", {})).get("nodes", [])).size(), 1)
	assert_eq(int(screen.get("_snapshot_revision")), 1)
	assert_false(Dictionary(screen.get("_pending_collected_nodes")).has(node_id))

func test_integrated_deposit_remains_available_during_pending_collect_batch() -> void:
	var setup: Dictionary = await _make_integrated_screen()
	var screen = setup.get("screen")
	var client: FakeOpenworldSupabaseClient = setup.get("client")
	var world = screen.call("get_openworld_world_2d")
	var resource_position: Vector2 = world.call("resource_position", "galho")
	var chest_position := RulesetScript.chest_position()
	var node_id := _resource_node_id(screen, "galho")
	client.delay_frames = 2
	client.enqueue_event_response(_event_ack("collect_batch", 1, {
		"pocket": {"galho": 1},
		"chest": {},
		"collected_nodes": {node_id: true},
		"last_message": "+1 Galho no bolso."
	}, resource_position))
	client.enqueue_event_response(_event_ack("deposit_all", 2, {
		"pocket": {},
		"chest": {"galho": 1},
		"collected_nodes": {node_id: true},
		"last_message": "Bau atualizado."
	}, chest_position))

	screen.set_player_position_for_tests(resource_position)
	screen.call("_advance_nearby_collection", 0.05)
	var active_collection: Dictionary = screen.get_model().active_collection
	active_collection["elapsed"] = float(active_collection.get("duration", 0.1))
	screen.get_model().active_collection = active_collection
	screen.call("_advance_nearby_collection", 0.05)
	assert_eq(int(Dictionary(screen.get_model().pocket).get("galho", 0)), 1)
	assert_true(Dictionary(screen.get("_pending_collected_nodes")).has(node_id))

	screen.set_player_position_for_tests(chest_position)
	screen.call("_update_labels")
	var pending_state: Dictionary = screen.call("_view_state", "")
	assert_true(bool(pending_state.get("deposit_available", false)))
	assert_true(str(pending_state.get("deposit_tooltip", "")).contains("continua salvando"))

	screen.call("_deposit_near_chest")
	await _wait_process_frames(10)

	assert_true(Dictionary(screen.get_model().pocket).is_empty())
	assert_eq(int(Dictionary(screen.get_model().chest).get("galho", 0)), 1)
	assert_eq(client.captured_events.size(), 2)
	assert_eq(str(Dictionary(client.captured_events[0]).get("event_type", "")), "collect_batch")
	assert_eq(str(Dictionary(client.captured_events[1]).get("event_type", "")), "deposit_all")
	assert_eq(int(Dictionary(client.captured_events[0]).get("expected_revision", -1)), 0)
	assert_eq(int(Dictionary(client.captured_events[1]).get("expected_revision", -1)), 1)
	assert_eq(int(screen.get("_snapshot_revision")), 2)

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

func _make_integrated_screen() -> Dictionary:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var client := FakeOpenworldSupabaseClient.new()
	var store := FakeOpenworldSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	screen.configure_integrated_alpha(client, store, "fake-token")
	screen.call("_hydrate_integrated_session", _integrated_session(0, Vector2(220, 330), {}, {}, {}, {}))
	await get_tree().process_frame
	return {"screen": screen, "client": client, "store": store}

func _make_integrated_screen_for_manual_bridge() -> Dictionary:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var client := FakeOpenworldSupabaseClient.new()
	var store := FakeOpenworldSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	var bridge = screen.call("_ensure_session_bridge")
	bridge.configure(screen.get_model(), client, store, "fake-token", Callable(screen, "_apply_remote_snapshot"))
	screen.integration_mode = "integrated_alpha"
	await get_tree().process_frame
	return {"screen": screen, "client": client, "store": store, "bridge": bridge}

func _integrated_session(
	revision: int,
	position: Vector2,
	pocket: Dictionary,
	chest: Dictionary,
	upgrades: Dictionary,
	collected_nodes: Dictionary,
	session_id: String = TEST_SESSION_ID,
	guidance: Dictionary = {}
) -> Dictionary:
	var snapshot_payload := {
		"ruleset_id": "openworld_forest_ruleset_v1",
		"ruleset_version": 1,
		"player_position": _position_dict(position),
		"session_seconds": 1,
		"pocket": pocket.duplicate(true),
		"chest": chest.duplicate(true),
		"upgrades": upgrades.duplicate(true),
		"collected_nodes": collected_nodes.duplicate(true),
		"last_message": "Bosque sincronizado.",
	}
	if not guidance.is_empty():
		snapshot_payload["guidance"] = guidance.duplicate(true)
	return {
		"id": session_id,
		"mode_id": "openworld",
		"slice_id": "forest",
		"ruleset_id": "openworld_forest_ruleset_v1",
		"ruleset_version": 1,
		"status": "started",
		"snapshot_revision": revision,
		"snapshot_payload": snapshot_payload,
	}

func _event_ack(event_type: String, revision: int, snapshot_patch: Dictionary, full_snapshot_position: Vector2) -> Dictionary:
	var patch := snapshot_patch.duplicate(true)
	var pocket := Dictionary(patch.get("pocket", {}))
	var chest := Dictionary(patch.get("chest", {}))
	var upgrades := Dictionary(patch.get("upgrades", {}))
	var collected_nodes := Dictionary(patch.get("collected_nodes", {}))
	return {
		"ok": true,
		"body": {
			"ok": true,
			"type": "mode_event_ack",
			"session_id": TEST_SESSION_ID,
			"mode_id": "openworld",
			"slice_id": "forest",
			"event_type": event_type,
			"revision_after": revision,
			"applied": true,
			"resync_required": false,
			"snapshot_patch": patch,
			"authoritative_fields": patch.keys(),
			"user_message": str(patch.get("last_message", "")),
			"session": _integrated_session(revision, full_snapshot_position, pocket, chest, upgrades, collected_nodes),
		},
	}

func _position_dict(position: Vector2) -> Dictionary:
	return {"x": position.x, "y": position.y}

func _resource_node_id(screen, item_id: String) -> String:
	for node: Dictionary in Array(screen.get("_resource_nodes")):
		if str(node.get("item_id", "")) == item_id:
			return str(node.get("node_id", ""))
	return ""

func _resource_node(screen, node_id: String) -> Dictionary:
	for node: Dictionary in Array(screen.get("_resource_nodes")):
		if str(node.get("node_id", "")) == node_id:
			return node
	return {}

func _captured_event(client: FakeOpenworldSupabaseClient, event_type: String) -> Dictionary:
	for event: Dictionary in client.captured_events:
		if str(event.get("event_type", "")) == event_type:
			return event
	return {}

func _wait_process_frames(frames: int) -> void:
	for _frame in frames:
		await get_tree().process_frame

func _wait_physics_frames(frames: int) -> void:
	for _frame in frames:
		await get_tree().physics_frame
