extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const SettingsStoreScript = preload("res://autoloads/settings_store.gd")

func before_each() -> void:
	_clear_saved_loadout()

func after_each() -> void:
	var launch_context = get_node_or_null("/root/LaunchContext")
	if launch_context != null:
		launch_context.clear_pending_mode_launch()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()
	_clear_saved_loadout()
	var profile_store = get_node_or_null("/root/ProfileStore")
	if profile_store != null:
		profile_store.clear_profile()

func test_frontend_fresh_profile_routes_campaign_to_campaign_runtime_and_surfaces_grouped_modes() -> void:
	_generate_resources()
	get_node("/root/ProfileStore").clear_profile()

	var frontend: Control = await _instantiate_frontend()

	var info_label: Label = frontend.find_child("InfoLabel", true, false)
	var config_title_label: Label = frontend.find_child("ConfigTitleLabel", true, false)
	var authored_notice: Label = frontend.find_child("AuthoredModeNotice", true, false)
	var suspended_run_card: PanelContainer = frontend.find_child("SuspendedRunCard", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var summary_label: Label = frontend.find_child("SummaryLabel", true, false)
	var message_label: Label = frontend.find_child("MessageLabel", true, false)
	var start_button: Button = frontend.find_child("StartButton", true, false)
	var canonical_button: Button = frontend.find_child("CanonicalButton", true, false)
	var configure_loadout_button: Button = frontend.find_child("ConfigureLoadoutButton", true, false)
	var race_section: VBoxContainer = frontend.find_child("RaceSection", true, false)
	var selection_scroll: ScrollContainer = frontend.find_child("SelectionScroll", true, false)
	var campaign_group: VBoxContainer = frontend.find_child("CampanhaGroup", true, false)
	var extras_group: VBoxContainer = frontend.find_child("ExtrasGroup", true, false)
	var versus_group: VBoxContainer = frontend.find_child("VersusGroup", true, false)
	var campaign_button: Button = frontend.find_child("CampanhaModeButton", true, false)
	var campaign_easy_button: Button = frontend.find_child("CampaignDifficultyEasyButton", true, false)
	var campaign_normal_button: Button = frontend.find_child("CampaignDifficultyNormalButton", true, false)
	var campaign_free_button: Button = frontend.find_child("CampaignDifficultyLivreButton", true, false)
	var survival_button: Button = frontend.find_child("SurvivalModeButton", true, false)
	var boss_button: Button = frontend.find_child("BossModeButton", true, false)
	var arena_bot_button: Button = frontend.find_child("ArenaBotModeButton", true, false)
	var arena_pvp_button: Button = frontend.find_child("ArenaPvpModeButton", true, false)
	assert_not_null(info_label)
	assert_not_null(config_title_label)
	assert_not_null(authored_notice)
	assert_not_null(suspended_run_card)
	assert_not_null(save_state_label)
	assert_not_null(summary_label)
	assert_not_null(message_label)
	assert_not_null(start_button)
	assert_not_null(canonical_button)
	assert_not_null(configure_loadout_button)
	assert_not_null(race_section)
	assert_not_null(selection_scroll)
	assert_not_null(campaign_group)
	assert_not_null(extras_group)
	assert_null(versus_group)
	assert_not_null(campaign_button)
	assert_not_null(campaign_easy_button)
	assert_not_null(campaign_normal_button)
	assert_not_null(campaign_free_button)
	assert_not_null(survival_button)
	assert_not_null(boss_button)
	assert_not_null(arena_bot_button)
	assert_null(arena_pvp_button)
	if OS.is_debug_build():
		assert_not_null(frontend.find_child("DeveloperUnlockToggle", true, false))

	assert_eq(config_title_label.text, "Jogar")
	assert_true(authored_notice.visible)
	assert_false(race_section.visible)
	assert_false(selection_scroll.visible)
	assert_false(summary_label.visible)
	assert_false(suspended_run_card.visible)
	assert_eq(info_label.text, "Comece pela Campanha do Troll. Arena Bot fica como treino de kit; Survival abre apos a Missao 1 e Boss so depois da campanha.")
	assert_eq(save_state_label.text, "A Campanha classica e a jornada principal. Survival, Boss e Arena Bot ficam como extras de resistencia, maestria e treino de kit.")
	assert_eq(summary_label.text, "Modo: Campanha do Troll\nEntrada: Missao 1 / Tutorial\nStatus: Entrada principal")
	assert_eq(message_label.text, "Campanha pronta para seguir a rota Classic.")
	assert_eq(start_button.text, "Continuar a Campanha")
	assert_false(start_button.disabled)
	assert_true(campaign_easy_button.button_pressed)
	assert_false(campaign_easy_button.disabled)
	assert_false(campaign_normal_button.button_pressed)
	assert_true(campaign_normal_button.disabled)
	assert_string_contains(campaign_normal_button.tooltip_text, "Easy")
	assert_false(campaign_free_button.button_pressed)
	assert_true(campaign_free_button.disabled)
	assert_string_contains(campaign_free_button.tooltip_text, "Classic - Easy")

	survival_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_true(start_button.disabled)
	assert_string_contains(message_label.text, "Missao 1/tutorial")

	arena_bot_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_eq(config_title_label.text, "Jogar")
	assert_true(configure_loadout_button.visible)
	assert_false(start_button.visible)
	assert_false(canonical_button.visible)
	assert_false(summary_label.visible)
	assert_string_contains(message_label.text, "Preparar kit")

	configure_loadout_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_eq(config_title_label.text, "Kit para Arena Bot")
	assert_true(race_section.visible)
	assert_true(selection_scroll.visible)
	assert_true(start_button.disabled)
	assert_eq(start_button.text, "Entrar na Arena Bot")
	assert_string_contains(summary_label.text, "Modo: Arena Bot")

	campaign_button.emit_signal("pressed")
	await get_tree().process_frame
	var launch_result: Dictionary = frontend.launch_selected_mode(false)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))
	assert_false(bool(launch_result.get("tutorial_entry", false)))
	assert_eq(str(launch_result.get("scene_path", "")), LocalModeCatalog.get_scene_path(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_true(get_node("/root/LaunchContext").has_pending_mode_launch(LocalModeCatalog.CAMPAIGN_MODE_ID))
	var launch_request = get_node("/root/LaunchContext").consume_pending_mode_launch()
	assert_eq(String(launch_request.mode_id), String(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_eq(launch_request.scene_path, LocalModeCatalog.get_scene_path(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_no_new_orphans()

func test_frontend_campaign_after_tutorial_uses_authored_route_and_survival_uses_builder() -> void:
	_generate_resources()
	get_node("/root/ProfileStore").complete_mandatory_tutorial()

	var frontend: Control = await _instantiate_frontend()

	var info_label: Label = frontend.find_child("InfoLabel", true, false)
	var config_title_label: Label = frontend.find_child("ConfigTitleLabel", true, false)
	var authored_notice: Label = frontend.find_child("AuthoredModeNotice", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var start_button: Button = frontend.find_child("StartButton", true, false)
	var canonical_button: Button = frontend.find_child("CanonicalButton", true, false)
	var configure_loadout_button: Button = frontend.find_child("ConfigureLoadoutButton", true, false)
	var survival_button: Button = frontend.find_child("SurvivalModeButton", true, false)
	var campaign_easy_button: Button = frontend.find_child("CampaignDifficultyEasyButton", true, false)
	var campaign_normal_button: Button = frontend.find_child("CampaignDifficultyNormalButton", true, false)
	var campaign_free_button: Button = frontend.find_child("CampaignDifficultyLivreButton", true, false)
	var skills_column: VBoxContainer = frontend.find_child("SkillsColumn", true, false)
	var potions_column: VBoxContainer = frontend.find_child("PotionsColumn", true, false)
	var message_label: Label = frontend.find_child("MessageLabel", true, false)
	assert_not_null(info_label)
	assert_not_null(config_title_label)
	assert_not_null(authored_notice)
	assert_not_null(save_state_label)
	assert_not_null(start_button)
	assert_not_null(canonical_button)
	assert_not_null(configure_loadout_button)
	assert_not_null(survival_button)
	assert_not_null(campaign_easy_button)
	assert_not_null(campaign_normal_button)
	assert_not_null(campaign_free_button)
	assert_not_null(skills_column)
	assert_not_null(potions_column)
	assert_not_null(message_label)

	assert_eq(info_label.text, "Campanha em andamento: Survival e Arena Bot estao liberados como extras de resistencia e treino; Boss segue bloqueado ate fechar a Campanha do Troll.")
	assert_eq(config_title_label.text, "Jogar")
	assert_true(authored_notice.visible)
	assert_eq(save_state_label.text, "A Campanha classica e a jornada principal. Survival, Boss e Arena Bot ficam como extras de resistencia, maestria e treino de kit.")
	assert_eq(start_button.text, "Continuar a Campanha")
	assert_false(start_button.disabled)
	assert_true(campaign_easy_button.button_pressed)
	assert_true(campaign_normal_button.disabled)
	assert_true(campaign_free_button.disabled)
	assert_string_contains(campaign_free_button.tooltip_text, "Classic - Easy")

	var launch_result: Dictionary = frontend.launch_selected_mode(false)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))
	assert_false(bool(launch_result.get("tutorial_entry", false)))
	assert_true(get_node("/root/LaunchContext").has_pending_mode_launch(LocalModeCatalog.CAMPAIGN_MODE_ID))
	var launch_request = get_node("/root/LaunchContext").consume_pending_mode_launch()
	assert_eq(String(launch_request.mode_id), String(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_eq(launch_request.scene_path, LocalModeCatalog.get_scene_path(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_eq(String(launch_request.get_campaign_id()), "blacksmith_campaign")
	assert_eq(String(launch_request.get_campaign_difficulty_id()), "easy")

	survival_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_eq(config_title_label.text, "Jogar")
	assert_false(authored_notice.visible)
	assert_false(canonical_button.visible)
	assert_true(configure_loadout_button.visible)
	assert_false(start_button.visible)
	var mode_summary_label: Label = frontend.find_child("ModeSummaryLabel", true, false)
	assert_not_null(mode_summary_label)
	assert_string_contains(mode_summary_label.text, "Desafio de ondas")
	assert_string_contains(mode_summary_label.text, "nao substitui a progressao")
	assert_string_contains(message_label.text, "Preparar kit")

	configure_loadout_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_eq(config_title_label.text, "Kit para Survival")
	assert_true(canonical_button.visible)
	assert_true(start_button.visible)
	assert_eq(start_button.text, "Entrar em Survival")
	assert_true(start_button.disabled)
	assert_eq(_count_enabled_checkboxes(skills_column), 2)
	assert_eq(_count_enabled_checkboxes(potions_column), 1)
	assert_eq(_count_disabled_checkboxes(skills_column), 2)
	assert_eq(_count_disabled_checkboxes(potions_column), 1)

	canonical_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_true(start_button.disabled)
	assert_string_contains(message_label.text, "ainda nao aprendeu recursos suficientes para um kit completo")
	assert_string_contains(save_state_label.text, "2/4 habilidades")
	assert_string_contains(save_state_label.text, "1/2 pocoes")
	assert_no_new_orphans()

func test_frontend_campaign_normal_unlocks_after_easy_completion_and_launches_with_normal_difficulty() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	profile_store.complete_mandatory_tutorial()
	profile_store.complete_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy")

	var frontend: Control = await _instantiate_frontend()
	var campaign_normal_button: Button = frontend.find_child("CampaignDifficultyNormalButton", true, false)
	var authored_notice: Label = frontend.find_child("AuthoredModeNotice", true, false)
	var summary_label: Label = frontend.find_child("SummaryLabel", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var message_label: Label = frontend.find_child("MessageLabel", true, false)
	var start_button: Button = frontend.find_child("StartButton", true, false)
	assert_not_null(campaign_normal_button)
	assert_not_null(authored_notice)
	assert_not_null(summary_label)
	assert_not_null(save_state_label)
	assert_not_null(message_label)
	assert_not_null(start_button)

	assert_false(campaign_normal_button.disabled)
	campaign_normal_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_true(campaign_normal_button.button_pressed)
	assert_eq(start_button.text, "Continuar a Campanha (Normal)")
	assert_eq(authored_notice.text, "Campanha do Troll em Normal usa uma segunda rota sem novas recompensas permanentes. Os modos extras ficam para treino, maestria e replay.")
	assert_string_contains(summary_label.text, "Classic - Normal")
	assert_string_contains(summary_label.text, "Entrada: Mapa 1")
	assert_string_contains(save_state_label.text, "segunda rota")
	assert_eq(message_label.text, "Campanha pronta para seguir a rota Classic - Normal.")

	var launch_result: Dictionary = frontend.launch_selected_mode(false)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))
	assert_true(get_node("/root/LaunchContext").has_pending_mode_launch(LocalModeCatalog.CAMPAIGN_MODE_ID))
	var launch_request = get_node("/root/LaunchContext").consume_pending_mode_launch()
	assert_eq(String(launch_request.get_campaign_id()), "blacksmith_campaign")
	assert_eq(String(launch_request.get_campaign_difficulty_id()), "normal")

func test_frontend_campaign_free_unlocks_after_easy_completion_and_uses_builder_contract() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	profile_store.complete_mandatory_tutorial()
	_apply_stage_reward(profile_store, 2)
	_apply_stage_reward(profile_store, 3)
	_apply_stage_reward(profile_store, 4)
	profile_store.complete_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy")

	var frontend: Control = await _instantiate_frontend()
	var campaign_free_button: Button = frontend.find_child("CampaignDifficultyLivreButton", true, false)
	var authored_notice: Label = frontend.find_child("AuthoredModeNotice", true, false)
	var config_title_label: Label = frontend.find_child("ConfigTitleLabel", true, false)
	var configure_loadout_button: Button = frontend.find_child("ConfigureLoadoutButton", true, false)
	var canonical_button: Button = frontend.find_child("CanonicalButton", true, false)
	var race_section: VBoxContainer = frontend.find_child("RaceSection", true, false)
	var selection_scroll: ScrollContainer = frontend.find_child("SelectionScroll", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var summary_label: Label = frontend.find_child("SummaryLabel", true, false)
	var message_label: Label = frontend.find_child("MessageLabel", true, false)
	var start_button: Button = frontend.find_child("StartButton", true, false)
	assert_not_null(campaign_free_button)
	assert_not_null(authored_notice)
	assert_not_null(config_title_label)
	assert_not_null(configure_loadout_button)
	assert_not_null(canonical_button)
	assert_not_null(race_section)
	assert_not_null(selection_scroll)
	assert_not_null(save_state_label)
	assert_not_null(summary_label)
	assert_not_null(message_label)
	assert_not_null(start_button)

	assert_false(campaign_free_button.disabled)
	campaign_free_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_true(campaign_free_button.button_pressed)
	assert_false(authored_notice.visible)
	assert_true(configure_loadout_button.visible)
	assert_false(start_button.visible)
	assert_false(summary_label.visible)
	assert_string_contains(save_state_label.text, "Campanha Livre selecionada")
	assert_string_contains(message_label.text, "Campanha Livre")

	configure_loadout_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_eq(config_title_label.text, "Kit para Campanha Livre")
	assert_true(race_section.visible)
	assert_true(selection_scroll.visible)
	assert_true(canonical_button.visible)
	assert_true(start_button.visible)
	assert_eq(start_button.text, "Entrar na Campanha Livre")
	assert_true(start_button.disabled)
	assert_string_contains(summary_label.text, "Modo: Campanha Livre")

	canonical_button.emit_signal("pressed")
	await get_tree().process_frame
	assert_false(start_button.disabled)
	assert_eq(message_label.text, "Kit pronto para Campanha Livre.")

	var launch_result: Dictionary = frontend.launch_selected_mode(false)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))
	assert_true(get_node("/root/LaunchContext").has_pending_mode_launch(LocalModeCatalog.CAMPAIGN_MODE_ID))
	var launch_request = get_node("/root/LaunchContext").consume_pending_mode_launch()
	assert_eq(String(launch_request.mode_id), String(LocalModeCatalog.CAMPAIGN_MODE_ID))
	assert_eq(String(launch_request.get_campaign_id()), "blacksmith_campaign")
	assert_eq(String(launch_request.get_campaign_difficulty_id()), "free")
	assert_eq(Array(launch_request.loadout.get_skill_ids()).size(), 4)
	assert_eq(Array(launch_request.loadout.get_potion_ids()).size(), 2)
	assert_no_new_orphans()

func test_frontend_campaign_easy_legacy_suspend_migrates_to_route_specific_key() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	var suspended_loadout = _build_valid_loadout()
	var legacy_key: StringName = ProgressionResolver.build_legacy_campaign_run_key(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID)
	var easy_key: StringName = ProgressionResolver.build_campaign_run_key(
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		&"easy"
	)
	profile_store.save_suspended_run(
		legacy_key,
		{
			"campaign_id": "blacksmith_campaign",
			"current_stage_index": 0,
			"current_level": 1,
			"loadout": suspended_loadout.to_id_payload(),
			"suspend_origin": "menu"
		}
	)

	var frontend: Control = await _instantiate_frontend()
	var suspended_run_card: PanelContainer = frontend.find_child("SuspendedRunCard", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	assert_not_null(suspended_run_card)
	assert_not_null(save_state_label)

	assert_true(suspended_run_card.visible)
	assert_true(profile_store.has_suspended_run(easy_key))
	assert_false(profile_store.has_suspended_run(legacy_key))
	assert_string_contains(save_state_label.text, "run suspensa da Campanha do Troll")

func test_frontend_survival_builder_launches_once_the_permanent_pool_is_complete() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.complete_mandatory_tutorial()
	_apply_stage_reward(profile_store, 2)
	_apply_stage_reward(profile_store, 3)
	_apply_stage_reward(profile_store, 4)

	var frontend: Control = await _instantiate_frontend()

	var survival_button: Button = frontend.find_child("SurvivalModeButton", true, false)
	var configure_loadout_button: Button = frontend.find_child("ConfigureLoadoutButton", true, false)
	var canonical_button: Button = frontend.find_child("CanonicalButton", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var start_button: Button = frontend.find_child("StartButton", true, false)
	assert_not_null(survival_button)
	assert_not_null(configure_loadout_button)
	assert_not_null(canonical_button)
	assert_not_null(save_state_label)
	assert_not_null(start_button)

	survival_button.emit_signal("pressed")
	await get_tree().process_frame
	configure_loadout_button.emit_signal("pressed")
	await get_tree().process_frame
	canonical_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_false(start_button.disabled)
	var launch_result: Dictionary = frontend.launch_selected_mode(false)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))
	assert_eq(save_state_label.text, "A selecao atual corresponde ao kit salvo localmente para Survival.")
	assert_true(get_node("/root/LaunchContext").has_pending_mode_launch(LocalModeCatalog.SURVIVAL_MODE_ID))
	var launch_request = get_node("/root/LaunchContext").consume_pending_mode_launch()
	assert_eq(String(launch_request.mode_id), String(LocalModeCatalog.SURVIVAL_MODE_ID))
	assert_eq(launch_request.scene_path, LocalModeCatalog.get_scene_path(LocalModeCatalog.SURVIVAL_MODE_ID))
	assert_eq(launch_request.get_survival_start_wave(), 1)
	assert_no_new_orphans()

func test_frontend_saved_selection_stays_on_builder_modes() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.complete_mandatory_tutorial()
	_apply_stage_reward(profile_store, 2)
	_apply_stage_reward(profile_store, 3)
	_apply_stage_reward(profile_store, 4)

	var frontend: Control = await _instantiate_frontend()
	var arena_bot_button: Button = frontend.find_child("ArenaBotModeButton", true, false)
	var configure_loadout_button: Button = frontend.find_child("ConfigureLoadoutButton", true, false)
	var canonical_button: Button = frontend.find_child("CanonicalButton", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var summary_label: Label = frontend.find_child("SummaryLabel", true, false)
	assert_not_null(arena_bot_button)
	assert_not_null(configure_loadout_button)
	assert_not_null(canonical_button)
	assert_not_null(save_state_label)
	assert_not_null(summary_label)

	arena_bot_button.emit_signal("pressed")
	await get_tree().process_frame
	configure_loadout_button.emit_signal("pressed")
	await get_tree().process_frame
	canonical_button.emit_signal("pressed")
	await get_tree().process_frame

	var launch_result: Dictionary = frontend.launch_selected_mode(false)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))
	assert_eq(save_state_label.text, "A selecao atual corresponde ao kit salvo localmente para Arena Bot.")
	assert_string_contains(summary_label.text, "Modo: Arena Bot")

	frontend.queue_free()
	await get_tree().process_frame

	var second_frontend: Control = await _instantiate_frontend()
	var second_configure_button: Button = second_frontend.find_child("ConfigureLoadoutButton", true, false)
	var second_save_state_label: Label = second_frontend.find_child("SaveStateLabel", true, false)
	var second_saved_button: Button = second_frontend.find_child("SavedButton", true, false)
	var second_summary_label: Label = second_frontend.find_child("SummaryLabel", true, false)
	var second_start_button: Button = second_frontend.find_child("StartButton", true, false)
	assert_not_null(second_configure_button)
	assert_not_null(second_save_state_label)
	assert_not_null(second_saved_button)
	assert_not_null(second_summary_label)
	assert_not_null(second_start_button)

	assert_eq(second_save_state_label.text, "Existe um kit salvo para este modo. Use Preparar kit para revisar ou entrar com a ultima combinacao.")
	assert_true(second_configure_button.visible)
	second_configure_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_eq(second_save_state_label.text, "Existe um kit salvo para Arena Bot. A selecao atual ainda nao esta completa; use Restaurar salvo para recuperar a ultima combinacao pronta.")
	assert_eq(second_saved_button.text, "Restaurar salvo (Arena Bot)")
	assert_eq(second_start_button.text, "Entrar na Arena Bot")
	assert_string_contains(second_summary_label.text, "Modo: Arena Bot")

	second_saved_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_eq(second_save_state_label.text, "A selecao atual corresponde ao kit salvo localmente para Arena Bot.")
	assert_string_contains(second_summary_label.text, "Modo: Arena Bot")
	assert_string_contains(second_summary_label.text, "Raca: Imortais")
	assert_string_contains(second_summary_label.text, "Arma: Martelo dos Imortais")
	assert_string_contains(second_summary_label.text, "Habilidades (4/4):")
	assert_string_contains(second_summary_label.text, "Arremesso de Martelo")
	assert_string_contains(second_summary_label.text, "Brado dos Imortais")
	assert_string_contains(second_summary_label.text, "Salto Quebrador")
	assert_string_contains(second_summary_label.text, "Impacto do Martelo")
	assert_string_contains(second_summary_label.text, "Pocoes (2/2): Frasco Vital, Tonico de Baluarte")
	assert_no_new_orphans()

func test_frontend_saved_selection_becomes_incompatible_when_progression_has_not_unlocked_the_pool() -> void:
	_generate_resources()
	get_node("/root/ProfileStore").complete_mandatory_tutorial()

	_write_saved_loadout({
		"mode_id": String(LocalModeCatalog.ARENA_BOT_MODE_ID),
		"race_id": "heroic",
		"weapon_id": "heroic_hammer",
		"skill_ids": ["heroic_rally", "breaker_leap", "hammer_impact", "seismic_ring"],
		"potion_ids": ["bastion_tonic", "vital_flask"]
	})

	var frontend: Control = await _instantiate_frontend()

	var configure_loadout_button: Button = frontend.find_child("ConfigureLoadoutButton", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var saved_button: Button = frontend.find_child("SavedButton", true, false)
	assert_not_null(configure_loadout_button)
	assert_not_null(save_state_label)
	assert_not_null(saved_button)

	assert_true(configure_loadout_button.visible)
	configure_loadout_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_true(saved_button.disabled)
	assert_string_contains(save_state_label.text, "nao combina com o estado atual da conta")
	assert_string_contains(save_state_label.text, "Campanha do Troll")

func test_frontend_disables_restore_when_saved_profile_no_longer_matches_current_content() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.complete_mandatory_tutorial()
	profile_store.complete_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID, &"easy")

	_write_saved_loadout({
		"mode_id": String(LocalModeCatalog.BOSS_MODE_ID),
		"race_id": "heroic",
		"weapon_id": "heroic_hammer",
		"skill_ids": ["heroic_rally", "breaker_leap", "missing_skill", "seismic_ring"],
		"potion_ids": ["bastion_tonic", "vital_flask"]
	})

	var frontend: Control = await _instantiate_frontend()

	var configure_loadout_button: Button = frontend.find_child("ConfigureLoadoutButton", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var saved_button: Button = frontend.find_child("SavedButton", true, false)
	var summary_label: Label = frontend.find_child("SummaryLabel", true, false)
	var start_button: Button = frontend.find_child("StartButton", true, false)
	assert_not_null(configure_loadout_button)
	assert_not_null(save_state_label)
	assert_not_null(saved_button)
	assert_not_null(summary_label)
	assert_not_null(start_button)

	assert_true(configure_loadout_button.visible)
	configure_loadout_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_true(saved_button.disabled)
	assert_eq(saved_button.text, "Restaurar salvo (Boss)")
	assert_string_contains(save_state_label.text, "O kit salvo para Boss nao combina mais com o pacote atual.")
	assert_string_contains(save_state_label.text, "1 habilidade do pacote salvo esta ausente.")
	assert_eq(start_button.text, "Entrar em Boss")
	assert_string_contains(summary_label.text, "Modo: Boss")
	assert_no_new_orphans()

func test_frontend_survival_suspended_run_prompts_continue_and_reuses_saved_loadout() -> void:
	_generate_resources()
	var profile_store = get_node("/root/ProfileStore")
	profile_store.clear_profile()
	profile_store.complete_mandatory_tutorial()
	var suspended_loadout = _build_valid_loadout()
	profile_store.save_suspended_run(
		ProgressionResolver.build_survival_run_key(),
		{
			"loadout": suspended_loadout.to_id_payload(),
			"start_wave": 3,
			"wave_manager": {
				"current_wave": 3,
				"completed_waves": 2,
				"target_wave": 5
			},
			"player": {
				"combat": {
					"health": 42.0,
					"max_health": 100.0
				}
			},
			"suspend_origin": "quit"
		}
	)

	var frontend: Control = await _instantiate_frontend()
	var survival_button: Button = frontend.find_child("SurvivalModeButton", true, false)
	var start_button: Button = frontend.find_child("StartButton", true, false)
	var message_label: Label = frontend.find_child("MessageLabel", true, false)
	var save_state_label: Label = frontend.find_child("SaveStateLabel", true, false)
	var suspended_run_card: PanelContainer = frontend.find_child("SuspendedRunCard", true, false)
	var suspended_run_card_eyebrow: Label = frontend.find_child("SuspendedRunCardEyebrowLabel", true, false)
	var suspended_run_card_title: Label = frontend.find_child("SuspendedRunCardTitleLabel", true, false)
	var suspended_run_card_body: Label = frontend.find_child("SuspendedRunCardBodyLabel", true, false)
	var suspended_run_card_hint: Label = frontend.find_child("SuspendedRunCardHintLabel", true, false)
	var prompt_panel: PanelContainer = frontend.find_child("SuspendedRunPrompt", true, false)
	var prompt_title: Label = frontend.find_child("SuspendedRunPromptTitleLabel", true, false)
	var prompt_hint: Label = frontend.find_child("SuspendedRunPromptHintLabel", true, false)
	var continue_button: Button = frontend.find_child("SuspendedRunContinueButton", true, false)
	assert_not_null(survival_button)
	assert_not_null(start_button)
	assert_not_null(message_label)
	assert_not_null(save_state_label)
	assert_not_null(suspended_run_card)
	assert_not_null(suspended_run_card_eyebrow)
	assert_not_null(suspended_run_card_title)
	assert_not_null(suspended_run_card_body)
	assert_not_null(suspended_run_card_hint)
	assert_not_null(prompt_panel)
	assert_not_null(prompt_title)
	assert_not_null(prompt_hint)
	assert_not_null(continue_button)

	survival_button.emit_signal("pressed")
	await get_tree().process_frame

	assert_false(start_button.disabled)
	assert_true(suspended_run_card.visible)
	assert_eq(suspended_run_card_eyebrow.text, "SALVO AO FECHAR O JOGO")
	assert_eq(suspended_run_card_title.text, "Survival em pausa")
	assert_string_contains(suspended_run_card_body.text, "onda 3")
	assert_string_contains(suspended_run_card_body.text, "2/5")
	assert_string_contains(suspended_run_card_body.text, "42%")
	assert_string_contains(suspended_run_card_hint.text, "Continuar")
	assert_string_contains(message_label.text, "run suspensa de Survival")
	assert_string_contains(message_label.text, "jogo foi fechado")
	assert_string_contains(save_state_label.text, "run suspensa de Survival")
	assert_string_contains(save_state_label.text, "jogo foi fechado")

	var launch_result: Dictionary = frontend.launch_selected_mode(false)
	assert_true(bool(launch_result.get("ok", false)))
	assert_true(bool(launch_result.get("prompted_suspended_run", false)))
	assert_true(prompt_panel.visible)
	assert_eq(prompt_title.text, "Survival em pausa")
	assert_string_contains((frontend.find_child("SuspendedRunPromptLabel", true, false) as Label).text, "jogo foi fechado")
	assert_string_contains(prompt_hint.text, "Abandonar")

	frontend._hide_suspended_run_prompt()
	var continue_result: Dictionary = frontend._launch_mode_internal(false, true)
	assert_true(bool(continue_result.get("ok", false)), str(continue_result.get("message", "")))

	assert_true(get_node("/root/LaunchContext").has_pending_mode_launch(LocalModeCatalog.SURVIVAL_MODE_ID))
	var launch_request = get_node("/root/LaunchContext").consume_pending_mode_launch()
	assert_true(launch_request.should_resume_suspended_run())
	assert_eq(String(launch_request.mode_id), String(LocalModeCatalog.SURVIVAL_MODE_ID))
	assert_eq(Array(launch_request.loadout.get_skill_ids()), Array(suspended_loadout.get_skill_ids()))
	assert_eq(Array(launch_request.loadout.get_potion_ids()), Array(suspended_loadout.get_potion_ids()))
	assert_no_new_orphans()

func _generate_resources() -> void:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

func _instantiate_frontend() -> Control:
	var frontend_scene: PackedScene = load("res://modes/frontend/frontend.tscn")
	assert_not_null(frontend_scene)
	var frontend: Control = frontend_scene.instantiate()
	add_child_autofree(frontend)
	await get_tree().process_frame
	return frontend

func _build_valid_loadout():
	var library = get_node("/root/ContentLibrary")
	library.reload()
	var races = library.get_races()
	assert_eq(races.size(), 1)

	var race = races[0]
	var weapon = library.get_weapons_for_race(race.id)[0]
	var skills = library.get_skills_for_weapon(race.id, weapon.id)
	var potions = library.get_potions_for_race(race.id)
	return library.build_loadout_from_ids(
		race.id,
		weapon.id,
		PackedStringArray([
			String(skills[0].id),
			String(skills[1].id),
			String(skills[2].id),
			String(skills[3].id)
		]),
		PackedStringArray([
			String(potions[0].id),
			String(potions[1].id)
		])
	)

func _clear_saved_loadout() -> void:
	var absolute_path: String = ProjectSettings.globalize_path(SettingsStoreScript.SAVE_PATH)
	if FileAccess.file_exists(SettingsStoreScript.SAVE_PATH):
		DirAccess.remove_absolute(absolute_path)

func _write_saved_loadout(payload: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(SettingsStoreScript.SAVE_PATH, FileAccess.WRITE)
	assert_not_null(file)
	file.store_string(JSON.stringify(payload, "\t"))

func _apply_stage_reward(profile_store: Node, stage_number: int, current_level: int = 1) -> void:
	var stage_scene: PackedScene = load("res://modes/campaign/stages/campaign_mission_%02d.tscn" % stage_number)
	assert_not_null(stage_scene)
	var stage_root = stage_scene.instantiate()
	assert_not_null(stage_root)
	add_child_autofree(stage_root)
	profile_store.apply_campaign_stage_completion(
		stage_root.build_reward_payload(
			ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
			&"easy",
			current_level
		)
	)

func _count_enabled_checkboxes(container: VBoxContainer) -> int:
	var total: int = 0
	for child: Node in container.get_children():
		var checkbox: CheckBox = child as CheckBox
		if checkbox != null and not checkbox.disabled:
			total += 1
	return total

func _count_disabled_checkboxes(container: VBoxContainer) -> int:
	var total: int = 0
	for child: Node in container.get_children():
		var checkbox: CheckBox = child as CheckBox
		if checkbox != null and checkbox.disabled:
			total += 1
	return total
