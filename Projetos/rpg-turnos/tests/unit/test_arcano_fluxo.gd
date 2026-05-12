extends "res://addons/gut/test.gd"

# Card stats reference (from slice_catalog.json):
#   fenda_astral      magia          cost 1  damage 2 magico  target any_enemy_permanent
#   amplificacao_campo magia_de_tabuleiro cost 3  gain_stats +1/+0 all_own_creatures
#   escudeiro         criatura       cost 1  2/2
#   goblin_ponte      criatura       cost 1  2/2
#
# Fluxo: volatile per-turn int; increments after each magia or magia_de_tabuleiro
# resolved by the player; resets at the start of the player's next upkeep.
# Adds +1 to magic damage per point when active_class_id == "arcano".

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

func _start_no_class_engine(deck: Array = []) -> BattleEngineScript:
	var engine = BattleEngineScript.new()
	var d: Array = deck if deck.size() > 0 else [
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	]
	engine.start_battle(catalog, d, {"enemy_ai_enabled": false})
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

# --- Fluxo counter initialization ---

func test_fluxo_starts_at_zero() -> void:
	var engine = _start_arcano_engine()
	assert_eq(engine.fluxo, 0, "Fluxo must be 0 at battle start.")

func test_fluxo_starts_at_zero_without_arcano_class() -> void:
	var engine = _start_no_class_engine()
	assert_eq(engine.fluxo, 0, "Fluxo must be 0 at battle start for any class.")

# --- Fluxo increment: spell types ---

func test_fluxo_increments_after_damage_spell() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)), "fenda_astral should resolve.")
	assert_eq(engine.fluxo, 1, "Fluxo must be 1 after one damage spell resolves.")

func test_fluxo_increments_after_board_spell() -> void:
	var engine = _start_arcano_engine(["amplificacao_campo", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"])

	# amplificacao_campo costs 3; starting energy is 3. No ally targets needed.
	var result: Dictionary = engine.play_card_from_hand(0, {})

	assert_true(bool(result.get("ok", false)), "amplificacao_campo should resolve.")
	assert_eq(engine.fluxo, 1, "Fluxo must be 1 after a magia_de_tabuleiro resolves.")

func test_fluxo_stacks_across_multiple_spells() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	# Three fenda_astral at cost 1 each; starting energy 3.
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_eq(engine.fluxo, 3, "Fluxo must stack: 3 spells -> fluxo 3.")

# --- Fluxo turn reset ---

func test_fluxo_resets_at_start_of_next_player_turn() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	assert_eq(engine.fluxo, 1, "Fluxo must be 1 after one spell.")

	# End player turn, then pass during the enemy turn so the next player upkeep resolves.
	engine.pass_priority("jogador")
	engine.finish_discard_phase()
	engine.pass_priority("jogador")

	assert_eq(engine.fluxo, 0, "Fluxo must reset to 0 in player upkeep at start of next turn.")

func test_fluxo_does_not_reset_during_enemy_turn() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	# Cast one spell (fluxo -> 1), then pass priority to end player turn.
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.pass_priority("jogador")

	# At this point we are in discard/enemy turn phase, not yet back at player upkeep.
	# Fluxo must still be 1 — it has not yet been reset.
	assert_eq(engine.fluxo, 1, "Fluxo must not reset before the player's own upkeep.")

# --- Fluxo damage amplification ---

func test_first_spell_damage_has_no_fluxo_bonus() -> void:
	# fluxo == 0 at cast time; bonus is applied BEFORE incrementing.
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	# fenda_astral deals 2 + fluxo(0) = 2 damage; 20 - 2 = 18.
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 18,
		"First spell deals base damage only (fluxo was 0 at cast).")

func test_second_spell_damage_includes_fluxo_bonus() -> void:
	# After the first spell fluxo == 1; second spell gets +1.
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # 2 damage, fluxo -> 1
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # 2 + 1 = 3 damage

	# 20 - 2 - 3 = 15.
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 15,
		"Second spell deals base + fluxo(1) damage.")

func test_third_spell_damage_includes_accumulated_fluxo() -> void:
	var engine = _start_arcano_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # +0 = 2 dmg, fluxo -> 1
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # +1 = 3 dmg, fluxo -> 2
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})  # +2 = 4 dmg, fluxo -> 3

	# 20 - 2 - 3 - 4 = 11.
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 11,
		"Third spell deals base + fluxo(2) damage (cumulative amplification).")

# --- Isolation: non-Arcano classes ---

func test_fluxo_does_not_increment_without_arcano_class() -> void:
	var engine = _start_no_class_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_eq(engine.fluxo, 0, "Fluxo must not increment without Arcano class.")

func test_fluxo_damage_bonus_does_not_apply_without_arcano_class() -> void:
	var engine = _start_no_class_engine()
	_place_enemy(engine, "goblin_ponte", 0, 20)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	# Without Arcano, fenda_astral always deals base 2 damage; 20 - 2 - 2 = 16.
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 16,
		"Spells deal base damage with no fluxo bonus when class is not Arcano.")

# --- Isolation: creature attacks ---

func test_fluxo_does_not_boost_creature_attack_damage() -> void:
	var engine = _start_arcano_engine()
	# Give enemy enough health to survive both a spell and a creature attack.
	_place_enemy(engine, "goblin_ponte", 0, 20)

	# Cast one spell to advance fluxo to 1.
	# fenda_astral is instantaneo: player retains priority after casting.
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	assert_eq(engine.fluxo, 1, "Precondition: fluxo is 1 before creature attacks.")

	var hp_after_spell: int = int(engine.enemy_slots[0].get("health", 0))  # 20 - 2 = 18

	# Place an ally creature that is already ready (bypassing summoning sickness).
	_place_ally(engine, "escudeiro", 0, true)

	# Attack: escudeiro ATK = 2. Fluxo must NOT affect creature combat.
	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)), "Creature attack should succeed.")
	# Enemy takes exactly ATK (2), not ATK + fluxo (3).
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), hp_after_spell - 2,
		"Creature attack must deal only base ATK; fluxo must not amplify creature combat damage.")
