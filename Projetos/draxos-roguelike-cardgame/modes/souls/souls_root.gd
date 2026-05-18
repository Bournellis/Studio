extends Control

var state_label: Label
var message_label: Label
var heal_button: Button
var max_health_button: Button
var reroll_shop_button: Button
var upgrade_options_box: VBoxContainer
var remove_options_box: VBoxContainer
var duplicate_options_box: VBoxContainer
var card_options_box: VBoxContainer
var relic_options_box: VBoxContainer
var preview_panel: PanelContainer
var preview_title_label: Label
var preview_body_label: Label

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	_build_ui()
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		var viewport: Viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()
		_return_to_ship()

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("ship_hub_background")
	background.name = "SoulsVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "SoulsScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.34)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var title: Label = Label.new()
	title.name = "SoulsTitle"
	title.text = "Almas"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title.anchor_left = 0.04
	title.anchor_top = 0.04
	title.anchor_right = 0.46
	title.anchor_bottom = 0.04
	title.offset_bottom = 44.0
	add_child(title)

	var shop_panel: PanelContainer = PanelContainer.new()
	shop_panel.name = "SoulsShopPanel"
	shop_panel.anchor_left = 0.06
	shop_panel.anchor_top = 0.16
	shop_panel.anchor_right = 0.68
	shop_panel.anchor_bottom = 0.92
	shop_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.045, 0.052, 0.84), Color(0.62, 0.40, 0.62, 0.84)))
	add_child(shop_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	shop_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var shop_title: Label = Label.new()
	shop_title.name = "SoulsShopTitle"
	shop_title.text = "Loja de Almas"
	shop_title.add_theme_font_size_override("font_size", 22)
	shop_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(shop_title)

	heal_button = Button.new()
	heal_button.name = "SoulsHealButton"
	heal_button.text = "Curar %d por %d almas" % [RunSession.PAID_HEAL_AMOUNT, RunSession.PAID_HEAL_COST]
	heal_button.tooltip_text = "Cura o Comandante durante a run. Nao aumenta HP maximo."
	heal_button.mouse_entered.connect(func() -> void:
		_show_shop_preview("Curar", heal_button.tooltip_text)
	)
	heal_button.mouse_exited.connect(_hide_shop_preview)
	heal_button.custom_minimum_size = Vector2(0, 52)
	heal_button.pressed.connect(_buy_heal)
	box.add_child(heal_button)

	max_health_button = Button.new()
	max_health_button.name = "SoulsMaxHealthButton"
	max_health_button.tooltip_text = "Aumenta HP maximo e HP atual. Limite: duas compras por run."
	max_health_button.mouse_entered.connect(func() -> void:
		_show_shop_preview("HP maximo", max_health_button.tooltip_text)
	)
	max_health_button.mouse_exited.connect(_hide_shop_preview)
	max_health_button.custom_minimum_size = Vector2(0, 44)
	max_health_button.pressed.connect(_buy_max_health)
	box.add_child(max_health_button)

	reroll_shop_button = Button.new()
	reroll_shop_button.name = "SoulsRerollShopButton"
	reroll_shop_button.tooltip_text = "Gera novas ofertas de cartas e reliquias. O custo aumenta a cada reroll."
	reroll_shop_button.mouse_entered.connect(func() -> void:
		_show_shop_preview("Reroll loja", reroll_shop_button.tooltip_text)
	)
	reroll_shop_button.mouse_exited.connect(_hide_shop_preview)
	reroll_shop_button.custom_minimum_size = Vector2(0, 40)
	reroll_shop_button.pressed.connect(_reroll_shop)
	box.add_child(reroll_shop_button)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "SoulsExpandedShopScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	var offers_box: VBoxContainer = VBoxContainer.new()
	offers_box.name = "SoulsExpandedShopOffers"
	offers_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	offers_box.add_theme_constant_override("separation", 10)
	scroll.add_child(offers_box)

	card_options_box = _add_offer_section(offers_box, "Cartas", "SoulsCardOptions")
	relic_options_box = _add_offer_section(offers_box, "Reliquias", "SoulsRelicOptions")
	remove_options_box = _add_offer_section(offers_box, "Remover carta", "SoulsRemoveOptions")
	duplicate_options_box = _add_offer_section(offers_box, "Duplicar carta", "SoulsDuplicateOptions")
	upgrade_options_box = _add_offer_section(offers_box, "Aprimorar carta", "SoulsUpgradeOptions")

	message_label = Label.new()
	message_label.name = "SoulsMessage"
	message_label.text = ""
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 13)
	message_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(message_label)

	var state_panel: PanelContainer = PanelContainer.new()
	state_panel.name = "SoulsRunStatePanel"
	state_panel.anchor_left = 1.0
	state_panel.anchor_top = 0.14
	state_panel.anchor_right = 1.0
	state_panel.anchor_bottom = 0.14
	state_panel.offset_left = -330.0
	state_panel.offset_right = -24.0
	state_panel.offset_bottom = 252.0
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
	state_title.text = "Estado da Run"
	state_title.add_theme_font_size_override("font_size", 20)
	state_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	state_box.add_child(state_title)

	state_label = Label.new()
	state_label.name = "SoulsRunState"
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state_label.add_theme_font_size_override("font_size", 13)
	state_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	state_box.add_child(state_label)

	var back_button: Button = Button.new()
	back_button.name = "SoulsBackToShipButton"
	back_button.text = "Voltar"
	back_button.custom_minimum_size = Vector2(0, 40)
	back_button.pressed.connect(_return_to_ship)
	state_box.add_child(back_button)

	_build_shop_preview_panel()

func _add_offer_section(parent: VBoxContainer, title_text: String, box_name: String) -> VBoxContainer:
	var title: Label = Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	parent.add_child(title)
	var options_box: VBoxContainer = VBoxContainer.new()
	options_box.name = box_name
	options_box.add_theme_constant_override("separation", 6)
	parent.add_child(options_box)
	return options_box

func _buy_heal() -> void:
	var result: Dictionary = RunSession.buy_paid_heal()
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
	_refresh()

func _buy_card_upgrade(card_id: String) -> void:
	var result: Dictionary = RunSession.buy_shop_card_upgrade(card_id)
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
		_refresh()

func _buy_remove_card(card_id: String) -> void:
	var result: Dictionary = RunSession.buy_shop_remove_card(card_id)
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
		_refresh()

func _buy_duplicate_card(card_id: String) -> void:
	var result: Dictionary = RunSession.buy_shop_duplicate_card(card_id)
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
		_refresh()

func _buy_card(card_id: String) -> void:
	var result: Dictionary = RunSession.buy_shop_card(card_id)
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
		_refresh()

func _buy_relic(relic_id: String) -> void:
	var result: Dictionary = RunSession.buy_shop_relic(relic_id)
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
		_refresh()

func _buy_max_health() -> void:
	var result: Dictionary = RunSession.buy_shop_max_health()
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
		_refresh()

func _reroll_shop() -> void:
	var result: Dictionary = RunSession.buy_shop_reroll()
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
		_refresh()

func _refresh() -> void:
	if heal_button != null:
		heal_button.disabled = not RunSession.can_buy_heal()
		heal_button.text = "Curar %d por %d almas" % [RunSession._modified_heal_amount(RunSession.PAID_HEAL_AMOUNT), RunSession.PAID_HEAL_COST]
	if max_health_button != null:
		max_health_button.text = "+%d HP max | %d almas (%d/%d)" % [
			RunSession.SHOP_MAX_HEALTH_AMOUNT,
			RunSession._shop_max_health_cost(),
			RunSession._shop_max_health_purchase_count(),
			RunSession.SHOP_MAX_HEALTH_PURCHASE_LIMIT
		]
		max_health_button.disabled = not RunSession.can_buy_shop_max_health()
	if reroll_shop_button != null:
		reroll_shop_button.text = "Reroll loja | %d almas" % RunSession.current_reroll_cost()
		reroll_shop_button.disabled = not RunSession.active or RunSession.soul_total < RunSession.current_reroll_cost()
	if state_label != null:
		state_label.text = _state_text()
	_refresh_card_options()
	_refresh_relic_options()
	_refresh_remove_options()
	_refresh_duplicate_options()
	_refresh_upgrade_options()

func _refresh_card_options() -> void:
	_rebuild_choice_buttons(card_options_box, RunSession.shop_card_choices(), _buy_card, "SoulsNoCardOptions", "Sem cartas a venda.")

func _refresh_relic_options() -> void:
	_rebuild_choice_buttons(relic_options_box, RunSession.shop_relic_choices(), _buy_relic, "SoulsNoRelicOptions", "Sem reliquias a venda.")

func _refresh_remove_options() -> void:
	_rebuild_choice_buttons(remove_options_box, RunSession.shop_remove_card_choices(), _buy_remove_card, "SoulsNoRemoveOptions", "Sem cartas para remover.")

func _refresh_duplicate_options() -> void:
	_rebuild_choice_buttons(duplicate_options_box, RunSession.shop_duplicate_card_choices(), _buy_duplicate_card, "SoulsNoDuplicateOptions", "Sem cartas para duplicar.")

func _refresh_upgrade_options() -> void:
	if upgrade_options_box == null:
		return
	_rebuild_choice_buttons(upgrade_options_box, RunSession.shop_upgrade_choices(), _buy_card_upgrade, "SoulsNoUpgradeOptions", "Sem upgrades disponiveis depois do ultimo combate.")

func _rebuild_choice_buttons(options_box: VBoxContainer, choices: Array[Dictionary], callback: Callable, empty_name: String, empty_text: String) -> void:
	if options_box == null:
		return
	for child: Node in options_box.get_children():
		child.queue_free()
	if choices.is_empty():
		var empty_label: Label = Label.new()
		empty_label.name = empty_name
		empty_label.text = empty_text
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", UiTokens.color("text_secondary", Color(0.72, 0.78, 0.82)))
		options_box.add_child(empty_label)
		return
	for choice: Dictionary in choices:
		var item_id: String = str(choice.get("card_id", choice.get("relic_id", "")))
		var button: Button = Button.new()
		button.name = "%s_%s" % [str(choice.get("id", "SoulsChoice")).replace(":", "_"), item_id]
		button.text = "%s\n%d almas" % [str(choice.get("title", item_id)), int(choice.get("cost", RunSession.SHOP_CARD_UPGRADE_COST))]
		button.tooltip_text = ContentLibrary.shop_choice_tooltip(choice)
		button.mouse_entered.connect(func() -> void:
			_show_shop_preview(str(choice.get("title", item_id)), ContentLibrary.shop_choice_tooltip(choice))
		)
		button.mouse_exited.connect(_hide_shop_preview)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(0, 46)
		button.disabled = not bool(choice.get("can_buy", false))
		button.pressed.connect(func() -> void:
			callback.call(item_id)
		)
		options_box.add_child(button)

func _state_text() -> String:
	if not RunSession.active:
		return "Nome: -\nClasse: -\nMapa: -\nHP: -\nMana: -\nMão: -\nAlmas: -"
	return "Nome: %s\nClasse: %s\nMapa: %s\nHP: %d/%d\nMana: %d\nMão: %d\nAlmas: %d" % [
		RunSession.player_display_name(),
		RunSession.selected_class_display_name,
		RunSession.current_node_display_name(),
		RunSession.current_health,
		RunSession.max_health,
		RunSession.max_mana,
		RunSession.max_hand_size,
		RunSession.soul_total
	]

func _return_to_ship() -> void:
	if RunSession.active and RunSession.has_selected_class():
		SaveManager.save_current_run()
	get_tree().change_scene_to_file("res://modes/ship_hub/ship_hub.tscn")

func _build_shop_preview_panel() -> void:
	preview_panel = PanelContainer.new()
	preview_panel.name = "SoulsTooltipPreview"
	preview_panel.visible = false
	preview_panel.z_index = 80
	preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_panel.custom_minimum_size = Vector2(292, 0)
	preview_panel.anchor_left = 1.0
	preview_panel.anchor_top = 0.52
	preview_panel.anchor_right = 1.0
	preview_panel.anchor_bottom = 0.52
	preview_panel.offset_left = -330.0
	preview_panel.offset_top = 0.0
	preview_panel.offset_right = -24.0
	preview_panel.offset_bottom = 190.0
	preview_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.065, 0.075, 0.92), Color(0.62, 0.55, 0.42, 0.92)))
	add_child(preview_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	preview_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	preview_title_label = Label.new()
	preview_title_label.name = "SoulsTooltipPreviewTitle"
	preview_title_label.add_theme_font_size_override("font_size", 17)
	preview_title_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(preview_title_label)

	preview_body_label = Label.new()
	preview_body_label.name = "SoulsTooltipPreviewBody"
	preview_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_body_label.add_theme_font_size_override("font_size", 12)
	preview_body_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96))
	box.add_child(preview_body_label)

func _show_shop_preview(title: String, body: String) -> void:
	if preview_panel == null:
		return
	preview_title_label.text = title
	preview_body_label.text = body
	preview_panel.visible = body != ""

func _hide_shop_preview() -> void:
	if preview_panel != null:
		preview_panel.visible = false

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	return style
