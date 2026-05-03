extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

func test_battle_starts_with_three_card_hand_and_one_energy() -> void:
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, Array(catalog.starter_deck_ids))

	assert_eq(engine.hand.size(), 3)
	assert_eq(engine.energy, 1)
	assert_eq(engine.round_number, 1)
	assert_eq(engine.player_health, 25)
	assert_eq(engine.enemy_health, 18)

func test_energy_scales_by_round_until_cap() -> void:
	var deck: Array = Array(catalog.starter_deck_ids)
	deck.append_array(Array(catalog.starter_deck_ids))
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, deck)

	for _i: int in range(5):
		engine.end_player_turn()

	assert_eq(engine.round_number, 6)
	assert_eq(engine.energy, 6)

func test_preparing_unit_blocks_but_does_not_attack_until_next_confrontation() -> void:
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, ["line_guard", "line_guard", "line_guard", "line_guard"])

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "player", "slot": 0})
	assert_true(bool(result.get("ok", false)))
	assert_false(bool(engine.player_slots[0].get("ready", false)))

	engine.end_player_turn()

	assert_true(bool(engine.player_slots[0].get("ready", false)))
	assert_eq(engine.enemy_health, 18)

func test_fast_card_attacks_in_same_turn_confrontation() -> void:
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, ["quick_scout", "line_guard", "line_guard", "line_guard"])

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "player", "slot": 0})
	assert_true(bool(result.get("ok", false)))
	assert_true(bool(engine.player_slots[0].get("ready", false)))

	engine.end_player_turn()

	assert_eq(engine.enemy_health, 16)

func test_damage_spell_can_win_duel_against_enemy_hero() -> void:
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, ["short_spark", "short_spark", "short_spark"])
	engine.enemy_health = 2

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "enemy", "slot": -1})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.outcome, "victory")

func test_player_defeat_is_detected() -> void:
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, Array(catalog.starter_deck_ids))
	engine.force_player_health(0)

	assert_eq(engine.outcome, "defeat")
