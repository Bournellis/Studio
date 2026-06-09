extends Control
const ProjectInfoScript := preload("res://core/project_info.gd")
const SessionStoreScript := preload("res://online/session_store.gd")
const ShellSurfacePresenterScript := preload("res://modes/boot/surfaces/shell_surface_presenter.gd")
const HubSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_surface_presenter.gd")
const HubAccountSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_account_surface_presenter.gd")
const BattleReplayPresenterScript := preload("res://modes/boot/surfaces/battle_replay_presenter.gd")
const ArenaSurfacePresenterScript := preload("res://modes/boot/surfaces/arena_surface_presenter.gd")
const BaseSurfacePresenterScript := preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const SocialSurfacePresenterScript := preload("res://modes/boot/surfaces/social_surface_presenter.gd")
const CompetitionSurfacePresenterScript := preload("res://modes/boot/surfaces/competition_surface_presenter.gd")
const ShopSurfacePresenterScript := preload("res://modes/boot/surfaces/shop_surface_presenter.gd")
const SurfaceUiHelpersScript := preload("res://modes/boot/surfaces/surface_ui_helpers.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellActionRouterScript := preload("res://modes/boot/ui/app_shell_action_router.gd")
const ModeShellRegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const ModeShellLauncherScript := preload("res://modes/boot/ui/mode_shell_launcher.gd")
const AppShellErrorContractScript := preload("res://modes/boot/ui/app_shell_error_contract.gd")
const OperationStateScript := preload("res://modes/boot/ui/operation_state.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")
const AccountSessionFlowScript := preload("res://modes/boot/flows/account_session_flow.gd")
const SurfaceActionFlowScript := preload("res://modes/boot/flows/surface_action_flow.gd")
const BattleLifecycleFlowScript := preload("res://modes/boot/flows/battle_lifecycle_flow.gd")
const ArenaLifecycleFlowScript := preload("res://modes/boot/flows/arena_lifecycle_flow.gd")
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
const ROUTE_ARENA_SELECTION := AppShellRouteContractScript.ROUTE_ARENA_SELECTION
const ROUTE_ARENA_LOADOUT := AppShellRouteContractScript.ROUTE_ARENA_LOADOUT
const ROUTE_ARENA_ACTIVE := AppShellRouteContractScript.ROUTE_ARENA_ACTIVE
const ROUTE_ARENA_REPLAY := AppShellRouteContractScript.ROUTE_ARENA_REPLAY
const ROUTE_ARENA_BUFF_CHOICE := AppShellRouteContractScript.ROUTE_ARENA_BUFF_CHOICE
const ROUTE_ARENA_SUMMARY := AppShellRouteContractScript.ROUTE_ARENA_SUMMARY
const ROUTE_MODE_SHELL := AppShellRouteContractScript.ROUTE_MODE_SHELL
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
const SOCIAL_AUTO_SYNC_SECONDS := 8.0
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
var _mode_fullscreen_overlay: Control
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
var _active_action_scope := OperationStateScript.DEFAULT_SCOPE
var _is_busy := false
var _replay_running := false
var _skip_replay := false
@warning_ignore("unused_private_class_variable")
var _battle_summary_skipped := false
var _battle_request_splash_active := false
var _compact_layout := false
var _social_auto_sync_timer: Timer
var _social_auto_sync_in_flight := false
var _social_auto_sync_last_text := ""
var _social_auto_sync_last_error := ""
var _battle_lab_overlay: Control
var _progression_lab_overlay: Control
var _active_mode_id := ""
var _mode_shell_navigation_cache: Dictionary = {}
var _mode_shell_active_screen: Control = null
@warning_ignore("unused_private_class_variable")
var _selected_base_structure_id := "nucleo_energia"
@warning_ignore("unused_private_class_variable")
var _last_social_friend_username := ""
@warning_ignore("unused_private_class_variable")
var _last_social_guild_name := ""
@warning_ignore("unused_private_class_variable")
var _last_social_chat_message := "Primeiro pulso do Conclave."
var _update_gate := ProjectInfoScript.unchecked_update_status()
var _account_session_flow = AccountSessionFlowScript.new()
var _surface_action_flow = SurfaceActionFlowScript.new()
var _battle_lifecycle_flow = BattleLifecycleFlowScript.new()
var _arena_lifecycle_flow = ArenaLifecycleFlowScript.new()
var _operation_state = OperationStateScript.new()
var _battle_replay_presenter = BattleReplayPresenterScript.new()
var _arena_surface_presenter = ArenaSurfacePresenterScript.new()
var _mode_shell_launcher = ModeShellLauncherScript.new()
@warning_ignore("unused_private_class_variable")
var _battle_history_entries: Array[Dictionary] = []
@warning_ignore("unused_private_class_variable")
var _battle_history_save_type := SessionStoreScript.SAVE_TYPE_NORMAL

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
	return UiTokens.panel_style_from_tokens(
		bg_token,
		border_token,
		_compact_layout,
		UiTokens.surface_accent_token(_current_screen, border_token),
		1,
		6
	)

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

func _action_context() -> Dictionary:
	return {
		"screen": _current_screen,
		"save_type": SessionStore.active_save_type,
		"has_account": SessionStore.has_account_state(),
		"offline": SessionStore.offline,
		"update_gate": _update_gate,
		"replay_running": _replay_running,
	}

func _emit_client_event(event_type: String, payload: Dictionary) -> void:
	if bool(ProjectSettings.get_setting("draxos_mobile/testing/disable_telemetry", false)):
		return
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
