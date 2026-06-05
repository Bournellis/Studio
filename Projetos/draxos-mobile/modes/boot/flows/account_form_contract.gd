extends RefCounted

const SessionStoreScript := preload("res://online/session_store.gd")

static func auth_form_values(host: Node, require_username: bool) -> Dictionary:
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

static func create_account_form_values(host: Node) -> Dictionary:
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

static func effective_alpha_username(username: String) -> String:
	var normalized := normalized_alpha_username(username)
	if normalized == "":
		normalized = normalized_alpha_username(SessionStore.account_username)
	if normalized == "":
		normalized = normalized_alpha_username(SessionStore.player_display_name())
	if normalized == "":
		normalized = "tester_%s" % SessionStore.ensure_session_id().replace("-", "").substr(0, 8)
	normalized = SessionStoreScript.base_account_username(normalized)
	return normalized

static func effective_alpha_invite(host: Node, invite_code: String) -> String:
	var normalized := invite_code.strip_edges().to_upper()
	if normalized == "":
		normalized = _input_text(host, "_auth_invite_input", SessionStore.DEFAULT_INVITE_CODE).to_upper()
	if normalized == "":
		normalized = SessionStore.DEFAULT_INVITE_CODE
	return normalized

static func normalized_alpha_username(username: String) -> String:
	return username.strip_edges().to_lower()

static func is_valid_alpha_username(username: String) -> bool:
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

static func _input_text(host: Node, property_name: String, fallback: String = "") -> String:
	return str(host.call("_social_input_text", host.get(property_name), fallback))

static func _set_error_text(host: Node, text: String) -> void:
	var label := host.get("_error_label") as Label
	if label != null:
		label.text = text

static func _set_detail_text(host: Node, text: String) -> void:
	var label := host.get("_detail_label") as Label
	if label != null:
		label.text = text
