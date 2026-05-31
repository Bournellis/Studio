extends GutTest

const SessionStoreScript = preload("res://online/session_store.gd")
const SupabaseClientScript = preload("res://online/supabase_client.gd")
const BackendConfigScript = preload("res://online/backend_config.gd")
const RuntimeConfigScript = preload("res://online/runtime_config.gd")
const BattleLogPresenterScript = preload("res://ui/battle_log_presenter.gd")

func test_request_id_is_uuid_v4() -> void:
	var request_id := SessionStoreScript.create_request_id()
	assert_eq(request_id.length(), 36)
	assert_eq(request_id.substr(14, 1), "4")
	assert_has(["8", "9", "a", "b"], request_id.substr(19, 1))

func test_session_store_validates_token_expiry() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	assert_false(store.has_valid_access_token(now))
	store.apply_auth_session({
		"access_token": "token",
		"refresh_token": "refresh",
		"expires_at": now + 3600,
		"user_id": "auth-user",
	})
	assert_true(store.has_valid_access_token(now))
	store.expires_at = now + 10
	assert_false(store.has_valid_access_token(now))
	store.free()

func test_session_store_flags_and_clears_progression_lab_local_only_cache() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	assert_true(store.apply_snapshot_cache({
		"cache_version": 1,
		"auth": {
			"access_token": "progression_lab_local_only",
			"refresh_token": "progression_lab_local_only",
			"expires_at": now + 3600,
			"user_id": "auth_progression_lab",
		},
		"session_id": "11111111-1111-4111-8111-111111111111",
		"guest_request_id": "22222222-2222-4222-8222-222222222222",
		"player": {"id": "player-local", "username": "plab_free_100_rewards_20h"},
		"resources": {"player_id": "player-local", "energia": 115},
		"build": {"player_id": "player-local", "weapon_type": "varinha_cinzas"},
		"base_state": {
			"structures": [{"structure_id": "nucleo_energia", "level": 3}],
			"jobs": [],
		},
		"progression_lab": {
			"save_id": "free_100_rewards_20h",
			"profile_id": "free_100_rewards",
			"milestone_id": "20h",
			"local_only": true,
		},
	}))
	assert_false(store.has_valid_access_token(now))
	assert_eq(store.access_token, "")
	assert_eq(store.refresh_token, "")
	assert_true(store.has_account_state())
	assert_true(store.is_progression_lab_local_only())
	assert_true(store.is_progression_lab_active())
	assert_eq(store.active_save_type, SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
	assert_eq(store.progression_lab_label(), "free_100_rewards/20h")

	assert_true(store.apply_auth_session({
		"access_token": "real-token",
		"refresh_token": "real-refresh",
		"expires_at": now + 3600,
		"user_id": "auth-real",
	}))
	assert_true(store.has_valid_access_token(now))
	assert_false(store.has_account_state())
	assert_false(store.has_base_state())
	assert_false(store.is_progression_lab_local_only())
	assert_false(store.is_progression_lab_active())
	assert_eq(store.active_save_type, SessionStoreScript.SAVE_TYPE_NORMAL)
	assert_eq(store.player_display_name(), "Guest Draxos")
	store.free()

func test_session_store_tracks_active_save_without_mixing_snapshots() -> void:
	var store = SessionStoreScript.new()
	store.player = {"id": "player-normal", "username": "normal_user"}
	store.resources = {"almas": 10}
	store.build = {"weapon_type": "varinha_cinzas"}
	store.base_state = {"structures": [{"structure_id": "nucleo_energia"}]}
	assert_true(store.has_account_state())
	assert_false(store.is_progression_lab_active())

	assert_true(store.set_active_save_type(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB))
	assert_true(store.is_progression_lab_active())
	assert_eq(store.active_save_label(), "Progression Lab")
	assert_eq(store.active_save_badge(), "lab")
	assert_false(store.has_account_state())
	assert_false(store.has_base_state())

	var snapshot := store.snapshot()
	var restored = SessionStoreScript.new()
	restored._apply_cache(snapshot)
	assert_true(restored.is_progression_lab_active())
	assert_false(restored.has_account_state())
	store.free()
	restored.free()

func test_session_store_keeps_server_state_as_snapshot() -> void:
	var store = SessionStoreScript.new()
	store.apply_auth_session({
		"access_token": "token",
		"refresh_token": "refresh",
		"expires_at": int(Time.get_unix_time_from_system()) + 3600,
		"user_id": "auth-user",
		"auth_method": "email",
		"email": "tester@example.com",
	})
	var applied := store.apply_server_state({
		"ok": true,
		"player": {"id": "player-1", "username": "guest_test"},
		"resources": {"almas": 1, "energia": 2},
		"build": {"weapon_type": "varinha_cinzas"},
		"last_battle_id": null,
	})
	assert_true(applied)
	var snapshot := store.snapshot()
	Dictionary(snapshot["resources"])["almas"] = 999
	assert_eq(int(store.resources.get("almas", 0)), 1)
	assert_true(store.is_registered_session())
	assert_eq(store.auth_email, "tester@example.com")
	assert_eq(store.account_username, "guest_test")
	store.free()

func test_session_store_persists_alpha_account_metadata() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	assert_true(store.apply_auth_session({
		"access_token": "email-token",
		"refresh_token": "email-refresh",
		"expires_at": now + 3600,
		"user_id": "auth-email",
		"auth_method": "email",
		"email": "alpha@example.com",
	}))
	store.account_username = "alpha_tester"
	var request_id := store.ensure_alpha_account_request_id()
	var snapshot := store.snapshot()

	var restored = SessionStoreScript.new()
	restored._apply_cache(snapshot)
	assert_true(restored.is_registered_session())
	assert_eq(restored.auth_email, "alpha@example.com")
	assert_eq(restored.account_username, "alpha_tester")
	assert_eq(restored.ensure_alpha_account_request_id(), request_id)
	assert_eq(restored.account_display_name(), "alpha_tester")
	store.free()
	restored.free()

func test_session_store_accepts_battle_log_snapshot_without_mutating_resources() -> void:
	var store = SessionStoreScript.new()
	store.resources = {"ossos": 0}
	var applied := store.apply_battle_result({
		"ok": true,
		"battle_log": _battle_log_fixture(),
		"rewards": {"type": "MVP_ONLY"},
		"competition": {
			"ranked": true,
			"result": "win",
			"arena_delta": 20,
			"ranking": {"arena_points": 20},
		},
	})
	assert_true(applied)
	assert_true(store.has_battle_log())
	assert_true(store.has_unseen_battle_result())
	assert_eq(str(store.last_battle_id), "battle-1")
	assert_eq(int(store.resources.get("ossos", 0)), 0)
	assert_eq(int(Dictionary(store.competition_state["last_battle"]).get("arena_delta", 0)), 20)
	store.mark_battle_result_seen()
	assert_false(store.has_unseen_battle_result())
	assert_true(bool(store.snapshot().get("last_battle_result_seen", false)))
	assert_true(store.apply_battle_result({
		"ok": true,
		"battle_log": _battle_log_fixture(),
		"rewards": {"type": "MVP_ONLY"},
	}))
	assert_false(store.has_unseen_battle_result())
	store.free()

func test_session_store_rejects_stale_save_scoped_surface_payloads() -> void:
	var store = SessionStoreScript.new()
	assert_false(store.is_progression_lab_active())
	var applied := store.apply_base_result({
		"ok": true,
		"_client": {"save_type": "progression_lab"},
		"resources": {"energia": 7},
		"base": {
			"construction_slots": 1,
			"structures": [{"structure_id": "nucleo_energia", "level": 1}],
			"jobs": [],
		},
	})
	assert_false(applied)
	assert_false(store.has_base_state())
	assert_eq(str(store.last_error.get("code", "")), "STALE_SAVE_RESPONSE")
	store.free()

func test_session_store_tracks_surface_snapshots_per_save() -> void:
	var store = SessionStoreScript.new()
	assert_true(store.apply_server_state({
		"ok": true,
		"_client": {"save_type": "normal"},
		"player": {"id": "player-normal", "username": "normal_user", "save_type": "normal"},
		"resources": {"almas": 1},
		"build": {"weapon_type": "varinha_cinzas"},
	}))
	assert_true(store.apply_base_result({
		"ok": true,
		"_client": {"save_type": "normal"},
		"resources": {"energia": 10},
		"base": {
			"construction_slots": 1,
			"structures": [{"structure_id": "nucleo_energia", "level": 1}],
			"jobs": [],
		},
	}))
	assert_true(store.has_account_state())
	assert_true(store.has_base_state())
	var diagnostics := store.diagnostics_snapshot()
	var surfaces := Dictionary(diagnostics.get("surfaces", {}))
	assert_eq(str(Dictionary(surfaces.get("account", {})).get("save_type", "")), "normal")
	assert_eq(str(Dictionary(surfaces.get("base", {})).get("save_type", "")), "normal")

	assert_true(store.set_active_save_type(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB))
	assert_false(store.has_account_state())
	assert_false(store.has_base_state())
	var lab_surfaces := Dictionary(store.diagnostics_snapshot().get("surfaces", {}))
	var lab_base_diagnostics := Dictionary(lab_surfaces.get("base", {}))
	assert_false(bool(lab_base_diagnostics.get("has_snapshot", true)))
	store.free()

func test_supabase_client_uses_local_contract_urls() -> void:
	var client = SupabaseClientScript.new()
	client.configure("http://127.0.0.1:54321/", "publishable")
	assert_eq(client.auth_anonymous_url(), "http://127.0.0.1:54321/auth/v1/signup")
	assert_eq(client.auth_password_url(), "http://127.0.0.1:54321/auth/v1/token?grant_type=password")
	assert_eq(client.function_url("account/bootstrap"), "http://127.0.0.1:54321/functions/v1/account/bootstrap")
	assert_eq(client.function_url("account/guest"), "http://127.0.0.1:54321/functions/v1/account/guest")
	assert_eq(client.function_url("account/saves/reset"), "http://127.0.0.1:54321/functions/v1/account/saves/reset")
	assert_eq(client.function_url("progression-lab/apply"), "http://127.0.0.1:54321/functions/v1/progression-lab/apply")
	assert_eq(client.function_url("battle/request"), "http://127.0.0.1:54321/functions/v1/battle/request")
	assert_eq(client.function_url("battle/history"), "http://127.0.0.1:54321/functions/v1/battle/history")
	assert_eq(client.function_url("battle/replay"), "http://127.0.0.1:54321/functions/v1/battle/replay")
	assert_eq(client.function_url("base/state"), "http://127.0.0.1:54321/functions/v1/base/state")
	assert_eq(client.function_url("minigames/registry"), "http://127.0.0.1:54321/functions/v1/minigames/registry")
	assert_eq(client.function_url("minigames/session/start"), "http://127.0.0.1:54321/functions/v1/minigames/session/start")
	assert_eq(client.function_url("social/state"), "http://127.0.0.1:54321/functions/v1/social/state")
	assert_eq(client.function_url("competition/ranking/current"), "http://127.0.0.1:54321/functions/v1/competition/ranking/current")
	assert_eq(client.function_url("monetization/state"), "http://127.0.0.1:54321/functions/v1/monetization/state")
	assert_eq(client.function_url("telemetry/client-event"), "http://127.0.0.1:54321/functions/v1/telemetry/client-event")
	assert_eq(client.manifest_url(), "http://127.0.0.1:54321/functions/v1/release/manifest")
	assert_eq(client.runtime_config_url(), "http://127.0.0.1:54321/functions/v1/release/config")
	client.free()

func test_supabase_client_diagnostics_do_not_expose_publishable_key() -> void:
	var client = SupabaseClientScript.new()
	client.configure("https://example.supabase.co/", "sb_publishable_example")
	client.configure_save_type("progression_lab")
	var diagnostics := client.diagnostics_snapshot()
	assert_false(diagnostics.has("publishable_key"))
	assert_false(str(diagnostics).contains("sb_publishable_example"))
	assert_eq(str(Dictionary(diagnostics.get("save_context", {})).get("active_save_type", "")), "progression_lab")
	assert_true(bool(Dictionary(diagnostics.get("auth", {})).get("publishable_key_configured", false)))
	client.free()

func test_backend_config_supports_internal_alpha_without_service_role() -> void:
	var config := BackendConfigScript.config_from_values(
		BackendConfigScript.ENVIRONMENT_INTERNAL_ALPHA,
		"https://example.supabase.co/",
		"sb_publishable_example",
		"test"
	)
	assert_true(bool(config.get("ok", false)))
	assert_eq(str(config.get("environment", "")), BackendConfigScript.ENVIRONMENT_INTERNAL_ALPHA)
	assert_eq(str(config.get("supabase_url", "")), "https://example.supabase.co")
	assert_eq(str(config.get("update_manifest_url", "")), "https://example.supabase.co/functions/v1/release/manifest")
	assert_eq(str(config.get("runtime_config_url", "")), "https://example.supabase.co/functions/v1/release/config")
	assert_true(bool(config.get("is_remote", false)))
	assert_false(Array(BackendConfigScript.client_environment_variables()).has("SUPABASE_SERVICE_ROLE_KEY"))
	assert_true(Array(BackendConfigScript.client_environment_variables()).has("DRAXOS_MOBILE_UPDATE_MANIFEST_URL"))
	assert_true(Array(BackendConfigScript.client_environment_variables()).has("DRAXOS_MOBILE_RUNTIME_CONFIG_URL"))
	assert_eq(
		BackendConfigScript.INTERNAL_ALPHA_RUNTIME_CONFIG_PATH,
		"res://online/internal_alpha_runtime_config.gd"
	)

func test_backend_config_rejects_secret_like_client_key() -> void:
	var config := BackendConfigScript.config_from_values(
		BackendConfigScript.ENVIRONMENT_INTERNAL_ALPHA,
		"https://example.supabase.co",
		"sb_secret_never_ship_this",
		"test"
	)
	assert_false(bool(config.get("ok", true)))
	assert_has(Array(config.get("errors", PackedStringArray())), BackendConfigScript.ERROR_PUBLISHABLE_KEY_LOOKS_SECRET)

func test_supabase_client_can_use_backend_config() -> void:
	var client = SupabaseClientScript.new()
	var config := BackendConfigScript.config_from_values(
		BackendConfigScript.ENVIRONMENT_INTERNAL_ALPHA,
		"https://example.supabase.co/",
		"sb_publishable_example",
		"test"
	)
	client.configure_backend(config)
	assert_eq(client.backend_environment, BackendConfigScript.ENVIRONMENT_INTERNAL_ALPHA)
	assert_eq(client.auth_anonymous_url(), "https://example.supabase.co/auth/v1/signup")
	assert_eq(client.function_url("account/state"), "https://example.supabase.co/functions/v1/account/state")
	assert_eq(client.manifest_url(), "https://example.supabase.co/functions/v1/release/manifest")
	assert_eq(client.runtime_config_url(), "https://example.supabase.co/functions/v1/release/config")
	var summary := client.backend_summary()
	assert_true(bool(summary.get("configured", false)))
	assert_eq(str(summary.get("update_manifest_url", "")), "https://example.supabase.co/functions/v1/release/manifest")
	assert_eq(str(summary.get("runtime_config_url", "")), "https://example.supabase.co/functions/v1/release/config")
	client.free()

func test_runtime_config_fallback_disables_t06_flags_conservatively() -> void:
	var config := RuntimeConfigScript.fallback(
		"https://example.supabase.co/functions/v1/release/config",
		"NETWORK_UNAVAILABLE",
		"Offline"
	)
	assert_eq(str(config.get("schema_version", "")), RuntimeConfigScript.SCHEMA_VERSION)
	assert_true(RuntimeConfigScript.is_fallback(config))
	for flag: String in RuntimeConfigScript.FEATURE_FLAGS:
		assert_false(RuntimeConfigScript.feature_enabled(config, flag), "Fallback should disable %s" % flag)
	var client := Dictionary(config.get("client", {}))
	assert_true(bool(client.get("offline_fallback_allowed", false)))
	var guardrails := Dictionary(config.get("guardrails", {}))
	assert_true(bool(guardrails.get("read_only", false)))
	assert_true(bool(guardrails.get("no_service_role", false)))
	assert_false(bool(guardrails.get("mutable_gameplay_state", true)))

func test_runtime_config_normalizes_only_known_feature_flags() -> void:
	var config := RuntimeConfigScript.normalize({
		"schema_version": "runtime_config_v1",
		"channel": "internal_alpha",
		"config_version": "test",
		"features": {
			"profile_account_panel": true,
			"battle_history_replay": "yes",
			"unknown_future_flag": true,
		},
		"client": {
			"offline_fallback_allowed": true,
			"config_refresh_seconds": 5,
		},
		"guardrails": {
			"release_scoped": true,
			"read_only": true,
			"no_service_role": true,
			"no_player_state": true,
			"mutable_gameplay_state": false,
		},
	})
	assert_false(RuntimeConfigScript.is_fallback(config))
	assert_true(RuntimeConfigScript.feature_enabled(config, RuntimeConfigScript.FEATURE_PROFILE_ACCOUNT_PANEL))
	assert_false(RuntimeConfigScript.feature_enabled(config, RuntimeConfigScript.FEATURE_BATTLE_HISTORY_REPLAY))
	assert_false(Dictionary(config.get("features", {})).has("unknown_future_flag"))
	assert_eq(int(Dictionary(config.get("client", {})).get("config_refresh_seconds", 0)), 60)

func test_runtime_config_fetch_error_returns_fallback_for_session_store() -> void:
	var result := RuntimeConfigScript.from_fetch_result({
		"ok": false,
		"status": 0,
		"error": {
			"code": "NETWORK_UNAVAILABLE",
			"message": "Runtime config offline.",
		},
	}, "https://example.supabase.co/functions/v1/release/config")
	assert_false(bool(result.get("ok", true)))
	assert_true(bool(result.get("fallback", false)))
	var store = SessionStoreScript.new()
	assert_true(store.apply_runtime_config(Dictionary(result.get("runtime_config", {}))))
	assert_true(store.runtime_config_is_fallback())
	assert_false(store.runtime_feature_enabled(RuntimeConfigScript.FEATURE_BASE_ROUTINE_PANEL))
	store.free()

func test_supabase_client_normalizes_save_context_header_state() -> void:
	var client = SupabaseClientScript.new()
	client.configure_save_type("progression_lab")
	assert_eq(client.active_save_type, "progression_lab")
	var annotated := client._with_client_context(
		{"ok": true, "body": {"ok": true}},
		PackedStringArray(["Accept: application/json", "x-draxos-save-type: progression_lab", "x-draxos-api-version: 1"])
	)
	assert_eq(str(Dictionary(annotated.get("_client", {})).get("save_type", "")), "progression_lab")
	assert_eq(str(Dictionary(annotated.get("_client", {})).get("api_version", "")), "1")
	var context := client.save_context_snapshot()
	assert_eq(str(context.get("api_version_header", "")), "x-draxos-api-version")
	assert_eq(str(context.get("api_version", "")), "1")
	assert_eq(Dictionary(annotated.get("body", {})), {"ok": true})
	client.configure_save_type("unknown")
	assert_eq(client.active_save_type, "normal")
	client.free()

func test_mutation_hash_is_stable_and_uses_sorted_payload_keys() -> void:
	var left := {
		"request_id": "00000000-0000-4000-8000-000000000001",
		"amount": 1,
		"nested": {"b": true, "a": "x"},
	}
	var right := {
		"nested": {"a": "x", "b": true},
		"amount": 1,
		"request_id": "00000000-0000-4000-8000-000000000001",
	}
	var left_hash := SessionStoreScript.request_hash_for_mutation("crafting/crush-bones", left)
	var right_hash := SupabaseClientScript.request_hash_for_mutation("crafting/crush-bones", right)
	assert_true(left_hash.begins_with("sha256:"))
	assert_eq(left_hash, right_hash)

func test_minigame_hash_and_session_store_bridge() -> void:
	var store = SessionStoreScript.new()
	store.active_save_type = SessionStoreScript.SAVE_TYPE_NORMAL
	store.resources = {"energia": 5, "ossos": 1}
	store.player = {"id": "player-test", "save_type": "normal", "xp": 3}
	var pending := store.prepare_pending_mutation(
		"minigames/session/complete",
		"minigame:rpgsuave:normal",
		"open_minigame_shell:rpgsuave",
		{
			"session_id": "00000000-0000-4000-8000-000000000101",
			"mode_id": "rpgsuave",
			"slice_id": "forest",
			"ruleset_id": "rpgsuave_forest_ruleset_v0",
			"ruleset_version": 1,
			"session_seconds": 30,
			"activity_score": 42,
			"deposited_items": {"galho": 2},
		}
	)
	assert_true(str(pending.get("request_hash", "")).begins_with("sha256:"))
	assert_true(store.apply_minigame_result({
		"_client": {"save_type": "normal"},
		"body": {
			"ok": true,
			"schema_version": "minigame_platform_v0",
			"request_id": str(pending.get("request_id", "")),
			"mode": {"mode_id": "rpgsuave", "slice_id": "forest"},
			"session": {"id": "00000000-0000-4000-8000-000000000101", "status": "completed"},
			"reward": {"resource_delta": {"energia": 2, "ossos": 1, "xp": 1}},
			"resources": {"energia": 7, "ossos": 2, "xp": 4},
		},
	}))
	assert_true(store.has_minigame_state())
	assert_eq(int(store.resources.get("energia", 0)), 7)
	assert_eq(int(store.resources.get("ossos", 0)), 2)
	assert_eq(int(store.player.get("xp", 0)), 4)
	assert_eq(
		str(store.pending_mutation(str(pending.get("request_id", ""))).get("status", "")),
		SessionStoreScript.MUTATION_STATUS_COMPLETED
	)
	var snapshot := store.snapshot()
	var restored = SessionStoreScript.new()
	restored._apply_cache(snapshot)
	assert_true(restored.has_minigame_state())
	store.free()
	restored.free()

func test_session_store_persists_pending_idempotent_mutation_for_retry() -> void:
	var store = SessionStoreScript.new()
	var first := store.prepare_pending_mutation(
		"base/collect",
		"base:normal",
		"collect_base",
		{}
	)
	var retry := store.prepare_pending_mutation(
		"base/collect",
		"base:normal",
		"collect_base",
		{}
	)

	assert_eq(str(first.get("request_id", "")), str(retry.get("request_id", "")))
	assert_eq(str(first.get("request_hash", "")), str(retry.get("request_hash", "")))
	assert_eq(int(retry.get("attempts", 0)), 2)
	assert_true(store.pending_mutation(str(first.get("request_id", ""))).has("payload_canonical"))

	var snapshot := store.snapshot()
	var restored = SessionStoreScript.new()
	restored._apply_cache(snapshot)
	assert_eq(
		str(restored.pending_mutation(str(first.get("request_id", ""))).get("request_hash", "")),
		str(first.get("request_hash", ""))
	)
	assert_true(restored.complete_pending_mutation(str(first.get("request_id", "")), {"ok": true}))
	assert_eq(
		str(restored.pending_mutation(str(first.get("request_id", ""))).get("status", "")),
		SessionStoreScript.MUTATION_STATUS_COMPLETED
	)
	store.free()
	restored.free()

func test_session_store_persists_local_telemetry_session_id() -> void:
	var store = SessionStoreScript.new()
	var first_id := store.ensure_session_id()
	assert_eq(first_id.length(), 36)
	var snapshot := store.snapshot()
	assert_eq(str(snapshot.get("session_id", "")), first_id)

	var restored = SessionStoreScript.new()
	restored._apply_cache(snapshot)
	assert_eq(restored.ensure_session_id(), first_id)

	store.clear_session()
	assert_ne(store.ensure_session_id(), first_id)
	store.free()
	restored.free()

func test_session_store_accepts_base_snapshot_without_local_mutation() -> void:
	var store = SessionStoreScript.new()
	store.resources = {"energia": 5}
	var applied := store.apply_base_result({
		"ok": true,
		"resources": {"energia": 7},
		"base": {
			"construction_slots": 1,
			"structures": [{"structure_id": "nucleo_energia", "level": 1}],
			"jobs": [],
		},
	})
	assert_true(applied)
	assert_true(store.has_base_state())
	assert_eq(int(store.resources.get("energia", 0)), 7)
	var snapshot := store.snapshot()
	Dictionary(snapshot["base_state"])["construction_slots"] = 99
	assert_eq(int(store.base_state.get("construction_slots", 0)), 1)
	store.free()

func test_session_store_domain_slices_are_deep_copy_snapshots() -> void:
	var store = SessionStoreScript.new()
	store.player = {"level": 3}
	store.resources = {"energia": 5}
	store.build = {"weapon": {"id": "varinha_cinzas"}}
	store.base_state = {"structures": [{"structure_id": "nucleo_energia", "level": 1}]}
	store.social_state = {"guild": {"name": "Conclave"}}
	store.competition_state = {"ranking": {"self": {"score": 10}}}
	store.monetization_state = {"summary": {"diamond_balance": 25}}
	store.crafting_state = {"inventory": [{"item_id": "pocao_vida", "quantity": 1}]}
	store.combat_build_state = {"spell_slots": [{"slot_index": 1, "spell_id": "sussurro_medo"}]}
	store.last_battle_log = {"events": [{"type": "battle_result"}]}
	store.last_battle_rewards = {"resources": {"ossos": 20}}

	var resources_snapshot := store.resources_snapshot()
	resources_snapshot["energia"] = 99
	assert_eq(int(store.resources.get("energia", 0)), 5)

	var base_snapshot := store.base_snapshot()
	Dictionary(Array(base_snapshot["structures"])[0])["level"] = 99
	assert_eq(int(Dictionary(Array(store.base_state["structures"])[0]).get("level", 0)), 1)

	var battle_snapshot := store.battle_snapshot()
	Dictionary(battle_snapshot["last_battle_rewards"])["resources"] = {"ossos": 999}
	assert_eq(int(Dictionary(store.last_battle_rewards["resources"]).get("ossos", 0)), 20)

	assert_eq(int(store.player_snapshot().get("level", 0)), 3)
	assert_eq(str(Dictionary(store.build_snapshot().get("weapon", {})).get("id", "")), "varinha_cinzas")
	assert_eq(str(Dictionary(store.social_snapshot().get("guild", {})).get("name", "")), "Conclave")
	var competition_snapshot := Dictionary(store.competition_snapshot())
	var ranking_snapshot := Dictionary(competition_snapshot.get("ranking", {}))
	var self_snapshot := Dictionary(ranking_snapshot.get("self", {}))
	assert_eq(int(self_snapshot.get("score", 0)), 10)
	assert_eq(int(Dictionary(store.monetization_snapshot().get("summary", {})).get("diamond_balance", 0)), 25)
	assert_eq(int(Dictionary(Array(store.crafting_snapshot().get("inventory", []))[0]).get("quantity", 0)), 1)
	assert_eq(str(Dictionary(Array(store.combat_build_snapshot().get("spell_slots", []))[0]).get("spell_id", "")), "sussurro_medo")
	store.free()

func test_session_store_accepts_social_and_competition_snapshots() -> void:
	var store = SessionStoreScript.new()
	assert_true(store.apply_social_result({
		"ok": true,
		"social": {
			"guild": {"name": "Conclave Alpha"},
			"friends": [],
			"guild_chat": [],
		},
	}))
	assert_true(store.has_social_state())
	assert_true(store.apply_competition_result({
		"ok": true,
		"matchmaking": {
			"player_power": 50,
			"selected_opponent": {"id": "bot_effect_trainer_01", "is_bot": true},
		},
	}))
	assert_true(store.has_competition_state())
	assert_eq(int(Dictionary(store.competition_state["matchmaking"]).get("player_power", 0)), 50)
	store.free()

func test_session_surfaces_tolerate_null_optional_payloads() -> void:
	var store = SessionStoreScript.new()
	assert_true(store.apply_social_result({
		"ok": true,
		"social": {
			"guild": null,
			"friends": null,
			"guild_chat": null,
		},
	}))
	assert_true(store.has_social_state())
	assert_true(store.apply_competition_result({
		"ok": true,
		"ranking": {
			"season": null,
			"self": null,
			"bots_included": false,
		},
	}))
	assert_true(store.has_competition_state())
	assert_true(store.apply_monetization_result({
		"ok": true,
		"monetization": {
			"battle_pass": {
				"pass": null,
				"progress": null,
			},
			"daily_rewards": null,
			"weekly_rewards": null,
			"alpha_products": null,
		},
	}))
	assert_true(store.has_monetization_state())
	store.free()

func test_session_store_accepts_monetization_snapshot() -> void:
	var store = SessionStoreScript.new()
	store.resources = {"diamante": 0}
	store.player = {"id": "player-1", "xp": 0}
	var applied := store.apply_monetization_result({
		"ok": true,
		"player": {"id": "player-1", "xp": 25},
		"resources": {"diamante": 500},
		"monetization": {
			"battle_pass": {
				"pass": {"id": "bp_s1_01"},
				"progress": {"pass_xp": 25, "premium_unlocked": true},
			},
			"daily_rewards": [],
			"weekly_rewards": [],
			"alpha_products": [],
		},
	})
	assert_true(applied)
	assert_true(store.has_monetization_state())
	assert_eq(int(store.resources.get("diamante", 0)), 500)
	assert_eq(int(store.player.get("xp", 0)), 25)
	var snapshot := store.snapshot()
	Dictionary(snapshot["monetization_state"])["alpha_products"] = [{"id": "mutated"}]
	assert_eq(Array(store.monetization_state.get("alpha_products", [])).size(), 0)
	store.free()

func test_session_store_save_reset_clears_gameplay_snapshots() -> void:
	var store = SessionStoreScript.new()
	store.base_state = {"structures": [{"structure_id": "nucleo_energia", "level": 2}]}
	store.social_state = {"guild": {"name": "Old Guild"}}
	store.competition_state = {"ranking": {"self": {"arena_points": 20}}}
	store.monetization_state = {"battle_pass": {"progress": {"premium_unlocked": true}}}
	store.last_battle_log = _battle_log_fixture()
	store.last_battle_rewards = {"type": "MVP_ONLY"}
	var applied := store.apply_save_reset({
		"ok": true,
		"player": {"id": "player-reset", "username": "guest_reset", "save_type": "normal", "level": 1, "xp": 0, "power": 0},
		"resources": {"player_id": "player-reset", "almas": 0, "energia": 0, "ossos": 0, "diamante": 0},
		"build": {"player_id": "player-reset", "weapon_type": "varinha_cinzas", "weapon_quality": "starter"},
		"last_battle_id": null,
	})
	assert_true(applied)
	assert_true(store.has_account_state())
	assert_false(store.has_base_state())
	assert_false(store.has_social_state())
	assert_false(store.has_competition_state())
	assert_false(store.has_monetization_state())
	assert_false(store.has_battle_log())
	assert_eq(int(store.player.get("level", 0)), 1)
	assert_eq(int(store.resources.get("ossos", -1)), 0)
	store.free()

func test_session_store_lab_save_reset_clears_progression_lab_metadata() -> void:
	var store = SessionStoreScript.new()
	store.active_save_type = SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB
	store.progression_lab = {
		"save_id": "free_100_rewards_10h",
		"profile_id": "free_100_rewards",
		"milestone_id": "10h",
		"local_only": false,
	}
	var applied := store.apply_save_reset({
		"ok": true,
		"_client": {"save_type": "progression_lab"},
		"player": {"id": "player-lab-reset", "username": "guest_lab", "save_type": "progression_lab", "level": 1, "xp": 0, "power": 0},
		"resources": {"player_id": "player-lab-reset", "almas": 0, "energia": 0, "ossos": 0, "diamante": 0},
		"build": {"player_id": "player-lab-reset", "weapon_type": "varinha_cinzas", "weapon_quality": "starter"},
		"last_battle_id": null,
	})
	assert_true(applied)
	assert_true(store.is_progression_lab_active())
	assert_true(store.progression_lab.is_empty())
	assert_eq(store.progression_lab_label(), "")
	assert_true(store.has_account_state())
	store.free()

func test_session_store_diagnostics_do_not_expose_auth_secrets() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	assert_true(store.apply_auth_session({
		"access_token": "super-secret-access-token",
		"refresh_token": "super-secret-refresh-token",
		"expires_at": now + 3600,
		"user_id": "auth-user",
		"auth_method": "email",
		"email": "tester@example.com",
	}))
	var diagnostics := store.diagnostics_snapshot()
	var diagnostic_text := str(diagnostics)
	assert_false(diagnostic_text.contains("super-secret-access-token"))
	assert_false(diagnostic_text.contains("super-secret-refresh-token"))
	assert_false(diagnostic_text.contains("tester@example.com"))
	assert_true(bool(Dictionary(diagnostics.get("auth", {})).get("has_access_token", false)))
	assert_true(bool(Dictionary(diagnostics.get("auth", {})).get("has_refresh_token", false)))
	store.free()

func test_session_store_progression_lab_apply_sets_metadata_and_clears_snapshots() -> void:
	var store = SessionStoreScript.new()
	store.active_save_type = SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB
	store.base_state = {"structures": [{"structure_id": "nucleo_energia", "level": 2}]}
	store.social_state = {"guild": {"name": "Old Lab Guild"}}
	store.competition_state = {"ranking": {"self": {"arena_points": 50}}}
	store.monetization_state = {"battle_pass": {"progress": {"premium_unlocked": true}}}
	store.last_battle_log = _battle_log_fixture()
	var applied := store.apply_progression_lab_result({
		"ok": true,
		"player": {"id": "player-lab", "username": "guest_lab", "save_type": "progression_lab", "level": 20, "xp": 4200, "power": 1500},
		"resources": {"player_id": "player-lab", "almas": 30, "energia": 40, "ossos": 12, "diamante": 5},
		"build": {"player_id": "player-lab", "weapon_type": "orbe_tempestade", "weapon_quality": "starter"},
		"last_battle_id": null,
		"progression_lab": {
			"save_id": "free_100_rewards_10h",
			"profile_id": "free_100_rewards",
			"milestone_id": "10h",
			"local_only": false,
		},
	})
	assert_true(applied)
	assert_true(store.is_progression_lab_active())
	assert_false(store.is_progression_lab_local_only())
	assert_eq(store.progression_lab_label(), "free_100_rewards/10h")
	assert_eq(int(store.player.get("level", 0)), 20)
	assert_eq(str(store.build.get("weapon_type", "")), "orbe_tempestade")
	assert_false(store.has_base_state())
	assert_false(store.has_social_state())
	assert_false(store.has_competition_state())
	assert_false(store.has_monetization_state())
	assert_false(store.has_battle_log())
	store.free()

func test_battle_log_presenter_sorts_formats_and_tolerates_unknown_events() -> void:
	var battle_log := _battle_log_fixture()
	battle_log["events"] = [
		{"t": 2.0, "seq": 3, "type": "mystery", "source": "system", "target": "none"},
		{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
		{"t": 1.0, "seq": 2, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
	]
	var events := BattleLogPresenterScript.sorted_events(battle_log)
	assert_eq(str(events[0].get("type", "")), "battle_start")
	assert_eq(str(events[2].get("type", "")), "mystery")
	assert_true(BattleLogPresenterScript.has_unknown_events(battle_log))
	assert_string_contains(BattleLogPresenterScript.format_event(events[2]), "Evento desconhecido")

func test_battle_log_presenter_formats_first_slice_rich_events() -> void:
	var battle_log := _battle_log_fixture()
	battle_log["mode"] = ProjectInfo.FIRST_SLICE_MODE
	battle_log["events"] = [
		{"t": 0.0, "seq": 1, "type": "passive_apply", "source": "player", "target": "player", "passive_id": "sangue_obediente", "passive_level": 10},
		{"t": 0.5, "seq": 2, "type": "mana_change", "source": "player", "target": "player", "mana_after": 12},
		{"t": 0.5, "seq": 3, "type": "cooldown_start", "source": "player", "target": "player", "spell_id": "marca_brasa", "ready_at": 7.5},
		{"t": 0.6, "seq": 4, "type": "spell_cast", "source": "player", "target": "opponent", "spell_id": "marca_brasa", "damage": 14, "damage_type": "fogo", "hp_after": 86},
		{"t": 0.5, "seq": 4, "type": "dot_apply", "source": "player", "target": "opponent", "status_id": "queimando", "stacks": 1},
		{"t": 1.5, "seq": 5, "type": "dot_tick", "source": "player", "target": "opponent", "status_id": "queimando", "damage": 6, "damage_type": "fogo", "hp_after": 94},
		{"t": 2.0, "seq": 6, "type": "status_apply", "source": "opponent", "target": "player", "status_id": "lento", "stacks": 1},
		{"t": 2.5, "seq": 7, "type": "barrier_gain", "source": "player", "target": "player", "amount": 30, "barrier_after": 30},
		{"t": 3.0, "seq": 8, "type": "barrier_absorb", "source": "opponent", "target": "player", "amount": 12, "damage_type": "gelo", "barrier_after": 18},
		{"t": 3.5, "seq": 9, "type": "resistance_apply", "source": "player", "target": "player", "amount": 0.08},
		{"t": 4.0, "seq": 10, "type": "summon_spawn", "source": "opponent", "target": "opponent_esqueleto", "hp": 60},
		{"t": 4.5, "seq": 11, "type": "summon_attack", "source": "opponent_esqueleto", "target": "player", "damage": 5, "damage_type": "morte", "hp_after": 80},
		{"t": 5.0, "seq": 12, "type": "pet_attack", "source": "player", "target": "opponent", "pet_id": "cao_cinzas", "damage": 10, "damage_type": "fogo", "hp_after": 84},
		{"t": 5.25, "seq": 13, "type": "consumable_use", "source": "player", "target": "player", "item_id": "pocao_vida", "slot_index": 1, "effect_id": "heal_over_time", "duration": 5, "tick_percent": 4},
		{"t": 5.5, "seq": 14, "type": "heal", "source": "player", "target": "player", "item_id": "pocao_vida", "amount": 2, "hp_after": 82},
		{"t": 6.0, "seq": 15, "type": "status_expire", "source": "player", "target": "opponent", "status_id": "queimando"},
		{"t": 7.5, "seq": 16, "type": "cooldown_ready", "source": "player", "target": "player", "spell_id": "marca_brasa"},
		{"t": 30.0, "seq": 17, "type": "anti_stall", "source": "system", "target": "none", "player_hp_after": 50, "opponent_hp_after": 48},
	]
	assert_false(BattleLogPresenterScript.has_unknown_events(battle_log))
	var lines: PackedStringArray = PackedStringArray()
	for event: Dictionary in BattleLogPresenterScript.sorted_events(battle_log):
		lines.append(BattleLogPresenterScript.format_event(event))
	var formatted := "\n".join(lines)
	assert_string_contains(formatted, "aplicou Queimando")
	assert_string_contains(formatted, "conjurou Marca Brasa")
	assert_string_contains(formatted, "Barreira")
	assert_string_contains(formatted, "invocou")
	assert_string_contains(formatted, "usou Pocao de Vida")
	assert_string_contains(formatted, "recuperou")
	assert_string_contains(formatted, "Limite da luta")
	assert_eq(BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast"), 1)
	assert_string_contains(BattleLogPresenterScript.format_summary(battle_log, {"type": "FIRST_SLICE_SIM", "resources": {"xp": 50}}), "XP +50")

func test_battle_log_presenter_tolerates_null_optional_payloads() -> void:
	var battle_log := {
		"schema_version": "battle_log_v1",
		"battle_id": "battle-null",
		"mode": ProjectInfo.FIRST_SLICE_MODE,
		"result": null,
		"participants": null,
		"events": null,
	}
	assert_eq(BattleLogPresenterScript.sorted_events(battle_log).size(), 0)
	assert_string_contains(BattleLogPresenterScript.format_summary(battle_log, {"resources": null}), "Resultado")

func _battle_log_fixture() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "battle-1",
		"seed": "seed",
		"mode": ProjectInfo.MVP_MODE,
		"participants": {
			"player": {"id": "player-1", "display_name": "Draxos"},
			"opponent": {"id": "mvp_training_bot", "display_name": "Bot de Treino", "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 1.0, "seq": 2, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
		],
	}
