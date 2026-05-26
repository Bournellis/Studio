extends Node

signal session_changed

const CACHE_VERSION := 1
const CACHE_PATH := "user://session_cache.json"
const DEFAULT_INVITE_CODE := "ALPHA-TEST"
const TOKEN_EXPIRY_GRACE_SECONDS := 60
const SAVE_TYPE_NORMAL := "normal"
const SAVE_TYPE_PROGRESSION_LAB := "progression_lab"

var access_token := ""
var refresh_token := ""
var expires_at := 0
var auth_user_id := ""
var session_id := ""
var guest_request_id := ""
var active_save_type := SAVE_TYPE_NORMAL
var player: Dictionary = {}
var resources: Dictionary = {}
var build: Dictionary = {}
var base_state: Dictionary = {}
var social_state: Dictionary = {}
var competition_state: Dictionary = {}
var monetization_state: Dictionary = {}
var progression_lab: Dictionary = {}
var last_battle_id: Variant = null
var last_battle_log: Dictionary = {}
var last_battle_rewards: Dictionary = {}
var last_error: Dictionary = {}
var offline := false

func load_cache() -> bool:
	if not FileAccess.file_exists(CACHE_PATH):
		ensure_session_id()
		return false

	var file := FileAccess.open(CACHE_PATH, FileAccess.READ)
	if file == null:
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false

	var cache := _as_dictionary(parsed)
	if int(cache.get("cache_version", 0)) != CACHE_VERSION:
		ensure_session_id()
		return false

	_apply_cache(cache)
	ensure_session_id()
	session_changed.emit()
	return true

func save_cache() -> bool:
	var file := FileAccess.open(CACHE_PATH, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string(JSON.stringify(snapshot(), "\t"))
	return true

func apply_snapshot_cache(cache: Dictionary) -> bool:
	if int(cache.get("cache_version", 0)) != CACHE_VERSION:
		last_error = {
			"code": "INVALID_SESSION_CACHE",
			"message": "Cache de sessao incompativel.",
		}
		session_changed.emit()
		return false

	_apply_cache(cache)
	ensure_session_id()
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func clear_session() -> void:
	access_token = ""
	refresh_token = ""
	expires_at = 0
	auth_user_id = ""
	session_id = create_request_id()
	guest_request_id = ""
	active_save_type = SAVE_TYPE_NORMAL
	player = {}
	resources = {}
	build = {}
	base_state = {}
	social_state = {}
	competition_state = {}
	monetization_state = {}
	progression_lab = {}
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

	if is_progression_lab_local_only():
		player = {}
		resources = {}
		build = {}
		base_state = {}
		social_state = {}
		competition_state = {}
		monetization_state = {}
		progression_lab = {}
		last_battle_id = null
		last_battle_log = {}
		last_battle_rewards = {}
		active_save_type = SAVE_TYPE_NORMAL
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
		last_error = _as_dictionary(body.get("error", {
			"code": "BATTLE_NOT_OK",
			"message": "Servidor recusou a batalha.",
		}))
		session_changed.emit()
		return false

	var battle_log := _as_dictionary(body.get("battle_log", {}))
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
	last_battle_rewards = _as_dictionary(body.get("rewards", {})).duplicate(true)
	last_battle_id = str(last_battle_log.get("battle_id", ""))
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_server_state(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "STATE_NOT_OK",
			"message": "Servidor recusou o estado de conta.",
		}))
		session_changed.emit()
		return false

	var server_player := _as_dictionary(body.get("player", {}))
	var server_resources := _as_dictionary(body.get("resources", {}))
	var server_build := _as_dictionary(body.get("build", {}))
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
	active_save_type = normalize_save_type(str(server_player.get("save_type", active_save_type)))
	last_battle_id = body.get("last_battle_id", last_battle_id)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_save_reset(payload: Dictionary) -> bool:
	if not apply_server_state(payload):
		return false

	base_state = {}
	social_state = {}
	competition_state = {}
	monetization_state = {}
	last_battle_id = null
	last_battle_log = {}
	last_battle_rewards = {}
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_base_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "BASE_NOT_OK",
			"message": "Servidor recusou o estado da base.",
		}))
		session_changed.emit()
		return false

	var server_base := _as_dictionary(body.get("base", {}))
	if server_base.is_empty():
		last_error = {
			"code": "BASE_STATE_INCOMPLETE",
			"message": "Estado da base incompleto.",
		}
		session_changed.emit()
		return false

	if body.get("resources", null) is Dictionary:
		resources = _as_dictionary(body.get("resources", {})).duplicate(true)
	base_state = server_base.duplicate(true)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_social_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "SOCIAL_NOT_OK",
			"message": "Servidor recusou o estado social.",
		}))
		session_changed.emit()
		return false

	var server_social := _as_dictionary(body.get("social", {}))
	if server_social.is_empty():
		last_error = {
			"code": "SOCIAL_STATE_INCOMPLETE",
			"message": "Estado social incompleto.",
		}
		session_changed.emit()
		return false

	social_state = server_social.duplicate(true)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_competition_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "COMPETITION_NOT_OK",
			"message": "Servidor recusou o estado competitivo.",
		}))
		session_changed.emit()
		return false

	var state := {}
	if body.get("matchmaking", null) is Dictionary:
		state["matchmaking"] = _as_dictionary(body.get("matchmaking", {})).duplicate(true)
	if body.get("ranking", null) is Dictionary:
		state["ranking"] = _as_dictionary(body.get("ranking", {})).duplicate(true)
	if state.is_empty():
		last_error = {
			"code": "COMPETITION_STATE_INCOMPLETE",
			"message": "Estado competitivo incompleto.",
		}
		session_changed.emit()
		return false

	for key: String in state.keys():
		competition_state[key] = state[key]
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_monetization_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "MONETIZATION_NOT_OK",
			"message": "Servidor recusou o estado de monetizacao.",
		}))
		session_changed.emit()
		return false

	var state := _as_dictionary(body.get("monetization", {}))
	if state.is_empty():
		last_error = {
			"code": "MONETIZATION_STATE_INCOMPLETE",
			"message": "Estado de monetizacao incompleto.",
		}
		session_changed.emit()
		return false

	if body.get("resources", null) is Dictionary:
		resources = _as_dictionary(body.get("resources", {})).duplicate(true)
	if body.get("player", null) is Dictionary:
		player = _as_dictionary(body.get("player", {})).duplicate(true)
	monetization_state = state.duplicate(true)
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

func has_base_state() -> bool:
	return not base_state.is_empty()

func has_social_state() -> bool:
	return not social_state.is_empty()

func has_competition_state() -> bool:
	return not competition_state.is_empty()

func has_monetization_state() -> bool:
	return not monetization_state.is_empty()

func is_progression_lab_local_only() -> bool:
	return bool(progression_lab.get("local_only", false))

func is_progression_lab_active() -> bool:
	return active_save_type == SAVE_TYPE_PROGRESSION_LAB

func active_save_label() -> String:
	if active_save_type == SAVE_TYPE_PROGRESSION_LAB:
		return "Progression Lab"
	return "Normal"

func active_save_badge() -> String:
	if active_save_type == SAVE_TYPE_PROGRESSION_LAB:
		return "lab"
	return "normal"

func set_active_save_type(save_type: String) -> bool:
	var normalized := normalize_save_type(save_type)
	if normalized == active_save_type:
		return false
	active_save_type = normalized
	_clear_account_snapshots()
	last_error = {}
	offline = false
	save_cache()
	session_changed.emit()
	return true

static func normalize_save_type(save_type: String) -> String:
	var normalized := save_type.strip_edges().to_lower()
	if normalized == SAVE_TYPE_PROGRESSION_LAB:
		return SAVE_TYPE_PROGRESSION_LAB
	return SAVE_TYPE_NORMAL

func progression_lab_label() -> String:
	if progression_lab.is_empty():
		return ""
	var profile_id := str(progression_lab.get("profile_id", ""))
	var milestone_id := str(progression_lab.get("milestone_id", ""))
	if profile_id != "" and milestone_id != "":
		return "%s/%s" % [profile_id, milestone_id]
	return str(progression_lab.get("save_id", "Progression Lab"))

func ensure_guest_request_id() -> String:
	if guest_request_id == "":
		guest_request_id = create_request_id()
		save_cache()
	return guest_request_id

func ensure_session_id() -> String:
	if session_id == "":
		session_id = create_request_id()
	return session_id

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
		"session_id": ensure_session_id(),
		"guest_request_id": guest_request_id,
		"active_save_type": active_save_type,
		"player": player.duplicate(true),
		"resources": resources.duplicate(true),
		"build": build.duplicate(true),
		"base_state": base_state.duplicate(true),
		"social_state": social_state.duplicate(true),
		"competition_state": competition_state.duplicate(true),
		"monetization_state": monetization_state.duplicate(true),
		"progression_lab": progression_lab.duplicate(true),
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
	var auth := _as_dictionary(cache.get("auth", {}))
	access_token = str(auth.get("access_token", ""))
	refresh_token = str(auth.get("refresh_token", ""))
	expires_at = int(auth.get("expires_at", 0))
	auth_user_id = str(auth.get("user_id", ""))
	session_id = str(cache.get("session_id", ""))
	guest_request_id = str(cache.get("guest_request_id", ""))
	active_save_type = normalize_save_type(str(cache.get("active_save_type", SAVE_TYPE_NORMAL)))
	player = _as_dictionary(cache.get("player", {})).duplicate(true)
	resources = _as_dictionary(cache.get("resources", {})).duplicate(true)
	build = _as_dictionary(cache.get("build", {})).duplicate(true)
	base_state = _as_dictionary(cache.get("base_state", {})).duplicate(true)
	social_state = _as_dictionary(cache.get("social_state", {})).duplicate(true)
	competition_state = _as_dictionary(cache.get("competition_state", {})).duplicate(true)
	monetization_state = _as_dictionary(cache.get("monetization_state", {})).duplicate(true)
	progression_lab = _as_dictionary(cache.get("progression_lab", {})).duplicate(true)
	last_battle_id = cache.get("last_battle_id", null)
	last_battle_log = _as_dictionary(cache.get("last_battle_log", {})).duplicate(true)
	last_battle_rewards = _as_dictionary(cache.get("last_battle_rewards", {})).duplicate(true)
	offline = bool(cache.get("offline", false))
	last_error = _as_dictionary(cache.get("last_error", {})).duplicate(true)
	if bool(progression_lab.get("local_only", false)):
		active_save_type = SAVE_TYPE_PROGRESSION_LAB

func _clear_account_snapshots() -> void:
	player = {}
	resources = {}
	build = {}
	base_state = {}
	social_state = {}
	competition_state = {}
	monetization_state = {}
	if active_save_type == SAVE_TYPE_NORMAL:
		progression_lab = {}
	last_battle_id = null
	last_battle_log = {}
	last_battle_rewards = {}

func _unwrap_body(payload: Dictionary) -> Dictionary:
	if payload.has("body") and payload["body"] is Dictionary:
		return _as_dictionary(payload["body"])
	return payload

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
