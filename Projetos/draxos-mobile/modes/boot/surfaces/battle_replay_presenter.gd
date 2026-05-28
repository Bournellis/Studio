extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const BattleVisualMockupScript := preload("res://ui/battle_visual_mockup.gd")

const EMPTY_BATTLE_TEXT := "Nenhuma batalha carregada. Solicite uma batalha, carregue o historico ou busque o ultimo resultado."
const EMPTY_HISTORY_TEXT := "Historico recente vazio para este save."
const MAX_RENDERED_HISTORY_ENTRIES := 5
const ACTION_SKIP_REPLAY := AppShellActionContractScript.ACTION_SKIP_REPLAY
const ACTION_RETURN_REFUGE := AppShellActionContractScript.ACTION_RETURN_REFUGE
const ACTION_SHOW_CURRENT_LOGS := AppShellActionContractScript.ACTION_SHOW_CURRENT_BATTLE_LOGS
const ACTION_RETURN_SUMMARY := AppShellActionContractScript.ACTION_RETURN_BATTLE_SUMMARY
const SUMMARY_RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]
const UX_BATTLE_BACKGROUND := "res://assets/ux_overhaul/battle_duel_stage.png"

var _host: Node
var _visual: Control
var _timeline_label: Label
var _timeline_lines: PackedStringArray = PackedStringArray()

func clear() -> void:
	_host = null
	_visual = null
	_timeline_label = null
	_timeline_lines = PackedStringArray()

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

func render_fullscreen_replay(
	host: Node,
	parent: Control,
	compact_layout: bool,
	_battle_log: Dictionary,
	_rewards: Dictionary
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
	var skip_button := _fullscreen_action_button("Pular", ACTION_SKIP_REPLAY, Vector2(96, 44) if compact_layout else Vector2(112, 48))
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
	stack.add_child(_fullscreen_center_label("Resultado da batalha", 18 if compact_layout else 24, "text_secondary"))
	var result_label := _fullscreen_center_label(str(summary.get("winner_label", "Resultado")), 34 if compact_layout else 44, "text_primary")
	result_label.name = "BattleSummaryResult"
	stack.add_child(result_label)
	if skipped:
		stack.add_child(_fullscreen_center_label("Batalha pulada para o resultado.", 13 if compact_layout else 15, "text_secondary"))

	var details := GridContainer.new()
	details.columns = 1
	details.add_theme_constant_override("separation", 8 if compact_layout else 10)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.add_child(details)
	var reward_text := str(summary.get("reward_text", ""))
	if reward_text != "":
		details.add_child(_summary_detail_panel("Recompensa", reward_text, compact_layout))
	var resources_text := str(summary.get("resources_text", ""))
	if resources_text != "":
		details.add_child(_summary_detail_panel("Recursos", resources_text, compact_layout))
	var ranking_text := str(summary.get("ranking_text", ""))
	if ranking_text != "":
		details.add_child(_summary_detail_panel("Ranking", ranking_text, compact_layout))

	var actions := GridContainer.new()
	actions.columns = 1
	actions.add_theme_constant_override("separation", 8 if compact_layout else 12)
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.custom_minimum_size = Vector2(0, 112 if compact_layout else 128)
	stack.add_child(actions)
	actions.add_child(_fullscreen_action_button("Voltar ao Refugio", ACTION_RETURN_REFUGE, Vector2(0, 58)))
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
	if _visual != null and is_instance_valid(_visual):
		_visual.load_battle_log(battle_log, rewards)
		set_replay_time(0.0)
	_refresh_timeline()

func append_event(event: Dictionary) -> void:
	_timeline_lines.append(BattleLogPresenterScript.format_event(event))
	if _visual != null and is_instance_valid(_visual):
		_visual.step_next_event()
	_refresh_timeline()

func reveal_all_events(events: Array[Dictionary]) -> void:
	for event: Dictionary in events:
		var formatted := BattleLogPresenterScript.format_event(event)
		if not _timeline_lines.has(formatted):
			_timeline_lines.append(formatted)
	if _visual != null and is_instance_valid(_visual):
		_visual.reveal_all()
	_refresh_timeline()

func reveal_all() -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.reveal_all()

func set_replay_time(replay_time: float) -> void:
	if _visual != null and is_instance_valid(_visual) and _visual.has_method("set_replay_time"):
		_visual.set_replay_time(replay_time)

func sorted_events(battle_log: Dictionary) -> Array[Dictionary]:
	return BattleLogPresenterScript.sorted_events(battle_log)

func build_warning_text(battle_log: Dictionary, expected_mode: String) -> String:
	var battle_mode := str(battle_log.get("mode", ""))
	var spell_count := BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast")
	if BattleLogPresenterScript.has_unknown_events(battle_log):
		return "Aviso: replay contem evento desconhecido; exibindo fallback."
	if battle_mode != expected_mode:
		return "Aviso: replay em modo %s. O rework atual usa %s; gere uma nova batalha com as Edge Functions atualizadas." % [
			battle_mode,
			expected_mode,
		]
	if spell_count <= 0:
		return "Aviso: replay sem habilidades registradas. Verifique se a versao local esta atualizada."
	return ""

static func history_entry_title(entry: Dictionary, index: int = 0) -> String:
	var battle_id := str(entry.get("battle_id", ""))
	var label_id := battle_id.substr(0, 8) if battle_id.length() >= 8 else battle_id
	var result := _winner_text(_as_dictionary(entry.get("result", {})))
	return "#%d %s | %s" % [index + 1, label_id, result]

static func history_entry_detail(entry: Dictionary) -> String:
	var opponent := _as_dictionary(entry.get("opponent", {}))
	var rewards := _as_dictionary(entry.get("rewards", {}))
	var created_at := str(entry.get("created_at", ""))
	var opponent_name := str(opponent.get("display_name", opponent.get("id", "oponente")))
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
	var ranking_text := _ranking_text(result)
	if ranking_text == "":
		var competition_state := _as_dictionary(SessionStore.competition_state)
		ranking_text = _ranking_text(_as_dictionary(competition_state.get("last_battle", {})))
	return {
		"winner": winner,
		"winner_label": _winner_summary_text(winner),
		"duration": duration,
		"duration_text": "%.1fs" % duration,
		"event_count": events.size(),
		"mode": str(battle_log.get("mode", "MVP_ONLY")),
		"reward_text": _reward_text(rewards),
		"resources_text": _resources_text(current_resources),
		"ranking_text": ranking_text,
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
			"Replay %d" % (index + 1),
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
	for key in ["xp", "almas", "energia", "sangue", "cristais", "ossos", "diamante"]:
		if not resources.has(key):
			continue
		parts.append("%s +%s" % [key.capitalize(), str(resources.get(key, 0))])
	return ", ".join(parts)

static func _resources_text(resources: Dictionary) -> String:
	if resources.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for key in SUMMARY_RESOURCE_KEYS:
		if resources.has(key):
			parts.append("%s %s" % [key.capitalize(), str(resources.get(key, 0))])
	if parts.is_empty():
		return ""
	return ", ".join(parts)

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

func _add_fullscreen_background(parent: Control) -> void:
	if ResourceLoader.exists(UX_BATTLE_BACKGROUND):
		var loaded_texture := load(UX_BATTLE_BACKGROUND)
		if loaded_texture is Texture2D:
			var art := TextureRect.new()
			art.texture = loaded_texture as Texture2D
			art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			art.modulate = Color(1, 1, 1, 0.70)
			art.mouse_filter = Control.MOUSE_FILTER_IGNORE
			art.set_anchors_preset(Control.PRESET_FULL_RECT)
			parent.add_child(art)
	var wash := ColorRect.new()
	wash.color = UiTokens.color("bg_void")
	wash.color.a = 0.58
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(wash)
	var blood := ColorRect.new()
	blood.color = UiTokens.color("bg_blood_wash")
	blood.color.a = 0.22
	blood.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(blood)

func _add_portrait_frame(parent: Control, compact_layout: bool) -> PanelContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	var edge := 10 if compact_layout else 18
	margin.add_theme_constant_override("margin_left", edge)
	margin.add_theme_constant_override("margin_top", edge)
	margin.add_theme_constant_override("margin_right", edge)
	margin.add_theme_constant_override("margin_bottom", edge)
	parent.add_child(margin)

	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", _panel_style("bg_panel_alt", "border_default"))
	frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(frame)
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
