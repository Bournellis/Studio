extends Node

signal session_changed

const CACHE_VERSION := 1
const CACHE_PATH := "user://session_cache.json"
const DEFAULT_INVITE_CODE := "ALPHA-TEST"
const TOKEN_EXPIRY_GRACE_SECONDS := 60

var access_token := ""
var refresh_token := ""
var expires_at := 0
var auth_user_id := ""
var guest_request_id := ""
var player: Dictionary = {}
var resources: Dictionary = {}
var build: Dictionary = {}
var last_battle_id: Variant = null
var last_battle_log: Dictionary = {}
var last_battle_rewards: Dictionary = {}
var last_error: Dictionary = {}
var offline := false

func load_cache() -> bool:
	if not FileAccess.file_exists(CACHE_PATH):
		return false

	var file := FileAccess.open(CACHE_PATH, FileAccess.READ)
	if file == null:
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false

	var cache := Dictionary(parsed)
	if int(cache.get("cache_version", 0)) != CACHE_VERSION:
		return false

	_apply_cache(cache)
	session_changed.emit()
	return true

func save_cache() -> bool:
	var file := FileAccess.open(CACHE_PATH, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(snapshot(), "\t"))
	return true

func clear_session() -> void:
	access_token = ""
	refresh_token = ""
	expires_at = 0
	auth_user_id = ""
	guest_request_id = ""
	player = {}
	resources = {}
	build = {}
	last_battle_id = null
	last_battle_log = {}
	last_battle_rewards = {}
	last_error = {}
	offline = false
	if FileAccess.file_exists(CACHE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CACHE_PATH))
	session_changed.emit()

func apply_auth_session(session: Dictionary) -> bool:
	var token := str(session.get("access_token", ""))
	var refresh := str(session.get("refresh_token", ""))
	var expiry := int(session.get("expires_at", 0))
	if token == "" or refresh == "" or expiry <= 0:
		last_error = {
			"code": "INVALID_AUTH_SESSION",
			"message": "Sessao anonima invalida.",
		}
		session_changed.emit()
		return false

	access_token = token
	refresh_token = refresh
	expires_at = expiry
	auth_user_id = str(session.get("user_id", auth_user_id))
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_battle_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not bool(body.get("ok", false)):
		last_error = Dictionary(body.get("error", {
			"code": "BATTLE_NOT_OK",
			"message": "Servidor recusou a batalha.",
		}))
		session_changed.emit()
		return false

	var battle_log := Dictionary(body.get("battle_log", {}))
	if battle_log.is_empty():
		last_error = {
			"code": "BATTLE_LOG_MISSING",
			"message": "Servidor nao retornou battle_log.",
		}
		session_changed.emit()
		return false

	if str(battle_log.get("schema_version", "")) != "battle_log_v1":
		last_error = {
			"code": "UNSUPPORTED_BATTLE_LOG",
			"message": "Versao de battle_log nao suportada.",
		}
		session_changed.emit()
		return false

	last_battle_log = battle_log.duplicate(true)
	last_battle_rewards = Dictionary(body.get("rewards", {})).duplicate(true)
	last_battle_id = str(last_battle_log.get("battle_id", ""))
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_server_state(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not bool(body.get("ok", false)):
		last_error = Dictionary(body.get("error", {
			"code": "STATE_NOT_OK",
			"message": "Servidor recusou o estado de conta.",
		}))
		session_changed.emit()
		return false

	var server_player := Dictionary(body.get("player", {}))
	var server_resources := Dictionary(body.get("resources", {}))
	var server_build := Dictionary(body.get("build", {}))
	if server_player.is_empty() or server_resources.is_empty() or server_build.is_empty():
		last_error = {
			"code": "ACCOUNT_STATE_INCOMPLETE",
			"message": "Estado de conta incompleto.",
		}
		session_changed.emit()
		return false

	player = server_player.duplicate(true)
	resources = server_resources.duplicate(true)
	build = server_build.duplicate(true)
	last_battle_id = body.get("last_battle_id", last_battle_id)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func mark_offline(error_payload: Dictionary) -> void:
	offline = true
	last_error = error_payload.duplicate(true)
	session_changed.emit()

func has_valid_access_token(now: int = int(Time.get_unix_time_from_system())) -> bool:
	return access_token != "" and expires_at > now + TOKEN_EXPIRY_GRACE_SECONDS

func has_account_state() -> bool:
	return not player.is_empty() and not resources.is_empty() and not build.is_empty()

func has_battle_log() -> bool:
	return not last_battle_log.is_empty()

func ensure_guest_request_id() -> String:
	if guest_request_id == "":
		guest_request_id = create_request_id()
		save_cache()
	return guest_request_id

func player_display_name() -> String:
	return str(player.get("username", "Guest Draxos"))

func snapshot() -> Dictionary:
	return {
		"cache_version": CACHE_VERSION,
		"auth": {
			"access_token": access_token,
			"refresh_token": refresh_token,
			"expires_at": expires_at,
			"user_id": auth_user_id,
		},
		"guest_request_id": guest_request_id,
		"player": player.duplicate(true),
		"resources": resources.duplicate(true),
		"build": build.duplicate(true),
		"last_battle_id": last_battle_id,
		"last_battle_log": last_battle_log.duplicate(true),
		"last_battle_rewards": last_battle_rewards.duplicate(true),
		"offline": offline,
		"last_error": last_error.duplicate(true),
	}

static func create_request_id() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var bytes: Array[int] = []
	for index in 16:
		bytes.append(rng.randi_range(0, 255))
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80

	var parts := PackedStringArray()
	for index in bytes.size():
		parts.append("%02x" % bytes[index])

	return "%s%s%s%s-%s%s-%s%s-%s%s-%s%s%s%s%s%s" % [
		parts[0], parts[1], parts[2], parts[3],
		parts[4], parts[5],
		parts[6], parts[7],
		parts[8], parts[9],
		parts[10], parts[11], parts[12], parts[13], parts[14], parts[15],
	]

func _apply_cache(cache: Dictionary) -> void:
	var auth := Dictionary(cache.get("auth", {}))
	access_token = str(auth.get("access_token", ""))
	refresh_token = str(auth.get("refresh_token", ""))
	expires_at = int(auth.get("expires_at", 0))
	auth_user_id = str(auth.get("user_id", ""))
	guest_request_id = str(cache.get("guest_request_id", ""))
	player = Dictionary(cache.get("player", {})).duplicate(true)
	resources = Dictionary(cache.get("resources", {})).duplicate(true)
	build = Dictionary(cache.get("build", {})).duplicate(true)
	last_battle_id = cache.get("last_battle_id", null)
	last_battle_log = Dictionary(cache.get("last_battle_log", {})).duplicate(true)
	last_battle_rewards = Dictionary(cache.get("last_battle_rewards", {})).duplicate(true)
	offline = bool(cache.get("offline", false))
	last_error = Dictionary(cache.get("last_error", {})).duplicate(true)

func _unwrap_body(payload: Dictionary) -> Dictionary:
	if payload.has("body") and payload["body"] is Dictionary:
		return Dictionary(payload["body"])
	return payload
