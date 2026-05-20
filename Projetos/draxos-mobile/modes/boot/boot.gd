extends Control

const ProjectInfoScript := preload("res://core/project_info.gd")
const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")

@onready var status_label: Label = %StatusLabel
@onready var action_list: VBoxContainer = %ActionList

var _action_buttons: Dictionary = {}
var _detail_label: Label
var _error_label: Label
var _timeline_label: Label
var _replay_running := false
var _skip_replay := false

func _ready() -> void:
	SessionStore.load_cache()
	SessionStore.session_changed.connect(_sync_status_from_session)
	status_label.text = "%s - primeiro slice" % ProjectInfoScript.PROJECT_NAME
	_build_action_buttons()
	_build_status_labels()
	_sync_status_from_session()
	if SessionStore.has_valid_access_token():
		call_deferred("_recover_session_state")

func _build_action_buttons() -> void:
	for action in ProjectInfoScript.boot_actions():
		var button := Button.new()
		button.text = action
		button.custom_minimum_size = Vector2(320, 48)
		button.disabled = action != "Entrar como guest"
		if action == "Entrar como guest":
			button.pressed.connect(_on_guest_pressed)
		elif action == "Solicitar batalha":
			button.pressed.connect(_on_battle_pressed)
		elif action == "Ver resultado":
			button.pressed.connect(_on_result_pressed)
		elif action == "Ver base":
			button.pressed.connect(_on_base_pressed)
		elif action == "Coletar base":
			button.pressed.connect(_on_collect_base_pressed)
		elif action == "Evoluir Nucleo":
			button.pressed.connect(_on_upgrade_nucleo_pressed)
		elif action == "Ver social":
			button.pressed.connect(_on_social_pressed)
		elif action == "Criar guilda":
			button.pressed.connect(_on_create_guild_pressed)
		elif action == "Chat guilda":
			button.pressed.connect(_on_guild_chat_pressed)
		elif action == "Preview matchmaking":
			button.pressed.connect(_on_matchmaking_pressed)
		elif action == "Ver ranking":
			button.pressed.connect(_on_ranking_pressed)
		elif action == "Ver loja":
			button.pressed.connect(_on_shop_pressed)
		elif action == "Comprar premium alpha":
			button.pressed.connect(_on_buy_premium_alpha_pressed)
		elif action == "Receber Diamante":
			button.pressed.connect(_on_grant_diamond_alpha_pressed)
		elif action == "Claim diario":
			button.pressed.connect(_on_claim_daily_pressed)
		action_list.add_child(button)
		_action_buttons[action] = button

func _build_status_labels() -> void:
	_detail_label = Label.new()
	_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	action_list.add_child(_detail_label)

	_error_label = Label.new()
	_error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error_label.add_theme_color_override("font_color", UiTokens.color("status_error"))
	action_list.add_child(_error_label)

	_timeline_label = Label.new()
	_timeline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_timeline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_timeline_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	action_list.add_child(_timeline_label)

func _on_guest_pressed() -> void:
	await _enter_guest()

func _on_battle_pressed() -> void:
	await _request_battle()

func _on_result_pressed() -> void:
	if _replay_running:
		_skip_replay = true
		return
	await _show_latest_battle()

func _on_base_pressed() -> void:
	await _show_base()

func _on_collect_base_pressed() -> void:
	await _collect_base()

func _on_upgrade_nucleo_pressed() -> void:
	await _upgrade_nucleo()

func _on_social_pressed() -> void:
	await _show_social()

func _on_create_guild_pressed() -> void:
	await _create_guild()

func _on_guild_chat_pressed() -> void:
	await _send_guild_chat()

func _on_matchmaking_pressed() -> void:
	await _show_matchmaking()

func _on_ranking_pressed() -> void:
	await _show_ranking()

func _on_shop_pressed() -> void:
	await _show_shop()

func _on_buy_premium_alpha_pressed() -> void:
	await _buy_premium_alpha()

func _on_grant_diamond_alpha_pressed() -> void:
	await _grant_diamond_alpha()

func _on_claim_daily_pressed() -> void:
	await _claim_daily_reward()

func _enter_guest() -> void:
	_set_busy(true, "Criando sessao guest...")
	var auth_result: Dictionary = {"ok": true}
	if not SessionStore.has_valid_access_token():
		auth_result = await SupabaseClient.sign_in_anonymously()
		if not bool(auth_result.get("ok", false)):
			_fail_with_error(auth_result)
			return
		SessionStore.apply_auth_session(Dictionary(auth_result.get("session", {})))
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
	_set_busy(false, "Sessao guest pronta.")
	_sync_status_from_session()

func _request_battle() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de solicitar batalha."
		return

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
	if not SessionStore.has_valid_access_token():
		_error_label.text = "Sessao anonima indisponivel."
		return

	_set_busy(true, "Buscando ultimo resultado...")
	var latest_result: Dictionary = await SupabaseClient.fetch_latest_battle(SessionStore.access_token)
	if not bool(latest_result.get("ok", false)):
		_fail_with_error(latest_result)
		return

	var body := Dictionary(latest_result.get("body", {}))
	if body.get("battle_log", null) == null:
		_set_busy(false, "Nenhuma batalha registrada.")
		_timeline_label.text = "Solicite uma batalha para gerar o primeiro replay MVP."
		_sync_status_from_session()
		return

	if not SessionStore.apply_battle_result(latest_result):
		_fail_with_error({"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	_set_busy(false, "Ultimo resultado recuperado.")
	await _play_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func _show_base() -> void:
	if not SessionStore.has_valid_access_token():
		_error_label.text = "Sessao anonima indisponivel."
		return

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
	_sync_status_from_session()

func _collect_base() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de coletar a base."
		return

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

	SessionStore.save_cache()
	_set_busy(false, "Coleta registrada no servidor.")
	_render_base_state(Dictionary(Dictionary(base_result.get("body", {})).get("collected", {})))
	_sync_status_from_session()

func _upgrade_nucleo() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de evoluir a base."
		return

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
	_sync_status_from_session()

func _show_social() -> void:
	if not SessionStore.has_valid_access_token():
		_error_label.text = "Sessao anonima indisponivel."
		return

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
	_sync_status_from_session()

func _create_guild() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de criar guilda."
		return

	_set_busy(true, "Criando guilda alpha...")
	var social_result: Dictionary = await SupabaseClient.create_guild(
		SessionStore.create_request_id(),
		"Conclave Alpha",
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
	_sync_status_from_session()

func _send_guild_chat() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de usar chat."
		return

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
	_sync_status_from_session()

func _show_matchmaking() -> void:
	if not SessionStore.has_valid_access_token():
		_error_label.text = "Sessao anonima indisponivel."
		return

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
	_sync_status_from_session()

func _show_ranking() -> void:
	if not SessionStore.has_valid_access_token():
		_error_label.text = "Sessao anonima indisponivel."
		return

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
	_sync_status_from_session()

func _show_shop() -> void:
	if not SessionStore.has_valid_access_token():
		_error_label.text = "Sessao anonima indisponivel."
		return

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
	_sync_status_from_session()

func _buy_premium_alpha() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de comprar premium alpha."
		return

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
	_sync_status_from_session()

func _grant_diamond_alpha() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de receber Diamante."
		return

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
	_sync_status_from_session()

func _claim_daily_reward() -> void:
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		_error_label.text = "Crie uma sessao guest antes de resgatar recompensa diaria."
		return

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

	var body := Dictionary(monetization_result.get("body", {}))
	var message := "Recompensa diaria registrada no servidor."
	if bool(body.get("already_claimed", false)):
		message = "Recompensa diaria ja havia sido resgatada."
	SessionStore.save_cache()
	_set_busy(false, message)
	_render_monetization_state()
	_sync_status_from_session()

func _set_busy(is_busy: bool, message: String) -> void:
	status_label.text = message
	for action: String in _action_buttons.keys():
		var button: Button = _action_buttons[action]
		button.disabled = is_busy or (_replay_running and action != "Ver resultado") or not _can_use_action(action)
	_error_label.text = ""

func _fail_with_error(result: Dictionary) -> void:
	var error_payload := Dictionary(result.get("error", {}))
	SessionStore.mark_offline(error_payload)
	_set_busy(false, "Modo offline controlado.")
	_sync_status_from_session()

func _sync_status_from_session() -> void:
	if SessionStore.has_account_state():
		status_label.text = "Sessao guest pronta: %s" % SessionStore.player_display_name()
		_detail_label.text = "Batalha do primeiro slice disponivel. O cliente apenas exibe o log recebido."
	elif SessionStore.has_valid_access_token():
		status_label.text = "Sessao anonima criada."
		_detail_label.text = "Use Entrar como guest para criar ou recuperar a conta MVP."
	else:
		status_label.text = "%s - primeiro slice" % ProjectInfoScript.PROJECT_NAME
		_detail_label.text = "Supabase local: %s" % SupabaseClient.supabase_url

	if SessionStore.offline and not SessionStore.last_error.is_empty():
		_error_label.text = "%s: %s" % [
			str(SessionStore.last_error.get("code", "NETWORK_UNAVAILABLE")),
			str(SessionStore.last_error.get("message", "Rede indisponivel.")),
		]
	elif _error_label != null:
		_error_label.text = ""

	for action: String in _action_buttons.keys():
		var button: Button = _action_buttons[action]
		button.disabled = _replay_running or not _can_use_action(action)

func _can_use_action(action: String) -> bool:
	if action == "Entrar como guest":
		return true
	if action == "Solicitar batalha":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Ver resultado":
		return SessionStore.has_valid_access_token()
	if action == "Ver base":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Coletar base":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Evoluir Nucleo":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Ver social":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Criar guilda":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Chat guilda":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Preview matchmaking":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Ver ranking":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Ver loja":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Comprar premium alpha":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Receber Diamante":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	if action == "Claim diario":
		return SessionStore.has_account_state() and SessionStore.has_valid_access_token()
	return false

func _render_base_state(collected: Dictionary = {}) -> void:
	var base := SessionStore.base_state
	if base.is_empty():
		_timeline_label.text = "Base ainda nao carregada."
		return

	var resources := SessionStore.resources
	var lines := PackedStringArray()
	lines.append("Refugio server-authoritative")
	lines.append("Recursos: Almas %s | Energia %s | Sangue %s | Cristais %s | Ossos %s | Diamante %s" % [
		str(resources.get("almas", 0)),
		str(resources.get("energia", 0)),
		str(resources.get("sangue", 0)),
		str(resources.get("cristais", 0)),
		str(resources.get("ossos", 0)),
		str(resources.get("diamante", 0)),
	])
	if not collected.is_empty():
		lines.append("Coletado: Almas %s | Energia %s | Sangue %s | Cristais %s | Ossos %s" % [
			str(collected.get("almas", 0)),
			str(collected.get("energia", 0)),
			str(collected.get("sangue", 0)),
			str(collected.get("cristais", 0)),
			str(collected.get("ossos", 0)),
		])

	var structures: Array = Array(base.get("structures", []))
	for item: Variant in structures:
		if not item is Dictionary:
			continue
		var structure := Dictionary(item)
		lines.append("%s L%s | pendente %s/%s" % [
			str(structure.get("display_name", structure.get("structure_id", ""))),
			str(structure.get("level", 0)),
			str(structure.get("pending_collectable", 0)),
			str(structure.get("storage_cap", 0)),
		])

	var jobs: Array = Array(base.get("jobs", []))
	var active_jobs := 0
	for item: Variant in jobs:
		if item is Dictionary and str(Dictionary(item).get("status", "")) == "active":
			active_jobs += 1
	lines.append("Fila: %d/%d" % [active_jobs, int(base.get("construction_slots", 1))])
	_timeline_label.text = "\n".join(lines)

func _render_social_state() -> void:
	var social := SessionStore.social_state
	if social.is_empty():
		_timeline_label.text = "Social ainda nao carregado."
		return

	var lines := PackedStringArray()
	lines.append("Social server-authoritative")
	var guild := Dictionary(social.get("guild", {}))
	if guild.is_empty():
		lines.append("Guilda: nenhuma")
	else:
		lines.append("Guilda: %s L%s" % [str(guild.get("name", "")), str(guild.get("level", 1))])
		lines.append("Membros: %d" % Array(social.get("guild_members", [])).size())
		lines.append("Estruturas de guilda: %d" % Array(social.get("guild_structures", [])).size())
	var friends: Array = Array(social.get("friends", []))
	lines.append("Amigos: %d" % friends.size())
	var messages: Array = Array(social.get("guild_chat", []))
	lines.append("Chat guilda: %d mensagens recentes" % messages.size())
	for item: Variant in messages.slice(0, min(messages.size(), 3)):
		if item is Dictionary:
			lines.append("- %s" % str(Dictionary(item).get("content", "")))
	_timeline_label.text = "\n".join(lines)

func _render_competition_state() -> void:
	var competition := SessionStore.competition_state
	if competition.is_empty():
		_timeline_label.text = "Competicao ainda nao carregada."
		return

	var lines := PackedStringArray()
	lines.append("Competicao server-authoritative")
	if competition.get("matchmaking", null) is Dictionary:
		var matchmaking := Dictionary(competition.get("matchmaking", {}))
		var opponent := Dictionary(matchmaking.get("selected_opponent", {}))
		lines.append("Poder: %s" % str(matchmaking.get("player_power", 0)))
		lines.append("Oponente: %s | bot=%s | ranked=%s" % [
			str(opponent.get("id", "nenhum")),
			str(opponent.get("is_bot", false)),
			str(opponent.get("is_ranked", false)),
		])
	if competition.get("ranking", null) is Dictionary:
		var ranking := Dictionary(competition.get("ranking", {}))
		var season := Dictionary(ranking.get("season", {}))
		var self := Dictionary(ranking.get("self", {}))
		lines.append("Season: %s" % str(season.get("display_name", "")))
		lines.append("Arena: %s pontos | bots no ranking: %s" % [
			str(self.get("arena_points", 0)),
			str(ranking.get("bots_included", false)),
		])
	_timeline_label.text = "\n".join(lines)

func _render_monetization_state() -> void:
	var monetization := SessionStore.monetization_state
	if monetization.is_empty():
		_timeline_label.text = "Loja alpha ainda nao carregada."
		return

	var resources := SessionStore.resources
	var lines := PackedStringArray()
	lines.append("Monetizacao alpha server-authoritative")
	lines.append("Recursos: Almas %s | Energia %s | Sangue %s | Cristais %s | Ossos %s | Diamante %s" % [
		str(resources.get("almas", 0)),
		str(resources.get("energia", 0)),
		str(resources.get("sangue", 0)),
		str(resources.get("cristais", 0)),
		str(resources.get("ossos", 0)),
		str(resources.get("diamante", 0)),
	])
	var battle_pass := Dictionary(monetization.get("battle_pass", {}))
	var pass := Dictionary(battle_pass.get("pass", {}))
	var progress := Dictionary(battle_pass.get("progress", {}))
	lines.append("Battle Pass: %s | XP %s | premium=%s" % [
		str(pass.get("display_name", "")),
		str(progress.get("pass_xp", 0)),
		str(progress.get("premium_unlocked", false)),
	])
	var daily_rewards: Array = Array(monetization.get("daily_rewards", []))
	for item: Variant in daily_rewards.slice(0, min(daily_rewards.size(), 3)):
		if item is Dictionary:
			var reward := Dictionary(item)
			lines.append("Diario: %s | xp %s | claimed=%s" % [
				str(reward.get("id", "")),
				str(reward.get("xp", 0)),
				str(reward.get("claimed", false)),
			])
	var products: Array = Array(monetization.get("alpha_products", []))
	lines.append("Produtos alpha: %d" % products.size())
	for item: Variant in products:
		if item is Dictionary:
			var product := Dictionary(item)
			lines.append("- %s" % str(product.get("id", "")))
	_timeline_label.text = "\n".join(lines)

func _play_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	var schema_version := str(battle_log.get("schema_version", ""))
	if schema_version != "battle_log_v1":
		_error_label.text = "UNSUPPORTED_BATTLE_LOG: %s" % schema_version
		_sync_status_from_session()
		return

	_replay_running = true
	_skip_replay = false
	_set_busy(false, "Reproduzindo replay do primeiro slice...")
	if _action_buttons.has("Ver resultado"):
		var result_button: Button = _action_buttons["Ver resultado"]
		result_button.text = "Pular replay"
		result_button.disabled = false

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
	if _action_buttons.has("Ver resultado"):
		var result_button: Button = _action_buttons["Ver resultado"]
		result_button.text = "Ver resultado"
	status_label.text = "Replay concluido."
	_sync_status_from_session()
