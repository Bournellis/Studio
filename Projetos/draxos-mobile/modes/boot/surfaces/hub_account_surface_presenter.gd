class_name BootHubAccountSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const ProjectInfoScript := preload("res://core/project_info.gd")

const SCREEN_BATTLE := "battle_entry"
const SCREEN_BASE := "base_management"
const SCREEN_SOCIAL := "social"
const SCREEN_COMPETITION := "competition"
const SCREEN_SHOP := "shop"

static func render_account_panel(host: Node) -> void:
	_add_section_label(host, "Perfil e ajustes")
	_add_body_text(host, "Conta, update e area de risco ficam aqui para manter o Refugio limpo.")
	render_profile_account_panel(host)
	render_session_status(host)
	render_update_gate(host)
	render_profile_actions(host)

static func home_account_summary_text(host: Node) -> String:
	var update_gate := _as_dictionary(host.get("_update_gate")) if host != null else {}
	var lines := PackedStringArray()
	lines.append("Conta: %s" % _account_identity_text(SessionStore))
	lines.append("Save ativo: %s (%s)" % [SessionStore.active_save_label(), SessionStore.active_save_badge()])
	lines.append("Estado: %s" % _account_state_text(SessionStore))
	lines.append("Build: %s %s | %s" % [
		ProjectInfoScript.RELEASE_CHANNEL,
		ProjectInfoScript.APP_VERSION,
		_alpha_status_text(SessionStore, update_gate),
	])
	lines.append("Update: %s" % str(update_gate.get("summary", "Update ainda nao verificado.")))
	return "\n".join(lines)

static func render_login(host: Node) -> void:
	_add_section_label(host, "Conta")
	_add_body_text(host, "Entre com email e senha para usar o save compartilhado entre PC, Web e Android. O convite libera o primeiro save desta conta.")
	host.set("_auth_email_input", _add_social_input(
		host,
		"Email",
		"tester@exemplo.com",
		SessionStore.auth_email,
		"Email usado na conta."
	))
	var password_input := _add_social_input(
		host,
		"Senha",
		"Senha da conta",
		"",
		"Senha da conta. Ela nao e salva nesta maquina."
	)
	password_input.secret = true
	host.set("_auth_password_input", password_input)
	host.set("_auth_username_input", _add_social_input(
		host,
		"Username",
		"draxos_tester",
		SessionStore.account_username,
		"Username publico: 3 a 24 letras minusculas, numeros ou underscores."
	))
	host.set("_auth_invite_input", _add_social_input(
		host,
		"Convite",
		SessionStore.DEFAULT_INVITE_CODE,
		SessionStore.DEFAULT_INVITE_CODE,
		"Convite usado apenas para liberar o primeiro save da conta."
	))
	_add_action_button(host, "Criar conta", AppShellActionContractScript.ACTION_EMAIL_SIGN_UP)
	_add_action_button(host, "Entrar com email", AppShellActionContractScript.ACTION_EMAIL_SIGN_IN)
	_add_action_button(host, "Sincronizar sessao", AppShellActionContractScript.ACTION_REFRESH_SESSION)
	_add_action_button(host, "Resetar sessao local", AppShellActionContractScript.ACTION_RESET_SESSION, "Limpar apenas token/cache local desta maquina? O estado salvo no servidor nao sera apagado.")

static func render_guest_access(host: Node) -> void:
	_add_section_label(host, "Teste rapido local")
	_add_body_text(host, "Use guest apenas para validar rapidamente sem criar conta. O teste principal usa email/senha.")
	_add_action_button(host, "Entrar como guest", AppShellActionContractScript.ACTION_ENTER_GUEST)

static func render_quick_test(host: Node) -> void:
	render_guest_access(host)
	if bool(host.call("_battle_lab_available")) or bool(host.call("_progression_lab_available")):
		_add_section_label(host, "Labs do editor")
		if bool(host.call("_battle_lab_available")):
			_add_action_button(host, "Battle Lab", AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB)
		if bool(host.call("_progression_lab_available")):
			_add_action_button(host, "Progression Lab", AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB)

static func render_active_save(host: Node) -> void:
	_add_section_label(host, "Save ativo")
	_add_body_text(host, "O save Normal executa o loop principal. O save Progression Lab fica isolado para testes e nao deve pontuar ranking/social.")
	_add_action_button(host, "Usar save normal", AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL)
	_add_action_button(host, "Usar save Progression Lab", AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB)
	_add_action_button(
		host,
		"Resetar save ativo",
		AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE,
		"Resetar apenas o save %s? O outro save e a sessao local serao preservados." % SessionStore.active_save_label()
	)
	_add_output_label(host, "Save atual: %s (%s)" % [
		SessionStore.active_save_label(),
		SessionStore.active_save_badge(),
	])

static func render_profile_account_panel(host: Node) -> void:
	_add_section_label(host, "Perfil e conta")
	_add_output_label(host, profile_account_status_text(host))

static func render_profile_actions(host: Node) -> void:
	_add_section_label(host, "Ajustes")
	_add_action_button(host, "Sincronizar", AppShellActionContractScript.ACTION_REFRESH_SESSION)
	_add_action_button(host, "Reset local", AppShellActionContractScript.ACTION_RESET_SESSION, "Limpar apenas os dados locais desta maquina? O save da conta nao sera apagado.")
	if SessionStore.has_valid_access_token() or SessionStore.has_account_state():
		_add_action_button(host, "Reset save", AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE, "Resetar apenas o save %s? O outro save e a sessao local serao preservados." % SessionStore.active_save_label())

static func render_session_status(host: Node) -> void:
	var account := "Conta: nao iniciada"
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		account = "Progression Lab local: %s | Nivel %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player_snapshot().get("level", 1)),
			str(SessionStore.player_snapshot().get("power", 0)),
		]
	elif SessionStore.has_account_state():
		account = "Conta %s: %s | Nivel %s | Poder %s" % [
			SessionStore.auth_method,
			SessionStore.player_display_name(),
			str(SessionStore.player_snapshot().get("level", 1)),
			str(SessionStore.player_snapshot().get("power", 0)),
		]
	elif SessionStore.has_valid_access_token():
		account = "Conta: sessao %s criada; falta carregar/criar save." % SessionStore.auth_method
	_add_output_label(host, account)
	_add_output_label(host, "Sessao local: %s | Offline: %s" % [
		SessionStore.ensure_session_id(),
		str(SessionStore.offline),
	])

static func render_update_gate(host: Node) -> void:
	_add_section_label(host, "Versao e updates")
	host.set("_update_output_label", _add_output_label(host, update_status_text(host)))
	_add_action_button(host, "Checar update", AppShellActionContractScript.ACTION_CHECK_UPDATE)

static func render_screen_links(host: Node) -> void:
	_add_section_label(host, "Telas")
	_add_screen_button(host, "Abrir Batalha", SCREEN_BATTLE)
	_add_screen_button(host, "Abrir Refugio", "refuge")
	_add_screen_button(host, "Abrir Social", SCREEN_SOCIAL)
	_add_screen_button(host, "Abrir Competicao", SCREEN_COMPETITION)
	_add_screen_button(host, "Abrir Loja", SCREEN_SHOP)

static func update_status_text(host: Node) -> String:
	var update_gate := host.get("_update_gate") as Dictionary
	var lines := PackedStringArray()
	lines.append("Canal: %s | Build: %s (code %d)" % [
		ProjectInfoScript.RELEASE_CHANNEL,
		ProjectInfoScript.APP_VERSION,
		ProjectInfoScript.APP_VERSION_CODE,
	])
	lines.append(str(update_gate.get("summary", "Update ainda nao verificado.")))
	lines.append(str(update_gate.get("detail", "O jogo vai checar o manifest remoto antes do teste fechado.")))
	var manifest_url := str(update_gate.get("manifest_url", ""))
	if manifest_url == "" and host.has_method("_manifest_url"):
		manifest_url = str(host.call("_manifest_url"))
	if manifest_url != "":
		lines.append("Manifest: %s" % manifest_url)
	var manifest := _as_dictionary(update_gate.get("manifest", {}))
	var artifacts := _as_dictionary(manifest.get("artifacts", {}))
	var platform_artifact := _as_dictionary(artifacts.get(ProjectInfoScript.current_platform_key(), {}))
	if not platform_artifact.is_empty():
		var label := str(platform_artifact.get("label", "Download"))
		var url := str(platform_artifact.get("url", ""))
		if url != "":
			lines.append("Download desta plataforma: %s - %s" % [label, url])
		else:
			lines.append("Download desta plataforma: %s ainda sem URL final." % label)
	return "\n".join(lines)

static func profile_account_status_text(host: Node = null, store: Object = null) -> String:
	var effective_store: Object = store
	if effective_store == null:
		effective_store = SessionStore
	var update_gate := {}
	if host != null:
		update_gate = _as_dictionary(host.get("_update_gate"))
	return "\n".join(profile_account_status_lines(effective_store, update_gate))

static func profile_account_status_lines(store: Object, update_gate: Dictionary = {}) -> PackedStringArray:
	var lines := PackedStringArray()
	lines.append("Username: %s" % _profile_username(store))
	lines.append("Conta: %s" % _account_identity_text(store))
	lines.append("Save ativo: %s (%s)" % [_store_call_string(store, "active_save_label", "Normal"), _store_call_string(store, "active_save_badge", "normal")])
	lines.append("Nivel: %s" % _player_field_text(store, "level", "sem save carregado"))
	lines.append("Poder: %s" % _player_field_text(store, "power", "sem save carregado"))
	lines.append("Auth: %s" % _auth_method_text(store))
	lines.append("Estado: %s" % _account_state_text(store))
	lines.append("Update: %s (%s)" % [
		str(update_gate.get("summary", "Update ainda nao verificado.")),
		str(update_gate.get("status", "unchecked")),
	])
	lines.append("Build: %s %s | %s" % [
		ProjectInfoScript.RELEASE_CHANNEL,
		ProjectInfoScript.APP_VERSION,
		_alpha_status_text(store, update_gate),
	])
	return lines

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

static func _profile_username(store: Object) -> String:
	var player := _store_dictionary(store, "player")
	var username := str(player.get("username", "")).strip_edges()
	if username != "":
		return username
	var account_username := _store_string(store, "account_username").strip_edges()
	if account_username != "":
		return account_username
	var auth_email := _store_string(store, "auth_email").strip_edges()
	if auth_email != "":
		return auth_email
	return "sem conta carregada"

static func _account_identity_text(store: Object) -> String:
	var account_username := _store_string(store, "account_username").strip_edges()
	if account_username != "":
		return account_username
	var auth_email := _store_string(store, "auth_email").strip_edges()
	if auth_email != "":
		return auth_email
	return "sem identidade"

static func _player_field_text(store: Object, key: String, fallback: String) -> String:
	var player := _store_dictionary(store, "player")
	if player.has(key):
		return str(player.get(key, fallback))
	return fallback

static func _auth_method_text(store: Object) -> String:
	var method := _store_string(store, "auth_method", "guest").strip_edges().to_lower()
	var email := _store_string(store, "auth_email").strip_edges()
	match method:
		"email":
			if email != "":
				return "email/senha (%s)" % email
			return "email/senha"
		"guest":
			return "guest dev"
	if method == "":
		return "desconhecido"
	return method

static func _account_state_text(store: Object) -> String:
	if _store_call_bool(store, "has_account_state"):
		if _store_call_bool(store, "is_progression_lab_local_only"):
			return "dados locais do Progression Lab"
		return "carregado do save ativo"
	if _store_call_bool(store, "has_valid_access_token"):
		return "sessao auth pronta; falta sincronizar/criar save"
	return "sem sessao auth"

static func _alpha_status_text(store: Object, update_gate: Dictionary) -> String:
	if _store_call_bool(store, "is_progression_lab_local_only"):
		return "Progression Lab local-only"
	if bool(update_gate.get("block_online", false)):
		return "bloqueado por update obrigatorio"
	if _store_bool(store, "offline"):
		return "offline/cache local"
	if _store_call_bool(store, "has_account_state"):
		return "online pronto"
	if _store_call_bool(store, "has_valid_access_token"):
		return "sessao auth sem save carregado"
	return "aguardando login"

static func _store_dictionary(store: Object, property_name: String) -> Dictionary:
	if store == null:
		return {}
	return _as_dictionary(store.get(property_name))

static func _store_string(store: Object, property_name: String, fallback: String = "") -> String:
	if store == null:
		return fallback
	var value: Variant = store.get(property_name)
	if value == null:
		return fallback
	return str(value)

static func _store_bool(store: Object, property_name: String) -> bool:
	if store == null:
		return false
	return bool(store.get(property_name))

static func _store_call_string(store: Object, method_name: String, fallback: String = "") -> String:
	if store == null or not store.has_method(method_name):
		return fallback
	return str(store.call(method_name))

static func _store_call_bool(store: Object, method_name: String) -> bool:
	if store == null or not store.has_method(method_name):
		return false
	return bool(store.call(method_name))

static func _add_section_label(host: Node, text: String) -> Label:
	return host.call("_add_section_label", text) as Label

static func _add_body_text(host: Node, text: String) -> Label:
	return host.call("_add_body_text", text) as Label

static func _add_output_label(host: Node, text: String) -> Label:
	return host.call("_add_output_label", text) as Label

static func _add_action_button(host: Node, text: String, action_id: String, confirm_message: String = "") -> Button:
	return host.call("_add_action_button", text, action_id, confirm_message) as Button

static func _add_social_input(host: Node, label_text: String, placeholder: String, initial_text: String, input_tooltip: String) -> LineEdit:
	return host.call("_add_social_input", label_text, placeholder, initial_text, input_tooltip) as LineEdit

static func _add_screen_button(host: Node, text: String, screen_id: String) -> Button:
	return host.call("_add_screen_button", text, screen_id) as Button
