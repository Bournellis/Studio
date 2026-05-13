extends "res://addons/gut/test.gd"

# on_death hook: fired from _record_creature_death for every creature destruction.
# Cards with on_death effects (Necromante starter deck):
#   incursor_vazio  (2/1 rapido) on_death: extra_cinza   → total 2 cinzas on death
#   batedor_eter    (1/2)        on_death: apply_status enjoo → first ready enemy
#   lamina_choque   (3/1 rapido) on_death: damage 1 magico  → first enemy permanent
#
# Non-death removals (e.g. moving a card not via damage) should NOT fire on_death.
#
# Necromante deck activation: select_class("necromante") + initialize_deck_for_class()
# must load the 20-card starter deck.

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

func _start_necro_engine(deck: Array = []) -> BattleEngineScript:
	return _start_engine(deck, {"class_id": "necromante"})

func _place_ally(engine: BattleEngineScript, card_id: String, slot: int, ready: bool = false) -> void:
	var occupant: Dictionary = engine._build_occupant(catalog.find_card(card_id), "jogador", false)
	if ready:
		occupant["ready"] = true
		occupant["exhausted"] = false
		occupant["summoning_sick"] = false
	engine.player_slots[slot] = occupant

func _place_enemy(engine: BattleEngineScript, card_id: String, slot: int, health_override: int = -1) -> void:
	var occupant: Dictionary = engine._build_occupant(catalog.find_card(card_id), "inimigo", false)
	if health_override > 0:
		occupant["health"] = health_override
	engine.enemy_slots[slot] = occupant

# --- on_death: extra_cinza (incursor_vazio) ---

func test_on_death_extra_cinza_gives_two_total() -> void:
	var engine = _start_necro_engine()
	# Place incursor_vazio as ally (health 1 → dies from any 1-damage hit).
	_place_ally(engine, "incursor_vazio", 0)
	assert_eq(engine.cinzas, 0, "Cinzas starts at 0.")
	# Kill it directly.
	engine.player_slots[0]["health"] = 0
	engine._remove_destroyed()
	# _record_creature_death: +1 (base cinzas) + _trigger_on_death extra_cinza: +1 = 2
	assert_eq(engine.cinzas, 2, "incursor_vazio death must yield 2 cinzas (1 base + 1 extra from on_death).")

func test_on_death_extra_cinza_fires_for_enemy_card_too() -> void:
	# Even if an enemy card had on_death extra_cinza, the hook fires.
	var engine = _start_engine()
	var occupant: Dictionary = engine._build_occupant(catalog.find_card("incursor_vazio"), "inimigo", false)
	engine.enemy_slots[0] = occupant
	engine.enemy_slots[0]["health"] = 0
	engine._remove_destroyed()
	assert_eq(engine.cinzas, 2, "on_death hook fires for enemy-owned incursor_vazio too.")

# --- on_death: apply_status enjoo (batedor_eter) ---

func test_on_death_enjoo_applied_to_first_ready_enemy() -> void:
	var engine = _start_necro_engine()
	_place_ally(engine, "batedor_eter", 0)
	# Place a ready enemy target.
	var enemy_occ: Dictionary = engine._build_occupant(catalog.find_card("goblin_ponte"), "inimigo", false)
	enemy_occ["summoning_sick"] = false
	enemy_occ["exhausted"] = false
	engine.enemy_slots[0] = enemy_occ

	engine.player_slots[0]["health"] = 0
	engine._remove_destroyed()

	var enemy_after: Dictionary = Dictionary(engine.enemy_slots[0])
	assert_true(Array(enemy_after.get("status", [])).has("enjoo"),
		"batedor_eter on_death must apply enjoo to first ready enemy creature.")

func test_on_death_enjoo_does_not_apply_when_no_ready_enemy() -> void:
	var engine = _start_necro_engine()
	_place_ally(engine, "batedor_eter", 0)
	# Enemy slot is empty — should not crash.
	engine.player_slots[0]["health"] = 0
	engine._remove_destroyed()
	# No crash and cinzas incremented normally.
	assert_eq(engine.cinzas, 1, "No crash when on_death enjoo has no valid target; base cinza still awarded.")

# --- on_death: damage (lamina_choque) ---

func test_on_death_damage_hits_first_enemy_permanent() -> void:
	var engine = _start_necro_engine()
	_place_ally(engine, "lamina_choque", 0)
	_place_enemy(engine, "goblin_ponte", 0)  # 2/2

	engine.player_slots[0]["health"] = 0
	engine._remove_destroyed()

	var enemy_after: Dictionary = Dictionary(engine.enemy_slots[0])
	assert_eq(int(enemy_after.get("health", -1)), 1,
		"lamina_choque on_death must deal 1 damage to first enemy permanent (2 - 1 = 1).")

func test_on_death_damage_no_crash_when_enemy_slot_empty() -> void:
	var engine = _start_necro_engine()
	_place_ally(engine, "lamina_choque", 0)
	# No enemies — should not crash.
	engine.player_slots[0]["health"] = 0
	engine._remove_destroyed()
	assert_eq(engine.cinzas, 1, "No crash when on_death damage has no valid target.")

func test_on_death_damage_can_kill_enemy() -> void:
	# If enemy has 1 health, the 1-damage on_death should kill it and add cinzas.
	var engine = _start_necro_engine()
	_place_ally(engine, "lamina_choque", 0)
	_place_enemy(engine, "goblin_ponte", 0, 1)  # health 1

	engine.player_slots[0]["health"] = 0
	engine._remove_destroyed()

	# lamina_choque death: cinzas += 1 (base) → on_death damage kills goblin → cinzas += 1 (base for goblin)
	assert_eq(engine.cinzas, 2,
		"lamina_choque on_death kills 1-health enemy: 2 cinzas total (one per creature death).")
	assert_null(engine.enemy_slots[0], "Enemy creature killed by on_death damage must be removed.")

# --- on_death hook does not fire for non-death removals ---

func test_on_death_does_not_fire_when_creature_is_placed_directly() -> void:
	# Directly replacing a slot (not via damage) should not trigger on_death.
	var engine = _start_necro_engine()
	_place_ally(engine, "incursor_vazio", 0)
	assert_eq(engine.cinzas, 0, "Placing a creature does not trigger on_death.")

func test_on_death_does_not_fire_when_creature_survives_damage() -> void:
	var engine = _start_necro_engine()
	_place_ally(engine, "incursor_vazio", 0)  # 2/1
	# Deal 0 damage — health stays at 1, creature survives.
	engine._apply_unit_damage("jogador", 0, 0)
	engine._remove_destroyed()
	assert_eq(engine.cinzas, 0, "Surviving creature must not trigger on_death.")

# --- Necromante deck activation ---

func test_necromante_starter_deck_has_20_cards() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("necromante")
	assert_eq(deck_ids.size(), 20, "Necromante starter deck must have exactly 20 cards.")

func test_necromante_starter_deck_all_cards_exist_in_catalog() -> void:
	var deck_ids: Array = ContentLibrary.get_class_starter_deck_ids("necromante")
	for card_id in deck_ids:
		var card = catalog.find_card(str(card_id))
		assert_not_null(card, "Necromante deck card '%s' must exist in catalog." % str(card_id))

func test_necromante_deck_activates_via_session() -> void:
	GameSession.start_new_game()
	GameSession.select_class("necromante")
	GameSession.initialize_deck_for_class()
	var deck: Array = GameSession.selected_deck_ids
	assert_eq(deck.size(), 20, "After initialize_deck_for_class(), Necromante deck must have 20 cards.")

func test_necromante_is_selectable_and_battle_config_includes_class_id() -> void:
	GameSession.start_new_game()
	GameSession.select_class("necromante")
	GameSession.initialize_deck_for_class()
	var config: Dictionary = GameSession.get_battle_config()
	assert_eq(str(config.get("class_id", "")), "necromante",
		"Battle config must include class_id == 'necromante' after selection.")
