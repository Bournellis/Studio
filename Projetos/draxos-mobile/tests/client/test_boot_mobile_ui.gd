extends GutTest

const BootScreenScript = preload("res://modes/boot/boot.gd")
const AppShellRouteContractScript = preload("res://modes/boot/ui/app_shell_route_contract.gd")
const AppShellActionContractScript = preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellActionRouterScript = preload("res://modes/boot/ui/app_shell_action_router.gd")
const AppShellErrorContractScript = preload("res://modes/boot/ui/app_shell_error_contract.gd")
const OperationStateScript = preload("res://modes/boot/ui/operation_state.gd")
const BaseSurfacePresenterScript = preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const BattleReplayPresenterScript = preload("res://modes/boot/surfaces/battle_replay_presenter.gd")
const HubSurfacePresenterScript = preload("res://modes/boot/surfaces/hub_surface_presenter.gd")
const ProgressionClarityPresenterScript = preload("res://modes/boot/surfaces/progression_clarity_presenter.gd")
const PreparationActionContractScript = preload("res://modes/boot/flows/preparation_action_contract.gd")
const SurfaceActionFlowScript = preload("res://modes/boot/flows/surface_action_flow.gd")
const ModeShellLauncherScript = preload("res://modes/boot/ui/mode_shell_launcher.gd")
const MobileUiContractScript = preload("res://modes/boot/ui/mobile_ui_contract.gd")
const TouchScrollContainerScript = preload("res://modes/boot/ui/touch_scroll_container.gd")

class SurfaceRefreshHost:
	extends Node

	var begin_calls: Array[Dictionary] = []
	var notices: PackedStringArray = PackedStringArray()
	var render_calls := 0

	func _render_base_state() -> void:
		render_calls += 1

	func _begin_surface_refresh(surface: String, endpoint: String, message: String, rendered_from_cache: bool = false) -> Dictionary:
		begin_calls.append({
			"surface": surface,
			"endpoint": endpoint,
			"message": message,
			"rendered_from_cache": rendered_from_cache,
		})
		return {"session_version": 1}

	func _show_notice(message: String) -> void:
		notices.append(message)

func before_each() -> void:
	ProjectSettings.set_setting("draxos_mobile/testing/disable_telemetry", true)
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/arena_dev_fixtures_enabled", false)
	_reset_session_store_for_test()

func after_each() -> void:
	ProjectSettings.set_setting("draxos_mobile/ui/force_compact_layout", false)
	ProjectSettings.set_setting("draxos_mobile/testing/disable_telemetry", false)
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/arena_dev_fixtures_enabled", false)
	_reset_session_store_for_test()
	await wait_process_frames(2)

func test_boot_compact_layout_groups_actions_for_mobile() -> void:
	ProjectSettings.set_setting("draxos_mobile/ui/force_compact_layout", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_true(boot._compact_layout)
	assert_eq(boot._action_button_columns(), 1)
	assert_eq(boot._base_map_columns(), 1)
	assert_true(boot._nav_buttons.is_empty())
	assert_true(boot._back_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_true(boot._content_scroll is TouchScrollContainerScript)
	assert_not_null(boot._first_screen_root)
	assert_true(boot._first_screen_root.visible)
	assert_false(boot._app_chrome_root.visible)
	assert_true(_label_tree_contains(boot._first_screen_root, "Escolha seu save"))
	assert_false(_label_tree_contains(boot._content_body, "Escolha seu save"))
	assert_not_null(_find_node_by_name(boot._first_screen_root, "EntrySceneBackground"))
	assert_null(_find_node_by_name(boot._first_screen_root, "EntryHeroPanel"))
	var sign_in_button := _find_button_by_text(boot._first_screen_root, "Entrar")
	assert_not_null(sign_in_button)
	assert_true(sign_in_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_null(_find_button_by_text(boot._first_screen_root, "Entrar no Refugio"))
	assert_false(_has_direct_button_child(boot._first_screen_root))

	boot._show_screen("account")
	assert_false(boot._first_screen_root.visible)
	assert_true(boot._app_chrome_root.visible)
	var action_grid := _first_action_grid(boot._content_body)
	assert_not_null(action_grid)
	assert_eq(action_grid.columns, boot._action_button_columns())
	var reset_button := boot._action_buttons["reset_session"] as Button
	assert_true(reset_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_eq(reset_button.mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_null(boot._auth_email_input)
	assert_false(_has_direct_button_child(boot._content_body))
	assert_not_null(boot._confirm_dialog)

func test_boot_route_stack_normalizes_legacy_screen_ids() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_eq(boot._current_screen, "entry")
	assert_false(boot._route_supports_back("hub"))
	assert_true(boot._route_supports_back("battle"))
	assert_eq(boot._normalize_route("hub"), "entry")
	assert_eq(boot._normalize_route("refuge_home"), "entry")
	assert_eq(boot._normalize_route("refugio"), "refuge")
	assert_eq(boot._normalize_route("refuge"), "refuge")
	assert_eq(boot._normalize_route("base"), "base_management")
	assert_eq(boot._normalize_route("conta"), "account")
	assert_eq(boot._normalize_route("perfil"), "account")
	assert_eq(boot._normalize_route("profile"), "account")
	assert_eq(boot._normalize_route("monetization"), "shop")
	assert_eq(boot._normalize_route("modes_ops"), "entry")
	assert_false(boot._route_supports_back("modes_ops"))

	boot._show_screen("modes_ops")
	assert_eq(boot._current_screen, "entry")
	assert_true(boot._screen_history.is_empty())

	boot._show_screen("battle")
	assert_eq(boot._current_screen, "battle_entry")
	assert_eq(boot._screen_history.size(), 1)
	assert_eq(boot._screen_history[0], "entry")
	assert_eq(boot._screen_title("battle"), "Batalha")

	boot._go_back()
	assert_eq(boot._current_screen, "entry")
	assert_true(boot._screen_history.is_empty())

func test_app_shell_route_contract_manages_back_stack_without_boot_ui() -> void:
	var history: Array[String] = []
	var current := AppShellRouteContractScript.ROUTE_ENTRY

	current = AppShellRouteContractScript.push_route(history, current, "base", true)
	assert_eq(current, "base_management")
	assert_eq(history, ["entry"])

	current = AppShellRouteContractScript.push_route(history, current, "social", true)
	assert_eq(current, "social")
	assert_eq(history, ["entry", "base_management"])

	current = AppShellRouteContractScript.pop_back_or_root(history)
	assert_eq(current, "base_management")
	assert_eq(history, ["entry"])

	current = AppShellRouteContractScript.pop_back_or_root(history)
	assert_eq(current, "entry")
	assert_true(history.is_empty())
	assert_eq(AppShellRouteContractScript.clear_for_root_return(history), "entry")
	assert_eq(AppShellRouteContractScript.clear_for_refuge_return(history), "refuge")

func test_app_shell_error_contract_normalizes_known_errors_without_boot_ui() -> void:
	var nested := {
		"body": {
			"error": {
				"code": "INVALID_PRODUCT",
				"message": "Raw backend text.",
			},
		},
	}
	var error_payload := AppShellErrorContractScript.extract_error(nested)

	assert_eq(error_payload.get("code"), "INVALID_PRODUCT")
	var friendly_message := AppShellErrorContractScript.friendly_message(
		str(error_payload.get("code", "")),
		str(error_payload.get("message", ""))
	)
	assert_eq(
		friendly_message,
		"Produto nao encontrado no catalogo atual."
	)
	assert_true(AppShellErrorContractScript.is_network_error("NETWORK_UNAVAILABLE"))
	assert_false(AppShellErrorContractScript.is_network_error("INVALID_PRODUCT"))
	assert_false(
		AppShellErrorContractScript.friendly_message("NETWORK_UNAVAILABLE", "").contains("local"),
		"Published Web builds should not describe remote CORS/network failures as local Supabase outages."
	)
	assert_eq(
		AppShellErrorContractScript.friendly_message("UNKNOWN_CODE", "Raw backend text."),
		"UNKNOWN_CODE: Raw backend text."
	)

func test_app_shell_action_contract_centralizes_online_gates_without_boot_ui() -> void:
	var required_update := {"block_online": true}

	assert_true(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.ACTION_ENTER_GUEST, required_update, false))
	assert_true(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.ACTION_SHOW_SHOP, required_update, false))
	assert_true(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.shop_purchase_action("alpha_redeem_medium"), required_update, false))
	assert_false(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.ACTION_CHECK_UPDATE, required_update, false))
	assert_false(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.ACTION_RESET_SESSION, required_update, false))
	assert_false(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL, required_update, false))
	assert_false(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB, required_update, false))
	assert_false(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB, required_update, false))
	assert_false(AppShellActionContractScript.update_gate_blocks_action(AppShellActionContractScript.select_base_structure_action("nucleo_energia"), required_update, false))

	assert_true(AppShellActionContractScript.is_allowed_during_replay(AppShellActionContractScript.ACTION_SKIP_REPLAY))
	assert_false(AppShellActionContractScript.is_allowed_during_replay(AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE))
	assert_eq(AppShellActionContractScript.action_value(AppShellActionContractScript.upgrade_base_structure_action("altar_das_almas")), "altar_das_almas")
	var arena_start_action := AppShellActionContractScript.arena_start_action("arena_veu_curta")
	assert_eq(arena_start_action, "arena_start:arena_veu_curta")
	assert_true(AppShellActionContractScript.is_arena_start(arena_start_action))
	assert_eq(AppShellActionContractScript.action_value(arena_start_action), "arena_veu_curta")
	var arena_start_difficulty_action := AppShellActionContractScript.arena_start_action("arena_veu_curta", "s1_d02_iniciado")
	assert_eq(arena_start_difficulty_action, "arena_start:arena_veu_curta:s1_d02_iniciado")
	assert_eq(AppShellActionContractScript.action_value(arena_start_difficulty_action), "arena_veu_curta")
	assert_eq(AppShellActionContractScript.action_value_at(arena_start_difficulty_action, 2), "s1_d02_iniciado")
	var arena_route := AppShellActionRouterScript.route_action(arena_start_action, {"save_type": "normal"})
	assert_eq(arena_route.get("category"), AppShellActionRouterScript.CATEGORY_ARENA)
	assert_eq(arena_route.get("mutation_endpoint"), "arena/pve/start")
	assert_true(bool(arena_route.get("requires_idempotent_retry", false)))
	var arena_abandon_route := AppShellActionRouterScript.route_action(AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT, {"save_type": "normal"})
	assert_eq(arena_abandon_route.get("category"), AppShellActionRouterScript.CATEGORY_ARENA)
	assert_eq(arena_abandon_route.get("mutation_endpoint"), "arena/pve/abandon")
	assert_true(bool(arena_abandon_route.get("requires_idempotent_retry", false)))
	assert_eq(AppShellActionContractScript.action_payload("show_shop", "shop", "normal", true, false), {
		"action_id": "show_shop",
		"screen": "shop",
		"save_type": "normal",
		"has_account": true,
		"offline": false,
	})

func test_boot_back_stack_returns_nested_routes_to_refugio_root() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("base")
	boot._show_screen("social")

	assert_eq(boot._current_screen, "social")
	assert_eq(boot._screen_history, ["entry", "base_management"])

	boot._go_back()
	assert_eq(boot._current_screen, "base_management")
	assert_eq(boot._screen_history, ["entry"])

	boot._go_back()
	assert_eq(boot._current_screen, "entry")
	assert_true(boot._screen_history.is_empty())
	assert_false(boot._back_button.visible)

func test_surface_actions_opened_from_refuge_go_back_to_refuge() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("refuge", false)
	for route: String in ["social", "competition", "shop"]:
		boot._show_surface_screen(route)
		assert_eq(boot._current_screen, boot._normalize_route(route))
		assert_eq(boot._screen_history, ["refuge"])
		boot._go_back()
		assert_eq(boot._current_screen, "refuge")
		assert_true(boot._screen_history.is_empty())

func test_default_busy_does_not_freeze_scoped_menu_actions_or_back() -> void:
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("refuge", false)
	await get_tree().process_frame
	var shop_action := AppShellActionContractScript.ACTION_SHOW_SHOP
	boot._operation_state.begin_busy(OperationStateScript.DEFAULT_SCOPE, AppShellActionContractScript.ACTION_REFRESH_SESSION)
	boot._sync_buttons()
	assert_false(boot._action_scope_busy(shop_action))

	boot._show_surface_screen("shop")
	await get_tree().process_frame
	boot._operation_state.begin_busy(OperationStateScript.DEFAULT_SCOPE, AppShellActionContractScript.ACTION_REFRESH_SESSION)
	boot._sync_buttons()
	assert_false(boot._back_button.disabled)
	boot._go_back()
	assert_eq(boot._current_screen, "refuge")

func test_authenticated_back_from_internal_surfaces_returns_to_refuge_root() -> void:
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("refuge")
	assert_eq(boot._current_screen, "refuge")
	assert_eq(boot._screen_history, ["entry"])

	boot._go_back()
	assert_eq(boot._current_screen, "refuge")
	assert_true(boot._screen_history.is_empty())

	boot._show_screen("account", false)
	assert_eq(boot._current_screen, "account")
	assert_true(boot._screen_history.is_empty())
	boot._go_back()
	assert_eq(boot._current_screen, "refuge")
	assert_true(boot._screen_history.is_empty())

	boot._show_surface_screen("social")
	assert_eq(boot._current_screen, "social")
	assert_eq(boot._screen_history, ["refuge"])
	boot._go_back()
	assert_eq(boot._current_screen, "refuge")
	assert_true(boot._screen_history.is_empty())

func test_boot_shell_has_no_global_tab_navigation() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_true(boot._nav_buttons.is_empty())
	assert_true(boot._back_button.visible == false)
	assert_false(boot._app_chrome_root.visible)
	boot._show_screen("base")
	assert_eq(boot._current_screen, "base_management")
	assert_true(boot._app_chrome_root.visible)
	assert_false(boot._first_screen_root.visible)
	assert_true(boot._back_button.visible)
	assert_true(boot._nav_buttons.is_empty())

func test_boot_refugio_home_renders_clean_scene_hotspots_and_account_route() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_eq(boot._current_screen, "entry")
	assert_true(_label_tree_contains(boot._first_screen_root, "Escolha seu save"))
	assert_null(_find_button_by_text(boot._first_screen_root, "Entrar no Refugio"))
	assert_not_null(boot._auth_email_input)
	assert_not_null(boot._auth_password_input)
	assert_null(boot._auth_username_input)
	assert_null(boot._auth_invite_input)
	assert_false(boot._action_buttons.has("email_sign_up"))
	assert_true(boot._action_buttons.has("open_create_account"))
	assert_true(boot._action_buttons.has("email_sign_in"))

	boot._show_screen("refuge")
	assert_eq(boot._current_screen, "refuge")
	assert_not_null(boot._first_screen_root)
	assert_true(boot._first_screen_root.visible)
	assert_false(boot._app_chrome_root.visible)
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeAltarBackground"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeAltarViewSpace"))
	assert_not_null(_find_node_by_name(boot._first_screen_root, "RefugeSceneBoard"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeAltarStage"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeAltarGlow"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeAltarCore"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeLoopPanel"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeProgressionPanel"))
	assert_not_null(_find_node_by_name(boot._first_screen_root, "RefugeMenuPopup"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeHotspotPanel"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugePathGrid"))
	assert_false(_label_tree_contains(boot._first_screen_root, "Caminhos do Refugio"))
	assert_false(_label_tree_contains(boot._content_body, "Altar do Mago"))
	assert_false(_label_tree_contains(boot._first_screen_root, "ALTAR"))
	assert_false(_label_tree_contains(boot._first_screen_root, "Refugio do Mago"))
	var top_hud := _find_node_by_name(boot._first_screen_root, "RefugeTopHud")
	assert_not_null(top_hud)
	assert_true(_visible_text_tree(top_hud).contains("Level - | Almas"))
	assert_false(_visible_text_tree(top_hud).contains("Refugio"))
	assert_not_null(_find_node_by_name(boot._first_screen_root, "RefugeFooterPanel"))
	assert_null(boot._auth_email_input)
	assert_false(boot._action_buttons.has("email_sign_up"))

	assert_null(_find_button_by_text(boot._first_screen_root, "Base"))
	assert_false(boot._action_buttons.has("show_base"))
	assert_null(_find_button_by_text(boot._first_screen_root, "Atualizar Refugio"))

	for spec: Dictionary in [
		{"prefix": "AR", "title": "Arena PVE"},
		{"prefix": "BQ", "title": "Bosque"},
		{"prefix": "RF", "title": "Refugio"},
		{"prefix": "SO", "title": "Social"},
		{"prefix": "LJ", "title": "Loja"},
	]:
		var hotspot := _find_node_by_name(boot._first_screen_root, "RefugeIcon_%s" % str(spec.get("title", ""))) as Button
		assert_not_null(hotspot, "Refugio should expose icon '%s'." % str(spec.get("title", "")))
		if hotspot == null:
			continue
		assert_eq(str(hotspot.text), str(spec.get("title", "")))
		assert_false(str(hotspot.text).begins_with("%s\n" % str(spec.get("prefix", ""))))
		assert_true(hotspot.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Batalha"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Competicao"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Preparacao"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Modos"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Coletar"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Energia"))

	var arena_hotspot := _find_node_by_name(boot._first_screen_root, "RefugeIcon_Arena PVE") as Button
	arena_hotspot.pressed.emit()
	await get_tree().process_frame
	var menu_popup := boot._refuge_menu_popup as PopupPanel
	assert_not_null(menu_popup)
	assert_true(menu_popup.visible)
	assert_true(_label_tree_contains(menu_popup, "Arena PVE"))
	assert_not_null(_find_button_by_text(menu_popup, "Abrir Arena PVE"))
	assert_null(_find_button_by_text(menu_popup, "Preparacao"))
	boot._go_back()
	assert_false(menu_popup.visible)

	var bosque_hotspot := _find_node_by_name(boot._first_screen_root, "RefugeIcon_Bosque") as Button
	assert_not_null(bosque_hotspot)
	assert_true(boot._action_buttons.has(AppShellActionContractScript.open_mode_shell_action("openworld")))
	bosque_hotspot.pressed.emit()
	await get_tree().process_frame
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_eq(str(boot.get("_active_mode_id")), "openworld")
	boot._return_to_refuge()
	await get_tree().process_frame

	var account_hotspot := _find_node_by_name(boot._first_screen_root, "RefugeIcon_Perfil") as Button
	account_hotspot.pressed.emit()
	await get_tree().process_frame
	var open_profile_button := _find_button_by_text(boot._refuge_menu_popup as Node, "Abrir Perfil")
	assert_not_null(open_profile_button)
	open_profile_button.pressed.emit()
	assert_eq(boot._current_screen, "account")
	assert_true(boot._app_chrome_root.visible)
	assert_false(boot._first_screen_root.visible)
	assert_null(boot._auth_email_input)
	assert_true(boot._back_button.visible)

func test_entry_create_account_opens_popup_without_inline_signup_fields() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_not_null(boot._create_account_dialog)
	assert_not_null(boot._signup_email_input)
	assert_not_null(boot._signup_password_input)
	assert_not_null(boot._signup_username_input)
	assert_null(boot._auth_username_input)
	assert_null(boot._auth_invite_input)
	assert_false(boot._action_buttons.has("email_sign_up"))

	var create_button := _find_button_by_text(boot._first_screen_root, "Criar conta")
	assert_not_null(create_button)
	create_button.pressed.emit()
	await get_tree().process_frame

	assert_true(boot._create_account_dialog.visible)
	assert_true(boot._signup_password_input.secret)
	assert_eq(boot._signup_email_input.text, _social_input_text_for_test(boot._auth_email_input))

func test_entry_puts_login_before_save_choice_and_exposes_internal_dev_tools() -> void:
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	ProjectSettings.set_setting("draxos_mobile/progression_lab/enabled", true)
	ProjectSettings.set_setting("draxos_mobile/battle_lab/enabled", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	var body := _find_node_by_name(boot._first_screen_root, "EntryFirstScreenBody")
	assert_not_null(body)
	assert_true(_child_index_by_name(body, "EntryAccountPanel") < _child_index_by_name(body, "EntrySavePanel"))
	assert_true(_child_index_by_name(body, "EntrySavePanel") < _child_index_by_name(body, "EntryDevPanel"))
	assert_not_null(_find_node_by_name(boot._first_screen_root, "EntrySceneBackground"))
	assert_null(_find_node_by_name(boot._first_screen_root, "EntryHeroPanel"))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Normal"))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Lab"))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Entrar"))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Criar conta"))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Ferramentas internas"))
	assert_true(_label_tree_contains(boot._first_screen_root, "Labs Dev"))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Battle Lab"))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Progression Lab"))
	assert_null(_find_button_by_text(boot._first_screen_root, "Modes Ops"))
	assert_true(boot._action_buttons.has("open_battle_lab"))
	assert_true(boot._action_buttons.has("open_progression_lab"))
	assert_not_null(_find_node_by_name(boot._first_screen_root, "EntryResetPanel"))

func test_refuge_exposes_labs_after_login_surface() -> void:
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	ProjectSettings.set_setting("draxos_mobile/progression_lab/enabled", true)
	ProjectSettings.set_setting("draxos_mobile/battle_lab/enabled", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("refuge")
	await get_tree().process_frame

	var dev_hotspot := _find_node_by_name(boot._first_screen_root, "RefugeIcon_LabsDev") as Button
	assert_not_null(dev_hotspot)
	assert_true(dev_hotspot.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)

	dev_hotspot.pressed.emit()
	await get_tree().process_frame
	var menu_popup := boot._refuge_menu_popup as PopupPanel
	assert_not_null(menu_popup)
	assert_true(menu_popup.visible)
	assert_true(_label_tree_contains(menu_popup, "Labs Dev"))
	assert_not_null(_find_button_by_text(menu_popup, "Battle Lab"))
	assert_not_null(_find_button_by_text(menu_popup, "Progression Lab"))
	assert_null(_find_button_by_text(menu_popup, "Modes Ops"))
	assert_true(boot._action_buttons.has("open_battle_lab"))
	assert_true(boot._action_buttons.has("open_progression_lab"))

func test_refuge_context_cta_priority_uses_loaded_state() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	SessionStore.last_battle_log = _battle_log_fixture()
	var cta := HubSurfacePresenterScript._refuge_context_cta_data(boot)
	assert_eq(str(cta.get("action_id", "")), "show_latest_battle")
	assert_eq(str(cta.get("text", "")), "Ver recompensa")

	SessionStore.base_state = _base_state_fixture()
	SessionStore.mark_battle_result_seen()
	cta = HubSurfacePresenterScript._refuge_context_cta_data(boot)
	assert_eq(str(cta.get("action_id", "")), "upgrade_base_structure:nucleo_energia")
	assert_eq(str(cta.get("text", "")), "Evoluir")

	SessionStore.last_battle_log = {}
	SessionStore.last_battle_result_seen = false
	SessionStore.base_state = _base_state_fixture()
	cta = HubSurfacePresenterScript._refuge_context_cta_data(boot)
	assert_eq(str(cta.get("action_id", "")), "upgrade_base_structure:nucleo_energia")
	assert_eq(str(cta.get("text", "")), "Evoluir")

	var upgrade_only := _base_state_fixture()
	var structures := Array(upgrade_only.get("structures", []))
	for index in range(structures.size()):
		var structure := Dictionary(structures[index])
		structure["pending_collectable"] = 0
		structures[index] = structure
	upgrade_only["structures"] = structures
	SessionStore.base_state = upgrade_only
	cta = HubSurfacePresenterScript._refuge_context_cta_data(boot)
	assert_eq(str(cta.get("action_id", "")), "upgrade_base_structure:nucleo_energia")
	assert_eq(str(cta.get("text", "")), "Evoluir")

	SessionStore.base_state = {}
	cta = HubSurfacePresenterScript._refuge_context_cta_data(boot)
	assert_eq(str(cta.get("action_id", "")), "open_arena")
	assert_eq(str(cta.get("text", "")), "Arena PVE")

func test_arena_selection_renders_remote_arenas_as_data_driven_actions() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	assert_true(SessionStore.apply_arena_result({
		"ok": true,
		"_client": {"save_type": SessionStore.SAVE_TYPE_NORMAL},
		"body": {
			"ok": true,
			"schema_version": "pve_arena_state_v1",
			"arenas": [
				{
					"id": "arena_tutorial_cinzas",
					"display_name": "Tutorial: Cinzas Do Refugio",
					"duel_count": 1,
					"default_difficulty_id": "s1_d00_intro",
					"unlocked": true,
					"difficulties": [
						{
							"difficulty_id": "s1_d00_intro",
							"difficulty_tier": 0,
							"max_steps": 1,
							"recommended_level_min": 1,
							"recommended_level_max": 3,
							"recommended_power_min": 80,
							"recommended_power_max": 180,
							"unlocked": true,
						},
					],
				},
				{
					"id": "arena_cinzas_curta",
					"display_name": "Arena Curta Das Cinzas",
					"max_steps": 3,
					"default_difficulty_id": "s1_d00_intro",
					"unlocked": true,
					"difficulties": [
						{
							"difficulty_id": "s1_d00_intro",
							"difficulty_tier": 0,
							"max_steps": 3,
							"recommended_level_min": 3,
							"recommended_level_max": 4,
							"recommended_power_min": 160,
							"recommended_power_max": 260,
							"unlocked": true,
						},
						{
							"difficulty_id": "s1_d01_aprendiz",
							"difficulty_tier": 1,
							"max_steps": 3,
							"recommended_level_min": 5,
							"recommended_level_max": 6,
							"recommended_power_min": 280,
							"recommended_power_max": 470,
							"unlocked": true,
						},
					],
				},
				{
					"id": "arena_veu_curta",
					"display_name": "Arena Do Veu",
					"max_steps": 4,
					"default_difficulty_id": "s1_d02_iniciado",
					"unlocked": false,
					"locked_reason": "Conclua dificuldade 1.",
					"difficulties": [
						{
							"difficulty_id": "s1_d02_iniciado",
							"difficulty_tier": 2,
							"max_steps": 4,
							"recommended_level_min": 8,
							"recommended_level_max": 10,
							"recommended_power_min": 650,
							"recommended_power_max": 1300,
							"unlocked": false,
							"locked_reason": "Conclua dificuldade 1.",
						},
					],
				},
			],
			"active_attempt": null,
		},
	}))

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	await get_tree().process_frame

	var tutorial_action := AppShellActionContractScript.arena_start_action("arena_tutorial_cinzas", "s1_d00_intro")
	var early_action := AppShellActionContractScript.arena_start_action("arena_cinzas_curta", "s1_d00_intro")
	var early_apprentice_action := AppShellActionContractScript.arena_start_action("arena_cinzas_curta", "s1_d01_aprendiz")
	var locked_action := AppShellActionContractScript.arena_start_action("arena_veu_curta", "s1_d02_iniciado")
	assert_true(boot._action_buttons.has(tutorial_action))
	assert_true(boot._action_buttons.has(early_action))
	assert_true(boot._action_buttons.has(early_apprentice_action))
	assert_true(boot._action_buttons.has(locked_action))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_START_EARLY))
	assert_true(_label_tree_contains(boot._content_body, "Intro | 1 duelo | primeiro clear | recomendado acima"))
	assert_not_null(_find_button_by_text(boot._content_body, "Aprendiz | 3 duelos | primeiro clear"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaRecommendedCard"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaSeason1ProgressPanel"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaSeason1Group_arena_tutorial_cinzas"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaSeason1Group_arena_cinzas_curta"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaSeason1Group_arena_veu_curta"))
	var locked_button := boot._action_buttons[locked_action] as Button
	assert_not_null(locked_button)
	assert_true(locked_button.disabled)
	assert_string_contains(locked_button.text, "bloqueada")
	assert_false(locked_button.text.contains("Conclua dificuldade 1."))
	assert_eq(locked_button.tooltip_text, "Conclua dificuldade 1.")
	assert_true(_label_tree_contains(boot._content_body, "bloqueada: Conclua dificuldade 1."))
	assert_true(_label_tree_contains(boot._content_body, "Temporada 1"))
	assert_true(_label_tree_contains(boot._content_body, "Outras arenas"))
	assert_true(_label_tree_contains(boot._content_body, "Dificuldades"))
	assert_false(_visible_text_tree(boot._content_body).contains("Outras opcoes"))
	assert_false(_visible_text_tree(boot._content_body).contains("s1_d00_intro"))
	assert_false(_visible_text_tree(boot._content_body).contains("s1_d01_aprendiz"))
	boot._sync_buttons()
	assert_true(locked_button.disabled)

func test_arena_selection_keeps_fixed_buttons_only_for_dev_fallback() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.arena_state = {}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	await get_tree().process_frame

	assert_true(_label_tree_contains(boot._content_body, "Fallback dev local"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_START_EARLY))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.arena_start_action("arena_tutorial_cinzas")))

func test_arena_first_access_loading_state_suppresses_dev_fallback_actions() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.arena_state = {}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL))

	boot._arena_lifecycle_flow.render_loading_selection(boot)
	await get_tree().process_frame

	assert_true(_label_tree_contains(boot._content_body, "Sincronizando Arena PVE"))
	assert_true(_label_tree_contains(boot._content_body, "Nenhuma tentativa local sera iniciada antes da resposta remota."))
	assert_false(_visible_text_tree(boot._content_body).contains("Fallback dev local"))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_START_EARLY))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_RETURN_REFUGE))

func test_arena_selection_recommends_next_uncompleted_arena_after_tutorial() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	assert_true(SessionStore.apply_arena_result({
		"ok": true,
		"_client": {"save_type": SessionStore.SAVE_TYPE_NORMAL},
		"body": {
			"ok": true,
			"schema_version": "pve_arena_state_v1",
			"progress": {
				"tutorial_completed": true,
				"metadata": {
					"completed_tiers": {"arena_tutorial_cinzas:s1_d00_intro": true},
					"completed_arenas": {"arena_tutorial_cinzas": true},
				},
			},
			"arenas": [
				{
					"id": "arena_tutorial_cinzas",
					"display_name": "Tutorial: Cinzas Do Refugio",
					"duel_count": 1,
					"default_difficulty_id": "s1_d00_intro",
					"unlocked": true,
					"difficulties": [
						{"difficulty_id": "s1_d00_intro", "max_steps": 1, "recommended_level_min": 1, "recommended_level_max": 3, "reward_preview": {"xp": 81, "almas": 6}, "unlocked": true},
					],
				},
				{
					"id": "arena_cinzas_curta",
					"display_name": "Arena Curta Das Cinzas",
					"duel_count": 3,
					"default_difficulty_id": "s1_d00_intro",
					"unlocked": true,
					"difficulties": [
						{"difficulty_id": "s1_d00_intro", "max_steps": 3, "recommended_level_min": 3, "recommended_level_max": 4, "recommended_power_min": 160, "recommended_power_max": 260, "reward_preview": {"xp": 150, "almas": 9, "ossos": 18}, "unlocked": true},
						{"difficulty_id": "s1_d01_aprendiz", "max_steps": 3, "recommended_level_min": 5, "recommended_level_max": 6, "recommended_power_min": 240, "recommended_power_max": 320, "reward_preview": {"xp": 180, "almas": 11}, "unlocked": false, "locked_reason": "Conclua a dificuldade anterior."},
					],
				},
			],
		},
	}))

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	await get_tree().process_frame

	var next_action := AppShellActionContractScript.arena_start_action("arena_cinzas_curta", "s1_d00_intro")
	assert_true(boot._action_buttons.has(next_action))
	assert_not_null(_find_button_by_text(boot._content_body, "Iniciar desafio recomendado"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaPreparationPanel"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaSeason1ProgressPanel"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaSeason1Group_arena_cinzas_curta"))
	assert_null(_find_button_by_text(boot._content_body, "Iniciar proximo desta arena"))
	assert_not_null(_find_button_by_text(boot._content_body, "Carregar Preparacao"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaSeason1ProgressPanel") < _child_index_by_name(boot._content_body, "ArenaRecommendedCard"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaRecommendedCard") < _child_index_by_name(boot._content_body, "ArenaPreparationPanel"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaPreparationPanel") < _child_index_by_name(boot._content_body, "ArenaSeason1Group_arena_cinzas_curta"))
	assert_true(_label_tree_contains(boot._content_body, "Proximo desafio"))
	assert_true(_label_tree_contains(boot._content_body, "Temporada 1"))
	assert_true(_label_tree_contains(boot._content_body, "Progresso S1: 1/3 dificuldades concluidas | 2 liberadas"))
	assert_true(_label_tree_contains(boot._content_body, "Arena Curta Das Cinzas"))
	assert_true(_label_tree_contains(boot._content_body, "Recompensa prevista: 150 XP, 9 Almas, 18 Ossos"))
	assert_true(_label_tree_contains(boot._content_body, "bloqueada: Conclua a dificuldade anterior."))
	assert_false(_visible_text_tree(boot._content_body).contains("s1_d00_intro"))

func test_arena_selection_routes_active_attempt_before_new_start() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	var start_action := AppShellActionContractScript.arena_start_action("arena_cinzas_curta", "s1_d00_intro")
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"arenas": [
			{
				"id": "arena_cinzas_curta",
				"display_name": "Arena Curta Das Cinzas",
				"duel_count": 3,
				"unlocked": true,
				"difficulties": [{"difficulty_id": "s1_d00_intro", "max_steps": 3, "unlocked": true}],
			},
		],
		"active_attempt": {
			"attempt_id": "44444444-4444-4444-8444-444444444440",
			"arena_id": "arena_cinzas_curta",
			"status": "active",
			"current_step_index": 1,
			"duel_count": 3,
			"duels_won": 1,
			"locked_loadout_hash": "sha256:test",
		},
	}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	await get_tree().process_frame

	assert_not_null(_find_node_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_not_null(_find_button_by_text(boot._content_body, "Carregar comportamento"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaActiveAttemptPanel"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaActiveAttemptPanel") < _child_index_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_not_null(_find_button_by_text(boot._content_body, "Retomar tentativa"))
	assert_not_null(_find_button_by_text(boot._content_body, "Abandonar tentativa"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT))
	assert_false(boot._action_buttons.has(start_action))
	assert_true(_label_tree_contains(boot._content_body, "Tentativa ativa encontrada"))
	assert_true(_label_tree_contains(boot._content_body, "duelos vencidos 1/3"))

func test_arena_selection_exposes_update_recovery_for_stuck_attempt() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	var start_action := AppShellActionContractScript.arena_start_action("arena_cinzas_curta", "s1_d00_intro")
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"arenas": [
			{
				"id": "arena_cinzas_curta",
				"display_name": "Arena Curta Das Cinzas",
				"duel_count": 3,
				"unlocked": true,
				"difficulties": [{"difficulty_id": "s1_d00_intro", "max_steps": 3, "unlocked": true}],
			},
		],
		"active_attempt": {
			"attempt_id": "attempt-stuck",
			"arena_id": "arena_cinzas_curta",
			"status": "active",
			"current_step_index": 3,
			"duel_count": 3,
			"duels_won": 3,
			"locked_loadout_hash": "sha256:test",
			"buff_offer": {},
		},
	}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	await get_tree().process_frame

	assert_not_null(_find_node_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_not_null(_find_button_by_text(boot._content_body, "Carregar comportamento"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaAttemptRecoveryPanel"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaAttemptRecoveryPanel") < _child_index_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_not_null(_find_button_by_text(boot._content_body, "Encerrar tentativa antiga"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL))
	assert_false(boot._action_buttons.has(start_action))
	assert_true(_label_tree_contains(boot._content_body, "ficou aberta antes do update"))
	assert_true(_label_tree_contains(boot._content_body, "duelos vencidos 3/3"))

func test_arena_active_exposes_behavior_adjustment_without_unlocking_loadout() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"arenas": [],
		"active_attempt": {
			"attempt_id": "44444444-4444-4444-8444-444444444441",
			"arena_id": "arena_cinzas_curta",
			"status": "active",
			"duel_index": 0,
			"duel_count": 3,
			"duels_won": 0,
			"locked_loadout_hash": "sha256:test",
			"loadout_summary": {"label": "Varinha de Cinzas, 1 habilidade, Pocao de Vida"},
			"next_enemy": {"display_name": "Aprendiz das Cinzas"},
			"temporary_buffs": [],
		},
	}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_ACTIVE)
	await get_tree().process_frame

	assert_not_null(_find_button_by_text(boot._content_body, "Resolver duelo"))
	assert_not_null(_find_button_by_text(boot._content_body, "Abandonar tentativa"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_SHOW_PREPARATION))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_not_null(_find_button_by_text(boot._content_body, "Carregar comportamento"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaActivePreparationPanel") > _child_index_by_name(boot._content_body, "ArenaAttemptSummaryPanel"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaActivePreparationPanel") < _child_index_by_name(boot._content_body, "ArenaLoadoutDetailsPanel"))
	assert_true(_button_text_index(boot._content_body, "Resolver duelo") < _button_text_index(boot._content_body, "Carregar comportamento"))
	assert_null(_find_button_by_text(boot._content_body, "Ajustar comportamento"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaDuelProgressRail"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaDuelProgressRailSteps"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaDuelProgressStep1"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaAttemptSummaryPanel"))
	assert_true(_label_tree_contains(boot._content_body, "Progresso dos duelos"))
	assert_false(_visible_text_tree(boot._content_body).contains("[1 agora] -> [2 espera] -> [3 espera]"))
	assert_true(_label_tree_contains(boot._content_body, "Duelo atual: 1/3"))
	assert_true(_label_tree_contains(boot._content_body, "Proximo inimigo: Aprendiz das Cinzas"))
	assert_true(_label_tree_contains(boot._content_body, "Resumo: Varinha de Cinzas, 1 habilidade, Pocao de Vida"))
	assert_true(_label_tree_contains(boot._content_body, "Comportamento: ajustavel entre duelos"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaLoadoutDetailsPanel"))
	var details_button := _find_button_by_text(boot._content_body, "Mostrar detalhes do loadout")
	assert_not_null(details_button)
	assert_false(_visible_text_tree(boot._content_body).contains("Detalhes somente leitura"))
	details_button.pressed.emit()
	await get_tree().process_frame
	assert_true(_visible_text_tree(boot._content_body).contains("Detalhes somente leitura"))
	assert_false(_visible_text_tree(boot._content_body).contains("Hash:"))
	assert_false(_visible_text_tree(boot._content_body).contains("sha256"))
	assert_not_null(_find_button_by_text(boot._content_body, "Ocultar detalhes do loadout"))

	assert_true(_apply_preparation_instrument_fixture("varinha_cinzas"))
	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, false)
	await get_tree().process_frame

	assert_not_null(_find_node_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_true(_label_tree_contains(boot._content_body, "Comportamento da tentativa"))
	assert_true(_label_tree_contains(boot._content_body, "Loadout travado para esta tentativa."))
	assert_null(_find_button_by_text(boot._content_body, "Ajustar comportamento"))
	assert_null(_find_button_by_text(boot._content_body, "Equipar Pocao de Vida"))
	assert_null(_find_button_by_text(boot._content_body, "Remover pocao"))
	assert_null(_find_button_by_text(boot._content_body, "Remover"))
	assert_not_null(_find_button_by_text(boot._content_body, "Usar comportamento padrao"))
	assert_not_null(_find_button_by_text(boot._content_body, "Pausar pocao"))

func test_arena_buff_choice_renders_comparable_cards_with_existing_actions() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"arenas": [],
		"active_attempt": {
			"attempt_id": "44444444-4444-4444-8444-444444444442",
			"arena_id": "arena_cinzas_curta",
			"status": "awaiting_buff",
			"duel_index": 1,
			"duel_count": 3,
			"duels_won": 1,
			"locked_loadout_hash": "sha256:test",
			"buff_offer": {
				"choices": [
					{
						"id": "arena_buff_vitalidade_menor",
						"label": "Vitalidade Menor",
						"stat_modifiers": [
							{"stat": "max_hp", "operation": "add_percent", "value": 4},
						],
					},
					{"id": "arena_buff_potencia_menor", "display_name": "Potencia Ritual Menor", "description": "+4% Potencia Ritual"},
					{"id": "arena_buff_guarda_menor", "display_name": "Guarda Menor", "description": "+4% Guarda"},
				],
			},
		},
	}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_BUFF_CHOICE)
	await get_tree().process_frame

	assert_not_null(_find_node_by_name(boot._content_body, "ArenaBuffChoiceCards"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaBuffChoiceCard1"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaBuffChoiceCard2"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaBuffChoiceCard3"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_not_null(_find_button_by_text(boot._content_body, "Carregar comportamento"))
	assert_true(_child_index_by_name(boot._content_body, "ArenaBuffChoiceCards") < _child_index_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_true(_label_tree_contains(boot._content_body, "Escolha um buff temporario"))
	assert_true(_label_tree_contains(boot._content_body, "Vitalidade Menor"))
	assert_true(_label_tree_contains(boot._content_body, "+4% HP maximo"))
	assert_true(_label_tree_contains(boot._content_body, "Temporario: dura ate encerrar esta tentativa."))
	assert_false(_visible_text_tree(boot._content_body).contains("Escolhas disponiveis"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.arena_choose_buff_action("arena_buff_vitalidade_menor")))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.arena_choose_buff_action("arena_buff_potencia_menor")))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.arena_choose_buff_action("arena_buff_guarda_menor")))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT))
	assert_not_null(_find_button_by_text(boot._content_body, "Abandonar tentativa"))

func test_arena_active_pending_buff_opens_choice_without_autoselecting_first_buff() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"arenas": [],
		"active_attempt": {
			"attempt_id": "44444444-4444-4444-8444-444444444443",
			"arena_id": "arena_cinzas_curta",
			"state": "awaiting_buff",
			"duel_index": 1,
			"duel_count": 3,
			"duels_won": 1,
			"locked_loadout_hash": "sha256:test",
			"buff_offer": {
				"step_index": 1,
				"choices": [
					{"id": "arena_buff_vitalidade_menor", "display_name": "Vitalidade Menor"},
					{"id": "arena_buff_potencia_menor", "display_name": "Potencia Ritual Menor"},
				],
			},
		},
	}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_ACTIVE)
	await get_tree().process_frame

	assert_not_null(_find_button_by_text(boot._content_body, "Escolher buff"))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaActivePreparationPanel"))
	assert_true(_button_text_index(boot._content_body, "Escolher buff") < _button_text_index(boot._content_body, "Carregar comportamento"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.arena_choose_buff_action("arena_buff_vitalidade_menor")))

func test_arena_active_after_selected_buff_returns_to_resolve_duel() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	var selected_buff := {
		"id": "arena_buff_vitalidade_menor",
		"label": "Vitalidade Menor",
		"stat_modifiers": [
			{"stat": "max_hp", "operation": "add_percent", "value": 4},
		],
	}
	assert_true(SessionStore.apply_arena_result({
		"ok": true,
		"_client": {"save_type": SessionStore.SAVE_TYPE_NORMAL},
		"body": {
			"ok": true,
			"schema_version": "arena_buff_select_response_v1",
			"attempt": {
				"id": "44444444-4444-4444-8444-444444444444",
				"arena_id": "arena_cinzas_curta",
				"status": "active",
				"max_steps": 3,
				"current_step_index": 1,
				"enemy_sequence": ["pve_aprendiz_cinzas", "pve_guardiao_barreira", "pve_sussurrador_veu"],
				"active_buffs": [selected_buff],
				"locked_loadout_hash": "sha256:test",
			},
			"step": {
				"step_index": 1,
				"buff_options": [
					selected_buff,
					{"id": "arena_buff_potencia_menor", "display_name": "Potencia Ritual Menor"},
					{"id": "arena_buff_guarda_menor", "display_name": "Guarda Menor"},
				],
				"selected_buff": selected_buff,
			},
			"selected_buff": selected_buff,
		},
	}))

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_ACTIVE)
	await get_tree().process_frame

	assert_not_null(_find_button_by_text(boot._content_body, "Resolver duelo"))
	assert_null(_find_button_by_text(boot._content_body, "Escolher buff"))
	assert_true(_label_tree_contains(boot._content_body, "Buffs ativos: Vitalidade Menor (+4% HP maximo)"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.arena_choose_buff_action("arena_buff_vitalidade_menor")))

func test_arena_summary_continues_to_arena_instead_of_reward_claim_copy() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"progress": {
			"tutorial_completed": true,
			"metadata": {
				"completed_tiers": {"arena_tutorial_cinzas:s1_d00_intro": true},
				"completed_arenas": {"arena_tutorial_cinzas": true},
			},
		},
		"arenas": [
			{
				"id": "arena_cinzas_curta",
				"display_name": "Arena Curta Das Cinzas",
				"duel_count": 3,
				"unlocked": true,
				"difficulties": [
					{"difficulty_id": "s1_d00_intro", "max_steps": 3, "recommended_level_min": 3, "recommended_level_max": 4, "recommended_power_min": 160, "recommended_power_max": 260, "reward_preview": {"xp": 150, "almas": 9}, "unlocked": true},
				],
			},
		],
		"active_attempt": {
			"attempt_id": "attempt-summary",
			"arena_id": "arena_tutorial_cinzas",
			"difficulty_id": "s1_d00_intro",
			"status": "completed",
			"duel_count": 1,
			"duels_won": 1,
			"locked_loadout_hash": "sha256:test",
		},
		"summary": {
			"status": "completed",
			"duels_won": 1,
			"duels_total": 1,
			"reward_label": "COMPLETION_REWARD_APPLIED_ON_DUEL_CLEAR",
		},
	}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SUMMARY)
	await get_tree().process_frame

	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY))
	assert_not_null(_find_button_by_text(boot._content_body, "Continuar na Arena"))
	assert_null(_find_button_by_text(boot._content_body, "Confirmar resumo"))
	assert_true(_label_tree_contains(boot._content_body, "recompensa ja foi aplicada pelo ultimo duelo"))
	assert_true(_label_tree_contains(boot._content_body, "Recompensa: COMPLETION_REWARD_APPLIED_ON_DUEL_CLEAR"))
	assert_true(_label_tree_contains(boot._content_body, "Proximo passo: veja a recomendacao da Temporada 1 antes de continuar."))
	assert_not_null(_find_node_by_name(boot._content_body, "ArenaSeason1NextStepPanel"))
	assert_true(_label_tree_contains(boot._content_body, "Proximo passo S1"))
	assert_true(_label_tree_contains(boot._content_body, "Continuar na Arena confirma o resumo e abre a lista atualizada de desafios."))

func test_boot_refugio_home_shows_progression_lab_when_dev_tools_are_enabled() -> void:
	ProjectSettings.set_setting("draxos_mobile/progression_lab/enabled", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	if boot._progression_lab_available():
		assert_true(_label_tree_contains(boot._first_screen_root, "Labs Dev"))
		assert_not_null(_find_button_by_text(boot._first_screen_root, "Progression Lab"))
		assert_true(boot._action_buttons.has("open_progression_lab"))

func test_boot_battle_running_route_stays_portrait() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_false(boot._route_prefers_landscape("battle_entry"))
	assert_false(boot._route_prefers_landscape("battle_running"))
	assert_false(boot._route_prefers_landscape("refuge_home"))
	assert_false(AppShellRouteContractScript.prefers_landscape("battle"))
	assert_false(AppShellRouteContractScript.prefers_landscape("battle_running"))
	assert_false(AppShellRouteContractScript.prefers_landscape("battle_summary"))
	assert_true(AppShellRouteContractScript.prefers_portrait("battle_running"))

func test_app_shell_route_contract_declares_battle_gameplay_mode() -> void:
	assert_true(AppShellRouteContractScript.is_battle_mode("battle"))
	assert_true(AppShellRouteContractScript.is_battle_mode("battle_running"))
	assert_true(AppShellRouteContractScript.is_battle_mode("battle_summary"))
	assert_true(AppShellRouteContractScript.is_battle_mode("battle_logs"))
	assert_false(AppShellRouteContractScript.is_battle_mode("base"))
	assert_true(AppShellRouteContractScript.is_first_screen("entry"))
	assert_false(AppShellRouteContractScript.is_first_screen("refugio"))
	assert_true(AppShellRouteContractScript.is_refuge_home("refugio"))
	assert_true(AppShellRouteContractScript.uses_immersive_layer("refuge"))
	assert_false(AppShellRouteContractScript.is_fullscreen_gameplay("battle"))
	assert_true(AppShellRouteContractScript.is_fullscreen_gameplay("battle_running"))
	assert_true(AppShellRouteContractScript.is_fullscreen_gameplay("battle_summary"))
	assert_true(AppShellRouteContractScript.is_fullscreen_gameplay("battle_logs"))
	assert_false(AppShellRouteContractScript.shows_app_chrome("refuge_home"))
	assert_true(AppShellRouteContractScript.shows_app_chrome("battle"))
	assert_false(AppShellRouteContractScript.shows_app_chrome("battle_running"))
	assert_false(AppShellRouteContractScript.shows_app_chrome("battle_summary"))
	assert_false(AppShellRouteContractScript.shows_app_chrome("battle_logs"))
	assert_eq(AppShellRouteContractScript.summary_route_for("battle_running"), "battle_summary")
	assert_eq(AppShellRouteContractScript.summary_route_for("battle_logs"), "battle_summary")
	assert_eq(AppShellRouteContractScript.summary_route_for("battle"), "battle_summary")
	assert_eq(AppShellRouteContractScript.summary_route_for("base"), "base_management")
	assert_true(AppShellRouteContractScript.is_safe_replay_action("skip_battle_replay"))
	assert_false(AppShellRouteContractScript.is_safe_replay_action("show_latest_battle"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("show_battle_history"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("battle_replay:11111111-1111-4111-8111-111111111111"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("replay_latest_battle"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("show_current_battle_logs"))
	assert_false(AppShellRouteContractScript.is_read_only_battle_action("request_battle"))

func test_internal_app_screen_layout_uses_portrait_single_column() -> void:
	assert_eq(BootScreenScript.surface_columns_for_size(Vector2(540, 960), 2), 1)
	assert_eq(BootScreenScript.surface_columns_for_size(Vector2(1180, 720), 2), 1)
	assert_eq(BootScreenScript.action_button_columns_for_size(Vector2(540, 960), true), 1)
	assert_eq(BootScreenScript.action_button_columns_for_size(Vector2(1180, 720), true), 1)

	var portrait_contract := MobileUiContractScript.layout_summary_for_size(Vector2(540, 960), true)
	assert_eq(str(portrait_contract.get("orientation", "")), "portrait")
	assert_eq(int(portrait_contract.get("surface_columns", 0)), 1)
	assert_eq(int(portrait_contract.get("action_button_columns", 0)), 1)
	assert_eq(int(portrait_contract.get("base_map_columns", 0)), 1)

	var landscape_contract := MobileUiContractScript.layout_summary_for_size(Vector2(1180, 720), true)
	assert_eq(str(landscape_contract.get("orientation", "")), "portrait")
	assert_eq(int(landscape_contract.get("surface_columns", 0)), 1)
	assert_eq(int(landscape_contract.get("action_button_columns", 0)), 1)
	assert_eq(int(landscape_contract.get("base_map_columns", 0)), 1)

	var button := Button.new()
	button.custom_minimum_size = Vector2(24, 12)
	MobileUiContractScript.apply_touch_button(button)
	assert_eq(button.mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_eq(button.focus_mode, Control.FOCUS_NONE)
	assert_true(button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	button.free()

func test_app_surfaces_open_as_internal_routes_with_back_and_touch_scroll() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	for route: String in ["base", "social", "competition", "shop"]:
		boot._show_screen(route)
		assert_eq(boot._current_screen, boot._normalize_route(route))
		assert_true(boot._back_button.visible)
		assert_true(boot._content_scroll is TouchScrollContainerScript)
		assert_true(boot._nav_buttons.is_empty())
		assert_eq(boot._screen_history.back(), "entry")
		boot._go_back()
		assert_eq(boot._current_screen, "entry")
		assert_true(boot._screen_history.is_empty())

func test_touch_scroll_container_uses_drag_threshold_and_wide_scrollbar() -> void:
	var scroll: DraxosTouchScrollContainer = TouchScrollContainerScript.new()
	scroll.custom_minimum_size = Vector2(240, 160)
	add_child_autofree(scroll)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(scroll.drag_threshold, MobileUiContractScript.TOUCH_DRAG_THRESHOLD)
	assert_eq(scroll.mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_eq(scroll.vertical_scroll_mode, ScrollContainer.SCROLL_MODE_SHOW_ALWAYS)
	assert_eq(scroll.horizontal_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED)

	var touch_press := InputEventScreenTouch.new()
	touch_press.pressed = true
	touch_press.position = Vector2(20, 20)
	scroll._gui_input(touch_press)

	var small_drag := InputEventScreenDrag.new()
	small_drag.relative = Vector2(0, 4)
	scroll._gui_input(small_drag)
	assert_false(scroll.is_touch_dragging_for_test())

	var large_drag := InputEventScreenDrag.new()
	large_drag.relative = Vector2(0, 24)
	scroll._gui_input(large_drag)
	assert_true(scroll.is_touch_dragging_for_test())
	assert_true(scroll.get_v_scroll_bar().custom_minimum_size.x >= MobileUiContractScript.TOUCH_SCROLLBAR_WIDTH)

func test_touch_scroll_container_releases_mouse_drag_from_global_release() -> void:
	var scroll: DraxosTouchScrollContainer = TouchScrollContainerScript.new()
	add_child_autofree(scroll)
	await get_tree().process_frame

	var mouse_press := InputEventMouseButton.new()
	mouse_press.button_index = MOUSE_BUTTON_LEFT
	mouse_press.pressed = true
	mouse_press.position = Vector2(24, 24)
	scroll._gui_input(mouse_press)
	assert_true(scroll.is_touch_pressing_for_test())

	var mouse_release := InputEventMouseButton.new()
	mouse_release.button_index = MOUSE_BUTTON_LEFT
	mouse_release.pressed = false
	mouse_release.position = Vector2(900, 900)
	scroll._input(mouse_release)
	assert_false(scroll.is_touch_pressing_for_test())
	assert_false(scroll.is_touch_dragging_for_test())

func test_touch_scroll_container_clears_stale_mouse_drag_on_motion_without_button() -> void:
	var scroll: DraxosTouchScrollContainer = TouchScrollContainerScript.new()
	add_child_autofree(scroll)
	await get_tree().process_frame

	var mouse_press := InputEventMouseButton.new()
	mouse_press.button_index = MOUSE_BUTTON_LEFT
	mouse_press.pressed = true
	mouse_press.position = Vector2(24, 24)
	scroll._gui_input(mouse_press)
	assert_true(scroll.is_touch_pressing_for_test())

	var stale_motion := InputEventMouseMotion.new()
	stale_motion.position = Vector2(24, 90)
	scroll._gui_input(stale_motion)
	assert_false(scroll.is_touch_pressing_for_test())
	assert_false(scroll.is_touch_dragging_for_test())

func test_boot_account_panel_renders_profile_settings_without_login_form() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	boot._show_screen("account")

	assert_null(boot._auth_email_input)
	assert_null(boot._auth_password_input)
	assert_null(boot._auth_username_input)
	assert_null(boot._auth_invite_input)
	assert_not_null(boot._update_output_label)
	assert_string_contains(boot._update_output_label.text, "Canal:")
	assert_false(boot._action_buttons.has("email_sign_up"))
	assert_false(boot._action_buttons.has("email_sign_in"))
	assert_false(boot._action_buttons.has("select_save_normal"))
	assert_false(boot._action_buttons.has("select_save_progression_lab"))
	assert_true(boot._action_buttons.has("check_update"))
	assert_true(boot._action_buttons.has("refresh_session"))
	assert_true(boot._action_buttons.has("reset_session"))

func test_boot_profile_account_panel_shows_save_account_update_and_build_status() -> void:
	_prepare_account_state()
	SessionStore.auth_method = "email"
	SessionStore.auth_email = "alpha@example.com"
	SessionStore.account_username = "alpha_tester"
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	boot._update_gate = ProjectInfo.update_status_from_manifest(_current_manifest_fixture(), "https://manifest.example")
	boot._show_screen("account", false)
	await get_tree().process_frame

	assert_true(_label_tree_contains(boot._content_body, "Perfil e conta"))
	assert_true(_label_tree_contains(boot._content_body, "Username: tester"))
	assert_true(_label_tree_contains(boot._content_body, "Conta: alpha_tester"))
	assert_true(_label_tree_contains(boot._content_body, "Save ativo: Normal (normal)"))
	assert_true(_label_tree_contains(boot._content_body, "Nivel: 8"))
	assert_true(_label_tree_contains(boot._content_body, "Poder: 120"))
	assert_true(_label_tree_contains(boot._content_body, "Auth: email/senha (alpha@example.com)"))
	assert_true(_label_tree_contains(boot._content_body, "Estado: carregado do save ativo"))
	assert_true(_label_tree_contains(boot._content_body, "Update: Build atualizada"))
	assert_true(_label_tree_contains(boot._content_body, "Build: internal_alpha %s | online pronto" % ProjectInfo.APP_VERSION))
	assert_null(boot._auth_email_input)

func test_boot_profile_account_panel_has_clear_empty_state_without_account() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	boot._show_screen("account")

	assert_true(_label_tree_contains(boot._content_body, "Username: sem conta carregada"))
	assert_true(_label_tree_contains(boot._content_body, "Estado: sem sessao auth"))
	assert_true(_label_tree_contains(boot._content_body, "Build: internal_alpha %s | aguardando login" % ProjectInfo.APP_VERSION))
	assert_null(boot._auth_email_input)

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
	assert_false(boot._action_buttons.has("collect_base"))
	assert_not_null(boot._base_state_container)
	await get_tree().process_frame

	boot._show_screen("social")
	assert_true(boot._action_buttons.has("show_social"))
	assert_true(boot._action_buttons.has("copy_social_username"))
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

func test_cached_surface_refresh_renders_local_shell_without_cache_flag() -> void:
	var flow = SurfaceActionFlowScript.new()
	var host = SurfaceRefreshHost.new()
	add_child_autofree(host)

	var token: Dictionary = flow._begin_cached_refresh(host, SessionStore.SURFACE_BASE, "base/state", "Buscando Refugio...", "_render_base_state")

	assert_eq(int(host.render_calls), 1)
	assert_eq(host.begin_calls.size(), 1)
	assert_eq(str(token.get("session_version", "")), "1")
	assert_false(bool(host.begin_calls[0].get("rendered_from_cache", true)))
	assert_eq(host.notices.size(), 1)
	assert_eq(str(host.notices[0]), "Superficie local visivel. Sincronizando com o servidor...")

func test_boot_surface_refresh_ignores_stale_completion_and_keeps_current_busy() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	var stale_token: Dictionary = boot._begin_surface_refresh(SessionStore.SURFACE_BATTLE, "battle/latest", "Buscando resultado...", false)
	var current_token: Dictionary = boot._begin_surface_refresh(SessionStore.SURFACE_BATTLE, "battle/latest", "Buscando resultado novo...", false)
	assert_false(boot._surface_refresh_current(SessionStore.SURFACE_BATTLE, stale_token))
	assert_true(boot._surface_refresh_current(SessionStore.SURFACE_BATTLE, current_token))

	var old_result := {
		"ok": true,
		"_client": {"endpoint": "battle/latest", "method": "GET", "duration_ms": 900, "response_code": 200},
	}
	assert_false(boot._finish_surface_refresh(SessionStore.SURFACE_BATTLE, stale_token, old_result, "Resultado antigo."))
	assert_true(boot._operation_state.is_busy(boot._surface_scope_id(SessionStore.SURFACE_BATTLE)))
	assert_true(bool(SessionStore.surface_refresh_snapshot(SessionStore.SURFACE_BATTLE).get("refreshing", false)))
	assert_false(SessionStore.has_battle_log())

	var current_result := {
		"ok": true,
		"_client": {"endpoint": "battle/latest", "method": "GET", "duration_ms": 40, "response_code": 200},
	}
	assert_true(boot._finish_surface_refresh(SessionStore.SURFACE_BATTLE, current_token, current_result, "Resultado atual."))
	assert_false(boot._operation_state.is_busy(boot._surface_scope_id(SessionStore.SURFACE_BATTLE)))
	assert_false(bool(SessionStore.surface_refresh_snapshot(SessionStore.SURFACE_BATTLE).get("refreshing", true)))

func test_battle_request_pending_state_uses_static_splash_only() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()

	boot._battle_request_splash_active = true
	boot._show_screen("battle")
	await get_tree().process_frame

	assert_eq(boot._current_screen, "battle_entry")
	assert_not_null(_find_node_by_name(boot._content_body, "BattleRequestSplash"))
	assert_not_null(_find_node_by_name(boot._content_body, "BattleRequestSplashArt"))
	assert_null(boot._battle_visual)
	assert_null(boot._timeline_label)
	assert_false(boot._action_buttons.has("request_battle"))
	assert_false(boot._action_buttons.has("show_latest_battle"))
	assert_false(_label_tree_contains(boot._content_body, "Solicitar batalha"))
	assert_null(_find_node_by_name(boot._content_body, "BattleDuelVisual"))

	boot._battle_request_splash_active = false
	boot._show_screen("battle", false)
	await get_tree().process_frame

	assert_not_null(boot._battle_visual)
	assert_true(boot._action_buttons.has("request_battle"))

func test_bosque_direct_entry_opens_openworld_without_player_facing_modes_route() -> void:
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("refuge")
	await get_tree().process_frame

	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Modos"))
	assert_null(_find_button_by_text(boot._first_screen_root, "Openworld"))
	assert_null(_find_button_by_text(boot._first_screen_root, "Openworld Bosque"))
	var bosque_icon := _find_node_by_name(boot._first_screen_root, "RefugeIcon_Bosque") as Button
	assert_not_null(bosque_icon)
	assert_eq(str(bosque_icon.text), "Bosque")
	assert_true(bosque_icon.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_true(boot._action_buttons.has(AppShellActionContractScript.open_mode_shell_action("openworld")))

	bosque_icon.pressed.emit()
	await get_tree().process_frame
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_eq(str(boot.get("_active_mode_id")), "openworld")
	assert_false(_label_tree_contains(boot._content_body, "Hub interno dos cinco modos oficiais"))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.mode_disabled_action("towerdefense")))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.mode_disabled_action("cardgame")))

func test_bosque_launcher_action_opens_overlay_without_recreating_openworld() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)

	var mode_screen := boot.get("_mode_shell_active_screen") as Control
	assert_not_null(mode_screen)
	if mode_screen == null:
		return
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_false(boot._shell_overlay_is_open())
	if mode_screen != null and mode_screen.has_method("set_player_position_for_tests"):
		mode_screen.call("set_player_position_for_tests", Vector2(512, 444))

	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)

	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ACCOUNT)
	assert_true(mode_screen == boot.get("_mode_shell_active_screen"))
	assert_true(bool(mode_screen.call("shell_overlay_paused_for_tests")))
	assert_not_null(_find_node_by_name(boot, "ModeShellMenuOverlay"))
	assert_not_null(_find_node_by_name(boot, "ModeShellMenuPanel"))
	assert_eq(boot._active_route_for_context(), AppShellRouteContractScript.ROUTE_ACCOUNT)

	boot._go_back()
	await get_tree().process_frame

	assert_false(boot._shell_overlay_is_open())
	assert_true(mode_screen == boot.get("_mode_shell_active_screen"))
	assert_false(bool(mode_screen.call("shell_overlay_paused_for_tests")))
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	if mode_screen.has_method("get_player_position"):
		var player_position: Vector2 = mode_screen.call("get_player_position")
		assert_eq(player_position.snapped(Vector2(0.01, 0.01)), Vector2(512, 444))

func test_bosque_overlay_back_pops_subroute_before_closing() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_SHOP)
	await get_tree().process_frame

	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_SHOP)
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

	boot._go_back()
	await get_tree().process_frame

	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ACCOUNT)

	boot._go_back()
	await get_tree().process_frame

	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

func test_bosque_overlay_header_buttons_keep_clickable_input_and_navigation() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_SHOP)
	await get_tree().process_frame

	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay") as Control
	var back_button := _find_node_by_name(boot, "ModeShellMenuBackButton") as Button
	var close_button := _find_node_by_name(boot, "ModeShellMenuCloseButton") as Button
	assert_not_null(overlay)
	assert_not_null(back_button)
	assert_not_null(close_button)
	assert_eq(overlay.mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_eq(back_button.mouse_filter, Control.MOUSE_FILTER_STOP)
	assert_eq(close_button.mouse_filter, Control.MOUSE_FILTER_STOP)
	assert_false(back_button.disabled)
	assert_false(close_button.disabled)

	_send_raw_click_to_boot(boot, back_button.get_global_rect().get_center())
	await get_tree().process_frame
	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ACCOUNT)

	close_button = _find_node_by_name(boot, "ModeShellMenuCloseButton") as Button
	assert_not_null(close_button)
	assert_false(close_button.disabled)
	_send_raw_click_to_boot(boot, close_button.get_global_rect().get_center())
	await get_tree().process_frame

	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

func test_bosque_overlay_internal_button_uses_viewport_rect_authority() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	await wait_process_frames(3)

	var mode_screen := boot.get("_mode_shell_active_screen") as Control
	var return_button := _find_button_by_text(_find_node_by_name(boot, "ModeShellMenuOverlay"), "Voltar ao Refugio")
	assert_not_null(mode_screen)
	assert_not_null(return_button)
	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_SELECTION)

	await _click_button_via_viewport(return_button)
	await wait_process_frames(2)

	if boot._shell_overlay_is_open():
		var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
		var relative_path := str(overlay.get_path_to(return_button))
		var center := return_button.get_global_rect().get_center()
		boot._handle_web_overlay_input_command([JSON.stringify({
			"type": "button",
			"path": relative_path,
			"x": center.x,
			"y": center.y,
			"text": return_button.text,
		})])
		await wait_process_frames(2)

	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_true(mode_screen == boot.get("_mode_shell_active_screen"))

func test_bosque_overlay_web_button_bridge_activates_internal_button() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	await wait_process_frames(3)

	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	var return_button := _find_button_by_text(overlay, "Voltar ao Refugio")
	assert_not_null(overlay)
	assert_not_null(return_button)
	assert_true(boot._shell_overlay_is_open())

	var relative_path := str(overlay.get_path_to(return_button))
	var center := return_button.get_global_rect().get_center()
	boot._handle_web_overlay_input_command([JSON.stringify({
		"type": "button",
		"path": relative_path,
		"x": center.x,
		"y": center.y,
		"text": return_button.text,
	})])
	await wait_process_frames(2)

	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

func test_bosque_overlay_web_wheel_bridge_scrolls_menu_body() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)

	var scroll := _find_node_by_name(boot, "ModeShellMenuScroll") as ScrollContainer
	assert_not_null(scroll)
	assert_true(boot._shell_overlay_is_open())
	assert_eq(scroll.scroll_vertical, 0)

	boot._handle_web_overlay_input_command([JSON.stringify({
		"type": "wheel",
		"deltaY": 420,
	})])
	await wait_process_frames(2)

	assert_gt(scroll.scroll_vertical, 0)

func test_bosque_overlay_escape_key_closes_from_web_input_phase() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	assert_true(boot._shell_overlay_is_open())

	var cancel_event := InputEventKey.new()
	cancel_event.pressed = true
	cancel_event.keycode = KEY_ESCAPE
	cancel_event.physical_keycode = KEY_ESCAPE
	boot._input(cancel_event)
	await wait_process_frames(2)

	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

func test_bosque_overlay_arena_replay_uses_overlay_fullscreen_parent() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"last_duel": {
			"battle_log": _arena_battle_log_fixture(),
			"rewards": {"almas": 7},
		},
	}
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	await wait_process_frames(3)

	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_SELECTION)

	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_ARENA_REPLAY)
	await get_tree().process_frame

	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	var fullscreen_layer := _find_node_by_name(boot, "ModeShellArenaFullscreenLayer") as Control
	var menu_panel := _find_node_by_name(boot, "ModeShellMenuPanel") as Control
	assert_not_null(overlay)
	assert_not_null(fullscreen_layer)
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_REPLAY)
	var battle_overlay := _find_node_by_name(overlay, "BattleFullscreenOverlay") as Control
	assert_not_null(battle_overlay)
	assert_true(fullscreen_layer.visible)
	assert_true(battle_overlay.get_parent() == fullscreen_layer)
	assert_true(menu_panel == null or not menu_panel.visible or menu_panel.get_parent() != fullscreen_layer)
	assert_true(boot._mode_shell_active_screen != null and is_instance_valid(boot._mode_shell_active_screen))

func test_bosque_overlay_close_blocks_only_for_replay_or_critical_mutation() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)

	boot._active_action_id = AppShellActionContractScript.ACTION_OPEN_ARENA
	boot._is_busy = true
	boot._go_back()
	await get_tree().process_frame
	assert_false(boot._shell_overlay_is_open())

	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	boot._active_action_id = AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL
	boot._is_busy = false
	boot._go_back()
	await get_tree().process_frame
	assert_false(boot._shell_overlay_is_open())

	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	boot._active_action_id = AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL
	boot._is_busy = true
	boot._go_back()
	await get_tree().process_frame
	assert_false(boot._shell_overlay_is_open())

	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	boot._shell_overlay_close_lock_action_id = AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL
	boot._is_busy = false
	boot._go_back()
	await get_tree().process_frame
	assert_true(boot._shell_overlay_is_open())
	assert_string_contains(boot._detail_label.text, "Aguarde a acao critica terminar")
	boot._shell_overlay_close_lock_action_id = ""
	boot._is_busy = false

	boot._go_back()
	await get_tree().process_frame
	assert_false(boot._shell_overlay_is_open())

	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	boot._active_action_id = ""
	boot._is_busy = false

	boot._replay_running = true
	boot._go_back()
	await get_tree().process_frame
	assert_true(boot._shell_overlay_is_open())
	boot._replay_running = false
	boot._go_back()
	await get_tree().process_frame
	assert_false(boot._shell_overlay_is_open())

func test_bosque_overlay_read_only_refresh_does_not_block_close_or_late_response() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)

	var token: Dictionary = boot._begin_surface_refresh(
		SessionStore.SURFACE_BASE,
		"base/state",
		"Buscando Refugio...",
		false
	)
	await wait_process_frames(1)
	var close_button := _find_node_by_name(boot, "ModeShellMenuCloseButton") as Button
	assert_not_null(close_button)
	assert_false(close_button.disabled)
	assert_true(boot._shell_overlay_is_open())
	assert_true(boot._is_busy)
	assert_eq(boot._mode_shell_overlay_controller.route_phase(), "refreshing")
	assert_false(boot._mode_shell_overlay_controller.route_ready())

	var refresh_button := _find_button_by_text(_find_node_by_name(boot, "ModeShellMenuOverlay"), "Atualizar perfil")
	if refresh_button != null:
		await _send_overlay_web_button_command(boot, refresh_button)
		assert_eq(boot._mode_shell_overlay_controller.last_ignored_input_reason(), "route_not_ready")

	boot._close_shell_overlay()
	await get_tree().process_frame

	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

	var finished := boot._finish_surface_refresh(
		SessionStore.SURFACE_BASE,
		token,
		{"ok": true, "body": {"late": true}},
		"Resposta tardia nao deve renderizar."
	)
	assert_false(finished)
	assert_false(
		boot._is_busy,
		"busy flag should be false after stale read-only refresh is ignored; scopes=%s phase=%s" % [
			Array(boot._operation_state.busy_scopes()),
			boot._mode_shell_overlay_controller.route_phase(),
		]
	)
	assert_false(_label_tree_contains(boot._content_body, "Resposta tardia nao deve renderizar."))

func test_bosque_overlay_internal_exit_actions_clear_active_action_state() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)

	await boot._trigger_action(AppShellActionContractScript.open_mode_shell_action("openworld"))
	await wait_process_frames(2)
	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._active_action_id, "")
	assert_eq(boot._active_action_scope, OperationStateScript.DEFAULT_SCOPE)
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_ACCOUNT)
	await wait_process_frames(3)
	await boot._trigger_action(AppShellActionContractScript.ACTION_RETURN_REFUGE)
	await wait_process_frames(2)
	assert_false(boot._shell_overlay_is_open())
	assert_eq(boot._active_action_id, "")
	assert_eq(boot._active_action_scope, OperationStateScript.DEFAULT_SCOPE)
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)

func test_bosque_overlay_web_text_bridge_focuses_social_inputs_and_preserves_values() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_SOCIAL)
	await wait_process_frames(3)

	var friend_input := boot.get("_social_friend_input") as LineEdit
	assert_not_null(friend_input)
	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_SOCIAL)

	await _send_overlay_web_focus_command(boot, friend_input)
	await _send_overlay_web_text_command(boot, friend_input, "friend_alpha", true)
	await wait_process_frames(2)

	assert_eq(friend_input.text, "friend_alpha")
	assert_eq(str(boot.get("_last_social_friend_username")), "friend_alpha")
	assert_eq(str(boot._mode_shell_overlay_controller.focused_control_path()), str((_find_node_by_name(boot, "ModeShellMenuOverlay") as Node).get_path_to(friend_input)))
	assert_true(_overlay_control_diagnostics_has_line_edit(boot, "friend_alpha"))

	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_SOCIAL, false)
	await wait_process_frames(2)

	var refreshed_friend_input := boot.get("_social_friend_input") as LineEdit
	assert_not_null(refreshed_friend_input)
	assert_eq(refreshed_friend_input.text, "friend_alpha")

func test_bosque_overlay_social_action_buttons_read_overlay_line_edits() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_SOCIAL)
	await wait_process_frames(3)

	var friend_input := boot.get("_social_friend_input") as LineEdit
	var add_friend_button := _find_button_by_text(_find_node_by_name(boot, "ModeShellMenuOverlay"), "Adicionar amigo")
	assert_not_null(friend_input)
	assert_not_null(add_friend_button)

	await _send_overlay_web_focus_command(boot, friend_input)
	await _send_overlay_web_text_command(boot, friend_input, "friend_alpha", true)
	_set_required_update_gate(boot)
	await _send_overlay_web_button_command(boot, add_friend_button)
	await wait_process_frames(3)

	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_SOCIAL)
	assert_eq(str(boot.get("_last_social_friend_username")), "friend_alpha")
	assert_eq(str(boot._web_last_action.get("action_id", "")), AppShellActionContractScript.ACTION_ADD_FRIEND)
	assert_string_contains(boot._error_label.text, "Update obrigatorio")

func test_bosque_overlay_shop_confirmable_actions_use_overlay_confirmation() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	SessionStore.monetization_state = _shop_state_fixture()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	await boot._trigger_shell_overlay_action(AppShellActionContractScript.ACTION_SHOW_SHOP)
	await wait_process_frames(3)

	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	var buy_button := _find_button_by_text(overlay, "Comprar Energia")
	assert_not_null(overlay)
	assert_not_null(buy_button)
	assert_true(boot._shell_overlay_is_open())

	await _send_overlay_web_button_command(boot, buy_button)
	await wait_process_frames(2)

	var confirm_panel := _find_node_by_name(boot, "ModeShellMenuConfirmPanel") as Control
	var cancel_button := _find_node_by_name(boot, "ModeShellCancelConfirmButton") as Button
	assert_not_null(confirm_panel)
	assert_not_null(cancel_button)
	assert_true(confirm_panel.visible)
	assert_true(boot._mode_shell_overlay_controller.confirmation_pending())
	assert_eq(
		str(boot.get("_pending_confirmation_action")),
		AppShellActionContractScript.shop_purchase_action(AppShellActionContractScript.PRODUCT_ALPHA_ENERGY_PACK)
	)
	assert_false(boot._confirm_dialog.visible)

	await _send_overlay_web_button_command(boot, cancel_button)
	await wait_process_frames(2)

	assert_false(boot._mode_shell_overlay_controller.confirmation_pending())
	assert_eq(str(boot.get("_pending_confirmation_action")), "")
	assert_false(confirm_panel.visible)

	await _send_overlay_web_button_command(boot, buy_button)
	await wait_process_frames(2)
	_set_required_update_gate(boot)
	var confirm_button := _find_node_by_name(boot, "ModeShellConfirmButton") as Button
	assert_not_null(confirm_button)
	await _send_overlay_web_button_command(boot, confirm_button)
	await wait_process_frames(3)

	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_SHOP)
	assert_false(boot._mode_shell_overlay_controller.confirmation_pending())
	assert_eq(str(boot._web_last_action.get("action_id", "")), AppShellActionContractScript.shop_purchase_action(AppShellActionContractScript.PRODUCT_ALPHA_ENERGY_PACK))
	assert_string_contains(boot._error_label.text, "Update obrigatorio")

func test_bosque_overlay_arena_resume_and_abandon_releases_attempt_after_confirmation() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/arena_dev_fixtures_enabled", true)
	_prepare_account_state()
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"dev_fixture": true,
		"arenas": [
			{
				"id": "arena_cinzas_curta",
				"display_name": "Arena Curta Das Cinzas",
				"duel_count": 3,
				"unlocked": true,
				"difficulties": [{"difficulty_id": "s1_d00_intro", "max_steps": 3, "unlocked": true}],
			},
		],
		"active_attempt": {
			"attempt_id": "11111111-1111-4111-8111-111111111111",
			"arena_id": "arena_cinzas_curta",
			"status": "active",
			"current_step_index": 1,
			"duel_count": 3,
			"duels_won": 1,
			"locked_loadout_hash": "sha256:test",
		},
	}
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	await wait_process_frames(3)

	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	var resume_button := _find_button_by_text(overlay, "Retomar tentativa")
	assert_not_null(overlay)
	assert_not_null(resume_button)
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_SELECTION)

	await _send_overlay_web_button_command(boot, resume_button)
	await wait_process_frames(3)

	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_ACTIVE)
	assert_eq(str(boot._web_last_action.get("action_id", "")), AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT)
	var fullscreen_layer := _find_node_by_name(boot, "ModeShellArenaFullscreenLayer") as Control
	var active_panel := _find_node_by_name(boot, "ModeShellArenaFullscreenPanel") as Control
	assert_not_null(fullscreen_layer)
	assert_not_null(active_panel)
	assert_true(fullscreen_layer.visible)
	assert_true(active_panel.get_parent() == fullscreen_layer)
	assert_true(active_panel.get_global_rect().size.x >= get_viewport().get_visible_rect().size.x * 0.8)
	assert_eq(boot._mode_shell_overlay_controller.top_layer_name(), "arena_fullscreen")

	overlay = _find_node_by_name(boot, "ModeShellMenuOverlay")
	var abandon_button := _find_button_by_text(overlay, "Abandonar tentativa")
	assert_not_null(abandon_button)
	await _send_overlay_web_button_command(boot, abandon_button)
	await wait_process_frames(3)

	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_ACTIVE)
	assert_true(boot._mode_shell_overlay_controller.confirmation_pending())
	var modal_layer := _find_node_by_name(boot, "ModeShellModalLayer") as Control
	var confirm_panel := _find_node_by_name(boot, "ModeShellMenuConfirmPanel") as Control
	assert_not_null(modal_layer)
	assert_not_null(confirm_panel)
	assert_true(modal_layer.visible)
	assert_true(confirm_panel.visible)
	assert_true(confirm_panel.get_parent() == modal_layer)
	assert_eq(boot._mode_shell_overlay_controller.top_layer_name(), "modal")
	assert_eq(str(boot.get("_pending_confirmation_action")), AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT)
	assert_ne(str(boot._web_last_action.get("action_id", "")), AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT)

	var confirm_button := _find_node_by_name(boot, "ModeShellConfirmButton") as Button
	assert_not_null(confirm_button)
	await _send_overlay_web_button_command(boot, confirm_button)
	await wait_process_frames(6)

	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._current_screen, AppShellRouteContractScript.ROUTE_MODE_SHELL)
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	assert_eq(str(boot._web_last_action.get("action_id", "")), AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT)
	assert_false(boot._mode_shell_overlay_controller.confirmation_pending())
	assert_eq(str(SessionStore.active_arena_attempt().get("state", "")), "abandoned")
	assert_eq(str(boot._arena_last_operation.get("phase", "")), "abandon_released")
	assert_false(bool(boot._arena_last_operation.get("active_attempt_blocks", true)))
	assert_eq(boot._mode_shell_overlay_controller.route_phase(), "ready")
	assert_false(
		boot._is_busy,
		"busy flag should be false after abandon release; scopes=%s phase=%s" % [
			Array(boot._operation_state.busy_scopes()),
			boot._mode_shell_overlay_controller.route_phase(),
		]
	)

func test_bosque_overlay_arena_stale_attempt_clears_locally_even_when_update_gate_blocks_remote() -> void:
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_account_state()
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"arenas": [
			{
				"id": "arena_cinzas_curta",
				"display_name": "Arena Curta Das Cinzas",
				"duel_count": 3,
				"unlocked": true,
				"difficulties": [{"difficulty_id": "s1_d00_intro", "max_steps": 3, "unlocked": true}],
			},
		],
		"active_attempt": {
			"attempt_id": "attempt-overlay-stale",
			"arena_id": "arena_cinzas_curta",
			"status": "active",
			"current_step_index": 1,
			"duel_count": 3,
			"duels_won": 1,
			"locked_loadout_hash": "sha256:stale",
		},
	}
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._open_mode_shell("openworld")
	await wait_process_frames(2)
	_set_required_update_gate(boot)
	boot._show_overlay_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	await wait_process_frames(3)

	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	var stale_button := _find_button_by_text(overlay, "Encerrar tentativa antiga")
	assert_not_null(stale_button)

	await _send_overlay_web_button_command(boot, stale_button)
	await wait_process_frames(2)
	assert_true(boot._mode_shell_overlay_controller.confirmation_pending())

	var confirm_button := _find_node_by_name(boot, "ModeShellConfirmButton") as Button
	assert_not_null(confirm_button)
	await _send_overlay_web_button_command(boot, confirm_button)
	await wait_process_frames(5)

	assert_true(boot._shell_overlay_is_open())
	assert_eq(boot._shell_overlay_current_route(), AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	assert_eq(str(boot._web_last_action.get("action_id", "")), AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT)
	assert_true(SessionStore.active_arena_attempt().is_empty())
	assert_eq(str(boot._arena_last_operation.get("phase", "")), "abandon_local_recovery_released")
	assert_false(bool(boot._arena_last_operation.get("active_attempt_blocks", true)))
	assert_false(boot._error_label.text.contains("Update obrigatorio"))

func test_refuge_no_longer_exposes_modes_popup_cards() -> void:
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("refuge")
	await get_tree().process_frame

	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeIcon_Modos"))
	assert_null(_find_button_by_text(boot._first_screen_root, "Modos"))
	assert_null(_find_button_by_text(boot._first_screen_root, "Openworld Bosque"))
	assert_null(_find_node_by_name(boot._first_screen_root, "ModeCard_basebuilder"))
	assert_null(_find_node_by_name(boot._first_screen_root, "ModeCard_autobattler"))
	assert_null(_find_node_by_name(boot._first_screen_root, "ModeCard_openworld"))
	assert_null(_find_node_by_name(boot._first_screen_root, "ModeCard_towerdefense"))
	assert_null(_find_node_by_name(boot._first_screen_root, "ModeCard_cardgame"))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.open_mode_shell_action("openworld")))

func test_boot_surface_presenters_keep_render_only_contract() -> void:
	assert_false(FileAccess.file_exists("res://modes/boot/surfaces/battle_surface_presenter.gd"))
	var boot_source := FileAccess.get_file_as_string("res://modes/boot/boot.gd")
	assert_false(boot_source.contains("battle_surface_presenter.gd"))
	var direct_session_read := RegEx.new()
	assert_eq(direct_session_read.compile("SessionStore\\.(player|resources|build|base_state|social_state|competition_state|monetization_state|crafting_state|combat_build_state|last_battle_log|last_battle_rewards)\\b"), OK)
	for script_path: String in _surface_presenter_script_paths():
		var source := FileAccess.get_file_as_string(script_path)
		for fragment: String in _forbidden_presenter_fragments():
			assert_false(
				source.contains(fragment),
				"%s must stay render-only and host-owned for '%s'" % [script_path, fragment]
			)
		assert_eq(
			direct_session_read.search(source),
			null,
			"%s must read SessionStore through read-only slices/snapshots" % script_path
		)

func test_boot_decomposition_keeps_shell_budget_and_boundaries() -> void:
	var boot_source := FileAccess.get_file_as_string("res://modes/boot/boot.gd")
	var line_count := boot_source.split("\n").size()
	assert_true(line_count <= 1200, "boot.gd must stay under the Foundation Final Polish shell budget; got %d lines" % line_count)
	var hub_source := FileAccess.get_file_as_string("res://modes/boot/surfaces/hub_surface_presenter.gd")
	var hub_line_count := hub_source.split("\n").size()
	assert_true(hub_line_count <= 900, "hub_surface_presenter.gd must stay a thin facade; got %d lines" % hub_line_count)
	assert_false(FileAccess.file_exists("res://modes/boot/boot_runtime_facade.gd"))
	var runtime_hot_budgets := {
		"res://modes/boot/boot_runtime.gd": 900,
		"res://modes/boot/boot_runtime_state.gd": 700,
		"res://modes/boot/boot_runtime_surface_api.gd": 700,
		"res://modes/boot/boot_runtime_status_controller.gd": 700,
		"res://modes/boot/boot_runtime_labs_controller.gd": 700,
		"res://modes/boot/boot_runtime_flow_facade.gd": 700,
		"res://modes/boot/boot_runtime_navigation_controller.gd": 700,
		"res://modes/boot/boot_runtime_action_dispatcher.gd": 700,
	}
	var runtime_hot_source := ""
	for script_path: String in runtime_hot_budgets.keys():
		assert_true(FileAccess.file_exists(script_path), "%s must exist as a budgeted runtime module" % script_path)
		var runtime_source := FileAccess.get_file_as_string(script_path)
		var runtime_line_count := runtime_source.split("\n").size()
		var budget := int(runtime_hot_budgets[script_path])
		assert_true(runtime_line_count < budget, "%s must stay under %d lines; got %d" % [script_path, budget, runtime_line_count])
		runtime_hot_source += "\n" + runtime_source
	var hub_full_source := FileAccess.get_file_as_string("res://modes/boot/surfaces/hub_surface_full_presenter.gd")
	var hub_full_line_count := hub_full_source.split("\n").size()
	assert_true(hub_full_line_count <= 900, "hub_surface_full_presenter.gd must stay below the hub hardening budget; got %d lines" % hub_full_line_count)
	assert_true(boot_source.contains("app_shell_action_contract.gd"))
	assert_true(boot_source.contains("account_session_flow.gd"))
	assert_true(boot_source.contains("surface_action_flow.gd"))
	assert_true(boot_source.contains("battle_lifecycle_flow.gd"))
	assert_true(boot_source.contains("surface_ui_helpers.gd"))
	assert_true(runtime_hot_source.contains("mode_shell_launcher.gd"))
	assert_false(runtime_hot_source.contains("mode_hub_surface_presenter.gd"))
	assert_false(boot_source.contains("\"mode_hub\""))
	assert_false(runtime_hot_source.contains("func _render_mode_content_body"))
	assert_false(runtime_hot_source.contains("func _render_mode_fullscreen"))
	assert_false(boot_source.contains("SupabaseClient.fetch_base_state"))
	assert_false(boot_source.contains("SupabaseClient.collect_base"))
	assert_false(boot_source.contains("SupabaseClient.fetch_social_state"))
	assert_false(boot_source.contains("SupabaseClient.request_battle"))

func test_mode_shell_launcher_owns_mode_screen_instantiation() -> void:
	assert_not_null(ModeShellLauncherScript)
	var runtime_source := FileAccess.get_file_as_string("res://modes/boot/boot_runtime_labs_controller.gd")
	runtime_source += "\n" + FileAccess.get_file_as_string("res://modes/boot/boot_runtime_flow_facade.gd")
	var launcher_source := FileAccess.get_file_as_string("res://modes/boot/ui/mode_shell_launcher.gd")
	assert_true(runtime_source.contains("_mode_shell_launcher.render(self)"))
	assert_true(runtime_source.contains("_mode_shell_launcher.open(self, mode_id)"))
	assert_true(launcher_source.contains("ModeShellRegistryScript.screen_path"))
	assert_true(launcher_source.contains("ModeUnavailableFallback"))

func test_boot_action_ids_are_centralized_in_contract() -> void:
	for script_path: String in _action_consumer_script_paths():
		var source := FileAccess.get_file_as_string(script_path)
		for action_literal: String in _centralized_action_literals():
			assert_false(
				source.contains("\"%s\"" % action_literal) or source.contains("\"%s" % action_literal),
				"%s must use AppShellActionContractScript for action id '%s'" % [script_path, action_literal]
			)

func test_auth_success_paths_return_directly_to_refuge() -> void:
	var source := FileAccess.get_file_as_string("res://modes/boot/flows/account_session_flow.gd")
	assert_true(source.contains("func email_sign_in"))
	assert_true(source.contains("func email_sign_up_with_credentials"))
	assert_true(source.count("host.call(\"_show_refuge_root") >= 5)

func test_guest_entry_forces_anonymous_session_when_email_session_is_cached() -> void:
	var source := FileAccess.get_file_as_string("res://modes/boot/flows/account_session_flow.gd")
	var enter_guest_source := source.substr(source.find("func enter_guest"), source.find("func enter_refuge") - source.find("func enter_guest"))
	assert_true(enter_guest_source.contains("SessionStore.is_registered_session()"))
	assert_true(enter_guest_source.contains("SessionStore.clear_session()"))
	assert_true(enter_guest_source.contains("SupabaseClient.sign_in_anonymously()"))

func test_boot_flows_do_not_create_visual_controls() -> void:
	for script_path: String in _flow_script_paths():
		var source := FileAccess.get_file_as_string(script_path)
		for fragment: String in _forbidden_flow_ui_fragments():
			assert_false(
				source.contains(fragment),
				"%s must orchestrate flows without creating UI controls via '%s'" % [script_path, fragment]
			)

func test_base_presenter_renders_loaded_state_without_network() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	SessionStore.base_state = _base_state_fixture()

	boot._show_screen("base")
	await get_tree().process_frame

	assert_string_contains(boot._timeline_label.text, "Refugio sincronizado")
	assert_string_contains(boot._timeline_label.text, "Fila: 1/2")
	assert_true(boot._action_buttons.has("select_base_structure:nucleo_energia"))
	assert_true(boot._action_buttons.has("upgrade_base_structure:nucleo_energia"))
	assert_not_null(boot._base_state_container)
	assert_true(_panel_tree_count(boot._base_state_container) >= 3)
	var upgrade_button := boot._action_buttons["upgrade_base_structure:nucleo_energia"] as Button
	assert_false(upgrade_button.disabled)
	assert_eq(upgrade_button.mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_true(upgrade_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)

func test_base_presenter_renders_crafting_state_without_network() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	SessionStore.base_state = _base_state_fixture()
	assert_true(SessionStore.apply_crafting_result({
		"ok": true,
		"save_type": SessionStore.SAVE_TYPE_NORMAL,
		"resources": {"ossos": 125, "po_osso": 75, "almas": 10, "energia": 20, "sangue": 0, "cristais": 0, "diamante": 0},
		"crafting": {
			"inventory": [{"item_id": AppShellActionContractScript.ITEM_HEALTH_POTION, "quantity": 2}],
			"potion_slots": [{"slot_index": 1, "potion_id": null}],
			"recipes": [{"id": AppShellActionContractScript.RECIPE_HEALTH_POTION}],
		},
	}))

	boot._show_screen("base")
	await get_tree().process_frame

	assert_true(_label_tree_contains(boot._base_state_container, "Po de Osso 75"))
	assert_true(_label_tree_contains(boot._base_state_container, "Pocoes 2"))
	assert_true(_label_tree_contains(boot._base_state_container, "As pocoes agora usam materiais do Bau e a Fogueira do Bosque."))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_CRUSH_BONES))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.open_mode_shell_action("openworld")))
	assert_false(boot._action_buttons.has(AppShellActionContractScript.ACTION_CRAFT_HEALTH_POTION))

func test_refuge_preparation_renders_potion_slot_and_behavior_defaults() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	assert_true(SessionStore.apply_build_result({
		"ok": true,
		"save_type": SessionStore.SAVE_TYPE_NORMAL,
		"build": {"weapon_type": "varinha_cinzas", "weapon_level": 4},
		"combat_build": {
			"power": 243,
			"weapon_type": "varinha_cinzas",
			"passive_id": "doutrina_pavor",
			"pet_id": "corvo_pressagio",
			"inventory": [{"item_id": AppShellActionContractScript.ITEM_HEALTH_POTION, "quantity": 3}],
			"potion_slots": [{
				"slot_index": 1,
				"potion_id": AppShellActionContractScript.ITEM_HEALTH_POTION,
				"behavior": {
					"enabled": true,
					"hp": {"mode": "below", "percent": 40},
					"mana": {"mode": "ignore", "percent": 0},
				},
			}],
			"spell_slots": [{
				"slot_index": 1,
				"unlock_level": 3,
				"unlocked": true,
				"spell_id": "sussurro_medo",
				"behavior": {
					"enabled": true,
					"hp": {"mode": "ignore", "percent": 0},
					"mana": {"mode": "ignore", "percent": 0},
				},
			}, {
				"slot_index": 2,
				"unlock_level": 7,
				"unlocked": true,
				"spell_id": null,
				"behavior": {},
			}, {
				"slot_index": 3,
				"unlock_level": 25,
				"unlocked": false,
				"spell_id": null,
				"behavior": {},
			}],
			"equipment_options": {
				"weapons": [
					{"id": "varinha_cinzas", "display_name": "Varinha de Cinzas", "unlocked": true, "equipped": true},
					{"id": "athame_hematico", "display_name": "Athame Hematico", "unlocked": true, "equipped": false},
				],
				"spells": [
					{"id": "sussurro_medo", "display_name": "Sussurro do Medo", "unlocked": true, "equipped": true},
					{"id": "incisao_ritual", "display_name": "Incisao Ritual", "unlocked": true, "equipped": false},
					{"id": "mandato_oculto", "display_name": "Mandato Oculto", "unlocked": false, "locked_reason": "Desbloqueia no nivel 25.", "equipped": false},
				],
				"doutrines": [
					{"id": "doutrina_pavor", "display_name": "Doutrina do Pavor", "unlocked": true, "equipped": true},
					{"id": "pacto_familiar", "display_name": "Pacto Familiar", "unlocked": true, "equipped": false},
				],
				"familiars": [
					{"id": "corvo_pressagio", "display_name": "Corvo de Pressagio", "unlocked": true, "equipped": true},
					{"id": "gato_tumular", "display_name": "Gato Tumular", "unlocked": true, "equipped": false},
					{"id": "lobo_tumular", "display_name": "Lobo Tumular", "unlocked": false, "locked_reason": "Desbloqueia no nivel 15.", "equipped": false},
				],
			},
		},
	}))

	boot._show_screen("refuge")
	await get_tree().process_frame

	var content := await _render_preparation_in_arena_selection(boot)
	assert_not_null(content)
	assert_true(_label_tree_contains(content, "Preparacao da Arena"))
	assert_true(_label_tree_contains(content, "Primeira sessao: confira instrumento, habilidades e pocao antes da Arena."))
	assert_true(_label_tree_contains(content, "Poder 243"))
	assert_true(_label_tree_contains(content, "Loadout atual:"))
	assert_true(_label_tree_contains(content, "Pocao e comportamento: Pocao de Vida equipada | Usa automaticamente; entra melhor com Vida abaixo de 40%"))
	assert_true(_label_tree_contains(content, "Editar loadout e comportamento"))
	assert_true(_label_tree_contains(content, "Ajuste instrumento, habilidades, Doutrina, Familiar, Pocao e preferencias simples."))
	assert_true(_label_tree_contains(content, "Instrumento: Varinha de Cinzas"))
	assert_true(_label_tree_contains(content, "Habilidades: 1 habilidade"))
	assert_true(_label_tree_contains(content, "Doutrina: Doutrina do Pavor"))
	assert_true(_label_tree_contains(content, "Familiar: Corvo de Pressagio"))
	assert_true(_label_tree_contains(content, "Pocao: Pocao de Vida equipada"))
	assert_true(_label_tree_contains(content, "Proximos marcos"))
	assert_true(_label_tree_contains(content, "Nivel 10: doutrina de combate."))
	assert_true(_label_tree_contains(content, "Em uso: Varinha de Cinzas L4"))
	assert_true(_label_tree_contains(content, "Athame Hematico: Disponivel"))
	assert_true(_label_tree_contains(content, "Pocao de Vida equipada"))
	assert_true(_label_tree_contains(content, "Estoque: Pocao de Vida x3"))
	assert_true(_label_tree_contains(content, "Usa automaticamente; entra melhor com Vida abaixo de 40%"))
	assert_true(_label_tree_contains(content, "Habilidade 1: Sussurro do Medo | Usa quando estiver pronta"))
	assert_true(_label_tree_contains(content, "Habilidade 2: vazia."))
	assert_true(_label_tree_contains(content, "Habilidade 3: desbloqueia no nivel 25."))
	assert_true(_label_tree_contains(content, "Mandato Oculto: Desbloqueia no nivel 25."))
	assert_true(_label_tree_contains(content, "Pacto Familiar: Disponivel"))
	assert_true(_label_tree_contains(content, "Gato Tumular: Disponivel"))
	assert_true(_label_tree_contains(content, "Lobo Tumular: Desbloqueia no nivel 15."))
	assert_not_null(_find_button_by_text(content, "Equipar Pocao de Vida"))
	assert_not_null(_find_button_by_text(content, "Remover pocao"))
	assert_not_null(_find_button_by_text(content, "Usar comportamento padrao"))
	assert_not_null(_find_button_by_text(content, "Pausar pocao"))
	assert_not_null(_find_button_by_text(content, "Usar na Arena"))
	assert_not_null(_find_button_by_text(content, "Pausar"))
	assert_null(_find_button_by_text(content, "Abrir Arena PVE"))
	var visible_text := _visible_text_tree(content).to_lower()
	for forbidden: String in ["behavior", "build", "slot", "endpoint", "server-authoritative", "schema", "snapshot"]:
		assert_false(visible_text.contains(forbidden), "Preparation should hide technical term '%s'." % forbidden)
	assert_true(boot._action_buttons.has(AppShellActionContractScript.equip_potion_action(AppShellActionContractScript.ITEM_HEALTH_POTION)))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_UNEQUIP_POTION))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.ACTION_ENABLE_POTION_DEFAULT))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.enable_spell_behavior_action("sussurro_medo")))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.remove_spell_position_action(1)))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.equip_instrument_action("athame_hematico")))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.equip_spell_position_action(2, "incisao_ritual")))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.equip_doctrine_action("pacto_familiar")))
	assert_true(boot._action_buttons.has(AppShellActionContractScript.equip_familiar_action("gato_tumular")))

func test_preparation_action_contract_keeps_player_safe_defaults_and_errors() -> void:
	var potion_behavior := PreparationActionContractScript.default_potion_behavior()
	assert_eq(potion_behavior.get("enabled"), true)
	assert_eq(potion_behavior.get("hp"), {"mode": "below", "percent": 40})
	assert_eq(potion_behavior.get("mana"), {"mode": "ignore", "percent": 0})
	var spell_behavior := PreparationActionContractScript.default_spell_behavior(false)
	assert_eq(spell_behavior.get("enabled"), false)
	assert_eq(spell_behavior.get("hp"), {"mode": "ignore", "percent": 0})
	assert_true(PreparationActionContractScript.is_network_error("NETWORK_UNAVAILABLE"))
	assert_false(PreparationActionContractScript.is_network_error("POTION_NOT_OWNED"))
	assert_eq(
		PreparationActionContractScript.error_message("POTION_NOT_OWNED"),
		"Voce ainda nao tem essa pocao. Prepare uma na Fogueira do Bosque."
	)
	assert_eq(
		PreparationActionContractScript.error_message("NETWORK_UNAVAILABLE"),
		"Sem conexao para carregar a preparacao. Verifique a internet e tente de novo."
	)
	assert_eq(
		PreparationActionContractScript.error_payload({"body": {"error": {"code": "INVALID_SPELL"}}}).get("code"),
		"INVALID_SPELL"
	)
	assert_eq(PreparationActionContractScript.error_payload({}).get("code"), "REQUEST_FAILED")

func test_refuge_top_hud_uses_existing_account_and_build_state_without_progression_bars() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	assert_true(SessionStore.apply_build_result({
		"ok": true,
		"save_type": SessionStore.SAVE_TYPE_NORMAL,
		"build": {"weapon_type": "varinha_cinzas"},
		"combat_build": {
			"power": 243,
			"weapon_type": "varinha_cinzas",
			"spell_slots": [{
				"slot_index": 3,
				"unlock_level": 25,
				"unlocked": false,
				"spell_id": null,
				"behavior": {},
			}],
			"equipment_options": {
				"familiars": [
					{"id": "lobo_tumular", "display_name": "Lobo Tumular", "unlocked": false, "locked_reason": "Desbloqueia no nivel 15.", "equipped": false},
				],
			},
		},
	}))

	boot._show_screen("refuge")
	await get_tree().process_frame

	var top_hud := _find_node_by_name(boot._first_screen_root, "RefugeTopHud")
	assert_not_null(top_hud)
	assert_true(_visible_text_tree(top_hud).contains("Level 8 | Almas 100 | Energia 200 | Ossos 3 | Po 0"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeProgressionPanel"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeProgressionLine"))
	assert_null(_find_node_by_name(boot._first_screen_root, "RefugeFirstSessionHintLabel"))
	assert_false(_label_tree_contains(boot._first_screen_root, "Progresso"))
	assert_false(_label_tree_contains(boot._first_screen_root, "Primeira sessao: siga o proximo passo e mantenha a base evoluindo."))
	var lines := ProgressionClarityPresenterScript.unlock_lines(SessionStore.combat_build_state, 3)
	assert_true(lines.has("Nivel 10: doutrina de combate."))
	assert_true(lines.has("Nivel 15: Lobo Tumular."))

func test_refuge_preparation_popup_refreshes_after_equip_feedback() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	assert_true(_apply_preparation_instrument_fixture("varinha_cinzas"))

	boot._show_screen("refuge")
	await get_tree().process_frame

	var content := await _render_preparation_in_arena_selection(boot)
	assert_not_null(content)
	assert_true(_label_tree_contains(content, "Em uso: Varinha de Cinzas L4"))

	assert_true(_apply_preparation_instrument_fixture("athame_hematico"))
	boot.set_meta("preparation_feedback_message", "Instrumento Ritual equipado.")
	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	await get_tree().process_frame
	content = boot._content_body

	assert_true(_label_tree_contains(content, "Ultima escolha: Instrumento Ritual equipado."))
	assert_true(_label_tree_contains(content, "Em uso: Athame Hematico L4"))
	assert_true(_label_tree_contains(content, "Varinha de Cinzas: Disponivel"))

func test_refuge_preparation_renders_empty_and_paused_states_without_network() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	assert_true(SessionStore.apply_build_result({
		"ok": true,
		"save_type": SessionStore.SAVE_TYPE_NORMAL,
		"build": {"weapon_type": "orbe_tempestade"},
		"combat_build": {
			"inventory": [],
			"potion_slots": [{
				"slot_index": 1,
				"potion_id": null,
				"behavior": {
					"enabled": true,
					"hp": {"mode": "below", "percent": 40},
					"mana": {"mode": "ignore", "percent": 0},
				},
			}],
			"equipped_spells": [],
		},
	}))

	boot._show_screen("refuge")
	await get_tree().process_frame

	var content := await _render_preparation_in_arena_selection(boot)
	assert_not_null(content)
	assert_true(_label_tree_contains(content, "Em uso: Orbe da Tempestade"))
	assert_true(_label_tree_contains(content, "Nenhuma pocao equipada"))
	assert_true(_label_tree_contains(content, "Estoque: nenhuma"))
	assert_true(_label_tree_contains(content, "Nenhuma habilidade equipada."))

func test_refuge_preparation_renders_paused_potion_and_spell_publicly() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	assert_true(SessionStore.apply_build_result({
		"ok": true,
		"save_type": SessionStore.SAVE_TYPE_NORMAL,
		"build": {
			"weapon_type": "varinha_cinzas",
			"pet_id": "corvo_pressagio",
			"pet_level": 2,
			"passive_id": "pacto_familiar",
			"passive_level": 3,
		},
		"combat_build": {
			"inventory": [{"item_id": AppShellActionContractScript.ITEM_HEALTH_POTION, "quantity": 1}],
			"potion_slots": [{
				"slot_index": 1,
				"potion_id": AppShellActionContractScript.ITEM_HEALTH_POTION,
				"behavior": {
					"enabled": false,
					"hp": {"mode": "below", "percent": 40},
					"mana": {"mode": "ignore", "percent": 0},
				},
			}],
			"equipped_spells": [{
				"slot_index": 1,
				"spell_id": "incisao_ritual",
				"behavior": {
					"enabled": false,
					"hp": {"mode": "ignore", "percent": 0},
					"mana": {"mode": "ignore", "percent": 0},
				},
			}],
		},
	}))

	boot._show_screen("refuge")
	await get_tree().process_frame

	var content := await _render_preparation_in_arena_selection(boot)
	assert_not_null(content)
	assert_true(_label_tree_contains(content, "Pocao pausada"))
	assert_true(_label_tree_contains(content, "Habilidade 1: Incisao Ritual | Pausada para Arena"))
	assert_true(_label_tree_contains(content, "Corvo de Pressagio L2"))
	assert_true(_label_tree_contains(content, "Pacto Familiar L3"))

func test_base_routine_panel_derives_objective_from_existing_payload() -> void:
	var routine: Dictionary = BaseSurfacePresenterScript.routine_summary(_base_state_fixture())

	assert_string_contains(str(routine.get("collect_text", "")), "Producao pendente: Almas 4 | Energia 12.")
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

	assert_true(_label_tree_contains(boot._base_state_container, "Rotina do Refugio"))
	assert_true(_label_tree_contains(boot._base_state_container, "Producao"))
	assert_false(_label_tree_contains(boot._base_state_container, "Coleta pronta:"))
	assert_true(_label_tree_contains(boot._base_state_container, "Almas 4"))
	assert_true(_label_tree_contains(boot._base_state_container, "Energia 12"))
	assert_true(_label_tree_contains(boot._base_state_container, "Fila em andamento: 1 obra(s)."))
	assert_true(_label_tree_contains(boot._base_state_container, "Altar das Almas -> L2 | resta 1m 30s"))
	assert_true(_label_tree_contains(boot._base_state_container, "Slots livres: 1/2."))
	assert_true(_label_tree_contains(boot._base_state_container, "Proximo: Nucleo de Energia pronto"))

func test_shop_presenter_renders_loaded_state_and_disables_claimed_items() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()
	SessionStore.monetization_state = _shop_state_fixture()

	boot._show_screen("shop")
	await get_tree().process_frame

	assert_string_contains(boot._timeline_label.text, "Loja sincronizada")
	assert_string_contains(boot._timeline_label.text, "Resgates hoje: 1/4")
	assert_true(boot._action_buttons.has("shop_purchase:alpha_energy_pack_small"))
	assert_true(boot._action_buttons.has("shop_purchase:alpha_battle_pass_premium"))
	assert_true(boot._action_buttons.has("claim_reward:daily_collect_base"))
	assert_not_null(boot._shop_state_container)
	assert_true(_panel_tree_count(boot._shop_state_container) >= 4)
	var pass_button := boot._action_buttons["shop_purchase:alpha_battle_pass_premium"] as Button
	assert_true(pass_button.disabled)
	var energy_button := boot._action_buttons["shop_purchase:alpha_energy_pack_small"] as Button
	assert_not_null(energy_button)
	assert_eq(str(energy_button.text), "Comprar Energia")
	var reward_button := boot._action_buttons["claim_reward:daily_collect_base"] as Button
	assert_true(reward_button.disabled)
	assert_true(_label_tree_contains(boot._shop_state_container, "Recompensa diaria"))
	assert_false(_label_tree_contains(boot._shop_state_container, "Coleta diaria"))

func test_visual_direction_v1_applies_surface_accents_without_changing_controls() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("social")
	await get_tree().process_frame
	var refresh_button := boot._action_buttons["show_social"] as Button
	var chat_button := boot._action_buttons["send_guild_chat"] as Button
	assert_not_null(refresh_button)
	assert_not_null(chat_button)
	assert_true(refresh_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_true(chat_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	var refresh_style := refresh_button.get_theme_stylebox("normal") as StyleBoxFlat
	var chat_style := chat_button.get_theme_stylebox("normal") as StyleBoxFlat
	assert_not_null(refresh_style)
	assert_not_null(chat_style)
	assert_eq(refresh_style.border_color, UiTokens.color("accent_social"))
	assert_eq(chat_style.border_color, UiTokens.button_style("cta", "normal", "accent_social").border_color)

	boot._show_screen("shop")
	await get_tree().process_frame
	var shop_button := boot._action_buttons["shop_purchase:alpha_redeem_small"] as Button
	assert_not_null(shop_button)
	var shop_style := shop_button.get_theme_stylebox("normal") as StyleBoxFlat
	assert_not_null(shop_style)
	assert_eq(shop_style.border_color, UiTokens.button_style("cta", "normal", "accent_shop").border_color)

func test_normal_surfaces_hide_internal_copy_terms() -> void:
	var forbidden_terms := PackedStringArray(["server-authoritative", "polling", "snapshot", "redeem", "alpha"])
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	SessionStore.base_state = _base_state_fixture()
	SessionStore.monetization_state = _shop_state_fixture()
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
	SessionStore.competition_state = {
		"matchmaking": {"player_power": 720, "candidate_count": 0, "selected_opponent": {}},
		"ranking": {"season": {"display_name": "Season alpha"}, "entries": []},
	}
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()

	for screen_id: String in ["entry", "refuge", "base", "social", "competition", "shop", "battle_summary"]:
		boot._show_screen(screen_id, false)
		await get_tree().process_frame
		var visible_text := _visible_text_tree(boot).to_lower()
		for term: String in forbidden_terms:
			assert_false(visible_text.contains(term), "%s should hide '%s' from normal UI copy." % [screen_id, term])

func test_boot_social_presenter_renders_chat_status_and_lab_badges() -> void:
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
	assert_string_contains(boot._timeline_label.text, "Sincronizacao disponivel apos login.")
	assert_string_contains(boot._timeline_label.text, "Meu username: fabio")
	assert_string_contains(boot._timeline_label.text, "Badge social: Save Normal | Badge save: Save Lab")
	assert_string_contains(boot._timeline_label.text, "Chat: 1 mensagem")
	assert_string_contains(boot._timeline_label.text, "Mensagem atual: tester_lab [lab]: Ola atual")
	assert_true(_label_tree_contains(boot._social_state_container, "Meu username"))
	assert_true(_label_tree_contains(boot._social_state_container, "Badge social: Save Normal"))
	assert_true(_label_tree_contains(boot._social_state_container, "Badge save: Save Lab"))
	assert_true(_label_tree_contains(boot._social_state_container, "Mensagens mais recentes. Esta tela busca novidades enquanto permanece aberta."))
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
	assert_true(_label_tree_contains(boot._social_state_container, "Meu username"))
	assert_true(_label_tree_contains(boot._social_state_container, "Sincronizacao disponivel apos login."))
	assert_true(_label_tree_contains(boot._social_state_container, "Nenhum amigo ainda. Digite um username e toque Adicionar amigo."))
	assert_true(_label_tree_contains(boot._social_state_container, "Crie uma guilda ou entre pelo nome para liberar membros, estruturas e chat."))
	assert_true(_label_tree_contains(boot._social_state_container, "Entre em uma guilda para liberar o chat."))
	await get_tree().process_frame

func test_social_auto_sync_timer_starts_only_for_social_with_account() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	boot._show_screen("social")
	await get_tree().process_frame
	assert_true(boot._social_auto_sync_timer.is_stopped())

	_prepare_account_state()
	boot._show_screen("social", false)
	await get_tree().process_frame
	assert_false(boot._social_auto_sync_timer.is_stopped())
	assert_eq(boot._social_auto_sync_timer.wait_time, 8.0)

	boot._show_screen("base", false)
	await get_tree().process_frame
	assert_true(boot._social_auto_sync_timer.is_stopped())

func test_social_auto_sync_timer_pauses_for_busy_and_offline_states() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()

	boot._show_screen("social")
	await get_tree().process_frame
	assert_false(boot._social_auto_sync_timer.is_stopped())

	boot._set_busy(true, "Testando pausa...")
	boot._sync_social_auto_sync_for_route()
	assert_true(boot._social_auto_sync_timer.is_stopped())
	assert_eq(boot._social_auto_sync_status_text(), "Sincronizacao pausada durante outra acao social.")

	boot._set_busy(false, "Teste concluido.")
	SessionStore.offline = true
	boot._sync_social_auto_sync_for_route()
	assert_true(boot._social_auto_sync_timer.is_stopped())
	assert_eq(boot._social_auto_sync_status_text(), "Sincronizacao pausada: sem conexao.")

func test_social_auto_sync_error_pauses_until_manual_refresh_succeeds() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	_prepare_account_state()

	boot._show_screen("social")
	await get_tree().process_frame
	assert_false(boot._social_auto_sync_timer.is_stopped())

	boot._social_auto_sync_last_error = "Falha temporaria."
	boot._sync_social_auto_sync_for_route()
	assert_true(boot._social_auto_sync_timer.is_stopped())
	assert_eq(boot._social_auto_sync_status_text(), "Sincronizacao pausada. Use Atualizar social para tentar novamente.")

	boot._social_auto_sync_last_error = ""
	boot._restart_social_auto_sync()
	assert_false(boot._social_auto_sync_timer.is_stopped())

func test_copy_social_username_uses_social_profile_without_network() -> void:
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
	boot._copy_social_username()
	await get_tree().process_frame

	assert_eq(boot._social_username_for_copy(), "fabio")
	assert_string_contains(boot._detail_label.text, "Username copiado: fabio")

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
	assert_string_contains(boot._timeline_label.text, "Treinos no ranking:")
	assert_true(_label_tree_contains(boot._competition_state_container, "Alvo de treino: sim | Pontua no ranking: nao"))
	assert_true(_label_tree_contains(boot._competition_state_container, "Progression Lab nao pontua competicao e fica fora do ranking."))
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
	assert_true(_label_tree_contains(boot._content_body, "recompensa XP +10"))
	assert_true(_label_tree_contains(boot._content_body, "vitoria"))

func test_boot_battle_running_renders_fullscreen_overlay_and_skip() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()

	boot._show_screen("battle_running")
	await get_tree().process_frame

	assert_eq(boot._current_screen, "battle_running")
	assert_not_null(boot._battle_fullscreen_overlay)
	assert_eq(boot.get_child(boot.get_child_count() - 1), boot._battle_fullscreen_overlay)
	assert_false(boot._app_chrome_root.visible)
	assert_false(boot._back_button.visible)
	assert_false(boot._route_shows_app_chrome("battle_running"))
	assert_not_null(boot._battle_visual)
	assert_null(boot._timeline_label)
	assert_true(boot._action_buttons.has("skip_battle_replay"))
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleDuelStage"))
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleDuelShellBand"))
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleDuelMatchupLabel"))
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleDuelProgressLabel"))
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleDuelStateLabel"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Draxos vs Treinador da Primeira Ruina"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Lances 0/2"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Aguardando primeiro lance"))
	assert_false(_label_tree_contains(boot._battle_fullscreen_overlay, "Autobattler"))
	assert_false(_label_tree_contains(boot._battle_fullscreen_overlay, "Timeline"))
	var skip_button := boot._action_buttons["skip_battle_replay"] as Button
	assert_eq(skip_button.name, "BattleSkipButton")
	assert_eq(skip_button.text, "Pular batalha")
	assert_true(skip_button.custom_minimum_size.x >= 132.0)
	assert_true(skip_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_true((skip_button.size_flags_horizontal & Control.SIZE_SHRINK_END) != 0)
	assert_eq((skip_button.get_parent() as HBoxContainer).alignment, BoxContainer.ALIGNMENT_END)
	assert_eq(skip_button.mouse_filter, Control.MOUSE_FILTER_STOP)

	boot._replay_running = true
	boot._sync_buttons()
	assert_false(skip_button.disabled)
	boot._skip_current_replay()
	assert_true(boot._skip_replay)

func test_boot_arena_replay_shell_highlights_duel_and_reward() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.arena_state = {
		"schema_version": "pve_arena_state_v1",
		"last_duel": {
			"battle_log": _arena_battle_log_fixture(),
			"rewards": _battle_rewards_fixture(),
		},
	}

	boot._show_screen(AppShellRouteContractScript.ROUTE_ARENA_REPLAY)
	await get_tree().process_frame

	assert_not_null(boot._battle_fullscreen_overlay)
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleDuelArenaContextLabel"))
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleDuelRewardLabel"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Duelo 2/3 da Arena"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Draxos vs Guardiao da Barreira"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Recompensa do duelo: XP +10"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "clear/aplicada no save"))

func test_boot_battle_summary_renders_reward_result_and_actions() -> void:
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()
	boot._battle_summary_skipped = true

	boot._show_screen("battle_summary")
	await get_tree().process_frame

	assert_eq(boot._current_screen, "battle_summary")
	assert_not_null(boot._battle_fullscreen_overlay)
	assert_false(boot._app_chrome_root.visible)
	assert_false(boot._back_button.visible)
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Resultado da batalha"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Vitoria"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Contra Treinador da Primeira Ruina"))
	assert_not_null(_find_node_by_name(boot._battle_fullscreen_overlay, "BattleSummaryOutcomeLabel"))
	assert_false(_label_tree_contains(boot._battle_fullscreen_overlay, "Vencedor"))
	assert_false(_label_tree_contains(boot._battle_fullscreen_overlay, "Duracao"))
	assert_false(_label_tree_contains(boot._battle_fullscreen_overlay, "Eventos"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Recompensa"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Recursos"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Progresso"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Proximo passo"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Nivel 8 | Poder 120"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Esta batalha somou XP +10."))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Nivel 10: doutrina de combate."))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "acompanhe producao, evolua a base"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "verificar a base"))
	assert_not_null(_find_button_by_text(boot._battle_fullscreen_overlay, "Voltar e verificar base"))
	assert_true(boot._action_buttons.has("return_refuge"))
	assert_true(boot._action_buttons.has("show_current_battle_logs"))
	assert_false(boot._action_buttons.has("replay_latest_battle"))
	assert_false(boot._action_buttons.has("show_battle_history"))
	assert_false(boot._action_buttons.has("request_battle"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("show_current_battle_logs"))

func test_boot_arena_battle_summary_uses_combat_reward_copy_without_ranking() -> void:
	_prepare_account_state()
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _arena_battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()
	boot._battle_summary_skipped = false

	boot._show_screen("battle_summary")
	await get_tree().process_frame

	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Resultado da Arena"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Combate"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Duelo 2/3 da Arena"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Adversario: Guardiao da Barreira"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Recompensa do duelo/clear: XP +10"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Recompensa aplicada: XP +10, Almas +0.8, Ossos +1 ja veio do servidor"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Proximo passo: continuar na Arena"))
	assert_false(_label_tree_contains(boot._battle_fullscreen_overlay, "Ranking"))
	assert_not_null(_find_button_by_text(boot._battle_fullscreen_overlay, "Voltar ao Refugio"))

func test_boot_battle_logs_render_current_battle_events() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()

	boot._show_screen("battle_logs")
	await get_tree().process_frame

	assert_eq(boot._current_screen, "battle_logs")
	assert_not_null(boot._battle_fullscreen_overlay)
	assert_false(boot._app_chrome_root.visible)
	assert_false(boot._back_button.visible)
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Logs da batalha"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Batalha iniciada"))
	assert_true(boot._action_buttons.has("return_battle_summary"))
	assert_true(boot._action_buttons.has("return_refuge"))
	assert_false(boot._action_buttons.has("show_battle_history"))

	boot._return_to_battle_summary()
	assert_eq(boot._current_screen, "battle_summary")

func test_boot_battle_summary_return_to_refuge_clears_lifecycle_state() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()
	SessionStore.last_battle_result_seen = false

	boot._show_screen("battle")
	boot._show_screen("battle_running")
	boot._battle_summary_skipped = true
	boot._show_screen("battle_summary")
	await get_tree().process_frame

	assert_eq(boot._current_screen, "battle_summary")
	assert_not_null(boot._battle_fullscreen_overlay)
	assert_true(boot._screen_history.size() >= 2)

	boot._replay_running = true
	boot._skip_replay = true
	boot._return_to_refuge()

	assert_eq(boot._current_screen, "refuge")
	assert_true(SessionStore.last_battle_result_seen)
	assert_true(boot._screen_history.is_empty())
	assert_false(boot._back_button.visible)
	assert_false(boot._replay_running)
	assert_false(boot._skip_replay)
	assert_false(boot._battle_summary_skipped)
	assert_null(boot._battle_fullscreen_overlay)
	assert_false(boot._app_chrome_root.visible)
	assert_true(boot._first_screen_root.visible)

func test_boot_play_battle_log_finishes_on_summary_route() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()

	await boot._play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

	assert_eq(boot._current_screen, "battle_summary")
	assert_false(boot._replay_running)
	assert_false(boot._skip_replay)
	assert_false(boot._battle_summary_skipped)
	assert_not_null(boot._battle_fullscreen_overlay)
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Resultado da batalha"))
	assert_true(boot._action_buttons.has("show_current_battle_logs"))
	assert_false(boot._action_buttons.has("show_battle_history"))
	assert_true(boot._action_buttons.has("return_refuge"))

func test_battle_summary_data_uses_battle_log_rewards_and_resource_state() -> void:
	var summary := BattleReplayPresenterScript.summary_data(
		_battle_log_fixture(),
		_battle_rewards_fixture(),
		{"almas": 7, "energia": 9, "diamante": 2}
	)

	assert_eq(str(summary.get("winner", "")), "player")
	assert_eq(str(summary.get("winner_label", "")), "Vitoria")
	assert_eq(str(summary.get("opponent_label", "")), "Treinador da Primeira Ruina")
	assert_string_contains(str(summary.get("outcome_text", "")), "Contra Treinador da Primeira Ruina")
	assert_eq(str(summary.get("duration_text", "")), "12.5s")
	assert_eq(int(summary.get("event_count", 0)), 2)
	assert_eq(str(summary.get("reward_text", "")), "XP +10, Almas +0.8, Ossos +1")
	assert_eq(str(summary.get("resources_text", "")), "Almas 7, Energia 9, Diamantes 2")
	assert_string_contains(str(summary.get("progress_text", "")), "Esta batalha somou XP +10.")
	assert_string_contains(str(summary.get("next_step_text", "")), "evolua a base")

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

func _find_button_by_text(root: Node, text: String) -> Button:
	if root == null:
		return null
	if root is Button and str((root as Button).text) == text:
		return root as Button
	for child: Node in root.get_children():
		var found := _find_button_by_text(child, text)
		if found != null:
			return found
	return null

func _button_text_index(root: Node, text: String) -> int:
	if root == null:
		return -1
	var buttons := root.find_children("*", "Button", true, false)
	for index in range(buttons.size()):
		var button := buttons[index] as Button
		if button != null and str(button.text) == text:
			return index
	return -1

func _render_preparation_in_arena_selection(boot: Node) -> Node:
	assert_null(_find_node_by_name(boot.get("_first_screen_root") as Node, "RefugeIcon_Preparacao"))
	boot.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(str(boot.get("_current_screen")), AppShellRouteContractScript.ROUTE_ARENA_SELECTION)
	assert_not_null(_find_node_by_name(boot.get("_content_body") as Node, "PreparationPanel"))
	return boot.get("_content_body") as Node

func _find_node_by_name(root: Node, node_name: String) -> Node:
	if root == null:
		return null
	if root.name == node_name:
		return root
	for child: Node in root.get_children():
		var found := _find_node_by_name(child, node_name)
		if found != null:
			return found
	return null

func _send_raw_click_to_boot(boot: Node, position: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	boot.call("_input", event)

func _click_button_via_viewport(button: Button) -> void:
	assert_not_null(button)
	if button == null:
		return
	var center := button.get_global_rect().get_center()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = center
	get_viewport().push_input(press)
	await get_tree().process_frame
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = center
	get_viewport().push_input(release)
	await get_tree().process_frame

func _send_overlay_web_button_command(boot: Node, button: Button) -> void:
	assert_not_null(button)
	if boot == null or button == null:
		return
	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	assert_not_null(overlay)
	if overlay == null:
		return
	var center := button.get_global_rect().get_center()
	boot.call("_handle_web_overlay_input_command", [JSON.stringify({
		"type": "button",
		"path": str(overlay.get_path_to(button)),
		"x": center.x,
		"y": center.y,
		"text": str(button.text),
	})])
	await wait_process_frames(2)

func _send_overlay_web_focus_command(boot: Node, input: LineEdit) -> void:
	assert_not_null(input)
	if boot == null or input == null:
		return
	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	assert_not_null(overlay)
	if overlay == null:
		return
	var center := input.get_global_rect().get_center()
	boot.call("_handle_web_overlay_input_command", [JSON.stringify({
		"type": "focus",
		"path": str(overlay.get_path_to(input)),
		"x": center.x,
		"y": center.y,
		"text": str(input.text),
	})])
	await wait_process_frames(2)

func _send_overlay_web_text_command(boot: Node, input: LineEdit, text: String, replace_existing: bool = false) -> void:
	assert_not_null(input)
	if boot == null or input == null:
		return
	var overlay := _find_node_by_name(boot, "ModeShellMenuOverlay")
	assert_not_null(overlay)
	if overlay == null:
		return
	boot.call("_handle_web_overlay_input_command", [JSON.stringify({
		"type": "text",
		"path": str(overlay.get_path_to(input)),
		"text": text,
		"replace": replace_existing,
	})])
	await wait_process_frames(2)

func _overlay_control_diagnostics_has_line_edit(boot: Node, expected_text: String) -> bool:
	if boot == null or boot.get("_mode_shell_overlay_controller") == null:
		return false
	var controls: Array = boot._mode_shell_overlay_controller.control_diagnostics()
	for item: Variant in controls:
		var control := item as Dictionary
		if str(control.get("type", "")) == "line_edit" and str(control.get("text", "")) == expected_text:
			return true
	return false

func _set_required_update_gate(boot: Node) -> void:
	boot.set("_update_gate", {
		"block_online": true,
		"summary": "Update obrigatorio antes de usar recursos online.",
		"detail": "Baixe a nova build pelo portal.",
		"minimum_supported_version": "0.0.99-alpha.0",
		"minimum_supported_version_code": 99,
	})

func _child_index_by_name(root: Node, node_name: String) -> int:
	if root == null:
		return -1
	var children := root.get_children()
	for index in range(children.size()):
		var child := children[index] as Node
		if child != null and child.name == node_name:
			return index
	return -1

func _social_input_text_for_test(input: LineEdit) -> String:
	if input == null:
		return ""
	return input.text.strip_edges()

func _label_tree_contains(root: Node, needle: String) -> bool:
	if root == null:
		return false
	if root is Label and str((root as Label).text).contains(needle):
		return true
	for child: Node in root.get_children():
		if _label_tree_contains(child, needle):
			return true
	return false

func _visible_text_tree(root: Node) -> String:
	if root == null:
		return ""
	if root is CanvasItem and not (root as CanvasItem).visible:
		return ""
	var lines := PackedStringArray()
	if root is Label:
		lines.append(str((root as Label).text))
	elif root is Button:
		lines.append(str((root as Button).text))
	for child: Node in root.get_children():
		var child_text := _visible_text_tree(child)
		if child_text != "":
			lines.append(child_text)
	return "\n".join(lines)

func _panel_tree_count(root: Node) -> int:
	if root == null:
		return 0
	var count := 1 if root is PanelContainer else 0
	for child: Node in root.get_children():
		count += _panel_tree_count(child)
	return count

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

func _action_consumer_script_paths() -> PackedStringArray:
	return PackedStringArray([
		"res://modes/boot/boot.gd",
		"res://modes/boot/boot_runtime.gd",
		"res://modes/boot/surfaces/base_surface_presenter.gd",
		"res://modes/boot/surfaces/battle_replay_presenter.gd",
		"res://modes/boot/surfaces/competition_surface_presenter.gd",
		"res://modes/boot/surfaces/hub_account_surface_presenter.gd",
		"res://modes/boot/surfaces/hub_surface_common_presenter.gd",
		"res://modes/boot/surfaces/hub_surface_entry_presenter.gd",
		"res://modes/boot/surfaces/hub_surface_full_presenter.gd",
		"res://modes/boot/surfaces/hub_surface_preparation_presenter.gd",
		"res://modes/boot/surfaces/hub_surface_presenter.gd",
		"res://modes/boot/surfaces/hub_surface_refuge_popup_presenter.gd",
		"res://modes/boot/surfaces/hub_surface_refuge_scene_presenter.gd",
		"res://modes/boot/surfaces/shop_surface_presenter.gd",
		"res://modes/boot/surfaces/social_surface_presenter.gd",
		"res://modes/boot/surfaces/surface_ui_helpers.gd",
		"res://modes/boot/ui/mode_shell_launcher.gd",
	])

func _flow_script_paths() -> PackedStringArray:
	return PackedStringArray([
		"res://modes/boot/flows/account_session_flow.gd",
		"res://modes/boot/flows/account_form_contract.gd",
		"res://modes/boot/flows/preparation_action_contract.gd",
		"res://modes/boot/flows/surface_action_flow.gd",
		"res://modes/boot/flows/battle_lifecycle_flow.gd",
	])

func _centralized_action_literals() -> PackedStringArray:
	return PackedStringArray([
		AppShellActionContractScript.ACTION_ENTER_GUEST,
		AppShellActionContractScript.ACTION_ENTER_REFUGE,
		AppShellActionContractScript.ACTION_OPEN_CREATE_ACCOUNT,
		AppShellActionContractScript.ACTION_CHECK_UPDATE,
		AppShellActionContractScript.ACTION_EMAIL_SIGN_UP,
		AppShellActionContractScript.ACTION_EMAIL_SIGN_IN,
		AppShellActionContractScript.ACTION_REFRESH_SESSION,
		AppShellActionContractScript.ACTION_RESET_SESSION,
		AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE,
		AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL,
		AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB,
		AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB,
		AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB,
		AppShellActionContractScript.ACTION_REQUEST_BATTLE,
		AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE,
		AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY,
		AppShellActionContractScript.ACTION_SKIP_REPLAY,
		AppShellActionContractScript.ACTION_RETURN_REFUGE,
		AppShellActionContractScript.ACTION_REPLAY_LATEST,
		AppShellActionContractScript.ACTION_SHOW_CURRENT_BATTLE_LOGS,
		AppShellActionContractScript.ACTION_RETURN_BATTLE_SUMMARY,
		AppShellActionContractScript.ACTION_SHOW_BASE,
		AppShellActionContractScript.ACTION_UPGRADE_NUCLEO,
		AppShellActionContractScript.ACTION_SHOW_SOCIAL,
		AppShellActionContractScript.ACTION_COPY_SOCIAL_USERNAME,
		AppShellActionContractScript.ACTION_ADD_FRIEND,
		AppShellActionContractScript.ACTION_CREATE_GUILD,
		AppShellActionContractScript.ACTION_JOIN_GUILD,
		AppShellActionContractScript.ACTION_SEND_GUILD_CHAT,
		AppShellActionContractScript.ACTION_SHOW_MATCHMAKING,
		AppShellActionContractScript.ACTION_SHOW_RANKING,
		AppShellActionContractScript.ACTION_SHOW_SHOP,
		AppShellActionContractScript.ACTION_BUY_PREMIUM_ALPHA,
		AppShellActionContractScript.ACTION_GRANT_DIAMOND_ALPHA,
		AppShellActionContractScript.ACTION_CLAIM_DAILY_REWARD,
		AppShellActionContractScript.PREFIX_SELECT_BASE_STRUCTURE,
		AppShellActionContractScript.PREFIX_UPGRADE_BASE_STRUCTURE,
		AppShellActionContractScript.PREFIX_SHOP_PURCHASE,
		AppShellActionContractScript.PREFIX_CLAIM_REWARD,
		AppShellActionContractScript.PREFIX_ARENA_START,
		AppShellActionContractScript.PREFIX_ARENA_CHOOSE_BUFF,
		AppShellActionContractScript.PREFIX_BATTLE_REPLAY,
		AppShellActionContractScript.PREFIX_OPEN_MODE_SHELL,
		AppShellActionContractScript.PREFIX_MODE_DISABLED,
	])

func _forbidden_flow_ui_fragments() -> PackedStringArray:
	return PackedStringArray([
		"Button.new(",
		"Label.new(",
		"LineEdit.new(",
		"PanelContainer.new(",
		"VBoxContainer.new(",
		"HBoxContainer.new(",
		"GridContainer.new(",
		"ScrollContainer.new(",
		"MarginContainer.new(",
		"PopupPanel.new(",
		"Control.new(",
		"ColorRect.new(",
		"TextureRect.new(",
	])

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
		"SessionStore.build =",
		"SessionStore.base_state =",
		"SessionStore.social_state =",
		"SessionStore.competition_state =",
		"SessionStore.monetization_state =",
		"SessionStore.crafting_state =",
		"SessionStore.combat_build_state =",
		"SessionStore.create_request_id(",
		"configure_save_type",
	])

func _reset_session_store_for_test() -> void:
	SessionStore.clear_session()

func _apply_preparation_instrument_fixture(active_instrument: String) -> bool:
	return SessionStore.apply_build_result({
		"ok": true,
		"save_type": SessionStore.SAVE_TYPE_NORMAL,
		"build": {"weapon_type": active_instrument, "weapon_level": 4},
		"combat_build": {
			"power": 243,
			"weapon_type": active_instrument,
			"weapon_level": 4,
			"inventory": [],
			"potion_slots": [{"slot_index": 1, "potion_id": null, "behavior": {}}],
			"spell_slots": [],
			"equipment_options": {
				"weapons": [
					{"id": "varinha_cinzas", "display_name": "Varinha de Cinzas", "unlocked": true, "equipped": active_instrument == "varinha_cinzas"},
					{"id": "athame_hematico", "display_name": "Athame Hematico", "unlocked": true, "equipped": active_instrument == "athame_hematico"},
				],
			},
		},
	})

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

func _battle_log_fixture() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "battle-fullscreen-1",
		"seed": "seed-fullscreen",
		"mode": ProjectInfo.FIRST_SLICE_MODE,
		"duration": 12.5,
		"participants": {
			"player": {"id": "player-1", "display_name": "Draxos"},
			"opponent": {"id": "bot-1", "display_name": "Treinador da Primeira Ruina", "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 0.0, "seq": 2, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
		],
	}

func _arena_battle_log_fixture() -> Dictionary:
	var battle_log := _battle_log_fixture()
	battle_log["battle_id"] = "arena-duel-fullscreen-1"
	battle_log["mode"] = "PVE_ARENA_V1"
	battle_log["metadata"] = {
		"mode": "PVE_ARENA_V1",
		"arena_id": "arena_cinzas_curta",
		"difficulty_id": "s1_d01_aprendiz",
		"duel_index": 2,
		"duel_count": 3,
	}
	battle_log["participants"] = {
		"player": {"id": "player-1", "display_name": "Draxos"},
		"opponent": {"id": "bot-arena-2", "display_name": "Guardiao da Barreira", "is_bot": true},
	}
	return battle_log

func _battle_rewards_fixture() -> Dictionary:
	return {
		"type": "FIRST_SLICE_SIM",
		"resources": {"xp": 10, "almas": 0.8, "ossos": 1},
	}

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
				"label": "Recompensa diaria",
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
