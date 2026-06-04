extends GutTest

const BridgeScript := preload("res://modes/openworld/openworld_integrated_session_bridge.gd")
const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

class FakeSessionStore:
	extends Node

	var active_save_type := "normal"
	var apply_ok := true
	var prepared: Array[Dictionary] = []
	var applied: Array[Dictionary] = []
	var failed: Array[Dictionary] = []

	func prepare_pending_mutation(endpoint: String, scope_id: String, source_id: String, payload: Dictionary) -> Dictionary:
		var index := prepared.size() + 1
		var request := {
			"request_id": "req-%d" % index,
			"request_hash": "hash-%d" % index,
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
		return apply_ok

	func fail_pending_mutation(request_id: String, body: Dictionary) -> void:
		failed.append({
			"request_id": request_id,
			"body": body.duplicate(true),
		})

class FakeSupabaseClient:
	extends Node

	var state_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var start_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var complete_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var abandon_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var event_results: Array[Dictionary] = []
	var state_calls: Array[Dictionary] = []
	var start_calls: Array[Dictionary] = []
	var complete_calls: Array[Dictionary] = []
	var abandon_calls: Array[Dictionary] = []
	var event_calls: Array[Dictionary] = []

	func get_mode_state(mode_id: String, token: String) -> Dictionary:
		state_calls.append({"mode_id": mode_id, "token": token})
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

	func record_mode_session_event(
		request_id: String,
		session_id: String,
		mode_id: String,
		slice_id: String,
		event_type: String,
		expected_revision: int,
		event_payload: Dictionary,
		token: String,
		request_hash: String
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
		if not event_results.is_empty():
			return event_results.pop_front()
		return {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}

func test_start_session_prepares_idempotent_request_and_hydrates_session() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	client.start_result = {
		"ok": true,
		"body": {
			"session": _session_payload("session-start", 3, {"pocket": {"galho": 2}, "last_message": "Snapshot remoto."}),
		},
	}

	await bridge.start_session()

	assert_eq(bridge.server_session_id(), "session-start")
	assert_eq(bridge.snapshot_revision(), 3)
	assert_eq(int(model.pocket.get("galho", 0)), 2)
	assert_eq(str(store.prepared[0].get("endpoint", "")), "modes/session/start")
	assert_eq(str(store.prepared[0].get("scope_id", "")), "mode:openworld:normal")
	assert_eq(str(client.start_calls[0].get("request_hash", "")), "hash-1")

func test_resume_session_hydrates_active_session_without_starting_new_one() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _session_payload("session-resume", 7, {"chest": {"folha": 4}}),
		},
	}

	await bridge.resume_or_start_session()

	assert_eq(bridge.server_session_id(), "session-resume")
	assert_eq(bridge.snapshot_revision(), 7)
	assert_eq(client.start_calls.size(), 0)
	assert_eq(int(model.chest.get("folha", 0)), 4)
	assert_eq(bridge.last_result_text, "Bosque retomado.")

func test_event_queue_keeps_network_failure_and_retries_successfully() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-event", 2, {}))
	client.event_results = [
		{"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}},
		{"ok": true, "body": {"session": _session_payload("session-event", 3, {}), "event": {"message": "Evento aplicado."}}},
	]

	bridge.record_event_deferred("collect_complete", {"node_id": "node-a"})
	await bridge.flush_event_queue()
	var failed_snapshot: Dictionary = bridge.debug_snapshot()
	assert_eq(int(failed_snapshot.get("event_queue_size", 0)), 1)
	assert_true(bool(failed_snapshot.get("event_retry_scheduled", false)))
	assert_eq(client.event_calls.size(), 1)

	await bridge.retry_queued_events_now()
	var retried_snapshot: Dictionary = bridge.debug_snapshot()
	assert_eq(int(retried_snapshot.get("event_queue_size", -1)), 0)
	assert_eq(bridge.snapshot_revision(), 3)
	assert_eq(client.event_calls.size(), 2)
	assert_eq(model.last_message, "Evento aplicado.")

func test_stale_event_resyncs_active_session_and_clears_queue() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-stale", 1, {}))
	client.event_results = [
		{"ok": false, "body": {"error": {"code": "MODE_SESSION_REVISION_STALE"}}},
	]
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _session_payload("session-stale", 9, {"chest": {"madeira": 1}}),
		},
	}

	bridge.record_event_deferred("deposit_all", {"position": {"x": 220, "y": 250}})
	await bridge.flush_event_queue()

	var snapshot: Dictionary = bridge.debug_snapshot()
	assert_eq(int(snapshot.get("event_queue_size", -1)), 0)
	assert_eq(bridge.snapshot_revision(), 9)
	assert_eq(int(model.chest.get("madeira", 0)), 1)
	assert_eq(model.last_message, "Bosque resincronizado. Repita a ultima acao se ela nao apareceu.")
	assert_eq(store.failed.size(), 1)

func test_guidance_update_ack_applies_snapshot_patch() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-guidance", 1, {}))
	var guidance := {
		"version": 1,
		"current_step": 4,
		"completed_steps": [1, 2, 3],
		"dismissed": false,
		"last_seen_at": "2026-06-04T12:00:00Z",
	}
	client.event_results = [
		{
			"ok": true,
			"body": {
				"session": _session_payload("session-guidance", 2, {"guidance": guidance}),
				"snapshot_patch": {"guidance": guidance},
				"event": {"message": "Dicas atualizadas."},
			},
		},
	]

	bridge.record_event_deferred("guidance_update", {"guidance": guidance})
	await bridge.flush_event_queue()

	assert_eq(bridge.snapshot_revision(), 2)
	assert_eq(int(model.guidance_state().get("current_step", 0)), 4)
	assert_eq(model.guidance_text(), "Perto do bau, use Depositar para guardar tudo.")
	assert_eq(model.last_message, "Dicas atualizadas.")

func test_complete_session_uses_request_hash_and_records_reward_summary() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-complete", 4, {"chest": {"galho": 3}}))
	client.complete_result = {
		"ok": true,
		"body": {
			"reward": {"resource_delta": {"cinzas": 5}},
			"session": {"id": "session-complete", "status": "completed"},
		},
	}

	var result: Dictionary = await bridge.complete_session(model.result_payload(12.0))

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(store.prepared[0].get("endpoint", "")), "modes/session/complete")
	assert_eq(str(client.complete_calls[0].get("request_hash", "")), "hash-1")
	assert_eq(str(client.complete_calls[0].get("session_id", "")), "session-complete")
	assert_eq(int(Dictionary(client.complete_calls[0].get("payload", {})).get("expected_revision", 0)), 4)
	assert_string_contains(bridge.last_result_text, "Recompensa aplicada")
	assert_string_contains(bridge.last_result_text, "cinzas +5")
	assert_eq(model.last_message, bridge.last_result_text)
	assert_eq(bridge.session_state(), "completed")
	assert_false(bridge.can_complete())

func test_abandon_session_uses_request_hash_and_clears_active_session() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-abandon", 5, {"pocket": {"galho": 1}}))
	client.abandon_result = {
		"ok": true,
		"body": {
			"session": {"id": "session-abandon", "status": "abandoned"},
		},
	}

	var result: Dictionary = await bridge.abandon_session("player_abandoned")

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(store.prepared[0].get("endpoint", "")), "modes/session/abandon")
	assert_eq(str(client.abandon_calls[0].get("request_hash", "")), "hash-1")
	assert_eq(str(client.abandon_calls[0].get("session_id", "")), "session-abandon")
	assert_eq(str(client.abandon_calls[0].get("reason", "")), "player_abandoned")
	assert_eq(bridge.server_session_id(), "")
	assert_eq(bridge.session_state(), "preview")

func _bridge(model: Object, client: Node, store: Node):
	add_child_autofree(client)
	add_child_autofree(store)
	var bridge = BridgeScript.new()
	bridge.configure(model, client, store, "token-alpha")
	add_child_autofree(bridge)
	return bridge

func _session_payload(session_id: String, revision: int, snapshot: Dictionary) -> Dictionary:
	var payload := snapshot.duplicate(true)
	if not payload.has("ruleset_id"):
		payload["ruleset_id"] = ModelScript.RULESET_ID
	return {
		"id": session_id,
		"status": "started",
		"snapshot_revision": revision,
		"snapshot_payload": payload,
	}
