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

	print("[smoke-session] signing in anonymously")
	var auth_result: Dictionary = await client.sign_in_anonymously()
	if not bool(auth_result.get("ok", false)):
		return _fail(auth_result)

	var session := Dictionary(auth_result.get("session", {}))
	var store = SessionStoreScript.new()
	if not store.apply_auth_session(session):
		store.free()
		client.queue_free()
		return 1

	print("[smoke-session] creating guest account")
	var guest_result: Dictionary = await client.create_guest_account(
		SessionStoreScript.DEFAULT_INVITE_CODE,
		SessionStoreScript.create_request_id(),
		"godot-session-smoke",
		store.access_token
	)
	if not bool(guest_result.get("ok", false)):
		store.free()
		client.queue_free()
		return _fail(guest_result)

	if not store.apply_server_state(guest_result):
		store.free()
		client.queue_free()
		return 1

	print("[smoke-session] fetching account state")
	var state_result: Dictionary = await client.fetch_account_state(store.access_token)
	if not bool(state_result.get("ok", false)):
		store.free()
		client.queue_free()
		return _fail(state_result)

	if not store.apply_server_state(state_result):
		store.free()
		client.queue_free()
		return 1

	print("[smoke-session] OK: %s / %s" % [
		store.player_display_name(),
		str(store.build.get("weapon_type", "")),
	])
	store.free()
	client.queue_free()
	return 0

func _fail(result: Dictionary) -> int:
	var error_payload := Dictionary(result.get("error", {}))
	printerr("[smoke-session] %s: %s" % [
		str(error_payload.get("code", "UNKNOWN_ERROR")),
		str(error_payload.get("message", "Session smoke failed.")),
	])
	return 1
