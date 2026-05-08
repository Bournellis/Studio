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
const NECRO_CHOICE_SLOW: String = "necro_slow"
const NECRO_CHOICE_ROT: String = "necro_rot"
const NECRO_CHOICE_CONFUSION: String = "necro_confusion"
const NECRO_CHOICE_REVIVE_ONE_ONE: String = "necro_revive_one_one"
const NECRO_CHOICE_REVIVE_FULL: String = "necro_revive_full"

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
var selected_class_id: String = ""
var class_active_used: bool = false
var flow: int = 0
var ashes: int = 0
var wave_index: int = 0
var waves: Array[Array] = []
var shuffle_enabled: bool = true

var _catalog
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func start_battle(catalog, deck_ids: Array, config: Dictionary = {}) -> void:
	_catalog = catalog
	var encounter: Dictionary = _encounter_from_config(config)
	encounter_id = str(encounter.get("id", ""))
	encounter_name = str(encounter.get("display_name", encounter_id))
	mode = str(encounter.get("mode", MODE_CLEAR_BOARD))
	enemy_director = str(encounter.get("enemy_director", "prefilled_board"))
	mana_per_turn = int(config.get("mana_per_turn", encounter.get("mana_per_turn", DEFAULT_MANA_PER_TURN)))
	mana = mana_per_turn
	player_health = int(config.get("player_health", _hero_health(catalog.player_hero if catalog != null else null, 20)))
	selected_class_id = str(config.get("class_id", ""))
	class_active_used = false
	flow = 0
	ashes = 0
	turn_number = 1
	boss_summon_index = 0
	boss_summons = _typed_dictionary_array(encounter.get("boss_summons", []))
	wave_index = 0
	waves = _typed_wave_array(encounter.get("waves", []))
	shuffle_enabled = bool(config.get("shuffle_deck", true))
	_setup_shuffle(int(config.get("shuffle_seed", 0)), encounter_id)
	outcome = ""
	current_phase = PHASE_MAIN
	log_lines = []
	visual_events = []
	discard = []
	hand = []
	deck = _typed_string_array(deck_ids)
	if deck.is_empty() and catalog != null:
		deck = _typed_string_array(Array(catalog.starter_deck_ids))
	_shuffle_deck(deck)
	enemy_health = int(encounter.get("boss_health", _hero_health(catalog.enemy_hero if catalog != null else null, DEFAULT_ENEMY_HEALTH)))
	player_slots = _empty_slots(int(encounter.get("player_slots_count", 3)))
	enemy_slots = _empty_slots(int(encounter.get("enemy_slots_count", 3)))
	_draw_to_hand_size()
	if mode == MODE_WAVES and not waves.is_empty():
		_spawn_next_wave()
	else:
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
		"boss_summons": boss_summons.duplicate(true),
		"selected_class_id": selected_class_id,
		"class_active_used": class_active_used,
		"flow": flow,
		"ashes": ashes,
		"wave_index": wave_index,
		"waves_total": waves.size(),
		"shuffle_enabled": shuffle_enabled
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

func get_valid_card_targets(hand_index: int) -> Array[Dictionary]:
	if outcome != "" or hand_index < 0 or hand_index >= hand.size():
		return []
	var card = _card(hand[hand_index])
	if not can_play_card(card):
		return []
	if card.occupies_slot():
		return _slot_targets(PLAYER_ID, true)
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage":
			var targets: Array[Dictionary] = []
			targets.append_array(_occupied_slot_targets(PLAYER_ID))
			targets.append_array(_occupied_slot_targets(ENEMY_ID))
			targets.append_array(_hero_targets())
			return targets
		"debuff":
			return _occupied_slot_targets(ENEMY_ID)
		"buff_ally", "buff_all_allies":
			return _occupied_slot_targets(PLAYER_ID)
	return []

func can_play_card_on_target(hand_index: int, target: Dictionary) -> bool:
	if target.is_empty():
		return hand_index >= 0 and hand_index < hand.size() and can_play_card(_card(hand[hand_index]))
	return _target_in_options(_normalized_target(target, PLAYER_ID), get_valid_card_targets(hand_index))

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
	if not target.is_empty() and not can_play_card_on_target(hand_index, target):
		return _fail("Alvo invalido.")
	if card.occupies_slot():
		var slot_index: int = int(target.get("slot", _first_open_slot(player_slots)))
		if slot_index < 0 or slot_index >= player_slots.size():
			return _fail("Slot invalido.")
		_spend_card(hand_index, card)
		_after_card_played()
		if player_slots[slot_index] != null:
			var sacrificed: Dictionary = Dictionary(player_slots[slot_index])
			discard.append(str(sacrificed.get("card_id", "")))
			_handle_unit_death(PLAYER_ID, sacrificed)
			_log("%s foi sacrificado para abrir espaco." % str(sacrificed.get("name", "Criatura")))
		player_slots[slot_index] = _build_occupant(card, PLAYER_ID, false)
		_resolve_on_enter(card)
		_apply_summon_passive(slot_index)
		_log("%s entrou no slot %d." % [card.display_name, slot_index + 1])
	else:
		_spend_card(hand_index, card)
		_after_card_played()
		_resolve_spell(card, target)
	_draw_to_hand_size()
	_check_outcome()
	return {"ok": true, "message": "Carta jogada."}

func get_necromancer_active_choices() -> Array[Dictionary]:
	return [
		{
			"id": NECRO_CHOICE_SLOW,
			"display_name": "Lentidao Sombria",
			"cost_ashes": 2,
			"text": "Uma criatura inimiga nao ataca neste turno.",
			"enabled": selected_class_id == "necromante" and ashes >= 2 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_ROT,
			"display_name": "Podridao Astral",
			"cost_ashes": 2,
			"text": "Uma criatura inimiga perde 1/1 permanente.",
			"enabled": selected_class_id == "necromante" and ashes >= 2 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_CONFUSION,
			"display_name": "Confusao Sepulcral",
			"cost_ashes": 2,
			"text": "Uma criatura inimiga ataca o proprio lado neste turno.",
			"enabled": selected_class_id == "necromante" and ashes >= 2 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_REVIVE_ONE_ONE,
			"display_name": "Reanimar 1/1",
			"cost_ashes": 4,
			"text": "Reanima a ultima criatura do descarte como 1/1.",
			"enabled": selected_class_id == "necromante" and ashes >= 4 and _has_discard_creature() and not _strict_open_slot_targets(PLAYER_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_REVIVE_FULL,
			"display_name": "Reanimar original",
			"cost_ashes": 6,
			"text": "Reanima a ultima criatura do descarte com stats originais.",
			"enabled": selected_class_id == "necromante" and ashes >= 6 and _has_discard_creature() and not _strict_open_slot_targets(PLAYER_ID).is_empty()
		}
	]

func can_use_class_active() -> bool:
	if outcome != "" or class_active_used:
		return false
	match selected_class_id:
		"arcano":
			return mana >= 1
		"invocador":
			return mana >= 1 and _first_ally_slot() >= 0
		"necromante":
			return ashes >= 2
	return false

func get_valid_class_active_targets(choice_id: String = "") -> Array[Dictionary]:
	if not can_use_class_active():
		return []
	match selected_class_id:
		"arcano":
			var targets: Array[Dictionary] = []
			targets.append_array(_occupied_slot_targets(PLAYER_ID))
			targets.append_array(_occupied_slot_targets(ENEMY_ID))
			targets.append_array(_hero_targets())
			return targets
		"invocador":
			return _occupied_slot_targets(PLAYER_ID)
		"necromante":
			match choice_id:
				NECRO_CHOICE_SLOW, NECRO_CHOICE_ROT, NECRO_CHOICE_CONFUSION:
					if ashes < 2:
						return []
					return _occupied_slot_targets(ENEMY_ID)
				NECRO_CHOICE_REVIVE_ONE_ONE:
					if ashes < 4 or not _has_discard_creature():
						return []
					return _strict_open_slot_targets(PLAYER_ID)
				NECRO_CHOICE_REVIVE_FULL:
					if ashes < 6 or not _has_discard_creature():
						return []
					return _strict_open_slot_targets(PLAYER_ID)
	return []

func can_use_class_active_on_target(target: Dictionary, choice_id: String = "") -> bool:
	if target.is_empty() and selected_class_id == "necromante" and choice_id == "":
		return can_use_class_active()
	if target.is_empty():
		return false
	return _target_in_options(_normalized_target(target, PLAYER_ID), get_valid_class_active_targets(choice_id))

func use_class_active(target: Dictionary = {}, choice_id: String = "") -> Dictionary:
	if not can_use_class_active():
		return _fail("Spell de classe indisponivel.")
	if not target.is_empty() and not can_use_class_active_on_target(target, choice_id):
		return _fail("Alvo invalido.")
	class_active_used = true
	match selected_class_id:
		"arcano":
			mana -= 1
			var amount: int = 1 + flow + _spell_damage_bonus()
			var arcane_target: Dictionary = target if not target.is_empty() else _first_enemy_target()
			if arcane_target.has("slot"):
				_damage_slot(str(arcane_target.get("owner", ENEMY_ID)), int(arcane_target.get("slot", -1)), amount)
			else:
				_damage_hero(str(arcane_target.get("owner", ENEMY_ID)), amount)
			_log("Spell de classe Arcano causou %d de dano." % amount)
		"invocador":
			mana -= 1
			var ally_slot: int = int(target.get("slot", _strongest_ally_slot()))
			_buff_slot(PLAYER_ID, ally_slot, 2, 0, false)
			_log("Spell de classe Invocador concedeu +2/+0 permanente.")
		"necromante":
			_resolve_necromancer_active(choice_id, target)
	_check_outcome()
	return {"ok": true, "message": "Spell de classe usada."}

func end_player_turn() -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	_log("Fim do turno %d." % turn_number)
	_auto_attack_side(PLAYER_ID)
	_check_outcome()
	if outcome == "" and mode == MODE_WAVES and _board_is_clear(ENEMY_ID) and _has_next_wave():
		_spawn_next_wave()
		_check_outcome()
	if outcome == "":
		_resolve_boss_summon()
		_check_outcome()
	if outcome == "":
		_auto_attack_side(ENEMY_ID)
		_check_outcome()
	turn_number += 1
	class_active_used = false
	flow = 0
	_clear_temporary_buffs()
	_resolve_start_of_player_turn()
	mana = mana_per_turn + _mana_aura_bonus()
	current_phase = PHASE_MAIN if outcome == "" else PHASE_ENDED
	return {"ok": true, "message": "Turno resolvido."}

func get_attack_options(owner_id: String, slot_index: int) -> Array[Dictionary]:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return []
	var opponent_id: String = _opponent_id(owner_id)
	var opposing_slots: Array = _slots_for_owner(opponent_id)
	var protected_slot: int = _first_protected_slot(opponent_id)
	if protected_slot >= 0:
		return [{"owner": opponent_id, "slot": protected_slot}]
	var attacker: Dictionary = Dictionary(slots[slot_index])
	if owner_id == PLAYER_ID and bool(attacker.get("voadora", false)) and _can_attack_hero(opponent_id):
		return [{"owner": opponent_id, "hero": true}]
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

func _spawn_next_wave() -> void:
	if not _has_next_wave():
		return
	var setups: Array = waves[wave_index]
	wave_index += 1
	_spawn_starting_enemies(setups)
	_log("Onda %d/%d entrou em campo." % [wave_index, waves.size()])

func _has_next_wave() -> bool:
	return wave_index < waves.size()

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
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage":
			var amount: int = int(effect.get("amount", effect.get("damage", 0))) + _spell_damage_bonus()
			if selected_class_id == "arcano":
				amount += flow
			var target_data: Dictionary = target if not target.is_empty() else _first_enemy_target()
			var target_owner: String = str(target_data.get("owner", ENEMY_ID))
			if target_data.has("slot"):
				_damage_slot(target_owner, int(target_data.get("slot", -1)), amount)
			else:
				_damage_hero(target_owner, amount)
			_log("%s causou %d de dano." % [card.display_name, amount])
		"debuff":
			_apply_debuff_to_target(effect, target)
			_log("%s aplicou %s." % [card.display_name, str(effect.get("debuff", "debuff"))])
		"buff_ally":
			var ally_slot: int = int(target.get("slot", _strongest_ally_slot()))
			_buff_slot(PLAYER_ID, ally_slot, int(effect.get("attack", 0)), int(effect.get("health", 0)), bool(effect.get("temporary", false)))
			_log("%s fortaleceu uma criatura aliada." % card.display_name)
		"buff_all_allies":
			for index: int in range(player_slots.size()):
				if player_slots[index] != null:
					_buff_slot(PLAYER_ID, index, int(effect.get("attack", 0)), int(effect.get("health", 0)), bool(effect.get("temporary", false)))
			_log("%s fortaleceu a mesa aliada." % card.display_name)
		_:
			_log("%s foi resolvida sem efeito especial." % card.display_name)

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
			_shuffle_deck(deck)
		hand.append(deck.pop_front())

func _setup_shuffle(seed_value: int, encounter_key: String) -> void:
	var seed_text: String = "%d:%s:%s" % [seed_value, encounter_key, selected_class_id]
	_rng.seed = absi(seed_text.hash())

func _shuffle_deck(target_deck: Array[String]) -> void:
	if not shuffle_enabled or target_deck.size() < 2:
		return
	for index: int in range(target_deck.size() - 1, 0, -1):
		var swap_index: int = _rng.randi_range(0, index)
		if swap_index == index:
			continue
		var card_id: String = target_deck[index]
		target_deck[index] = target_deck[swap_index]
		target_deck[swap_index] = card_id

func _auto_attack_side(owner_id: String) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(slots[index])
		if int(occupant.get("slow_turns", 0)) > 0:
			occupant["slow_turns"] = int(occupant.get("slow_turns", 0)) - 1
			slots[index] = occupant
			_set_slots_for_owner(owner_id, slots)
			_log("%s perdeu o ataque por Lentidao." % str(occupant.get("name", "Criatura")))
			continue
		if int(occupant.get("confusion_turns", 0)) > 0:
			occupant["confusion_turns"] = int(occupant.get("confusion_turns", 0)) - 1
			slots[index] = occupant
			_set_slots_for_owner(owner_id, slots)
			var confused_target: Dictionary = _first_same_side_target(owner_id, index)
			if not confused_target.is_empty():
				_resolve_attack(owner_id, index, confused_target)
				_log("%s atacou em Confusao." % str(occupant.get("name", "Criatura")))
				if outcome != "":
					return
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
		if owner_id == PLAYER_ID:
			discard.append(str(occupant.get("card_id", "")))
		_handle_unit_death(owner_id, occupant)
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
	if mode == MODE_WAVES and _board_is_clear(ENEMY_ID) and not _has_next_wave():
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
		"ready": ready,
		"keywords": Array(card.keywords),
		"protecao": card.has_keyword("protecao"),
		"voadora": card.has_keyword("voadora"),
		"regeneracao": card.has_keyword("regeneracao"),
		"slow_turns": 0,
		"curse_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 0
	}

func _after_card_played() -> void:
	if selected_class_id == "arcano":
		flow += 1

func _resolve_on_enter(card) -> void:
	var effect: Dictionary = Dictionary(card.effect)
	var on_enter: Dictionary = Dictionary(effect.get("on_enter", {}))
	match str(on_enter.get("action", "")):
		"gain_mana":
			mana += int(on_enter.get("amount", 0))
			_log("%s gerou %d de mana neste turno." % [card.display_name, int(on_enter.get("amount", 0))])

func _apply_summon_passive(_slot_index: int) -> void:
	if selected_class_id != "invocador":
		return
	var target_slot: int = _strongest_ally_slot()
	if target_slot >= 0:
		_buff_slot(PLAYER_ID, target_slot, 1, 0, false)
		_log("Comandante de Campo concedeu +1/+0 permanente.")

func _resolve_necromancer_active(choice_id: String = "", target: Dictionary = {}) -> void:
	if choice_id == NECRO_CHOICE_SLOW:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "slow", "amount": 1}, target)
		_log("Ritual das Sombras I aplicou Lentidao.")
	elif choice_id == NECRO_CHOICE_ROT:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "rot", "amount": 1}, target)
		_log("Ritual das Sombras I aplicou Podridao.")
	elif choice_id == NECRO_CHOICE_CONFUSION:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "confusion", "amount": 1}, target)
		_log("Ritual das Sombras I aplicou Confusao.")
	elif choice_id == NECRO_CHOICE_REVIVE_ONE_ONE and _revive_from_discard_into_slot(true, int(target.get("slot", -1))):
		ashes -= 4
		_log("Ritual das Sombras II reanimou uma criatura 1/1.")
	elif choice_id == NECRO_CHOICE_REVIVE_FULL and _revive_from_discard_into_slot(false, int(target.get("slot", -1))):
		ashes -= 6
		_log("Ritual das Sombras III reanimou uma criatura com stats originais.")
	elif ashes >= 6 and _revive_from_discard(false):
		ashes -= 6
		_log("Ritual das Sombras III reanimou uma criatura com stats originais.")
	elif ashes >= 4 and _revive_from_discard(true):
		ashes -= 4
		_log("Ritual das Sombras II reanimou uma criatura 1/1.")
	else:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "rot", "amount": 1}, _first_enemy_target())
		_log("Ritual das Sombras I aplicou Podridao.")

func _revive_from_discard(as_one_one: bool) -> bool:
	var open_slot: int = _first_strict_open_slot(player_slots)
	if open_slot < 0:
		return false
	return _revive_from_discard_into_slot(as_one_one, open_slot)

func _revive_from_discard_into_slot(as_one_one: bool, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= player_slots.size() or player_slots[slot_index] != null:
		return false
	for index: int in range(discard.size() - 1, -1, -1):
		var card = _card(discard[index])
		if card == null or not card.occupies_slot():
			continue
		discard.remove_at(index)
		var occupant: Dictionary = _build_occupant(card, PLAYER_ID, false)
		if as_one_one:
			occupant["attack"] = 1
			occupant["health"] = 1
			occupant["max_health"] = 1
		player_slots[slot_index] = occupant
		return true
	return false

func _handle_unit_death(owner_id: String, occupant: Dictionary) -> void:
	if selected_class_id == "necromante":
		var gained: int = 1
		var card = _card(str(occupant.get("card_id", "")))
		if card != null:
			var on_death: Dictionary = Dictionary(Dictionary(card.effect).get("on_death", {}))
			if str(on_death.get("action", "")) == "gain_ashes":
				gained = int(on_death.get("amount", gained))
			elif str(on_death.get("action", "")) == "damage":
				_damage_first_enemy(int(on_death.get("amount", 0)))
			elif str(on_death.get("action", "")) == "debuff":
				_apply_debuff_to_target(on_death, _first_enemy_target())
		ashes += gained
		_log("Colheita Sombria gerou %d Cinza(s)." % gained)
	if owner_id == PLAYER_ID:
		return

func _apply_debuff_to_target(effect: Dictionary, target: Dictionary) -> void:
	var target_data: Dictionary = target if target.has("slot") else _first_enemy_target()
	var owner_id: String = str(target_data.get("owner", ENEMY_ID))
	var slot_index: int = int(target_data.get("slot", -1))
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	var amount: int = int(effect.get("amount", 1))
	match str(effect.get("debuff", "")):
		"slow":
			occupant["slow_turns"] = max(int(occupant.get("slow_turns", 0)), amount)
		"rot":
			occupant["attack"] = max(0, int(occupant.get("attack", 0)) - amount)
			occupant["health"] = int(occupant.get("health", 0)) - amount
			occupant["max_health"] = max(1, int(occupant.get("max_health", 1)) - amount)
		"curse":
			occupant["curse_turns"] = max(int(occupant.get("curse_turns", 0)), amount)
		"confusion":
			occupant["confusion_turns"] = max(int(occupant.get("confusion_turns", 0)), amount)
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)
	if int(occupant.get("health", 0)) <= 0:
		_damage_slot(owner_id, slot_index, 0)

func _buff_slot(owner_id: String, slot_index: int, attack_bonus: int, health_bonus: int, temporary: bool) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	occupant["attack"] = int(occupant.get("attack", 0)) + attack_bonus
	occupant["health"] = int(occupant.get("health", 0)) + health_bonus
	occupant["max_health"] = int(occupant.get("max_health", 0)) + health_bonus
	if temporary:
		occupant["temporary_attack_bonus"] = int(occupant.get("temporary_attack_bonus", 0)) + attack_bonus
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _clear_temporary_buffs() -> void:
	for index: int in range(player_slots.size()):
		if player_slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(player_slots[index])
		var temporary_attack: int = int(occupant.get("temporary_attack_bonus", 0))
		if temporary_attack != 0:
			occupant["attack"] = max(0, int(occupant.get("attack", 0)) - temporary_attack)
			occupant["temporary_attack_bonus"] = 0
			player_slots[index] = occupant

func _resolve_start_of_player_turn() -> void:
	for index: int in range(player_slots.size()):
		if player_slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(player_slots[index])
		if bool(occupant.get("regeneracao", false)):
			occupant["health"] = mini(int(occupant.get("max_health", 0)), int(occupant.get("health", 0)) + 1)
			player_slots[index] = occupant

func _mana_aura_bonus() -> int:
	var bonus: int = 0
	for occupant: Variant in player_slots:
		if occupant == null:
			continue
		var card = _card(str(Dictionary(occupant).get("card_id", "")))
		if card == null:
			continue
		var effect: Dictionary = Dictionary(card.effect)
		if str(effect.get("aura", "")) == "mana_per_turn":
			bonus += int(effect.get("amount", 0))
	return bonus

func _spell_damage_bonus() -> int:
	var bonus: int = 0
	for occupant: Variant in player_slots:
		if occupant == null:
			continue
		var card = _card(str(Dictionary(occupant).get("card_id", "")))
		if card == null:
			continue
		var effect: Dictionary = Dictionary(card.effect)
		if str(effect.get("aura", "")) == "spell_damage":
			bonus += int(effect.get("amount", 0))
	return bonus

func _first_ally_slot() -> int:
	for index: int in range(player_slots.size()):
		if player_slots[index] != null:
			return index
	return -1

func _strongest_ally_slot() -> int:
	var best_index: int = -1
	var best_attack: int = -1
	for index: int in range(player_slots.size()):
		if player_slots[index] == null:
			continue
		var attack_value: int = int(Dictionary(player_slots[index]).get("attack", 0))
		if attack_value > best_attack:
			best_attack = attack_value
			best_index = index
	return best_index

func _first_enemy_target() -> Dictionary:
	for index: int in range(enemy_slots.size()):
		if enemy_slots[index] != null:
			return {"owner": ENEMY_ID, "slot": index}
	return {"owner": ENEMY_ID, "hero": true}

func _slot_targets(owner_id: String, include_empty: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if include_empty or slots[index] != null:
			result.append({"owner": owner_id, "slot": index})
	return result

func _occupied_slot_targets(owner_id: String) -> Array[Dictionary]:
	return _slot_targets(owner_id, false)

func _strict_open_slot_targets(owner_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if slots[index] == null:
			result.append({"owner": owner_id, "slot": index})
	return result

func _hero_targets() -> Array[Dictionary]:
	if not (mode in [MODE_DUEL, MODE_SUMMONER_BOSS]):
		return []
	return [
		{"owner": PLAYER_ID, "hero": true},
		{"owner": ENEMY_ID, "hero": true}
	]

func _has_discard_creature() -> bool:
	for card_id: String in discard:
		var card = _card(card_id)
		if card != null and card.occupies_slot():
			return true
	return false

func _damage_first_enemy(amount: int) -> void:
	if amount <= 0:
		return
	var target: Dictionary = _first_enemy_target()
	if target.has("slot"):
		_damage_slot(str(target.get("owner", ENEMY_ID)), int(target.get("slot", -1)), amount)
	else:
		_damage_hero(str(target.get("owner", ENEMY_ID)), amount)

func _first_protected_slot(owner_id: String) -> int:
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if slots[index] != null and bool(Dictionary(slots[index]).get("protecao", false)):
			return index
	return -1

func _first_same_side_target(owner_id: String, attacker_index: int) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if index != attacker_index and slots[index] != null:
			return {"owner": owner_id, "slot": index}
	return {}

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
	var normalized: Dictionary = _normalized_target(target, PLAYER_ID)
	for option: Dictionary in options:
		if str(option.get("owner", "")) == str(normalized.get("owner", "")) and int(option.get("slot", -999)) == int(normalized.get("slot", -999)) and bool(option.get("hero", false)) == bool(normalized.get("hero", false)):
			return true
	return false

func _normalized_target(target: Dictionary, default_owner: String) -> Dictionary:
	var result: Dictionary = target.duplicate()
	if not result.has("owner"):
		result["owner"] = default_owner
	return result

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

func _typed_wave_array(source: Variant) -> Array[Array]:
	var result: Array[Array] = []
	if typeof(source) != TYPE_ARRAY:
		return result
	for wave: Variant in Array(source):
		if typeof(wave) == TYPE_ARRAY:
			result.append(Array(wave))
	return result

func _log(line: String) -> void:
	log_lines.append(line)
	if log_lines.size() > MAX_LOG_LINES:
		log_lines.pop_front()

func _fail(message: String) -> Dictionary:
	return {"ok": false, "message": message}
