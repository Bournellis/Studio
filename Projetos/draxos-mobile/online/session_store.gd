extends Node

signal session_changed

const RuntimeConfigScript = preload("res://online/runtime_config.gd")

const CACHE_VERSION := 1
const CACHE_PATH := "user://session_cache.json"
const DEFAULT_INVITE_CODE := "ALPHA-TEST"
const TOKEN_EXPIRY_GRACE_SECONDS := 60
const SAVE_TYPE_NORMAL := "normal"
const SAVE_TYPE_PROGRESSION_LAB := "progression_lab"
const CLIENT_META_KEY := "_client"
const CLIENT_SAVE_TYPE_KEY := "save_type"
const MUTATION_STATUS_PENDING := "pending"
const MUTATION_STATUS_COMPLETED := "completed"
const MUTATION_STATUS_FAILED := "failed"
const SURFACE_ACCOUNT := "account"
const SURFACE_BASE := "base"
const SURFACE_SOCIAL := "social"
const SURFACE_COMPETITION := "competition"
const SURFACE_MONETIZATION := "monetization"
const SURFACE_BATTLE := "battle"
const SURFACE_CRAFTING := "crafting"
const SURFACE_BUILD := "build"

var access_token := ""
var refresh_token := ""
var expires_at := 0
var auth_user_id := ""
var auth_method := "guest"
var auth_email := ""
var session_id := ""
var guest_request_id := ""
var alpha_account_request_id := ""
var account_username := ""
var active_save_type := SAVE_TYPE_NORMAL
var player: Dictionary = {}
var resources: Dictionary = {}
var build: Dictionary = {}
var base_state: Dictionary = {}
var social_state: Dictionary = {}
var competition_state: Dictionary = {}
var monetization_state: Dictionary = {}
var crafting_state: Dictionary = {}
var combat_build_state: Dictionary = {}
var progression_lab: Dictionary = {}
var last_battle_id: Variant = null
var last_battle_log: Dictionary = {}
var last_battle_rewards: Dictionary = {}
var last_battle_result_seen := false
var last_error: Dictionary = {}
var runtime_config: Dictionary = {}
var surface_save_types: Dictionary = {}
var pending_mutations: Dictionary = {}
var offline := false

func _init() -> void:
	runtime_config = RuntimeConfigScript.fallback()

func load_cache() -> bool:
	if not FileAccess.file_exists(CACHE_PATH):
		ensure_session_id()
		return false

	var file := FileAccess.open(CACHE_PATH, FileAccess.READ)
	if file == null:
		return false

	var parsed := _parse_json_dictionary(file.get_as_text())
	if parsed.is_empty():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CACHE_PATH))
		ensure_session_id()
		return false

	var cache := parsed
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
	auth_method = "guest"
	auth_email = ""
	session_id = create_request_id()
	guest_request_id = ""
	alpha_account_request_id = ""
	account_username = ""
	active_save_type = SAVE_TYPE_NORMAL
	player = {}
	resources = {}
	build = {}
	base_state = {}
	social_state = {}
	competition_state = {}
	monetization_state = {}
	crafting_state = {}
	combat_build_state = {}
	progression_lab = {}
	last_battle_id = null
	last_battle_log = {}
	last_battle_rewards = {}
	last_battle_result_seen = false
	last_error = {}
	surface_save_types = {}
	pending_mutations = {}
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
			"message": "Sessao de autenticacao invalida.",
		}
		session_changed.emit()
		return false

	if is_progression_lab_local_only():
		_clear_account_snapshots()
		progression_lab = {}
		active_save_type = SAVE_TYPE_NORMAL
	access_token = token
	refresh_token = refresh
	expires_at = expiry
	auth_user_id = str(session.get("user_id", auth_user_id))
	auth_method = str(session.get("auth_method", "guest")).strip_edges().to_lower()
	if auth_method == "":
		auth_method = "guest"
	auth_email = str(session.get("email", auth_email)).strip_edges()
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_battle_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_BATTLE, payload, active_save_type):
		return false
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

	var incoming_battle_id := str(battle_log.get("battle_id", ""))
	var same_battle := incoming_battle_id != "" and incoming_battle_id == str(last_battle_id)
	var previous_seen := last_battle_result_seen
	last_battle_log = battle_log.duplicate(true)
	last_battle_rewards = _as_dictionary(body.get("rewards", {})).duplicate(true)
	last_battle_id = incoming_battle_id
	last_battle_result_seen = same_battle and previous_seen
	_remember_surface_snapshot(SURFACE_BATTLE)
	if body.get("competition", null) is Dictionary:
		competition_state["last_battle"] = _as_dictionary(body.get("competition", {})).duplicate(true)
		_remember_surface_snapshot(SURFACE_COMPETITION)
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
	if not _accept_save_scoped_payload(
		SURFACE_ACCOUNT,
		payload,
		str(server_player.get("save_type", active_save_type))
	):
		return false
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
	active_save_type = _payload_save_type(payload, str(server_player.get("save_type", active_save_type)))
	if not player.has("save_type"):
		player["save_type"] = active_save_type
	_remember_surface_snapshot(SURFACE_ACCOUNT)
	var server_username := str(server_player.get("username", "")).strip_edges()
	if active_save_type == SAVE_TYPE_NORMAL or account_username == "":
		account_username = base_account_username(server_username)
	last_battle_id = body.get("last_battle_id", last_battle_id)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_save_reset(payload: Dictionary) -> bool:
	if not apply_server_state(payload):
		return false

	if active_save_type == SAVE_TYPE_PROGRESSION_LAB:
		progression_lab = {}
	_clear_gameplay_snapshots()
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_progression_lab_result(payload: Dictionary) -> bool:
	if not apply_server_state(payload):
		return false

	var body := _unwrap_body(payload)
	var metadata := _as_dictionary(body.get("progression_lab", {}))
	if metadata.is_empty():
		last_error = {
			"code": "PROGRESSION_LAB_METADATA_MISSING",
			"message": "Servidor nao retornou metadados do Progression Lab.",
		}
		session_changed.emit()
		return false

	active_save_type = SAVE_TYPE_PROGRESSION_LAB
	progression_lab = metadata.duplicate(true)
	progression_lab["local_only"] = bool(progression_lab.get("local_only", false))
	_clear_gameplay_snapshots()
	_remember_surface_snapshot(SURFACE_ACCOUNT)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_base_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_BASE, payload, active_save_type):
		return false
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
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	base_state = server_base.duplicate(true)
	_remember_surface_snapshot(SURFACE_BASE)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_social_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_SOCIAL, payload, active_save_type):
		return false
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
	_remember_surface_snapshot(SURFACE_SOCIAL)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_competition_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_COMPETITION, payload, active_save_type):
		return false
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
	_remember_surface_snapshot(SURFACE_COMPETITION)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_monetization_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_MONETIZATION, payload, active_save_type):
		return false
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
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	if body.get("player", null) is Dictionary:
		player = _as_dictionary(body.get("player", {})).duplicate(true)
		if not player.has("save_type"):
			player["save_type"] = active_save_type
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	monetization_state = state.duplicate(true)
	_remember_surface_snapshot(SURFACE_MONETIZATION)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_crafting_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_CRAFTING, payload, active_save_type):
		return false
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "CRAFTING_NOT_OK",
			"message": "Servidor recusou crafting.",
		}))
		session_changed.emit()
		return false

	var state := _as_dictionary(body.get("crafting", {}))
	if state.is_empty():
		last_error = {
			"code": "CRAFTING_STATE_INCOMPLETE",
			"message": "Estado de crafting incompleto.",
		}
		session_changed.emit()
		return false

	if body.get("resources", null) is Dictionary:
		resources = _as_dictionary(body.get("resources", {})).duplicate(true)
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	crafting_state = state.duplicate(true)
	_remember_surface_snapshot(SURFACE_CRAFTING)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_build_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_BUILD, payload, active_save_type):
		return false
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "BUILD_NOT_OK",
			"message": "Servidor recusou preparacao.",
		}))
		session_changed.emit()
		return false

	var state := _as_dictionary(body.get("combat_build", {}))
	if state.is_empty():
		last_error = {
			"code": "BUILD_STATE_INCOMPLETE",
			"message": "Estado de preparacao incompleto.",
		}
		session_changed.emit()
		return false

	if body.get("build", null) is Dictionary:
		build = _as_dictionary(body.get("build", {})).duplicate(true)
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	if body.get("player", null) is Dictionary:
		var player_patch := _as_dictionary(body.get("player", {}))
		for key_variant: Variant in player_patch.keys():
			player[str(key_variant)] = player_patch.get(key_variant)
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	combat_build_state = state.duplicate(true)
	_remember_surface_snapshot(SURFACE_BUILD)
	last_error = {}
	offline = false
	session_changed.emit()
	return true

func apply_runtime_config(config: Dictionary) -> bool:
	runtime_config = RuntimeConfigScript.normalize(config)
	session_changed.emit()
	return true

func mark_offline(error_payload: Dictionary) -> void:
	offline = true
	last_error = error_payload.duplicate(true)
	session_changed.emit()

func has_valid_access_token(now: int = int(Time.get_unix_time_from_system())) -> bool:
	return access_token != "" and expires_at > now + TOKEN_EXPIRY_GRACE_SECONDS

func has_account_state() -> bool:
	return not player.is_empty() and not resources.is_empty() and not build.is_empty() and _surface_matches_active_save(SURFACE_ACCOUNT)

func has_battle_log() -> bool:
	return not last_battle_log.is_empty() and _surface_matches_active_save(SURFACE_BATTLE)

func has_unseen_battle_result() -> bool:
	return has_battle_log() and not last_battle_result_seen

func mark_battle_result_seen() -> void:
	if not has_battle_log():
		return
	last_battle_result_seen = true
	session_changed.emit()

func has_base_state() -> bool:
	return not base_state.is_empty() and _surface_matches_active_save(SURFACE_BASE)

func has_social_state() -> bool:
	return not social_state.is_empty() and _surface_matches_active_save(SURFACE_SOCIAL)

func has_competition_state() -> bool:
	return not competition_state.is_empty() and _surface_matches_active_save(SURFACE_COMPETITION)

func has_monetization_state() -> bool:
	return not monetization_state.is_empty() and _surface_matches_active_save(SURFACE_MONETIZATION)

func has_crafting_state() -> bool:
	return not crafting_state.is_empty() and _surface_matches_active_save(SURFACE_CRAFTING)

func has_build_state() -> bool:
	return not combat_build_state.is_empty() and _surface_matches_active_save(SURFACE_BUILD)

func is_progression_lab_local_only() -> bool:
	return bool(progression_lab.get("local_only", false))

func is_progression_lab_active() -> bool:
	return active_save_type == SAVE_TYPE_PROGRESSION_LAB

func is_registered_session() -> bool:
	return auth_method == "email"

func runtime_feature_enabled(feature_id: String) -> bool:
	return RuntimeConfigScript.feature_enabled(runtime_config, feature_id)

func runtime_config_is_fallback() -> bool:
	return RuntimeConfigScript.is_fallback(runtime_config)

func account_slice() -> Dictionary:
	return {
		"auth_user_id": auth_user_id,
		"auth_method": auth_method,
		"auth_email": auth_email,
		"account_username": account_username,
		"player": player.duplicate(true),
	}

func save_slice() -> Dictionary:
	return {
		"active_save_type": active_save_type,
		"label": active_save_label(),
		"badge": active_save_badge(),
		"surface_save_types": surface_save_types.duplicate(true),
		"progression_lab": progression_lab.duplicate(true),
	}

func player_snapshot() -> Dictionary:
	return player.duplicate(true)

func resources_snapshot() -> Dictionary:
	return resources.duplicate(true)

func build_snapshot() -> Dictionary:
	return build.duplicate(true)

func base_snapshot() -> Dictionary:
	return base_state.duplicate(true)

func battle_snapshot() -> Dictionary:
	return {
		"last_battle_id": last_battle_id,
		"last_battle_log": last_battle_log.duplicate(true),
		"last_battle_rewards": last_battle_rewards.duplicate(true),
		"last_battle_result_seen": last_battle_result_seen,
	}

func social_snapshot() -> Dictionary:
	return social_state.duplicate(true)

func competition_snapshot() -> Dictionary:
	return competition_state.duplicate(true)

func monetization_snapshot() -> Dictionary:
	return monetization_state.duplicate(true)

func crafting_snapshot() -> Dictionary:
	return crafting_state.duplicate(true)

func combat_build_snapshot() -> Dictionary:
	return combat_build_state.duplicate(true)

func diagnostics_snapshot() -> Dictionary:
	var runtime := RuntimeConfigScript.normalize(runtime_config)
	return {
		"cache_version": CACHE_VERSION,
		"session_id": ensure_session_id(),
		"auth": {
			"has_access_token": access_token != "",
			"has_refresh_token": refresh_token != "",
			"expires_at": expires_at,
			"has_auth_user_id": auth_user_id != "",
			"auth_method": auth_method,
			"registered": is_registered_session(),
		},
		"save": {
			"active_save_type": active_save_type,
			"label": active_save_label(),
			"badge": active_save_badge(),
		},
		"surfaces": _diagnostics_surfaces(),
		"progression_lab": {
			"active": is_progression_lab_active(),
			"local_only": is_progression_lab_local_only(),
			"has_metadata": not progression_lab.is_empty(),
			"label": progression_lab_label(),
		},
		"runtime_config": {
			"fallback": RuntimeConfigScript.is_fallback(runtime),
			"config_source": str(runtime.get("config_source", "")),
			"config_version": str(runtime.get("config_version", "")),
			"channel": str(runtime.get("channel", "")),
			"features": _as_dictionary(runtime.get("features", {})).duplicate(true),
		},
		"offline": offline,
		"last_error": {
			"code": str(last_error.get("code", "")),
			"status": int(last_error.get("status", 0)),
		},
	}

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

func account_display_name() -> String:
	if account_username != "":
		return account_username
	if auth_email != "":
		return auth_email
	return player_display_name()

func snapshot() -> Dictionary:
	return {
		"cache_version": CACHE_VERSION,
		"auth": {
			"access_token": access_token,
			"refresh_token": refresh_token,
			"expires_at": expires_at,
			"user_id": auth_user_id,
			"auth_method": auth_method,
			"email": auth_email,
		},
		"session_id": ensure_session_id(),
		"guest_request_id": guest_request_id,
		"alpha_account_request_id": alpha_account_request_id,
		"account_username": account_username,
		"active_save_type": active_save_type,
		"player": player.duplicate(true),
		"resources": resources.duplicate(true),
		"build": build.duplicate(true),
		"base_state": base_state.duplicate(true),
		"social_state": social_state.duplicate(true),
		"competition_state": competition_state.duplicate(true),
		"monetization_state": monetization_state.duplicate(true),
		"crafting_state": crafting_state.duplicate(true),
		"combat_build_state": combat_build_state.duplicate(true),
		"progression_lab": progression_lab.duplicate(true),
		"surface_save_types": surface_save_types.duplicate(true),
		"pending_mutations": pending_mutations.duplicate(true),
		"last_battle_id": last_battle_id,
		"last_battle_log": last_battle_log.duplicate(true),
		"last_battle_rewards": last_battle_rewards.duplicate(true),
		"last_battle_result_seen": last_battle_result_seen,
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

func prepare_pending_mutation(endpoint: String, scope_id: String, action_id: String, payload: Dictionary = {}) -> Dictionary:
	var normalized_endpoint := endpoint.strip_edges()
	var normalized_scope := scope_id.strip_edges()
	var normalized_action := action_id.strip_edges()
	var base_payload := payload.duplicate(true)
	base_payload.erase("request_hash")
	var request_id := str(base_payload.get("request_id", "")).strip_edges()
	if request_id == "":
		request_id = _matching_pending_request_id(normalized_endpoint, normalized_scope, normalized_action, base_payload)
	if request_id == "":
		request_id = create_request_id()
	base_payload["request_id"] = request_id
	var request_hash := request_hash_for_mutation(normalized_endpoint, base_payload)
	var attempts := 1
	if pending_mutations.has(request_id):
		attempts = int(_as_dictionary(pending_mutations.get(request_id, {})).get("attempts", 0)) + 1
	var canonical_payload := canonical_json(base_payload)
	var record := {
		"request_id": request_id,
		"request_hash": request_hash,
		"endpoint": normalized_endpoint,
		"scope_id": normalized_scope,
		"action_id": normalized_action,
		"payload": base_payload.duplicate(true),
		"payload_canonical": canonical_payload,
		"status": MUTATION_STATUS_PENDING,
		"attempts": attempts,
		"timestamp": Time.get_unix_time_from_system(),
	}
	pending_mutations[request_id] = record
	var body := base_payload.duplicate(true)
	body["request_hash"] = request_hash
	session_changed.emit()
	return {
		"request_id": request_id,
		"request_hash": request_hash,
		"endpoint": normalized_endpoint,
		"scope_id": normalized_scope,
		"action_id": normalized_action,
		"payload": body,
		"attempts": attempts,
	}

func complete_pending_mutation(request_id: String, response_payload: Dictionary = {}) -> bool:
	return _mark_pending_mutation(request_id, MUTATION_STATUS_COMPLETED, response_payload)

func fail_pending_mutation(request_id: String, error_payload: Dictionary = {}) -> bool:
	return _mark_pending_mutation(request_id, MUTATION_STATUS_FAILED, error_payload)

func clear_pending_mutation(request_id: String) -> bool:
	var normalized := request_id.strip_edges()
	var had_record := pending_mutations.has(normalized)
	pending_mutations.erase(normalized)
	if had_record:
		session_changed.emit()
	return had_record

func pending_mutation(request_id: String) -> Dictionary:
	return _as_dictionary(pending_mutations.get(request_id.strip_edges(), {})).duplicate(true)

static func request_hash_for_mutation(endpoint: String, payload: Dictionary) -> String:
	var canonical_payload := payload.duplicate(true)
	canonical_payload.erase("request_hash")
	return sha256_text("sha256", canonical_json({
		"endpoint": endpoint.strip_edges(),
		"payload": canonical_payload,
	}))

static func sha256_text(prefix: String, value: String) -> String:
	var hashing := HashingContext.new()
	var start_error := hashing.start(HashingContext.HASH_SHA256)
	if start_error != OK:
		return ""
	hashing.update(value.to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	if prefix.strip_edges() == "":
		return digest
	return "%s:%s" % [prefix.strip_edges(), digest]

static func canonical_json(value: Variant) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT, TYPE_FLOAT:
			return JSON.stringify(value)
		TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH:
			return JSON.stringify(str(value))
		TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			var parts := PackedStringArray()
			for item: Variant in value:
				parts.append(canonical_json(item))
			return "[%s]" % ",".join(parts)
		TYPE_DICTIONARY:
			var dictionary := Dictionary(value)
			var keys := PackedStringArray()
			for key: Variant in dictionary.keys():
				keys.append(str(key))
			keys.sort()
			var parts := PackedStringArray()
			for key: String in keys:
				parts.append("%s:%s" % [JSON.stringify(key), canonical_json(dictionary[key])])
			return "{%s}" % ",".join(parts)
		_:
			return JSON.stringify(value)

func _apply_cache(cache: Dictionary) -> void:
	var auth := _as_dictionary(cache.get("auth", {}))
	access_token = str(auth.get("access_token", ""))
	refresh_token = str(auth.get("refresh_token", ""))
	expires_at = int(auth.get("expires_at", 0))
	auth_user_id = str(auth.get("user_id", ""))
	auth_method = str(auth.get("auth_method", "guest")).strip_edges().to_lower()
	if auth_method == "":
		auth_method = "guest"
	auth_email = str(auth.get("email", ""))
	session_id = str(cache.get("session_id", ""))
	guest_request_id = str(cache.get("guest_request_id", ""))
	alpha_account_request_id = str(cache.get("alpha_account_request_id", ""))
	account_username = str(cache.get("account_username", ""))
	active_save_type = normalize_save_type(str(cache.get("active_save_type", SAVE_TYPE_NORMAL)))
	player = _as_dictionary(cache.get("player", {})).duplicate(true)
	resources = _as_dictionary(cache.get("resources", {})).duplicate(true)
	build = _as_dictionary(cache.get("build", {})).duplicate(true)
	base_state = _as_dictionary(cache.get("base_state", {})).duplicate(true)
	social_state = _as_dictionary(cache.get("social_state", {})).duplicate(true)
	competition_state = _as_dictionary(cache.get("competition_state", {})).duplicate(true)
	monetization_state = _as_dictionary(cache.get("monetization_state", {})).duplicate(true)
	crafting_state = _as_dictionary(cache.get("crafting_state", {})).duplicate(true)
	combat_build_state = _as_dictionary(cache.get("combat_build_state", {})).duplicate(true)
	progression_lab = _as_dictionary(cache.get("progression_lab", {})).duplicate(true)
	surface_save_types = _normalized_surface_save_types(_as_dictionary(cache.get("surface_save_types", {})))
	pending_mutations = _normalized_pending_mutations(_as_dictionary(cache.get("pending_mutations", {})))
	last_battle_id = cache.get("last_battle_id", null)
	last_battle_log = _as_dictionary(cache.get("last_battle_log", {})).duplicate(true)
	last_battle_rewards = _as_dictionary(cache.get("last_battle_rewards", {})).duplicate(true)
	last_battle_result_seen = bool(cache.get("last_battle_result_seen", false))
	offline = bool(cache.get("offline", false))
	last_error = _as_dictionary(cache.get("last_error", {})).duplicate(true)
	if not progression_lab.is_empty() and not bool(progression_lab.get("local_only", false)):
		active_save_type = SAVE_TYPE_PROGRESSION_LAB
	if bool(progression_lab.get("local_only", false)):
		active_save_type = SAVE_TYPE_PROGRESSION_LAB
		access_token = ""
		refresh_token = ""
		expires_at = 0
		auth_user_id = ""
		auth_method = "guest"
		auth_email = ""
	if active_save_type == SAVE_TYPE_NORMAL:
		progression_lab = {}
	_backfill_surface_save_types()

func _clear_account_snapshots() -> void:
	player = {}
	resources = {}
	build = {}
	base_state = {}
	social_state = {}
	competition_state = {}
	monetization_state = {}
	crafting_state = {}
	combat_build_state = {}
	if active_save_type == SAVE_TYPE_NORMAL:
		progression_lab = {}
	last_battle_id = null
	last_battle_log = {}
	last_battle_rewards = {}
	last_battle_result_seen = false
	surface_save_types = {}

func _matching_pending_request_id(endpoint: String, scope_id: String, action_id: String, payload: Dictionary) -> String:
	var canonical_payload := canonical_json(payload)
	for key: Variant in pending_mutations.keys():
		var record := _as_dictionary(pending_mutations.get(key, {}))
		if str(record.get("status", "")) != MUTATION_STATUS_PENDING:
			continue
		if str(record.get("endpoint", "")) != endpoint:
			continue
		if str(record.get("scope_id", "")) != scope_id:
			continue
		if str(record.get("action_id", "")) != action_id:
			continue
		var record_payload := _as_dictionary(record.get("payload", {})).duplicate(true)
		record_payload.erase("request_id")
		record_payload.erase("request_hash")
		if canonical_json(record_payload) == canonical_payload:
			return str(record.get("request_id", key)).strip_edges()
	return ""

func _mark_pending_mutation(request_id: String, status: String, payload: Dictionary = {}) -> bool:
	var normalized := request_id.strip_edges()
	if not pending_mutations.has(normalized):
		return false
	var record := _as_dictionary(pending_mutations.get(normalized, {})).duplicate(true)
	record["status"] = status
	record["completed_at"] = Time.get_unix_time_from_system()
	if not payload.is_empty():
		record["response_payload"] = payload.duplicate(true)
	pending_mutations[normalized] = record
	session_changed.emit()
	return true

func _normalized_pending_mutations(source: Dictionary) -> Dictionary:
	var normalized := {}
	for key: Variant in source.keys():
		var request_id := str(key).strip_edges()
		if request_id == "":
			continue
		var record := _as_dictionary(source.get(key, {})).duplicate(true)
		record["request_id"] = str(record.get("request_id", request_id)).strip_edges()
		record["request_hash"] = str(record.get("request_hash", "")).strip_edges()
		record["endpoint"] = str(record.get("endpoint", "")).strip_edges()
		record["scope_id"] = str(record.get("scope_id", "")).strip_edges()
		record["action_id"] = str(record.get("action_id", "")).strip_edges()
		record["status"] = str(record.get("status", MUTATION_STATUS_PENDING)).strip_edges()
		if record["status"] == "":
			record["status"] = MUTATION_STATUS_PENDING
		record["attempts"] = maxi(1, int(record.get("attempts", 1)))
		record["payload"] = _as_dictionary(record.get("payload", {})).duplicate(true)
		record["payload_canonical"] = str(record.get("payload_canonical", canonical_json(record["payload"])))
		normalized[request_id] = record
	return normalized

func _clear_gameplay_snapshots() -> void:
	base_state = {}
	social_state = {}
	competition_state = {}
	monetization_state = {}
	crafting_state = {}
	combat_build_state = {}
	last_battle_id = null
	last_battle_log = {}
	last_battle_rewards = {}
	last_battle_result_seen = false
	surface_save_types.erase(SURFACE_BASE)
	surface_save_types.erase(SURFACE_SOCIAL)
	surface_save_types.erase(SURFACE_COMPETITION)
	surface_save_types.erase(SURFACE_MONETIZATION)
	surface_save_types.erase(SURFACE_CRAFTING)
	surface_save_types.erase(SURFACE_BUILD)
	surface_save_types.erase(SURFACE_BATTLE)

func ensure_alpha_account_request_id() -> String:
	if alpha_account_request_id == "":
		alpha_account_request_id = create_request_id()
		save_cache()
	return alpha_account_request_id

static func base_account_username(username: String) -> String:
	var normalized := username.strip_edges()
	if normalized.ends_with("_lab"):
		return normalized.trim_suffix("_lab")
	return normalized

func _unwrap_body(payload: Dictionary) -> Dictionary:
	if payload.has("body") and payload["body"] is Dictionary:
		return _as_dictionary(payload["body"])
	return payload

func _payload_save_type(payload: Dictionary, fallback_save_type: String) -> String:
	var meta := _as_dictionary(payload.get(CLIENT_META_KEY, {}))
	if meta.has(CLIENT_SAVE_TYPE_KEY):
		return normalize_save_type(str(meta.get(CLIENT_SAVE_TYPE_KEY, fallback_save_type)))
	var body := _unwrap_body(payload)
	if body.has("save_type"):
		return normalize_save_type(str(body.get("save_type", fallback_save_type)))
	var body_player := _as_dictionary(body.get("player", {}))
	if body_player.has("save_type"):
		return normalize_save_type(str(body_player.get("save_type", fallback_save_type)))
	return normalize_save_type(fallback_save_type)

func _accept_save_scoped_payload(surface: String, payload: Dictionary, fallback_save_type: String) -> bool:
	var payload_save_type := _payload_save_type(payload, fallback_save_type)
	if payload_save_type == active_save_type:
		return true
	last_error = {
		"code": "STALE_SAVE_RESPONSE",
		"message": "Resposta de %s pertence ao save %s, mas o save ativo e %s." % [
			surface,
			payload_save_type,
			active_save_type,
		],
	}
	session_changed.emit()
	return false

func _remember_surface_snapshot(surface: String, save_type: String = active_save_type) -> void:
	surface_save_types[surface] = normalize_save_type(save_type)

func _surface_matches_active_save(surface: String) -> bool:
	return normalize_save_type(str(surface_save_types.get(surface, active_save_type))) == active_save_type

func _backfill_surface_save_types() -> void:
	if has_account_state() and not surface_save_types.has(SURFACE_ACCOUNT):
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	if not base_state.is_empty() and not surface_save_types.has(SURFACE_BASE):
		_remember_surface_snapshot(SURFACE_BASE)
	if not social_state.is_empty() and not surface_save_types.has(SURFACE_SOCIAL):
		_remember_surface_snapshot(SURFACE_SOCIAL)
	if not competition_state.is_empty() and not surface_save_types.has(SURFACE_COMPETITION):
		_remember_surface_snapshot(SURFACE_COMPETITION)
	if not monetization_state.is_empty() and not surface_save_types.has(SURFACE_MONETIZATION):
		_remember_surface_snapshot(SURFACE_MONETIZATION)
	if not crafting_state.is_empty() and not surface_save_types.has(SURFACE_CRAFTING):
		_remember_surface_snapshot(SURFACE_CRAFTING)
	if not combat_build_state.is_empty() and not surface_save_types.has(SURFACE_BUILD):
		_remember_surface_snapshot(SURFACE_BUILD)
	if not last_battle_log.is_empty() and not surface_save_types.has(SURFACE_BATTLE):
		_remember_surface_snapshot(SURFACE_BATTLE)

func _diagnostics_surfaces() -> Dictionary:
	return {
		SURFACE_ACCOUNT: _diagnostics_surface(SURFACE_ACCOUNT, has_account_state()),
		SURFACE_BASE: _diagnostics_surface(SURFACE_BASE, has_base_state()),
		SURFACE_SOCIAL: _diagnostics_surface(SURFACE_SOCIAL, has_social_state()),
		SURFACE_COMPETITION: _diagnostics_surface(SURFACE_COMPETITION, has_competition_state()),
		SURFACE_MONETIZATION: _diagnostics_surface(SURFACE_MONETIZATION, has_monetization_state()),
		SURFACE_CRAFTING: _diagnostics_surface(SURFACE_CRAFTING, has_crafting_state()),
		SURFACE_BUILD: _diagnostics_surface(SURFACE_BUILD, has_build_state()),
		SURFACE_BATTLE: _diagnostics_surface(SURFACE_BATTLE, has_battle_log()),
	}

func _diagnostics_surface(surface: String, has_snapshot: bool) -> Dictionary:
	return {
		"has_snapshot": has_snapshot,
		"save_type": normalize_save_type(str(surface_save_types.get(surface, active_save_type))),
		"matches_active_save": _surface_matches_active_save(surface),
	}

func _normalized_surface_save_types(value: Dictionary) -> Dictionary:
	var normalized := {}
	for key: String in value.keys():
		normalized[key] = normalize_save_type(str(value.get(key, SAVE_TYPE_NORMAL)))
	return normalized

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _parse_json_dictionary(text: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return {}
	var data: Variant = parser.data
	if data is Dictionary:
		return Dictionary(data)
	return {}
