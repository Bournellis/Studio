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

func test_battle_log_presenter_formats_first_slice_rich_events() -> void:
	var battle_log := _battle_log_fixture()
	battle_log["mode"] = ProjectInfo.FIRST_SLICE_MODE
	battle_log["events"] = [
		{"t": 0.0, "seq": 1, "type": "passive_apply", "source": "player", "target": "player", "passive_id": "vampirismo", "passive_level": 10},
		{"t": 0.5, "seq": 2, "type": "mana_change", "source": "player", "target": "player", "mana_after": 12},
		{"t": 0.5, "seq": 3, "type": "cooldown_start", "source": "player", "target": "player", "spell_id": "acender", "ready_at": 7.5},
		{"t": 0.5, "seq": 4, "type": "dot_apply", "source": "player", "target": "opponent", "status_id": "queimando", "stacks": 1},
		{"t": 1.5, "seq": 5, "type": "dot_tick", "source": "player", "target": "opponent", "status_id": "queimando", "damage": 6, "damage_type": "fogo", "hp_after": 94},
		{"t": 2.0, "seq": 6, "type": "status_apply", "source": "opponent", "target": "player", "status_id": "lento", "stacks": 1},
		{"t": 2.5, "seq": 7, "type": "barrier_gain", "source": "player", "target": "player", "amount": 30, "barrier_after": 30},
		{"t": 3.0, "seq": 8, "type": "barrier_absorb", "source": "opponent", "target": "player", "amount": 12, "damage_type": "gelo", "barrier_after": 18},
		{"t": 3.5, "seq": 9, "type": "resistance_apply", "source": "player", "target": "player", "amount": 0.08},
		{"t": 4.0, "seq": 10, "type": "summon_spawn", "source": "opponent", "target": "opponent_esqueleto", "hp": 60},
		{"t": 4.5, "seq": 11, "type": "summon_attack", "source": "opponent_esqueleto", "target": "player", "damage": 5, "damage_type": "morte", "hp_after": 80},
		{"t": 5.0, "seq": 12, "type": "pet_attack", "source": "player", "target": "opponent", "pet_id": "brasido", "damage": 10, "damage_type": "fogo", "hp_after": 84},
		{"t": 5.5, "seq": 13, "type": "heal", "source": "player", "target": "player", "amount": 2, "hp_after": 82},
		{"t": 6.0, "seq": 14, "type": "status_expire", "source": "player", "target": "opponent", "status_id": "queimando"},
		{"t": 7.5, "seq": 15, "type": "cooldown_ready", "source": "player", "target": "player", "spell_id": "acender"},
		{"t": 30.0, "seq": 16, "type": "anti_stall", "source": "system", "target": "none", "player_hp_after": 50, "opponent_hp_after": 48},
	]
	assert_false(BattleLogPresenterScript.has_unknown_events(battle_log))
	var lines: PackedStringArray = PackedStringArray()
	for event: Dictionary in BattleLogPresenterScript.sorted_events(battle_log):
		lines.append(BattleLogPresenterScript.format_event(event))
	var formatted := "\n".join(lines)
	assert_string_contains(formatted, "aplicou queimando")
	assert_string_contains(formatted, "Barreira")
	assert_string_contains(formatted, "invocou")
	assert_string_contains(formatted, "Anti-stall")
	assert_string_contains(BattleLogPresenterScript.format_summary(battle_log, {"type": "FIRST_SLICE_SIM", "resources": {"xp": 50}}), "FIRST_SLICE_SIM")

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
