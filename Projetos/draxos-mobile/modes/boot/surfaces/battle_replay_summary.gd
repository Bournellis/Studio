extends RefCounted

const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const ProgressionClarityPresenterScript := preload("res://modes/boot/surfaces/progression_clarity_presenter.gd")

const SUMMARY_RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "po_osso", "diamante"]

static func history_entry_title(entry: Dictionary, index: int = 0) -> String:
	var result := winner_text(as_dictionary(entry.get("result", {})))
	return "Batalha %d | %s" % [index + 1, result]

static func history_entry_detail(entry: Dictionary) -> String:
	var opponent := as_dictionary(entry.get("opponent", {}))
	var rewards := as_dictionary(entry.get("rewards", {}))
	var created_at := str(entry.get("created_at", ""))
	var opponent_name := str(opponent.get("display_name", "oponente")).strip_edges()
	if opponent_name == "":
		opponent_name = "oponente"
	var event_count := int(entry.get("event_count", 0))
	return "%s | %s eventos | %.1fs | recompensa %s | vs %s" % [
		created_at if created_at != "" else "sem data",
		str(event_count),
		float(entry.get("duration", 0.0)),
		reward_text(rewards),
		opponent_name,
	]

static func summary_data(battle_log: Dictionary, rewards: Dictionary, current_resources: Dictionary = {}) -> Dictionary:
	var result := as_dictionary(battle_log.get("result", {}))
	var winner := str(result.get("winner", ""))
	var events := BattleLogPresenterScript.sorted_events(battle_log)
	var duration := float(battle_log.get("duration", -1.0))
	if duration < 0.0 and not events.is_empty():
		duration = float(events[events.size() - 1].get("t", 0.0))
	if duration < 0.0:
		duration = 0.0
	var arena_log := is_arena_battle_log(battle_log)
	var ranking := "" if arena_log else ranking_text(result)
	if ranking == "" and not arena_log:
		var competition_state := as_dictionary(SessionStore.competition_snapshot())
		ranking = ranking_text(as_dictionary(competition_state.get("last_battle", {})))
	return {
		"winner": winner,
		"winner_label": winner_summary_text(winner),
		"player_label": participant_label(battle_log, "player", "Jogador"),
		"opponent_label": participant_label(battle_log, "opponent", "Oponente"),
		"outcome_text": outcome_text(battle_log, result, winner, duration),
		"duration": duration,
		"duration_text": "%.1fs" % duration,
		"event_count": events.size(),
		"mode": str(battle_log.get("mode", "MVP_ONLY")),
		"reward_text": reward_text(rewards),
		"resources_text": resources_text(current_resources),
		"ranking_text": ranking,
		"progress_text": ProgressionClarityPresenterScript.battle_summary_text(rewards, SessionStore.combat_build_snapshot()),
		"next_step_text": summary_next_step_text(rewards, battle_log),
	}

static func current_battle_logs_text(battle_log: Dictionary) -> String:
	var events := BattleLogPresenterScript.sorted_events(battle_log)
	if events.is_empty():
		return "Nenhum evento textual carregado para esta batalha."
	var lines := PackedStringArray()
	for index in range(events.size()):
		lines.append("%02d. %s" % [index + 1, BattleLogPresenterScript.format_event(events[index])])
	return "\n".join(lines)

static func winner_text(result: Dictionary) -> String:
	match str(result.get("winner", "")):
		"player":
			return "vitoria"
		"opponent":
			return "derrota"
		"draw":
			return "empate"
		_:
			return "resultado"

static func winner_summary_text(winner: String) -> String:
	match winner:
		"player":
			return "Vitoria"
		"opponent":
			return "Derrota"
		"draw":
			return "Empate"
		_:
			return "Resultado"

static func reward_text(rewards: Dictionary) -> String:
	var resources := as_dictionary(rewards.get("resources", {}))
	if resources.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for key in ["xp", "almas", "energia", "sangue", "cristais", "ossos", "po_osso", "diamante"]:
		if not resources.has(key):
			continue
		parts.append("%s +%s" % [resource_label(key), str(resources.get(key, 0))])
	return ", ".join(parts)

static func resources_text(resources: Dictionary) -> String:
	if resources.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for key in SUMMARY_RESOURCE_KEYS:
		if resources.has(key):
			parts.append("%s %s" % [resource_label(key), str(resources.get(key, 0))])
	if parts.is_empty():
		return ""
	return ", ".join(parts)

static func resource_label(key: String) -> String:
	match key:
		"xp":
			return "XP"
		"po_osso":
			return "Po de Osso"
		"diamante":
			return "Diamantes"
		_:
			return key.capitalize()

static func participant_label(battle_log: Dictionary, participant_key: String, fallback: String) -> String:
	var participants := as_dictionary(battle_log.get("participants", {}))
	var participant := as_dictionary(participants.get(participant_key, {}))
	var display_name := str(participant.get("display_name", "")).strip_edges()
	if display_name != "":
		return display_name
	return fallback

static func outcome_text(battle_log: Dictionary, result: Dictionary, winner: String, duration: float) -> String:
	var opponent_label := participant_label(battle_log, "opponent", "Oponente")
	var reason := reason_text(str(result.get("reason", "")), winner)
	var arena_context := arena_duel_text(battle_log)
	if arena_context != "":
		return "%s contra %s - %s em %.1fs." % [arena_context, opponent_label, reason, duration]
	return "Contra %s - %s em %.1fs." % [opponent_label, reason, duration]

static func arena_combat_summary_text(battle_log: Dictionary, summary: Dictionary) -> String:
	var arena_context := arena_duel_text(battle_log)
	var duration_text := str(summary.get("duration_text", "0.0s"))
	var event_count := int(summary.get("event_count", 0))
	var player_label := str(summary.get("player_label", participant_label(battle_log, "player", "Jogador")))
	var opponent_label := str(summary.get("opponent_label", participant_label(battle_log, "opponent", "Oponente")))
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

static func reason_text(reason: String, winner: String) -> String:
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

static func ranking_text(result: Dictionary) -> String:
	var ranking := as_dictionary(result.get("ranking", {}))
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

static func summary_next_step_text(rewards: Dictionary, battle_log: Dictionary = {}) -> String:
	var reward_summary := reward_text(rewards)
	if is_arena_battle_log(battle_log):
		if reward_summary != "":
			return "Proximo passo: continuar na Arena, ou sair para usar %s no Refugio. Nao ha cooldown de combate." % reward_summary
		return "Proximo passo: continuar a tentativa para buscar o clear, ou voltar ao Refugio para revisar loadout e base."
	if reward_summary != "":
		return "Use %s no Refugio: acompanhe producao, evolua a base quando houver Energia e peca outra batalha." % reward_summary
	return "Volte ao Refugio para conferir producao, evolucao e preparacao antes da proxima batalha."

static func is_arena_battle_log(battle_log: Dictionary) -> bool:
	var metadata := as_dictionary(battle_log.get("metadata", {}))
	return str(metadata.get("mode", battle_log.get("mode", ""))) == "PVE_ARENA_V1"

static func arena_duel_text(battle_log: Dictionary) -> String:
	var metadata := as_dictionary(battle_log.get("metadata", {}))
	if not is_arena_battle_log(battle_log):
		return ""
	var duel_index := int(metadata.get("duel_index", 0))
	var duel_count := int(metadata.get("duel_count", 0))
	if duel_index <= 0 or duel_count <= 0:
		return "Duelo da Arena"
	return "Duelo %d/%d da Arena" % [duel_index, duel_count]

static func arena_replay_header_text(battle_log: Dictionary, rewards: Dictionary) -> String:
	var events := BattleLogPresenterScript.sorted_events(battle_log)
	var arena_context := arena_duel_text(battle_log)
	if arena_context == "":
		arena_context = "Duelo da Arena"
	return "%s\nMatchup: %s\nLances carregados: %d\n%s" % [
		arena_context,
		matchup_text(battle_log),
		events.size(),
		duel_reward_text(rewards),
	]

static func arena_reward_summary_text(rewards: Dictionary) -> String:
	var reward_summary := reward_text(rewards)
	if reward_summary == "":
		return "Recompensa do duelo/clear: nenhuma recompensa aplicada neste duelo. O clear final da tentativa e o ponto em que o servidor aplica progresso e recursos."
	return "Recompensa do duelo/clear: %s\nRecompensa aplicada: %s ja veio do servidor para o save; continuar apenas confirma o resumo." % [reward_summary, reward_summary]

static func duel_reward_text(rewards: Dictionary) -> String:
	var reward_summary := reward_text(rewards)
	if reward_summary == "":
		return "Recompensa do duelo: sem aplicacao ainda; busque o clear."
	return "Recompensa do duelo: %s | clear/aplicada no save." % reward_summary

static func matchup_text(battle_log: Dictionary) -> String:
	return "%s vs %s" % [
		participant_label(battle_log, "player", "Jogador"),
		participant_label(battle_log, "opponent", "Oponente"),
	]

static func as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
