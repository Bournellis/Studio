class_name DraxosArenaSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const PreparationPresenterScript := preload("res://modes/boot/surfaces/hub_surface_preparation_presenter.gd")
const ArenaSurfaceTextScript := preload("res://modes/boot/surfaces/arena_surface_text.gd")

func render_selection(host: Node) -> void:
	var arena := SessionStore.arena_snapshot()
	_call_host(host, "_add_body_text", ["Escolha uma Arena PVE. O loadout trava ao iniciar; buffs e comportamento ficam entre vitorias."])
	if _has_remote_arena_state(arena):
		var arenas := _as_array(arena.get("arenas", []))
		_render_recommended_arena(host, arenas)
		_add_arena_preparation_control(host, false)
		_render_available_arenas(host, arenas)
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
	_call_host(host, "_add_body_text", ["Loadout travado para esta tentativa. Voce ainda pode ajustar comportamento simples entre duelos."])
	_add_loadout_details_control(host, attempt)
	_call_host(host, "_add_action_button", ["Continuar com loadout travado", AppShellActionContractScript.ACTION_ARENA_LOCK_LOADOUT])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_active(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	_call_host(host, "_add_body_text", ["Tentativa em andamento. Cada duelo comeca com HP cheio."])
	_add_duel_progress_rail(host, attempt)
	_add_loadout_details_control(host, attempt)
	_add_attempt_summary_panel(host, attempt)
	if bool(host.get_meta("arena_active_preparation_open", false)):
		_add_arena_preparation_control(host, true)
	if not _pending_buff_choices(attempt).is_empty():
		_call_host(host, "_add_action_button", ["Escolher buff", AppShellActionContractScript.arena_choose_buff_action(_first_buff_id(attempt))])
	else:
		_call_host(host, "_add_action_button", ["Resolver duelo", AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL])
	if not bool(host.get_meta("arena_active_preparation_open", false)):
		_call_host(host, "_add_action_button", ["Ajustar comportamento", AppShellActionContractScript.ACTION_SHOW_PREPARATION])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_buff_choice(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	var choices := _pending_buff_choices(attempt)
	_call_host(host, "_add_body_text", ["Escolha 1 buff temporario para os proximos duelos desta tentativa."])
	if choices.is_empty():
		_call_host(host, "_add_output_label", ["Nenhum buff pendente. Volte para a tentativa ativa."])
		_call_host(host, "_add_action_button", ["Continuar tentativa", AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL])
		return
	_add_buff_choice_cards(host, choices)

func render_summary(host: Node) -> void:
	var arena := SessionStore.arena_snapshot()
	var attempt := SessionStore.active_arena_attempt()
	var summary := _as_dictionary(arena.get("summary", attempt.get("summary", {})))
	_call_host(host, "_add_body_text", ["Tentativa encerrada. Quando houve clear, a recompensa ja foi aplicada pelo ultimo duelo; este passo apenas atualiza a Arena."])
	_call_host(host, "_add_output_label", [_summary_text(attempt, summary)])
	_call_host(host, "_add_action_button", ["Continuar na Arena", AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_replay(host: Node, overlay: Control, compact_layout: bool, battle_log: Dictionary, rewards: Dictionary) -> void:
	var presenter = host.get("_battle_replay_presenter")
	presenter.render_fullscreen_replay(host, overlay, compact_layout, battle_log, rewards)

func _render_available_arenas(host: Node, arenas: Array) -> void:
	if arenas.is_empty():
		_render_dev_fallback_arenas(host)
		return
	var panel := _arena_panel(host, "ArenaAlternativesPanel", "bg_panel", "border_default")
	var stack := _arena_panel_stack(panel, 7)
	stack.add_child(_arena_label("Outras arenas", 14, "text_primary"))
	stack.add_child(_arena_label("Escolha outra lista ou veja por que ela ainda esta bloqueada.", 12, "text_secondary"))
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
			var label := _arena_button_label(arena, difficulty)
			var action_id := AppShellActionContractScript.arena_start_action(arena_id, difficulty_id)
			var unlocked := _arena_is_unlocked(difficulty) and _arena_is_unlocked(arena)
			var locked_reason := _arena_locked_reason(difficulty if not _arena_is_unlocked(difficulty) else arena)
			if not unlocked:
				label = "%s | bloqueada" % label
			stack.add_child(_arena_action_button(host, label, action_id, not unlocked, locked_reason))
			if not unlocked:
				stack.add_child(_arena_label("bloqueada: %s" % locked_reason, 11, "text_secondary"))
	_call_host(host, "_add_content_control", [panel])

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
	var label := "Iniciar Arena PVE"
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
	stack.add_child(_arena_action_button(host, label, action_id, false, "", true))
	_call_host(host, "_add_content_control", [panel])

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
			stack.add_child(_arena_label("Fica aqui, logo abaixo de Iniciar Arena PVE. Carregue para revisar loadout, Pocao e comportamento antes de iniciar.", 12, "text_secondary"))
			stack.add_child(_arena_action_button(host, "Carregar Preparacao", AppShellActionContractScript.ACTION_SHOW_PREPARATION, false, "", true))
		_call_host(host, "_add_content_control", [panel])
		return
	var context := "arena_active_behavior" if behavior_only else "arena_pre_start"
	_call_host(host, "_add_content_control", [PreparationPresenterScript.preparation_panel(host, compact, context)])

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
	stack.add_child(_arena_label("Estado: %s | Buffs ativos: %d" % [
		_friendly_attempt_state(_attempt_state(attempt)),
		_as_array(attempt.get("temporary_buffs", [])).size(),
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
	button.text = text
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
	var label := str(choice.get("display_name", buff_id)).strip_edges()
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
