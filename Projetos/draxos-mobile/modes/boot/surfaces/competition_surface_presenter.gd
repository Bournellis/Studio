class_name BootCompetitionSurfacePresenter
extends RefCounted

static func render(host: Node) -> void:
	_add_body_text(host, "Competicao alpha com matchmaking por poder, pontos de arena por batalha normal e leaderboard sem bots.")
	var matchmaking_button := _add_action_button(host, "Preview matchmaking", "show_matchmaking")
	matchmaking_button.tooltip_text = "Mostra o oponente sugerido para o seu poder atual. Bots podem aparecer como alvo de treino, mas nao entram no leaderboard."
	var ranking_button := _add_action_button(host, "Ver ranking", "show_ranking")
	ranking_button.tooltip_text = "Busca o top 10 da season, sua posicao atual e o modelo de pontos de arena aplicado no servidor."
	host.set("_timeline_label", _add_output_label(host, ""))
	var competition_state_container := VBoxContainer.new()
	competition_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	competition_state_container.add_theme_constant_override("separation", 10)
	_content_body(host).add_child(competition_state_container)
	host.set("_competition_state_container", competition_state_container)
	host.call("_render_competition_state")

static func render_state(host: Node) -> void:
	var timeline_label := host.get("_timeline_label") as Label
	if timeline_label == null:
		return
	var competition_state_container := host.get("_competition_state_container") as VBoxContainer
	if competition_state_container != null:
		host.call("_clear_node_children", competition_state_container)
	var competition := _as_dictionary(SessionStore.competition_state)
	if competition.is_empty():
		timeline_label.text = "Competicao ainda nao carregada. Use Preview matchmaking ou Ver ranking."
		if competition_state_container != null:
			competition_state_container.add_child(_base_info_panel(
				host,
				"Leaderboard da Alpha",
				"Batalhas normais atualizam pontos de arena no servidor. Use Ver ranking para carregar o top 10 e a sua posicao."
			))
		return

	var lines := PackedStringArray()
	lines.append("Competicao server-authoritative")
	var last_battle := _as_dictionary(competition.get("last_battle", {}))
	if not last_battle.is_empty():
		if bool(last_battle.get("ranked", false)):
			lines.append("Ultima batalha: %s%d pontos | %s" % [
				"+" if int(last_battle.get("arena_delta", 0)) >= 0 else "",
				int(last_battle.get("arena_delta", 0)),
				_competition_result_text(str(last_battle.get("result", "draw"))),
			])
		else:
			lines.append("Ultima batalha: sem pontuacao (%s)" % str(last_battle.get("excluded_reason", "fora do ranking")))
	var matchmaking := _as_dictionary(competition.get("matchmaking", {}))
	if matchmaking.is_empty():
		lines.append("Matchmaking: ainda nao carregado.")
	else:
		var opponent := _as_dictionary(matchmaking.get("selected_opponent", {}))
		lines.append("Poder: %s" % str(matchmaking.get("player_power", 0)))
		lines.append("Oponente: %s | Poder %s | bot=%s | ranqueado=%s" % [
			str(opponent.get("id", "nenhum")),
			str(opponent.get("power", "?")),
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
		if self_ranking.is_empty():
			lines.append("Arena: save atual fora da competicao.")
		else:
			lines.append("Arena: #%s | %s pontos | %sV/%sD" % [
				str(self_ranking.get("rank", "?")),
				str(self_ranking.get("arena_points", 0)),
				str(self_ranking.get("wins", 0)),
				str(self_ranking.get("losses", 0)),
			])
		lines.append("Top %s | Jogadores ranqueados: %s | bots no ranking: %s" % [
			str(ranking.get("top_limit", 10)),
			str(ranking.get("total_ranked", 0)),
			str(ranking.get("bots_included", false)),
		])
	timeline_label.text = "\n".join(lines)
	_render_competition_panels(host, last_battle, matchmaking, ranking)

static func _render_competition_panels(host: Node, last_battle: Dictionary, matchmaking: Dictionary, ranking: Dictionary) -> void:
	var competition_state_container := host.get("_competition_state_container") as VBoxContainer
	if competition_state_container == null:
		return
	var panels: Array = []
	if not last_battle.is_empty():
		panels.append(_competition_last_battle_panel(host, last_battle))
	panels.append(_competition_matchmaking_panel(host, matchmaking))
	panels.append(_competition_ranking_panel(host, ranking))
	host.call("_add_responsive_panel_layout", competition_state_container, panels, 2)

static func _competition_last_battle_panel(host: Node, last_battle: Dictionary) -> Control:
	var panel := _base_panel(host)
	panel.tooltip_text = "Resumo competitivo retornado pela ultima battle/request. O cliente apenas apresenta estes dados; a pontuacao vem do servidor."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Ultima Batalha Competitiva", "text_primary", 17))
	if not bool(last_battle.get("ranked", false)):
		box.add_child(_base_label(host, "Sem pontuacao: %s" % str(last_battle.get("excluded_reason", "fora do ranking")), "status_warning"))
		return panel
	var ranking := _as_dictionary(last_battle.get("ranking", {}))
	var raw_delta := int(last_battle.get("arena_delta_raw", last_battle.get("arena_delta", 0)))
	var applied_delta := int(last_battle.get("arena_delta", 0))
	var delta_color := "status_success" if raw_delta >= 0 else "status_warning"
	box.add_child(_base_label(host, "%s | Delta %s%d | Total %s pontos" % [
		_competition_result_text(str(last_battle.get("result", "draw"))),
		"+" if applied_delta >= 0 else "",
		applied_delta,
		str(ranking.get("arena_points", 0)),
	], delta_color))
	if raw_delta != applied_delta:
		box.add_child(_base_label(host, "Formula: %s%d | aplicado: %s%d por piso minimo em 0" % [
			"+" if raw_delta >= 0 else "",
			raw_delta,
			"+" if applied_delta >= 0 else "",
			applied_delta,
		], "text_secondary"))
	box.add_child(_base_label(host, "Poder: voce %s vs oponente %s | Modelo %s" % [
		str(last_battle.get("player_power", 0)),
		str(last_battle.get("opponent_power", 0)),
		_competition_scoring_model_text(str(last_battle.get("scoring_model", ""))),
	], "text_secondary"))
	return panel

static func _competition_matchmaking_panel(host: Node, matchmaking: Dictionary) -> Control:
	var panel := _base_panel(host)
	panel.tooltip_text = "Preview de matchmaking: mostra quem o servidor escolheria para uma batalha pelo poder atual."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Matchmaking", "text_primary", 17))
	if matchmaking.is_empty():
		box.add_child(_base_label(host, "Ainda nao carregado. Use Preview matchmaking.", "text_secondary"))
		return panel
	var opponent := _as_dictionary(matchmaking.get("selected_opponent", {}))
	box.add_child(_base_label(host, "Seu poder: %s | candidatos: %s" % [
		str(matchmaking.get("player_power", 0)),
		str(matchmaking.get("candidate_count", "?")),
	], "text_secondary"))
	if opponent.is_empty():
		box.add_child(_base_label(host, "Nenhum oponente disponivel agora.", "status_warning"))
		return panel
	box.add_child(_base_label(host, "Oponente: %s | Poder %s | Faixa %s" % [
		str(opponent.get("id", "desconhecido")),
		str(opponent.get("power", "?")),
		str(opponent.get("power_band", "?")),
	], "text_secondary"))
	box.add_child(_base_label(host, "Bot de treino: %s | Entra no ranking: %s" % [
		"sim" if bool(opponent.get("is_bot", false)) else "nao",
		"sim" if bool(opponent.get("is_ranked", false)) else "nao",
	], "status_warning" if bool(opponent.get("is_bot", false)) else "text_secondary"))
	return panel

static func _competition_ranking_panel(host: Node, ranking: Dictionary) -> Control:
	var panel := _base_panel(host)
	panel.tooltip_text = "Leaderboard da season alpha. Mostra top 10 e sua posicao mesmo quando voce estiver fora do top."
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Leaderboard", "text_primary", 17))
	if ranking.is_empty():
		box.add_child(_base_label(host, "Ainda nao carregado. Use Ver ranking.", "text_secondary"))
		return panel
	if str(ranking.get("excluded_reason", "")) == "PROGRESSION_LAB_DOES_NOT_RANK":
		box.add_child(_base_label(host, "Progression Lab nao pontua competicao e fica fora do leaderboard.", "status_error"))
		return panel
	var season := _as_dictionary(ranking.get("season", {}))
	box.add_child(_base_label(host, "%s | Modelo %s" % [
		str(season.get("display_name", "Season alpha")),
		_competition_scoring_model_text(str(ranking.get("scoring_model", ""))),
	], "text_secondary"))
	var self_ranking := _as_dictionary(ranking.get("self", {}))
	if not self_ranking.is_empty():
		box.add_child(_base_label(host, "Sua posicao: #%s | %s pontos | %sV/%sD" % [
			str(self_ranking.get("rank", "?")),
			str(self_ranking.get("arena_points", 0)),
			str(self_ranking.get("wins", 0)),
			str(self_ranking.get("losses", 0)),
		], "status_success" if bool(ranking.get("self_in_top", false)) else "status_warning"))
	var entries := _as_array(ranking.get("entries", []))
	if entries.is_empty():
		box.add_child(_base_label(host, "Nenhum jogador pontuou ainda nesta season.", "text_secondary"))
		return panel
	box.add_child(_base_label(host, "Top %s" % str(ranking.get("top_limit", 10)), "text_primary"))
	for item: Variant in entries:
		var entry := _as_dictionary(item)
		if entry.is_empty():
			continue
		box.add_child(_base_label(host, "#%s  %s  |  %s pts  |  %sV/%sD" % [
			str(entry.get("rank", "?")),
			_competition_entry_name(entry),
			str(entry.get("arena_points", 0)),
			str(entry.get("wins", 0)),
			str(entry.get("losses", 0)),
		], "status_success" if str(entry.get("player_id", "")) == str(self_ranking.get("player_id", "")) else "text_secondary"))
	return panel

static func _competition_entry_name(entry: Dictionary) -> String:
	var player := _as_dictionary(entry.get("player", {}))
	var username := str(entry.get("username", player.get("username", ""))).strip_edges()
	if username == "":
		username = "jogador"
	var badge := str(player.get("save_badge", "normal"))
	if badge == "lab":
		return "%s [lab]" % username
	return username

static func _competition_result_text(result: String) -> String:
	match result:
		"win":
			return "Vitoria"
		"loss":
			return "Derrota"
	return "Empate"

static func _competition_scoring_model_text(model: String) -> String:
	if model == "alpha_v0_power_adjusted":
		return "alpha v0: +20/-10 ajustado por poder"
	if model.strip_edges() == "":
		return "nao informado"
	return model

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
