extends GutTest

const SessionStoreScript = preload("res://online/session_store.gd")
const SupabaseClientScript = preload("res://online/supabase_client.gd")
const BackendConfigScript = preload("res://online/backend_config.gd")
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
	assert_true(store.has_valid_access_token(now))
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
	store.free()

func test_session_store_accepts_battle_log_snapshot_without_mutating_resources() -> void:
	var store = SessionStoreScript.new()
	store.resources = {"ossos": 0}
	var applied := store.apply_battle_result({
		"ok": true,
		"battle_log": _battle_log_fixture(),
		"rewards": {"type": "MVP_ONLY"},
	})
	assert_true(applied)
	assert_true(store.has_battle_log())
	assert_eq(str(store.last_battle_id), "battle-1")
	assert_eq(int(store.resources.get("ossos", 0)), 0)
	store.free()

func test_supabase_client_uses_local_contract_urls() -> void:
	var client = SupabaseClientScript.new()
	client.configure("http://127.0.0.1:54321/", "publishable")
	assert_eq(client.auth_anonymous_url(), "http://127.0.0.1:54321/auth/v1/signup")
	assert_eq(client.function_url("account/guest"), "http://127.0.0.1:54321/functions/v1/account/guest")
	assert_eq(client.function_url("account/saves/reset"), "http://127.0.0.1:54321/functions/v1/account/saves/reset")
	assert_eq(client.function_url("battle/request"), "http://127.0.0.1:54321/functions/v1/battle/request")
	assert_eq(client.function_url("base/state"), "http://127.0.0.1:54321/functions/v1/base/state")
	assert_eq(client.function_url("social/state"), "http://127.0.0.1:54321/functions/v1/social/state")
	assert_eq(client.function_url("competition/ranking/current"), "http://127.0.0.1:54321/functions/v1/competition/ranking/current")
	assert_eq(client.function_url("monetization/state"), "http://127.0.0.1:54321/functions/v1/monetization/state")
	assert_eq(client.function_url("telemetry/client-event"), "http://127.0.0.1:54321/functions/v1/telemetry/client-event")
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
	assert_true(bool(config.get("is_remote", false)))
	assert_false(Array(BackendConfigScript.client_environment_variables()).has("SUPABASE_SERVICE_ROLE_KEY"))

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
	var summary := client.backend_summary()
	assert_true(bool(summary.get("configured", false)))
	client.free()

func test_supabase_client_normalizes_save_context_header_state() -> void:
	var client = SupabaseClientScript.new()
	client.configure_save_type("progression_lab")
	assert_eq(client.active_save_type, "progression_lab")
	client.configure_save_type("unknown")
	assert_eq(client.active_save_type, "normal")
	client.free()

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
		{"t": 5.5, "seq": 13, "type": "heal", "source": "player", "target": "player", "amount": 2, "hp_after": 82},
		{"t": 6.0, "seq": 14, "type": "status_expire", "source": "player", "target": "opponent", "status_id": "queimando"},
		{"t": 7.5, "seq": 15, "type": "cooldown_ready", "source": "player", "target": "player", "spell_id": "marca_brasa"},
		{"t": 30.0, "seq": 16, "type": "anti_stall", "source": "system", "target": "none", "player_hp_after": 50, "opponent_hp_after": 48},
	]
	assert_false(BattleLogPresenterScript.has_unknown_events(battle_log))
	var lines: PackedStringArray = PackedStringArray()
	for event: Dictionary in BattleLogPresenterScript.sorted_events(battle_log):
		lines.append(BattleLogPresenterScript.format_event(event))
	var formatted := "\n".join(lines)
	assert_string_contains(formatted, "aplicou queimando")
	assert_string_contains(formatted, "conjurou marca_brasa")
	assert_string_contains(formatted, "Barreira")
	assert_string_contains(formatted, "invocou")
	assert_string_contains(formatted, "Anti-stall")
	assert_eq(BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast"), 1)
	assert_string_contains(BattleLogPresenterScript.format_summary(battle_log, {"type": "FIRST_SLICE_SIM", "resources": {"xp": 50}}), "FIRST_SLICE_SIM")

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
