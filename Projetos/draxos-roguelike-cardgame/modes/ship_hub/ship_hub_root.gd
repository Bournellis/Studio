extends Control

const REGION_SPECS: Array[Dictionary] = [
	{
		"id": "command_station",
		"title": "Comando",
		"body": "Comandante Draxos: escolha de Classe e estado da run.",
		"status": "Classes Arcano, Invocador e Necromante disponiveis para teste."
	},
	{
		"id": "grand_master_channel",
		"title": "Grande Mestre",
		"body": "Canal ancestral: ordens estrategicas para a invasao.",
		"status": "Comunicacao placeholder ativa."
	},
	{
		"id": "subordinate_station",
		"title": "Subordinados",
		"body": "Equipe da nave: ofertas podem variar por Classe.",
		"status": "NPCs fixos, ofertas futuras."
	},
	{
		"id": "mission_map_console",
		"title": "Mapa",
		"body": "Mapa de navegacao focado no planeta elemental.",
		"status": "Encontros de limpar board e ondas disponiveis."
	},
	{
		"id": "deck_system",
		"title": "Deck",
		"body": "Preparacao de cartas, upgrades e recompensas da run.",
		"status": "Decks iniciais mockup carregados por Classe."
	},
	{
		"id": "soul_engine",
		"title": "Almas",
		"body": "Moeda da nave para cura e upgrades entre missoes.",
		"status": "Cura paga de teste disponivel durante a run."
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
	for spec: Dictionary in REGION_SPECS:
		ids.append(str(spec.get("id", "")))
	return ids

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("ship_hub_background")
	background.name = "ShipHubVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "ShipHubVisualScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.28)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "ShipHubLayout"
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 28)
	root_margin.add_theme_constant_override("margin_top", 22)
	root_margin.add_theme_constant_override("margin_right", 28)
	root_margin.add_theme_constant_override("margin_bottom", 22)
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 14)
	root_margin.add_child(main_box)

	var header: VBoxContainer = VBoxContainer.new()
	header.name = "ShipHubHeader"
	header.add_theme_constant_override("separation", 6)
	main_box.add_child(header)

	var title: Label = Label.new()
	title.name = "ShipHubTitle"
	title.text = "Nave Draxos - Ponte de Comando"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	header.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.name = "ShipHubSubtitle"
	subtitle.text = "Comandante Draxos em campanha no planeta elemental"
	subtitle.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	header.add_child(subtitle)

	var content: HBoxContainer = HBoxContainer.new()
	content.name = "ShipHubContent"
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	main_box.add_child(content)

	var grid: GridContainer = GridContainer.new()
	grid.name = "ShipHubRegions"
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	content.add_child(grid)

	for spec: Dictionary in REGION_SPECS:
		grid.add_child(_build_region_button(spec))

	var side_panel: PanelContainer = PanelContainer.new()
	side_panel.name = "ShipHubStatusPanel"
	side_panel.custom_minimum_size = Vector2(330, 0)
	side_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel"))
	content.add_child(side_panel)

	var side_scroll: ScrollContainer = ScrollContainer.new()
	side_scroll.name = "ShipHubStatusScroll"
	side_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	side_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_panel.add_child(side_scroll)

	var side_box: VBoxContainer = VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 10)
	side_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_scroll.add_child(side_box)

	var side_title: Label = Label.new()
	side_title.text = "Estado da Nave"
	side_title.add_theme_font_size_override("font_size", 22)
	side_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	side_box.add_child(side_title)

	status_label = Label.new()
	status_label.name = "ShipHubStatus"
	status_label.text = _run_state_text()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	side_box.add_child(status_label)

	var class_title: Label = Label.new()
	class_title.text = "Classe"
	class_title.add_theme_font_size_override("font_size", 18)
	class_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	side_box.add_child(class_title)

	for class_option: Dictionary in ContentLibrary.get_class_options():
		side_box.add_child(_build_class_button(class_option))

	start_run_button = Button.new()
	start_run_button.name = "ShipHubStartRunButton"
	start_run_button.text = "Iniciar Run"
	start_run_button.pressed.connect(_on_start_run_pressed)
	side_box.add_child(start_run_button)

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
	side_box.add_child(map_button)

	heal_button = Button.new()
	heal_button.name = "ShipHubPaidHealButton"
	heal_button.text = "Cura paga"
	heal_button.pressed.connect(func() -> void:
		var result: Dictionary = RunSession.buy_paid_heal()
		status_label.text = "%s\n\n%s" % [str(result.get("message", "")), _run_state_text()]
		_refresh_run_controls()
	)
	side_box.add_child(heal_button)

	var back_button: Button = Button.new()
	back_button.name = "ShipHubBackToBootButton"
	back_button.text = "Voltar ao Boot"
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/boot/boot.tscn")
	)
	side_box.add_child(back_button)
	_refresh_run_controls()

func _build_region_button(spec: Dictionary) -> Button:
	var button: Button = Button.new()
	button.name = "Region_%s" % str(spec.get("id", "unknown"))
	button.text = "%s\n%s" % [str(spec.get("title", "")), str(spec.get("body", ""))]
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	button.custom_minimum_size = Vector2(190, 150)
	button.add_theme_stylebox_override("normal", _panel_style("bg_panel_alt"))
	button.add_theme_stylebox_override("hover", _panel_style("placeholder"))
	button.pressed.connect(func() -> void:
		_select_region(spec)
	)
	return button

func _select_region(spec: Dictionary) -> void:
	status_label.text = "%s\n\n%s\n\n%s" % [str(spec.get("body", "")), str(spec.get("status", "")), _run_state_text()]

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
		str(class_option.get("mechanic_status", "Mecanica pendente."))
	]
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 76)
	button.pressed.connect(func() -> void:
		selected_class_id = class_id
		status_label.text = "%s\n\n%s\n\n%s" % [
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

func _run_state_text() -> String:
	if not RunSession.active:
		return "Run: inativa. Escolha uma Classe para iniciar."
	var completed_text: String = "nenhum"
	if not RunSession.completed_node_ids.is_empty():
		completed_text = ", ".join(RunSession.completed_node_ids)
	var last_text: String = ""
	if RunSession.last_completed_node_id != "":
		last_text = "\nUltimo encontro: %s" % RunSession.last_completed_node_id
	return "Run: ativa\nClasse: %s\nVida: %d/%d\nMana: %d\nAlmas: %d\nSpell: %s\nNodes concluidos: %s\nRecompensas pendentes: %d\nRecompensas aplicadas: %d%s" % [
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

func _panel_style(color_token: String) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var bg_color: Color = UiTokens.color(color_token, Color(0.1, 0.11, 0.12))
	style.bg_color = Color(bg_color.r, bg_color.g, bg_color.b, 0.82)
	var border_color: Color = UiTokens.color("border_default", Color(0.25, 0.3, 0.34))
	style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	return style
