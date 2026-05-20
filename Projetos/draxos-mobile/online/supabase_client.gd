extends Node

const DEFAULT_SUPABASE_URL := "http://127.0.0.1:54321"
const DEFAULT_PUBLISHABLE_KEY := "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"
const REQUEST_TIMEOUT_SECONDS := 15.0

var supabase_url := DEFAULT_SUPABASE_URL
var publishable_key := DEFAULT_PUBLISHABLE_KEY

func _ready() -> void:
	_load_project_settings()

func configure(url: String, key: String) -> void:
	supabase_url = url.strip_edges().trim_suffix("/")
	publishable_key = key.strip_edges()

func auth_anonymous_url() -> String:
	return "%s/auth/v1/signup" % supabase_url

func function_url(endpoint: String) -> String:
	return "%s/functions/v1/%s" % [supabase_url, endpoint.trim_prefix("/")]

func sign_in_anonymously() -> Dictionary:
	var result: Dictionary = await _send_json(
		auth_anonymous_url(),
		HTTPClient.METHOD_POST,
		_base_headers(),
		{"data": {"provider": "guest"}}
	)
	if not bool(result.get("ok", false)):
		return result

	var payload: Dictionary = Dictionary(result.get("body", {}))
	var session := _session_from_auth_payload(payload)
	if session.is_empty():
		return _error("INVALID_AUTH_RESPONSE", "Supabase Auth did not return an anonymous session.")

	return {"ok": true, "session": session}

func create_guest_account(invite_code: String, request_id: String, device_label: String, access_token: String) -> Dictionary:
	return await _send_json(
		function_url("account/guest"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		{
			"invite_code": invite_code,
			"device_label": device_label,
			"request_id": request_id,
		}
	)

func fetch_account_state(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("account/state"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func request_battle(request_id: String, access_token: String, mode: String = ProjectInfo.DEFAULT_BATTLE_MODE, opponent_bot_id: String = "") -> Dictionary:
	var body := {
		"request_id": request_id,
		"mode": mode,
	}
	if opponent_bot_id.strip_edges() != "":
		body["opponent_bot_id"] = opponent_bot_id.strip_edges()
	return await _send_json(
		function_url("battle/request"),
		HTTPClient.METHOD_POST,
		_auth_headers(access_token),
		body
	)

func fetch_latest_battle(access_token: String) -> Dictionary:
	return await _send_json(
		function_url("battle/latest"),
		HTTPClient.METHOD_GET,
		_auth_headers(access_token),
		{}
	)

func _load_project_settings() -> void:
	var configured_url := str(ProjectSettings.get_setting("draxos_mobile/supabase/url", DEFAULT_SUPABASE_URL))
	var configured_key := str(ProjectSettings.get_setting("draxos_mobile/supabase/publishable_key", DEFAULT_PUBLISHABLE_KEY))
	configure(configured_url, configured_key)

func _base_headers() -> PackedStringArray:
	return PackedStringArray([
		"Accept: application/json",
		"Content-Type: application/json",
		"apikey: %s" % publishable_key,
	])

func _auth_headers(access_token: String) -> PackedStringArray:
	var headers := _base_headers()
	headers.append("Authorization: Bearer %s" % access_token)
	return headers

func _send_json(url: String, method: HTTPClient.Method, headers: PackedStringArray, body: Dictionary) -> Dictionary:
	if publishable_key == "":
		return _error("CLIENT_MISCONFIGURED", "Supabase publishable key is missing.")

	var request := HTTPRequest.new()
	request.timeout = REQUEST_TIMEOUT_SECONDS
	add_child(request)

	var request_body := ""
	if method != HTTPClient.METHOD_GET:
		request_body = JSON.stringify(body)

	var error_code: Error = request.request(url, headers, method, request_body)
	if error_code != OK:
		request.queue_free()
		return _error("REQUEST_NOT_STARTED", "HTTP request could not be started.")

	var completed: Array = await request.request_completed
	request.queue_free()

	var result_code := int(completed[0])
	var response_code := int(completed[1])
	var response_body := PackedByteArray(completed[3]).get_string_from_utf8()

	if result_code != HTTPRequest.RESULT_SUCCESS:
		return _error("NETWORK_UNAVAILABLE", "Rede indisponivel ou Supabase local fora do ar.", response_code)

	var parsed: Variant = null
	if response_body != "":
		parsed = JSON.parse_string(response_body)

	if parsed == null:
		parsed = {}
	if not parsed is Dictionary:
		return _error("INVALID_JSON", "Server response was not a JSON object.", response_code)

	var payload := Dictionary(parsed)
	if response_code < 200 or response_code >= 300 or not bool(payload.get("ok", true)):
		return _server_error(payload, response_code)

	return {"ok": true, "status": response_code, "body": payload}

func _session_from_auth_payload(payload: Dictionary) -> Dictionary:
	var access_token := str(payload.get("access_token", ""))
	var refresh_token := str(payload.get("refresh_token", ""))
	var expires_at := int(payload.get("expires_at", 0))
	var user := Dictionary(payload.get("user", {}))
	if access_token == "" or refresh_token == "" or expires_at <= 0:
		return {}
	if not bool(user.get("is_anonymous", false)):
		return {}

	return {
		"access_token": access_token,
		"refresh_token": refresh_token,
		"expires_at": expires_at,
		"user_id": str(user.get("id", "")),
		"is_anonymous": true,
	}

func _server_error(payload: Dictionary, response_code: int) -> Dictionary:
	var error_payload := Dictionary(payload.get("error", {}))
	var code := str(error_payload.get("code", "HTTP_ERROR"))
	var message := str(error_payload.get("message", "Request failed."))
	return _error(code, message, response_code)

func _error(code: String, message: String, status: int = 0) -> Dictionary:
	return {
		"ok": false,
		"status": status,
		"error": {
			"code": code,
			"message": message,
		},
	}
