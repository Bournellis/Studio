extends RefCounted

static func snapshot(state: Dictionary) -> Dictionary:
	return {
		"cache_version": int(state.get("cache_version", 1)),
		"auth": {
			"access_token": str(state.get("access_token", "")),
			"refresh_token": str(state.get("refresh_token", "")),
			"expires_at": int(state.get("expires_at", 0)),
			"user_id": str(state.get("auth_user_id", "")),
			"auth_method": str(state.get("auth_method", "guest")),
			"email": str(state.get("auth_email", "")),
		},
		"session_id": str(state.get("session_id", "")),
		"guest_request_id": str(state.get("guest_request_id", "")),
		"alpha_account_request_id": str(state.get("alpha_account_request_id", "")),
		"account_username": str(state.get("account_username", "")),
		"active_save_type": str(state.get("active_save_type", "normal")),
		"player": _dict(state.get("player", {})).duplicate(true),
		"resources": _dict(state.get("resources", {})).duplicate(true),
		"build": _dict(state.get("build", {})).duplicate(true),
		"base_state": _dict(state.get("base_state", {})).duplicate(true),
		"social_state": _dict(state.get("social_state", {})).duplicate(true),
		"competition_state": _dict(state.get("competition_state", {})).duplicate(true),
		"monetization_state": _dict(state.get("monetization_state", {})).duplicate(true),
		"crafting_state": _dict(state.get("crafting_state", {})).duplicate(true),
		"combat_build_state": _dict(state.get("combat_build_state", {})).duplicate(true),
		"mode_state": _dict(state.get("mode_state", {})).duplicate(true),
		"progression_lab": _dict(state.get("progression_lab", {})).duplicate(true),
		"arena_state": _dict(state.get("arena_state", {})).duplicate(true),
		"surface_save_types": _dict(state.get("surface_save_types", {})).duplicate(true),
		"pending_mutations": _dict(state.get("pending_mutations", {})).duplicate(true),
		"last_battle_id": state.get("last_battle_id", null),
		"last_battle_log": _dict(state.get("last_battle_log", {})).duplicate(true),
		"last_battle_rewards": _dict(state.get("last_battle_rewards", {})).duplicate(true),
		"last_battle_result_seen": bool(state.get("last_battle_result_seen", false)),
		"offline": bool(state.get("offline", false)),
		"last_error": _dict(state.get("last_error", {})).duplicate(true),
	}

static func cache_auth(cache: Dictionary) -> Dictionary:
	return _dict(cache.get("auth", {}))

static func cache_dict(cache: Dictionary, key: String) -> Dictionary:
	return _dict(cache.get(key, {})).duplicate(true)

static func cache_string(cache: Dictionary, key: String, fallback: String = "") -> String:
	return str(cache.get(key, fallback))

static func cache_int(cache: Dictionary, key: String, fallback: int = 0) -> int:
	return int(cache.get(key, fallback))

static func cache_bool(cache: Dictionary, key: String, fallback: bool = false) -> bool:
	return bool(cache.get(key, fallback))

static func _dict(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
