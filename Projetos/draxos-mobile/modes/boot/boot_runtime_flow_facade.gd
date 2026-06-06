extends "res://modes/boot/boot_runtime_labs_controller.gd"

# Compatibility facade for account, battle, arena, mode, base, social, competition, and shop flows.
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

func _open_arena() -> void:
	await _arena_lifecycle_flow.open_arena(self)

func _start_arena_tutorial() -> void:
	await _arena_lifecycle_flow.start_tutorial(self)

func _start_arena_early() -> void:
	await _arena_lifecycle_flow.start_early(self)

func _start_arena_by_id(arena_id: String, difficulty_id: String = "") -> void:
	await _arena_lifecycle_flow.start_arena(self, arena_id, difficulty_id)

func _lock_arena_loadout() -> void:
	_arena_lifecycle_flow.lock_loadout(self)

func _resume_arena_attempt() -> void:
	_arena_lifecycle_flow.resume_attempt(self)

func _resolve_arena_duel() -> void:
	await _arena_lifecycle_flow.resolve_duel(self)

func _choose_arena_buff(buff_id: String) -> void:
	await _arena_lifecycle_flow.choose_buff(self, buff_id)

func _abandon_arena_attempt() -> void:
	await _arena_lifecycle_flow.abandon_attempt(self)

func _claim_arena_summary() -> void:
	await _arena_lifecycle_flow.claim_summary(self)

func _open_mode_shell(mode_id: String = "") -> void:
	_mode_shell_launcher.open(self, mode_id)

func _openworld_integrated_alpha_enabled(mode_id: String) -> bool:
	if mode_id != ModeShellRegistryScript.MODE_OPENWORLD:
		return false
	if not bool(ProjectSettings.get_setting("draxos_mobile/modes/openworld/integrated_alpha", false)):
		return false
	return SessionStore.has_valid_access_token() and SessionStore.has_account_state() and not SessionStore.is_progression_lab_local_only()

func _show_base() -> void:
	await _surface_action_flow.show_base(self)

func _sync_refuge_state_if_needed() -> void:
	await _surface_action_flow.sync_refuge_state_if_needed(self)

func _upgrade_base_structure(structure_id: String) -> void:
	await _surface_action_flow.upgrade_base_structure(self, structure_id)

func _show_crafting() -> void:
	await _surface_action_flow.show_crafting(self)

func _crush_bones() -> void:
	await _surface_action_flow.crush_bones(self)

func _craft_health_potion() -> void:
	await _surface_action_flow.craft_health_potion(self)

func _base_surface_target_screen() -> String:
	if _current_screen == SCREEN_REFUGE:
		return SCREEN_REFUGE
	return SCREEN_BASE

func _show_preparation() -> void:
	await _surface_action_flow.show_preparation(self)

func _equip_health_potion() -> void:
	await _surface_action_flow.equip_health_potion(self)

func _equip_potion(item_id: String) -> void:
	await _surface_action_flow.equip_potion(self, item_id)

func _unequip_potion() -> void:
	await _surface_action_flow.unequip_potion(self)

func _enable_potion_default() -> void:
	await _surface_action_flow.enable_potion_default(self)

func _disable_potion() -> void:
	await _surface_action_flow.disable_potion(self)

func _enable_spell_behavior(spell_id: String) -> void:
	await _surface_action_flow.enable_spell_behavior(self, spell_id)

func _disable_spell_behavior(spell_id: String) -> void:
	await _surface_action_flow.disable_spell_behavior(self, spell_id)

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

func _copy_social_username() -> void:
	var username := _social_username_for_copy()
	if username == "":
		_error_label.text = "Username social ainda nao carregado. Atualize o Social e tente novamente."
		_sync_immersive_feedback()
		return
	DisplayServer.clipboard_set(username)
	_show_notice("Username copiado: %s" % username)

func _social_username_for_copy() -> String:
	var social_player := _as_dictionary(SessionStore.social_state.get("player", {}))
	var username := str(social_player.get("username", "")).strip_edges()
	if username != "":
		return username
	return str(SessionStore.player.get("username", "")).strip_edges()

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

func _play_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	await _battle_lifecycle_flow.play_battle_log(self, battle_log, rewards)
