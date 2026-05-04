class_name BattleEngine
extends RefCounted

const HAND_SIZE: int = 3
const SLOT_COUNT: int = 3
const ENERGY_CAP: int = 6
const PHASE_ROUND_START: String = "round_start"
const PHASE_DRAW: String = "draw"
const PHASE_MAIN: String = "main"
const PHASE_MAIN_1: String = "main_1"
const PHASE_COMBAT: String = "combat"
const PHASE_MAIN_2: String = "main_2"
const PHASE_TURN_END: String = "turn_end"
const DEFAULT_PHASE_SEQUENCE: Array = [
	PHASE_ROUND_START,
	PHASE_DRAW,
	PHASE_MAIN_1,
	PHASE_COMBAT,
	PHASE_MAIN_2,
	PHASE_TURN_END
]

var round_number: int = 1
var player_health: int = 25
var enemy_health: int = 18
var energy: int = 1
var deck: Array = []
var hand: Array = []
var discard: Array = []
var player_slots: Array = []
var enemy_slots: Array = []
var log_lines: Array[String] = []
var outcome: String = ""
var hero_power_used: bool = false
var phase_sequence: Array[String] = []
var current_phase: String = PHASE_MAIN_1

var _catalog
var _phase_index: int = -1
var _pending_draw_amount: int = HAND_SIZE

func start_battle(catalog, deck_ids: Array, config: Dictionary = {}) -> void:
	_catalog = catalog
	round_number = 1
	player_health = catalog.player_hero.max_health
	enemy_health = catalog.enemy_hero.max_health
	energy = 1
	deck = deck_ids.duplicate()
	hand = []
	discard = []
	player_slots = [null, null, null]
	enemy_slots = [null, null, null]
	log_lines = []
	outcome = ""
	hero_power_used = false
	phase_sequence = _phase_sequence_from_config(config)
	current_phase = ""
	_phase_index = -1
	_pending_draw_amount = HAND_SIZE
	_log("Duelo iniciado.")
	_enter_next_phase()

func get_state() -> Dictionary:
	return {
		"round": round_number,
		"player_health": player_health,
		"enemy_health": enemy_health,
		"energy": energy,
		"deck": deck.duplicate(),
		"hand": hand.duplicate(),
		"discard": discard.duplicate(),
		"player_slots": player_slots.duplicate(true),
		"enemy_slots": enemy_slots.duplicate(true),
		"log": log_lines.duplicate(),
		"outcome": outcome,
		"hero_power_used": hero_power_used,
		"current_phase": current_phase,
		"phase_sequence": phase_sequence.duplicate()
	}

func use_player_hero_power() -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if not can_play_main_actions():
		return _fail("Poder heroico so pode ser usado em fase principal neste prototipo.")
	if hero_power_used:
		return _fail("Poder heroico ja usado nesta rodada.")
	if deck.is_empty():
		return _fail("O deck esta vazio.")

	hero_power_used = true
	_draw_cards(1)
	_log("Poder heroico: Preparar comprou 1 carta.")
	return {"ok": true, "message": "Poder heroico comprou 1 carta."}

func play_card_from_hand(hand_index: int, target: Dictionary) -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if not can_play_main_actions():
		return _fail("Cartas so podem ser jogadas em fase principal neste prototipo.")
	if hand_index < 0 or hand_index >= hand.size():
		return _fail("Carta de mao invalida.")

	var card_id: String = str(hand[hand_index])
	var card = _catalog.find_card(card_id)
	if card == null:
		return _fail("Carta inexistente: %s." % card_id)
	if card.cost > energy:
		return _fail("Energia insuficiente para %s." % card.display_name)

	if card.occupies_slot():
		return _play_permanent(hand_index, card, target)
	if card.is_damage_spell():
		return _play_damage_spell(hand_index, card, target)
	if card.is_buff_command():
		return _play_buff_command(hand_index, card, target)
	return _fail("Tipo de carta ainda nao suportado neste slice.")

func advance_phase() -> Dictionary:
	if outcome != "":
		return {"ok": false, "message": "A batalha ja terminou."}
	if not _is_player_controlled_phase(current_phase):
		return _fail("A fase atual resolve automaticamente.")

	var previous_phase: String = current_phase
	if current_phase == PHASE_COMBAT:
		_resolve_combat_phase()
		_check_outcome()
		if outcome != "":
			return {"ok": true, "message": "Combate resolvido."}

	_enter_next_phase()
	return {"ok": true, "message": _phase_advance_message(previous_phase)}

func end_player_turn() -> Dictionary:
	return advance_phase()

func can_play_main_actions() -> bool:
	return outcome == "" and current_phase in [PHASE_MAIN, PHASE_MAIN_1, PHASE_MAIN_2]

func get_phase_label() -> String:
	match current_phase:
		PHASE_ROUND_START:
			return "Inicio de round"
		PHASE_DRAW:
			return "Compra"
		PHASE_MAIN:
			return "Fase principal"
		PHASE_MAIN_1:
			return "Fase principal 1"
		PHASE_COMBAT:
			return "Combate"
		PHASE_MAIN_2:
			return "Pos-combate"
		PHASE_TURN_END:
			return "Fim do turno"
		_:
			return "Indefinida"

func get_advance_phase_label() -> String:
	match current_phase:
		PHASE_MAIN:
			return "Encerrar turno"
		PHASE_MAIN_1:
			return "Ir para combate"
		PHASE_COMBAT:
			return "Resolver combate"
		PHASE_MAIN_2:
			return "Encerrar turno"
		_:
			return "Aguarde"

func force_player_health(value: int) -> void:
	player_health = value
	_check_outcome()

func _phase_sequence_from_config(config: Dictionary) -> Array[String]:
	var configured: Array = Array(config.get("phase_sequence", DEFAULT_PHASE_SEQUENCE))
	if configured.is_empty():
		configured = DEFAULT_PHASE_SEQUENCE

	var result: Array[String] = []
	for phase: Variant in configured:
		result.append(str(phase))
	return result

func _enter_next_phase() -> void:
	if outcome != "":
		return
	if phase_sequence.is_empty():
		phase_sequence = _phase_sequence_from_config({})

	_phase_index += 1
	if _phase_index >= phase_sequence.size():
		_phase_index = 0

	current_phase = phase_sequence[_phase_index]
	_log("Fase: %s." % get_phase_label())
	_resolve_automatic_phase()

	if outcome == "" and _is_automatic_phase(current_phase):
		_enter_next_phase()

func _resolve_automatic_phase() -> void:
	match current_phase:
		PHASE_ROUND_START:
			energy = min(round_number, ENERGY_CAP)
			hero_power_used = false
			_log("Inicio da rodada %d. Energia %d." % [round_number, energy])
		PHASE_DRAW:
			var requested: int = _pending_draw_amount
			var before_count: int = hand.size()
			_draw_cards(requested)
			var drawn: int = hand.size() - before_count
			if round_number == 1 and before_count == 0:
				_log("Mao inicial com %d cartas." % drawn)
			else:
				_log("Compra: %d carta(s)." % drawn)
			_pending_draw_amount = 1
		PHASE_TURN_END:
			_log("Fim do turno.")
			round_number += 1
			_pending_draw_amount = 1

func _is_automatic_phase(phase: String) -> bool:
	return phase in [PHASE_ROUND_START, PHASE_DRAW, PHASE_TURN_END]

func _is_player_controlled_phase(phase: String) -> bool:
	return phase in [PHASE_MAIN, PHASE_MAIN_1, PHASE_COMBAT, PHASE_MAIN_2]

func _phase_advance_message(previous_phase: String) -> String:
	match previous_phase:
		PHASE_MAIN:
			return "Turno encerrado."
		PHASE_MAIN_1:
			return "Fase de combate."
		PHASE_COMBAT:
			return "Combate resolvido."
		PHASE_MAIN_2:
			return "Turno encerrado."
		_:
			return "Fase avancada."

func _resolve_combat_phase() -> void:
	_run_enemy_phase()
	_resolve_confrontation()

func _play_permanent(hand_index: int, card, target: Dictionary) -> Dictionary:
	var slot_index: int = int(target.get("slot", -1))
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return _fail("Escolha um slot aliado valido.")
	if player_slots[slot_index] != null:
		return _fail("Esse slot aliado ja esta ocupado.")

	player_slots[slot_index] = _build_occupant(card, "player")
	_spend_card(hand_index, card)
	_log("%s entrou no slot P%d." % [card.display_name, slot_index + 1])
	_check_outcome()
	return {"ok": true, "message": "Carta jogada."}

func _play_damage_spell(hand_index: int, card, target: Dictionary) -> Dictionary:
	var amount: int = int(card.effect.get("amount", 0))
	var target_owner: String = str(target.get("owner", "enemy"))
	if target_owner != "enemy":
		return _fail("Centelha so mira alvos inimigos neste slice.")

	var slot_index: int = int(target.get("slot", -1))
	if slot_index >= 0 and slot_index < SLOT_COUNT and enemy_slots[slot_index] != null:
		var occupant: Dictionary = enemy_slots[slot_index]
		occupant["health"] = int(occupant.get("health", 0)) - amount
		enemy_slots[slot_index] = occupant
		_log("%s causou %d de dano em E%d." % [card.display_name, amount, slot_index + 1])
		_remove_destroyed()
	else:
		enemy_health -= amount
		_log("%s causou %d de dano ao heroi inimigo." % [card.display_name, amount])

	_spend_card(hand_index, card)
	_check_outcome()
	return {"ok": true, "message": "Magia resolvida."}

func _play_buff_command(hand_index: int, card, target: Dictionary) -> Dictionary:
	var slot_index: int = int(target.get("slot", -1))
	if slot_index < 0 or slot_index >= SLOT_COUNT:
		return _fail("Escolha um slot aliado valido.")
	if player_slots[slot_index] == null:
		return _fail("Manter a Linha precisa de um alvo aliado.")

	var amount: int = int(card.effect.get("amount", 0))
	var occupant: Dictionary = player_slots[slot_index]
	occupant["health"] = int(occupant.get("health", 0)) + amount
	occupant["max_health"] = int(occupant.get("max_health", 0)) + amount
	player_slots[slot_index] = occupant
	_spend_card(hand_index, card)
	_log("%s fortaleceu P%d em +%d vida." % [card.display_name, slot_index + 1, amount])
	return {"ok": true, "message": "Comando resolvido."}

func _run_enemy_phase() -> void:
	var acted: bool = false
	for script_entry: Dictionary in _catalog.enemy_script:
		if int(script_entry.get("round", 0)) != round_number:
			continue
		var action: String = str(script_entry.get("action", ""))
		if action == "play":
			_enemy_play_card(str(script_entry.get("card_id", "")), int(script_entry.get("slot", 0)))
			acted = true
		elif action == "direct_damage":
			var amount: int = int(script_entry.get("amount", 0))
			player_health -= amount
			_log("O inimigo causou %d de dano direto." % amount)
			acted = true

	if not acted and round_number > 4:
		player_health -= 1
		_log("O inimigo pressiona a rota e causa 1 de dano direto.")

func _enemy_play_card(card_id: String, preferred_slot: int) -> void:
	var card = _catalog.find_card(card_id)
	if card == null:
		return
	var slot_index: int = _first_enemy_slot(preferred_slot)
	if slot_index == -1:
		_log("O inimigo nao encontrou slot livre para %s." % card.display_name)
		return
	enemy_slots[slot_index] = _build_occupant(card, "enemy")
	_log("O inimigo jogou %s em E%d." % [card.display_name, slot_index + 1])

func _resolve_confrontation() -> void:
	_log("Confronto resolve as 3 rotas.")
	for lane: int in range(SLOT_COUNT):
		var player_unit: Variant = player_slots[lane]
		var enemy_unit: Variant = enemy_slots[lane]

		var player_ready: bool = _is_ready_attacker(player_unit)
		var enemy_ready: bool = _is_ready_attacker(enemy_unit)

		if player_ready and enemy_unit != null:
			var enemy_dict: Dictionary = enemy_unit
			enemy_dict["health"] = int(enemy_dict.get("health", 0)) - int(player_unit.get("attack", 0))
			enemy_slots[lane] = enemy_dict
			_log("P%d causa %d de dano em E%d." % [lane + 1, int(player_unit.get("attack", 0)), lane + 1])
		elif player_ready:
			enemy_health -= int(player_unit.get("attack", 0))
			_log("P%d atinge o heroi inimigo por %d." % [lane + 1, int(player_unit.get("attack", 0))])

		if enemy_ready and player_unit != null:
			var player_dict: Dictionary = player_unit
			player_dict["health"] = int(player_dict.get("health", 0)) - int(enemy_unit.get("attack", 0))
			player_slots[lane] = player_dict
			_log("E%d causa %d de dano em P%d." % [lane + 1, int(enemy_unit.get("attack", 0)), lane + 1])
		elif enemy_ready:
			player_health -= int(enemy_unit.get("attack", 0))
			_log("E%d atinge o heroi do jogador por %d." % [lane + 1, int(enemy_unit.get("attack", 0))])

	_remove_destroyed()
	_ready_survivors()
	_check_outcome()

func _build_occupant(card, owner: String) -> Dictionary:
	return {
		"card_id": card.id,
		"name": card.display_name,
		"owner": owner,
		"type": card.card_type,
		"attack": card.attack,
		"health": card.health,
		"max_health": card.health,
		"ready": card.has_keyword("fast"),
		"keywords": Array(card.keywords)
	}

func _is_ready_attacker(occupant: Variant) -> bool:
	if occupant == null:
		return false
	var data: Dictionary = occupant
	return bool(data.get("ready", false)) and int(data.get("attack", 0)) > 0

func _ready_survivors() -> void:
	for lane: int in range(SLOT_COUNT):
		if player_slots[lane] != null:
			var player_unit: Dictionary = player_slots[lane]
			player_unit["ready"] = true
			player_slots[lane] = player_unit
		if enemy_slots[lane] != null:
			var enemy_unit: Dictionary = enemy_slots[lane]
			enemy_unit["ready"] = true
			enemy_slots[lane] = enemy_unit

func _remove_destroyed() -> void:
	for lane: int in range(SLOT_COUNT):
		if player_slots[lane] != null and int(player_slots[lane].get("health", 0)) <= 0:
			_log("%s foi removida de P%d." % [str(player_slots[lane].get("name", "Carta")), lane + 1])
			player_slots[lane] = null
		if enemy_slots[lane] != null and int(enemy_slots[lane].get("health", 0)) <= 0:
			_log("%s foi removida de E%d." % [str(enemy_slots[lane].get("name", "Carta")), lane + 1])
			enemy_slots[lane] = null

func _check_outcome() -> void:
	if outcome != "":
		return
	if enemy_health <= 0:
		outcome = "victory"
		_log("Vitoria: o heroi inimigo chegou a 0 HP.")
	elif player_health <= 0:
		outcome = "defeat"
		_log("Derrota: o heroi do jogador chegou a 0 HP.")

func _spend_card(hand_index: int, card) -> void:
	energy -= card.cost
	discard.append(hand[hand_index])
	hand.remove_at(hand_index)

func _draw_cards(amount: int) -> void:
	for _i: int in range(amount):
		if deck.is_empty():
			return
		hand.append(deck.pop_front())

func _first_enemy_slot(preferred_slot: int) -> int:
	if preferred_slot >= 0 and preferred_slot < SLOT_COUNT and enemy_slots[preferred_slot] == null:
		return preferred_slot
	for index: int in range(SLOT_COUNT):
		if enemy_slots[index] == null:
			return index
	return -1

func _log(line: String) -> void:
	log_lines.append(line)
	if log_lines.size() > 12:
		log_lines.pop_front()

func _fail(message: String) -> Dictionary:
	_log(message)
	return {"ok": false, "message": message}
