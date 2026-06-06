extends RefCounted

const AccountSaveSliceScript = preload("res://online/session/account_save_slice.gd")
const PendingMutationQueueScript = preload("res://online/session/pending_mutation_queue.gd")
const SessionCacheSliceScript = preload("res://online/session/session_cache_slice.gd")
const SurfaceRefreshSliceScript = preload("res://online/session/surface_refresh_slice.gd")
const TelemetrySliceScript = preload("res://online/session/telemetry_slice.gd")

static func clear_session(store: Object, session_id: String, save_type_normal: String, cache_path: String) -> void:
	store.set("access_token", "")
	store.set("refresh_token", "")
	store.set("expires_at", 0)
	store.set("auth_user_id", "")
	store.set("auth_method", "guest")
	store.set("auth_email", "")
	store.set("session_id", session_id)
	store.set("guest_request_id", "")
	store.set("alpha_account_request_id", "")
	store.set("account_username", "")
	store.set("active_save_type", save_type_normal)
	store.set("player", {})
	store.set("resources", {})
	store.set("build", {})
	store.set("base_state", {})
	store.set("social_state", {})
	store.set("competition_state", {})
	store.set("monetization_state", {})
	store.set("crafting_state", {})
	store.set("combat_build_state", {})
	store.set("mode_state", {})
	store.set("openworld_local_state", {})
	store.set("progression_lab", {})
	store.set("arena_state", {})
	store.set("last_battle_id", null)
	store.set("last_battle_log", {})
	store.set("last_battle_rewards", {})
	store.set("last_battle_result_seen", false)
	store.set("last_error", {})
	store.set("surface_save_types", {})
	store.set("surface_refresh_meta", {})
	store.set("request_latency_log", [])
	store.set("pending_mutations", {})
	store.set("offline", false)
	if FileAccess.file_exists(cache_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(cache_path))

static func snapshot(store: Object, cache_version: int) -> Dictionary:
	return SessionCacheSliceScript.snapshot({
		"cache_version": cache_version,
		"access_token": str(store.get("access_token")),
		"refresh_token": str(store.get("refresh_token")),
		"expires_at": int(store.get("expires_at")),
		"auth_user_id": str(store.get("auth_user_id")),
		"auth_method": str(store.get("auth_method")),
		"auth_email": str(store.get("auth_email")),
		"session_id": str(store.call("ensure_session_id")),
		"guest_request_id": str(store.get("guest_request_id")),
		"alpha_account_request_id": str(store.get("alpha_account_request_id")),
		"account_username": str(store.get("account_username")),
		"active_save_type": str(store.get("active_save_type")),
		"player": _dict(store.get("player")),
		"resources": _dict(store.get("resources")),
		"build": _dict(store.get("build")),
		"base_state": _dict(store.get("base_state")),
		"social_state": _dict(store.get("social_state")),
		"competition_state": _dict(store.get("competition_state")),
		"monetization_state": _dict(store.get("monetization_state")),
		"crafting_state": _dict(store.get("crafting_state")),
		"combat_build_state": _dict(store.get("combat_build_state")),
		"mode_state": _dict(store.get("mode_state")),
		"openworld_local_state": _dict(store.get("openworld_local_state")),
		"progression_lab": _dict(store.get("progression_lab")),
		"arena_state": _dict(store.get("arena_state")),
		"surface_save_types": _dict(store.get("surface_save_types")),
		"surface_refresh_meta": _dict(store.get("surface_refresh_meta")),
		"request_latency_log": _array(store.get("request_latency_log")),
		"pending_mutations": _dict(store.get("pending_mutations")),
		"last_battle_id": store.get("last_battle_id"),
		"last_battle_log": _dict(store.get("last_battle_log")),
		"last_battle_rewards": _dict(store.get("last_battle_rewards")),
		"last_battle_result_seen": bool(store.get("last_battle_result_seen")),
		"offline": bool(store.get("offline")),
		"last_error": _dict(store.get("last_error")),
	})

static func apply_cache(
	store: Object,
	cache: Dictionary,
	save_type_normal: String,
	save_type_progression_lab: String,
	surfaces: Array
) -> void:
	var auth := SessionCacheSliceScript.cache_auth(cache)
	store.set("access_token", str(auth.get("access_token", "")))
	store.set("refresh_token", str(auth.get("refresh_token", "")))
	store.set("expires_at", int(auth.get("expires_at", 0)))
	store.set("auth_user_id", str(auth.get("user_id", "")))
	var auth_method := str(auth.get("auth_method", "guest")).strip_edges().to_lower()
	store.set("auth_method", "guest" if auth_method == "" else auth_method)
	store.set("auth_email", str(auth.get("email", "")))
	store.set("session_id", SessionCacheSliceScript.cache_string(cache, "session_id"))
	store.set("guest_request_id", SessionCacheSliceScript.cache_string(cache, "guest_request_id"))
	store.set("alpha_account_request_id", SessionCacheSliceScript.cache_string(cache, "alpha_account_request_id"))
	store.set("account_username", SessionCacheSliceScript.cache_string(cache, "account_username"))
	store.set(
		"active_save_type",
		AccountSaveSliceScript.normalize_save_type(SessionCacheSliceScript.cache_string(cache, "active_save_type", save_type_normal))
	)
	store.set("player", SessionCacheSliceScript.cache_dict(cache, "player"))
	store.set("resources", SessionCacheSliceScript.cache_dict(cache, "resources"))
	store.set("build", SessionCacheSliceScript.cache_dict(cache, "build"))
	store.set("base_state", SessionCacheSliceScript.cache_dict(cache, "base_state"))
	store.set("social_state", SessionCacheSliceScript.cache_dict(cache, "social_state"))
	store.set("competition_state", SessionCacheSliceScript.cache_dict(cache, "competition_state"))
	store.set("monetization_state", SessionCacheSliceScript.cache_dict(cache, "monetization_state"))
	store.set("crafting_state", SessionCacheSliceScript.cache_dict(cache, "crafting_state"))
	store.set("combat_build_state", SessionCacheSliceScript.cache_dict(cache, "combat_build_state"))
	store.set("mode_state", SessionCacheSliceScript.cache_dict(cache, "mode_state"))
	store.set("openworld_local_state", SessionCacheSliceScript.cache_dict(cache, "openworld_local_state"))
	store.set("progression_lab", SessionCacheSliceScript.cache_dict(cache, "progression_lab"))
	store.set("arena_state", SessionCacheSliceScript.cache_dict(cache, "arena_state"))
	store.set("surface_save_types", AccountSaveSliceScript.normalized_surface_save_types(SessionCacheSliceScript.cache_dict(cache, "surface_save_types")))
	store.set("surface_refresh_meta", SurfaceRefreshSliceScript.normalized_meta(SessionCacheSliceScript.cache_dict(cache, "surface_refresh_meta")))
	store.set("request_latency_log", SessionCacheSliceScript.cache_array(cache, "request_latency_log"))
	store.set("pending_mutations", PendingMutationQueueScript.normalize(SessionCacheSliceScript.cache_dict(cache, "pending_mutations")))
	store.set("last_battle_id", cache.get("last_battle_id", null))
	store.set("last_battle_log", SessionCacheSliceScript.cache_dict(cache, "last_battle_log"))
	store.set("last_battle_rewards", SessionCacheSliceScript.cache_dict(cache, "last_battle_rewards"))
	store.set("last_battle_result_seen", SessionCacheSliceScript.cache_bool(cache, "last_battle_result_seen"))
	store.set("offline", SessionCacheSliceScript.cache_bool(cache, "offline"))
	store.set("last_error", SessionCacheSliceScript.cache_dict(cache, "last_error"))
	var progression_lab := _dict(store.get("progression_lab"))
	if not progression_lab.is_empty() and not bool(progression_lab.get("local_only", false)):
		store.set("active_save_type", save_type_progression_lab)
	if bool(progression_lab.get("local_only", false)):
		store.set("active_save_type", save_type_progression_lab)
		store.set("access_token", "")
		store.set("refresh_token", "")
		store.set("expires_at", 0)
		store.set("auth_user_id", "")
		store.set("auth_method", "guest")
		store.set("auth_email", "")
	if str(store.get("active_save_type")) == save_type_normal:
		store.set("progression_lab", {})
	backfill_surface_save_types(store, surfaces)

static func clear_account_snapshots(store: Object, save_type_normal: String) -> void:
	store.set("player", {})
	store.set("resources", {})
	store.set("build", {})
	store.set("base_state", {})
	store.set("social_state", {})
	store.set("competition_state", {})
	store.set("monetization_state", {})
	store.set("crafting_state", {})
	store.set("combat_build_state", {})
	store.set("arena_state", {})
	store.set("mode_state", {})
	store.set("openworld_local_state", {})
	if str(store.get("active_save_type")) == save_type_normal:
		store.set("progression_lab", {})
	store.set("last_battle_id", null)
	store.set("last_battle_log", {})
	store.set("last_battle_rewards", {})
	store.set("last_battle_result_seen", false)
	store.set("surface_save_types", {})
	store.set("surface_refresh_meta", {})

static func clear_gameplay_snapshots(store: Object, surfaces: Array) -> void:
	store.set("base_state", {})
	store.set("social_state", {})
	store.set("competition_state", {})
	store.set("monetization_state", {})
	store.set("crafting_state", {})
	store.set("combat_build_state", {})
	store.set("arena_state", {})
	store.set("mode_state", {})
	store.set("openworld_local_state", {})
	store.set("last_battle_id", null)
	store.set("last_battle_log", {})
	store.set("last_battle_rewards", {})
	store.set("last_battle_result_seen", false)
	var surface_save_types := _dict(store.get("surface_save_types"))
	var surface_refresh_meta := _dict(store.get("surface_refresh_meta"))
	for surface: String in surfaces:
		if surface == "account":
			continue
		surface_save_types.erase(surface)
		surface_refresh_meta.erase(surface)
	store.set("surface_save_types", surface_save_types)
	store.set("surface_refresh_meta", surface_refresh_meta)

static func has_surface_snapshot(store: Object, surface: String) -> bool:
	var states := {
		"account": bool(store.call("has_account_state")),
		"base": bool(store.call("has_base_state")),
		"social": bool(store.call("has_social_state")),
		"competition": bool(store.call("has_competition_state")),
		"monetization": bool(store.call("has_monetization_state")),
		"crafting": bool(store.call("has_crafting_state")),
		"build": bool(store.call("has_build_state")),
		"battle": bool(store.call("has_battle_log")),
		"arena": bool(store.call("has_arena_state")),
		"mode": bool(store.call("has_mode_state")),
	}
	return bool(states.get(surface.strip_edges(), false))

static func remember_surface_snapshot(
	store: Object,
	surface: String,
	save_type: String,
	active_save_type: String,
	server_source: String
) -> void:
	var normalized_save_type := AccountSaveSliceScript.normalize_save_type(save_type)
	var surface_save_types := _dict(store.get("surface_save_types"))
	var surface_refresh_meta := _dict(store.get("surface_refresh_meta"))
	surface_save_types[surface] = normalized_save_type
	var meta := SurfaceRefreshSliceScript.surface_meta(surface_refresh_meta, surface, active_save_type)
	meta["surface"] = surface
	meta["save_type"] = normalized_save_type
	if str(meta.get("source", "")).strip_edges() == "":
		meta["source"] = server_source
	surface_refresh_meta[surface] = meta
	store.set("surface_save_types", surface_save_types)
	store.set("surface_refresh_meta", surface_refresh_meta)

static func backfill_surface_save_types(store: Object, surfaces: Array) -> void:
	for surface: String in surfaces:
		if bool(store.call("has_surface_snapshot", surface)) and not _dict(store.get("surface_save_types")).has(surface):
			store.call("_remember_surface_snapshot", surface)

static func diagnostics_snapshot(store: Object, cache_version: int, surfaces: Array) -> Dictionary:
	return TelemetrySliceScript.diagnostics_snapshot({
		"cache_version": cache_version,
		"session_id": str(store.call("ensure_session_id")),
		"has_access_token": str(store.get("access_token")) != "",
		"has_refresh_token": str(store.get("refresh_token")) != "",
		"expires_at": int(store.get("expires_at")),
		"has_auth_user_id": str(store.get("auth_user_id")) != "",
		"auth_method": str(store.get("auth_method")),
		"registered": bool(store.call("is_registered_session")),
		"save": {
			"active_save_type": str(store.get("active_save_type")),
			"label": str(store.call("active_save_label")),
			"badge": str(store.call("active_save_badge")),
		},
		"surfaces": diagnostics_surfaces(store, surfaces),
		"progression_lab": {
			"active": bool(store.call("is_progression_lab_active")),
			"local_only": bool(store.call("is_progression_lab_local_only")),
			"has_metadata": not _dict(store.get("progression_lab")).is_empty(),
			"label": str(store.call("progression_lab_label")),
		},
		"runtime_config": _dict(store.get("runtime_config")),
		"pending_mutations": PendingMutationQueueScript.counts_by_save(_dict(store.get("pending_mutations"))),
		"request_latency_log": _array(store.call("recent_request_latencies")),
		"offline": bool(store.get("offline")),
		"last_error": _dict(store.get("last_error")),
	})

static func diagnostics_surfaces(store: Object, surfaces: Array) -> Dictionary:
	var result := {}
	for surface: String in surfaces:
		var diagnostics := AccountSaveSliceScript.diagnostics_surface(
			surface,
			bool(store.call("has_surface_snapshot", surface)),
			_dict(store.get("surface_save_types")),
			str(store.get("active_save_type"))
		)
		diagnostics["refresh"] = store.call("surface_refresh_snapshot", surface)
		result[surface] = diagnostics
	return result

static func _dict(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
