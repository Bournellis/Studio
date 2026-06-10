class_name DraxosArenaSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const PreparationPresenterScript := preload("res://modes/boot/surfaces/hub_surface_preparation_presenter.gd")
const ArenaSurfaceTextScript := preload("res://modes/boot/surfaces/arena_surface_text.gd")

func render_selection(host: Node) -> void:
	var arena := SessionStore.arena_snapshot()
	var active_attempt := SessionStore.active_arena_attempt()
	if _selection_blocks_on_attempt(active_attempt):
		_call_host(host, "_add_body_text", ["Existe uma tentativa de Arena aberta. Retome ou encerre antes de iniciar outra."])
		_render_active_attempt_recovery(host, active_attempt)
		_add_arena_preparation_control(host, true)
		_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])
		return
	_call_host(host, "_add_body_text", ["Escolha uma Arena PVE. O loadout trava ao iniciar; buffs e comportamento ficam entre vitorias."])
	if _has_remote_arena_state(arena):
		var arenas := _as_array(arena.get("arenas", []))
		var progress := _as_dictionary(arena.get("progress", {}))
		var recommended_action_id := _recommended_start_action_id(arenas)
		_render_season_progress_panel(host, arenas, progress)
		_render_recommended_arena(host, arenas)
		_add_arena_preparation_control(host, false)
		_render_available_arenas(host, arenas, recommended_action_id)
	else:
		_render_dev_fallback_arenas(host)
		_add_arena_preparation_control(host, false)
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_loading_selection(host: Node) -> void:
	_call_host(host, "_add_body_text", ["Carregando Arena PVE. As opcoes aparecem assim que o save sincronizar."])
	_call_host(host, "_add_output_label", ["Sincronizando Arena PVE\nBuscando arenas e tentativa ativa.\nNenhuma tentativa local sera iniciada antes da resposta remota."])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_loadout(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	_call_host(host, "_add_body_text", ["Loadout ja foi travado ao iniciar esta tentativa. Siga para o proximo duelo ou ajuste apenas comportamento simples."])
	_call_host(host, "_add_action_button", ["Continuar com loadout travado", AppShellActionContractScript.ACTION_ARENA_LOCK_LOADOUT])
	_add_loadout_details_control(host, attempt)
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_active(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	if _attempt_needs_recovery(attempt):
		_call_host(host, "_add_body_text", ["Uma tentativa antiga ficou aberta antes do update. Encerre esta tentativa para liberar uma nova Arena."])
		_render_active_attempt_recovery(host, attempt)
		_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])
		return
	_call_host(host, "_add_body_text", ["Tentativa em andamento. Cada duelo comeca com HP cheio."])
	_add_duel_progress_rail(host, attempt)
	_add_attempt_summary_panel(host, attempt)
	if not _pending_buff_choices(attempt).is_empty():
		_call_host(host, "_add_action_button", ["Escolher buff", AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT])
	else:
		_call_host(host, "_add_action_button", ["Resolver duelo", AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL])
	_add_arena_preparation_control(host, true)
	_add_loadout_details_control(host, attempt)
	_call_host(host, "_add_action_button", ["Abandonar tentativa", AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_buff_choice(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	var choices := _pending_buff_choices(attempt)
	_call_host(host, "_add_body_text", ["Escolha 1 buff temporario para os proximos duelos desta tentativa."])
	if choices.is_empty():
		_call_host(host, "_add_output_label", ["Nenhum buff pendente. Volte para a tentativa ativa."])
		_call_host(host, "_add_action_button", ["Retomar tentativa", AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT])
		_add_arena_preparation_control(host, true)
		_call_host(host, "_add_action_button", ["Abandonar tentativa", AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT])
		return
	_add_buff_choice_cards(host, choices)
	_add_arena_preparation_control(host, true)
	_call_host(host, "_add_action_button", ["Abandonar tentativa", AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT])

func render_summary(host: Node) -> void:
	var arena := SessionStore.arena_snapshot()
	var attempt := SessionStore.active_arena_attempt()
	var summary := _as_dictionary(arena.get("summary", attempt.get("summary", {})))
	_call_host(host, "_add_body_text", ["Tentativa encerrada. Quando houve clear, a recompensa ja foi aplicada pelo ultimo duelo; este passo apenas atualiza a Arena."])
	_call_host(host, "_add_output_label", [_summary_text(attempt, summary)])
	_render_summary_next_step(host)
	_call_host(host, "_add_action_button", ["Continuar na Arena", AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_replay(host: Node, overlay: Control, compact_layout: bool, battle_log: Dictionary, rewards: Dictionary) -> void:
	var presenter = host.get("_battle_replay_presenter")
	presenter.render_fullscreen_replay(host, overlay, compact_layout, battle_log, rewards)

func _render_available_arenas(host: Node, arenas: Array, recommended_action_id: String = "") -> void:
	if arenas.is_empty():
		_render_dev_fallback_arenas(host)
		return
	var progress := _as_dictionary(SessionStore.arena_snapshot().get("progress", {}))
	_call_host(host, "_add_section_label", ["Outras arenas"])
	for arena_variant: Variant in arenas:
		var arena := _as_dictionary(arena_variant)
		var arena_id := str(arena.get("id", "")).strip_edges()
		if arena_id == "":
			continue
		_render_arena_group(host, arena, progress, recommended_action_id)

func _render_recommended_arena(host: Node, arenas: Array) -> void:
	var recommendation := _recommended_arena_option(arenas)
	if recommendation.is_empty():
		return
	var arena := _as_dictionary(recommendation.get("arena", {}))
	var difficulty := _as_dictionary(recommendation.get("difficulty", {}))
	var arena_id := str(arena.get("id", "")).strip_edges()
	var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
	if arena_id == "":
		return
	var label := "Iniciar desafio recomendado"
	var action_id := AppShellActionContractScript.arena_start_action(arena_id, difficulty_id)
	var panel := _arena_panel(host, "ArenaRecommendedCard", "bg_panel_alt", "accent_battle")
	var stack := _arena_panel_stack(panel, 7)
	stack.add_child(_arena_label("Proximo desafio", 15, "text_primary"))
	stack.add_child(_arena_label("%s\n%s duelo%s | %s | Lv %s | Poder %s" % [
		str(arena.get("display_name", arena_id)),
		str(difficulty.get("max_steps", arena.get("duel_count", 1))),
		"" if int(difficulty.get("max_steps", arena.get("duel_count", 1))) == 1 else "s",
		_difficulty_label(difficulty),
		_level_range_text(difficulty),
		_power_range_text(difficulty),
	], 13, "text_secondary"))
	stack.add_child(_arena_label("Progresso S1: %s | Recompensa prevista: %s" % [
		_tier_status_text(arena_id, difficulty, _as_dictionary(SessionStore.arena_snapshot().get("progress", {}))),
		_reward_preview_text(_as_dictionary(difficulty.get("reward_preview", arena.get("reward_preview", {})))),
	], 12, "text_secondary"))
	stack.add_child(_arena_action_button(host, label, action_id, false, "", true))
	_call_host(host, "_add_content_control", [panel])

func _render_season_progress_panel(host: Node, arenas: Array, progress: Dictionary) -> void:
	var totals := _season_progress_counts(arenas, progress)
	var recommendation := _recommended_arena_option(arenas)
	var next_text := "Complete o tutorial para abrir a primeira arena curta."
	if not recommendation.is_empty():
		var arena := _as_dictionary(recommendation.get("arena", {}))
		var difficulty := _as_dictionary(recommendation.get("difficulty", {}))
		next_text = "%s - %s" % [
			str(arena.get("display_name", str(arena.get("id", "Arena PVE")))),
			_difficulty_meta_text(difficulty),
		]
	var panel := _arena_panel(host, "ArenaSeason1ProgressPanel", "bg_panel", "border_default")
	var stack := _arena_panel_stack(panel, 7)
	stack.add_child(_arena_label("Temporada 1", 14, "text_primary"))
	stack.add_child(_arena_label("Progresso S1: %d/%d dificuldades concluidas | %d liberadas" % [
		int(totals.get("completed", 0)),
		int(totals.get("total", 0)),
		int(totals.get("unlocked", 0)),
	], 12, "text_secondary"))
	stack.add_child(_arena_label("Proximo recomendado: %s" % next_text, 12, "text_secondary"))
	_call_host(host, "_add_content_control", [panel])

func _render_arena_group(host: Node, arena: Dictionary, progress: Dictionary, recommended_action_id: String = "") -> void:
	var arena_id := str(arena.get("id", "")).strip_edges()
	if arena_id == "":
		return
	var difficulties := _as_array(arena.get("difficulties", []))
	if difficulties.is_empty():
		difficulties = [arena]
	var next_option := _best_option_for_arena(arena, progress)
	var panel := _arena_panel(host, "ArenaSeason1Group_%s" % arena_id, "bg_panel", "border_default")
	var stack := _arena_panel_stack(panel, 7)
	stack.add_child(_arena_label(str(arena.get("display_name", arena_id)), 14, "text_primary"))
	var description := str(arena.get("description", "")).strip_edges()
	if description != "":
		stack.add_child(_arena_label(description, 12, "text_secondary"))
	stack.add_child(_arena_label("%s | %d duelo%s | %d/%d dificuldades concluidas" % [
		_short_arena_label(arena),
		int(arena.get("duel_count", arena.get("max_steps", 1))),
		"" if int(arena.get("duel_count", arena.get("max_steps", 1))) == 1 else "s",
		_arena_completed_count(arena_id, difficulties, progress),
		difficulties.size(),
	], 12, "text_secondary"))
	if not _arena_is_unlocked(arena):
		stack.add_child(_arena_label("bloqueada: %s" % _arena_locked_reason(arena), 12, "text_secondary"))
	elif not next_option.is_empty():
		var next_difficulty := _as_dictionary(next_option.get("difficulty", {}))
		stack.add_child(_arena_label("Proximo desta arena: %s" % _difficulty_detail_text(next_difficulty), 12, "text_secondary"))
	stack.add_child(_arena_label("Dificuldades", 12, "text_primary"))
	for difficulty_variant: Variant in difficulties:
		var difficulty := _as_dictionary(difficulty_variant)
		var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
		var unlocked := _arena_is_unlocked(arena) and _arena_is_unlocked(difficulty)
		var locked_reason := _difficulty_locked_reason(arena, difficulty)
		var action_id := AppShellActionContractScript.arena_start_action(arena_id, difficulty_id)
		var label := _difficulty_action_label(arena_id, difficulty, progress)
		if not unlocked:
			label = "%s | bloqueada" % label
		var is_next := unlocked and not next_option.is_empty() and difficulty_id == str(_as_dictionary(next_option.get("difficulty", {})).get("difficulty_id", ""))
		if action_id == recommended_action_id:
			stack.add_child(_arena_label("%s | recomendado acima" % label, 12, "text_secondary"))
		else:
			stack.add_child(_arena_action_button(host, label, action_id, not unlocked, locked_reason, is_next))
		stack.add_child(_arena_label(_difficulty_detail_text(difficulty) if unlocked else "bloqueada: %s" % locked_reason, 11, "text_secondary"))
	_call_host(host, "_add_content_control", [panel])

func _render_summary_next_step(host: Node) -> void:
	var arena := SessionStore.arena_snapshot()
	var arenas := _as_array(arena.get("arenas", []))
	if arenas.is_empty():
		return
	var recommendation := _recommended_arena_option(arenas)
	if recommendation.is_empty():
		return
	var next_arena := _as_dictionary(recommendation.get("arena", {}))
	var difficulty := _as_dictionary(recommendation.get("difficulty", {}))
	var panel := _arena_panel(host, "ArenaSeason1NextStepPanel", "bg_panel_alt", "accent_battle")
	var stack := _arena_panel_stack(panel, 7)
	stack.add_child(_arena_label("Proximo passo S1", 14, "text_primary"))
	stack.add_child(_arena_label("%s\n%s" % [
		str(next_arena.get("display_name", next_arena.get("id", "Arena PVE"))),
		_difficulty_detail_text(difficulty),
	], 12, "text_secondary"))
	stack.add_child(_arena_label("Continuar na Arena confirma o resumo e abre a lista atualizada de desafios.", 12, "text_secondary"))
	_call_host(host, "_add_content_control", [panel])

func _render_active_attempt_recovery(host: Node, attempt: Dictionary) -> void:
	var needs_recovery := _attempt_needs_recovery(attempt)
	var panel_name := "ArenaAttemptRecoveryPanel" if needs_recovery else "ArenaActiveAttemptPanel"
	var panel := _arena_panel(host, panel_name, "bg_panel_alt", "accent_battle")
	var stack := _arena_panel_stack(panel, 7)
	stack.add_child(_arena_label("Tentativa ativa encontrada", 15, "text_primary"))
	var status := _friendly_attempt_state(_attempt_state(attempt))
	if needs_recovery:
		stack.add_child(_arena_label("Esta tentativa ficou aberta antes do update ou esta sem proximo passo valido. Encerre a tentativa antiga para liberar uma nova run.", 12, "text_secondary"))
	else:
		stack.add_child(_arena_label("Retome esta tentativa antes de iniciar outra Arena. O loadout segue travado ate encerrar.", 12, "text_secondary"))
	stack.add_child(_arena_label("Estado: %s | %s" % [status, _duel_progress_short_text(attempt)], 12, "text_secondary"))
	if needs_recovery:
		stack.add_child(_arena_action_button(host, "Encerrar tentativa antiga", AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT, false, "", true))
	else:
		stack.add_child(_arena_action_button(host, "Retomar tentativa", AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT, false, "", true))
		stack.add_child(_arena_action_button(host, "Abandonar tentativa", AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT))
	_call_host(host, "_add_content_control", [panel])
	_add_duel_progress_rail(host, attempt)

func _add_arena_preparation_control(host: Node, behavior_only: bool) -> void:
	var compact := bool(host.get("_compact_layout"))
	if SessionStore.combat_build_snapshot().is_empty():
		var panel_name := "ArenaActivePreparationPanel" if behavior_only else "ArenaPreparationPanel"
		var panel := _arena_panel(host, panel_name, "bg_panel", "border_default")
		var stack := _arena_panel_stack(panel, 7)
		stack.add_child(_arena_label("Preparacao", 14, "text_primary"))
		if behavior_only:
			stack.add_child(_arena_label("Carregue o estado atual para ajustar apenas comportamento entre duelos. O loadout desta tentativa ja esta travado.", 12, "text_secondary"))
			stack.add_child(_arena_action_button(host, "Carregar comportamento", AppShellActionContractScript.ACTION_SHOW_PREPARATION, false, "", true))
		else:
			stack.add_child(_arena_label("Revise loadout, Pocao e comportamento antes de iniciar. O desafio recomendado fica acima para manter o fluxo claro.", 12, "text_secondary"))
			stack.add_child(_arena_action_button(host, "Carregar Preparacao", AppShellActionContractScript.ACTION_SHOW_PREPARATION, false, "", true))
		_call_host(host, "_add_content_control", [panel])
		return
	var context := "arena_active_behavior" if behavior_only else "arena_pre_start"
	_call_host(host, "_add_content_control", [PreparationPresenterScript.preparation_panel(host, compact, context)])

func _recommended_start_action_id(arenas: Array) -> String:
	var recommendation := _recommended_arena_option(arenas)
	if recommendation.is_empty():
		return ""
	var arena := _as_dictionary(recommendation.get("arena", {}))
	var difficulty := _as_dictionary(recommendation.get("difficulty", {}))
	var arena_id := str(arena.get("id", "")).strip_edges()
	var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
	if arena_id == "":
		return ""
	return AppShellActionContractScript.arena_start_action(arena_id, difficulty_id)

func _recommended_arena_option(arenas: Array) -> Dictionary:
	var progress := _as_dictionary(SessionStore.arena_snapshot().get("progress", {}))
	var first_unlocked := {}
	for arena_variant: Variant in arenas:
		var arena := _as_dictionary(arena_variant)
		if not _arena_is_unlocked(arena):
			continue
		var arena_id := str(arena.get("id", "")).strip_edges()
		if arena_id == "":
			continue
		var difficulties := _as_array(arena.get("difficulties", []))
		if difficulties.is_empty():
			difficulties = [arena]
		for difficulty_variant: Variant in difficulties:
			var difficulty := _as_dictionary(difficulty_variant)
			if not _arena_is_unlocked(difficulty):
				continue
			var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
			var option := {"arena": arena, "difficulty": difficulty}
			if first_unlocked.is_empty():
				first_unlocked = option
			if not _tier_completed(arena_id, difficulty_id, progress):
				return option
	return first_unlocked

func _best_option_for_arena(arena: Dictionary, progress: Dictionary) -> Dictionary:
	if not _arena_is_unlocked(arena):
		return {}
	var arena_id := str(arena.get("id", "")).strip_edges()
	if arena_id == "":
		return {}
	var first_unlocked := {}
	var difficulties := _as_array(arena.get("difficulties", []))
	if difficulties.is_empty():
		difficulties = [arena]
	for difficulty_variant: Variant in difficulties:
		var difficulty := _as_dictionary(difficulty_variant)
		if not _arena_is_unlocked(difficulty):
			continue
		var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
		var option := {"arena": arena, "difficulty": difficulty}
		if first_unlocked.is_empty():
			first_unlocked = option
		if not _tier_completed(arena_id, difficulty_id, progress):
			return option
	return first_unlocked

func _season_progress_counts(arenas: Array, progress: Dictionary) -> Dictionary:
	var total := 0
	var unlocked := 0
	var completed := 0
	for arena_variant: Variant in arenas:
		var arena := _as_dictionary(arena_variant)
		var arena_id := str(arena.get("id", "")).strip_edges()
		if arena_id == "":
			continue
		var difficulties := _as_array(arena.get("difficulties", []))
		if difficulties.is_empty():
			difficulties = [arena]
		for difficulty_variant: Variant in difficulties:
			var difficulty := _as_dictionary(difficulty_variant)
			var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
			total += 1
			if _arena_is_unlocked(arena) and _arena_is_unlocked(difficulty):
				unlocked += 1
			if _tier_completed(arena_id, difficulty_id, progress):
				completed += 1
	return {"total": total, "unlocked": unlocked, "completed": completed}

func _arena_completed_count(arena_id: String, difficulties: Array, progress: Dictionary) -> int:
	var count := 0
	for difficulty_variant: Variant in difficulties:
		var difficulty := _as_dictionary(difficulty_variant)
		var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
		if _tier_completed(arena_id, difficulty_id, progress):
			count += 1
	return count

func _difficulty_action_label(arena_id: String, difficulty: Dictionary, progress: Dictionary) -> String:
	return "%s | %s duelo%s | %s" % [
		_difficulty_label(difficulty),
		str(difficulty.get("max_steps", difficulty.get("enemy_count", 1))),
		"" if int(difficulty.get("max_steps", difficulty.get("enemy_count", 1))) == 1 else "s",
		_tier_status_text(arena_id, difficulty, progress),
	]

func _difficulty_detail_text(difficulty: Dictionary) -> String:
	return "%s | Recompensa prevista: %s" % [
		_difficulty_meta_text(difficulty),
		_reward_preview_text(_as_dictionary(difficulty.get("reward_preview", {}))),
	]

func _difficulty_locked_reason(arena: Dictionary, difficulty: Dictionary) -> String:
	if not _arena_is_unlocked(arena):
		return _arena_locked_reason(arena)
	if not _arena_is_unlocked(difficulty):
		return _arena_locked_reason(difficulty)
	return ""

func _render_dev_fallback_arenas(host: Node) -> void:
	_call_host(host, "_add_output_label", ["Estado remoto da Arena indisponivel. Fallback dev local: tutorial e arena curta."])
	_call_host(host, "_add_action_button", ["Tutorial 1 duelo", AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL])
	_call_host(host, "_add_action_button", ["Arena inicial 3 duelos", AppShellActionContractScript.ACTION_ARENA_START_EARLY])

func _duel_progress_text(attempt: Dictionary) -> String:
	return ArenaSurfaceTextScript.duel_progress_text(attempt)

func _add_duel_progress_rail(host: Node, attempt: Dictionary) -> void:
	var duels_won := clampi(int(attempt.get("duels_won", attempt.get("current_step_index", 0))), 0, 99)
	var duel_index := int(attempt.get("duel_index", duels_won))
	var duels_total := maxi(1, int(attempt.get("duel_count", attempt.get("duels_total", 1))))
	var state := _attempt_state(attempt)
	var current_duel := clampi(duel_index + 1, 1, duels_total)
	if state in ["completed", "claimed"]:
		current_duel = duels_total

	var panel := _arena_panel(host, "ArenaDuelProgressRail", "bg_panel", "border_default")
	var stack := _arena_panel_stack(panel, 7)
	stack.add_child(_arena_label("Progresso dos duelos", 14, "text_primary"))
	var legacy_text := _arena_label(_duel_progress_text(attempt), 1, "text_secondary")
	legacy_text.name = "ArenaDuelProgressRailText"
	legacy_text.visible = false
	stack.add_child(legacy_text)
	var rail := HBoxContainer.new()
	rail.name = "ArenaDuelProgressRailSteps"
	rail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rail.add_theme_constant_override("separation", 6)
	stack.add_child(rail)

	for index in range(1, duels_total + 1):
		var step_state := "waiting"
		if index <= duels_won or state in ["completed", "claimed"]:
			step_state = "won"
		elif state == "failed" and index == current_duel:
			step_state = "failed"
		elif index == current_duel:
			step_state = "current"
		rail.add_child(_duel_progress_step(index, step_state))

	stack.add_child(_arena_label("%d de %d vencidos" % [clampi(duels_won, 0, duels_total), duels_total], 12, "text_secondary"))
	_call_host(host, "_add_content_control", [panel])

func _duel_progress_step(index: int, step_state: String) -> PanelContainer:
	var step := PanelContainer.new()
	step.name = "ArenaDuelProgressStep%d" % index
	step.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	step.custom_minimum_size = Vector2(0, 38)
	step.add_theme_stylebox_override("panel", _duel_progress_step_style(step_state))

	var label := _arena_label(str(index), 13, "text_primary")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.tooltip_text = _duel_progress_step_tooltip(index, step_state)
	step.tooltip_text = label.tooltip_text
	step.add_child(label)
	return step

func _duel_progress_step_tooltip(index: int, step_state: String) -> String:
	return ArenaSurfaceTextScript.duel_progress_step_tooltip(index, step_state)

func _duel_progress_step_style(step_state: String) -> StyleBoxFlat:
	var color_token := "border_default"
	var blend := 0.08
	match step_state:
		"won":
			color_token = "status_success"
			blend = 0.24
		"failed":
			color_token = "status_error"
			blend = 0.22
		"current":
			color_token = "accent_battle"
			blend = 0.28
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel").lerp(UiTokens.color(color_token), blend)
	style.border_color = UiTokens.color(color_token)
	style.set_border_width_all(2 if step_state == "current" else 1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _add_attempt_summary_panel(host: Node, attempt: Dictionary) -> void:
	var panel := _arena_panel(host, "ArenaAttemptSummaryPanel", "bg_panel", "border_default")
	var stack := _arena_panel_stack(panel, 6)
	var duels_won := int(attempt.get("duels_won", attempt.get("current_step_index", 0)))
	var next_duel := int(attempt.get("duel_index", duels_won)) + 1
	var duels_total := maxi(1, int(attempt.get("duel_count", attempt.get("duels_total", 1))))
	stack.add_child(_arena_label("Proximo duelo", 14, "text_primary"))
	stack.add_child(_arena_label("Duelo atual: %d/%d" % [clampi(next_duel, 1, duels_total), duels_total], 12, "text_secondary"))
	stack.add_child(_arena_label("Proximo inimigo: %s" % _next_enemy_label(attempt), 12, "text_secondary"))
	stack.add_child(_arena_label("Estado: %s | Buffs ativos: %s" % [
		_friendly_attempt_state(_attempt_state(attempt)),
		ArenaSurfaceTextScript.active_buff_summary_text(attempt),
	], 12, "text_secondary"))
	stack.add_child(_arena_label("Comportamento: ajustavel entre duelos", 12, "text_secondary"))
	stack.add_child(_arena_label("Loadout travado. Pocao tambem pode ser ajustada antes do duelo.", 12, "text_secondary"))
	_call_host(host, "_add_content_control", [panel])

func _add_loadout_details_control(host: Node, attempt: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.name = "ArenaLoadoutDetailsPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style_variant: Variant = _call_host(host, "_panel_style", ["bg_panel", "border_default"])
	if style_variant is StyleBox:
		panel.add_theme_stylebox_override("panel", style_variant)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	panel.add_child(stack)

	var title := _arena_label("Loadout travado", 14, "text_primary")
	stack.add_child(title)
	var summary := _arena_label(_loadout_locked_summary_text(attempt), 12, "text_secondary")
	stack.add_child(summary)

	var details := _arena_label(_loadout_details_text(attempt), 12, "text_secondary")
	details.name = "ArenaLoadoutDetailsText"
	details.visible = false
	stack.add_child(details)

	var toggle := Button.new()
	toggle.name = "ArenaLoadoutDetailsToggle"
	toggle.text = "Mostrar detalhes do loadout"
	toggle.tooltip_text = "Abre um resumo read-only do loadout travado nesta tentativa."
	toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_call_host(host, "_prepare_touch_button", [toggle])
	toggle.pressed.connect(func() -> void:
		details.visible = not details.visible
		toggle.text = "Ocultar detalhes do loadout" if details.visible else "Mostrar detalhes do loadout"
	)
	stack.add_child(toggle)
	_call_host(host, "_add_content_control", [panel])

func _arena_label(text: String, font_size: int, color_token: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _arena_panel(host: Node, name: String, bg_token: String, border_token: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style_variant: Variant = _call_host(host, "_panel_style", [bg_token, border_token])
	if style_variant is StyleBox:
		panel.add_theme_stylebox_override("panel", style_variant)
	return panel

func _arena_panel_stack(panel: PanelContainer, separation: int) -> VBoxContainer:
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", separation)
	panel.add_child(stack)
	return stack

func _arena_action_button(
	host: Node,
	text: String,
	action_id: String,
	disabled: bool = false,
	disabled_reason: String = "",
	primary: bool = false
) -> Button:
	var button := Button.new()
	button.name = "ArenaAction_%s" % _control_name_fragment(action_id)
	button.text = text
	button.set_meta("action_id", action_id)
	button.tooltip_text = disabled_reason if disabled_reason.strip_edges() != "" else text
	button.disabled = disabled
	button.set_meta("force_disabled", disabled)
	button.set_meta("disabled_reason", disabled_reason.strip_edges())
	button.custom_minimum_size = Vector2(0, 58 if primary else 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_call_host(host, "_prepare_touch_button", [button])
	_call_host(host, "_apply_action_button_style", [button, action_id])
	button.pressed.connect(func() -> void:
		_call_host(host, "_trigger_action", [action_id, ""])
	)
	var action_buttons: Variant = host.get("_action_buttons")
	if action_buttons is Dictionary:
		var buttons := action_buttons as Dictionary
		buttons[action_id] = button
	return button

func _add_buff_choice_cards(host: Node, choices: Array) -> void:
	var panel := _arena_panel(host, "ArenaBuffChoiceCards", "bg_panel", "border_default")
	var stack := _arena_panel_stack(panel, 8)
	stack.add_child(_arena_label("Escolha um buff temporario", 14, "text_primary"))
	stack.add_child(_arena_label("Vale so para esta tentativa. Compare as 3 opcoes antes do proximo duelo.", 12, "text_secondary"))

	var cards := GridContainer.new()
	cards.name = "ArenaBuffChoiceGrid"
	cards.columns = 1
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("h_separation", 8)
	cards.add_theme_constant_override("v_separation", 8)
	stack.add_child(cards)

	var visible_count := mini(choices.size(), 3)
	for index in range(visible_count):
		var choice := _as_dictionary(choices[index])
		var buff_id := str(choice.get("id", "")).strip_edges()
		if buff_id == "":
			continue
		cards.add_child(_buff_choice_card(host, choice, index + 1, buff_id))
	_call_host(host, "_add_content_control", [panel])

func _buff_choice_card(host: Node, choice: Dictionary, index: int, buff_id: String) -> PanelContainer:
	var card := _arena_panel(host, "ArenaBuffChoiceCard%d" % index, "bg_panel_alt", "border_default")
	var stack := _arena_panel_stack(card, 5)
	var label := ArenaSurfaceTextScript.buff_label_text(choice)
	if label == "":
		label = buff_id
	stack.add_child(_arena_label(label, 13, "text_primary"))
	stack.add_child(_arena_label(_buff_effect_text(choice), 12, "text_secondary"))
	stack.add_child(_arena_label("Temporario: dura ate encerrar esta tentativa.", 11, "text_secondary"))
	stack.add_child(_arena_action_button(host, "Escolher", AppShellActionContractScript.arena_choose_buff_action(buff_id), false, "", true))
	return card

func _buff_effect_text(choice: Dictionary) -> String:
	return ArenaSurfaceTextScript.buff_effect_text(choice)

func _loadout_locked_summary_text(attempt: Dictionary) -> String:
	return ArenaSurfaceTextScript.loadout_locked_summary_text(attempt)

func _loadout_details_text(attempt: Dictionary) -> String:
	return ArenaSurfaceTextScript.loadout_details_text(attempt)

func _loadout_value_text(value: Variant) -> String:
	return ArenaSurfaceTextScript.loadout_value_text(value)

func _humanize_id(value: String) -> String:
	return ArenaSurfaceTextScript.humanize_id(value)

func _next_enemy_label(attempt: Dictionary) -> String:
	return ArenaSurfaceTextScript.next_enemy_label(attempt)

func _summary_text(attempt: Dictionary, summary: Dictionary) -> String:
	return ArenaSurfaceTextScript.summary_text(attempt, summary)

func _has_remote_arena_state(arena: Dictionary) -> bool:
	return not bool(arena.get("dev_fixture", false)) and not _as_array(arena.get("arenas", [])).is_empty()

func _arena_button_label(arena: Dictionary, difficulty: Dictionary = {}) -> String:
	return ArenaSurfaceTextScript.arena_button_label(arena, difficulty)

func _short_arena_label(arena: Dictionary) -> String:
	return ArenaSurfaceTextScript.short_arena_label(arena)

func _difficulty_label(difficulty: Dictionary) -> String:
	return ArenaSurfaceTextScript.difficulty_label(difficulty)

func _difficulty_meta_text(difficulty: Dictionary) -> String:
	return ArenaSurfaceTextScript.difficulty_meta_text(difficulty)

func _reward_preview_text(reward_preview: Dictionary) -> String:
	return ArenaSurfaceTextScript.reward_preview_text(reward_preview)

func _tier_status_text(arena_id: String, difficulty: Dictionary, progress: Dictionary) -> String:
	return ArenaSurfaceTextScript.tier_status_text(arena_id, difficulty, progress)

func _friendly_attempt_state(state: String) -> String:
	return ArenaSurfaceTextScript.friendly_attempt_state(state)

func _tier_completed(arena_id: String, difficulty_id: String, progress: Dictionary) -> bool:
	if arena_id == "arena_tutorial_cinzas" and bool(progress.get("tutorial_completed", false)):
		return true
	var metadata := _as_dictionary(progress.get("metadata", {}))
	var completed_tiers := _as_dictionary(metadata.get("completed_tiers", {}))
	if difficulty_id != "" and bool(completed_tiers.get("%s:%s" % [arena_id, difficulty_id], false)):
		return true
	if difficulty_id != "":
		return false
	var completed_arenas := _as_dictionary(metadata.get("completed_arenas", {}))
	return bool(completed_arenas.get(arena_id, false))

func _level_range_text(difficulty: Dictionary) -> String:
	return ArenaSurfaceTextScript.level_range_text(difficulty)

func _power_range_text(difficulty: Dictionary) -> String:
	return ArenaSurfaceTextScript.power_range_text(difficulty)

func _arena_is_unlocked(arena: Dictionary) -> bool:
	if arena.has("unlocked"):
		return bool(arena.get("unlocked", false))
	return bool(arena.get("enabled", true))

func _arena_locked_reason(arena: Dictionary) -> String:
	return ArenaSurfaceTextScript.arena_locked_reason(arena)

func _first_buff_id(attempt: Dictionary) -> String:
	for choice_variant: Variant in _pending_buff_choices(attempt):
		var choice := _as_dictionary(choice_variant)
		var buff_id := str(choice.get("id", "")).strip_edges()
		if buff_id != "":
			return buff_id
	return ""

func _attempt_state(attempt: Dictionary) -> String:
	return ArenaSurfaceTextScript.attempt_state(attempt)

func _pending_buff_choices(attempt: Dictionary) -> Array:
	var offer := _as_dictionary(attempt.get("buff_offer", {}))
	return _as_array(offer.get("choices", attempt.get("pending_buff_choices", [])))

func _selection_blocks_on_attempt(attempt: Dictionary) -> bool:
	if attempt.is_empty():
		return false
	var status := _attempt_state(attempt)
	return status in ["active", "awaiting_buff"] or _attempt_needs_recovery(attempt)

func _attempt_needs_recovery(attempt: Dictionary) -> bool:
	if attempt.is_empty():
		return false
	var status := _attempt_state(attempt)
	if status in ["completed", "failed", "claimed", "abandoned"]:
		return false
	if status not in ["active", "awaiting_buff", "active_incompatible"]:
		return false
	if _attempt_id(attempt) == "":
		return true
	if status == "active_incompatible":
		return true
	if not _pending_buff_choices(attempt).is_empty():
		return false
	if status == "awaiting_buff":
		return true
	var total := maxi(0, int(attempt.get("duel_count", attempt.get("duels_total", attempt.get("max_steps", 0)))))
	var current := maxi(
		int(attempt.get("current_step_index", 0)),
		int(attempt.get("duels_won", attempt.get("duel_index", 0)))
	)
	return total <= 0 or current >= total

func _attempt_id(attempt: Dictionary) -> String:
	return str(attempt.get("attempt_id", attempt.get("id", ""))).strip_edges()

func _duel_progress_short_text(attempt: Dictionary) -> String:
	var duels_won := clampi(int(attempt.get("duels_won", attempt.get("current_step_index", 0))), 0, 99)
	var duels_total := maxi(1, int(attempt.get("duel_count", attempt.get("duels_total", attempt.get("max_steps", 1)))))
	return "duelos vencidos %d/%d" % [clampi(duels_won, 0, duels_total), duels_total]

func _call_host(host: Node, method: String, args: Array = []) -> Variant:
	if host == null or not host.has_method(method):
		return null
	return host.callv(method, args)

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []

static func _control_name_fragment(value: String) -> String:
	var text := value.strip_edges().to_lower()
	var output := PackedStringArray()
	for index in range(text.length()):
		var character := text.substr(index, 1)
		var code := character.unicode_at(0)
		var valid := (code >= 48 and code <= 57) or (code >= 97 and code <= 122)
		output.append(character if valid else "_")
	var result := "".join(output)
	while result.contains("__"):
		result = result.replace("__", "_")
	result = result.strip_edges()
	while result.begins_with("_"):
		result = result.substr(1)
	while result.ends_with("_"):
		result = result.substr(0, result.length() - 1)
	return result if result != "" else "arena_action"
