class_name BattleEngine
extends RefCounted

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"

const MODE_CLEAR_BOARD: String = "limpar_mesa"
const MODE_DUEL: String = "duelo"
const MODE_WAVES: String = "ondas"
const MODE_DEFENSE_POSITION: String = "defesa_posicao"
const MODE_SURVIVE_TURNS: String = "sobreviver_turnos"
const MODE_SUMMONER_BOSS: String = "chefe_summoner"

const PHASE_MAIN: String = "fase_principal"
const PHASE_ENDED: String = "encerrada"

const STARTING_HAND_SIZE: int = 5
const DEFAULT_MANA_PER_TURN: int = 3
const DEFAULT_ENEMY_HEALTH: int = 20
const MAX_LOG_LINES: int = 18

var turn_number: int = 1
var player_health: int = 30
var enemy_health: int = DEFAULT_ENEMY_HEALTH
var mana: int = DEFAULT_MANA_PER_TURN
var mana_per_turn: int = DEFAULT_MANA_PER_TURN
var deck: Array[String] = []
var discard: Array[String] = []
var hand: Array[String] = []
var player_slots: Array = []
var enemy_slots: Array = []
var log_lines: Array[String] = []
var visual_events: Array[Dictionary] = []
var outcome: String = ""
var current_phase: String = PHASE_MAIN
var mode: String = MODE_CLEAR_BOARD
var encounter_id: String = ""
var encounter_name: String = ""
var enemy_director: String = ""
var boss_summon_index: int = 0
var boss_summons: Array[Dictionary] = []

var _catalog

func start_battle(catalog, deck_ids: Array, config: Dictionary = {}) -> void:
	_catalog = catalog
	var encounter: Dictionary = _encounter_from_config(config)
	encounter_id = str(encounter.get("id", ""))
	encounter_name = str(encounter.get("display_name", encounter_id))
	mode = str(encounter.get("mode", MODE_CLEAR_BOARD))
	enemy_director = str(encounter.get("enemy_director", "prefilled_board"))
	mana_per_turn = int(config.get("mana_per_turn", encounter.get("mana_per_turn", DEFAULT_MANA_PER_TURN)))
	mana = mana_per_turn
	turn_number = 1
	boss_summon_index = 0
	boss_summons = _typed_dictionary_array(encounter.get("boss_summons", []))
	outcome = ""
	current_phase = PHASE_MAIN
	log_lines = []
	visual_events = []
	discard = []
	hand = []
	deck = _typed_string_array(deck_ids)
	if deck.is_empty() and catalog != null:
		deck = _typed_string_array(Array(catalog.starter_deck_ids))
	player_health = _hero_health(catalog.player_hero if catalog != null else null, 30)
	enemy_health = int(encounter.get("boss_health", _hero_health(catalog.enemy_hero if catalog != null else null, DEFAULT_ENEMY_HEALTH)))
	player_slots = _empty_slots(int(encounter.get("player_slots_count", 3)))
	enemy_slots = _empty_slots(int(encounter.get("enemy_slots_count", 3)))
	_draw_to_hand_size()
	_spawn_starting_enemies(Array(config.get("starting_enemy_slots", encounter.get("starting_enemy_slots", []))))
	_log("Encontro iniciado: %s." % encounter_name)
	_check_outcome()

func get_state() -> Dictionary:
	return {
		"turn": turn_number,
		"player_health": player_health,
		"enemy_health": enemy_health,
		"mana": mana,
		"mana_per_turn": mana_per_turn,
		"deck": deck.duplicate(),
		"discard": discard.duplicate(),
		"hand": hand.duplicate(),
		"player_slots": player_slots.duplicate(true),
		"enemy_slots": enemy_slots.duplicate(true),
		"log": log_lines.duplicate(),
		"visual_events": visual_events.duplicate(true),
		"outcome": outcome,
		"current_phase": current_phase,
		"mode": mode,
		"modo_batalha": mode,
		"encounter_id": encounter_id,
		"enemy_director": enemy_director,
		"boss_summon_index": boss_summon_index,
		"boss_summons": boss_summons.duplicate(true)
	}

func get_mode_label() -> String:
	match mode:
		MODE_CLEAR_BOARD:
			return "Limpar mesa"
		MODE_DUEL:
			return "Duelo"
		MODE_WAVES:
			return "Ondas"
		MODE_DEFENSE_POSITION:
			return "Defesa de posicao"
		MODE_SURVIVE_TURNS:
			return "Sobreviver turnos"
		MODE_SUMMONER_BOSS:
			return "Chefe summoner"
	return mode

func get_mode_progress_label() -> String:
	return get_mode_label()

func can_play_card(card) -> bool:
	return outcome == "" and card != null and int(card.cost) <= mana and not hand.is_empty()

func play_card_from_hand(hand_index: int, target: Dictionary = {}) -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if hand_index < 0 or hand_index >= hand.size():
		return _fail("Indice de carta invalido.")
	var card_id: String = hand[hand_index]
	var card = _card(card_id)
	if card == null:
		return _fail("Carta nao encontrada: %s." % card_id)
	if int(card.cost) > mana:
		return _fail("Mana insuficiente.")
	if card.occupies_slot():
		var slot_index: int = int(target.get("slot", _first_open_slot(player_slots)))
		if slot_index < 0 or slot_index >= player_slots.size():
			return _fail("Slot invalido.")
		_spend_card(hand_index, card)
		if player_slots[slot_index] != null:
			var sacrificed: Dictionary = Dictionary(player_slots[slot_index])
			discard.append(str(sacrificed.get("card_id", "")))
			_log("%s foi sacrificado para abrir espaco." % str(sacrificed.get("name", "Criatura")))
		player_slots[slot_index] = _build_occupant(card, PLAYER_ID, false)
		_log("%s entrou no slot %d." % [card.display_name, slot_index + 1])
	else:
		_spend_card(hand_index, card)
		_resolve_spell(card, target)
	_draw_to_hand_size()
	_check_outcome()
	return {"ok": true, "message": "Carta jogada."}

func end_player_turn() -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	_log("Fim do turno %d." % turn_number)
	_auto_attack_side(PLAYER_ID)
	_check_outcome()
	if outcome == "":
		_resolve_boss_summon()
		_check_outcome()
	if outcome == "":
		_auto_attack_side(ENEMY_ID)
		_check_outcome()
	turn_number += 1
	mana = mana_per_turn
	current_phase = PHASE_MAIN if outcome == "" else PHASE_ENDED
	return {"ok": true, "message": "Turno resolvido."}

func get_attack_options(owner_id: String, slot_index: int) -> Array[Dictionary]:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return []
	var opponent_id: String = _opponent_id(owner_id)
	var opposing_slots: Array = _slots_for_owner(opponent_id)
	if slot_index < opposing_slots.size() and opposing_slots[slot_index] != null:
		return [{"owner": opponent_id, "slot": slot_index}]
	for index: int in range(opposing_slots.size()):
		if opposing_slots[index] != null:
			return [{"owner": opponent_id, "slot": index}]
	if _can_attack_hero(opponent_id):
		return [{"owner": opponent_id, "hero": true}]
	return []

func attack_with_unit(owner_id: String, slot_index: int, target: Dictionary = {}) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return _fail("Atacante invalido.")
	var options: Array[Dictionary] = get_attack_options(owner_id, slot_index)
	if options.is_empty():
		return _fail("Sem alvo valido.")
	var chosen_target: Dictionary = target if not target.is_empty() else options[0]
	if not _target_in_options(chosen_target, options):
		return _fail("Alvo invalido.")
	_resolve_attack(owner_id, slot_index, chosen_target)
	_check_outcome()
	return {"ok": true, "message": "Ataque resolvido."}

func _encounter_from_config(config: Dictionary) -> Dictionary:
	if config.has("encounter") and typeof(config.get("encounter")) == TYPE_DICTIONARY:
		return Dictionary(config.get("encounter"))
	var requested_id: String = str(config.get("encounter_id", ""))
	if _catalog != null and requested_id != "":
		var requested: Dictionary = _catalog.find_encounter(requested_id)
		if not requested.is_empty():
			return requested
	if _catalog != null:
		var fallback: Dictionary = _catalog.find_encounter(str(_catalog.default_encounter_id))
		if not fallback.is_empty():
			return fallback
	return {
		"id": "placeholder",
		"display_name": "Placeholder",
		"mode": MODE_CLEAR_BOARD,
		"enemy_director": "prefilled_board",
		"player_slots_count": 3,
		"enemy_slots_count": 3
	}

func _spawn_starting_enemies(setups: Array) -> void:
	for setup: Variant in setups:
		if typeof(setup) != TYPE_DICTIONARY:
			continue
		var setup_data: Dictionary = Dictionary(setup)
		var slot_index: int = int(setup_data.get("slot", -1))
		var card = _card(str(setup_data.get("card_id", "")))
		if card == null or slot_index < 0 or slot_index >= enemy_slots.size():
			continue
		enemy_slots[slot_index] = _build_occupant(card, ENEMY_ID, true)

func _resolve_boss_summon() -> void:
	if mode != MODE_SUMMONER_BOSS or boss_summons.is_empty():
		return
	var open_slot: int = _first_strict_open_slot(enemy_slots)
	if open_slot < 0:
		_log("Chefe Invocador tentou invocar, mas a mesa inimiga esta cheia.")
		return
	var summon: Dictionary = boss_summons[boss_summon_index % boss_summons.size()]
	boss_summon_index += 1
	var card = _card(str(summon.get("card_id", "")))
	if card == null:
		_log("Chefe Invocador falhou ao invocar uma criatura ausente.")
		return
	enemy_slots[open_slot] = _build_occupant(card, ENEMY_ID, true)
	_log("Chefe Invocador invocou %s no slot %d." % [card.display_name, open_slot + 1])

func _resolve_spell(card, target: Dictionary) -> void:
	if card.is_damage_spell():
		var amount: int = int(card.effect.get("amount", card.effect.get("damage", 0)))
		var target_owner: String = str(target.get("owner", ENEMY_ID))
		if target.has("slot"):
			_damage_slot(target_owner, int(target.get("slot", -1)), amount)
		else:
			_damage_hero(target_owner, amount)
		_log("%s causou %d de dano." % [card.display_name, amount])
	else:
		_log("%s foi resolvida como placeholder." % card.display_name)

func _spend_card(hand_index: int, card) -> void:
	mana -= int(card.cost)
	var card_id: String = hand[hand_index]
	hand.remove_at(hand_index)
	discard.append(card_id)

func _draw_to_hand_size() -> void:
	while hand.size() < STARTING_HAND_SIZE:
		if deck.is_empty():
			if discard.is_empty():
				return
			deck = discard.duplicate()
			discard = []
		hand.append(deck.pop_front())

func _auto_attack_side(owner_id: String) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if slots[index] == null:
			continue
		var result: Dictionary = attack_with_unit(owner_id, index)
		if not bool(result.get("ok", false)):
			continue
		if outcome != "":
			return

func _resolve_attack(owner_id: String, slot_index: int, target: Dictionary) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	var attacker: Dictionary = Dictionary(slots[slot_index])
	var damage: int = int(attacker.get("attack", 0))
	if bool(target.get("hero", false)):
		_damage_hero(str(target.get("owner", _opponent_id(owner_id))), damage)
		_log("%s atacou diretamente." % str(attacker.get("name", "Criatura")))
		return
	var target_owner: String = str(target.get("owner", _opponent_id(owner_id)))
	var target_slot: int = int(target.get("slot", -1))
	_damage_slot(target_owner, target_slot, damage)
	_log("%s atacou o slot %d." % [str(attacker.get("name", "Criatura")), target_slot + 1])

func _damage_slot(owner_id: String, slot_index: int, amount: int) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	occupant["health"] = int(occupant.get("health", 0)) - amount
	if int(occupant.get("health", 0)) <= 0:
		_log("%s foi destruido." % str(occupant.get("name", "Criatura")))
		slots[slot_index] = null
	else:
		slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _damage_hero(owner_id: String, amount: int) -> void:
	if owner_id == PLAYER_ID:
		player_health = max(0, player_health - amount)
	else:
		enemy_health = max(0, enemy_health - amount)

func _check_outcome() -> void:
	if player_health <= 0:
		outcome = "derrota"
		current_phase = PHASE_ENDED
		return
	if _can_attack_hero(ENEMY_ID) and enemy_health <= 0:
		outcome = "vitoria"
		current_phase = PHASE_ENDED
		return
	if mode == MODE_CLEAR_BOARD and _board_is_clear(ENEMY_ID):
		outcome = "vitoria"
		current_phase = PHASE_ENDED

func _board_is_clear(owner_id: String) -> bool:
	for occupant: Variant in _slots_for_owner(owner_id):
		if occupant != null:
			return false
	return true

func _can_attack_hero(owner_id: String) -> bool:
	return owner_id == PLAYER_ID or mode in [MODE_DUEL, MODE_SUMMONER_BOSS]

func _build_occupant(card, owner_id: String, ready: bool) -> Dictionary:
	return {
		"owner": owner_id,
		"card_id": card.id,
		"name": card.display_name,
		"attack": int(card.attack),
		"health": int(card.health),
		"max_health": int(card.health),
		"ready": ready
	}

func _first_open_slot(slots: Array) -> int:
	for index: int in range(slots.size()):
		if slots[index] == null:
			return index
	return 0 if not slots.is_empty() else -1

func _first_strict_open_slot(slots: Array) -> int:
	for index: int in range(slots.size()):
		if slots[index] == null:
			return index
	return -1

func _empty_slots(count: int) -> Array:
	var result: Array = []
	for _index: int in range(max(0, count)):
		result.append(null)
	return result

func _slots_for_owner(owner_id: String) -> Array:
	return enemy_slots if owner_id == ENEMY_ID else player_slots

func _set_slots_for_owner(owner_id: String, slots: Array) -> void:
	if owner_id == ENEMY_ID:
		enemy_slots = slots
	else:
		player_slots = slots

func _opponent_id(owner_id: String) -> String:
	return ENEMY_ID if owner_id == PLAYER_ID else PLAYER_ID

func _target_in_options(target: Dictionary, options: Array[Dictionary]) -> bool:
	for option: Dictionary in options:
		if str(option.get("owner", "")) == str(target.get("owner", "")) and int(option.get("slot", -999)) == int(target.get("slot", -999)) and bool(option.get("hero", false)) == bool(target.get("hero", false)):
			return true
	return false

func _card(card_id: String):
	if _catalog == null:
		return null
	return _catalog.find_card(card_id)

func _hero_health(hero, fallback: int) -> int:
	if hero == null:
		return fallback
	return int(hero.max_health)

func _typed_string_array(source: Array) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in source:
		result.append(str(item))
	return result

func _typed_dictionary_array(source: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(source) != TYPE_ARRAY:
		return result
	for item: Variant in source:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(Dictionary(item))
	return result

func _log(line: String) -> void:
	log_lines.append(line)
	if log_lines.size() > MAX_LOG_LINES:
		log_lines.pop_front()

func _fail(message: String) -> Dictionary:
	return {"ok": false, "message": message}
