class_name BootSocialSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

static func render(host: Node) -> void:
	_add_body_text(host, "Social Basico: amigos, guilda e chat de guilda em um so lugar.")
	var refresh_social_button := _add_action_button(host, "Atualizar social", AppShellActionContractScript.ACTION_SHOW_SOCIAL)
	refresh_social_button.tooltip_text = "Busca amigos, guilda, membros, estruturas e mensagens recentes."
	var copy_username_button := _add_action_button(host, "Copiar meu username", AppShellActionContractScript.ACTION_COPY_SOCIAL_USERNAME)
	copy_username_button.tooltip_text = "Copia o username social da conta para compartilhar com outro jogador."
	_add_section_label(host, "Amigos")
	host.set("_social_friend_input", _add_social_input(
		host,
		"Amigo por username",
		"guest_12345678",
		str(host.get("_last_social_friend_username")),
		"Digite o username do outro jogador para adicionar aos amigos."
	))
	var add_friend_button := _add_action_button(host, "Adicionar amigo", AppShellActionContractScript.ACTION_ADD_FRIEND)
	add_friend_button.tooltip_text = "Adiciona o username informado a sua lista de amigos."
	_add_section_label(host, "Guilda")
	host.set("_social_guild_input", _add_social_input(
		host,
		"Guilda",
		str(host.call("_default_guild_name")),
		str(host.call("_default_social_guild_text")),
		"Digite o nome da guilda para criar ou entrar. O nome precisa ter 3 a 32 caracteres."
	))
	var create_guild_button := _add_action_button(host, "Criar guilda", AppShellActionContractScript.ACTION_CREATE_GUILD, "Criar uma guilda para esta conta?")
	create_guild_button.tooltip_text = "Cria uma guilda e abre o canal de chat para seus membros."
	var join_guild_button := _add_action_button(host, "Entrar guilda", AppShellActionContractScript.ACTION_JOIN_GUILD)
	join_guild_button.tooltip_text = "Entra na guilda pelo nome exato. Voce so pode participar de uma guilda por vez."
	_add_section_label(host, "Chat")
	host.set("_social_chat_input", _add_social_input(
		host,
		"Mensagem de guilda",
		"Mensagem curta para o chat",
		str(host.get("_last_social_chat_message")),
		"Mensagem enviada para o canal da guilda."
	))
	var send_chat_button := _add_action_button(host, "Enviar chat guilda", AppShellActionContractScript.ACTION_SEND_GUILD_CHAT)
	send_chat_button.tooltip_text = "Envia a mensagem digitada e atualiza as conversas recentes."
	host.set("_timeline_label", _add_output_label(host, ""))
	var social_state_container := VBoxContainer.new()
	social_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_state_container.add_theme_constant_override("separation", 10)
	_content_body(host).add_child(social_state_container)
	host.set("_social_state_container", social_state_container)
	host.call("_render_social_state")

static func render_state(host: Node) -> void:
	var timeline_label := host.get("_timeline_label") as Label
	if timeline_label == null:
		return
	var social_state_container := host.get("_social_state_container") as VBoxContainer
	if social_state_container != null:
		host.call("_clear_node_children", social_state_container)
	var social := _as_dictionary(SessionStore.social_state)
	if social.is_empty():
		timeline_label.text = "\n".join(PackedStringArray([
			"Meu username: %s" % _fallback_username_text(),
			"Badge social: pendente | Badge save: %s" % _social_save_badge_text(SessionStore.active_save_badge()),
			str(host.call("_social_auto_sync_status_text")),
			"Estado atual: nenhum dado social carregado.",
		]))
		if social_state_container != null:
			host.call("_add_responsive_panel_layout", social_state_container, [
				_social_identity_panel(host, {}, {}, {}, false),
				_social_friends_panel(host, []),
				_social_guild_panel(host, {}, [], []),
				_social_chat_panel(host, [], false),
			], 2)
		return

	var identity := _as_dictionary(social.get("identity", {}))
	var active_player := _as_dictionary(social.get("active_player", {}))
	var social_player := _as_dictionary(social.get("player", {}))
	var guild := _as_dictionary(social.get("guild", {}))
	var friends := _as_array(social.get("friends", []))
	var members := _as_array(social.get("guild_members", []))
	var structures := _as_array(social.get("guild_structures", []))
	var messages := _as_array(social.get("guild_chat", []))

	var lines := PackedStringArray()
	lines.append("Meu username: %s" % _social_username_text(social_player, _fallback_username_text()))
	lines.append("Badge social: %s | Badge save: %s" % [
		_social_save_badge_text(str(identity.get("viewer_badge", SessionStore.active_save_badge()))),
		_social_save_badge_text(_profile_save_badge(active_player)),
	])
	lines.append(str(host.call("_social_auto_sync_status_text")))
	lines.append("Use Atualizar social quando quiser forcar uma nova busca.")
	lines.append("Amigos: %s" % _count_text(friends.size(), "amigo", "amigos"))
	if guild.is_empty():
		lines.append("Guilda: nenhuma")
	else:
		lines.append("Guilda: %s L%s | %s | %s" % [
			str(guild.get("name", "")),
			str(guild.get("level", 1)),
			_count_text(members.size(), "membro", "membros"),
			_count_text(structures.size(), "estrutura", "estruturas"),
		])
	lines.append("Chat: %s" % _count_text(messages.size(), "mensagem", "mensagens"))
	lines.append("Mensagem atual: %s" % _latest_message_text(messages))
	timeline_label.text = "\n".join(lines)
	if social_state_container != null:
		host.call("_add_responsive_panel_layout", social_state_container, [
			_social_identity_panel(host, identity, social_player, active_player),
			_social_friends_panel(host, friends),
			_social_guild_panel(host, guild, members, structures),
			_social_chat_panel(host, messages, not guild.is_empty()),
		], 2)

static func _social_identity_panel(host: Node, identity: Dictionary, social_player: Dictionary, active_player: Dictionary, social_loaded: bool = true) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Meu username", "text_primary", 17))
	box.add_child(_base_label(host, _social_username_text(social_player, _fallback_username_text()), "text_secondary"))
	var badge := str(identity.get("viewer_badge", SessionStore.active_save_badge()))
	var active_badge := _profile_save_badge(active_player)
	var social_badge_text := _social_save_badge_text(badge) if social_loaded else "pendente"
	box.add_child(_base_label(host, "Badge social: %s" % social_badge_text, "status_error" if badge == "lab" else "status_success"))
	box.add_child(_base_label(host, "Badge save: %s" % _social_save_badge_text(active_badge), "status_error" if active_badge == "lab" else "status_success"))
	box.add_child(_base_label(host, str(host.call("_social_auto_sync_status_text")), "text_secondary"))
	if bool(identity.get("fallback_to_active_save", false)):
		box.add_child(_base_label(host, "Social usando o save ativo enquanto o perfil Normal ainda nao foi aberto.", "status_warning"))
	return panel

static func _social_friends_panel(host: Node, friends: Array) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Amigos - %s" % _count_text(friends.size(), "amigo", "amigos"), "text_primary", 17))
	if friends.is_empty():
		box.add_child(_base_label(host, "Nenhum amigo ainda. Digite um username e toque Adicionar amigo.", "text_secondary"))
		box.add_child(_base_label(host, "Depois de adicionar, o amigo aparece aqui na proxima sincronizacao.", "text_secondary"))
		return panel
	for item: Variant in friends:
		var friendship := _as_dictionary(item)
		var profile := _as_dictionary(friendship.get("friend", {}))
		var created_at := _compact_timestamp(str(friendship.get("created_at", "")))
		var line := "%s - %s - L%s - Poder %s" % [
			_social_username_text(profile),
			_friend_status_text(str(friendship.get("status", "accepted"))),
			str(profile.get("level", 1)),
			str(profile.get("power", 0)),
		]
		if created_at != "":
			line += " - desde %s" % created_at
		box.add_child(_base_label(host, line, "status_error" if str(profile.get("save_badge", "")) == "lab" else "text_secondary"))
	return panel

static func _social_guild_panel(host: Node, guild: Dictionary, members: Array, structures: Array) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Guilda", "text_primary", 17))
	if guild.is_empty():
		box.add_child(_base_label(host, "Voce ainda nao esta em uma guilda.", "text_secondary"))
		box.add_child(_base_label(host, "Crie uma guilda ou entre pelo nome para liberar membros, estruturas e chat.", "text_secondary"))
		return panel
	box.add_child(_base_label(host, "%s | Nivel %s | %s" % [
		str(guild.get("name", "")),
		str(guild.get("level", 1)),
		_count_text(members.size(), "membro", "membros"),
	], "text_secondary"))
	box.add_child(_base_label(host, "Membros", "text_primary"))
	if members.is_empty():
		box.add_child(_base_label(host, "Nenhum membro carregado agora.", "status_warning"))
	else:
		for item: Variant in members:
			var member := _as_dictionary(item)
			var profile := _as_dictionary(member.get("player", {}))
			var badge := str(profile.get("save_badge", "normal"))
			box.add_child(_base_label(host, "%s - %s - L%s - Poder %s" % [
				_social_username_text(profile),
				_member_role_text(str(member.get("role", "member"))),
				str(profile.get("level", 1)),
				str(profile.get("power", 0)),
			], "status_error" if badge == "lab" else "text_secondary"))
	box.add_child(_base_label(host, "Estruturas informativas", "text_primary"))
	if structures.is_empty():
		box.add_child(_base_label(host, "Nenhuma estrutura de guilda carregada agora.", "text_secondary"))
	else:
		for item: Variant in structures:
			var structure := _as_dictionary(item)
			box.add_child(_base_label(host, "%s L%s" % [
				_guild_structure_label(str(structure.get("structure_id", ""))),
				str(structure.get("level", 1)),
			], "text_secondary"))
	return panel

static func _social_chat_panel(host: Node, messages: Array, has_guild: bool) -> Control:
	var panel := _base_panel(host)
	panel.tooltip_text = "Mostra as mensagens carregadas mais recentemente."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Chat - %s" % _count_text(messages.size(), "mensagem", "mensagens"), "text_primary", 17))
	box.add_child(_base_label(host, "Mensagens mais recentes. Esta tela busca novidades enquanto permanece aberta.", "text_secondary"))
	if messages.is_empty():
		if has_guild:
			box.add_child(_base_label(host, "Sem mensagens ainda. Envie uma mensagem curta para abrir a conversa.", "text_secondary"))
		else:
			box.add_child(_base_label(host, "Entre em uma guilda para liberar o chat.", "text_secondary"))
		return panel
	for item: Variant in messages:
		var message := _as_dictionary(item)
		var badge := str(message.get("sender_save_badge", "normal"))
		box.add_child(_base_label(host, _message_summary_text(message), "status_error" if badge == "lab" else "text_secondary"))
	return panel

static func _latest_message_text(messages: Array) -> String:
	for item: Variant in messages:
		var message := _as_dictionary(item)
		if not message.is_empty():
			return _message_summary_text(message)
	return "nenhuma"

static func _message_summary_text(message: Dictionary) -> String:
	var sender_label := str(message.get("sender_username", "desconhecido")).strip_edges()
	if sender_label == "":
		sender_label = "desconhecido"
	var badge := str(message.get("sender_save_badge", "normal"))
	if badge == "lab":
		sender_label += " [lab]"
	var content := str(message.get("content", "")).strip_edges()
	if content == "":
		content = "(mensagem vazia)"
	var created_at := _compact_timestamp(str(message.get("created_at", "")))
	if created_at != "":
		return "%s: %s (%s)" % [sender_label, content, created_at]
	return "%s: %s" % [sender_label, content]

static func _social_username_text(profile: Dictionary, fallback: String = "sem username") -> String:
	var username := str(profile.get("username", "")).strip_edges()
	if username == "":
		username = fallback.strip_edges()
	if username == "":
		username = "sem username"
	var badge := str(profile.get("save_badge", "normal"))
	if badge == "lab":
		return "%s [lab]" % username
	return username

static func _social_save_badge_text(badge: String) -> String:
	if badge == "lab":
		return "Save Lab"
	return "Save Normal"

static func _profile_save_badge(profile: Dictionary) -> String:
	var badge := str(profile.get("save_badge", "")).strip_edges()
	if badge == "":
		badge = SessionStore.active_save_badge()
	return badge

static func _fallback_username_text() -> String:
	var username := SessionStore.account_display_name().strip_edges()
	if username == "":
		username = "sem username"
	return username

static func _friend_status_text(status: String) -> String:
	match status:
		"accepted":
			return "aceito"
		"pending":
			return "pendente"
	return status

static func _member_role_text(role: String) -> String:
	match role:
		"owner":
			return "lider"
		"member":
			return "membro"
	return role

static func _count_text(count: int, singular: String, plural: String) -> String:
	if count == 1:
		return "1 %s" % singular
	return "%d %s" % [count, plural]

static func _compact_timestamp(value: String) -> String:
	var text := value.strip_edges()
	if text == "":
		return ""
	text = text.replace("T", " ")
	text = text.replace("Z", "")
	var dot_index := text.find(".")
	if dot_index >= 0:
		text = text.substr(0, dot_index)
	if text.length() > 16:
		return text.substr(0, 16)
	return text

static func _guild_structure_label(structure_id: String) -> String:
	match structure_id:
		"oficina_ritual":
			return "Oficina Ritual"
		"condensador_astral":
			return "Condensador Astral"
		"arquivo_de_dominio":
			return "Arquivo de Dominio"
		"cofre_abissal":
			return "Cofre Abissal"
	return structure_id

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

static func _as_array(value: Variant) -> Array:
	return value if value is Array else []

static func _content_body(host: Node) -> VBoxContainer:
	return host.get("_content_body") as VBoxContainer

static func _base_panel(host: Node) -> PanelContainer:
	return host.call("_base_panel") as PanelContainer

static func _base_label(host: Node, text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	return host.call("_base_label", text, color_token, font_size) as Label

static func _add_body_text(host: Node, text: String) -> Label:
	return host.call("_add_body_text", text) as Label

static func _add_output_label(host: Node, text: String) -> Label:
	return host.call("_add_output_label", text) as Label

static func _add_action_button(host: Node, text: String, action_id: String, confirm_message: String = "") -> Button:
	return host.call("_add_action_button", text, action_id, confirm_message) as Button

static func _add_section_label(host: Node, text: String) -> Label:
	return host.call("_add_section_label", text) as Label

static func _add_social_input(host: Node, label_text: String, placeholder: String, initial_text: String, input_tooltip: String) -> LineEdit:
	return host.call("_add_social_input", label_text, placeholder, initial_text, input_tooltip) as LineEdit
