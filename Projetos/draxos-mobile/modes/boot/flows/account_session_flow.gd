class_name DraxosAccountSessionFlow
extends RefCounted

const ProjectInfoScript := preload("res://core/project_info.gd")
const SessionStoreScript := preload("res://online/session_store.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellErrorContractScript := preload("res://modes/boot/ui/app_shell_error_contract.gd")

func _prepare_mutation(endpoint: String, action_id: String, payload: Dictionary = {}) -> Dictionary:
	return SessionStore.prepare_pending_mutation(
		endpoint,
		"session:%s" % SessionStore.active_save_type,
		action_id,
		payload
	)

func _request_id(mutation: Dictionary) -> String:
	return str(mutation.get("request_id", ""))

func _request_hash(mutation: Dictionary) -> String:
	return str(mutation.get("request_hash", ""))

func _complete_mutation(mutation: Dictionary, result: Dictionary) -> void:
	SessionStore.complete_pending_mutation(_request_id(mutation), result)

func _fail_mutation(mutation: Dictionary, result: Dictionary) -> void:
	SessionStore.fail_pending_mutation(_request_id(mutation), result)

func check_runtime_config(_host: Node) -> void:
	var config_result: Dictionary = await SupabaseClient.fetch_runtime_config()
	var config_payload := _as_dictionary(config_result.get("runtime_config", {}))
	if config_payload.is_empty():
		config_payload = _as_dictionary(config_result.get("body", {}))
	SessionStore.apply_runtime_config(config_payload)

func check_update_manifest(host: Node, manual: bool = false) -> void:
	if manual:
		host.call("_set_busy", true, "Checando manifest de update...")
	var manifest_result: Dictionary = await SupabaseClient.fetch_update_manifest()
	var update_gate: Dictionary
	if bool(manifest_result.get("ok", false)):
		update_gate = ProjectInfoScript.update_status_from_manifest(
			_as_dictionary(manifest_result.get("body", {})),
			SupabaseClient.manifest_url()
		)
		_set_error_text(host, "")
	else:
		var update_error := AppShellErrorContractScript.extract_error(manifest_result)
		update_gate = ProjectInfoScript.update_status_error(
			str(update_error.get("code", "UPDATE_CHECK_FAILED")),
			str(update_error.get("message", "Manifest indisponivel.")),
			SupabaseClient.manifest_url()
		)
		if manual:
			_set_error_text(host, str(update_gate.get("detail", "Manifest indisponivel.")))
	host.set("_update_gate", update_gate)
	if manual:
		host.call("_set_busy", false, str(update_gate.get("summary", "Checagem concluida.")))
	elif bool(update_gate.get("block_online", false)):
		_set_error_text(host, "Update obrigatorio antes de usar recursos online.")
		_set_detail_text(host, str(update_gate.get("detail", "Baixe a nova build pelo portal.")))
	host.call("_refresh_update_output_label")
	host.call("_sync_status_from_session")

func enter_guest(host: Node) -> void:
	host.call("_set_busy", true, "Criando sessao guest...")
	var selected_save_type := SessionStore.active_save_type
	var auth_result: Dictionary = {"ok": true}
	if SessionStore.has_valid_access_token() and SessionStore.is_registered_session():
		SessionStore.clear_session()
		host.call("_clear_battle_history")
		SessionStore.set_active_save_type(selected_save_type)
		SupabaseClient.configure_save_type(SessionStore.active_save_type)
	if not SessionStore.has_valid_access_token() or SessionStore.is_progression_lab_local_only():
		auth_result = await SupabaseClient.sign_in_anonymously()
		if not bool(auth_result.get("ok", false)):
			host.call("_fail_with_error", auth_result)
			return
		SessionStore.apply_auth_session(_as_dictionary(auth_result.get("session", {})))
		host.call("_clear_battle_history")
		SessionStore.save_cache()

	var request_id := SessionStore.ensure_guest_request_id()
	var mutation := _prepare_mutation("account/guest", AppShellActionContractScript.ACTION_ENTER_GUEST, {
		"invite_code": SessionStore.DEFAULT_INVITE_CODE,
		"device_label": OS.get_name(),
		"request_id": request_id,
	})
	var guest_result: Dictionary = await SupabaseClient.create_guest_account(
		SessionStore.DEFAULT_INVITE_CODE,
		_request_id(mutation),
		OS.get_name(),
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(guest_result.get("ok", false)):
		_fail_mutation(mutation, guest_result)
		host.call("_fail_with_error", guest_result)
		return

	_complete_mutation(mutation, guest_result)
	SessionStore.apply_server_state(guest_result)
	var recovered := await recover_session_state(host)
	if not recovered:
		return
	host.call("_show_refuge_root", "Sessao guest pronta. Todos os paineis estao disponiveis.")

func enter_refuge(host: Node) -> void:
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		host.call("_show_refuge_root")
		return
	if SessionStore.has_valid_access_token():
		if not SessionStore.has_account_state():
			var active_save_ready := await recover_or_create_active_save(host)
			if not active_save_ready:
				return
		host.call("_show_refuge_root")
		return
	_set_error_text(host, "Escolha um save e entre/crie uma conta antes de abrir o Refugio.")
	_set_detail_text(host, "Para teste local, use Guest dev ou carregue um save pelo Progression Lab.")
	host.call("_sync_immersive_feedback")
	host.call("_emit_client_event", "precondition_failed", {
		"action_id": AppShellActionContractScript.ACTION_ENTER_REFUGE,
		"screen": str(host.get("_current_screen")),
		"reason": "missing_session",
	})

func email_sign_up(host: Node) -> void:
	var credentials := auth_form_values(host, true)
	if credentials.is_empty():
		return
	await email_sign_up_with_credentials(host, credentials)

func email_sign_up_from_dialog(host: Node) -> void:
	var credentials := create_account_form_values(host)
	if credentials.is_empty():
		return
	await email_sign_up_with_credentials(host, credentials)

func email_sign_up_with_credentials(host: Node, credentials: Dictionary) -> void:
	host.call("_set_busy", true, "Criando conta por email...")
	var auth_result: Dictionary = await SupabaseClient.sign_up_with_email(
		str(credentials.get("email", "")),
		str(credentials.get("password", ""))
	)
	if not bool(auth_result.get("ok", false)):
		host.call("_fail_with_error", auth_result)
		return
	var selected_save_type := SessionStore.active_save_type
	SessionStore.clear_session()
	host.call("_clear_battle_history")
	SessionStore.set_active_save_type(selected_save_type)
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	SessionStore.apply_auth_session(_as_dictionary(auth_result.get("session", {})))
	SessionStore.account_username = str(credentials.get("username", ""))
	SessionStore.save_cache()
	var save_ready := await recover_or_create_active_save(
		host,
		str(credentials.get("invite", "")),
		str(credentials.get("username", ""))
	)
	if not save_ready:
		return
	host.call("_show_refuge_root", "Conta criada. O save %s esta pronto." % SessionStore.active_save_label())

func email_sign_in(host: Node) -> void:
	var credentials := auth_form_values(host, false)
	if credentials.is_empty():
		return
	host.call("_set_busy", true, "Entrando com email...")
	var auth_result: Dictionary = await SupabaseClient.sign_in_with_email(
		str(credentials.get("email", "")),
		str(credentials.get("password", ""))
	)
	if not bool(auth_result.get("ok", false)):
		host.call("_fail_with_error", auth_result)
		return
	var selected_save_type := SessionStore.active_save_type
	SessionStore.clear_session()
	host.call("_clear_battle_history")
	SessionStore.set_active_save_type(selected_save_type)
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	SessionStore.apply_auth_session(_as_dictionary(auth_result.get("session", {})))
	if str(credentials.get("username", "")) != "":
		SessionStore.account_username = str(credentials.get("username", ""))
	SessionStore.save_cache()
	var recovered := await recover_session_state(host)
	if not recovered:
		var error_payload := AppShellErrorContractScript.extract_error({
			"error": SessionStore.last_error,
		})
		if str(error_payload.get("code", "")) == "PLAYER_NOT_FOUND" and str(credentials.get("username", "")) != "":
			recovered = await recover_or_create_active_save(
				host,
				str(credentials.get("invite", "")),
				str(credentials.get("username", ""))
			)
	if not recovered:
		return
	host.call("_show_refuge_root", "Login concluido. Save %s sincronizado." % SessionStore.active_save_label())

func refresh_session(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de sincronizar.")):
		return
	var recovered := await recover_session_state(host)
	if recovered:
		host.call("_show_screen", str(host.get("_current_screen")), false)

func reset_local_session(host: Node) -> void:
	var previous_player_id := str(SessionStore.player.get("id", ""))
	var previous_session_id := SessionStore.ensure_session_id()
	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		await SupabaseClient.send_client_telemetry(
			SessionStore.access_token,
			previous_session_id,
			"local_session_reset",
			{
				"player_id": previous_player_id,
				"screen": str(host.get("_current_screen")),
			}
		)
	SessionStore.clear_session()
	host.call("_clear_battle_history")
	SessionStore.save_cache()
	_clear_screen_history(host)
	host.call("_set_busy", false, "Dados locais limpos. Entre com email para recuperar a conta ou use guest dev.")
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ENTRY, false)

func reset_active_save(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email antes de resetar o save ativo.")):
		return
	host.call("_set_busy", true, "Resetando save %s..." % SessionStore.active_save_label())
	var mutation := _prepare_mutation("account/saves/reset", AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE, {
		"save_type": SessionStore.active_save_type,
	})
	var reset_result: Dictionary = await SupabaseClient.reset_active_save(
		_request_id(mutation),
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(reset_result.get("ok", false)):
		_fail_mutation(mutation, reset_result)
		host.call("_fail_with_error", reset_result)
		return
	if not SessionStore.apply_save_reset(reset_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {
			"ok": false,
			"error": SessionStore.last_error,
		})
		return
	_complete_mutation(mutation, reset_result)
	SessionStore.save_cache()
	host.call("_clear_battle_history")
	_clear_screen_history(host)
	host.call("_set_busy", false, "Save %s resetado. O outro save foi preservado." % SessionStore.active_save_label())
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ENTRY, false)

func select_save(host: Node, save_type: String) -> void:
	var changed := SessionStore.set_active_save_type(save_type)
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	if changed:
		host.call("_clear_battle_history")
		_clear_screen_history(host)

	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		var active_save_ready := await recover_or_create_active_save(host)
		if not active_save_ready:
			host.call("_show_screen", AppShellRouteContractScript.ROUTE_ENTRY, false)
			return
		var ready_message := "Save %s pronto. Batalha, Refugio, Social, Competicao e Loja usam este contexto." % SessionStore.active_save_label()
		if SessionStore.is_progression_lab_active():
			ready_message = "Save Progression Lab pronto. As abas usam o player Lab isolado e ele nao pontua ranking."
		host.call("_set_busy", false, ready_message)
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ENTRY, false)
		return

	if changed:
		var message := "Save ativo alterado para %s." % SessionStore.active_save_label()
		if SessionStore.is_progression_lab_active():
			message = "Save Progression Lab selecionado. Entre com email para criar/carregar o player Lab isolado ou use guest dev."
		host.call("_set_busy", false, message)
	else:
		host.call("_set_busy", false, "Save %s ja estava ativo." % SessionStore.active_save_label())
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ENTRY, false)

func recover_session_state(host: Node) -> bool:
	if SessionStore.is_progression_lab_local_only():
		host.call("_sync_status_from_session")
		return false
	if not SessionStore.has_valid_access_token():
		host.call("_sync_status_from_session")
		return false

	host.call("_set_busy", true, "Recuperando estado do servidor...")
	var state_result: Dictionary = await SupabaseClient.fetch_account_state(SessionStore.access_token)
	if not bool(state_result.get("ok", false)):
		host.call("_fail_with_error", state_result)
		return false

	return apply_recovered_state(host, state_result, "Sessao sincronizada com o servidor.")

func recover_or_create_active_save(host: Node, invite_code: String = "", username: String = "") -> bool:
	if SessionStore.is_progression_lab_local_only():
		host.call("_sync_status_from_session")
		return false
	if not SessionStore.has_valid_access_token():
		host.call("_sync_status_from_session")
		return false

	host.call("_set_busy", true, "Carregando save %s..." % SessionStore.active_save_label())
	var state_result: Dictionary = await SupabaseClient.fetch_account_state(SessionStore.access_token)
	if bool(state_result.get("ok", false)):
		return apply_recovered_state(host, state_result, "Save %s sincronizado." % SessionStore.active_save_label())

	var state_error := AppShellErrorContractScript.extract_error(state_result)
	if str(state_error.get("code", "")) != "PLAYER_NOT_FOUND":
		host.call("_fail_with_error", state_result)
		return false

	host.call("_set_busy", true, "Criando save %s..." % SessionStore.active_save_label())
	var account_result: Dictionary
	var mutation: Dictionary = {}
	if SessionStore.is_registered_session():
		var effective_username := effective_alpha_username(username)
		var effective_invite := effective_alpha_invite(host, invite_code)
		var alpha_request_id := SessionStore.ensure_alpha_account_request_id()
		mutation = _prepare_mutation("account/bootstrap", AppShellActionContractScript.ACTION_EMAIL_SIGN_UP, {
			"invite_code": effective_invite,
			"username": effective_username,
			"device_label": OS.get_name(),
			"request_id": alpha_request_id,
		})
		account_result = await SupabaseClient.bootstrap_alpha_account(
			effective_invite,
			effective_username,
			_request_id(mutation),
			OS.get_name(),
			SessionStore.access_token,
			_request_hash(mutation)
		)
	else:
		var guest_request_id := SessionStore.ensure_guest_request_id()
		mutation = _prepare_mutation("account/guest", AppShellActionContractScript.ACTION_ENTER_GUEST, {
			"invite_code": SessionStore.DEFAULT_INVITE_CODE,
			"device_label": OS.get_name(),
			"request_id": guest_request_id,
		})
		account_result = await SupabaseClient.create_guest_account(
			SessionStore.DEFAULT_INVITE_CODE,
			_request_id(mutation),
			OS.get_name(),
			SessionStore.access_token,
			_request_hash(mutation)
		)
	if not bool(account_result.get("ok", false)):
		_fail_mutation(mutation, account_result)
		var account_error := AppShellErrorContractScript.extract_error(account_result)
		if str(account_error.get("code", "")) == "ACCOUNT_ALREADY_CREATED":
			state_result = await SupabaseClient.fetch_account_state(SessionStore.access_token)
			if bool(state_result.get("ok", false)):
				return apply_recovered_state(host, state_result, "Save %s sincronizado." % SessionStore.active_save_label())
		host.call("_fail_with_error", account_result)
		return false

	_complete_mutation(mutation, account_result)
	return apply_recovered_state(host, account_result, "Save %s pronto." % SessionStore.active_save_label())

func auth_form_values(host: Node, require_username: bool) -> Dictionary:
	var email := _input_text(host, "_auth_email_input").to_lower()
	var password := _input_text(host, "_auth_password_input")
	var username := normalized_alpha_username(_input_text(host, "_auth_username_input", SessionStore.account_username))
	var invite := _input_text(host, "_auth_invite_input", SessionStore.DEFAULT_INVITE_CODE).to_upper()

	if email == "" or not email.contains("@") or not email.contains("."):
		_set_error_text(host, "Informe um email valido.")
		_set_detail_text(host, "A conta usa email/senha para compartilhar o save entre PC, Web e Android.")
		return {}
	if password.length() < 6:
		_set_error_text(host, "A senha precisa ter pelo menos 6 caracteres.")
		_set_detail_text(host, "Use a mesma senha para recuperar o save em outra plataforma.")
		return {}
	if require_username and username == "":
		_set_error_text(host, "Informe um username valido.")
		_set_detail_text(host, "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore.")
		return {}
	if username != "" and not is_valid_alpha_username(username):
		_set_error_text(host, "Username invalido.")
		_set_detail_text(host, "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore.")
		return {}
	if require_username and invite == "":
		_set_error_text(host, "Informe o convite.")
		_set_detail_text(host, "O convite libera o primeiro save desta conta.")
		return {}

	return {
		"email": email,
		"password": password,
		"username": username,
		"invite": invite,
	}

func create_account_form_values(host: Node) -> Dictionary:
	var email := _input_text(host, "_signup_email_input").to_lower()
	var password := _input_text(host, "_signup_password_input")
	var username := normalized_alpha_username(_input_text(host, "_signup_username_input", SessionStore.account_username))

	if email == "" or not email.contains("@") or not email.contains("."):
		_set_error_text(host, "Informe um email valido.")
		_set_detail_text(host, "A conta usa email/senha para compartilhar o save entre PC, Web e Android.")
		host.call("_sync_immersive_feedback")
		return {}
	if password.length() < 6:
		_set_error_text(host, "A senha precisa ter pelo menos 6 caracteres.")
		_set_detail_text(host, "Use a mesma senha para recuperar o save em outra plataforma.")
		host.call("_sync_immersive_feedback")
		return {}
	if username == "":
		_set_error_text(host, "Informe um username valido.")
		_set_detail_text(host, "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore.")
		host.call("_sync_immersive_feedback")
		return {}
	if not is_valid_alpha_username(username):
		_set_error_text(host, "Username invalido.")
		_set_detail_text(host, "Use 3 a 24 caracteres: letras minusculas, numeros ou underscore.")
		host.call("_sync_immersive_feedback")
		return {}

	return {
		"email": email,
		"password": password,
		"username": username,
		"invite": SessionStore.DEFAULT_INVITE_CODE,
	}

func effective_alpha_username(username: String) -> String:
	var normalized := normalized_alpha_username(username)
	if normalized == "":
		normalized = normalized_alpha_username(SessionStore.account_username)
	if normalized == "":
		normalized = normalized_alpha_username(SessionStore.player_display_name())
	if normalized == "":
		normalized = "tester_%s" % SessionStore.ensure_session_id().replace("-", "").substr(0, 8)
	normalized = SessionStoreScript.base_account_username(normalized)
	return normalized

func effective_alpha_invite(host: Node, invite_code: String) -> String:
	var normalized := invite_code.strip_edges().to_upper()
	if normalized == "":
		normalized = _input_text(host, "_auth_invite_input", SessionStore.DEFAULT_INVITE_CODE).to_upper()
	if normalized == "":
		normalized = SessionStore.DEFAULT_INVITE_CODE
	return normalized

func normalized_alpha_username(username: String) -> String:
	return username.strip_edges().to_lower()

func is_valid_alpha_username(username: String) -> bool:
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

func apply_recovered_state(host: Node, state_result: Dictionary, message: String) -> bool:
	if not SessionStore.apply_server_state(state_result):
		host.call("_fail_with_error", {
			"ok": false,
			"error": SessionStore.last_error,
		})
		return false
	SessionStore.save_cache()
	host.call("_set_busy", false, message)
	host.call("_sync_status_from_session")
	return true

func _input_text(host: Node, property_name: String, fallback: String = "") -> String:
	return str(host.call("_social_input_text", host.get(property_name), fallback))

func _set_error_text(host: Node, text: String) -> void:
	var label := host.get("_error_label") as Label
	if label != null:
		label.text = text

func _set_detail_text(host: Node, text: String) -> void:
	var label := host.get("_detail_label") as Label
	if label != null:
		label.text = text

func _clear_screen_history(host: Node) -> void:
	var history: Array = host.get("_screen_history")
	history.clear()

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}
