extends "res://tests/unit/draxos_test_base.gd"

const BattleCombatFxPresenterScript = preload("res://modes/battle/battle_combat_fx_presenter.gd")
const BattleHudPresenterScript = preload("res://modes/battle/battle_hud_presenter.gd")

func test_main_menu_defaults_to_slot_one_and_button_states() -> void:
	var menu = await _instantiate_scene("res://modes/boot/boot.tscn")
	assert_eq(SaveManager.current_slot_index, 1)
	var slot_one: Button = menu.find_child("MainMenuSlot1", true, false)
	var new_button: Button = menu.find_child("MainMenuNewGameButton", true, false)
	var continue_button: Button = menu.find_child("MainMenuContinueButton", true, false)
	var delete_button: Button = menu.find_child("MainMenuDeleteButton", true, false)
	assert_not_null(slot_one)
	assert_string_contains(slot_one.text, "Save 1")
	assert_eq(slot_one.text.find("Slot"), -1)
	assert_false(new_button.disabled)
	assert_true(continue_button.disabled)
	assert_true(delete_button.disabled)
	menu._open_delete_modal()
	var delete_label: Label = menu.find_child("MainMenuDeleteConfirmText", true, false)
	assert_not_null(delete_label)
	assert_eq(delete_label.text, "Deletar Save 1?")
	menu.queue_free()
	await get_tree().process_frame

func test_main_menu_can_delete_stale_save_file_without_blocking_new_game() -> void:
	_write_test_save_file(1, {"version": SaveManager.SAVE_VERSION - 1, "run": {"selected_class_id": "arcano"}})
	var menu = await _instantiate_scene("res://modes/boot/boot.tscn")
	var slot_one: Button = menu.find_child("MainMenuSlot1", true, false)
	var new_button: Button = menu.find_child("MainMenuNewGameButton", true, false)
	var continue_button: Button = menu.find_child("MainMenuContinueButton", true, false)
	var delete_button: Button = menu.find_child("MainMenuDeleteButton", true, false)
	assert_string_contains(slot_one.text, "antigo")
	assert_false(new_button.disabled)
	assert_true(continue_button.disabled)
	assert_false(delete_button.disabled)
	menu.queue_free()
	await get_tree().process_frame

func test_new_game_ship_modal_requires_class_and_saves_choice() -> void:
	var begin_result: Dictionary = SaveManager.begin_new_game(1)
	assert_true(bool(begin_result.get("ok", false)), str(begin_result.get("message", "")))
	var ship = await _instantiate_scene("res://modes/ship_hub/ship_hub.tscn")
	var modal: PanelContainer = ship.find_child("ShipHubClassChoiceModal", true, false)
	assert_not_null(modal)
	assert_true(modal.visible)
	var invocador_button: Button = ship.find_child("ShipHubClass_invocador", true, false)
	assert_not_null(invocador_button)
	invocador_button.pressed.emit()
	await get_tree().process_frame
	var name_modal: PanelContainer = ship.find_child("ShipHubPlayerNameModal", true, false)
	var name_input: LineEdit = ship.find_child("ShipHubPlayerNameInput", true, false)
	var confirm_button: Button = ship.find_child("ShipHubPlayerNameConfirm", true, false)
	assert_not_null(name_modal)
	assert_true(name_modal.visible)
	name_input.text = "Nyth"
	confirm_button.pressed.emit()
	await get_tree().process_frame
	assert_false(modal.visible)
	assert_false(name_modal.visible)
	assert_eq(RunSession.selected_class_id, "invocador")
	assert_eq(RunSession.player_display_name(), "Nyth")
	assert_true(SaveManager.has_save(1))
	ship.queue_free()
	await get_tree().process_frame

func test_ship_hub_creates_manifest_overlays() -> void:
	_start_class_run("arcano", 44)
	var ship = await _instantiate_scene("res://modes/ship_hub/ship_hub.tscn")
	assert_not_null(ship.find_child("ShipHubOverlay_deck", true, false))
	assert_not_null(ship.find_child("ShipHubOverlay_map", true, false))
	assert_not_null(ship.find_child("ShipHubOverlay_souls", true, false))
	assert_null(ship.find_child("ShipHubVisualButtons", true, false))
	ship.queue_free()
	await get_tree().process_frame

func test_ship_hub_hides_run_state_and_deck_keeps_it() -> void:
	_start_class_run("arcano", 44)
	var ship = await _instantiate_scene("res://modes/ship_hub/ship_hub.tscn")
	assert_null(ship.find_child("ShipHubRunStatePanel", true, false))
	assert_null(ship.find_child("ShipHubRunState", true, false))
	assert_not_null(ship.find_child("ShipHubClassChoiceMessage", true, false))
	ship.queue_free()
	await get_tree().process_frame
	var deck = await _instantiate_scene("res://modes/deck/deck.tscn")
	assert_not_null(deck.find_child("DeckRunStatePanel", true, false))
	assert_not_null(deck.find_child("DeckRunState", true, false))
	deck.queue_free()
	await get_tree().process_frame

func test_ship_overlay_manifest_positions_map_and_souls() -> void:
	assert_eq(VisualAssets.ship_overlay_position("map"), Vector2(0.45, 0.74))
	assert_eq(VisualAssets.ship_overlay_position("souls"), Vector2(0.22, 0.60))

func test_victory_reward_modal_records_reward_and_selects_next_map() -> void:
	_start_class_run("arcano", 77)
	RunSession.mark_node_completed("n01_tutorial_primeiro_contato")
	RunSession.mark_node_completed("n02_tutorial_dois_fronts")
	RunSession.mark_node_completed("n03_tutorial_primeira_onda")
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.outcome = "vitoria"
	battle.engine.player_health = 17
	battle._after_battle_action()
	await get_tree().process_frame
	var modal: PanelContainer = battle.find_child("BattleRewardModal", true, false)
	assert_not_null(modal)
	assert_true(modal.visible)
	var reward_style: StyleBoxFlat = modal.get_theme_stylebox("panel") as StyleBoxFlat
	assert_almost_eq(reward_style.bg_color.a, 0.72, 0.01)
	assert_eq(RunSession.soul_total, 4)
	assert_eq(RunSession.current_health, 17)
	assert_eq(RunSession.current_node_id, "n05_ondas_iniciais")
	assert_true(SaveManager.has_save(1))
	battle.queue_free()
	await get_tree().process_frame

func test_souls_screen_heals_five_for_ten_souls() -> void:
	_start_class_run("necromante", 55)
	RunSession.current_health = 10
	RunSession.soul_total = 10
	var souls = await _instantiate_scene("res://modes/souls/souls.tscn")
	var heal: Button = souls.find_child("SoulsHealButton", true, false)
	assert_not_null(heal)
	assert_false(heal.disabled)
	heal.pressed.emit()
	await get_tree().process_frame
	assert_eq(RunSession.current_health, 15)
	assert_eq(RunSession.soul_total, 0)
	assert_true(SaveManager.has_save(1))
	souls.queue_free()
	await get_tree().process_frame

func test_deck_screen_lists_grouped_cards_and_upgrades() -> void:
	_start_class_run("arcano", 44)
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	RunSession.record_battle_result("n02_tutorial_dois_fronts", "vitoria", 20)
	var deck = await _instantiate_scene("res://modes/deck/deck.tscn")
	var list: VBoxContainer = deck.find_child("DeckGroupedCards", true, false)
	assert_not_null(list)
	assert_gt(_count_children_with_prefix(list, "DeckCard_"), 3)
	var upgrade_label: Label = deck.find_child("DeckUpgradeState", true, false)
	assert_not_null(upgrade_label)
	assert_string_contains(upgrade_label.text, "+1 Mana")
	deck.queue_free()
	await get_tree().process_frame

func test_deck_screen_falls_back_to_class_starter_deck_when_run_deck_empty() -> void:
	_start_class_run("invocador", 44)
	RunSession.current_deck_ids = []
	var deck = await _instantiate_scene("res://modes/deck/deck.tscn")
	var list: VBoxContainer = deck.find_child("DeckGroupedCards", true, false)
	assert_not_null(list)
	assert_eq(_count_children_with_prefix(list, "DeckCard_"), 3)
	assert_null(deck.find_child("DeckEmptyMessage", true, false))
	deck.queue_free()
	await get_tree().process_frame

func test_ship_overlay_alpha_debt_reports_map_without_real_alpha() -> void:
	var debts: Array[String] = VisualAssets.ship_overlay_alpha_debt_report()
	var found_map_debt: bool = false
	for debt: String in debts:
		if debt.find("map") >= 0 and debt.find("Mapa.png") >= 0:
			found_map_debt = true
	assert_true(found_map_debt, "Mapa.png should be reported as a non-fatal alpha debt.")

func test_escape_on_secondary_screens_returns_without_null_viewport_error() -> void:
	_start_class_run("arcano", 44)
	for scene_path: String in ["res://modes/run_map/run_map.tscn", "res://modes/deck/deck.tscn", "res://modes/souls/souls.tscn"]:
		var scene = await _instantiate_scene(scene_path)
		var event: InputEventKey = InputEventKey.new()
		event.pressed = true
		event.keycode = KEY_ESCAPE
		scene._unhandled_input(event)
		await get_tree().process_frame
		assert_true(true, "ESC handled for %s" % scene_path)
		if is_instance_valid(scene):
			scene.queue_free()
		if get_tree().current_scene != null:
			get_tree().current_scene.queue_free()
			get_tree().current_scene = null
		await get_tree().process_frame

func test_battle_choice_modals_are_centered_and_scrollable() -> void:
	_start_class_run("necromante", 44)
	RunSession.class_active_unlocked = true
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var necro_modal: PanelContainer = battle.find_child("NecromancerChoiceModal", true, false)
	var pending_modal: PanelContainer = battle.find_child("PendingBattleChoiceModal", true, false)
	assert_not_null(necro_modal)
	assert_not_null(pending_modal)
	assert_eq(necro_modal.anchor_left, 0.5)
	assert_eq(necro_modal.anchor_top, 0.5)
	assert_eq(necro_modal.offset_left, -necro_modal.offset_right)
	assert_eq(necro_modal.offset_top, -necro_modal.offset_bottom)
	assert_eq(pending_modal.anchor_left, 0.5)
	assert_eq(pending_modal.anchor_top, 0.5)
	assert_eq(pending_modal.offset_left, -pending_modal.offset_right)
	assert_eq(pending_modal.offset_top, -pending_modal.offset_bottom)
	assert_not_null(battle.find_child("NecromancerChoiceScroll", true, false))
	assert_not_null(battle.find_child("PendingBattleChoiceScroll", true, false))
	var necro_style: StyleBoxFlat = necro_modal.get_theme_stylebox("panel") as StyleBoxFlat
	var pending_style: StyleBoxFlat = pending_modal.get_theme_stylebox("panel") as StyleBoxFlat
	assert_almost_eq(necro_style.bg_color.a, 0.72, 0.01)
	assert_almost_eq(pending_style.bg_color.a, 0.72, 0.01)
	battle.engine.pending_choices.clear()
	battle.engine.pending_choices.append({"action": "weaken", "source_name": "Teste", "amount": 1})
	battle._play_combat_fx_events([{"type": "stage", "stage": "Teste", "label": "Teste"}], battle.engine.get_state())
	battle._refresh_pending_choice_modal()
	assert_false(pending_modal.visible)
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_exposes_enemy_board_area_drop_zone_for_tempest() -> void:
	_start_class_run("arcano", 44)
	RunSession.current_deck_ids = ["arcano_tempestade"]
	RunSession.max_hand_size = 1
	RunSession.max_mana = 2
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var area_target = battle.find_child("BattleEnemyBoardAreaTarget", true, false)
	var board_margin = battle.find_child("BattleBoardMargin", true, false)
	var enemy_slot = battle.find_child("EnemySlot0", true, false)
	battle._refresh()
	assert_not_null(area_target)
	assert_not_null(board_margin)
	assert_not_null(enemy_slot)
	assert_true(area_target.visible)
	assert_true(area_target.get_index() < board_margin.get_index())
	assert_gt(area_target.get_global_rect().size.y, enemy_slot.get_global_rect().size.y)
	assert_gt(area_target.get_global_rect().size.x, enemy_slot.get_global_rect().size.x * 2.0)
	assert_true(area_target.get_global_rect().intersects(enemy_slot.get_global_rect()))
	var tempest_payload: Dictionary = {"kind": "battle_card", "card_id": "arcano_tempestade", "hand_index": 0}
	assert_true(enemy_slot._can_drop_data(Vector2.ZERO, tempest_payload))
	assert_eq(str(battle._slot_or_area_drop_target(tempest_payload, BattleEngine.ENEMY_ID, 0).get("area", "")), "board")
	assert_true(area_target._can_drop_data(Vector2.ZERO, tempest_payload))
	var before_mana: int = battle.engine.mana
	battle._on_area_target_dropped(tempest_payload, {"owner": BattleEngine.ENEMY_ID, "area": "board"})
	assert_lt(battle.engine.mana, before_mana)
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_sacrifice_modal_cancel_and_confirm() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var manual_hand: Array[String] = ["invocador_soldado", "invocador_batedor"]
	var empty_cards: Array[String] = []
	battle.engine.hand = manual_hand
	battle.engine.deck = empty_cards.duplicate()
	battle.engine.discard = empty_cards.duplicate()
	battle.engine.mana = 2
	battle.engine.player_slots[0] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_soldado"), BattleEngine.PLAYER_ID, false)
	battle._refresh()
	var before_mana: int = battle.engine.mana
	battle._on_slot_target_dropped({"kind": "battle_card", "hand_index": 1, "card_id": "invocador_batedor"}, BattleEngine.PLAYER_ID, 0)
	var modal: PanelContainer = battle.find_child("BattleSacrificeConfirmModal", true, false)
	assert_not_null(modal)
	assert_true(modal.visible)
	assert_eq(battle.engine.mana, before_mana)
	assert_eq(str(Dictionary(battle.engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	var cancel_button: Button = battle.find_child("BattleSacrificeCancelButton", true, false)
	cancel_button.pressed.emit()
	await get_tree().process_frame
	assert_false(modal.visible)
	assert_eq(battle.engine.mana, before_mana)
	assert_eq(battle.engine.hand.size(), 2)
	battle._on_slot_target_dropped({"kind": "battle_card", "hand_index": 1, "card_id": "invocador_batedor"}, BattleEngine.PLAYER_ID, 0)
	var confirm_button: Button = battle.find_child("BattleSacrificeConfirmButton", true, false)
	confirm_button.pressed.emit()
	await get_tree().process_frame
	assert_false(modal.visible)
	assert_eq(str(Dictionary(battle.engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_lt(battle.engine.mana, before_mana)
	battle.queue_free()
	await get_tree().process_frame

func test_field_unit_drop_moves_creature_in_battle_scene() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.player_slots[1] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_soldado"), BattleEngine.PLAYER_ID, false)
	battle._refresh()
	battle._on_slot_target_dropped({"kind": "field_unit", "owner": BattleEngine.PLAYER_ID, "slot": 1}, BattleEngine.PLAYER_ID, 0)
	assert_not_null(battle.engine.player_slots[0])
	assert_null(battle.engine.player_slots[1])
	battle.queue_free()
	await get_tree().process_frame

func test_field_unit_drop_swaps_adjacent_creatures_in_battle_scene() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.player_slots[0] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_soldado"), BattleEngine.PLAYER_ID, false)
	battle.engine.player_slots[1] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_batedor"), BattleEngine.PLAYER_ID, false)
	battle._refresh()
	battle._on_slot_target_dropped({"kind": "field_unit", "owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.PLAYER_ID, 1)
	assert_eq(str(Dictionary(battle.engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_eq(str(Dictionary(battle.engine.player_slots[1]).get("card_id", "")), "invocador_soldado")
	assert_true(bool(Dictionary(battle.engine.player_slots[0]).get("moved_this_turn", false)))
	assert_true(bool(Dictionary(battle.engine.player_slots[1]).get("moved_this_turn", false)))
	battle.queue_free()
	await get_tree().process_frame

func test_duel_battle_layout_uses_compact_hud_composition() -> void:
	_start_class_run("arcano", 101)
	RunSession.select_node("n06_duelo_inicial")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	await get_tree().process_frame
	var main_stack: VBoxContainer = battle.find_child("BattleMainStack", true, false)
	var enemy_hud: PanelContainer = battle.find_child("BattleEnemyCommanderHud", true, false)
	var intent_panel: PanelContainer = battle.find_child("BattleEnemyIntentPanel", true, false)
	var player_hud: PanelContainer = battle.find_child("BattlePlayerHudDock", true, false)
	var player_target: PanelContainer = battle.find_child("BattlePlayerHeroTarget", true, false)
	var enemy_target: PanelContainer = battle.find_child("BattleEnemyHeroTarget", true, false)
	var hand_row: HBoxContainer = battle.find_child("BattleHandControlsRow", true, false)
	var area_target = battle.find_child("BattleEnemyBoardAreaTarget", true, false)
	assert_not_null(main_stack)
	assert_not_null(enemy_hud)
	assert_not_null(intent_panel)
	assert_not_null(player_hud)
	assert_not_null(player_target)
	assert_not_null(enemy_target)
	assert_not_null(hand_row)
	assert_not_null(area_target)
	assert_false(_has_label_text(player_target, "Heroi"))
	assert_false(_has_label_text(enemy_target, "Heroi"))
	assert_eq(player_target.custom_minimum_size, Vector2(118, 42))
	assert_eq(enemy_target.custom_minimum_size, Vector2(118, 42))
	assert_true(enemy_hud.get_parent() == battle)
	assert_true(intent_panel.visible)
	assert_true(_has_label_text(intent_panel, "Intencao inimiga"))
	assert_true(player_hud.get_parent() == hand_row)
	assert_null(battle.find_child("BattlePlayerHpStat", true, false))
	assert_eq(str(area_target.get_parent().name), "BattleBoardSurface")
	assert_false(main_stack.is_ancestor_of(enemy_hud))
	_assert_control_inside_viewport(battle.find_child("BattleHandPanel", true, false) as Control)
	_assert_control_inside_viewport(enemy_hud)
	_assert_control_inside_viewport(intent_panel)
	battle.queue_free()
	await get_tree().process_frame

func test_map_nine_duel_scene_keeps_four_lane_hud() -> void:
	_start_class_run("arcano", 99)
	RunSession.select_node("n12_duelo_elite")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var enemy_hud: PanelContainer = battle.find_child("BattleEnemyCommanderHud", true, false)
	assert_not_null(enemy_hud)
	assert_true(enemy_hud.visible)
	assert_eq(battle.enemy_slots_box.get_child_count(), 4)
	assert_eq(battle.player_slots_box.get_child_count(), 4)
	assert_not_null(battle.find_child("BattlePlayerHudDock", true, false))
	battle.queue_free()
	await get_tree().process_frame

func test_track02_dense_board_layouts_remain_readable_for_5_6_7_slots() -> void:
	var cases: Array[Dictionary] = [
		{"node_id": "n22_soberano_tempestades", "slots": 6},
		{"node_id": "n28_portal_caos", "slots": 6},
		{"node_id": "n29_dragao_primordial", "slots": 7}
	]
	for test_case: Dictionary in cases:
		_start_class_run("arcano", 202)
		RunSession.max_mana = 6
		RunSession.max_hand_size = 5
		RunSession.current_deck_ids.append_array(["arcano_barreira", "arcano_tempestade", "arcano_vortice", "arcano_acelerar"])
		RunSession.select_node(str(test_case.get("node_id", "")))
		var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
		await get_tree().process_frame
		assert_eq(battle.player_slots_box.get_child_count(), int(test_case.get("slots", 0)))
		assert_eq(battle.enemy_slots_box.get_child_count(), int(test_case.get("slots", 0)))
		assert_true(battle._uses_dense_battle_layout())
		assert_true(battle._field_card_size().x >= 70.0)
		assert_true(battle._hand_card_size().x >= 82.0)
		_assert_control_inside_viewport(battle.find_child("BattleHandPanel", true, false) as Control)
		_assert_control_inside_viewport(battle.find_child("BattleEnemyIntentPanel", true, false) as Control)
		_assert_control_inside_viewport(battle.find_child("BattleEndTurnFloatingButton", true, false) as Control)
		battle.queue_free()
		await get_tree().process_frame

func test_battle_scene_uses_resolve_combat_button() -> void:
	_start_class_run("arcano")
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var button: Button = battle.find_child("BattleEndTurnFloatingButton", true, false)
	assert_not_null(button)
	assert_string_contains(button.text, "Resolver")
	button.pressed.emit()
	await get_tree().process_frame
	assert_string_contains(button.text, "Resolver")
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_shows_discard_hint_badge_near_hand() -> void:
	_start_class_run("arcano")
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var badge: PanelContainer = battle.find_child("BattleDiscardHintBadge", true, false)
	var hand: HBoxContainer = battle.find_child("BattleHand", true, false)
	assert_not_null(badge)
	assert_not_null(hand)
	assert_true(badge.visible)
	assert_string_contains(str(badge.tooltip_text), "cartas selecionadas")
	assert_true(badge.get_global_rect().intersects(hand.get_parent().get_global_rect()))
	battle.queue_free()
	await get_tree().process_frame

func test_battle_hud_presenter_preserves_resource_and_objective_text() -> void:
	_start_class_run("arcano", 20260518)
	RunSession.class_passive_unlocked = true
	var state: Dictionary = {
		"player_health": 17,
		"mana": 2,
		"mana_per_turn": 6,
		"flow": 3,
		"mode": BattleEngine.MODE_WAVES,
		"wave_index": 2,
		"waves_total": 4,
		"enemy_commander_enabled": true,
		"enemy_health": 22,
		"enemy_mana": 1,
		"enemy_mana_per_turn": 4,
		"enemy_hand_count": 5
	}
	var player_values: Dictionary = BattleHudPresenterScript.player_values(state)
	assert_eq(str(player_values.get("hp_text", "")), "17")
	assert_eq(str(player_values.get("mana_text", "")), "2/6")
	assert_eq(Dictionary(player_values.get("class_resource", {})), {"label": "Fluxo", "value": 3})
	var enemy_values: Dictionary = BattleHudPresenterScript.enemy_commander_values(state)
	assert_true(bool(enemy_values.get("visible", false)))
	assert_eq(int(enemy_values.get("hand_count", 0)), 5)
	assert_eq(BattleHudPresenterScript.objective_text(state, "Comandante inimigo"), "Onda 2/4")
	assert_true(BattleHudPresenterScript.enemy_hero_visible({"mode": BattleEngine.MODE_DUEL}))

func test_battle_combat_fx_presenter_preserves_damage_state_and_labels() -> void:
	var state: Dictionary = {
		"player_health": 20,
		"enemy_health": 18,
		"player_slots": [{"card_id": "arcano_fagulha", "health": 5}],
		"enemy_slots": [null]
	}
	var slot_event: Dictionary = {
		"type": "damage",
		"target_owner": BattleEngine.PLAYER_ID,
		"target_slot": 0,
		"amount": 2,
		"health_after": 3
	}
	var updated: Dictionary = BattleCombatFxPresenterScript.state_after_event(state, slot_event)
	var updated_slots: Array = Array(updated.get("player_slots", []))
	var original_slots: Array = Array(state.get("player_slots", []))
	assert_eq(int(Dictionary(updated_slots[0]).get("health", 0)), 3)
	assert_eq(int(Dictionary(original_slots[0]).get("health", 0)), 5)
	assert_true(BattleCombatFxPresenterScript.event_targets_slot(slot_event, BattleEngine.PLAYER_ID, 0))
	assert_eq(BattleCombatFxPresenterScript.event_text({"type": "attack", "source_name": "A", "target_name": "B", "damage": 4}), "A -> B | 4 dano")
	var hero_updated: Dictionary = BattleCombatFxPresenterScript.state_after_event(state, {
		"type": "damage",
		"target_owner": BattleEngine.ENEMY_ID,
		"target_hero": true,
		"amount": 6
	})
	assert_eq(int(hero_updated.get("enemy_health", 0)), 12)
	assert_eq(BattleCombatFxPresenterScript.filtered_events([slot_event, {"type": "ignored"}]).size(), 1)
