extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const BattleVisualMockupScript := preload("res://ui/battle_visual_mockup.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")
const ProgressionClarityPresenterScript := preload("res://modes/boot/surfaces/progression_clarity_presenter.gd")

const EMPTY_BATTLE_TEXT := "Nenhuma batalha carregada. Solicite uma batalha, carregue o historico ou busque o ultimo resultado."
const EMPTY_HISTORY_TEXT := "Historico recente vazio para este save."
const MAX_RENDERED_HISTORY_ENTRIES := 5
const ACTION_SKIP_REPLAY := AppShellActionContractScript.ACTION_SKIP_REPLAY
const ACTION_RETURN_REFUGE := AppShellActionContractScript.ACTION_RETURN_REFUGE
const ACTION_SHOW_CURRENT_LOGS := AppShellActionContractScript.ACTION_SHOW_CURRENT_BATTLE_LOGS
const ACTION_RETURN_SUMMARY := AppShellActionContractScript.ACTION_RETURN_BATTLE_SUMMARY
const SUMMARY_RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "po_osso", "diamante"]
const UX_BATTLE_BACKGROUND := "res://assets/ux_overhaul/battle_duel_stage.png"

var _host: Node
var _visual: Control
var _timeline_label: Label
var _duel_matchup_label: Label
var _duel_progress_label: Label
var _duel_state_label: Label
var _timeline_lines: PackedStringArray = PackedStringArray()
var _duel_visible_events := 0
var _duel_total_events := 0

func clear() -> void:
	_host = null
	_visual = null
	_timeline_label = null
	_duel_matchup_label = null
	_duel_progress_label = null
	_duel_state_label = null
	_timeline_lines = PackedStringArray()
	_duel_visible_events = 0
	_duel_total_events = 0

func render(
	host: Node,
	compact_layout: bool,
	battle_log: Dictionary,
	rewards: Dictionary,
	has_battle_log: bool,
	history_entries: Array[Dictionary] = []
) -> void:
	clear()
	_host = host
	_call_host("_add_body_text", ["Entre na arena, veja o duelo e volte ao Refugio com o resultado da luta."])
	_call_host("_add_action_button", ["Solicitar batalha", AppShellActionContractScript.ACTION_REQUEST_BATTLE])
	_call_host("_add_action_button", ["Historico", AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY])
	_call_host("_add_action_button", ["Ver resultado", AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE])
	_render_history_entries(history_entries)

	_visual = BattleVisualMockupScript.new()
	_visual.custom_minimum_size = Vector2(0, 560 if compact_layout else 720)
	_call_host("_add_content_control", [_visual])
	_timeline_label = _call_host("_add_output_label", [""]) as Label

	if has_battle_log:
		show_battle_log(battle_log, rewards)
	else:
		show_empty_state(EMPTY_BATTLE_TEXT)

func render_request_splash(host: Node, compact_layout: bool) -> void:
	clear()
	_host = host
	_call_host("_add_content_control", [_request_splash(compact_layout)])

func render_fullscreen_replay(
	host: Node,
	parent: Control,
	compact_layout: bool,
	battle_log: Dictionary,
	rewards: Dictionary
) -> void:
	clear()
	_host = host
	_add_fullscreen_background(parent)
	var frame := _add_portrait_frame(parent, compact_layout)
	frame.name = "BattleRunningStageFrame"
	var stage_column := VBoxContainer.new()
	stage_column.add_theme_constant_override("separation", 8 if compact_layout else 10)
	stage_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(stage_column)

	stage_column.add_child(_battle_duel_shell_band(battle_log, rewards, compact_layout))

	_visual = BattleVisualMockupScript.new()
	_visual.name = "BattleDuelVisual"
	if _visual.has_method("set_stage_only_mode"):
		_visual.set_stage_only_mode(true)
	_visual.custom_minimum_size = Vector2(0, 0)
	_visual.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_visual.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stage_column.add_child(_visual)
	_timeline_label = null

	var skip_row := HBoxContainer.new()
	skip_row.name = "BattleSkipRow"
	skip_row.alignment = BoxContainer.ALIGNMENT_END
	skip_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_column.add_child(skip_row)
	var skip_button := _fullscreen_action_button("Pular batalha", ACTION_SKIP_REPLAY, Vector2(132, 44) if compact_layout else Vector2(152, 48))
	skip_button.name = "BattleSkipButton"
	skip_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	skip_row.add_child(skip_button)

func render_fullscreen_summary(
	host: Node,
	parent: Control,
	compact_layout: bool,
	battle_log: Dictionary,
	rewards: Dictionary,
	current_resources: Dictionary,
	skipped: bool
) -> void:
	clear()
	_host = host
	_add_fullscreen_background(parent)
	var frame := _add_portrait_frame(parent, compact_layout)
	frame.name = "BattleSummaryFrame"
	var stack := VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 14 if compact_layout else 18)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(stack)

	var summary := summary_data(battle_log, rewards, current_resources)
	var arena_log := _is_arena_battle_log(battle_log)
	stack.add_child(_fullscreen_center_label("Resultado da Arena" if arena_log else "Resultado da batalha", 18 if compact_layout else 24, "text_secondary"))
	var result_label := _fullscreen_center_label(str(summary.get("winner_label", "Resultado")), 34 if compact_layout else 44, "text_primary")
	result_label.name = "BattleSummaryResult"
	stack.add_child(result_label)
	var outcome_text := str(summary.get("outcome_text", ""))
	if outcome_text != "":
		var outcome_label := _fullscreen_center_label(outcome_text, 14 if compact_layout else 17, "text_secondary")
		outcome_label.name = "BattleSummaryOutcomeLabel"
		stack.add_child(outcome_label)
	if skipped:
		stack.add_child(_fullscreen_center_label("Resultado aberto sem assistir todos os lances.", 13 if compact_layout else 15, "text_secondary"))

	var details := GridContainer.new()
	details.columns = 1
	details.add_theme_constant_override("separation", 8 if compact_layout else 10)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(details)
	if arena_log:
		details.add_child(_summary_detail_panel("Combate", _arena_combat_summary_text(battle_log, summary), compact_layout))
		details.add_child(_summary_detail_panel("Recompensa", _arena_reward_summary_text(rewards), compact_layout))
		var next_step_text := str(summary.get("next_step_text", ""))
		if next_step_text != "":
			details.add_child(_summary_detail_panel("Proximo passo", next_step_text, compact_layout))
	else:
		var reward_text := str(summary.get("reward_text", ""))
		if reward_text != "":
			details.add_child(_summary_detail_panel("Recompensa", reward_text, compact_layout))
		var resources_text := str(summary.get("resources_text", ""))
		if resources_text != "":
			details.add_child(_summary_detail_panel("Recursos", resources_text, compact_layout))
		var ranking_text := str(summary.get("ranking_text", ""))
		if ranking_text != "":
			details.add_child(_summary_detail_panel("Ranking", ranking_text, compact_layout))
		var progress_text := str(summary.get("progress_text", ""))
		if progress_text != "":
			details.add_child(_summary_detail_panel("Progresso", progress_text, compact_layout))
		var next_step_text := str(summary.get("next_step_text", ""))
		if next_step_text != "":
			details.add_child(_summary_detail_panel("Proximo passo", next_step_text, compact_layout))
	stack.add_child(_fullscreen_center_label(
		"Resumo da Arena pronto. Siga a tentativa ou volte ao Refugio para evoluir." if arena_log else "Recompensa registrada. Volte para verificar a base e escolher o proximo passo.",
		13 if compact_layout else 15,
		"text_secondary"
	))

	var actions := GridContainer.new()
	actions.columns = 1
	actions.add_theme_constant_override("separation", 8 if compact_layout else 12)
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.custom_minimum_size = Vector2(0, 112 if compact_layout else 128)
	stack.add_child(actions)
	actions.add_child(_fullscreen_action_button("Voltar ao Refugio" if arena_log else "Voltar e verificar base", ACTION_RETURN_REFUGE, Vector2(0, 58)))
	actions.add_child(_fullscreen_action_button("Ver logs da batalha", ACTION_SHOW_CURRENT_LOGS, Vector2(0, 48)))
	_timeline_label = null

func render_fullscreen_logs(
	host: Node,
	parent: Control,
	compact_layout: bool,
	battle_log: Dictionary,
	rewards: Dictionary
) -> void:
	clear()
	_host = host
	_add_fullscreen_background(parent)
	var frame := _add_portrait_frame(parent, compact_layout)
	frame.name = "BattleLogsFrame"
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8 if compact_layout else 12)
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_child(stack)

	stack.add_child(_fullscreen_center_label("Logs da batalha", 20 if compact_layout else 28, "text_primary"))
	stack.add_child(_fullscreen_label(BattleLogPresenterScript.format_summary(battle_log, rewards), 11 if compact_layout else 13, "text_secondary"))

	var scroll := ScrollContainer.new()
	scroll.name = "BattleLogsScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stack.add_child(scroll)

	_timeline_label = _fullscreen_label(_current_battle_logs_text(battle_log), 12 if compact_layout else 14, "text_primary")
	_timeline_label.name = "BattleLogsList"
	_timeline_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_timeline_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_timeline_label)
	scroll.resized.connect(func() -> void:
		if _timeline_label != null and is_instance_valid(_timeline_label):
			_timeline_label.custom_minimum_size.x = maxf(0.0, scroll.size.x - 18.0)
	)

	var actions := GridContainer.new()
	actions.columns = 1
	actions.add_theme_constant_override("separation", 8 if compact_layout else 12)
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(actions)
	actions.add_child(_fullscreen_action_button("Voltar ao Resultado", ACTION_RETURN_SUMMARY, Vector2(0, 56)))
	actions.add_child(_fullscreen_action_button("Voltar ao Refugio", ACTION_RETURN_REFUGE, Vector2(0, 56)))

func get_timeline_label() -> Label:
	return _timeline_label

func get_visual() -> Control:
	return _visual

func show_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.load_battle_log(battle_log, rewards)
		_visual.reveal_all()
	_set_timeline_text(_visual.get_timeline_text() if _visual != null and is_instance_valid(_visual) else BattleLogPresenterScript.format_summary(battle_log, rewards))

func show_empty_state(message: String = EMPTY_BATTLE_TEXT) -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.show_empty_state(message)
	_set_timeline_text(message)

func begin_replay(battle_log: Dictionary, rewards: Dictionary) -> void:
	_timeline_lines = _initial_replay_lines(battle_log, rewards)
	_duel_visible_events = 0
	_duel_total_events = sorted_events(battle_log).size()
	if _visual != null and is_instance_valid(_visual):
		_visual.load_battle_log(battle_log, rewards)
		set_replay_time(0.0)
	_update_duel_shell_status("Aguardando primeiro lance", 0)
	_refresh_timeline()

func append_event(event: Dictionary) -> void:
	_timeline_lines.append(BattleLogPresenterScript.format_event(event))
	_duel_visible_events = mini(_duel_visible_events + 1, max(_duel_total_events, _duel_visible_events + 1))
	if _visual != null and is_instance_valid(_visual):
		_visual.step_next_event()
	_update_duel_shell_status(_event_state_text(event), _duel_visible_events)
	_refresh_timeline()

func reveal_all_events(events: Array[Dictionary]) -> void:
	for event: Dictionary in events:
		var formatted := BattleLogPresenterScript.format_event(event)
		if not _timeline_lines.has(formatted):
			_timeline_lines.append(formatted)
	_duel_total_events = maxi(_duel_total_events, events.size())
	_duel_visible_events = _duel_total_events
	if _visual != null and is_instance_valid(_visual):
		_visual.reveal_all()
	var final_state := "Todos os lances exibidos"
	if not events.is_empty():
		final_state = _event_state_text(events[events.size() - 1])
	_update_duel_shell_status(final_state, _duel_visible_events)
	_refresh_timeline()

func reveal_all() -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.reveal_all()
	_duel_visible_events = _duel_total_events
	_update_duel_shell_status("Todos os lances exibidos", _duel_visible_events)

func set_replay_time(replay_time: float) -> void:
	if _visual != null and is_instance_valid(_visual) and _visual.has_method("set_replay_time"):
		_visual.set_replay_time(replay_time)

func sorted_events(battle_log: Dictionary) -> Array[Dictionary]:
	return BattleLogPresenterScript.sorted_events(battle_log)

func build_warning_text(battle_log: Dictionary, expected_mode: String) -> String:
	var battle_mode := str(battle_log.get("mode", ""))
	var spell_count := BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast")
	if BattleLogPresenterScript.has_unknown_events(battle_log):
		return "Aviso: esta luta tem um lance que ainda nao possui apresentacao completa."
	if battle_mode != expected_mode:
		return "Aviso: esta batalha usa uma versao diferente. Solicite uma nova luta se algo parecer estranho."
	if spell_count <= 0:
		return "Aviso: esta luta nao registrou habilidades."
	return ""

static func history_entry_title(entry: Dictionary, index: int = 0) -> String:
	var result := _winner_text(_as_dictionary(entry.get("result", {})))
	return "Batalha %d | %s" % [index + 1, result]

static func history_entry_detail(entry: Dictionary) -> String:
	var opponent := _as_dictionary(entry.get("opponent", {}))
	var rewards := _as_dictionary(entry.get("rewards", {}))
	var created_at := str(entry.get("created_at", ""))
	var opponent_name := str(opponent.get("display_name", "oponente")).strip_edges()
	if opponent_name == "":
		opponent_name = "oponente"
	var event_count := int(entry.get("event_count", 0))
	return "%s | %s eventos | %.1fs | recompensa %s | vs %s" % [
		created_at if created_at != "" else "sem data",
		str(event_count),
		float(entry.get("duration", 0.0)),
		_reward_text(rewards),
		opponent_name,
	]

static func summary_data(battle_log: Dictionary, rewards: Dictionary, current_resources: Dictionary = {}) -> Dictionary:
	var result := _as_dictionary(battle_log.get("result", {}))
	var winner := str(result.get("winner", ""))
	var events := BattleLogPresenterScript.sorted_events(battle_log)
	var duration := float(battle_log.get("duration", -1.0))
	if duration < 0.0 and not events.is_empty():
		duration = float(events[events.size() - 1].get("t", 0.0))
	if duration < 0.0:
		duration = 0.0
	var arena_log := _is_arena_battle_log(battle_log)
	var ranking_text := "" if arena_log else _ranking_text(result)
	if ranking_text == "" and not arena_log:
		var competition_state := _as_dictionary(SessionStore.competition_snapshot())
		ranking_text = _ranking_text(_as_dictionary(competition_state.get("last_battle", {})))
	return {
		"winner": winner,
		"winner_label": _winner_summary_text(winner),
		"player_label": _participant_label(battle_log, "player", "Jogador"),
		"opponent_label": _participant_label(battle_log, "opponent", "Oponente"),
		"outcome_text": _outcome_text(battle_log, result, winner, duration),
		"duration": duration,
		"duration_text": "%.1fs" % duration,
		"event_count": events.size(),
		"mode": str(battle_log.get("mode", "MVP_ONLY")),
		"reward_text": _reward_text(rewards),
		"resources_text": _resources_text(current_resources),
		"ranking_text": ranking_text,
		"progress_text": ProgressionClarityPresenterScript.battle_summary_text(rewards, SessionStore.combat_build_snapshot()),
		"next_step_text": _summary_next_step_text(rewards, battle_log),
	}

static func current_battle_logs_text(battle_log: Dictionary) -> String:
	var events := BattleLogPresenterScript.sorted_events(battle_log)
	if events.is_empty():
		return "Nenhum evento textual carregado para esta batalha."
	var lines := PackedStringArray()
	for index in range(events.size()):
		lines.append("%02d. %s" % [index + 1, BattleLogPresenterScript.format_event(events[index])])
	return "\n".join(lines)

func _initial_replay_lines(battle_log: Dictionary, rewards: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	if _is_arena_battle_log(battle_log):
		lines.append(_arena_replay_header_text(battle_log, rewards))
	else:
		lines.append(BattleLogPresenterScript.format_summary(battle_log, rewards))
	var spell_count := BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast")
	var weapon_count := BattleLogPresenterScript.count_events_of_type(battle_log, "weapon_attack")
	var pet_count := BattleLogPresenterScript.count_events_of_type(battle_log, "pet_attack")
	var summon_count := BattleLogPresenterScript.count_events_of_type(battle_log, "summon_attack")
	lines.append("Lances: %d habilidades | %d ataques | %d familiares | %d invocacoes" % [
		spell_count,
		weapon_count,
		pet_count,
		summon_count,
	])
	return lines

func _render_history_entries(history_entries: Array[Dictionary]) -> void:
	_call_host("_add_section_label", ["Historico recente"])
	if history_entries.is_empty():
		_call_host("_add_body_text", [EMPTY_HISTORY_TEXT])
		return

	var count := mini(history_entries.size(), MAX_RENDERED_HISTORY_ENTRIES)
	for index in range(count):
		var entry := history_entries[index]
		var battle_id := str(entry.get("battle_id", "")).strip_edges()
		if battle_id == "":
			continue
		_call_host("_add_body_text", [
			"%s\n%s" % [history_entry_title(entry, index), history_entry_detail(entry)],
		])
		_call_host("_add_action_button", [
			"Assistir %d" % (index + 1),
			AppShellActionContractScript.battle_replay_action(battle_id),
		])

static func _winner_text(result: Dictionary) -> String:
	match str(result.get("winner", "")):
		"player":
			return "vitoria"
		"opponent":
			return "derrota"
		"draw":
			return "empate"
		_:
			return "resultado"

static func _winner_summary_text(winner: String) -> String:
	match winner:
		"player":
			return "Vitoria"
		"opponent":
			return "Derrota"
		"draw":
			return "Empate"
		_:
			return "Resultado"

static func _reward_text(rewards: Dictionary) -> String:
	var resources := _as_dictionary(rewards.get("resources", {}))
	if resources.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for key in ["xp", "almas", "energia", "sangue", "cristais", "ossos", "po_osso", "diamante"]:
		if not resources.has(key):
			continue
		parts.append("%s +%s" % [_resource_label(key), str(resources.get(key, 0))])
	return ", ".join(parts)

static func _resources_text(resources: Dictionary) -> String:
	if resources.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for key in SUMMARY_RESOURCE_KEYS:
		if resources.has(key):
			parts.append("%s %s" % [_resource_label(key), str(resources.get(key, 0))])
	if parts.is_empty():
		return ""
	return ", ".join(parts)

static func _resource_label(key: String) -> String:
	match key:
		"xp":
			return "XP"
		"po_osso":
			return "Po de Osso"
		"diamante":
			return "Diamantes"
		_:
			return key.capitalize()

static func _participant_label(battle_log: Dictionary, participant_key: String, fallback: String) -> String:
	var participants := _as_dictionary(battle_log.get("participants", {}))
	var participant := _as_dictionary(participants.get(participant_key, {}))
	var display_name := str(participant.get("display_name", "")).strip_edges()
	if display_name != "":
		return display_name
	return fallback

static func _outcome_text(battle_log: Dictionary, result: Dictionary, winner: String, duration: float) -> String:
	var opponent_label := _participant_label(battle_log, "opponent", "Oponente")
	var reason := _reason_text(str(result.get("reason", "")), winner)
	var arena_context := _arena_duel_text(battle_log)
	if arena_context != "":
		return "%s contra %s - %s em %.1fs." % [arena_context, opponent_label, reason, duration]
	return "Contra %s - %s em %.1fs." % [opponent_label, reason, duration]

static func _arena_combat_summary_text(battle_log: Dictionary, summary: Dictionary) -> String:
	var arena_context := _arena_duel_text(battle_log)
	var duration_text := str(summary.get("duration_text", "0.0s"))
	var event_count := int(summary.get("event_count", 0))
	var player_label := str(summary.get("player_label", _participant_label(battle_log, "player", "Jogador")))
	var opponent_label := str(summary.get("opponent_label", _participant_label(battle_log, "opponent", "Oponente")))
	if arena_context == "":
		arena_context = "Duelo da Arena"
	return "%s\nMatchup: %s vs %s\nAdversario: %s\nLances: %d | Duracao: %s" % [
		arena_context,
		player_label,
		opponent_label,
		opponent_label,
		event_count,
		duration_text,
	]

static func _reason_text(reason: String, winner: String) -> String:
	match reason:
		"opponent_defeated":
			return "oponente caiu" if winner == "player" else "duelo encerrado"
		"player_defeated":
			return "jogador caiu" if winner == "opponent" else "duelo encerrado"
		"draw":
			return "empate confirmado"
		"timeout":
			return "tempo esgotado"
		_:
			match winner:
				"player":
					return "vitoria confirmada"
				"opponent":
					return "derrota confirmada"
				"draw":
					return "empate confirmado"
				_:
					return "desfecho registrado"

static func _ranking_text(result: Dictionary) -> String:
	var ranking := _as_dictionary(result.get("ranking", {}))
	var arena_delta := int(result.get("arena_delta", result.get("arena_delta_raw", 0)))
	if ranking.is_empty() and arena_delta == 0 and not result.has("rank"):
		return ""
	var parts: PackedStringArray = PackedStringArray()
	if arena_delta != 0:
		parts.append("%s%d pontos de arena" % ["+" if arena_delta > 0 else "", arena_delta])
	var rank_value := str(ranking.get("rank", result.get("rank", ""))).strip_edges()
	if rank_value != "":
		parts.append("posicao #%s" % rank_value)
	var arena_points := str(ranking.get("arena_points", result.get("arena_points", ""))).strip_edges()
	if arena_points != "":
		parts.append("%s pontos totais" % arena_points)
	return ", ".join(parts)

static func _summary_next_step_text(rewards: Dictionary, battle_log: Dictionary = {}) -> String:
	var reward_text := _reward_text(rewards)
	if _is_arena_battle_log(battle_log):
		if reward_text != "":
			return "Proximo passo: continuar na Arena, ou sair para usar %s no Refugio. Nao ha cooldown de combate." % reward_text
		return "Proximo passo: continuar a tentativa para buscar o clear, ou voltar ao Refugio para revisar loadout e base."
	if reward_text != "":
		return "Use %s no Refugio: colete, evolua a base quando houver Energia e peca outra batalha." % reward_text
	return "Volte ao Refugio para conferir coleta, evolucao e preparacao antes da proxima batalha."

static func _is_arena_battle_log(battle_log: Dictionary) -> bool:
	var metadata := _as_dictionary(battle_log.get("metadata", {}))
	return str(metadata.get("mode", battle_log.get("mode", ""))) == "PVE_ARENA_V1"

static func _arena_duel_text(battle_log: Dictionary) -> String:
	var metadata := _as_dictionary(battle_log.get("metadata", {}))
	if not _is_arena_battle_log(battle_log):
		return ""
	var duel_index := int(metadata.get("duel_index", 0))
	var duel_count := int(metadata.get("duel_count", 0))
	if duel_index <= 0 or duel_count <= 0:
		return "Duelo da Arena"
	return "Duelo %d/%d da Arena" % [duel_index, duel_count]

static func _arena_replay_header_text(battle_log: Dictionary, rewards: Dictionary) -> String:
	var events := BattleLogPresenterScript.sorted_events(battle_log)
	var arena_context := _arena_duel_text(battle_log)
	if arena_context == "":
		arena_context = "Duelo da Arena"
	return "%s\nMatchup: %s\nLances carregados: %d\n%s" % [
		arena_context,
		_matchup_text(battle_log),
		events.size(),
		_duel_reward_text(rewards),
	]

static func _arena_reward_summary_text(rewards: Dictionary) -> String:
	var reward_text := _reward_text(rewards)
	if reward_text == "":
		return "Recompensa do duelo/clear: nenhuma recompensa aplicada neste duelo. O clear final da tentativa e o ponto em que o servidor aplica progresso e recursos."
	return "Recompensa do duelo/clear: %s\nRecompensa aplicada: %s ja veio do servidor para o save; continuar apenas confirma o resumo." % [reward_text, reward_text]

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

func _refresh_timeline() -> void:
	_set_timeline_text("\n".join(_timeline_lines))

func _set_timeline_text(text: String) -> void:
	if _timeline_label != null and is_instance_valid(_timeline_label):
		_timeline_label.text = text

func _current_battle_logs_text(battle_log: Dictionary) -> String:
	return current_battle_logs_text(battle_log)

func _request_splash(compact_layout: bool) -> Control:
	var splash := Control.new()
	splash.name = "BattleRequestSplash"
	splash.custom_minimum_size = Vector2(0, 520 if compact_layout else 640)
	splash.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	splash.size_flags_vertical = Control.SIZE_EXPAND_FILL
	splash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	splash.clip_contents = true
	_add_battle_background_layers(splash, 0.88, 0.34, 0.12)
	return splash

func _battle_duel_shell_band(battle_log: Dictionary, _rewards: Dictionary, compact_layout: bool) -> PanelContainer:
	_duel_total_events = sorted_events(battle_log).size()
	_duel_visible_events = 0
	var arena_log := _is_arena_battle_log(battle_log)

	var panel := PanelContainer.new()
	panel.name = "BattleDuelShellBand"
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "accent_battle"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var shell_height := 86 if compact_layout else 96
	if arena_log:
		shell_height = 118 if compact_layout else 132
	panel.custom_minimum_size = Vector2(0, shell_height)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4 if compact_layout else 6)
	panel.add_child(stack)

	if arena_log:
		var arena_label := _fullscreen_center_label(_arena_duel_text(battle_log), 14 if compact_layout else 16, "text_primary")
		arena_label.name = "BattleDuelArenaContextLabel"
		stack.add_child(arena_label)

	_duel_matchup_label = _fullscreen_center_label(_matchup_text(battle_log), 15 if compact_layout else 18, "text_primary")
	_duel_matchup_label.name = "BattleDuelMatchupLabel"
	stack.add_child(_duel_matchup_label)

	var status_row := HBoxContainer.new()
	status_row.name = "BattleDuelStatusRow"
	status_row.alignment = BoxContainer.ALIGNMENT_CENTER
	status_row.add_theme_constant_override("separation", 8 if compact_layout else 12)
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(status_row)

	_duel_progress_label = _fullscreen_center_label("", 12 if compact_layout else 14, "text_secondary")
	_duel_progress_label.name = "BattleDuelProgressLabel"
	_duel_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_child(_duel_progress_label)

	_duel_state_label = _fullscreen_center_label("", 12 if compact_layout else 14, "text_secondary")
	_duel_state_label.name = "BattleDuelStateLabel"
	_duel_state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_child(_duel_state_label)

	if arena_log:
		var reward_label := _fullscreen_center_label(_duel_reward_text(_rewards), 12 if compact_layout else 14, "text_secondary")
		reward_label.name = "BattleDuelRewardLabel"
		stack.add_child(reward_label)

	_update_duel_shell_status("Aguardando primeiro lance", 0)
	return panel

static func _duel_reward_text(rewards: Dictionary) -> String:
	var reward_text := _reward_text(rewards)
	if reward_text == "":
		return "Recompensa do duelo: sem aplicacao ainda; busque o clear."
	return "Recompensa do duelo: %s | clear/aplicada no save." % reward_text

static func _matchup_text(battle_log: Dictionary) -> String:
	return "%s vs %s" % [
		_participant_label(battle_log, "player", "Jogador"),
		_participant_label(battle_log, "opponent", "Oponente"),
	]

func _update_duel_shell_status(state_text: String, visible_events: int = -1) -> void:
	if visible_events >= 0:
		_duel_visible_events = clampi(visible_events, 0, max(_duel_total_events, visible_events))
	if _duel_progress_label != null and is_instance_valid(_duel_progress_label):
		if _duel_total_events > 0:
			_duel_progress_label.text = "Lances %d/%d" % [_duel_visible_events, _duel_total_events]
		else:
			_duel_progress_label.text = "Sem lances carregados"
	if _duel_state_label != null and is_instance_valid(_duel_state_label):
		_duel_state_label.text = state_text if state_text != "" else "Duelo em andamento"

func _event_state_text(event: Dictionary) -> String:
	match str(event.get("type", "")):
		"battle_start":
			return "Batalha iniciada"
		"battle_result":
			return "Resultado definido"
		"spell_cast":
			return "Habilidade conjurada"
		"weapon_attack":
			return "Ataque registrado"
		"pet_attack":
			return "Familiar avancou"
		"summon_attack":
			return "Aliado avancou"
		"dot_tick":
			return "Efeito continuo"
		"heal", "consumable_use":
			return "Recuperacao usada"
		_:
			return "Novo lance registrado"

func _add_fullscreen_background(parent: Control) -> void:
	_add_battle_background_layers(parent, 0.70, 0.58, 0.22)

func _add_battle_background_layers(parent: Control, art_alpha: float, void_alpha: float, blood_alpha: float) -> void:
	if ResourceLoader.exists(UX_BATTLE_BACKGROUND):
		var loaded_texture := load(UX_BATTLE_BACKGROUND)
		if loaded_texture is Texture2D:
			var art := TextureRect.new()
			art.name = "BattleRequestSplashArt" if parent.name == "BattleRequestSplash" else "BattleFullscreenBackgroundArt"
			art.texture = loaded_texture as Texture2D
			art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			art.modulate = Color(1, 1, 1, art_alpha)
			art.mouse_filter = Control.MOUSE_FILTER_IGNORE
			art.set_anchors_preset(Control.PRESET_FULL_RECT)
			parent.add_child(art)
	var wash := ColorRect.new()
	wash.name = "BattleBackgroundVoidWash"
	wash.color = UiTokens.color("bg_void")
	wash.color.a = void_alpha
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(wash)
	var blood := ColorRect.new()
	blood.name = "BattleBackgroundBloodWash"
	blood.color = UiTokens.color("bg_blood_wash")
	blood.color.a = blood_alpha
	blood.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(blood)

func _add_portrait_frame(parent: Control, compact_layout: bool) -> PanelContainer:
	var safe_frame := Control.new()
	safe_frame.name = "BattleSafeFrame"
	parent.add_child(safe_frame)
	var sync_frame := func() -> void:
		var viewport_size := parent.get_viewport_rect().size
		if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
			viewport_size = parent.size
		if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
			viewport_size = Vector2(390, 844)
		var safe_rect := MobileUiContractScript.immersive_safe_rect(viewport_size, compact_layout)
		safe_frame.position = safe_rect.position
		safe_frame.size = safe_rect.size
	sync_frame.call()
	parent.resized.connect(sync_frame)

	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", _panel_style("bg_panel_alt", "border_default"))
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_frame.add_child(frame)
	return frame

func _battle_header_panel(battle_log: Dictionary, rewards: Dictionary, compact_layout: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4 if compact_layout else 6)
	panel.add_child(stack)
	stack.add_child(_fullscreen_label("Arena", 20 if compact_layout else 24, "text_primary"))
	stack.add_child(_fullscreen_label(BattleLogPresenterScript.format_summary(battle_log, rewards), 11 if compact_layout else 13, "text_secondary"))
	return panel

func _fullscreen_label(text: String, font_size: int, color_token: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _fullscreen_center_label(text: String, font_size: int, color_token: String) -> Label:
	var label := _fullscreen_label(text, font_size, color_token)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func _add_summary_stat(parent: Node, label_text: String, value_text: String, compact_layout: bool) -> void:
	parent.add_child(_fullscreen_label(label_text, 13 if compact_layout else 15, "text_secondary"))
	parent.add_child(_fullscreen_label(value_text, 15 if compact_layout else 18, "text_primary"))

func _summary_detail_panel(title: String, text: String, compact_layout: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 5 if compact_layout else 8)
	panel.add_child(stack)
	stack.add_child(_fullscreen_label(title, 14 if compact_layout else 17, "text_primary"))
	stack.add_child(_fullscreen_label(text, 12 if compact_layout else 14, "text_secondary"))
	return panel

func _fullscreen_action_button(text: String, action_id: String, min_size: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = text
	button.custom_minimum_size = min_size
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_call_host("_prepare_touch_button", [button])
	var primary := action_id == ACTION_RETURN_REFUGE or action_id == ACTION_RETURN_SUMMARY
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_stylebox_override("normal", _fullscreen_button_style(primary, false))
	button.add_theme_stylebox_override("hover", _fullscreen_button_style(primary, true))
	button.add_theme_stylebox_override("pressed", _fullscreen_button_style(primary, true))
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(func() -> void:
		_call_host("_trigger_action", [action_id])
	)
	if _host != null and is_instance_valid(_host):
		var buttons: Variant = _host.get("_action_buttons")
		if buttons is Dictionary:
			var action_buttons: Dictionary = buttons
			action_buttons[action_id] = button
	return button

func _fullscreen_button_style(primary: bool, active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := UiTokens.color("accent_astral" if primary else "border_default")
	style.bg_color = UiTokens.color("bg_panel").lerp(accent, 0.18 if primary else 0.06)
	if active:
		style.bg_color = style.bg_color.lerp(accent, 0.10)
	style.border_color = accent
	style.set_border_width_all(2 if primary else 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _panel_style(background_token: String, border_token: String) -> StyleBoxFlat:
	return _call_host("_panel_style", [background_token, border_token]) as StyleBoxFlat

func _call_host(method_name: StringName, args: Array = []) -> Variant:
	if _host == null or not is_instance_valid(_host) or not _host.has_method(method_name):
		push_error("BattleReplayPresenter host missing method: %s" % str(method_name))
		return null
	return _host.callv(method_name, args)
