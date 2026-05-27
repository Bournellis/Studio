class_name BootSocialSurfacePresenter
extends RefCounted

static func render(host: Node) -> void:
	_add_body_text(host, "Social alpha da conta: encontre outro jogador por username, crie ou entre em uma guilda e teste chat de guilda por polling.")
	var refresh_social_button := _add_action_button(host, "Atualizar social", "show_social")
	refresh_social_button.tooltip_text = "Busca amigos, guilda, membros, estruturas e mensagens recentes no servidor."
	host.set("_social_friend_input", _add_social_input(
		host,
		"Amigo por username",
		"guest_12345678",
		str(host.get("_last_social_friend_username")),
		"Digite o username do outro jogador. No alpha a amizade e aceita automaticamente."
	))
	var add_friend_button := _add_action_button(host, "Adicionar amigo", "add_friend")
	add_friend_button.tooltip_text = "Cria amizade aceita nos dois sentidos, usando o username informado."
	host.set("_social_guild_input", _add_social_input(
		host,
		"Guilda",
		str(host.call("_default_guild_name")),
		str(host.call("_default_social_guild_text")),
		"Digite o nome da guilda para criar ou entrar. O nome precisa ter 3 a 32 caracteres."
	))
	var create_guild_button := _add_action_button(host, "Criar guilda", "create_guild", "Criar uma guilda alpha para esta conta?")
	create_guild_button.tooltip_text = "Cria uma guilda, adiciona voce como owner e inicializa estruturas e canal de chat."
	var join_guild_button := _add_action_button(host, "Entrar guilda", "join_guild")
	join_guild_button.tooltip_text = "Entra na guilda pelo nome exato. Voce so pode participar de uma guilda por vez."
	host.set("_social_chat_input", _add_social_input(
		host,
		"Mensagem de guilda",
		"Mensagem curta para o chat",
		str(host.get("_last_social_chat_message")),
		"Mensagem enviada para o canal da guilda. O alpha aplica rate limit simples para evitar spam."
	))
	var send_chat_button := _add_action_button(host, "Enviar chat guilda", "send_guild_chat")
	send_chat_button.tooltip_text = "Envia a mensagem digitada e atualiza o polling do chat."
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
		timeline_label.text = "Social ainda nao carregado. Use Atualizar social."
		if social_state_container != null:
			social_state_container.add_child(_base_info_panel(
				host,
				"Social da conta",
				"Atualize o Social para ver amigos, guilda, membros, estruturas e chat por polling."
			))
		return

	var lines := PackedStringArray()
	var identity := _as_dictionary(social.get("identity", {}))
	var active_player := _as_dictionary(social.get("active_player", {}))
	var social_player := _as_dictionary(social.get("player", {}))
	lines.append("Social server-authoritative")
	lines.append("Escopo: conta inteira | Save ativo: %s" % _social_save_badge_text(str(identity.get("viewer_badge", SessionStore.active_save_badge()))))
	lines.append("Identidade social: %s" % _social_username_text(social_player))
	var guild := _as_dictionary(social.get("guild", {}))
	if guild.is_empty():
		lines.append("Guilda: nenhuma")
	else:
		lines.append("Guilda: %s L%s" % [str(guild.get("name", "")), str(guild.get("level", 1))])
		lines.append("Membros: %d" % _as_array(social.get("guild_members", [])).size())
		lines.append("Estruturas de guilda: %d" % _as_array(social.get("guild_structures", [])).size())
	var friends := _as_array(social.get("friends", []))
	lines.append("Amigos: %d" % friends.size())
	var messages := _as_array(social.get("guild_chat", []))
	lines.append("Chat guilda: %d mensagens recentes" % messages.size())
	for item: Variant in messages.slice(0, min(messages.size(), 4)):
		var message := _as_dictionary(item)
		if not message.is_empty():
			lines.append("- %s: %s" % [
				str(message.get("sender_username", "desconhecido")),
				str(message.get("content", "")),
			])
	timeline_label.text = "\n".join(lines)
	if social_state_container != null:
		social_state_container.add_child(_social_identity_panel(host, identity, social_player, active_player))
		social_state_container.add_child(_social_friends_panel(host, friends))
		social_state_container.add_child(_social_guild_panel(host, guild, _as_array(social.get("guild_members", [])), _as_array(social.get("guild_structures", []))))
		social_state_container.add_child(_social_chat_panel(host, messages))

static func _social_identity_panel(host: Node, identity: Dictionary, social_player: Dictionary, active_player: Dictionary) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Identidade Social", "text_primary", 17))
	box.add_child(_base_label(host, "Username social: %s" % _social_username_text(social_player), "text_secondary"))
	box.add_child(_base_label(host, "Save ativo: %s" % _social_username_text(active_player), "text_secondary"))
	var badge := str(identity.get("viewer_badge", SessionStore.active_save_badge()))
	var badge_label := _base_label(host, "Marcador visivel: %s" % _social_save_badge_text(badge), "status_error" if badge == "lab" else "status_success")
	box.add_child(badge_label)
	if bool(identity.get("fallback_to_active_save", false)):
		box.add_child(_base_label(host, "Aviso: save Normal ainda nao existe; o social esta usando o save ativo como fallback.", "status_warning"))
	return panel

static func _social_friends_panel(host: Node, friends: Array) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Amigos (%d)" % friends.size(), "text_primary", 17))
	if friends.is_empty():
		box.add_child(_base_label(host, "Nenhum amigo ainda. Use o username do outro jogador para adicionar.", "text_secondary"))
		return panel
	for item: Variant in friends:
		var friendship := _as_dictionary(item)
		var profile := _as_dictionary(friendship.get("friend", {}))
		box.add_child(_base_label(host, "%s | %s | L%s | Poder %s" % [
			_social_username_text(profile),
			str(friendship.get("status", "accepted")),
			str(profile.get("level", 1)),
			str(profile.get("power", 0)),
		], "status_error" if str(profile.get("save_badge", "")) == "lab" else "text_secondary"))
	return panel

static func _social_guild_panel(host: Node, guild: Dictionary, members: Array, structures: Array) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Guilda", "text_primary", 17))
	if guild.is_empty():
		box.add_child(_base_label(host, "Sem guilda. Crie uma guilda ou entre pelo nome.", "text_secondary"))
		return panel
	box.add_child(_base_label(host, "%s | Level %s | %d membros" % [
		str(guild.get("name", "")),
		str(guild.get("level", 1)),
		members.size(),
	], "text_secondary"))
	box.add_child(_base_label(host, "Membros", "text_primary"))
	for item: Variant in members:
		var member := _as_dictionary(item)
		var profile := _as_dictionary(member.get("player", {}))
		var badge := str(profile.get("save_badge", "normal"))
		box.add_child(_base_label(host, "%s | %s | L%s | Poder %s" % [
			_social_username_text(profile),
			str(member.get("role", "member")),
			str(profile.get("level", 1)),
			str(profile.get("power", 0)),
		], "status_error" if badge == "lab" else "text_secondary"))
	box.add_child(_base_label(host, "Estruturas", "text_primary"))
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		box.add_child(_base_label(host, "%s L%s" % [
			_guild_structure_label(str(structure.get("structure_id", ""))),
			str(structure.get("level", 1)),
		], "text_secondary"))
	return panel

static func _social_chat_panel(host: Node, messages: Array) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Chat de Guilda (%d recentes)" % messages.size(), "text_primary", 17))
	if messages.is_empty():
		box.add_child(_base_label(host, "Sem mensagens recentes. Entre em uma guilda e envie a primeira mensagem.", "text_secondary"))
		return panel
	for item: Variant in messages:
		var message := _as_dictionary(item)
		var badge := str(message.get("sender_save_badge", "normal"))
		var sender_label := str(message.get("sender_username", "desconhecido"))
		if badge == "lab":
			sender_label += " [lab]"
		box.add_child(_base_label(host, "%s: %s" % [
			sender_label,
			str(message.get("content", "")),
		], "status_error" if badge == "lab" else "text_secondary"))
	return panel

static func _social_username_text(profile: Dictionary) -> String:
	var username := str(profile.get("username", "")).strip_edges()
	if username == "":
		username = "sem username"
	var badge := str(profile.get("save_badge", "normal"))
	if badge == "lab":
		return "%s [lab]" % username
	return username

static func _social_save_badge_text(badge: String) -> String:
	if badge == "lab":
		return "lab"
	return "normal"

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

static func _base_info_panel(host: Node, title: String, body: String) -> Control:
	return host.call("_base_info_panel", title, body) as Control

static func _base_label(host: Node, text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	return host.call("_base_label", text, color_token, font_size) as Label

static func _add_body_text(host: Node, text: String) -> Label:
	return host.call("_add_body_text", text) as Label

static func _add_output_label(host: Node, text: String) -> Label:
	return host.call("_add_output_label", text) as Label

static func _add_action_button(host: Node, text: String, action_id: String, confirm_message: String = "") -> Button:
	return host.call("_add_action_button", text, action_id, confirm_message) as Button

static func _add_social_input(host: Node, label_text: String, placeholder: String, initial_text: String, input_tooltip: String) -> LineEdit:
	return host.call("_add_social_input", label_text, placeholder, initial_text, input_tooltip) as LineEdit
