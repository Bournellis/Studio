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
		_cleanup(client, store)
		return exit_code

	exit_code = await _check_base(client, store)
	if exit_code != 0:
		_cleanup(client, store)
		return exit_code

	exit_code = await _check_social(client, store)
	if exit_code != 0:
		_cleanup(client, store)
		return exit_code

	exit_code = await _check_competition(client, store)
	if exit_code != 0:
		_cleanup(client, store)
		return exit_code

	exit_code = await _check_shop(client, store)
	if exit_code != 0:
		_cleanup(client, store)
		return exit_code

	print("[smoke-foundation-surfaces] OK: base/shop/social/competition for %s" % store.player_display_name())
	_cleanup(client, store)
	return 0

func _create_guest_session(client: Node, store: Node) -> int:
	print("[smoke-foundation-surfaces] signing in anonymously")
	var auth_result: Dictionary = await client.sign_in_anonymously()
	if not bool(auth_result.get("ok", false)):
		return _fail(auth_result, "auth")
	if not store.apply_auth_session(_as_dictionary(auth_result.get("session", {}))):
		return 1

	print("[smoke-foundation-surfaces] creating guest account")
	var guest_result: Dictionary = await client.create_guest_account(
		SessionStoreScript.DEFAULT_INVITE_CODE,
		SessionStoreScript.create_request_id(),
		"godot-foundation-surfaces-smoke",
		store.access_token
	)
	if not bool(guest_result.get("ok", false)):
		return _fail(guest_result, "guest")
	if not store.apply_server_state(guest_result):
		return 1

	print("[smoke-foundation-surfaces] fetching account state")
	var state_result: Dictionary = await client.fetch_account_state(store.access_token)
	if not bool(state_result.get("ok", false)):
		return _fail(state_result, "state")
	if not store.apply_server_state(state_result):
		return 1
	return 0

func _check_base(client: Node, store: Node) -> int:
	print("[smoke-foundation-surfaces] checking base")
	var base_result: Dictionary = await client.fetch_base_state(store.access_token)
	if not bool(base_result.get("ok", false)) or not store.apply_base_result(base_result):
		return _fail(base_result, "base")
	var structures := Array(store.base_state.get("structures", []))
	if structures.size() < 6:
		return _fail_local("base", "BASE_STRUCTURES_MISSING", "Base state must expose the six current structures.")
	if int(store.base_state.get("construction_slots", 0)) < 1:
		return _fail_local("base", "BASE_SLOTS_MISSING", "Base state must expose construction slots.")

	var collect_result: Dictionary = await client.collect_base(
		SessionStoreScript.create_request_id(),
		store.access_token
	)
	if not bool(collect_result.get("ok", false)) or not store.apply_base_result(collect_result):
		return _fail(collect_result, "base-collect")
	return 0

func _check_social(client: Node, store: Node) -> int:
	print("[smoke-foundation-surfaces] checking social")
	var social_result: Dictionary = await client.fetch_social_state(store.access_token)
	if not bool(social_result.get("ok", false)) or not store.apply_social_result(social_result):
		return _fail(social_result, "social")
	if not store.social_state.has("identity") or not store.social_state.has("player"):
		return _fail_local("social", "SOCIAL_IDENTITY_MISSING", "Social state must expose account identity and player profile.")

	var guild_result: Dictionary = await client.create_guild(
		SessionStoreScript.create_request_id(),
		"Conclave Foundation %s" % store.session_id.substr(0, 6),
		store.access_token
	)
	if not bool(guild_result.get("ok", false)) or not store.apply_social_result(guild_result):
		return _fail(guild_result, "guild")
	if _as_dictionary(store.social_state.get("guild", {})).is_empty():
		return _fail_local("social", "GUILD_MISSING", "Guild creation must return the updated social state.")

	var chat_result: Dictionary = await client.send_guild_chat(
		SessionStoreScript.create_request_id(),
		"Foundation surfaces smoke ativo.",
		store.access_token
	)
	if not bool(chat_result.get("ok", false)) or not store.apply_social_result(chat_result):
		return _fail(chat_result, "chat")
	if Array(store.social_state.get("guild_chat", [])).is_empty():
		return _fail_local("social", "GUILD_CHAT_MISSING", "Guild chat mutation must return recent chat.")
	return 0

func _check_competition(client: Node, store: Node) -> int:
	print("[smoke-foundation-surfaces] checking competition")
	var matchmaking_result: Dictionary = await client.fetch_matchmaking_preview(store.access_token)
	if not bool(matchmaking_result.get("ok", false)) or not store.apply_competition_result(matchmaking_result):
		return _fail(matchmaking_result, "matchmaking")
	var matchmaking := _as_dictionary(store.competition_state.get("matchmaking", {}))
	if matchmaking.is_empty() or not matchmaking.has("candidate_count"):
		return _fail_local("competition", "MATCHMAKING_MISSING", "Matchmaking preview must expose the candidate count.")

	var ranking_result: Dictionary = await client.fetch_ranking_current(store.access_token)
	if not bool(ranking_result.get("ok", false)) or not store.apply_competition_result(ranking_result):
		return _fail(ranking_result, "ranking")
	var ranking := _as_dictionary(store.competition_state.get("ranking", {}))
	if ranking.is_empty() or not ranking.has("self"):
		return _fail_local("competition", "RANKING_SELF_MISSING", "Ranking state must expose the player entry.")
	return 0

func _check_shop(client: Node, store: Node) -> int:
	print("[smoke-foundation-surfaces] checking shop")
	var shop_result: Dictionary = await client.fetch_monetization_state(store.access_token)
	if not bool(shop_result.get("ok", false)) or not store.apply_monetization_result(shop_result):
		return _fail(shop_result, "shop")
	if not store.monetization_state.has("shop_summary") or Array(store.monetization_state.get("alpha_products", [])).is_empty():
		return _fail_local("shop", "SHOP_CATALOG_MISSING", "Shop state must expose summary and alpha products.")

	var redeem_result: Dictionary = await client.alpha_purchase(
		SessionStoreScript.create_request_id(),
		"alpha_redeem_small",
		store.access_token
	)
	if not bool(redeem_result.get("ok", false)) or not store.apply_monetization_result(redeem_result):
		return _fail(redeem_result, "shop-redeem")

	var reward_result: Dictionary = await client.claim_reward(
		SessionStoreScript.create_request_id(),
		"daily_collect_base",
		store.access_token
	)
	if not bool(reward_result.get("ok", false)) or not store.apply_monetization_result(reward_result):
		return _fail(reward_result, "reward")
	return 0

func _cleanup(client: Node, store: Node) -> void:
	store.free()
	client.queue_free()

func _fail(result: Dictionary, scope: String) -> int:
	var error_payload := _as_dictionary(result.get("error", {}))
	if error_payload.is_empty():
		var body := _as_dictionary(result.get("body", {}))
		error_payload = _as_dictionary(body.get("error", {}))
	printerr("[smoke-foundation-surfaces:%s] %s: %s" % [
		scope,
		str(error_payload.get("code", "UNKNOWN_ERROR")),
		str(error_payload.get("message", "Foundation surfaces smoke failed.")),
	])
	return 1

func _fail_local(scope: String, code: String, message: String) -> int:
	printerr("[smoke-foundation-surfaces:%s] %s: %s" % [scope, code, message])
	return 1

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
