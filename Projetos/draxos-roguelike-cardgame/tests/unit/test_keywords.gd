extends "res://tests/unit/draxos_test_base.gd"

const BattlePreviewPresenterScript = preload("res://modes/battle/battle_preview_presenter.gd")

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
	assert_string_contains(text, "Causa 7 de dano")
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 2})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_null(engine.enemy_slots[2])

func test_new_arcano_cards_resolve_area_damage_and_accelerate() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_bola_de_fogo_lvl3"], {
		"encounter": {
			"id": "test_fireball",
			"display_name": "Teste Bola",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_medio"},
				{"slot": 1, "card_id": "elemental_guardiao"},
				{"slot": 2, "card_id": "elemental_medio"}
			]
		},
		"class_id": "arcano",
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	var fireball_result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_true(bool(fireball_result.get("ok", false)), str(fireball_result.get("message", "")))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("health", 0)), 1)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 2)

	engine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_acelerar_lvl3", "arcano_choque"], {
		"encounter": {
			"id": "test_accelerate",
			"display_name": "Teste Acelerar",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 1,
			"enemy_slots_count": 1,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_medio"}]
		},
		"class_id": "arcano",
		"mana_per_turn": 1,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.player_slots[0] = engine._build_occupant(ContentLibrary.get_card("arcano_fagulha"), BattleEngine.PLAYER_ID, false)
	assert_false(engine.can_play_card_without_target(0))
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "area": "board"}).get("ok", false)))
	assert_eq(engine.mana, 2)
	assert_eq(int(engine.get_state().get("temporary_ability_power", 0)), 4)
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0}).get("ok", false)))
	assert_null(engine.enemy_slots[0])

func test_invocador_new_cards_apply_temporary_buff_and_regeneration() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_golem_lvl2", "invocador_atacar_lvl2"], {
		"encounter": {
			"id": "test_golem",
			"display_name": "Teste Golem",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 2,
			"enemy_slots_count": 2,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "invocador",
		"mana_per_turn": 5,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0}).get("ok", false)))
	assert_false(bool(engine.play_card_from_hand(0).get("ok", false)))
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "area": "board"}).get("ok", false)))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 7)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("temporary_health_bonus", 0)), 2)
	var occupant: Dictionary = Dictionary(engine.player_slots[0])
	occupant["health"] = 3
	engine.player_slots[0] = occupant
	engine.resolve_combat_cycle()
	assert_true(int(Dictionary(engine.player_slots[0]).get("health", 0)) >= 4)

func test_necromante_new_cards_carrion_remove_and_punish_snared() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_carniceiro"], {
		"encounter": {
			"id": "test_carrion",
			"display_name": "Teste Carnica",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 2,
			"enemy_slots_count": 2,
			"starting_enemy_slots": [{"slot": 1, "card_id": "elemental_menor"}]
		},
		"class_id": "necromante",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0}).get("ok", false)))
	engine._damage_slot(BattleEngine.ENEMY_ID, 1, 3)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 3)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 3)

	engine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_diabrete_lvl3"], {
		"encounter": {
			"id": "test_imp",
			"display_name": "Teste Diabrete",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 1,
			"enemy_slots_count": 1,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "necromante",
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0}).get("ok", false)))
	engine._damage_slot(BattleEngine.PLAYER_ID, 0, 1)
	assert_null(engine.player_slots[0])
	assert_null(engine.enemy_slots[0])

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
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "area": "board"})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 5)

func test_unlocked_passive_and_active_stay_visible_with_preview_data() -> void:
	_start_class_run("arcano", 99)
	RunSession.class_passive_unlocked = true
	RunSession.class_active_unlocked = true
	RunSession.select_node("n06_duelo_inicial")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var passive_tile = battle.find_child("BattleClassPassiveTile", true, false)
	var active_tile = battle.find_child("BattleClassActiveTile", true, false)
	assert_not_null(passive_tile)
	assert_not_null(active_tile)
	assert_true(passive_tile.visible)
	assert_true(active_tile.visible)
	assert_string_contains(str(battle._class_passive_preview_data().get("body", "")), "Fluxo")
	assert_string_contains(str(battle._class_active_preview_data().get("body", "")), "Fluxo")
	assert_eq(BattlePreviewPresenterScript.class_passive_preview_data(), battle._class_passive_preview_data())
	assert_eq(BattlePreviewPresenterScript.class_active_preview_data(battle.engine), battle._class_active_preview_data())
	var occupant: Dictionary = battle.engine._build_occupant(ContentLibrary.get_card("arcano_fagulha"), BattleEngine.PLAYER_ID, false)
	assert_eq(BattlePreviewPresenterScript.card_preview_data(battle.engine, "arcano_fagulha", occupant), battle._card_preview_data("arcano_fagulha", occupant))
	assert_eq(BattlePreviewPresenterScript.hero_preview_data(BattleEngine.PLAYER_ID, "Arcano", battle.engine.player_health), battle._hero_preview_data(BattleEngine.PLAYER_ID, "Arcano", battle.engine.player_health))
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
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("attack", 0)), 3)
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("health", 0)), 3)

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
	assert_eq(choices.size(), 3)
	for choice: Dictionary in choices:
		var choice_id: String = str(choice.get("id", ""))
		assert_false(["necro_slow", "necro_confusion", "necro_revive_full"].has(choice_id))
	assert_true(bool(engine.use_class_active({"owner": BattleEngine.ENEMY_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_ROT).get("ok", false)))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 3)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 3)

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
	assert_eq(choices.size(), 7)
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

func test_track02_atropelar_brutal_and_inspirar_resolve_in_combat_stage() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_DUEL)
	engine.enemy_health = 20
	engine.enemy_max_health = 20
	engine.player_slots[0] = engine._build_occupant(_keyword_card("trample", 5, 3, ["atropelar"]), BattleEngine.PLAYER_ID, false)
	engine.player_slots[1] = engine._build_occupant(_keyword_card("captain", 0, 3, ["inspirar"], {"inspire_amount": 1}), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("blocker", 0, 2, []), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[0])
	assert_eq(engine.enemy_health, 16)

	engine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[1] = engine._build_occupant(_keyword_card("brutal", 2, 4, ["brutal"]), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("left", 0, 2, []), BattleEngine.ENEMY_ID, true)
	engine.enemy_slots[1] = engine._build_occupant(_keyword_card("front", 0, 5, []), BattleEngine.ENEMY_ID, true)
	engine.enemy_slots[2] = engine._build_occupant(_keyword_card("right", 0, 2, []), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 1)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 1)

func test_track02_drenar_ecoar_veneno_congelar_and_drenar_almas_use_damage_hooks() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_health = 10
	engine.player_max_health = 12
	engine.player_slots[0] = engine._build_occupant(_keyword_card("reaper", 2, 4, ["drenar", "ecoar", "veneno", "congelar", "drenar_almas"], {
		"drain_amount": 2,
		"poison_apply_amount": 2
	}), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("victim", 3, 8, []), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(engine.player_health, 12)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("poison_amount", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("frozen_turns", 0)), 1)
	assert_true(bool(Dictionary(engine.player_slots[0]).get("echo_used", false)))
	assert_eq(engine.bonus_souls, 0)
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[0])
	assert_eq(engine.bonus_souls, 3)

func test_track02_escudo_resistencia_espinhos_and_furia_modify_received_damage() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("attacker", 3, 5, []), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("shield", 0, 4, ["escudo"]), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 4)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("shield_charges", 0)), 0)

	engine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("attacker", 3, 5, []), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("stone", 0, 4, ["resistencia", "espinhos", "furia"], {
		"resistance_amount": 2,
		"thorns_amount": 2
	}), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 3)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 3)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 1)

func test_track02_imune_blocks_spells_debuffs_and_keyword_removal() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "necro_prender"], {
		"encounter": {
			"id": "test_imune",
			"display_name": "Teste Imune",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 3,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("lich", 3, 5, ["imune", "crescer"]), BattleEngine.ENEMY_ID, true)
	assert_false(engine.can_play_card_on_target(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0}))
	engine._apply_debuff_to_target({"debuff": "freeze", "amount": 1}, {"owner": BattleEngine.ENEMY_ID, "slot": 0})
	engine._remove_keywords_from_target({"owner": BattleEngine.ENEMY_ID, "slot": 0})
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("frozen_turns", 0)), 0)
	assert_true(bool(Dictionary(engine.enemy_slots[0]).get("imune", false)))
	assert_true(bool(Dictionary(engine.enemy_slots[0]).get("crescer", false)))

func test_track02_crescer_proliferar_pacto_ressurgir_and_profanar_use_turn_death_and_end_combat_timing() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("spawner", 0, 3, ["proliferar"]), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("grower", 0, 3, ["crescer"], {"grow_amount": 2}), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[1])
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 2)

	engine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("twin_a", 2, 3, ["pacto"]), BattleEngine.PLAYER_ID, false)
	engine.player_slots[1] = engine._build_occupant(_keyword_card("twin_b", 2, 3, ["pacto"]), BattleEngine.PLAYER_ID, false)
	engine._recalculate_pact_bonuses(BattleEngine.PLAYER_ID)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 4)
	engine.player_slots[1] = null
	engine._recalculate_pact_bonuses(BattleEngine.PLAYER_ID)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 2)

	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("phoenix", 4, 5, ["ressurgir"]), BattleEngine.ENEMY_ID, true)
	engine._damage_slot(BattleEngine.ENEMY_ID, 0, 99)
	assert_not_null(engine.enemy_slots[0])
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)
	assert_true(Array(Dictionary(engine.enemy_slots[0]).get("keywords", [])).is_empty())

	engine.enemy_slots[1] = engine._build_occupant(_keyword_card("profane", 0, 1, ["profanar"]), BattleEngine.ENEMY_ID, true)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("blessed", 1, 3, ["defensor", "escudo"]), BattleEngine.PLAYER_ID, false)
	engine._damage_slot(BattleEngine.ENEMY_ID, 1, 99)
	assert_false(bool(Dictionary(engine.player_slots[0]).get("defensor", false)))
	assert_false(bool(Dictionary(engine.player_slots[0]).get("escudo", false)))

func test_track02_entrar_sacrificio_and_poison_maintenance_are_available_to_card_effects() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("ally", 1, 2, []), BattleEngine.PLAYER_ID, false)
	var herald := _keyword_card("herald", 1, 2, ["entrar"], {"on_enter": {"action": "summon_token", "count": 1, "attack": 1, "health": 1, "name": "Recruta"}})
	engine._resolve_on_enter(herald, BattleEngine.PLAYER_ID, 0)
	assert_not_null(engine.player_slots[1])
	assert_eq(str(Dictionary(engine.player_slots[1]).get("name", "")), "Recruta")

	var sacrifice_card := _keyword_card("sacrifice", 2, 2, ["sacrificio"], {"sacrifice_discount": 2})
	sacrifice_card.cost = 3
	engine.mana = 1
	assert_eq(engine._minimum_card_play_cost(sacrifice_card), 1)
	assert_eq(engine._card_play_cost_for_target(sacrifice_card, {"owner": BattleEngine.PLAYER_ID, "slot": 0, "confirm_sacrifice": true}), 1)

	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("poisoned", 0, 4, []), BattleEngine.ENEMY_ID, true)
	engine._apply_poison_to_slot(BattleEngine.ENEMY_ID, 0, 2)
	engine._resolve_poison_ticks()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)
