extends "res://tests/unit/draxos_test_base.gd"

const CombatResolutionDirector = preload("res://battle/combat_resolution_director.gd")

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

func test_combat_discard_marks_during_main_phase_and_redraws_after_combat() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [
		"invocador_promover",
		"invocador_promover",
		"invocador_promover",
		"invocador_soldado",
		"invocador_soldado",
		"invocador_soldado"
	], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 1,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false,
		"precombat_enabled": true
	})
	assert_false(engine.is_precombat_phase())
	assert_eq(engine.current_phase, BattleEngine.PHASE_MAIN)
	assert_eq(engine.hand.count("invocador_promover"), 3)
	for hand_index: int in range(3):
		assert_true(bool(engine.toggle_precombat_discard(hand_index).get("ok", false)))
	assert_eq(Array(engine.get_state().get("precombat_discard_indices", [])).size(), 3)
	var combat_result: Dictionary = engine.resolve_combat_cycle()
	assert_true(bool(combat_result.get("ok", false)), str(combat_result.get("message", "")))
	assert_eq(engine.hand.size(), 3)
	assert_eq(engine.hand.count("invocador_soldado"), 3)
	assert_eq(engine.discard.count("invocador_promover"), 3)

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

func test_combat_resolution_director_matches_battle_engine_wrappers() -> void:
	var wrapper_engine: BattleEngine = _combat_resolution_engine()
	var direct_engine: BattleEngine = _combat_resolution_engine()
	var wrapper_attack_target: Dictionary = {"owner": BattleEngine.ENEMY_ID, "slot": 0}
	var direct_attack_target: Dictionary = {"owner": BattleEngine.ENEMY_ID, "slot": 0}
	wrapper_engine._resolve_attack(BattleEngine.PLAYER_ID, 0, wrapper_attack_target)
	CombatResolutionDirector.resolve_attack(direct_engine, BattleEngine.PLAYER_ID, 0, direct_attack_target)
	assert_eq(wrapper_engine.enemy_slots, direct_engine.enemy_slots)
	assert_eq(wrapper_engine.player_slots, direct_engine.player_slots)
	assert_eq(wrapper_engine.discard, direct_engine.discard)
	assert_eq(wrapper_engine.dead_unit_count, direct_engine.dead_unit_count)
	assert_eq(wrapper_engine.log_lines, direct_engine.log_lines)

func test_combat_resolution_director_preserves_damage_result_schema() -> void:
	var wrapper_engine: BattleEngine = _combat_resolution_engine()
	var direct_engine: BattleEngine = _combat_resolution_engine()
	var context: Dictionary = {"source_kind": "combat", "source_owner": BattleEngine.PLAYER_ID, "source_slot": 0}
	var wrapper_result: Dictionary = wrapper_engine._deal_slot_damage(BattleEngine.ENEMY_ID, 0, 2, context)
	var direct_result: Dictionary = CombatResolutionDirector.deal_slot_damage(direct_engine, BattleEngine.ENEMY_ID, 0, 2, context)
	assert_eq(wrapper_result, direct_result)
	assert_eq(wrapper_engine.enemy_slots, direct_engine.enemy_slots)
	assert_eq(wrapper_engine.player_slots, direct_engine.player_slots)

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

func test_combat_fx_state_removes_dead_slot_only_on_damage_event() -> void:
	_start_class_run("arcano", 44)
	RunSession.select_node("n04_pouso_elemental")
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

func _combat_resolution_engine() -> BattleEngine:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_combat_resolution_director",
			"display_name": "Teste Diretor Combate",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 0,
		"max_hand_size": 0,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.player_slots[0] = engine._build_occupant(_keyword_card("combat_source", 2, 4, []), BattleEngine.PLAYER_ID, true)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("combat_target", 1, 5, []), BattleEngine.ENEMY_ID, true)
	engine.outcome = ""
	engine.current_phase = BattleEngine.PHASE_MAIN
	engine.log_lines = []
	return engine

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
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 1)
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
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 6)

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
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 1)
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
			"starting_enemy_slots": [{"slot": 0, "card_id": "arcano_fagulha"}]
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
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)

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
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 2)

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
	assert_eq(engine.required_defense_turns, 5)
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
	assert_eq(str(Dictionary(engine.enemy_slots[1]).get("card_id", "")), "enemy_gelo_djinn_do_frio")
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
	assert_eq(first_boss.enemy_health, 22)
	assert_eq(_occupied_count(first_boss.enemy_slots), 2)
	assert_eq(first_boss.boss_summons.size(), 3)
	assert_false(first_boss.boss_phase_hooks.is_empty())

	var final_boss: BattleEngine = BattleEngine.new()
	final_boss.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "chefe_summoner_final",
		"mana_per_turn": 5,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(final_boss.enemy_health, 50)
	assert_eq(final_boss.board_format, BattleEngine.BOARD_FORMAT_ABYSS)
	assert_true(_occupied_count(final_boss.enemy_slots) >= 7)
	assert_true(_enemy_board_has_card(final_boss.enemy_slots, "enemy_fogo_fenix"))
