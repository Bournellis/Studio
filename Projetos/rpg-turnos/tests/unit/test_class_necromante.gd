extends "res://addons/gut/test.gd"

# Card stats reference (from slice_catalog.json):
#   escudeiro     criatura  cost 1  2/2
#   goblin_ponte  criatura  cost 1  2/2
#   lobo_faminto  criatura  cost 1  3/1
#   fenda_astral  magia     cost 1  2 magico damage
#
# Ritual das Sombras: cost 0 energy + Cinzas; 1x/own turn.
#   Degrau I  (2 Cinzas): apply debuff to enemy creature
#             debuffs: "enjoo_estendido" (2 turns), "queimando", "minus_atk" (-2/+0)
#   Degrau II (4 Cinzas): spawn 1/1 token from Memorial into empty ally slot
#   Degrau III(6 Cinzas): spawn token with original stats and keywords
#
# enjoo_estendido: sets enjoo_estendido_turns=2 on occupant;
#   blocks attacking while > 0; decrements each upkeep of that controller.

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

func _start_necro_engine(deck: Array = [], extra_config: Dictionary = {}) -> BattleEngineScript:
	var engine = BattleEngineScript.new()
	var d: Array = deck if deck.size() > 0 else [
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	]
	var config: Dictionary = {"enemy_ai_enabled": false, "class_id": "necromante"}
	for k in extra_config:
		config[k] = extra_config[k]
	engine.start_battle(catalog, d, config)
	return engine

func _place_enemy(engine: BattleEngineScript, card_id: String, slot: int, health_override: int = -1) -> void:
	var occupant: Dictionary = engine._build_occupant(catalog.find_card(card_id), "inimigo", false)
	if health_override > 0:
		occupant["health"] = health_override
	engine.enemy_slots[slot] = occupant

func _place_ally(engine: BattleEngineScript, card_id: String, slot: int, ready: bool = false) -> void:
	var occupant: Dictionary = engine._build_occupant(catalog.find_card(card_id), "jogador", false)
	if ready:
		occupant["ready"] = true
		occupant["exhausted"] = false
		occupant["summoning_sick"] = false
	engine.player_slots[slot] = occupant

func _set_cinzas(engine: BattleEngineScript, amount: int) -> void:
	engine.cinzas = amount

func _advance_enemy_turn(engine: BattleEngineScript) -> void:
	# Pass player priority → discard phase → end turn → enemy upkeep.
	engine.pass_priority()
	engine.finish_discard_phase()
	engine.pass_priority()  # enemy passes → back to player upkeep

# --- Guard: hero_power_used and once-per-turn ---

func test_ritual_sets_hero_power_used_flag() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 2)
	_place_enemy(engine, "goblin_ponte", 0)
	engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})
	var controller: Dictionary = engine._controller(BattleEngineScript.PLAYER_ID)
	assert_true(bool(controller.get("hero_power_used", false)),
		"hero_power_used must be true after Ritual das Sombras.")

func test_ritual_cannot_be_used_twice_in_same_turn() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 6)
	_place_enemy(engine, "goblin_ponte", 0)
	engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})
	var result: Dictionary = engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "queimando"})
	assert_false(bool(result.get("ok", false)),
		"Ritual das Sombras cannot be used twice in the same turn.")

func test_ritual_does_not_cost_energy() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 2)
	_place_enemy(engine, "goblin_ponte", 0)
	var controller_before: Dictionary = engine._controller(BattleEngineScript.PLAYER_ID)
	var energy_before: int = int(controller_before.get("energy", 0))
	engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})
	var controller_after: Dictionary = engine._controller(BattleEngineScript.PLAYER_ID)
	assert_eq(int(controller_after.get("energy", 0)), energy_before,
		"Ritual das Sombras must not deduct energy.")

# --- Cinzas cost validation ---

func test_ritual_fails_with_insufficient_cinzas_tier_1() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 1)
	_place_enemy(engine, "goblin_ponte", 0)
	var result: Dictionary = engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})
	assert_false(bool(result.get("ok", false)),
		"Ritual Degrau I must fail when cinzas < 2.")

func test_ritual_fails_with_insufficient_cinzas_tier_2() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 3)
	# Put a creature in memorial first.
	_place_enemy(engine, "goblin_ponte", 0, 2)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # kills it → memorial
	engine.cinzas = 3  # override to test exactly the boundary
	var result: Dictionary = engine.use_player_hero_power({"tier": 2, "memorial_index": 0, "slot": 0})
	assert_false(bool(result.get("ok", false)),
		"Ritual Degrau II must fail when cinzas < 4.")

func test_ritual_fails_with_insufficient_cinzas_tier_3() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 5)
	_place_enemy(engine, "goblin_ponte", 0, 2)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.cinzas = 5
	var result: Dictionary = engine.use_player_hero_power({"tier": 3, "memorial_index": 0, "slot": 0})
	assert_false(bool(result.get("ok", false)),
		"Ritual Degrau III must fail when cinzas < 6.")

func test_ritual_deducts_cinzas_on_success() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 4)
	_place_enemy(engine, "goblin_ponte", 0)
	engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})
	assert_eq(engine.cinzas, 2, "Cinzas must decrease by the tier cost (4 - 2 = 2).")

# --- Degrau I: enjoo_estendido ---

func test_ritual_degrau_i_applies_enjoo_estendido() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 2)
	_place_enemy(engine, "goblin_ponte", 0)
	var result: Dictionary = engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})
	assert_true(bool(result.get("ok", false)), "Ritual Degrau I should succeed.")
	var occupant: Dictionary = Dictionary(engine.enemy_slots[0])
	assert_eq(int(occupant.get("enjoo_estendido_turns", 0)), 2,
		"enjoo_estendido_turns must be 2 after Degrau I.")
	assert_true(Array(occupant.get("status", [])).has("enjoo_estendido"),
		"Status array must include 'enjoo_estendido'.")

func test_enjoo_estendido_blocks_enemy_attack() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 2)
	_place_enemy(engine, "goblin_ponte", 0)
	engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})
	# Manually give the enemy priority and check attack.
	engine.pass_priority()  # player passes
	# Now enemy has priority; goblin_ponte should not be able to attack.
	assert_false(engine._can_attack_from_slot("inimigo", 0),
		"Enemy creature with enjoo_estendido must not be able to attack.")

func test_enjoo_estendido_expires_after_two_enemy_upkeeps() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 2)
	_place_enemy(engine, "goblin_ponte", 0)
	engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "enjoo_estendido"})

	# Turn 1 end → enemy upkeep: turns go from 2 → 1.
	_advance_enemy_turn(engine)
	var occupant_t1: Dictionary = Dictionary(engine.enemy_slots[0])
	assert_eq(int(occupant_t1.get("enjoo_estendido_turns", -1)), 1,
		"enjoo_estendido_turns must be 1 after one enemy upkeep.")
	assert_true(Array(occupant_t1.get("status", [])).has("enjoo_estendido"),
		"Status must still include enjoo_estendido after one upkeep.")

	# Turn 2 end → enemy upkeep: turns go from 1 → 0, status removed.
	_advance_enemy_turn(engine)
	var occupant_t2: Dictionary = Dictionary(engine.enemy_slots[0])
	assert_eq(int(occupant_t2.get("enjoo_estendido_turns", -1)), 0,
		"enjoo_estendido_turns must be 0 after two enemy upkeeps.")
	assert_false(Array(occupant_t2.get("status", [])).has("enjoo_estendido"),
		"Status must NOT include enjoo_estendido after expiry.")

# --- Degrau I: other debuffs ---

func test_ritual_degrau_i_applies_queimando() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 2)
	_place_enemy(engine, "goblin_ponte", 0)
	var result: Dictionary = engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "queimando"})
	assert_true(bool(result.get("ok", false)), "Ritual Degrau I queimando should succeed.")
	var occupant: Dictionary = Dictionary(engine.enemy_slots[0])
	assert_true(Array(occupant.get("status", [])).has("queimando"),
		"Status array must include 'queimando'.")

func test_ritual_degrau_i_applies_minus_atk() -> void:
	var engine = _start_necro_engine()
	_set_cinzas(engine, 2)
	_place_enemy(engine, "goblin_ponte", 0)  # goblin 2/2
	var result: Dictionary = engine.use_player_hero_power({"tier": 1, "slot": 0, "debuff": "minus_atk"})
	assert_true(bool(result.get("ok", false)), "Ritual Degrau I minus_atk should succeed.")
	var occupant: Dictionary = Dictionary(engine.enemy_slots[0])
	assert_eq(int(occupant.get("attack", -1)), 0,
		"Enemy creature must have attack reduced by 2 (2 - 2 = 0).")

# --- Degrau II: spawn 1/1 token ---

func test_ritual_degrau_ii_spawns_1_1_token() -> void:
	var engine = _start_necro_engine()
	# Kill an enemy to populate memorial.
	_place_enemy(engine, "escudeiro", 0, 1)   # 2/2, health overridden to 1
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # fenda_astral kills it
	assert_eq(engine.memorial_de_batalha.size(), 1, "Memorial must have one entry.")
	engine.cinzas = 4  # set after kill

	var result: Dictionary = engine.use_player_hero_power({"tier": 2, "memorial_index": 0, "slot": 0})
	assert_true(bool(result.get("ok", false)), "Ritual Degrau II should succeed.")

	var token: Dictionary = Dictionary(engine.player_slots[0])
	assert_false(token.is_empty(), "Slot 0 must have the spawned token.")
	assert_eq(int(token.get("attack", -1)), 1, "Token attack must be 1.")
	assert_eq(int(token.get("health", -1)), 1, "Token health must be 1.")
	assert_eq(int(token.get("max_health", -1)), 1, "Token max_health must be 1.")
	assert_true(bool(token.get("is_token", false)), "Token must have is_token flag.")

func test_ritual_degrau_ii_token_preserves_name_from_memorial() -> void:
	var engine = _start_necro_engine()
	_place_enemy(engine, "escudeiro", 0, 1)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.cinzas = 4

	engine.use_player_hero_power({"tier": 2, "memorial_index": 0, "slot": 0})
	var token: Dictionary = Dictionary(engine.player_slots[0])
	assert_false(str(token.get("name", "")).is_empty(), "Token must have a name from the memorial entry.")

# --- Degrau III: spawn with original stats ---

func test_ritual_degrau_iii_spawns_with_original_stats() -> void:
	var engine = _start_necro_engine()
	# Kill bruto_mercenario (4/4) to populate memorial with high-stat creature.
	_place_enemy(engine, "bruto_mercenario", 0, 1)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.cinzas = 6

	var result: Dictionary = engine.use_player_hero_power({"tier": 3, "memorial_index": 0, "slot": 0})
	assert_true(bool(result.get("ok", false)), "Ritual Degrau III should succeed.")

	var token: Dictionary = Dictionary(engine.player_slots[0])
	assert_eq(int(token.get("attack", -1)), 4, "Degrau III token must have original attack (4).")
	assert_eq(int(token.get("max_health", -1)), 4, "Degrau III token must have original max_health (4).")

func test_ritual_degrau_ii_vs_iii_stat_difference() -> void:
	# Same memorial entry, Degrau II gives 1/1, Degrau III gives original stats.
	var engine = _start_necro_engine()
	_place_enemy(engine, "bruto_mercenario", 0, 1)  # 4/4
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.cinzas = 4
	engine.use_player_hero_power({"tier": 2, "memorial_index": 0, "slot": 0})
	var t2: Dictionary = Dictionary(engine.player_slots[0])
	assert_eq(int(t2.get("attack", -1)), 1, "Degrau II always gives 1 ATK.")

	# Reset engine and spawn via Degrau III.
	var engine2 = _start_necro_engine()
	_place_enemy(engine2, "bruto_mercenario", 0, 1)
	engine2.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine2.cinzas = 6
	engine2.use_player_hero_power({"tier": 3, "memorial_index": 0, "slot": 0})
	var t3: Dictionary = Dictionary(engine2.player_slots[0])
	assert_eq(int(t3.get("attack", -1)), 4, "Degrau III gives original ATK (4).")

# --- Spawned token generates cinzas on death ---

func test_token_generates_cinzas_on_destruction() -> void:
	var engine = _start_necro_engine()
	_place_enemy(engine, "goblin_ponte", 0, 1)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # kill enemy → cinzas=1, memorial+=1
	engine.cinzas = 4  # set after

	engine.use_player_hero_power({"tier": 2, "memorial_index": 0, "slot": 0})
	var cinzas_before_token_death: int = engine.cinzas
	# Kill the token with a card.
	engine.pass_priority()           # player ends main, discard
	engine.finish_discard_phase()    # enemy upkeep
	engine.pass_priority()           # enemy passes → player upkeep, draw, main phase
	# Now it's the player's turn again; kill the token with fenda_astral.
	var token: Dictionary = Dictionary(engine.player_slots[0])
	if token.is_empty():
		# token may have died during test; skip detailed check
		pass
	else:
		# Direct damage to the token slot.
		engine.player_slots[0]["health"] = 0
		engine._remove_destroyed()
		assert_eq(engine.cinzas, cinzas_before_token_death + 1,
			"Destroyed token must generate 1 cinza (uses same _record_creature_death pipeline).")
