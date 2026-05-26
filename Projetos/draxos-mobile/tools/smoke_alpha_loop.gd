extends SceneTree

const SessionStoreScript = preload("res://online/session_store.gd")
const SupabaseClientScript = preload("res://online/supabase_client.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	var client = SupabaseClientScript.new()
	root.add_child(client)
	client.configure(
		str(ProjectSettings.get_setting("draxos_mobile/supabase/url", SupabaseClientScript.DEFAULT_SUPABASE_URL)),
		str(ProjectSettings.get_setting("draxos_mobile/supabase/publishable_key", SupabaseClientScript.DEFAULT_PUBLISHABLE_KEY))
	)

	var store = SessionStoreScript.new()
	store.ensure_session_id()

	var exit_code := await _create_guest_session(client, store)
	if exit_code != 0:
		store.free()
		client.queue_free()
		return exit_code

	if await _send_telemetry(client, store, "screen_opened", {"screen": "hub"}) != 0:
		store.free()
		client.queue_free()
		return 1

	print("[smoke-alpha-loop] requesting battle")
	var battle_result: Dictionary = await client.request_battle(
		SessionStoreScript.create_request_id(),
		store.access_token,
		ProjectInfo.FIRST_SLICE_MODE,
		"bot_effect_trainer_01"
	)
	if not bool(battle_result.get("ok", false)) or not store.apply_battle_result(battle_result):
		store.free()
		client.queue_free()
		return _fail(battle_result, "battle")
	var battle_competition := Dictionary(store.competition_state.get("last_battle", {}))
	if battle_competition.is_empty() or not battle_competition.has("arena_delta"):
		store.free()
		client.queue_free()
		return _fail({"error": {"code": "BATTLE_COMPETITION_MISSING"}}, "battle-competition")

	print("[smoke-alpha-loop] loading base")
	var base_result: Dictionary = await client.fetch_base_state(store.access_token)
	if not bool(base_result.get("ok", false)) or not store.apply_base_result(base_result):
		store.free()
		client.queue_free()
		return _fail(base_result, "base")
	var collect_result: Dictionary = await client.collect_base(
		SessionStoreScript.create_request_id(),
		store.access_token
	)
	if not bool(collect_result.get("ok", false)) or not store.apply_base_result(collect_result):
		store.free()
		client.queue_free()
		return _fail(collect_result, "base-collect")

	print("[smoke-alpha-loop] loading social")
	var social_result: Dictionary = await client.fetch_social_state(store.access_token)
	if not bool(social_result.get("ok", false)) or not store.apply_social_result(social_result):
		store.free()
		client.queue_free()
		return _fail(social_result, "social")
	var guild_result: Dictionary = await client.create_guild(
		SessionStoreScript.create_request_id(),
		"Conclave Smoke %s" % store.session_id.substr(0, 6),
		store.access_token
	)
	if not bool(guild_result.get("ok", false)) or not store.apply_social_result(guild_result):
		store.free()
		client.queue_free()
		return _fail(guild_result, "guild")
	var chat_result: Dictionary = await client.send_guild_chat(
		SessionStoreScript.create_request_id(),
		"Smoke alpha loop ativo.",
		store.access_token
	)
	if not bool(chat_result.get("ok", false)) or not store.apply_social_result(chat_result):
		store.free()
		client.queue_free()
		return _fail(chat_result, "chat")

	print("[smoke-alpha-loop] loading competition")
	var matchmaking_result: Dictionary = await client.fetch_matchmaking_preview(store.access_token)
	if not bool(matchmaking_result.get("ok", false)) or not store.apply_competition_result(matchmaking_result):
		store.free()
		client.queue_free()
		return _fail(matchmaking_result, "matchmaking")
	var ranking_result: Dictionary = await client.fetch_ranking_current(store.access_token)
	if not bool(ranking_result.get("ok", false)) or not store.apply_competition_result(ranking_result):
		store.free()
		client.queue_free()
		return _fail(ranking_result, "ranking")

	print("[smoke-alpha-loop] loading shop")
	var shop_result: Dictionary = await client.fetch_monetization_state(store.access_token)
	if not bool(shop_result.get("ok", false)) or not store.apply_monetization_result(shop_result):
		store.free()
		client.queue_free()
		return _fail(shop_result, "shop")
	var reward_result: Dictionary = await client.claim_reward(
		SessionStoreScript.create_request_id(),
		"daily_collect_base",
		store.access_token
	)
	if not bool(reward_result.get("ok", false)) or not store.apply_monetization_result(reward_result):
		store.free()
		client.queue_free()
		return _fail(reward_result, "reward")

	if await _send_telemetry(client, store, "action_success", {"action_id": "smoke_alpha_loop"}) != 0:
		store.free()
		client.queue_free()
		return 1

	print("[smoke-alpha-loop] OK: %s / battle %s" % [
		store.player_display_name(),
		str(store.last_battle_id),
	])
	store.free()
	client.queue_free()
	return 0

func _create_guest_session(client: Node, store: Node) -> int:
	print("[smoke-alpha-loop] signing in anonymously")
	var auth_result: Dictionary = await client.sign_in_anonymously()
	if not bool(auth_result.get("ok", false)):
		return _fail(auth_result, "auth")
	if not store.apply_auth_session(_as_dictionary(auth_result.get("session", {}))):
		return 1

	print("[smoke-alpha-loop] creating guest account")
	var guest_result: Dictionary = await client.create_guest_account(
		SessionStoreScript.DEFAULT_INVITE_CODE,
		SessionStoreScript.create_request_id(),
		"godot-alpha-loop-smoke",
		store.access_token
	)
	if not bool(guest_result.get("ok", false)):
		return _fail(guest_result, "guest")
	if not store.apply_server_state(guest_result):
		return 1

	print("[smoke-alpha-loop] fetching account state")
	var state_result: Dictionary = await client.fetch_account_state(store.access_token)
	if not bool(state_result.get("ok", false)):
		return _fail(state_result, "state")
	if not store.apply_server_state(state_result):
		return 1
	return 0

func _send_telemetry(client: Node, store: Node, event_type: String, payload: Dictionary) -> int:
	var telemetry_result: Dictionary = await client.send_client_telemetry(
		store.access_token,
		store.ensure_session_id(),
		event_type,
		payload
	)
	if not bool(telemetry_result.get("ok", false)):
		return _fail(telemetry_result, "telemetry")
	return 0

func _fail(result: Dictionary, scope: String) -> int:
	var error_payload := _as_dictionary(result.get("error", {}))
	if error_payload.is_empty():
		var body := _as_dictionary(result.get("body", {}))
		error_payload = _as_dictionary(body.get("error", {}))
	printerr("[smoke-alpha-loop:%s] %s: %s" % [
		scope,
		str(error_payload.get("code", "UNKNOWN_ERROR")),
		str(error_payload.get("message", "Alpha loop smoke failed.")),
	])
	return 1

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
