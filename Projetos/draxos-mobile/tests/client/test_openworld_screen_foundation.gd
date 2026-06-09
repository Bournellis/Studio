extends GutTest

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")
const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")

class FakeSessionStore:
	extends Node

	var active_save_type := "normal"
	var prepared: Array[Dictionary] = []
	var applied: Array[Dictionary] = []
	var failed: Array[Dictionary] = []
	var telemetry_session_id := "telemetry-session"
	var openworld_local_state: Dictionary = {}

	func prepare_pending_mutation(endpoint: String, scope_id: String, source_id: String, payload: Dictionary) -> Dictionary:
		var index := prepared.size() + 1
		var request := {
			"request_id": "screen-req-%d" % index,
			"request_hash": "screen-hash-%d" % index,
		}
		prepared.append({
			"endpoint": endpoint,
			"scope_id": scope_id,
			"source_id": source_id,
			"payload": payload.duplicate(true),
			"request": request.duplicate(true),
		})
		return request

	func apply_mode_result(result: Dictionary) -> bool:
		applied.append(result.duplicate(true))
		return true

	func fail_pending_mutation(request_id: String, body: Dictionary) -> void:
		failed.append({"request_id": request_id, "body": body.duplicate(true)})

	func ensure_session_id() -> String:
		return telemetry_session_id

	func remember_openworld_local_state(state: Dictionary) -> void:
		openworld_local_state = state.duplicate(true)

	func openworld_local_snapshot() -> Dictionary:
		return openworld_local_state.duplicate(true)

	func clear_openworld_local_state() -> void:
		openworld_local_state = {}

class FakeSupabaseClient:
	extends Node

	var state_result: Dictionary = {"ok": true, "body": {"active_session": {}}}
	var start_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var complete_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var abandon_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var checkpoint_results: Array[Dictionary] = []
	var state_delay_frames := 0
	var state_calls: Array[Dictionary] = []
	var start_calls: Array[Dictionary] = []
	var complete_calls: Array[Dictionary] = []
	var abandon_calls: Array[Dictionary] = []
	var checkpoint_calls: Array[Dictionary] = []
	var event_calls: Array[Dictionary] = []
	var telemetry_calls: Array[Dictionary] = []

	func get_mode_state(mode_id: String, token: String) -> Dictionary:
		state_calls.append({"mode_id": mode_id, "token": token})
		for _index in range(state_delay_frames):
			await get_tree().process_frame
		return state_result

	func start_mode_session(request_id: String, mode_id: String, slice_id: String, token: String, request_hash: String) -> Dictionary:
		start_calls.append({
			"request_id": request_id,
			"mode_id": mode_id,
			"slice_id": slice_id,
			"token": token,
			"request_hash": request_hash,
		})
		return start_result

	func complete_mode_session(request_id: String, session_id: String, mode_id: String, payload: Dictionary, token: String, request_hash: String) -> Dictionary:
		complete_calls.append({
			"request_id": request_id,
			"session_id": session_id,
			"mode_id": mode_id,
			"payload": payload.duplicate(true),
			"token": token,
			"request_hash": request_hash,
		})
		return complete_result

	func checkpoint_mode_session(request_id: String, payload: Dictionary, token: String, request_hash: String) -> Dictionary:
		checkpoint_calls.append({
			"request_id": request_id,
			"payload": payload.duplicate(true),
			"token": token,
			"request_hash": request_hash,
		})
		if not checkpoint_results.is_empty():
			return checkpoint_results.pop_front()
		var session_id := str(payload.get("session_id", "screen-session"))
		var sequence := int(payload.get("client_sequence", 0))
		return {
			"ok": true,
			"body": {
				"type": "mode_checkpoint_ack",
				"session_id": session_id,
				"checkpoint_id": str(payload.get("checkpoint_id", "")),
				"accepted_checkpoint_id": str(payload.get("checkpoint_id", "")),
				"snapshot_revision": int(payload.get("base_revision", 0)) + 1,
				"complete_ready": true,
				"session": {
					"id": session_id,
					"status": "started",
					"snapshot_revision": int(payload.get("base_revision", 0)) + 1,
					"snapshot_payload": {
						"ruleset_id": ModelScript.RULESET_ID,
						"checkpoint": {
							"accepted_checkpoint_id": str(payload.get("checkpoint_id", "")),
							"checkpoint_id": str(payload.get("checkpoint_id", "")),
							"client_sequence": sequence,
						},
					},
				},
			},
		}

	func record_mode_session_event(
		request_id: String,
		session_id: String,
		mode_id: String,
		slice_id: String,
		event_type: String,
		expected_revision: int,
		event_payload: Dictionary,
		token: String,
		request_hash: String = ""
	) -> Dictionary:
		event_calls.append({
			"request_id": request_id,
			"session_id": session_id,
			"mode_id": mode_id,
			"slice_id": slice_id,
			"event_type": event_type,
			"expected_revision": expected_revision,
			"event_payload": event_payload.duplicate(true),
			"token": token,
			"request_hash": request_hash,
		})
		return {
			"ok": true,
			"body": {
				"ok": true,
				"type": "mode_event_ack",
				"session_id": session_id,
				"mode_id": mode_id,
				"slice_id": slice_id,
				"event_type": event_type,
				"revision_after": expected_revision + 1,
				"applied": true,
				"resync_required": false,
				"snapshot_patch": {},
				"user_message": "Bosque sincronizado.",
			},
		}

	func abandon_mode_session(request_id: String, session_id: String, mode_id: String, reason: String, token: String, request_hash: String) -> Dictionary:
		abandon_calls.append({
			"request_id": request_id,
			"session_id": session_id,
			"mode_id": mode_id,
			"reason": reason,
			"token": token,
			"request_hash": request_hash,
		})
		return abandon_result

	func send_client_telemetry(token: String, session_id: String, event_type: String, payload: Dictionary) -> Dictionary:
		telemetry_calls.append({
			"token": token,
			"session_id": session_id,
			"event_type": event_type,
			"payload": payload.duplicate(true),
		})
		return {"ok": true}

func before_each() -> void:
	ProjectSettings.set_setting("draxos_mobile/testing/disable_telemetry", false)

func after_each() -> void:
	ProjectSettings.set_setting("draxos_mobile/testing/disable_telemetry", false)

func test_integrated_screen_starts_session_and_reports_synced_state() -> void:
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	client.start_result = {
		"ok": true,
		"body": {
			"session": _session_payload("screen-session", 2, {"last_message": "Bosque online."}),
		},
	}
	var screen = ScreenScript.new()
	screen.configure_integrated_alpha(client, store, "token-alpha")
	add_child_autofree(screen)
	await wait_seconds(0.12)

	assert_eq(screen.session_state_for_tests(), "synced")
	assert_eq(str(client.start_calls[0].get("request_hash", "")), "screen-hash-1")
	assert_eq(str(screen.call("_server_session_id")), "screen-session")
	assert_true(_telemetry_has_event(client, "mode_session_started"))

func test_integrated_bootstrap_hides_world_until_remote_state_arrives() -> void:
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	client.state_delay_frames = 4
	var now_unix := int(Time.get_unix_time_from_system())
	client.state_result = {
		"ok": true,
		"body": {
			"server_time": now_unix,
			"active_session": _session_payload("hidden-bootstrap-session", 7, {
				"last_message": "Bosque online.",
				"node_state": {
					"node_galho_01": {
						"next_spawn_at": now_unix + 300,
					},
				},
			}),
		},
	}
	var screen = ScreenScript.new()
	screen.configure_integrated_alpha(client, store, "token-alpha")
	add_child_autofree(screen)

	var world_view := screen.find_child("OpenworldForestWorldView", true, false) as SubViewportContainer
	assert_not_null(world_view)
	assert_true(screen.bootstrap_loading_for_tests())
	assert_false(world_view.visible)

	await get_tree().process_frame
	assert_false(world_view.visible)

	await wait_seconds(0.18)
	assert_eq(screen.session_state_for_tests(), "synced")
	assert_false(screen.bootstrap_loading_for_tests())
	assert_true(world_view.visible)

func test_preview_result_without_auth_is_explicitly_no_reward() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame

	await screen.call("_show_result")

	assert_eq(screen.session_state_for_tests(), "preview")
	assert_string_contains(screen.get_model().last_message, "sem recompensa")
	assert_string_contains(str(screen.call("_result_text")), "Resumo da visita")
	assert_string_contains(str(screen.call("_result_text")), "Sem recompensa")
	await get_tree().process_frame

func test_back_preserves_online_session_for_resume() -> void:
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _session_payload("resume-session", 4, {}),
		},
	}
	var screen = ScreenScript.new()
	screen.configure_integrated_alpha(client, store, "token-alpha")
	add_child_autofree(screen)
	await wait_seconds(0.12)
	watch_signals(screen)

	var back := screen.find_child("OpenworldBackButton", true, false) as Button
	assert_not_null(back)
	back.pressed.emit()
	await get_tree().process_frame

	assert_signal_emitted(screen, "close_requested")
	assert_eq(client.abandon_calls.size(), 0)
	assert_true(_telemetry_has_event(client, "mode_session_exit_preserved"))

func test_back_with_failed_checkpoint_preserves_pending_state_and_closes() -> void:
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _session_payload("pending-exit-session", 4, {}),
		},
	}
	client.checkpoint_results = [
		{"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}},
		{"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}},
	]
	var screen = ScreenScript.new()
	screen.configure_integrated_alpha(client, store, "token-alpha")
	add_child_autofree(screen)
	await wait_seconds(0.12)
	var bridge = screen.call("_ensure_session_bridge")
	bridge.record_event_deferred("deposit_all", {"position": {"x": 220, "y": 250}, "session_seconds": 8})
	await get_tree().process_frame
	watch_signals(screen)

	var back := screen.find_child("OpenworldBackButton", true, false) as Button
	assert_not_null(back)
	back.pressed.emit()
	await wait_seconds(0.08)

	assert_signal_emitted(screen, "close_requested")
	assert_eq(str(store.openworld_local_snapshot().get("session_id", "")), "pending-exit-session")
	assert_true(Array(store.openworld_local_snapshot().get("pending_operations", [])).size() > 0)
	assert_string_contains(screen.get_model().last_message, "pendentes preservadas")
	assert_true(_telemetry_has_event(client, "mode_session_exit_preserved"))

func test_integrated_completion_result_uses_visit_summary_text() -> void:
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _session_payload("complete-session", 5, {
				"session_seconds": 72,
				"chest": {"galho": 3},
				"upgrades": {"fogueira_estavel_1": true},
				"last_message": "Bosque online.",
			}),
		},
	}
	client.complete_result = {
		"ok": true,
		"body": {
			"reward": {"resource_delta": {"wood": 2}},
			"result_payload": {"session_seconds": 72},
		},
	}
	var screen = ScreenScript.new()
	screen.configure_integrated_alpha(client, store, "token-alpha")
	add_child_autofree(screen)
	await wait_seconds(0.12)
	var bridge = screen.call("_ensure_session_bridge")
	if bridge.has_pending_events():
		await bridge.flush_event_queue()
		await get_tree().process_frame

	await screen.call("_show_result")
	await get_tree().process_frame

	var result_text := str(screen.call("_result_text"))
	assert_string_contains(result_text, "Resumo da visita")
	assert_string_contains(result_text, "Galho x3")
	assert_string_contains(result_text, "Fogueira estavel I")
	assert_string_contains(result_text, "Recompensa aplicada: Madeira +2")
	assert_false(result_text.contains("resource_delta"))

func test_explicit_abandon_requires_confirmation_and_discards_session() -> void:
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	add_child_autofree(client)
	add_child_autofree(store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _session_payload("abandon-session", 3, {"pocket": {"galho": 1}}),
		},
	}
	client.abandon_result = {
		"ok": true,
		"body": {"session": {"id": "abandon-session", "status": "abandoned"}},
	}
	var screen = ScreenScript.new()
	screen.configure_integrated_alpha(client, store, "token-alpha")
	add_child_autofree(screen)
	await wait_seconds(0.12)
	screen.get_inventory_sheet().open_sheet("session")
	screen.call("_update_labels")
	await get_tree().process_frame

	var abandon := screen.find_child("OpenworldSheetAbandonButton", true, false) as Button
	assert_not_null(abandon)
	abandon.pressed.emit()
	await get_tree().process_frame
	assert_true(screen.abandon_confirm_pending_for_tests())
	assert_eq(client.abandon_calls.size(), 0)

	abandon = screen.find_child("OpenworldSheetAbandonButton", true, false) as Button
	assert_not_null(abandon)
	assert_eq(abandon.text, "Confirmar abandono")
	abandon.pressed.emit()
	await wait_seconds(0.08)

	assert_eq(client.abandon_calls.size(), 1)
	assert_eq(str(client.abandon_calls[0].get("request_hash", "")), "screen-hash-1")
	assert_eq(screen.session_state_for_tests(), "preview")
	assert_false(screen.abandon_confirm_pending_for_tests())
	assert_true(_telemetry_has_event(client, "mode_session_abandoned"))

func test_inventory_sheet_uses_dirty_render_signature() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var sheet = screen.get_inventory_sheet()
	sheet.open_sheet("pocket")
	screen.call("_update_labels")
	await get_tree().process_frame
	var first_count := int(sheet.render_count())
	await wait_seconds(0.08)
	var stable_count := int(sheet.render_count())
	assert_eq(stable_count, first_count)

	screen.get_model().add_to_pocket("galho", 1)
	screen.call("_update_labels")
	await get_tree().process_frame
	assert_gt(int(sheet.render_count()), stable_count)

func test_obstacles_are_loaded_from_ruleset_data() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var world = screen.get_openworld_world_2d()
	var obstacles := RulesetScript.obstacles()
	assert_false(obstacles.is_empty())
	var first := obstacles[0] as Dictionary
	var expected_position := Vector2(first.get("position", Vector2.ZERO))
	assert_eq(world.call("obstacle_position", str(first.get("id", ""))), expected_position)

func test_preview_item_ids_keep_clean_player_names() -> void:
	var model = ModelScript.new()
	assert_eq(model.item_display_name("cinzas_preview"), "Cinzas")
	assert_eq(model.item_display_name("resto_ritual"), "Resto ritual")
	assert_eq(model.item_display_name("po_cinzento"), "Po cinzento")
	assert_eq(model.item_display_name("ossos_preview"), "Resto ritual")
	assert_eq(model.item_display_name("po_osso_preview"), "Po cinzento")

func _session_payload(session_id: String, revision: int, snapshot: Dictionary) -> Dictionary:
	var payload := snapshot.duplicate(true)
	if not payload.has("ruleset_id"):
		payload["ruleset_id"] = ModelScript.RULESET_ID
	var now := int(Time.get_unix_time_from_system())
	return {
		"id": session_id,
		"status": "started",
		"started_at": now - 60,
		"expires_at": now + 3600,
		"snapshot_revision": revision,
		"snapshot_payload": payload,
	}

func _telemetry_has_event(client: FakeSupabaseClient, event_type: String) -> bool:
	for call: Dictionary in client.telemetry_calls:
		if str(call.get("event_type", "")) == event_type:
			return true
	return false
