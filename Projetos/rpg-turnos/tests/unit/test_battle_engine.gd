extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

func _start_engine(deck: Array, config: Dictionary = {}):
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, deck, config)
	return engine

func _starter_deck() -> Array:
	return Array(catalog.starter_deck_ids)

func test_c1_is_single_main_game_and_starts_clear_board() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})

	assert_eq(engine.modo_batalha, "limpar_mesa")
	assert_eq(engine.current_phase, "fase_principal")
	assert_eq(engine.active_player_id, "jogador")
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.hand.size(), 4)
	assert_eq(engine.energy, 3)
	assert_eq(engine.player_health, 25)
	assert_eq(engine.enemy_health, 0)
	assert_eq(engine.enemy_slots.size(), 3)
	assert_true(engine.controladores.has("jogador"))
	assert_true(engine.controladores.has("inimigo"))

func test_player_pass_automates_enemy_and_pauses_on_player_in_enemy_turn() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})

	var result: Dictionary = engine.pass_priority("jogador")

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.turno, 2)
	assert_eq(engine.active_player_id, "inimigo")
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.current_phase, "fase_principal")

func test_hero_power_costs_energy_grants_persistent_armor_and_auto_resolves_enemy() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})

	var result: Dictionary = engine.use_player_hero_power()

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.energy, 2)
	assert_eq(engine.player_armor, 2)
	assert_eq(engine.player_health, 25)
	assert_true(engine.hero_power_used)
	assert_eq(engine.priority_owner_id, "jogador")
	assert_gt(engine.eventos_visuais.size(), 0)

func test_normal_action_auto_returns_priority_after_enemy_pass() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.consecutive_passes, 1)
	assert_true(engine.player_slots[0] != null)

func test_instant_action_keeps_priority_without_enemy_automation() -> void:
	var engine = _start_engine(["raio_curto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.consecutive_passes, 0)
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 1)

func test_creature_has_enjoo_until_own_upkeep() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	assert_eq(engine.get_slot_attack_status("jogador", 0), "Enjoo")

	engine.pass_priority("jogador")
	engine.pass_priority("jogador")

	assert_eq(engine.active_player_id, "jogador")
	assert_eq(engine.get_slot_attack_status("jogador", 0), "Pode atacar")

func test_rapido_can_attack_immediately() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	assert_eq(engine.get_slot_attack_status("jogador", 0), "Pode atacar")
	assert_gt(engine.get_attack_options("jogador", 0).size(), 0)

func test_attack_damage_between_creatures_is_simultaneous() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_null(engine.player_slots[0])
	assert_null(engine.enemy_slots[0])

func test_clear_board_does_not_allow_empty_lane_attack_without_objective() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.enemy_slots[0] = null
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	assert_eq(engine.get_attack_options("jogador", 0).size(), 0)

func test_duel_allows_empty_lane_attack_against_enemy_hero() -> void:
	var engine = _start_engine(
		["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"],
		{"encounter_id": "duelista_bandido", "enemy_ai_enabled": false}
	)

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": -1})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.enemy_health, 17)

func test_slot_restriction_rejects_large_card_on_bridge_slot() -> void:
	var engine = _start_engine(["bruto_mercenario", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "jogador", "slot": 1})

	assert_false(bool(result.get("ok", false)))
	assert_null(engine.player_slots[1])

func test_cover_reduces_ranged_damage() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 2})
	engine.priority_owner_id = "inimigo"

	var result: Dictionary = engine.attack_with_unit("inimigo", 2, {"owner": "jogador", "slot": 2})

	assert_true(bool(result.get("ok", false)))
	assert_eq(int(engine.player_slots[2].get("health", 0)), 2)

func test_high_reach_route_can_offer_multiple_targets() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 1})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 2})
	engine.priority_owner_id = "inimigo"

	var options: Array = engine.get_attack_options("inimigo", 2)

	assert_eq(options.size(), 2)
	assert_eq(str(Dictionary(options[0]).get("label", "")), "P2")
	assert_eq(str(Dictionary(options[1]).get("label", "")), "P3")

func test_atropelar_deals_overflow_to_hero_in_duel() -> void:
	var engine = _start_engine(
		["javali_guerra", "escudeiro", "escudeiro", "escudeiro"],
		{"encounter_id": "duelista_bandido", "enemy_ai_enabled": false}
	)
	engine.enemy_slots[0] = engine._build_occupant(catalog.find_card("goblin_ponte"), "inimigo", false)
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	engine.player_slots[0]["summoning_sick"] = false
	engine.player_slots[0]["ready"] = true

	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.enemy_health, 18)

func test_burning_terrain_ticks_on_occupant_upkeep() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	engine._player_slot_definitions[0]["terrain"] = "queimando"

	engine._resolve_upkeep("jogador")

	assert_eq(int(engine.player_slots[0].get("health", 0)), 1)

func test_hand_limit_discards_extra_draws() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})
	var controller: Dictionary = engine._controller("jogador")
	controller["hand"] = _starter_deck().slice(0, 8)
	controller["deck"] = ["escudeiro", "guarda_vila"]
	controller["discard"] = []
	engine._set_controller("jogador", controller)

	var drawn: int = engine._draw_cards_for("jogador", 2)

	assert_eq(drawn, 0)
	assert_eq(engine._controller("jogador").get("hand").size(), 8)
	assert_eq(engine._controller("jogador").get("discard").size(), 2)

func test_clear_board_victory_when_last_enemy_destroyed() -> void:
	var engine = _start_engine(["golpe_preciso", "golpe_preciso", "golpe_preciso", "golpe_preciso"], {"enemy_ai_enabled": false})
	engine.enemy_slots[0] = null
	engine.enemy_slots[1] = null
	engine.enemy_slots[2]["health"] = 3

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 2})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.outcome, "victory")

func test_duel_victory_when_enemy_hero_reaches_zero() -> void:
	var engine = _start_engine(
		["golpe_preciso", "golpe_preciso", "golpe_preciso", "golpe_preciso"],
		{"encounter_id": "duelista_bandido", "enemy_ai_enabled": false}
	)
	engine.force_enemy_health(3)

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": -1})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.outcome, "victory")

func test_player_defeat_wins_over_simultaneous_result() -> void:
	var engine = _start_engine(["golpe_preciso", "golpe_preciso", "golpe_preciso", "golpe_preciso"], {"enemy_ai_enabled": false})

	engine.force_player_health(0)

	assert_eq(engine.outcome, "defeat")
