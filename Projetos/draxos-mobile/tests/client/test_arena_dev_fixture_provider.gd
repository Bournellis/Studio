extends GutTest

const ArenaDevFixtureProviderScript := preload("res://modes/boot/flows/arena_dev_fixture_provider.gd")
const SessionStoreScript := preload("res://online/session_store.gd")

const DEV_TOOLS_SETTING := "draxos_mobile/internal_alpha/dev_tools_enabled"
const ARENA_FIXTURES_SETTING := "draxos_mobile/internal_alpha/arena_dev_fixtures_enabled"

var _original_dev_tools: Variant
var _original_arena_fixtures: Variant

func before_each() -> void:
	_original_dev_tools = ProjectSettings.get_setting(DEV_TOOLS_SETTING, false)
	_original_arena_fixtures = ProjectSettings.get_setting(ARENA_FIXTURES_SETTING, false)

func after_each() -> void:
	ProjectSettings.set_setting(DEV_TOOLS_SETTING, _original_dev_tools)
	ProjectSettings.set_setting(ARENA_FIXTURES_SETTING, _original_arena_fixtures)

func test_internal_dev_tools_do_not_enable_arena_remote_failure_fixture() -> void:
	ProjectSettings.set_setting(DEV_TOOLS_SETTING, true)
	ProjectSettings.set_setting(ARENA_FIXTURES_SETTING, false)
	var remote_failure := {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var result := ArenaDevFixtureProviderScript.state_fallback_result_for_runtime(
		remote_failure,
		SessionStoreScript.SAVE_TYPE_NORMAL,
		false
	)

	assert_false(bool(result.get("ok", false)))
	assert_eq(Dictionary(result.get("error", {})).get("code"), "NETWORK_UNAVAILABLE")

func test_arena_fixture_setting_keeps_local_fixture_available() -> void:
	ProjectSettings.set_setting(DEV_TOOLS_SETTING, false)
	ProjectSettings.set_setting(ARENA_FIXTURES_SETTING, true)
	var remote_failure := {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var result := ArenaDevFixtureProviderScript.state_fallback_result(remote_failure, SessionStoreScript.SAVE_TYPE_NORMAL)

	assert_true(bool(result.get("ok", false)))
	assert_true(bool(Dictionary(result.get("body", {})).get("dev_fixture", false)))
	assert_eq(Dictionary(result.get("_client", {})).get("save_type"), SessionStoreScript.SAVE_TYPE_NORMAL)

func test_arena_fixture_abandon_returns_terminal_attempt_without_rewards() -> void:
	ProjectSettings.set_setting(DEV_TOOLS_SETTING, false)
	ProjectSettings.set_setting(ARENA_FIXTURES_SETTING, true)
	var store := SessionStoreScript.new()
	var remote_failure := {"ok": false, "error": {"code": "NETWORK_UNAVAILABLE"}}
	var attempt := {
		"attempt_id": "dev-stuck",
		"arena_id": "arena_cinzas_curta",
		"state": "active",
		"current_step_index": 3,
		"duel_count": 3,
		"duels_won": 3,
		"buff_offer": {},
	}

	var result := ArenaDevFixtureProviderScript.abandon_attempt_fallback_result(remote_failure, attempt, store)
	var body := Dictionary(result.get("body", {}))
	var arena_state := Dictionary(body.get("arena_state", {}))
	var active_attempt := Dictionary(arena_state.get("active_attempt", {}))
	var summary := Dictionary(active_attempt.get("summary", {}))

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(active_attempt.get("state", "")), "abandoned")
	assert_eq(str(active_attempt.get("status", "")), "abandoned")
	assert_false(bool(summary.get("reward_already_applied", true)))
	assert_false(bool(summary.get("mutates_economy", true)))
	store.free()
