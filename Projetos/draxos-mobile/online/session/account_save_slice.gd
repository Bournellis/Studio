extends RefCounted

const SAVE_TYPE_NORMAL := "normal"
const SAVE_TYPE_PROGRESSION_LAB := "progression_lab"
const CLIENT_META_KEY := "_client"
const CLIENT_SAVE_TYPE_KEY := "save_type"

static func normalize_save_type(save_type: String) -> String:
	var normalized := save_type.strip_edges().to_lower()
	if normalized == SAVE_TYPE_PROGRESSION_LAB:
		return SAVE_TYPE_PROGRESSION_LAB
	return SAVE_TYPE_NORMAL

static func active_save_label(save_type: String) -> String:
	if normalize_save_type(save_type) == SAVE_TYPE_PROGRESSION_LAB:
		return "Progression Lab"
	return "Normal"

static func active_save_badge(save_type: String) -> String:
	if normalize_save_type(save_type) == SAVE_TYPE_PROGRESSION_LAB:
		return "lab"
	return "normal"

static func account_slice(auth_user_id: String, auth_method: String, auth_email: String, account_username: String, player: Dictionary) -> Dictionary:
	return {
		"auth_user_id": auth_user_id,
		"auth_method": auth_method,
		"auth_email": auth_email,
		"account_username": account_username,
		"player": player.duplicate(true),
	}

static func save_slice(active_save_type: String, surface_save_types: Dictionary, progression_lab: Dictionary) -> Dictionary:
	return {
		"active_save_type": normalize_save_type(active_save_type),
		"label": active_save_label(active_save_type),
		"badge": active_save_badge(active_save_type),
		"surface_save_types": surface_save_types.duplicate(true),
		"progression_lab": progression_lab.duplicate(true),
	}

static func progression_lab_label(progression_lab: Dictionary) -> String:
	if progression_lab.is_empty():
		return ""
	var profile_id := str(progression_lab.get("profile_id", ""))
	var milestone_id := str(progression_lab.get("milestone_id", ""))
	if profile_id != "" and milestone_id != "":
		return "%s/%s" % [profile_id, milestone_id]
	return str(progression_lab.get("save_id", "Progression Lab"))

static func base_account_username(username: String) -> String:
	var normalized := username.strip_edges()
	if normalized.ends_with("_lab"):
		return normalized.trim_suffix("_lab")
	return normalized

static func unwrap_body(payload: Dictionary) -> Dictionary:
	if payload.has("body") and payload["body"] is Dictionary:
		return _as_dictionary(payload["body"])
	return payload

static func payload_save_type(payload: Dictionary, fallback_save_type: String) -> String:
	var meta := _as_dictionary(payload.get(CLIENT_META_KEY, {}))
	if meta.has(CLIENT_SAVE_TYPE_KEY):
		return normalize_save_type(str(meta.get(CLIENT_SAVE_TYPE_KEY, fallback_save_type)))
	var body := unwrap_body(payload)
	if body.has("save_type"):
		return normalize_save_type(str(body.get("save_type", fallback_save_type)))
	var body_player := _as_dictionary(body.get("player", {}))
	if body_player.has("save_type"):
		return normalize_save_type(str(body_player.get("save_type", fallback_save_type)))
	return normalize_save_type(fallback_save_type)

static func accept_save_scoped_payload(surface: String, payload: Dictionary, fallback_save_type: String, active_save_type: String) -> Dictionary:
	var payload_type := payload_save_type(payload, fallback_save_type)
	var active_type := normalize_save_type(active_save_type)
	if payload_type == active_type:
		return {
			"ok": true,
			"save_type": payload_type,
		}
	return {
		"ok": false,
		"save_type": payload_type,
		"error": {
			"code": "STALE_SAVE_RESPONSE",
			"message": "Resposta de %s pertence ao save %s, mas o save ativo e %s." % [
				surface,
				payload_type,
				active_type,
			],
		},
	}

static func has_account_state(player: Dictionary, resources: Dictionary, build: Dictionary, surface_save_types: Dictionary, active_save_type: String) -> bool:
	return (
		not player.is_empty()
		and not resources.is_empty()
		and not build.is_empty()
		and surface_matches_active_save(surface_save_types, "account", active_save_type)
	)

static func is_progression_lab_local_only(progression_lab: Dictionary) -> bool:
	return bool(progression_lab.get("local_only", false))

static func surface_matches_active_save(surface_save_types: Dictionary, surface: String, active_save_type: String) -> bool:
	return normalize_save_type(str(surface_save_types.get(surface, active_save_type))) == normalize_save_type(active_save_type)

static func diagnostics_surface(surface: String, has_snapshot: bool, surface_save_types: Dictionary, active_save_type: String) -> Dictionary:
	return {
		"has_snapshot": has_snapshot,
		"save_type": normalize_save_type(str(surface_save_types.get(surface, active_save_type))),
		"matches_active_save": surface_matches_active_save(surface_save_types, surface, active_save_type),
	}

static func normalized_surface_save_types(value: Dictionary) -> Dictionary:
	var normalized := {}
	for key: Variant in value.keys():
		normalized[str(key)] = normalize_save_type(str(value.get(key, SAVE_TYPE_NORMAL)))
	return normalized

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
