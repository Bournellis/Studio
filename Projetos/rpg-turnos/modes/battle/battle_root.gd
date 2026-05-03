extends Control

const BattleEngineScript = preload("res://battle/battle_engine.gd")
const BattleSlotControlScript = preload("res://ui/controls/battle_slot_control.gd")
const BattleCardTokenScript = preload("res://ui/controls/battle_card_token.gd")
const EnemyHeroDropZoneScript = preload("res://ui/controls/enemy_hero_drop_zone.gd")

var engine
var status_label: Label
var feedback_label: Label
var log_label: Label
var enemy_hero_zone
var enemy_slots_box: HBoxContainer
var player_slots_box: HBoxContainer
var hand_box: HBoxContainer
var end_turn_button: Button
var hero_power_button: Button
var last_feedback: String = ""

func _ready() -> void:
	engine = BattleEngineScript.new()
	engine.start_battle(ContentLibrary.get_catalog(), GameSession.selected_deck_ids)
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.045, 0.05, 0.055)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 16
	root.offset_top = 12
	root.offset_right = -16
	root.offset_bottom = -12
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	var header_panel: PanelContainer = PanelContainer.new()
	header_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1)))
	root.add_child(header_panel)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	header_panel.add_child(header)

	status_label = Label.new()
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_font_size_override("font_size", 19)
	header.add_child(status_label)

	hero_power_button = Button.new()
	hero_power_button.text = "Poder heroico"
	hero_power_button.custom_minimum_size = Vector2(150, 40)
	hero_power_button.pressed.connect(_on_hero_power_pressed)
	header.add_child(hero_power_button)

	end_turn_button = Button.new()
	end_turn_button.text = "Resolver turno"
	end_turn_button.custom_minimum_size = Vector2(170, 40)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	header.add_child(end_turn_button)

	feedback_label = Label.new()
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(feedback_label)

	var main_area: HBoxContainer = HBoxContainer.new()
	main_area.custom_minimum_size = Vector2(0, 300)
	main_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_area.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	main_area.add_theme_constant_override("separation", 10)
	root.add_child(main_area)

	var board_panel: PanelContainer = PanelContainer.new()
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.07, 0.08, 0.085)))
	main_area.add_child(board_panel)

	var board_root: VBoxContainer = VBoxContainer.new()
	board_root.add_theme_constant_override("separation", 5)
	board_panel.add_child(board_root)

	var enemy_title: Label = Label.new()
	enemy_title.text = "Campo inimigo"
	enemy_title.add_theme_font_size_override("font_size", 15)
	board_root.add_child(enemy_title)

	enemy_hero_zone = EnemyHeroDropZoneScript.new()
	enemy_hero_zone.custom_minimum_size = Vector2(0, 44)
	enemy_hero_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_hero_zone.add_theme_stylebox_override("panel", _panel_style(Color(0.16, 0.08, 0.09)))
	enemy_hero_zone.card_dropped.connect(_on_card_dropped_on_enemy_hero)
	board_root.add_child(enemy_hero_zone)

	enemy_slots_box = HBoxContainer.new()
	enemy_slots_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_slots_box.add_theme_constant_override("separation", 10)
	board_root.add_child(enemy_slots_box)

	var route_label: Label = Label.new()
	route_label.text = "Rotas diretas: P1 x E1 | P2 x E2 | P3 x E3"
	route_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	board_root.add_child(route_label)

	var player_title: Label = Label.new()
	player_title.text = "Campo do jogador"
	player_title.add_theme_font_size_override("font_size", 15)
	board_root.add_child(player_title)

	player_slots_box = HBoxContainer.new()
	player_slots_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_slots_box.add_theme_constant_override("separation", 10)
	board_root.add_child(player_slots_box)

	var log_panel: PanelContainer = PanelContainer.new()
	log_panel.custom_minimum_size = Vector2(320, 0)
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.085, 0.09)))
	main_area.add_child(log_panel)

	var log_root: VBoxContainer = VBoxContainer.new()
	log_root.add_theme_constant_override("separation", 5)
	log_panel.add_child(log_root)

	var log_title: Label = Label.new()
	log_title.text = "Log do turno"
	log_title.add_theme_font_size_override("font_size", 15)
	log_root.add_child(log_title)

	var log_scroll: ScrollContainer = ScrollContainer.new()
	log_scroll.custom_minimum_size = Vector2(0, 240)
	log_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_root.add_child(log_scroll)

	log_label = Label.new()
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_scroll.add_child(log_label)

	var hand_panel: PanelContainer = PanelContainer.new()
	hand_panel.custom_minimum_size = Vector2(0, 132)
	hand_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1)))
	root.add_child(hand_panel)

	var hand_root: VBoxContainer = VBoxContainer.new()
	hand_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_root.add_theme_constant_override("separation", 0)
	hand_panel.add_child(hand_root)

	var hand_scroll: ScrollContainer = ScrollContainer.new()
	hand_scroll.custom_minimum_size = Vector2(0, 112)
	hand_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hand_root.add_child(hand_scroll)

	hand_box = HBoxContainer.new()
	hand_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_box.add_theme_constant_override("separation", 8)
	hand_scroll.add_child(hand_box)

func _refresh() -> void:
	status_label.text = "Rodada %d | Energia %d | Jogador %d HP | Inimigo %d HP | Deck %d" % [
		engine.round_number,
		engine.energy,
		engine.player_health,
		engine.enemy_health,
		engine.deck.size()
	]
	if last_feedback == "":
		feedback_label.text = "Jogue uma carta por drag-and-drop ou use os botoes abaixo de cada carta."
	else:
		feedback_label.text = last_feedback

	for child: Node in enemy_hero_zone.get_children():
		enemy_hero_zone.remove_child(child)
		child.free()
	var enemy_hero_label: Label = Label.new()
	enemy_hero_label.text = "Heroi inimigo: %d HP" % engine.enemy_health
	enemy_hero_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_hero_zone.add_child(enemy_hero_label)

	_rebuild_slot_row(enemy_slots_box, "enemy", engine.enemy_slots)
	_rebuild_slot_row(player_slots_box, "player", engine.player_slots)
	_rebuild_hand()
	log_label.text = "\n".join(engine.log_lines)
	end_turn_button.disabled = engine.outcome != ""
	hero_power_button.disabled = engine.outcome != "" or engine.hero_power_used or engine.deck.is_empty()

	if engine.outcome != "":
		_finish_battle()

func _rebuild_slot_row(container: HBoxContainer, owner: String, slots: Array) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.free()
	for index: int in range(slots.size()):
		var slot = BattleSlotControlScript.new()
		slot.setup(owner, index, slots[index])
		slot.card_dropped.connect(_on_card_dropped_on_slot)
		container.add_child(slot)

func _rebuild_hand() -> void:
	for child: Node in hand_box.get_children():
		hand_box.remove_child(child)
		child.free()
	for index: int in range(engine.hand.size()):
		var card_id: String = str(engine.hand[index])
		var token = BattleCardTokenScript.new()
		token.setup(card_id, index)

		var card_box: VBoxContainer = VBoxContainer.new()
		card_box.custom_minimum_size = Vector2(172, 0)
		card_box.add_theme_constant_override("separation", 2)
		card_box.add_child(token)
		_add_hand_action_controls(card_box, ContentLibrary.get_card(card_id), index)
		hand_box.add_child(card_box)

func _on_card_dropped_on_slot(data: Dictionary, owner: String, slot_index: int) -> void:
	var card = ContentLibrary.get_card(str(data.get("card_id", "")))
	var target: Dictionary = {"owner": owner, "slot": slot_index}
	if card != null and card.is_buff_command():
		target["owner"] = "player"
	var result: Dictionary = engine.play_card_from_hand(int(data.get("hand_index", -1)), target)
	_record_action_feedback(result)
	call_deferred("_refresh")

func _on_card_dropped_on_enemy_hero(data: Dictionary) -> void:
	var result: Dictionary = engine.play_card_from_hand(int(data.get("hand_index", -1)), {"owner": "enemy", "slot": -1})
	_record_action_feedback(result)
	call_deferred("_refresh")

func _on_end_turn_pressed() -> void:
	var result: Dictionary = engine.end_player_turn()
	_record_action_feedback(result)
	_refresh()

func _on_hero_power_pressed() -> void:
	var result: Dictionary = engine.use_player_hero_power()
	_record_action_feedback(result)
	call_deferred("_refresh")

func _add_hand_action_controls(parent: VBoxContainer, card, hand_index: int) -> void:
	if card == null:
		return

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)

	if card.occupies_slot():
		for lane: int in range(3):
			var button: Button = _small_action_button("P%d" % (lane + 1))
			button.disabled = card.cost > engine.energy or engine.player_slots[lane] != null
			button.pressed.connect(_play_hand_card_to_player_slot.bind(hand_index, lane))
			row.add_child(button)
	elif card.is_damage_spell():
		var hero_button: Button = _small_action_button("Heroi")
		hero_button.disabled = card.cost > engine.energy
		hero_button.pressed.connect(_play_hand_card_to_enemy_hero.bind(hand_index))
		row.add_child(hero_button)
		for lane: int in range(3):
			var button: Button = _small_action_button("E%d" % (lane + 1))
			button.disabled = card.cost > engine.energy or engine.enemy_slots[lane] == null
			button.pressed.connect(_play_hand_card_to_enemy_slot.bind(hand_index, lane))
			row.add_child(button)
	elif card.is_buff_command():
		for lane: int in range(3):
			var button: Button = _small_action_button("P%d" % (lane + 1))
			button.disabled = card.cost > engine.energy or engine.player_slots[lane] == null
			button.pressed.connect(_play_hand_card_to_player_slot.bind(hand_index, lane))
			row.add_child(button)

func _small_action_button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(40, 24)
	button.add_theme_font_size_override("font_size", 12)
	return button

func _play_hand_card_to_player_slot(hand_index: int, slot_index: int) -> void:
	var result: Dictionary = engine.play_card_from_hand(hand_index, {"owner": "player", "slot": slot_index})
	_record_action_feedback(result)
	call_deferred("_refresh")

func _play_hand_card_to_enemy_slot(hand_index: int, slot_index: int) -> void:
	var result: Dictionary = engine.play_card_from_hand(hand_index, {"owner": "enemy", "slot": slot_index})
	_record_action_feedback(result)
	call_deferred("_refresh")

func _play_hand_card_to_enemy_hero(hand_index: int) -> void:
	var result: Dictionary = engine.play_card_from_hand(hand_index, {"owner": "enemy", "slot": -1})
	_record_action_feedback(result)
	call_deferred("_refresh")

func _record_action_feedback(result: Dictionary) -> void:
	last_feedback = str(result.get("message", ""))

func _finish_battle() -> void:
	if engine.outcome == "victory":
		GameSession.complete_encounter("O duelista foi vencido no primeiro encontro.")
	else:
		GameSession.record_defeat("O heroi caiu; o estado pre-combate sera restaurado.")
	get_tree().change_scene_to_file("res://modes/battle/result.tscn")

func _panel_style(fill: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color(0.26, 0.3, 0.32)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	return style
