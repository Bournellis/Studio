class_name DraxosModeShellOverlayController
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellActionRouterScript := preload("res://modes/boot/ui/app_shell_action_router.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")

const _OVERLAY_ACTION_ROUTES := {
	AppShellActionContractScript.ACTION_OPEN_ARENA: AppShellRouteContractScript.ROUTE_ARENA_SELECTION,
	AppShellActionContractScript.ACTION_SHOW_BASE: AppShellRouteContractScript.ROUTE_BASE,
	AppShellActionContractScript.ACTION_SHOW_SHOP: AppShellRouteContractScript.ROUTE_SHOP,
	AppShellActionContractScript.ACTION_SHOW_SOCIAL: AppShellRouteContractScript.ROUTE_SOCIAL,
	AppShellActionContractScript.ACTION_SHOW_ACCOUNT: AppShellRouteContractScript.ROUTE_ACCOUNT,
}

var _root: Control
var _backdrop: ColorRect
var _panel: PanelContainer
var _content_title: Label
var _status_label: Label
var _detail_label: Label
var _error_label: Label
var _back_button: Button
var _close_button: Button
var _content_scroll: ScrollContainer
var _content_body: VBoxContainer
var _current_route := ""
var _history: Array[String] = []
var _saved_targets: Dictionary = {}

func is_open() -> bool:
	return _root != null and is_instance_valid(_root)

func current_route() -> String:
	return _current_route

func history_size() -> int:
	return _history.size()

func supports_action(action_id: String) -> bool:
	return _route_for_action(action_id) != ""

func open_for_action(host: Node, action_id: String) -> bool:
	if not supports_action(action_id):
		return false
	_ensure_open(host)
	var route_id := _route_for_action(action_id)
	if route_id != "":
		show_screen(host, route_id, _current_route != "" and route_id != _current_route)
	_detail_label.text = "Abrindo a superficie sobre o Bosque..."
	_sync_busy_buttons(host)
	return true

func show_screen(host: Node, route_id: String, push_history: bool = true) -> void:
	_ensure_open(host)
	var target := AppShellRouteContractScript.normalize(route_id)
	if push_history and _current_route != "" and target != _current_route:
		_history.append(_current_route)
	_current_route = target
	_prepare_host_for_route(host, target)
	host.call("_render_route_contents", target)
	host.call("_sync_status_from_session")
	var context := _as_dictionary(host.call("_action_context"))
	host.call("_emit_client_event", "screen_opened", {
		"screen": target,
		"host_screen": AppShellRouteContractScript.ROUTE_MODE_SHELL,
		"overlay": true,
		"has_account": bool(context.get("has_account", false)),
		"offline": bool(context.get("offline", false)),
	})
	host.call("_sync_social_auto_sync_for_route")

func go_back(host: Node) -> bool:
	if not is_open():
		return false
	if _close_blocked(host):
		_show_blocked_message(host)
		return true
	if not _history.is_empty():
		show_screen(host, str(_history.pop_back()), false)
		return true
	close(host)
	return true

func close(host: Node) -> bool:
	if not is_open():
		return false
	if _close_blocked(host):
		_show_blocked_message(host)
		return false
	host.call("_clear_battle_fullscreen_overlay")
	_restore_host_targets(host)
	_set_bosque_paused(host, false)
	if is_instance_valid(_root):
		_root.queue_free()
	_root = null
	_backdrop = null
	_panel = null
	_current_route = ""
	_history.clear()
	host.call("_sync_status_from_session")
	return true

func force_close(host: Node) -> void:
	if not is_open():
		return
	host.call("_clear_battle_fullscreen_overlay")
	_restore_host_targets(host)
	_set_bosque_paused(host, false)
	if is_instance_valid(_root):
		_root.queue_free()
	_root = null
	_current_route = ""
	_history.clear()

func fullscreen_parent() -> Control:
	if is_open():
		return _root
	return null

func sync_layout(host: Node) -> void:
	if not is_open():
		return
	var viewport_size: Vector2 = host.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		var host_control := host as Control
		viewport_size = host_control.size if host_control != null else Vector2(1280, 720)
	var compact: bool = bool(host.get("_compact_layout")) or viewport_size.x <= 820.0
	var safe_margin: float = 12.0 if compact else 24.0
	if compact:
		_panel.anchor_left = 0.0
		_panel.anchor_top = 0.0
		_panel.anchor_right = 1.0
		_panel.anchor_bottom = 1.0
		_panel.offset_left = safe_margin
		_panel.offset_right = -safe_margin
		_panel.offset_top = maxf(28.0, viewport_size.y * 0.08)
		_panel.offset_bottom = -safe_margin
	else:
		var panel_width := clampf(viewport_size.x * 0.42, 440.0, 640.0)
		_panel.anchor_left = 1.0
		_panel.anchor_top = 0.0
		_panel.anchor_right = 1.0
		_panel.anchor_bottom = 1.0
		_panel.offset_left = -panel_width - safe_margin
		_panel.offset_right = -safe_margin
		_panel.offset_top = safe_margin
		_panel.offset_bottom = -safe_margin

func sync_controls(host: Node) -> void:
	if not is_open():
		return
	sync_layout(host)
	_sync_busy_buttons(host)

func bind_targets_for_tests(host: Node) -> void:
	_ensure_open(host)

func _ensure_open(host: Node) -> void:
	if is_open():
		sync_layout(host)
		return
	_build_overlay(host)
	host.add_child(_root)
	_bind_host_targets(host)
	_set_bosque_paused(host, true)
	sync_layout(host)

func _build_overlay(host: Node) -> void:
	_root = Control.new()
	_root.name = "ModeShellMenuOverlay"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_backdrop = ColorRect.new()
	_backdrop.name = "ModeShellMenuBackdrop"
	_backdrop.color = Color(0.02, 0.025, 0.03, 0.64)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_backdrop)

	_panel = PanelContainer.new()
	_panel.name = "ModeShellMenuPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", UiTokens.panel_style_from_tokens("bg_panel", "border_active", bool(host.get("_compact_layout")), "accent_refuge", 1, 8, 12))
	_root.add_child(_panel)

	var shell := VBoxContainer.new()
	shell.name = "ModeShellMenuLayout"
	shell.add_theme_constant_override("separation", 10)
	shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shell.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel.add_child(shell)

	var header := HBoxContainer.new()
	header.name = "ModeShellMenuHeader"
	header.add_theme_constant_override("separation", 8)
	shell.add_child(header)

	_back_button = Button.new()
	_back_button.name = "ModeShellMenuBackButton"
	_back_button.text = "Voltar"
	_back_button.pressed.connect(func() -> void:
		go_back(host)
	)
	if host.has_method("_prepare_touch_button"):
		host.call("_prepare_touch_button", _back_button)
	header.add_child(_back_button)

	_content_title = Label.new()
	_content_title.name = "ModeShellMenuTitle"
	_content_title.text = "Bosque"
	_content_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_content_title.add_theme_font_size_override("font_size", 20)
	_content_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	header.add_child(_content_title)

	_close_button = Button.new()
	_close_button.name = "ModeShellMenuCloseButton"
	_close_button.text = "Fechar"
	_close_button.pressed.connect(func() -> void:
		close(host)
	)
	if host.has_method("_prepare_touch_button"):
		host.call("_prepare_touch_button", _close_button)
	header.add_child(_close_button)

	_status_label = Label.new()
	_status_label.name = "ModeShellMenuStatus"
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	shell.add_child(_status_label)

	_detail_label = Label.new()
	_detail_label.name = "ModeShellMenuDetail"
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.add_theme_color_override("font_color", UiTokens.color("text_muted"))
	shell.add_child(_detail_label)

	_error_label = Label.new()
	_error_label.name = "ModeShellMenuError"
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.add_theme_color_override("font_color", UiTokens.color("status_error"))
	shell.add_child(_error_label)

	_content_scroll = ScrollContainer.new()
	_content_scroll.name = "ModeShellMenuScroll"
	_content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shell.add_child(_content_scroll)

	_content_body = VBoxContainer.new()
	_content_body.name = "ModeShellMenuBody"
	_content_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_theme_constant_override("separation", 10)
	_content_scroll.add_child(_content_body)

func _bind_host_targets(host: Node) -> void:
	_saved_targets = {
		"status_label": host.get("_status_label"),
		"detail_label": host.get("_detail_label"),
		"error_label": host.get("_error_label"),
		"back_button": host.get("_back_button"),
		"content_title": host.get("_content_title"),
		"content_scroll": host.get("_content_scroll"),
		"content_body": host.get("_content_body"),
		"action_buttons": host.get("_action_buttons"),
		"current_action_grid": host.get("_current_action_grid"),
	}
	host.set("_status_label", _status_label)
	host.set("_detail_label", _detail_label)
	host.set("_error_label", _error_label)
	host.set("_back_button", _back_button)
	host.set("_content_title", _content_title)
	host.set("_content_scroll", _content_scroll)
	host.set("_content_body", _content_body)
	host.set("_action_buttons", {})
	host.set("_current_action_grid", null)

func _restore_host_targets(host: Node) -> void:
	if _saved_targets.is_empty():
		return
	host.set("_status_label", _saved_targets.get("status_label"))
	host.set("_detail_label", _saved_targets.get("detail_label"))
	host.set("_error_label", _saved_targets.get("error_label"))
	host.set("_back_button", _saved_targets.get("back_button"))
	host.set("_content_title", _saved_targets.get("content_title"))
	host.set("_content_scroll", _saved_targets.get("content_scroll"))
	host.set("_content_body", _saved_targets.get("content_body"))
	host.set("_action_buttons", _saved_targets.get("action_buttons", {}))
	host.set("_current_action_grid", _saved_targets.get("current_action_grid"))
	_saved_targets.clear()

func _prepare_host_for_route(host: Node, route_id: String) -> void:
	if route_id != AppShellRouteContractScript.ROUTE_ARENA_ACTIVE:
		host.set_meta("arena_active_preparation_open", false)
	if route_id != AppShellRouteContractScript.ROUTE_BATTLE_ENTRY:
		host.set("_battle_request_splash_active", false)
	host.call("_apply_orientation_for_route", AppShellRouteContractScript.ROUTE_MODE_SHELL)
	(host.get("_action_buttons") as Dictionary).clear()
	host.set("_current_action_grid", null)
	host.set("_timeline_label", null)
	host.set("_update_output_label", null)
	host.set("_base_state_container", null)
	host.set("_social_state_container", null)
	host.set("_competition_state_container", null)
	host.set("_shop_state_container", null)
	host.set("_refuge_menu_popup", null)
	host.set("_social_friend_input", null)
	host.set("_social_guild_input", null)
	host.set("_social_chat_input", null)
	host.set("_auth_email_input", null)
	host.set("_auth_password_input", null)
	host.set("_auth_username_input", null)
	host.set("_auth_invite_input", null)
	host.set("_immersive_feedback_panel", null)
	host.set("_immersive_status_label", null)
	host.set("_immersive_detail_label", null)
	host.set("_immersive_error_label", null)
	host.set("_battle_visual", null)
	host.call("_clear_battle_fullscreen_overlay")
	host.get("_battle_replay_presenter").clear()
	_error_label.text = ""
	host.call("_clear_content_body")
	_content_scroll.scroll_vertical = 0
	_content_title.text = AppShellRouteContractScript.title_for(route_id)
	_back_button.visible = true
	_back_button.disabled = _close_blocked(host)
	_close_button.disabled = _close_blocked(host)

func _set_bosque_paused(host: Node, paused: bool) -> void:
	var screen := host.get("_mode_shell_active_screen") as Control
	if screen != null and is_instance_valid(screen) and screen.has_method("set_shell_overlay_paused"):
		screen.call("set_shell_overlay_paused", paused)

func _close_blocked(host: Node) -> bool:
	if bool(host.get("_replay_running")):
		return true
	var action_id := str(host.get("_active_action_id")).strip_edges()
	if action_id == "":
		return false
	var route := AppShellActionRouterScript.route_action(action_id, _as_dictionary(host.call("_action_context")))
	return str(route.get("mutation_endpoint", "")).strip_edges() != ""

func _show_blocked_message(host: Node) -> void:
	var message := "Aguarde a acao atual terminar antes de fechar."
	if bool(host.get("_replay_running")):
		message = "Replay em andamento; use Pular replay ou aguarde concluir."
	_detail_label.text = message
	host.call("_sync_buttons")

func _sync_busy_buttons(host: Node) -> void:
	if _back_button != null:
		_back_button.disabled = _close_blocked(host)
	if _close_button != null:
		_close_button.disabled = _close_blocked(host)

func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

func _route_for_action(action_id: String) -> String:
	return str(_OVERLAY_ACTION_ROUTES.get(action_id.strip_edges(), "")).strip_edges()
