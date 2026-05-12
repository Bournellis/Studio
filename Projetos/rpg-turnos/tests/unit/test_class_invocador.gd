extends "res://addons/gut/test.gd"

# Card stats reference (from slice_catalog.json):
#   escudeiro        2/2   cost 1
#   guarda_vila      1/4   cost 1  (defensor)
#   lobo_faminto     3/1   cost 1  (rapido)
#   bruto_mercenario 4/4   cost 3
#   reforco_aliado   magia cost 1  effect: gain_stats +2/+0 any_own_creature
#   amplificacao_campo magia_de_tabuleiro cost 3 effect: gain_stats +1/+0 all_own_creatures

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

func _start_invocador_engine(deck: Array = [], extra_config: Dictionary = {}) -> BattleEngineScript:
	var engine = BattleEngineScript.new()
	var d: Array = deck if deck.size() > 0 else ["escudeiro", "escudeiro", "escudeiro", "escudeiro", "escudeiro"]
	var config: Dictionary = {"enemy_ai_enabled": false, "class_id": "invocador"}
	for k in extra_config:
		config[k] = extra_config[k]
	engine.start_battle(catalog, d, config)
	return engine

func _start_no_class_engine(deck: Array = []) -> BattleEngineScript:
	var engine = BattleEngineScript.new()
	var d: Array = deck if deck.size() > 0 else ["escudeiro", "escudeiro", "escudeiro", "escudeiro", "escudeiro"]
	engine.start_battle(catalog, d, {"enemy_ai_enabled": false})
	return engine

# --- Comandante de Campo passive ---

func test_comandante_de_campo_buffs_pre_existing_ally_when_it_has_higher_atk() -> void:
	var engine = _start_invocador_engine()
	# lobo_faminto ATK 3 is higher than escudeiro ATK 2.
	engine.player_slots[1] = engine._build_occupant(catalog.find_card("lobo_faminto"), "jogador", false)

	# Summon escudeiro (ATK 2) from hand.
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	# lobo_faminto (ATK 3) is highest — passive buffs it to 4.
	assert_eq(int(engine.player_slots[1].get("attack", 0)), 4, "Passive should buff the highest-ATK pre-existing ally (+1).")
	assert_eq(int(engine.player_slots[0].get("attack", 0)), 2, "Newly summoned escudeiro (lower ATK) unchanged.")

func test_comandante_de_campo_buffs_newly_summoned_creature_when_it_has_highest_atk() -> void:
	var engine = _start_invocador_engine()
	# guarda_vila ATK 1 is lower than escudeiro ATK 2.
	engine.player_slots[1] = engine._build_occupant(catalog.find_card("guarda_vila"), "jogador", false)

	# Summon escudeiro (ATK 2) from hand.
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	# escudeiro (ATK 2) is highest — passive buffs it to 3.
	assert_eq(int(engine.player_slots[0].get("attack", 0)), 3, "Newly summoned escudeiro (highest ATK) is buffed.")
	assert_eq(int(engine.player_slots[1].get("attack", 0)), 1, "guarda_vila (lower ATK) unchanged.")

func test_comandante_de_campo_buffs_single_summoned_creature_when_field_was_empty() -> void:
	var engine = _start_invocador_engine()
	# No pre-existing allies. Summon escudeiro as the first creature.
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	# Escudeiro is the only ally — passive fires and buffs it +1. 2 + 1 = 3.
	assert_eq(int(engine.player_slots[0].get("attack", 0)), 3, "Only summoned ally receives +1 from passive.")

func test_comandante_de_campo_buff_is_permanent_across_turns() -> void:
	var engine = _start_invocador_engine()
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	var atk_after_summon: int = int(engine.player_slots[0].get("attack", 0))

	# Pass through a full turn cycle.
	engine.pass_priority("jogador")
	engine.finish_discard_phase()
	engine.pass_priority("jogador")

	assert_eq(engine.active_player_id, "jogador")
	assert_eq(int(engine.player_slots[0].get("attack", 0)), atk_after_summon, "Passive buff is permanent; ATK unchanged after turn cycle.")

func test_comandante_de_campo_does_not_trigger_without_invocador_class() -> void:
	var engine = _start_no_class_engine()
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	# No passive: escudeiro ATK stays at base 2.
	assert_eq(int(engine.player_slots[0].get("attack", 0)), 2, "No passive trigger without Invocador class — ATK stays at base value.")

func test_comandante_de_campo_does_not_trigger_for_enemy_summon() -> void:
	var engine = _start_invocador_engine()
	engine.player_slots[0] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)
	var atk_before: int = int(engine.player_slots[0].get("attack", 0))

	# Directly place enemy creature (bypass hand — no player action).
	engine.enemy_slots[0] = engine._build_occupant(catalog.find_card("goblin_ponte"), "inimigo", false)

	assert_eq(int(engine.player_slots[0].get("attack", 0)), atk_before, "Passive must not trigger on enemy placement.")

# --- Amplificar hero power ---

func test_amplificar_grants_permanent_attack_buff_to_chosen_ally() -> void:
	var engine = _start_invocador_engine()
	engine.player_slots[0] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)

	var result: Dictionary = engine.use_player_hero_power({"owner": "jogador", "slot": 0})

	assert_true(bool(result.get("ok", false)), "Amplificar should succeed.")
	# escudeiro base ATK 2, gains +2 = 4.
	assert_eq(int(engine.player_slots[0].get("attack", 0)), 4, "Amplificar grants +2 ATK permanently.")
	assert_eq(engine.energy, 2, "Amplificar costs 1 energy.")
	assert_true(engine.hero_power_used, "Hero power marked as used.")

func test_amplificar_buff_is_permanent_across_turns() -> void:
	var engine = _start_invocador_engine()
	engine.player_slots[0] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)
	engine.use_player_hero_power({"owner": "jogador", "slot": 0})
	var atk_after_buff: int = int(engine.player_slots[0].get("attack", 0))

	engine.pass_priority("jogador")
	engine.finish_discard_phase()
	engine.pass_priority("jogador")

	assert_eq(engine.active_player_id, "jogador")
	assert_eq(int(engine.player_slots[0].get("attack", 0)), atk_after_buff, "Amplificar buff is permanent; ATK must survive a turn cycle.")

func test_amplificar_fails_without_valid_target() -> void:
	var engine = _start_invocador_engine()
	# No creatures on field — slot 0 is null.
	var result: Dictionary = engine.use_player_hero_power({"owner": "jogador", "slot": 0})

	assert_false(bool(result.get("ok", false)), "Amplificar should fail with no allied creature in target slot.")

func test_amplificar_fails_if_already_used_this_turn() -> void:
	var engine = _start_invocador_engine()
	engine.player_slots[0] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)
	engine.use_player_hero_power({"owner": "jogador", "slot": 0})

	var result: Dictionary = engine.use_player_hero_power({"owner": "jogador", "slot": 0})

	assert_false(bool(result.get("ok", false)), "Hero power cannot be used twice in the same turn.")

# --- Legacy fallback (no class) ---

func test_preparar_defesa_is_fallback_with_no_class() -> void:
	var engine = _start_no_class_engine()

	var result: Dictionary = engine.use_player_hero_power()

	assert_true(bool(result.get("ok", false)), "Preparar Defesa fallback should succeed.")
	assert_eq(engine.player_armor, 2, "Fallback grants 2 armor.")
	assert_eq(engine.energy, 2, "Fallback costs 1 energy.")

func test_preparar_defesa_fallback_for_unknown_class_id() -> void:
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, ["escudeiro", "escudeiro", "escudeiro", "escudeiro", "escudeiro"], {
		"enemy_ai_enabled": false,
		"class_id": "classe_inexistente"
	})

	var result: Dictionary = engine.use_player_hero_power()

	assert_true(bool(result.get("ok", false)), "Unknown class_id should fall back to Preparar Defesa.")
	assert_eq(engine.player_armor, 2, "Fallback grants 2 armor.")

# --- Invocador stat buff cards ---

func test_reforco_aliado_applies_permanent_attack_buff() -> void:
	var engine = _start_invocador_engine(["reforco_aliado", "escudeiro", "escudeiro", "escudeiro", "escudeiro"])
	engine.player_slots[1] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "jogador", "slot": 1})

	assert_true(bool(result.get("ok", false)), "Reforco Aliado should resolve successfully.")
	# escudeiro base ATK 2, gains +2 = 4.
	assert_eq(int(engine.player_slots[1].get("attack", 0)), 4, "Escudeiro gains +2 ATK from Reforco Aliado.")

func test_amplificacao_campo_buffs_all_own_creatures() -> void:
	var engine = _start_invocador_engine(["amplificacao_campo", "escudeiro", "escudeiro", "escudeiro", "escudeiro"])
	# Pre-place allies directly (no passive trigger since these aren't summoned via play_card_from_hand).
	engine.player_slots[0] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)
	engine.player_slots[1] = engine._build_occupant(catalog.find_card("guarda_vila"), "jogador", false)

	# amplificacao_campo costs 3; starting energy is 3. Index 0 in hand.
	var result: Dictionary = engine.play_card_from_hand(0, {})

	assert_true(bool(result.get("ok", false)), "Amplificacao de Campo should resolve.")
	# escudeiro ATK 2 + 1 = 3.
	assert_eq(int(engine.player_slots[0].get("attack", 0)), 3, "Escudeiro gains +1 ATK from Amplificacao de Campo.")
	# guarda_vila ATK 1 + 1 = 2.
	assert_eq(int(engine.player_slots[1].get("attack", 0)), 2, "Guarda Vila gains +1 ATK from Amplificacao de Campo.")
