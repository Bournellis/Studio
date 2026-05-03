extends Control

const BattleEngineScript = preload("res://battle/battle_engine.gd")
const BattleSlotControlScript = preload("res://ui/controls/battle_slot_control.gd")
const BattleCardTokenScript = preload("res://ui/controls/battle_card_token.gd")
const EnemyHeroDropZoneScript = preload("res://ui/controls/enemy_hero_drop_zone.gd")

var engine
var status_label: Label
var log_label: Label
var enemy_hero_zone
var enemy_slots_box: HBoxContainer
var player_slots_box: HBoxContainer
var hand_box: HBoxContainer
var end_turn_button: Button

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
	root.offset_left = 20
	root.offset_top = 14
	root.offset_right = -20
	root.offset_bottom = -14
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 20)
	root.add_child(status_label)

	enemy_hero_zone = EnemyHeroDropZoneScript.new()
	enemy_hero_zone.custom_minimum_size = Vector2(260, 64)
	enemy_hero_zone.add_theme_stylebox_override("panel", _panel_style(Color(0.16, 0.08, 0.09)))
	enemy_hero_zone.card_dropped.connect(_on_card_dropped_on_enemy_hero)
	root.add_child(enemy_hero_zone)

	enemy_slots_box = HBoxContainer.new()
	enemy_slots_box.add_theme_constant_override("separation", 10)
	root.add_child(enemy_slots_box)

	player_slots_box = HBoxContainer.new()
	player_slots_box.add_theme_constant_override("separation", 10)
	root.add_child(player_slots_box)

	var hand_panel: PanelContainer = PanelContainer.new()
	hand_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hand_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1)))
	root.add_child(hand_panel)

	var hand_root: VBoxContainer = VBoxContainer.new()
	hand_root.add_theme_constant_override("separation", 8)
	hand_panel.add_child(hand_root)

	var hand_title: Label = Label.new()
	hand_title.text = "Mao"
	hand_root.add_child(hand_title)

	hand_box = HBoxContainer.new()
	hand_box.add_theme_constant_override("separation", 8)
	hand_root.add_child(hand_box)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 8)
	root.add_child(actions)

	log_label = Label.new()
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	actions.add_child(log_label)

	end_turn_button = Button.new()
	end_turn_button.text = "Encerrar turno"
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	actions.add_child(end_turn_button)

func _refresh() -> void:
	status_label.text = "Rodada %d | Energia %d | Jogador %d HP | Inimigo %d HP | Deck %d" % [
		engine.round_number,
		engine.energy,
		engine.player_health,
		engine.enemy_health,
		engine.deck.size()
	]

	for child: Node in enemy_hero_zone.get_children():
		enemy_hero_zone.remove_child(child)
		child.free()
	var enemy_hero_label: Label = Label.new()
	enemy_hero_label.text = "Heroi inimigo: %d HP | Arraste uma magia de dano aqui" % engine.enemy_health
	enemy_hero_zone.add_child(enemy_hero_label)

	_rebuild_slot_row(enemy_slots_box, "enemy", engine.enemy_slots)
	_rebuild_slot_row(player_slots_box, "player", engine.player_slots)
	_rebuild_hand()
	log_label.text = "\n".join(engine.log_lines)

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
		var token = BattleCardTokenScript.new()
		token.setup(str(engine.hand[index]), index)
		hand_box.add_child(token)

func _on_card_dropped_on_slot(data: Dictionary, owner: String, slot_index: int) -> void:
	var card = ContentLibrary.get_card(str(data.get("card_id", "")))
	var target: Dictionary = {"owner": owner, "slot": slot_index}
	if card != null and card.is_buff_command():
		target["owner"] = "player"
	var result: Dictionary = engine.play_card_from_hand(int(data.get("hand_index", -1)), target)
	if not bool(result.get("ok", false)):
		pass
	_refresh()

func _on_card_dropped_on_enemy_hero(data: Dictionary) -> void:
	engine.play_card_from_hand(int(data.get("hand_index", -1)), {"owner": "enemy", "slot": -1})
	_refresh()

func _on_end_turn_pressed() -> void:
	engine.end_player_turn()
	_refresh()

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
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style
