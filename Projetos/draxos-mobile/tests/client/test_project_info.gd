extends GutTest

func test_project_info_constants_are_set() -> void:
	assert_eq(ProjectInfo.PROJECT_NAME, "DraxosMobile")
	assert_eq(ProjectInfo.GODOT_VERSION, "4.6.2-stable")
	assert_eq(ProjectInfo.GUT_VERSION, "9.6.0")
	assert_eq(ProjectInfo.ACTIVE_TRACK, "Track 00 - First Slice Foundation")

func test_boot_actions_match_mvp_scope() -> void:
	var actions := ProjectInfo.boot_actions()
	assert_eq(actions.size(), 3)
	assert_has(actions, "Entrar como guest")
	assert_has(actions, "Solicitar batalha")
	assert_has(actions, "Ver resultado")
