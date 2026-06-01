extends "res://modes/boot/boot_runtime_surface_api.gd"

# Busy state, status feedback, social auto-sync, and precondition guards.
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
	return _current_screen == SCREEN_SOCIAL and not _is_busy and not _social_auto_sync_in_flight and _social_auto_sync_last_error == "" and not SessionStore.offline and not SessionStore.is_progression_lab_local_only() and SessionStore.has_valid_access_token() and SessionStore.has_account_state()

func _on_social_auto_sync_timeout() -> void:
	await _auto_sync_social_state()

func _auto_sync_social_state() -> void:
	if _current_screen != SCREEN_SOCIAL:
		_sync_social_auto_sync_for_route()
		return
	if _is_busy:
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
	if _is_busy: return "Sincronizacao pausada durante outra acao."
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
		button.disabled = force_disabled or _is_busy or (_replay_running and not _action_allowed_during_replay(action_id))
		button.disabled = button.disabled or _update_gate_blocks_action(action_id)
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
				button.disabled = button.disabled or not bool(product.get("can_purchase", true))
		elif AppShellActionContractScript.is_claim_reward(action_id):
			var reward := _shop_reward_by_id(AppShellActionContractScript.action_value(action_id))
			if not reward.is_empty():
				button.disabled = button.disabled or bool(reward.get("claimed", false))
		if action_id == AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE:
			if button.name == "RefugeContextCta" and SessionStore.has_unseen_battle_result():
				button.text = "Ver recompensa"
			else:
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
