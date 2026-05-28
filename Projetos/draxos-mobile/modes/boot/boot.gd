extends Control

const ProjectInfoScript := preload("res://core/project_info.gd")
const SessionStoreScript := preload("res://online/session_store.gd")
const ShellSurfacePresenterScript := preload("res://modes/boot/surfaces/shell_surface_presenter.gd")
const HubSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_surface_presenter.gd")
const HubAccountSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_account_surface_presenter.gd")
const BattleReplayPresenterScript := preload("res://modes/boot/surfaces/battle_replay_presenter.gd")
const BaseSurfacePresenterScript := preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const SocialSurfacePresenterScript := preload("res://modes/boot/surfaces/social_surface_presenter.gd")
const CompetitionSurfacePresenterScript := preload("res://modes/boot/surfaces/competition_surface_presenter.gd")
const ShopSurfacePresenterScript := preload("res://modes/boot/surfaces/shop_surface_presenter.gd")
const SurfaceUiHelpersScript := preload("res://modes/boot/surfaces/surface_ui_helpers.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellErrorContractScript := preload("res://modes/boot/ui/app_shell_error_contract.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")
const AccountSessionFlowScript := preload("res://modes/boot/flows/account_session_flow.gd")
const SurfaceActionFlowScript := preload("res://modes/boot/flows/surface_action_flow.gd")
const BattleLifecycleFlowScript := preload("res://modes/boot/flows/battle_lifecycle_flow.gd")

const ROUTE_ENTRY := AppShellRouteContractScript.ROUTE_ENTRY
const ROUTE_REFUGE := AppShellRouteContractScript.ROUTE_REFUGE
const ROUTE_ACCOUNT := AppShellRouteContractScript.ROUTE_ACCOUNT
const ROUTE_BASE := AppShellRouteContractScript.ROUTE_BASE
const ROUTE_SOCIAL := AppShellRouteContractScript.ROUTE_SOCIAL
const ROUTE_COMPETITION := AppShellRouteContractScript.ROUTE_COMPETITION
const ROUTE_SHOP := AppShellRouteContractScript.ROUTE_SHOP
const ROUTE_BATTLE_ENTRY := AppShellRouteContractScript.ROUTE_BATTLE_ENTRY
const ROUTE_BATTLE_RUNNING := AppShellRouteContractScript.ROUTE_BATTLE_RUNNING
const ROUTE_BATTLE_SUMMARY := AppShellRouteContractScript.ROUTE_BATTLE_SUMMARY
const ROUTE_BATTLE_LOGS := AppShellRouteContractScript.ROUTE_BATTLE_LOGS
const ROUTE_BATTLE_LAB := "battle_lab"
const ROUTE_PROGRESSION_LAB := "progression_lab"

const SCREEN_HUB := ROUTE_ENTRY
const SCREEN_REFUGE := ROUTE_REFUGE
const SCREEN_BATTLE := ROUTE_BATTLE_ENTRY
const SCREEN_BASE := ROUTE_BASE
const SCREEN_SOCIAL := ROUTE_SOCIAL
const SCREEN_COMPETITION := ROUTE_COMPETITION
const SCREEN_SHOP := ROUTE_SHOP
const BATTLE_LAB_SCREEN_PATH := "res://dev/battle_lab/battle_lab_screen.gd"
const PROGRESSION_LAB_SCREEN_PATH := "res://dev/progression_lab/progression_lab_screen.gd"
const BATTLE_REPLAY_TICK_SECONDS := 0.05
const APP_ORIENTATION_PORTRAIT := DisplayServer.SCREEN_PORTRAIT
const ACTION_SKIP_REPLAY := AppShellActionContractScript.ACTION_SKIP_REPLAY
const ACTION_RETURN_REFUGE := AppShellActionContractScript.ACTION_RETURN_REFUGE
const ACTION_REPLAY_LATEST := AppShellActionContractScript.ACTION_REPLAY_LATEST
const ACTION_SHOW_CURRENT_BATTLE_LOGS := AppShellActionContractScript.ACTION_SHOW_CURRENT_BATTLE_LOGS
const ACTION_RETURN_BATTLE_SUMMARY := AppShellActionContractScript.ACTION_RETURN_BATTLE_SUMMARY

const RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]
const BASE_STRUCTURE_IDS := ["altar_das_almas", "nucleo_energia", "pocos_sangue", "minas_cristal", "estrutura_stats", "ossario"]
const ALPHA_ENERGY_PACK_PRODUCT_ID := AppShellActionContractScript.PRODUCT_ALPHA_ENERGY_PACK

var _status_label: Label
var _detail_label: Label
var _error_label: Label
var _back_button: Button
var _content_title: Label
var _content_scroll: ScrollContainer
var _content_body: VBoxContainer
var _timeline_label: Label
var _update_output_label: Label
var _base_state_container: VBoxContainer
var _social_state_container: VBoxContainer
var _competition_state_container: VBoxContainer
var _shop_state_container: VBoxContainer
var _auth_email_input: LineEdit
var _auth_password_input: LineEdit
var _auth_username_input: LineEdit
var _auth_invite_input: LineEdit
var _signup_email_input: LineEdit
var _signup_password_input: LineEdit
var _signup_username_input: LineEdit
var _social_friend_input: LineEdit
var _social_guild_input: LineEdit
var _social_chat_input: LineEdit
var _battle_visual: Control
var _battle_fullscreen_overlay: Control
var _confirm_dialog: ConfirmationDialog
var _create_account_dialog: ConfirmationDialog
var _refuge_menu_popup: PopupPanel
var _app_chrome_root: Control
var _first_screen_root: Control
var _immersive_feedback_panel: Control
var _immersive_status_label: Label
var _immersive_detail_label: Label
var _immersive_error_label: Label

var _action_buttons: Dictionary = {}
var _nav_buttons: Dictionary = {}
var _current_action_grid: GridContainer
var _screen_history: Array[String] = []
var _current_screen := SCREEN_HUB
var _pending_confirmation_action := ""
var _active_action_id := ""
var _is_busy := false
var _replay_running := false
var _skip_replay := false
var _battle_summary_skipped := false
var _compact_layout := false
var _battle_lab_overlay: Control
var _progression_lab_overlay: Control
var _selected_base_structure_id := "nucleo_energia"
var _last_social_friend_username := ""
var _last_social_guild_name := ""
var _last_social_chat_message := "Primeiro pulso do Conclave."
var _update_gate := ProjectInfoScript.unchecked_update_status()
var _account_session_flow = AccountSessionFlowScript.new()
var _surface_action_flow = SurfaceActionFlowScript.new()
var _battle_lifecycle_flow = BattleLifecycleFlowScript.new()
var _battle_replay_presenter = BattleReplayPresenterScript.new()
var _battle_history_entries: Array[Dictionary] = []
var _battle_history_save_type := SessionStoreScript.SAVE_TYPE_NORMAL

func _ready() -> void:
	_clear_existing_scene()
	_build_ui()
	SessionStore.session_changed.connect(_sync_status_from_session)
	var cache_loaded := SessionStore.load_cache()
	SessionStore.ensure_session_id()
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	_update_gate = ProjectInfoScript.unchecked_update_status(SupabaseClient.manifest_url())
	if not cache_loaded:
		SessionStore.save_cache()
	_show_screen(SCREEN_HUB, false)
	_sync_status_from_session()
	call_deferred("_check_runtime_config")
	call_deferred("_check_update_manifest")
	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		call_deferred("_recover_session_state")

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _create_account_dialog != null and _create_account_dialog.visible:
		_create_account_dialog.hide()
		return
	if _confirm_dialog != null and _confirm_dialog.visible:
		_confirm_dialog.hide()
		return
	if _close_refuge_menu_popup_if_open():
		return
	if _battle_lab_overlay != null and is_instance_valid(_battle_lab_overlay):
		_close_battle_lab_overlay()
		return
	if _progression_lab_overlay != null and is_instance_valid(_progression_lab_overlay):
		_close_progression_lab_overlay()
		return
	if _replay_running:
		_skip_current_replay()
		return
	if _current_screen != SCREEN_HUB:
		_go_back()

func _clear_existing_scene() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()

func _build_ui() -> void:
	_compact_layout = _should_use_compact_layout()
	ShellSurfacePresenterScript.render(self)
	_render_create_account_dialog()

func _close_refuge_menu_popup_if_open() -> bool:
	if _refuge_menu_popup == null or not is_instance_valid(_refuge_menu_popup):
		return false
	if not _refuge_menu_popup.visible:
		return false
	_refuge_menu_popup.hide()
	return true

func _render_create_account_dialog() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Criar conta"
	dialog.confirmed.connect(Callable(self, "_on_create_account_confirmed"))
	add_child(dialog)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	dialog.add_child(box)

	var intro := Label.new()
	intro.text = "Crie a conta com email, senha e username."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(intro)

	_signup_email_input = _dialog_line_edit(box, "Email", "tester@exemplo.com", false)
	_signup_password_input = _dialog_line_edit(box, "Senha", "Minimo 6 caracteres", true)
	_signup_username_input = _dialog_line_edit(box, "Username", "draxos_tester", false)

	dialog.get_ok_button().text = "Criar conta"
	dialog.get_cancel_button().text = "Voltar"
	_create_account_dialog = dialog

func _dialog_line_edit(parent: VBoxContainer, label_text: String, placeholder: String, secret: bool) -> LineEdit:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)
	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.secret = secret
	input.custom_minimum_size = MobileUiContractScript.input_min_size(true)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(input)
	return input

func _should_use_compact_layout() -> bool:
	if bool(ProjectSettings.get_setting("draxos_mobile/ui/force_compact_layout", false)):
		return true
	if OS.get_name() == "Android":
		return true
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= MobileUiContractScript.COMPACT_WIDTH_BREAKPOINT:
		return true
	return viewport_size.y <= 620.0 and viewport_size.x > viewport_size.y

func _manifest_url() -> String:
	return SupabaseClient.manifest_url()

func _button_min_size() -> Vector2:
	return MobileUiContractScript.button_min_size(_compact_layout)

func _action_button_columns() -> int:
	return action_button_columns_for_size(get_viewport_rect().size, _compact_layout)

func _surface_columns(max_columns: int = 2) -> int:
	return surface_columns_for_size(get_viewport_rect().size, max_columns)

static func action_button_columns_for_size(viewport_size: Vector2, compact: bool) -> int:
	return MobileUiContractScript.action_button_columns_for_size(viewport_size, compact)

static func surface_columns_for_size(viewport_size: Vector2, max_columns: int = 2) -> int:
	return MobileUiContractScript.surface_columns_for_size(viewport_size, max_columns)

func _base_map_columns() -> int:
	return MobileUiContractScript.base_map_columns_for_size(get_viewport_rect().size, _compact_layout)

func _reset_action_group() -> void:
	_current_action_grid = null

func _ensure_action_grid() -> GridContainer:
	if _current_action_grid != null and is_instance_valid(_current_action_grid):
		return _current_action_grid
	var grid := GridContainer.new()
	grid.columns = _action_button_columns()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8 if _compact_layout else 10)
	grid.add_theme_constant_override("v_separation", 8)
	_content_body.add_child(grid)
	_current_action_grid = grid
	return grid

func _show_screen(screen_id: String, push_history: bool = true) -> void:
	screen_id = AppShellRouteContractScript.push_route(_screen_history, _current_screen, screen_id, push_history)
	_current_screen = screen_id
	_apply_orientation_for_route(screen_id)
	_action_buttons.clear()
	_current_action_grid = null
	_timeline_label = null
	_update_output_label = null
	_base_state_container = null
	_social_state_container = null
	_competition_state_container = null
	_shop_state_container = null
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
		SCREEN_BASE:
			_render_base_screen()
		SCREEN_SOCIAL:
			_render_social_screen()
		SCREEN_COMPETITION:
			_render_competition_screen()
		SCREEN_SHOP:
			_render_shop_screen()
		_:
			_render_entry_screen()

	_sync_status_from_session()
	_emit_client_event("screen_opened", {
		"screen": screen_id,
		"has_account": SessionStore.has_account_state(),
		"offline": SessionStore.offline,
	})

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
	_show_screen(previous, false)

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

func _battle_lab_available() -> bool:
	if not OS.has_feature("editor"):
		return false
	if not bool(ProjectSettings.get_setting("draxos_mobile/battle_lab/enabled", false)):
		return false
	return ResourceLoader.exists(BATTLE_LAB_SCREEN_PATH)

func _open_battle_lab_overlay() -> void:
	if not _battle_lab_available():
		_error_label.text = "Battle Lab dev indisponivel neste ambiente."
		return
	if _battle_lab_overlay != null and is_instance_valid(_battle_lab_overlay):
		return
	var script: Script = load(BATTLE_LAB_SCREEN_PATH)
	if script == null or not script.can_instantiate():
		_error_label.text = "Battle Lab dev nao pode ser carregado."
		return
	var overlay: Control = script.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", Callable(self, "_close_battle_lab_overlay"))
	add_child(overlay)
	_battle_lab_overlay = overlay
	_emit_client_event("battle_lab_opened", {
		"screen": _current_screen,
	})

func _close_battle_lab_overlay() -> void:
	if _battle_lab_overlay == null or not is_instance_valid(_battle_lab_overlay):
		_battle_lab_overlay = null
		return
	_battle_lab_overlay.queue_free()
	_battle_lab_overlay = null
	_emit_client_event("battle_lab_closed", {
		"screen": _current_screen,
	})

func _progression_lab_available() -> bool:
	if not OS.has_feature("editor"):
		return false
	if not bool(ProjectSettings.get_setting("draxos_mobile/progression_lab/enabled", false)):
		return false
	return ResourceLoader.exists(PROGRESSION_LAB_SCREEN_PATH)

func _open_progression_lab_overlay() -> void:
	if not _progression_lab_available():
		_error_label.text = "Progression Lab dev indisponivel neste ambiente."
		return
	if _progression_lab_overlay != null and is_instance_valid(_progression_lab_overlay):
		return
	var script: Script = load(PROGRESSION_LAB_SCREEN_PATH)
	if script == null or not script.can_instantiate():
		_error_label.text = "Progression Lab dev nao pode ser carregado."
		return
	var overlay: Control = script.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", Callable(self, "_close_progression_lab_overlay"))
	add_child(overlay)
	_progression_lab_overlay = overlay
	_emit_client_event("progression_lab_opened", {
		"screen": _current_screen,
	})

func _close_progression_lab_overlay() -> void:
	if _progression_lab_overlay == null or not is_instance_valid(_progression_lab_overlay):
		_progression_lab_overlay = null
		return
	_progression_lab_overlay.queue_free()
	_progression_lab_overlay = null
	_emit_client_event("progression_lab_closed", {
		"screen": _current_screen,
	})

func _clear_content_body() -> void:
	for child: Node in _content_body.get_children():
		_content_body.remove_child(child)
		child.queue_free()

func _clear_first_screen_root() -> void:
	if _first_screen_root == null or not is_instance_valid(_first_screen_root):
		return
	for child: Node in _first_screen_root.get_children():
		_first_screen_root.remove_child(child)
		child.queue_free()

func _clear_node_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func _clear_battle_fullscreen_overlay() -> void:
	if _battle_fullscreen_overlay == null:
		return
	if is_instance_valid(_battle_fullscreen_overlay):
		_battle_fullscreen_overlay.queue_free()
	_battle_fullscreen_overlay = null

func _create_battle_fullscreen_overlay() -> Control:
	var overlay := Control.new()
	overlay.name = "BattleFullscreenOverlay"
	overlay.set_anchors_preset(Control.PRESET_TOP_LEFT)
	overlay.position = Vector2.ZERO
	var root_size := Vector2(get_tree().root.size)
	overlay.size = root_size if root_size.x > 0.0 and root_size.y > 0.0 else get_viewport_rect().size
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	_battle_fullscreen_overlay = overlay
	return overlay

func _render_entry_screen() -> void:
	HubSurfacePresenterScript.render_entry(self)

func _render_refuge_screen() -> void:
	HubSurfacePresenterScript.render_refuge(self)
	call_deferred("_sync_refuge_state_if_needed")

func _render_account_screen() -> void:
	HubAccountSurfacePresenterScript.render_account_panel(self)

func _render_battle_screen() -> void:
	_battle_lifecycle_flow.render_entry(self)

func _render_battle_running_screen() -> void:
	_battle_lifecycle_flow.render_running(self)

func _render_battle_summary_screen() -> void:
	_battle_lifecycle_flow.render_summary(self)

func _render_battle_logs_screen() -> void:
	_battle_lifecycle_flow.render_logs(self)

func _render_base_screen() -> void:
	BaseSurfacePresenterScript.render(self)

func _render_social_screen() -> void:
	SocialSurfacePresenterScript.render(self)

func _render_competition_screen() -> void:
	CompetitionSurfacePresenterScript.render(self)

func _render_shop_screen() -> void:
	ShopSurfacePresenterScript.render(self)

func _add_section_label(text: String) -> Label:
	_reset_action_group()
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16 if _compact_layout else 18)
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	_content_body.add_child(label)
	return label

func _add_body_text(text: String) -> Label:
	_reset_action_group()
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _compact_layout:
		label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(label)
	return label

func _add_output_label(text: String) -> Label:
	_reset_action_group()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(panel)

	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _compact_layout:
		label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(label)
	return label

func _add_content_control(control: Control) -> void:
	_reset_action_group()
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(control)

func _add_responsive_panel_layout(container: VBoxContainer, panels: Array, max_columns: int = 2) -> void:
	if container == null:
		return
	var column_count := _surface_columns(max_columns)
	if column_count <= 1 or panels.size() <= 1:
		for panel: Variant in panels:
			if panel is Control:
				container.add_child(panel as Control)
		return

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8 if _compact_layout else 10)
	container.add_child(row)

	var columns: Array = []
	for index in range(column_count):
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 8 if _compact_layout else 10)
		row.add_child(column)
		columns.append(column)

	for index in range(panels.size()):
		var panel: Variant = panels[index]
		if panel is Control:
			var column := columns[index % column_count] as VBoxContainer
			if column != null:
				column.add_child(panel as Control)

func _add_action_button(text: String, action_id: String, confirm_message: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = _button_min_size()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = text
	_prepare_touch_button(button)
	button.pressed.connect(func() -> void:
		_trigger_action(action_id, confirm_message)
	)
	_ensure_action_grid().add_child(button)
	_action_buttons[action_id] = button
	return button

func _add_social_input(label_text: String, placeholder: String, initial_text: String, input_tooltip: String) -> LineEdit:
	_reset_action_group()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(box)

	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	box.add_child(label)

	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.text = initial_text
	input.tooltip_text = input_tooltip
	input.custom_minimum_size = MobileUiContractScript.input_min_size(_compact_layout)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(input)
	return input

func _add_screen_button(text: String, screen_id: String) -> Button:
	var target_screen := _normalize_route(screen_id)
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = _button_min_size()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "Abrir %s." % _screen_title(screen_id)
	_prepare_touch_button(button)
	button.pressed.connect(func() -> void:
		_show_screen(target_screen)
	)
	_ensure_action_grid().add_child(button)
	return button

func _prepare_touch_button(button: Button) -> void:
	MobileUiContractScript.apply_touch_button(button)

func _trigger_action(action_id: String, confirm_message: String = "") -> void:
	if _is_busy:
		return
	if confirm_message != "":
		_pending_confirmation_action = action_id
		_confirm_dialog.dialog_text = confirm_message
		_confirm_dialog.popup_centered()
		return
	await _execute_action(action_id)

func _on_confirmation_confirmed() -> void:
	var action_id := _pending_confirmation_action
	_pending_confirmation_action = ""
	if action_id == "":
		return
	await _execute_action(action_id)

func _execute_action(action_id: String) -> void:
	_active_action_id = action_id
	_error_label.text = ""
	_emit_client_event("action_start", _action_payload(action_id))
	if _update_gate_blocks_action(action_id):
		_error_label.text = "Update obrigatorio antes de usar recursos online."
		_detail_label.text = str(_update_gate.get("detail", "Baixe a nova build pelo portal."))
		_emit_client_event("precondition_failed", {
			"action_id": action_id,
			"screen": _current_screen,
			"reason": "required_update",
			"current_version": ProjectInfoScript.APP_VERSION,
			"minimum_supported_version": str(_update_gate.get("minimum_supported_version", "")),
		})
		_sync_buttons()
	elif AppShellActionContractScript.is_select_base_structure(action_id):
		_select_base_structure(AppShellActionContractScript.action_value(action_id))
	elif AppShellActionContractScript.is_upgrade_base_structure(action_id):
		await _upgrade_base_structure(AppShellActionContractScript.action_value(action_id))
	elif AppShellActionContractScript.is_shop_purchase(action_id):
		await _buy_shop_product(AppShellActionContractScript.action_value(action_id))
	elif AppShellActionContractScript.is_claim_reward(action_id):
		await _claim_shop_reward(AppShellActionContractScript.action_value(action_id))
	elif AppShellActionContractScript.is_battle_replay(action_id):
		await _show_battle_replay(AppShellActionContractScript.action_value(action_id))
	else:
		match action_id:
			AppShellActionContractScript.ACTION_ENTER_GUEST:
				await _enter_guest()
			AppShellActionContractScript.ACTION_ENTER_REFUGE:
				await _enter_refuge()
			AppShellActionContractScript.ACTION_OPEN_CREATE_ACCOUNT:
				_open_create_account_dialog()
			AppShellActionContractScript.ACTION_CHECK_UPDATE:
				await _check_update_manifest(true)
			AppShellActionContractScript.ACTION_EMAIL_SIGN_UP:
				await _email_sign_up()
			AppShellActionContractScript.ACTION_EMAIL_SIGN_IN:
				await _email_sign_in()
			AppShellActionContractScript.ACTION_REFRESH_SESSION:
				await _refresh_session()
			AppShellActionContractScript.ACTION_RESET_SESSION:
				await _reset_local_session()
			AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE:
				await _reset_active_save()
			AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL:
				await _select_save(SessionStoreScript.SAVE_TYPE_NORMAL)
			AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB:
				await _select_save(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
			AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB:
				_open_battle_lab_overlay()
			AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB:
				_open_progression_lab_overlay()
			AppShellActionContractScript.ACTION_REQUEST_BATTLE:
				await _request_battle()
			ACTION_SKIP_REPLAY:
				_skip_current_replay()
			ACTION_RETURN_REFUGE:
				_return_to_refuge()
			ACTION_REPLAY_LATEST:
				await _replay_latest_battle_from_summary()
			ACTION_SHOW_CURRENT_BATTLE_LOGS:
				_show_current_battle_logs()
			ACTION_RETURN_BATTLE_SUMMARY:
				_return_to_battle_summary()
			AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE:
				if _replay_running:
					_skip_replay = true
					return
				await _show_latest_battle()
			AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY:
				await _show_battle_history()
			AppShellActionContractScript.ACTION_SHOW_BASE:
				await _show_base()
			AppShellActionContractScript.ACTION_COLLECT_BASE:
				await _collect_base()
			AppShellActionContractScript.ACTION_BUY_ENERGY_PACK_ALPHA:
				await _buy_energy_pack_alpha()
			AppShellActionContractScript.ACTION_UPGRADE_NUCLEO:
				await _upgrade_base_structure(AppShellActionContractScript.STRUCTURE_NUCLEO_ENERGIA)
			AppShellActionContractScript.ACTION_SHOW_SOCIAL:
				await _show_social()
			AppShellActionContractScript.ACTION_ADD_FRIEND:
				await _add_friend()
			AppShellActionContractScript.ACTION_CREATE_GUILD:
				await _create_guild()
			AppShellActionContractScript.ACTION_JOIN_GUILD:
				await _join_guild()
			AppShellActionContractScript.ACTION_SEND_GUILD_CHAT:
				await _send_guild_chat()
			AppShellActionContractScript.ACTION_SHOW_MATCHMAKING:
				await _show_matchmaking()
			AppShellActionContractScript.ACTION_SHOW_RANKING:
				await _show_ranking()
			AppShellActionContractScript.ACTION_SHOW_SHOP:
				await _show_shop()
			AppShellActionContractScript.ACTION_BUY_PREMIUM_ALPHA:
				await _buy_shop_product(AppShellActionContractScript.PRODUCT_ALPHA_BATTLE_PASS_PREMIUM)
			AppShellActionContractScript.ACTION_GRANT_DIAMOND_ALPHA:
				await _buy_shop_product(AppShellActionContractScript.PRODUCT_ALPHA_REDEEM_MEDIUM)
			AppShellActionContractScript.ACTION_CLAIM_DAILY_REWARD:
				await _claim_shop_reward(AppShellActionContractScript.REWARD_DAILY_COLLECT_BASE)
	if _active_action_id == action_id:
		var event_type := "action_failure" if _error_label.text != "" else "action_success"
		var payload := _action_payload(action_id)
		if _error_label.text != "":
			payload["error_text"] = _error_label.text
		_emit_client_event(event_type, payload)
	_active_action_id = ""

func _check_runtime_config() -> void:
	await _account_session_flow.check_runtime_config(self)

func _check_update_manifest(manual: bool = false) -> void:
	await _account_session_flow.check_update_manifest(self, manual)

func _enter_guest() -> void:
	await _account_session_flow.enter_guest(self)

func _enter_refuge() -> void:
	await _account_session_flow.enter_refuge(self)

func _open_create_account_dialog() -> void:
	if _create_account_dialog == null:
		return
	_signup_email_input.text = _social_input_text(_auth_email_input, SessionStore.auth_email)
	_signup_password_input.text = _social_input_text(_auth_password_input)
	_signup_username_input.text = SessionStore.account_username
	_error_label.text = ""
	_sync_immersive_feedback()
	_create_account_dialog.popup_centered(Vector2i(340, 340))

func _on_create_account_confirmed() -> void:
	await _email_sign_up_from_dialog()

func _email_sign_up() -> void:
	await _account_session_flow.email_sign_up(self)

func _email_sign_up_from_dialog() -> void:
	await _account_session_flow.email_sign_up_from_dialog(self)

func _email_sign_up_with_credentials(credentials: Dictionary) -> void:
	await _account_session_flow.email_sign_up_with_credentials(self, credentials)

func _email_sign_in() -> void:
	await _account_session_flow.email_sign_in(self)

func _refresh_session() -> void:
	await _account_session_flow.refresh_session(self)

func _reset_local_session() -> void:
	await _account_session_flow.reset_local_session(self)

func _reset_active_save() -> void:
	await _account_session_flow.reset_active_save(self)

func _select_save(save_type: String) -> void:
	await _account_session_flow.select_save(self, save_type)

func _recover_session_state() -> bool:
	return await _account_session_flow.recover_session_state(self)

func _recover_or_create_active_save(invite_code: String = "", username: String = "") -> bool:
	return await _account_session_flow.recover_or_create_active_save(self, invite_code, username)

func _auth_form_values(require_username: bool) -> Dictionary:
	return _account_session_flow.auth_form_values(self, require_username)

func _create_account_form_values() -> Dictionary:
	return _account_session_flow.create_account_form_values(self)

func _effective_alpha_username(username: String) -> String:
	return _account_session_flow.effective_alpha_username(username)

func _effective_alpha_invite(invite_code: String) -> String:
	return _account_session_flow.effective_alpha_invite(self, invite_code)

func _normalized_alpha_username(username: String) -> String:
	return _account_session_flow.normalized_alpha_username(username)

func _is_valid_alpha_username(username: String) -> bool:
	return _account_session_flow.is_valid_alpha_username(username)

func _apply_recovered_state(state_result: Dictionary, message: String) -> bool:
	return _account_session_flow.apply_recovered_state(self, state_result, message)

func _request_battle() -> void:
	await _battle_lifecycle_flow.request_battle(self)

func _show_latest_battle() -> void:
	await _battle_lifecycle_flow.show_latest_battle(self)

func _skip_current_replay() -> void:
	_battle_lifecycle_flow.skip_current_replay(self)

func _return_to_refuge() -> void:
	_battle_lifecycle_flow.return_to_refuge(self)

func _show_current_battle_logs() -> void:
	_battle_lifecycle_flow.show_current_battle_logs(self)

func _return_to_battle_summary() -> void:
	_battle_lifecycle_flow.return_to_battle_summary(self)

func _replay_latest_battle_from_summary() -> void:
	await _battle_lifecycle_flow.replay_latest_battle_from_summary(self)

func _show_battle_history() -> void:
	await _battle_lifecycle_flow.show_battle_history(self)

func _show_battle_replay(battle_id: String) -> void:
	await _battle_lifecycle_flow.show_battle_replay(self, battle_id)

func _show_base() -> void:
	await _surface_action_flow.show_base(self)

func _sync_refuge_state_if_needed() -> void:
	await _surface_action_flow.sync_refuge_state_if_needed(self)

func _collect_base() -> void:
	await _surface_action_flow.collect_base(self)

func _buy_energy_pack_alpha() -> void:
	await _surface_action_flow.buy_energy_pack_alpha(self)

func _upgrade_base_structure(structure_id: String) -> void:
	await _surface_action_flow.upgrade_base_structure(self, structure_id)

func _base_surface_target_screen() -> String:
	if _current_screen == SCREEN_REFUGE:
		return SCREEN_REFUGE
	return SCREEN_BASE

func _show_social() -> void:
	await _surface_action_flow.show_social(self)

func _add_friend() -> void:
	await _surface_action_flow.add_friend(self)

func _create_guild() -> void:
	await _surface_action_flow.create_guild(self)

func _join_guild() -> void:
	await _surface_action_flow.join_guild(self)

func _send_guild_chat() -> void:
	await _surface_action_flow.send_guild_chat(self)

func _show_matchmaking() -> void:
	await _surface_action_flow.show_matchmaking(self)

func _show_ranking() -> void:
	await _surface_action_flow.show_ranking(self)

func _show_shop() -> void:
	await _surface_action_flow.show_shop(self)

func _buy_shop_product(product_id: String) -> void:
	await _surface_action_flow.buy_shop_product(self, product_id)

func _claim_shop_reward(reward_id: String) -> void:
	await _surface_action_flow.claim_shop_reward(self, reward_id)

func _set_busy(is_busy: bool, message: String) -> void:
	_is_busy = is_busy
	if is_busy:
		_status_label.text = message
		_detail_label.text = "Aguardando resposta do servidor..."
		_error_label.text = ""
	else:
		_status_label.text = _session_status_text()
		_detail_label.text = message
	_sync_immersive_feedback()
	_sync_buttons()

func _show_notice(message: String) -> void:
	if _detail_label != null:
		_detail_label.text = message
	_sync_immersive_feedback()

func _fail_with_error(result: Dictionary) -> void:
	var error_payload := _extract_error(result)
	var code := str(error_payload.get("code", "REQUEST_FAILED"))
	if _is_network_error(code):
		SessionStore.mark_offline(error_payload)
	else:
		SessionStore.offline = false
		SessionStore.last_error = error_payload
		SessionStore.session_changed.emit()
	_set_busy(false, "Acao nao concluida.")
	_error_label.text = _friendly_error_message(code, str(error_payload.get("message", "Falha na requisicao.")))
	_sync_immersive_feedback()
	_emit_client_event("action_failure", {
		"action_id": _active_action_id,
		"screen": _current_screen,
		"code": code,
		"message": str(error_payload.get("message", "")),
		"network": _is_network_error(code),
	})
	if _is_network_error(code):
		_emit_client_event("network_failure", {
			"action_id": _active_action_id,
			"screen": _current_screen,
			"code": code,
		})

func _sync_status_from_session() -> void:
	if _status_label == null:
		return
	if not _is_busy and not _replay_running:
		_status_label.text = _session_status_text()
	_sync_immersive_feedback()
	_sync_buttons()

func _sync_immersive_feedback() -> void:
	var has_visible_feedback := false
	if _immersive_status_label != null and is_instance_valid(_immersive_status_label):
		_immersive_status_label.text = _status_label.text if _status_label != null else _session_status_text()
		_immersive_status_label.visible = _immersive_status_label.text.strip_edges() != "" and _is_busy
		has_visible_feedback = has_visible_feedback or _immersive_status_label.visible
	if _immersive_detail_label != null and is_instance_valid(_immersive_detail_label):
		_immersive_detail_label.text = _detail_label.text if _detail_label != null else ""
		_immersive_detail_label.visible = _immersive_detail_label.text.strip_edges() != ""
		has_visible_feedback = has_visible_feedback or _immersive_detail_label.visible
	if _immersive_error_label != null and is_instance_valid(_immersive_error_label):
		_immersive_error_label.text = _error_label.text if _error_label != null else ""
		_immersive_error_label.visible = _immersive_error_label.text.strip_edges() != ""
		has_visible_feedback = has_visible_feedback or _immersive_error_label.visible
	if _immersive_feedback_panel != null and is_instance_valid(_immersive_feedback_panel):
		_immersive_feedback_panel.visible = has_visible_feedback

func _sync_buttons() -> void:
	for action_id: String in _action_buttons.keys():
		var button: Button = _action_buttons[action_id]
		if not is_instance_valid(button):
			continue
		button.disabled = _is_busy or (_replay_running and not _action_allowed_during_replay(action_id))
		button.disabled = button.disabled or _update_gate_blocks_action(action_id)
		if action_id == ACTION_SKIP_REPLAY:
			button.disabled = not _replay_running
		if action_id == AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL:
			button.disabled = button.disabled or not SessionStore.is_progression_lab_active()
		elif action_id == AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB:
			button.disabled = button.disabled or SessionStore.is_progression_lab_active()
		elif AppShellActionContractScript.is_upgrade_base_structure(action_id):
			button.disabled = button.disabled or not _can_upgrade_base_structure(AppShellActionContractScript.action_value(action_id))
		elif AppShellActionContractScript.is_shop_purchase(action_id):
			var product := _shop_product_by_id(AppShellActionContractScript.action_value(action_id))
			if not product.is_empty():
				button.disabled = button.disabled or not bool(product.get("can_purchase", true))
		elif AppShellActionContractScript.is_claim_reward(action_id):
			var reward := _shop_reward_by_id(AppShellActionContractScript.action_value(action_id))
			if not reward.is_empty():
				button.disabled = button.disabled or bool(reward.get("claimed", false))
		if action_id == AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE:
			button.text = "Pular replay" if _replay_running else "Ver resultado"
	for screen_id: String in _nav_buttons.keys():
		var nav_button: Button = _nav_buttons[screen_id]
		nav_button.disabled = _is_busy or _replay_running
	if _back_button != null:
		_back_button.disabled = _is_busy or _replay_running

func _action_allowed_during_replay(action_id: String) -> bool:
	return AppShellActionContractScript.is_allowed_during_replay(action_id)

func _update_status_text() -> String:
	return HubAccountSurfacePresenterScript.update_status_text(self)

func _refresh_update_output_label() -> void:
	if _update_output_label != null and is_instance_valid(_update_output_label):
		_update_output_label.text = _update_status_text()

func _update_gate_blocks_action(action_id: String) -> bool:
	return AppShellActionContractScript.update_gate_blocks_action(action_id, _update_gate, _replay_running)

func _sync_nav_buttons() -> void:
	for screen_id: String in _nav_buttons.keys():
		var button: Button = _nav_buttons[screen_id]
		button.button_pressed = screen_id == _current_screen

func _require_session(message: String) -> bool:
	if SessionStore.is_progression_lab_local_only():
		_error_label.text = "Save local-only do Progression Lab nao executa acoes online."
		_detail_label.text = "Use o seeder com Supabase local para testar batalha, coleta, upgrades e outras mudancas."
		_sync_immersive_feedback()
		_emit_client_event("precondition_failed", {
			"action_id": _active_action_id,
			"screen": _current_screen,
			"reason": "progression_lab_local_only",
		})
		return false
	if SessionStore.has_valid_access_token():
		return true
	_error_label.text = message
	_detail_label.text = "Entre com email na Entrada ou use guest dev para teste local."
	_sync_immersive_feedback()
	_emit_client_event("precondition_failed", {
		"action_id": _active_action_id,
		"screen": _current_screen,
		"reason": "missing_session",
	})
	return false

func _require_account(message: String) -> bool:
	if SessionStore.is_progression_lab_local_only():
		_error_label.text = "Save local-only do Progression Lab nao executa acoes online."
		_detail_label.text = "Para batalhas, coleta, upgrades e compras, rode o seeder com Supabase local e carregue o save."
		_sync_immersive_feedback()
		_emit_client_event("precondition_failed", {
			"action_id": _active_action_id,
			"screen": _current_screen,
			"reason": "progression_lab_local_only",
		})
		return false
	if SessionStore.has_valid_access_token() and SessionStore.has_account_state():
		return true
	_error_label.text = message
	_detail_label.text = "Entre com email na Entrada ou use guest dev para teste local."
	_sync_immersive_feedback()
	_emit_client_event("precondition_failed", {
		"action_id": _active_action_id,
		"screen": _current_screen,
		"reason": "missing_account",
	})
	return false

func _render_base_state(collected: Dictionary = {}) -> void:
	SurfaceUiHelpersScript.render_base_state(self, collected)
func _render_base_playable_panels(structures: Array, base: Dictionary, collected: Dictionary) -> void:
	SurfaceUiHelpersScript.render_base_playable_panels(self, structures, base, collected)
func _base_summary_panel(base: Dictionary, collected: Dictionary) -> Control:
	return SurfaceUiHelpersScript.base_summary_panel(self, base, collected)
func _base_map_panel(structures: Array) -> Control:
	return SurfaceUiHelpersScript.base_map_panel(self, structures)
func _base_detail_panel(structures: Array) -> Control:
	return SurfaceUiHelpersScript.base_detail_panel(self, structures)
func _base_structure_button(structure: Dictionary) -> Button:
	return SurfaceUiHelpersScript.base_structure_button(self, structure)
func _select_base_structure(structure_id: String) -> void:
	SurfaceUiHelpersScript.select_base_structure(self, structure_id)
func _ensure_selected_base_structure(structures: Array) -> void:
	SurfaceUiHelpersScript.ensure_selected_base_structure(self, structures)
func _base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	return SurfaceUiHelpersScript.base_structure_by_id(structures, structure_id)
func _base_panel() -> PanelContainer:
	return SurfaceUiHelpersScript.base_panel(self)
func _base_info_panel(title_text: String, body_text: String) -> Control:
	return SurfaceUiHelpersScript.base_info_panel(self, title_text, body_text)
func _base_label(text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	return SurfaceUiHelpersScript.base_label(self, text, color_token, font_size)
func _base_structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	return SurfaceUiHelpersScript.base_structure_card_style(structure_id, selected)
func _base_structure_color(structure_id: String) -> Color:
	return SurfaceUiHelpersScript.base_structure_color(structure_id)
func _base_structure_symbol(structure_id: String) -> String:
	return SurfaceUiHelpersScript.base_structure_symbol(structure_id)
func _base_structure_short_label(structure_id: String) -> String:
	return SurfaceUiHelpersScript.base_structure_short_label(structure_id)
func _base_benefit_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_benefit_text(structure)
func _base_pending_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_pending_text(structure)
func _base_upgrade_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_upgrade_text(structure)
func _base_next_level_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_next_level_text(structure)
func _base_short_status(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_short_status(structure)
func _base_status_color_token(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_status_color_token(structure)
func _base_structure_tooltip(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_structure_tooltip(structure)
func _can_upgrade_base_structure(structure_id: String) -> bool:
	return SurfaceUiHelpersScript.can_upgrade_base_structure(self, structure_id)
func _active_base_jobs(jobs: Array) -> Array:
	return SurfaceUiHelpersScript.active_base_jobs(jobs)
func _format_cost(cost: Dictionary) -> String:
	return SurfaceUiHelpersScript.format_cost(cost)
func _format_duration(total_seconds: int) -> String:
	return SurfaceUiHelpersScript.format_duration(total_seconds)
func _format_number(value: float) -> String:
	return SurfaceUiHelpersScript.format_number(value)
func _render_social_state() -> void:
	SurfaceUiHelpersScript.render_social_state(self)
func _social_identity_panel(identity: Dictionary, social_player: Dictionary, active_player: Dictionary) -> Control:
	return SurfaceUiHelpersScript.social_identity_panel(self, identity, social_player, active_player)
func _social_friends_panel(friends: Array) -> Control:
	return SurfaceUiHelpersScript.social_friends_panel(self, friends)
func _social_guild_panel(guild: Dictionary, members: Array, structures: Array) -> Control:
	return SurfaceUiHelpersScript.social_guild_panel(self, guild, members, structures)
func _social_chat_panel(messages: Array) -> Control:
	return SurfaceUiHelpersScript.social_chat_panel(self, messages)
func _social_input_text(input: LineEdit, fallback: String = "") -> String:
	return SurfaceUiHelpersScript.social_input_text(input, fallback)
func _default_social_guild_text() -> String:
	return SurfaceUiHelpersScript.default_social_guild_text(self)
func _social_username_text(profile: Dictionary) -> String:
	return SurfaceUiHelpersScript.social_username_text(profile)
func _social_save_badge_text(badge: String) -> String:
	return SurfaceUiHelpersScript.social_save_badge_text(badge)
func _guild_structure_label(structure_id: String) -> String:
	return SurfaceUiHelpersScript.guild_structure_label(structure_id)
func _render_competition_state() -> void:
	SurfaceUiHelpersScript.render_competition_state(self)
func _render_competition_panels(last_battle: Dictionary, matchmaking: Dictionary, ranking: Dictionary) -> void:
	SurfaceUiHelpersScript.render_competition_panels(self, last_battle, matchmaking, ranking)
func _competition_last_battle_panel(last_battle: Dictionary) -> Control:
	return SurfaceUiHelpersScript.competition_last_battle_panel(self, last_battle)
func _competition_matchmaking_panel(matchmaking: Dictionary) -> Control:
	return SurfaceUiHelpersScript.competition_matchmaking_panel(self, matchmaking)
func _competition_ranking_panel(ranking: Dictionary) -> Control:
	return SurfaceUiHelpersScript.competition_ranking_panel(self, ranking)
func _competition_entry_name(entry: Dictionary) -> String:
	return SurfaceUiHelpersScript.competition_entry_name(entry)
func _competition_result_text(result: String) -> String:
	return SurfaceUiHelpersScript.competition_result_text(result)
func _competition_scoring_model_text(model: String) -> String:
	return SurfaceUiHelpersScript.competition_scoring_model_text(model)
func _render_monetization_state() -> void:
	SurfaceUiHelpersScript.render_monetization_state(self)
func _render_shop_panels(monetization: Dictionary) -> void:
	SurfaceUiHelpersScript.render_shop_panels(self, monetization)
func _shop_summary_panel(summary: Dictionary) -> Control:
	return SurfaceUiHelpersScript.shop_summary_panel(self, summary)
func _shop_product_group_panel(title_text: String, products: Array) -> Control:
	return SurfaceUiHelpersScript.shop_product_group_panel(self, title_text, products)
func _shop_reward_group_panel(title_text: String, rewards: Array) -> Control:
	return SurfaceUiHelpersScript.shop_reward_group_panel(self, title_text, rewards)
func _shop_product_status_text(product: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_product_status_text(product)
func _shop_product_status_color(product: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_product_status_color(product)
func _shop_locked_reason_text(reason: String) -> String:
	return SurfaceUiHelpersScript.shop_locked_reason_text(reason)
func _shop_effect_text(effect: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_effect_text(effect)
func _format_shop_delta(delta: Dictionary, empty_text: String) -> String:
	return SurfaceUiHelpersScript.format_shop_delta(delta, empty_text)
func _shop_product_by_id(product_id: String) -> Dictionary:
	return SurfaceUiHelpersScript.shop_product_by_id(product_id)
func _shop_reward_by_id(reward_id: String) -> Dictionary:
	return SurfaceUiHelpersScript.shop_reward_by_id(reward_id)
func _shop_purchase_message(product_id: String, body: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_purchase_message(product_id, body)
func _play_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	await _battle_lifecycle_flow.play_battle_log(self, battle_log, rewards)

func _screen_title(screen_id: String) -> String:
	return AppShellRouteContractScript.title_for(screen_id)

func _session_status_text() -> String:
	if bool(_update_gate.get("block_online", false)):
		return str(_update_gate.get("summary", "Update obrigatorio antes de usar recursos online."))
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		var label := SessionStore.progression_lab_label()
		if label == "":
			label = SessionStore.player_display_name()
		return "Progression Lab local: %s (somente leitura)" % label
	if SessionStore.is_progression_lab_active():
		if SessionStore.has_account_state():
			return "Save Progression Lab - sessao %s pronta: %s" % [
				SessionStore.auth_method,
				SessionStore.player_display_name(),
			]
		return "Save Progression Lab ativo - isolado do save normal"
	if SessionStore.has_account_state():
		return "Save Normal - sessao %s pronta: %s" % [
			SessionStore.auth_method,
			SessionStore.player_display_name(),
		]
	if SessionStore.has_valid_access_token():
		return "Save %s - sessao %s criada." % [
			SessionStore.active_save_label(),
			SessionStore.auth_method,
		]
	return "%s - primeiro slice" % ProjectInfoScript.PROJECT_NAME

func _default_guild_name() -> String:
	var player_id := str(SessionStore.player.get("id", ""))
	var suffix := player_id.replace("-", "").substr(0, 8)
	if suffix == "":
		suffix = SessionStoreScript.create_request_id().replace("-", "").substr(0, 8)
	return "Conclave %s" % suffix

func _format_resources(resources: Dictionary, include_diamond: bool = true) -> String:
	return SurfaceUiHelpersScript.format_resources(resources, include_diamond)
func _resource_total(resources: Dictionary) -> float:
	return SurfaceUiHelpersScript.resource_total(resources)
func _structure_label(structure_id: String, fallback: String = "") -> String:
	return SurfaceUiHelpersScript.structure_label(structure_id, fallback)
func _extract_error(result: Dictionary) -> Dictionary:
	return AppShellErrorContractScript.extract_error(result)

func _friendly_error_message(code: String, message: String) -> String:
	return AppShellErrorContractScript.friendly_message(code, message)

func _is_network_error(code: String) -> bool:
	return AppShellErrorContractScript.is_network_error(code)

func _panel_style(bg_token: String, border_token: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color(bg_token)
	style.border_color = UiTokens.color(border_token)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10 if _compact_layout else 14
	style.content_margin_right = 10 if _compact_layout else 14
	style.content_margin_top = 8 if _compact_layout else 12
	style.content_margin_bottom = 8 if _compact_layout else 12
	return style

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []

static func _as_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not value is Array:
		return result
	for item: Variant in Array(value):
		if item is Dictionary:
			result.append(Dictionary(item))
	return result

func _battle_history_for_active_save() -> Array[Dictionary]:
	return _battle_lifecycle_flow.battle_history_for_active_save(self)

func _clear_battle_history() -> void:
	_battle_lifecycle_flow.clear_battle_history(self)

func _action_payload(action_id: String) -> Dictionary:
	return AppShellActionContractScript.action_payload(
		action_id,
		_current_screen,
		SessionStore.active_save_type,
		SessionStore.has_account_state(),
		SessionStore.offline
	)

func _emit_client_event(event_type: String, payload: Dictionary) -> void:
	if SessionStore.is_progression_lab_local_only():
		return
	if not SessionStore.has_valid_access_token():
		return
	call_deferred("_send_telemetry_deferred", event_type, payload.duplicate(true))

func _send_telemetry_deferred(event_type: String, payload: Dictionary) -> void:
	var result: Dictionary = await SupabaseClient.send_client_telemetry(
		SessionStore.access_token,
		SessionStore.ensure_session_id(),
		event_type,
		payload
	)
	if not bool(result.get("ok", false)):
		var error_payload := _extract_error(result)
		print("[telemetry] %s: %s" % [
			str(error_payload.get("code", "TELEMETRY_FAILED")),
			str(error_payload.get("message", "")),
		])
