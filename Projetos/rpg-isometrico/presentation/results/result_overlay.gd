class_name ResultOverlay
extends CanvasLayer

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

const FRONTEND_SCENE_PATH: String = LocalModeCatalog.FRONTEND_SCENE_PATH

var eyebrow_label: Label
var title_label: Label
var summary_label: Label
var details_scroll: ScrollContainer
var details_label: Label
var return_button: Button

func _ready() -> void:
	visible = false
	layer = 20
	_build_ui()

func bind(session_manager) -> void:
	if session_manager != null and not session_manager.session_ended.is_connected(show_result):
		session_manager.session_ended.connect(show_result)

func show_result(result: Dictionary) -> void:
	visible = true
	var player_victory: bool = bool(result.get("player_victory", false))
	var mode_id: StringName = StringName(str(result.get("mode_id", "")))
	eyebrow_label.text = _build_eyebrow_text(mode_id)
	title_label.text = str(result.get("title", "Vitoria" if player_victory else "Derrota"))
	title_label.modulate = Color(0.76, 0.98, 0.76, 1.0) if player_victory else Color(1.0, 0.72, 0.68, 1.0)
	summary_label.text = _build_result_summary(result)
	details_label.text = _format_result_details(result)
	details_scroll.scroll_vertical = 0
	return_button.text = "Voltar a Campanha e Extras" if _is_campaign_or_extra_mode(mode_id) else "Voltar ao menu local"
	return_button.grab_focus()

func _build_eyebrow_text(mode_id: StringName) -> String:
	if mode_id == LocalModeCatalog.CAMPAIGN_MODE_ID:
		return "RESULTADO DA CAMPANHA"
	if _is_extra_mode(mode_id):
		return "RESULTADO DO EXTRA"
	return "RESULTADO DA SESSAO"

func _build_ui() -> void:
	var backdrop: Control = Control.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var scrim: ColorRect = ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.05, 0.46)
	backdrop.add_child(scrim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(560.0, 0.0)
	center.add_child(panel)

	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.07, 0.08, 0.11, 0.96)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color(0.84, 0.46, 0.24, 0.48)
	style_box.corner_radius_top_left = 18
	style_box.corner_radius_top_right = 18
	style_box.corner_radius_bottom_left = 18
	style_box.corner_radius_bottom_right = 18
	panel.add_theme_stylebox_override("panel", style_box)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var column: VBoxContainer = VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(column)

	eyebrow_label = Label.new()
	eyebrow_label.name = "EyebrowLabel"
	eyebrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow_label.add_theme_font_size_override("font_size", 12)
	eyebrow_label.modulate = Color(0.98, 0.8, 0.56, 1.0)
	column.add_child(eyebrow_label)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.text = "Resultado"
	column.add_child(title_label)

	summary_label = Label.new()
	summary_label.name = "SummaryLabel"
	summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.modulate = Color(0.86, 0.9, 0.96, 1.0)
	column.add_child(summary_label)

	var details_frame: PanelContainer = PanelContainer.new()
	details_frame.custom_minimum_size = Vector2(0.0, 260.0)
	details_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_frame.add_theme_stylebox_override(
		"panel",
		_build_frame_style(Color(0.1, 0.11, 0.15, 0.94), Color(0.84, 0.46, 0.24, 0.14), 14)
	)
	column.add_child(details_frame)

	var details_margin: MarginContainer = MarginContainer.new()
	details_margin.add_theme_constant_override("margin_left", 14)
	details_margin.add_theme_constant_override("margin_top", 12)
	details_margin.add_theme_constant_override("margin_right", 14)
	details_margin.add_theme_constant_override("margin_bottom", 12)
	details_frame.add_child(details_margin)

	details_scroll = ScrollContainer.new()
	details_scroll.name = "DetailsScroll"
	details_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	details_scroll.follow_focus = true
	details_margin.add_child(details_scroll)

	details_label = Label.new()
	details_label.name = "DetailsLabel"
	details_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_label.custom_minimum_size = Vector2(460.0, 0.0)
	details_label.text = ""
	details_label.modulate = Color(0.92, 0.94, 0.98, 1.0)
	details_scroll.add_child(details_label)

	return_button = Button.new()
	return_button.name = "ReturnButton"
	return_button.text = "Voltar ao menu local"
	return_button.custom_minimum_size = Vector2(260.0, 42.0)
	return_button.pressed.connect(_on_return_pressed)
	column.add_child(return_button)

func _build_result_summary(result: Dictionary) -> String:
	var mode_id: StringName = StringName(str(result.get("mode_id", "")))
	var parts: Array[String] = []
	if mode_id != &"":
		parts.append(LocalModeCatalog.get_display_name(mode_id))
	parts.append("Duracao %s" % _format_duration(float(result.get("duration_seconds", 0.0))))
	if bool(result.get("player_victory", false)):
		parts.append("saida positiva")
	else:
		parts.append("retorno por derrota")
	return " | ".join(parts)

func _format_result_details(result: Dictionary) -> String:
	var lines: Array[String] = []
	var mode_id: StringName = StringName(str(result.get("mode_id", "")))
	if mode_id != &"":
		lines.append("Modo: %s" % LocalModeCatalog.get_display_name(mode_id))
	lines.append("Duracao da sessao: %s" % _format_duration(float(result.get("duration_seconds", 0.0))))

	var summary_lines: Variant = result.get("summary_lines", [])
	if summary_lines is Array and not summary_lines.is_empty():
		var summary_section: Array[String] = []
		for line: Variant in summary_lines:
			summary_section.append(str(line))
		_append_section(lines, "Resumo principal", summary_section)

	var round_summary: Dictionary = result.get("round_summary", {})
	var campaign_summary: Dictionary = round_summary.get("campaign", {})
	var survival_summary: Dictionary = round_summary.get("survival", {})
	var boss_summary: Dictionary = round_summary.get("boss", {})
	var extra_mode_summary: Dictionary = round_summary.get("extra_mode", {})
	if not campaign_summary.is_empty():
		_append_section(lines, str(campaign_summary.get("campaign_name", "Campaign 1")), [
			"Dificuldade: %s | etapas concluidas: %d / %d" % [
				str(campaign_summary.get("difficulty_label", "Classic - Easy")),
				int(campaign_summary.get("stages_completed", 0)),
				int(campaign_summary.get("target_stages", 0))
			],
			"Trolls derrotados: %d" % int(campaign_summary.get("enemies_defeated", 0))
		])
	if not survival_summary.is_empty():
		_append_section(lines, "Survival", [
			"Ondas concluidas: %d / %d" % [
				int(survival_summary.get("waves_completed", 0)),
				int(survival_summary.get("target_wave", 0))
			],
			"Maior onda alcancada: %d | Trolls derrotados: %d" % [
				int(survival_summary.get("highest_wave_reached", 0)),
				int(survival_summary.get("enemies_defeated", 0))
			]
		])
	if not boss_summary.is_empty():
		_append_section(lines, str(boss_summary.get("boss_name", "Boss Troll")), [
			"Fase final: %s" % str(boss_summary.get("phase_label", "Fase 1")),
			"Vida restante: %.0f / %.0f" % [
				float(boss_summary.get("remaining_health", 0.0)),
				float(boss_summary.get("max_health", 0.0))
			],
			"Dano sofrido pelo jogador: %.0f" % float(boss_summary.get("player_damage_taken", 0.0))
		])
	if not extra_mode_summary.is_empty():
		_append_extra_mode_section(lines, extra_mode_summary)
	var combatants: Dictionary = round_summary.get("combatants", {})
	var player_stats: Dictionary = combatants.get("player", {})
	var bot_stats: Dictionary = combatants.get("bot", {})
	var boss_stats: Dictionary = combatants.get("boss", {})
	var enemy_stats: Dictionary = combatants.get("enemy", {})

	_append_combatant_summary(lines, "Jogador", player_stats, true)
	_append_combatant_summary(lines, "Bot", bot_stats)
	_append_combatant_summary(lines, "Boss Troll", boss_stats)
	_append_combatant_summary(lines, "Trolls", enemy_stats)
	_append_section(lines, "Proximo passo", _build_next_step_lines(mode_id, result))

	return "\n".join(lines)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file(FRONTEND_SCENE_PATH)

func _append_combatant_summary(lines: Array[String], label: String, stats: Dictionary, force_show: bool = false) -> void:
	if stats.is_empty() or (not force_show and not _has_meaningful_stats(stats)):
		return

	_append_section(lines, label, [
		"Dano causado: %.0f | sofrido: %.0f" % [
			float(stats.get("damage_dealt", 0.0)),
			float(stats.get("damage_taken", 0.0))
		],
		"Cura: %.0f | barreira: %.0f | acoes: %d" % [
			float(stats.get("healing_done", 0.0)),
			float(stats.get("barrier_applied", 0.0)),
			int(stats.get("actions_used", 0))
		]
	])

func _build_next_step_lines(mode_id: StringName, result: Dictionary) -> Array[String]:
	if mode_id == LocalModeCatalog.CAMPAIGN_MODE_ID:
		var round_summary: Dictionary = result.get("round_summary", {})
		var campaign_summary: Dictionary = round_summary.get("campaign", {})
		var is_free_replay: bool = str(campaign_summary.get("difficulty_id", "")) == "free"
		if is_free_replay:
			if bool(result.get("player_victory", false)):
				return [
					"Volte ao menu para ajustar o kit, repetir a Campanha Livre ou seguir para outros extras."
				]
			return [
				"Volte ao menu para ajustar o kit livre e recomecar do Mapa 1."
			]
		if bool(result.get("player_victory", false)):
			return [
				"Volte ao menu para seguir a Campanha do Troll, revisar a rota ou testar os extras abertos pelo progresso."
			]
		return [
			"Volte ao menu para recomecar a rota Classic a partir da Missao 1."
		]
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.SURVIVAL_MODE_ID:
			return [
				"Volte ao menu para repetir a prova de resistencia, ajustar o kit ou seguir a Campanha do Troll."
			]
		LocalModeCatalog.BOSS_MODE_ID:
			return [
				"Volte ao menu para repetir a pratica de maestria, ajustar o kit ou revisar a campanha."
			]
		LocalModeCatalog.ARENA_BOT_MODE_ID:
			return [
				"Volte ao menu para testar outra combinacao, repetir a simulacao ou seguir a campanha."
			]
	return [
		"Volte ao menu local para repetir o modo, ajustar o kit ou iniciar outra rodada."
	]

func _append_extra_mode_section(lines: Array[String], extra_mode_summary: Dictionary) -> void:
	var grants_permanent_progress: bool = bool(extra_mode_summary.get("grants_permanent_progress", false))
	_append_section(lines, "Extra", [
		"Funcao: %s" % str(extra_mode_summary.get("role", "Treino")),
		"Framing: %s" % str(extra_mode_summary.get("framing", "Desafio local")),
		"Leitura: %s" % str(extra_mode_summary.get("result_focus", "dominio do kit")),
		"Progressao permanente: %s" % ("altera o perfil" if grants_permanent_progress else "sem alteracao; a fonte principal segue na campanha")
	])

func _is_campaign_or_extra_mode(mode_id: StringName) -> bool:
	return mode_id == LocalModeCatalog.CAMPAIGN_MODE_ID or _is_extra_mode(mode_id)

func _is_extra_mode(mode_id: StringName) -> bool:
	var normalized_mode_id: StringName = LocalModeCatalog.normalize_mode_id(mode_id)
	return (
		normalized_mode_id == LocalModeCatalog.SURVIVAL_MODE_ID
		or normalized_mode_id == LocalModeCatalog.BOSS_MODE_ID
		or normalized_mode_id == LocalModeCatalog.ARENA_BOT_MODE_ID
	)

func _has_meaningful_stats(stats: Dictionary) -> bool:
	for value: Variant in stats.values():
		if value is int and int(value) > 0:
			return true
		if value is float and float(value) > 0.0:
			return true
	return false

func _append_section(lines: Array[String], title: String, section_lines: Array[String]) -> void:
	if section_lines.is_empty():
		return
	if not lines.is_empty():
		lines.append("")
	lines.append("%s:" % title)
	for line: String in section_lines:
		lines.append("- %s" % line)

func _format_duration(total_seconds: float) -> String:
	var clamped_seconds: float = maxf(0.0, total_seconds)
	var minutes: int = int(floor(clamped_seconds / 60.0))
	var seconds: int = int(floor(fmod(clamped_seconds, 60.0)))
	return "%02d:%02d" % [minutes, seconds]

func _build_frame_style(bg_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = bg_color
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = border_color
	style_box.corner_radius_top_left = radius
	style_box.corner_radius_top_right = radius
	style_box.corner_radius_bottom_left = radius
	style_box.corner_radius_bottom_right = radius
	return style_box
