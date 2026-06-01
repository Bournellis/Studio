extends RefCounted

static func state_from_body(body: Dictionary, current_mode_state: Dictionary) -> Dictionary:
	if body.has("modes") or body.has("progress") or body.has("sessions"):
		return body.duplicate(true)
	if body.get("state", null) is Dictionary:
		return _as_dictionary(body.get("state", {})).duplicate(true)

	var incoming_state := current_mode_state.duplicate(true)
	if body.get("mode", null) is Dictionary:
		incoming_state["mode"] = _as_dictionary(body.get("mode", {})).duplicate(true)
	if body.get("session", null) is Dictionary:
		incoming_state["last_session"] = _as_dictionary(body.get("session", {})).duplicate(true)
	if body.get("reward", null) is Dictionary:
		incoming_state["last_reward"] = _as_dictionary(body.get("reward", {})).duplicate(true)
	if body.get("limits", null) is Dictionary:
		incoming_state["limits"] = _as_dictionary(body.get("limits", {})).duplicate(true)
	if body.get("server_time", null) != null:
		incoming_state["server_time"] = body.get("server_time")
	return incoming_state

static func request_id_from_body(body: Dictionary) -> String:
	return str(body.get("request_id", "")).strip_edges()

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
