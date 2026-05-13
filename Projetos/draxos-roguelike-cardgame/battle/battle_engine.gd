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
const PHASE_PENDING_COMBAT_CHOICE: String = "escolha_pos_combate"
const PHASE_PENDING_MAINTENANCE_CHOICE: String = "escolha_pos_manutencao"
const PHASE_ENDED: String = "encerrada"

const DEFAULT_MAX_HAND_SIZE: int = 3
const DEFAULT_MANA_PER_TURN: int = 2
const DEFAULT_ENEMY_HEALTH: int = 20
const DEFAULT_DEFENSE_HEALTH: int = 10
const DEFAULT_OBJECTIVE_TURNS: int = 3
const MAX_LOG_LINES: int = 18
const PROMOTE_CHOICE_STATS: String = "promote_stats"
const PROMOTE_CHOICE_INITIATIVE: String = "promote_initiative"
const PROMOTE_CHOICE_DEFENDER: String = "promote_defender"
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
var max_hand_size: int = DEFAULT_MAX_HAND_SIZE
var enemy_commander_enabled: bool = false
var enemy_mana: int = 0
var enemy_mana_per_turn: int = 0
var enemy_hand_count: int = 0
var deck: Array[String] = []
var discard: Array[String] = []
var hand: Array[String] = []
var pending_choices: Array[Dictionary] = []
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
var class_passive_unlocked: bool = false
var class_active_unlocked: bool = false
var class_active_used: bool = false
var flow: int = 0
var ashes: int = 0
var wave_index: int = 0
var waves: Array[Array] = []
var survived_turns: int = 0
var required_survive_turns: int = DEFAULT_OBJECTIVE_TURNS
var required_defense_turns: int = DEFAULT_OBJECTIVE_TURNS
var defense_slot_index: int = 1
var defense_objective_health: int = DEFAULT_DEFENSE_HEALTH
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
	max_hand_size = int(config.get("max_hand_size", encounter.get("max_hand_size", DEFAULT_MAX_HAND_SIZE)))
	enemy_commander_enabled = bool(config.get("enemy_commander_enabled", encounter.get("enemy_commander_enabled", false)))
	enemy_mana_per_turn = int(config.get("enemy_mana_per_turn", encounter.get("enemy_mana_per_turn", DEFAULT_MANA_PER_TURN))) if enemy_commander_enabled else 0
	enemy_mana = int(config.get("enemy_mana", encounter.get("enemy_mana", enemy_mana_per_turn))) if enemy_commander_enabled else 0
	enemy_hand_count = int(config.get("enemy_hand_count", encounter.get("enemy_hand_count", max_hand_size))) if enemy_commander_enabled else 0
	player_health = int(config.get("player_health", _hero_health(catalog.player_hero if catalog != null else null, 20)))
	selected_class_id = str(config.get("class_id", ""))
	class_passive_unlocked = bool(config.get("class_passive_unlocked", false))
	class_active_unlocked = bool(config.get("class_active_unlocked", false))
	class_active_used = false
	flow = 0
	ashes = 0
	turn_number = 1
	boss_summon_index = 0
	boss_summons = _typed_dictionary_array(encounter.get("boss_summons", []))
	wave_index = 0
	waves = _typed_wave_array(encounter.get("waves", []))
	survived_turns = 0
	required_survive_turns = int(encounter.get("survive_turns", DEFAULT_OBJECTIVE_TURNS))
	required_defense_turns = int(encounter.get("defense_turns", DEFAULT_OBJECTIVE_TURNS))
	defense_slot_index = int(encounter.get("defense_slot", 1))
	defense_objective_health = int(encounter.get("defense_health", DEFAULT_DEFENSE_HEALTH))
	shuffle_enabled = bool(config.get("shuffle_deck", true))
	_setup_shuffle(int(config.get("shuffle_seed", 0)), encounter_id)
	outcome = ""
	current_phase = PHASE_MAIN
	log_lines = []
	visual_events = []
	pending_choices = []
	discard = []
	hand = []
	deck = _typed_string_array(deck_ids)
	if deck.is_empty() and catalog != null:
		deck = _typed_string_array(Array(catalog.starter_deck_ids))
	_shuffle_deck(deck)
	enemy_health = int(encounter.get("enemy_health", encounter.get("boss_health", _hero_health(catalog.enemy_hero if catalog != null else null, DEFAULT_ENEMY_HEALTH))))
	player_slots = _empty_slots(int(encounter.get("player_slots_count", 3)))
	enemy_slots = _empty_slots(int(encounter.get("enemy_slots_count", 3)))
	if mode == MODE_DEFENSE_POSITION:
		_setup_defense_objective()
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
		"max_hand_size": max_hand_size,
		"ability_power": _ability_power_bonus(),
		"enemy_commander_enabled": enemy_commander_enabled,
		"enemy_mana": enemy_mana,
		"enemy_mana_per_turn": enemy_mana_per_turn,
		"enemy_hand_count": enemy_hand_count,
		"deck": deck.duplicate(),
		"discard": discard.duplicate(),
		"hand": hand.duplicate(),
		"pending_choices": pending_choices.duplicate(true),
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
		"class_passive_unlocked": class_passive_unlocked,
		"class_active_unlocked": class_active_unlocked,
		"class_active_used": class_active_used,
		"flow": flow,
		"ashes": ashes,
		"wave_index": wave_index,
		"waves_total": waves.size(),
		"survived_turns": survived_turns,
		"required_survive_turns": required_survive_turns,
		"required_defense_turns": required_defense_turns,
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

func get_card_text_context(card_id: String) -> Dictionary:
	var card = _card(card_id)
	if card == null:
		return {}
	var effect: Dictionary = Dictionary(card.effect)
	var context: Dictionary = {
		"ability_power": _ability_power_bonus(),
		"flow": flow
	}
	var action: String = str(effect.get("action", ""))
	if effect.has("amount"):
		var amount: int = int(effect.get("amount", 0)) if str(effect.get("aura", "")) == "ability_power" else _effect_amount(effect)
		if selected_class_id == "arcano" and class_passive_unlocked and action in ["damage", "random_damage"]:
			amount += flow
		context["amount"] = amount
	if effect.has("attack"):
		context["effect_attack"] = _effect_number(effect, "attack")
	if effect.has("health"):
		context["effect_health"] = _effect_number(effect, "health")
	if effect.has("on_death") and typeof(effect.get("on_death")) == TYPE_DICTIONARY:
		var on_death: Dictionary = Dictionary(effect.get("on_death"))
		if on_death.has("amount"):
			context["amount"] = int(on_death.get("amount", 0)) + _ability_power_bonus()
	return context

func can_play_card(card) -> bool:
	return outcome == "" and pending_choices.is_empty() and card != null and int(card.cost) <= mana and not hand.is_empty()

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
		"random_damage":
			return []
		"debuff", "weaken", "snare":
			return _occupied_slot_targets(ENEMY_ID)
		"buff_ally", "buff_all_allies", "promote":
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
		if player_slots[slot_index] != null and bool(Dictionary(player_slots[slot_index]).get("objective", false)):
			return _fail("Objetivo de defesa nao pode ser substituido.")
		_spend_card(hand_index, card)
		_after_card_played()
		if player_slots[slot_index] != null:
			var sacrificed: Dictionary = Dictionary(player_slots[slot_index])
			discard.append(str(sacrificed.get("card_id", "")))
			_handle_unit_death(PLAYER_ID, sacrificed, false)
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

func has_pending_choice() -> bool:
	return not pending_choices.is_empty()

func get_pending_choice() -> Dictionary:
	return pending_choices[0].duplicate(true) if not pending_choices.is_empty() else {}

func get_promote_choices() -> Array[Dictionary]:
	return [
		{"id": PROMOTE_CHOICE_STATS, "display_name": "+1/+1", "text": "A criatura alvo recebe +1/+1 aumentado por Poder de habilidade."},
		{"id": PROMOTE_CHOICE_INITIATIVE, "display_name": "Iniciativa", "text": "A criatura alvo ganha Iniciativa permanente."},
		{"id": PROMOTE_CHOICE_DEFENDER, "display_name": "Defensor", "text": "A criatura alvo ganha Defensor permanente."}
	]

func get_valid_pending_choice_targets() -> Array[Dictionary]:
	if pending_choices.is_empty():
		return []
	var choice: Dictionary = pending_choices[0]
	match str(choice.get("action", "")):
		"weaken":
			return _occupied_slot_targets(ENEMY_ID)
	return []

func resolve_pending_choice(target: Dictionary = {}, option_id: String = "") -> Dictionary:
	if pending_choices.is_empty():
		return _fail("Nenhuma escolha pendente.")
	var choice: Dictionary = pending_choices[0]
	var valid_targets: Array[Dictionary] = get_valid_pending_choice_targets()
	pending_choices.pop_front()
	match str(choice.get("action", "")):
		"promote":
			_resolve_promote_choice(choice, option_id)
		"weaken":
			var chosen_target: Dictionary = target if not target.is_empty() else (valid_targets[0] if not valid_targets.is_empty() else {})
			if chosen_target.is_empty() or not _target_in_options(chosen_target, valid_targets):
				_log("Enfraquecer perdeu efeito: nenhum alvo valido.")
			else:
				_apply_debuff_to_target({"debuff": "weaken", "amount": int(choice.get("amount", 1)) + _ability_power_bonus()}, chosen_target)
				_log("%s aplicou Enfraquecer." % str(choice.get("source_name", "Efeito")))
	_check_outcome()
	if pending_choices.is_empty() and outcome == "" and current_phase in [PHASE_PENDING_COMBAT_CHOICE, PHASE_PENDING_MAINTENANCE_CHOICE]:
		_resume_after_pending_choice()
	return {"ok": true, "message": "Escolha resolvida."}

func get_necromancer_active_choices() -> Array[Dictionary]:
	return [
		{
			"id": NECRO_CHOICE_SLOW,
			"display_name": "Lentidao Sombria",
			"cost_ashes": 2,
			"text": "Uma criatura inimiga nao ataca neste turno.",
			"enabled": selected_class_id == "necromante" and class_active_unlocked and ashes >= 2 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_ROT,
			"display_name": "Podridao Astral",
			"cost_ashes": 2,
			"text": "Uma criatura inimiga perde 1/1 permanente.",
			"enabled": selected_class_id == "necromante" and class_active_unlocked and ashes >= 2 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_CONFUSION,
			"display_name": "Confusao Sepulcral",
			"cost_ashes": 2,
			"text": "Uma criatura inimiga ataca o proprio lado neste turno.",
			"enabled": selected_class_id == "necromante" and class_active_unlocked and ashes >= 2 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_REVIVE_ONE_ONE,
			"display_name": "Reanimar 1/1",
			"cost_ashes": 4,
			"text": "Reanima a ultima criatura do descarte como 1/1.",
			"enabled": selected_class_id == "necromante" and class_active_unlocked and ashes >= 4 and _has_discard_creature() and not _strict_open_slot_targets(PLAYER_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_REVIVE_FULL,
			"display_name": "Reanimar original",
			"cost_ashes": 6,
			"text": "Reanima a ultima criatura do descarte com stats originais.",
			"enabled": selected_class_id == "necromante" and class_active_unlocked and ashes >= 6 and _has_discard_creature() and not _strict_open_slot_targets(PLAYER_ID).is_empty()
		}
	]

func can_use_class_active() -> bool:
	if outcome != "" or class_active_used or not class_active_unlocked:
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
			var amount: int = 1 + flow + _ability_power_bonus()
			var arcane_target: Dictionary = target if not target.is_empty() else _first_enemy_target()
			if arcane_target.is_empty():
				_log("Spell de classe Arcano perdeu efeito: nenhum alvo valido.")
			elif arcane_target.has("slot"):
				_damage_slot(str(arcane_target.get("owner", ENEMY_ID)), int(arcane_target.get("slot", -1)), amount)
			else:
				_damage_hero(str(arcane_target.get("owner", ENEMY_ID)), amount)
			_log("Spell de classe Arcano causou %d de dano." % amount)
		"invocador":
			mana -= 1
			var ally_slot: int = int(target.get("slot", _strongest_ally_slot()))
			var attack_bonus: int = 2 + _ability_power_bonus()
			_buff_slot(PLAYER_ID, ally_slot, attack_bonus, 0, false)
			_log("Spell de classe Invocador concedeu +%d/+0 permanente." % attack_bonus)
		"necromante":
			_resolve_necromancer_active(choice_id, target)
	_check_outcome()
	return {"ok": true, "message": "Spell de classe usada."}

func end_player_turn() -> Dictionary:
	return resolve_combat_cycle()

func resolve_combat_cycle() -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if not pending_choices.is_empty():
		return _fail("Resolva as escolhas pendentes antes do combate.")
	_log("Combate do ciclo %d." % turn_number)
	if outcome == "":
		_resolve_lane_combat_step()
		_check_outcome()
	if outcome == "" and not pending_choices.is_empty():
		current_phase = PHASE_PENDING_COMBAT_CHOICE
		return {"ok": true, "message": "Combate resolvido; escolha pendente."}
	if outcome == "":
		_resolve_maintenance_step()
		_check_outcome()
	if outcome == "" and not pending_choices.is_empty():
		current_phase = PHASE_PENDING_MAINTENANCE_CHOICE
		return {"ok": true, "message": "Manutencao resolvida; escolha pendente."}
	_finish_cycle()
	return {"ok": true, "message": "Ciclo resolvido."}

func _resume_after_pending_choice() -> void:
	if current_phase == PHASE_PENDING_COMBAT_CHOICE:
		_resolve_maintenance_step()
		_check_outcome()
		if outcome == "" and not pending_choices.is_empty():
			current_phase = PHASE_PENDING_MAINTENANCE_CHOICE
			return
	if current_phase == PHASE_PENDING_MAINTENANCE_CHOICE and not pending_choices.is_empty():
		return
	if outcome == "":
		_finish_cycle()

func _finish_cycle() -> void:
	if outcome == "" and mode in [MODE_DEFENSE_POSITION, MODE_SURVIVE_TURNS]:
		survived_turns += 1
		_log("Turnos de objetivo sobrevividos: %d/%d." % [survived_turns, _required_objective_turns()])
		_check_outcome()
	turn_number += 1
	class_active_used = false
	flow = 0
	_clear_temporary_buffs()
	_resolve_start_of_player_turn()
	mana = mana_per_turn + _mana_aura_bonus()
	current_phase = PHASE_MAIN if outcome == "" else PHASE_ENDED

func _resolve_maintenance_step() -> void:
	_log("Manutencao da mesa.")
	if mode == MODE_WAVES and _board_is_clear(ENEMY_ID) and _has_next_wave():
		_spawn_next_wave()
	if outcome == "":
		_resolve_boss_summon()

func get_attack_options(owner_id: String, slot_index: int) -> Array[Dictionary]:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return []
	var opponent_id: String = _opponent_id(owner_id)
	var opposing_slots: Array = _slots_for_owner(opponent_id)
	if slot_index < opposing_slots.size() and opposing_slots[slot_index] != null:
		return [{"owner": opponent_id, "slot": slot_index}]
	var defender_target: Dictionary = _nearest_defender_target(opponent_id, slot_index)
	if not defender_target.is_empty():
		return [defender_target]
	if _can_receive_direct_damage(opponent_id):
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
			var amount: int = _effect_amount(effect)
			if selected_class_id == "arcano" and class_passive_unlocked:
				amount += flow
			var target_data: Dictionary = target if not target.is_empty() else _first_enemy_target()
			if target_data.is_empty():
				_log("%s perdeu efeito: nenhum alvo valido." % card.display_name)
			elif target_data.has("slot"):
				var target_owner: String = str(target_data.get("owner", ENEMY_ID))
				_damage_slot(target_owner, int(target_data.get("slot", -1)), amount)
			else:
				var target_owner: String = str(target_data.get("owner", ENEMY_ID))
				_damage_hero(target_owner, amount)
			_log("%s causou %d de dano." % [card.display_name, amount])
		"random_damage":
			var total: int = _effect_amount(effect)
			if selected_class_id == "arcano" and class_passive_unlocked:
				total += flow
			_resolve_random_damage(total)
			_log("%s distribuiu %d de dano." % [card.display_name, total])
		"debuff", "weaken", "snare":
			var debuff_effect: Dictionary = effect.duplicate()
			debuff_effect["amount"] = _effect_amount(effect)
			_apply_debuff_to_target(debuff_effect, target)
			_log("%s aplicou %s." % [card.display_name, str(effect.get("debuff", "debuff"))])
		"buff_ally":
			var ally_slot: int = int(target.get("slot", _strongest_ally_slot()))
			_buff_slot(PLAYER_ID, ally_slot, _effect_number(effect, "attack"), _effect_number(effect, "health"), bool(effect.get("temporary", false)))
			_log("%s fortaleceu uma criatura aliada." % card.display_name)
		"buff_all_allies":
			for index: int in range(player_slots.size()):
				if player_slots[index] != null:
					_buff_slot(PLAYER_ID, index, _effect_number(effect, "attack"), _effect_number(effect, "health"), bool(effect.get("temporary", false)))
			_log("%s fortaleceu a mesa aliada." % card.display_name)
		"promote":
			pending_choices.append({
				"action": "promote",
				"source_name": card.display_name,
				"target": target.duplicate(),
				"options": get_promote_choices()
			})
			_log("%s aguarda escolha de promocao." % card.display_name)
		_:
			_log("%s foi resolvida sem efeito especial." % card.display_name)

func _spend_card(hand_index: int, card) -> void:
	mana -= int(card.cost)
	var card_id: String = hand[hand_index]
	hand.remove_at(hand_index)
	discard.append(card_id)

func _draw_to_hand_size() -> void:
	while hand.size() < max_hand_size:
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

func _resolve_lane_combat_step() -> void:
	var lane_count: int = max(player_slots.size(), enemy_slots.size())
	for index: int in range(lane_count):
		if outcome != "":
			return
		_resolve_lane(index)

func _resolve_lane(index: int) -> void:
	var player_can_attack: bool = _prepare_lane_attacker(PLAYER_ID, index)
	var enemy_can_attack: bool = _prepare_lane_attacker(ENEMY_ID, index)
	var player_unit: Dictionary = _slot_occupant(PLAYER_ID, index)
	var enemy_unit: Dictionary = _slot_occupant(ENEMY_ID, index)
	if player_unit.is_empty() and enemy_unit.is_empty():
		return
	if not player_unit.is_empty() and not enemy_unit.is_empty():
		_resolve_opposed_lane(index, player_can_attack, enemy_can_attack)
		return
	if not player_unit.is_empty() and player_can_attack:
		_resolve_open_lane_attack(PLAYER_ID, index)
	elif not enemy_unit.is_empty() and enemy_can_attack:
		_resolve_open_lane_attack(ENEMY_ID, index)

func _resolve_open_lane_attack(owner_id: String, slot_index: int) -> void:
	var options: Array[Dictionary] = get_attack_options(owner_id, slot_index)
	if options.is_empty():
		return
	_resolve_attack(owner_id, slot_index, options[0])

func _resolve_opposed_lane(index: int, player_can_attack: bool, enemy_can_attack: bool) -> void:
	var player_unit: Dictionary = _slot_occupant(PLAYER_ID, index)
	var enemy_unit: Dictionary = _slot_occupant(ENEMY_ID, index)
	if player_unit.is_empty() or enemy_unit.is_empty():
		return
	var player_damage: int = int(player_unit.get("attack", 0)) if player_can_attack else 0
	var enemy_damage: int = int(enemy_unit.get("attack", 0)) if enemy_can_attack else 0
	var player_initiative: bool = bool(player_unit.get("iniciativa", false)) and player_can_attack
	var enemy_initiative: bool = bool(enemy_unit.get("iniciativa", false)) and enemy_can_attack
	if player_initiative and not enemy_initiative:
		_damage_slot(ENEMY_ID, index, player_damage)
		if _slot_occupant(ENEMY_ID, index).is_empty():
			_log("%s usou Iniciativa na lane %d." % [str(player_unit.get("name", "Criatura")), index + 1])
			return
		_damage_slot(PLAYER_ID, index, enemy_damage)
		_log("Lane %d trocou dano com Iniciativa aliada." % [index + 1])
		return
	if enemy_initiative and not player_initiative:
		_damage_slot(PLAYER_ID, index, enemy_damage)
		if _slot_occupant(PLAYER_ID, index).is_empty():
			_log("%s usou Iniciativa na lane %d." % [str(enemy_unit.get("name", "Criatura")), index + 1])
			return
		_damage_slot(ENEMY_ID, index, player_damage)
		_log("Lane %d trocou dano com Iniciativa inimiga." % [index + 1])
		return
	_deal_simultaneous_slot_damage(index, player_damage, enemy_damage)
	_log("Lane %d resolveu dano simultaneo." % [index + 1])

func _prepare_lane_attacker(owner_id: String, slot_index: int) -> bool:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return false
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if bool(occupant.get("objective", false)):
		return false
	if int(occupant.get("slow_turns", 0)) > 0:
		occupant["slow_turns"] = int(occupant.get("slow_turns", 0)) - 1
		slots[slot_index] = occupant
		_set_slots_for_owner(owner_id, slots)
		_log("%s perdeu o ataque por Lentidao." % str(occupant.get("name", "Criatura")))
		return false
	if int(occupant.get("confusion_turns", 0)) > 0:
		occupant["confusion_turns"] = int(occupant.get("confusion_turns", 0)) - 1
		slots[slot_index] = occupant
		_set_slots_for_owner(owner_id, slots)
		var confused_target: Dictionary = _first_same_side_target(owner_id, slot_index)
		if not confused_target.is_empty():
			_resolve_attack(owner_id, slot_index, confused_target)
			_log("%s atacou em Confusao." % str(occupant.get("name", "Criatura")))
		return false
	return true

func _deal_simultaneous_slot_damage(lane_index: int, player_damage: int, enemy_damage: int) -> void:
	var player_unit: Dictionary = _slot_occupant(PLAYER_ID, lane_index)
	var enemy_unit: Dictionary = _slot_occupant(ENEMY_ID, lane_index)
	if player_unit.is_empty() or enemy_unit.is_empty():
		return
	player_unit["health"] = int(player_unit.get("health", 0)) - enemy_damage
	enemy_unit["health"] = int(enemy_unit.get("health", 0)) - player_damage
	_store_or_destroy_lane_unit(PLAYER_ID, lane_index, player_unit)
	_store_or_destroy_lane_unit(ENEMY_ID, lane_index, enemy_unit)

func _store_or_destroy_lane_unit(owner_id: String, slot_index: int, occupant: Dictionary) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if int(occupant.get("health", 0)) <= 0:
		_log("%s foi destruido." % str(occupant.get("name", "Criatura")))
		var card_id: String = str(occupant.get("card_id", ""))
		var revived: Dictionary = _handle_unit_death(owner_id, occupant, true)
		if revived.is_empty() and owner_id == PLAYER_ID and card_id != "":
			discard.append(card_id)
		slots[slot_index] = revived if not revived.is_empty() else null
	else:
		slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

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
		var card_id: String = str(occupant.get("card_id", ""))
		var revived: Dictionary = _handle_unit_death(owner_id, occupant, true)
		if revived.is_empty() and owner_id == PLAYER_ID and card_id != "":
			discard.append(card_id)
		slots[slot_index] = revived if not revived.is_empty() else null
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
	if mode == MODE_DEFENSE_POSITION and not _defense_objective_alive():
		outcome = "derrota"
		current_phase = PHASE_ENDED
		return
	if _enemy_hero_is_objective() and enemy_health <= 0:
		outcome = "vitoria"
		current_phase = PHASE_ENDED
		return
	if mode == MODE_CLEAR_BOARD and _board_is_clear(ENEMY_ID):
		outcome = "vitoria"
		current_phase = PHASE_ENDED
	if mode == MODE_WAVES and _board_is_clear(ENEMY_ID) and not _has_next_wave():
		outcome = "vitoria"
		current_phase = PHASE_ENDED
	if mode == MODE_DEFENSE_POSITION and _defense_objective_alive() and survived_turns >= required_defense_turns:
		outcome = "vitoria"
		current_phase = PHASE_ENDED
	if mode == MODE_SURVIVE_TURNS and survived_turns >= required_survive_turns:
		outcome = "vitoria"
		current_phase = PHASE_ENDED

func _board_is_clear(owner_id: String) -> bool:
	for occupant: Variant in _slots_for_owner(owner_id):
		if occupant != null:
			return false
	return true

func _setup_defense_objective() -> void:
	if player_slots.is_empty():
		return
	var safe_slot: int = clampi(defense_slot_index, 0, player_slots.size() - 1)
	defense_slot_index = safe_slot
	player_slots[safe_slot] = {
		"owner": PLAYER_ID,
		"card_id": "",
		"name": "Objetivo de Defesa",
		"attack": 0,
		"health": defense_objective_health,
		"max_health": defense_objective_health,
		"ready": false,
		"keywords": [],
		"iniciativa": false,
		"regeneracao": false,
		"defensor": false,
		"reviver": false,
		"revive_marker": false,
		"objective": true,
		"slow_turns": 0,
		"curse_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 0
	}

func _defense_objective_alive() -> bool:
	if defense_slot_index < 0 or defense_slot_index >= player_slots.size() or player_slots[defense_slot_index] == null:
		return false
	return bool(Dictionary(player_slots[defense_slot_index]).get("objective", false))

func _required_objective_turns() -> int:
	return required_defense_turns if mode == MODE_DEFENSE_POSITION else required_survive_turns

func _can_receive_direct_damage(owner_id: String) -> bool:
	return owner_id == PLAYER_ID or _enemy_hero_is_objective()

func _enemy_hero_is_objective() -> bool:
	return mode in [MODE_DUEL, MODE_SUMMONER_BOSS]

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
		"iniciativa": card.has_keyword("iniciativa"),
		"regeneracao": card.has_keyword("regeneracao"),
		"defensor": card.has_keyword("defensor"),
		"reviver": card.has_keyword("reviver"),
		"revive_marker": false,
		"slow_turns": 0,
		"curse_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 0
	}

func _after_card_played() -> void:
	if selected_class_id == "arcano" and class_passive_unlocked:
		flow += 1

func _resolve_on_enter(card) -> void:
	var effect: Dictionary = Dictionary(card.effect)
	var on_enter: Dictionary = Dictionary(effect.get("on_enter", {}))
	match str(on_enter.get("action", "")):
		"gain_mana":
			mana += int(on_enter.get("amount", 0))
			_log("%s gerou %d de mana neste turno." % [card.display_name, int(on_enter.get("amount", 0))])

func _apply_summon_passive(_slot_index: int) -> void:
	if selected_class_id != "invocador" or not class_passive_unlocked:
		return
	var target_slot: int = _strongest_ally_slot()
	if target_slot >= 0:
		_buff_slot(PLAYER_ID, target_slot, 1, 0, false)
		_log("Comandante de Campo concedeu +1/+0 permanente.")

func _resolve_necromancer_active(choice_id: String = "", target: Dictionary = {}) -> void:
	if choice_id == NECRO_CHOICE_SLOW:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "slow", "amount": 1 + _ability_power_bonus()}, target)
		_log("Ritual das Sombras I aplicou Lentidao.")
	elif choice_id == NECRO_CHOICE_ROT:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "rot", "amount": 1 + _ability_power_bonus()}, target)
		_log("Ritual das Sombras I aplicou Podridao.")
	elif choice_id == NECRO_CHOICE_CONFUSION:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "confusion", "amount": 1 + _ability_power_bonus()}, target)
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
		_apply_debuff_to_target({"debuff": "rot", "amount": 1 + _ability_power_bonus()}, _first_enemy_target())
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

func _handle_unit_death(owner_id: String, occupant: Dictionary, allow_revive: bool = true) -> Dictionary:
	if bool(occupant.get("objective", false)):
		return {}
	var card = _card(str(occupant.get("card_id", "")))
	if card != null:
		var on_death: Dictionary = Dictionary(Dictionary(card.effect).get("on_death", {}))
		if str(on_death.get("action", "")) == "damage":
			_damage_first_enemy(int(on_death.get("amount", 0)) + _ability_power_bonus())
		elif str(on_death.get("action", "")) in ["debuff", "weaken"]:
			_queue_on_death_debuff(card.display_name, on_death)
	if selected_class_id == "necromante" and class_passive_unlocked:
		var gained: int = 1
		if card != null:
			var on_death: Dictionary = Dictionary(Dictionary(card.effect).get("on_death", {}))
			if str(on_death.get("action", "")) == "gain_ashes":
				gained = int(on_death.get("amount", gained))
		ashes += gained
		_log("Colheita Sombria gerou %d Cinza(s)." % gained)
	if allow_revive and card != null and card.has_keyword("reviver") and not bool(occupant.get("revive_marker", false)):
		var revived: Dictionary = _build_occupant(card, owner_id, false)
		revived["revive_marker"] = true
		_log("%s reviveu com um marcador." % str(occupant.get("name", "Criatura")))
		return revived
	return {}

func _queue_on_death_debuff(source_name: String, effect: Dictionary) -> void:
	var debuff_name: String = str(effect.get("debuff", ""))
	if debuff_name == "weaken":
		pending_choices.append({
			"action": "weaken",
			"source_name": source_name,
			"amount": int(effect.get("amount", 1))
		})
		_log("%s aguarda alvo para Enfraquecer." % source_name)
	else:
		_apply_debuff_to_target(effect, _first_enemy_target())

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
		"rot", "weaken":
			occupant["attack"] = max(0, int(occupant.get("attack", 0)) - amount)
			occupant["health"] = int(occupant.get("health", 0)) - amount
			occupant["max_health"] = max(1, int(occupant.get("max_health", 1)) - amount)
		"snare":
			occupant["slow_turns"] = max(int(occupant.get("slow_turns", 0)), amount)
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
	return _ability_power_bonus()

func _ability_power_bonus() -> int:
	var bonus: int = 0
	for occupant: Variant in player_slots:
		if occupant == null:
			continue
		var card = _card(str(Dictionary(occupant).get("card_id", "")))
		if card == null:
			continue
		var effect: Dictionary = Dictionary(card.effect)
		if str(effect.get("aura", "")) in ["spell_damage", "ability_power"]:
			bonus += int(effect.get("amount", 0))
	return bonus

func _effect_amount(effect: Dictionary) -> int:
	return int(effect.get("amount", effect.get("damage", 0))) + _ability_power_bonus()

func _effect_number(effect: Dictionary, key: String) -> int:
	var base: int = int(effect.get(key, 0))
	if base == 0:
		return 0
	return base + _ability_power_bonus()

func _resolve_random_damage(total: int) -> void:
	for _point: int in range(max(0, total)):
		var targets: Array[Dictionary] = _random_damage_targets()
		if targets.is_empty():
			return
		var target: Dictionary = targets[_rng.randi_range(0, targets.size() - 1)]
		if target.has("slot"):
			_damage_slot(str(target.get("owner", ENEMY_ID)), int(target.get("slot", -1)), 1)
		else:
			_damage_hero(str(target.get("owner", ENEMY_ID)), 1)

func _random_damage_targets() -> Array[Dictionary]:
	var targets: Array[Dictionary] = _occupied_slot_targets(ENEMY_ID)
	if _enemy_hero_is_objective():
		targets.append({"owner": ENEMY_ID, "hero": true})
	return targets

func _resolve_promote_choice(choice: Dictionary, option_id: String) -> void:
	var target: Dictionary = Dictionary(choice.get("target", {}))
	var slot_index: int = int(target.get("slot", -1))
	if slot_index < 0 or slot_index >= player_slots.size() or player_slots[slot_index] == null:
		_log("Promover perdeu efeito: alvo ausente.")
		return
	match option_id:
		PROMOTE_CHOICE_INITIATIVE:
			_add_keyword_to_slot(PLAYER_ID, slot_index, "iniciativa")
			_log("Promover concedeu Iniciativa.")
		PROMOTE_CHOICE_DEFENDER:
			_add_keyword_to_slot(PLAYER_ID, slot_index, "defensor")
			_log("Promover concedeu Defensor.")
		_:
			var amount: int = 1 + _ability_power_bonus()
			_buff_slot(PLAYER_ID, slot_index, amount, amount, false)
			_log("Promover concedeu +%d/+%d." % [amount, amount])

func _add_keyword_to_slot(owner_id: String, slot_index: int, keyword: String) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	var keywords: Array = Array(occupant.get("keywords", []))
	if not keywords.has(keyword):
		keywords.append(keyword)
	occupant["keywords"] = keywords
	match keyword:
		"iniciativa":
			occupant["iniciativa"] = true
		"defensor":
			occupant["defensor"] = true
		"reviver":
			occupant["reviver"] = true
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _nearest_defender_target(owner_id: String, lane_index: int) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	var best_index: int = -1
	var best_distance: int = 99999
	for index: int in range(slots.size()):
		if slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(slots[index])
		if not bool(occupant.get("defensor", false)):
			continue
		var distance: int = absi(index - lane_index)
		if distance < best_distance or (distance == best_distance and (best_index < 0 or index < best_index)):
			best_distance = distance
			best_index = index
	if best_index < 0:
		return {}
	return {"owner": owner_id, "slot": best_index}

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
	if _enemy_hero_is_objective():
		return {"owner": ENEMY_ID, "hero": true}
	return {}

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

func _slot_occupant(owner_id: String, slot_index: int) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return {}
	return Dictionary(slots[slot_index])

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
