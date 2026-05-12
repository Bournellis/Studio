extends Control

const HOTSPOT_SPECS: Array[Dictionary] = [
	{
		"id": "command_station",
		"title": "Comando",
		"body": "Classe e estado da run",
		"status": "Classes Arcano, Invocador e Necromante disponiveis para teste.",
		"position": Vector2(0.50, 0.56),
		"size": Vector2(238, 58)
	},
	{
		"id": "mission_map_console",
		"title": "Mapa",
		"body": "Rota de invasao",
		"status": "Encontros de limpar board e ondas disponiveis.",
		"position": Vector2(0.75, 0.46),
		"size": Vector2(210, 54)
	},
	{
		"id": "deck_system",
		"title": "Deck",
		"body": "Cartas e upgrades",
		"status": "Decks iniciais mockup carregados por Classe.",
		"position": Vector2(0.25, 0.58),
		"size": Vector2(216, 54)
	},
	{
		"id": "soul_engine",
		"title": "Almas",
		"body": "Cura e recursos",
		"status": "Cura paga de teste disponivel durante a run.",
		"position": Vector2(0.86, 0.39),
		"size": Vector2(194, 54)
	}
]

var status_label: Label
var selected_class_id: String = ""
var start_run_button: Button
var map_button: Button
var heal_button: Button

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	selected_class_id = RunSession.selected_class_id
	_build_ui()

func get_region_ids() -> Array[String]:
	var ids: Array[String] = []
	for spec: Dictionary in HOTSPOT_SPECS:
		ids.append(str(spec.get("id", "")))
	return ids

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("ship_hub_background")
	background.name = "ShipHubVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "ShipHubVisualScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.16)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var title_panel: PanelContainer = PanelContainer.new()
	title_panel.name = "ShipHubTitlePanel"
	title_panel.anchor_left = 0.02
	title_panel.anchor_top = 0.03
	title_panel.anchor_right = 0.40
	title_panel.anchor_bottom = 0.03
	title_panel.offset_right = 0.0
	title_panel.offset_bottom = 86.0
	title_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", 0.50))
	add_child(title_panel)

	var title_box: VBoxContainer = VBoxContainer.new()
	title_box.add_theme_constant_override("separation", 3)
	title_panel.add_child(title_box)

	var title: Label = Label.new()
	title.name = "ShipHubTitle"
	title.text = "Nave Draxos"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title_box.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.name = "ShipHubSubtitle"
	subtitle.text = "Ponte de comando da invasao elemental"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", UiTokens.color("text_secondary", Color(0.74, 0.78, 0.8)))
	title_box.add_child(subtitle)

	var hotspot_layer: Control = Control.new()
	hotspot_layer.name = "ShipHubHotspots"
	hotspot_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hotspot_layer)

	for spec: Dictionary in HOTSPOT_SPECS:
		hotspot_layer.add_child(_build_hotspot_button(spec))

	_build_class_panel()
	_build_action_panel()
	_refresh_run_controls()

func _build_class_panel() -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "ShipHubCommandPanel"
	panel.anchor_left = 0.02
	panel.anchor_top = 1.0
	panel.anchor_right = 0.60
	panel.anchor_bottom = 1.0
	panel.offset_top = -202.0
	panel.offset_bottom = -20.0
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", 0.66))
	add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	box.add_child(header)

	var class_title: Label = Label.new()
	class_title.text = "Classe do Comandante"
	class_title.add_theme_font_size_override("font_size", 18)
	class_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	class_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(class_title)

	var run_summary: Label = Label.new()
	run_summary.text = _compact_run_summary()
	run_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	run_summary.add_theme_font_size_override("font_size", 12)
	run_summary.add_theme_color_override("font_color", Color(0.86, 0.92, 0.94))
	header.add_child(run_summary)

	var class_row: HBoxContainer = HBoxContainer.new()
	class_row.name = "ShipHubClassRow"
	class_row.add_theme_constant_override("separation", 8)
	box.add_child(class_row)

	for class_option: Dictionary in ContentLibrary.get_class_options():
		class_row.add_child(_build_class_button(class_option))

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "ShipHubStatusScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.custom_minimum_size = Vector2(0, 44)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	status_label = Label.new()
	status_label.name = "ShipHubStatus"
	status_label.text = _run_state_text()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(status_label)

func _build_action_panel() -> void:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "ShipHubActionPanel"
	panel.anchor_left = 1.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -286.0
	panel.offset_top = -248.0
	panel.offset_right = -20.0
	panel.offset_bottom = -20.0
	panel.add_theme_stylebox_override("panel", _panel_style("bg_panel_alt", 0.70))
	add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)

	var title: Label = Label.new()
	title.text = "Acoes"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	start_run_button = Button.new()
	start_run_button.name = "ShipHubStartRunButton"
	start_run_button.text = "Iniciar Run"
	start_run_button.pressed.connect(_on_start_run_pressed)
	box.add_child(start_run_button)

	map_button = Button.new()
	map_button.name = "ShipHubOpenRunMapButton"
	map_button.text = "Abrir Mapa de Missao"
	map_button.pressed.connect(func() -> void:
		if not RunSession.active:
			status_label.text = "Escolha uma Classe e inicie a run antes de abrir o mapa."
			_refresh_run_controls()
			return
		get_tree().change_scene_to_file("res://modes/run_map/run_map.tscn")
	)
	box.add_child(map_button)

	heal_button = Button.new()
	heal_button.name = "ShipHubPaidHealButton"
	heal_button.text = "Cura paga"
	heal_button.pressed.connect(func() -> void:
		var result: Dictionary = RunSession.buy_paid_heal()
		status_label.text = "%s\n\n%s" % [str(result.get("message", "")), _run_state_text()]
		_refresh_run_controls()
	)
	box.add_child(heal_button)

	var back_button: Button = Button.new()
	back_button.name = "ShipHubBackToBootButton"
	back_button.text = "Voltar ao Boot"
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/boot/boot.tscn")
	)
	box.add_child(back_button)

func _build_hotspot_button(spec: Dictionary) -> Button:
	var button: Button = Button.new()
	button.name = "ShipHubHotspot_%s" % str(spec.get("id", "unknown"))
	button.text = "%s\n%s" % [str(spec.get("title", "")), str(spec.get("body", ""))]
	button.tooltip_text = str(spec.get("status", ""))
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	var size: Vector2 = spec.get("size", Vector2(200, 54))
	var position: Vector2 = spec.get("position", Vector2(0.5, 0.5))
	button.anchor_left = position.x
	button.anchor_top = position.y
	button.anchor_right = position.x
	button.anchor_bottom = position.y
	button.offset_left = -size.x * 0.5
	button.offset_top = -size.y * 0.5
	button.offset_right = size.x * 0.5
	button.offset_bottom = size.y * 0.5
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_stylebox_override("normal", _hotspot_style(false))
	button.add_theme_stylebox_override("hover", _hotspot_style(true))
	button.add_theme_stylebox_override("pressed", _hotspot_style(true))
	button.pressed.connect(func() -> void:
		_select_region(spec)
	)
	return button

func _select_region(spec: Dictionary) -> void:
	status_label.text = "%s\n%s\n\n%s" % [
		str(spec.get("body", "")),
		str(spec.get("status", "")),
		_run_state_text()
	]

func _on_start_run_pressed() -> void:
	if selected_class_id == "":
		status_label.text = "Escolha uma Classe antes de iniciar a run."
		_refresh_run_controls()
		return
	var result: Dictionary = RunSession.start_class_run(selected_class_id)
	status_label.text = str(result.get("message", "Run iniciada."))
	_refresh_run_controls()

func _build_class_button(class_option: Dictionary) -> Button:
	var button: Button = Button.new()
	var class_id: String = str(class_option.get("id", ""))
	button.name = "ShipHubClass_%s" % class_id
	button.text = "%s\n%s" % [
		str(class_option.get("display_name", class_id)),
		str(class_option.get("role_text", ""))
	]
	button.tooltip_text = "%s\n%s" % [
		str(class_option.get("mechanic_status", "")),
		str(class_option.get("active_text", ""))
	]
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.custom_minimum_size = Vector2(0, 66)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 11)
	button.pressed.connect(func() -> void:
		selected_class_id = class_id
		status_label.text = "%s\n%s\n%s" % [
			str(class_option.get("role_text", "")),
			str(class_option.get("mechanic_status", "")),
			str(class_option.get("active_text", ""))
		]
		_refresh_run_controls()
	)
	return button

func _refresh_run_controls() -> void:
	if start_run_button != null:
		start_run_button.disabled = selected_class_id == ""
	if map_button != null:
		map_button.disabled = not RunSession.active
	if heal_button != null:
		heal_button.disabled = not RunSession.can_buy_heal()
		heal_button.text = "Curar %d por %d almas" % [RunSession.PAID_HEAL_AMOUNT, RunSession.PAID_HEAL_COST]

func _compact_run_summary() -> String:
	if not RunSession.active:
		return "Run inativa"
	return "%s | Vida %d/%d | Mana %d | Almas %d" % [
		RunSession.selected_class_display_name,
		RunSession.current_health,
		RunSession.max_health,
		RunSession.max_mana,
		RunSession.soul_total
	]

func _run_state_text() -> String:
	if not RunSession.active:
		return "Run: inativa. Escolha uma Classe para iniciar."
	var completed_text: String = "nenhum"
	if not RunSession.completed_node_ids.is_empty():
		completed_text = ", ".join(RunSession.completed_node_ids)
	var last_text: String = ""
	if RunSession.last_completed_node_id != "":
		last_text = "\nUltimo encontro: %s" % RunSession.last_completed_node_id
	return "Run: ativa | Classe: %s | Vida: %d/%d | Mana: %d | Almas: %d\nSpell: %s\nNodes concluidos: %s | Recompensas pendentes: %d | Aplicadas: %d%s" % [
		RunSession.selected_class_display_name,
		RunSession.current_health,
		RunSession.max_health,
		RunSession.max_mana,
		RunSession.soul_total,
		RunSession.selected_class_active_text,
		completed_text,
		RunSession.rewards_pending.size(),
		RunSession.applied_reward_ids.size(),
		last_text
	]

func _panel_style(color_token: String, alpha: float = 0.72) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var bg_color: Color = UiTokens.color(color_token, Color(0.1, 0.11, 0.12))
	style.bg_color = Color(bg_color.r, bg_color.g, bg_color.b, alpha)
	var border_color: Color = UiTokens.color("border_default", Color(0.25, 0.3, 0.34))
	style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.72)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	return style

func _hotspot_style(is_hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.055, 0.065, 0.42 if not is_hover else 0.64)
	style.border_color = Color(0.55, 0.86, 0.96, 0.60 if not is_hover else 0.95)
	style.set_border_width_all(1 if not is_hover else 2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10
	style.content_margin_top = 7
	style.content_margin_right = 10
	style.content_margin_bottom = 7
	return style
