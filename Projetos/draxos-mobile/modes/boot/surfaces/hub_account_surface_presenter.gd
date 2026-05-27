class_name BootHubAccountSurfacePresenter
extends RefCounted

const ProjectInfoScript := preload("res://core/project_info.gd")

const SCREEN_BATTLE := "battle"
const SCREEN_BASE := "base"
const SCREEN_SOCIAL := "social"
const SCREEN_COMPETITION := "competition"
const SCREEN_SHOP := "shop"

static func render_login(host: Node) -> void:
	_add_section_label(host, "Conta Internal Alpha")
	_add_body_text(host, "Entre com email e senha para usar o save compartilhado entre PC, Web e Android. O convite libera o primeiro save desta conta.")
	host.set("_auth_email_input", _add_social_input(
		host,
		"Email",
		"tester@exemplo.com",
		SessionStore.auth_email,
		"Email usado no Supabase Auth da Internal Alpha."
	))
	var password_input := _add_social_input(
		host,
		"Senha",
		"Senha da conta alpha",
		"",
		"Senha da conta alpha. Ela nao e salva no cache local."
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
		"Convite alpha",
		SessionStore.DEFAULT_INVITE_CODE,
		SessionStore.DEFAULT_INVITE_CODE,
		"Convite usado apenas para liberar o primeiro save da conta."
	))
	_add_action_button(host, "Criar conta alpha", "email_sign_up")
	_add_action_button(host, "Entrar com email", "email_sign_in")
	_add_action_button(host, "Sincronizar sessao", "refresh_session")
	_add_action_button(host, "Resetar sessao local", "reset_session", "Limpar apenas token/cache local desta maquina? O estado salvo no servidor nao sera apagado.")

static func render_quick_test(host: Node) -> void:
	_add_section_label(host, "Teste rapido")
	_add_body_text(host, "Use guest apenas para validar rapidamente sem criar conta. O teste principal da alpha usa email/senha.")
	_add_action_button(host, "Entrar como guest", "enter_guest")
	if bool(host.call("_battle_lab_available")) or bool(host.call("_progression_lab_available")):
		_add_section_label(host, "Labs do editor")
		if bool(host.call("_battle_lab_available")):
			_add_action_button(host, "Battle Lab", "open_battle_lab")
		if bool(host.call("_progression_lab_available")):
			_add_action_button(host, "Progression Lab", "open_progression_lab")

static func render_active_save(host: Node) -> void:
	_add_section_label(host, "Save ativo")
	_add_body_text(host, "O save Normal executa o loop server-authoritative local. O save Progression Lab fica isolado para testes e nao deve pontuar ranking/social.")
	_add_action_button(host, "Usar save normal", "select_save_normal")
	_add_action_button(host, "Usar save Progression Lab", "select_save_progression_lab")
	_add_action_button(
		host,
		"Resetar save ativo",
		"reset_active_save",
		"Resetar apenas o save %s no servidor? O outro save e a sessao local serao preservados." % SessionStore.active_save_label()
	)
	_add_output_label(host, "Save atual: %s (%s)" % [
		SessionStore.active_save_label(),
		SessionStore.active_save_badge(),
	])

static func render_session_status(host: Node) -> void:
	var account := "Conta: nao iniciada"
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		account = "Progression Lab local: %s | Level %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player.get("level", 1)),
			str(SessionStore.player.get("power", 0)),
		]
	elif SessionStore.has_account_state():
		account = "Conta %s: %s | Level %s | Poder %s" % [
			SessionStore.auth_method,
			SessionStore.player_display_name(),
			str(SessionStore.player.get("level", 1)),
			str(SessionStore.player.get("power", 0)),
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
	_add_action_button(host, "Checar update", "check_update")

static func render_screen_links(host: Node) -> void:
	_add_section_label(host, "Telas")
	_add_screen_button(host, "Abrir Batalha", SCREEN_BATTLE)
	_add_screen_button(host, "Abrir Base", SCREEN_BASE)
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
	var manifest_url := str(update_gate.get("manifest_url", SupabaseClient.manifest_url()))
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

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

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
