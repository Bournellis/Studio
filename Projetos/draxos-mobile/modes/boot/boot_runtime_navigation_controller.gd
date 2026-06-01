extends "res://modes/boot/boot_runtime_flow_facade.gd"

# Screen lifecycle, route normalization, history, and chrome visibility.
func _show_screen(screen_id: String, push_history: bool = true) -> void:
	screen_id = AppShellRouteContractScript.push_route(_screen_history, _current_screen, screen_id, push_history)
	_current_screen = screen_id
	if screen_id != ROUTE_BATTLE_ENTRY:
		_battle_request_splash_active = false
	_apply_orientation_for_route(screen_id)
	_action_buttons.clear()
	_current_action_grid = null
	_timeline_label = null
	_update_output_label = null
	_base_state_container = null
	_modes_ops_state_container = null
	_social_state_container = null
	_competition_state_container = null
	_shop_state_container = null
	_refuge_menu_popup = null
	_social_friend_input = null
	_social_guild_input = null
	_social_chat_input = null
	_auth_email_input = null
	_auth_password_input = null
	_auth_username_input = null
	_auth_invite_input = null
	_immersive_feedback_panel = null
	_immersive_status_label = null
	_immersive_detail_label = null
	_immersive_error_label = null
	_battle_visual = null
	_clear_battle_fullscreen_overlay()
	_clear_mode_fullscreen_overlay()
	_battle_replay_presenter.clear()
	_error_label.text = ""
	if _route_shows_first_screen(screen_id):
		_clear_first_screen_root()
	_clear_content_body()
	if _content_scroll != null:
		_content_scroll.scroll_vertical = 0
	_content_title.text = _screen_title(screen_id)
	_back_button.visible = _route_shows_app_chrome(screen_id) and _route_supports_back(screen_id)
	_sync_app_chrome_for_route(screen_id)
	_sync_nav_buttons()
	match screen_id:
		SCREEN_HUB:
			_render_entry_screen()
		SCREEN_REFUGE:
			_render_refuge_screen()
		ROUTE_ACCOUNT:
			_render_account_screen()
		SCREEN_BATTLE:
			_render_battle_screen()
		ROUTE_BATTLE_RUNNING:
			_render_battle_running_screen()
		ROUTE_BATTLE_SUMMARY:
			_render_battle_summary_screen()
		ROUTE_BATTLE_LOGS:
			_render_battle_logs_screen()
		ROUTE_ARENA_SELECTION:
			_render_arena_selection_screen()
		ROUTE_ARENA_LOADOUT:
			_render_arena_loadout_screen()
		ROUTE_ARENA_ACTIVE:
			_render_arena_active_screen()
		ROUTE_ARENA_REPLAY:
			_render_arena_replay_screen()
		ROUTE_ARENA_BUFF_CHOICE:
			_render_arena_buff_choice_screen()
		ROUTE_ARENA_SUMMARY:
			_render_arena_summary_screen()
		ROUTE_MODE_HUB:
			_render_mode_hub_screen()
		ROUTE_MODES_OPS:
			_render_modes_ops_screen()
		SCREEN_BASE:
			_render_base_screen()
		SCREEN_SOCIAL:
			_render_social_screen()
		SCREEN_COMPETITION:
			_render_competition_screen()
		SCREEN_SHOP:
			_render_shop_screen()
		ROUTE_MODE_SHELL:
			_render_mode_shell_screen()
		_:
			_render_entry_screen()
	_sync_status_from_session()
	_emit_client_event("screen_opened", {
		"screen": screen_id,
		"has_account": SessionStore.has_account_state(),
		"offline": SessionStore.offline,
	})
	_sync_social_auto_sync_for_route()
func _show_refuge_root(message: String = "") -> void:
	_show_screen(AppShellRouteContractScript.clear_for_refuge_return(_screen_history), false)
	if message != "":
		_show_notice(message)
func _show_surface_screen(screen_id: String) -> void:
	var target_screen := _normalize_route(screen_id)
	var current_screen := _normalize_route(_current_screen)
	_show_screen(target_screen, target_screen != current_screen)
func _go_back() -> void:
	if _is_busy:
		return
	if _close_refuge_menu_popup_if_open():
		return
	var previous := AppShellRouteContractScript.pop_back_or_root(_screen_history)
	if previous == SCREEN_HUB and _session_uses_refuge_root():
		previous = SCREEN_REFUGE
		_screen_history.clear()
	_show_screen(previous, false)
func _session_uses_refuge_root() -> bool:
	if SessionStore.has_valid_access_token():
		return true
	if SessionStore.has_account_state():
		return true
	return SessionStore.is_progression_lab_local_only()
func _normalize_route(route_id: String) -> String:
	return AppShellRouteContractScript.normalize(route_id)
func _route_supports_back(route_id: String) -> bool:
	return AppShellRouteContractScript.supports_back(route_id)
func _route_prefers_landscape(route_id: String) -> bool:
	return AppShellRouteContractScript.prefers_landscape(route_id)
func _route_shows_app_chrome(route_id: String) -> bool:
	return AppShellRouteContractScript.shows_app_chrome(route_id)
func _route_shows_first_screen(route_id: String) -> bool:
	return AppShellRouteContractScript.uses_immersive_layer(route_id)
func _sync_app_chrome_for_route(route_id: String) -> void:
	if _app_chrome_root != null and is_instance_valid(_app_chrome_root):
		_app_chrome_root.visible = _route_shows_app_chrome(route_id)
	if _first_screen_root != null and is_instance_valid(_first_screen_root):
		_first_screen_root.visible = _route_shows_first_screen(route_id)
func _apply_orientation_for_route(_route_id: String) -> void:
	if OS.get_name() != "Android":
		return
	DisplayServer.screen_set_orientation(APP_ORIENTATION_PORTRAIT)
