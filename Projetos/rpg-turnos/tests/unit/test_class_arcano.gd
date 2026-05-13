extends "res://addons/gut/test.gd"

# Card stats reference (from slice_catalog.json):
#   fenda_astral   magia  cost 1  damage 2 magico  target any_enemy_permanent
#   goblin_ponte   criatura cost 1  2/2
#   escudeiro      criatura cost 1  2/2
#
# Arcano hero power — Pulso Astral:
#   cost 1 | once_per_own_turn | action: damage | amount: 1 | damage_type: magico
#   target: any_permanent_or_hero | fluxo_bonus: true
#   Deals 1 + fluxo magic damage to any enemy permanent or hero.

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

func _start_arcano_engine(deck: Array = [], extra_config: Dictionary = {}) -> BattleEngineScript:
	var engine = BattleEngineScript.new()
	var d: Array = deck if deck.size() > 0 else [
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	]
	var config: Dictionary = {"enemy_ai_enabled": false, "class_id": "arcano"}
	for k in extra_config:
		config[k] = extra_config[k]
	engine.start_battle(catalog, d, config)
	return engine

func _start_arcano_duelo_engine(deck: Array = []) -> BattleEngineScript:
	# Duelo mode provides an enemy hero as a valid Pulso Astral target.
	var d: Array = deck if deck.size() > 0 else [
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	]
	return _start_arcano_engine(d, {"encounter_id": "confronto_guardiao"})

func _place_enemy(engine: BattleEngineScript, card_id: String, slot: int, health_override: int = -1) -> void:
	var occupant: Dictionary = engine._build_occupant(catalog.find_card(card_id), "inimigo", false)
	if health_override > 0:
		occupant["health"] = health_override
	engine.enemy_slots[slot] = occupant

# --- Pulso Astral: slot target ---

func test_pulso_astral_deals_damage_to_enemy_slot() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 10)

	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)), "Pulso Astral should succeed against enemy slot.")
	# Base 1 damage, fluxo == 0 at this point.
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 9,
		"Pulso Astral deals 1 magic damage (no fluxo yet).")

func test_pulso_astral_costs_1_energy() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0)
	var energy_before: int = engine.energy

	engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_eq(engine.energy, energy_before - 1, "Pulso Astral costs 1 energy.")

func test_pulso_astral_marks_hero_power_used() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0)

	engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_true(engine.hero_power_used, "Hero power must be marked as used after Pulso Astral.")

func test_pulso_astral_fails_if_already_used_this_turn() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 10)

	engine.use_player_hero_power({"owner": "inimigo", "slot": 0})
	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_false(bool(result.get("ok", false)), "Pulso Astral cannot be used twice in the same turn.")

func test_pulso_astral_fails_with_no_valid_slot_target() -> void:
	var engine = _start_arcano_engine()
	engine.enemy_slots[0] = null
	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_false(bool(result.get("ok", false)), "Pulso Astral must fail when the target slot is empty.")

func test_pulso_astral_fails_with_insufficient_energy() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0)
	var controller: Dictionary = engine._controller("jogador")
	controller["energy"] = 0
	engine._set_controller("jogador", controller)
	engine._sync_public_fields()
	assert_eq(engine.energy, 0, "Precondition: energy exhausted after 3 spells.")

	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_false(bool(result.get("ok", false)), "Pulso Astral fails when there is no energy.")

# --- Pulso Astral: hero target (duelo mode) ---

func test_pulso_astral_deals_damage_to_enemy_hero_in_duelo() -> void:
	var engine = _start_arcano_duelo_engine()
	var hp_before: int = engine.enemy_health

	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": -1})

	assert_true(bool(result.get("ok", false)), "Pulso Astral should succeed targeting enemy hero.")
	assert_eq(engine.enemy_health, hp_before - 1,
		"Pulso Astral deals 1 magic damage to enemy hero (no fluxo yet).")

func test_pulso_astral_fails_hero_target_in_non_duelo_mode() -> void:
	var engine = _start_arcano_engine()
	# Default mode (limpar_mesa) has no enemy hero.
	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": -1})

	assert_false(bool(result.get("ok", false)), "Pulso Astral fails when no enemy hero exists.")

# --- Pulso Astral: fluxo amplification ---

func test_pulso_astral_applies_fluxo_bonus_from_prior_spells() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	# Cast two fenda_astral first: fluxo -> 2.
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # fluxo 0->1
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # fluxo 1->2
	assert_eq(engine.fluxo, 2, "Precondition: fluxo is 2 before hero power.")

	var hp_before: int = int(engine.enemy_slots[0].get("health", 0))
	engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	# Pulso Astral: 1 base + 2 fluxo = 3 damage.
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), hp_before - 3,
		"Pulso Astral applies fluxo bonus: 1 + fluxo(2) = 3 damage.")

func test_pulso_astral_with_zero_fluxo_deals_base_damage_only() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 10)
	assert_eq(engine.fluxo, 0, "Precondition: fluxo starts at 0.")

	engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 9,
		"Pulso Astral with fluxo 0 deals exactly 1 base damage.")

func test_pulso_astral_does_not_increment_fluxo() -> void:
	# Hero power is not a magia/magia_de_tabuleiro card; it must not increment fluxo.
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)
	assert_eq(engine.fluxo, 0, "Precondition: fluxo starts at 0.")

	engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_eq(engine.fluxo, 0, "Hero power must not increment fluxo.")

func test_pulso_astral_hero_power_resets_between_turns() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	engine.use_player_hero_power({"owner": "inimigo", "slot": 0})
	assert_true(engine.hero_power_used, "Precondition: hero power marked used.")

	# Advance to next player turn.
	engine.pass_priority("jogador")
	engine.finish_discard_phase()
	engine.pass_priority("jogador")

	assert_false(engine.hero_power_used, "Hero power available flag must reset at start of new turn.")
