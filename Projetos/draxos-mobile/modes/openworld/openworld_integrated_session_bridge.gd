class_name OpenworldIntegratedSessionBridge
extends Node

signal state_changed

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

const EVENT_RETRY_SECONDS := 1.25
const ACTION_SCOPE_TEMPLATE := "mode:openworld:%s"
const SOURCE_ID := "open_mode_shell:openworld"

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
var _pending_collected_nodes: Dictionary = {}
var _last_pending_request_id := ""
var _last_heartbeat_seconds := 0.0
var _apply_snapshot_callback := Callable()

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
	return _server_session_id != "" and _server_synced and not has_pending_events()

func uses_authority() -> bool:
	return is_active() and _server_session_id != ""

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

func record_heartbeat_if_due(session_seconds: float, heartbeat_seconds: float, position_payload: Dictionary) -> void:
	if _server_session_id == "" or not _server_synced:
		return
	if session_seconds - _last_heartbeat_seconds < heartbeat_seconds:
		return
	_last_heartbeat_seconds = session_seconds
	record_event_deferred("move_heartbeat", {
		"position": position_payload.duplicate(true),
		"session_seconds": int(session_seconds),
	})

func resume_or_start_session() -> void:
	if _network_busy or _server_session_id != "":
		return
	if not is_active():
		_set_model_message("Preview sem recompensa.")
		_server_synced = false
		_emit_state_changed()
		return
	_network_busy = true
	_emit_state_changed()
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, access_token)
	_network_busy = false
	if bool(state_result.get("ok", false)):
		var body := _response_body(state_result)
		var active_session := _as_dictionary(body.get("active_session", {}))
		if not active_session.is_empty() and hydrate_session(active_session):
			last_result_text = "Bosque retomado."
			_set_model_message("Bosque retomado.")
			_emit_state_changed()
			return
	elif not _is_network_error(state_result):
		_set_model_message("Preview sem recompensa.")
	_emit_state_changed()
	await start_session()

func start_session() -> void:
	if _network_busy or _server_session_id != "":
		return
	if not is_active():
		_set_model_message("Preview sem recompensa.")
		_server_synced = false
		_emit_state_changed()
		return
	_network_busy = true
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
	else:
		_server_synced = false
		last_result_text = "Preview sem recompensa."
		_set_model_message("Preview sem recompensa.")
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_emit_state_changed()

func complete_session(result_payload: Dictionary) -> Dictionary:
	if _network_busy:
		return {"ok": false, "busy": true}
	if _server_session_id == "":
		return {"ok": false, "missing_session": true}
	if not can_complete():
		last_result_text = "Sincronize o Bosque antes de completar."
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
		last_result_text = "Recompensa aplicada: %s" % JSON.stringify(reward.get("resource_delta", {}))
		_set_model_message("Recompensa integrada aplicada.")
		_server_synced = true
	else:
		_server_synced = false
		last_result_text = "Preview preservado. Recompensa bloqueada ate resync."
		_set_model_message("Sincronizacao pendente.")
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_emit_state_changed()
	return result

func hydrate_session(session: Dictionary) -> bool:
	var session_id := str(session.get("id", "")).strip_edges()
	if session_id == "":
		return false
	_server_session_id = session_id
	_snapshot_revision = int(session.get("snapshot_revision", 0))
	var snapshot_payload := _as_dictionary(session.get("snapshot_payload", session.get("snapshot", {})))
	if not snapshot_payload.is_empty():
		apply_remote_snapshot(snapshot_payload)
	_server_synced = true
	_pending_event_count = 0
	_pending_collected_nodes = {}
	_emit_state_changed()
	return true

func apply_remote_snapshot(snapshot_payload: Dictionary) -> void:
	if _apply_snapshot_callback.is_valid():
		_apply_snapshot_callback.call(snapshot_payload)
	elif model != null and model.has_method("apply_snapshot"):
		model.apply_snapshot(snapshot_payload)

func record_event_deferred(event_type: String, event_payload: Dictionary) -> void:
	if not uses_authority():
		return
	_event_queue.append({
		"event_type": event_type,
		"event_payload": event_payload.duplicate(true),
	})
	_pending_event_count = _event_queue.size() + (1 if _event_flush_active else 0)
	_server_synced = false
	if model != null and str(model.get("last_message")).strip_edges() == "":
		_set_model_message("Sincronizando Bosque...")
	_emit_state_changed()
	call_deferred("flush_event_queue")

func flush_event_queue() -> void:
	if _server_session_id == "":
		return
	if _event_flush_active:
		return
	if not is_active():
		_server_synced = false
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
			hydrate_session(_as_dictionary(body.get("session", {})))
			_set_model_message(str(_as_dictionary(body.get("event", {})).get("message", str(model.get("last_message")) if model != null else "")))
			continue
		_server_synced = false
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
	_emit_state_changed()

func retry_queued_events_now() -> void:
	_event_retry_scheduled = false
	await flush_event_queue()

func resync_session(success_message: String) -> bool:
	if not is_active():
		return false
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, access_token)
	if not bool(state_result.get("ok", false)):
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
	if active_session.is_empty() or not hydrate_session(active_session):
		return false
	_set_model_message(success_message)
	_emit_state_changed()
	return true

func debug_snapshot() -> Dictionary:
	return {
		"server_session_id": _server_session_id,
		"snapshot_revision": _snapshot_revision,
		"server_synced": _server_synced,
		"network_busy": _network_busy,
		"pending_event_count": _pending_event_count,
		"event_queue_size": _event_queue.size(),
		"event_flush_active": _event_flush_active,
		"event_retry_scheduled": _event_retry_scheduled,
		"last_pending_request_id": _last_pending_request_id,
	}

func _schedule_event_retry() -> void:
	if _event_retry_scheduled:
		return
	_event_retry_scheduled = true
	call_deferred("_retry_event_queue")

func _retry_event_queue() -> void:
	if is_inside_tree():
		await get_tree().create_timer(EVENT_RETRY_SECONDS).timeout
	_event_retry_scheduled = false
	flush_event_queue()

func _scope_id() -> String:
	return ACTION_SCOPE_TEMPLATE % str(session_store.get("active_save_type"))

func _set_model_message(message: String) -> void:
	if model != null:
		model.set("last_message", message)

func _emit_state_changed() -> void:
	state_changed.emit()

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
