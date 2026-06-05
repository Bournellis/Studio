extends SceneTree

const RuntimeConfigScript = preload("res://online/runtime_config.gd")
const SessionStoreScript = preload("res://online/session_store.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	var remote_config := RuntimeConfigScript.normalize({
		"schema_version": "runtime_config_v1",
		"channel": "internal_alpha",
		"config_version": "smoke",
		"features": {
			"profile_account_panel": true,
			"battle_history_replay": false,
			"unknown_flag": true,
		},
		"client": {
			"offline_fallback_allowed": true,
			"config_refresh_seconds": 900,
		},
		"guardrails": {
			"release_scoped": true,
			"read_only": false,
			"no_service_role": true,
			"no_secrets": true,
			"no_player_state": true,
			"no_gameplay_tuning": true,
			"mutable_gameplay_state": true,
		},
	})
	if RuntimeConfigScript.is_fallback(remote_config):
		return _fail_text("remote config fixture should normalize as non-fallback")
	if not RuntimeConfigScript.feature_enabled(remote_config, RuntimeConfigScript.FEATURE_PROFILE_ACCOUNT_PANEL):
		return _fail_text("known true feature flag should be enabled")
	if RuntimeConfigScript.feature_enabled(remote_config, RuntimeConfigScript.FEATURE_BATTLE_HISTORY_REPLAY):
		return _fail_text("known false feature flag should stay disabled")
	if Dictionary(remote_config.get("features", {})).has("unknown_flag"):
		return _fail_text("unknown feature flag should be ignored")

	var store = SessionStoreScript.new()
	if not store.apply_runtime_config(remote_config):
		store.free()
		return _fail_text("SessionStore should accept normalized runtime config")
	if not store.runtime_feature_enabled(RuntimeConfigScript.FEATURE_PROFILE_ACCOUNT_PANEL):
		store.free()
		return _fail_text("SessionStore should expose enabled runtime flag")
	if not store.runtime_allows_gameplay_mutation():
		store.free()
		return _fail_text("remote runtime config should allow gameplay mutations")

	var fallback_result := RuntimeConfigScript.from_fetch_result({
		"ok": false,
		"status": 0,
		"error": {
			"code": "NETWORK_UNAVAILABLE",
			"message": "Runtime config unavailable.",
		},
	}, "http://127.0.0.1:54321/functions/v1/release/config")
	store.apply_runtime_config(Dictionary(fallback_result.get("runtime_config", {})))
	if not store.runtime_config_is_fallback():
		store.free()
		return _fail_text("failed fetch should produce fallback config")
	if store.runtime_allows_gameplay_mutation():
		store.free()
		return _fail_text("fallback runtime config should block gameplay mutations")
	for flag: String in RuntimeConfigScript.FEATURE_FLAGS:
		if store.runtime_feature_enabled(flag):
			store.free()
			return _fail_text("fallback should disable %s" % flag)

	store.free()
	print("[smoke-runtime-config] OK")
	return 0

func _fail_text(message: String) -> int:
	printerr("[smoke-runtime-config] %s" % message)
	return 1
