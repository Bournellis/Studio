class_name OpenworldRewardSummary
extends RefCounted

static func summary(body: Dictionary, reward: Dictionary, model: Object, fallback_session_seconds: float) -> String:
	var completion_reward_text := reward_text(body, reward)
	if model != null and model.has_method("visit_summary_text"):
		return str(model.call("visit_summary_text", completion_seconds(body, fallback_session_seconds), completion_reward_text))
	return "Visita encerrada. %s" % completion_reward_text

static func reward_text(body: Dictionary, reward: Dictionary) -> String:
	if is_cap_zero_completion(body, reward):
		return "Limite diario atingido; sem recompensa nova."
	var delta := _as_dictionary(reward.get("resource_delta", body.get("resource_delta", {})))
	if delta.is_empty():
		return "Nenhuma recompensa nova."
	return "Recompensa aplicada: %s." % resource_delta_text(delta)

static func resource_delta_text(delta: Dictionary) -> String:
	var keys := PackedStringArray()
	for key: String in delta.keys():
		keys.append(key)
	keys.sort()
	var parts := PackedStringArray()
	for key: String in keys:
		var amount := int(delta.get(key, 0))
		if amount != 0:
			parts.append("%s %+d" % [resource_display_name(key), amount])
	return ", ".join(parts) if not parts.is_empty() else "sem alteracao"

static func completion_seconds(body: Dictionary, fallback_session_seconds: float) -> float:
	var session := _as_dictionary(body.get("session", {}))
	if session.has("session_seconds"):
		return float(session.get("session_seconds", 0.0))
	return float(fallback_session_seconds)

static func resource_display_name(resource_id: String) -> String:
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

static func is_cap_zero_completion(body: Dictionary, reward: Dictionary) -> bool:
	return bool(body.get("cap_zero", reward.get("cap_zero", false))) or status(body, reward) == "cap_zero"

static func status(body: Dictionary, reward: Dictionary) -> String:
	return str(body.get("reward_status", reward.get("reward_status", "applied")))

static func period_key(body: Dictionary, reward: Dictionary) -> String:
	return str(body.get("period_key", reward.get("period_key", "")))

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
