extends "res://modes/boot/boot_runtime_flow_facade.gd"

# Screen lifecycle, route normalization, history, and chrome visibility.
func _show_screen(screen_id: String, push_history: bool = true) -> void:
	screen_id = _normalize_route(screen_id)
	if _shell_overlay_should_capture_screen(screen_id):
		_show_overlay_screen(screen_id, push_history)
		return
	if _shell_overlay_is_open():
		_mode_shell_overlay_controller.force_close(self)
	screen_id = AppShellRouteContractScript.push_route(_screen_history, _current_screen, screen_id, push_history)
	_current_screen = screen_id
	if screen_id != ROUTE_ARENA_ACTIVE:
		set_meta("arena_active_preparation_open", false)
	if screen_id != ROUTE_BATTLE_ENTRY:
		_battle_request_splash_active = false
	_apply_orientation_for_route(screen_id)
	_action_buttons.clear()
	_current_action_grid = null
	_timeline_label = null
	_update_output_label = null
	_base_state_container = null
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
	_render_route_contents(screen_id)
	_sync_status_from_session()
	_publish_web_diagnostics_state()
	_emit_client_event("screen_opened", {
		"screen": screen_id,
		"has_account": SessionStore.has_account_state(),
		"offline": SessionStore.offline,
	})
	_sync_social_auto_sync_for_route()

func _render_route_contents(screen_id: String) -> void:
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

func _show_refuge_root(message: String = "") -> void:
	_show_screen(AppShellRouteContractScript.clear_for_refuge_return(_screen_history), false)
	if message != "":
		_show_notice(message)
func _show_surface_screen(screen_id: String) -> void:
	var target_screen := _normalize_route(screen_id)
	var current_screen := _active_route_for_context()
	_show_screen(target_screen, target_screen != current_screen)
func _go_back() -> void:
	if _shell_overlay_is_open():
		if _mode_shell_overlay_controller.go_back(self):
			return
	if _replay_running:
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

func _show_overlay_screen(route_id: String, push_history: bool = true) -> void:
	_mode_shell_overlay_controller.show_screen(self, route_id, push_history)
	_publish_web_diagnostics_state()
	call_deferred("_publish_web_diagnostics_state")

func _open_shell_overlay_action(action_id: String) -> bool:
	if _current_screen != ROUTE_MODE_SHELL:
		return false
	if not _mode_shell_overlay_controller.open_for_action(self, action_id):
		return false
	return true

func _close_shell_overlay() -> bool:
	var closed := _mode_shell_overlay_controller.close(self)
	_publish_web_diagnostics_state()
	return closed

func _shell_overlay_is_open() -> bool:
	return _mode_shell_overlay_controller.is_open()

func _shell_overlay_current_route() -> String:
	return _mode_shell_overlay_controller.current_route()

func _shell_overlay_epoch() -> int:
	return _mode_shell_overlay_controller.epoch()

func _active_route_for_context() -> String:
	if _shell_overlay_is_open() and _mode_shell_overlay_controller.current_route() != "":
		return _mode_shell_overlay_controller.current_route()
	return _current_screen

func _shell_overlay_should_capture_screen(screen_id: String) -> bool:
	if not _shell_overlay_is_open():
		return false
	if screen_id == ROUTE_MODE_SHELL or screen_id == SCREEN_HUB or screen_id == SCREEN_REFUGE:
		return false
	return true

func _shell_overlay_fullscreen_parent() -> Control:
	return _mode_shell_overlay_controller.fullscreen_parent()

func _publish_web_diagnostics_state() -> void:
	if not OS.has_feature("web"):
		return
	var overlay_panel := {}
	var overlay_buttons: Array[Dictionary] = []
	var overlay_controls: Array[Dictionary] = []
	var overlay_input := {}
	var pending_confirmation := {}
	if _shell_overlay_is_open():
		overlay_panel = _mode_shell_overlay_controller.panel_diagnostics()
		overlay_buttons = _mode_shell_overlay_controller.button_diagnostics()
		overlay_controls = _mode_shell_overlay_controller.control_diagnostics()
		overlay_input = _mode_shell_overlay_controller.input_diagnostics()
		pending_confirmation = _mode_shell_overlay_controller.confirmation_diagnostics()
	var payload := {
		"project": ProjectInfoScript.PROJECT_NAME,
		"releaseChannel": ProjectInfoScript.RELEASE_CHANNEL,
		"appVersion": ProjectInfoScript.APP_VERSION,
		"appVersionCode": ProjectInfoScript.APP_VERSION_CODE,
		"viewportSize": {
			"width": get_viewport_rect().size.x,
			"height": get_viewport_rect().size.y,
		},
		"currentScreen": _current_screen,
		"activeRoute": _active_route_for_context(),
		"overlayOpen": _shell_overlay_is_open(),
		"overlayRoute": _shell_overlay_current_route(),
		"overlayEpoch": _shell_overlay_epoch(),
		"overlayPanel": overlay_panel,
		"overlayButtons": overlay_buttons,
		"overlayControls": overlay_controls,
		"overlayInput": overlay_input,
		"focusedControl": str(overlay_input.get("focused_control", "")),
		"pendingConfirmation": pending_confirmation,
		"actionInput": {
			"sequence": _web_action_sequence,
			"last": _web_last_action.duplicate(true),
		},
		"arena": _web_arena_diagnostics(),
		"lastArenaOperation": _arena_last_operation.duplicate(true),
		"busy": _is_busy,
		"criticalCloseLock": _shell_overlay_close_lock_action_id,
		"replayRunning": _replay_running,
	}
	JavaScriptBridge.eval("window.DRAXOS_GODOT_STATE = %s;" % JSON.stringify(payload), true)
	_ensure_web_overlay_input_bridge()
	_focus_web_canvas_for_shell_input()
	_apply_web_smoke_overlay_request()

func _web_arena_diagnostics() -> Dictionary:
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := str(attempt.get("attempt_id", attempt.get("id", ""))).strip_edges()
	var attempt_state := str(attempt.get("state", attempt.get("status", ""))).strip_edges()
	var terminal := attempt_state in ["completed", "failed", "claimed", "abandoned", "local_cleared"]
	var blocks := not attempt.is_empty() and not terminal and attempt_state in ["active", "awaiting_buff", "active_incompatible"]
	var requires_local_clear := false
	if _arena_lifecycle_flow != null and _arena_lifecycle_flow.has_method("attempt_requires_local_clear"):
		requires_local_clear = bool(_arena_lifecycle_flow.call("attempt_requires_local_clear", attempt))
	return {
		"activeAttemptPresent": not attempt.is_empty(),
		"activeAttemptId": attempt_id,
		"activeAttemptState": attempt_state,
		"activeAttemptBlocksSelection": blocks,
		"activeAttemptRequiresLocalClear": requires_local_clear,
		"devFixture": bool(SessionStore.arena_snapshot().get("dev_fixture", false)),
		"summary": _as_dictionary(SessionStore.arena_snapshot().get("summary", {})),
	}

func _ensure_web_overlay_input_bridge() -> void:
	if _web_overlay_input_bridge_bound:
		return
	_web_overlay_input_bridge_callback = JavaScriptBridge.create_callback(_handle_web_overlay_input_command)
	JavaScriptBridge.get_interface("window").__draxosGodotOverlayCommand = _web_overlay_input_bridge_callback
	JavaScriptBridge.eval("""(function(){
		if (window.__DRAXOS_OVERLAY_INPUT_BRIDGE_BOUND) return;
		window.__DRAXOS_OVERLAY_INPUT_BRIDGE_BOUND = true;
		function overlayState() {
			return window.DRAXOS_GODOT_STATE || {};
		}
		function callGodot(command) {
			if (typeof window.__draxosGodotOverlayCommand === 'function') {
				window.__draxosGodotOverlayCommand(command);
			}
		}
		function callGodotPayload(payload) {
			callGodot(JSON.stringify(payload));
		}
		function canvasPoint(event, state) {
			const canvas = document.querySelector('canvas');
			if (!canvas) return null;
			const rect = canvas.getBoundingClientRect();
			if (rect.width <= 0 || rect.height <= 0) return null;
			const viewport = state && state.viewportSize ? state.viewportSize : null;
			const scaleX = viewport && viewport.width ? viewport.width / rect.width : 1;
			const scaleY = viewport && viewport.height ? viewport.height / rect.height : 1;
			return {
				x: (event.clientX - rect.left) * scaleX,
				y: (event.clientY - rect.top) * scaleY,
			};
		}
		function rectContains(rect, point) {
			if (!rect || !point) return false;
			return point.x >= rect.x &&
				point.x <= rect.x + rect.width &&
				point.y >= rect.y &&
				point.y <= rect.y + rect.height;
		}
		function overlayButtonAt(state, point) {
			const buttons = Array.isArray(state.overlayButtons) ? state.overlayButtons : [];
			for (let index = buttons.length - 1; index >= 0; index -= 1) {
				const button = buttons[index];
				if (rectContains(button, point)) return button;
			}
			return null;
		}
		function overlayControlAt(state, point) {
			const controls = Array.isArray(state.overlayControls) ? state.overlayControls : [];
			for (let index = controls.length - 1; index >= 0; index -= 1) {
				const control = controls[index];
				if (rectContains(control, point)) return control;
			}
			const button = overlayButtonAt(state, point);
			if (button) {
				return {
					type: 'button',
					path: button.path,
					text: button.text || '',
					action_id: button.action_id || '',
					x: button.x,
					y: button.y,
					width: button.width,
					height: button.height
				};
			}
			return null;
		}
		function overlayChromeMetrics() {
			const canvas = document.querySelector('canvas');
			if (!canvas) return null;
			const rect = canvas.getBoundingClientRect();
			const compact = rect.width <= 820;
			if (compact) {
				const margin = 12;
				const top = rect.top + Math.max(28, rect.height * 0.08);
				return {
					left: rect.left + margin,
					right: rect.right - margin,
					top,
					bottom: top + 80
				};
			}
			const panelWidth = Math.min(640, Math.max(440, rect.width * 0.42));
			const top = rect.top + 24;
			return {
				left: rect.right - panelWidth - 24,
				right: rect.right - 24,
				top,
				bottom: top + 80
			};
		}
		let lastPointerDownAt = 0;
		function handleOverlayPress(event) {
			const now = Date.now();
			if (event.type === 'mousedown' && now - lastPointerDownAt < 250) return;
			if (event.type === 'pointerdown') lastPointerDownAt = now;
			const state = overlayState();
			if (!state.overlayOpen) return;
			const point = canvasPoint(event, state);
			if (!point) return;
			const control = overlayControlAt(state, point);
			if (control && control.path && control.type === 'button') {
				event.preventDefault();
				event.stopPropagation();
				callGodotPayload({
					type: 'button',
					path: control.path,
					x: point.x,
					y: point.y,
					text: control.text || ''
				});
				return;
			}
			if (control && control.path && control.type === 'line_edit') {
				event.preventDefault();
				event.stopPropagation();
				callGodotPayload({
					type: 'focus',
					path: control.path,
					x: point.x,
					y: point.y,
					text: control.text || ''
				});
				return;
			}
			const metrics = overlayChromeMetrics();
			if (!metrics) return;
			if (event.clientY < metrics.top || event.clientY > metrics.bottom) return;
			if (event.clientX >= metrics.right - 112 && event.clientX <= metrics.right) {
				event.preventDefault();
				event.stopPropagation();
				callGodot('close');
				return;
			}
			if (event.clientX >= metrics.left && event.clientX <= metrics.left + 112) {
				event.preventDefault();
				event.stopPropagation();
				callGodot('back');
			}
		}
		window.addEventListener('pointerdown', handleOverlayPress, true);
		window.addEventListener('mousedown', handleOverlayPress, true);
		window.addEventListener('wheel', function(event) {
			const state = overlayState();
			if (!state.overlayOpen) return;
			const point = canvasPoint(event, state);
			const panel = state.overlayPanel || null;
			if (!rectContains(panel, point)) return;
			event.preventDefault();
			event.stopPropagation();
			callGodotPayload({
				type: 'wheel',
				deltaY: event.deltaY || 0
			});
		}, { capture: true, passive: false });
		window.addEventListener('keydown', function(event) {
			const state = overlayState();
			if (!state.overlayOpen) return;
			const focusedPath = String(state.focusedControl || state.overlayInput?.focused_control || '');
			if (event.key === 'Escape' || event.code === 'Escape') {
				event.preventDefault();
				event.stopPropagation();
				callGodot('escape');
				return;
			}
			if (!focusedPath) return;
			if (event.ctrlKey || event.metaKey || event.altKey) return;
			if (event.key === 'Backspace') {
				event.preventDefault();
				event.stopPropagation();
				callGodotPayload({
					type: 'backspace',
					path: focusedPath
				});
				return;
			}
			if (event.key === 'Enter') {
				event.preventDefault();
				event.stopPropagation();
				return;
			}
			if (typeof event.key === 'string' && event.key.length === 1) {
				event.preventDefault();
				event.stopPropagation();
				callGodotPayload({
					type: 'text',
					path: focusedPath,
					text: event.key
				});
			}
		}, true);
	})();""", true)
	_web_overlay_input_bridge_bound = true

func _handle_web_overlay_input_command(args: Array) -> void:
	if not _shell_overlay_is_open():
		return
	var command := ""
	if not args.is_empty():
		command = str(args[0]).strip_edges()
	var parsed: Variant = null
	if command.begins_with("{"):
		parsed = JSON.parse_string(command)
	if parsed is Dictionary:
		var payload := parsed as Dictionary
		match str(payload.get("type", "")).strip_edges():
			"button":
				var point := Vector2(
					float(payload.get("x", -100000.0)),
					float(payload.get("y", -100000.0))
				)
				if _mode_shell_overlay_controller.request_button(self, str(payload.get("path", "")), point):
					call_deferred("_publish_web_diagnostics_state")
			"focus":
				var focus_point := Vector2(
					float(payload.get("x", -100000.0)),
					float(payload.get("y", -100000.0))
				)
				if _mode_shell_overlay_controller.request_focus(self, str(payload.get("path", "")), focus_point):
					call_deferred("_publish_web_diagnostics_state")
			"text":
				if _mode_shell_overlay_controller.request_text_input(
					self,
					str(payload.get("path", "")),
					str(payload.get("text", "")),
					bool(payload.get("replace", false))
				):
					call_deferred("_publish_web_diagnostics_state")
			"backspace":
				if _mode_shell_overlay_controller.request_text_backspace(self, str(payload.get("path", ""))):
					call_deferred("_publish_web_diagnostics_state")
			"wheel":
				if _mode_shell_overlay_controller.request_scroll(self, float(payload.get("deltaY", 0.0))):
					call_deferred("_publish_web_diagnostics_state")
			_:
				return
		return
	match command:
		"close":
			_mode_shell_overlay_controller.request_close(self)
		"back", "escape":
			_mode_shell_overlay_controller.request_back(self)
		_:
			return
	_publish_web_diagnostics_state()

func _focus_web_canvas_for_shell_input() -> void:
	if not (_shell_overlay_is_open() or _current_screen == ROUTE_MODE_SHELL):
		return
	if _shell_overlay_is_open() \
			and (
				_mode_shell_overlay_controller.focused_control_path() != "" \
				or _mode_shell_overlay_controller.confirmation_pending()
			):
		return
	JavaScriptBridge.eval("""(function(){
		const canvas = document.querySelector('canvas');
		if (!canvas) return;
		canvas.tabIndex = 0;
		if (!canvas.__draxosFocusBound) {
			canvas.__draxosFocusBound = true;
			canvas.addEventListener('pointerdown', function(){
				canvas.focus({ preventScroll: true });
			}, true);
		}
		if (document.activeElement !== canvas) {
			canvas.focus({ preventScroll: true });
		}
	})();""", true)

func _apply_web_smoke_overlay_request() -> void:
	if _web_smoke_overlay_request_applied:
		return
	if not OS.has_feature("web"):
		return
	if ProjectInfoScript.RELEASE_CHANNEL != "internal_alpha":
		return
	if not bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/dev_tools_enabled", false)):
		return
	var request := str(JavaScriptBridge.eval("(new URLSearchParams(window.location.search).get('draxos_smoke') || '')", true)).strip_edges()
	var route_id := ""
	var seed_arena_active := false
	var seed_required_update := false
	match request:
		"overlay-account":
			route_id = AppShellRouteContractScript.ROUTE_ACCOUNT
		"overlay-base":
			route_id = AppShellRouteContractScript.ROUTE_BASE
		"overlay-shop":
			route_id = AppShellRouteContractScript.ROUTE_SHOP
		"overlay-shop-confirm":
			route_id = AppShellRouteContractScript.ROUTE_SHOP
			seed_required_update = true
		"overlay-social":
			route_id = AppShellRouteContractScript.ROUTE_SOCIAL
		"overlay-social-form":
			route_id = AppShellRouteContractScript.ROUTE_SOCIAL
			seed_required_update = true
		"overlay-arena":
			route_id = AppShellRouteContractScript.ROUTE_ARENA_SELECTION
		"overlay-arena-active":
			route_id = AppShellRouteContractScript.ROUTE_ARENA_SELECTION
			seed_arena_active = true
		_:
			return
	if seed_arena_active:
		_seed_web_smoke_arena_active_attempt()
	if seed_required_update:
		_seed_web_smoke_required_update_gate()
	_web_smoke_overlay_request_applied = true
	call_deferred("_open_web_smoke_overlay_route", route_id)

func _open_web_smoke_overlay_route(route_id: String) -> void:
	if _shell_overlay_is_open():
		return
	_open_mode_shell(ModeShellRegistryScript.MODE_OPENWORLD)
	_show_overlay_screen(route_id, false)

func _seed_web_smoke_required_update_gate() -> void:
	_update_gate = {
		"block_online": true,
		"summary": "Update obrigatorio antes de usar recursos online.",
		"detail": "Smoke Web bloqueou mutacoes remotas para validar clique real sem alterar servidor.",
		"minimum_supported_version": "0.0.99-alpha.0",
		"minimum_supported_version_code": 99,
	}

func _seed_web_smoke_arena_active_attempt() -> void:
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/arena_dev_fixtures_enabled", true)
	SessionStore.access_token = "web-smoke-token"
	SessionStore.expires_at = int(Time.get_unix_time_from_system()) + 3600
	SessionStore.player = {"id": "web-smoke-player", "level": 8, "power": 120, "username": "web_smoke"}
	SessionStore.resources = {"almas": 100, "energia": 200, "sangue": 8, "cristais": 5, "ossos": 3, "diamante": 160}
	SessionStore.build = {"weapon_id": "varinha_cinzas"}
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
			"attempt_id": "22222222-2222-4222-8222-222222222222",
			"arena_id": "arena_cinzas_curta",
			"status": "active",
			"current_step_index": 1,
			"duel_count": 3,
			"duels_won": 1,
			"locked_loadout_hash": "sha256:web-smoke",
			"loadout_summary": {"label": "Varinha de Cinzas, smoke Web"},
			"next_enemy": {"display_name": "Aprendiz das Cinzas"},
			"temporary_buffs": [],
			"buff_offer": {},
		},
	}
