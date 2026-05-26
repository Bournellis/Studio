extends Control

const ProjectInfoScript := preload("res://core/project_info.gd")
const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const BattleVisualMockupScript := preload("res://ui/battle_visual_mockup.gd")
const SessionStoreScript := preload("res://online/session_store.gd")

const SCREEN_HUB := "hub"
const SCREEN_BATTLE := "battle"
const SCREEN_BASE := "base"
const SCREEN_SOCIAL := "social"
const SCREEN_COMPETITION := "competition"
const SCREEN_SHOP := "shop"
const BATTLE_LAB_SCREEN_PATH := "res://dev/battle_lab/battle_lab_screen.gd"
const PROGRESSION_LAB_SCREEN_PATH := "res://dev/progression_lab/progression_lab_screen.gd"
const BATTLE_REPLAY_TICK_SECONDS := 0.05

const RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]
const BASE_STRUCTURE_IDS := ["altar_das_almas", "nucleo_energia", "pocos_sangue", "minas_cristal", "estrutura_stats", "ossario"]
const ALPHA_ENERGY_PACK_PRODUCT_ID := "alpha_energy_pack_small"

var _status_label: Label
var _detail_label: Label
var _error_label: Label
var _back_button: Button
var _content_title: Label
var _content_body: VBoxContainer
var _timeline_label: Label
var _base_state_container: VBoxContainer
var _social_state_container: VBoxContainer
var _social_friend_input: LineEdit
var _social_guild_input: LineEdit
var _social_chat_input: LineEdit
var _battle_visual: Control
var _confirm_dialog: ConfirmationDialog

var _action_buttons: Dictionary = {}
var _nav_buttons: Dictionary = {}
var _screen_history: Array[String] = []
var _current_screen := SCREEN_HUB
var _pending_confirmation_action := ""
var _active_action_id := ""
var _is_busy := false
var _replay_running := false
var _skip_replay := false
var _battle_lab_overlay: Control
var _progression_lab_overlay: Control
var _selected_base_structure_id := "nucleo_energia"
var _last_social_friend_username := ""
var _last_social_guild_name := ""
var _last_social_chat_message := "Primeiro pulso do Conclave."

func _ready() -> void:
	_clear_existing_scene()
	_build_ui()
	SessionStore.session_changed.connect(_sync_status_from_session)
	var cache_loaded := SessionStore.load_cache()
	SessionStore.ensure_session_id()
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	if not cache_loaded:
		SessionStore.save_cache()
	_show_screen(SCREEN_HUB, false)
	_sync_status_from_session()
	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		call_deferred("_recover_session_state")

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _confirm_dialog != null and _confirm_dialog.visible:
		_confirm_dialog.hide()
		return
	if _battle_lab_overlay != null and is_instance_valid(_battle_lab_overlay):
		_close_battle_lab_overlay()
		return
	if _progression_lab_overlay != null and is_instance_valid(_progression_lab_overlay):
		_close_progression_lab_overlay()
		return
	if _replay_running:
		_skip_replay = true
		_show_notice("Replay pulando para o resumo final...")
		return
	if _current_screen != SCREEN_HUB:
		_go_back()

func _clear_existing_scene() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = UiTokens.color("bg_deep")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16
	root.offset_top = 12
	root.offset_right = -16
	root.offset_bottom = -12
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(header)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 8)
	header.add_child(header_box)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	header_box.add_child(title_row)

	var title_stack := VBoxContainer.new()
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_stack)

	var title := Label.new()
	title.text = "DraxosMobile"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title_stack.add_child(title)

	_status_label = Label.new()
	_status_label.text = "%s - primeiro slice" % ProjectInfoScript.PROJECT_NAME
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	title_stack.add_child(_status_label)

	_back_button = Button.new()
	_back_button.text = "Voltar"
	_back_button.custom_minimum_size = Vector2(110, 42)
	_back_button.pressed.connect(_go_back)
	title_row.add_child(_back_button)

	var nav := HBoxContainer.new()
	nav.add_theme_constant_override("separation", 6)
	header_box.add_child(nav)
	_add_nav_button(nav, "Refugio", SCREEN_HUB)
	_add_nav_button(nav, "Batalha", SCREEN_BATTLE)
	_add_nav_button(nav, "Base", SCREEN_BASE)
	_add_nav_button(nav, "Social", SCREEN_SOCIAL)
	_add_nav_button(nav, "Competicao", SCREEN_COMPETITION)
	_add_nav_button(nav, "Loja", SCREEN_SHOP)

	var content_panel := PanelContainer.new()
	content_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel_alt", "border_default"))
	content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(content_panel)

	var content_stack := VBoxContainer.new()
	content_stack.add_theme_constant_override("separation", 8)
	content_panel.add_child(content_stack)

	_content_title = Label.new()
	_content_title.add_theme_font_size_override("font_size", 22)
	_content_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	content_stack.add_child(_content_title)

	_detail_label = Label.new()
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	content_stack.add_child(_detail_label)

	_error_label = Label.new()
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.add_theme_color_override("font_color", UiTokens.color("status_error"))
	content_stack.add_child(_error_label)

	var separator := HSeparator.new()
	content_stack.add_child(separator)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_stack.add_child(scroll)

	_content_body = VBoxContainer.new()
	_content_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_theme_constant_override("separation", 10)
	scroll.add_child(_content_body)

	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Confirmar acao"
	_confirm_dialog.dialog_text = ""
	_confirm_dialog.confirmed.connect(_on_confirmation_confirmed)
	add_child(_confirm_dialog)
	_confirm_dialog.get_ok_button().text = "Confirmar"
	_confirm_dialog.get_cancel_button().text = "Voltar"

func _add_nav_button(nav: HBoxContainer, label: String, screen_id: String) -> void:
	var target_screen := screen_id
	var button := Button.new()
	button.text = label
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(120, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void:
		_show_screen(target_screen)
	)
	nav.add_child(button)
	_nav_buttons[screen_id] = button

func _show_screen(screen_id: String, push_history: bool = true) -> void:
	if push_history and screen_id != _current_screen:
		_screen_history.append(_current_screen)
	_current_screen = screen_id
	_action_buttons.clear()
	_timeline_label = null
	_base_state_container = null
	_social_state_container = null
	_social_friend_input = null
	_social_guild_input = null
	_social_chat_input = null
	_battle_visual = null
	_error_label.text = ""
	_clear_content_body()
	_content_title.text = _screen_title(screen_id)
	_back_button.visible = screen_id != SCREEN_HUB
	_sync_nav_buttons()

	match screen_id:
		SCREEN_HUB:
			_render_hub_screen()
		SCREEN_BATTLE:
			_render_battle_screen()
		SCREEN_BASE:
			_render_base_screen()
		SCREEN_SOCIAL:
			_render_social_screen()
		SCREEN_COMPETITION:
			_render_competition_screen()
		SCREEN_SHOP:
			_render_shop_screen()
		_:
			_render_hub_screen()

	_sync_status_from_session()
	_emit_client_event("screen_opened", {
		"screen": screen_id,
		"has_account": SessionStore.has_account_state(),
		"offline": SessionStore.offline,
	})

func _go_back() -> void:
	if _is_busy:
		return
	if _screen_history.is_empty():
		_show_screen(SCREEN_HUB, false)
		return
	var previous: String = _screen_history.pop_back()
	_show_screen(previous, false)

func _battle_lab_available() -> bool:
	if not OS.has_feature("editor"):
		return false
	if not bool(ProjectSettings.get_setting("draxos_mobile/battle_lab/enabled", false)):
		return false
	return ResourceLoader.exists(BATTLE_LAB_SCREEN_PATH)

func _open_battle_lab_overlay() -> void:
	if not _battle_lab_available():
		_error_label.text = "Battle Lab dev indisponivel neste ambiente."
		return
	if _battle_lab_overlay != null and is_instance_valid(_battle_lab_overlay):
		return
	var script: Script = load(BATTLE_LAB_SCREEN_PATH)
	if script == null or not script.can_instantiate():
		_error_label.text = "Battle Lab dev nao pode ser carregado."
		return
	var overlay: Control = script.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", Callable(self, "_close_battle_lab_overlay"))
	add_child(overlay)
	_battle_lab_overlay = overlay
	_emit_client_event("battle_lab_opened", {
		"screen": _current_screen,
	})

func _close_battle_lab_overlay() -> void:
	if _battle_lab_overlay == null or not is_instance_valid(_battle_lab_overlay):
		_battle_lab_overlay = null
		return
	_battle_lab_overlay.queue_free()
	_battle_lab_overlay = null
	_emit_client_event("battle_lab_closed", {
		"screen": _current_screen,
	})

func _progression_lab_available() -> bool:
	if not OS.has_feature("editor"):
		return false
	if not bool(ProjectSettings.get_setting("draxos_mobile/progression_lab/enabled", false)):
		return false
	return ResourceLoader.exists(PROGRESSION_LAB_SCREEN_PATH)

func _open_progression_lab_overlay() -> void:
	if not _progression_lab_available():
		_error_label.text = "Progression Lab dev indisponivel neste ambiente."
		return
	if _progression_lab_overlay != null and is_instance_valid(_progression_lab_overlay):
		return
	var script: Script = load(PROGRESSION_LAB_SCREEN_PATH)
	if script == null or not script.can_instantiate():
		_error_label.text = "Progression Lab dev nao pode ser carregado."
		return
	var overlay: Control = script.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", Callable(self, "_close_progression_lab_overlay"))
	add_child(overlay)
	_progression_lab_overlay = overlay
	_emit_client_event("progression_lab_opened", {
		"screen": _current_screen,
	})

func _close_progression_lab_overlay() -> void:
	if _progression_lab_overlay == null or not is_instance_valid(_progression_lab_overlay):
		_progression_lab_overlay = null
		return
	_progression_lab_overlay.queue_free()
	_progression_lab_overlay = null
	_emit_client_event("progression_lab_closed", {
		"screen": _current_screen,
	})

func _clear_content_body() -> void:
	for child: Node in _content_body.get_children():
		_content_body.remove_child(child)
		child.queue_free()

func _clear_node_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func _render_hub_screen() -> void:
	_add_section_label("Alpha PC local")
	_add_body_text("Track 01 endurece o playtest local: sessao recuperavel, reset seguro de cache, erros claros e telemetria nao autoritativa.")
	_add_action_button("Entrar como guest", "enter_guest")
	_add_action_button("Sincronizar sessao", "refresh_session")
	_add_action_button("Resetar sessao local", "reset_session", "Limpar apenas token/cache local desta maquina? O estado salvo no servidor nao sera apagado.")
	if _battle_lab_available():
		_add_action_button("Battle Lab Dev", "open_battle_lab")
	if _progression_lab_available():
		_add_action_button("Progression Lab Dev", "open_progression_lab")

	_add_section_label("Save ativo")
	_add_body_text("O save Normal executa o loop server-authoritative local. O save Progression Lab fica isolado para testes e nao deve pontuar ranking/social.")
	_add_action_button("Usar save normal", "select_save_normal")
	_add_action_button("Usar save Progression Lab", "select_save_progression_lab")
	_add_action_button(
		"Resetar save ativo",
		"reset_active_save",
		"Resetar apenas o save %s no servidor? O outro save e a sessao local serao preservados." % SessionStore.active_save_label()
	)
	_add_output_label("Save atual: %s (%s)" % [
		SessionStore.active_save_label(),
		SessionStore.active_save_badge(),
	])

	var account := "Conta: nao iniciada"
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		account = "Progression Lab local: %s | Level %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player.get("level", 1)),
			str(SessionStore.player.get("power", 0)),
		]
	elif SessionStore.has_account_state():
		account = "Conta: %s | Level %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player.get("level", 1)),
			str(SessionStore.player.get("power", 0)),
		]
	elif SessionStore.has_valid_access_token():
		account = "Conta: sessao anonima criada; falta recuperar/criar guest."
	_add_output_label(account)
	_add_output_label("Sessao local: %s | Offline: %s" % [
		SessionStore.ensure_session_id(),
		str(SessionStore.offline),
	])

	_add_section_label("Telas")
	_add_screen_button("Abrir Batalha", SCREEN_BATTLE)
	_add_screen_button("Abrir Base", SCREEN_BASE)
	_add_screen_button("Abrir Social", SCREEN_SOCIAL)
	_add_screen_button("Abrir Competicao", SCREEN_COMPETITION)
	_add_screen_button("Abrir Loja", SCREEN_SHOP)

func _render_battle_screen() -> void:
	_add_body_text("Batalha server-authoritative: o cliente solicita a luta, recebe o log e apenas apresenta o replay.")
	_add_action_button("Solicitar batalha", "request_battle")
	_add_action_button("Ver resultado", "show_latest_battle")
	_battle_visual = BattleVisualMockupScript.new()
	_battle_visual.custom_minimum_size = Vector2(0, 720)
	_content_body.add_child(_battle_visual)
	_timeline_label = _add_output_label("")
	if SessionStore.has_battle_log():
		_battle_visual.load_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)
		_battle_visual.reveal_all()
		_timeline_label.text = _battle_visual.get_timeline_text()
	else:
		_battle_visual.show_empty_state("Nenhuma batalha carregada. Solicite uma batalha ou busque o ultimo resultado.")
		_timeline_label.text = "Nenhuma batalha carregada. Solicite uma batalha ou busque o ultimo resultado."

func _render_base_screen() -> void:
	_add_body_text("Base do Refugio: predios permanentes, coleta offline e uma fila de construcao server-authoritative.")
	_add_action_button("Atualizar base", "show_base")
	_add_action_button("Coletar producao", "collect_base", "Coletar a producao offline acumulada da base?")
	_add_action_button("Comprar Energia alpha", "buy_energy_pack_alpha", "Gastar 80 Diamantes para comprar 80 Energia no save ativo?")
	_timeline_label = _add_output_label("")
	_base_state_container = VBoxContainer.new()
	_base_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_base_state_container.add_theme_constant_override("separation", 10)
	_content_body.add_child(_base_state_container)
	_render_base_state()

func _render_social_screen() -> void:
	_add_body_text("Social alpha da conta: encontre outro jogador por username, crie ou entre em uma guilda e teste chat de guilda por polling.")
	var refresh_social_button := _add_action_button("Atualizar social", "show_social")
	refresh_social_button.tooltip_text = "Busca amigos, guilda, membros, estruturas e mensagens recentes no servidor."
	_social_friend_input = _add_social_input(
		"Amigo por username",
		"guest_12345678",
		_last_social_friend_username,
		"Digite o username do outro jogador. No alpha a amizade e aceita automaticamente."
	)
	var add_friend_button := _add_action_button("Adicionar amigo", "add_friend")
	add_friend_button.tooltip_text = "Cria amizade aceita nos dois sentidos, usando o username informado."
	_social_guild_input = _add_social_input(
		"Guilda",
		_default_guild_name(),
		_default_social_guild_text(),
		"Digite o nome da guilda para criar ou entrar. O nome precisa ter 3 a 32 caracteres."
	)
	var create_guild_button := _add_action_button("Criar guilda", "create_guild", "Criar uma guilda alpha para esta conta?")
	create_guild_button.tooltip_text = "Cria uma guilda, adiciona voce como owner e inicializa estruturas e canal de chat."
	var join_guild_button := _add_action_button("Entrar guilda", "join_guild")
	join_guild_button.tooltip_text = "Entra na guilda pelo nome exato. Voce so pode participar de uma guilda por vez."
	_social_chat_input = _add_social_input(
		"Mensagem de guilda",
		"Mensagem curta para o chat",
		_last_social_chat_message,
		"Mensagem enviada para o canal da guilda. O alpha aplica rate limit simples para evitar spam."
	)
	var send_chat_button := _add_action_button("Enviar chat guilda", "send_guild_chat")
	send_chat_button.tooltip_text = "Envia a mensagem digitada e atualiza o polling do chat."
	_timeline_label = _add_output_label("")
	_social_state_container = VBoxContainer.new()
	_social_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_social_state_container.add_theme_constant_override("separation", 10)
	_content_body.add_child(_social_state_container)
	_render_social_state()

func _render_competition_screen() -> void:
	_add_body_text("Competicao v0 com preview de matchmaking por poder e ranking da season sem bots.")
	_add_action_button("Preview matchmaking", "show_matchmaking")
	_add_action_button("Ver ranking", "show_ranking")
	_timeline_label = _add_output_label("")
	_render_competition_state()

func _render_shop_screen() -> void:
	_add_body_text("Loja alpha funcional: Battle Pass, Diamante, premium alpha e claims idempotentes.")
	_add_action_button("Atualizar loja", "show_shop")
	_add_action_button("Comprar premium alpha", "buy_premium_alpha", "Liberar Premium Battle Pass Alpha nesta conta de teste?")
	_add_action_button("Receber Diamante", "grant_diamond_alpha", "Creditar 500 Diamantes alpha nesta conta de teste?")
	_add_action_button("Claim diario", "claim_daily_reward", "Resgatar a recompensa diaria de coleta da base?")
	_timeline_label = _add_output_label("")
	_render_monetization_state()

func _add_section_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	_content_body.add_child(label)
	return label

func _add_body_text(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(label)
	return label

func _add_output_label(text: String) -> Label:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(panel)

	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(label)
	return label

func _add_action_button(text: String, action_id: String, confirm_message: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void:
		_trigger_action(action_id, confirm_message)
	)
	_content_body.add_child(button)
	_action_buttons[action_id] = button
	return button

func _add_social_input(label_text: String, placeholder: String, initial_text: String, tooltip_text: String) -> LineEdit:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(box)

	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	box.add_child(label)

	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.text = initial_text
	input.tooltip_text = tooltip_text
	input.custom_minimum_size = Vector2(260, 40)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(input)
	return input

func _add_screen_button(text: String, screen_id: String) -> Button:
	var target_screen := screen_id
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void:
		_show_screen(target_screen)
	)
	_content_body.add_child(button)
	return button

func _trigger_action(action_id: String, confirm_message: String = "") -> void:
	if _is_busy:
		return
	if confirm_message != "":
		_pending_confirmation_action = action_id
		_confirm_dialog.dialog_text = confirm_message
		_confirm_dialog.popup_centered()
		return
	await _execute_action(action_id)

func _on_confirmation_confirmed() -> void:
	var action_id := _pending_confirmation_action
	_pending_confirmation_action = ""
	if action_id == "":
		return
	await _execute_action(action_id)

func _execute_action(action_id: String) -> void:
	_active_action_id = action_id
	_error_label.text = ""
	_emit_client_event("action_start", _action_payload(action_id))
	if action_id.begins_with("select_base_structure:"):
		_select_base_structure(action_id.get_slice(":", 1))
	elif action_id.begins_with("upgrade_base_structure:"):
		await _upgrade_base_structure(action_id.get_slice(":", 1))
	else:
		match action_id:
			"enter_guest":
				await _enter_guest()
			"refresh_session":
				await _refresh_session()
			"reset_session":
				await _reset_local_session()
			"reset_active_save":
				await _reset_active_save()
			"select_save_normal":
				_select_save(SessionStoreScript.SAVE_TYPE_NORMAL)
			"select_save_progression_lab":
				_select_save(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB)
			"open_battle_lab":
				_open_battle_lab_overlay()
			"open_progression_lab":
				_open_progression_lab_overlay()
			"request_battle":
				await _request_battle()
			"show_latest_battle":
				if _replay_running:
					_skip_replay = true
					return
				await _show_latest_battle()
			"show_base":
				await _show_base()
			"collect_base":
				await _collect_base()
			"buy_energy_pack_alpha":
				await _buy_energy_pack_alpha()
			"upgrade_nucleo":
				await _upgrade_base_structure("nucleo_energia")
			"show_social":
				await _show_social()
			"add_friend":
				await _add_friend()
			"create_guild":
				await _create_guild()
			"join_guild":
				await _join_guild()
			"send_guild_chat":
				await _send_guild_chat()
			"show_matchmaking":
				await _show_matchmaking()
			"show_ranking":
				await _show_ranking()
			"show_shop":
				await _show_shop()
			"buy_premium_alpha":
				await _buy_premium_alpha()
			"grant_diamond_alpha":
				await _grant_diamond_alpha()
			"claim_daily_reward":
				await _claim_daily_reward()
	if _active_action_id == action_id:
		var event_type := "action_failure" if _error_label.text != "" else "action_success"
		var payload := _action_payload(action_id)
		if _error_label.text != "":
			payload["error_text"] = _error_label.text
		_emit_client_event(event_type, payload)
	_active_action_id = ""

func _enter_guest() -> void:
	_set_busy(true, "Criando sessao guest...")
	var auth_result: Dictionary = {"ok": true}
	if not SessionStore.has_valid_access_token() or SessionStore.is_progression_lab_local_only():
		auth_result = await SupabaseClient.sign_in_anonymously()
		if not bool(auth_result.get("ok", false)):
			_fail_with_error(auth_result)
			return
		SessionStore.apply_auth_session(_as_dictionary(auth_result.get("session", {})))
		SessionStore.save_cache()

	var request_id := SessionStore.ensure_guest_request_id()
	var guest_result: Dictionary = await SupabaseClient.create_guest_account(
		SessionStore.DEFAULT_INVITE_CODE,
		request_id,
		OS.get_name(),
		SessionStore.access_token
	)
	if not bool(guest_result.get("ok", false)):
		_fail_with_error(guest_result)
		return

	SessionStore.apply_server_state(guest_result)
	var recovered := await _recover_session_state()
	if not recovered:
		return
	_show_notice("Sessao guest pronta. Todas as abas do alpha estao disponiveis.")
	_show_screen(SCREEN_HUB, false)

func _refresh_session() -> void:
	if not _require_session("Crie uma sessao guest antes de sincronizar."):
		return
	var recovered := await _recover_session_state()
	if recovered:
		_show_screen(_current_screen, false)

func _reset_local_session() -> void:
	var previous_player_id := str(SessionStore.player.get("id", ""))
	var previous_session_id := SessionStore.ensure_session_id()
	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		await SupabaseClient.send_client_telemetry(
			SessionStore.access_token,
			previous_session_id,
			"local_session_reset",
			{
				"player_id": previous_player_id,
				"screen": _current_screen,
			}
		)
	SessionStore.clear_session()
	SessionStore.save_cache()
	_screen_history.clear()
	_set_busy(false, "Cache local limpo. Entre como guest para recuperar ou criar uma sessao de teste.")
	_show_screen(SCREEN_HUB, false)

func _reset_active_save() -> void:
	if not _require_account("Crie uma sessao guest antes de resetar o save ativo."):
		return
	_set_busy(true, "Resetando save %s..." % SessionStore.active_save_label())
	var reset_result: Dictionary = await SupabaseClient.reset_active_save(
		SessionStore.create_request_id(),
		SessionStore.access_token
	)
	if not bool(reset_result.get("ok", false)):
		_fail_with_error(reset_result)
		return
	if not SessionStore.apply_save_reset(reset_result):
		_fail_with_error({
			"ok": false,
			"error": SessionStore.last_error,
		})
		return
	SessionStore.save_cache()
	_screen_history.clear()
	_set_busy(false, "Save %s resetado. O outro save foi preservado." % SessionStore.active_save_label())
	_show_screen(SCREEN_HUB, false)

func _select_save(save_type: String) -> void:
	var changed := SessionStore.set_active_save_type(save_type)
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	if changed:
		_screen_history.clear()
		var message := "Save ativo alterado para %s." % SessionStore.active_save_label()
		if SessionStore.is_progression_lab_active():
			message = "Save Progression Lab selecionado. As acoes usam um player isolado no Supabase local."
		_set_busy(false, message)
	else:
		_set_busy(false, "Save %s ja estava ativo." % SessionStore.active_save_label())
	_show_screen(SCREEN_HUB, false)

func _recover_session_state() -> bool:
	if SessionStore.is_progression_lab_local_only():
		_sync_status_from_session()
		return false
	if not SessionStore.has_valid_access_token():
		_sync_status_from_session()
		return false

	_set_busy(true, "Recuperando estado do servidor...")
	var state_result: Dictionary = await SupabaseClient.fetch_account_state(SessionStore.access_token)
	if not bool(state_result.get("ok", false)):
		_fail_with_error(state_result)
		return false

	SessionStore.apply_server_state(state_result)
	SessionStore.save_cache()
	_set_busy(false, "Sessao sincronizada com o servidor.")
	_sync_status_from_session()
	return true

func _request_battle() -> void:
	if not _require_account("Crie uma sessao guest antes de solicitar batalha."):
		return

	_show_screen(SCREEN_BATTLE, false)
	_set_busy(true, "Solicitando batalha...")
	var battle_result: Dictionary = await SupabaseClient.request_battle(
		SessionStoreScript.create_request_id(),
		SessionStore.access_token,
		ProjectInfoScript.DEFAULT_BATTLE_MODE
	)
	if not bool(battle_result.get("ok", false)):
		_fail_with_error(battle_result)
		return

	if not SessionStore.apply_battle_result(battle_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	var recovered := await _recover_session_state()
	if not recovered:
		return
	await _play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func _show_latest_battle() -> void:
	if not _require_session("Crie uma sessao guest antes de ver resultado."):
		return

	_show_screen(SCREEN_BATTLE, false)
	_set_busy(true, "Buscando ultimo resultado...")
	var latest_result: Dictionary = await SupabaseClient.fetch_latest_battle(SessionStore.access_token)
	if not bool(latest_result.get("ok", false)):
		_fail_with_error(latest_result)
		return

	var body := _as_dictionary(latest_result.get("body", {}))
	if body.get("battle_log", null) == null:
		_set_busy(false, "Nenhuma batalha registrada.")
		_timeline_label.text = "Solicite uma batalha para gerar o primeiro replay."
		return

	if not SessionStore.apply_battle_result(latest_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Ultimo resultado recuperado.")
	await _play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func _show_base() -> void:
	if SessionStore.is_progression_lab_local_only():
		_show_screen(SCREEN_BASE, false)
		_set_busy(false, "Snapshot local do Progression Lab carregado. Base em modo somente leitura; coletas e upgrades precisam de save seeded no Supabase local.")
		_render_base_state()
		return
	if not _require_session("Crie uma sessao guest antes de abrir a base."):
		return

	_show_screen(SCREEN_BASE, false)
	_set_busy(true, "Buscando Refugio...")
	var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
	if not bool(base_result.get("ok", false)):
		_fail_with_error(base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Refugio recuperado.")
	_render_base_state()

func _collect_base() -> void:
	if not _require_account("Crie uma sessao guest antes de coletar a base."):
		return

	_show_screen(SCREEN_BASE, false)
	_set_busy(true, "Coletando producao offline...")
	var base_result: Dictionary = await SupabaseClient.collect_base(
		SessionStoreScript.create_request_id(),
		SessionStore.access_token
	)
	if not bool(base_result.get("ok", false)):
		_fail_with_error(base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	var body := _as_dictionary(base_result.get("body", {}))
	var collected := _as_dictionary(body.get("collected", {}))
	var message := "Coleta registrada no servidor."
	if _resource_total(collected) <= 0.0:
		message = "Nada para coletar agora."
	SessionStore.save_cache()
	_set_busy(false, message)
	_render_base_state(collected)

func _buy_energy_pack_alpha() -> void:
	if not _require_account("Crie uma sessao guest antes de comprar Energia alpha."):
		return

	_show_screen(SCREEN_BASE, false)
	_set_busy(true, "Comprando pacote de Energia alpha...")
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		SessionStoreScript.create_request_id(),
		ALPHA_ENERGY_PACK_PRODUCT_ID,
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return

	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
	if bool(base_result.get("ok", false)):
		SessionStore.apply_base_result(base_result)

	SessionStore.save_cache()
	_set_busy(false, "Energia alpha comprada. A Base foi atualizada com o novo saldo.")
	_render_base_state()

func _upgrade_base_structure(structure_id: String) -> void:
	if not _require_account("Crie uma sessao guest antes de evoluir a base."):
		return
	var target_structure_id := structure_id.strip_edges()
	if target_structure_id == "":
		target_structure_id = _selected_base_structure_id
	_selected_base_structure_id = target_structure_id

	_show_screen(SCREEN_BASE, false)
	_set_busy(true, "Solicitando evolucao de %s..." % _structure_label(target_structure_id))
	var base_result: Dictionary = await SupabaseClient.upgrade_base_structure(
		SessionStoreScript.create_request_id(),
		target_structure_id,
		SessionStore.access_token
	)
	if not bool(base_result.get("ok", false)):
		_fail_with_error(base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Evolucao de %s iniciada no servidor." % _structure_label(target_structure_id))
	_render_base_state()

func _show_social() -> void:
	if not _require_session("Crie uma sessao guest antes de abrir Social."):
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Buscando Social...")
	var social_result: Dictionary = await SupabaseClient.fetch_social_state(SessionStore.access_token)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Social recuperado.")
	_render_social_state()

func _add_friend() -> void:
	if not _require_account("Crie uma sessao guest antes de adicionar amigo."):
		return

	_last_social_friend_username = _social_input_text(_social_friend_input)
	if _last_social_friend_username == "":
		_error_label.text = "Informe o username do amigo."
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Adicionando amigo...")
	var social_result: Dictionary = await SupabaseClient.add_friend(
		SessionStoreScript.create_request_id(),
		_last_social_friend_username,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Amigo adicionado.")
	_render_social_state()

func _create_guild() -> void:
	if not _require_account("Crie uma sessao guest antes de criar guilda."):
		return

	_last_social_guild_name = _social_input_text(_social_guild_input, _default_guild_name())
	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Criando guilda alpha...")
	var social_result: Dictionary = await SupabaseClient.create_guild(
		SessionStoreScript.create_request_id(),
		_last_social_guild_name,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Guilda criada no servidor.")
	_render_social_state()

func _join_guild() -> void:
	if not _require_account("Crie uma sessao guest antes de entrar em guilda."):
		return

	_last_social_guild_name = _social_input_text(_social_guild_input)
	if _last_social_guild_name == "":
		_error_label.text = "Informe o nome da guilda."
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Entrando na guilda...")
	var social_result: Dictionary = await SupabaseClient.join_guild(
		SessionStoreScript.create_request_id(),
		_last_social_guild_name,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Guilda sincronizada.")
	_render_social_state()

func _send_guild_chat() -> void:
	if not _require_account("Crie uma sessao guest antes de usar chat."):
		return

	_last_social_chat_message = _social_input_text(_social_chat_input, _last_social_chat_message)
	if _last_social_chat_message == "":
		_error_label.text = "Digite uma mensagem para o chat da guilda."
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Enviando mensagem de guilda...")
	var social_result: Dictionary = await SupabaseClient.send_guild_chat(
		SessionStoreScript.create_request_id(),
		_last_social_chat_message,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		_fail_with_error(social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Mensagem registrada no servidor.")
	_render_social_state()

func _show_matchmaking() -> void:
	if not _require_session("Crie uma sessao guest antes de abrir matchmaking."):
		return

	_show_screen(SCREEN_COMPETITION, false)
	_set_busy(true, "Buscando matchmaking...")
	var competition_result: Dictionary = await SupabaseClient.fetch_matchmaking_preview(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		_fail_with_error(competition_result)
		return
	if not SessionStore.apply_competition_result(competition_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Matchmaking recuperado.")
	_render_competition_state()

func _show_ranking() -> void:
	if not _require_session("Crie uma sessao guest antes de abrir ranking."):
		return

	_show_screen(SCREEN_COMPETITION, false)
	_set_busy(true, "Buscando ranking...")
	var competition_result: Dictionary = await SupabaseClient.fetch_ranking_current(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		_fail_with_error(competition_result)
		return
	if not SessionStore.apply_competition_result(competition_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Ranking recuperado.")
	_render_competition_state()

func _show_shop() -> void:
	if not _require_session("Crie uma sessao guest antes de abrir Loja."):
		return

	_show_screen(SCREEN_SHOP, false)
	_set_busy(true, "Buscando loja alpha...")
	var monetization_result: Dictionary = await SupabaseClient.fetch_monetization_state(SessionStore.access_token)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Loja alpha recuperada.")
	_render_monetization_state()

func _buy_premium_alpha() -> void:
	if not _require_account("Crie uma sessao guest antes de comprar premium alpha."):
		return

	_show_screen(SCREEN_SHOP, false)
	_set_busy(true, "Liberando premium alpha...")
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		SessionStoreScript.create_request_id(),
		"alpha_battle_pass_premium",
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Premium alpha liberado.")
	_render_monetization_state()

func _grant_diamond_alpha() -> void:
	if not _require_account("Crie uma sessao guest antes de receber Diamante."):
		return

	_show_screen(SCREEN_SHOP, false)
	_set_busy(true, "Registrando compra alpha de Diamante...")
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		SessionStoreScript.create_request_id(),
		"alpha_diamante_500",
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Diamante alpha creditado.")
	_render_monetization_state()

func _claim_daily_reward() -> void:
	if not _require_account("Crie uma sessao guest antes de resgatar recompensa diaria."):
		return

	_show_screen(SCREEN_SHOP, false)
	_set_busy(true, "Resgatando recompensa diaria...")
	var monetization_result: Dictionary = await SupabaseClient.claim_reward(
		SessionStoreScript.create_request_id(),
		"daily_collect_base",
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_with_error(monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	var body := _as_dictionary(monetization_result.get("body", {}))
	var message := "Recompensa diaria registrada no servidor."
	if bool(body.get("already_claimed", false)):
		message = "Recompensa diaria ja havia sido resgatada."
	SessionStore.save_cache()
	_set_busy(false, message)
	_render_monetization_state()

func _set_busy(is_busy: bool, message: String) -> void:
	_is_busy = is_busy
	if is_busy:
		_status_label.text = message
		_detail_label.text = "Aguardando resposta do servidor..."
		_error_label.text = ""
	else:
		_status_label.text = _session_status_text()
		_detail_label.text = message
	_sync_buttons()

func _show_notice(message: String) -> void:
	if _detail_label != null:
		_detail_label.text = message

func _fail_with_error(result: Dictionary) -> void:
	var error_payload := _extract_error(result)
	var code := str(error_payload.get("code", "REQUEST_FAILED"))
	if _is_network_error(code):
		SessionStore.mark_offline(error_payload)
	else:
		SessionStore.offline = false
		SessionStore.last_error = error_payload
		SessionStore.session_changed.emit()
	_set_busy(false, "Acao nao concluida.")
	_error_label.text = _friendly_error_message(code, str(error_payload.get("message", "Falha na requisicao.")))
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

func _sync_status_from_session() -> void:
	if _status_label == null:
		return
	if not _is_busy and not _replay_running:
		_status_label.text = _session_status_text()
	_sync_buttons()

func _sync_buttons() -> void:
	for action_id: String in _action_buttons.keys():
		var button: Button = _action_buttons[action_id]
		if not is_instance_valid(button):
			continue
		button.disabled = _is_busy or (_replay_running and action_id != "show_latest_battle")
		if action_id == "select_save_normal":
			button.disabled = button.disabled or not SessionStore.is_progression_lab_active()
		elif action_id == "select_save_progression_lab":
			button.disabled = button.disabled or SessionStore.is_progression_lab_active()
		elif action_id.begins_with("upgrade_base_structure:"):
			button.disabled = button.disabled or not _can_upgrade_base_structure(action_id.get_slice(":", 1))
		if action_id == "show_latest_battle":
			button.text = "Pular replay" if _replay_running else "Ver resultado"
	for screen_id: String in _nav_buttons.keys():
		var nav_button: Button = _nav_buttons[screen_id]
		nav_button.disabled = _is_busy or _replay_running
	_back_button.disabled = _is_busy or _replay_running

func _sync_nav_buttons() -> void:
	for screen_id: String in _nav_buttons.keys():
		var button: Button = _nav_buttons[screen_id]
		button.button_pressed = screen_id == _current_screen

func _require_session(message: String) -> bool:
	if SessionStore.is_progression_lab_local_only():
		_error_label.text = "Save local-only do Progression Lab nao executa acoes online."
		_detail_label.text = "Use o seeder com Supabase local para testar batalha, coleta, upgrades e outras mutacoes server-authoritative."
		_emit_client_event("precondition_failed", {
			"action_id": _active_action_id,
			"screen": _current_screen,
			"reason": "progression_lab_local_only",
		})
		return false
	if SessionStore.has_valid_access_token():
		return true
	_error_label.text = message
	_detail_label.text = "Use Entrar como guest no Refugio."
	_emit_client_event("precondition_failed", {
		"action_id": _active_action_id,
		"screen": _current_screen,
		"reason": "missing_session",
	})
	return false

func _require_account(message: String) -> bool:
	if SessionStore.is_progression_lab_local_only():
		_error_label.text = "Save local-only do Progression Lab nao executa acoes online."
		_detail_label.text = "Para batalhas, coleta, upgrades e compras, rode o seeder com Supabase local e carregue o cache server-backed."
		_emit_client_event("precondition_failed", {
			"action_id": _active_action_id,
			"screen": _current_screen,
			"reason": "progression_lab_local_only",
		})
		return false
	if SessionStore.has_valid_access_token() and SessionStore.has_account_state():
		return true
	_error_label.text = message
	_detail_label.text = "Use Entrar como guest no Refugio."
	_emit_client_event("precondition_failed", {
		"action_id": _active_action_id,
		"screen": _current_screen,
		"reason": "missing_account",
	})
	return false

func _render_base_state(collected: Dictionary = {}) -> void:
	if _timeline_label == null:
		return
	var base := SessionStore.base_state
	if _base_state_container != null:
		_clear_node_children(_base_state_container)
	if base.is_empty():
		_timeline_label.text = "Base ainda nao carregada. Use Atualizar base."
		if _base_state_container != null:
			_base_state_container.add_child(_base_info_panel(
				"Base nao carregada",
				"Use Atualizar base para buscar os predios, a fila de construcao e os recursos no servidor."
			))
		return

	var resources := SessionStore.resources
	var lines := PackedStringArray()
	if SessionStore.is_progression_lab_local_only():
		lines.append("Refugio Progression Lab local (somente leitura)")
		lines.append("Acoes online exigem cache server-backed criado pelo seeder Supabase.")
	else:
		lines.append("Refugio server-authoritative")
	lines.append("Recursos: %s" % _format_resources(resources))
	if not collected.is_empty():
		if _resource_total(collected) <= 0.0:
			lines.append("Coleta: nada acumulado agora.")
		else:
			lines.append("Coletado: %s" % _format_resources(collected, false))

	var structures := _as_array(base.get("structures", []))
	if structures.is_empty():
		lines.append("Estruturas: nenhuma estrutura retornada pelo servidor.")
	else:
		lines.append("Estruturas: %d predios clicaveis no mapa abaixo." % structures.size())
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		if structure.is_empty():
			continue
		lines.append("- %s L%s | pendente %s/%s | %s" % [
			_structure_label(str(structure.get("structure_id", "")), str(structure.get("display_name", ""))),
			str(structure.get("level", 0)),
			_format_number(float(structure.get("pending_collectable", 0.0))),
			_format_number(float(structure.get("storage_cap", 0.0))),
			str(structure.get("blocked_message", "Upgrade bloqueado.")),
		])

	var jobs := _as_array(base.get("jobs", []))
	var active_jobs := 0
	for item: Variant in jobs:
		var job := _as_dictionary(item)
		if str(job.get("status", "")) == "active":
			active_jobs += 1
			lines.append("- Em construcao: %s -> L%s | resta %s" % [
				_structure_label(str(job.get("structure_id", ""))),
				str(job.get("target_level", "?")),
				_format_duration(int(job.get("remaining_seconds", 0))),
			])
	lines.append("Fila: %d/%d" % [active_jobs, int(base.get("construction_slots", 1))])
	_timeline_label.text = "\n".join(lines)
	_render_base_playable_panels(structures, base, collected)

func _render_base_playable_panels(structures: Array, base: Dictionary, collected: Dictionary) -> void:
	if _base_state_container == null:
		return
	_ensure_selected_base_structure(structures)
	_base_state_container.add_child(_base_summary_panel(base, collected))
	_base_state_container.add_child(_base_map_panel(structures))
	_base_state_container.add_child(_base_detail_panel(structures))

func _base_summary_panel(base: Dictionary, collected: Dictionary) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Resumo da Base", "text_primary", 17))
	box.add_child(_base_label("Recursos: %s" % _format_resources(SessionStore.resources), "text_secondary"))
	var active_jobs := _active_base_jobs(_as_array(base.get("jobs", [])))
	box.add_child(_base_label("Fila de construcao: %d/%d" % [
		active_jobs.size(),
		int(base.get("construction_slots", 1)),
	], "text_secondary"))
	if not collected.is_empty():
		var collect_text := "Coleta: nada acumulado agora."
		if _resource_total(collected) > 0.0:
			collect_text = "Coletado agora: %s" % _format_resources(collected, false)
		box.add_child(_base_label(collect_text, "status_success"))
	if SessionStore.is_progression_lab_active():
		box.add_child(_base_label("Progression Lab: base isolada do save normal.", "status_warning"))
	return panel

func _base_map_panel(structures: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label("Mapa da Base", "text_primary", 17))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for structure_id: String in BASE_STRUCTURE_IDS:
		var structure := _base_structure_by_id(structures, structure_id)
		if structure.is_empty():
			continue
		grid.add_child(_base_structure_button(structure))
	return panel

func _base_detail_panel(structures: Array) -> Control:
	var structure := _base_structure_by_id(structures, _selected_base_structure_id)
	if structure.is_empty() and not structures.is_empty():
		structure = _as_dictionary(structures[0])
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	if structure.is_empty():
		box.add_child(_base_label("Selecione um predio no mapa da Base.", "text_secondary"))
		return panel

	var structure_id := str(structure.get("structure_id", ""))
	var display_label := _structure_label(structure_id, str(structure.get("display_name", "")))
	box.add_child(_base_label("%s - Level %s/%s" % [
		display_label,
		str(structure.get("level", 0)),
		str(structure.get("max_level", 40)),
	], "text_primary", 18))
	box.add_child(_base_label(str(structure.get("description", "")), "text_secondary"))
	box.add_child(_base_label("Beneficio: %s" % _base_benefit_text(structure), "text_secondary"))
	box.add_child(_base_label("Producao pendente: %s" % _base_pending_text(structure), "text_secondary"))
	box.add_child(_base_label("Proximo upgrade: %s" % _base_upgrade_text(structure), "text_secondary"))
	box.add_child(_base_label("Status: %s" % str(structure.get("blocked_message", "")), _base_status_color_token(structure)))

	var action_id := "upgrade_base_structure:%s" % structure_id
	var upgrade_button := Button.new()
	upgrade_button.text = "Evoluir %s" % display_label
	upgrade_button.custom_minimum_size = Vector2(260, 44)
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.tooltip_text = _base_structure_tooltip(structure)
	upgrade_button.disabled = not _can_upgrade_base_structure(structure_id)
	upgrade_button.pressed.connect(func() -> void:
		_trigger_action(action_id, "Iniciar upgrade de %s no servidor?" % display_label)
	)
	box.add_child(upgrade_button)
	_action_buttons[action_id] = upgrade_button
	return panel

func _base_structure_button(structure: Dictionary) -> Button:
	var structure_id := str(structure.get("structure_id", ""))
	var selected := structure_id == _selected_base_structure_id
	var button := Button.new()
	button.text = "%s\n%s\nL%s -> %s\n%s" % [
		_base_structure_symbol(structure_id),
		_base_structure_short_label(structure_id),
		str(structure.get("level", 0)),
		_base_next_level_text(structure),
		_base_short_status(structure),
	]
	button.custom_minimum_size = Vector2(190, 112)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = _base_structure_tooltip(structure)
	button.add_theme_stylebox_override("normal", _base_structure_card_style(structure_id, selected))
	button.add_theme_stylebox_override("hover", _base_structure_card_style(structure_id, true))
	button.add_theme_stylebox_override("pressed", _base_structure_card_style(structure_id, true))
	var action_id := "select_base_structure:%s" % structure_id
	button.pressed.connect(func() -> void:
		_trigger_action(action_id)
	)
	_action_buttons[action_id] = button
	return button

func _select_base_structure(structure_id: String) -> void:
	if structure_id.strip_edges() == "":
		return
	_selected_base_structure_id = structure_id.strip_edges()
	_render_base_state()

func _ensure_selected_base_structure(structures: Array) -> void:
	if not _base_structure_by_id(structures, _selected_base_structure_id).is_empty():
		return
	for structure_id: String in BASE_STRUCTURE_IDS:
		if not _base_structure_by_id(structures, structure_id).is_empty():
			_selected_base_structure_id = structure_id
			return
	if not structures.is_empty():
		_selected_base_structure_id = str(_as_dictionary(structures[0]).get("structure_id", _selected_base_structure_id))

func _base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		if str(structure.get("structure_id", "")) == structure_id:
			return structure
	return {}

func _base_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return panel

func _base_info_panel(title_text: String, body_text: String) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(title_text, "text_primary", 17))
	box.add_child(_base_label(body_text, "text_secondary"))
	return panel

func _base_label(text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _base_structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _base_structure_color(structure_id).darkened(0.25 if selected else 0.45)
	style.border_color = UiTokens.color("status_success") if selected else UiTokens.color("border_default")
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _base_structure_color(structure_id: String) -> Color:
	match structure_id:
		"altar_das_almas":
			return Color(0.45, 0.35, 0.78)
		"nucleo_energia":
			return Color(0.25, 0.58, 0.86)
		"pocos_sangue":
			return Color(0.70, 0.20, 0.26)
		"minas_cristal":
			return Color(0.22, 0.66, 0.62)
		"estrutura_stats":
			return Color(0.58, 0.58, 0.50)
		"ossario":
			return Color(0.72, 0.66, 0.54)
	return UiTokens.color("bg_panel_alt")

func _base_structure_symbol(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "[ALM]"
		"nucleo_energia":
			return "[ENE]"
		"pocos_sangue":
			return "[SAN]"
		"minas_cristal":
			return "[CRI]"
		"estrutura_stats":
			return "[STA]"
		"ossario":
			return "[OSS]"
	return "[???]"

func _base_structure_short_label(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "Altar"
		"nucleo_energia":
			return "Nucleo"
		"pocos_sangue":
			return "Pocos"
		"minas_cristal":
			return "Minas"
		"estrutura_stats":
			return "Stats"
		"ossario":
			return "Ossario"
	return structure_id

func _base_benefit_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces != "" and produces != "<null>":
		return "%s por dia: %s | armazenamento: %s" % [
			produces.capitalize(),
			_format_number(float(structure.get("daily_production", 0.0))),
			_format_number(float(structure.get("storage_cap", 0.0))),
		]
	return str(structure.get("benefit_label", "Bonus permanente."))

func _base_pending_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces == "" or produces == "<null>":
		return "Este predio nao gera coleta direta."
	return "%s %s de %s" % [
		_format_number(float(structure.get("pending_collectable", 0.0))),
		produces.capitalize(),
		_format_number(float(structure.get("storage_cap", 0.0))),
	]

func _base_upgrade_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	if next_level == null:
		return "nivel maximo"
	var cost := _as_dictionary(structure.get("upgrade_cost", {}))
	return "L%s | custo %s | tempo %s" % [
		str(next_level),
		_format_cost(cost),
		_format_duration(int(structure.get("upgrade_duration_seconds", 0))),
	]

func _base_next_level_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	return "max" if next_level == null else "L%s" % str(next_level)

func _base_short_status(structure: Dictionary) -> String:
	var active_job := _as_dictionary(structure.get("active_job", {}))
	if not active_job.is_empty():
		return "Upgrade %s" % _format_duration(int(active_job.get("remaining_seconds", 0)))
	if bool(structure.get("can_upgrade", false)):
		return "Upgrade pronto"
	return str(structure.get("blocked_message", "Bloqueado"))

func _base_status_color_token(structure: Dictionary) -> String:
	if bool(structure.get("can_upgrade", false)):
		return "status_success"
	var reason := str(structure.get("blocked_reason", ""))
	if reason == "INSUFFICIENT_RESOURCES" or reason == "CONSTRUCTION_QUEUE_FULL":
		return "status_warning"
	return "text_secondary"

func _base_structure_tooltip(structure: Dictionary) -> String:
	var structure_id := str(structure.get("structure_id", ""))
	return "%s\nO que e: %s\nComo funciona: %s\nImporta porque: %s" % [
		_structure_label(structure_id, str(structure.get("display_name", ""))),
		str(structure.get("description", "")),
		_base_upgrade_text(structure),
		_base_benefit_text(structure),
	]

func _can_upgrade_base_structure(structure_id: String) -> bool:
	if SessionStore.is_progression_lab_local_only():
		return false
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		return false
	var base := SessionStore.base_state
	var structures := _as_array(base.get("structures", []))
	var structure := _base_structure_by_id(structures, structure_id)
	return bool(structure.get("can_upgrade", false))

func _active_base_jobs(jobs: Array) -> Array:
	var active: Array = []
	for item: Variant in jobs:
		var job := _as_dictionary(item)
		if str(job.get("status", "")) == "active":
			active.append(job)
	return active

func _format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "-"
	var parts := PackedStringArray()
	for key: String in cost.keys():
		parts.append("%s %s" % [str(key).capitalize(), _format_number(float(cost.get(key, 0.0)))])
	return " | ".join(parts)

func _format_duration(total_seconds: int) -> String:
	var seconds: int = max(0, total_seconds)
	var hours := int(seconds / 3600)
	var minutes := int((seconds % 3600) / 60)
	var remaining_seconds: int = seconds % 60
	if hours > 0:
		return "%dh %02dm" % [hours, minutes]
	if minutes > 0:
		return "%dm %02ds" % [minutes, remaining_seconds]
	return "%ds" % remaining_seconds

func _format_number(value: float) -> String:
	if abs(value - round(value)) < 0.005:
		return str(int(round(value)))
	return "%.2f" % value

func _render_social_state() -> void:
	if _timeline_label == null:
		return
	if _social_state_container != null:
		_clear_node_children(_social_state_container)
	var social := SessionStore.social_state
	if social.is_empty():
		_timeline_label.text = "Social ainda nao carregado. Use Atualizar social."
		if _social_state_container != null:
			_social_state_container.add_child(_base_info_panel(
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
	_timeline_label.text = "\n".join(lines)
	if _social_state_container != null:
		_social_state_container.add_child(_social_identity_panel(identity, social_player, active_player))
		_social_state_container.add_child(_social_friends_panel(friends))
		_social_state_container.add_child(_social_guild_panel(guild, _as_array(social.get("guild_members", [])), _as_array(social.get("guild_structures", []))))
		_social_state_container.add_child(_social_chat_panel(messages))

func _social_identity_panel(identity: Dictionary, social_player: Dictionary, active_player: Dictionary) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Identidade Social", "text_primary", 17))
	box.add_child(_base_label("Username social: %s" % _social_username_text(social_player), "text_secondary"))
	box.add_child(_base_label("Save ativo: %s" % _social_username_text(active_player), "text_secondary"))
	var badge := str(identity.get("viewer_badge", SessionStore.active_save_badge()))
	var badge_label := _base_label("Marcador visivel: %s" % _social_save_badge_text(badge), "status_error" if badge == "lab" else "status_success")
	box.add_child(badge_label)
	if bool(identity.get("fallback_to_active_save", false)):
		box.add_child(_base_label("Aviso: save Normal ainda nao existe; o social esta usando o save ativo como fallback.", "status_warning"))
	return panel

func _social_friends_panel(friends: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Amigos (%d)" % friends.size(), "text_primary", 17))
	if friends.is_empty():
		box.add_child(_base_label("Nenhum amigo ainda. Use o username do outro jogador para adicionar.", "text_secondary"))
		return panel
	for item: Variant in friends:
		var friendship := _as_dictionary(item)
		var profile := _as_dictionary(friendship.get("friend", {}))
		box.add_child(_base_label("%s | %s | L%s | Poder %s" % [
			_social_username_text(profile),
			str(friendship.get("status", "accepted")),
			str(profile.get("level", 1)),
			str(profile.get("power", 0)),
		], "status_error" if str(profile.get("save_badge", "")) == "lab" else "text_secondary"))
	return panel

func _social_guild_panel(guild: Dictionary, members: Array, structures: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Guilda", "text_primary", 17))
	if guild.is_empty():
		box.add_child(_base_label("Sem guilda. Crie uma guilda ou entre pelo nome.", "text_secondary"))
		return panel
	box.add_child(_base_label("%s | Level %s | %d membros" % [
		str(guild.get("name", "")),
		str(guild.get("level", 1)),
		members.size(),
	], "text_secondary"))
	box.add_child(_base_label("Membros", "text_primary"))
	for item: Variant in members:
		var member := _as_dictionary(item)
		var profile := _as_dictionary(member.get("player", {}))
		var badge := str(profile.get("save_badge", "normal"))
		box.add_child(_base_label("%s | %s | L%s | Poder %s" % [
			_social_username_text(profile),
			str(member.get("role", "member")),
			str(profile.get("level", 1)),
			str(profile.get("power", 0)),
		], "status_error" if badge == "lab" else "text_secondary"))
	box.add_child(_base_label("Estruturas", "text_primary"))
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		box.add_child(_base_label("%s L%s" % [
			_guild_structure_label(str(structure.get("structure_id", ""))),
			str(structure.get("level", 1)),
		], "text_secondary"))
	return panel

func _social_chat_panel(messages: Array) -> Control:
	var panel := _base_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label("Chat de Guilda (%d recentes)" % messages.size(), "text_primary", 17))
	if messages.is_empty():
		box.add_child(_base_label("Sem mensagens recentes. Entre em uma guilda e envie a primeira mensagem.", "text_secondary"))
		return panel
	for item: Variant in messages:
		var message := _as_dictionary(item)
		var badge := str(message.get("sender_save_badge", "normal"))
		var sender_label := str(message.get("sender_username", "desconhecido"))
		if badge == "lab":
			sender_label += " [lab]"
		box.add_child(_base_label("%s: %s" % [
			sender_label,
			str(message.get("content", "")),
		], "status_error" if badge == "lab" else "text_secondary"))
	return panel

func _social_input_text(input: LineEdit, fallback: String = "") -> String:
	if input == null:
		return fallback.strip_edges()
	var text := input.text.strip_edges()
	if text == "":
		return fallback.strip_edges()
	return text

func _default_social_guild_text() -> String:
	if _last_social_guild_name.strip_edges() != "":
		return _last_social_guild_name
	var guild := _as_dictionary(SessionStore.social_state.get("guild", {}))
	if not guild.is_empty():
		return str(guild.get("name", "")).strip_edges()
	return _default_guild_name()

func _social_username_text(profile: Dictionary) -> String:
	var username := str(profile.get("username", "")).strip_edges()
	if username == "":
		username = "sem username"
	var badge := str(profile.get("save_badge", "normal"))
	if badge == "lab":
		return "%s [lab]" % username
	return username

func _social_save_badge_text(badge: String) -> String:
	if badge == "lab":
		return "lab"
	return "normal"

func _guild_structure_label(structure_id: String) -> String:
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

func _render_competition_state() -> void:
	if _timeline_label == null:
		return
	var competition := SessionStore.competition_state
	if competition.is_empty():
		_timeline_label.text = "Competicao ainda nao carregada. Use Preview matchmaking ou Ver ranking."
		return

	var lines := PackedStringArray()
	lines.append("Competicao server-authoritative")
	var matchmaking := _as_dictionary(competition.get("matchmaking", {}))
	if matchmaking.is_empty():
		lines.append("Matchmaking: ainda nao carregado.")
	else:
		var opponent := _as_dictionary(matchmaking.get("selected_opponent", {}))
		lines.append("Poder: %s" % str(matchmaking.get("player_power", 0)))
		lines.append("Oponente: %s | bot=%s | ranked=%s" % [
			str(opponent.get("id", "nenhum")),
			str(opponent.get("is_bot", false)),
			str(opponent.get("is_ranked", false)),
		])
	var ranking := _as_dictionary(competition.get("ranking", {}))
	if ranking.is_empty():
		lines.append("Ranking: ainda nao carregado.")
	else:
		var season := _as_dictionary(ranking.get("season", {}))
		var self_ranking := _as_dictionary(ranking.get("self", {}))
		lines.append("Season: %s" % str(season.get("display_name", "")))
		lines.append("Arena: %s pontos | bots no ranking: %s" % [
			str(self_ranking.get("arena_points", 0)),
			str(ranking.get("bots_included", false)),
		])
	_timeline_label.text = "\n".join(lines)

func _render_monetization_state() -> void:
	if _timeline_label == null:
		return
	var monetization := SessionStore.monetization_state
	if monetization.is_empty():
		_timeline_label.text = "Loja alpha ainda nao carregada. Use Atualizar loja."
		return

	var lines := PackedStringArray()
	lines.append("Monetizacao alpha server-authoritative")
	lines.append("Recursos: %s" % _format_resources(SessionStore.resources))
	var battle_pass := _as_dictionary(monetization.get("battle_pass", {}))
	var pass_config := _as_dictionary(battle_pass.get("pass", {}))
	var progress := _as_dictionary(battle_pass.get("progress", {}))
	lines.append("Battle Pass: %s | XP %s | premium=%s" % [
		str(pass_config.get("display_name", pass_config.get("id", ""))),
		str(progress.get("pass_xp", 0)),
		str(progress.get("premium_unlocked", false)),
	])
	var daily_rewards := _as_array(monetization.get("daily_rewards", []))
	lines.append("Recompensas diarias:")
	for item: Variant in daily_rewards.slice(0, min(daily_rewards.size(), 5)):
		var reward := _as_dictionary(item)
		if reward.is_empty():
			continue
		lines.append("- %s | xp %s | claimed=%s" % [
			str(reward.get("label", reward.get("id", ""))),
			str(reward.get("xp", 0)),
			str(reward.get("claimed", false)),
		])
	var products := _as_array(monetization.get("alpha_products", []))
	lines.append("Produtos alpha: %d" % products.size())
	for item: Variant in products:
		var product := _as_dictionary(item)
		if not product.is_empty():
			lines.append("- %s" % str(product.get("label", product.get("id", ""))))
	_timeline_label.text = "\n".join(lines)

func _play_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	var schema_version := str(battle_log.get("schema_version", ""))
	if schema_version != "battle_log_v1":
		_error_label.text = "UNSUPPORTED_BATTLE_LOG: %s" % schema_version
		_sync_status_from_session()
		return

	_error_label.text = ""
	_show_screen(SCREEN_BATTLE, false)
	_replay_running = true
	_skip_replay = false
	_set_busy(false, "Reproduzindo replay do primeiro slice...")
	_sync_buttons()
	_emit_client_event("replay_start", {
		"battle_id": str(battle_log.get("battle_id", "")),
		"mode": str(battle_log.get("mode", "")),
	})

	var lines: PackedStringArray = PackedStringArray()
	lines.append(BattleLogPresenterScript.format_summary(battle_log, rewards))
	var spell_count := BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast")
	var weapon_count := BattleLogPresenterScript.count_events_of_type(battle_log, "weapon_attack")
	var pet_count := BattleLogPresenterScript.count_events_of_type(battle_log, "pet_attack")
	var summon_count := BattleLogPresenterScript.count_events_of_type(battle_log, "summon_attack")
	lines.append("Eventos: %d spells | %d ataques | %d familiares | %d summons" % [
		spell_count,
		weapon_count,
		pet_count,
		summon_count,
	])
	if _battle_visual != null and is_instance_valid(_battle_visual):
		_battle_visual.load_battle_log(battle_log, rewards)
		_set_battle_visual_time(0.0)
	_timeline_label.text = "\n".join(lines)

	var events := BattleLogPresenterScript.sorted_events(battle_log)
	var battle_mode := str(battle_log.get("mode", ""))
	if battle_mode != ProjectInfoScript.DEFAULT_BATTLE_MODE:
		_error_label.text = "Aviso: replay em modo %s. O rework atual usa %s; gere uma nova batalha com as Edge Functions atualizadas." % [
			battle_mode,
			ProjectInfoScript.DEFAULT_BATTLE_MODE,
		]
	elif spell_count <= 0:
		_error_label.text = "Aviso: replay FIRST_SLICE_SIM sem spell_cast. Verifique build, bot e Supabase local atualizados."
	if BattleLogPresenterScript.has_unknown_events(battle_log):
		_error_label.text = "Aviso: replay contem evento desconhecido; exibindo fallback."

	var replay_time := 0.0
	for event: Dictionary in events:
		if _skip_replay:
			break
		var event_time := maxf(replay_time, float(event.get("t", replay_time)))
		while replay_time + 0.001 < event_time:
			if _skip_replay:
				break
			var tick := minf(BATTLE_REPLAY_TICK_SECONDS, event_time - replay_time)
			replay_time += tick
			_set_battle_visual_time(replay_time)
			await get_tree().create_timer(tick).timeout
		if _skip_replay:
			break
		lines.append(BattleLogPresenterScript.format_event(event))
		_set_battle_visual_time(event_time)
		if _battle_visual != null and is_instance_valid(_battle_visual):
			_battle_visual.step_next_event()
		_timeline_label.text = "\n".join(lines)
		replay_time = event_time
		await get_tree().process_frame

	if _skip_replay:
		_emit_client_event("replay_skip", {
			"battle_id": str(battle_log.get("battle_id", "")),
			"events": events.size(),
		})
		for event: Dictionary in events:
			var formatted := BattleLogPresenterScript.format_event(event)
			if not lines.has(formatted):
				lines.append(formatted)
		if _battle_visual != null and is_instance_valid(_battle_visual):
			_battle_visual.reveal_all()
		_timeline_label.text = "\n".join(lines)

	if _battle_visual != null and is_instance_valid(_battle_visual):
		_battle_visual.reveal_all()

	_replay_running = false
	_skip_replay = false
	_set_busy(false, "Replay concluido.")
	_emit_client_event("replay_end", {
		"battle_id": str(battle_log.get("battle_id", "")),
		"events": events.size(),
	})
	_sync_buttons()

func _set_battle_visual_time(replay_time: float) -> void:
	if _battle_visual != null and is_instance_valid(_battle_visual) and _battle_visual.has_method("set_replay_time"):
		_battle_visual.set_replay_time(replay_time)

func _screen_title(screen_id: String) -> String:
	match screen_id:
		SCREEN_HUB:
			return "Refugio"
		SCREEN_BATTLE:
			return "Batalha"
		SCREEN_BASE:
			return "Base"
		SCREEN_SOCIAL:
			return "Social"
		SCREEN_COMPETITION:
			return "Competicao"
		SCREEN_SHOP:
			return "Loja"
	return "Refugio"

func _session_status_text() -> String:
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		var label := SessionStore.progression_lab_label()
		if label == "":
			label = SessionStore.player_display_name()
		return "Progression Lab local: %s (somente leitura)" % label
	if SessionStore.is_progression_lab_active():
		return "Save Progression Lab ativo - isolado do save normal"
	if SessionStore.has_account_state():
		return "Save Normal - sessao guest pronta: %s" % SessionStore.player_display_name()
	if SessionStore.has_valid_access_token():
		return "Save %s - sessao anonima criada." % SessionStore.active_save_label()
	return "%s - primeiro slice" % ProjectInfoScript.PROJECT_NAME

func _default_guild_name() -> String:
	var player_id := str(SessionStore.player.get("id", ""))
	var suffix := player_id.replace("-", "").substr(0, 8)
	if suffix == "":
		suffix = SessionStoreScript.create_request_id().replace("-", "").substr(0, 8)
	return "Conclave %s" % suffix

func _format_resources(resources: Dictionary, include_diamond: bool = true) -> String:
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		if key == "diamante" and not include_diamond:
			continue
		parts.append("%s %s" % [key.capitalize(), str(resources.get(key, 0))])
	return " | ".join(parts)

func _resource_total(resources: Dictionary) -> float:
	var total := 0.0
	for key: String in RESOURCE_KEYS:
		total += float(resources.get(key, 0.0))
	return total

func _structure_label(structure_id: String, fallback: String = "") -> String:
	if fallback != "":
		return fallback
	match structure_id:
		"altar_das_almas":
			return "Altar das Almas"
		"nucleo_energia":
			return "Nucleo de Energia"
		"pocos_sangue":
			return "Pocos de Sangue"
		"minas_cristal":
			return "Minas de Cristal"
		"estrutura_stats":
			return "Estrutura de Stats"
		"ossario":
			return "Ossario"
	return structure_id

func _extract_error(result: Dictionary) -> Dictionary:
	var error_payload := _as_dictionary(result.get("error", {}))
	if error_payload.is_empty():
		var body := _as_dictionary(result.get("body", {}))
		error_payload = _as_dictionary(body.get("error", {}))
	if error_payload.is_empty():
		error_payload = {
			"code": "REQUEST_FAILED",
			"message": "Acao nao concluida.",
		}
	return error_payload

func _friendly_error_message(code: String, message: String) -> String:
	match code:
		"PROGRESSION_LAB_SAVE_PENDING":
			return "Save Progression Lab selecionado. Acoes online serao ligadas ao Supabase local na proxima subetapa."
		"PROGRESSION_LAB_LOCAL_ONLY":
			return "Save local-only do Progression Lab. Use o seeder com Supabase local para testar acoes online."
		"PROGRESSION_LAB_SAVE_REQUIRED":
			return "Selecione o save Progression Lab antes de aplicar um perfil do laboratorio."
		"PROGRESSION_LAB_SAVE_NOT_FOUND":
			return "Perfil/milestone do Progression Lab nao encontrado no catalogo do servidor."
		"INVALID_PROGRESSION_LAB_SAVE":
			return "O servidor recusou o estado gerado do Progression Lab."
		"NETWORK_UNAVAILABLE":
			return "Supabase local indisponivel. Confirme Docker/Supabase local em http://127.0.0.1:54321 e tente sincronizar."
		"REQUEST_NOT_STARTED":
			return "Requisicao nao iniciou. Verifique URL/chave local do Supabase nas Project Settings."
		"CLIENT_MISCONFIGURED":
			return "Cliente Supabase sem chave publishable configurada."
		"INSUFFICIENT_RESOURCES":
			return "Recursos insuficientes para esta acao. Na Base, confira Energia, custo e loja alpha."
		"CONSTRUCTION_QUEUE_FULL":
			return "Fila de construcao cheia. Aguarde o upgrade ativo terminar antes de iniciar outro."
		"STRUCTURE_ALREADY_UPGRADING":
			return "Este predio ja esta em upgrade."
		"LEVEL_CAP_REACHED":
			return "O level do jogador limita o proximo upgrade deste predio."
		"INVALID_STRUCTURE":
			return "Predio da Base nao encontrado no contrato atual."
		"USER_NOT_FOUND":
			return "Usuario nao encontrado. Confirme o username do outro jogador."
		"INVALID_FRIEND":
			return "Voce nao pode adicionar a propria conta como amigo."
		"INVALID_GUILD_NAME":
			return "Nome de guilda invalido. Use de 3 a 32 caracteres."
		"GUILD_NOT_FOUND":
			return "Guilda nao encontrada. Confira o nome exato com o outro jogador."
		"GUILD_REQUIRED":
			return "Entre em uma guilda antes de enviar mensagem no chat."
		"GUILD_ALREADY_JOINED":
			return "Esta conta ja participa de uma guilda."
		"GUILD_FULL":
			return "Esta guilda esta cheia."
		"EMPTY_MESSAGE":
			return "Digite uma mensagem antes de enviar."
		"CHAT_RATE_LIMITED":
			return "Aguarde alguns segundos antes de enviar outra mensagem."
		"PRODUCT_NOT_FOUND":
			return "Produto alpha nao encontrado no servidor."
		"REWARD_NOT_FOUND":
			return "Recompensa alpha nao encontrada no servidor."
		"UNAUTHENTICATED":
			return "Sessao expirada. Entre como guest novamente."
	return "%s: %s" % [code, message]

func _is_network_error(code: String) -> bool:
	return code in ["NETWORK_UNAVAILABLE", "REQUEST_NOT_STARTED", "CLIENT_MISCONFIGURED", "INVALID_JSON"]

func _panel_style(bg_token: String, border_token: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color(bg_token)
	style.border_color = UiTokens.color(border_token)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []

func _action_payload(action_id: String) -> Dictionary:
	return {
		"action_id": action_id,
		"screen": _current_screen,
		"save_type": SessionStore.active_save_type,
		"has_account": SessionStore.has_account_state(),
		"offline": SessionStore.offline,
	}

func _emit_client_event(event_type: String, payload: Dictionary) -> void:
	if SessionStore.is_progression_lab_local_only():
		return
	if not SessionStore.has_valid_access_token():
		return
	call_deferred("_send_telemetry_deferred", event_type, payload.duplicate(true))

func _send_telemetry_deferred(event_type: String, payload: Dictionary) -> void:
	var result: Dictionary = await SupabaseClient.send_client_telemetry(
		SessionStore.access_token,
		SessionStore.ensure_session_id(),
		event_type,
		payload
	)
	if not bool(result.get("ok", false)):
		var error_payload := _extract_error(result)
		print("[telemetry] %s: %s" % [
			str(error_payload.get("code", "TELEMETRY_FAILED")),
			str(error_payload.get("message", "")),
		])
