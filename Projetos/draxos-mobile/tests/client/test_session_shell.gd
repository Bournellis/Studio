extends GutTest

const SessionStoreScript = preload("res://online/session_store.gd")
const SupabaseClientScript = preload("res://online/supabase_client.gd")
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

func test_session_store_keeps_server_state_as_snapshot() -> void:
	var store = SessionStoreScript.new()
	var applied := store.apply_server_state({
		"ok": true,
		"player": {"id": "player-1", "username": "guest_test"},
		"resources": {"almas": 1, "energia": 2},
		"build": {"weapon_type": "varinha_magica"},
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
	assert_eq(client.function_url("battle/request"), "http://127.0.0.1:54321/functions/v1/battle/request")
	client.free()

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
