extends "res://addons/gut/test.gd"

const ArenaSessionManager = preload("res://modes/arena/arena_session_manager.gd")

func test_session_manager_runs_prematch_and_postmatch_windows() -> void:
	var manager: ArenaSessionManager = add_child_autofree(ArenaSessionManager.new())

	manager.start_session()
	assert_eq(int(manager.state), int(ArenaSessionManager.SessionState.PRE_MATCH))
	assert_true(manager.get_state_remaining_seconds() > 0.0)
	assert_true(await wait_for_signal(manager.session_started, 2.0))
	assert_eq(int(manager.state), int(ArenaSessionManager.SessionState.IN_PROGRESS))

	manager.end_session({"player_victory": true})
	assert_eq(int(manager.state), int(ArenaSessionManager.SessionState.POST_MATCH))
	assert_true(manager.get_state_remaining_seconds() > 0.0)
	assert_true(await wait_for_signal(manager.session_ended, 2.0))
	assert_eq(int(manager.state), int(ArenaSessionManager.SessionState.SESSION_END))
