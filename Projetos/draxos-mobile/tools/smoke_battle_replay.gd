extends SceneTree

const BattleLogPresenterScript = preload("res://ui/battle_log_presenter.gd")
const BackendConfigScript = preload("res://online/backend_config.gd")
const ProjectInfoScript = preload("res://core/project_info.gd")
const SessionStoreScript = preload("res://online/session_store.gd")
const SupabaseClientScript = preload("res://online/supabase_client.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	var backend_config := BackendConfigScript.load_from_project_settings()
	var supabase_url := str(backend_config.get("supabase_url", SupabaseClientScript.DEFAULT_SUPABASE_URL))
	var publishable_key := str(backend_config.get("publishable_key", SupabaseClientScript.DEFAULT_PUBLISHABLE_KEY))
	var client = SupabaseClientScript.new()
	root.add_child(client)
	client.configure(supabase_url, publishable_key)

	var battle_client = client
	var battle_function_url := OS.get_environment("BATTLE_FUNCTION_URL").strip_edges().trim_suffix("/")
	if battle_function_url != "":
		battle_client = SupabaseClientScript.new()
		root.add_child(battle_client)
		battle_client.configure(battle_function_url, publishable_key)

	var store = SessionStoreScript.new()
	var exit_code := await _create_guest_session(client, store)
	if exit_code != 0:
		store.free()
		_free_clients(client, battle_client)
		return exit_code

	print("[smoke-replay] requesting first-slice battle")
	var battle_result: Dictionary = await battle_client.request_battle(
		SessionStoreScript.create_request_id(),
		store.access_token,
		ProjectInfoScript.FIRST_SLICE_MODE,
		"bot_effect_trainer_01"
	)
	if not bool(battle_result.get("ok", false)):
		store.free()
		_free_clients(client, battle_client)
		return _fail(battle_result)
	if not store.apply_battle_result(battle_result):
		store.free()
		_free_clients(client, battle_client)
		return 1

	var events := BattleLogPresenterScript.sorted_events(store.last_battle_log)
	if events.is_empty():
		printerr("[smoke-replay] battle log has no events")
		store.free()
		_free_clients(client, battle_client)
		return 1

	var first_line := BattleLogPresenterScript.format_event(events[0])
	var summary := BattleLogPresenterScript.format_summary(store.last_battle_log, store.last_battle_rewards)
	if BattleLogPresenterScript.has_unknown_events(store.last_battle_log):
		printerr("[smoke-replay] first-slice replay produced unknown events")
		store.free()
		_free_clients(client, battle_client)
		return 1
	print("[smoke-replay] first event: %s" % first_line)
	print("[smoke-replay] summary: %s" % summary)

	var latest_result: Dictionary = await battle_client.fetch_latest_battle(store.access_token)
	if not bool(latest_result.get("ok", false)):
		store.free()
		_free_clients(client, battle_client)
		return _fail(latest_result)
	if not store.apply_battle_result(latest_result):
		store.free()
		_free_clients(client, battle_client)
		return 1

	var latest_battle_id := str(store.last_battle_log.get("battle_id", ""))
	print("[smoke-replay] fetching battle history")
	var history_result: Dictionary = await battle_client.fetch_battle_history(store.access_token, 5)
	if not bool(history_result.get("ok", false)):
		store.free()
		_free_clients(client, battle_client)
		return _fail(history_result)
	var history_body := _as_dictionary(history_result.get("body", {}))
	var history_entries := _as_array(history_body.get("history", []))
	if history_entries.is_empty():
		printerr("[smoke-replay] battle history is empty")
		store.free()
		_free_clients(client, battle_client)
		return 1
	var newest_entry := _as_dictionary(history_entries[0])
	if str(newest_entry.get("battle_id", "")) != latest_battle_id:
		printerr("[smoke-replay] newest history battle does not match latest replay")
		store.free()
		_free_clients(client, battle_client)
		return 1
	if newest_entry.has("events"):
		printerr("[smoke-replay] history entry leaked full event log")
		store.free()
		_free_clients(client, battle_client)
		return 1

	print("[smoke-replay] fetching saved replay")
	var resources_before: Dictionary = store.resources.duplicate(true)
	var replay_result: Dictionary = await battle_client.fetch_battle_replay(latest_battle_id, store.access_token)
	if not bool(replay_result.get("ok", false)):
		store.free()
		_free_clients(client, battle_client)
		return _fail(replay_result)
	if not store.apply_battle_result(replay_result):
		store.free()
		_free_clients(client, battle_client)
		return 1
	if store.resources != resources_before:
		printerr("[smoke-replay] read-only replay changed local resources")
		store.free()
		_free_clients(client, battle_client)
		return 1

	print("[smoke-replay] OK: %s events, battle %s" % [
		events.size(),
		str(store.last_battle_log.get("battle_id", "")),
	])
	store.free()
	_free_clients(client, battle_client)
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

func _free_clients(primary: Node, battle_client: Node) -> void:
	if battle_client != primary and battle_client != null and is_instance_valid(battle_client):
		battle_client.queue_free()
	if primary != null and is_instance_valid(primary):
		primary.queue_free()

func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
