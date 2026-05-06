extends Control

const BattleEngineScript = preload("res://battle/battle_engine.gd")
const BattleSlotControlScript = preload("res://ui/controls/battle_slot_control.gd")
const BattleCardTokenScript = preload("res://ui/controls/battle_card_token.gd")
const EnemyHeroDropZoneScript = preload("res://ui/controls/enemy_hero_drop_zone.gd")

const PLAYER_OWNER: String = "jogador"
const ENEMY_OWNER: String = "inimigo"
const UI_MARGIN: float = 12.0
const SLOT_CARD_WIDTH: float = 164.0
const HAND_CARD_WIDTH: float = 160.0

var engine
var status_label: Label
var variant_label: Label
var phase_label: Label
var priority_label: Label
var wave_label: Label
var feedback_label: Label
var log_label: Label
var route_label: Label
var player_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var player_portrait_rect: TextureRect
var enemy_portrait_rect: TextureRect
var energy_pips_box: HBoxContainer
var priority_dot: ColorRect
var hand_limit_label: Label
var discard_counter_label: Label
var discard_bar: ProgressBar
var enemy_hero_zone
var enemy_slots_box: HBoxContainer
var player_slots_box: HBoxContainer
var hand_box: HBoxContainer
var end_turn_button: Button
var hero_power_button: Button
var visual_layer: Control
var last_feedback: String = ""
var _visual_event_cursor: int = 0

func _ready() -> void:
	_fit_to_viewport()
	if not get_tree().root.size_changed.is_connected(_fit_to_viewport):
		get_tree().root.size_changed.connect(_fit_to_viewport)
	engine = BattleEngineScript.new()
	engine.start_battle(ContentLibrary.get_catalog(), GameSession.selected_deck_ids, GameSession.get_battle_config())
	_build_ui()
	_refresh()

func _exit_tree() -> void:
	if get_tree().root.size_changed.is_connected(_fit_to_viewport):
		get_tree().root.size_changed.disconnect(_fit_to_viewport)

func _fit_to_viewport() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.045, 0.05, 0.055)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = UI_MARGIN
	root.offset_top = UI_MARGIN
	root.offset_right = -UI_MARGIN
	root.offset_bottom = -UI_MARGIN
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	_build_header(root)

	feedback_label = Label.new()
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.clip_text = true
	feedback_label.max_lines_visible = 2
	root.add_child(feedback_label)

	_build_battlefield(root)
	_build_hand(root)

	visual_layer = Control.new()
	visual_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(visual_layer)

func _build_header(root: VBoxContainer) -> void:
	var header_panel: PanelContainer = PanelContainer.new()
	header_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1)))
	root.add_child(header_panel)

	var header_root: VBoxContainer = VBoxContainer.new()
	header_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_root.add_theme_constant_override("separation", 6)
	header_panel.add_child(header_root)

	var info_grid: GridContainer = GridContainer.new()
	info_grid.columns = 5
	info_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_grid.add_theme_constant_override("h_separation", 8)
	info_grid.add_theme_constant_override("v_separation", 2)
	header_root.add_child(info_grid)

	status_label = _header_info_label(18)
	variant_label = _header_info_label(14)
	phase_label = _header_info_label(14)
	priority_label = _header_info_label(14)
	wave_label = _header_info_label(14)
	wave_label.name = "wave_label"
	info_grid.add_child(status_label)
	info_grid.add_child(variant_label)
	info_grid.add_child(phase_label)
	info_grid.add_child(priority_label)
	info_grid.add_child(wave_label)

	var vitals_row: HBoxContainer = HBoxContainer.new()
	vitals_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vitals_row.add_theme_constant_override("separation", 10)
	header_root.add_child(vitals_row)

	player_portrait_rect = _portrait_rect("player_portrait_rect", "portrait_hero_aprendiz")
	vitals_row.add_child(player_portrait_rect)

	player_hp_bar = _stat_bar("player_hp_bar", "Jogador")
	vitals_row.add_child(player_hp_bar)

	enemy_portrait_rect = _portrait_rect("enemy_portrait_rect", "portrait_hero_duelista_bandido")
	vitals_row.add_child(enemy_portrait_rect)

	enemy_hp_bar = _stat_bar("enemy_hp_bar", "Inimigo")
	vitals_row.add_child(enemy_hp_bar)

	priority_dot = ColorRect.new()
	priority_dot.name = "priority_dot"
	priority_dot.custom_minimum_size = Vector2(18, 18)
	vitals_row.add_child(priority_dot)

	energy_pips_box = HBoxContainer.new()
	energy_pips_box.name = "energy_pips"
	energy_pips_box.custom_minimum_size = Vector2(150, 22)
	energy_pips_box.add_theme_constant_override("separation", 3)
	vitals_row.add_child(energy_pips_box)

	hand_limit_label = _header_info_label(12)
	hand_limit_label.name = "hand_limit_label"
	vitals_row.add_child(hand_limit_label)

	discard_counter_label = _header_info_label(12)
	discard_counter_label.name = "discard_counter_label"
	vitals_row.add_child(discard_counter_label)

	discard_bar = ProgressBar.new()
	discard_bar.name = "discard_bar"
	discard_bar.custom_minimum_size = Vector2(96, 18)
	discard_bar.show_percentage = false
	vitals_row.add_child(discard_bar)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 8)
	header_root.add_child(actions)

	hero_power_button = Button.new()
	hero_power_button.name = "hero_power_button"
	hero_power_button.text = "Defesa astral"
	hero_power_button.custom_minimum_size = Vector2(142, 36)
	hero_power_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	hero_power_button.pressed.connect(_on_hero_power_pressed)
	actions.add_child(hero_power_button)

	end_turn_button = Button.new()
	end_turn_button.name = "end_turn_button"
	end_turn_button.text = "Resolver turno"
	end_turn_button.custom_minimum_size = Vector2(188, 36)
	end_turn_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	actions.add_child(end_turn_button)

func _build_battlefield(root: VBoxContainer) -> void:
	var board_panel: PanelContainer = PanelContainer.new()
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.07, 0.08, 0.085)))
	root.add_child(board_panel)

	var board_scroll: ScrollContainer = ScrollContainer.new()
	board_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_child(board_scroll)

	var board_root: VBoxContainer = VBoxContainer.new()
	board_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_root.add_theme_constant_override("separation", 6)
	board_scroll.add_child(board_root)

	var enemy_title: Label = _section_label("Campo inimigo")
	board_root.add_child(enemy_title)

	enemy_hero_zone = EnemyHeroDropZoneScript.new()
	enemy_hero_zone.custom_minimum_size = Vector2(0, 42)
	enemy_hero_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_hero_zone.add_theme_stylebox_override("panel", _panel_style(Color(0.16, 0.08, 0.09)))
	enemy_hero_zone.card_dropped.connect(_on_card_dropped_on_enemy_hero)
	board_root.add_child(enemy_hero_zone)

	enemy_slots_box = _build_slot_row(board_root, "enemy_lane_panel")

	route_label = Label.new()
	route_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	route_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_label.clip_text = true
	route_label.max_lines_visible = 2
	board_root.add_child(route_label)

	var player_title: Label = _section_label("Campo do jogador")
	board_root.add_child(player_title)

	player_slots_box = _build_slot_row(board_root, "player_lane_panel")

	var log_panel: PanelContainer = PanelContainer.new()
	log_panel.custom_minimum_size = Vector2(0, 96)
	log_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.085, 0.09)))
	board_root.add_child(log_panel)

	var log_root: VBoxContainer = VBoxContainer.new()
	log_root.add_theme_constant_override("separation", 4)
	log_panel.add_child(log_root)

	var log_title: Label = _section_label("Log do turno")
	log_root.add_child(log_title)

	var log_scroll: ScrollContainer = ScrollContainer.new()
	log_scroll.custom_minimum_size = Vector2(0, 64)
	log_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_root.add_child(log_scroll)

	log_label = Label.new()
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_scroll.add_child(log_label)

func _build_slot_row(parent: VBoxContainer, panel_name: String) -> HBoxContainer:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = panel_name
	scroll.custom_minimum_size = Vector2(0, 126)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(scroll)

	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8)
	scroll.add_child(row)
	return row

func _build_hand(root: VBoxContainer) -> void:
	var hand_panel: PanelContainer = PanelContainer.new()
	hand_panel.custom_minimum_size = Vector2(0, 138)
	hand_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1)))
	root.add_child(hand_panel)

	var hand_scroll: ScrollContainer = ScrollContainer.new()
	hand_scroll.custom_minimum_size = Vector2(0, 116)
	hand_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hand_panel.add_child(hand_scroll)

	hand_box = HBoxContainer.new()
	hand_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_box.add_theme_constant_override("separation", 8)
	hand_scroll.add_child(hand_box)

func _refresh() -> void:
	var enemy_text: String = "Inimigo %d HP" % engine.enemy_health
	if not engine._controller_has_hero(ENEMY_OWNER):
		enemy_text = "Sem heroi inimigo"
	status_label.text = "Turno %d | Energia %d | Armadura %d | Jogador %d HP | %s | Deck %d | Mao %d" % [
		engine.turno,
		engine.energy,
		engine.player_armor,
		engine.player_health,
		enemy_text,
		engine.deck.size(),
		engine.hand.size()
	]
	variant_label.text = "Modo: %s" % engine.get_mode_label()
	phase_label.text = "Fase: %s" % engine.get_phase_label()
	priority_label.text = "%s | %s" % [engine.get_active_controller_label(), engine.get_priority_label()]
	wave_label.text = engine.get_mode_progress_label()
	wave_label.visible = wave_label.text != ""
	route_label.text = engine.get_board_route_summary()
	_update_vitals()
	if last_feedback == "":
		feedback_label.text = "Use cartas, ataques, Preparar Defesa ou passe prioridade durante a fase principal."
	else:
		feedback_label.text = last_feedback

	for child: Node in enemy_hero_zone.get_children():
		enemy_hero_zone.remove_child(child)
		child.free()
	var enemy_hero_label: Label = Label.new()
	if engine.modo_batalha == BattleEngineScript.MODE_DUEL:
		enemy_hero_label.text = "Heroi inimigo: %d HP | Armadura %d" % [engine.enemy_health, engine.enemy_armor]
	elif engine.modo_batalha == BattleEngineScript.MODE_WAVES:
		enemy_hero_label.text = "Sem heroi inimigo | Objetivo: vencer %s" % engine.get_wave_label()
	elif engine.modo_batalha == BattleEngineScript.MODE_DEFENSE:
		enemy_hero_label.text = "Sem heroi inimigo | Objetivo: sobreviver %s" % engine.get_defense_label()
	elif engine.modo_batalha == BattleEngineScript.MODE_BOSS_PARTS:
		enemy_hero_label.text = "Sem heroi inimigo | Objetivo: destruir %s" % engine.get_boss_label()
	elif engine.modo_batalha == BattleEngineScript.MODE_PUZZLE:
		enemy_hero_label.text = "Sem heroi inimigo | Objetivo: resolver %s" % engine.get_puzzle_label()
	else:
		enemy_hero_label.text = "Sem heroi inimigo | Objetivo: limpar a mesa"
	enemy_hero_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_hero_zone.add_child(enemy_hero_label)

	_rebuild_slot_row(enemy_slots_box, "enemy", engine.enemy_slots)
	_rebuild_slot_row(player_slots_box, "player", engine.player_slots)
	_rebuild_hand()
	log_label.text = "\n".join(engine.log_lines)
	end_turn_button.text = engine.get_advance_phase_label()
	end_turn_button.disabled = engine.outcome != "" or (
		engine.current_phase == BattleEngineScript.PHASE_MAIN and engine.priority_owner_id != PLAYER_OWNER
	) or (
		engine.current_phase == BattleEngineScript.PHASE_DISCARD and not engine.can_finish_discard()
	)
	hero_power_button.disabled = not engine.can_use_player_hero_power()
	call_deferred("_play_pending_visual_events")

	if engine.outcome != "":
		_finish_battle()

func _rebuild_slot_row(container: HBoxContainer, owner: String, slots: Array) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.free()
	for index: int in range(slots.size()):
		var slot_box: VBoxContainer = VBoxContainer.new()
		slot_box.custom_minimum_size = Vector2(SLOT_CARD_WIDTH, 0)
		slot_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_box.add_theme_constant_override("separation", 2)
		var slot = BattleSlotControlScript.new()
		slot.setup(owner, index, slots[index], _slot_visual_state(owner, index, slots[index]))
		slot.card_dropped.connect(_on_card_dropped_on_slot)
		slot_box.add_child(slot)
		_add_slot_attack_controls(slot_box, owner, index)
		container.add_child(slot_box)

func _rebuild_hand() -> void:
	for child: Node in hand_box.get_children():
		hand_box.remove_child(child)
		child.free()
	for index: int in range(engine.hand.size()):
		var card_id: String = str(engine.hand[index])
		var token = BattleCardTokenScript.new()
		token.setup(card_id, index)

		var card_box: VBoxContainer = VBoxContainer.new()
		card_box.custom_minimum_size = Vector2(HAND_CARD_WIDTH, 0)
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
	var result: Dictionary = engine.advance_phase()
	_record_action_feedback(result)
	_refresh()

func _on_hero_power_pressed() -> void:
	var result: Dictionary = engine.use_player_hero_power()
	_record_action_feedback(result)
	call_deferred("_refresh")

func _add_hand_action_controls(parent: VBoxContainer, card, hand_index: int) -> void:
	if card == null:
		return

	var grid: GridContainer = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	parent.add_child(grid)

	if engine.current_phase == BattleEngineScript.PHASE_DISCARD:
		var discard_button: Button = _small_action_button("Descartar")
		discard_button.disabled = not engine.can_discard_from_hand(hand_index)
		discard_button.custom_minimum_size = Vector2(96, 24)
		discard_button.pressed.connect(_discard_hand_card.bind(hand_index))
		grid.add_child(discard_button)
		return

	if card.occupies_slot():
		for lane: int in range(engine.player_slots.size()):
			var button: Button = _small_action_button(engine.get_slot_label(PLAYER_OWNER, lane))
			button.disabled = not engine.can_play_card(card) or engine.player_slots[lane] != null
			button.pressed.connect(_play_hand_card_to_player_slot.bind(hand_index, lane))
			grid.add_child(button)
	elif card.is_damage_spell():
		if engine.modo_batalha == BattleEngineScript.MODE_DUEL:
			var hero_button: Button = _small_action_button("Heroi")
			hero_button.disabled = not engine.can_play_card(card)
			hero_button.pressed.connect(_play_hand_card_to_enemy_hero.bind(hand_index))
			grid.add_child(hero_button)
		for lane: int in range(engine.enemy_slots.size()):
			var button: Button = _small_action_button(engine.get_slot_label(ENEMY_OWNER, lane))
			button.disabled = not engine.can_play_card(card) or engine.enemy_slots[lane] == null
			button.pressed.connect(_play_hand_card_to_enemy_slot.bind(hand_index, lane))
			grid.add_child(button)
	elif card.is_board_spell():
		var cast_button: Button = _small_action_button("Conjurar")
		cast_button.custom_minimum_size = Vector2(92, 24)
		cast_button.disabled = not engine.can_play_card(card)
		cast_button.pressed.connect(_play_hand_card_as_board_spell.bind(hand_index))
		grid.add_child(cast_button)
	elif card.is_buff_command():
		for lane: int in range(engine.player_slots.size()):
			var button: Button = _small_action_button(engine.get_slot_label(PLAYER_OWNER, lane))
			button.disabled = not engine.can_play_card(card) or engine.player_slots[lane] == null
			button.pressed.connect(_play_hand_card_to_player_slot.bind(hand_index, lane))
			grid.add_child(button)

func _add_slot_attack_controls(parent: VBoxContainer, owner: String, slot_index: int) -> void:
	var status: Label = Label.new()
	status.text = engine.get_slot_attack_status(owner, slot_index)
	status.clip_text = true
	status.max_lines_visible = 1
	status.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status.add_theme_font_size_override("font_size", 11)
	parent.add_child(status)
	if owner != "player":
		return
	var options: Array = engine.get_attack_options(PLAYER_OWNER, slot_index)
	if options.is_empty():
		return
	var grid: GridContainer = GridContainer.new()
	grid.columns = 1
	grid.add_theme_constant_override("v_separation", 3)
	parent.add_child(grid)
	for option: Variant in options:
		var target: Dictionary = Dictionary(option)
		var button: Button = _small_action_button("Atacar %s" % str(target.get("label", "")))
		button.custom_minimum_size = Vector2(112, 24)
		button.pressed.connect(_attack_from_player_slot.bind(slot_index, target))
		grid.add_child(button)

func _small_action_button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(42, 24)
	button.add_theme_font_size_override("font_size", 12)
	return button

func _header_info_label(font_size: int) -> Label:
	var label: Label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_text = true
	label.max_lines_visible = 1
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _stat_bar(node_name: String, label_text: String) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.name = node_name
	bar.custom_minimum_size = Vector2(150, 20)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.show_percentage = false
	bar.max_value = 25
	bar.value = 25
	bar.tooltip_text = label_text
	return bar

func _update_vitals() -> void:
	player_hp_bar.max_value = BattleEngineScript.DEFAULT_PLAYER_HEALTH
	player_hp_bar.value = max(0, engine.player_health)
	player_hp_bar.tooltip_text = "Jogador: %d HP, %d armadura" % [engine.player_health, engine.player_armor]
	player_hp_bar.add_theme_stylebox_override("fill", _bar_fill(Color(0.36, 0.68, 0.52)))

	if engine.modo_batalha == BattleEngineScript.MODE_DUEL:
		enemy_hp_bar.visible = true
		enemy_portrait_rect.visible = true
		enemy_hp_bar.max_value = BattleEngineScript.DEFAULT_ENEMY_HEALTH
		enemy_hp_bar.value = max(0, engine.enemy_health)
		enemy_hp_bar.tooltip_text = "Inimigo: %d HP, %d armadura" % [engine.enemy_health, engine.enemy_armor]
		enemy_hp_bar.add_theme_stylebox_override("fill", _bar_fill(Color(0.78, 0.32, 0.34)))
	else:
		enemy_hp_bar.visible = false
		enemy_portrait_rect.visible = false

	priority_dot.color = UiTokens.color("energy") if engine.priority_owner_id == PLAYER_OWNER else UiTokens.color("hp_enemy")

	for child: Node in energy_pips_box.get_children():
		energy_pips_box.remove_child(child)
		child.free()
	var player_controller: Dictionary = Dictionary(engine.controladores.get(PLAYER_OWNER, {}))
	var max_energy: int = int(player_controller.get("energy_max", engine.energy))
	for index: int in range(max_energy):
		var pip: ColorRect = ColorRect.new()
		pip.custom_minimum_size = Vector2(14, 18)
		pip.color = Color(0.92, 0.74, 0.36) if index < engine.energy else Color(0.2, 0.22, 0.23)
		energy_pips_box.add_child(pip)
	energy_pips_box.tooltip_text = "Energia: %d/%d" % [engine.energy, max_energy]

	var max_hand: int = int(player_controller.get("max_hand_size", engine.hand.size()))
	hand_limit_label.text = "Mao %d/%d | Deck %d" % [engine.hand.size(), max_hand, engine.deck.size()]
	if engine.current_phase == BattleEngineScript.PHASE_DISCARD:
		var remaining_discards: int = max(0, engine.hand.size() - engine.discard_target_size)
		discard_counter_label.text = "Descarte: %d restante(s)" % remaining_discards
		discard_bar.max_value = max(1, engine.hand.size())
		discard_bar.value = max(0, engine.hand.size() - remaining_discards)
		discard_bar.visible = true
	else:
		discard_counter_label.text = "Descarte: inativo"
		discard_bar.visible = false

func _slot_visual_state(owner: String, slot_index: int, occupant: Variant) -> Dictionary:
	var attack_status: String = engine.get_slot_attack_status(owner, slot_index)
	return {
		"label": engine.get_slot_label(owner, slot_index),
		"attack_status": attack_status,
		"is_attack_source": owner == PLAYER_OWNER and attack_status == "Pode atacar",
		"is_attack_target": _is_slot_attack_target(owner, slot_index),
		"is_empty": occupant == null
	}

func _is_slot_attack_target(owner: String, slot_index: int) -> bool:
	for source_index: int in range(engine.player_slots.size()):
		for option: Variant in engine.get_attack_options(PLAYER_OWNER, source_index):
			var target: Dictionary = Dictionary(option)
			if str(target.get("owner", "")) == owner and int(target.get("slot", -1)) == slot_index:
				return true
	return false

func _bar_fill(fill: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func _portrait_rect(node_name: String, asset_id: String) -> TextureRect:
	var rect: TextureRect = TextureRect.new()
	rect.name = node_name
	rect.custom_minimum_size = Vector2(48, 48)
	rect.texture = AssetIds.texture(asset_id)
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.modulate = Color.WHITE if rect.texture != null else UiTokens.color("placeholder")
	return rect

func _section_label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	return label

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

func _play_hand_card_as_board_spell(hand_index: int) -> void:
	var result: Dictionary = engine.play_card_from_hand(hand_index, {})
	_record_action_feedback(result)
	call_deferred("_refresh")

func _discard_hand_card(hand_index: int) -> void:
	var result: Dictionary = engine.discard_card_from_hand(hand_index)
	_record_action_feedback(result)
	call_deferred("_refresh")

func _attack_from_player_slot(slot_index: int, target: Dictionary) -> void:
	var result: Dictionary = engine.attack_with_unit(PLAYER_OWNER, slot_index, target)
	_record_action_feedback(result)
	call_deferred("_refresh")

func _record_action_feedback(result: Dictionary) -> void:
	last_feedback = str(result.get("message", ""))

func _play_pending_visual_events() -> void:
	if visual_layer == null or engine == null:
		return
	while _visual_event_cursor < engine.eventos_visuais.size():
		var event: Dictionary = Dictionary(engine.eventos_visuais[_visual_event_cursor])
		_visual_event_cursor += 1
		_spawn_feedback_label(event)

func _spawn_feedback_label(event: Dictionary) -> void:
	var label: Label = Label.new()
	label.text = str(event.get("text", ""))
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(event.get("color", Color.WHITE)))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual_layer.add_child(label)
	label.global_position = _visual_event_position(event)
	label.scale = Vector2(0.8, 0.8)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -34), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.65).set_delay(0.15)
	tween.tween_property(label, "scale", Vector2.ONE, 0.18)
	tween.finished.connect(func() -> void:
		if is_instance_valid(label):
			label.queue_free()
	)

func _visual_event_position(event: Dictionary) -> Vector2:
	var owner: String = str(event.get("owner", PLAYER_OWNER))
	var slot_index: int = int(event.get("slot", -1))
	if slot_index >= 0:
		var container: HBoxContainer = enemy_slots_box if owner == ENEMY_OWNER else player_slots_box
		if container != null and slot_index < container.get_child_count():
			var slot_box: Control = container.get_child(slot_index)
			var rect: Rect2 = slot_box.get_global_rect()
			return rect.get_center() - Vector2(32, 18)
	if owner == ENEMY_OWNER and enemy_hero_zone != null:
		return enemy_hero_zone.get_global_rect().get_center() - Vector2(42, 18)
	return status_label.get_global_rect().get_center() - Vector2(42, -18)

func _finish_battle() -> void:
	if engine.outcome == "victory":
		var summary: String = "A emboscada foi vencida no encontro de teste."
		if engine.encounter_id == "duelista_bandido":
			summary = "O Guardiao Elemental foi derrotado em confronto."
		elif engine.encounter_id == "invasao_em_ondas":
			summary = "A invasao em ondas foi repelida."
		elif engine.encounter_id == "defesa_do_portao":
			summary = "O portao resistiu ao ataque inimigo."
		elif engine.encounter_id == "colosso_fragmentado":
			summary = "O Colosso Fragmentado perdeu todas as partes vitais."
		elif engine.encounter_id == "enigma_da_ponte":
			summary = "A ruptura de selos foi resolvida."
		GameSession.complete_encounter(summary)
		GameSession.save_game()
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
	style.content_margin_left = 10
	style.content_margin_top = 8
	style.content_margin_right = 10
	style.content_margin_bottom = 8
	return style
