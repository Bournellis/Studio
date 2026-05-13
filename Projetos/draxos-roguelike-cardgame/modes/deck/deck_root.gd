extends Control

var state_label: Label

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	if RunSession.active and RunSession.current_node_id == "":
		RunSession.select_next_available_node()
	_build_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		var viewport: Viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()
		_return_to_ship()

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("ship_hub_background")
	background.name = "DeckVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "DeckScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.34)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var title: Label = Label.new()
	title.name = "DeckTitle"
	title.text = "Deck"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title.anchor_left = 0.04
	title.anchor_top = 0.04
	title.anchor_right = 0.46
	title.anchor_bottom = 0.04
	title.offset_bottom = 44.0
	add_child(title)

	var deck_panel: PanelContainer = PanelContainer.new()
	deck_panel.name = "DeckListPanel"
	deck_panel.anchor_left = 0.04
	deck_panel.anchor_top = 0.14
	deck_panel.anchor_right = 0.70
	deck_panel.anchor_bottom = 0.94
	deck_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.052, 0.82), Color(0.42, 0.52, 0.58, 0.78)))
	add_child(deck_panel)

	var deck_margin: MarginContainer = MarginContainer.new()
	deck_margin.add_theme_constant_override("margin_left", 14)
	deck_margin.add_theme_constant_override("margin_top", 12)
	deck_margin.add_theme_constant_override("margin_right", 14)
	deck_margin.add_theme_constant_override("margin_bottom", 12)
	deck_panel.add_child(deck_margin)

	var deck_scroll: ScrollContainer = ScrollContainer.new()
	deck_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	deck_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	deck_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_margin.add_child(deck_scroll)

	var list: VBoxContainer = VBoxContainer.new()
	list.name = "DeckGroupedCards"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	deck_scroll.add_child(list)
	_populate_deck_list(list)

	var state_panel: PanelContainer = PanelContainer.new()
	state_panel.name = "DeckRunStatePanel"
	state_panel.anchor_left = 1.0
	state_panel.anchor_top = 0.12
	state_panel.anchor_right = 1.0
	state_panel.anchor_bottom = 0.12
	state_panel.offset_left = -330.0
	state_panel.offset_right = -24.0
	state_panel.offset_bottom = 440.0
	state_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.052, 0.84), Color(0.44, 0.62, 0.68, 0.78)))
	add_child(state_panel)

	var state_margin: MarginContainer = MarginContainer.new()
	state_margin.add_theme_constant_override("margin_left", 14)
	state_margin.add_theme_constant_override("margin_top", 12)
	state_margin.add_theme_constant_override("margin_right", 14)
	state_margin.add_theme_constant_override("margin_bottom", 12)
	state_panel.add_child(state_margin)

	var state_box: VBoxContainer = VBoxContainer.new()
	state_box.add_theme_constant_override("separation", 10)
	state_margin.add_child(state_box)

	var state_title: Label = Label.new()
	state_title.text = "Estado"
	state_title.add_theme_font_size_override("font_size", 20)
	state_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	state_box.add_child(state_title)

	state_label = Label.new()
	state_label.name = "DeckRunState"
	state_label.text = _state_text()
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state_label.add_theme_font_size_override("font_size", 13)
	state_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	state_box.add_child(state_label)

	var upgrade_title: Label = Label.new()
	upgrade_title.text = "Upgrades"
	upgrade_title.add_theme_font_size_override("font_size", 18)
	upgrade_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	state_box.add_child(upgrade_title)

	var upgrade_label: Label = Label.new()
	upgrade_label.name = "DeckUpgradeState"
	upgrade_label.text = _upgrade_text()
	upgrade_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	upgrade_label.add_theme_font_size_override("font_size", 12)
	upgrade_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	state_box.add_child(upgrade_label)

	var back_button: Button = Button.new()
	back_button.name = "DeckBackToShipButton"
	back_button.text = "Voltar"
	back_button.custom_minimum_size = Vector2(0, 40)
	back_button.pressed.connect(_return_to_ship)
	state_box.add_child(back_button)

func _populate_deck_list(list: VBoxContainer) -> void:
	var counts: Dictionary = {}
	var deck_ids: Array[String] = _display_deck_ids()
	if deck_ids.is_empty():
		var empty_label: Label = Label.new()
		empty_label.name = "DeckEmptyMessage"
		empty_label.text = "Nenhum deck ativo. Volte ao menu principal e inicie ou continue um save."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.add_theme_font_size_override("font_size", 15)
		empty_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
		list.add_child(empty_label)
		return
	for card_id: String in deck_ids:
		counts[card_id] = int(counts.get(card_id, 0)) + 1
	var ids: Array = counts.keys()
	ids.sort()
	for card_id_variant: Variant in ids:
		var card_id: String = str(card_id_variant)
		var card = ContentLibrary.get_card(card_id)
		var row: PanelContainer = PanelContainer.new()
		row.name = "DeckCard_%s" % card_id
		row.custom_minimum_size = Vector2(0.0, 82.0)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_stylebox_override("panel", _panel_style(Color(0.055, 0.065, 0.072, 0.72), VisualAssets.card_frame_color(card_id)))
		list.add_child(row)

		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		row.add_child(margin)

		var label: Label = Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
		if card == null:
			label.text = "x%d  %s" % [int(counts.get(card_id, 0)), card_id]
		else:
			var stat_text: String = ""
			if card.occupies_slot():
				stat_text = " | %d/%d" % [int(card.attack), int(card.health)]
			label.text = "x%d  %s | %s | Custo %d%s\n%s" % [
				int(counts.get(card_id, 0)),
				str(card.display_name),
				UiTokens.type_display_name(str(card.card_type)),
				int(card.cost),
				stat_text,
				VisualAssets.card_display_text(card)
			]
		margin.add_child(label)

func _display_deck_ids() -> Array[String]:
	if not RunSession.current_deck_ids.is_empty():
		return RunSession.current_deck_ids.duplicate()
	if RunSession.selected_class_id == "":
		return []
	var class_option: Dictionary = ContentLibrary.find_class_option(RunSession.selected_class_id)
	if class_option.is_empty():
		return []
	return _string_array(class_option.get("starter_deck", []))

func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in Array(value):
		result.append(str(item))
	return result

func _state_text() -> String:
	if not RunSession.active:
		return "Classe: -\nMapa: -\nHP: -\nMana: -\nMão: -\nAlmas: -"
	return "Classe: %s\nMapa: %s\nHP: %d/%d\nMana: %d\nMão: %d\nAlmas: %d" % [
		RunSession.selected_class_display_name,
		RunSession.current_node_display_name(),
		RunSession.current_health,
		RunSession.max_health,
		RunSession.max_mana,
		RunSession.max_hand_size,
		RunSession.soul_total
	]

func _upgrade_text() -> String:
	if not RunSession.active:
		return "-"
	var parts: Array[String] = []
	parts.append("Passiva: %s" % ("desbloqueada" if RunSession.class_passive_unlocked else "bloqueada"))
	parts.append("Spell: %s" % ("desbloqueada" if RunSession.class_active_unlocked else "bloqueada"))
	for applied_id: String in RunSession.automatic_reward_ids:
		var reward_id: String = applied_id.get_slice(":", 1)
		parts.append(RunSession.automatic_reward_display_name(reward_id))
	return "\n".join(parts)

func _return_to_ship() -> void:
	if RunSession.active and RunSession.has_selected_class():
		SaveManager.save_current_run()
	get_tree().change_scene_to_file("res://modes/ship_hub/ship_hub.tscn")

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 6
	style.content_margin_top = 6
	style.content_margin_right = 6
	style.content_margin_bottom = 6
	return style
