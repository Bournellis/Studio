extends "res://addons/gut/test.gd"

# Card stats reference (from slice_catalog.json):
#   escudeiro       criatura  cost 1  2/2
#   goblin_ponte    criatura  cost 1  2/2
#   lobo_faminto    criatura  cost 1  3/1
#   fenda_astral    magia     cost 1  2 magico damage  target any_enemy_permanent
#
# Cinzas: persistent per-encounter int; increments by 1 for each creature
# destroyed on either side; resets to 0 at start_battle (new encounter).
#
# Memorial de Batalha: per-encounter list of destroyed creature snapshots
# ({card_id, name, attack, max_health, keywords}); resets at start_battle.

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

func _start_engine(deck: Array = [], extra_config: Dictionary = {}) -> BattleEngineScript:
	var engine = BattleEngineScript.new()
	var d: Array = deck if deck.size() > 0 else [
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	]
	var config: Dictionary = {"enemy_ai_enabled": false}
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

# --- Initial state ---

func test_cinzas_starts_at_zero() -> void:
	var engine = _start_engine()
	assert_eq(engine.cinzas, 0, "Cinzas must be 0 at battle start.")

func test_memorial_starts_empty() -> void:
	var engine = _start_engine()
	assert_eq(engine.memorial_de_batalha.size(), 0, "Memorial must be empty at battle start.")

# --- Increment on enemy death ---

func test_cinzas_increments_on_enemy_creature_death() -> void:
	var engine = _start_engine()
	# fenda_astral deals 2 magico — goblin_ponte has 2 health, so it dies
	_place_enemy(engine, "goblin_ponte", 0)

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)), "fenda_astral should resolve.")
	assert_eq(engine.cinzas, 1, "Cinzas must be 1 after one enemy creature dies.")

# --- Increment on ally death ---

func test_cinzas_increments_on_ally_creature_death() -> void:
	# Use lobo_faminto (3/1 — dies in one hit from goblin_ponte 2/2 attack).
	var engine = _start_engine(["fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"])
	_place_ally(engine, "lobo_faminto", 0, true)    # ready, 3 ATK / 1 HP
	_place_enemy(engine, "goblin_ponte", 0)          # 2 ATK / 2 HP

	# Lobo attacks goblin: lobo takes 2 damage (dies), goblin takes 3 damage (also dies).
	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)), "attack_with_unit should succeed.")
	# Both died — cinzas should be 2.
	assert_eq(engine.cinzas, 2, "Cinzas must be 2 when both attacker and defender die in the same combat.")

# --- Multi-death in one resolution ---

func test_cinzas_counts_each_death_separately() -> void:
	var engine = _start_engine([
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	])
	# Place two enemies with 1 health each so fenda_astral (2 damage) would normally kill one,
	# but we need two deaths from two separate plays. Kill them one at a time.
	_place_enemy(engine, "goblin_ponte", 0, 2)  # health 2 = killed by fenda_astral
	_place_enemy(engine, "goblin_ponte", 1, 2)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	assert_eq(engine.cinzas, 1, "One death so far.")

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 1})
	assert_eq(engine.cinzas, 2, "Cinzas accumulates: 2 deaths total.")

# --- Persistence across turns ---

func test_cinzas_persists_across_turns() -> void:
	var engine = _start_engine([
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	])
	_place_enemy(engine, "goblin_ponte", 0, 2)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	assert_eq(engine.cinzas, 1, "Cinzas is 1 after kill.")

	# Advance turn: discard phase → pass_priority to end turn → upkeep.
	engine.pass_priority()
	engine.finish_discard_phase()
	engine.pass_priority()  # enemy pass → round ends, player upkeep starts

	assert_eq(engine.cinzas, 1, "Cinzas must persist across turn boundary (not reset like fluxo).")

# --- Reset on new encounter (start_battle) ---

func test_cinzas_resets_on_new_encounter() -> void:
	var engine = _start_engine([
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	])
	_place_enemy(engine, "goblin_ponte", 0, 2)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	assert_eq(engine.cinzas, 1, "Cinzas was 1 before new encounter.")

	engine.start_battle(catalog, ["fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"], {"enemy_ai_enabled": false})
	assert_eq(engine.cinzas, 0, "Cinzas must reset to 0 on start_battle (new encounter).")

func test_memorial_resets_on_new_encounter() -> void:
	var engine = _start_engine([
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	])
	_place_enemy(engine, "goblin_ponte", 0, 2)
	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})
	assert_eq(engine.memorial_de_batalha.size(), 1, "Memorial had one entry before new encounter.")

	engine.start_battle(catalog, ["fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"], {"enemy_ai_enabled": false})
	assert_eq(engine.memorial_de_batalha.size(), 0, "Memorial must be empty on start_battle (new encounter).")

# --- Memorial records correct creature data ---

func test_memorial_records_card_id_and_name() -> void:
	var engine = _start_engine()
	_place_enemy(engine, "goblin_ponte", 0, 2)

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_eq(engine.memorial_de_batalha.size(), 1, "Memorial must have one entry.")
	var entry: Dictionary = Dictionary(engine.memorial_de_batalha[0])
	assert_eq(str(entry.get("card_id", "")), "goblin_ponte", "Memorial entry must record card_id.")
	assert_false(str(entry.get("name", "")).is_empty(), "Memorial entry must record name.")

func test_memorial_records_attack_and_max_health() -> void:
	var engine = _start_engine()
	_place_enemy(engine, "escudeiro", 0, 1)  # 2/2, override health to 1 so dies to fenda_astral

	engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_eq(engine.memorial_de_batalha.size(), 1, "Memorial must have one entry.")
	var entry: Dictionary = Dictionary(engine.memorial_de_batalha[0])
	assert_eq(int(entry.get("attack", -1)), 2, "Memorial must record original attack.")
	assert_eq(int(entry.get("max_health", -1)), 2, "Memorial must record max_health.")

func test_memorial_records_both_sides() -> void:
	var engine = _start_engine([
		"fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral", "fenda_astral"
	])
	_place_ally(engine, "lobo_faminto", 0, true)  # 3/1 — dies from goblin 2 ATK
	_place_enemy(engine, "goblin_ponte", 0)        # 2/2 — dies from lobo 3 ATK

	engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 0})

	assert_eq(engine.memorial_de_batalha.size(), 2, "Memorial must record both the ally and enemy deaths.")

# --- get_state exposes cinzas and memorial ---

func test_get_state_exposes_cinzas() -> void:
	var engine = _start_engine()
	var state: Dictionary = engine.get_state()
	assert_true(state.has("cinzas"), "get_state must include 'cinzas' key.")
	assert_eq(int(state.get("cinzas", -1)), 0, "Initial cinzas in get_state must be 0.")

func test_get_state_exposes_memorial_de_batalha() -> void:
	var engine = _start_engine()
	var state: Dictionary = engine.get_state()
	assert_true(state.has("memorial_de_batalha"), "get_state must include 'memorial_de_batalha' key.")
	assert_eq(int(state.get("memorial_de_batalha", []).size()), 0, "Initial memorial in get_state must be empty.")
