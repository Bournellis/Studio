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
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const AppShellErrorContractScript := preload("res://modes/boot/ui/app_shell_error_contract.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")

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
const ACTION_SKIP_REPLAY := "skip_battle_replay"
const ACTION_RETURN_REFUGE := "return_refuge"
const ACTION_REPLAY_LATEST := "replay_latest_battle"
const ACTION_SHOW_CURRENT_BATTLE_LOGS := "show_current_battle_logs"
const ACTION_RETURN_BATTLE_SUMMARY := "return_battle_summary"

const RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]
const BASE_STRUCTURE_IDS := ["altar_das_almas", "nucleo_energia", "pocos_sangue", "minas_cristal", "estrutura_stats", "ossario"]
const ALPHA_ENERGY_PACK_PRODUCT_ID := "alpha_energy_pack_small"

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
	intro.text = "Crie a conta alpha com email, senha e username."
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
	_battle_replay_presenter.render(
		self,
		_compact_layout,
		SessionStore.last_battle_log,
		SessionStore.last_battle_rewards,
		SessionStore.has_battle_log(),
		_battle_history_for_active_save()
	)
	_timeline_label = _battle_replay_presenter.get_timeline_label()
	_battle_visual = _battle_replay_presenter.get_visual()

func _render_battle_running_screen() -> void:
	var overlay := _create_battle_fullscreen_overlay()
	_battle_replay_presenter.render_fullscreen_replay(
		self,
		overlay,
		_compact_layout,
		SessionStore.last_battle_log,
		SessionStore.last_battle_rewards
	)
	_timeline_label = _battle_replay_presenter.get_timeline_label()
	_battle_visual = _battle_replay_presenter.get_visual()

func _render_battle_summary_screen() -> void:
	var overlay := _create_battle_fullscreen_overlay()
	_battle_replay_presenter.render_fullscreen_summary(
		self,
		overlay,
		_compact_layout,
		SessionStore.last_battle_log,
		SessionStore.last_battle_rewards,
		SessionStore.resources,
		_battle_summary_skipped
	)
	_timeline_label = _battle_replay_presenter.get_timeline_label()
	_battle_visual = _battle_replay_presenter.get_visual()

func _render_battle_logs_screen() -> void:
	var overlay := _create_battle_fullscreen_overlay()
	_battle_replay_presenter.render_fullscreen_logs(
		self,
		overlay,
		_compact_layout,
		SessionStore.last_battle_log,
		SessionStore.last_battle_rewards
	)
	_timeline_label = _battle_replay_presenter.get_timeline_label()
	_battle_visual = _battle_replay_presenter.get_visual()

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
	elif action_id.begins_with("select_base_structure:"):
		_select_base_structure(action_id.get_slice(":", 1))
	elif action_id.begins_with("upgrade_base_structure:"):
		await _upgrade_base_structure(action_id.get_slice(":", 1))
	elif action_id.begins_with("shop_purchase:"):
		await _buy_shop_product(action_id.get_slice(":", 1))
	elif action_id.begins_with("claim_reward:"):
		await _claim_shop_reward(action_id.get_slice(":", 1))
	elif action_id.begins_with("battle_replay:"):
		await _show_battle_replay(action_id.get_slice(":", 1))
	else:
		match action_id:
			"enter_guest":
				await _enter_guest()
			"enter_refuge":
				await _enter_refuge()
			"open_create_account":
				_open_create_account_dialog()
			"check_update":
				await _check_update_manifest(true)
			"email_sign_up":
				await _email_sign_up()
			"email_sign_in":
				await _email_sign_in()
			"refresh_session":
				await _refresh_session()
			"reset_session":
				await _reset_local_session()
			"reset_active_save":
				await _reset_active_save()
			"select_save_normal":
				await _select_save(SessionStoreScript.SAVE_TYPE_NORMAL)
			"select_save_progression_lab":
				await _select_save(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
			"open_battle_lab":
				_open_battle_lab_overlay()
			"open_progression_lab":
				_open_progression_lab_overlay()
			"request_battle":
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
			"show_latest_battle":
				if _replay_running:
					_skip_replay = true
					return
				await _show_latest_battle()
			"show_battle_history":
				await _show_battle_history()
			"show_base":
				await _show_base()
			"collect_base":
				await _collect_base()
			"buy_energy_pack_alpha":
				await _buy_energy_pack_alpha()
			"upgrade_nucleo":
				await _upgrade_base_structure("nucleo_energia")
			"show_social":
				await _show_social()
			"add_friend":
				await _add_friend()
			"create_guild":
				await _create_guild()
			"join_guild":
				await _join_guild()
			"send_guild_chat":
				await _send_guild_chat()
			"show_matchmaking":
				await _show_matchmaking()
			"show_ranking":
				await _show_ranking()
			"show_shop":
				await _show_shop()
			"buy_premium_alpha":
				await _buy_shop_product("alpha_battle_pass_premium")
			"grant_diamond_alpha":
				await _buy_shop_product("alpha_redeem_medium")
			"claim_daily_reward":
				await _claim_shop_reward("daily_collect_base")
	if _active_action_id == action_id:
		var event_type := "action_failure" if _error_label.text != "" else "action_success"
		var payload := _action_payload(action_id)
		if _error_label.text != "":
			payload["error_text"] = _error_label.text
		_emit_client_event(event_type, payload)
	_active_action_id = ""

func _check_runtime_config() -> void:
	var config_result: Dictionary = await SupabaseClient.fetch_runtime_config()
	var config_payload := _as_dictionary(config_result.get("runtime_config", {}))
	if config_payload.is_empty():
		config_payload = _as_dictionary(config_result.get("body", {}))
	SessionStore.apply_runtime_config(config_payload)

func _check_update_manifest(manual: bool = false) -> void:
	if manual:
		_set_busy(true, "Checando manifest de update...")
	var manifest_result: Dictionary = await SupabaseClient.fetch_update_manifest()
	if bool(manifest_result.get("ok", false)):
		_update_gate = ProjectInfoScript.update_status_from_manifest(
			_as_dictionary(manifest_result.get("body", {})),
			SupabaseClient.manifest_url()
		)
		_error_label.text = ""
	else:
		var update_error := _extract_error(manifest_result)
		_update_gate = ProjectInfoScript.update_status_error(
			str(update_error.get("code", "UPDATE_CHECK_FAILED")),
			str(update_error.get("message", "Manifest indisponivel.")),
			SupabaseClient.manifest_url()
		)
		if manual:
			_error_label.text = str(_update_gate.get("detail", "Manifest indisponivel."))
	if manual:
		_set_busy(false, str(_update_gate.get("summary", "Checagem concluida.")))
	elif bool(_update_gate.get("block_online", false)):
		_error_label.text = "Update obrigatorio antes de usar recursos online."
		_detail_label.text = str(_update_gate.get("detail", "Baixe a nova build pelo portal."))
	_refresh_update_output_label()
	_sync_status_from_session()

func _enter_guest() -> void:
	_set_busy(true, "Criando sessao guest...")
	var auth_result: Dictionary = {"ok": true}
	if not SessionStore.has_valid_access_token() or SessionStore.is_progression_lab_local_only():
		auth_result = await SupabaseClient.sign_in_anonymously()
		if not bool(auth_result.get("ok", false)):
			_fail_with_error(auth_result)
			return
		SessionStore.apply_auth_session(_as_dictionary(auth_result.get("session", {})))
		_clear_battle_history()
		SessionStore.save_cache()

	var request_id := SessionStore.ensure_guest_request_id()
	var guest_result: Dictionary = await SupabaseClient.create_guest_account(
		SessionStore.DEFAULT_INVITE_CODE,
		request_id,
		OS.get_name(),
		SessionStore.access_token
	)
	if not bool(guest_result.get("ok", false)):
		_fail_with_error(guest_result)
		return

	SessionStore.apply_server_state(guest_result)
	var recovered := await _recover_session_state()
	if not recovered:
		return
	_show_notice("Sessao guest pronta. Todas as abas do alpha estao disponiveis.")
	_show_screen(SCREEN_REFUGE, false)

func _enter_refuge() -> void:
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		_show_screen(SCREEN_REFUGE)
		return
	if SessionStore.has_valid_access_token():
		if not SessionStore.has_account_state():
			var active_save_ready := await _recover_or_create_active_save()
			if not active_save_ready:
				return
		_show_screen(SCREEN_REFUGE)
		return
	_error_label.text = "Escolha um save e entre/crie uma conta antes de abrir o Refugio."
	_detail_label.text = "Para teste local, use Guest dev ou carregue um save pelo Progression Lab."
	_sync_immersive_feedback()
	_emit_client_event("precondition_failed", {
		"action_id": "enter_refuge",
		"screen": _current_screen,
		"reason": "missing_session",
	})

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
	var credentials := _auth_form_values(true)
	if credentials.is_empty():
		return
	await _email_sign_up_with_credentials(credentials)

func _email_sign_up_from_dialog() -> void:
	var credentials := _create_account_form_values()
	if credentials.is_empty():
		return
	await _email_sign_up_with_credentials(credentials)

func _email_sign_up_with_credentials(credentials: Dictionary) -> void:
	_set_busy(true, "Criando conta por email...")
	var auth_result: Dictionary = await SupabaseClient.sign_up_with_email(
		str(credentials.get("email", "")),
		str(credentials.get("password", ""))
	)
	if not bool(auth_result.get("ok", false)):
		_fail_with_error(auth_result)
		return
	var selected_save_type := SessionStore.active_save_type
	SessionStore.clear_session()
	_clear_battle_history()
	SessionStore.set_active_save_type(selected_save_type)
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	SessionStore.apply_auth_session(_as_dictionary(auth_result.get("session", {})))
	SessionStore.account_username = str(credentials.get("username", ""))
	SessionStore.save_cache()
	var save_ready := await _recover_or_create_active_save(str(credentials.get("invite", "")), str(credentials.get("username", "")))
	if not save_ready:
		return
	_show_notice("Conta alpha criada. O save %s esta pronto." % SessionStore.active_save_label())
	_show_screen(SCREEN_REFUGE, false)

func _email_sign_in() -> void:
	var credentials := _auth_form_values(false)
	if credentials.is_empty():
		return
	_set_busy(true, "Entrando com email...")
	var auth_result: Dictionary = await SupabaseClient.sign_in_with_email(
		str(credentials.get("email", "")),
		str(credentials.get("password", ""))
	)
	if not bool(auth_result.get("ok", false)):
		_fail_with_error(auth_result)
		return
	var selected_save_type := SessionStore.active_save_type
	SessionStore.clear_session()
	_clear_battle_history()
	SessionStore.set_active_save_type(selected_save_type)
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	SessionStore.apply_auth_session(_as_dictionary(auth_result.get("session", {})))
	if str(credentials.get("username", "")) != "":
		SessionStore.account_username = str(credentials.get("username", ""))
	SessionStore.save_cache()
	var recovered := await _recover_session_state()
	if not recovered:
		var error_payload := _extract_error({
			"error": SessionStore.last_error,
		})
		if str(error_payload.get("code", "")) == "PLAYER_NOT_FOUND" and str(credentials.get("username", "")) != "":
			recovered = await _recover_or_create_active_save(str(credentials.get("invite", "")), str(credentials.get("username", "")))
	if not recovered:
		return
	_show_notice("Login concluido. Save %s sincronizado." % SessionStore.active_save_label())
	_show_screen(SCREEN_REFUGE, false)

func _refresh_session() -> void:
	if not _require_session("Entre com email ou use guest dev antes de sincronizar."):
		return
	var recovered := await _recover_session_state()
	if recovered:
		_show_screen(_current_screen, false)

func _reset_local_session() -> void:
	var previous_player_id := str(SessionStore.player.get("id", ""))
	var previous_session_id := SessionStore.ensure_session_id()
	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		await SupabaseClient.send_client_telemetry(
			SessionStore.access_token,
			previous_session_id,
			"local_session_reset",
			{
				"player_id": previous_player_id,
				"screen": _current_screen,
			}
		)
	SessionStore.clear_session()
	_clear_battle_history()
	SessionStore.save_cache()
	_screen_history.clear()
	_set_busy(false, "Cache local limpo. Entre com email para recuperar a conta alpha ou use guest dev.")
	_show_screen(SCREEN_HUB, false)

func _reset_active_save() -> void:
	if not _require_account("Entre com email antes de resetar o save ativo."):
		return
	_set_busy(true, "Resetando save %s..." % SessionStore.active_save_label())
	var reset_result: Dictionary = await SupabaseClient.reset_active_save(
		SessionStoreScript.create_request_id(),
		SessionStore.access_token
	)
	if not bool(reset_result.get("ok", false)):
		_fail_with_error(reset_result)
		return
	if not SessionStore.apply_save_reset(reset_result):
		_fail_with_error({
			"ok": false,
			"error": SessionStore.last_error,
		})
		return
	SessionStore.save_cache()
	_clear_battle_history()
	_screen_history.clear()
	_set_busy(false, "Save %s resetado. O outro save foi preservado." % SessionStore.active_save_label())
	_show_screen(SCREEN_HUB, false)

func _select_save(save_type: String) -> void:
	var changed := SessionStore.set_active_save_type(save_type)
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	if changed:
		_clear_battle_history()
		_screen_history.clear()

	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		var active_save_ready := await _recover_or_create_active_save()
		if not active_save_ready:
			_show_screen(SCREEN_HUB, false)
			return
		var ready_message := "Save %s pronto. Batalha, Refugio, Social, Competicao e Loja usam este contexto." % SessionStore.active_save_label()
		if SessionStore.is_progression_lab_active():
			ready_message = "Save Progression Lab pronto. As abas usam o player Lab isolado e ele nao pontua ranking."
		_set_busy(false, ready_message)
		_show_screen(SCREEN_HUB, false)
		return

	if changed:
		var message := "Save ativo alterado para %s." % SessionStore.active_save_label()
		if SessionStore.is_progression_lab_active():
			message = "Save Progression Lab selecionado. Entre com email para criar/carregar o player Lab isolado ou use guest dev."
		_set_busy(false, message)
	else:
		_set_busy(false, "Save %s ja estava ativo." % SessionStore.active_save_label())
	_show_screen(SCREEN_HUB, false)

func _recover_session_state() -> bool:
	if SessionStore.is_progression_lab_local_only():
		_sync_status_from_session()
		return false
	if not SessionStore.has_valid_access_token():
		_sync_status_from_session()
		return false

	_set_busy(true, "Recuperando estado do servidor...")
	var state_result: Dictionary = await SupabaseClient.fetch_account_state(SessionStore.access_token)
	if not bool(state_result.get("ok", false)):
		_fail_with_error(state_result)
		return false

	return _apply_recovered_state(state_result, "Sessao sincronizada com o servidor.")

func _recover_or_create_active_save(invite_code: String = "", username: String = "") -> bool:
	if SessionStore.is_progression_lab_local_only():
		_sync_status_from_session()
		return false
	if not SessionStore.has_valid_access_token():
		_sync_status_from_session()
		return false

	_set_busy(true, "Carregando save %s..." % SessionStore.active_save_label())
	var state_result: Dictionary = await SupabaseClient.fetch_account_state(SessionStore.access_token)
	if bool(state_result.get("ok", false)):
		return _apply_recovered_state(state_result, "Save %s sincronizado." % SessionStore.active_save_label())

	var state_error := _extract_error(state_result)
	if str(state_error.get("code", "")) != "PLAYER_NOT_FOUND":
		_fail_with_error(state_result)
		return false

	_set_busy(true, "Criando save %s..." % SessionStore.active_save_label())
	var account_result: Dictionary
	if SessionStore.is_registered_session():
		var effective_username := _effective_alpha_username(username)
		var effective_invite := _effective_alpha_invite(invite_code)
		account_result = await SupabaseClient.bootstrap_alpha_account(
			effective_invite,
			effective_username,
			SessionStore.ensure_alpha_account_request_id(),
			OS.get_name(),
			SessionStore.access_token
		)
	else:
		account_result = await SupabaseClient.create_guest_account(
			SessionStore.DEFAULT_INVITE_CODE,
			SessionStore.ensure_guest_request_id(),
			OS.get_name(),
			SessionStore.access_token
		)
	if not bool(account_result.get("ok", false)):
		var account_error := _extract_error(account_result)
		if str(account_error.get("code", "")) == "ACCOUNT_ALREADY_CREATED":
			state_result = await SupabaseClient.fetch_account_state(SessionStore.access_token)
			if bool(state_result.get("ok", false)):
				return _apply_recovered_state(state_result, "Save %s sincronizado." % SessionStore.active_save_label())
		_fail_with_error(account_result)
		return false

	return _apply_recovered_state(account_result, "Save %s pronto." % SessionStore.active_save_label())

func _auth_form_values(require_username: bool) -> Dictionary:
	var email := _social_input_text(_auth_email_input).to_lower()
	var password := _social_input_text(_auth_password_input)
	var username := _normalized_alpha_username(_social_input_text(_auth_username_input, SessionStore.account_username))
	var invite := _social_input_text(_auth_invite_input, SessionStore.DEFAULT_INVITE_CODE).to_upper()

	if email == "" or not email.contains("@") or not email.contains("."):
		_error_label.text = "Informe um email valido."
		_detail_label.text = "A conta alpha usa email/senha para compartilhar o save entre PC, Web e Android."
		return {}
	if password.length() < 6:
		_error_label.text = "A senha precisa ter pelo menos 6 caracteres."
		_detail_label.text = "Use a mesma senha para recuperar o save em outra plataforma."
		return {}
	if require_username and username == "":
		_error_label.text = "Informe um username valido."
		_detail_label.text = "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore."
		return {}
	if username != "" and not _is_valid_alpha_username(username):
		_error_label.text = "Username invalido."
		_detail_label.text = "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore."
		return {}
	if require_username and invite == "":
		_error_label.text = "Informe o convite alpha."
		_detail_label.text = "O convite libera o primeiro save desta conta."
		return {}

	return {
		"email": email,
		"password": password,
		"username": username,
		"invite": invite,
	}

func _create_account_form_values() -> Dictionary:
	var email := _social_input_text(_signup_email_input).to_lower()
	var password := _social_input_text(_signup_password_input)
	var username := _normalized_alpha_username(_social_input_text(_signup_username_input, SessionStore.account_username))

	if email == "" or not email.contains("@") or not email.contains("."):
		_error_label.text = "Informe um email valido."
		_detail_label.text = "A conta alpha usa email/senha para compartilhar o save entre PC, Web e Android."
		_sync_immersive_feedback()
		return {}
	if password.length() < 6:
		_error_label.text = "A senha precisa ter pelo menos 6 caracteres."
		_detail_label.text = "Use a mesma senha para recuperar o save em outra plataforma."
		_sync_immersive_feedback()
		return {}
	if username == "":
		_error_label.text = "Informe um username valido."
		_detail_label.text = "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore."
		_sync_immersive_feedback()
		return {}
	if not _is_valid_alpha_username(username):
		_error_label.text = "Username invalido."
		_detail_label.text = "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore."
		_sync_immersive_feedback()
		return {}

	return {
		"email": email,
		"password": password,
		"username": username,
		"invite": SessionStore.DEFAULT_INVITE_CODE,
	}

func _effective_alpha_username(username: String) -> String:
	var normalized := _normalized_alpha_username(username)
	if normalized == "":
		normalized = _normalized_alpha_username(SessionStore.account_username)
	if normalized == "":
		normalized = _normalized_alpha_username(SessionStore.player_display_name())
	if normalized == "":
		normalized = "tester_%s" % SessionStore.ensure_session_id().replace("-", "").substr(0, 8)
	normalized = SessionStoreScript.base_account_username(normalized)
	return normalized

func _effective_alpha_invite(invite_code: String) -> String:
	var normalized := invite_code.strip_edges().to_upper()
	if normalized == "":
		normalized = _social_input_text(_auth_invite_input, SessionStore.DEFAULT_INVITE_CODE).to_upper()
	if normalized == "":
		normalized = SessionStore.DEFAULT_INVITE_CODE
	return normalized

func _normalized_alpha_username(username: String) -> String:
	return username.strip_edges().to_lower()

func _is_valid_alpha_username(username: String) -> bool:
	if username.length() < 3 or username.length() > 24:
		return false
	for index in username.length():
		var code := username.unicode_at(index)
		var is_number := code >= 48 and code <= 57
		var is_lower := code >= 97 and code <= 122
		var is_underscore := code == 95
		if not is_number and not is_lower and not is_underscore:
			return false
	return true

func _apply_recovered_state(state_result: Dictionary, message: String) -> bool:
	if not SessionStore.apply_server_state(state_result):
		_fail_with_error({
			"ok": false,
			"error": SessionStore.last_error,
		})
		return false
	SessionStore.save_cache()
	_set_busy(false, message)
	_sync_status_from_session()
	return true

func _request_battle() -> void:
	if not _require_account("Entre com email antes de solicitar batalha."):
		return

	_show_screen(SCREEN_BATTLE, false)
	_set_busy(true, "Solicitando batalha...")
	var battle_result: Dictionary = await SupabaseClient.request_battle(
		SessionStoreScript.create_request_id(),
		SessionStore.access_token,
		ProjectInfoScript.DEFAULT_BATTLE_MODE
	)
	if not bool(battle_result.get("ok", false)):
		_fail_with_error(battle_result)
		return

	if not SessionStore.apply_battle_result(battle_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	var recovered := await _recover_session_state()
	if not recovered:
		return
	await _play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func _show_latest_battle() -> void:
	if not _require_session("Entre com email ou use guest dev antes de ver resultado."):
		return

	_show_screen(SCREEN_BATTLE, false)
	_set_busy(true, "Buscando ultimo resultado...")
	var latest_result: Dictionary = await SupabaseClient.fetch_latest_battle(SessionStore.access_token)
	if not bool(latest_result.get("ok", false)):
		_fail_with_error(latest_result)
		return

	var body := _as_dictionary(latest_result.get("body", {}))
	if body.get("battle_log", null) == null:
		_set_busy(false, "Nenhuma batalha registrada.")
		_battle_replay_presenter.show_empty_state("Solicite uma batalha para gerar o primeiro replay.")
		return

	if not SessionStore.apply_battle_result(latest_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Ultimo resultado recuperado.")
	await _play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func _skip_current_replay() -> void:
	if not _replay_running:
		return
	_skip_replay = true
	_show_notice("Replay pulando para o resumo final...")
	_sync_buttons()

func _return_to_refuge() -> void:
	_replay_running = false
	_skip_replay = false
	_battle_summary_skipped = false
	_show_screen(AppShellRouteContractScript.clear_for_refuge_return(_screen_history), false)

func _show_current_battle_logs() -> void:
	if not SessionStore.has_battle_log():
		_error_label.text = "Nenhum log de batalha carregado."
		return
	_show_screen(ROUTE_BATTLE_LOGS)

func _return_to_battle_summary() -> void:
	_show_screen(ROUTE_BATTLE_SUMMARY, false)

func _replay_latest_battle_from_summary() -> void:
	if not SessionStore.has_battle_log():
		_error_label.text = "Nenhum replay carregado para rever."
		return
	await _play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func _show_battle_history() -> void:
	if not _require_session("Entre com email ou use guest dev antes de abrir o historico."):
		return

	_show_screen(SCREEN_BATTLE, false)
	_set_busy(true, "Buscando historico de batalhas...")
	var history_result: Dictionary = await SupabaseClient.fetch_battle_history(SessionStore.access_token)
	if not bool(history_result.get("ok", false)):
		_fail_with_error(history_result)
		return

	var body := _as_dictionary(history_result.get("body", {}))
	_battle_history_entries = _as_dictionary_array(body.get("history", []))
	_battle_history_save_type = SessionStore.active_save_type
	_show_screen(SCREEN_BATTLE, false)
	_set_busy(false, "Historico atualizado: %d batalhas recentes." % _battle_history_entries.size())

func _show_battle_replay(battle_id: String) -> void:
	if not _require_session("Entre com email ou use guest dev antes de reproduzir historico."):
		return

	var requested_battle_id := battle_id.strip_edges()
	if requested_battle_id == "":
		_error_label.text = "BATTLE_ID_MISSING: batalha invalida no historico."
		return

	_show_screen(SCREEN_BATTLE, false)
	_set_busy(true, "Carregando replay salvo...")
	var replay_result: Dictionary = await SupabaseClient.fetch_battle_replay(
		requested_battle_id,
		SessionStore.access_token
	)
	if not bool(replay_result.get("ok", false)):
		_fail_with_error(replay_result)
		return

	if not SessionStore.apply_battle_result(replay_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Replay salvo recuperado.")
	await _play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func _show_base() -> void:
	var target_screen := _base_surface_target_screen()
	if SessionStore.is_progression_lab_local_only():
		_show_screen(target_screen, false)
		_set_busy(false, "Snapshot local do Progression Lab carregado. Refugio em modo somente leitura; coletas e upgrades precisam de save seeded no Supabase local.")
		_render_base_state()
		return
	if not _require_session("Entre com email ou use guest dev antes de atualizar o Refugio."):
		return

	_show_screen(target_screen, false)
	_set_busy(true, "Buscando Refugio...")
	var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
	if not bool(base_result.get("ok", false)):
		_fail_with_error(base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Refugio recuperado.")
	_render_base_state()

func _sync_refuge_state_if_needed() -> void:
	if _current_screen != SCREEN_REFUGE:
		return
	if _is_busy or not SessionStore.base_state.is_empty():
		return
	if SessionStore.is_progression_lab_local_only():
		return
	if not SessionStore.has_valid_access_token():
		return
	await _show_base()

func _collect_base() -> void:
	if not _require_account("Entre com email ou use guest dev antes de coletar o Refugio."):
		return

	_show_screen(_base_surface_target_screen(), false)
	_set_busy(true, "Coletando producao offline...")
	var base_result: Dictionary = await SupabaseClient.collect_base(
		SessionStoreScript.create_request_id(),
		SessionStore.access_token
	)
	if not bool(base_result.get("ok", false)):
		_fail_with_error(base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	var body := _as_dictionary(base_result.get("body", {}))
	var collected := _as_dictionary(body.get("collected", {}))
	var message := "Coleta registrada no servidor."
	if _resource_total(collected) <= 0.0:
		message = "Nada para coletar agora."
	SessionStore.save_cache()
	_set_busy(false, message)
	_render_base_state(collected)

func _buy_energy_pack_alpha() -> void:
	if not _require_account("Entre com email ou use guest dev antes de comprar Energia alpha."):
		return

	_show_screen(_base_surface_target_screen(), false)
	_set_busy(true, "Comprando pacote de Energia alpha...")
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		SessionStoreScript.create_request_id(),
		ALPHA_ENERGY_PACK_PRODUCT_ID,
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return

	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
	if bool(base_result.get("ok", false)):
		SessionStore.apply_base_result(base_result)

	SessionStore.save_cache()
	_set_busy(false, "Energia alpha comprada. O Refugio foi atualizado com o novo saldo.")
	_render_base_state()

func _upgrade_base_structure(structure_id: String) -> void:
	if not _require_account("Entre com email ou use guest dev antes de evoluir o Refugio."):
		return
	var target_structure_id := structure_id.strip_edges()
	if target_structure_id == "":
		target_structure_id = _selected_base_structure_id
	_selected_base_structure_id = target_structure_id

	_show_screen(_base_surface_target_screen(), false)
	_set_busy(true, "Solicitando evolucao de %s..." % _structure_label(target_structure_id))
	var base_result: Dictionary = await SupabaseClient.upgrade_base_structure(
		SessionStoreScript.create_request_id(),
		target_structure_id,
		SessionStore.access_token
	)
	if not bool(base_result.get("ok", false)):
		_fail_with_error(base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Evolucao de %s iniciada no servidor." % _structure_label(target_structure_id))
	_render_base_state()

func _base_surface_target_screen() -> String:
	if _current_screen == SCREEN_REFUGE:
		return SCREEN_REFUGE
	return SCREEN_BASE

func _show_social() -> void:
	if not _require_session("Entre com email ou use guest dev antes de abrir Social."):
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Buscando Social...")
	var social_result: Dictionary = await SupabaseClient.fetch_social_state(SessionStore.access_token)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Social recuperado.")
	_render_social_state()

func _add_friend() -> void:
	if not _require_account("Entre com email ou use guest dev antes de adicionar amigo."):
		return

	_last_social_friend_username = _social_input_text(_social_friend_input)
	if _last_social_friend_username == "":
		_error_label.text = "Informe o username do amigo."
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Adicionando amigo...")
	var social_result: Dictionary = await SupabaseClient.add_friend(
		SessionStoreScript.create_request_id(),
		_last_social_friend_username,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Amigo adicionado.")
	_render_social_state()

func _create_guild() -> void:
	if not _require_account("Entre com email ou use guest dev antes de criar guilda."):
		return

	_last_social_guild_name = _social_input_text(_social_guild_input, _default_guild_name())
	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Criando guilda alpha...")
	var social_result: Dictionary = await SupabaseClient.create_guild(
		SessionStoreScript.create_request_id(),
		_last_social_guild_name,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Guilda criada no servidor.")
	_render_social_state()

func _join_guild() -> void:
	if not _require_account("Entre com email ou use guest dev antes de entrar em guilda."):
		return

	_last_social_guild_name = _social_input_text(_social_guild_input)
	if _last_social_guild_name == "":
		_error_label.text = "Informe o nome da guilda."
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Entrando na guilda...")
	var social_result: Dictionary = await SupabaseClient.join_guild(
		SessionStoreScript.create_request_id(),
		_last_social_guild_name,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Guilda sincronizada.")
	_render_social_state()

func _send_guild_chat() -> void:
	if not _require_account("Entre com email ou use guest dev antes de usar chat."):
		return

	_last_social_chat_message = _social_input_text(_social_chat_input, _last_social_chat_message)
	if _last_social_chat_message == "":
		_error_label.text = "Digite uma mensagem para o chat da guilda."
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Enviando mensagem de guilda...")
	var social_result: Dictionary = await SupabaseClient.send_guild_chat(
		SessionStoreScript.create_request_id(),
		_last_social_chat_message,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Mensagem registrada no servidor.")
	_render_social_state()

func _show_matchmaking() -> void:
	if not _require_session("Entre com email ou use guest dev antes de abrir matchmaking."):
		return

	_show_screen(SCREEN_COMPETITION, false)
	_set_busy(true, "Buscando matchmaking...")
	var competition_result: Dictionary = await SupabaseClient.fetch_matchmaking_preview(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		_fail_with_error(competition_result)
		return
	if not SessionStore.apply_competition_result(competition_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Matchmaking recuperado.")
	_render_competition_state()

func _show_ranking() -> void:
	if not _require_session("Entre com email ou use guest dev antes de abrir ranking."):
		return

	_show_screen(SCREEN_COMPETITION, false)
	_set_busy(true, "Buscando ranking...")
	var competition_result: Dictionary = await SupabaseClient.fetch_ranking_current(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		_fail_with_error(competition_result)
		return
	if not SessionStore.apply_competition_result(competition_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Ranking recuperado.")
	_render_competition_state()

func _show_shop() -> void:
	if not _require_session("Entre com email ou use guest dev antes de abrir Loja."):
		return

	_show_screen(SCREEN_SHOP, false)
	_set_busy(true, "Buscando loja alpha...")
	var monetization_result: Dictionary = await SupabaseClient.fetch_monetization_state(SessionStore.access_token)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Loja alpha recuperada.")
	_render_monetization_state()

func _buy_shop_product(product_id: String) -> void:
	if not _require_account("Entre com email ou use guest dev antes de comprar na Loja."):
		return

	_show_screen(SCREEN_SHOP, false)
	_set_busy(true, "Processando produto alpha...")
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		SessionStoreScript.create_request_id(),
		product_id,
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	if product_id == ALPHA_ENERGY_PACK_PRODUCT_ID or product_id == "alpha_double_construction_queue":
		var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
		if bool(base_result.get("ok", false)):
			SessionStore.apply_base_result(base_result)

	SessionStore.save_cache()
	_set_busy(false, _shop_purchase_message(product_id, _as_dictionary(monetization_result.get("body", {}))))
	_render_monetization_state()

func _claim_shop_reward(reward_id: String) -> void:
	if not _require_account("Entre com email ou use guest dev antes de resgatar recompensa."):
		return

	_show_screen(SCREEN_SHOP, false)
	_set_busy(true, "Resgatando recompensa...")
	var monetization_result: Dictionary = await SupabaseClient.claim_reward(
		SessionStoreScript.create_request_id(),
		reward_id,
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	var body := _as_dictionary(monetization_result.get("body", {}))
	var message := "Recompensa registrada no servidor."
	if bool(body.get("already_claimed", false)):
		message = "Recompensa ja havia sido resgatada neste periodo."
	SessionStore.save_cache()
	_set_busy(false, message)
	_render_monetization_state()

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
	if _immersive_status_label != null and is_instance_valid(_immersive_status_label):
		_immersive_status_label.text = _status_label.text if _status_label != null else _session_status_text()
	if _immersive_detail_label != null and is_instance_valid(_immersive_detail_label):
		_immersive_detail_label.text = _detail_label.text if _detail_label != null else ""
	if _immersive_error_label != null and is_instance_valid(_immersive_error_label):
		_immersive_error_label.text = _error_label.text if _error_label != null else ""

func _sync_buttons() -> void:
	for action_id: String in _action_buttons.keys():
		var button: Button = _action_buttons[action_id]
		if not is_instance_valid(button):
			continue
		button.disabled = _is_busy or (_replay_running and not _action_allowed_during_replay(action_id))
		button.disabled = button.disabled or _update_gate_blocks_action(action_id)
		if action_id == ACTION_SKIP_REPLAY:
			button.disabled = not _replay_running
		if action_id == "select_save_normal":
			button.disabled = button.disabled or not SessionStore.is_progression_lab_active()
		elif action_id == "select_save_progression_lab":
			button.disabled = button.disabled or SessionStore.is_progression_lab_active()
		elif action_id.begins_with("upgrade_base_structure:"):
			button.disabled = button.disabled or not _can_upgrade_base_structure(action_id.get_slice(":", 1))
		elif action_id.begins_with("shop_purchase:"):
			var product := _shop_product_by_id(action_id.get_slice(":", 1))
			if not product.is_empty():
				button.disabled = button.disabled or not bool(product.get("can_purchase", true))
		elif action_id.begins_with("claim_reward:"):
			var reward := _shop_reward_by_id(action_id.get_slice(":", 1))
			if not reward.is_empty():
				button.disabled = button.disabled or bool(reward.get("claimed", false))
		if action_id == "show_latest_battle":
			button.text = "Pular replay" if _replay_running else "Ver resultado"
	for screen_id: String in _nav_buttons.keys():
		var nav_button: Button = _nav_buttons[screen_id]
		nav_button.disabled = _is_busy or _replay_running
	if _back_button != null:
		_back_button.disabled = _is_busy or _replay_running

func _action_allowed_during_replay(action_id: String) -> bool:
	return AppShellRouteContractScript.is_safe_replay_action(action_id)

func _update_status_text() -> String:
	return HubAccountSurfacePresenterScript.update_status_text(self)

func _refresh_update_output_label() -> void:
	if _update_output_label != null and is_instance_valid(_update_output_label):
		_update_output_label.text = _update_status_text()

func _update_gate_blocks_action(action_id: String) -> bool:
	if not bool(_update_gate.get("block_online", false)):
		return false
	if _replay_running and AppShellRouteContractScript.is_safe_replay_action(action_id):
		return false
	if action_id in [
		ACTION_SKIP_REPLAY,
		ACTION_RETURN_REFUGE,
		ACTION_REPLAY_LATEST,
	]:
		return false
	if action_id in [
		"check_update",
		"reset_session",
		"select_save_normal",
		"select_save_progression_lab",
		"open_battle_lab",
		"open_progression_lab",
	]:
		return false
	if action_id.begins_with("select_base_structure:"):
		return false
	return true

func _sync_nav_buttons() -> void:
	for screen_id: String in _nav_buttons.keys():
		var button: Button = _nav_buttons[screen_id]
		button.button_pressed = screen_id == _current_screen

func _require_session(message: String) -> bool:
	if SessionStore.is_progression_lab_local_only():
		_error_label.text = "Save local-only do Progression Lab nao executa acoes online."
		_detail_label.text = "Use o seeder com Supabase local para testar batalha, coleta, upgrades e outras mutacoes server-authoritative."
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
	_detail_label.text = "Entre com email no Refugio ou use guest dev para teste local."
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
		_detail_label.text = "Para batalhas, coleta, upgrades e compras, rode o seeder com Supabase local e carregue o cache server-backed."
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
	_detail_label.text = "Entre com email no Refugio ou use guest dev para teste local."
	_sync_immersive_feedback()
	_emit_client_event("precondition_failed", {
		"action_id": _active_action_id,
		"screen": _current_screen,
		"reason": "missing_account",
	})
	return false

func _render_base_state(collected: Dictionary = {}) -> void:
	BaseSurfacePresenterScript.render_state(self, collected)

func _render_base_playable_panels(structures: Array, base: Dictionary, collected: Dictionary) -> void:
	if _base_state_container == null:
		return
	_ensure_selected_base_structure(structures)
	_base_state_container.add_child(_base_summary_panel(base, collected))
	_base_state_container.add_child(_base_map_panel(structures))
	_base_state_container.add_child(_base_detail_panel(structures))

func _base_summary_panel(base: Dictionary, collected: Dictionary) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Resumo do Refugio", "text_primary", 17))
	box.add_child(_base_label("Recursos: %s" % _format_resources(SessionStore.resources), "text_secondary"))
	var active_jobs := _active_base_jobs(_as_array(base.get("jobs", [])))
	box.add_child(_base_label("Fila de construcao: %d/%d" % [
		active_jobs.size(),
		int(base.get("construction_slots", 1)),
	], "text_secondary"))
	if not collected.is_empty():
		var collect_text := "Coleta: nada acumulado agora."
		if _resource_total(collected) > 0.0:
			collect_text = "Coletado agora: %s" % _format_resources(collected, false)
		box.add_child(_base_label(collect_text, "status_success"))
	if SessionStore.is_progression_lab_active():
		box.add_child(_base_label("Progression Lab: base isolada do save normal.", "status_warning"))
	return panel

func _base_map_panel(structures: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label("Mapa do Refugio", "text_primary", 17))
	var grid := GridContainer.new()
	grid.columns = _base_map_columns()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for structure_id: String in BASE_STRUCTURE_IDS:
		var structure := _base_structure_by_id(structures, structure_id)
		if structure.is_empty():
			continue
		grid.add_child(_base_structure_button(structure))
	return panel

func _base_detail_panel(structures: Array) -> Control:
	var structure := _base_structure_by_id(structures, _selected_base_structure_id)
	if structure.is_empty() and not structures.is_empty():
		structure = _as_dictionary(structures[0])
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	if structure.is_empty():
		box.add_child(_base_label("Selecione um predio no mapa do Refugio.", "text_secondary"))
		return panel

	var structure_id := str(structure.get("structure_id", ""))
	var display_label := _structure_label(structure_id, str(structure.get("display_name", "")))
	box.add_child(_base_label("%s - Level %s/%s" % [
		display_label,
		str(structure.get("level", 0)),
		str(structure.get("max_level", 40)),
	], "text_primary", 18))
	box.add_child(_base_label(str(structure.get("description", "")), "text_secondary"))
	box.add_child(_base_label("Beneficio: %s" % _base_benefit_text(structure), "text_secondary"))
	box.add_child(_base_label("Producao pendente: %s" % _base_pending_text(structure), "text_secondary"))
	box.add_child(_base_label("Proximo upgrade: %s" % _base_upgrade_text(structure), "text_secondary"))
	box.add_child(_base_label("Status: %s" % str(structure.get("blocked_message", "")), _base_status_color_token(structure)))

	var action_id := "upgrade_base_structure:%s" % structure_id
	var upgrade_button := Button.new()
	upgrade_button.text = "Evoluir %s" % display_label
	upgrade_button.custom_minimum_size = _button_min_size()
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.tooltip_text = _base_structure_tooltip(structure)
	upgrade_button.disabled = not _can_upgrade_base_structure(structure_id)
	upgrade_button.pressed.connect(func() -> void:
		_trigger_action(action_id, "Iniciar upgrade de %s no servidor?" % display_label)
	)
	box.add_child(upgrade_button)
	_action_buttons[action_id] = upgrade_button
	return panel

func _base_structure_button(structure: Dictionary) -> Button:
	var structure_id := str(structure.get("structure_id", ""))
	var selected := structure_id == _selected_base_structure_id
	var button := Button.new()
	button.text = "%s\n%s\nL%s -> %s\n%s" % [
		_base_structure_symbol(structure_id),
		_base_structure_short_label(structure_id),
		str(structure.get("level", 0)),
		_base_next_level_text(structure),
		_base_short_status(structure),
	]
	button.custom_minimum_size = Vector2(132, 96) if _compact_layout else Vector2(170, 112)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = _base_structure_tooltip(structure)
	button.add_theme_stylebox_override("normal", _base_structure_card_style(structure_id, selected))
	button.add_theme_stylebox_override("hover", _base_structure_card_style(structure_id, true))
	button.add_theme_stylebox_override("pressed", _base_structure_card_style(structure_id, true))
	var action_id := "select_base_structure:%s" % structure_id
	button.pressed.connect(func() -> void:
		_trigger_action(action_id)
	)
	_action_buttons[action_id] = button
	return button

func _select_base_structure(structure_id: String) -> void:
	BaseSurfacePresenterScript.select_structure(self, structure_id)

func _ensure_selected_base_structure(structures: Array) -> void:
	if not _base_structure_by_id(structures, _selected_base_structure_id).is_empty():
		return
	for structure_id: String in BASE_STRUCTURE_IDS:
		if not _base_structure_by_id(structures, structure_id).is_empty():
			_selected_base_structure_id = structure_id
			return
	if not structures.is_empty():
		_selected_base_structure_id = str(_as_dictionary(structures[0]).get("structure_id", _selected_base_structure_id))

func _base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		if str(structure.get("structure_id", "")) == structure_id:
			return structure
	return {}

func _base_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return panel

func _base_info_panel(title_text: String, body_text: String) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(title_text, "text_primary", 17))
	box.add_child(_base_label(body_text, "text_secondary"))
	return panel

func _base_label(text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	if font_size > 0:
		label.add_theme_font_size_override("font_size", max(12, font_size - 1) if _compact_layout else font_size)
	elif _compact_layout:
		label.add_theme_font_size_override("font_size", 13)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _base_structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _base_structure_color(structure_id).darkened(0.25 if selected else 0.45)
	style.border_color = UiTokens.color("status_success") if selected else UiTokens.color("border_default")
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _base_structure_color(structure_id: String) -> Color:
	match structure_id:
		"altar_das_almas":
			return Color(0.45, 0.35, 0.78)
		"nucleo_energia":
			return Color(0.25, 0.58, 0.86)
		"pocos_sangue":
			return Color(0.70, 0.20, 0.26)
		"minas_cristal":
			return Color(0.22, 0.66, 0.62)
		"estrutura_stats":
			return Color(0.58, 0.58, 0.50)
		"ossario":
			return Color(0.72, 0.66, 0.54)
	return UiTokens.color("bg_panel_alt")

func _base_structure_symbol(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "[ALM]"
		"nucleo_energia":
			return "[ENE]"
		"pocos_sangue":
			return "[SAN]"
		"minas_cristal":
			return "[CRI]"
		"estrutura_stats":
			return "[STA]"
		"ossario":
			return "[OSS]"
	return "[???]"

func _base_structure_short_label(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "Altar"
		"nucleo_energia":
			return "Nucleo"
		"pocos_sangue":
			return "Pocos"
		"minas_cristal":
			return "Minas"
		"estrutura_stats":
			return "Stats"
		"ossario":
			return "Ossario"
	return structure_id

func _base_benefit_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces != "" and produces != "<null>":
		return "%s por dia: %s | armazenamento: %s" % [
			produces.capitalize(),
			_format_number(float(structure.get("daily_production", 0.0))),
			_format_number(float(structure.get("storage_cap", 0.0))),
		]
	return str(structure.get("benefit_label", "Bonus permanente."))

func _base_pending_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces == "" or produces == "<null>":
		return "Este predio nao gera coleta direta."
	return "%s %s de %s" % [
		_format_number(float(structure.get("pending_collectable", 0.0))),
		produces.capitalize(),
		_format_number(float(structure.get("storage_cap", 0.0))),
	]

func _base_upgrade_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	if next_level == null:
		return "nivel maximo"
	var cost := _as_dictionary(structure.get("upgrade_cost", {}))
	return "L%s | custo %s | tempo %s" % [
		str(next_level),
		_format_cost(cost),
		_format_duration(int(structure.get("upgrade_duration_seconds", 0))),
	]

func _base_next_level_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	return "max" if next_level == null else "L%s" % str(next_level)

func _base_short_status(structure: Dictionary) -> String:
	var active_job := _as_dictionary(structure.get("active_job", {}))
	if not active_job.is_empty():
		return "Upgrade %s" % _format_duration(int(active_job.get("remaining_seconds", 0)))
	if bool(structure.get("can_upgrade", false)):
		return "Upgrade pronto"
	return str(structure.get("blocked_message", "Bloqueado"))

func _base_status_color_token(structure: Dictionary) -> String:
	if bool(structure.get("can_upgrade", false)):
		return "status_success"
	var reason := str(structure.get("blocked_reason", ""))
	if reason == "INSUFFICIENT_RESOURCES" or reason == "CONSTRUCTION_QUEUE_FULL":
		return "status_warning"
	return "text_secondary"

func _base_structure_tooltip(structure: Dictionary) -> String:
	var structure_id := str(structure.get("structure_id", ""))
	return "%s\nO que e: %s\nComo funciona: %s\nImporta porque: %s" % [
		_structure_label(structure_id, str(structure.get("display_name", ""))),
		str(structure.get("description", "")),
		_base_upgrade_text(structure),
		_base_benefit_text(structure),
	]

func _can_upgrade_base_structure(structure_id: String) -> bool:
	return BaseSurfacePresenterScript.can_upgrade_structure(self, structure_id)

func _active_base_jobs(jobs: Array) -> Array:
	var active: Array = []
	for item: Variant in jobs:
		var job := _as_dictionary(item)
		if str(job.get("status", "")) == "active":
			active.append(job)
	return active

func _format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "-"
	var parts := PackedStringArray()
	for key: String in cost.keys():
		parts.append("%s %s" % [str(key).capitalize(), _format_number(float(cost.get(key, 0.0)))])
	return " | ".join(parts)

func _format_duration(total_seconds: int) -> String:
	var seconds: int = max(0, total_seconds)
	var hours := int(float(seconds) / 3600.0)
	var minutes := int(float(seconds % 3600) / 60.0)
	var remaining_seconds: int = seconds % 60
	if hours > 0:
		return "%dh %02dm" % [hours, minutes]
	if minutes > 0:
		return "%dm %02ds" % [minutes, remaining_seconds]
	return "%ds" % remaining_seconds

func _format_number(value: float) -> String:
	if abs(value - round(value)) < 0.005:
		return str(int(round(value)))
	return "%.2f" % value

func _render_social_state() -> void:
	SocialSurfacePresenterScript.render_state(self)

func _social_identity_panel(identity: Dictionary, social_player: Dictionary, active_player: Dictionary) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Identidade Social", "text_primary", 17))
	box.add_child(_base_label("Username social: %s" % _social_username_text(social_player), "text_secondary"))
	box.add_child(_base_label("Save ativo: %s" % _social_username_text(active_player), "text_secondary"))
	var badge := str(identity.get("viewer_badge", SessionStore.active_save_badge()))
	var badge_label := _base_label("Marcador visivel: %s" % _social_save_badge_text(badge), "status_error" if badge == "lab" else "status_success")
	box.add_child(badge_label)
	if bool(identity.get("fallback_to_active_save", false)):
		box.add_child(_base_label("Aviso: save Normal ainda nao existe; o social esta usando o save ativo como fallback.", "status_warning"))
	return panel

func _social_friends_panel(friends: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Amigos (%d)" % friends.size(), "text_primary", 17))
	if friends.is_empty():
		box.add_child(_base_label("Nenhum amigo ainda. Use o username do outro jogador para adicionar.", "text_secondary"))
		return panel
	for item: Variant in friends:
		var friendship := _as_dictionary(item)
		var profile := _as_dictionary(friendship.get("friend", {}))
		box.add_child(_base_label("%s | %s | L%s | Poder %s" % [
			_social_username_text(profile),
			str(friendship.get("status", "accepted")),
			str(profile.get("level", 1)),
			str(profile.get("power", 0)),
		], "status_error" if str(profile.get("save_badge", "")) == "lab" else "text_secondary"))
	return panel

func _social_guild_panel(guild: Dictionary, members: Array, structures: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Guilda", "text_primary", 17))
	if guild.is_empty():
		box.add_child(_base_label("Sem guilda. Crie uma guilda ou entre pelo nome.", "text_secondary"))
		return panel
	box.add_child(_base_label("%s | Level %s | %d membros" % [
		str(guild.get("name", "")),
		str(guild.get("level", 1)),
		members.size(),
	], "text_secondary"))
	box.add_child(_base_label("Membros", "text_primary"))
	for item: Variant in members:
		var member := _as_dictionary(item)
		var profile := _as_dictionary(member.get("player", {}))
		var badge := str(profile.get("save_badge", "normal"))
		box.add_child(_base_label("%s | %s | L%s | Poder %s" % [
			_social_username_text(profile),
			str(member.get("role", "member")),
			str(profile.get("level", 1)),
			str(profile.get("power", 0)),
		], "status_error" if badge == "lab" else "text_secondary"))
	box.add_child(_base_label("Estruturas", "text_primary"))
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		box.add_child(_base_label("%s L%s" % [
			_guild_structure_label(str(structure.get("structure_id", ""))),
			str(structure.get("level", 1)),
		], "text_secondary"))
	return panel

func _social_chat_panel(messages: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Chat de Guilda (%d recentes)" % messages.size(), "text_primary", 17))
	if messages.is_empty():
		box.add_child(_base_label("Sem mensagens recentes. Entre em uma guilda e envie a primeira mensagem.", "text_secondary"))
		return panel
	for item: Variant in messages:
		var message := _as_dictionary(item)
		var badge := str(message.get("sender_save_badge", "normal"))
		var sender_label := str(message.get("sender_username", "desconhecido"))
		if badge == "lab":
			sender_label += " [lab]"
		box.add_child(_base_label("%s: %s" % [
			sender_label,
			str(message.get("content", "")),
		], "status_error" if badge == "lab" else "text_secondary"))
	return panel

func _social_input_text(input: LineEdit, fallback: String = "") -> String:
	if input == null:
		return fallback.strip_edges()
	var text := input.text.strip_edges()
	if text == "":
		return fallback.strip_edges()
	return text

func _default_social_guild_text() -> String:
	if _last_social_guild_name.strip_edges() != "":
		return _last_social_guild_name
	var guild := _as_dictionary(SessionStore.social_state.get("guild", {}))
	if not guild.is_empty():
		return str(guild.get("name", "")).strip_edges()
	return _default_guild_name()

func _social_username_text(profile: Dictionary) -> String:
	var username := str(profile.get("username", "")).strip_edges()
	if username == "":
		username = "sem username"
	var badge := str(profile.get("save_badge", "normal"))
	if badge == "lab":
		return "%s [lab]" % username
	return username

func _social_save_badge_text(badge: String) -> String:
	if badge == "lab":
		return "lab"
	return "normal"

func _guild_structure_label(structure_id: String) -> String:
	match structure_id:
		"oficina_ritual":
			return "Oficina Ritual"
		"condensador_astral":
			return "Condensador Astral"
		"arquivo_de_dominio":
			return "Arquivo de Dominio"
		"cofre_abissal":
			return "Cofre Abissal"
	return structure_id

func _render_competition_state() -> void:
	CompetitionSurfacePresenterScript.render_state(self)

func _render_competition_panels(last_battle: Dictionary, matchmaking: Dictionary, ranking: Dictionary) -> void:
	if _competition_state_container == null:
		return
	if not last_battle.is_empty():
		_competition_state_container.add_child(_competition_last_battle_panel(last_battle))
	_competition_state_container.add_child(_competition_matchmaking_panel(matchmaking))
	_competition_state_container.add_child(_competition_ranking_panel(ranking))

func _competition_last_battle_panel(last_battle: Dictionary) -> Control:
	var panel := _base_panel()
	panel.tooltip_text = "Resumo competitivo retornado pela ultima battle/request. O cliente apenas apresenta estes dados; a pontuacao vem do servidor."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Ultima Batalha Competitiva", "text_primary", 17))
	if not bool(last_battle.get("ranked", false)):
		box.add_child(_base_label("Sem pontuacao: %s" % str(last_battle.get("excluded_reason", "fora do ranking")), "status_warning"))
		return panel
	var ranking := _as_dictionary(last_battle.get("ranking", {}))
	var raw_delta := int(last_battle.get("arena_delta_raw", last_battle.get("arena_delta", 0)))
	var applied_delta := int(last_battle.get("arena_delta", 0))
	var delta_color := "status_success" if raw_delta >= 0 else "status_warning"
	box.add_child(_base_label("%s | Delta %s%d | Total %s pontos" % [
		_competition_result_text(str(last_battle.get("result", "draw"))),
		"+" if applied_delta >= 0 else "",
		applied_delta,
		str(ranking.get("arena_points", 0)),
	], delta_color))
	if raw_delta != applied_delta:
		box.add_child(_base_label("Formula: %s%d | aplicado: %s%d por piso minimo em 0" % [
			"+" if raw_delta >= 0 else "",
			raw_delta,
			"+" if applied_delta >= 0 else "",
			applied_delta,
		], "text_secondary"))
	box.add_child(_base_label("Poder: voce %s vs oponente %s | Modelo %s" % [
		str(last_battle.get("player_power", 0)),
		str(last_battle.get("opponent_power", 0)),
		_competition_scoring_model_text(str(last_battle.get("scoring_model", ""))),
	], "text_secondary"))
	return panel

func _competition_matchmaking_panel(matchmaking: Dictionary) -> Control:
	var panel := _base_panel()
	panel.tooltip_text = "Preview de matchmaking: mostra quem o servidor escolheria para uma batalha pelo poder atual."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Matchmaking", "text_primary", 17))
	if matchmaking.is_empty():
		box.add_child(_base_label("Ainda nao carregado. Use Preview matchmaking.", "text_secondary"))
		return panel
	var opponent := _as_dictionary(matchmaking.get("selected_opponent", {}))
	box.add_child(_base_label("Seu poder: %s | candidatos: %s" % [
		str(matchmaking.get("player_power", 0)),
		str(matchmaking.get("candidate_count", "?")),
	], "text_secondary"))
	if opponent.is_empty():
		box.add_child(_base_label("Nenhum oponente disponivel agora.", "status_warning"))
		return panel
	box.add_child(_base_label("Oponente: %s | Poder %s | Faixa %s" % [
		str(opponent.get("id", "desconhecido")),
		str(opponent.get("power", "?")),
		str(opponent.get("power_band", "?")),
	], "text_secondary"))
	box.add_child(_base_label("Bot de treino: %s | Entra no ranking: %s" % [
		"sim" if bool(opponent.get("is_bot", false)) else "nao",
		"sim" if bool(opponent.get("is_ranked", false)) else "nao",
	], "status_warning" if bool(opponent.get("is_bot", false)) else "text_secondary"))
	return panel

func _competition_ranking_panel(ranking: Dictionary) -> Control:
	var panel := _base_panel()
	panel.tooltip_text = "Leaderboard da season alpha. Mostra top 10 e sua posicao mesmo quando voce estiver fora do top."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Leaderboard", "text_primary", 17))
	if ranking.is_empty():
		box.add_child(_base_label("Ainda nao carregado. Use Ver ranking.", "text_secondary"))
		return panel
	if str(ranking.get("excluded_reason", "")) == "PROGRESSION_LAB_DOES_NOT_RANK":
		box.add_child(_base_label("Progression Lab nao pontua competicao e fica fora do leaderboard.", "status_error"))
		return panel
	var season := _as_dictionary(ranking.get("season", {}))
	box.add_child(_base_label("%s | Modelo %s" % [
		str(season.get("display_name", "Season alpha")),
		_competition_scoring_model_text(str(ranking.get("scoring_model", ""))),
	], "text_secondary"))
	var self_ranking := _as_dictionary(ranking.get("self", {}))
	if not self_ranking.is_empty():
		box.add_child(_base_label("Sua posicao: #%s | %s pontos | %sV/%sD" % [
			str(self_ranking.get("rank", "?")),
			str(self_ranking.get("arena_points", 0)),
			str(self_ranking.get("wins", 0)),
			str(self_ranking.get("losses", 0)),
		], "status_success" if bool(ranking.get("self_in_top", false)) else "status_warning"))
	var entries := _as_array(ranking.get("entries", []))
	if entries.is_empty():
		box.add_child(_base_label("Nenhum jogador pontuou ainda nesta season.", "text_secondary"))
		return panel
	box.add_child(_base_label("Top %s" % str(ranking.get("top_limit", 10)), "text_primary"))
	for item: Variant in entries:
		var entry := _as_dictionary(item)
		if entry.is_empty():
			continue
		box.add_child(_base_label("#%s  %s  |  %s pts  |  %sV/%sD" % [
			str(entry.get("rank", "?")),
			_competition_entry_name(entry),
			str(entry.get("arena_points", 0)),
			str(entry.get("wins", 0)),
			str(entry.get("losses", 0)),
		], "status_success" if str(entry.get("player_id", "")) == str(self_ranking.get("player_id", "")) else "text_secondary"))
	return panel

func _competition_entry_name(entry: Dictionary) -> String:
	var player := _as_dictionary(entry.get("player", {}))
	var username := str(entry.get("username", player.get("username", ""))).strip_edges()
	if username == "":
		username = "jogador"
	var badge := str(player.get("save_badge", "normal"))
	if badge == "lab":
		return "%s [lab]" % username
	return username

func _competition_result_text(result: String) -> String:
	match result:
		"win":
			return "Vitoria"
		"loss":
			return "Derrota"
	return "Empate"

func _competition_scoring_model_text(model: String) -> String:
	if model == "alpha_v0_power_adjusted":
		return "alpha v0: +20/-10 ajustado por poder"
	if model.strip_edges() == "":
		return "nao informado"
	return model

func _render_monetization_state() -> void:
	ShopSurfacePresenterScript.render_state(self)

func _render_shop_panels(monetization: Dictionary) -> void:
	var summary := _as_dictionary(monetization.get("shop_summary", {}))
	if not summary.is_empty():
		_shop_state_container.add_child(_shop_summary_panel(summary))

	var redeem_products: Array = []
	var purchase_products: Array = []
	for item: Variant in _as_array(monetization.get("alpha_products", [])):
		var product := _as_dictionary(item)
		if product.is_empty():
			continue
		if bool(product.get("daily_redeem", false)):
			redeem_products.append(product)
		else:
			purchase_products.append(product)
	_shop_state_container.add_child(_shop_product_group_panel("Redeems diarios de Diamante", redeem_products))
	_shop_state_container.add_child(_shop_product_group_panel("Compras e conveniencias", purchase_products))
	_shop_state_container.add_child(_shop_reward_group_panel("Recompensas diarias", _as_array(monetization.get("daily_rewards", []))))

	var battle_pass := _as_dictionary(monetization.get("battle_pass", {}))
	_shop_state_container.add_child(_shop_reward_group_panel("Battle Pass", _as_array(battle_pass.get("rewards", []))))

func _shop_summary_panel(summary: Dictionary) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Resumo da Loja", "text_primary", 17))
	box.add_child(_base_label("Diamante: %s | Moeda principal do alpha: %s" % [
		str(summary.get("diamond_balance", 0)),
		str(summary.get("currency", "diamante")).capitalize(),
	], "text_secondary"))
	box.add_child(_base_label("Premium: %s | Redeems hoje: %s/%s | Reset: meia-noite America/Sao_Paulo" % [
		"ativo" if bool(summary.get("premium_unlocked", false)) else "inativo",
		str(summary.get("daily_redeems_claimed", 0)),
		str(summary.get("daily_redeems_total", 0)),
	], "text_secondary"))
	var owned := _as_array(summary.get("convenience_owned", []))
	if owned.is_empty():
		box.add_child(_base_label("Conveniencias ativas: nenhuma.", "text_secondary"))
	else:
		var owned_ids := PackedStringArray()
		for item: Variant in owned:
			owned_ids.append(str(item))
		box.add_child(_base_label("Conveniencias ativas: %s" % ", ".join(owned_ids), "status_success"))
	return panel

func _shop_product_group_panel(title_text: String, products: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label(title_text, "text_primary", 17))
	if products.is_empty():
		box.add_child(_base_label("Nenhum produto retornado pelo servidor.", "text_secondary"))
		return panel
	for item: Variant in products:
		var product := _as_dictionary(item)
		if product.is_empty():
			continue
		box.add_child(_base_label("%s | %s" % [
			str(product.get("label", product.get("id", ""))),
			_shop_product_status_text(product),
		], _shop_product_status_color(product)))
		box.add_child(_base_label("Custo: %s | Recebe: %s | Efeito: %s" % [
			_format_shop_delta(_as_dictionary(product.get("cost", {})), "gratis"),
			_format_shop_delta(_as_dictionary(product.get("resources", {})), "nenhum recurso direto"),
			_shop_effect_text(_as_dictionary(product.get("effect", {}))),
		], "text_secondary"))
		var description := str(product.get("description", ""))
		if description != "":
			box.add_child(_base_label(description, "text_secondary"))
	return panel

func _shop_reward_group_panel(title_text: String, rewards: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label(title_text, "text_primary", 17))
	if rewards.is_empty():
		box.add_child(_base_label("Nenhuma recompensa retornada pelo servidor.", "text_secondary"))
		return panel
	for item: Variant in rewards:
		var reward := _as_dictionary(item)
		if reward.is_empty():
			continue
		var status_text := "resgatada" if bool(reward.get("claimed", false)) else "disponivel"
		var color_token := "status_success" if not bool(reward.get("claimed", false)) else "text_secondary"
		if bool(reward.get("premium_required", false)):
			status_text += " | premium"
		box.add_child(_base_label("%s | XP %s | %s" % [
			str(reward.get("label", reward.get("id", ""))),
			str(reward.get("xp", 0)),
			status_text,
		], color_token))
		box.add_child(_base_label("Recursos: %s | Periodo: %s" % [
			_format_shop_delta(_as_dictionary(reward.get("resources", {})), "nenhum recurso"),
			str(reward.get("period_key", "")),
		], "text_secondary"))
	return panel

func _shop_product_status_text(product: Dictionary) -> String:
	if bool(product.get("already_redeemed", false)):
		return "resgatado hoje"
	if bool(product.get("already_owned", false)):
		return "ja ativo"
	if bool(product.get("can_purchase", true)):
		return "disponivel"
	return _shop_locked_reason_text(str(product.get("locked_reason", "")))

func _shop_product_status_color(product: Dictionary) -> String:
	if bool(product.get("can_purchase", true)):
		return "status_success"
	if bool(product.get("already_redeemed", false)) or bool(product.get("already_owned", false)):
		return "text_secondary"
	return "status_warning"

func _shop_locked_reason_text(reason: String) -> String:
	match reason:
		"DAILY_REDEEM_ALREADY_CLAIMED":
			return "resgatado hoje"
		"ALREADY_OWNED":
			return "ja ativo"
		"INSUFFICIENT_RESOURCES":
			return "Diamante insuficiente"
		"":
			return "indisponivel"
	return reason

func _shop_effect_text(effect: Dictionary) -> String:
	if effect.is_empty():
		return "nenhum efeito persistente"
	match str(effect.get("type", "")):
		"construction_slots":
			return "fila do Refugio: %s slots" % str(effect.get("value", 0))
	return str(effect)

func _format_shop_delta(delta: Dictionary, empty_text: String) -> String:
	if delta.is_empty():
		return empty_text
	return _format_cost(delta)

func _shop_product_by_id(product_id: String) -> Dictionary:
	return ShopSurfacePresenterScript.product_by_id(product_id)

func _shop_reward_by_id(reward_id: String) -> Dictionary:
	return ShopSurfacePresenterScript.reward_by_id(reward_id)

func _shop_purchase_message(product_id: String, body: Dictionary) -> String:
	return ShopSurfacePresenterScript.purchase_message(product_id, body)

func _play_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	var schema_version := str(battle_log.get("schema_version", ""))
	if schema_version != "battle_log_v1":
		_error_label.text = "UNSUPPORTED_BATTLE_LOG: %s" % schema_version
		_sync_status_from_session()
		return

	_error_label.text = ""
	_show_screen(ROUTE_BATTLE_RUNNING, false)
	_replay_running = true
	_skip_replay = false
	_set_busy(false, "Reproduzindo replay do primeiro slice...")
	_sync_buttons()
	_emit_client_event("replay_start", {
		"battle_id": str(battle_log.get("battle_id", "")),
		"mode": str(battle_log.get("mode", "")),
	})

	_battle_replay_presenter.begin_replay(battle_log, rewards)
	_timeline_label = _battle_replay_presenter.get_timeline_label()
	_battle_visual = _battle_replay_presenter.get_visual()

	var events := _battle_replay_presenter.sorted_events(battle_log)
	var warning_text := _battle_replay_presenter.build_warning_text(battle_log, ProjectInfoScript.DEFAULT_BATTLE_MODE)
	if not warning_text.is_empty():
		_error_label.text = warning_text

	var replay_time := 0.0
	for event: Dictionary in events:
		if _skip_replay:
			break
		var event_time := maxf(replay_time, float(event.get("t", replay_time)))
		while replay_time + 0.001 < event_time:
			if _skip_replay:
				break
			var tick := minf(BATTLE_REPLAY_TICK_SECONDS, event_time - replay_time)
			replay_time += tick
			_battle_replay_presenter.set_replay_time(replay_time)
			await get_tree().create_timer(tick).timeout
		if _skip_replay:
			break
		_battle_replay_presenter.set_replay_time(event_time)
		_battle_replay_presenter.append_event(event)
		replay_time = event_time
		await get_tree().process_frame

	if _skip_replay:
		_emit_client_event("replay_skip", {
			"battle_id": str(battle_log.get("battle_id", "")),
			"events": events.size(),
		})
		_battle_replay_presenter.reveal_all_events(events)

	_battle_replay_presenter.reveal_all()

	var skipped := _skip_replay
	_replay_running = false
	_skip_replay = false
	_battle_summary_skipped = skipped
	_emit_client_event("replay_end", {
		"battle_id": str(battle_log.get("battle_id", "")),
		"events": events.size(),
		"skipped": skipped,
	})
	_show_screen(AppShellRouteContractScript.summary_route_for(ROUTE_BATTLE_RUNNING), false)
	_set_busy(false, "Replay concluido.")
	_sync_buttons()

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
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		if key == "diamante" and not include_diamond:
			continue
		parts.append("%s %s" % [key.capitalize(), str(resources.get(key, 0))])
	return " | ".join(parts)

func _resource_total(resources: Dictionary) -> float:
	var total := 0.0
	for key: String in RESOURCE_KEYS:
		total += float(resources.get(key, 0.0))
	return total

func _structure_label(structure_id: String, fallback: String = "") -> String:
	if fallback != "":
		return fallback
	match structure_id:
		"altar_das_almas":
			return "Altar das Almas"
		"nucleo_energia":
			return "Nucleo de Energia"
		"pocos_sangue":
			return "Pocos de Sangue"
		"minas_cristal":
			return "Minas de Cristal"
		"estrutura_stats":
			return "Estrutura de Stats"
		"ossario":
			return "Ossario"
	return structure_id

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
	if _battle_history_save_type != SessionStore.active_save_type:
		_clear_battle_history()
	return _battle_history_entries

func _clear_battle_history() -> void:
	_battle_history_entries = []
	_battle_history_save_type = SessionStore.active_save_type

func _action_payload(action_id: String) -> Dictionary:
	return {
		"action_id": action_id,
		"screen": _current_screen,
		"save_type": SessionStore.active_save_type,
		"has_account": SessionStore.has_account_state(),
		"offline": SessionStore.offline,
	}

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
