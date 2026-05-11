extends Control

const BattleClassActiveTokenScript = preload("res://ui/controls/battle_class_active_token.gd")
const BattleHeroTargetControlScript = preload("res://ui/controls/battle_hero_target_control.gd")

var engine: BattleEngine = BattleEngine.new()
var status_label: Label
var hero_targets_box: HBoxContainer
var enemy_slots_box: HBoxContainer
var player_slots_box: HBoxContainer
var hand_box: HBoxContainer
var log_label: Label
var map_button: Button
var class_active_tile
var necromancer_modal: PanelContainer
var necromancer_choices_box: VBoxContainer
var preview_timer: Timer
var preview_panel: PanelContainer
var preview_title_label: Label
var preview_subtitle_label: Label
var preview_body_label: Label
var preview_state_label: Label
var current_node: Dictionary = {}
var current_encounter: Dictionary = {}
var selected_hand_index: int = -1
var selected_necromancer_choice_id: String = ""
var pending_preview_data: Dictionary = {}

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	if not RunSession.active:
		RunSession.start_empty_run()
	if RunSession.current_node_id == "":
		RunSession.select_node(_first_available_node_id())
	current_node = _current_node()
	current_encounter = ContentLibrary.get_catalog().find_encounter(str(current_node.get("encounter_id", ContentLibrary.get_default_encounter_id())))
	var deck_ids: Array = RunSession.current_deck_ids if not RunSession.current_deck_ids.is_empty() else ContentLibrary.get_starter_deck_ids()
	engine.start_battle(ContentLibrary.get_catalog(), deck_ids, {
		"encounter": current_encounter,
		"class_id": RunSession.selected_class_id,
		"mana_per_turn": RunSession.max_mana if RunSession.max_mana > 0 else 3,
		"player_health": RunSession.current_health if RunSession.current_health > 0 else 20,
		"shuffle_seed": RunSession.run_seed
	})
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("battle_board_background")
	background.name = "BattleVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "BattleVisualScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.34)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "BattleLayout"
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 18)
	root_margin.add_theme_constant_override("margin_top", 16)
	root_margin.add_theme_constant_override("margin_right", 18)
	root_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 8)
	root_margin.add_child(main_box)

	status_label = Label.new()
	status_label.name = "BattleStatus"
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_box.add_child(status_label)

	hero_targets_box = HBoxContainer.new()
	hero_targets_box.name = "BattleHeroTargets"
	hero_targets_box.add_theme_constant_override("separation", 10)

	enemy_slots_box = HBoxContainer.new()
	enemy_slots_box.name = "BattleEnemySlots"
	enemy_slots_box.add_theme_constant_override("separation", 10)
	enemy_slots_box.alignment = BoxContainer.ALIGNMENT_CENTER

	player_slots_box = HBoxContainer.new()
	player_slots_box.name = "BattlePlayerSlots"
	player_slots_box.add_theme_constant_override("separation", 10)
	player_slots_box.alignment = BoxContainer.ALIGNMENT_CENTER

	var board_panel: PanelContainer = PanelContainer.new()
	board_panel.name = "BattleBoardPanel"
	board_panel.custom_minimum_size = Vector2(0, 230)
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.065, 0.065, 0.64), VisualAssets.surface_accent_color("battle_board_background")))
	main_box.add_child(board_panel)

	var board_margin: MarginContainer = MarginContainer.new()
	board_margin.add_theme_constant_override("margin_left", 14)
	board_margin.add_theme_constant_override("margin_top", 12)
	board_margin.add_theme_constant_override("margin_right", 14)
	board_margin.add_theme_constant_override("margin_bottom", 12)
	board_panel.add_child(board_margin)

	var board_box: VBoxContainer = VBoxContainer.new()
	board_box.name = "BattleBoardRows"
	board_box.add_theme_constant_override("separation", 12)
	board_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_margin.add_child(board_box)

	board_box.add_child(hero_targets_box)
	board_box.add_child(enemy_slots_box)
	var board_spacer: Control = Control.new()
	board_spacer.name = "BattleBoardCenterSpace"
	board_spacer.custom_minimum_size = Vector2(0, 18)
	board_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_box.add_child(board_spacer)
	board_box.add_child(player_slots_box)

	hand_box = HBoxContainer.new()
	hand_box.name = "BattleHand"
	hand_box.add_theme_constant_override("separation", 10)
	hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_box.add_child(hand_box)

	var actions: HBoxContainer = HBoxContainer.new()
	actions.name = "BattleActions"
	actions.add_theme_constant_override("separation", 10)
	main_box.add_child(actions)

	class_active_tile = BattleClassActiveTokenScript.new()
	class_active_tile.name = "BattleClassActiveTile"
	class_active_tile.choices_requested.connect(_open_necromancer_modal)
	class_active_tile.mouse_entered.connect(func() -> void:
		_schedule_preview(_class_active_preview_data())
	)
	class_active_tile.mouse_exited.connect(_hide_preview)
	actions.add_child(class_active_tile)

	var end_turn_button: Button = Button.new()
	end_turn_button.name = "BattleEndTurnButton"
	end_turn_button.text = "Encerrar Turno"
	end_turn_button.pressed.connect(func() -> void:
		engine.end_player_turn()
		selected_hand_index = -1
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

	var log_scroll: ScrollContainer = ScrollContainer.new()
	log_scroll.name = "BattleLogScroll"
	log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	log_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_scroll.custom_minimum_size = Vector2(0, 86)
	main_box.add_child(log_scroll)

	log_label = Label.new()
	log_label.name = "BattleLog"
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.add_child(log_label)

	_build_preview_panel()
	_build_necromancer_modal()

func _build_preview_panel() -> void:
	preview_timer = Timer.new()
	preview_timer.name = "BattleCardPreviewTimer"
	preview_timer.one_shot = true
	preview_timer.wait_time = 0.22
	preview_timer.timeout.connect(func() -> void:
		_show_preview_now(pending_preview_data)
	)
	add_child(preview_timer)

	preview_panel = PanelContainer.new()
	preview_panel.name = "BattleCardPreview"
	preview_panel.visible = false
	preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_panel.custom_minimum_size = Vector2(278, 0)
	preview_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1), Color(0.62, 0.55, 0.42)))
	add_child(preview_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	preview_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	margin.add_child(box)

	preview_title_label = Label.new()
	preview_title_label.name = "BattleCardPreviewTitle"
	preview_title_label.add_theme_font_size_override("font_size", 18)
	preview_title_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(preview_title_label)

	preview_subtitle_label = Label.new()
	preview_subtitle_label.name = "BattleCardPreviewSubtitle"
	preview_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_subtitle_label.add_theme_font_size_override("font_size", 12)
	preview_subtitle_label.add_theme_color_override("font_color", Color(0.98, 0.78, 0.48))
	box.add_child(preview_subtitle_label)

	preview_body_label = Label.new()
	preview_body_label.name = "BattleCardPreviewBody"
	preview_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_body_label.add_theme_font_size_override("font_size", 12)
	preview_body_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96))
	box.add_child(preview_body_label)

	preview_state_label = Label.new()
	preview_state_label.name = "BattleCardPreviewState"
	preview_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_state_label.add_theme_font_size_override("font_size", 11)
	preview_state_label.add_theme_color_override("font_color", Color(0.72, 0.8, 0.84))
	box.add_child(preview_state_label)

func _build_necromancer_modal() -> void:
	necromancer_modal = PanelContainer.new()
	necromancer_modal.name = "NecromancerChoiceModal"
	necromancer_modal.visible = false
	necromancer_modal.set_anchors_preset(Control.PRESET_CENTER)
	necromancer_modal.position = Vector2(300, 130)
	necromancer_modal.custom_minimum_size = Vector2(320, 0)
	necromancer_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.1, 0.08, 0.12), Color(0.62, 0.42, 0.7)))
	add_child(necromancer_modal)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	necromancer_modal.add_child(margin)

	necromancer_choices_box = VBoxContainer.new()
	necromancer_choices_box.name = "NecromancerChoiceList"
	necromancer_choices_box.add_theme_constant_override("separation", 7)
	margin.add_child(necromancer_choices_box)

func _refresh() -> void:
	var state: Dictionary = engine.get_state()
	status_label.text = "%s | %s\nClasse %s | Mana %d/%d | Vida %d | Inimigo %d\nFluxo %d | Cinzas %d | Onda %d/%d | Resultado: %s" % [
		str(current_encounter.get("display_name", "Encontro")),
		engine.get_mode_label(),
		RunSession.selected_class_display_name,
		int(state.get("mana", 0)),
		int(state.get("mana_per_turn", 0)),
		int(state.get("player_health", 0)),
		int(state.get("enemy_health", 0)),
		int(state.get("flow", 0)),
		int(state.get("ashes", 0)),
		int(state.get("wave_index", 0)),
		int(state.get("waves_total", 0)),
		str(state.get("outcome", ""))
	]
	_rebuild_hero_targets(state)
	_rebuild_slots(enemy_slots_box, Array(state.get("enemy_slots", [])), BattleEngine.ENEMY_ID)
	_rebuild_slots(player_slots_box, Array(state.get("player_slots", [])), BattleEngine.PLAYER_ID)
	_rebuild_hand(Array(state.get("hand", [])))
	_refresh_class_active_tile()
	_refresh_necromancer_modal()
	log_label.text = "\n".join(Array(state.get("log", [])))
	if map_button != null and engine.outcome == "vitoria":
		map_button.text = "Continuar no Mapa"

func _rebuild_hero_targets(state: Dictionary) -> void:
	for child: Node in hero_targets_box.get_children():
		child.queue_free()
	var hero_targets: Array[Dictionary] = engine.get_valid_class_active_targets("")
	for hand_index: int in range(engine.hand.size()):
		hero_targets.append_array(engine.get_valid_card_targets(hand_index))
	if not _has_target(hero_targets, {"owner": BattleEngine.PLAYER_ID, "hero": true}) and not _has_target(hero_targets, {"owner": BattleEngine.ENEMY_ID, "hero": true}):
		hero_targets_box.visible = false
		return
	hero_targets_box.visible = true
	_add_hero_target(BattleEngine.PLAYER_ID, _hero_display_name(BattleEngine.PLAYER_ID), int(state.get("player_health", 0)))
	_add_hero_target(BattleEngine.ENEMY_ID, _hero_display_name(BattleEngine.ENEMY_ID), int(state.get("enemy_health", 0)))

func _add_hero_target(owner_id: String, display_name: String, health: int) -> void:
	var target: Dictionary = {"owner": owner_id, "hero": true}
	var visual_state: Dictionary = {
		"accepted_card_indices": _accepted_card_indices_for_target(target),
		"accepted_class_choices": _accepted_class_choices_for_target(target)
	}
	visual_state["is_drop_target"] = not Array(visual_state.get("accepted_card_indices", [])).is_empty() or not Array(visual_state.get("accepted_class_choices", [])).is_empty()
	var hero_target = BattleHeroTargetControlScript.new()
	hero_target.name = "Battle%sHeroTarget" % ("Player" if owner_id == BattleEngine.PLAYER_ID else "Enemy")
	hero_target.setup(owner_id, display_name, health, visual_state)
	hero_target.target_dropped.connect(_on_hero_target_dropped)
	hero_target.mouse_entered.connect(func() -> void:
		_schedule_preview(_hero_preview_data(owner_id, display_name, health))
	)
	hero_target.mouse_exited.connect(_hide_preview)
	hero_targets_box.add_child(hero_target)

func _rebuild_slots(container: HBoxContainer, slots: Array, owner_id: String) -> void:
	for child: Node in container.get_children():
		child.queue_free()
	for index: int in range(slots.size()):
		var target: Dictionary = {"owner": owner_id, "slot": index}
		var visual_state: Dictionary = {
			"label": "%s %d" % ["Jogador" if owner_id == BattleEngine.PLAYER_ID else "Inimigo", index + 1],
			"is_empty": slots[index] == null,
			"accepted_card_indices": _accepted_card_indices_for_target(target),
			"accepted_class_choices": _accepted_class_choices_for_target(target)
		}
		visual_state["is_drop_target"] = not Array(visual_state.get("accepted_card_indices", [])).is_empty() or not Array(visual_state.get("accepted_class_choices", [])).is_empty()
		var slot_control: BattleSlotControl = BattleSlotControl.new()
		slot_control.name = "%sSlot%d" % ["Player" if owner_id == BattleEngine.PLAYER_ID else "Enemy", index]
		slot_control.setup(owner_id, index, slots[index], visual_state)
		slot_control.card_dropped.connect(_on_slot_target_dropped)
		slot_control.mouse_entered.connect(func() -> void:
			_schedule_preview(_slot_preview_data(owner_id, index, slots[index]))
		)
		slot_control.mouse_exited.connect(_hide_preview)
		container.add_child(slot_control)

func _rebuild_hand(hand: Array) -> void:
	for child: Node in hand_box.get_children():
		child.queue_free()
	if selected_hand_index >= hand.size():
		selected_hand_index = -1
	for index: int in range(hand.size()):
		var card_id: String = str(hand[index])
		var card = ContentLibrary.get_card(card_id)
		var token: BattleCardToken = BattleCardToken.new()
		token.name = "BattleHandCard%d" % index
		token.setup(card_id, index, engine.can_play_card(card), selected_hand_index == index)
		token.mouse_entered.connect(func() -> void:
			_schedule_preview(_card_preview_data(card_id, {}))
		)
		token.mouse_exited.connect(_hide_preview)
		token.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				selected_hand_index = index
				_show_preview_now(_card_preview_data(card_id, {}))
				_update_hand_selection_visuals()
		)
		hand_box.add_child(token)

func _update_hand_selection_visuals() -> void:
	for child: Node in hand_box.get_children():
		if child is BattleCardToken:
			var token: BattleCardToken = child
			token.set_selected(token.hand_index == selected_hand_index)

func _refresh_class_active_tile() -> void:
	if selected_necromancer_choice_id != "" and not _choice_is_enabled(selected_necromancer_choice_id):
		selected_necromancer_choice_id = ""
	var requires_choice: bool = RunSession.selected_class_id == "necromante"
	var choice_id: String = selected_necromancer_choice_id if requires_choice else ""
	var detail_text: String = _class_active_detail_text(choice_id)
	var enabled: bool = engine.can_use_class_active()
	if requires_choice:
		enabled = enabled and choice_id != "" and not engine.get_valid_class_active_targets(choice_id).is_empty()
	else:
		enabled = enabled and not engine.get_valid_class_active_targets("").is_empty()
	class_active_tile.setup(RunSession.selected_class_id, _class_active_display_name(choice_id), detail_text, choice_id, enabled, requires_choice)

func _refresh_necromancer_modal() -> void:
	if necromancer_modal == null or necromancer_choices_box == null:
		return
	for child: Node in necromancer_choices_box.get_children():
		child.queue_free()
	var title: Label = Label.new()
	title.text = "Ritual das Sombras"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	necromancer_choices_box.add_child(title)
	for choice: Dictionary in engine.get_necromancer_active_choices():
		var button: Button = Button.new()
		var choice_id: String = str(choice.get("id", ""))
		button.name = "NecroChoice_%s" % choice_id
		button.text = "%s | %d Cinzas\n%s" % [
			str(choice.get("display_name", choice_id)),
			int(choice.get("cost_ashes", 0)),
			str(choice.get("text", ""))
		]
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.disabled = not bool(choice.get("enabled", false))
		button.pressed.connect(func() -> void:
			selected_necromancer_choice_id = choice_id
			necromancer_modal.visible = false
			_refresh()
		)
		necromancer_choices_box.add_child(button)
	var close_button: Button = Button.new()
	close_button.name = "NecroChoiceClose"
	close_button.text = "Fechar"
	close_button.pressed.connect(func() -> void:
		necromancer_modal.visible = false
	)
	necromancer_choices_box.add_child(close_button)

func _open_necromancer_modal() -> void:
	if RunSession.selected_class_id != "necromante":
		return
	necromancer_modal.visible = true
	_refresh_necromancer_modal()

func _on_slot_target_dropped(data: Dictionary, owner: String, slot_index: int) -> void:
	_resolve_drop(data, {"owner": owner, "slot": slot_index})

func _on_hero_target_dropped(data: Dictionary, owner: String) -> void:
	_resolve_drop(data, {"owner": owner, "hero": true})

func _resolve_drop(data: Dictionary, target: Dictionary) -> void:
	match str(data.get("kind", "")):
		"battle_card":
			engine.play_card_from_hand(int(data.get("hand_index", -1)), target)
		"class_active":
			engine.use_class_active(target, str(data.get("choice_id", "")))
			selected_necromancer_choice_id = ""
	selected_hand_index = -1
	_hide_preview()
	_after_battle_action()

func _after_battle_action() -> void:
	if engine.outcome == "vitoria":
		RunSession.record_battle_result(RunSession.current_node_id, engine.outcome, engine.player_health)
	_refresh()

func _accepted_card_indices_for_target(target: Dictionary) -> Array[int]:
	var result: Array[int] = []
	for index: int in range(engine.hand.size()):
		if engine.can_play_card_on_target(index, target):
			result.append(index)
	return result

func _accepted_class_choices_for_target(target: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if not engine.can_use_class_active():
		return result
	if RunSession.selected_class_id == "necromante":
		for choice: Dictionary in engine.get_necromancer_active_choices():
			var choice_id: String = str(choice.get("id", ""))
			if bool(choice.get("enabled", false)) and engine.can_use_class_active_on_target(target, choice_id):
				result.append(choice_id)
	elif engine.can_use_class_active_on_target(target, ""):
		result.append("")
	return result

func _has_target(targets: Array[Dictionary], target: Dictionary) -> bool:
	for option: Dictionary in targets:
		if str(option.get("owner", "")) == str(target.get("owner", "")) and int(option.get("slot", -999)) == int(target.get("slot", -999)) and bool(option.get("hero", false)) == bool(target.get("hero", false)):
			return true
	return false

func _choice_is_enabled(choice_id: String) -> bool:
	for choice: Dictionary in engine.get_necromancer_active_choices():
		if str(choice.get("id", "")) == choice_id:
			return bool(choice.get("enabled", false))
	return false

func _schedule_preview(data: Dictionary) -> void:
	pending_preview_data = data
	if preview_timer != null:
		preview_timer.start()

func _show_preview_now(data: Dictionary) -> void:
	if data.is_empty() or preview_panel == null:
		return
	if preview_timer != null:
		preview_timer.stop()
	preview_title_label.text = str(data.get("title", ""))
	preview_subtitle_label.text = str(data.get("subtitle", ""))
	preview_body_label.text = str(data.get("body", ""))
	preview_state_label.text = str(data.get("state", ""))
	var target_position: Vector2 = get_local_mouse_position() + Vector2(18, 18)
	preview_panel.position = Vector2(min(target_position.x, max(18.0, size.x - 320.0)), min(target_position.y, max(18.0, size.y - 240.0)))
	preview_panel.visible = true

func _hide_preview() -> void:
	if preview_timer != null:
		preview_timer.stop()
	if preview_panel != null:
		preview_panel.visible = false

func _card_preview_data(card_id: String, occupant: Dictionary) -> Dictionary:
	var card = ContentLibrary.get_card(card_id)
	if card == null:
		return {"title": card_id, "subtitle": "Carta", "body": "", "state": ""}
	var subtitle: String = "%s | Custo %d" % [UiTokens.type_display_name(str(card.card_type)), int(card.cost)]
	if card.occupies_slot():
		subtitle += " | %d/%d" % [int(card.attack), int(card.health)]
	var body: String = VisualAssets.card_display_text(card)
	var keyword_text: String = _keyword_text(Array(card.keywords))
	if keyword_text != "":
		body += "\n\n%s" % keyword_text
	var state: String = ""
	if not occupant.is_empty():
		state = "Em campo: %d/%d" % [int(occupant.get("health", 0)), int(occupant.get("max_health", 0))]
		if int(occupant.get("slow_turns", 0)) > 0:
			state += " | Lentidao %d" % int(occupant.get("slow_turns", 0))
		if int(occupant.get("confusion_turns", 0)) > 0:
			state += " | Confusao %d" % int(occupant.get("confusion_turns", 0))
	return {"title": str(card.display_name), "subtitle": subtitle, "body": body, "state": state}

func _slot_preview_data(owner_id: String, slot_index: int, occupant: Variant) -> Dictionary:
	if occupant == null:
		return {
			"title": "%s %d" % ["Slot aliado" if owner_id == BattleEngine.PLAYER_ID else "Slot inimigo", slot_index + 1],
			"subtitle": "Livre",
			"body": "Pode receber cartas ou efeitos validos para este lado da mesa.",
			"state": ""
		}
	var data: Dictionary = Dictionary(occupant)
	return _card_preview_data(str(data.get("card_id", "")), data)

func _hero_preview_data(owner_id: String, display_name: String, health: int) -> Dictionary:
	return {
		"title": display_name,
		"subtitle": "Heroi %s" % ("aliado" if owner_id == BattleEngine.PLAYER_ID else "inimigo"),
		"body": "Alvo disponivel somente em modos com heroi.",
		"state": "Vida %d" % health
	}

func _class_active_preview_data() -> Dictionary:
	return {
		"title": _class_active_display_name(selected_necromancer_choice_id),
		"subtitle": "Spell de classe",
		"body": _class_active_detail_text(selected_necromancer_choice_id),
		"state": "Disponivel" if engine.can_use_class_active() else "Indisponivel neste turno"
	}

func _class_active_display_name(choice_id: String = "") -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "Rajada Arcana"
		"invocador":
			return "Ordem de Guerra"
		"necromante":
			for choice: Dictionary in engine.get_necromancer_active_choices():
				if str(choice.get("id", "")) == choice_id:
					return str(choice.get("display_name", "Ritual das Sombras"))
			return "Ritual das Sombras"
	return "Spell de Classe"

func _class_active_detail_text(choice_id: String = "") -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "1 mana. Arraste para uma criatura ou heroi valido; causa 1 + Fluxo de dano."
		"invocador":
			return "1 mana. Arraste para uma criatura aliada; concede +2/+0 permanente."
		"necromante":
			for choice: Dictionary in engine.get_necromancer_active_choices():
				if str(choice.get("id", "")) == choice_id:
					return "%d Cinzas. %s" % [int(choice.get("cost_ashes", 0)), str(choice.get("text", ""))]
			return "Clique para escolher Lentidao, Podridao, Confusao ou uma reanimacao antes de arrastar."
	return ""

func _keyword_text(keywords: Array) -> String:
	var parts: Array[String] = []
	for keyword: Variant in keywords:
		match str(keyword):
			"protecao":
				parts.append("Protecao: inimigos priorizam esta criatura.")
			"voadora":
				parts.append("Voadora: pode atacar o heroi inimigo diretamente quando o modo permite.")
			"regeneracao":
				parts.append("Regeneracao: recupera 1 HP no inicio do turno do jogador.")
	return "\n".join(parts)

func _hero_display_name(owner_id: String) -> String:
	var catalog = ContentLibrary.get_catalog()
	if owner_id == BattleEngine.PLAYER_ID and catalog != null and catalog.player_hero != null:
		return str(catalog.player_hero.display_name)
	if owner_id == BattleEngine.ENEMY_ID and catalog != null and catalog.enemy_hero != null:
		return str(catalog.enemy_hero.display_name)
	return "Heroi"

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 6
	style.content_margin_top = 6
	style.content_margin_right = 6
	style.content_margin_bottom = 6
	return style

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
