extends Control

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var bg_asset_id: String = "result_bg_victory" if GameSession.last_battle_result == "victory" else "result_bg_defeat"
	var bg_visual: TextureRect = TextureRect.new()
	bg_visual.name = "bg_visual"
	bg_visual.texture = AssetIds.texture(bg_asset_id)
	bg_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_visual.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_visual.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg_visual)

	var background: ColorRect = ColorRect.new()
	background.name = "ambiance_layer"
	background.color = UiTokens.color("bg_deep", Color(0.045, 0.05, 0.055))
	background.color.a = 0.8 if bg_visual.texture != null else 1.0
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 320)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	var title: Label = Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.text = "Vitoria" if GameSession.last_battle_result == "victory" else "Derrota"
	box.add_child(title)

	var result_icon_rect: TextureRect = TextureRect.new()
	result_icon_rect.name = "result_icon_rect"
	result_icon_rect.custom_minimum_size = Vector2(64, 64)
	result_icon_rect.texture = AssetIds.texture("icon_victory" if GameSession.last_battle_result == "victory" else "icon_defeat")
	result_icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_icon_rect.modulate = Color.WHITE if result_icon_rect.texture != null else _result_color()
	box.add_child(result_icon_rect)

	var summary: Label = Label.new()
	summary.text = GameSession.last_battle_summary
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(summary)

	if GameSession.last_battle_result == "victory":
		var reward_label: Label = Label.new()
		reward_label.name = "reward_label"
		reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		reward_label.text = _reward_text()
		box.add_child(reward_label)

		var back: Button = Button.new()
		back.text = "Voltar ao mapa"
		back.custom_minimum_size = Vector2(220, 44)
		back.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://modes/world/world.tscn"))
		box.add_child(back)
	else:
		var retry: Button = Button.new()
		retry.text = "Tentar novamente"
		retry.custom_minimum_size = Vector2(220, 44)
		retry.pressed.connect(_retry)
		box.add_child(retry)

func _retry() -> void:
	GameSession.restore_pre_combat_snapshot()
	get_tree().change_scene_to_file("res://modes/battle/deck_setup.tscn")

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel", Color(0.09, 0.1, 0.12))
	style.border_color = _result_color()
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 28
	style.content_margin_top = 28
	style.content_margin_right = 28
	style.content_margin_bottom = 28
	return style

func _result_color() -> Color:
	if GameSession.last_battle_result == "victory":
		return UiTokens.color("hp_player", Color(0.32, 0.52, 0.38))
	return UiTokens.color("hp_enemy", Color(0.52, 0.32, 0.34))

func _reward_text() -> String:
	return reward_text_for_card_ids(GameSession.last_reward_card_ids)

static func reward_text_for_card_ids(card_ids: Array) -> String:
	if card_ids.is_empty():
		return "Recompensas: ja reclamadas neste encontro."
	var names: Array[String] = []
	for card_id: Variant in card_ids:
		names.append(ContentLibrary.get_card_name(str(card_id)))
	return "Recompensas: %s." % ", ".join(names)
