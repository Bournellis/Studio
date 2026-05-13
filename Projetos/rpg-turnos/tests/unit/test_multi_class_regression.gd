extends "res://addons/gut/test.gd"

# P14 - Multi-Class Regression Checkpoint
#
# Scope:
#   - Each of the 3 classes starts a battle without errors.
#   - Each class completes a full turn cycle without errors.
#   - Hero power is available at battle start for each class.
#   - No hero power or card mechanic requires an enemy hero outside duelo.
#   - Each class starter deck loads with exactly 20 cards.
#
# This file does not duplicate mechanic-depth coverage from
# test_class_invocador.gd / test_class_arcano.gd / test_class_necromante.gd.
# It anchors the 3-class baseline for regression.

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _start_engine(class_id: String, deck: Array = [], extra_config: Dictionary = {}) -> BattleEngineScript:
	var engine := BattleEngineScript.new()
	var d: Array = deck if deck.size() > 0 else [
		"escudeiro", "escudeiro", "escudeiro", "escudeiro", "escudeiro"
	]
	var config: Dictionary = {"enemy_ai_enabled": false, "class_id": class_id}
	for k in extra_config:
		config[k] = extra_config[k]
	engine.start_battle(catalog, d, config)
	return engine

func _full_turn_cycle(engine: BattleEngineScript) -> void:
	# Player passes -> discard phase -> enemy passes -> back to player.
	engine.pass_priority("jogador")
	engine.finish_discard_phase()
	engine.pass_priority("jogador")

func _place_enemy(engine: BattleEngineScript, card_id: String, slot: int) -> void:
	engine.enemy_slots[slot] = engine._build_occupant(catalog.find_card(card_id), "inimigo", false)

# ---------------------------------------------------------------------------
# Startup — each class initialises correctly
# ---------------------------------------------------------------------------

func test_invocador_battle_starts_with_correct_class_id() -> void:
	var engine = _start_engine("invocador")
	assert_eq(engine.active_class_id, "invocador",
		"BattleEngine must expose active_class_id == 'invocador' after start_battle.")

func test_arcano_battle_starts_with_correct_class_id() -> void:
	var engine = _start_engine("arcano")
	assert_eq(engine.active_class_id, "arcano",
		"BattleEngine must expose active_class_id == 'arcano' after start_battle.")

func test_necromante_battle_starts_with_correct_class_id() -> void:
	var engine = _start_engine("necromante")
	assert_eq(engine.active_class_id, "necromante",
		"BattleEngine must expose active_class_id == 'necromante' after start_battle.")

# ---------------------------------------------------------------------------
# Hero power available at battle start
# ---------------------------------------------------------------------------

func test_invocador_hero_power_not_used_at_battle_start() -> void:
	var engine = _start_engine("invocador")
	assert_false(engine.hero_power_used,
		"Hero power must not be marked used at battle start (Invocador).")

func test_arcano_hero_power_not_used_at_battle_start() -> void:
	var engine = _start_engine("arcano")
	assert_false(engine.hero_power_used,
		"Hero power must not be marked used at battle start (Arcano).")

func test_necromante_hero_power_not_used_at_battle_start() -> void:
	var engine = _start_engine("necromante")
	assert_false(engine.hero_power_used,
		"Hero power must not be marked used at battle start (Necromante).")

# ---------------------------------------------------------------------------
# Full turn cycle — no crash, state consistent
# ---------------------------------------------------------------------------

func test_invocador_completes_full_turn_cycle() -> void:
	var engine = _start_engine("invocador")
	_full_turn_cycle(engine)
	assert_eq(engine.active_player_id, "jogador",
		"Active player must be 'jogador' after full turn cycle (Invocador).")
	assert_false(engine.hero_power_used,
		"Hero power used flag must reset after turn cycle (Invocador).")

func test_arcano_completes_full_turn_cycle_and_fluxo_resets() -> void:
	var engine = _start_engine("arcano", ["fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"])
	_place_enemy(engine, "goblin_ponte", 0)
	# Cast one spell so fluxo > 0 before the turn ends.
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	assert_eq(engine.fluxo, 1, "Precondition: fluxo is 1 after one spell.")

	_full_turn_cycle(engine)

	assert_eq(engine.active_player_id, "jogador",
		"Active player must be 'jogador' after full turn cycle (Arcano).")
	assert_eq(engine.fluxo, 0,
		"Fluxo must reset to 0 at start of new player turn.")
	assert_false(engine.hero_power_used,
		"Hero power used flag must reset after turn cycle (Arcano).")

func test_necromante_completes_full_turn_cycle_cinzas_persist() -> void:
	var engine = _start_engine("necromante")
	# Give necromante 4 cinzas directly (simulating prior deaths).
	engine.cinzas = 4
	_full_turn_cycle(engine)

	assert_eq(engine.active_player_id, "jogador",
		"Active player must be 'jogador' after full turn cycle (Necromante).")
	assert_eq(engine.cinzas, 4,
		"Cinzas must persist across turn boundary (not reset like fluxo).")
	assert_false(engine.hero_power_used,
		"Hero power used flag must reset after turn cycle (Necromante).")

# ---------------------------------------------------------------------------
# No enemy hero required outside duelo
# ---------------------------------------------------------------------------

func test_invocador_amplificar_does_not_require_enemy_hero() -> void:
	# Amplificar targets an allied creature — enemy hero presence is irrelevant.
	var engine = _start_engine("invocador")
	engine.player_slots[0] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)

	var result: Dictionary = engine.use_player_hero_power({"owner": "jogador", "slot": 0})

	assert_true(bool(result.get("ok", false)),
		"Amplificar must succeed in non-duelo mode (no enemy hero required).")

func test_arcano_pulso_astral_slot_target_does_not_require_enemy_hero() -> void:
	# Pulso Astral targeting an enemy slot does not need an enemy hero.
	var engine = _start_engine("arcano")
	_place_enemy(engine, "goblin_ponte", 0)

	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)),
		"Pulso Astral targeting a slot must succeed in non-duelo mode.")

func test_arcano_pulso_astral_hero_target_fails_without_enemy_hero() -> void:
	# Regression anchor: slot == -1 means hero target; must fail if no enemy hero.
	var engine = _start_engine("arcano")

	var result: Dictionary = engine.use_player_hero_power({"owner": "inimigo", "slot": -1})

	assert_false(bool(result.get("ok", false)),
		"Pulso Astral hero-target must fail in non-duelo mode (no enemy hero).")

func test_necromante_ritual_degrau_i_does_not_require_enemy_hero() -> void:
	# Degrau I (Cinzas 2) applies a debuff to an enemy creature — no hero needed.
	var engine = _start_engine("necromante")
	engine.cinzas = 2
	_place_enemy(engine, "goblin_ponte", 0)

	var result: Dictionary = engine.use_player_hero_power({
		"tier": 1,
		"debuff": "enjoo_estendido",
		"owner": "inimigo",
		"slot": 0
	})

	assert_true(bool(result.get("ok", false)),
		"Ritual das Sombras Degrau I must succeed in non-duelo mode (no enemy hero required).")

# ---------------------------------------------------------------------------
# Starter deck loads correctly for each class
# ---------------------------------------------------------------------------

func test_invocador_starter_deck_has_20_cards() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("invocador")
	assert_eq(deck_ids.size(), 20,
		"Invocador starter deck must have exactly 20 cards.")

func test_arcano_starter_deck_has_20_cards() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("arcano")
	assert_eq(deck_ids.size(), 20,
		"Arcano starter deck must have exactly 20 cards.")

func test_necromante_starter_deck_has_20_cards() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("necromante")
	assert_eq(deck_ids.size(), 20,
		"Necromante starter deck must have exactly 20 cards.")

func test_invocador_starter_deck_all_cards_exist_in_catalog() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("invocador")
	for card_id in deck_ids:
		var card = catalog.find_card(str(card_id))
		assert_false(card == null or (card is Dictionary and card.is_empty()),
			"Invocador starter deck card missing from catalog: %s" % card_id)

func test_arcano_starter_deck_all_cards_exist_in_catalog() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("arcano")
	for card_id in deck_ids:
		var card = catalog.find_card(str(card_id))
		assert_false(card == null or (card is Dictionary and card.is_empty()),
			"Arcano starter deck card missing from catalog: %s" % card_id)

func test_necromante_starter_deck_all_cards_exist_in_catalog() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("necromante")
	for card_id in deck_ids:
		var card = catalog.find_card(str(card_id))
		assert_false(card == null or (card is Dictionary and card.is_empty()),
			"Necromante starter deck card missing from catalog: %s" % card_id)
