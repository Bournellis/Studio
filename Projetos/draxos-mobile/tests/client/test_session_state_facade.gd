extends GutTest

const SessionStoreScript := preload("res://online/session_store.gd")
const SessionStateFacadeScript := preload("res://online/session/session_state_facade.gd")

func test_clear_session_resets_auth_gameplay_and_cache_file() -> void:
	var store = SessionStoreScript.new()
	var cache_path := "user://session_state_facade_test_cache.json"
	var file := FileAccess.open(cache_path, FileAccess.WRITE)
	file.store_string("{}")
	file.close()
	store.access_token = "token"
	store.refresh_token = "refresh"
	store.resources = {"almas": 3}
	store.pending_mutations = {"request-1": {"status": "pending"}}
	store.offline = true

	SessionStateFacadeScript.clear_session(store, "session-direct", SessionStoreScript.SAVE_TYPE_NORMAL, cache_path)

	assert_eq(store.access_token, "")
	assert_eq(store.refresh_token, "")
	assert_eq(store.session_id, "session-direct")
	assert_eq(store.active_save_type, SessionStoreScript.SAVE_TYPE_NORMAL)
	assert_true(store.resources.is_empty())
	assert_true(store.pending_mutations.is_empty())
	assert_false(store.offline)
	assert_false(FileAccess.file_exists(cache_path))
	store.free()

func test_snapshot_returns_deep_copy() -> void:
	var store = SessionStoreScript.new()
	store.resources = {"almas": 1, "nested": {"value": 2}}
	store.base_state = {"structures": [{"structure_id": "nucleo_energia", "level": 1}]}

	var snapshot := SessionStateFacadeScript.snapshot(store, SessionStoreScript.CACHE_VERSION)
	Dictionary(snapshot["resources"])["almas"] = 999
	Dictionary(Dictionary(snapshot["resources"])["nested"])["value"] = 999
	Array(Dictionary(snapshot["base_state"])["structures"])[0]["level"] = 99

	assert_eq(int(store.resources.get("almas", 0)), 1)
	assert_eq(int(Dictionary(store.resources.get("nested", {})).get("value", 0)), 2)
	assert_eq(int(Dictionary(Array(store.base_state.get("structures", []))[0]).get("level", 0)), 1)
	store.free()

func test_apply_cache_restores_state_and_progression_lab_mode() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	SessionStateFacadeScript.apply_cache(
		store,
		{
			"cache_version": SessionStoreScript.CACHE_VERSION,
			"auth": {
				"access_token": "token",
				"refresh_token": "refresh",
				"expires_at": now + 600,
				"user_id": "auth-user",
				"auth_method": "email",
				"email": "alpha@example.com",
			},
			"session_id": "11111111-1111-4111-8111-111111111111",
			"active_save_type": SessionStoreScript.SAVE_TYPE_NORMAL,
			"player": {"id": "player-1", "username": "plab_user"},
			"resources": {"energia": 9},
			"base_state": {"structures": [{"structure_id": "nucleo_energia"}]},
			"progression_lab": {"save_id": "free_100_rewards_20h", "profile_id": "free_100_rewards", "milestone_id": "20h"},
			"surface_save_types": {"base": SessionStoreScript.SAVE_TYPE_NORMAL},
		},
		SessionStoreScript.SAVE_TYPE_NORMAL,
		SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB,
		SessionStoreScript.SNAPSHOT_SURFACES
	)

	assert_eq(store.access_token, "token")
	assert_eq(store.auth_email, "alpha@example.com")
	assert_eq(store.active_save_type, SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
	assert_eq(int(store.resources.get("energia", 0)), 9)
	assert_false(store.base_state.is_empty())
	assert_false(store.has_base_state())
	assert_eq(_as_dictionary(store.surface_save_types).get(SessionStoreScript.SURFACE_BASE), SessionStoreScript.SAVE_TYPE_NORMAL)
	store.free()

func test_clear_gameplay_snapshots_preserves_account_surface_only() -> void:
	var store = SessionStoreScript.new()
	store.player = {"id": "player-1"}
	store.base_state = {"structures": [{"structure_id": "nucleo_energia"}]}
	store.arena_state = {"arenas": [{"id": "arena_tutorial_cinzas"}]}
	store.last_battle_log = {"schema_version": "battle_log_v1"}
	store.surface_save_types = {
		SessionStoreScript.SURFACE_ACCOUNT: SessionStoreScript.SAVE_TYPE_NORMAL,
		SessionStoreScript.SURFACE_BASE: SessionStoreScript.SAVE_TYPE_NORMAL,
		SessionStoreScript.SURFACE_ARENA: SessionStoreScript.SAVE_TYPE_NORMAL,
	}
	store.surface_refresh_meta = {
		SessionStoreScript.SURFACE_ACCOUNT: {"source": "server"},
		SessionStoreScript.SURFACE_BASE: {"source": "server"},
	}

	SessionStateFacadeScript.clear_gameplay_snapshots(store, SessionStoreScript.GAMEPLAY_SURFACES)

	assert_false(store.player.is_empty())
	assert_true(store.base_state.is_empty())
	assert_true(store.arena_state.is_empty())
	assert_true(store.last_battle_log.is_empty())
	assert_true(_as_dictionary(store.surface_save_types).has(SessionStoreScript.SURFACE_ACCOUNT))
	assert_false(_as_dictionary(store.surface_save_types).has(SessionStoreScript.SURFACE_BASE))
	assert_false(_as_dictionary(store.surface_refresh_meta).has(SessionStoreScript.SURFACE_BASE))
	store.free()

func test_remember_surface_snapshot_writes_save_type_and_refresh_meta() -> void:
	var store = SessionStoreScript.new()
	store.active_save_type = SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB

	SessionStateFacadeScript.remember_surface_snapshot(
		store,
		SessionStoreScript.SURFACE_ARENA,
		SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB,
		store.active_save_type,
		SessionStoreScript.SURFACE_REFRESH_SOURCE_SERVER
	)

	assert_eq(_as_dictionary(store.surface_save_types).get(SessionStoreScript.SURFACE_ARENA), SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
	var meta: Dictionary = _as_dictionary(_as_dictionary(store.surface_refresh_meta).get(SessionStoreScript.SURFACE_ARENA, {}))
	assert_eq(str(meta.get("surface", "")), SessionStoreScript.SURFACE_ARENA)
	assert_eq(str(meta.get("source", "")), SessionStoreScript.SURFACE_REFRESH_SOURCE_SERVER)
	store.free()

func test_diagnostics_snapshot_uses_store_call_compatibility() -> void:
	var store = SessionStoreScript.new()
	store.session_id = "11111111-1111-4111-8111-111111111111"
	store.access_token = "token"
	store.auth_user_id = "auth-user"
	store.auth_method = "email"
	store.auth_email = "alpha@example.com"
	store.player = {"id": "player-1", "username": "alpha"}
	store.base_state = {"structures": [{"structure_id": "nucleo_energia"}]}
	store.progression_lab = {"save_id": "free_100_rewards_20h"}
	store.active_save_type = SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB
	store.pending_mutations = {
		"request-1": {
			"status": SessionStoreScript.MUTATION_STATUS_PENDING,
			"save_type": SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB,
		},
	}
	SessionStateFacadeScript.remember_surface_snapshot(
		store,
		SessionStoreScript.SURFACE_BASE,
		SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB,
		store.active_save_type,
		SessionStoreScript.SURFACE_REFRESH_SOURCE_SERVER
	)

	var diagnostics := SessionStateFacadeScript.diagnostics_snapshot(
		store,
		SessionStoreScript.CACHE_VERSION,
		SessionStoreScript.SNAPSHOT_SURFACES
	)

	assert_eq(int(diagnostics.get("cache_version", 0)), SessionStoreScript.CACHE_VERSION)
	assert_true(bool(_as_dictionary(diagnostics.get("auth", {})).get("has_access_token", false)))
	assert_eq(_as_dictionary(diagnostics.get("save", {})).get("active_save_type"), SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
	assert_true(bool(_as_dictionary(_as_dictionary(diagnostics.get("surfaces", {})).get(SessionStoreScript.SURFACE_BASE, {})).get("has_snapshot", false)))
	assert_eq(int(_as_dictionary(diagnostics.get("pending_mutations", {})).get(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB, 0)), 1)
	store.free()

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
