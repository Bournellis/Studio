extends Control

const BattleClassActiveTokenScript = preload("res://ui/controls/battle_class_active_token.gd")
const BattleHeroTargetControlScript = preload("res://ui/controls/battle_hero_target_control.gd")
const BattleBoardAreaTargetScript = preload("res://ui/controls/battle_board_area_target.gd")

var engine: BattleEngine = BattleEngine.new()
var player_hud_dock: PanelContainer
var enemy_commander_hud: PanelContainer
var enemy_cardback_rail: Control
var objective_chip: Label
var player_hp_value: Label
var player_mana_value: Label
var class_resource_chip: PanelContainer
var class_resource_label: Label
var class_resource_value: Label
var enemy_hp_value: Label
var enemy_mana_value: Label
var hero_targets_box: HBoxContainer
var player_hero_target_box: HBoxContainer
var enemy_board_area_target
var enemy_slots_box: HBoxContainer
var player_slots_box: HBoxContainer
var hand_box: HBoxContainer
var history_log_label: Label
var history_panel: PanelContainer
var end_turn_button: Button
var esc_menu: PanelContainer
var class_passive_tile
var class_active_tile
var combat_fx_panel: PanelContainer
var combat_fx_label: Label
var combat_fx_timer: Timer
var combat_fx_queue: Array[Dictionary] = []
var combat_fx_index: int = 0
var active_combat_fx_event: Dictionary = {}
var necromancer_modal: PanelContainer
var necromancer_choices_box: VBoxContainer
var pending_choice_modal: PanelContainer
var pending_choice_box: VBoxContainer
var reward_modal: PanelContainer
var reward_text_label: Label
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
var victory_recorded: bool = false

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
		"class_passive_unlocked": RunSession.class_passive_unlocked,
		"class_active_unlocked": RunSession.class_active_unlocked,
		"mana_per_turn": RunSession.max_mana if RunSession.max_mana > 0 else 2,
		"max_hand_size": RunSession.max_hand_size if RunSession.max_hand_size > 0 else RunSession.DEFAULT_MAX_HAND_SIZE,
		"player_health": RunSession.current_health if RunSession.current_health > 0 else 20,
		"shuffle_seed": RunSession.run_seed
	})
	_build_ui()
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		var viewport: Viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()
		_toggle_esc_menu()

func _toggle_esc_menu() -> void:
	if esc_menu != null:
		esc_menu.visible = not esc_menu.visible

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("battle_board_background")
	background.name = "BattleVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "BattleVisualScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.16)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "BattleLayout"
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", _battle_outer_margin_x())
	root_margin.add_theme_constant_override("margin_top", _battle_outer_margin_top())
	root_margin.add_theme_constant_override("margin_right", _battle_outer_margin_x())
	root_margin.add_theme_constant_override("margin_bottom", _battle_outer_margin_bottom())
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.name = "BattleMainStack"
	main_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_box.add_theme_constant_override("separation", 4 if _uses_dense_battle_layout() else 6)
	root_margin.add_child(main_box)

	hero_targets_box = HBoxContainer.new()
	hero_targets_box.name = "BattleHeroTargets"
	hero_targets_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_targets_box.add_theme_constant_override("separation", 8)
	hero_targets_box.alignment = BoxContainer.ALIGNMENT_CENTER

	enemy_slots_box = HBoxContainer.new()
	enemy_slots_box.name = "BattleEnemySlots"
	enemy_slots_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enemy_slots_box.add_theme_constant_override("separation", 8)
	enemy_slots_box.alignment = BoxContainer.ALIGNMENT_CENTER

	enemy_board_area_target = BattleBoardAreaTargetScript.new()
	enemy_board_area_target.name = "BattleEnemyBoardAreaTarget"
	enemy_board_area_target.visible = false
	enemy_board_area_target.target_dropped.connect(_on_area_target_dropped)

	player_slots_box = HBoxContainer.new()
	player_slots_box.name = "BattlePlayerSlots"
	player_slots_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_slots_box.add_theme_constant_override("separation", 8)
	player_slots_box.alignment = BoxContainer.ALIGNMENT_CENTER

	player_hero_target_box = HBoxContainer.new()
	player_hero_target_box.name = "BattlePlayerHeroTargets"
	player_hero_target_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_hero_target_box.add_theme_constant_override("separation", 8)
	player_hero_target_box.alignment = BoxContainer.ALIGNMENT_CENTER

	var board_panel: PanelContainer = PanelContainer.new()
	board_panel.name = "BattleBoardPanel"
	board_panel.custom_minimum_size = Vector2(0, _board_min_height())
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.04, 0.045, 0.18), Color(0.48, 0.40, 0.34, 0.70)))
	main_box.add_child(board_panel)

	var board_surface: Control = Control.new()
	board_surface.name = "BattleBoardSurface"
	board_surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_child(board_surface)

	board_surface.add_child(enemy_board_area_target)
	_apply_area_target_overlay_rect(enemy_board_area_target)

	var board_margin: MarginContainer = MarginContainer.new()
	board_margin.name = "BattleBoardMargin"
	board_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	board_margin.add_theme_constant_override("margin_left", 10 if _uses_dense_battle_layout() else 14)
	board_margin.add_theme_constant_override("margin_top", 6 if _uses_dense_battle_layout() else 8)
	board_margin.add_theme_constant_override("margin_right", 10 if _uses_dense_battle_layout() else 14)
	board_margin.add_theme_constant_override("margin_bottom", 6 if _uses_dense_battle_layout() else 8)
	board_surface.add_child(board_margin)

	var board_box: VBoxContainer = VBoxContainer.new()
	board_box.name = "BattleBoardRows"
	board_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_box.add_theme_constant_override("separation", 4 if _uses_dense_battle_layout() else 6)
	board_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_margin.add_child(board_box)

	objective_chip = Label.new()
	objective_chip.name = "BattleObjectiveChip"
	objective_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective_chip.visible = false
	objective_chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_chip.add_theme_font_size_override("font_size", 11)
	objective_chip.add_theme_color_override("font_color", Color(0.98, 0.86, 0.48))
	objective_chip.add_theme_stylebox_override("normal", _label_chip_style(Color(0.07, 0.06, 0.045, 0.72), Color(0.86, 0.64, 0.22, 0.88)))
	board_box.add_child(objective_chip)
	board_box.add_child(hero_targets_box)
	board_box.add_child(enemy_slots_box)
	var board_spacer: Control = Control.new()
	board_spacer.name = "BattleBoardCenterSpace"
	board_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_spacer.custom_minimum_size = Vector2(0, _board_center_space())
	board_spacer.size_flags_vertical = Control.SIZE_SHRINK_CENTER if _is_compact_viewport() else Control.SIZE_EXPAND_FILL
	board_box.add_child(board_spacer)
	board_box.add_child(player_slots_box)
	board_box.add_child(player_hero_target_box)

	var hand_panel: PanelContainer = PanelContainer.new()
	hand_panel.name = "BattleHandPanel"
	hand_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hand_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.04, 0.045, 0.60), Color(0.30, 0.38, 0.42, 0.75)))
	main_box.add_child(hand_panel)

	var hand_margin: MarginContainer = MarginContainer.new()
	hand_margin.add_theme_constant_override("margin_left", 8)
	hand_margin.add_theme_constant_override("margin_top", 4 if _is_compact_viewport() else 6)
	hand_margin.add_theme_constant_override("margin_right", 8)
	hand_margin.add_theme_constant_override("margin_bottom", 4 if _is_compact_viewport() else 6)
	hand_panel.add_child(hand_margin)

	var hand_row: HBoxContainer = HBoxContainer.new()
	hand_row.name = "BattleHandControlsRow"
	hand_row.add_theme_constant_override("separation", 8 if _is_compact_viewport() else 10)
	hand_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hand_margin.add_child(hand_row)

	player_hud_dock = _build_player_hud_dock()
	hand_row.add_child(player_hud_dock)

	hand_box = HBoxContainer.new()
	hand_box.name = "BattleHand"
	hand_box.add_theme_constant_override("separation", 8)
	hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	hand_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hand_row.add_child(hand_box)

	_build_floating_end_turn_button()
	enemy_commander_hud = _build_enemy_commander_hud()
	add_child(enemy_commander_hud)
	_apply_enemy_commander_hud_rect(enemy_commander_hud)

	history_panel = PanelContainer.new()
	history_panel.name = "BattleLogHistoryPanel"
	history_panel.visible = false
	history_panel.anchor_left = 1.0
	history_panel.anchor_top = 0.13
	history_panel.anchor_right = 1.0
	history_panel.anchor_bottom = 0.13
	history_panel.offset_left = -336.0
	history_panel.offset_top = 0.0
	history_panel.offset_right = -18.0
	history_panel.offset_bottom = 250.0
	history_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.055, 0.06, 0.88), Color(0.42, 0.48, 0.52, 0.90)))
	add_child(history_panel)

	var history_margin: MarginContainer = MarginContainer.new()
	history_margin.add_theme_constant_override("margin_left", 10)
	history_margin.add_theme_constant_override("margin_top", 10)
	history_margin.add_theme_constant_override("margin_right", 10)
	history_margin.add_theme_constant_override("margin_bottom", 10)
	history_panel.add_child(history_margin)

	var log_scroll: ScrollContainer = ScrollContainer.new()
	log_scroll.name = "BattleLogScroll"
	log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	log_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	history_margin.add_child(log_scroll)

	history_log_label = Label.new()
	history_log_label.name = "BattleLog"
	history_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	history_log_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	history_log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.add_child(history_log_label)

	_build_preview_panel()
	_build_combat_fx_panel()
	_build_necromancer_modal()
	_build_pending_choice_modal()
	_build_reward_modal()
	_build_esc_menu()

func _build_enemy_commander_hud() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "BattleEnemyCommanderHud"
	panel.visible = false
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.custom_minimum_size = _enemy_commander_hud_size()
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.075, 0.035, 0.04, 0.70), Color(0.62, 0.28, 0.26, 0.82)))

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	panel.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "BattleEnemyCommanderRow"
	row.add_theme_constant_override("separation", 6 if _is_compact_viewport() else 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)

	row.add_child(_build_hud_stat("BattleEnemyManaStat", "MANA", "BattleEnemyManaValue", UiTokens.color("energy")))

	enemy_cardback_rail = Control.new()
	enemy_cardback_rail.name = "BattleEnemyCardbackRail"
	enemy_cardback_rail.clip_contents = true
	enemy_cardback_rail.custom_minimum_size = Vector2(168 if _is_compact_viewport() else 196, 46 if _is_compact_viewport() else 56)
	enemy_cardback_rail.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	row.add_child(enemy_cardback_rail)
	return panel

func _build_player_hud_dock() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "BattlePlayerHudDock"
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.055, 0.74), Color(0.32, 0.50, 0.54, 0.82)))

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4 if _is_compact_viewport() else 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4 if _is_compact_viewport() else 6)
	panel.add_child(margin)

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "BattlePlayerHudRow"
	row.add_theme_constant_override("separation", 5 if _is_compact_viewport() else 7)
	margin.add_child(row)

	row.add_child(_build_hud_stat("BattlePlayerManaStat", "MANA", "BattlePlayerManaValue", UiTokens.color("energy")))

	class_resource_chip = _build_class_resource_chip()
	row.add_child(class_resource_chip)

	class_passive_tile = BattleClassActiveTokenScript.new()
	class_passive_tile.name = "BattleClassPassiveTile"
	class_passive_tile.mouse_entered.connect(func() -> void:
		_schedule_preview(_class_passive_preview_data())
	)
	class_passive_tile.mouse_exited.connect(_hide_preview)
	row.add_child(class_passive_tile)

	class_active_tile = BattleClassActiveTokenScript.new()
	class_active_tile.name = "BattleClassActiveTile"
	class_active_tile.choices_requested.connect(_open_necromancer_modal)
	class_active_tile.mouse_entered.connect(func() -> void:
		_schedule_preview(_class_active_preview_data())
	)
	class_active_tile.mouse_exited.connect(_hide_preview)
	row.add_child(class_active_tile)

	var history_button: Button = Button.new()
	history_button.name = "BattleLogHistoryButton"
	history_button.text = "Log"
	history_button.tooltip_text = "Abrir historico de combate"
	history_button.custom_minimum_size = Vector2(48 if _is_compact_viewport() else 54, 36 if _is_compact_viewport() else 38)
	history_button.pressed.connect(_toggle_history_log)
	row.add_child(history_button)
	return panel

func _build_hud_stat(panel_name: String, caption: String, value_name: String, accent: Color) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = panel_name
	panel.custom_minimum_size = Vector2(76 if _is_compact_viewport() else 96, 38 if _is_compact_viewport() else 46)
	panel.add_theme_stylebox_override("panel", _hud_stat_style(accent))

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	panel.add_child(box)

	var label: Label = Label.new()
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.80))
	box.add_child(label)

	var value: Label = Label.new()
	value.name = value_name
	value.text = "0"
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 17 if _is_compact_viewport() else 21)
	value.add_theme_color_override("font_color", Color(0.98, 0.96, 0.88))
	box.add_child(value)
	if value_name == "BattlePlayerHpValue":
		player_hp_value = value
	elif value_name == "BattlePlayerManaValue":
		player_mana_value = value
	elif value_name == "BattleEnemyHpValue":
		enemy_hp_value = value
	elif value_name == "BattleEnemyManaValue":
		enemy_mana_value = value
	return panel

func _build_class_resource_chip() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "BattleClassResourceChip"
	panel.visible = false
	panel.custom_minimum_size = Vector2(82 if _is_compact_viewport() else 108, 38 if _is_compact_viewport() else 46)
	panel.add_theme_stylebox_override("panel", _hud_stat_style(Color(0.64, 0.42, 0.86)))

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	panel.add_child(box)

	class_resource_label = Label.new()
	class_resource_label.name = "BattleClassResourceLabel"
	class_resource_label.text = ""
	class_resource_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_resource_label.add_theme_font_size_override("font_size", 8)
	class_resource_label.add_theme_color_override("font_color", Color(0.84, 0.78, 0.92))
	box.add_child(class_resource_label)

	class_resource_value = Label.new()
	class_resource_value.name = "BattleClassResourceValue"
	class_resource_value.text = ""
	class_resource_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_resource_value.add_theme_font_size_override("font_size", 17 if _is_compact_viewport() else 21)
	class_resource_value.add_theme_color_override("font_color", Color(0.98, 0.96, 0.88))
	box.add_child(class_resource_value)
	return panel

func _build_floating_end_turn_button() -> void:
	end_turn_button = Button.new()
	end_turn_button.name = "BattleEndTurnFloatingButton"
	end_turn_button.text = "Resolver\nCombate"
	end_turn_button.tooltip_text = "Resolver combate e manutencao da mesa"
	end_turn_button.custom_minimum_size = Vector2(104 if _is_compact_viewport() else 122, 58 if _is_compact_viewport() else 70)
	end_turn_button.anchor_left = 1.0
	end_turn_button.anchor_top = 0.5
	end_turn_button.anchor_right = 1.0
	end_turn_button.anchor_bottom = 0.5
	end_turn_button.offset_left = -118.0 if _is_compact_viewport() else -140.0
	end_turn_button.offset_top = -28.0 if _is_compact_viewport() else -35.0
	end_turn_button.offset_right = -10.0 if _is_compact_viewport() else -14.0
	end_turn_button.offset_bottom = 30.0 if _is_compact_viewport() else 35.0
	end_turn_button.pressed.connect(func() -> void:
		engine.resolve_combat_cycle()
		selected_hand_index = -1
		_after_battle_action()
		_play_combat_fx_events(Array(engine.get_state().get("visual_events", [])))
	)
	add_child(end_turn_button)

func _build_combat_fx_panel() -> void:
	combat_fx_panel = PanelContainer.new()
	combat_fx_panel.name = "BattleCombatFxPanel"
	combat_fx_panel.visible = false
	combat_fx_panel.anchor_left = 0.5
	combat_fx_panel.anchor_top = 0.47
	combat_fx_panel.anchor_right = 0.5
	combat_fx_panel.anchor_bottom = 0.47
	combat_fx_panel.offset_left = -190.0
	combat_fx_panel.offset_top = -32.0
	combat_fx_panel.offset_right = 190.0
	combat_fx_panel.offset_bottom = 32.0
	combat_fx_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.028, 0.045, 0.88), Color(0.82, 0.58, 0.28, 0.92)))
	add_child(combat_fx_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	combat_fx_panel.add_child(margin)

	combat_fx_label = Label.new()
	combat_fx_label.name = "BattleCombatFxLabel"
	combat_fx_label.text = ""
	combat_fx_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combat_fx_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_fx_label.add_theme_font_size_override("font_size", 15)
	combat_fx_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	margin.add_child(combat_fx_label)

	combat_fx_timer = Timer.new()
	combat_fx_timer.name = "BattleCombatFxTimer"
	combat_fx_timer.one_shot = true
	combat_fx_timer.timeout.connect(_advance_combat_fx)
	add_child(combat_fx_timer)

func _build_esc_menu() -> void:
	esc_menu = PanelContainer.new()
	esc_menu.name = "BattleEscMenu"
	esc_menu.visible = false
	esc_menu.anchor_left = 0.5
	esc_menu.anchor_top = 0.5
	esc_menu.anchor_right = 0.5
	esc_menu.anchor_bottom = 0.5
	esc_menu.offset_left = -160.0
	esc_menu.offset_top = -128.0
	esc_menu.offset_right = 160.0
	esc_menu.offset_bottom = 128.0
	esc_menu.custom_minimum_size = Vector2(320, 256)
	esc_menu.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.05, 0.06, 0.94), Color(0.68, 0.58, 0.38, 0.95)))
	add_child(esc_menu)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	esc_menu.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.name = "BattleEscMenuActions"
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var title: Label = Label.new()
	title.name = "BattleEscMenuTitle"
	title.text = "Pausa"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	var resume_button: Button = _build_esc_button("BattleEscResumeButton", "Retomar")
	resume_button.pressed.connect(func() -> void:
		esc_menu.visible = false
	)
	box.add_child(resume_button)

	var map_button: Button = _build_esc_button("BattleEscBackToRunMapButton", "Voltar ao Mapa")
	map_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/run_map/run_map.tscn")
	)
	box.add_child(map_button)

	var boot_button: Button = _build_esc_button("BattleEscMainMenuButton", "Menu Principal")
	boot_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/boot/boot.tscn")
	)
	box.add_child(boot_button)

	var quit_button: Button = _build_esc_button("BattleEscQuitButton", "Fechar Jogo")
	quit_button.pressed.connect(func() -> void:
		get_tree().quit()
	)
	box.add_child(quit_button)

func _build_esc_button(node_name: String, text: String) -> Button:
	var button: Button = Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(0, 38)
	return button

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
	_apply_centered_modal_rect(necromancer_modal, _choice_modal_size())
	necromancer_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.1, 0.08, 0.12), Color(0.62, 0.42, 0.7)))
	add_child(necromancer_modal)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	necromancer_modal.add_child(margin)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "NecromancerChoiceScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	necromancer_choices_box = VBoxContainer.new()
	necromancer_choices_box.name = "NecromancerChoiceList"
	necromancer_choices_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	necromancer_choices_box.add_theme_constant_override("separation", 7)
	scroll.add_child(necromancer_choices_box)

func _build_pending_choice_modal() -> void:
	pending_choice_modal = PanelContainer.new()
	pending_choice_modal.name = "PendingBattleChoiceModal"
	pending_choice_modal.visible = false
	_apply_centered_modal_rect(pending_choice_modal, _choice_modal_size())
	pending_choice_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1), Color(0.78, 0.62, 0.34)))
	add_child(pending_choice_modal)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	pending_choice_modal.add_child(margin)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "PendingBattleChoiceScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	pending_choice_box = VBoxContainer.new()
	pending_choice_box.name = "PendingBattleChoiceList"
	pending_choice_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pending_choice_box.add_theme_constant_override("separation", 7)
	scroll.add_child(pending_choice_box)

func _build_reward_modal() -> void:
	reward_modal = PanelContainer.new()
	reward_modal.name = "BattleRewardModal"
	reward_modal.visible = false
	reward_modal.anchor_left = 0.5
	reward_modal.anchor_top = 0.5
	reward_modal.anchor_right = 0.5
	reward_modal.anchor_bottom = 0.5
	reward_modal.offset_left = -220.0
	reward_modal.offset_top = -150.0
	reward_modal.offset_right = 220.0
	reward_modal.offset_bottom = 150.0
	reward_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.052, 0.06, 0.96), Color(0.88, 0.70, 0.34, 0.95)))
	add_child(reward_modal)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	reward_modal.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title: Label = Label.new()
	title.name = "BattleRewardTitle"
	title.text = "Vitória"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	reward_text_label = Label.new()
	reward_text_label.name = "BattleRewardText"
	reward_text_label.text = ""
	reward_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reward_text_label.add_theme_font_size_override("font_size", 14)
	reward_text_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	reward_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(reward_text_label)

	var ok_button: Button = Button.new()
	ok_button.name = "BattleRewardOkButton"
	ok_button.text = "OK"
	ok_button.custom_minimum_size = Vector2(0, 42)
	ok_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/run_map/run_map.tscn")
	)
	box.add_child(ok_button)

func _refresh() -> void:
	var state: Dictionary = engine.get_state()
	_refresh_player_hud(state)
	_refresh_enemy_commander_hud(state)
	_refresh_objective_chip(state)
	_rebuild_hero_targets(state)
	_refresh_area_targets()
	_rebuild_slots(enemy_slots_box, Array(state.get("enemy_slots", [])), BattleEngine.ENEMY_ID)
	_rebuild_slots(player_slots_box, Array(state.get("player_slots", [])), BattleEngine.PLAYER_ID)
	_rebuild_hand(Array(state.get("hand", [])))
	_refresh_class_passive_tile()
	_refresh_class_active_tile()
	_refresh_necromancer_modal()
	_refresh_pending_choice_modal()
	var log_entries: Array = Array(state.get("log", []))
	if history_log_label != null:
		history_log_label.text = "\n".join(log_entries)
	if end_turn_button != null:
		end_turn_button.disabled = engine.outcome != "" or engine.has_pending_choice()

func _refresh_player_hud(state: Dictionary) -> void:
	if player_hp_value != null:
		player_hp_value.text = str(int(state.get("player_health", 0)))
	if player_mana_value != null:
		player_mana_value.text = "%d/%d" % [int(state.get("mana", 0)), int(state.get("mana_per_turn", 0))]
	if class_resource_chip == null:
		return
	var resource: Dictionary = _class_resource_data(state)
	class_resource_chip.visible = not resource.is_empty()
	if resource.is_empty():
		if class_resource_label != null:
			class_resource_label.text = ""
		if class_resource_value != null:
			class_resource_value.text = ""
		return
	class_resource_label.text = str(resource.get("label", ""))
	class_resource_value.text = str(resource.get("value", "0"))

func _refresh_enemy_commander_hud(state: Dictionary) -> void:
	var enabled: bool = bool(state.get("enemy_commander_enabled", false))
	if enemy_commander_hud != null:
		enemy_commander_hud.visible = enabled
	if enemy_hp_value != null:
		enemy_hp_value.text = str(int(state.get("enemy_health", 0)))
	if enemy_mana_value != null:
		enemy_mana_value.text = "%d/%d" % [int(state.get("enemy_mana", 0)), int(state.get("enemy_mana_per_turn", 0))]
	_rebuild_enemy_cardbacks(int(state.get("enemy_hand_count", 0)) if enabled else 0)

func _refresh_objective_chip(state: Dictionary) -> void:
	if objective_chip == null:
		return
	var text: String = _objective_text(state)
	objective_chip.text = text
	objective_chip.visible = text != ""

func _class_resource_data(state: Dictionary) -> Dictionary:
	match RunSession.selected_class_id:
		"arcano":
			if RunSession.class_passive_unlocked:
				return {"label": "Fluxo", "value": int(state.get("flow", 0))}
		"necromante":
			if RunSession.class_passive_unlocked or RunSession.class_active_unlocked or int(state.get("ashes", 0)) > 0:
				return {"label": "Cinzas", "value": int(state.get("ashes", 0))}
	return {}

func _objective_text(state: Dictionary) -> String:
	var mode: String = str(state.get("mode", ""))
	match mode:
		BattleEngine.MODE_WAVES:
			var total_waves: int = int(state.get("waves_total", 0))
			if total_waves > 0:
				return "Onda %d/%d" % [int(state.get("wave_index", 0)), total_waves]
		BattleEngine.MODE_DEFENSE_POSITION:
			return "Defenda %d/%d" % [int(state.get("survived_turns", 0)), int(state.get("required_defense_turns", 0))]
		BattleEngine.MODE_SURVIVE_TURNS:
			return "Sobreviva %d/%d" % [int(state.get("survived_turns", 0)), int(state.get("required_survive_turns", 0))]
		BattleEngine.MODE_SUMMONER_BOSS:
			return "Chefe HP %d" % int(state.get("enemy_health", 0))
	if bool(state.get("enemy_commander_enabled", false)):
		return "Derrote %s" % _hero_display_name(BattleEngine.ENEMY_ID)
	return ""

func _rebuild_enemy_cardbacks(count: int) -> void:
	if enemy_cardback_rail == null:
		return
	for child: Node in enemy_cardback_rail.get_children():
		child.queue_free()
	var cardback_size: Vector2 = Vector2(30, 42) if _is_compact_viewport() else Vector2(36, 52)
	var step_x: float = 22.0 if _is_compact_viewport() else 27.0
	for index: int in range(count):
		var cardback: PanelContainer = PanelContainer.new()
		cardback.name = "BattleEnemyCardback%d" % index
		cardback.custom_minimum_size = cardback_size
		cardback.position = Vector2(index * step_x, 2.0)
		cardback.add_theme_stylebox_override("panel", _cardback_style())
		enemy_cardback_rail.add_child(cardback)

func _toggle_history_log() -> void:
	if history_panel != null:
		history_panel.visible = not history_panel.visible

func _rebuild_hero_targets(state: Dictionary) -> void:
	for child: Node in hero_targets_box.get_children():
		child.queue_free()
	for child: Node in player_hero_target_box.get_children():
		child.queue_free()
	hero_targets_box.visible = _enemy_hero_visible(state)
	player_hero_target_box.visible = true
	if hero_targets_box.visible:
		_add_hero_target(hero_targets_box, BattleEngine.ENEMY_ID, _hero_display_name(BattleEngine.ENEMY_ID), int(state.get("enemy_health", 0)))
	_add_hero_target(player_hero_target_box, BattleEngine.PLAYER_ID, _hero_display_name(BattleEngine.PLAYER_ID), int(state.get("player_health", 0)))

func _add_hero_target(container: HBoxContainer, owner_id: String, display_name: String, health: int) -> void:
	var target: Dictionary = {"owner": owner_id, "hero": true}
	var visual_state: Dictionary = {
		"accepted_card_indices": _accepted_card_indices_for_target(target),
		"accepted_class_choices": _accepted_class_choices_for_target(target)
	}
	visual_state["is_drop_target"] = not Array(visual_state.get("accepted_card_indices", [])).is_empty() or not Array(visual_state.get("accepted_class_choices", [])).is_empty()
	visual_state["is_attack_target"] = _active_event_targets_hero(owner_id)
	var hero_target = BattleHeroTargetControlScript.new()
	hero_target.name = "Battle%sHeroTarget" % ("Player" if owner_id == BattleEngine.PLAYER_ID else "Enemy")
	hero_target.setup(owner_id, display_name, health, visual_state)
	hero_target.target_dropped.connect(_on_hero_target_dropped)
	hero_target.mouse_entered.connect(func() -> void:
		_schedule_preview(_hero_preview_data(owner_id, display_name, health))
	)
	hero_target.mouse_exited.connect(_hide_preview)
	container.add_child(hero_target)

func _refresh_area_targets() -> void:
	if enemy_board_area_target == null:
		return
	var target: Dictionary = {"owner": BattleEngine.ENEMY_ID, "area": "board"}
	var visual_state: Dictionary = {
		"accepted_card_indices": _accepted_card_indices_for_target(target),
		"board_table": true
	}
	var visible: bool = _has_enemy_board_area_card_in_hand() or not Array(visual_state.get("accepted_card_indices", [])).is_empty()
	enemy_board_area_target.setup("Mesa inimiga", "Solte spells de area aqui", target, visual_state)
	enemy_board_area_target.visible = visible

func _rebuild_slots(container: HBoxContainer, slots: Array, owner_id: String) -> void:
	for child: Node in container.get_children():
		child.queue_free()
	var area_target: Dictionary = {"owner": BattleEngine.ENEMY_ID, "area": "board"}
	var accepted_area_card_indices: Array[int] = []
	if owner_id == BattleEngine.ENEMY_ID:
		accepted_area_card_indices = _accepted_card_indices_for_target(area_target)
	for index: int in range(slots.size()):
		var target: Dictionary = {"owner": owner_id, "slot": index}
		var visual_state: Dictionary = {
			"label": "%s %d" % ["Jogador" if owner_id == BattleEngine.PLAYER_ID else "Inimigo", index + 1],
			"is_empty": slots[index] == null,
			"card_size": _field_card_size(),
			"can_drag_unit": owner_id == BattleEngine.PLAYER_ID and slots[index] != null,
			"accepted_move_sources": _accepted_move_sources_for_target(owner_id, index),
			"accepted_area_card_indices": accepted_area_card_indices,
			"accepted_card_indices": _accepted_card_indices_for_target(target),
			"accepted_class_choices": _accepted_class_choices_for_target(target)
		}
		visual_state["is_attack_source"] = _active_event_sources_slot(owner_id, index)
		visual_state["is_attack_target"] = _active_event_targets_slot(owner_id, index)
		visual_state["is_drop_target"] = not Array(visual_state.get("accepted_card_indices", [])).is_empty() or not Array(visual_state.get("accepted_class_choices", [])).is_empty() or not Array(visual_state.get("accepted_move_sources", [])).is_empty() or not Array(visual_state.get("accepted_area_card_indices", [])).is_empty()
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
		token.setup(card_id, index, engine.can_play_card(card), selected_hand_index == index, _hand_card_size(), engine.get_card_text_context(card_id))
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

func _refresh_class_passive_tile() -> void:
	class_passive_tile.visible = RunSession.class_passive_unlocked
	if not RunSession.class_passive_unlocked:
		return
	class_passive_tile.setup(RunSession.selected_class_id, _class_passive_display_name(), _class_passive_detail_text(), "", true, false, "PASSIVA", false)

func _refresh_class_active_tile() -> void:
	class_active_tile.visible = RunSession.class_active_unlocked
	if not RunSession.class_active_unlocked:
		return
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

func _refresh_pending_choice_modal() -> void:
	if pending_choice_modal == null or pending_choice_box == null:
		return
	for child: Node in pending_choice_box.get_children():
		child.queue_free()
	var choice: Dictionary = engine.get_pending_choice()
	pending_choice_modal.visible = not choice.is_empty()
	if choice.is_empty():
		return
	var title: Label = Label.new()
	title.text = str(choice.get("source_name", "Escolha pendente"))
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	pending_choice_box.add_child(title)
	match str(choice.get("action", "")):
		"promote":
			for option: Dictionary in Array(choice.get("options", [])):
				var option_id: String = str(option.get("id", ""))
				var button: Button = Button.new()
				button.name = "PendingChoice_%s" % option_id
				button.text = "%s\n%s" % [str(option.get("display_name", option_id)), str(option.get("text", ""))]
				button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				button.pressed.connect(func() -> void:
					engine.resolve_pending_choice({}, option_id)
					_after_battle_action()
				)
				pending_choice_box.add_child(button)
		"weaken":
			for target: Dictionary in engine.get_valid_pending_choice_targets():
				var slot_index: int = int(target.get("slot", -1))
				var occupant: Dictionary = Dictionary(engine.enemy_slots[slot_index])
				var button: Button = Button.new()
				button.name = "PendingWeakenTarget_%d" % slot_index
				button.text = "Enfraquecer %s\nSlot inimigo %d" % [str(occupant.get("name", "Criatura")), slot_index + 1]
				button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				button.pressed.connect(func() -> void:
					engine.resolve_pending_choice(target)
					_after_battle_action()
				)
				pending_choice_box.add_child(button)
			if engine.get_valid_pending_choice_targets().is_empty():
				var button: Button = Button.new()
				button.name = "PendingWeakenNoTarget"
				button.text = "Resolver sem alvo valido"
				button.pressed.connect(func() -> void:
					engine.resolve_pending_choice()
					_after_battle_action()
				)
				pending_choice_box.add_child(button)

func _open_necromancer_modal() -> void:
	if RunSession.selected_class_id != "necromante" or not RunSession.class_active_unlocked:
		return
	necromancer_modal.visible = true
	_refresh_necromancer_modal()

func _on_slot_target_dropped(data: Dictionary, owner: String, slot_index: int) -> void:
	_resolve_drop(data, _slot_or_area_drop_target(data, owner, slot_index))

func _on_hero_target_dropped(data: Dictionary, owner: String) -> void:
	_resolve_drop(data, {"owner": owner, "hero": true})

func _on_area_target_dropped(data: Dictionary, target: Dictionary) -> void:
	_resolve_drop(data, target)

func _resolve_drop(data: Dictionary, target: Dictionary) -> void:
	match str(data.get("kind", "")):
		"battle_card":
			engine.play_card_from_hand(int(data.get("hand_index", -1)), target)
		"class_active":
			engine.use_class_active(target, str(data.get("choice_id", "")))
			selected_necromancer_choice_id = ""
		"field_unit":
			engine.move_unit(str(data.get("owner", BattleEngine.PLAYER_ID)), int(data.get("slot", -1)), int(target.get("slot", -1)))
	selected_hand_index = -1
	_hide_preview()
	_after_battle_action()

func _slot_or_area_drop_target(data: Dictionary, owner: String, slot_index: int) -> Dictionary:
	var slot_target: Dictionary = {"owner": owner, "slot": slot_index}
	if str(data.get("kind", "")) != "battle_card" or owner != BattleEngine.ENEMY_ID:
		return slot_target
	var hand_index: int = int(data.get("hand_index", -1))
	var area_target: Dictionary = {"owner": BattleEngine.ENEMY_ID, "area": "board"}
	if engine.can_play_card_on_target(hand_index, area_target) and not engine.can_play_card_on_target(hand_index, slot_target):
		return area_target
	return slot_target

func _after_battle_action() -> void:
	if engine.outcome == "vitoria" and not victory_recorded:
		victory_recorded = true
		var reward_summary: Dictionary = RunSession.record_battle_result(RunSession.current_node_id, engine.outcome, engine.player_health)
		SaveManager.save_current_run()
		_show_reward_modal(reward_summary)
	_refresh()

func _show_reward_modal(summary: Dictionary) -> void:
	if reward_modal == null or reward_text_label == null:
		return
	var lines: Array[String] = []
	lines.append("Encontro concluído: %s" % str(summary.get("node_id", "")))
	lines.append("Almas +%d" % int(summary.get("souls_gained", 0)))
	var rewards: Array = Array(summary.get("automatic_rewards", []))
	for reward_id: Variant in rewards:
		lines.append(RunSession.automatic_reward_display_name(str(reward_id)))
	var next_node_id: String = str(summary.get("next_node_id", ""))
	if next_node_id == "":
		lines.append("Rota concluída.")
	else:
		lines.append("Próximo: %s" % RunSession.current_node_display_name())
	reward_text_label.text = "\n".join(lines)
	reward_modal.visible = true

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

func _accepted_move_sources_for_target(owner_id: String, slot_index: int) -> Array[int]:
	var result: Array[int] = []
	if owner_id != BattleEngine.PLAYER_ID:
		return result
	for source_index: int in range(engine.player_slots.size()):
		if engine.can_move_unit(owner_id, source_index, slot_index):
			result.append(source_index)
	return result

func _has_target(targets: Array[Dictionary], target: Dictionary) -> bool:
	for option: Dictionary in targets:
		if str(option.get("owner", "")) == str(target.get("owner", "")) and int(option.get("slot", -999)) == int(target.get("slot", -999)) and bool(option.get("hero", false)) == bool(target.get("hero", false)) and str(option.get("area", "")) == str(target.get("area", "")):
			return true
	return false

func _choice_is_enabled(choice_id: String) -> bool:
	for choice: Dictionary in engine.get_necromancer_active_choices():
		if str(choice.get("id", "")) == choice_id:
			return bool(choice.get("enabled", false))
	return false

func _enemy_hero_visible(state: Dictionary) -> bool:
	return str(state.get("mode", "")) in [BattleEngine.MODE_DUEL, BattleEngine.MODE_SUMMONER_BOSS]

func _has_enemy_board_area_card_in_hand() -> bool:
	for card_id: String in engine.hand:
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		if str(Dictionary(card.effect).get("action", "")) == "random_damage":
			return true
	return false

func _active_event_sources_slot(owner_id: String, slot_index: int) -> bool:
	return str(active_combat_fx_event.get("source_owner", "")) == owner_id and int(active_combat_fx_event.get("source_slot", -999)) == slot_index

func _active_event_targets_slot(owner_id: String, slot_index: int) -> bool:
	return not bool(active_combat_fx_event.get("target_hero", false)) and str(active_combat_fx_event.get("target_owner", "")) == owner_id and int(active_combat_fx_event.get("target_slot", -999)) == slot_index

func _active_event_targets_hero(owner_id: String) -> bool:
	return bool(active_combat_fx_event.get("target_hero", false)) and str(active_combat_fx_event.get("target_owner", "")) == owner_id

func _play_combat_fx_events(events: Array) -> void:
	combat_fx_queue = []
	for event: Variant in events:
		if typeof(event) == TYPE_DICTIONARY and str(Dictionary(event).get("type", "")) in ["stage", "attack", "damage"]:
			combat_fx_queue.append(Dictionary(event))
	combat_fx_index = 0
	if combat_fx_queue.is_empty() or combat_fx_panel == null:
		active_combat_fx_event = {}
		return
	_advance_combat_fx()

func _advance_combat_fx() -> void:
	if combat_fx_index >= combat_fx_queue.size():
		active_combat_fx_event = {}
		if combat_fx_panel != null:
			combat_fx_panel.visible = false
		_refresh()
		return
	active_combat_fx_event = combat_fx_queue[combat_fx_index]
	combat_fx_index += 1
	if combat_fx_panel != null and combat_fx_label != null:
		combat_fx_label.text = _combat_fx_text(active_combat_fx_event)
		combat_fx_panel.visible = true
	_refresh()
	if combat_fx_timer != null:
		combat_fx_timer.start(0.34)

func _combat_fx_text(event: Dictionary) -> String:
	match str(event.get("type", "")):
		"stage":
			return str(event.get("label", event.get("stage", "Etapa")))
		"attack":
			return "%s -> %s | %d dano" % [str(event.get("source_name", "Criatura")), str(event.get("target_name", "Alvo")), int(event.get("damage", 0))]
		"damage":
			return "%s | dano %d" % [str(event.get("stage", "Combate")), int(event.get("amount", 0))]
	return ""

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
	var body: String = VisualAssets.card_display_text(card, engine.get_card_text_context(card_id))
	var keyword_text: String = _keyword_text(Array(card.keywords))
	if keyword_text != "":
		body += "\n\n%s" % keyword_text
	var state: String = ""
	if not occupant.is_empty():
		var state_parts: Array[String] = []
		var current_attack: int = int(occupant.get("attack", 0))
		var current_health: int = int(occupant.get("health", 0))
		var current_max_health: int = int(occupant.get("max_health", card.health))
		if current_attack != int(card.attack):
			state_parts.append("ATK atual %d (base %d)" % [current_attack, int(card.attack)])
		else:
			state_parts.append("ATK %d" % current_attack)
		if current_health != int(card.health) or current_max_health != int(card.health):
			state_parts.append("HP atual %d/%d (base %d)" % [current_health, current_max_health, int(card.health)])
		else:
			state_parts.append("HP %d/%d" % [current_health, current_max_health])
		var temporary_attack: int = int(occupant.get("temporary_attack_bonus", 0))
		if temporary_attack != 0:
			state_parts.append("Bonus temporario +%d ATK" % temporary_attack)
		if int(occupant.get("slow_turns", 0)) > 0:
			state_parts.append("Lentidao %d" % int(occupant.get("slow_turns", 0)))
		if int(occupant.get("confusion_turns", 0)) > 0:
			state_parts.append("Confusao %d" % int(occupant.get("confusion_turns", 0)))
		if bool(occupant.get("regeneracao", false)):
			state_parts.append("Regeneracao")
		if bool(occupant.get("defensor", false)):
			state_parts.append("Defensor")
		if bool(occupant.get("revive_marker", false)):
			state_parts.append("Revive usado")
		state = " | ".join(state_parts)
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
	if str(data.get("card_id", "")) == "" and bool(data.get("objective", false)):
		return {
			"title": str(data.get("name", "Objetivo de Defesa")),
			"subtitle": "Objetivo de defesa",
			"body": "Proteja este slot ate o objetivo do encontro ser concluido.",
			"state": "ATK %d | HP %d/%d" % [int(data.get("attack", 0)), int(data.get("health", 0)), int(data.get("max_health", data.get("health", 0)))]
		}
	return _card_preview_data(str(data.get("card_id", "")), data)

func _hero_preview_data(owner_id: String, display_name: String, health: int) -> Dictionary:
	return {
		"title": display_name,
		"subtitle": "Heroi %s" % ("aliado" if owner_id == BattleEngine.PLAYER_ID else "inimigo"),
		"body": "Alvo visivel do combate. Criaturas inimigas sem frente nem defensor causam dano ao jogador; herois inimigos recebem dano direto nos modos apropriados.",
		"state": "Vida %d" % health
	}

func _class_passive_preview_data() -> Dictionary:
	if not RunSession.class_passive_unlocked:
		return {}
	return {
		"title": _class_passive_display_name(),
		"subtitle": "Passiva de classe",
		"body": _class_passive_detail_text(),
		"state": "Liberada"
	}

func _class_active_preview_data() -> Dictionary:
	if not RunSession.class_active_unlocked:
		return {}
	return {
		"title": _class_active_display_name(selected_necromancer_choice_id),
		"subtitle": "Spell de classe",
		"body": _class_active_detail_text(selected_necromancer_choice_id),
		"state": "Disponivel" if engine.can_use_class_active() else "Indisponivel neste turno"
	}

func _class_passive_display_name() -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "Fluxo Continuo"
		"invocador":
			return "Comandante de Campo"
		"necromante":
			return "Colheita Sombria"
	return "Passiva"

func _class_passive_detail_text() -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "Cada carta jogada neste turno gera 1 Fluxo. Fluxo aumenta dano direto de spells e da Rajada Arcana ate o inicio do proximo turno."
		"invocador":
			return "Sempre que uma criatura aliada entra em campo, a criatura aliada com maior ATK recebe +1/+0 permanente durante a batalha."
		"necromante":
			return "Sempre que qualquer criatura morre em campo, aliada ou inimiga, ganha 1 Cinza. Cinzas acumulam e alimentam o Ritual das Sombras."
	return ""

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
			"iniciativa":
				parts.append("Iniciativa: causa dano primeiro na lane; se destruir o alvo, nao recebe retorno.")
			"regeneracao":
				parts.append("Regeneracao: recupera 1 HP no inicio do turno do jogador.")
			"defensor":
				parts.append("Defensor: protege lanes vazias, atraindo ataques sem alvo frontal.")
			"reviver":
				parts.append("Reviver: volta uma vez com stats originais no mesmo slot.")
	return "\n".join(parts)

func _hero_display_name(owner_id: String) -> String:
	var catalog = ContentLibrary.get_catalog()
	if owner_id == BattleEngine.PLAYER_ID:
		return RunSession.player_display_name()
	if owner_id == BattleEngine.ENEMY_ID and catalog != null and catalog.enemy_hero != null:
		return str(catalog.enemy_hero.display_name)
	return "Heroi"

func _hud_stat_style(accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.025, 0.032, 0.86)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.88)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8
	style.content_margin_top = 4
	style.content_margin_right = 8
	style.content_margin_bottom = 4
	return style

func _label_chip_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12
	style.content_margin_top = 4
	style.content_margin_right = 12
	style.content_margin_bottom = 4
	return style

func _cardback_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.028, 0.055, 0.94)
	style.border_color = Color(0.62, 0.46, 0.88, 0.92)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

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

func _is_compact_viewport() -> bool:
	return get_viewport_rect().size.y <= 600.0

func _uses_dense_battle_layout() -> bool:
	var max_slots: int = maxi(engine.player_slots.size(), engine.enemy_slots.size())
	var mode: String = str(engine.mode)
	return _is_compact_viewport() \
		or bool(engine.enemy_commander_enabled) \
		or max_slots >= 4 \
		or mode in [BattleEngine.MODE_DUEL, BattleEngine.MODE_SUMMONER_BOSS]

func _battle_outer_margin_x() -> int:
	return 8 if _is_compact_viewport() else 12

func _battle_outer_margin_top() -> int:
	if bool(engine.enemy_commander_enabled):
		return 54 if _is_compact_viewport() else 66
	return 6 if _is_compact_viewport() else 10

func _battle_outer_margin_bottom() -> int:
	return 5 if _is_compact_viewport() else 8

func _enemy_commander_hud_size() -> Vector2:
	return Vector2(390, 52) if _is_compact_viewport() else Vector2(450, 64)

func _apply_enemy_commander_hud_rect(control: Control) -> void:
	var hud_size: Vector2 = _enemy_commander_hud_size()
	control.anchor_left = 0.5
	control.anchor_top = 0.0
	control.anchor_right = 0.5
	control.anchor_bottom = 0.0
	control.offset_left = -hud_size.x * 0.5
	control.offset_top = 5.0 if _is_compact_viewport() else 8.0
	control.offset_right = hud_size.x * 0.5
	control.offset_bottom = control.offset_top + hud_size.y

func _apply_area_target_overlay_rect(control: Control) -> void:
	control.anchor_left = 0.09
	control.anchor_top = 0.05
	control.anchor_right = 0.91
	control.anchor_bottom = 0.52
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0

func _choice_modal_size() -> Vector2:
	return Vector2(380, 340) if _is_compact_viewport() else Vector2(480, 380)

func _apply_centered_modal_rect(control: Control, modal_size: Vector2) -> void:
	control.anchor_left = 0.5
	control.anchor_top = 0.5
	control.anchor_right = 0.5
	control.anchor_bottom = 0.5
	control.offset_left = -modal_size.x * 0.5
	control.offset_top = -modal_size.y * 0.5
	control.offset_right = modal_size.x * 0.5
	control.offset_bottom = modal_size.y * 0.5
	control.custom_minimum_size = modal_size

func _field_card_size() -> Vector2:
	if _is_compact_viewport():
		return Vector2(70, 98) if _uses_dense_battle_layout() else Vector2(76, 108)
	return Vector2(94, 132) if _uses_dense_battle_layout() else Vector2(112, 158)

func _hand_card_size() -> Vector2:
	if _is_compact_viewport():
		return Vector2(82, 122) if _uses_dense_battle_layout() else Vector2(94, 138)
	return Vector2(106, 156) if _uses_dense_battle_layout() else Vector2(126, 188)

func _board_min_height() -> float:
	var card_height: float = _field_card_size().y
	var chrome: float = 34.0 if _is_compact_viewport() else 42.0
	return card_height * 2.0 + _board_center_space() + chrome

func _board_center_space() -> float:
	if _is_compact_viewport():
		return 2.0 if _uses_dense_battle_layout() else 4.0
	return 6.0 if _uses_dense_battle_layout() else 16.0

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
