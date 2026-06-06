extends Node

const BackendConfigScript = preload("res://online/backend_config.gd")
const RuntimeConfigScript = preload("res://online/runtime_config.gd")
const PendingMutationQueueScript = preload("res://online/session/pending_mutation_queue.gd")
const ProjectInfoScript = preload("res://core/project_info.gd")

const DEFAULT_SUPABASE_URL := BackendConfigScript.DEFAULT_LOCAL_SUPABASE_URL
const DEFAULT_PUBLISHABLE_KEY := BackendConfigScript.DEFAULT_LOCAL_PUBLISHABLE_KEY
const REQUEST_TIMEOUT_SECONDS := 15.0
const SAVE_TYPE_NORMAL := "normal"
const SAVE_TYPE_PROGRESSION_LAB := "progression_lab"
const DRAXOS_API_VERSION := "1"
const CLIENT_META_KEY := "_client"
const CLIENT_SAVE_TYPE_KEY := "save_type"
const CLIENT_API_VERSION_KEY := "api_version"

var supabase_url := DEFAULT_SUPABASE_URL
var publishable_key := DEFAULT_PUBLISHABLE_KEY
var update_manifest_url := "%s/functions/v1/release/manifest" % DEFAULT_SUPABASE_URL
var runtime_config_endpoint_url := "%s/functions/v1/release/config" % DEFAULT_SUPABASE_URL
var backend_environment := BackendConfigScript.DEFAULT_BACKEND_ENVIRONMENT
var backend_config_source := "defaults"
var backend_config_errors := PackedStringArray()
var active_save_type := SAVE_TYPE_NORMAL

func _ready() -> void:
	_load_project_settings()

func configure(url: String, key: String) -> void:
	configure_backend(BackendConfigScript.config_from_values(
		BackendConfigScript.ENVIRONMENT_CUSTOM,
		url,
		key,
		"manual"
	))

func configure_backend(config: Dictionary) -> void:
	backend_environment = str(config.get("environment", BackendConfigScript.DEFAULT_BACKEND_ENVIRONMENT))
	backend_config_source = str(config.get("source", "unknown"))
	backend_config_errors = _packed_string_array(config.get("errors", PackedStringArray()))
	supabase_url = str(config.get("supabase_url", "")).strip_edges().trim_suffix("/")
	publishable_key = str(config.get("publishable_key", "")).strip_edges()
	update_manifest_url = str(config.get("update_manifest_url", "")).strip_edges()
	runtime_config_endpoint_url = str(config.get("runtime_config_url", "")).strip_edges()

func backend_summary() -> Dictionary:
	return {
		"environment": backend_environment,
		"source": backend_config_source,
		"supabase_url": supabase_url,
		"update_manifest_url": update_manifest_url,
		"runtime_config_url": runtime_config_endpoint_url,
		"configured": backend_config_errors.is_empty(),
		"errors": backend_config_errors,
	}

func diagnostics_snapshot() -> Dictionary:
	var summary := backend_summary()
	return {
		"backend": {
			"environment": str(summary.get("environment", "")),
			"source": str(summary.get("source", "")),
			"supabase_url": str(summary.get("supabase_url", "")),
			"update_manifest_url": str(summary.get("update_manifest_url", "")),
			"runtime_config_url": str(summary.get("runtime_config_url", "")),
			"configured": bool(summary.get("configured", false)),
			"errors": _packed_string_array(summary.get("errors", PackedStringArray())),
		},
		"auth": {
			"publishable_key_configured": publishable_key != "",
		},
		"save_context": save_context_snapshot(),
	}

func save_context_snapshot() -> Dictionary:
	return {
		"active_save_type": active_save_type,
		"save_header": "x-draxos-save-type",
		"api_version_header": "x-draxos-api-version",
		"api_version": DRAXOS_API_VERSION,
	}

func configure_save_type(save_type: String) -> void:
	active_save_type = _normalize_save_type(save_type)

func auth_anonymous_url() -> String:
	return "%s/auth/v1/signup" % supabase_url

func auth_password_url() -> String:
	return "%s/auth/v1/token?grant_type=password" % supabase_url

func auth_refresh_url() -> String:
	return "%s/auth/v1/token?grant_type=refresh_token" % supabase_url

func function_url(endpoint: String) -> String:
	return "%s/functions/v1/%s" % [supabase_url, endpoint.trim_prefix("/")]

func manifest_url() -> String:
	return update_manifest_url

func runtime_config_url() -> String:
	return runtime_config_endpoint_url

func fetch_update_manifest() -> Dictionary:
	if update_manifest_url == "":
		return _error("UPDATE_MANIFEST_URL_MISSING", "Update manifest URL is not configured.")
	return await _send_json(
		update_manifest_url,
		HTTPClient.METHOD_GET,
		_manifest_headers(),
		{}
	)

func fetch_runtime_config() -> Dictionary:
	if runtime_config_endpoint_url == "":
		return RuntimeConfigScript.from_fetch_result(
			_error("RUNTIME_CONFIG_URL_MISSING", "Runtime config URL is not configured."),
			runtime_config_endpoint_url
		)
	var result: Dictionary = await _send_json(
		runtime_config_endpoint_url,
		HTTPClient.METHOD_GET,
		_release_headers(runtime_config_endpoint_url),
		{}
	)
	return RuntimeConfigScript.from_fetch_result(result, runtime_config_endpoint_url)

func sign_in_anonymously() -> Dictionary:
	var result: Dictionary = await _send_json(
		auth_anonymous_url(),
		HTTPClient.METHOD_POST,
		_base_headers(),
		{"data": {"provider": "guest"}}
	)
	if not bool(result.get("ok", false)):
		return result

	var payload: Dictionary = _as_dictionary(result.get("body", {}))
	var session := _session_from_auth_payload(payload, true, false)
	if session.is_empty():
		return _error("INVALID_AUTH_RESPONSE", "Supabase Auth did not return an anonymous session.")

	return {"ok": true, "session": session}

func sign_up_with_email(email: String, password: String) -> Dictionary:
	var result: Dictionary = await _send_json(
		auth_anonymous_url(),
		HTTPClient.METHOD_POST,
		_base_headers(),
		{
			"email": email.strip_edges(),
			"password": password,
		}
	)
	if not bool(result.get("ok", false)):
		return result

	var payload: Dictionary = _as_dictionary(result.get("body", {}))
	var session := _session_from_auth_payload(payload, false, true)
	if session.is_empty():
		return _error("INVALID_AUTH_RESPONSE", "Supabase Auth did not return an email session. Confirm email may still be enabled.")

	return {"ok": true, "session": session}

func sign_in_with_email(email: String, password: String) -> Dictionary:
	var result: Dictionary = await _send_json(
		auth_password_url(),
		HTTPClient.METHOD_POST,
		_base_headers(),
		{
			"email": email.strip_edges(),
			"password": password,
		}
	)
	if not bool(result.get("ok", false)):
		return result

	var payload: Dictionary = _as_dictionary(result.get("body", {}))
	var session := _session_from_auth_payload(payload, false, true)
	if session.is_empty():
		return _error("INVALID_AUTH_RESPONSE", "Supabase Auth did not return an email session.")

	return {"ok": true, "session": session}

func refresh_auth_session(refresh_token: String) -> Dictionary:
	var refresh := refresh_token.strip_edges()
	if refresh == "":
		return _error("REFRESH_TOKEN_MISSING", "Refresh token is not available.")
	var result: Dictionary = await _send_json(
		auth_refresh_url(),
		HTTPClient.METHOD_POST,
		_base_headers(),
		{"refresh_token": refresh}
	)
	if not bool(result.get("ok", false)):
		return result

	var payload: Dictionary = _as_dictionary(result.get("body", {}))
	var session := _session_from_auth_payload(payload, false, false)
	if session.is_empty():
		return _error("INVALID_AUTH_RESPONSE", "Supabase Auth did not return a refreshed session.")

	return {"ok": true, "session": session}

func bootstrap_alpha_account(invite_code: String, username: String, request_id: String, device_label: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("account/bootstrap"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("account/bootstrap", {
			"invite_code": invite_code,
			"username": username,
			"device_label": device_label,
			"request_id": request_id,
		}, request_hash)
	)

func create_guest_account(invite_code: String, request_id: String, device_label: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("account/guest"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("account/guest", {
			"invite_code": invite_code,
			"device_label": device_label,
			"request_id": request_id,
		}, request_hash)
	)

func fetch_account_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("account/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func reset_active_save(request_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("account/saves/reset"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("account/saves/reset", {
			"request_id": request_id,
			"save_type": active_save_type,
		}, request_hash)
	)

func apply_progression_lab_save(request_id: String, profile_id: String, milestone_id: String, save_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	var normalized_hash := request_hash.strip_edges()
	if normalized_hash == "":
		return _error("INVALID_REQUEST_HASH", "Progression Lab apply requires a prepared mutation request_hash.")
	return await _send_json(
		function_url("progression-lab/apply"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("progression-lab/apply", {
			"request_id": request_id,
			"profile_id": profile_id,
			"milestone_id": milestone_id,
			"save_id": save_id,
		}, normalized_hash)
	)

func run_remote_battle_lab(request_payload: Dictionary, access_token: String) -> Dictionary:
	return await _send_json(
		function_url("lab-runner/battle"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		{
			"request": request_payload,
		}
	)

func run_remote_progression_lab(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("lab-runner/progression"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		{}
	)

func request_battle(request_id: String, access_token: String, mode: String = "", opponent_bot_id: String = "", request_hash: String = "") -> Dictionary:
	var effective_mode := mode.strip_edges()
	if effective_mode == "":
		effective_mode = ProjectInfoScript.DEFAULT_BATTLE_MODE
	var body := {
		"request_id": request_id,
		"mode": effective_mode,
	}
	if opponent_bot_id.strip_edges() != "":
		body["opponent_bot_id"] = opponent_bot_id.strip_edges()
	return await _send_json(
		function_url("battle/request"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("battle/request", body, request_hash)
	)

func fetch_latest_battle(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("battle/latest"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func fetch_battle_history(access_token: String, limit: int = 10) -> Dictionary:
	var safe_limit := clampi(limit, 1, 20)
	return await _send_json(
		"%s?limit=%d" % [function_url("battle/history"), safe_limit],
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func fetch_battle_replay(battle_id: String, access_token: String) -> Dictionary:
	return await _send_json(
		"%s?battle_id=%s" % [function_url("battle/replay"), battle_id.strip_edges()],
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func fetch_arena_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("arena/pve/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func start_arena_attempt(request_id: String, arena_id: String, difficulty_id: String, difficulty_tier: int, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("arena/pve/start"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("arena/pve/start", {
			"request_id": request_id,
			"arena_id": arena_id.strip_edges(),
			"difficulty_id": difficulty_id.strip_edges(),
			"difficulty_tier": maxi(0, difficulty_tier),
		}, request_hash)
	)

func resolve_arena_duel(request_id: String, attempt_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("arena/pve/duel/request"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("arena/pve/duel/request", {
			"request_id": request_id,
			"attempt_id": attempt_id.strip_edges(),
		}, request_hash)
	)

func choose_arena_buff(request_id: String, attempt_id: String, step_index: int, buff_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("arena/pve/buff/select"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("arena/pve/buff/select", {
			"request_id": request_id,
			"attempt_id": attempt_id.strip_edges(),
			"step_index": maxi(1, step_index),
			"buff_id": buff_id.strip_edges(),
		}, request_hash)
	)

func claim_arena_summary(request_id: String, attempt_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("arena/pve/claim"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("arena/pve/claim", {
			"request_id": request_id,
			"attempt_id": attempt_id.strip_edges(),
		}, request_hash)
	)

func abandon_arena_attempt(request_id: String, attempt_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("arena/pve/abandon"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("arena/pve/abandon", {
			"request_id": request_id,
			"attempt_id": attempt_id.strip_edges(),
		}, request_hash)
	)

func fetch_base_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("base/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func collect_base(request_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("base/collect"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("base/collect", {"request_id": request_id}, request_hash)
	)

func upgrade_base_structure(request_id: String, structure_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("base/upgrade"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("base/upgrade", {
			"request_id": request_id,
			"structure_id": structure_id,
		}, request_hash)
	)

func get_mode_state(mode_id: String, access_token: String) -> Dictionary:
	return await _send_json(
		"%s?mode_id=%s" % [function_url("modes/state"), mode_id.strip_edges()],
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func start_mode_session(request_id: String, mode_id: String, slice_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("modes/session/start"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("modes/session/start", {
			"request_id": request_id,
			"mode_id": mode_id.strip_edges(),
			"slice_id": slice_id.strip_edges(),
		}, request_hash)
	)

func complete_mode_session(request_id: String, session_id: String, mode_id: String, result_payload: Dictionary, access_token: String, request_hash: String = "") -> Dictionary:
	var body := result_payload.duplicate(true)
	body["request_id"] = request_id
	body["session_id"] = session_id.strip_edges()
	body["mode_id"] = mode_id.strip_edges()
	return await _send_json(
		function_url("modes/session/complete"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("modes/session/complete", body, request_hash)
	)

func record_mode_session_event(
	request_id: String,
	session_id: String,
	mode_id: String,
	slice_id: String,
	event_type: String,
	expected_revision: int,
	event_payload: Dictionary,
	access_token: String,
	request_hash: String = ""
) -> Dictionary:
	var body := {
		"request_id": request_id,
		"session_id": session_id.strip_edges(),
		"mode_id": mode_id.strip_edges(),
		"slice_id": slice_id.strip_edges(),
		"event_type": event_type.strip_edges(),
		"expected_revision": expected_revision,
		"event_payload": event_payload.duplicate(true),
	}
	return await _send_json(
		function_url("modes/session/event"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("modes/session/event", body, request_hash)
	)

func checkpoint_mode_session(request_id: String, checkpoint_payload: Dictionary, access_token: String, request_hash: String = "") -> Dictionary:
	var body := checkpoint_payload.duplicate(true)
	body["request_id"] = request_id
	return await _send_json(
		function_url("modes/session/checkpoint"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("modes/session/checkpoint", body, request_hash)
	)

func abandon_mode_session(request_id: String, session_id: String, mode_id: String, reason: String, access_token: String, request_hash: String = "") -> Dictionary:
	var body := {
		"request_id": request_id,
		"session_id": session_id.strip_edges(),
		"mode_id": mode_id.strip_edges(),
		"reason": reason.strip_edges(),
	}
	return await _send_json(
		function_url("modes/session/abandon"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("modes/session/abandon", body, request_hash)
	)

func fetch_crafting_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("crafting/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func crush_bones(request_id: String, amount: int, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("crafting/crush-bones"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("crafting/crush-bones", {
			"request_id": request_id,
			"amount": maxi(1, amount),
		}, request_hash)
	)

func craft_item(request_id: String, recipe_id: String, quantity: int, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("crafting/craft"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("crafting/craft", {
			"request_id": request_id,
			"recipe_id": recipe_id,
			"quantity": maxi(1, quantity),
		}, request_hash)
	)

func station_craft_item(request_id: String, recipe_id: String, quantity: int, station_context: Dictionary, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("crafting/station-craft"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("crafting/station-craft", {
			"request_id": request_id,
			"recipe_id": recipe_id,
			"quantity": maxi(1, quantity),
			"station_context": station_context.duplicate(true),
		}, request_hash)
	)

func fetch_build_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("build/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func equip_build(request_id: String, partial_payload: Dictionary, access_token: String, request_hash: String = "") -> Dictionary:
	var body := partial_payload.duplicate(true)
	body["request_id"] = request_id
	return await _send_json(
		function_url("build/equip"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("build/equip", body, request_hash)
	)

func update_spell_behavior(request_id: String, spell_id: String, behavior: Dictionary, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("build/spell-behavior"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("build/spell-behavior", {
			"request_id": request_id,
			"spell_id": spell_id,
			"behavior": behavior,
		}, request_hash)
	)

func equip_potion(request_id: String, item_id: Variant, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("build/potion/equip"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("build/potion/equip", {
			"request_id": request_id,
			"slot_index": 1,
			"item_id": item_id,
		}, request_hash)
	)

func update_potion_behavior(request_id: String, behavior: Dictionary, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("build/potion-behavior"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("build/potion-behavior", {
			"request_id": request_id,
			"slot_index": 1,
			"behavior": behavior,
		}, request_hash)
	)

func fetch_social_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("social/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func add_friend(request_id: String, friend_username: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("social/friends/add"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("social/friends/add", {
			"request_id": request_id,
			"username": friend_username,
		}, request_hash)
	)

func create_guild(request_id: String, guild_name: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("social/guild/create"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("social/guild/create", {
			"request_id": request_id,
			"name": guild_name,
		}, request_hash)
	)

func join_guild(request_id: String, guild_name: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("social/guild/join"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("social/guild/join", {
			"request_id": request_id,
			"name": guild_name,
		}, request_hash)
	)

func send_guild_chat(request_id: String, content: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("social/chat/send"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("social/chat/send", {
			"request_id": request_id,
			"content": content,
		}, request_hash)
	)

func fetch_matchmaking_preview(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("competition/matchmaking/preview"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func fetch_ranking_current(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("competition/ranking/current"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func fetch_monetization_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("monetization/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func claim_reward(request_id: String, reward_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("monetization/rewards/claim"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("monetization/rewards/claim", {
			"request_id": request_id,
			"reward_id": reward_id,
		}, request_hash)
	)

func alpha_purchase(request_id: String, product_id: String, access_token: String, request_hash: String = "") -> Dictionary:
	return await _send_json(
		function_url("monetization/alpha-purchase"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		_with_request_hash("monetization/alpha-purchase", {
			"request_id": request_id,
			"product_id": product_id,
		}, request_hash)
	)

func send_client_telemetry(access_token: String, session_id: String, event_type: String, payload: Dictionary = {}) -> Dictionary:
	return await _send_json(
		function_url("telemetry/client-event"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		{
			"schema_version": "telemetry_client_v1",
			"event_type": event_type,
			"session_id": session_id,
			"payload": payload,
		}
	)

func _load_project_settings() -> void:
	configure_backend(BackendConfigScript.load_from_project_settings())

func _base_headers() -> PackedStringArray:
	return PackedStringArray([
		"Accept: application/json",
		"Content-Type: application/json",
		"apikey: %s" % publishable_key,
		"x-draxos-save-type: %s" % active_save_type,
		"x-draxos-api-version: %s" % DRAXOS_API_VERSION,
	])

func _manifest_headers() -> PackedStringArray:
	return _release_headers(update_manifest_url)

func _release_headers(url: String) -> PackedStringArray:
	var headers := PackedStringArray([
		"Accept: application/json",
		"Content-Type: application/json",
	])
	if url.begins_with(supabase_url):
		headers.append("apikey: %s" % publishable_key)
	return headers

func _auth_headers(access_token: String) -> PackedStringArray:
	var headers := _base_headers()
	headers.append("Authorization: Bearer %s" % access_token)
	return headers

func _with_request_hash(endpoint: String, body: Dictionary, request_hash: String = "") -> Dictionary:
	var result := body.duplicate(true)
	if str(result.get("request_id", "")).strip_edges() == "":
		return result
	var resolved_hash := request_hash.strip_edges()
	if resolved_hash == "":
		resolved_hash = request_hash_for_mutation(endpoint, result)
	result["request_hash"] = resolved_hash
	return result

static func request_hash_for_mutation(endpoint: String, payload: Dictionary) -> String:
	return PendingMutationQueueScript.request_hash_for_mutation(endpoint, payload)

func _send_json(url: String, method: HTTPClient.Method, headers: PackedStringArray, body: Dictionary) -> Dictionary:
	var started_ms := int(Time.get_ticks_msec())
	if not backend_config_errors.is_empty():
		return _with_client_context(
			_error("CLIENT_MISCONFIGURED", "Backend config invalid: %s" % ", ".join(backend_config_errors)),
			headers,
			_request_context(url, method, started_ms, 0)
		)
	if publishable_key == "":
		return _with_client_context(
			_error("CLIENT_MISCONFIGURED", "Supabase publishable key is missing."),
			headers,
			_request_context(url, method, started_ms, 0)
		)

	var request := HTTPRequest.new()
	request.timeout = REQUEST_TIMEOUT_SECONDS
	add_child(request)

	var request_body := ""
	if method != HTTPClient.METHOD_GET:
		request_body = JSON.stringify(body)

	var error_code: Error = request.request(url, headers, method, request_body)
	if error_code != OK:
		request.queue_free()
		return _with_client_context(
			_error("REQUEST_NOT_STARTED", "HTTP request could not be started."),
			headers,
			_request_context(url, method, started_ms, 0)
		)

	var completed: Array = await request.request_completed
	request.queue_free()

	var result_code := int(completed[0])
	var response_code := int(completed[1])
	var response_body := PackedByteArray(completed[3]).get_string_from_utf8()

	if result_code != HTTPRequest.RESULT_SUCCESS:
		return _with_client_context(
			_error("NETWORK_UNAVAILABLE", _network_unavailable_message(), response_code),
			headers,
			_request_context(url, method, started_ms, response_code)
		)

	var parsed: Variant = null
	if response_body != "":
		parsed = JSON.parse_string(response_body)

	if parsed == null:
		parsed = {}
	if not parsed is Dictionary:
		return _with_client_context(
			_error("INVALID_JSON", "Server response was not a JSON object.", response_code),
			headers,
			_request_context(url, method, started_ms, response_code)
		)

	var payload := _as_dictionary(parsed)
	if response_code < 200 or response_code >= 300 or not bool(payload.get("ok", true)):
		return _with_client_context(_server_error(payload, response_code), headers, _request_context(url, method, started_ms, response_code))

	return _with_client_context({"ok": true, "status": response_code, "body": payload}, headers, _request_context(url, method, started_ms, response_code))

func _session_from_auth_payload(payload: Dictionary, require_anonymous: bool, require_registered: bool) -> Dictionary:
	var access_token := str(payload.get("access_token", ""))
	var refresh_token := str(payload.get("refresh_token", ""))
	var expires_at := int(payload.get("expires_at", 0))
	if expires_at <= 0:
		expires_at = int(Time.get_unix_time_from_system()) + int(payload.get("expires_in", 3600))
	var user := _as_dictionary(payload.get("user", {}))
	if access_token == "" or refresh_token == "" or expires_at <= 0:
		return {}
	var is_anonymous := bool(user.get("is_anonymous", false))
	if require_anonymous and not is_anonymous:
		return {}
	if require_registered and is_anonymous:
		return {}

	return {
		"access_token": access_token,
		"refresh_token": refresh_token,
		"expires_at": expires_at,
		"user_id": str(user.get("id", "")),
		"is_anonymous": is_anonymous,
		"auth_method": "guest" if is_anonymous else "email",
		"email": str(user.get("email", "")),
	}

func _server_error(payload: Dictionary, response_code: int) -> Dictionary:
	var error_payload := _as_dictionary(payload.get("error", {}))
	var raw_error: Variant = payload.get("error", "")
	var raw_code := str(payload.get("error_code", "")).strip_edges()
	var raw_message := str(payload.get("msg", "")).strip_edges()
	if raw_message == "":
		raw_message = str(payload.get("error_description", "")).strip_edges()
	var code := str(error_payload.get("code", "")).strip_edges()
	var message := str(error_payload.get("message", "")).strip_edges()
	if code == "" and raw_code != "":
		code = raw_code
	if code == "" and raw_error is String:
		code = str(raw_error).strip_edges()
	var payload_code: Variant = payload.get("code", "")
	if code == "" and not (payload_code is int):
		code = str(payload_code).strip_edges()
	if message == "" and raw_message != "":
		message = raw_message
	if message == "" and raw_error is String and raw_message == "":
		message = str(raw_error).strip_edges()
	code = _normalize_server_error_code(code, response_code)
	if message == "":
		message = "Request failed."
	return _error(code, message, response_code)

static func _normalize_server_error_code(code: String, _response_code: int) -> String:
	var normalized := code.strip_edges()
	var lowered := normalized.to_lower()
	if lowered in ["invalid_credentials", "invalid_grant"]:
		return "INVALID_LOGIN_CREDENTIALS"
	if lowered in ["email_not_confirmed", "email_not_confirmed_signup"]:
		return "EMAIL_NOT_CONFIRMED"
	if lowered in ["email_exists", "user_already_exists", "user_already_registered"]:
		return "EMAIL_ALREADY_EXISTS"
	if lowered in ["bad_json", "validation_failed", "invalid_request"]:
		return "HTTP_ERROR"
	if normalized == "" or normalized.is_valid_int():
		return "HTTP_ERROR"
	return normalized.to_upper()

func _error(code: String, message: String, status: int = 0) -> Dictionary:
	return {
		"ok": false,
		"status": status,
		"error": {
			"code": code,
			"message": message,
		},
	}

func _network_unavailable_message() -> String:
	if backend_environment == BackendConfigScript.ENVIRONMENT_LOCAL or supabase_url.begins_with("http://127.0.0.1") or supabase_url.begins_with("http://localhost"):
		return "Rede indisponivel ou Supabase local fora do ar."
	return "Rede indisponivel ou Supabase remoto bloqueou a conexao."

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _packed_string_array(value: Variant) -> PackedStringArray:
	if value is PackedStringArray:
		return value
	var result := PackedStringArray()
	if value is Array:
		for item in value:
			result.append(str(item))
	return result

static func _with_client_context(result: Dictionary, headers: PackedStringArray, request_context: Dictionary = {}) -> Dictionary:
	var context := _client_context_from_headers(headers)
	for key: Variant in request_context.keys():
		context[str(key)] = request_context.get(key)
	if context.is_empty():
		return result
	var annotated := result.duplicate(true)
	annotated[CLIENT_META_KEY] = context
	return annotated

static func _client_context_from_headers(headers: PackedStringArray) -> Dictionary:
	var context := {}
	for header: String in headers:
		var delimiter_index := header.find(":")
		if delimiter_index < 0:
			continue
		var header_name := header.substr(0, delimiter_index).strip_edges().to_lower()
		var header_value := header.substr(delimiter_index + 1).strip_edges()
		if header_name == "x-draxos-save-type":
			context[CLIENT_SAVE_TYPE_KEY] = _normalize_save_type(header_value)
		elif header_name == "x-draxos-api-version":
			context[CLIENT_API_VERSION_KEY] = header_value
	return context

func _request_context(url: String, method: HTTPClient.Method, started_ms: int, response_code: int) -> Dictionary:
	var duration_ms := maxi(0, int(Time.get_ticks_msec()) - started_ms)
	return {
		"url": url,
		"endpoint": _logical_endpoint(url),
		"method": _method_label(method),
		"duration_ms": duration_ms,
		"response_code": response_code,
		"environment": backend_environment,
	}

func _logical_endpoint(url: String) -> String:
	var functions_marker := "/functions/v1/"
	var marker_index := url.find(functions_marker)
	if marker_index >= 0:
		return url.substr(marker_index + functions_marker.length()).get_slice("?", 0)
	if url.find("/auth/v1/") >= 0:
		return "auth/%s" % url.get_slice("/auth/v1/", 1).get_slice("?", 0)
	return url.get_file()

static func _method_label(method: HTTPClient.Method) -> String:
	match method:
		HTTPClient.METHOD_GET:
			return "GET"
		HTTPClient.METHOD_POST:
			return "POST"
		HTTPClient.METHOD_PUT:
			return "PUT"
		HTTPClient.METHOD_PATCH:
			return "PATCH"
		HTTPClient.METHOD_DELETE:
			return "DELETE"
		_:
			return str(int(method))

static func _stable_json(value: Variant) -> String:
	return PendingMutationQueueScript.canonical_json(value)

static func _normalize_save_type(save_type: String) -> String:
	if save_type.strip_edges().to_lower() == SAVE_TYPE_PROGRESSION_LAB:
		return SAVE_TYPE_PROGRESSION_LAB
	return SAVE_TYPE_NORMAL
