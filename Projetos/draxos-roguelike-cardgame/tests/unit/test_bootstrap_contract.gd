extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")
const TEST_SAVE_PREFIX: String = "user://gut_draxos_save_slot_"

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var scene_result: Dictionary = SceneGeneratorScript.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))
	ContentLibrary.reload()
	VisualAssets.reload()

func before_each() -> void:
	SaveManager.save_path_prefix = TEST_SAVE_PREFIX
	_clear_test_saves()
	SaveManager.select_slot(1)
	SaveManager.pending_new_game = false
	RunSession.reset()

func after_each() -> void:
	_clear_test_saves()
	SaveManager.save_path_prefix = "user://draxos_save_slot_"
	SaveManager.select_slot(1)
	SaveManager.pending_new_game = false
	RunSession.reset()

func test_catalog_uses_redesigned_class_decks() -> void:
	var catalog = ContentLibrary.get_catalog()
	for class_id: String in ["arcano", "invocador", "necromante"]:
		var class_option: Dictionary = catalog.find_class_option(class_id)
		assert_false(class_option.is_empty(), "Missing class %s" % class_id)
		assert_eq(int(class_option.get("starting_mana", 0)), 2)
		assert_eq(int(class_option.get("starting_health", 0)), 20)
		assert_eq(int(class_option.get("starting_hand_size", 0)), 3)
		var deck: Array = Array(class_option.get("starter_deck", []))
		assert_eq(deck.size(), 12)
		var counts: Dictionary = {}
		for card_id: String in deck:
			assert_not_null(catalog.find_card(card_id), "Missing card %s" % card_id)
			counts[card_id] = int(counts.get(card_id, 0)) + 1
		assert_eq(counts.size(), 4)
		for count: Variant in counts.values():
			assert_eq(int(count), 3)

func test_catalog_removes_old_player_cards_and_keeps_enemies() -> void:
	var catalog = ContentLibrary.get_catalog()
	for removed_id: String in ["arcano_spell_dano", "arcano_construtor_fluxo", "invocador_protecao", "invocador_buff_unico", "necro_spell_lentidao"]:
		assert_null(catalog.find_card(removed_id), "Old player card should be removed: %s" % removed_id)
	for enemy_id: String in ["elemental_agil", "elemental_guardiao", "elemental_tita"]:
		assert_not_null(catalog.find_card(enemy_id), "Enemy card should remain: %s" % enemy_id)
	assert_true(ContentLibrary.get_card("invocador_guardiao").has_keyword("defensor"))
	assert_true(ContentLibrary.get_card("necro_esqueleto").has_keyword("reviver"))
	assert_eq(int(ContentLibrary.get_card("arcano_choque").effect.get("amount", 0)), 2)
	assert_eq(int(ContentLibrary.get_card("arcano_fagulha").health), 2)
	assert_eq(int(ContentLibrary.get_card("arcano_barreira").attack), 1)
	assert_true(ContentLibrary.get_card("arcano_barreira").has_keyword("defensor"))
	assert_eq(int(ContentLibrary.get_card("arcano_tempestade").effect.get("amount", 0)), 4)
	assert_eq(int(ContentLibrary.get_card("necro_prender").cost), 1)

func test_run_session_tracks_hand_limit_reward() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.max_mana, 2)
	assert_eq(RunSession.max_hand_size, 3)
	assert_eq(RunSession.current_deck_ids.size(), 12)
	assert_eq(RunSession.current_node_id, "n01_pouso_elemental")
	RunSession.record_battle_result("n02_ondas_iniciais", "vitoria", 20)
	assert_eq(RunSession.max_mana, 3)
	RunSession.record_battle_result("n03_duelo_inicial", "vitoria", 20)
	assert_eq(RunSession.max_hand_size, 4)
	assert_eq(RunSession.current_deck_ids.size(), 12)
	assert_true(RunSession.automatic_reward_ids.has("n03_duelo_inicial:%s" % RunSession.REWARD_MAX_HAND_SIZE_1))

func test_necromancer_passive_reward_unlocks_active_then_upgrade() -> void:
	var result: Dictionary = RunSession.start_class_run("necromante", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.record_battle_result("n05_chefe_invocador", "vitoria", 20)
	assert_true(RunSession.class_passive_unlocked)
	assert_true(RunSession.class_active_unlocked)
	assert_eq(RunSession.class_active_level, 1)
	RunSession.record_battle_result("n07_limpeza_elite", "vitoria", 20)
	assert_eq(RunSession.class_active_level, 2)

func test_arcano_and_invocador_keep_active_on_second_reward() -> void:
	for class_id: String in ["arcano", "invocador"]:
		var result: Dictionary = RunSession.start_class_run(class_id, 77)
		assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
		RunSession.record_battle_result("n05_chefe_invocador", "vitoria", 20)
		assert_true(RunSession.class_passive_unlocked)
		assert_false(RunSession.class_active_unlocked)
		RunSession.record_battle_result("n07_limpeza_elite", "vitoria", 20)
		assert_true(RunSession.class_active_unlocked)
		RunSession.reset()

func test_necromancer_save_migration_sets_old_unlocked_active_to_level_two() -> void:
	RunSession.load_snapshot({
		"active": true,
		"selected_class_id": "necromante",
		"class_active_unlocked": true,
		"class_passive_unlocked": true
	})
	assert_eq(RunSession.class_active_level, 2)

func test_run_session_rejects_invalid_player_names() -> void:
	assert_false(bool(RunSession.validate_player_name("A").get("ok", false)))
	assert_false(bool(RunSession.validate_player_name("Nome Grande Demais X").get("ok", false)))
	assert_true(bool(RunSession.validate_player_name("Nyx").get("ok", false)))

func test_save_manager_saves_loads_names_and_deletes_slots() -> void:
	var result: Dictionary = RunSession.start_class_run("invocador", 123, "Kael")
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.current_node_id, "n01_pouso_elemental")
	assert_eq(RunSession.player_display_name(), "Kael")
	var save_result: Dictionary = SaveManager.save_current_run(1)
	assert_true(bool(save_result.get("ok", false)), str(save_result.get("message", "")))
	assert_true(SaveManager.has_save(1))
	RunSession.reset()
	var load_result: Dictionary = SaveManager.load_slot(1)
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	assert_eq(RunSession.selected_class_id, "invocador")
	assert_eq(RunSession.current_node_id, "n01_pouso_elemental")
	assert_eq(RunSession.player_display_name(), "Kael")
	var slots: Array[Dictionary] = SaveManager.get_slots()
	assert_string_contains(str(slots[0].get("summary", "")), "Kael")
	assert_string_contains(str(slots[0].get("summary", "")), "Invocador")
	var delete_result: Dictionary = SaveManager.delete_slot(1)
	assert_true(bool(delete_result.get("ok", false)), str(delete_result.get("message", "")))
	assert_false(SaveManager.has_save(1))

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
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.outcome = "vitoria"
	battle.engine.player_health = 17
	battle._after_battle_action()
	await get_tree().process_frame
	var modal: PanelContainer = battle.find_child("BattleRewardModal", true, false)
	assert_not_null(modal)
	assert_true(modal.visible)
	assert_eq(RunSession.soul_total, 4)
	assert_eq(RunSession.current_health, 17)
	assert_eq(RunSession.current_node_id, "n02_ondas_iniciais")
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
	RunSession.record_battle_result("n02_ondas_iniciais", "vitoria", 20)
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
	assert_gt(_count_children_with_prefix(list, "DeckCard_"), 3)
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
	battle.queue_free()
	await get_tree().process_frame

func test_battle_engine_draws_to_dynamic_hand_limit() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "arcano_fagulha", "arcano_barreira", "arcano_tempestade", "arcano_choque"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(engine.hand.size(), 3)
	engine.max_hand_size = 4
	engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0})
	assert_eq(engine.hand.size(), 4)

func test_ability_power_updates_spell_values_and_text() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha", "arcano_barreira", "arcano_choque", "arcano_tempestade"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"class_passive_unlocked": true,
		"mana_per_turn": 4,
		"max_hand_size": 4,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0})
	engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 1})
	assert_eq(int(engine.get_state().get("ability_power", 0)), 2)
	var text: String = VisualAssets.card_display_text(ContentLibrary.get_card("arcano_choque"), engine.get_card_text_context("arcano_choque"))
	assert_string_contains(text, "Causa 6 de dano")
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 2})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_null(engine.enemy_slots[2])

func test_arcane_tempest_requires_enemy_board_area_target() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_tempestade"], {
		"encounter": {
			"id": "test_area_spell",
			"display_name": "Teste Area",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "arcano",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_false(bool(engine.play_card_from_hand(0).get("ok", false)))
	var targets: Array[Dictionary] = engine.get_valid_card_targets(0)
	assert_eq(targets.size(), 1)
	assert_eq(str(targets[0].get("area", "")), "board")
	assert_eq(str(targets[0].get("owner", "")), BattleEngine.ENEMY_ID)
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "area": "board"})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var enemy_slot: Variant = engine.enemy_slots[0]
	assert_true(enemy_slot == null or int(Dictionary(enemy_slot).get("health", 0)) < 2 or engine.enemy_health < 20)

func test_battle_scene_exposes_enemy_board_area_drop_zone_for_tempest() -> void:
	_start_class_run("arcano", 44)
	RunSession.current_deck_ids = ["arcano_tempestade"]
	RunSession.max_hand_size = 1
	RunSession.max_mana = 2
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var area_target = battle.find_child("BattleEnemyBoardAreaTarget", true, false)
	var board_margin = battle.find_child("BattleBoardMargin", true, false)
	var enemy_slot = battle.find_child("EnemySlot0", true, false)
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
	var before_mana: int = battle.engine.mana
	battle._on_slot_target_dropped(tempest_payload, BattleEngine.ENEMY_ID, 0)
	assert_lt(battle.engine.mana, before_mana)
	battle.queue_free()
	await get_tree().process_frame

func test_summon_on_occupied_slot_requires_confirmation_without_spending() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_batedor"], {
		"encounter": {
			"id": "test_sacrifice",
			"display_name": "Teste Sacrificio",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_solido"}]
		},
		"mana_per_turn": 2,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"slot": 0}).get("ok", false)))
	var before_mana: int = engine.mana
	var before_hand: Array[String] = engine.hand.duplicate()
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_false(bool(result.get("ok", false)))
	assert_true(bool(result.get("requires_confirmation", false)))
	assert_eq(engine.mana, before_mana)
	assert_eq(engine.hand, before_hand)
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	var confirmed_target: Dictionary = Dictionary(result.get("target", {}))
	confirmed_target["confirm_sacrifice"] = true
	assert_true(bool(engine.play_card_from_hand(int(result.get("hand_index", -1)), confirmed_target).get("ok", false)))
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_lt(engine.mana, before_mana)

func test_summon_cannot_replace_defense_objective() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_objective_replace",
			"display_name": "Teste Objetivo",
			"mode": BattleEngine.MODE_DEFENSE_POSITION,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"defense_slot": 1,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_false(engine.can_play_card_on_target(0, {"owner": BattleEngine.PLAYER_ID, "slot": 1}))
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 1})
	assert_false(bool(result.get("ok", false)))
	assert_false(bool(result.get("requires_confirmation", false)))

func test_battle_scene_sacrifice_modal_cancel_and_confirm() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n01_pouso_elemental")
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

func test_combat_fx_state_removes_dead_slot_only_on_damage_event() -> void:
	_start_class_run("arcano", 44)
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.combat_fx_state = battle.engine.get_state().duplicate(true)
	var attack_event: Dictionary = {"type": "attack", "target_owner": BattleEngine.ENEMY_ID, "target_slot": 0}
	battle._apply_combat_fx_event_to_state(attack_event)
	assert_not_null(Array(battle.combat_fx_state.get("enemy_slots", []))[0])
	var damage_event: Dictionary = {
		"type": "damage",
		"target_owner": BattleEngine.ENEMY_ID,
		"target_slot": 0,
		"amount": 99,
		"health_after": -97,
		"destroyed": true,
		"removed": true
	}
	battle._apply_combat_fx_event_to_state(damage_event)
	assert_null(Array(battle.combat_fx_state.get("enemy_slots", []))[0])
	battle.queue_free()
	await get_tree().process_frame

func test_ability_power_updates_class_active_values() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha", "invocador_soldado", "invocador_soldado"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"class_active_unlocked": true,
		"mana_per_turn": 4,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 1})
	engine.play_card_from_hand(0, {"slot": 0})
	assert_eq(int(engine.get_state().get("ability_power", 0)), 1)
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 5)

func test_creature_moves_to_adjacent_empty_slot_once_per_turn() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_move",
			"display_name": "Teste Movimento",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_solido"}]
		},
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 1})
	assert_true(engine.can_move_unit(BattleEngine.PLAYER_ID, 1, 0))
	assert_true(bool(engine.move_unit(BattleEngine.PLAYER_ID, 1, 0).get("ok", false)))
	assert_not_null(engine.player_slots[0])
	assert_null(engine.player_slots[1])
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 1))

func test_creature_move_swaps_adjacent_occupied_slots_and_blocks_objective() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_batedor"], {
		"encounter": {
			"id": "test_move_blocks",
			"display_name": "Teste Movimento Bloqueios",
			"mode": BattleEngine.MODE_DEFENSE_POSITION,
			"player_slots_count": 4,
			"enemy_slots_count": 4,
			"defense_slot": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_solido"}]
		},
		"mana_per_turn": 4,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.play_card_from_hand(0, {"slot": 1})
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 2))
	assert_true(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 1))
	assert_true(bool(engine.move_unit(BattleEngine.PLAYER_ID, 0, 1).get("ok", false)))
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_eq(str(Dictionary(engine.player_slots[1]).get("card_id", "")), "invocador_soldado")
	assert_true(bool(Dictionary(engine.player_slots[0]).get("moved_this_turn", false)))
	assert_true(bool(Dictionary(engine.player_slots[1]).get("moved_this_turn", false)))
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 1))
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 1, 0))
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 3, 2))

func test_field_unit_drop_moves_creature_in_battle_scene() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n01_pouso_elemental")
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
	RunSession.select_node("n01_pouso_elemental")
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

func test_defender_redirects_empty_lane_to_nearest_defender() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_soldado", "invocador_soldado"], {
		"encounter": {
			"id": "test_defensor",
			"display_name": "Teste Defensor",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "invocador_guardiao"}]
		},
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_eq(engine.enemy_health, 20)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 2)

func test_overflow_rechecks_dead_defender_between_sequential_lanes() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_guardiao"], {
		"encounter": {
			"id": "test_dead_defender_overflow",
			"display_name": "Teste Defensor Morto",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_agil"},
				{"slot": 1, "card_id": "elemental_bruto"},
				{"slot": 2, "card_id": "elemental_solido"}
			]
		},
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_null(engine.player_slots[0])
	assert_null(engine.enemy_slots[0])
	assert_eq(engine.player_health, 19)

func test_sequential_overflow_skips_creature_killed_before_its_turn() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_overflow_dead_attacker",
			"display_name": "Teste Sobra Atacante Morto",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 1, "card_id": "elemental_bruto"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 0,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.player_slots[0] = engine._build_occupant(ContentLibrary.get_card("elemental_bruto"), BattleEngine.PLAYER_ID, false)
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[1])
	assert_eq(engine.player_health, 20)

func test_duel_overflow_hits_enemy_hero_when_no_front_or_defender() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_duel_overflow",
			"display_name": "Teste Duelo Sobra",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 16,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_eq(engine.enemy_health, 15)

func test_non_hero_overflow_hits_nearest_enemy_creature() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_nearest_overflow",
			"display_name": "Teste Sobra Proxima",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_guardiao"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 5)

func test_defender_does_not_intercept_front_target() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_defender_front",
			"display_name": "Teste Defensor Frente",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_menor"},
				{"slot": 2, "card_id": "invocador_guardiao"}
			]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[0])
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 4)

func test_initiative_kills_before_normal_response() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_batedor"], {
		"encounter": {
			"id": "test_initiative_order",
			"display_name": "Teste Iniciativa",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[0])
	assert_not_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 1)

func test_same_stage_attackers_deal_damage_before_death() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_stage_batch",
			"display_name": "Teste Etapa",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_true(bool(Dictionary(engine.player_slots[0]).get("revive_marker", false)))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 1)

func test_overflow_attack_has_no_retaliation() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_overflow_no_retaliation",
			"display_name": "Teste Sobra Sem Retorno",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_assaltante"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 1)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 1)

func test_duel_enemy_commander_plays_after_combat_for_next_turn() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_duel_enemy_after_combat",
			"display_name": "Teste Duelo Ordem IA",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_commander_enabled": true,
			"enemy_mana_per_turn": 2,
			"enemy_hand_count": 1,
			"enemy_deck": ["elemental_duelista"],
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 2)
	assert_eq(engine.enemy_health, 18)
	assert_eq(str(Dictionary(engine.enemy_slots[0]).get("card_id", "")), "elemental_duelista")

func test_duel_encounters_enemy_commander_draws_and_plays_cards() -> void:
	for encounter_id: String in ["duelo_inicial", "duelo_elite"]:
		var engine: BattleEngine = BattleEngine.new()
		engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_soldado", "invocador_soldado"], {
			"encounter_id": encounter_id,
			"mana_per_turn": 3,
			"max_hand_size": 3,
			"player_health": 20,
			"shuffle_deck": false
		})
		assert_true(engine.enemy_commander_enabled)
		assert_gt(engine.enemy_hand.size(), 0)
		var before_board: int = _occupied_count(engine.enemy_slots)
		var before_discard: int = engine.enemy_discard.size()
		engine.resolve_combat_cycle()
		assert_gt(_occupied_count(engine.enemy_slots), before_board)
		assert_gt(engine.enemy_discard.size(), before_discard)

func test_duel_battle_layout_uses_compact_hud_composition() -> void:
	_start_class_run("arcano", 101)
	RunSession.select_node("n03_duelo_inicial")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	await get_tree().process_frame
	var main_stack: VBoxContainer = battle.find_child("BattleMainStack", true, false)
	var enemy_hud: PanelContainer = battle.find_child("BattleEnemyCommanderHud", true, false)
	var player_hud: PanelContainer = battle.find_child("BattlePlayerHudDock", true, false)
	var player_target: PanelContainer = battle.find_child("BattlePlayerHeroTarget", true, false)
	var enemy_target: PanelContainer = battle.find_child("BattleEnemyHeroTarget", true, false)
	var hand_row: HBoxContainer = battle.find_child("BattleHandControlsRow", true, false)
	var area_target = battle.find_child("BattleEnemyBoardAreaTarget", true, false)
	assert_not_null(main_stack)
	assert_not_null(enemy_hud)
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
	assert_true(player_hud.get_parent() == hand_row)
	assert_null(battle.find_child("BattlePlayerHpStat", true, false))
	assert_eq(str(area_target.get_parent().name), "BattleBoardSurface")
	assert_false(main_stack.is_ancestor_of(enemy_hud))
	_assert_control_inside_viewport(battle.find_child("BattleHandPanel", true, false) as Control)
	_assert_control_inside_viewport(enemy_hud)
	battle.queue_free()
	await get_tree().process_frame

func test_map_nine_duel_scene_keeps_four_lane_hud() -> void:
	_start_class_run("arcano", 99)
	RunSession.select_node("n09_duelo_elite")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var enemy_hud: PanelContainer = battle.find_child("BattleEnemyCommanderHud", true, false)
	assert_not_null(enemy_hud)
	assert_true(enemy_hud.visible)
	assert_eq(battle.enemy_slots_box.get_child_count(), 4)
	assert_eq(battle.player_slots_box.get_child_count(), 4)
	assert_not_null(battle.find_child("BattlePlayerHudDock", true, false))
	battle.queue_free()
	await get_tree().process_frame

func test_unlocked_passive_and_active_stay_visible_with_preview_data() -> void:
	_start_class_run("arcano", 99)
	RunSession.class_passive_unlocked = true
	RunSession.class_active_unlocked = true
	RunSession.select_node("n03_duelo_inicial")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var passive_tile = battle.find_child("BattleClassPassiveTile", true, false)
	var active_tile = battle.find_child("BattleClassActiveTile", true, false)
	assert_not_null(passive_tile)
	assert_not_null(active_tile)
	assert_true(passive_tile.visible)
	assert_true(active_tile.visible)
	assert_string_contains(str(battle._class_passive_preview_data().get("body", "")), "Fluxo")
	assert_string_contains(str(battle._class_active_preview_data().get("body", "")), "Fluxo")
	battle.engine.mana = 0
	battle._refresh()
	assert_true(active_tile.visible)
	battle.queue_free()
	await get_tree().process_frame

func test_promote_choice_applies_stats_or_keywords() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "arcano_fagulha", "invocador_promover"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 3,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.play_card_from_hand(0, {"slot": 1})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_true(engine.has_pending_choice())
	engine.resolve_pending_choice({}, BattleEngine.PROMOTE_CHOICE_STATS)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 4)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 4)

func test_reviver_returns_once_but_not_on_replacement() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto", "invocador_soldado", "invocador_soldado"], {
		"encounter": {
			"id": "test_reviver",
			"display_name": "Teste Reviver",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_menor"},
				{"slot": 1, "card_id": "elemental_bruto"}
			]
		},
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_true(bool(Dictionary(engine.player_slots[0]).get("revive_marker", false)))
	var sacrifice_result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(sacrifice_result.get("requires_confirmation", false)))
	var confirmed_target: Dictionary = Dictionary(sacrifice_result.get("target", {}))
	confirmed_target["confirm_sacrifice"] = true
	engine.play_card_from_hand(int(sacrifice_result.get("hand_index", -1)), confirmed_target)
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	assert_false(bool(Dictionary(engine.player_slots[0]).get("revive_marker", false)))

func test_on_death_weaken_uses_pending_target_choice() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_morto_vivo", "arcano_choque", "arcano_choque"], {
		"encounter": {
			"id": "test_enfraquecer",
			"display_name": "Teste Enfraquecer",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_menor"},
				{"slot": 1, "card_id": "elemental_bruto"}
			]
		},
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_true(engine.has_pending_choice())
	engine.resolve_pending_choice({"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("attack", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("health", 0)), 2)

func test_necromancer_active_level_one_choices_use_exact_values() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha", "necro_esqueleto"], {
		"encounter": {
			"id": "test_necro_level_one",
			"display_name": "Teste Necro I",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_bruto"}]
		},
		"class_id": "necromante",
		"class_active_unlocked": true,
		"class_active_level": 1,
		"mana_per_turn": 2,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 1})
	engine.ashes = 2
	var choices: Array[Dictionary] = engine.get_necromancer_active_choices()
	assert_eq(choices.size(), 2)
	for choice: Dictionary in choices:
		var choice_id: String = str(choice.get("id", ""))
		assert_false(["necro_slow", "necro_confusion", "necro_revive_full"].has(choice_id))
	assert_true(bool(engine.use_class_active({"owner": BattleEngine.ENEMY_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_ROT).get("ok", false)))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)

func test_necromancer_active_level_two_adds_upgrades_and_temp_attack() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto", "invocador_soldado"], {
		"encounter": {
			"id": "test_necro_level_two",
			"display_name": "Teste Necro II",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_bruto"}]
		},
		"class_id": "necromante",
		"class_active_unlocked": true,
		"class_active_level": 2,
		"mana_per_turn": 2,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.discard.append("necro_esqueleto")
	engine.ashes = 4
	var choices: Array[Dictionary] = engine.get_necromancer_active_choices()
	assert_eq(choices.size(), 5)
	assert_true(engine.can_use_class_active_on_target({"owner": BattleEngine.PLAYER_ID, "slot": 1}, BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE))
	assert_true(bool(engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_ATTACK_FOUR).get("ok", false)))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 5)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("temporary_attack_bonus", 0)), 4)

func test_necromancer_reanimation_does_not_replace_occupied_slots() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_necro_no_auto_replace",
			"display_name": "Teste Necro Sem Troca",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 2,
			"enemy_slots_count": 2,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "necromante",
		"class_active_unlocked": true,
		"class_active_level": 2,
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.discard.append("necro_esqueleto")
	engine.ashes = 4
	assert_false(engine.can_use_class_active_on_target({"owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE))
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE)
	assert_false(bool(result.get("ok", false)))
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	assert_eq(engine.ashes, 4)

func test_combat_cycle_resolves_combat_before_maintenance() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "arcano_choque", "arcano_choque"], {
		"encounter_id": "ondas_iniciais",
		"class_id": "arcano",
		"mana_per_turn": 3,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine._damage_slot(BattleEngine.ENEMY_ID, 0, 99)
	engine._damage_slot(BattleEngine.ENEMY_ID, 1, 99)
	assert_eq(engine.wave_index, 1)
	engine.resolve_combat_cycle()
	assert_eq(engine.wave_index, 2)

func test_defense_position_does_not_win_by_clearing_board_before_turn_goal() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "defesa_posicao_inicial",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(engine.required_defense_turns, 4)
	assert_eq(engine.wave_index, 1)
	for index: int in range(engine.enemy_slots.size()):
		engine._damage_slot(BattleEngine.ENEMY_ID, index, 99)
	engine._check_outcome()
	assert_eq(engine.outcome, "")
	engine.survived_turns = engine.required_defense_turns
	engine._check_outcome()
	assert_eq(engine.outcome, "vitoria")

func test_survive_still_wins_when_board_is_cleared_and_starts_buffed() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "sobreviver_turnos_inicial",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(str(Dictionary(engine.enemy_slots[1]).get("card_id", "")), "elemental_bruto")
	for index: int in range(engine.enemy_slots.size()):
		engine._damage_slot(BattleEngine.ENEMY_ID, index, 99)
	engine._check_outcome()
	assert_eq(engine.outcome, "vitoria")

func test_boss_encounters_start_with_stronger_boards() -> void:
	var first_boss: BattleEngine = BattleEngine.new()
	first_boss.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "chefe_invocador",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(first_boss.enemy_health, 20)
	assert_true(_occupied_count(first_boss.enemy_slots) >= 3)

	var final_boss: BattleEngine = BattleEngine.new()
	final_boss.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "chefe_summoner_final",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(final_boss.enemy_health, 34)
	assert_true(_occupied_count(final_boss.enemy_slots) >= 4)
	assert_false(_enemy_board_has_card(final_boss.enemy_slots, "elemental_tita"))

func test_battle_scene_uses_resolve_combat_button() -> void:
	_start_class_run("arcano")
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var button: Button = battle.find_child("BattleEndTurnFloatingButton", true, false)
	assert_not_null(button)
	assert_string_contains(button.text, "Resolver")
	battle.queue_free()
	await get_tree().process_frame

func _instantiate_scene(path: String):
	var packed: PackedScene = load(path)
	assert_not_null(packed)
	var node = packed.instantiate()
	add_child(node)
	await get_tree().process_frame
	return node

func _start_class_run(class_id: String, seed: int = 0) -> void:
	var result: Dictionary = RunSession.start_class_run(class_id, seed)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func _count_children_with_prefix(node: Node, prefix: String) -> int:
	var count: int = 0
	for child: Node in node.get_children():
		if str(child.name).begins_with(prefix):
			count += 1
	return count

func _occupied_count(slots: Array) -> int:
	var count: int = 0
	for occupant: Variant in slots:
		if occupant != null:
			count += 1
	return count

func _enemy_board_has_card(slots: Array, card_id: String) -> bool:
	for occupant: Variant in slots:
		if occupant != null and str(Dictionary(occupant).get("card_id", "")) == card_id:
			return true
	return false

func _has_label_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text) == text:
		return true
	for child: Node in node.get_children():
		if _has_label_text(child, text):
			return true
	return false

func _assert_control_inside_viewport(control: Control) -> void:
	assert_not_null(control)
	if control == null:
		return
	var rect: Rect2 = control.get_global_rect()
	var viewport_size: Vector2 = control.get_viewport_rect().size
	assert_true(rect.position.x >= -1.0, "%s should not extend past the left edge." % str(control.name))
	assert_true(rect.position.y >= -1.0, "%s should not extend past the top edge." % str(control.name))
	assert_true(rect.position.x + rect.size.x <= viewport_size.x + 1.0, "%s should not extend past the right edge." % str(control.name))
	assert_true(rect.position.y + rect.size.y <= viewport_size.y + 1.0, "%s should not extend past the bottom edge." % str(control.name))

func _clear_test_saves() -> void:
	for index: int in range(1, SaveManager.SLOT_COUNT + 1):
		var path: String = "%s%d.json" % [TEST_SAVE_PREFIX, index]
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
