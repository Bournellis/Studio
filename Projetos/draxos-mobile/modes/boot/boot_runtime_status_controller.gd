extends "res://modes/boot/boot_runtime_surface_api.gd"

# Busy state, status feedback, social auto-sync, and precondition guards.
func _shell_overlay_set_route_phase(phase: String, route_id: String = "", reason: String = "") -> void:
	if _mode_shell_overlay_controller != null and _mode_shell_overlay_controller.is_open():
		_mode_shell_overlay_controller.set_route_phase(self, phase, route_id, reason)

func _clear_shell_overlay_busy_except_route(route_id: String) -> void:
	var keep_scope := _shell_overlay_scope_for_route(route_id)
	var cleared := false
	for scope: String in _operation_state.busy_scopes():
		if scope == OperationStateScript.DEFAULT_SCOPE or scope == keep_scope:
			continue
		_operation_state.invalidate_scope(scope)
		cleared = true
	if cleared:
		_is_busy = _operation_state.any_busy()

func _shell_overlay_scope_for_route(route_id: String) -> String:
	match AppShellRouteContractScript.normalize(route_id):
		ROUTE_ACCOUNT:
			return _surface_scope_id(SessionStore.SURFACE_ACCOUNT)
		SCREEN_BASE, ROUTE_ARENA_LOADOUT:
			return _surface_scope_id(SessionStore.SURFACE_BASE)
		SCREEN_SOCIAL:
			return _surface_scope_id(SessionStore.SURFACE_SOCIAL)
		SCREEN_COMPETITION:
			return _surface_scope_id(SessionStore.SURFACE_COMPETITION)
		SCREEN_SHOP:
			return _surface_scope_id(SessionStore.SURFACE_MONETIZATION)
		ROUTE_ARENA_SELECTION, ROUTE_ARENA_ACTIVE, ROUTE_ARENA_REPLAY, ROUTE_ARENA_BUFF_CHOICE, ROUTE_ARENA_SUMMARY:
			return _surface_scope_id(SessionStore.SURFACE_ARENA)
		_:
			return ""

func _set_busy(is_busy: bool, message: String) -> void:
	if is_busy:
		_operation_state.begin_busy(_active_action_scope, _active_action_id)
		_status_label.text = message
		_detail_label.text = "Aguardando resposta do servidor..."
		_error_label.text = ""
	else:
		if _active_action_scope == "":
			_operation_state.clear_all_busy()
		else:
			_operation_state.clear_busy(_active_action_scope)
		_status_label.text = _session_status_text()
		_detail_label.text = message
	_is_busy = _operation_state.any_busy()
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
	_operation_state.set_action_error(_active_action_id, error_payload)
	_set_busy(false, "Acao nao concluida.")
	_error_label.text = _friendly_error_message(code, str(error_payload.get("message", "Falha na requisicao.")))
	_sync_immersive_feedback()
	_emit_client_event("action_failure", {
		"action_id": _active_action_id,
		"screen": _active_route_for_context(),
		"code": code,
		"message": str(error_payload.get("message", "")),
		"network": _is_network_error(code),
	})
	if _is_network_error(code):
		_emit_client_event("network_failure", {
			"action_id": _active_action_id,
			"screen": _active_route_for_context(),
			"code": code,
		})
	_sync_social_auto_sync_for_route()

func _ensure_social_auto_sync_timer() -> void:
	if _social_auto_sync_timer != null and is_instance_valid(_social_auto_sync_timer): return
	_social_auto_sync_timer = Timer.new()
	_social_auto_sync_timer.name = "SocialAutoSyncTimer"
	_social_auto_sync_timer.one_shot = true
	_social_auto_sync_timer.wait_time = SOCIAL_AUTO_SYNC_SECONDS
	_social_auto_sync_timer.timeout.connect(Callable(self, "_on_social_auto_sync_timeout"))
	add_child(_social_auto_sync_timer)

func _sync_social_auto_sync_for_route() -> void:
	_ensure_social_auto_sync_timer()
	if not _can_start_social_auto_sync():
		_social_auto_sync_timer.stop()
	elif _social_auto_sync_timer.is_stopped():
		_social_auto_sync_timer.wait_time = SOCIAL_AUTO_SYNC_SECONDS
		_social_auto_sync_timer.start()

func _restart_social_auto_sync() -> void:
	_ensure_social_auto_sync_timer()
	_social_auto_sync_timer.stop()
	if _can_start_social_auto_sync():
		_social_auto_sync_timer.wait_time = SOCIAL_AUTO_SYNC_SECONDS
		_social_auto_sync_timer.start()

func _can_start_social_auto_sync() -> bool:
	return _active_route_for_context() == SCREEN_SOCIAL and not _surface_scope_busy(SessionStore.SURFACE_SOCIAL) and not _social_auto_sync_in_flight and _social_auto_sync_last_error == "" and not SessionStore.offline and not SessionStore.is_progression_lab_local_only() and SessionStore.has_valid_access_token() and SessionStore.has_account_state()

func _on_social_auto_sync_timeout() -> void:
	await _auto_sync_social_state()

func _auto_sync_social_state() -> void:
	if _active_route_for_context() != SCREEN_SOCIAL:
		_sync_social_auto_sync_for_route()
		return
	if _surface_scope_busy(SessionStore.SURFACE_SOCIAL):
		_restart_social_auto_sync()
		return
	if not _can_start_social_auto_sync():
		_sync_social_auto_sync_for_route()
		return
	_social_auto_sync_in_flight = true
	_social_auto_sync_last_error = ""
	await _surface_action_flow.auto_sync_social(self)

func _handle_social_auto_sync_error(result: Dictionary) -> void:
	var error_payload := _extract_error(result)
	var code := str(error_payload.get("code", "REQUEST_FAILED"))
	_social_auto_sync_last_error = _friendly_error_message(code, str(error_payload.get("message", "Falha na requisicao.")))
	if _is_network_error(code): SessionStore.mark_offline(error_payload)
	_show_notice("Social nao atualizou agora. Use Atualizar social para tentar novamente.")
	_render_social_state()
	_sync_social_auto_sync_for_route()

func _social_auto_sync_status_text() -> String:
	if _social_auto_sync_in_flight: return "Sincronizacao do Social em andamento."
	if SessionStore.offline: return "Sincronizacao pausada: sem conexao."
	if _social_auto_sync_last_error != "": return "Sincronizacao pausada. Use Atualizar social para tentar novamente."
	if SessionStore.is_progression_lab_local_only(): return "Sincronizacao pausada no Lab local."
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state(): return "Sincronizacao disponivel apos login."
	if _surface_scope_busy(SessionStore.SURFACE_SOCIAL): return "Sincronizacao pausada durante outra acao social."
	if _social_auto_sync_last_text != "":
		return "Sincronizacao ativa a cada 8s | ultima: %s" % _social_auto_sync_last_text
	return "Sincronizacao ativa a cada 8s nesta tela."

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
		var force_disabled := bool(button.get_meta("force_disabled", false))
		if not force_disabled:
			button.set_meta("disabled_reason", "")
		button.set_meta("soft_block_reason", "")
		button.disabled = force_disabled or _action_scope_busy(action_id) or (_replay_running and not _action_allowed_during_replay(action_id))
		var update_blocks := _update_gate_blocks_action(action_id) and not _arena_abandon_can_run_locally(action_id)
		if update_blocks:
			button.set_meta("disabled_reason", "required_update")
			if _shell_overlay_is_open():
				button.set_meta("soft_block_reason", "required_update")
			else:
				button.disabled = true
		if force_disabled and str(button.get_meta("disabled_reason", "")).strip_edges() != "":
			button.tooltip_text = str(button.get_meta("disabled_reason", ""))
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
				if not bool(product.get("can_purchase", true)):
					var product_reason := _shop_locked_reason_text(str(product.get("locked_reason", "")))
					button.tooltip_text = product_reason
					if _shell_overlay_is_open():
						button.set_meta("soft_block_reason", "shop_product_unavailable")
					else:
						button.set_meta("disabled_reason", "shop_product_unavailable")
						button.disabled = true
		elif AppShellActionContractScript.is_claim_reward(action_id):
			var reward := _shop_reward_by_id(AppShellActionContractScript.action_value(action_id))
			if not reward.is_empty():
				if bool(reward.get("claimed", false)):
					button.tooltip_text = "Recompensa ja resgatada."
					if _shell_overlay_is_open():
						button.set_meta("soft_block_reason", "shop_reward_already_claimed")
					else:
						button.set_meta("disabled_reason", "shop_reward_already_claimed")
						button.disabled = true
		if action_id == AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE:
			if button.name == "RefugeContextCta" and SessionStore.has_unseen_battle_result():
				button.text = "Ver recompensa"
			else:
				button.text = "Pular replay" if _replay_running else "Ver resultado"
	for screen_id: String in _nav_buttons.keys():
		var nav_button: Button = _nav_buttons[screen_id]
		nav_button.disabled = _replay_running
	if _back_button != null:
		_back_button.disabled = _replay_running
	if _shell_overlay_is_open():
		_mode_shell_overlay_controller.sync_controls(self)

func _action_allowed_during_replay(action_id: String) -> bool:
	return AppShellActionContractScript.is_allowed_during_replay(action_id)

func _action_scope_busy(action_id: String) -> bool:
	var route := AppShellActionRouterScript.route_action(action_id, _action_context())
	var scope := str(route.get("scope_id", OperationStateScript.DEFAULT_SCOPE))
	if OperationStateScript.normalize_scope(scope) == OperationStateScript.DEFAULT_SCOPE:
		return _operation_state.is_busy(OperationStateScript.DEFAULT_SCOPE)
	return _operation_state.is_busy(scope)

func _arena_abandon_can_run_locally(action_id: String) -> bool:
	if action_id != AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT:
		return false
	var fixture_enabled := OS.has_feature("editor") or bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/arena_dev_fixtures_enabled", false))
	var fixture_state := bool(SessionStore.arena_snapshot().get("dev_fixture", false))
	if fixture_state and fixture_enabled:
		return true
	if _arena_lifecycle_flow == null or not _arena_lifecycle_flow.has_method("attempt_requires_local_clear"):
		return false
	return bool(_arena_lifecycle_flow.call("attempt_requires_local_clear", SessionStore.active_arena_attempt()))

func _surface_scope_busy(surface: String) -> bool:
	return _operation_state.is_busy("%s:%s" % [surface.strip_edges(), SessionStore.active_save_type]) or _operation_state.is_busy(OperationStateScript.DEFAULT_SCOPE)

func _surface_scope_id(surface: String) -> String:
	return "%s:%s" % [surface.strip_edges(), SessionStore.active_save_type]

func _begin_surface_refresh(surface: String, endpoint: String, message: String, rendered_from_cache: bool = false) -> Dictionary:
	var previous_scope := _active_action_scope
	_active_action_scope = _surface_scope_id(surface)
	var token := _operation_state.begin_busy(_active_action_scope, _active_action_id)
	var session_token := SessionStore.begin_surface_refresh(surface, _active_action_id, endpoint, rendered_from_cache)
	token["session_version"] = int(session_token.get("version", 0))
	if _shell_overlay_is_open():
		token["shell_overlay_epoch"] = _shell_overlay_epoch()
		token["shell_overlay_route"] = _shell_overlay_current_route()
		_shell_overlay_set_route_phase("refreshing", _shell_overlay_current_route(), "Sincronizando com o servidor...")
	_status_label.text = message
	_detail_label.text = "Atualizando com o servidor..." if rendered_from_cache else "Aguardando resposta do servidor..."
	_error_label.text = ""
	_is_busy = _operation_state.any_busy()
	_sync_immersive_feedback()
	_sync_buttons()
	_active_action_scope = previous_scope
	if rendered_from_cache:
		_emit_client_event("surface_cache_rendered", {
			"surface": surface,
			"scope_id": str(token.get("scope_id", _surface_scope_id(surface))),
			"endpoint": endpoint,
			"method": "GET",
			"action_id": _active_action_id,
			"duration_ms": 0,
			"response_code": 0,
			"ok": true,
			"fail": false,
			"used_cache": true,
			"rendered_from_cache": true,
			"server_timing": {},
			"save_type": SessionStore.active_save_type,
		})
	return token

func _finish_surface_refresh(surface: String, token: Dictionary, result: Dictionary, message: String) -> bool:
	if not _surface_refresh_current(surface, token):
		_ignore_stale_surface_refresh(surface, token, "Resposta antiga ignorada; mantendo a superficie atual.")
		return false
	if not _operation_state.complete_busy(_surface_scope_id(surface), token):
		return false
	if not SessionStore.complete_surface_refresh(surface, result, _surface_token_for_session(token)):
		return false
	_emit_surface_latency_event("surface_refresh", surface, result, true)
	_emit_surface_latency_event("request_latency", surface, result, true)
	_is_busy = _operation_state.any_busy()
	_status_label.text = _session_status_text()
	_detail_label.text = message
	_sync_immersive_feedback()
	_sync_buttons()
	if _shell_overlay_is_open():
		_shell_overlay_set_route_phase("ready", _shell_overlay_current_route(), message)
	return true

func _fail_surface_refresh(surface: String, token: Dictionary, result: Dictionary) -> bool:
	if not _surface_refresh_current(surface, token):
		_ignore_stale_surface_refresh(surface, token, "Falha antiga ignorada; mantendo a superficie atual.")
		return false
	if not _operation_state.complete_busy(_surface_scope_id(surface), token):
		return false
	if not SessionStore.fail_surface_refresh(surface, result, _surface_token_for_session(token)):
		return false
	_emit_surface_latency_event("surface_refresh", surface, result, false)
	_emit_surface_latency_event("request_latency", surface, result, false)
	_is_busy = _operation_state.any_busy()
	_sync_immersive_feedback()
	_sync_buttons()
	if _shell_overlay_is_open():
		_shell_overlay_set_route_phase("ready", _shell_overlay_current_route(), "Servidor nao respondeu. Acoes disponiveis usam o estado local/cache.")
	return true

func _surface_token_for_session(token: Dictionary) -> Dictionary:
	return {
		"version": int(token.get("session_version", 0)),
	}

func _surface_refresh_current(surface: String, token: Dictionary) -> bool:
	if token.is_empty():
		return true
	if not _operation_state.is_current_lifecycle_token(token):
		return false
	if not _surface_refresh_overlay_context_current(token):
		return false
	var refresh := SessionStore.surface_refresh_snapshot(surface)
	return int(refresh.get("refresh_version", 0)) == int(token.get("session_version", 0))

func _ignore_stale_surface_refresh(surface: String, token: Dictionary, message: String = "") -> bool:
	if _surface_refresh_current(surface, token):
		return false
	var overlay_stale := _surface_refresh_overlay_context_stale(token)
	if overlay_stale and _operation_state.is_current_lifecycle_token(token):
		_operation_state.clear_busy(str(token.get("scope", _surface_scope_id(surface))))
		SessionStore.fail_surface_refresh(surface, {"error": "OVERLAY_CONTEXT_CLOSED"}, _surface_token_for_session(token))
	elif message.strip_edges() != "":
		_show_notice(message)
	_emit_client_event("surface_refresh_stale_ignored", {
		"surface": surface,
		"scope_id": _surface_scope_id(surface),
		"token_version": int(token.get("session_version", token.get("version", 0))),
		"current_version": int(SessionStore.surface_refresh_snapshot(surface).get("refresh_version", 0)),
		"save_type": SessionStore.active_save_type,
		"overlay_stale": overlay_stale,
		"token_overlay_epoch": int(token.get("shell_overlay_epoch", 0)),
		"current_overlay_epoch": _shell_overlay_epoch(),
		"token_overlay_route": str(token.get("shell_overlay_route", "")),
		"current_overlay_route": _shell_overlay_current_route(),
	})
	_is_busy = _operation_state.any_busy()
	_sync_immersive_feedback()
	_sync_buttons()
	if _shell_overlay_is_open():
		_shell_overlay_set_route_phase("ready", _shell_overlay_current_route(), message)
	return true

func _clear_shell_overlay_transient_busy() -> void:
	var cleared := false
	for scope: String in _operation_state.busy_scopes():
		if scope == OperationStateScript.DEFAULT_SCOPE:
			continue
		_operation_state.invalidate_scope(scope)
		cleared = true
	if not cleared:
		return
	_is_busy = _operation_state.any_busy()
	_sync_immersive_feedback()
	_sync_buttons()

func _surface_refresh_overlay_context_current(token: Dictionary) -> bool:
	if not token.has("shell_overlay_epoch"):
		return true
	var token_epoch := int(token.get("shell_overlay_epoch", 0))
	if token_epoch <= 0:
		return true
	if not _shell_overlay_is_open():
		return false
	if _shell_overlay_epoch() != token_epoch:
		return false
	var token_route := str(token.get("shell_overlay_route", "")).strip_edges()
	return token_route == "" or token_route == _shell_overlay_current_route()

func _surface_refresh_overlay_context_stale(token: Dictionary) -> bool:
	return token.has("shell_overlay_epoch") and not _surface_refresh_overlay_context_current(token)

func _emit_surface_latency_event(event_type: String, surface: String, result: Dictionary, ok: bool) -> void:
	var client := _as_dictionary(result.get("_client", {}))
	var body := _as_dictionary(result.get("body", {}))
	var refresh := SessionStore.surface_refresh_snapshot(surface)
	_emit_client_event(event_type, {
		"surface": surface,
		"method": str(client.get("method", "")),
		"endpoint": str(client.get("endpoint", refresh.get("last_endpoint", ""))),
		"action_id": str(refresh.get("last_action_id", "")),
		"scope_id": _surface_scope_id(surface),
		"duration_ms": int(client.get("duration_ms", refresh.get("last_latency_ms", 0))),
		"response_code": int(client.get("response_code", result.get("status", refresh.get("last_status", 0)))),
		"ok": ok,
		"fail": not ok,
		"used_cache": str(refresh.get("source", "")) == SessionStore.SURFACE_REFRESH_SOURCE_CACHE,
		"rendered_from_cache": bool(refresh.get("rendered_from_cache", false)),
		"server_timing": _as_dictionary(body.get("server_timing", {})),
		"save_type": SessionStore.active_save_type,
	})

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
