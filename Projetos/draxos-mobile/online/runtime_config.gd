class_name RuntimeConfig
extends RefCounted

const SCHEMA_VERSION := "runtime_config_v1"
const CHANNEL_INTERNAL_ALPHA := "internal_alpha"
const DEFAULT_CONFIG_VERSION := "client-fallback"
const DEFAULT_REFRESH_SECONDS := 900

const FEATURE_PROFILE_ACCOUNT_PANEL := "profile_account_panel"
const FEATURE_BATTLE_HISTORY_REPLAY := "battle_history_replay"
const FEATURE_BASE_ROUTINE_PANEL := "base_routine_panel"
const FEATURE_SOCIAL_QOL_READABILITY := "social_qol_readability"
const FEATURE_ASSET_PACK_01_SAFE := "asset_pack_01_safe"
const FEATURE_FLAGS := [
	FEATURE_PROFILE_ACCOUNT_PANEL,
	FEATURE_BATTLE_HISTORY_REPLAY,
	FEATURE_BASE_ROUTINE_PANEL,
	FEATURE_SOCIAL_QOL_READABILITY,
	FEATURE_ASSET_PACK_01_SAFE,
]

static func fallback(source_url: String = "", reason_code: String = "", reason_message: String = "") -> Dictionary:
	var config := {
		"schema_version": SCHEMA_VERSION,
		"channel": CHANNEL_INTERNAL_ALPHA,
		"config_version": DEFAULT_CONFIG_VERSION,
		"generated_at": "",
		"features": default_features(),
		"client": {
			"offline_fallback_allowed": true,
			"config_refresh_seconds": DEFAULT_REFRESH_SECONDS,
		},
		"guardrails": default_guardrails(),
		"fallback": true,
		"config_source": "fallback",
		"source_url": source_url,
	}
	if reason_code != "" or reason_message != "":
		config["fallback_reason"] = {
			"code": reason_code,
			"message": reason_message,
		}
	return config

static func normalize(payload: Dictionary, source_url: String = "") -> Dictionary:
	if str(payload.get("schema_version", "")) != SCHEMA_VERSION:
		return fallback(
			source_url,
			"UNSUPPORTED_RUNTIME_CONFIG",
			"Runtime config schema is missing or unsupported."
		)

	var config := fallback(source_url)
	config["fallback"] = bool(payload.get("fallback", false))
	config["config_source"] = str(payload.get("config_source", "remote"))
	config["channel"] = _string_or(payload.get("channel", CHANNEL_INTERNAL_ALPHA), CHANNEL_INTERNAL_ALPHA)
	config["config_version"] = _string_or(payload.get("config_version", DEFAULT_CONFIG_VERSION), DEFAULT_CONFIG_VERSION)
	config["generated_at"] = _string_or(payload.get("generated_at", ""), "")
	config["features"] = _features_from(_as_dictionary(payload.get("features", {})))
	config["client"] = _client_from(_as_dictionary(payload.get("client", {})))
	config["guardrails"] = _guardrails_from(_as_dictionary(payload.get("guardrails", {})))
	if payload.get("fallback_reason", null) is Dictionary:
		config["fallback_reason"] = _as_dictionary(payload.get("fallback_reason", {})).duplicate(true)
	return config

static func from_fetch_result(result: Dictionary, source_url: String) -> Dictionary:
	if bool(result.get("ok", false)):
		var config := normalize(_as_dictionary(result.get("body", {})), source_url)
		return {
			"ok": true,
			"status": int(result.get("status", 200)),
			"body": config,
			"runtime_config": config,
			"fallback": bool(config.get("fallback", false)),
		}

	var error := _as_dictionary(result.get("error", {}))
	var code := str(error.get("code", "RUNTIME_CONFIG_UNAVAILABLE"))
	var message := str(error.get("message", "Runtime config unavailable; using conservative fallback."))
	var config := fallback(source_url, code, message)
	return {
		"ok": false,
		"status": int(result.get("status", 0)),
		"error": {
			"code": code,
			"message": message,
		},
		"body": config,
		"runtime_config": config,
		"fallback": true,
	}

static func default_features() -> Dictionary:
	var features := {}
	for flag: String in FEATURE_FLAGS:
		features[flag] = false
	return features

static func default_guardrails() -> Dictionary:
	return {
		"release_scoped": true,
		"read_only": true,
		"no_service_role": true,
		"no_secrets": true,
		"no_player_state": true,
		"no_gameplay_tuning": true,
		"mutable_gameplay_state": false,
	}

static func feature_enabled(config: Dictionary, feature_id: String) -> bool:
	var normalized := normalize(config)
	var features := _as_dictionary(normalized.get("features", {}))
	return bool(features.get(feature_id, false))

static func is_fallback(config: Dictionary) -> bool:
	return bool(normalize(config).get("fallback", true))

static func _features_from(payload: Dictionary) -> Dictionary:
	var features := default_features()
	for flag: String in FEATURE_FLAGS:
		if payload.get(flag, null) is bool:
			features[flag] = bool(payload.get(flag, false))
	return features

static func _client_from(payload: Dictionary) -> Dictionary:
	return {
		"offline_fallback_allowed": _bool_or(payload.get("offline_fallback_allowed", true), true),
		"config_refresh_seconds": clampi(
			_int_or(payload.get("config_refresh_seconds", DEFAULT_REFRESH_SECONDS), DEFAULT_REFRESH_SECONDS),
			60,
			3600
		),
	}

static func _guardrails_from(payload: Dictionary) -> Dictionary:
	var guardrails := default_guardrails()
	for key: String in guardrails.keys():
		if payload.get(key, null) is bool:
			guardrails[key] = bool(payload.get(key, guardrails[key]))
	return guardrails

static func _string_or(value: Variant, fallback_value: String) -> String:
	if value is String:
		return str(value)
	return fallback_value

static func _bool_or(value: Variant, fallback_value: bool) -> bool:
	if value is bool:
		return bool(value)
	return fallback_value

static func _int_or(value: Variant, fallback_value: int) -> int:
	if value is int or value is float:
		return int(value)
	return fallback_value

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
