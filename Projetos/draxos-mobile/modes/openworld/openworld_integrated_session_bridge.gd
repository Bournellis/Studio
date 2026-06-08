class_name OpenworldIntegratedSessionBridge
extends Node

signal state_changed

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

const CHECKPOINT_RETRY_SECONDS := 1.25
const MAX_CHECKPOINT_RETRY_BACKOFF_SECONDS := 8.0
const MAX_LOCAL_SESSION_CACHE_SECONDS := 7200
const LOCAL_SESSION_CACHE_GRACE_SECONDS := 60
const ACTION_SCOPE_TEMPLATE := "mode:openworld:%s"
const SOURCE_ID := "open_mode_shell:openworld"
const LOCAL_STATE_SCHEMA := "openworld_forest_local_checkpoint_v1"
const PENDING_OPS_SCHEMA := "openworld_pending_ops_cache_v1"
const DURABLE_PROGRESS_SCHEMA := "openworld_forest_progress_v2"
const SESSION_PREVIEW := "preview"
const SESSION_STARTING := "starting"
const SESSION_SYNCED := "synced"
const SESSION_PENDING := "pending"
const SESSION_RESYNCING := "resyncing"
const SESSION_COMPLETED := "completed"
const SESSION_OFFLINE := "offline"
const SESSION_BLOCKED := "blocked"

var model: Object = null
var supabase_client: Node = null
var session_store: Node = null
var access_token := ""
var last_result_text := ""

var _server_session_id := ""
var _server_started_at_unix := 0
var _server_expires_at_unix := 0
var _snapshot_revision := 0
var _server_synced := false
var _network_busy := false
var _checkpoint_dirty := false
var _checkpoint_in_flight := false
var _checkpoint_retry_scheduled := false
var _checkpoint_retry_attempts := 0
var _client_sequence := 0
var _accepted_checkpoint_id := ""
var _last_checkpoint_subject := ""
var _pending_collected_nodes: Dictionary = {}
var _local_collected_nodes: Dictionary = {}
var _pending_operations: Array[Dictionary] = []
var _last_pending_request_id := ""
var _last_position_payload: Dictionary = {}
var _last_session_seconds := 0
var _apply_snapshot_callback := Callable()
var _session_state := SESSION_PREVIEW
var _completed := false

func configure(target_model: Object, client: Node, store: Node, token: String, apply_snapshot_callback := Callable()) -> void:
	model = target_model
	supabase_client = client
	session_store = store
	access_token = token.strip_edges()
	_apply_snapshot_callback = apply_snapshot_callback

func is_active() -> bool:
	return supabase_client != null and session_store != null and _active_access_token() != ""

func server_session_id() -> String:
	return _server_session_id

func snapshot_revision() -> int:
	return _snapshot_revision

func durable_progress_revision() -> int:
	var progress := _durable_progress_cache_snapshot()
	if not progress.is_empty() and _durable_progress_matches_context(progress):
		return int(progress.get("progress_revision", _snapshot_revision))
	return _snapshot_revision

func durable_progress_snapshot() -> Dictionary:
	return _durable_progress_cache_snapshot()

func network_busy() -> bool:
	return _network_busy

func has_pending_events() -> bool:
	return not _pending_operations.is_empty() or _checkpoint_dirty or _checkpoint_in_flight or _checkpoint_retry_scheduled

func can_complete() -> bool:
	return _server_session_id != "" and not _completed and _accepted_checkpoint_id != "" and not has_pending_events()

func uses_authority() -> bool:
	return is_active() and _server_session_id != "" and not _completed

func can_record_event() -> bool:
	return uses_authority()

func session_state() -> String:
	return _session_state

func is_completed() -> bool:
	return _completed

func pending_summary_text() -> String:
	if _last_checkpoint_subject == "fogueira_estavel_1":
		if _last_pending_request_id != "" or _checkpoint_in_flight:
			return "Salvando Fogueira..."
		if not _pending_operations.is_empty() or _checkpoint_dirty or _checkpoint_retry_scheduled:
			return "Fogueira pendente de salvamento"
	if _last_pending_request_id != "":
		return "Salvando progresso do Bosque..."
	if _checkpoint_in_flight:
		return "Salvando progresso do Bosque..."
	if not _pending_operations.is_empty() or _checkpoint_dirty:
		return "Alteracoes locais pendentes"
	if _checkpoint_retry_scheduled:
		return "Falha ao salvar; tentando novamente"
	return ""

func has_pending_collected_node(node_id: String) -> bool:
	return bool(_pending_collected_nodes.get(node_id, false)) or bool(_local_collected_nodes.get(node_id, false))

func remember_pending_collected_node(node_id: String) -> void:
	var clean_node_id := node_id.strip_edges()
	if clean_node_id == "":
		return
	_pending_collected_nodes[clean_node_id] = true
	_local_collected_nodes[clean_node_id] = true

func pending_collected_nodes_for_tests() -> Dictionary:
	return _pending_collected_nodes.duplicate(true)

func record_heartbeat_if_due(session_seconds: float, _heartbeat_seconds: float, position_payload: Dictionary) -> void:
	if _server_session_id == "" or _completed:
		return
	_remember_runtime_context(session_seconds, position_payload)
	_save_local_checkpoint_state()

func resume_or_start_session() -> void:
	if _network_busy or _server_session_id != "" or _completed:
		return
	if not is_active():
		_set_model_message("Preview sem recompensa.")
		_server_synced = false
		_session_state = SESSION_PREVIEW
		_emit_state_changed()
		return

	_network_busy = true
	_session_state = SESSION_STARTING
	_set_model_message("Carregando Bosque...")
	_emit_state_changed()
	var loaded_local := _load_local_checkpoint_state()
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, _active_access_token())
	_network_busy = false
	if bool(state_result.get("ok", false)):
		var body := _response_body(state_result)
		var active_session := _active_session_from_body(body)
		if loaded_local and _same_session(active_session):
			_apply_remote_metadata(active_session)
			last_result_text = "Bosque retomado."
			if not _pending_operations.is_empty() or _checkpoint_dirty:
				_set_model_message("Alteracoes locais pendentes; sincronizando.")
				await flush_checkpoint(true)
			else:
				_set_model_message("Bosque salvo no servidor.")
			_emit_state_changed()
			return
		if loaded_local:
			_discard_local_checkpoint_state()
			loaded_local = false
		if not active_session.is_empty() and hydrate_session(active_session, true):
			last_result_text = "Bosque retomado."
			_set_model_message("Bosque retomado.")
			_emit_client_telemetry("mode_session_resumed", {"result": "ok"})
			_emit_state_changed()
			return
		if not loaded_local:
			await start_session()
			if _server_session_id != "":
				_set_model_message("Nova visita ao Bosque.")
				_emit_state_changed()
			return
	if loaded_local:
		_session_state = SESSION_PENDING if _checkpoint_dirty else SESSION_SYNCED
		_set_model_message("Alteracoes locais pendentes; aguardando servidor." if _checkpoint_dirty else "Bosque salvo no servidor.")
		_emit_state_changed()
		return
	var loaded_durable := _load_durable_progress_preview()
	if _is_network_error(state_result):
		_server_synced = false
		_session_state = SESSION_OFFLINE
		_set_model_message("Alteracoes locais pendentes; conexao indisponivel." if loaded_local else ("Cache visual do Bosque carregado. Recompensa indisponivel." if loaded_durable else "Preview sem recompensa. Conexao indisponivel."))
		_emit_client_telemetry("mode_preview_started", {"result": "offline", "error_code": _error_code(state_result)})
	else:
		_set_model_message("Cache visual do Bosque carregado." if loaded_durable else "Preview sem recompensa.")
		_session_state = SESSION_BLOCKED
		_emit_client_telemetry("mode_preview_started", {"result": "state_blocked", "error_code": _error_code(state_result)})
	_emit_state_changed()

func start_session() -> void:
	if _network_busy or _server_session_id != "" or _completed:
		return
	if not is_active():
		_set_model_message("Preview sem recompensa.")
		_server_synced = false
		_session_state = SESSION_PREVIEW
		_emit_state_changed()
		return
	if not _runtime_allows_mutation():
		_runtime_mutation_block_result("modes/session/start")
		return
	_network_busy = true
	_session_state = SESSION_STARTING
	_emit_state_changed()
	var request_payload := {
		"mode_id": ModelScript.MODE_ID,
		"slice_id": ModelScript.SLICE_ID,
	}
	var request: Dictionary = session_store.prepare_pending_mutation(
		"modes/session/start",
		_scope_id(),
		SOURCE_ID,
		request_payload
	)
	_last_pending_request_id = str(request.get("request_id", ""))
	var result: Dictionary = await supabase_client.start_mode_session(
		str(request.get("request_id", "")),
		ModelScript.MODE_ID,
		ModelScript.SLICE_ID,
		_active_access_token(),
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	var body := _response_body(result)
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		_remember_durable_progress_from_body(body)
		hydrate_session(_as_dictionary(body.get("session", {})), true)
		var durable_patch := _durable_progress_patch(_durable_progress_cache_snapshot())
		if not durable_patch.is_empty():
			apply_remote_snapshot(durable_patch, false)
		_last_pending_request_id = ""
		last_result_text = "Bosque iniciado."
		_set_model_message("Bosque pronto.")
		_emit_client_telemetry("mode_session_started", {"result": "ok"})
	else:
		_server_synced = false
		last_result_text = "Preview sem recompensa."
		if _is_network_error(result):
			_session_state = SESSION_OFFLINE
			_set_model_message("Preview sem recompensa. Conexao indisponivel.")
			_emit_client_telemetry("mode_preview_started", {"result": "offline", "error_code": _error_code(result)})
		else:
			_session_state = SESSION_BLOCKED
			_set_model_message("Preview sem recompensa.")
			_emit_client_telemetry("mode_preview_started", {"result": "blocked", "error_code": _error_code(result)})
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_emit_state_changed()

func complete_session(result_payload: Dictionary) -> Dictionary:
	if _network_busy or _checkpoint_in_flight:
		return {"ok": false, "busy": true}
	if _server_session_id == "":
		return {"ok": false, "missing_session": true}
	if _completed:
		return {"ok": false, "completed": true}
	if _accepted_checkpoint_id == "" or _checkpoint_dirty:
		await flush_checkpoint(true)
	if not can_complete():
		last_result_text = "Recompensa pendente de sincronizacao."
		_set_model_message("Salve o checkpoint para encerrar com recompensa.")
		_emit_state_changed()
		return {"ok": false, "pending_sync": true}
	if not _runtime_allows_mutation():
		return _runtime_mutation_block_result("modes/session/complete")
	var payload := result_payload.duplicate(true)
	payload["session_id"] = _server_session_id
	payload["expected_revision"] = _snapshot_revision
	var request: Dictionary = session_store.prepare_pending_mutation(
		"modes/session/complete",
		_scope_id(),
		SOURCE_ID,
		payload
	)
	_last_pending_request_id = str(request.get("request_id", ""))
	_network_busy = true
	_emit_state_changed()
	var result: Dictionary = await supabase_client.complete_mode_session(
		str(request.get("request_id", "")),
		_server_session_id,
		ModelScript.MODE_ID,
		payload,
		_active_access_token(),
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		var body := _response_body(result)
		_remember_durable_progress_from_body(body)
		var reward := _as_dictionary(body.get("reward", {}))
		_last_pending_request_id = ""
		_completed = true
		_session_state = SESSION_COMPLETED
		_checkpoint_dirty = false
		_checkpoint_retry_scheduled = false
		_pending_collected_nodes = {}
		_pending_operations = []
		var reward_summary := _reward_summary(body, reward)
		last_result_text = reward_summary
		_set_model_message(reward_summary)
		_server_synced = true
		_clear_local_checkpoint_state()
		_emit_client_telemetry("mode_session_completed", {
			"result": "ok",
			"reward_status": _reward_status(body, reward),
			"period_key": _period_key(body, reward),
		})
		if _is_cap_zero_completion(body, reward):
			_emit_client_telemetry("mode_cap_zero_completed", {
				"result": "ok",
				"reward_status": "cap_zero",
				"period_key": _period_key(body, reward),
			})
		else:
			_emit_client_telemetry("mode_reward_applied", {
				"result": "ok",
				"reward_status": _reward_status(body, reward),
				"period_key": _period_key(body, reward),
			})
	else:
		_server_synced = false
		last_result_text = "Recompensa pendente de sincronizacao."
		_set_model_message("Recompensa pendente de sincronizacao.")
		_session_state = SESSION_OFFLINE if _is_network_error(result) else SESSION_BLOCKED
		_emit_client_telemetry("mode_sync_failed", {"result": "complete_failed", "error_code": _error_code(result)})
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
		_save_local_checkpoint_state(true)
	_emit_state_changed()
	return result

func abandon_session(reason: String = "player_abandoned") -> Dictionary:
	if _network_busy:
		return {"ok": false, "busy": true}
	if _server_session_id == "":
		return {"ok": false, "missing_session": true}
	if _completed:
		return {"ok": false, "completed": true}
	if not _runtime_allows_mutation():
		return _runtime_mutation_block_result("modes/session/abandon")
	var payload := {
		"session_id": _server_session_id,
		"reason": reason.strip_edges(),
	}
	var request: Dictionary = session_store.prepare_pending_mutation(
		"modes/session/abandon",
		_scope_id(),
		SOURCE_ID,
		payload
	)
	_last_pending_request_id = str(request.get("request_id", ""))
	_network_busy = true
	_session_state = SESSION_PENDING
	_emit_state_changed()
	var result: Dictionary = await supabase_client.abandon_mode_session(
		_last_pending_request_id,
		_server_session_id,
		ModelScript.MODE_ID,
		reason,
		_active_access_token(),
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		_server_session_id = ""
		_snapshot_revision = 0
		_server_synced = false
		_completed = false
		_checkpoint_dirty = false
		_checkpoint_in_flight = false
		_checkpoint_retry_scheduled = false
		_pending_collected_nodes = {}
		_local_collected_nodes = {}
		_pending_operations = []
		_last_pending_request_id = ""
		_accepted_checkpoint_id = ""
		_session_state = SESSION_PREVIEW
		last_result_text = "Sessao abandonada. Resultado descartado."
		_set_model_message("Sessao do Bosque abandonada.")
		_clear_local_checkpoint_state()
		_emit_client_telemetry("mode_session_abandoned", {"result": "ok", "reason": reason.strip_edges()})
	else:
		_server_synced = false
		_session_state = SESSION_OFFLINE if _is_network_error(result) else SESSION_BLOCKED
		_set_model_message("Nao foi possivel abandonar agora. Sessao preservada.")
		_emit_client_telemetry("mode_sync_failed", {"result": "abandon_failed", "error_code": _error_code(result)})
		if not _is_network_error(result):
			session_store.fail_pending_mutation(_last_pending_request_id, _response_body(result))
	_emit_state_changed()
	return result

func hydrate_session(session: Dictionary, apply_remote_position := true) -> bool:
	var session_id := str(session.get("id", "")).strip_edges()
	if session_id == "":
		return false
	_server_session_id = session_id
	_server_started_at_unix = _timestamp_to_unix(session.get("started_at", 0))
	_server_expires_at_unix = _timestamp_to_unix(session.get("expires_at", 0))
	_snapshot_revision = int(session.get("snapshot_revision", 0))
	_completed = str(session.get("status", "started")) == "completed"
	var snapshot_payload := _as_dictionary(session.get("snapshot_payload", session.get("snapshot", {})))
	if not snapshot_payload.is_empty():
		_local_collected_nodes = _true_dictionary(snapshot_payload.get("collected_nodes", {}))
		var checkpoint := _as_dictionary(snapshot_payload.get("checkpoint", {}))
		_accepted_checkpoint_id = str(checkpoint.get("accepted_checkpoint_id", checkpoint.get("checkpoint_id", ""))).strip_edges()
		_client_sequence = maxi(_client_sequence, int(checkpoint.get("client_sequence", _client_sequence)))
		_remember_durable_progress_from_snapshot(snapshot_payload, {
			"last_checkpoint_session_id": session_id,
			"snapshot_revision": _snapshot_revision,
		})
		apply_remote_snapshot(snapshot_payload, apply_remote_position)
	_server_synced = true
	_checkpoint_dirty = false
	_checkpoint_in_flight = false
	_checkpoint_retry_scheduled = false
	_pending_collected_nodes = {}
	_pending_operations = []
	_clear_pending_ops_cache()
	_last_checkpoint_subject = ""
	_session_state = SESSION_COMPLETED if _completed else SESSION_SYNCED
	_save_local_checkpoint_state()
	_emit_state_changed()
	return true

func apply_remote_snapshot(snapshot_payload: Dictionary, apply_remote_position := true) -> void:
	if _apply_snapshot_callback.is_valid():
		_apply_snapshot_callback.call(snapshot_payload, apply_remote_position)
	elif model != null and model.has_method("apply_snapshot"):
		model.apply_snapshot(snapshot_payload)

func apply_station_craft_ack(body: Dictionary) -> void:
	_remember_durable_progress_from_body(body)
	var session := _as_dictionary(body.get("session", {}))
	var session_id := str(body.get("session_id", session.get("id", ""))).strip_edges()
	if session_id != "":
		_server_session_id = session_id
	var revision_after := int(body.get("snapshot_revision", session.get("snapshot_revision", _snapshot_revision)))
	_snapshot_revision = maxi(_snapshot_revision, revision_after)
	var patch := _durable_progress_patch(_durable_progress_cache_snapshot())
	if not patch.is_empty():
		patch["last_message"] = "Pocao preparada."
		apply_remote_snapshot(patch, false)
	_server_synced = not _checkpoint_dirty
	_session_state = SESSION_PENDING if _checkpoint_dirty else SESSION_SYNCED
	_save_local_checkpoint_state()
	_emit_client_telemetry("station_craft_applied", {"result": "ok"})
	_emit_state_changed()

func record_event_deferred(event_type: String, event_payload: Dictionary) -> void:
	if not uses_authority():
		return
	var payload := event_payload.duplicate(true)
	_remember_runtime_context(float(payload.get("session_seconds", _last_session_seconds)), _as_dictionary(payload.get("position", _last_position_payload)))
	match event_type:
		"collect_complete":
			var node_id := str(payload.get("node_id", "")).strip_edges()
			if node_id != "":
				remember_pending_collected_node(node_id)
				_queue_operation({
					"type": "collect_node",
					"node_id": node_id,
					"item_id": str(payload.get("item_id", "")).strip_edges(),
				}, node_id)
		"deposit_all":
			_queue_operation({"type": "deposit_all"}, "deposit_all")
		"craft":
			_queue_operation({
				"type": "craft_recipe",
				"recipe_id": str(payload.get("recipe_id", "")).strip_edges(),
			}, str(payload.get("recipe_id", "")).strip_edges())
		"guidance_update":
			_queue_operation({
				"type": "guidance_update",
				"guidance": _as_dictionary(payload.get("guidance", {})).duplicate(true),
			}, "guidance_update")
		"collect_start", "collect_cancel", "move_heartbeat":
			_save_local_checkpoint_state()
		_:
			_mark_checkpoint_dirty(event_type)

func flush_event_queue() -> void:
	await flush_checkpoint(false)

func flush_checkpoint(force := false) -> Dictionary:
	if _server_session_id == "":
		return {"ok": false, "missing_session": true}
	if _checkpoint_in_flight:
		return {"ok": false, "busy": true}
	if not force and not _checkpoint_dirty:
		return {"ok": true, "skipped": true}
	if not _runtime_allows_mutation():
		_runtime_mutation_block_result("modes/session/checkpoint")
		_save_local_checkpoint_state()
		return {"ok": false, "blocked_by_runtime_config": true}
	if not is_active():
		_session_state = SESSION_OFFLINE
		_save_local_checkpoint_state()
		_emit_state_changed()
		return {"ok": false, "offline": true}
	var payload := _build_checkpoint_payload()
	var sent_operation_ids := _pending_operation_ids()
	var request: Dictionary = session_store.prepare_pending_mutation(
		"modes/session/checkpoint",
		_scope_id(),
		SOURCE_ID,
		payload
	)
	_last_pending_request_id = str(request.get("request_id", ""))
	var sent_sequence := int(payload.get("client_sequence", _client_sequence))
	_checkpoint_in_flight = true
	_session_state = SESSION_PENDING
	_emit_state_changed()
	var result: Dictionary = await supabase_client.checkpoint_mode_session(
		_last_pending_request_id,
		payload,
		_active_access_token(),
		str(request.get("request_hash", ""))
	)
	_checkpoint_in_flight = false
	var body := _response_body(result)
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		_apply_checkpoint_ack(body, sent_sequence, sent_operation_ids)
		_last_pending_request_id = ""
		_checkpoint_retry_attempts = 0
		_checkpoint_retry_scheduled = false
		_emit_client_telemetry("mode_checkpoint_saved", {"result": "ok", "client_sequence": sent_sequence})
	else:
		_server_synced = false
		_checkpoint_dirty = true
		var error_code := _error_code(result)
		if not _is_network_error(result):
			session_store.fail_pending_mutation(_last_pending_request_id, body)
			_session_state = SESSION_BLOCKED
			_set_model_message("Falha ao salvar no servidor. Alteracoes seguem pendentes.")
			_emit_client_telemetry("mode_sync_failed", {"result": "checkpoint_failed", "error_code": error_code})
		else:
			_session_state = SESSION_OFFLINE
			_set_model_message("Alteracoes locais pendentes; tentando novamente.")
			_schedule_checkpoint_retry()
		_save_local_checkpoint_state()
	_emit_state_changed()
	return result

func _apply_checkpoint_ack(body: Dictionary, sent_sequence: int, sent_operation_ids: Array[String] = []) -> void:
	var durable_progress_updated := _remember_durable_progress_from_body(body)
	var session := _as_dictionary(body.get("session", {}))
	var session_id := str(body.get("session_id", session.get("id", ""))).strip_edges()
	if session_id != "":
		_server_session_id = session_id
	var revision_after := int(body.get("snapshot_revision", session.get("snapshot_revision", _snapshot_revision)))
	_snapshot_revision = maxi(_snapshot_revision, revision_after)
	_accepted_checkpoint_id = str(body.get("accepted_checkpoint_id", body.get("checkpoint_id", _accepted_checkpoint_id))).strip_edges()
	_remove_acked_operations(sent_operation_ids)
	var durable_patch := _durable_progress_patch(_durable_progress_cache_snapshot()) if durable_progress_updated else {}
	if not durable_patch.is_empty():
		durable_patch["last_message"] = "Bosque salvo no servidor."
		apply_remote_snapshot(durable_patch, false)
	if sent_sequence >= _client_sequence:
		_checkpoint_dirty = not _pending_operations.is_empty()
		_pending_collected_nodes = {}
		_server_synced = _pending_operations.is_empty()
		_session_state = SESSION_SYNCED if _pending_operations.is_empty() else SESSION_PENDING
		if _pending_operations.is_empty():
			_last_checkpoint_subject = ""
	else:
		_checkpoint_dirty = true
		_server_synced = false
		_session_state = SESSION_PENDING
	_set_model_message("Alteracoes locais pendentes." if _checkpoint_dirty else "Bosque salvo no servidor.")
	_save_local_checkpoint_state()
	if _checkpoint_dirty:
		call_deferred("flush_checkpoint", false)

func _build_checkpoint_payload() -> Dictionary:
	var snapshot_payload := _local_snapshot_payload()
	return {
		"session_id": _server_session_id,
		"mode_id": ModelScript.MODE_ID,
		"slice_id": ModelScript.SLICE_ID,
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"checkpoint_id": _checkpoint_id_for_sequence(_client_sequence),
		"base_revision": _snapshot_revision,
		"client_sequence": _client_sequence,
		"operations": _pending_operations.duplicate(true),
		"visit_snapshot": _visit_snapshot_payload(),
		"snapshot_payload": snapshot_payload,
		"client_summary": {
			"collected_count": _local_collected_nodes.size(),
			"pocket_count": _inventory_count(_as_dictionary(snapshot_payload.get("pocket", {}))),
			"chest_count": _inventory_count(_as_dictionary(snapshot_payload.get("chest", {}))),
		},
	}

func _local_snapshot_payload() -> Dictionary:
	var snapshot_payload: Dictionary = model.snapshot() if model != null and model.has_method("snapshot") else {}
	snapshot_payload["session_seconds"] = _last_session_seconds
	snapshot_payload["collected_nodes"] = _local_collected_nodes.duplicate(true)
	if not _last_position_payload.is_empty():
		snapshot_payload["player_position"] = _last_position_payload.duplicate(true)
	if model != null:
		var active_collection: Dictionary = _as_dictionary(model.get("active_collection"))
		if not active_collection.is_empty():
			snapshot_payload["active_collection"] = active_collection.duplicate(true)
	return snapshot_payload

func _visit_snapshot_payload() -> Dictionary:
	var payload := {
		"session_seconds": _last_session_seconds,
	}
	if not _last_position_payload.is_empty():
		payload["player_position"] = _last_position_payload.duplicate(true)
	return payload

func retry_queued_events_now() -> void:
	_checkpoint_retry_scheduled = false
	await flush_checkpoint(true)

func resync_session(success_message: String) -> bool:
	if not is_active():
		return false
	_session_state = SESSION_RESYNCING
	_emit_state_changed()
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, _active_access_token())
	if not bool(state_result.get("ok", false)):
		_session_state = SESSION_OFFLINE if _is_network_error(state_result) else SESSION_BLOCKED
		_emit_client_telemetry("mode_sync_failed", {"result": "resync_failed", "error_code": _error_code(state_result)})
		_emit_state_changed()
		return false
	var active_session := _active_session_from_body(_response_body(state_result))
	if active_session.is_empty():
		_session_state = SESSION_PREVIEW
		_emit_state_changed()
		return false
	if _same_session(active_session):
		_apply_remote_metadata(active_session)
	else:
		if not hydrate_session(active_session, true):
			_session_state = SESSION_PREVIEW
			_emit_state_changed()
			return false
	_set_model_message(success_message)
	_emit_client_telemetry("mode_session_resynced", {"result": "ok"})
	_emit_state_changed()
	return true

func debug_snapshot() -> Dictionary:
	return {
		"server_session_id": _server_session_id,
		"snapshot_revision": _snapshot_revision,
		"session_state": _session_state,
		"completed": _completed,
		"server_synced": _server_synced,
		"network_busy": _network_busy,
		"pending_event_count": _pending_operations.size(),
		"event_queue_size": _pending_operations.size(),
		"collect_batch_size": 0,
		"event_queue_types": _pending_operation_types(),
		"event_flush_active": _checkpoint_in_flight,
		"event_retry_scheduled": _checkpoint_retry_scheduled,
		"event_retry_attempts": _checkpoint_retry_attempts,
		"checkpoint_dirty": _checkpoint_dirty,
		"checkpoint_in_flight": _checkpoint_in_flight,
		"accepted_checkpoint_id": _accepted_checkpoint_id,
		"last_checkpoint_subject": _last_checkpoint_subject,
		"client_sequence": _client_sequence,
		"last_pending_request_id": _last_pending_request_id,
		"pending_operations": _pending_operations.duplicate(true),
	}

func record_exit_preserved() -> void:
	if _server_session_id == "" or _completed:
		return
	_save_local_checkpoint_state()
	_emit_client_telemetry("mode_session_exit_preserved", {"result": "ok"})

func _queue_operation(operation: Dictionary, checkpoint_subject := "") -> void:
	var next_operation := operation.duplicate(true)
	if str(next_operation.get("op_id", "")).strip_edges() == "":
		next_operation["op_id"] = _operation_id()
	next_operation["queued_at_unix"] = Time.get_unix_time_from_system()
	_pending_operations.append(next_operation)
	_mark_checkpoint_dirty(str(next_operation.get("type", "operation")), checkpoint_subject)

func _operation_id() -> String:
	if session_store != null and session_store.has_method("create_request_id"):
		return "owop_%s" % str(session_store.call("create_request_id"))
	return "owop_%d_%d" % [Time.get_ticks_usec(), randi()]

func _pending_operation_ids() -> Array[String]:
	var result: Array[String] = []
	for operation: Dictionary in _pending_operations:
		var op_id := str(operation.get("op_id", "")).strip_edges()
		if op_id != "":
			result.append(op_id)
	return result

func _pending_operation_types() -> Array[String]:
	var result: Array[String] = []
	for operation: Dictionary in _pending_operations:
		result.append(str(operation.get("type", "operation")))
	return result

func _remove_acked_operations(operation_ids: Array[String]) -> void:
	if operation_ids.is_empty():
		return
	var acked: Dictionary = {}
	for op_id in operation_ids:
		acked[str(op_id)] = true
	var remaining: Array[Dictionary] = []
	for operation: Dictionary in _pending_operations:
		var op_id := str(operation.get("op_id", "")).strip_edges()
		if op_id == "" or not bool(acked.get(op_id, false)):
			remaining.append(operation)
	_pending_operations = remaining
	if _pending_operations.is_empty():
		_clear_pending_ops_cache()
	else:
		_remember_pending_ops_cache()

func _remove_operations_applied_by_progress(progress: Dictionary) -> void:
	if _pending_operations.is_empty():
		return
	var applied_ops := _as_dictionary(progress.get("applied_ops", {}))
	if applied_ops.is_empty():
		return
	var acked: Array[String] = []
	for operation: Dictionary in _pending_operations:
		var op_id := str(operation.get("op_id", "")).strip_edges()
		if op_id != "" and applied_ops.has(op_id):
			acked.append(op_id)
	_remove_acked_operations(acked)

func _mark_checkpoint_dirty(event_type: String, checkpoint_subject := "") -> void:
	_client_sequence += 1
	_checkpoint_dirty = true
	_last_checkpoint_subject = checkpoint_subject.strip_edges()
	_server_synced = false
	_session_state = SESSION_PENDING
	if model != null and str(model.get("last_message")).strip_edges() == "":
		_set_model_message("Alteracoes locais pendentes.")
	_save_local_checkpoint_state()
	_remember_pending_ops_cache()
	_emit_client_telemetry("mode_session_checkpoint_pending", {
		"result": "queued",
		"event_type": event_type,
	})
	_emit_state_changed()
	call_deferred("flush_checkpoint", false)

func _active_session_cache_snapshot() -> Dictionary:
	if session_store == null:
		return {}
	if session_store.has_method("openworld_active_session_snapshot"):
		return _as_dictionary(session_store.call("openworld_active_session_snapshot"))
	if session_store.has_method("openworld_local_snapshot"):
		return _as_dictionary(session_store.call("openworld_local_snapshot"))
	return {}

func _can_remember_active_session_cache() -> bool:
	if session_store == null:
		return false
	return session_store.has_method("remember_openworld_active_session_state") or session_store.has_method("remember_openworld_local_state")

func _remember_active_session_cache(state: Dictionary) -> void:
	if session_store == null:
		return
	if session_store.has_method("remember_openworld_active_session_state"):
		session_store.call("remember_openworld_active_session_state", state)
	elif session_store.has_method("remember_openworld_local_state"):
		session_store.call("remember_openworld_local_state", state)

func _durable_progress_cache_snapshot() -> Dictionary:
	if session_store == null or not session_store.has_method("openworld_durable_progress_snapshot"):
		return {}
	return _as_dictionary(session_store.call("openworld_durable_progress_snapshot"))

func _pending_ops_cache_snapshot() -> Dictionary:
	if session_store == null or not session_store.has_method("openworld_pending_ops_snapshot"):
		return {}
	return _as_dictionary(session_store.call("openworld_pending_ops_snapshot"))

func _load_pending_ops_cache_for_session(session_id: String) -> Array[Dictionary]:
	var cache := _pending_ops_cache_snapshot()
	if cache.is_empty():
		return []
	if str(cache.get("schema_version", "")) != PENDING_OPS_SCHEMA:
		return []
	if str(cache.get("save_type", _active_save_type())) != _active_save_type():
		return []
	if str(cache.get("session_id", "")).strip_edges() != session_id.strip_edges():
		return []
	if str(cache.get("ruleset_id", "")) != ModelScript.RULESET_ID:
		return []
	if int(cache.get("ruleset_version", 0)) != ModelScript.RULESET_VERSION:
		return []
	if not _local_session_cache_is_live(cache):
		_clear_pending_ops_cache()
		return []
	return _operation_array(cache.get("operations", []))

func _remember_pending_ops_cache() -> void:
	if session_store == null or not session_store.has_method("remember_openworld_pending_ops_state"):
		return
	if _pending_operations.is_empty():
		session_store.call("clear_openworld_pending_ops_state")
		return
	session_store.call("remember_openworld_pending_ops_state", {
		"schema_version": PENDING_OPS_SCHEMA,
		"save_type": _active_save_type(),
		"session_id": _server_session_id,
		"started_at": _server_started_at_unix,
		"expires_at": _server_expires_at_unix,
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"client_sequence": _client_sequence,
		"operations": _pending_operations.duplicate(true),
		"updated_at_unix": Time.get_unix_time_from_system(),
	})

func _clear_pending_ops_cache() -> void:
	if session_store != null and session_store.has_method("clear_openworld_pending_ops_state"):
		session_store.call("clear_openworld_pending_ops_state")

func _operation_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var source := _as_array(value)
	for operation_variant: Variant in source:
		var operation := _as_dictionary(operation_variant)
		if operation.is_empty():
			continue
		var op_id := str(operation.get("op_id", "")).strip_edges()
		var op_type := str(operation.get("type", "")).strip_edges()
		if not op_id.begins_with("owop_") or op_type == "":
			continue
		result.append(operation.duplicate(true))
	return result

func _load_durable_progress_preview() -> bool:
	var progress := _durable_progress_cache_snapshot()
	if progress.is_empty() or not _durable_progress_matches_context(progress):
		return false
	var patch := _durable_progress_patch(progress)
	if patch.is_empty():
		return false
	patch["last_message"] = "Cache visual do Bosque carregado."
	apply_remote_snapshot(patch, false)
	return true

func _remember_durable_progress_from_body(body: Dictionary) -> bool:
	if body.is_empty():
		return false
	var durable_progress := _as_dictionary(body.get("durable_progress", {}))
	if not durable_progress.is_empty():
		return _remember_durable_progress(durable_progress)
	var session := _as_dictionary(body.get("session", {}))
	if not session.is_empty():
		return _remember_durable_progress_from_snapshot(_as_dictionary(session.get("snapshot_payload", session.get("snapshot", {}))), {
			"last_checkpoint_session_id": str(session.get("id", body.get("session_id", ""))),
			"snapshot_revision": int(session.get("snapshot_revision", body.get("snapshot_revision", 0))),
		})
	return false

func _remember_durable_progress_from_snapshot(snapshot_payload: Dictionary, metadata: Dictionary = {}) -> bool:
	if snapshot_payload.is_empty():
		return false
	var source := _durable_source_from_snapshot(snapshot_payload)
	if source.is_empty():
		return false
	return _remember_durable_progress(source, metadata)

func _remember_durable_progress(source: Dictionary, metadata: Dictionary = {}) -> bool:
	if session_store == null or not session_store.has_method("remember_openworld_durable_progress_state"):
		return false
	var progress := _normalize_durable_progress(source, metadata)
	if progress.is_empty():
		return false
	session_store.call("remember_openworld_durable_progress_state", progress)
	return true

func _durable_source_from_snapshot(snapshot_payload: Dictionary) -> Dictionary:
	var durable_progress := _as_dictionary(snapshot_payload.get("durable_progress", {}))
	if not durable_progress.is_empty():
		return durable_progress
	if snapshot_payload.has("pocket") or snapshot_payload.has("chest") or snapshot_payload.has("upgrades") or snapshot_payload.has("structures") or snapshot_payload.has("node_state"):
		return snapshot_payload
	var durable_base := _as_dictionary(snapshot_payload.get("durable_base", {}))
	return durable_base

func _normalize_durable_progress(source: Dictionary, metadata: Dictionary = {}) -> Dictionary:
	if source.is_empty() and metadata.is_empty():
		return {}
	var upgrades := _true_dictionary(source.get("upgrades", {}))
	var structures := _true_dictionary(source.get("structures", {}))
	if bool(upgrades.get("fogueira_estavel_1", false)):
		structures["fogueira_estavel_1"] = true
	if bool(structures.get("fogueira_estavel_1", false)):
		upgrades["fogueira_estavel_1"] = true
	var progress := {
		"schema_version": DURABLE_PROGRESS_SCHEMA,
		"save_type": str(source.get("save_type", metadata.get("save_type", _active_save_type()))),
		"ruleset_id": str(source.get("ruleset_id", metadata.get("ruleset_id", ModelScript.RULESET_ID))),
		"ruleset_version": int(source.get("ruleset_version", metadata.get("ruleset_version", ModelScript.RULESET_VERSION))),
		"pocket": _positive_int_dictionary(source.get("pocket", {})),
		"chest": _positive_int_dictionary(source.get("chest", {})),
		"upgrades": upgrades,
		"structures": structures,
		"guidance": _as_dictionary(source.get("guidance", metadata.get("guidance", {}))).duplicate(true),
		"node_state": _as_dictionary(source.get("node_state", metadata.get("node_state", {}))).duplicate(true),
		"reward_ledger": _as_dictionary(source.get("reward_ledger", metadata.get("reward_ledger", {}))).duplicate(true),
		"applied_ops": _as_dictionary(source.get("applied_ops", metadata.get("applied_ops", {}))).duplicate(true),
		"last_checkpoint_session_id": str(source.get("last_checkpoint_session_id", metadata.get("last_checkpoint_session_id", ""))),
		"last_completed_session_id": str(source.get("last_completed_session_id", metadata.get("last_completed_session_id", ""))),
		"progress_revision": int(source.get("progress_revision", metadata.get("progress_revision", metadata.get("snapshot_revision", 0)))),
		"updated_at_unix": int(source.get("updated_at_unix", Time.get_unix_time_from_system())),
	}
	return progress

func _durable_progress_matches_context(progress: Dictionary) -> bool:
	if str(progress.get("save_type", _active_save_type())) != _active_save_type():
		return false
	if str(progress.get("ruleset_id", ModelScript.RULESET_ID)) != ModelScript.RULESET_ID:
		return false
	if int(progress.get("ruleset_version", ModelScript.RULESET_VERSION)) != ModelScript.RULESET_VERSION:
		return false
	return true

func _durable_progress_patch(progress: Dictionary) -> Dictionary:
	if progress.is_empty():
		return {}
	if not _durable_progress_matches_context(progress):
		return {}
	return {
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"pocket": _positive_int_dictionary(progress.get("pocket", {})),
		"chest": _positive_int_dictionary(progress.get("chest", {})),
		"upgrades": _true_dictionary(progress.get("upgrades", {})),
		"structures": _true_dictionary(progress.get("structures", {})),
		"guidance": _as_dictionary(progress.get("guidance", {})).duplicate(true),
		"node_state": _as_dictionary(progress.get("node_state", {})).duplicate(true),
	}

func _load_local_checkpoint_state() -> bool:
	if session_store == null:
		return false
	var local_state := _active_session_cache_snapshot()
	if local_state.is_empty():
		return false
	if str(local_state.get("schema_version", "")) != LOCAL_STATE_SCHEMA:
		return false
	if str(local_state.get("save_type", _active_save_type())) != _active_save_type():
		return false
	if str(local_state.get("ruleset_id", "")) != ModelScript.RULESET_ID:
		return false
	if int(local_state.get("ruleset_version", 0)) != ModelScript.RULESET_VERSION:
		return false
	if not _local_session_cache_is_live(local_state):
		_clear_local_checkpoint_state()
		return false
	var snapshot_payload := _as_dictionary(local_state.get("snapshot_payload", {}))
	if snapshot_payload.is_empty():
		return false
	_server_session_id = str(local_state.get("session_id", "")).strip_edges()
	if _server_session_id == "":
		return false
	_server_started_at_unix = _timestamp_to_unix(local_state.get("started_at", 0))
	_server_expires_at_unix = _timestamp_to_unix(local_state.get("expires_at", 0))
	_snapshot_revision = int(local_state.get("snapshot_revision", 0))
	_accepted_checkpoint_id = str(local_state.get("accepted_checkpoint_id", "")).strip_edges()
	_client_sequence = int(local_state.get("client_sequence", 0))
	_checkpoint_dirty = bool(local_state.get("checkpoint_dirty", false))
	_last_checkpoint_subject = str(local_state.get("last_checkpoint_subject", "")).strip_edges()
	_pending_collected_nodes = _true_dictionary(local_state.get("pending_collected_nodes", {}))
	_pending_operations = _operation_array(local_state.get("pending_operations", []))
	if _pending_operations.is_empty():
		_pending_operations = _load_pending_ops_cache_for_session(_server_session_id)
	if not _pending_operations.is_empty():
		_checkpoint_dirty = true
	_local_collected_nodes = _true_dictionary(snapshot_payload.get("collected_nodes", {}))
	_last_position_payload = _as_dictionary(snapshot_payload.get("player_position", {})).duplicate(true)
	_last_session_seconds = int(snapshot_payload.get("session_seconds", 0))
	_completed = false
	if _pending_operations.is_empty() and not _checkpoint_dirty:
		_remember_durable_progress_from_snapshot(snapshot_payload, {
			"last_checkpoint_session_id": _server_session_id,
			"snapshot_revision": _snapshot_revision,
		})
	apply_remote_snapshot(snapshot_payload, true)
	_server_synced = not _checkpoint_dirty
	_session_state = SESSION_PENDING if _checkpoint_dirty else SESSION_SYNCED
	return true

func _save_local_checkpoint_state(reward_pending := false) -> void:
	if session_store == null or _server_session_id == "" or _completed:
		return
	if not _can_remember_active_session_cache():
		return
	var snapshot_payload := _local_snapshot_payload()
	if _pending_operations.is_empty() and not _checkpoint_dirty:
		_remember_durable_progress_from_snapshot(snapshot_payload, {
			"last_checkpoint_session_id": _server_session_id,
			"snapshot_revision": _snapshot_revision,
		})
	_remember_active_session_cache({
		"schema_version": LOCAL_STATE_SCHEMA,
		"save_type": _active_save_type(),
		"session_id": _server_session_id,
		"started_at": _server_started_at_unix,
		"expires_at": _server_expires_at_unix,
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"snapshot_revision": _snapshot_revision,
		"accepted_checkpoint_id": _accepted_checkpoint_id,
		"client_sequence": _client_sequence,
		"checkpoint_dirty": _checkpoint_dirty,
		"checkpoint_in_flight": _checkpoint_in_flight,
		"last_checkpoint_subject": _last_checkpoint_subject,
		"reward_pending": reward_pending,
		"pending_collected_nodes": _pending_collected_nodes.duplicate(true),
		"pending_operations": _pending_operations.duplicate(true),
		"snapshot_payload": snapshot_payload,
		"updated_at_unix": Time.get_unix_time_from_system(),
	})
	_remember_pending_ops_cache()

func _clear_local_checkpoint_state() -> void:
	if session_store == null:
		return
	if session_store.has_method("clear_openworld_active_session_state"):
		session_store.call("clear_openworld_active_session_state")
	elif session_store.has_method("clear_openworld_local_state"):
		session_store.call("clear_openworld_local_state")
	_clear_pending_ops_cache()

func _discard_local_checkpoint_state() -> void:
	_clear_local_checkpoint_state()
	_server_session_id = ""
	_server_started_at_unix = 0
	_server_expires_at_unix = 0
	_snapshot_revision = 0
	_accepted_checkpoint_id = ""
	_client_sequence = 0
	_checkpoint_dirty = false
	_checkpoint_in_flight = false
	_checkpoint_retry_scheduled = false
	_pending_collected_nodes = {}
	_local_collected_nodes = {}
	_pending_operations = []
	_last_pending_request_id = ""
	_last_checkpoint_subject = ""
	_server_synced = false
	_completed = false
	_session_state = SESSION_PREVIEW

func _apply_remote_metadata(session: Dictionary) -> void:
	if not _same_session(session):
		return
	_snapshot_revision = maxi(_snapshot_revision, int(session.get("snapshot_revision", _snapshot_revision)))
	var snapshot_payload := _as_dictionary(session.get("snapshot_payload", session.get("snapshot", {})))
	var checkpoint := _as_dictionary(snapshot_payload.get("checkpoint", {}))
	_remember_durable_progress_from_snapshot(snapshot_payload, {
		"last_checkpoint_session_id": _server_session_id,
		"snapshot_revision": int(session.get("snapshot_revision", _snapshot_revision)),
	})
	_remove_operations_applied_by_progress(_durable_progress_cache_snapshot())
	var remote_sequence := int(checkpoint.get("client_sequence", -1))
	if remote_sequence >= _client_sequence:
		_accepted_checkpoint_id = str(checkpoint.get("accepted_checkpoint_id", checkpoint.get("checkpoint_id", _accepted_checkpoint_id))).strip_edges()
		if _pending_operations.is_empty():
			_checkpoint_dirty = false
			_pending_collected_nodes = {}
			_last_checkpoint_subject = ""
		else:
			_checkpoint_dirty = true
	_server_synced = not _checkpoint_dirty
	_session_state = SESSION_PENDING if _checkpoint_dirty else SESSION_SYNCED
	_save_local_checkpoint_state()

func _same_session(session: Dictionary) -> bool:
	return not session.is_empty() and str(session.get("id", "")).strip_edges() == _server_session_id

func _active_session_from_body(body: Dictionary) -> Dictionary:
	var now_unix := _body_now_unix(body)
	var active_session := _as_dictionary(body.get("active_session", {}))
	if not active_session.is_empty():
		return active_session if _session_is_live(active_session, now_unix) else {}
	var sessions := _as_array(body.get("sessions", []))
	for session_variant: Variant in sessions:
		var candidate := _as_dictionary(session_variant)
		if str(candidate.get("status", "")) == "started" and _session_is_live(candidate, now_unix):
			return candidate
	return {}

func _local_session_cache_is_live(local_state: Dictionary) -> bool:
	var now_unix := int(Time.get_unix_time_from_system())
	var expires_at := _timestamp_to_unix(local_state.get("expires_at", 0))
	if expires_at <= 0 or expires_at <= now_unix:
		return false
	var started_at := _timestamp_to_unix(local_state.get("started_at", 0))
	if started_at > 0 and now_unix - started_at > MAX_LOCAL_SESSION_CACHE_SECONDS + LOCAL_SESSION_CACHE_GRACE_SECONDS:
		return false
	return true

func _session_is_live(session: Dictionary, now_unix: int) -> bool:
	if str(session.get("status", "")) != "started":
		return false
	var expires_at := _timestamp_to_unix(session.get("expires_at", 0))
	if expires_at <= 0:
		return false
	return expires_at > now_unix

func _body_now_unix(body: Dictionary) -> int:
	var server_now := _timestamp_to_unix(body.get("server_time", 0))
	return server_now if server_now > 0 else int(Time.get_unix_time_from_system())

func _timestamp_to_unix(value: Variant) -> int:
	if value is int:
		return int(value)
	if value is float:
		return int(value)
	var text := str(value).strip_edges()
	if text == "" or text == "<null>":
		return 0
	if text.is_valid_int():
		return int(text)
	var clean := text.replace("Z", "")
	var plus_index := clean.find("+", 19)
	if plus_index >= 0:
		clean = clean.substr(0, plus_index)
	var minus_index := clean.find("-", 19)
	if minus_index >= 0:
		clean = clean.substr(0, minus_index)
	if clean.length() > 19:
		clean = clean.substr(0, 19)
	return int(Time.get_unix_time_from_datetime_string(clean))


func _remember_runtime_context(session_seconds: float, position_payload: Dictionary) -> void:
	_last_session_seconds = maxi(_last_session_seconds, int(session_seconds))
	if not position_payload.is_empty():
		_last_position_payload = position_payload.duplicate(true)

func _checkpoint_id_for_sequence(sequence: int) -> String:
	return "%s-%06d" % [_server_session_id, maxi(0, sequence)]

func _schedule_checkpoint_retry() -> void:
	if _checkpoint_retry_scheduled:
		return
	_checkpoint_retry_scheduled = true
	_checkpoint_retry_attempts += 1
	call_deferred("_retry_checkpoint")

func _retry_checkpoint() -> void:
	if is_inside_tree():
		var delay := minf(MAX_CHECKPOINT_RETRY_BACKOFF_SECONDS, CHECKPOINT_RETRY_SECONDS * float(maxi(1, _checkpoint_retry_attempts)))
		await get_tree().create_timer(delay).timeout
	_checkpoint_retry_scheduled = false
	flush_checkpoint(false)

func _scope_id() -> String:
	return ACTION_SCOPE_TEMPLATE % str(session_store.get("active_save_type"))

func _set_model_message(message: String) -> void:
	if model != null:
		model.set("last_message", message)

func _emit_state_changed() -> void:
	state_changed.emit()

func _emit_client_telemetry(event_type: String, payload: Dictionary) -> void:
	if bool(ProjectSettings.get_setting("draxos_mobile/testing/disable_telemetry", false)):
		return
	if not is_active() or supabase_client == null or not supabase_client.has_method("send_client_telemetry"):
		return
	var body := _telemetry_payload(payload)
	call_deferred("_send_client_telemetry_deferred", event_type, body)

func _send_client_telemetry_deferred(event_type: String, payload: Dictionary) -> void:
	if supabase_client == null or not supabase_client.has_method("send_client_telemetry"):
		return
	await supabase_client.send_client_telemetry(
		_active_access_token(),
		_telemetry_session_id(),
		event_type,
		payload
	)

func _telemetry_payload(payload: Dictionary) -> Dictionary:
	var result := payload.duplicate(true)
	result["mode_id"] = ModelScript.MODE_ID
	result["slice_id"] = ModelScript.SLICE_ID
	result["session_id"] = _server_session_id
	result["revision"] = _snapshot_revision
	result["pending_count"] = 1 if has_pending_events() else 0
	result["save_type"] = _active_save_type()
	result["source"] = SOURCE_ID
	return result

func _telemetry_session_id() -> String:
	if session_store != null and session_store.has_method("ensure_session_id"):
		return str(session_store.ensure_session_id())
	return _server_session_id

func _active_save_type() -> String:
	if session_store == null:
		return "normal"
	return str(session_store.get("active_save_type"))

func _active_access_token() -> String:
	if session_store != null:
		var live_token := str(session_store.get("access_token")).strip_edges()
		if live_token != "":
			return live_token
	return access_token.strip_edges()

func _runtime_allows_mutation() -> bool:
	if session_store != null and session_store.has_method("runtime_allows_gameplay_mutation"):
		return bool(session_store.call("runtime_allows_gameplay_mutation"))
	return true

func _runtime_mutation_block_result(action: String) -> Dictionary:
	var reason := "Acoes online de progresso estao pausadas pela configuracao remota."
	if session_store != null and session_store.has_method("runtime_mutation_block_reason"):
		reason = str(session_store.call("runtime_mutation_block_reason"))
	last_result_text = "Alteracoes locais pendentes; recompensa indisponivel."
	_set_model_message(reason)
	_server_synced = false
	_checkpoint_dirty = true
	_session_state = SESSION_BLOCKED
	_emit_client_telemetry("mode_mutation_blocked", {
		"result": "blocked",
		"action": action,
		"reason": "runtime_read_only",
	})
	_emit_state_changed()
	return {
		"ok": false,
		"blocked_by_runtime_config": true,
		"error": {
			"code": "RUNTIME_MUTATION_BLOCKED",
			"message": reason,
		},
	}

func _reward_summary(body: Dictionary, reward: Dictionary) -> String:
	var reward_text := ""
	if _is_cap_zero_completion(body, reward):
		reward_text = "Limite diario atingido; sem recompensa nova."
	else:
		var delta := _as_dictionary(reward.get("resource_delta", body.get("resource_delta", {})))
		if delta.is_empty():
			reward_text = "Nenhuma recompensa nova."
		else:
			reward_text = "Recompensa aplicada: %s." % _resource_delta_text(delta)
	if model != null and model.has_method("visit_summary_text"):
		return str(model.call("visit_summary_text", _completion_seconds(body), reward_text))
	return "Visita encerrada. %s" % reward_text

func _resource_delta_text(delta: Dictionary) -> String:
	var keys := PackedStringArray()
	for key: String in delta.keys():
		keys.append(key)
	keys.sort()
	var parts := PackedStringArray()
	for key: String in keys:
		var amount := int(delta.get(key, 0))
		if amount != 0:
			parts.append("%s %+d" % [_reward_resource_display_name(key), amount])
	return ", ".join(parts) if not parts.is_empty() else "sem alteracao"

func _completion_seconds(body: Dictionary) -> float:
	var session := _as_dictionary(body.get("session", {}))
	if session.has("session_seconds"):
		return float(session.get("session_seconds", 0.0))
	return float(_last_session_seconds)

func _reward_resource_display_name(resource_id: String) -> String:
	match resource_id:
		"wood":
			return "Madeira"
		"herb":
			return "Ervas"
		"stone":
			return "Pedras"
		"essence":
			return "Essencia"
		"ashes":
			return "Cinzas"
		"bone":
			return "Ossos"
		"bone_dust":
			return "Po de Osso"
		_:
			return resource_id

func _is_cap_zero_completion(body: Dictionary, reward: Dictionary) -> bool:
	return bool(body.get("cap_zero", reward.get("cap_zero", false))) or _reward_status(body, reward) == "cap_zero"

func _reward_status(body: Dictionary, reward: Dictionary) -> String:
	return str(body.get("reward_status", reward.get("reward_status", "applied")))

func _period_key(body: Dictionary, reward: Dictionary) -> String:
	return str(body.get("period_key", reward.get("period_key", "")))

func _response_body(result: Dictionary) -> Dictionary:
	return _as_dictionary(result.get("body", result))

func _error_code(result: Dictionary) -> String:
	var body := _response_body(result)
	var error := _as_dictionary(body.get("error", body))
	return str(error.get("code", result.get("code", "")))

func _is_network_error(result: Dictionary) -> bool:
	var code := _error_code(result)
	return code in ["NETWORK_UNAVAILABLE", "REQUEST_NOT_STARTED", "CLIENT_MISCONFIGURED"]

func _inventory_count(inventory: Dictionary) -> int:
	var total := 0
	for key: String in inventory.keys():
		total += maxi(0, int(inventory.get(key, 0)))
	return total

func _positive_int_dictionary(value: Variant) -> Dictionary:
	var source := _as_dictionary(value)
	var result: Dictionary = {}
	for key: String in source.keys():
		var clean_key := ModelScript.canonical_item_id(str(key))
		var amount := maxi(0, int(source.get(key, 0)))
		if amount > 0:
			result[clean_key] = int(result.get(clean_key, 0)) + amount
	return result

func _true_dictionary(value: Variant) -> Dictionary:
	var source := _as_dictionary(value)
	var result: Dictionary = {}
	for key: String in source.keys():
		if bool(source.get(key, false)):
			result[key] = true
	return result

func _as_array(value: Variant) -> Array:
	return value if value is Array else []

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
