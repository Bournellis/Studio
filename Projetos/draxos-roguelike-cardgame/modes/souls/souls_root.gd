extends Control

var state_label: Label
var message_label: Label
var heal_button: Button

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
	shop_panel.anchor_left = 0.12
	shop_panel.anchor_top = 0.24
	shop_panel.anchor_right = 0.58
	shop_panel.anchor_bottom = 0.66
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
	heal_button.custom_minimum_size = Vector2(0, 52)
	heal_button.pressed.connect(_buy_heal)
	box.add_child(heal_button)

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

func _buy_heal() -> void:
	var result: Dictionary = RunSession.buy_paid_heal()
	message_label.text = str(result.get("message", ""))
	if bool(result.get("ok", false)):
		SaveManager.save_current_run()
	_refresh()

func _refresh() -> void:
	if heal_button != null:
		heal_button.disabled = not RunSession.can_buy_heal()
	if state_label != null:
		state_label.text = _state_text()

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
