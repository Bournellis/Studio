extends RefCounted

static func has_token(meta_by_surface: Dictionary, surface: String, active_save_type: String, token: Dictionary) -> bool:
	if token.is_empty():
		return true
	var meta := surface_meta(meta_by_surface, surface, active_save_type)
	return int(meta.get("refresh_version", 0)) == int(token.get("version", 0))

static func begin(
	meta_by_surface: Dictionary,
	surface: String,
	active_save_type: String,
	cache_source: String,
	action_id: String,
	endpoint: String,
	rendered_from_cache: bool
) -> Dictionary:
	var normalized_surface := surface.strip_edges()
	var now_ms := int(Time.get_ticks_msec())
	var meta := surface_meta(meta_by_surface, normalized_surface, active_save_type)
	var version := int(meta.get("refresh_version", 0)) + 1
	meta["surface"] = normalized_surface
	meta["save_type"] = active_save_type
	meta["refresh_version"] = version
	meta["refreshing"] = true
	meta["source"] = cache_source
	meta["last_refresh_started_at"] = _now_text()
	meta["last_refresh_started_ms"] = now_ms
	meta["last_action_id"] = action_id.strip_edges()
	meta["last_endpoint"] = endpoint.strip_edges()
	meta["last_scope_id"] = "%s:%s" % [normalized_surface, active_save_type]
	meta["rendered_from_cache"] = rendered_from_cache
	meta["last_error"] = {}
	meta_by_surface[normalized_surface] = meta
	return {"surface": normalized_surface, "version": version, "started_ms": now_ms}

static func complete(
	meta_by_surface: Dictionary,
	latency_log: Array,
	surface: String,
	active_save_type: String,
	result: Dictionary,
	token: Dictionary,
	server_source: String,
	latency_limit: int
) -> bool:
	var normalized_surface := surface.strip_edges()
	if not has_token(meta_by_surface, normalized_surface, active_save_type, token):
		return false
	var meta := surface_meta(meta_by_surface, normalized_surface, active_save_type)
	var client := _dict(result.get("_client", {}))
	var body := _dict(result.get("body", {}))
	meta["refreshing"] = false
	meta["source"] = server_source
	meta["last_success_at"] = _now_text()
	meta["last_latency_ms"] = int(client.get("duration_ms", meta.get("last_latency_ms", 0)))
	meta["last_status"] = int(result.get("status", client.get("response_code", 0)))
	meta["last_error"] = {}
	if body.get("cache", null) is Dictionary:
		var cache_meta := _dict(body.get("cache", {}))
		if str(cache_meta.get("generated_at", "")).strip_edges() != "":
			meta["generated_at"] = str(cache_meta.get("generated_at", ""))
	if str(meta.get("generated_at", "")).strip_edges() == "":
		meta["generated_at"] = str(meta.get("last_success_at", ""))
	meta_by_surface[normalized_surface] = meta
	record_latency(latency_log, request_latency_payload(result, normalized_surface, true, meta), latency_limit)
	return true

static func fail(
	meta_by_surface: Dictionary,
	latency_log: Array,
	surface: String,
	active_save_type: String,
	result: Dictionary,
	token: Dictionary,
	has_snapshot: bool,
	cache_source: String,
	latency_limit: int
) -> bool:
	var normalized_surface := surface.strip_edges()
	if not has_token(meta_by_surface, normalized_surface, active_save_type, token):
		return false
	var meta := surface_meta(meta_by_surface, normalized_surface, active_save_type)
	var client := _dict(result.get("_client", {}))
	meta["refreshing"] = false
	meta["last_error"] = _dict(result.get("error", _dict(result.get("body", {})).get("error", {}))).duplicate(true)
	meta["last_latency_ms"] = int(client.get("duration_ms", meta.get("last_latency_ms", 0)))
	meta["last_status"] = int(result.get("status", client.get("response_code", 0)))
	if str(meta.get("source", "")).strip_edges() == "":
		meta["source"] = cache_source if has_snapshot else ""
	meta_by_surface[normalized_surface] = meta
	record_latency(latency_log, request_latency_payload(result, normalized_surface, false, meta), latency_limit)
	return true

static func snapshot(meta_by_surface: Dictionary, surface: String, active_save_type: String, has_snapshot: bool) -> Dictionary:
	var normalized_surface := surface.strip_edges()
	var meta := surface_meta(meta_by_surface, normalized_surface, active_save_type)
	meta["has_snapshot"] = has_snapshot
	meta["save_type"] = active_save_type
	return meta

static func record_latency(latency_log: Array, payload: Dictionary, latency_limit: int) -> void:
	var entry := payload.duplicate(true)
	if str(entry.get("endpoint", "")).strip_edges() == "" and str(entry.get("url", "")).strip_edges() == "":
		return
	entry["recorded_at"] = _now_text()
	latency_log.append(entry)
	while latency_log.size() > latency_limit:
		latency_log.pop_front()

static func normalized_meta(value: Dictionary) -> Dictionary:
	var result := {}
	for key: Variant in value.keys():
		var surface := str(key).strip_edges()
		if surface == "":
			continue
		result[surface] = _dict(value.get(key, {})).duplicate(true)
	return result

static func surface_meta(meta_by_surface: Dictionary, surface: String, active_save_type: String) -> Dictionary:
	var normalized_surface := surface.strip_edges()
	if meta_by_surface.get(normalized_surface, null) is Dictionary:
		return _dict(meta_by_surface.get(normalized_surface, {})).duplicate(true)
	return {
		"surface": normalized_surface,
		"save_type": active_save_type,
		"generated_at": "",
		"last_refresh_started_at": "",
		"last_success_at": "",
		"last_latency_ms": 0,
		"refreshing": false,
		"last_error": {},
		"source": "",
		"rendered_from_cache": false,
		"last_scope_id": "%s:%s" % [normalized_surface, active_save_type],
		"refresh_version": 0,
	}

static func request_latency_payload(result: Dictionary, surface: String, ok: bool, meta: Dictionary = {}) -> Dictionary:
	var client := _dict(result.get("_client", {}))
	var body := _dict(result.get("body", {}))
	var refresh := _dict(meta)
	return {
		"surface": surface,
		"endpoint": str(client.get("endpoint", refresh.get("last_endpoint", ""))),
		"url": str(client.get("url", "")),
		"method": str(client.get("method", "")),
		"action_id": str(refresh.get("last_action_id", "")),
		"scope_id": str(refresh.get("last_scope_id", "")),
		"duration_ms": int(client.get("duration_ms", refresh.get("last_latency_ms", 0))),
		"response_code": int(client.get("response_code", result.get("status", refresh.get("last_status", 0)))),
		"ok": ok,
		"fail": not ok,
		"used_cache": str(refresh.get("source", "")) == "cache",
		"rendered_from_cache": bool(refresh.get("rendered_from_cache", false)),
		"server_timing": _dict(body.get("server_timing", {})),
	}

static func _now_text() -> String:
	return Time.get_datetime_string_from_system(true)

static func _dict(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
