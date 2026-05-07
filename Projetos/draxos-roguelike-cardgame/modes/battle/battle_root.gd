extends Control

var engine: BattleEngine = BattleEngine.new()
var status_label: Label
var enemy_slots_box: HBoxContainer
var player_slots_box: HBoxContainer
var hand_box: HBoxContainer
var log_label: Label
var map_button: Button
var current_node: Dictionary = {}
var current_encounter: Dictionary = {}

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	if not RunSession.active:
		RunSession.start_empty_run()
	if RunSession.current_node_id == "":
		RunSession.select_node(_first_available_node_id())
	current_node = _current_node()
	current_encounter = ContentLibrary.get_catalog().find_encounter(str(current_node.get("encounter_id", ContentLibrary.get_default_encounter_id())))
	var deck_ids: Array = RunSession.current_deck_ids if not RunSession.current_deck_ids.is_empty() else ContentLibrary.get_starter_deck_ids()
	engine.start_battle(ContentLibrary.get_catalog(), deck_ids, {"encounter": current_encounter})
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.name = "BattleBackground"
	background.color = UiTokens.color("bg_deep", Color(0.045, 0.05, 0.055))
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "BattleLayout"
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 28)
	root_margin.add_theme_constant_override("margin_top", 24)
	root_margin.add_theme_constant_override("margin_right", 28)
	root_margin.add_theme_constant_override("margin_bottom", 24)
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 14)
	root_margin.add_child(main_box)

	status_label = Label.new()
	status_label.name = "BattleStatus"
	status_label.add_theme_font_size_override("font_size", 24)
	status_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_box.add_child(status_label)

	enemy_slots_box = HBoxContainer.new()
	enemy_slots_box.name = "BattleEnemySlots"
	enemy_slots_box.add_theme_constant_override("separation", 10)
	main_box.add_child(enemy_slots_box)

	player_slots_box = HBoxContainer.new()
	player_slots_box.name = "BattlePlayerSlots"
	player_slots_box.add_theme_constant_override("separation", 10)
	main_box.add_child(player_slots_box)

	hand_box = HBoxContainer.new()
	hand_box.name = "BattleHand"
	hand_box.add_theme_constant_override("separation", 10)
	main_box.add_child(hand_box)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.name = "BattleActions"
	actions.add_theme_constant_override("separation", 10)
	main_box.add_child(actions)

	var end_turn_button: Button = Button.new()
	end_turn_button.name = "BattleEndTurnButton"
	end_turn_button.text = "Encerrar Turno"
	end_turn_button.pressed.connect(func() -> void:
		engine.end_player_turn()
		_after_battle_action()
	)
	actions.add_child(end_turn_button)

	map_button = Button.new()
	map_button.name = "BattleBackToRunMapButton"
	map_button.text = "Voltar ao Mapa"
	map_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/run_map/run_map.tscn")
	)
	actions.add_child(map_button)

	log_label = Label.new()
	log_label.name = "BattleLog"
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	main_box.add_child(log_label)

func _refresh() -> void:
	var state: Dictionary = engine.get_state()
	status_label.text = "%s | %s | Classe %s | Mana %d/%d | Vida %d | Inimigo %d | Resultado: %s" % [
		str(current_encounter.get("display_name", "Encontro")),
		engine.get_mode_label(),
		RunSession.selected_class_display_name,
		int(state.get("mana", 0)),
		int(state.get("mana_per_turn", 0)),
		int(state.get("player_health", 0)),
		int(state.get("enemy_health", 0)),
		str(state.get("outcome", ""))
	]
	_rebuild_slots(enemy_slots_box, Array(state.get("enemy_slots", [])), "Inimigo")
	_rebuild_slots(player_slots_box, Array(state.get("player_slots", [])), "Jogador")
	_rebuild_hand(Array(state.get("hand", [])))
	log_label.text = "\n".join(Array(state.get("log", [])))
	if map_button != null and engine.outcome == "vitoria":
		map_button.text = "Continuar no Mapa"

func _rebuild_slots(container: HBoxContainer, slots: Array, label_prefix: String) -> void:
	for child: Node in container.get_children():
		child.queue_free()
	for index: int in range(slots.size()):
		var slot_label: Label = Label.new()
		slot_label.name = "%sSlot%d" % [label_prefix, index]
		slot_label.custom_minimum_size = Vector2(170, 82)
		slot_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
		if slots[index] == null:
			slot_label.text = "%s %d\nvazio" % [label_prefix, index + 1]
		else:
			var occupant: Dictionary = Dictionary(slots[index])
			slot_label.text = "%s %d\n%s %d/%d" % [
				label_prefix,
				index + 1,
				str(occupant.get("name", "Carta")),
				int(occupant.get("attack", 0)),
				int(occupant.get("health", 0))
			]
		container.add_child(slot_label)

func _rebuild_hand(hand: Array) -> void:
	for child: Node in hand_box.get_children():
		child.queue_free()
	for index: int in range(hand.size()):
		var card_id: String = str(hand[index])
		var card = ContentLibrary.get_card(card_id)
		var button: Button = Button.new()
		button.name = "BattleHandCard%d" % index
		button.text = "%s\nCusto %d" % [ContentLibrary.get_card_name(card_id), int(card.cost if card != null else 0)]
		button.custom_minimum_size = Vector2(150, 92)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = card == null or int(card.cost) > engine.mana or engine.outcome != ""
		button.pressed.connect(func() -> void:
			_play_hand_card(index)
		)
		hand_box.add_child(button)

func _play_hand_card(hand_index: int) -> void:
	var card = ContentLibrary.get_card(engine.hand[hand_index])
	var target: Dictionary = {}
	if card != null and card.occupies_slot():
		target = {"slot": _first_open_player_slot()}
	else:
		target = _first_enemy_target()
	engine.play_card_from_hand(hand_index, target)
	_after_battle_action()

func _after_battle_action() -> void:
	if engine.outcome == "vitoria":
		RunSession.record_battle_result(RunSession.current_node_id, engine.outcome, engine.player_health)
	_refresh()

func _first_open_player_slot() -> int:
	for index: int in range(engine.player_slots.size()):
		if engine.player_slots[index] == null:
			return index
	return 0

func _first_enemy_target() -> Dictionary:
	for index: int in range(engine.enemy_slots.size()):
		if engine.enemy_slots[index] != null:
			return {"owner": BattleEngine.ENEMY_ID, "slot": index}
	return {"owner": BattleEngine.ENEMY_ID, "hero": true}

func _first_available_node_id() -> String:
	for node: Dictionary in Array(ContentLibrary.get_run_map().get("nodes", [])):
		if RunSession.is_node_available(node):
			return str(node.get("id", ""))
	return ""

func _current_node() -> Dictionary:
	for node: Dictionary in Array(ContentLibrary.get_run_map().get("nodes", [])):
		if str(node.get("id", "")) == RunSession.current_node_id:
			return node
	return {}
