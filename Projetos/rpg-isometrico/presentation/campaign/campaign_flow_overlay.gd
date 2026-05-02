class_name CampaignFlowOverlay
extends CanvasLayer

const CampaignRewardPayload = preload("res://gameplay/profile/campaign_reward_payload.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

signal continue_requested()
signal skill_selected(skill_id: StringName)

var eyebrow_label: Label
var title_label: Label
var body_label: Label
var footer_hint_label: Label
var choices_column: VBoxContainer
var continue_button: Button

func _ready() -> void:
	layer = 18
	visible = false
	_build_ui()

func show_tutorial_prompt(title: String, body: String) -> void:
	_show_overlay("TUTORIAL", title, body, false)
	footer_hint_label.text = "Use a acao destacada para retomar o combate."

func show_stage_briefing(
	campaign_name: String,
	difficulty_label: String,
	stage_name: String,
	stage_number: int,
	target_stage_count: int,
	objective_text: String,
	is_boss_stage: bool = false,
	is_free_replay: bool = false
) -> void:
	var body_lines: Array[String] = [
		"%s | %s" % [campaign_name, difficulty_label],
		(
			"Etapa %d/%d de replay livre." % [stage_number, maxi(1, target_stage_count)]
			if is_free_replay
			else "Etapa %d/%d da jornada authored." % [stage_number, maxi(1, target_stage_count)]
		),
		"Objetivo: %s" % objective_text
	]
	if is_free_replay and stage_number <= 1:
		body_lines.append("A Campanha Livre usa o kit preparado com recursos ja aprendidos; ela existe para replay e buildcraft, nao para novos unlocks permanentes.")
	elif is_free_replay and is_boss_stage:
		body_lines.append("Confronto final do replay livre: teste a execucao do kit escolhido sem alterar a progressao principal.")
	elif is_free_replay:
		body_lines.append("Continue o replay livre: ajuste o dominio do kit e avance sem substituir a Campanha Classica.")
	elif stage_number <= 1:
		body_lines.append("A Campanha Classica ensina e equipa o kit aos poucos; voce nao precisa montar um kit completo antes de jogar.")
	elif is_boss_stage:
		body_lines.append("Confronto final da rota: vença o chefe para fechar a jornada principal e abrir o desafio extra de maestria.")
	else:
		body_lines.append("Siga a rota da forja: sobreviva, aprenda o proximo passo do kit e avance para o chefe.")
	_show_overlay("CAMPANHA LIVRE" if is_free_replay else "CAMPANHA CLASSICA", stage_name, "\n".join(body_lines), true, "Comecar replay" if is_free_replay else "Comecar etapa")
	footer_hint_label.text = "Continue para assumir o controle desta etapa."

func show_reward_overlay(title: String, lines: Array[String], button_text: String = "Seguir") -> void:
	_show_overlay("AVANCO DA CAMPANHA", title, "\n".join(lines), true, button_text)
	footer_hint_label.text = "Continue para voltar ao fluxo da campanha."

func show_reward_payload(reward_payload: CampaignRewardPayload, button_text: String = "Seguir") -> void:
	if reward_payload == null or reward_payload.is_empty():
		show_reward_overlay("Recompensa", [], button_text)
		return
	var is_free_replay: bool = reward_payload.difficulty_id == &"free"
	_show_overlay("REPLAY LIVRE" if is_free_replay else "AVANCO DA CAMPANHA", reward_payload.title, _build_reward_payload_body(reward_payload), true, button_text)
	footer_hint_label.text = "Continue para preparar a proxima etapa da Campanha Livre." if is_free_replay else "Continue para preparar a proxima etapa da Campanha Classica."

func show_level_up_overlay(
	level_number: int,
	available_skills: Array[Dictionary],
	body_lines: Array[String]
) -> void:
	_show_overlay(
		"PREPARO DA JORNADA",
		"Nivel %d da Campanha" % level_number,
		"\n".join(body_lines),
		available_skills.is_empty(),
		"Aplicar nivel"
	)
	footer_hint_label.text = (
		"Escolha a spell que vai entrar na run agora."
		if not available_skills.is_empty()
		else "Nenhuma spell nova esta disponivel. Aplique o nivel para seguir."
	)
	_clear_choices()
	for skill_entry_variant: Variant in available_skills:
		var skill_entry: Dictionary = Dictionary(skill_entry_variant)
		var button: Button = Button.new()
		button.text = str(skill_entry.get("label", "Liberar spell"))
		button.tooltip_text = str(skill_entry.get("description", ""))
		button.custom_minimum_size = Vector2(0.0, 44.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(
			func() -> void:
				skill_selected.emit(StringName(str(skill_entry.get("skill_id", ""))))
		)
		choices_column.add_child(button)
	if available_skills.is_empty():
		continue_button.grab_focus()

func hide_overlay() -> void:
	visible = false
	_clear_choices()
	eyebrow_label.text = ""
	title_label.text = ""
	body_label.text = ""
	footer_hint_label.text = ""

func is_showing_choice() -> bool:
	return visible and choices_column.get_child_count() > 0

func _show_overlay(
	eyebrow: String,
	title: String,
	body: String,
	show_continue: bool,
	button_text: String = "Continuar"
) -> void:
	visible = true
	eyebrow_label.text = eyebrow
	title_label.text = title
	body_label.text = body
	footer_hint_label.text = ""
	_clear_choices()
	continue_button.visible = show_continue
	continue_button.text = button_text
	if show_continue:
		continue_button.grab_focus()

func _build_ui() -> void:
	var backdrop: Control = Control.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var scrim: ColorRect = ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.04, 0.66)
	backdrop.add_child(scrim)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(600.0, 0.0)
	center.add_child(panel)

	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.08, 0.11, 0.98)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.88, 0.5, 0.24, 0.48)
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.corner_radius_bottom_right = 20
	panel.add_theme_stylebox_override("panel", panel_style)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)

	eyebrow_label = Label.new()
	eyebrow_label.name = "EyebrowLabel"
	eyebrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow_label.add_theme_font_size_override("font_size", 12)
	eyebrow_label.modulate = Color(1.0, 0.8, 0.56, 1.0)
	column.add_child(eyebrow_label)

	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.modulate = Color(0.98, 0.9, 0.78, 1.0)
	column.add_child(title_label)

	var body_frame: PanelContainer = PanelContainer.new()
	body_frame.add_theme_stylebox_override(
		"panel",
		_build_frame_style(Color(0.1, 0.11, 0.15, 0.92), Color(0.82, 0.46, 0.24, 0.16), 14)
	)
	column.add_child(body_frame)

	var body_margin: MarginContainer = MarginContainer.new()
	body_margin.add_theme_constant_override("margin_left", 16)
	body_margin.add_theme_constant_override("margin_top", 14)
	body_margin.add_theme_constant_override("margin_right", 16)
	body_margin.add_theme_constant_override("margin_bottom", 14)
	body_frame.add_child(body_margin)

	body_label = Label.new()
	body_label.name = "BodyLabel"
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.custom_minimum_size = Vector2(500.0, 0.0)
	body_label.modulate = Color(0.9, 0.92, 0.96, 1.0)
	body_margin.add_child(body_label)

	choices_column = VBoxContainer.new()
	choices_column.name = "ChoicesColumn"
	choices_column.add_theme_constant_override("separation", 10)
	column.add_child(choices_column)

	footer_hint_label = Label.new()
	footer_hint_label.name = "FooterHintLabel"
	footer_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_hint_label.modulate = Color(0.92, 0.82, 0.68, 1.0)
	column.add_child(footer_hint_label)

	continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = "Continuar"
	continue_button.custom_minimum_size = Vector2(0.0, 44.0)
	continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_button.visible = false
	continue_button.pressed.connect(func() -> void: continue_requested.emit())
	column.add_child(continue_button)

func _clear_choices() -> void:
	for child: Node in choices_column.get_children():
		choices_column.remove_child(child)
		child.queue_free()

func _build_reward_payload_body(reward_payload: CampaignRewardPayload) -> String:
	var lines: Array[String] = []
	var progression_lines: Array[String] = _build_reward_progression_lines(reward_payload)
	var permanent_unlock_lines: Array[String] = _build_reward_permanent_unlock_lines(reward_payload)
	var menu_unlock_lines: Array[String] = _build_reward_menu_unlock_lines(reward_payload)

	if not progression_lines.is_empty():
		lines.append("Proximo trecho da jornada")
		for line: String in progression_lines:
			lines.append("- %s" % line)

	if not permanent_unlock_lines.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("Kit aprendido permanentemente")
		for line: String in permanent_unlock_lines:
			lines.append(line)

	if not menu_unlock_lines.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("Extras abertos pelo progresso")
		for line: String in menu_unlock_lines:
			lines.append(line)

	if lines.is_empty():
		for summary_line: String in reward_payload.summary_lines:
			lines.append(summary_line)

	return "\n".join(lines)

func _build_reward_progression_lines(reward_payload: CampaignRewardPayload) -> Array[String]:
	var lines: Array[String] = []
	if reward_payload.next_level > 0 and reward_payload.pending_level_increase > 0:
		lines.append("Nivel %d preparado para a proxima etapa." % reward_payload.next_level)
	elif reward_payload.pending_level_increase > 0:
		lines.append("Level up preparado para a proxima etapa.")
	if reward_payload.pending_skill_points > 0:
		lines.append("%d ponto%s de habilidade vao reforcar o kit no inicio da proxima etapa." % [
			reward_payload.pending_skill_points,
			"" if reward_payload.pending_skill_points == 1 else "s"
		])
	return lines

func _build_reward_permanent_unlock_lines(reward_payload: CampaignRewardPayload) -> Array[String]:
	var lines: Array[String] = []
	for skill_id_text: String in reward_payload.permanent_skill_unlock_ids:
		lines.append("- %s entrou no kit permanente da jornada." % _resolve_skill_display_name(StringName(skill_id_text)))
	for potion_id_text: String in reward_payload.permanent_potion_unlock_ids:
		lines.append("- %s entrou no kit permanente da jornada." % _resolve_potion_display_name(StringName(potion_id_text)))
	return lines

func _build_reward_menu_unlock_lines(reward_payload: CampaignRewardPayload) -> Array[String]:
	var lines: Array[String] = []
	for mode_id_text: String in reward_payload.menu_unlock_mode_ids:
		lines.append("- %s abriu como extra ligado ao progresso da campanha." % _resolve_mode_display_name(StringName(mode_id_text)))
	return lines

func _resolve_skill_display_name(skill_id: StringName) -> String:
	var content_library: Node = _content_library()
	if content_library == null:
		return String(skill_id)
	var skill = content_library.get_skill(skill_id)
	if skill == null or str(skill.display_name) == "":
		return String(skill_id)
	return str(skill.display_name)

func _resolve_potion_display_name(potion_id: StringName) -> String:
	var content_library: Node = _content_library()
	if content_library == null:
		return String(potion_id)
	var potion = content_library.get_potion(potion_id)
	if potion == null or str(potion.display_name) == "":
		return String(potion_id)
	return str(potion.display_name)

func _resolve_mode_display_name(mode_id: StringName) -> String:
	if LocalModeCatalog.is_supported_mode(mode_id):
		return LocalModeCatalog.get_display_name(mode_id)
	return String(mode_id)

func _content_library() -> Node:
	return get_node_or_null("/root/ContentLibrary")

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
