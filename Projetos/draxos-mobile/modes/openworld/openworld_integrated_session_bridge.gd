class_name OpenworldIntegratedSessionBridge
extends Node

signal state_changed

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

const EVENT_RETRY_SECONDS := 1.25
const MAX_EVENT_QUEUE_SIZE := 20
const MAX_EVENT_RETRY_BACKOFF_SECONDS := 8.0
const ACTION_SCOPE_TEMPLATE := "mode:openworld:%s"
const SOURCE_ID := "open_mode_shell:openworld"
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
var _snapshot_revision := 0
var _server_synced := false
var _network_busy := false
var _pending_event_count := 0
var _event_queue: Array[Dictionary] = []
var _event_flush_active := false
var _event_retry_scheduled := false
var _event_retry_attempts := 0
var _client_event_seq := 0
var _pending_collected_nodes: Dictionary = {}
var _last_pending_request_id := ""
var _last_heartbeat_seconds := 0.0
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
	return supabase_client != null and session_store != null and access_token != ""

func server_session_id() -> String:
	return _server_session_id

func snapshot_revision() -> int:
	return _snapshot_revision

func network_busy() -> bool:
	return _network_busy

func has_pending_events() -> bool:
	return _event_flush_active or not _event_queue.is_empty() or _pending_event_count > 0

func can_complete() -> bool:
	return _server_session_id != "" and not _completed and _server_synced and not has_pending_events()

func uses_authority() -> bool:
	return is_active() and _server_session_id != "" and not _completed

func session_state() -> String:
	return _session_state

func is_completed() -> bool:
	return _completed

func pending_summary_text() -> String:
	if _last_pending_request_id != "":
		return _last_pending_request_id
	if has_pending_events():
		return "fila:%d" % (_event_queue.size() + (1 if _event_flush_active else 0))
	return ""

func has_pending_collected_node(node_id: String) -> bool:
	return bool(_pending_collected_nodes.get(node_id, false))

func remember_pending_collected_node(node_id: String) -> void:
	if node_id.strip_edges() == "":
		return
	_pending_collected_nodes[node_id] = true

func pending_collected_nodes_for_tests() -> Dictionary:
	return _pending_collected_nodes.duplicate(true)

func record_heartbeat_if_due(session_seconds: float, heartbeat_seconds: float, position_payload: Dictionary) -> void:
	if _server_session_id == "" or not _server_synced or _completed:
		return
	if session_seconds - _last_heartbeat_seconds < heartbeat_seconds:
		return
	_last_heartbeat_seconds = session_seconds
	record_event_deferred("move_heartbeat", {
		"position": position_payload.duplicate(true),
		"session_seconds": int(session_seconds),
	})

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
	_emit_state_changed()
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, access_token)
	_network_busy = false
	if bool(state_result.get("ok", false)):
		var body := _response_body(state_result)
		var active_session := _as_dictionary(body.get("active_session", {}))
		if not active_session.is_empty() and hydrate_session(active_session):
			last_result_text = "Bosque retomado."
			_set_model_message("Bosque retomado.")
			_emit_client_telemetry("mode_session_resumed", {"result": "ok"})
			_emit_state_changed()
			return
	elif not _is_network_error(state_result):
		_set_model_message("Preview sem recompensa.")
		_session_state = SESSION_BLOCKED
		_emit_client_telemetry("mode_preview_started", {"result": "state_blocked", "error_code": _error_code(state_result)})
	else:
		_set_model_message("Preview sem recompensa. Conexao indisponivel.")
		_session_state = SESSION_OFFLINE
		_emit_client_telemetry("mode_preview_started", {"result": "offline", "error_code": _error_code(state_result)})
	_emit_state_changed()
	await start_session()

func start_session() -> void:
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
		access_token,
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	var body := _response_body(result)
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		hydrate_session(_as_dictionary(body.get("session", {})))
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
	if _network_busy:
		return {"ok": false, "busy": true}
	if _server_session_id == "":
		return {"ok": false, "missing_session": true}
	if _completed:
		return {"ok": false, "completed": true}
	if not can_complete():
		last_result_text = "Sincronize o Bosque antes de encerrar."
		_set_model_message("Sincronizacao pendente.")
		_emit_state_changed()
		return {"ok": false, "pending_sync": true}
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
		access_token,
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		var body := _response_body(result)
		var reward := _as_dictionary(body.get("reward", {}))
		_last_pending_request_id = ""
		_completed = true
		_session_state = SESSION_COMPLETED
		_event_queue.clear()
		_pending_event_count = 0
		_pending_collected_nodes = {}
		var reward_summary := _reward_summary(body, reward)
		last_result_text = reward_summary
		_set_model_message(reward_summary)
		_server_synced = true
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
		last_result_text = "Preview preservado. Recompensa bloqueada ate resync."
		_set_model_message("Sincronizacao pendente.")
		_session_state = SESSION_OFFLINE if _is_network_error(result) else SESSION_BLOCKED
		_emit_client_telemetry("mode_sync_failed", {"result": "complete_failed", "error_code": _error_code(result)})
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_emit_state_changed()
	return result

func abandon_session(reason: String = "player_abandoned") -> Dictionary:
	if _network_busy:
		return {"ok": false, "busy": true}
	if _server_session_id == "":
		return {"ok": false, "missing_session": true}
	if _completed:
		return {"ok": false, "completed": true}
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
		access_token,
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		_server_session_id = ""
		_snapshot_revision = 0
		_server_synced = false
		_completed = false
		_event_queue.clear()
		_pending_event_count = 0
		_pending_collected_nodes = {}
		_last_pending_request_id = ""
		_session_state = SESSION_PREVIEW
		last_result_text = "Sessao abandonada. Resultado descartado."
		_set_model_message("Sessao do Bosque abandonada.")
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
	_snapshot_revision = int(session.get("snapshot_revision", 0))
	_completed = str(session.get("status", "started")) == "completed"
	var snapshot_payload := _as_dictionary(session.get("snapshot_payload", session.get("snapshot", {})))
	if not snapshot_payload.is_empty():
		apply_remote_snapshot(snapshot_payload, apply_remote_position)
	_server_synced = true
	_pending_event_count = 0
	_pending_collected_nodes = {}
	_session_state = SESSION_COMPLETED if _completed else SESSION_SYNCED
	_emit_state_changed()
	return true

func apply_remote_snapshot(snapshot_payload: Dictionary, apply_remote_position := true) -> void:
	if _apply_snapshot_callback.is_valid():
		_apply_snapshot_callback.call(snapshot_payload, apply_remote_position)
	elif model != null and model.has_method("apply_snapshot"):
		model.apply_snapshot(snapshot_payload)

func record_event_deferred(event_type: String, event_payload: Dictionary) -> void:
	if not uses_authority():
		return
	if _event_queue.size() >= MAX_EVENT_QUEUE_SIZE:
		_set_model_message("Sincronizacao cheia. Aguarde o Bosque salvar antes de agir.")
		_emit_client_telemetry("mode_sync_failed", {
			"result": "queue_full",
			"event_type": event_type,
		})
		_emit_state_changed()
		return
	_client_event_seq += 1
	var payload := event_payload.duplicate(true)
	payload["client_event_seq"] = _client_event_seq
	if not payload.has("client_position_revision"):
		payload["client_position_revision"] = int(payload.get("position_revision", 0))
	_event_queue.append({
		"event_type": event_type,
		"event_payload": payload,
		"client_event_seq": _client_event_seq,
		"position_revision": int(payload.get("client_position_revision", 0)),
	})
	_pending_event_count = _event_queue.size() + (1 if _event_flush_active else 0)
	_server_synced = false
	_session_state = SESSION_PENDING
	if model != null and str(model.get("last_message")).strip_edges() == "":
		_set_model_message("Sincronizando Bosque...")
	_emit_client_telemetry("mode_session_sync_pending", {
		"result": "queued",
		"event_type": event_type,
	})
	_emit_state_changed()
	call_deferred("flush_event_queue")

func flush_event_queue() -> void:
	if _server_session_id == "":
		return
	if _event_flush_active:
		return
	if not is_active():
		_server_synced = false
		_session_state = SESSION_OFFLINE
		_emit_state_changed()
		return
	_event_flush_active = true
	while not _event_queue.is_empty():
		var job := _as_dictionary(_event_queue.front())
		var event_type := str(job.get("event_type", "")).strip_edges()
		var event_payload := _as_dictionary(job.get("event_payload", {}))
		if event_type == "":
			_event_queue.pop_front()
			continue
		var request_payload := event_payload.duplicate(true)
		request_payload["event_type"] = event_type
		request_payload["session_id"] = _server_session_id
		request_payload["expected_revision"] = _snapshot_revision
		var request: Dictionary = session_store.prepare_pending_mutation(
			"modes/session/event",
			_scope_id(),
			SOURCE_ID,
			request_payload
		)
		_last_pending_request_id = str(request.get("request_id", ""))
		_pending_event_count = _event_queue.size() + 1
		_server_synced = false
		_emit_state_changed()
		var result: Dictionary = await supabase_client.record_mode_session_event(
			_last_pending_request_id,
			_server_session_id,
			ModelScript.MODE_ID,
			ModelScript.SLICE_ID,
			event_type,
			_snapshot_revision,
			event_payload,
			access_token,
			str(request.get("request_hash", ""))
		)
		var body := _response_body(result)
		if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
			_event_queue.pop_front()
			if bool(body.get("resync_required", false)):
				await resync_session("Bosque sincronizado.")
				_event_queue.clear()
				break
			_apply_event_ack(body, job)
			_event_retry_attempts = 0
			continue
		_server_synced = false
		_session_state = SESSION_PENDING
		var error_code := _error_code(result)
		_set_model_message("Sincronizacao pendente.")
		if not _is_network_error(result):
			session_store.fail_pending_mutation(_last_pending_request_id, body)
			_event_queue.pop_front()
			if error_code == "MODE_SESSION_REVISION_STALE":
				await resync_session("Bosque resincronizado. Repita a ultima acao se ela nao apareceu.")
			else:
				await resync_session("Bosque resincronizado apos erro do servidor.")
			_event_queue.clear()
			_emit_client_telemetry("mode_sync_failed", {"result": "event_failed", "error_code": error_code})
		else:
			_set_model_message("Sincronizacao pendente. Tentando novamente...")
			_schedule_event_retry()
		break
	_event_flush_active = false
	_pending_event_count = _event_queue.size()
	if _event_queue.is_empty():
		_last_pending_request_id = ""
		if _server_session_id != "":
			_server_synced = true
			if not _completed:
				_session_state = SESSION_SYNCED
	_emit_state_changed()

func _apply_event_ack(body: Dictionary, _job: Dictionary) -> void:
	var session := _as_dictionary(body.get("session", {}))
	var session_id := str(body.get("session_id", session.get("id", ""))).strip_edges()
	if session_id != "":
		_server_session_id = session_id
	var revision_after := int(body.get("revision_after", -1))
	if revision_after < 0 and not session.is_empty():
		revision_after = int(session.get("snapshot_revision", _snapshot_revision))
	if revision_after >= 0:
		_snapshot_revision = revision_after
	var snapshot_patch := _as_dictionary(body.get("snapshot_patch", {}))
	if snapshot_patch.is_empty() and not session.is_empty():
		var snapshot_payload := _as_dictionary(session.get("snapshot_payload", session.get("snapshot", {})))
		snapshot_patch = _event_snapshot_patch(snapshot_payload)
	if not snapshot_patch.is_empty() and model != null and model.has_method("apply_authoritative_patch"):
		model.apply_authoritative_patch(snapshot_patch, true)
		var collected_nodes := _as_dictionary(snapshot_patch.get("collected_nodes", {}))
		if not collected_nodes.is_empty():
			_clear_confirmed_pending_nodes(collected_nodes)
	var user_message := str(body.get("user_message", _as_dictionary(body.get("event", {})).get("message", ""))).strip_edges()
	if user_message != "":
		_set_model_message(user_message)
	_server_synced = true
	if not _completed:
		_session_state = SESSION_SYNCED

func _event_snapshot_patch(snapshot_payload: Dictionary) -> Dictionary:
	var patch: Dictionary = {}
	for key: String in [
		"pocket",
		"chest",
		"upgrades",
		"collected_nodes",
		"reward_payload",
		"session_seconds",
		"activity_score",
		"capacity",
		"pocket_weight",
		"current_speed",
		"guidance",
		"last_message",
	]:
		if snapshot_payload.has(key):
			patch[key] = snapshot_payload.get(key)
	return patch

func _clear_confirmed_pending_nodes(collected_nodes: Dictionary) -> void:
	for node_id: String in collected_nodes.keys():
		if bool(collected_nodes.get(node_id, false)):
			_pending_collected_nodes.erase(node_id)

func retry_queued_events_now() -> void:
	_event_retry_scheduled = false
	await flush_event_queue()

func resync_session(success_message: String) -> bool:
	if not is_active():
		return false
	_session_state = SESSION_RESYNCING
	_emit_state_changed()
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, access_token)
	if not bool(state_result.get("ok", false)):
		_session_state = SESSION_OFFLINE if _is_network_error(state_result) else SESSION_BLOCKED
		_emit_client_telemetry("mode_sync_failed", {"result": "resync_failed", "error_code": _error_code(state_result)})
		_emit_state_changed()
		return false
	var body := _response_body(state_result)
	var active_session := _as_dictionary(body.get("active_session", {}))
	if active_session.is_empty():
		var sessions := _as_array(body.get("sessions", []))
		for session_variant: Variant in sessions:
			var candidate := _as_dictionary(session_variant)
			if str(candidate.get("status", "")) == "started":
				active_session = candidate
				break
	var active_session_id := str(active_session.get("id", "")).strip_edges()
	var apply_remote_position := active_session_id == "" or active_session_id != _server_session_id
	if active_session.is_empty() or not hydrate_session(active_session, apply_remote_position):
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
		"pending_event_count": _pending_event_count,
		"event_queue_size": _event_queue.size(),
		"event_flush_active": _event_flush_active,
		"event_retry_scheduled": _event_retry_scheduled,
		"event_retry_attempts": _event_retry_attempts,
		"last_pending_request_id": _last_pending_request_id,
	}

func record_exit_preserved() -> void:
	if _server_session_id == "" or _completed:
		return
	_emit_client_telemetry("mode_session_exit_preserved", {"result": "ok"})

func _schedule_event_retry() -> void:
	if _event_retry_scheduled:
		return
	_event_retry_scheduled = true
	_event_retry_attempts += 1
	call_deferred("_retry_event_queue")

func _retry_event_queue() -> void:
	if is_inside_tree():
		var delay := minf(MAX_EVENT_RETRY_BACKOFF_SECONDS, EVENT_RETRY_SECONDS * float(maxi(1, _event_retry_attempts)))
		await get_tree().create_timer(delay).timeout
	_event_retry_scheduled = false
	flush_event_queue()

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
		access_token,
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
	result["pending_count"] = _pending_event_count
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

func _reward_summary(body: Dictionary, reward: Dictionary) -> String:
	if _is_cap_zero_completion(body, reward):
		return "Visita encerrada. Limite diario atingido; sem recompensa nova."
	var delta := _as_dictionary(reward.get("resource_delta", body.get("resource_delta", {})))
	if delta.is_empty():
		return "Visita encerrada. Nenhuma recompensa nova."
	return "Visita encerrada. Recompensa aplicada: %s." % _resource_delta_text(delta)

func _resource_delta_text(delta: Dictionary) -> String:
	var keys := PackedStringArray()
	for key: String in delta.keys():
		keys.append(key)
	keys.sort()
	var parts := PackedStringArray()
	for key: String in keys:
		var amount := int(delta.get(key, 0))
		if amount != 0:
			parts.append("%s %+d" % [key, amount])
	return ", ".join(parts) if not parts.is_empty() else "sem alteracao"

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

func _as_array(value: Variant) -> Array:
	return value if value is Array else []

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
