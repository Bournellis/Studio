extends Control

const ProjectInfoScript := preload("res://core/project_info.gd")
const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")

const SCREEN_HUB := "hub"
const SCREEN_BATTLE := "battle"
const SCREEN_BASE := "base"
const SCREEN_SOCIAL := "social"
const SCREEN_COMPETITION := "competition"
const SCREEN_SHOP := "shop"

const RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]

var _status_label: Label
var _detail_label: Label
var _error_label: Label
var _back_button: Button
var _content_title: Label
var _content_body: VBoxContainer
var _timeline_label: Label
var _confirm_dialog: ConfirmationDialog

var _action_buttons: Dictionary = {}
var _nav_buttons: Dictionary = {}
var _screen_history: Array[String] = []
var _current_screen := SCREEN_HUB
var _pending_confirmation_action := ""
var _is_busy := false
var _replay_running := false
var _skip_replay := false

func _ready() -> void:
	_clear_existing_scene()
	_build_ui()
	SessionStore.session_changed.connect(_sync_status_from_session)
	SessionStore.load_cache()
	_show_screen(SCREEN_HUB, false)
	_sync_status_from_session()
	if SessionStore.has_valid_access_token():
		call_deferred("_recover_session_state")

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if _confirm_dialog != null and _confirm_dialog.visible:
		_confirm_dialog.hide()
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

func _go_back() -> void:
	if _is_busy:
		return
	if _screen_history.is_empty():
		_show_screen(SCREEN_HUB, false)
		return
	var previous: String = _screen_history.pop_back()
	_show_screen(previous, false)

func _clear_content_body() -> void:
	for child: Node in _content_body.get_children():
		_content_body.remove_child(child)
		child.queue_free()

func _render_hub_screen() -> void:
	_add_section_label("Alpha liberado")
	_add_body_text("Todos os sistemas da Track 00 ficam disponiveis para teste. Se uma acao tiver pre-condicao, ela deve responder com erro claro em vez de parecer morta.")
	_add_action_button("Entrar como guest", "enter_guest")

	var account := "Conta: nao iniciada"
	if SessionStore.has_account_state():
		account = "Conta: %s | Level %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player.get("level", 1)),
			str(SessionStore.player.get("power", 0)),
		]
	elif SessionStore.has_valid_access_token():
		account = "Conta: sessao anonima criada; falta recuperar/criar guest."
	_add_output_label(account)

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
	_timeline_label = _add_output_label("")
	if SessionStore.has_battle_log():
		_timeline_label.text = BattleLogPresenterScript.format_summary(SessionStore.last_battle_log, SessionStore.last_battle_rewards)
	else:
		_timeline_label.text = "Nenhuma batalha carregada. Solicite uma batalha ou busque o ultimo resultado."

func _render_base_screen() -> void:
	_add_body_text("Base v0 com seis estruturas, coleta offline e fila de construcao no servidor.")
	_add_action_button("Atualizar base", "show_base")
	_add_action_button("Coletar producao", "collect_base", "Coletar a producao offline acumulada da base?")
	_add_action_button("Evoluir Nucleo", "upgrade_nucleo", "Iniciar evolucao do Nucleo de Energia usando recursos do servidor?")
	_timeline_label = _add_output_label("")
	_render_base_state()

func _render_social_screen() -> void:
	_add_body_text("Social alpha disponivel para teste: estado social, guilda e chat por polling.")
	_add_action_button("Atualizar social", "show_social")
	_add_action_button("Criar guilda", "create_guild", "Criar uma guilda alpha para esta conta?")
	_add_action_button("Chat guilda", "send_guild_chat", "Enviar uma mensagem fixa de teste no chat da guilda?")
	_timeline_label = _add_output_label("")
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
	match action_id:
		"enter_guest":
			await _enter_guest()
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
		"upgrade_nucleo":
			await _upgrade_nucleo()
		"show_social":
			await _show_social()
		"create_guild":
			await _create_guild()
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

func _enter_guest() -> void:
	_set_busy(true, "Criando sessao guest...")
	var auth_result: Dictionary = {"ok": true}
	if not SessionStore.has_valid_access_token():
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
	await _recover_session_state()
	_show_notice("Sessao guest pronta. Todas as abas do alpha estao disponiveis.")
	_show_screen(SCREEN_HUB, false)

func _recover_session_state() -> void:
	if not SessionStore.has_valid_access_token():
		_sync_status_from_session()
		return

	_set_busy(true, "Recuperando estado do servidor...")
	var state_result: Dictionary = await SupabaseClient.fetch_account_state(SessionStore.access_token)
	if not bool(state_result.get("ok", false)):
		_fail_with_error(state_result)
		return

	SessionStore.apply_server_state(state_result)
	SessionStore.save_cache()
	_set_busy(false, "Sessao sincronizada com o servidor.")
	_sync_status_from_session()

func _request_battle() -> void:
	if not _require_account("Crie uma sessao guest antes de solicitar batalha."):
		return

	_show_screen(SCREEN_BATTLE, false)
	_set_busy(true, "Solicitando batalha...")
	var battle_result: Dictionary = await SupabaseClient.request_battle(
		SessionStore.create_request_id(),
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
	await _recover_session_state()
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
		SessionStore.create_request_id(),
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

func _upgrade_nucleo() -> void:
	if not _require_account("Crie uma sessao guest antes de evoluir a base."):
		return

	_show_screen(SCREEN_BASE, false)
	_set_busy(true, "Solicitando evolucao do Nucleo...")
	var base_result: Dictionary = await SupabaseClient.upgrade_base_structure(
		SessionStore.create_request_id(),
		"nucleo_energia",
		SessionStore.access_token
	)
	if not bool(base_result.get("ok", false)):
		_fail_with_error(base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Evolucao iniciada no servidor.")
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

func _create_guild() -> void:
	if not _require_account("Crie uma sessao guest antes de criar guilda."):
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Criando guilda alpha...")
	var social_result: Dictionary = await SupabaseClient.create_guild(
		SessionStore.create_request_id(),
		_default_guild_name(),
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

func _send_guild_chat() -> void:
	if not _require_account("Crie uma sessao guest antes de usar chat."):
		return

	_show_screen(SCREEN_SOCIAL, false)
	_set_busy(true, "Enviando mensagem de guilda...")
	var social_result: Dictionary = await SupabaseClient.send_guild_chat(
		SessionStore.create_request_id(),
		"Primeiro pulso do Conclave.",
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
		SessionStore.create_request_id(),
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
		SessionStore.create_request_id(),
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
		SessionStore.create_request_id(),
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
	if SessionStore.has_valid_access_token():
		return true
	_error_label.text = message
	_detail_label.text = "Use Entrar como guest no Refugio."
	return false

func _require_account(message: String) -> bool:
	if SessionStore.has_valid_access_token() and SessionStore.has_account_state():
		return true
	_error_label.text = message
	_detail_label.text = "Use Entrar como guest no Refugio."
	return false

func _render_base_state(collected: Dictionary = {}) -> void:
	if _timeline_label == null:
		return
	var base := SessionStore.base_state
	if base.is_empty():
		_timeline_label.text = "Base ainda nao carregada. Use Atualizar base."
		return

	var resources := SessionStore.resources
	var lines := PackedStringArray()
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
		lines.append("Estruturas:")
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		if structure.is_empty():
			continue
		lines.append("- %s L%s | pendente %s/%s" % [
			_structure_label(str(structure.get("structure_id", "")), str(structure.get("display_name", ""))),
			str(structure.get("level", 0)),
			str(structure.get("pending_collectable", 0)),
			str(structure.get("storage_cap", 0)),
		])

	var jobs := _as_array(base.get("jobs", []))
	var active_jobs := 0
	for item: Variant in jobs:
		var job := _as_dictionary(item)
		if str(job.get("status", "")) == "active":
			active_jobs += 1
			lines.append("- Em construcao: %s -> L%s" % [
				_structure_label(str(job.get("structure_id", ""))),
				str(job.get("target_level", "?")),
			])
	lines.append("Fila: %d/%d" % [active_jobs, int(base.get("construction_slots", 1))])
	_timeline_label.text = "\n".join(lines)

func _render_social_state() -> void:
	if _timeline_label == null:
		return
	var social := SessionStore.social_state
	if social.is_empty():
		_timeline_label.text = "Social ainda nao carregado. Use Atualizar social."
		return

	var lines := PackedStringArray()
	lines.append("Social server-authoritative")
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
			lines.append("- %s" % str(message.get("content", "")))
	_timeline_label.text = "\n".join(lines)

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

	_show_screen(SCREEN_BATTLE, false)
	_replay_running = true
	_skip_replay = false
	_set_busy(false, "Reproduzindo replay do primeiro slice...")
	_sync_buttons()

	var lines: PackedStringArray = PackedStringArray()
	lines.append(BattleLogPresenterScript.format_summary(battle_log, rewards))
	_timeline_label.text = "\n".join(lines)

	var events := BattleLogPresenterScript.sorted_events(battle_log)
	if BattleLogPresenterScript.has_unknown_events(battle_log):
		_error_label.text = "Aviso: replay contem evento desconhecido; exibindo fallback."

	for event: Dictionary in events:
		if _skip_replay:
			break
		lines.append(BattleLogPresenterScript.format_event(event))
		_timeline_label.text = "\n".join(lines)
		await get_tree().create_timer(0.15).timeout

	if _skip_replay:
		for event: Dictionary in events:
			var formatted := BattleLogPresenterScript.format_event(event)
			if not lines.has(formatted):
				lines.append(formatted)
		_timeline_label.text = "\n".join(lines)

	_replay_running = false
	_skip_replay = false
	_set_busy(false, "Replay concluido.")
	_sync_buttons()

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
	if SessionStore.has_account_state():
		return "Sessao guest pronta: %s" % SessionStore.player_display_name()
	if SessionStore.has_valid_access_token():
		return "Sessao anonima criada."
	return "%s - primeiro slice" % ProjectInfoScript.PROJECT_NAME

func _default_guild_name() -> String:
	var player_id := str(SessionStore.player.get("id", ""))
	var suffix := player_id.replace("-", "").substr(0, 8)
	if suffix == "":
		suffix = SessionStore.create_request_id().replace("-", "").substr(0, 8)
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
		"altar_almas":
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
		"INSUFFICIENT_RESOURCES":
			return "Energia insuficiente para iniciar evolucao do Nucleo."
		"GUILD_REQUIRED":
			return "Crie uma guilda antes de enviar mensagem no chat."
		"GUILD_ALREADY_JOINED":
			return "Esta conta ja participa de uma guilda."
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
