extends SceneTree

const BattleLogPresenterScript = preload("res://ui/battle_log_presenter.gd")
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
	var exit_code := await _create_guest_session(client, store)
	if exit_code != 0:
		store.free()
		client.queue_free()
		return exit_code

	print("[smoke-replay] requesting first-slice battle")
	var battle_result: Dictionary = await client.request_battle(
		SessionStoreScript.create_request_id(),
		store.access_token,
		ProjectInfo.FIRST_SLICE_MODE,
		"bot_effect_trainer_01"
	)
	if not bool(battle_result.get("ok", false)):
		store.free()
		client.queue_free()
		return _fail(battle_result)
	if not store.apply_battle_result(battle_result):
		store.free()
		client.queue_free()
		return 1

	var events := BattleLogPresenterScript.sorted_events(store.last_battle_log)
	if events.is_empty():
		printerr("[smoke-replay] battle log has no events")
		store.free()
		client.queue_free()
		return 1

	var first_line := BattleLogPresenterScript.format_event(events[0])
	var summary := BattleLogPresenterScript.format_summary(store.last_battle_log, store.last_battle_rewards)
	if BattleLogPresenterScript.has_unknown_events(store.last_battle_log):
		printerr("[smoke-replay] first-slice replay produced unknown events")
		store.free()
		client.queue_free()
		return 1
	print("[smoke-replay] first event: %s" % first_line)
	print("[smoke-replay] summary: %s" % summary)

	var latest_result: Dictionary = await client.fetch_latest_battle(store.access_token)
	if not bool(latest_result.get("ok", false)):
		store.free()
		client.queue_free()
		return _fail(latest_result)
	if not store.apply_battle_result(latest_result):
		store.free()
		client.queue_free()
		return 1

	print("[smoke-replay] OK: %s events, battle %s" % [
		events.size(),
		str(store.last_battle_log.get("battle_id", "")),
	])
	store.free()
	client.queue_free()
	return 0

func _create_guest_session(client: Node, store: Node) -> int:
	print("[smoke-replay] signing in anonymously")
	var auth_result: Dictionary = await client.sign_in_anonymously()
	if not bool(auth_result.get("ok", false)):
		return _fail(auth_result)
	if not store.apply_auth_session(Dictionary(auth_result.get("session", {}))):
		return 1

	print("[smoke-replay] creating guest account")
	var guest_result: Dictionary = await client.create_guest_account(
		SessionStoreScript.DEFAULT_INVITE_CODE,
		SessionStoreScript.create_request_id(),
		"godot-replay-smoke",
		store.access_token
	)
	if not bool(guest_result.get("ok", false)):
		return _fail(guest_result)
	if not store.apply_server_state(guest_result):
		return 1
	return 0

func _fail(result: Dictionary) -> int:
	var error_payload := Dictionary(result.get("error", {}))
	printerr("[smoke-replay] %s: %s" % [
		str(error_payload.get("code", "UNKNOWN_ERROR")),
		str(error_payload.get("message", "Replay smoke failed.")),
	])
	return 1
