extends RefCounted

const RuntimeConfigScript := preload("res://online/runtime_config.gd")

static func create_request_id() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var bytes: Array[int] = []
	for index in 16:
		bytes.append(rng.randi_range(0, 255))
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80

	var parts := PackedStringArray()
	for index in bytes.size():
		parts.append("%02x" % bytes[index])

	return "%s%s%s%s-%s%s-%s%s-%s%s-%s%s%s%s%s%s" % [
		parts[0], parts[1], parts[2], parts[3],
		parts[4], parts[5],
		parts[6], parts[7],
		parts[8], parts[9],
		parts[10], parts[11], parts[12], parts[13], parts[14], parts[15],
	]

static func diagnostics_snapshot(input: Dictionary) -> Dictionary:
	var runtime := RuntimeConfigScript.normalize(_as_dictionary(input.get("runtime_config", {})))
	var last_error := _as_dictionary(input.get("last_error", {}))
	return {
		"cache_version": int(input.get("cache_version", 0)),
		"session_id": str(input.get("session_id", "")),
		"auth": {
			"has_access_token": bool(input.get("has_access_token", false)),
			"has_refresh_token": bool(input.get("has_refresh_token", false)),
			"expires_at": int(input.get("expires_at", 0)),
			"has_auth_user_id": bool(input.get("has_auth_user_id", false)),
			"auth_method": str(input.get("auth_method", "guest")),
			"registered": bool(input.get("registered", false)),
		},
		"save": _as_dictionary(input.get("save", {})).duplicate(true),
		"surfaces": _as_dictionary(input.get("surfaces", {})).duplicate(true),
		"progression_lab": _as_dictionary(input.get("progression_lab", {})).duplicate(true),
		"runtime_config": {
			"fallback": RuntimeConfigScript.is_fallback(runtime),
			"config_source": str(runtime.get("config_source", "")),
			"config_version": str(runtime.get("config_version", "")),
			"channel": str(runtime.get("channel", "")),
			"features": _as_dictionary(runtime.get("features", {})).duplicate(true),
		},
		"pending_mutations": _as_dictionary(input.get("pending_mutations", {})).duplicate(true),
		"offline": bool(input.get("offline", false)),
		"last_error": {
			"code": str(last_error.get("code", "")),
			"status": int(last_error.get("status", 0)),
		},
	}

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
