extends "res://modes/boot/boot_runtime_navigation_controller.gd"

# Action dispatch bridge preserving host.call action methods and telemetry payloads.
func _trigger_action(action_id: String, confirm_message: String = "") -> void:
	var route := AppShellActionRouterScript.route_action(action_id, _action_context())
	if _action_scope_is_busy(str(route.get("scope_id", OperationStateScript.DEFAULT_SCOPE))):
		return
	if confirm_message != "":
		_pending_confirmation_action = action_id
		_confirm_dialog.dialog_text = confirm_message
		_confirm_dialog.popup_centered()
		return
	await _execute_action(action_id)

func _trigger_shell_overlay_action(action_id: String) -> void:
	if not _open_shell_overlay_action(action_id):
		await _trigger_action(action_id)
		return
	await _run_shell_overlay_entry_action(action_id)

func _run_shell_overlay_entry_action(action_id: String) -> void:
	match action_id:
		AppShellActionContractScript.ACTION_SHOW_ACCOUNT:
			_show_account()
		AppShellActionContractScript.ACTION_SHOW_BASE:
			await _show_base()
		AppShellActionContractScript.ACTION_SHOW_SHOP:
			await _show_shop()
		AppShellActionContractScript.ACTION_SHOW_SOCIAL:
			await _show_social()
		AppShellActionContractScript.ACTION_OPEN_ARENA:
			await _open_arena()

func _on_confirmation_confirmed() -> void:
	var action_id := _pending_confirmation_action
	_pending_confirmation_action = ""
	if action_id == "":
		return
	await _execute_action(action_id)

func _execute_action(action_id: String) -> void:
	var route := AppShellActionRouterScript.route_action(action_id, _action_context())
	var action := str(route.get("action_id", action_id))
	var scope := str(route.get("scope_id", OperationStateScript.DEFAULT_SCOPE))
	var endpoint := str(route.get("mutation_endpoint", "")).strip_edges()
	if _action_scope_is_busy(scope):
		return
	_record_web_action_input(action)
	_active_action_id = action
	_active_action_scope = scope
	if endpoint != "" and _shell_overlay_is_open():
		_shell_overlay_close_lock_action_id = action
	_error_label.text = ""
	var action_started_ms := int(Time.get_ticks_msec())
	_emit_client_event("action_start", _as_dictionary(route.get("payload", _action_payload(action))))
	if bool(route.get("blocked_by_update", false)):
		_error_label.text = "Update obrigatorio antes de usar recursos online."
		_detail_label.text = str(_update_gate.get("detail", "Baixe a nova build pelo portal."))
		_emit_client_event("precondition_failed", {
			"action_id": action,
			"screen": _current_screen,
			"reason": "required_update",
			"current_version": ProjectInfoScript.APP_VERSION,
			"minimum_supported_version": str(_update_gate.get("minimum_supported_version", "")),
		})
		_sync_buttons()
	elif endpoint != "" and not SessionStore.runtime_allows_gameplay_mutation():
		_error_label.text = SessionStore.runtime_mutation_block_reason()
		_detail_label.text = "Tente sincronizar a configuracao remota antes de executar a acao."
		_emit_client_event("precondition_failed", {
			"action_id": action,
			"screen": _current_screen,
			"reason": "runtime_read_only",
			"endpoint": endpoint,
			"runtime_fallback": SessionStore.runtime_config_is_fallback(),
		})
		_sync_immersive_feedback()
		_sync_buttons()
	elif AppShellActionContractScript.is_select_base_structure(action):
		_select_base_structure(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_upgrade_base_structure(action):
		await _upgrade_base_structure(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_shop_purchase(action):
		await _buy_shop_product(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_claim_reward(action):
		await _claim_shop_reward(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_build_equip_action(action):
		await _surface_action_flow.handle_build_equip_action(self, action)
	elif AppShellActionContractScript.is_enable_spell_behavior(action):
		await _enable_spell_behavior(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_disable_spell_behavior(action):
		await _disable_spell_behavior(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_equip_potion(action):
		await _equip_potion(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_arena_start(action):
		await _start_arena_by_id(
			AppShellActionContractScript.action_value(action),
			AppShellActionContractScript.action_value_at(action, 2)
		)
	elif AppShellActionContractScript.is_arena_choose_buff(action):
		await _choose_arena_buff(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_battle_replay(action):
		await _show_battle_replay(AppShellActionContractScript.action_value(action))
	elif AppShellActionContractScript.is_open_mode_shell(action):
		if _shell_overlay_is_open():
			_close_shell_overlay()
		else:
			_open_mode_shell(AppShellActionContractScript.action_value(action))
	else:
		match action:
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
			AppShellActionContractScript.ACTION_SHOW_ACCOUNT:
				_show_account()
			AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL:
				await _select_save(SessionStoreScript.SAVE_TYPE_NORMAL)
			AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB:
				await _select_save(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
			AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB:
				_open_battle_lab_overlay()
			AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB:
				_open_progression_lab_overlay()
			AppShellActionContractScript.ACTION_OPEN_ARENA:
				await _open_arena()
			AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL:
				await _start_arena_tutorial()
			AppShellActionContractScript.ACTION_ARENA_START_EARLY:
				await _start_arena_early()
			AppShellActionContractScript.ACTION_ARENA_LOCK_LOADOUT:
				_lock_arena_loadout()
			AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT:
				_resume_arena_attempt()
			AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL:
				await _resolve_arena_duel()
			AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT:
				await _abandon_arena_attempt()
			AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY:
				await _claim_arena_summary()
			AppShellActionContractScript.ACTION_REQUEST_BATTLE:
				await _request_battle()
			ACTION_SKIP_REPLAY:
				_skip_current_replay()
			ACTION_RETURN_REFUGE:
				if _shell_overlay_is_open():
					_close_shell_overlay()
				else:
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
				else:
					await _show_latest_battle()
			AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY:
				await _show_battle_history()
			AppShellActionContractScript.ACTION_SHOW_BASE:
				await _show_base()
			AppShellActionContractScript.ACTION_UPGRADE_NUCLEO:
				await _upgrade_base_structure(AppShellActionContractScript.STRUCTURE_NUCLEO_ENERGIA)
			AppShellActionContractScript.ACTION_SHOW_CRAFTING:
				await _show_crafting()
			AppShellActionContractScript.ACTION_CRUSH_BONES:
				await _crush_bones()
			AppShellActionContractScript.ACTION_CRAFT_HEALTH_POTION:
				await _craft_health_potion()
			AppShellActionContractScript.ACTION_SHOW_PREPARATION:
				await _show_preparation()
			AppShellActionContractScript.ACTION_EQUIP_HEALTH_POTION:
				await _equip_health_potion()
			AppShellActionContractScript.ACTION_UNEQUIP_POTION:
				await _unequip_potion()
			AppShellActionContractScript.ACTION_ENABLE_POTION_DEFAULT:
				await _enable_potion_default()
			AppShellActionContractScript.ACTION_DISABLE_POTION:
				await _disable_potion()
			AppShellActionContractScript.ACTION_SHOW_SOCIAL:
				await _show_social()
			AppShellActionContractScript.ACTION_COPY_SOCIAL_USERNAME:
				_copy_social_username()
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
	if _active_action_id == action:
		var event_type := "action_failure" if _error_label.text != "" else "action_success"
		var payload := _action_payload(action)
		if _error_label.text != "":
			payload["error_text"] = _error_label.text
		payload["duration_ms"] = maxi(0, int(Time.get_ticks_msec()) - action_started_ms)
		payload["scope_id"] = _active_action_scope
		payload["endpoint"] = endpoint
		payload["method"] = "POST" if endpoint != "" else ""
		payload["response_code"] = 0
		payload["ok"] = event_type == "action_success"
		payload["fail"] = event_type != "action_success"
		payload["used_cache"] = false
		payload["rendered_from_cache"] = false
		payload["server_timing"] = {}
		_emit_client_event(event_type, payload)
		_emit_client_event("action_latency", payload.duplicate(true))
	_active_action_id = ""
	_active_action_scope = OperationStateScript.DEFAULT_SCOPE
	if _shell_overlay_close_lock_action_id == action:
		_shell_overlay_close_lock_action_id = ""

func _record_web_action_input(action_id: String) -> void:
	_web_action_sequence += 1
	_web_last_action = {
		"action_id": action_id,
		"screen": _current_screen,
		"active_route": _active_route_for_context(),
		"overlay_open": _shell_overlay_is_open(),
		"overlay_route": _shell_overlay_current_route(),
	}
	if has_method("_publish_web_diagnostics_state"):
		_publish_web_diagnostics_state()
		call_deferred("_publish_web_diagnostics_state")

func _action_scope_is_busy(scope_id: String) -> bool:
	var scope := OperationStateScript.normalize_scope(scope_id)
	if scope == OperationStateScript.DEFAULT_SCOPE:
		return _operation_state.is_busy(OperationStateScript.DEFAULT_SCOPE)
	return _operation_state.is_busy(scope)
