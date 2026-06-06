extends GutTest

func test_project_info_constants_are_set() -> void:
	assert_eq(ProjectInfo.PROJECT_NAME, "DraxosMobile")
	assert_eq(ProjectInfo.GODOT_VERSION, "4.6.2-stable")
	assert_eq(ProjectInfo.GUT_VERSION, "9.6.0")
	assert_eq(ProjectInfo.ACTIVE_TRACK, "Track 03 - Internal Alpha v0")
	assert_eq(ProjectInfo.RELEASE_CHANNEL, "internal_alpha")
	assert_eq(ProjectInfo.APP_VERSION, "0.0.6-alpha.0")
	assert_eq(ProjectInfo.APP_VERSION_CODE, 6)
	assert_eq(ProjectInfo.MANIFEST_SCHEMA_VERSION, "internal_alpha_manifest_v1")
	assert_eq(ProjectInfo.MVP_MODE, "MVP_ONLY")
	assert_eq(ProjectInfo.FIRST_SLICE_MODE, "FIRST_SLICE_SIM")
	assert_eq(ProjectInfo.DEFAULT_BATTLE_MODE, ProjectInfo.FIRST_SLICE_MODE)

func test_boot_actions_match_mvp_scope() -> void:
	var actions := ProjectInfo.boot_actions()
	assert_eq(actions.size(), 23)
	assert_has(actions, "Criar conta")
	assert_has(actions, "Entrar com email")
	assert_has(actions, "Entrar como guest dev")
	assert_has(actions, "Sincronizar sessao")
	assert_has(actions, "Checar update")
	assert_has(actions, "Resetar sessao local")
	assert_has(actions, "Resetar save ativo")
	assert_has(actions, "Solicitar batalha")
	assert_has(actions, "Ver resultado")
	assert_has(actions, "Ver base")
	assert_has(actions, "Evoluir predio do Refugio")
	assert_has(actions, "Ver social")
	assert_has(actions, "Adicionar amigo")
	assert_has(actions, "Criar guilda")
	assert_has(actions, "Entrar guilda")
	assert_has(actions, "Enviar chat guilda")
	assert_has(actions, "Preview matchmaking")
	assert_has(actions, "Ver ranking")
	assert_has(actions, "Ver loja")
	assert_has(actions, "Comprar Energia na Loja")
	assert_has(actions, "Comprar premium")
	assert_has(actions, "Recompensa diaria")
	assert_false(actions.has("Coletar base"))
	assert_false(actions.has("Comprar Energia Refugio"))
	assert_false(actions.has("Receber Diamante"))

func test_version_compare_handles_alpha_style_strings() -> void:
	assert_eq(ProjectInfo.compare_versions("0.0.1-alpha.0", "0.0.1-alpha.0"), 0)
	assert_true(ProjectInfo.compare_versions("0.0.1-alpha.0", "0.0.2-alpha.0") < 0)
	assert_true(ProjectInfo.compare_versions("0.1.0-alpha.0", "0.0.9-alpha.9") > 0)

func test_update_manifest_current_recommended_and_required_status() -> void:
	var base_manifest := {
		"schema_version": ProjectInfo.MANIFEST_SCHEMA_VERSION,
		"channel": ProjectInfo.RELEASE_CHANNEL,
		"latest_version": ProjectInfo.APP_VERSION,
		"latest_version_code": ProjectInfo.APP_VERSION_CODE,
		"minimum_supported_version": ProjectInfo.APP_VERSION,
		"minimum_supported_version_code": ProjectInfo.APP_VERSION_CODE,
		"requires_save_reset": false,
		"notes": ["Teste de manifest."],
	}

	var current := ProjectInfo.update_status_from_manifest(base_manifest, "https://example/manifest")
	assert_eq(str(current.get("status", "")), "current")
	assert_false(bool(current.get("block_online", true)))
	assert_false(bool(current.get("update_available", true)))

	var recommended_manifest := base_manifest.duplicate(true)
	recommended_manifest["latest_version"] = "0.0.6-alpha.0"
	recommended_manifest["latest_version_code"] = ProjectInfo.APP_VERSION_CODE + 1
	var recommended := ProjectInfo.update_status_from_manifest(recommended_manifest)
	assert_eq(str(recommended.get("status", "")), "recommended")
	assert_false(bool(recommended.get("block_online", true)))
	assert_true(bool(recommended.get("update_available", false)))

	var required_manifest := base_manifest.duplicate(true)
	required_manifest["minimum_supported_version"] = "0.0.6-alpha.0"
	required_manifest["minimum_supported_version_code"] = ProjectInfo.APP_VERSION_CODE + 1
	var required := ProjectInfo.update_status_from_manifest(required_manifest)
	assert_eq(str(required.get("status", "")), "required")
	assert_true(bool(required.get("block_online", false)))
	assert_true(bool(required.get("update_available", false)))

func test_update_manifest_rejects_wrong_channel() -> void:
	var wrong_channel := ProjectInfo.update_status_from_manifest({
		"schema_version": ProjectInfo.MANIFEST_SCHEMA_VERSION,
		"channel": "public_release",
	})
	assert_eq(str(wrong_channel.get("status", "")), "unavailable")
