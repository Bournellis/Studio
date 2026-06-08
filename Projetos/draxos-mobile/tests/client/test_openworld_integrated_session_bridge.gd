extends GutTest

const BridgeScript := preload("res://modes/openworld/openworld_integrated_session_bridge.gd")
const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

class FakeSessionStore:
	extends Node

	var active_save_type := "normal"
	var access_token := ""
	var apply_ok := true
	var openworld_local_state: Dictionary = {}
	var openworld_durable_progress_state: Dictionary = {}
	var openworld_pending_ops_state: Dictionary = {}
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

	func remember_openworld_active_session_state(state: Dictionary) -> void:
		openworld_local_state = {
			"schema_version": "openworld_forest_local_state_v2",
			"active_session_cache": state.duplicate(true),
		}
		if not openworld_durable_progress_state.is_empty():
			openworld_local_state["durable_progress_cache"] = openworld_durable_progress_state.duplicate(true)
		if not openworld_pending_ops_state.is_empty():
			openworld_local_state["pending_ops_cache"] = openworld_pending_ops_state.duplicate(true)

	func remember_openworld_local_state(state: Dictionary) -> void:
		remember_openworld_active_session_state(state)

	func openworld_active_session_snapshot() -> Dictionary:
		if str(openworld_local_state.get("schema_version", "")) == "openworld_forest_local_state_v2":
			return Dictionary(openworld_local_state.get("active_session_cache", {})).duplicate(true)
		return openworld_local_state.duplicate(true)

	func openworld_local_snapshot() -> Dictionary:
		return openworld_active_session_snapshot()

	func remember_openworld_durable_progress_state(progress: Dictionary) -> void:
		openworld_durable_progress_state = progress.duplicate(true)
		if str(openworld_local_state.get("schema_version", "")) == "openworld_forest_local_state_v2":
			openworld_local_state["durable_progress_cache"] = openworld_durable_progress_state.duplicate(true)

	func openworld_durable_progress_snapshot() -> Dictionary:
		return openworld_durable_progress_state.duplicate(true)

	func remember_openworld_pending_ops_state(state: Dictionary) -> void:
		openworld_pending_ops_state = state.duplicate(true)
		if str(openworld_local_state.get("schema_version", "")) == "openworld_forest_local_state_v2":
			openworld_local_state["pending_ops_cache"] = openworld_pending_ops_state.duplicate(true)

	func openworld_pending_ops_snapshot() -> Dictionary:
		return openworld_pending_ops_state.duplicate(true)

	func clear_openworld_pending_ops_state() -> void:
		openworld_pending_ops_state = {}
		if str(openworld_local_state.get("schema_version", "")) == "openworld_forest_local_state_v2":
			openworld_local_state.erase("pending_ops_cache")

	func clear_openworld_active_session_state() -> void:
		if str(openworld_local_state.get("schema_version", "")) == "openworld_forest_local_state_v2":
			openworld_local_state.erase("active_session_cache")
			if openworld_durable_progress_state.is_empty():
				openworld_local_state = {}
			else:
				openworld_local_state["durable_progress_cache"] = openworld_durable_progress_state.duplicate(true)
			if not openworld_pending_ops_state.is_empty():
				openworld_local_state["pending_ops_cache"] = openworld_pending_ops_state.duplicate(true)
			return
		openworld_local_state = {}

	func clear_openworld_local_state() -> void:
		clear_openworld_active_session_state()

	func ensure_session_id() -> String:
		return "telemetry-session"

class FakeSupabaseClient:
	extends Node

	var state_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var start_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var complete_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var abandon_result: Dictionary = {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var checkpoint_results: Array[Dictionary] = []
	var state_calls: Array[Dictionary] = []
	var start_calls: Array[Dictionary] = []
	var complete_calls: Array[Dictionary] = []
	var abandon_calls: Array[Dictionary] = []
	var checkpoint_calls: Array[Dictionary] = []
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

	func checkpoint_mode_session(request_id: String, payload: Dictionary, token: String, request_hash: String) -> Dictionary:
		checkpoint_calls.append({
			"request_id": request_id,
			"payload": payload.duplicate(true),
			"token": token,
			"request_hash": request_hash,
		})
		if not checkpoint_results.is_empty():
			return checkpoint_results.pop_front()
		return {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}

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
		return {"ok": false, "error": {"code": "LEGACY_EVENT_FORBIDDEN_IN_TEST"}}

func test_start_session_prepares_idempotent_request_hydrates_and_caches_session() -> void:
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
	assert_eq(str(client.start_calls[0].get("request_hash", "")), "hash-1")
	assert_eq(str(store.openworld_active_session_snapshot().get("session_id", "")), "session-start")
	assert_eq(int(Dictionary(store.openworld_durable_progress_snapshot().get("pocket", {})).get("galho", 0)), 2)

func test_resume_applies_matching_remote_durable_metadata_when_idle() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	store.openworld_local_state = _local_state("session-local", 4, {
		"chest": {"galho": 2},
		"collected_nodes": {"node_galho_01": true},
		"checkpoint": {"accepted_checkpoint_id": "session-local-000001", "client_sequence": 1},
	})
	var bridge = _bridge(model, client, store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": _session_payload("session-local", 9, {
				"chest": {"folha": 5},
				"checkpoint": {"accepted_checkpoint_id": "session-local-000001", "client_sequence": 1},
			}),
		},
	}

	await bridge.resume_or_start_session()

	assert_eq(bridge.server_session_id(), "session-local")
	assert_eq(bridge.snapshot_revision(), 9)
	assert_eq(int(model.chest.get("galho", 0)), 0)
	assert_eq(int(model.chest.get("folha", 0)), 5)
	assert_eq(str(model.last_message), "Bosque salvo no servidor.")

func test_resume_uses_matching_session_list_entry_when_active_session_is_missing() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	store.openworld_local_state = _local_state("session-listed-local", 4, {
		"chest": {"galho": 2},
		"checkpoint": {"accepted_checkpoint_id": "session-listed-local-000001", "client_sequence": 1},
	})
	var bridge = _bridge(model, client, store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": {},
			"sessions": [
				_session_payload("session-listed-local", 7, {
					"chest": {"folha": 5},
					"checkpoint": {"accepted_checkpoint_id": "session-listed-local-000001", "client_sequence": 1},
				}),
			],
		},
	}

	await bridge.resume_or_start_session()

	assert_eq(bridge.server_session_id(), "session-listed-local")
	assert_eq(bridge.snapshot_revision(), 7)
	assert_eq(client.start_calls.size(), 0)
	assert_eq(int(model.chest.get("galho", 0)), 0)
	assert_eq(int(model.chest.get("folha", 0)), 5)
	assert_eq(str(store.openworld_active_session_snapshot().get("session_id", "")), "session-listed-local")

func test_resume_preserves_live_local_session_when_state_omits_active_session() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var local_state := _local_state("session-local-omitted", 4, {
		"pocket": {"galho": 1},
		"checkpoint": {"accepted_checkpoint_id": "session-local-omitted-000001", "client_sequence": 1},
	})
	local_state["checkpoint_dirty"] = true
	local_state["client_sequence"] = 2
	local_state["pending_operations"] = [
		{"op_id": "owop_local_omitted", "type": "deposit_all"},
	]
	store.openworld_local_state = local_state
	var bridge = _bridge(model, client, store)
	client.state_result = {
		"ok": true,
		"body": {
			"active_session": {},
			"sessions": [],
		},
	}
	client.checkpoint_results = [
		{"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}},
	]

	await bridge.resume_or_start_session()

	assert_eq(bridge.server_session_id(), "session-local-omitted")
	assert_eq(client.start_calls.size(), 0)
	assert_true(bridge.has_pending_events())
	assert_eq(Array(store.openworld_pending_ops_snapshot().get("operations", [])).size(), 1)
	assert_eq(str(store.openworld_active_session_snapshot().get("session_id", "")), "session-local-omitted")
	assert_string_contains(str(model.last_message), "pendentes")

func test_resume_discards_expired_remote_session_fallback_and_starts_new_visit() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	client.state_result = {
		"ok": true,
		"body": {
			"server_time": _unix_future(0),
			"active_session": {},
			"sessions": [
				_session_payload("session-expired", 9, {
					"chest": {"galho": 4},
					"collected_nodes": {"node_galho_01": true},
				}, _unix_past(7201), _unix_past(1)),
			],
		},
	}
	client.start_result = {
		"ok": true,
		"body": {
			"session": _session_payload("session-new", 1, {
				"chest": {"galho": 4},
				"collected_nodes": {},
			}),
		},
	}

	await bridge.resume_or_start_session()

	assert_eq(bridge.server_session_id(), "session-new")
	assert_eq(client.start_calls.size(), 1)
	assert_false(bool(Dictionary(bridge.debug_snapshot()).get("checkpoint_dirty", true)))
	assert_false(bridge.has_pending_collected_node("node_galho_01"))
	assert_eq(int(model.chest.get("galho", 0)), 4)
	assert_eq(str(model.last_message), "Nova visita ao Bosque.")

func test_resume_discards_expired_local_cache_when_server_has_no_active_session() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	store.openworld_local_state = _local_state("session-local-expired", 8, {
		"chest": {"galho": 9},
		"collected_nodes": {"node_galho_01": true},
	}, _unix_past(7201), _unix_past(1))
	store.openworld_pending_ops_state = {
		"schema_version": "openworld_pending_ops_cache_v1",
		"save_type": "normal",
		"session_id": "session-local-expired",
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"operations": [{"op_id": "owop_expired", "type": "deposit_all"}],
	}
	var bridge = _bridge(model, client, store)
	client.state_result = {
		"ok": true,
		"body": {
			"server_time": _unix_future(0),
			"active_session": {},
			"sessions": [],
		},
	}
	client.start_result = {
		"ok": true,
		"body": {
			"session": _session_payload("session-new-local-expired", 1, {
				"chest": {"folha": 2},
				"collected_nodes": {},
			}),
		},
	}

	await bridge.resume_or_start_session()

	assert_eq(bridge.server_session_id(), "session-new-local-expired")
	assert_eq(client.start_calls.size(), 1)
	assert_eq(int(model.chest.get("galho", 0)), 0)
	assert_eq(int(model.chest.get("folha", 0)), 2)
	assert_false(bridge.has_pending_collected_node("node_galho_01"))
	assert_eq(str(store.openworld_active_session_snapshot().get("session_id", "")), "session-new-local-expired")
	assert_true(store.openworld_pending_ops_snapshot().is_empty())

func test_durable_campfire_alias_survives_upgrade_only_snapshot() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-fogueira", 4, {
		"upgrades": {"fogueira_estavel_1": true},
	}))

	assert_true(bool(model.upgrades.get("fogueira_estavel_1", false)))
	assert_true(bool(model.structures.get("fogueira_estavel_1", false)))
	assert_true(bool(Dictionary(store.openworld_durable_progress_snapshot().get("upgrades", {})).get("fogueira_estavel_1", false)))
	assert_true(bool(Dictionary(store.openworld_durable_progress_snapshot().get("structures", {})).get("fogueira_estavel_1", false)))

func test_campfire_craft_checkpoint_uses_explicit_pending_status() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-fogueira-pending", 2, {}))

	bridge.record_event_deferred("craft", {
		"recipe_id": "fogueira_estavel_1",
		"position": {"x": 305, "y": 330},
		"session_seconds": 18,
	})

	assert_string_contains(bridge.pending_summary_text(), "Fogueira")
	assert_eq(str(Dictionary(bridge.debug_snapshot()).get("last_checkpoint_subject", "")), "fogueira_estavel_1")

func test_collect_and_deposit_save_checkpoint_without_legacy_microevents() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-checkpoint", 2, {}))
	model.pocket = {"galho": 1}
	client.checkpoint_results = [_checkpoint_ack("session-checkpoint", 3, "session-checkpoint-000001", 1)]

	bridge.record_event_deferred("collect_complete", {
		"node_id": "node_galho_01",
		"item_id": "galho",
		"position": {"x": 330, "y": 420},
		"session_seconds": 4,
	})
	await bridge.flush_checkpoint(true)

	assert_eq(client.event_calls.size(), 0)
	assert_eq(client.checkpoint_calls.size(), 1)
	var payload := Dictionary(client.checkpoint_calls[0].get("payload", {}))
	var snapshot := Dictionary(payload.get("snapshot_payload", {}))
	var operations := Array(payload.get("operations", []))
	assert_eq(str(store.prepared[0].get("endpoint", "")), "modes/session/checkpoint")
	assert_true(bool(Dictionary(snapshot.get("collected_nodes", {})).get("node_galho_01", false)))
	assert_eq(operations.size(), 1)
	assert_eq(str(Dictionary(operations[0]).get("type", "")), "collect_node")
	assert_eq(str(Dictionary(operations[0]).get("node_id", "")), "node_galho_01")
	assert_true(str(Dictionary(operations[0]).get("op_id", "")).begins_with("owop_"))
	assert_eq(bridge.snapshot_revision(), 3)
	assert_false(bool(bridge.debug_snapshot().get("checkpoint_dirty", true)))
	assert_true(store.openworld_pending_ops_snapshot().is_empty())

func test_checkpoint_network_failure_keeps_local_state_and_retries_successfully() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-retry", 2, {}))
	model.chest = {"galho": 1}
	client.checkpoint_results = [
		{"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}},
		_checkpoint_ack("session-retry", 3, "session-retry-000001", 1),
	]

	bridge.record_event_deferred("deposit_all", {"position": {"x": 220, "y": 250}, "session_seconds": 6})
	await bridge.flush_checkpoint(true)

	assert_eq(client.checkpoint_calls.size(), 1)
	assert_true(bool(bridge.debug_snapshot().get("checkpoint_dirty", false)))
	assert_true(bool(bridge.debug_snapshot().get("event_retry_scheduled", false)))
	assert_eq(Array(store.openworld_pending_ops_snapshot().get("operations", [])).size(), 1)
	assert_eq(int(Dictionary(store.openworld_active_session_snapshot().get("snapshot_payload", {})).get("session_seconds", 0)), 6)

	await bridge.retry_queued_events_now()

	assert_eq(client.checkpoint_calls.size(), 2)
	assert_eq(bridge.snapshot_revision(), 3)
	assert_false(bool(bridge.debug_snapshot().get("checkpoint_dirty", true)))
	assert_true(store.openworld_pending_ops_snapshot().is_empty())

func test_checkpoint_server_cooldown_discards_collect_without_retry_loop() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	var now := _unix_future(0)
	var node_state := {
		"node_galho_01": {
			"last_collected_at": now - 10,
			"next_spawn_at": now + 290,
			"collected_count": 1,
		},
	}
	var snapshot := {
		"node_state": node_state,
		"server_time": now,
		"checkpoint": {"accepted_checkpoint_id": "session-cooldown-000001", "client_sequence": 0},
	}
	bridge.hydrate_session(_session_payload("session-cooldown", 2, snapshot))
	client.state_result = {
		"ok": true,
		"body": {
			"server_time": now,
			"active_session": _session_payload("session-cooldown", 2, snapshot),
		},
	}
	client.checkpoint_results = [{
		"ok": false,
		"body": {"error": {"code": "OPENWORLD_NODE_ON_COOLDOWN"}},
	}]

	bridge.record_event_deferred("collect_complete", {
		"node_id": "node_galho_01",
		"item_id": "galho",
		"position": {"x": 330, "y": 420},
		"session_seconds": 9,
	})
	await bridge.flush_checkpoint(true)

	assert_eq(client.checkpoint_calls.size(), 1)
	assert_eq(client.state_calls.size(), 1)
	assert_false(bridge.has_pending_events())
	assert_false(bridge.has_pending_collected_node("node_galho_01"))
	assert_eq(store.failed.size(), 0)
	assert_true(store.openworld_pending_ops_snapshot().is_empty())
	assert_string_contains(str(model.last_message), "regenerando")
	assert_eq(bridge.pending_summary_text(), "")

func test_complete_session_flushes_checkpoint_before_reward_complete() -> void:
	var model = ModelScript.new()
	var client := FakeSupabaseClient.new()
	var store := FakeSessionStore.new()
	var bridge = _bridge(model, client, store)
	bridge.hydrate_session(_session_payload("session-complete", 4, {"chest": {"galho": 3}}))
	model.chest = {"galho": 3}
	client.checkpoint_results = [_checkpoint_ack("session-complete", 5, "session-complete-000001", 1)]
	client.complete_result = {
		"ok": true,
		"body": {
			"reward": {"resource_delta": {"cinzas": 5}},
			"session": {"id": "session-complete", "status": "completed", "session_seconds": 12},
		},
	}

	bridge.record_event_deferred("deposit_all", {"position": {"x": 220, "y": 250}, "session_seconds": 12})
	var result: Dictionary = await bridge.complete_session(model.result_payload(12.0))

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(store.prepared[0].get("endpoint", "")), "modes/session/checkpoint")
	assert_eq(str(store.prepared[1].get("endpoint", "")), "modes/session/complete")
	assert_eq(str(client.complete_calls[0].get("request_hash", "")), "hash-2")
	assert_eq(int(Dictionary(client.complete_calls[0].get("payload", {})).get("expected_revision", 0)), 5)
	assert_string_contains(bridge.last_result_text, "Recompensa aplicada")
	assert_eq(bridge.session_state(), "completed")
	assert_true(store.openworld_active_session_snapshot().is_empty())
	assert_eq(int(Dictionary(store.openworld_durable_progress_snapshot().get("chest", {})).get("galho", 0)), 3)

func test_abandon_session_uses_request_hash_and_clears_local_checkpoint_cache() -> void:
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
	assert_eq(bridge.server_session_id(), "")
	assert_eq(bridge.session_state(), "preview")
	assert_true(store.openworld_active_session_snapshot().is_empty())

func _bridge(model: Object, client: Node, store: Node):
	add_child_autofree(client)
	add_child_autofree(store)
	var bridge = BridgeScript.new()
	bridge.configure(model, client, store, "token-alpha")
	add_child_autofree(bridge)
	return bridge

func _session_payload(session_id: String, revision: int, snapshot: Dictionary, started_at: int = 0, expires_at: int = 0) -> Dictionary:
	var payload := snapshot.duplicate(true)
	if not payload.has("ruleset_id"):
		payload["ruleset_id"] = ModelScript.RULESET_ID
	if not payload.has("ruleset_version"):
		payload["ruleset_version"] = ModelScript.RULESET_VERSION
	var started := started_at if started_at > 0 else _unix_past(60)
	var expires := expires_at if expires_at > 0 else _unix_future(3600)
	return {
		"id": session_id,
		"status": "started",
		"started_at": started,
		"expires_at": expires,
		"snapshot_revision": revision,
		"snapshot_payload": payload,
	}

func _local_state(session_id: String, revision: int, snapshot: Dictionary, started_at: int = 0, expires_at: int = 0) -> Dictionary:
	var payload := snapshot.duplicate(true)
	payload["ruleset_id"] = ModelScript.RULESET_ID
	payload["ruleset_version"] = ModelScript.RULESET_VERSION
	var started := started_at if started_at > 0 else _unix_past(60)
	var expires := expires_at if expires_at > 0 else _unix_future(3600)
	return {
		"schema_version": "openworld_forest_local_checkpoint_v1",
		"save_type": "normal",
		"session_id": session_id,
		"started_at": started,
		"expires_at": expires,
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"snapshot_revision": revision,
		"accepted_checkpoint_id": str(Dictionary(payload.get("checkpoint", {})).get("accepted_checkpoint_id", "")),
		"client_sequence": int(Dictionary(payload.get("checkpoint", {})).get("client_sequence", 0)),
		"checkpoint_dirty": false,
		"snapshot_payload": payload,
	}

func _unix_future(seconds: int) -> int:
	return int(Time.get_unix_time_from_system()) + seconds

func _unix_past(seconds: int) -> int:
	return int(Time.get_unix_time_from_system()) - seconds

func _checkpoint_ack(session_id: String, revision: int, checkpoint_id: String, client_sequence: int) -> Dictionary:
	return {
		"ok": true,
		"body": {
			"type": "mode_checkpoint_ack",
			"session_id": session_id,
			"checkpoint_id": checkpoint_id,
			"accepted_checkpoint_id": checkpoint_id,
			"snapshot_revision": revision,
			"complete_ready": true,
			"session": _session_payload(session_id, revision, {
				"checkpoint": {
					"accepted_checkpoint_id": checkpoint_id,
					"checkpoint_id": checkpoint_id,
					"client_sequence": client_sequence,
				},
			}),
		},
	}
