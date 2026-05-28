extends GutTest

const BootScreenScript = preload("res://modes/boot/boot.gd")
const AppShellRouteContractScript = preload("res://modes/boot/ui/app_shell_route_contract.gd")
const BaseSurfacePresenterScript = preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const BattleReplayPresenterScript = preload("res://modes/boot/surfaces/battle_replay_presenter.gd")
const MobileUiContractScript = preload("res://modes/boot/ui/mobile_ui_contract.gd")
const TouchScrollContainerScript = preload("res://modes/boot/ui/touch_scroll_container.gd")

func before_each() -> void:
	_reset_session_store_for_test()

func after_each() -> void:
	ProjectSettings.set_setting("draxos_mobile/ui/force_compact_layout", false)
	_reset_session_store_for_test()

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
	assert_true(_label_tree_contains(boot._first_screen_root, "Conta"))
	assert_false(_label_tree_contains(boot._content_body, "Conta"))
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
	var sign_up_button := boot._action_buttons["email_sign_up"] as Button
	assert_true(sign_up_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)
	assert_eq(sign_up_button.mouse_filter, Control.MOUSE_FILTER_PASS)
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

func test_boot_refugio_home_renders_altar_hotspots_and_account_route() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_eq(boot._current_screen, "entry")
	assert_true(_label_tree_contains(boot._first_screen_root, "Conta"))
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
	assert_not_null(_find_node_by_name(boot._first_screen_root, "RefugeHotspotPanel"))
	assert_true(_label_tree_contains(boot._first_screen_root, "Caminhos do Refugio"))
	assert_false(_label_tree_contains(boot._content_body, "Altar do Mago"))
	assert_not_null(_find_node_by_name(boot._first_screen_root, "RefugeFooterPanel"))
	assert_null(boot._auth_email_input)
	assert_false(boot._action_buttons.has("email_sign_up"))

	assert_null(_find_button_by_text(boot._first_screen_root, "Base"))
	assert_false(boot._action_buttons.has("show_base"))
	assert_true(boot._action_buttons.has("collect_base"))
	assert_not_null(boot._base_state_container)
	assert_null(_find_button_by_text(boot._first_screen_root, "Atualizar Refugio"))
	assert_true(_label_tree_contains(boot._first_screen_root, "Altar do Refugio"))
	assert_true(_label_tree_contains(boot._first_screen_root, "Entre ou use Guest dev para sincronizar."))
	assert_not_null(_find_button_by_text(boot._first_screen_root, "Coletar"))

	for hotspot_text: String in ["Batalha", "Social", "Competicao", "Loja", "Perfil"]:
		var hotspot := _find_button_by_text(boot._first_screen_root, hotspot_text)
		assert_not_null(hotspot, "Refugio should expose hotspot '%s'." % hotspot_text)
		assert_true(hotspot.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)

	var account_hotspot := _find_button_by_text(boot._first_screen_root, "Perfil")
	account_hotspot.pressed.emit()
	assert_eq(boot._current_screen, "account")
	assert_true(boot._app_chrome_root.visible)
	assert_false(boot._first_screen_root.visible)
	assert_not_null(boot._auth_email_input)
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
	assert_false(AppShellRouteContractScript.is_battle_mode("base"))
	assert_true(AppShellRouteContractScript.is_first_screen("entry"))
	assert_false(AppShellRouteContractScript.is_first_screen("refugio"))
	assert_true(AppShellRouteContractScript.is_refuge_home("refugio"))
	assert_true(AppShellRouteContractScript.uses_immersive_layer("refuge"))
	assert_false(AppShellRouteContractScript.is_fullscreen_gameplay("battle"))
	assert_true(AppShellRouteContractScript.is_fullscreen_gameplay("battle_running"))
	assert_true(AppShellRouteContractScript.is_fullscreen_gameplay("battle_summary"))
	assert_false(AppShellRouteContractScript.shows_app_chrome("refuge_home"))
	assert_true(AppShellRouteContractScript.shows_app_chrome("battle"))
	assert_false(AppShellRouteContractScript.shows_app_chrome("battle_running"))
	assert_false(AppShellRouteContractScript.shows_app_chrome("battle_summary"))
	assert_eq(AppShellRouteContractScript.summary_route_for("battle_running"), "battle_summary")
	assert_eq(AppShellRouteContractScript.summary_route_for("battle"), "battle_summary")
	assert_eq(AppShellRouteContractScript.summary_route_for("base"), "base_management")
	assert_true(AppShellRouteContractScript.is_safe_replay_action("skip_battle_replay"))
	assert_false(AppShellRouteContractScript.is_safe_replay_action("show_latest_battle"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("show_battle_history"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("battle_replay:11111111-1111-4111-8111-111111111111"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("replay_latest_battle"))
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

func test_boot_account_panel_renders_login_save_session_and_update_gate() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	boot._show_screen("account")

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
	boot._show_screen("account", false)
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
	boot._show_screen("account")

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
	assert_true(_panel_tree_count(boot._base_state_container) >= 3)
	var upgrade_button := boot._action_buttons["upgrade_base_structure:nucleo_energia"] as Button
	assert_false(upgrade_button.disabled)
	assert_eq(upgrade_button.mouse_filter, Control.MOUSE_FILTER_PASS)
	assert_true(upgrade_button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET)

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

	assert_true(_label_tree_contains(boot._base_state_container, "Rotina do Refugio"))
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
	assert_true(_panel_tree_count(boot._shop_state_container) >= 4)
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
	assert_not_null(boot._timeline_label)
	assert_true(boot._action_buttons.has("skip_battle_replay"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Autobattler"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Timeline"))
	var skip_button := boot._action_buttons["skip_battle_replay"] as Button
	assert_eq(skip_button.text, "Pular")
	assert_eq(skip_button.custom_minimum_size.x, 0.0)
	assert_true(skip_button.custom_minimum_size.y >= 64.0)
	assert_true((skip_button.size_flags_horizontal & Control.SIZE_EXPAND_FILL) != 0)
	assert_eq(skip_button.mouse_filter, Control.MOUSE_FILTER_STOP)

	boot._replay_running = true
	boot._sync_buttons()
	assert_false(skip_button.disabled)
	boot._skip_current_replay()
	assert_true(boot._skip_replay)

func test_boot_battle_summary_renders_fullscreen_stats_resources_and_actions() -> void:
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
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Resumo da batalha - replay pulado"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Vencedor"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Vitoria"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Duracao"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "12.5s"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Eventos"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Recompensa"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "FIRST_SLICE_SIM xp=10, almas=0.8, ossos=1"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Recursos"))
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "energia=200"))
	assert_true(boot._action_buttons.has("return_refuge"))
	assert_true(boot._action_buttons.has("replay_latest_battle"))
	assert_true(boot._action_buttons.has("show_battle_history"))
	assert_false(boot._action_buttons.has("request_battle"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("replay_latest_battle"))
	assert_true(AppShellRouteContractScript.is_read_only_battle_action("show_battle_history"))

func test_boot_battle_summary_return_to_refuge_clears_lifecycle_state() -> void:
	var boot = BootScreenScript.new()
	add_child_autofree(boot)
	SessionStore.last_battle_log = _battle_log_fixture()
	SessionStore.last_battle_rewards = _battle_rewards_fixture()

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
	assert_true(_label_tree_contains(boot._battle_fullscreen_overlay, "Resumo da batalha"))
	assert_true(boot._action_buttons.has("return_refuge"))

func test_battle_summary_data_uses_battle_log_rewards_and_resource_snapshot() -> void:
	var summary := BattleReplayPresenterScript.summary_data(
		_battle_log_fixture(),
		_battle_rewards_fixture(),
		{"almas": 7, "energia": 9, "diamante": 2}
	)

	assert_eq(str(summary.get("winner", "")), "player")
	assert_eq(str(summary.get("winner_label", "")), "Vitoria")
	assert_eq(str(summary.get("duration_text", "")), "12.5s")
	assert_eq(int(summary.get("event_count", 0)), 2)
	assert_eq(str(summary.get("reward_text", "")), "FIRST_SLICE_SIM xp=10, almas=0.8, ossos=1")
	assert_eq(str(summary.get("resources_text", "")), "almas=7, energia=9, diamante=2")

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
