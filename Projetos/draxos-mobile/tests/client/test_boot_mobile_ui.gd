extends GutTest

const BootScreenScript = preload("res://modes/boot/boot.gd")
const BaseSurfacePresenterScript = preload("res://modes/boot/surfaces/base_surface_presenter.gd")

func before_each() -> void:
	_reset_session_store_for_test()

func after_each() -> void:
	ProjectSettings.set_setting("draxos_mobile/ui/force_compact_layout", false)
	_reset_session_store_for_test()

func test_boot_compact_layout_groups_actions_for_mobile_landscape() -> void:
	ProjectSettings.set_setting("draxos_mobile/ui/force_compact_layout", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_true(boot._compact_layout)
	assert_eq(boot._action_button_columns(), 3)
	assert_eq(boot._base_map_columns(), 6)
	var hub_button := boot._nav_buttons["hub"] as Button
	assert_true(hub_button.custom_minimum_size.y >= 48.0)

	var action_grid := _first_action_grid(boot._content_body)
	assert_not_null(action_grid)
	assert_eq(action_grid.columns, 3)
	var sign_up_button := boot._action_buttons["email_sign_up"] as Button
	assert_true(sign_up_button.custom_minimum_size.y >= 48.0)
	assert_false(_has_direct_button_child(boot._content_body))
	assert_not_null(boot._confirm_dialog)

func test_boot_hub_presenter_renders_login_save_session_and_update_gate() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_not_null(boot._auth_email_input)
	assert_not_null(boot._auth_password_input)
	assert_true(boot._auth_password_input.secret)
	assert_not_null(boot._auth_username_input)
	assert_not_null(boot._auth_invite_input)
	assert_not_null(boot._update_output_label)
	assert_string_contains(boot._update_output_label.text, "Canal:")
	assert_true(boot._action_buttons.has("email_sign_up"))
	assert_true(boot._action_buttons.has("email_sign_in"))
	assert_true(boot._action_buttons.has("select_save_normal"))
	assert_true(boot._action_buttons.has("select_save_progression_lab"))
	assert_true(boot._action_buttons.has("check_update"))

func test_boot_profile_account_panel_shows_save_account_update_and_alpha_status() -> void:
	_prepare_account_state()
	SessionStore.auth_method = "email"
	SessionStore.auth_email = "alpha@example.com"
	SessionStore.account_username = "alpha_tester"
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	boot._update_gate = ProjectInfo.update_status_from_manifest(_current_manifest_fixture(), "https://manifest.example")
	boot._show_screen("hub", false)
	await get_tree().process_frame

	assert_true(_label_tree_contains(boot._content_body, "Perfil e conta"))
	assert_true(_label_tree_contains(boot._content_body, "Username: tester"))
	assert_true(_label_tree_contains(boot._content_body, "Conta: alpha_tester"))
	assert_true(_label_tree_contains(boot._content_body, "Save ativo: Normal (normal)"))
	assert_true(_label_tree_contains(boot._content_body, "Level: 8"))
	assert_true(_label_tree_contains(boot._content_body, "Poder: 120"))
	assert_true(_label_tree_contains(boot._content_body, "Auth: email/senha (alpha@example.com)"))
	assert_true(_label_tree_contains(boot._content_body, "account/state: carregado do save ativo"))
	assert_true(_label_tree_contains(boot._content_body, "Update: Build atualizada"))
	assert_true(_label_tree_contains(boot._content_body, "Alpha: internal_alpha 0.0.1-alpha.0 | online pronto"))

func test_boot_profile_account_panel_has_clear_empty_state_without_account() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_true(_label_tree_contains(boot._content_body, "Username: sem conta carregada"))
	assert_true(_label_tree_contains(boot._content_body, "account/state: sem sessao auth"))
	assert_true(_label_tree_contains(boot._content_body, "Alpha: internal_alpha 0.0.1-alpha.0 | aguardando login"))

func test_boot_surface_presenters_render_shells_without_network() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("battle")
	assert_true(boot._action_buttons.has("request_battle"))
	assert_true(boot._action_buttons.has("show_battle_history"))
	assert_true(boot._action_buttons.has("show_latest_battle"))
	assert_not_null(boot._battle_visual)
	await get_tree().process_frame

	boot._show_screen("base")
	assert_true(boot._action_buttons.has("show_base"))
	assert_true(boot._action_buttons.has("collect_base"))
	assert_not_null(boot._base_state_container)
	await get_tree().process_frame

	boot._show_screen("social")
	assert_true(boot._action_buttons.has("show_social"))
	assert_true(boot._action_buttons.has("send_guild_chat"))
	assert_not_null(boot._social_state_container)
	await get_tree().process_frame

	boot._show_screen("competition")
	assert_true(boot._action_buttons.has("show_matchmaking"))
	assert_true(boot._action_buttons.has("show_ranking"))
	assert_not_null(boot._competition_state_container)
	await get_tree().process_frame

	boot._show_screen("shop")
	assert_true(boot._action_buttons.has("show_shop"))
	assert_true(boot._action_buttons.has("claim_reward:daily_collect_base"))
	assert_not_null(boot._shop_state_container)
	await get_tree().process_frame

func test_boot_surface_presenters_keep_render_only_contract() -> void:
	assert_false(FileAccess.file_exists("res://modes/boot/surfaces/battle_surface_presenter.gd"))
	var boot_source := FileAccess.get_file_as_string("res://modes/boot/boot.gd")
	assert_false(boot_source.contains("battle_surface_presenter.gd"))
	for script_path: String in _surface_presenter_script_paths():
		var source := FileAccess.get_file_as_string(script_path)
		for fragment: String in _forbidden_presenter_fragments():
			assert_false(
				source.contains(fragment),
				"%s must stay render-only and host-owned for '%s'" % [script_path, fragment]
			)

func test_base_presenter_renders_loaded_state_without_network() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	SessionStore.base_state = _base_state_fixture()

	boot._show_screen("base")
	await get_tree().process_frame

	assert_string_contains(boot._timeline_label.text, "Refugio server-authoritative")
	assert_string_contains(boot._timeline_label.text, "Fila: 1/2")
	assert_true(boot._action_buttons.has("select_base_structure:nucleo_energia"))
	assert_true(boot._action_buttons.has("upgrade_base_structure:nucleo_energia"))
	assert_not_null(boot._base_state_container)
	assert_true(boot._base_state_container.get_child_count() >= 3)
	var upgrade_button := boot._action_buttons["upgrade_base_structure:nucleo_energia"] as Button
	assert_false(upgrade_button.disabled)

func test_base_routine_panel_derives_objective_from_existing_payload() -> void:
	var routine: Dictionary = BaseSurfacePresenterScript.routine_summary(_base_state_fixture())

	assert_string_contains(str(routine.get("collect_text", "")), "Coleta pronta: Almas 4 | Energia 12.")
	assert_eq(int(routine.get("active_job_count", 0)), 1)
	assert_eq(int(routine.get("free_slots", -1)), 1)
	assert_eq(str(routine.get("next_upgrade_id", "")), "nucleo_energia")
	assert_string_contains(str(routine.get("next_upgrade_text", "")), "Nucleo de Energia para L3")
	assert_string_contains(str(routine.get("next_upgrade_text", "")), "custo Energia 20")
	assert_string_contains(str(routine.get("next_upgrade_text", "")), "tempo 2m 00s")

	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	SessionStore.base_state = _base_state_fixture()

	boot._show_screen("base")
	await get_tree().process_frame

	assert_true(_label_tree_contains(boot._base_state_container, "Rotina da Base"))
	assert_true(_label_tree_contains(boot._base_state_container, "Coleta pronta: Almas 4 | Energia 12."))
	assert_true(_label_tree_contains(boot._base_state_container, "Jobs em andamento: 1."))
	assert_true(_label_tree_contains(boot._base_state_container, "Altar das Almas -> L2 | resta 1m 30s"))
	assert_true(_label_tree_contains(boot._base_state_container, "Slots livres: 1/2."))
	assert_true(_label_tree_contains(boot._base_state_container, "Proximo upgrade: Nucleo de Energia para L3"))

func test_shop_presenter_renders_loaded_state_and_disables_claimed_items() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	SessionStore.monetization_state = _shop_state_fixture()

	boot._show_screen("shop")
	await get_tree().process_frame

	assert_string_contains(boot._timeline_label.text, "Loja alpha server-authoritative")
	assert_string_contains(boot._timeline_label.text, "Redeems hoje: 1/4")
	assert_true(boot._action_buttons.has("shop_purchase:alpha_battle_pass_premium"))
	assert_true(boot._action_buttons.has("claim_reward:daily_collect_base"))
	assert_not_null(boot._shop_state_container)
	assert_true(boot._shop_state_container.get_child_count() >= 4)
	var pass_button := boot._action_buttons["shop_purchase:alpha_battle_pass_premium"] as Button
	assert_true(pass_button.disabled)
	var reward_button := boot._action_buttons["claim_reward:daily_collect_base"] as Button
	assert_true(reward_button.disabled)

func test_boot_social_presenter_renders_chat_polling_and_lab_badges() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.social_state = {
		"identity": {"viewer_badge": "normal"},
		"player": {"username": "fabio", "save_badge": "normal"},
		"active_player": {"username": "lab_save", "save_badge": "lab"},
		"guild": {"name": "Conclave QA", "level": 2},
		"friends": [{
			"status": "accepted",
			"friend": {"username": "tester_lab", "save_badge": "lab", "level": 8, "power": 640},
		}],
		"guild_members": [{
			"role": "member",
			"player": {"username": "tester_lab", "save_badge": "lab", "level": 8, "power": 640},
		}],
		"guild_structures": [{"structure_id": "oficina_ritual", "level": 1}],
		"guild_chat": [{
			"sender_username": "tester_lab",
			"sender_save_badge": "lab",
			"content": "Ola atual",
			"created_at": "2026-05-27T14:45:20Z",
		}],
	}

	boot._show_screen("social")
	assert_string_contains(boot._timeline_label.text, "Refresh: snapshot atual por polling manual")
	assert_string_contains(boot._timeline_label.text, "Chat de guilda: 1 mensagem atual")
	assert_string_contains(boot._timeline_label.text, "Mensagem atual: tester_lab [lab]: Ola atual")
	assert_true(_label_tree_contains(boot._social_state_container, "Mensagens mais recentes recebidas por polling."))
	assert_true(_label_tree_contains(boot._social_state_container, "tester_lab [lab]: Ola atual (2026-05-27 14:45)"))
	assert_true(_label_tree_contains(boot._social_state_container, "Oficina Ritual L1"))
	await get_tree().process_frame

func test_boot_social_presenter_renders_empty_states_and_refresh_hint() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.social_state = {
		"identity": {"viewer_badge": "normal"},
		"player": {"username": "fabio", "save_badge": "normal"},
		"active_player": {"username": "fabio", "save_badge": "normal"},
		"friends": [],
		"guild": null,
		"guild_members": [],
		"guild_structures": [],
		"guild_chat": [],
	}

	boot._show_screen("social")
	assert_string_contains(boot._timeline_label.text, "Mensagem atual: nenhuma")
	assert_true(_label_tree_contains(boot._social_state_container, "Refresh e Polling"))
	assert_true(_label_tree_contains(boot._social_state_container, "Nenhum amigo ainda. Use o username do outro jogador para adicionar."))
	assert_true(_label_tree_contains(boot._social_state_container, "Chat e estruturas aparecem depois que a conta entra em uma guilda."))
	assert_true(_label_tree_contains(boot._social_state_container, "Sem guilda. O chat fica disponivel depois de criar ou entrar em uma guilda."))
	await get_tree().process_frame

func test_boot_competition_presenter_preserves_lab_and_bot_ranking_messages() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.competition_state = {
		"matchmaking": {
			"player_power": 720,
			"candidate_count": 1,
			"selected_opponent": {
				"id": "bot_rankless_001",
				"power": 700,
				"power_band": "near",
				"is_bot": true,
				"is_ranked": false,
			},
		},
		"ranking": {
			"excluded_reason": "PROGRESSION_LAB_DOES_NOT_RANK",
			"bots_included": false,
			"top_limit": 10,
			"total_ranked": 0,
		},
	}

	boot._show_screen("competition")
	assert_string_contains(boot._timeline_label.text, "bots no ranking:")
	assert_true(_label_tree_contains(boot._competition_state_container, "Bot de treino: sim | Entra no ranking: nao"))
	assert_true(_label_tree_contains(boot._competition_state_container, "Progression Lab nao pontua competicao e fica fora do leaderboard."))
	await get_tree().process_frame

func test_boot_battle_presenter_renders_history_entries_without_network() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	var history_entries: Array[Dictionary] = []
	history_entries.append({
		"battle_id": "11111111-1111-4111-8111-111111111111",
		"created_at": "2026-05-27T12:00:00Z",
		"schema_version": "battle_log_v1",
		"mode": ProjectInfo.FIRST_SLICE_MODE,
		"duration": 12.5,
		"event_count": 14,
		"opponent": {"display_name": "Treinador da Primeira Ruina"},
		"result": {"winner": "player"},
		"rewards": {"type": "FIRST_SLICE_SIM", "resources": {"xp": 10, "almas": 0.8}},
	})
	boot._battle_history_entries = history_entries

	boot._show_screen("battle")
	await get_tree().process_frame

	assert_true(boot._action_buttons.has("show_battle_history"))
	assert_true(boot._action_buttons.has("battle_replay:11111111-1111-4111-8111-111111111111"))
	assert_true(_label_tree_contains(boot._content_body, "FIRST_SLICE_SIM"))
	assert_true(_label_tree_contains(boot._content_body, "vitoria"))

func _first_action_grid(parent: Node) -> GridContainer:
	for child: Node in parent.get_children():
		if child is GridContainer:
			return child
	return null

func _has_direct_button_child(parent: Node) -> bool:
	for child: Node in parent.get_children():
		if child is Button:
			return true
	return false

func _label_tree_contains(root: Node, needle: String) -> bool:
	if root == null:
		return false
	if root is Label and str((root as Label).text).contains(needle):
		return true
	for child: Node in root.get_children():
		if _label_tree_contains(child, needle):
			return true
	return false

func _surface_presenter_script_paths() -> PackedStringArray:
	var paths: PackedStringArray = PackedStringArray()
	var dir := DirAccess.open("res://modes/boot/surfaces")
	assert_not_null(dir)
	if dir == null:
		return paths
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".gd"):
			continue
		paths.append("res://modes/boot/surfaces/%s" % file_name)
	return paths

func _forbidden_presenter_fragments() -> PackedStringArray:
	return PackedStringArray([
		"SupabaseClient",
		"BackendConfig",
		"HTTPRequest",
		"await ",
		"_execute_action",
		"_emit_client_event",
		"_send_telemetry_deferred",
		"send_client_telemetry",
		"SessionStore.apply_",
		"SessionStore.save_cache",
		"SessionStore.clear_session",
		"SessionStore.set_active_save_type",
		"SessionStore.mark_offline",
		"SessionStore.session_changed",
		"SessionStore.access_token =",
		"SessionStore.player =",
		"SessionStore.resources =",
		"configure_save_type",
	])

func _reset_session_store_for_test() -> void:
	SessionStore.clear_session()

func _prepare_account_state() -> void:
	SessionStore.access_token = "test-token"
	SessionStore.expires_at = int(Time.get_unix_time_from_system()) + 3600
	SessionStore.player = {"id": "player-1", "level": 8, "power": 120, "username": "tester"}
	SessionStore.resources = {
		"almas": 100,
		"energia": 200,
		"sangue": 8,
		"cristais": 5,
		"ossos": 3,
		"diamante": 160,
	}
	SessionStore.build = {"weapon_id": "varinha_cinzas"}

func _current_manifest_fixture() -> Dictionary:
	return {
		"schema_version": ProjectInfo.MANIFEST_SCHEMA_VERSION,
		"channel": ProjectInfo.RELEASE_CHANNEL,
		"latest_version": ProjectInfo.APP_VERSION,
		"latest_version_code": ProjectInfo.APP_VERSION_CODE,
		"minimum_supported_version": ProjectInfo.APP_VERSION,
		"minimum_supported_version_code": ProjectInfo.APP_VERSION_CODE,
		"requires_save_reset": false,
		"notes": ["Alpha QA current."],
	}

func _base_state_fixture() -> Dictionary:
	return {
		"construction_slots": 2,
		"structures": [
			{
				"structure_id": "nucleo_energia",
				"display_name": "Nucleo de Energia",
				"level": 2,
				"max_level": 40,
				"next_level": 3,
				"description": "Gera Energia para upgrades.",
				"produces": "energia",
				"daily_production": 40,
				"pending_collectable": 12,
				"storage_cap": 80,
				"upgrade_cost": {"energia": 20},
				"upgrade_duration_seconds": 120,
				"can_upgrade": true,
				"blocked_message": "Upgrade disponivel.",
			},
			{
				"structure_id": "altar_das_almas",
				"display_name": "Altar das Almas",
				"level": 1,
				"max_level": 40,
				"next_level": 2,
				"description": "Gera Almas.",
				"produces": "almas",
				"daily_production": 20,
				"pending_collectable": 4,
				"storage_cap": 50,
				"upgrade_cost": {"energia": 10},
				"upgrade_duration_seconds": 60,
				"can_upgrade": false,
				"blocked_reason": "CONSTRUCTION_QUEUE_FULL",
				"blocked_message": "Fila de construcao cheia.",
			},
		],
		"jobs": [
			{
				"status": "active",
				"structure_id": "altar_das_almas",
				"target_level": 2,
				"remaining_seconds": 90,
			},
		],
	}

func _shop_state_fixture() -> Dictionary:
	return {
		"shop_summary": {
			"diamond_balance": 160,
			"currency": "diamante",
			"premium_unlocked": true,
			"daily_redeems_claimed": 1,
			"daily_redeems_total": 4,
			"daily_redeem_period_key": "2026-05-27",
			"reset_timezone": "America/Sao_Paulo",
			"convenience_owned": ["alpha_double_construction_queue"],
		},
		"alpha_products": [
			{
				"id": "alpha_redeem_small",
				"label": "Redeem pequeno",
				"daily_redeem": true,
				"can_purchase": true,
				"cost": {},
				"resources": {"diamante": 40},
				"description": "Diamante diario pequeno.",
			},
			{
				"id": "alpha_battle_pass_premium",
				"label": "Comprar Battle Pass",
				"daily_redeem": false,
				"can_purchase": false,
				"already_owned": true,
				"locked_reason": "ALREADY_OWNED",
				"cost": {"diamante": 120},
				"resources": {},
				"description": "Premium ja ativo.",
			},
		],
		"daily_rewards": [
			{
				"id": "daily_collect_base",
				"label": "Coleta diaria",
				"xp": 20,
				"claimed": true,
				"resources": {"energia": 80},
				"period_key": "2026-05-27",
			},
		],
		"battle_pass": {
			"pass": {"id": "bp_s1_01", "display_name": "Battle Pass Alpha"},
			"progress": {"pass_xp": 30, "premium_unlocked": true},
			"rewards": [
				{
					"id": "bp_alpha_1",
					"label": "Recompensa Alpha",
					"xp": 10,
					"claimed": false,
					"premium_required": true,
					"resources": {"ossos": 2},
					"period_key": "s1",
				},
			],
		},
	}
