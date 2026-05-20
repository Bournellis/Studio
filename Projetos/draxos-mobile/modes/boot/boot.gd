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
	status_label.text = "%s - MVP tecnico minimo" % ProjectInfoScript.PROJECT_NAME
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
		ProjectInfoScript.MVP_MODE
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
		_detail_label.text = "Batalha MVP disponivel. O cliente apenas exibe o log recebido."
	elif SessionStore.has_valid_access_token():
		status_label.text = "Sessao anonima criada."
		_detail_label.text = "Use Entrar como guest para criar ou recuperar a conta MVP."
	else:
		status_label.text = "%s - MVP tecnico minimo" % ProjectInfoScript.PROJECT_NAME
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
	return false

func _play_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	var schema_version := str(battle_log.get("schema_version", ""))
	if schema_version != "battle_log_v1":
		_error_label.text = "UNSUPPORTED_BATTLE_LOG: %s" % schema_version
		_sync_status_from_session()
		return

	_replay_running = true
	_skip_replay = false
	_set_busy(false, "Reproduzindo replay MVP...")
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
