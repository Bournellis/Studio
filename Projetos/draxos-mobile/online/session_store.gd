extends Node

signal session_changed

const RuntimeConfigScript = preload("res://online/runtime_config.gd")
const AccountSaveSliceScript = preload("res://online/session/account_save_slice.gd")
const ArenaSliceScript = preload("res://online/session/arena_slice.gd")
const ModeSliceScript = preload("res://online/session/mode_slice.gd")
const PendingMutationQueueScript = preload("res://online/session/pending_mutation_queue.gd")
const SessionStateFacadeScript = preload("res://online/session/session_state_facade.gd")
const SurfaceRefreshSliceScript = preload("res://online/session/surface_refresh_slice.gd")
const TelemetrySliceScript = preload("res://online/session/telemetry_slice.gd")

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
const SURFACE_ARENA := "arena"
const SURFACE_CRAFTING := "crafting"
const SURFACE_BUILD := "build"
const SURFACE_MODE := "mode"
const SURFACE_REFRESH_SOURCE_CACHE := "cache"
const SURFACE_REFRESH_SOURCE_SERVER := "server"
const REQUEST_LATENCY_LOG_LIMIT := 40
const GAMEPLAY_SURFACES := [
	SURFACE_BASE,
	SURFACE_SOCIAL,
	SURFACE_COMPETITION,
	SURFACE_MONETIZATION,
	SURFACE_CRAFTING,
	SURFACE_BUILD,
	SURFACE_BATTLE,
	SURFACE_ARENA,
	SURFACE_MODE,
]
const SNAPSHOT_SURFACES := [
	SURFACE_ACCOUNT,
	SURFACE_BASE,
	SURFACE_SOCIAL,
	SURFACE_COMPETITION,
	SURFACE_MONETIZATION,
	SURFACE_CRAFTING,
	SURFACE_BUILD,
	SURFACE_BATTLE,
	SURFACE_ARENA,
	SURFACE_MODE,
]

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
var mode_state: Dictionary = {}
var progression_lab: Dictionary = {}
var arena_state: Dictionary = {}
var last_battle_id: Variant = null
var last_battle_log: Dictionary = {}
var last_battle_rewards: Dictionary = {}
var last_battle_result_seen := false
var last_error: Dictionary = {}
var runtime_config: Dictionary = {}
var surface_save_types: Dictionary = {}
var surface_refresh_meta: Dictionary = {}
var request_latency_log: Array = []
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
	SessionStateFacadeScript.clear_session(self, create_request_id(), SAVE_TYPE_NORMAL, CACHE_PATH)
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

func apply_arena_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_ARENA, payload, active_save_type):
		return false
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "ARENA_NOT_OK",
			"message": "Servidor recusou a Arena PVE.",
		}))
		session_changed.emit()
		return false

	var state := ArenaSliceScript.state_from_body(body, arena_state)
	if state.is_empty():
		last_error = {
			"code": "ARENA_STATE_MISSING",
			"message": "Servidor nao retornou arena_state.",
		}
		session_changed.emit()
		return false
	if str(state.get("schema_version", "")) != "pve_arena_state_v1":
		last_error = {
			"code": "UNSUPPORTED_ARENA_STATE",
			"message": "Versao de arena_state nao suportada.",
		}
		session_changed.emit()
		return false

	if body.get("player", null) is Dictionary:
		var player_patch := _as_dictionary(body.get("player", {}))
		for key_variant: Variant in player_patch.keys():
			player[str(key_variant)] = player_patch.get(key_variant)
		if not player.has("save_type"):
			player["save_type"] = active_save_type
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	if body.get("resources", null) is Dictionary:
		resources = _as_dictionary(body.get("resources", {})).duplicate(true)
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	if body.get("build", null) is Dictionary:
		build = _as_dictionary(body.get("build", {})).duplicate(true)
		_remember_surface_snapshot(SURFACE_ACCOUNT)

	if bool(body.get("dev_fixture", false)):
		state["dev_fixture"] = true
	elif not state.has("dev_fixture"):
		state["dev_fixture"] = false
	arena_state = state.duplicate(true)
	_remember_surface_snapshot(SURFACE_ARENA)
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
	if body.get("base", null) is Dictionary:
		base_state = _as_dictionary(body.get("base", {})).duplicate(true)
		_remember_surface_snapshot(SURFACE_BASE)
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

func apply_mode_result(payload: Dictionary) -> bool:
	var body := _unwrap_body(payload)
	if not _accept_save_scoped_payload(SURFACE_MODE, payload, active_save_type):
		return false
	if not bool(body.get("ok", false)):
		last_error = _as_dictionary(body.get("error", {
			"code": "MODE_NOT_OK",
			"message": "Servidor recusou o mode.",
		}))
		session_changed.emit()
		return false

	var incoming_state := ModeSliceScript.state_from_body(body, mode_state)
	if incoming_state.is_empty():
		last_error = {
			"code": "MODE_STATE_INCOMPLETE",
			"message": "Estado de mode incompleto.",
		}
		session_changed.emit()
		return false

	if body.get("resources", null) is Dictionary:
		_patch_resources(_as_dictionary(body.get("resources", {})))
		_remember_surface_snapshot(SURFACE_ACCOUNT)
	if body.get("player", null) is Dictionary:
		var player_patch := _as_dictionary(body.get("player", {}))
		for key_variant: Variant in player_patch.keys():
			player[str(key_variant)] = player_patch.get(key_variant)
		if not player.has("save_type"):
			player["save_type"] = active_save_type
		_remember_surface_snapshot(SURFACE_ACCOUNT)

	var request_id := ModeSliceScript.request_id_from_body(body)
	if request_id != "":
		complete_pending_mutation(request_id, body)
	mode_state = incoming_state.duplicate(true)
	_remember_surface_snapshot(SURFACE_MODE)
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
	return AccountSaveSliceScript.has_account_state(player, resources, build, surface_save_types, active_save_type)

func has_battle_log() -> bool:
	return not last_battle_log.is_empty() and _surface_matches_active_save(SURFACE_BATTLE)

func has_arena_state() -> bool:
	return not arena_state.is_empty() and _surface_matches_active_save(SURFACE_ARENA)

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

func has_mode_state() -> bool:
	return not mode_state.is_empty() and _surface_matches_active_save(SURFACE_MODE)

func has_surface_snapshot(surface: String) -> bool:
	return SessionStateFacadeScript.has_surface_snapshot(self, surface)

func begin_surface_refresh(surface: String, action_id: String = "", endpoint: String = "", rendered_from_cache: bool = false) -> Dictionary:
	var token := SurfaceRefreshSliceScript.begin(surface_refresh_meta, surface, active_save_type, SURFACE_REFRESH_SOURCE_CACHE, action_id, endpoint, rendered_from_cache)
	session_changed.emit()
	return token

func complete_surface_refresh(surface: String, result: Dictionary = {}, token: Dictionary = {}) -> bool:
	if not SurfaceRefreshSliceScript.complete(surface_refresh_meta, request_latency_log, surface, active_save_type, result, token, SURFACE_REFRESH_SOURCE_SERVER, REQUEST_LATENCY_LOG_LIMIT):
		return false
	session_changed.emit()
	return true

func fail_surface_refresh(surface: String, result: Dictionary = {}, token: Dictionary = {}) -> bool:
	if not SurfaceRefreshSliceScript.fail(surface_refresh_meta, request_latency_log, surface, active_save_type, result, token, has_surface_snapshot(surface), SURFACE_REFRESH_SOURCE_CACHE, REQUEST_LATENCY_LOG_LIMIT):
		return false
	session_changed.emit()
	return true

func surface_refresh_snapshot(surface: String) -> Dictionary:
	return SurfaceRefreshSliceScript.snapshot(surface_refresh_meta, surface, active_save_type, has_surface_snapshot(surface))

func record_request_latency(payload: Dictionary) -> void:
	SurfaceRefreshSliceScript.record_latency(request_latency_log, payload, REQUEST_LATENCY_LOG_LIMIT)

func recent_request_latencies() -> Array:
	return request_latency_log.duplicate(true)

func is_progression_lab_local_only() -> bool:
	return AccountSaveSliceScript.is_progression_lab_local_only(progression_lab)

func is_progression_lab_active() -> bool:
	return active_save_type == SAVE_TYPE_PROGRESSION_LAB

func is_registered_session() -> bool:
	return auth_method == "email"

func runtime_feature_enabled(feature_id: String) -> bool:
	return RuntimeConfigScript.feature_enabled(runtime_config, feature_id)

func runtime_config_is_fallback() -> bool:
	return RuntimeConfigScript.is_fallback(runtime_config)

func account_slice() -> Dictionary:
	return AccountSaveSliceScript.account_slice(auth_user_id, auth_method, auth_email, account_username, player)

func save_slice() -> Dictionary:
	return AccountSaveSliceScript.save_slice(active_save_type, surface_save_types, progression_lab)

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

func arena_snapshot() -> Dictionary:
	return arena_state.duplicate(true)

func has_remote_arena_state() -> bool:
	return has_arena_state() and not bool(arena_state.get("dev_fixture", false))

func arena_by_id(arena_id: String) -> Dictionary:
	return ArenaSliceScript.arena_by_id(arena_state, arena_id)

func arena_difficulty_by_id(arena_id: String, difficulty_id: String = "") -> Dictionary:
	return ArenaSliceScript.arena_difficulty_by_id(arena_state, arena_id, difficulty_id)

func active_arena_attempt() -> Dictionary:
	return ArenaSliceScript.active_attempt(arena_state)

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

func mode_snapshot() -> Dictionary:
	return mode_state.duplicate(true)

func diagnostics_snapshot() -> Dictionary:
	return SessionStateFacadeScript.diagnostics_snapshot(self, CACHE_VERSION, SNAPSHOT_SURFACES)

func active_save_label() -> String:
	return AccountSaveSliceScript.active_save_label(active_save_type)

func active_save_badge() -> String:
	return AccountSaveSliceScript.active_save_badge(active_save_type)

func set_active_save_type(save_type: String) -> bool:
	var normalized := normalize_save_type(save_type)
	if normalized == active_save_type:
		return false
	active_save_type = normalized
	_clear_account_snapshots()
	pending_mutations = PendingMutationQueueScript.prune_pending_outside_save(pending_mutations, active_save_type)
	last_error = {}
	offline = false
	save_cache()
	session_changed.emit()
	return true

static func normalize_save_type(save_type: String) -> String:
	return AccountSaveSliceScript.normalize_save_type(save_type)

func progression_lab_label() -> String:
	return AccountSaveSliceScript.progression_lab_label(progression_lab)

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
	return SessionStateFacadeScript.snapshot(self, CACHE_VERSION)

static func create_request_id() -> String:
	return TelemetrySliceScript.create_request_id()

func prepare_pending_mutation(endpoint: String, scope_id: String, action_id: String, payload: Dictionary = {}) -> Dictionary:
	var prepared := PendingMutationQueueScript.prepare(pending_mutations, endpoint, scope_id, action_id, payload)
	pending_mutations = _as_dictionary(prepared.get("queue", pending_mutations))
	session_changed.emit()
	return _as_dictionary(prepared.get("mutation", {}))

func complete_pending_mutation(request_id: String, response_payload: Dictionary = {}) -> bool:
	return _mark_pending_mutation(request_id, MUTATION_STATUS_COMPLETED, response_payload)

func fail_pending_mutation(request_id: String, error_payload: Dictionary = {}) -> bool:
	return _mark_pending_mutation(request_id, MUTATION_STATUS_FAILED, error_payload)

func clear_pending_mutation(request_id: String) -> bool:
	var result := PendingMutationQueueScript.clear(pending_mutations, request_id)
	pending_mutations = _as_dictionary(result.get("queue", pending_mutations))
	if bool(result.get("changed", false)):
		session_changed.emit()
	return bool(result.get("changed", false))

func pending_mutation(request_id: String) -> Dictionary:
	return PendingMutationQueueScript.get_record(pending_mutations, request_id)

static func request_hash_for_mutation(endpoint: String, payload: Dictionary) -> String:
	return PendingMutationQueueScript.request_hash_for_mutation(endpoint, payload)

static func sha256_text(prefix: String, value: String) -> String:
	return PendingMutationQueueScript.sha256_text(prefix, value)

static func canonical_json(value: Variant) -> String:
	return PendingMutationQueueScript.canonical_json(value)

func _apply_cache(cache: Dictionary) -> void:
	SessionStateFacadeScript.apply_cache(self, cache, SAVE_TYPE_NORMAL, SAVE_TYPE_PROGRESSION_LAB, SNAPSHOT_SURFACES)

func _clear_account_snapshots() -> void:
	SessionStateFacadeScript.clear_account_snapshots(self, SAVE_TYPE_NORMAL)

func _mark_pending_mutation(request_id: String, status: String, payload: Dictionary = {}) -> bool:
	var result := PendingMutationQueueScript.mark(pending_mutations, request_id, status, payload)
	pending_mutations = _as_dictionary(result.get("queue", pending_mutations))
	if bool(result.get("changed", false)):
		session_changed.emit()
	return bool(result.get("changed", false))

func _clear_gameplay_snapshots() -> void:
	SessionStateFacadeScript.clear_gameplay_snapshots(self, GAMEPLAY_SURFACES)

func _patch_resources(resource_patch: Dictionary) -> void:
	for key_variant: Variant in resource_patch.keys():
		var key := str(key_variant)
		if key == "xp":
			player["xp"] = resource_patch.get(key_variant)
		else:
			resources[key] = resource_patch.get(key_variant)

func ensure_alpha_account_request_id() -> String:
	if alpha_account_request_id == "":
		alpha_account_request_id = create_request_id()
		save_cache()
	return alpha_account_request_id

static func base_account_username(username: String) -> String:
	return AccountSaveSliceScript.base_account_username(username)

func _unwrap_body(payload: Dictionary) -> Dictionary:
	return AccountSaveSliceScript.unwrap_body(payload)

func _payload_save_type(payload: Dictionary, fallback_save_type: String) -> String:
	return AccountSaveSliceScript.payload_save_type(payload, fallback_save_type)

func _accept_save_scoped_payload(surface: String, payload: Dictionary, fallback_save_type: String) -> bool:
	var result := AccountSaveSliceScript.accept_save_scoped_payload(surface, payload, fallback_save_type, active_save_type)
	if bool(result.get("ok", false)):
		return true
	last_error = _as_dictionary(result.get("error", {}))
	session_changed.emit()
	return false

func _remember_surface_snapshot(surface: String, save_type: String = active_save_type) -> void:
	SessionStateFacadeScript.remember_surface_snapshot(self, surface, save_type, active_save_type, SURFACE_REFRESH_SOURCE_SERVER)

func _surface_matches_active_save(surface: String) -> bool:
	return AccountSaveSliceScript.surface_matches_active_save(surface_save_types, surface, active_save_type)

func _backfill_surface_save_types() -> void:
	SessionStateFacadeScript.backfill_surface_save_types(self, SNAPSHOT_SURFACES)

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
