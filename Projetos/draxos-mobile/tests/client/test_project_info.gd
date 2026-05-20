extends GutTest

func test_project_info_constants_are_set() -> void:
	assert_eq(ProjectInfo.PROJECT_NAME, "DraxosMobile")
	assert_eq(ProjectInfo.GODOT_VERSION, "4.6.2-stable")
	assert_eq(ProjectInfo.GUT_VERSION, "9.6.0")
	assert_eq(ProjectInfo.ACTIVE_TRACK, "Track 00 - First Slice Foundation")
	assert_eq(ProjectInfo.MVP_MODE, "MVP_ONLY")
	assert_eq(ProjectInfo.FIRST_SLICE_MODE, "FIRST_SLICE_SIM")
	assert_eq(ProjectInfo.DEFAULT_BATTLE_MODE, ProjectInfo.FIRST_SLICE_MODE)

func test_boot_actions_match_mvp_scope() -> void:
	var actions := ProjectInfo.boot_actions()
	assert_eq(actions.size(), 15)
	assert_has(actions, "Entrar como guest")
	assert_has(actions, "Solicitar batalha")
	assert_has(actions, "Ver resultado")
	assert_has(actions, "Ver base")
	assert_has(actions, "Coletar base")
	assert_has(actions, "Evoluir Nucleo")
	assert_has(actions, "Ver social")
	assert_has(actions, "Criar guilda")
	assert_has(actions, "Chat guilda")
	assert_has(actions, "Preview matchmaking")
	assert_has(actions, "Ver ranking")
	assert_has(actions, "Ver loja")
	assert_has(actions, "Comprar premium alpha")
	assert_has(actions, "Receber Diamante")
	assert_has(actions, "Claim diario")
