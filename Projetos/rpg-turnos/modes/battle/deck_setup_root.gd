extends Control

var deck_slots: Array = []
const CardPoolDropZoneScript = preload("res://ui/controls/card_pool_drop_zone.gd")
const CardTokenScript = preload("res://ui/controls/card_token.gd")
const DeckSlotControlScript = preload("res://ui/controls/deck_slot_control.gd")

var pool_container
var pool_summary_label: Label
var deck_summary_label: Label
var status_label: Label
var start_button: Button
var selected_deck: Array = []
var slot_grid: GridContainer

func _ready() -> void:
	selected_deck = GameSession.selected_deck_ids.duplicate()
	ContentLibrary.ensure_loaded()
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.045, 0.052, 0.058)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 18
	root.offset_top = 14
	root.offset_right = -18
	root.offset_bottom = -14
	root.add_theme_constant_override("separation", 12)
	add_child(root)

	var title: Label = Label.new()
	title.text = "Setup do Deck"
	title.add_theme_font_size_override("font_size", 28)
	root.add_child(title)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)

	var columns: HBoxContainer = HBoxContainer.new()
	columns.custom_minimum_size = Vector2(0, 380)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	root.add_child(columns)

	var pool_panel: PanelContainer = PanelContainer.new()
	pool_panel.custom_minimum_size = Vector2(300, 0)
	pool_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pool_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pool_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.1, 0.11)))
	columns.add_child(pool_panel)

	var pool_box: VBoxContainer = VBoxContainer.new()
	pool_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pool_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pool_box.add_theme_constant_override("separation", 8)
	pool_panel.add_child(pool_box)

	var pool_title: Label = Label.new()
	pool_title.text = "Cartas desbloqueadas disponiveis"
	pool_box.add_child(pool_title)

	pool_summary_label = Label.new()
	pool_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pool_box.add_child(pool_summary_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 320)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pool_box.add_child(scroll)

	pool_container = CardPoolDropZoneScript.new()
	pool_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pool_container.deck_card_returned.connect(_on_deck_card_returned)
	scroll.add_child(pool_container)

	var deck_panel: PanelContainer = PanelContainer.new()
	deck_panel.custom_minimum_size = Vector2(430, 0)
	deck_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1)))
	columns.add_child(deck_panel)

	var deck_box: VBoxContainer = VBoxContainer.new()
	deck_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_box.add_theme_constant_override("separation", 8)
	deck_panel.add_child(deck_box)

	var deck_title: Label = Label.new()
	deck_title.text = "Deck selecionado"
	deck_box.add_child(deck_title)

	deck_summary_label = Label.new()
	deck_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	deck_box.add_child(deck_summary_label)

	var deck_scroll: ScrollContainer = ScrollContainer.new()
	deck_scroll.custom_minimum_size = Vector2(0, 320)
	deck_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	deck_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	deck_box.add_child(deck_scroll)

	slot_grid = GridContainer.new()
	slot_grid.columns = 2
	slot_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot_grid.add_theme_constant_override("h_separation", 8)
	slot_grid.add_theme_constant_override("v_separation", 8)
	deck_scroll.add_child(slot_grid)

	for index: int in range(GameSession.REQUIRED_DECK_SIZE):
		var slot = DeckSlotControlScript.new()
		slot.card_dropped.connect(_on_card_dropped_on_slot)
		slot.clear_requested.connect(_on_clear_slot)
		deck_slots.append(slot)
		slot_grid.add_child(slot)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("separation", 8)
	root.add_child(actions)

	var back_button: Button = Button.new()
	back_button.text = "Voltar ao mapa"
	back_button.custom_minimum_size = Vector2(150, 40)
	back_button.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://modes/world/world.tscn"))
	actions.add_child(back_button)

	var clear_button: Button = Button.new()
	clear_button.text = "Limpar deck"
	clear_button.custom_minimum_size = Vector2(140, 40)
	clear_button.pressed.connect(_clear_deck)
	actions.add_child(clear_button)

	var auto_fill_button: Button = Button.new()
	auto_fill_button.text = "Auto preencher"
	auto_fill_button.custom_minimum_size = Vector2(150, 40)
	auto_fill_button.pressed.connect(_auto_fill_deck)
	actions.add_child(auto_fill_button)

	start_button = Button.new()
	start_button.text = "Iniciar encontro"
	start_button.custom_minimum_size = Vector2(180, 40)
	start_button.pressed.connect(_on_start_pressed)
	actions.add_child(start_button)

func _refresh() -> void:
	while selected_deck.size() < GameSession.REQUIRED_DECK_SIZE:
		selected_deck.append("")
	for index: int in range(deck_slots.size()):
		deck_slots[index].setup(index, str(selected_deck[index]))

	for child: Node in pool_container.get_children():
		pool_container.remove_child(child)
		child.free()
	var available_entries: Array = _available_pool_entries()
	for entry: Dictionary in available_entries:
		var entry_box: VBoxContainer = VBoxContainer.new()
		entry_box.custom_minimum_size = Vector2(168, 0)
		entry_box.add_theme_constant_override("separation", 6)
		pool_container.add_child(entry_box)

		var token = CardTokenScript.new()
		token.setup(str(entry.get("card_id", "")), "pool", int(entry.get("pool_index", -1)))
		entry_box.add_child(token)

		var add_button: Button = Button.new()
		add_button.text = "Adicionar"
		add_button.pressed.connect(_add_pool_card_to_first_open.bind(str(entry.get("card_id", ""))))
		entry_box.add_child(add_button)

	if available_entries.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "Todas as cartas desbloqueadas ja estao no deck."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		pool_container.add_child(empty_label)

	var selected_count: int = _compact_deck().size()
	var valid: bool = GameSession.is_deck_valid(_compact_deck())
	start_button.disabled = not valid
	pool_summary_label.text = "Disponiveis fora do deck: %d." % available_entries.size()
	deck_summary_label.text = "Selecionadas: %d/%d. O deck precisa estar completo para iniciar." % [
		selected_count,
		GameSession.REQUIRED_DECK_SIZE
	]
	status_label.text = "Arraste cartas, use Adicionar, ou ajuste com Limpar deck e Auto preencher."
	if not valid:
		status_label.text += " Deck atual: %d/%d." % [selected_count, GameSession.REQUIRED_DECK_SIZE]
	else:
		status_label.text += " Deck valido para o encontro ativo."

func _available_pool_entries() -> Array:
	var remaining: Array = GameSession.unlocked_card_ids.duplicate()
	for card_id: Variant in selected_deck:
		if str(card_id) == "":
			continue
		var index: int = remaining.find(str(card_id))
		if index != -1:
			remaining.remove_at(index)

	var entries: Array = []
	for index: int in range(remaining.size()):
		entries.append({"card_id": str(remaining[index]), "pool_index": index})
	return entries

func _compact_deck() -> Array:
	var result: Array = []
	for card_id: Variant in selected_deck:
		if str(card_id) != "":
			result.append(str(card_id))
	return result

func _on_card_dropped_on_slot(card_id: String, slot_index: int, source: String, source_index: int) -> void:
	if slot_index < 0 or slot_index >= selected_deck.size():
		return
	if source == "deck" and source_index >= 0 and source_index < selected_deck.size():
		selected_deck[source_index] = selected_deck[slot_index]
	selected_deck[slot_index] = card_id
	call_deferred("_refresh")

func _on_clear_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < selected_deck.size():
		selected_deck[slot_index] = ""
	call_deferred("_refresh")

func _on_deck_card_returned(deck_index: int) -> void:
	_on_clear_slot(deck_index)

func _add_pool_card_to_first_open(card_id: String) -> void:
	for index: int in range(selected_deck.size()):
		if str(selected_deck[index]) == "":
			selected_deck[index] = card_id
			_refresh()
			return

func _clear_deck() -> void:
	selected_deck.clear()
	for _index: int in range(GameSession.REQUIRED_DECK_SIZE):
		selected_deck.append("")
	_refresh()

func _auto_fill_deck() -> void:
	while selected_deck.size() < GameSession.REQUIRED_DECK_SIZE:
		selected_deck.append("")
	var available: Array = _available_pool_entries()
	for index: int in range(selected_deck.size()):
		if str(selected_deck[index]) != "":
			continue
		if available.is_empty():
			break
		selected_deck[index] = str(available.pop_front().get("card_id", ""))
	_refresh()

func _on_start_pressed() -> void:
	var compact: Array = _compact_deck()
	if not GameSession.set_selected_deck(compact):
		_refresh()
		return
	get_tree().change_scene_to_file("res://modes/battle/battle.tscn")

func _panel_style(fill: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color(0.25, 0.3, 0.33)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	return style
