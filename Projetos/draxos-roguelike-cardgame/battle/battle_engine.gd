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
const NECRO_CHOICE_ROT: String = "necro_rot"
const NECRO_CHOICE_ATTACK_TWO: String = "necro_attack_two"
const NECRO_CHOICE_LIGHTNING: String = "necro_lightning"
const NECRO_CHOICE_REVIVE_ONE_ONE: String = "necro_revive_one_one"
const NECRO_CHOICE_ROT_TWO: String = "necro_rot_two"
const NECRO_CHOICE_ATTACK_FOUR: String = "necro_attack_four"
const NECRO_CHOICE_LIGHTNING_MAJOR: String = "necro_lightning_major"
const COMBAT_STAGE_INITIATIVE_FRONT: String = "Iniciativa - Frente"
const COMBAT_STAGE_INITIATIVE_OVERFLOW: String = "Iniciativa - Sobra"
const COMBAT_STAGE_NORMAL_FRONT: String = "Combate - Frente"
const COMBAT_STAGE_NORMAL_OVERFLOW: String = "Combate - Sobra"

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
var enemy_deck: Array[String] = []
var enemy_discard: Array[String] = []
var enemy_hand: Array[String] = []
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
var class_active_level: int = 0
var class_active_used: bool = false
var invocador_passive_triggered: bool = false
var flow: int = 0
var ashes: int = 0
var temporary_ability_power_bonus: int = 0
var card_upgrade_counts: Dictionary = {}
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
	class_active_level = int(config.get("class_active_level", 0))
	if selected_class_id == "necromante" and class_active_unlocked and class_active_level <= 0:
		class_active_level = 1
	class_active_used = false
	flow = 0
	ashes = 0
	temporary_ability_power_bonus = 0
	card_upgrade_counts = Dictionary(config.get("card_upgrade_counts", {}))
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
	deck = _effective_deck_ids(_typed_string_array(deck_ids))
	if deck.is_empty() and catalog != null:
		deck = _typed_string_array(Array(catalog.starter_deck_ids))
	_shuffle_deck(deck)
	enemy_discard = []
	enemy_hand = []
	enemy_deck = []
	if enemy_commander_enabled:
		enemy_deck = _typed_string_array(Array(config.get("enemy_deck", encounter.get("enemy_deck", []))))
		if enemy_deck.is_empty():
			enemy_deck = _enemy_deck_from_starting_slots(encounter)
	_shuffle_deck(enemy_deck)
	enemy_health = int(encounter.get("enemy_health", encounter.get("boss_health", _hero_health(catalog.enemy_hero if catalog != null else null, DEFAULT_ENEMY_HEALTH))))
	player_slots = _empty_slots(int(encounter.get("player_slots_count", 3)))
	enemy_slots = _empty_slots(int(encounter.get("enemy_slots_count", 3)))
	if mode == MODE_DEFENSE_POSITION:
		_setup_defense_objective()
	_draw_to_hand_size()
	if _uses_wave_director() and not waves.is_empty():
		_spawn_next_wave()
	else:
		_spawn_starting_enemies(Array(config.get("starting_enemy_slots", encounter.get("starting_enemy_slots", []))))
	if enemy_commander_enabled:
		_draw_enemy_to_hand_size()
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
		"temporary_ability_power": temporary_ability_power_bonus,
		"enemy_commander_enabled": enemy_commander_enabled,
		"enemy_mana": enemy_mana,
		"enemy_mana_per_turn": enemy_mana_per_turn,
		"enemy_hand_count": enemy_hand.size() if enemy_commander_enabled else 0,
		"enemy_hand_target_size": enemy_hand_count,
		"enemy_deck": enemy_deck.duplicate(),
		"enemy_discard": enemy_discard.duplicate(),
		"enemy_hand": enemy_hand.duplicate(),
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
		"class_active_level": class_active_level,
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
		if selected_class_id == "arcano" and class_passive_unlocked and action in ["damage", "random_damage", "adjacent_damage"]:
			amount += flow
		context["amount"] = amount
	if effect.has("primary_bonus"):
		context["primary_amount"] = int(context.get("amount", _effect_amount(effect))) + int(effect.get("primary_bonus", 0))
	if effect.has("mana"):
		context["mana"] = int(effect.get("mana", 0))
	if effect.has("temporary_ability_power"):
		context["temporary_ability_power"] = int(effect.get("temporary_ability_power", 0))
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

func can_play_card_without_target(hand_index: int) -> bool:
	if hand_index < 0 or hand_index >= hand.size():
		return false
	var card = _card(hand[hand_index])
	if not can_play_card(card) or card.occupies_slot():
		return false
	return _card_can_resolve_without_target(card)

func get_valid_card_targets(hand_index: int) -> Array[Dictionary]:
	if outcome != "" or hand_index < 0 or hand_index >= hand.size():
		return _empty_targets()
	var card = _card(hand[hand_index])
	if not can_play_card(card):
		return _empty_targets()
	if card.occupies_slot():
		return _summon_slot_targets()
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage":
			var targets: Array[Dictionary] = []
			targets.append_array(_occupied_slot_targets(PLAYER_ID))
			targets.append_array(_occupied_slot_targets(ENEMY_ID))
			targets.append_array(_hero_targets())
			return targets
		"adjacent_damage":
			return _occupied_slot_targets(ENEMY_ID)
		"random_damage":
			var area_targets: Array[Dictionary] = []
			if not _area_damage_targets(ENEMY_ID).is_empty():
				area_targets.append(_board_area_target(ENEMY_ID))
			return area_targets
		"debuff", "weaken", "snare", "multi_debuff", "punish_snared":
			return _occupied_slot_targets(ENEMY_ID)
		"buff_ally", "promote":
			return _occupied_slot_targets(PLAYER_ID)
		"buff_all_allies", "gain_mana":
			return [{}]
	return _empty_targets()

func can_play_card_on_target(hand_index: int, target: Dictionary) -> bool:
	if target.is_empty():
		if hand_index < 0 or hand_index >= hand.size():
			return false
		var card = _card(hand[hand_index])
		if card == null:
			return false
		if not _card_can_resolve_without_target(card):
			return false
		return can_play_card(card)
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
	if target.is_empty() and str(Dictionary(card.effect).get("action", "")) == "random_damage":
		return _fail("Alvo invalido.")
	if not target.is_empty() and not can_play_card_on_target(hand_index, target):
		return _fail("Alvo invalido.")
	if card.occupies_slot():
		var slot_index: int = int(target.get("slot", _first_open_slot(player_slots)))
		if slot_index < 0 or slot_index >= player_slots.size():
			return _fail("Slot invalido.")
		if player_slots[slot_index] != null and bool(Dictionary(player_slots[slot_index]).get("objective", false)):
			return _fail("Objetivo de defesa nao pode ser substituido.")
		if player_slots[slot_index] != null and not bool(target.get("confirm_sacrifice", false)):
			var sacrificed_preview: Dictionary = Dictionary(player_slots[slot_index])
			return {
				"ok": false,
				"requires_confirmation": true,
				"confirmation": "sacrifice",
				"message": "Sacrificar %s para invocar %s?" % [str(sacrificed_preview.get("name", "Criatura")), str(card.display_name)],
				"hand_index": hand_index,
				"target": {"owner": PLAYER_ID, "slot": slot_index},
				"sacrificed_name": str(sacrificed_preview.get("name", "Criatura")),
				"summon_name": str(card.display_name)
			}
		_spend_card(hand_index, card)
		_after_card_played()
		if player_slots[slot_index] != null:
			var sacrificed: Dictionary = Dictionary(player_slots[slot_index])
			player_slots[slot_index] = null
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
		return _empty_targets()
	var choice: Dictionary = pending_choices[0]
	match str(choice.get("action", "")):
		"weaken":
			return _occupied_slot_targets(ENEMY_ID)
	return _empty_targets()

func resolve_pending_choice(target: Dictionary = {}, option_id: String = "") -> Dictionary:
	if pending_choices.is_empty():
		return _fail("Nenhuma escolha pendente.")
	var choice: Dictionary = pending_choices[0]
	var valid_targets: Array[Dictionary] = get_valid_pending_choice_targets()
	pending_choices.pop_front()
	match str(choice.get("action", "")):
		"promote":
			_resolve_promote_choice(choice, option_id)
			var remaining_picks: int = int(choice.get("remaining_picks", 1)) - 1
			if remaining_picks > 0:
				var remaining_options: Array = []
				for option: Dictionary in Array(choice.get("options", [])):
					if str(option.get("id", "")) != option_id:
						remaining_options.append(option)
				if not remaining_options.is_empty():
					choice["remaining_picks"] = remaining_picks
					choice["options"] = remaining_options
					pending_choices.push_front(choice)
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
	var active_ready: bool = selected_class_id == "necromante" and class_active_unlocked and class_active_level >= 1
	var choices: Array[Dictionary] = [
		{
			"id": NECRO_CHOICE_ROT,
			"display_name": "Podridao Astral",
			"cost_ashes": 2,
			"text": "Uma criatura inimiga perde 1/1 permanente.",
			"enabled": active_ready and ashes >= 2 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_ATTACK_TWO,
			"display_name": "Furia das Cinzas",
			"cost_ashes": 2,
			"text": "Uma criatura aliada ganha +2 ATK ate o final do turno.",
			"enabled": active_ready and ashes >= 2 and not _occupied_slot_targets(PLAYER_ID).is_empty()
		},
		{
			"id": NECRO_CHOICE_LIGHTNING,
			"display_name": "Raio das Cinzas",
			"cost_ashes": 2,
			"text": "Causa 2 de dano diretamente ao heroi inimigo.",
			"enabled": active_ready and ashes >= 2 and _enemy_hero_is_objective()
		}
	]
	if class_active_level >= 2:
		choices.append({
			"id": NECRO_CHOICE_REVIVE_ONE_ONE,
			"display_name": "Reanimar 1/1",
			"cost_ashes": 4,
			"text": "Reanima a ultima criatura do descarte como 1/1.",
			"enabled": active_ready and ashes >= 4 and _has_discard_creature() and not _strict_open_slot_targets(PLAYER_ID).is_empty()
		})
		choices.append({
			"id": NECRO_CHOICE_ROT_TWO,
			"display_name": "Podridao Profunda",
			"cost_ashes": 4,
			"text": "Uma criatura inimiga perde 2/2 permanente.",
			"enabled": active_ready and ashes >= 4 and not _occupied_slot_targets(ENEMY_ID).is_empty()
		})
		choices.append({
			"id": NECRO_CHOICE_ATTACK_FOUR,
			"display_name": "Furia das Cinzas Maior",
			"cost_ashes": 4,
			"text": "Uma criatura aliada ganha +4 ATK ate o final do turno.",
			"enabled": active_ready and ashes >= 4 and not _occupied_slot_targets(PLAYER_ID).is_empty()
		})
		choices.append({
			"id": NECRO_CHOICE_LIGHTNING_MAJOR,
			"display_name": "Raio das Cinzas Maior",
			"cost_ashes": 4,
			"text": "Causa 4 de dano diretamente ao heroi inimigo.",
			"enabled": active_ready and ashes >= 4 and _enemy_hero_is_objective()
		})
	return choices

func can_use_class_active() -> bool:
	if outcome != "" or class_active_used or not class_active_unlocked:
		return false
	match selected_class_id:
		"arcano":
			return mana >= 1
		"invocador":
			return mana >= 1 and _first_ally_slot() >= 0
		"necromante":
			return class_active_level >= 1 and ashes >= 2
	return false

func get_valid_class_active_targets(choice_id: String = "") -> Array[Dictionary]:
	if not can_use_class_active():
		return _empty_targets()
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
				NECRO_CHOICE_ROT:
					if ashes < 2:
						return _empty_targets()
					return _occupied_slot_targets(ENEMY_ID)
				NECRO_CHOICE_ATTACK_TWO:
					if ashes < 2:
						return _empty_targets()
					return _occupied_slot_targets(PLAYER_ID)
				NECRO_CHOICE_REVIVE_ONE_ONE:
					if class_active_level < 2 or ashes < 4 or not _has_discard_creature():
						return _empty_targets()
					return _strict_open_slot_targets(PLAYER_ID)
				NECRO_CHOICE_ROT_TWO:
					if class_active_level < 2 or ashes < 4:
						return _empty_targets()
					return _occupied_slot_targets(ENEMY_ID)
				NECRO_CHOICE_ATTACK_FOUR:
					if class_active_level < 2 or ashes < 4:
						return _empty_targets()
					return _occupied_slot_targets(PLAYER_ID)
				NECRO_CHOICE_LIGHTNING:
					if ashes < 2 or not _enemy_hero_is_objective():
						return _empty_targets()
					return [{"owner": ENEMY_ID, "hero": true}]
				NECRO_CHOICE_LIGHTNING_MAJOR:
					if class_active_level < 2 or ashes < 4 or not _enemy_hero_is_objective():
						return _empty_targets()
					return [{"owner": ENEMY_ID, "hero": true}]
	return _empty_targets()

func can_use_class_active_on_target(target: Dictionary, choice_id: String = "") -> bool:
	if target.is_empty():
		return false
	return _target_in_options(_normalized_target(target, PLAYER_ID), get_valid_class_active_targets(choice_id))

func use_class_active(target: Dictionary = {}, choice_id: String = "") -> Dictionary:
	if not can_use_class_active():
		return _fail("Spell de classe indisponivel.")
	if selected_class_id == "necromante" and (target.is_empty() or choice_id == ""):
		return _fail("Escolha de Cinzas invalida.")
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
	visual_events = []
	_log("Combate do ciclo %d." % turn_number)
	if outcome == "":
		_resolve_staged_combat_step()
		_resolve_end_of_combat_regeneration()
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
	_resolve_enemy_preparation_step()
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
		_resolve_enemy_preparation_step()
		_finish_cycle()

func _resolve_enemy_preparation_step() -> void:
	if outcome != "":
		return
	_resolve_enemy_turn_actions()
	_check_outcome()

func _finish_cycle() -> void:
	if outcome == "" and mode in [MODE_DEFENSE_POSITION, MODE_SURVIVE_TURNS]:
		survived_turns += 1
		_log("Turnos de objetivo sobrevividos: %d/%d." % [survived_turns, _required_objective_turns()])
		_check_outcome()
	turn_number += 1
	class_active_used = false
	invocador_passive_triggered = false
	flow = 0
	temporary_ability_power_bonus = 0
	_clear_temporary_buffs()
	_resolve_start_of_player_turn()
	mana = mana_per_turn + _mana_aura_bonus()
	if enemy_commander_enabled:
		enemy_mana = enemy_mana_per_turn
		_draw_enemy_to_hand_size()
	current_phase = PHASE_MAIN if outcome == "" else PHASE_ENDED

func _resolve_maintenance_step() -> void:
	_log("Manutencao da mesa.")
	if _uses_wave_director() and _board_is_clear(ENEMY_ID) and _has_next_wave():
		_spawn_next_wave()
	if outcome == "":
		_resolve_boss_summon()

func get_attack_options(owner_id: String, slot_index: int) -> Array[Dictionary]:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return _empty_targets()
	var front_target: Dictionary = _front_attack_target(owner_id, slot_index)
	if not front_target.is_empty():
		return [front_target]
	var overflow_target: Dictionary = _overflow_attack_target(owner_id, slot_index)
	if not overflow_target.is_empty():
		return [overflow_target]
	return _empty_targets()

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

func get_valid_move_targets(owner_id: String, from_slot: int) -> Array[Dictionary]:
	if outcome != "" or not pending_choices.is_empty() or owner_id != PLAYER_ID:
		return _empty_targets()
	var slots: Array = _slots_for_owner(owner_id)
	if from_slot < 0 or from_slot >= slots.size() or slots[from_slot] == null:
		return _empty_targets()
	var occupant: Dictionary = Dictionary(slots[from_slot])
	if bool(occupant.get("objective", false)) or bool(occupant.get("moved_this_turn", false)):
		return _empty_targets()
	var targets: Array[Dictionary] = []
	for target_slot: int in [from_slot - 1, from_slot + 1]:
		if target_slot < 0 or target_slot >= slots.size():
			continue
		if slots[target_slot] == null:
			targets.append({"owner": owner_id, "slot": target_slot})
			continue
		var target_occupant: Dictionary = Dictionary(slots[target_slot])
		if bool(target_occupant.get("objective", false)) or bool(target_occupant.get("moved_this_turn", false)):
			continue
		targets.append({"owner": owner_id, "slot": target_slot})
	return targets

func can_move_unit(owner_id: String, from_slot: int, to_slot: int) -> bool:
	return _target_in_options({"owner": owner_id, "slot": to_slot}, get_valid_move_targets(owner_id, from_slot))

func move_unit(owner_id: String, from_slot: int, to_slot: int) -> Dictionary:
	if not can_move_unit(owner_id, from_slot, to_slot):
		return _fail("Movimento invalido.")
	var slots: Array = _slots_for_owner(owner_id)
	var occupant: Dictionary = Dictionary(slots[from_slot])
	occupant["moved_this_turn"] = true
	if slots[to_slot] == null:
		slots[from_slot] = null
		slots[to_slot] = occupant
		_log("%s moveu do slot %d para o slot %d." % [str(occupant.get("name", "Criatura")), from_slot + 1, to_slot + 1])
	else:
		var target_occupant: Dictionary = Dictionary(slots[to_slot])
		target_occupant["moved_this_turn"] = true
		slots[from_slot] = target_occupant
		slots[to_slot] = occupant
		_log("%s e %s trocaram os slots %d e %d." % [str(occupant.get("name", "Criatura")), str(target_occupant.get("name", "Criatura")), from_slot + 1, to_slot + 1])
	_set_slots_for_owner(owner_id, slots)
	return {"ok": true, "message": "Criatura movida."}

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
		"adjacent_damage":
			var amount: int = _effect_amount(effect)
			if selected_class_id == "arcano" and class_passive_unlocked:
				amount += flow
			var target_slot: int = int(target.get("slot", -1))
			var target_owner: String = str(target.get("owner", ENEMY_ID))
			if target_slot < 0:
				_log("%s perdeu efeito: alvo invalido." % card.display_name)
				return
			for slot_index: int in [target_slot - 1, target_slot, target_slot + 1]:
				if slot_index < 0 or slot_index >= _slots_for_owner(target_owner).size():
					continue
				var slot_damage: int = amount + (int(effect.get("primary_bonus", 0)) if slot_index == target_slot else 0)
				_damage_slot(target_owner, slot_index, slot_damage)
			_log("%s explodiu o slot %d e adjacentes." % [card.display_name, target_slot + 1])
		"random_damage":
			var total: int = _effect_amount(effect)
			if selected_class_id == "arcano" and class_passive_unlocked:
				total += flow
			if str(target.get("area", "")) != "board":
				_log("%s perdeu efeito: alvo de area invalido." % card.display_name)
				return
			_resolve_random_damage(total, str(target.get("owner", ENEMY_ID)))
			_log("%s distribuiu %d de dano." % [card.display_name, total])
		"debuff", "weaken", "snare":
			var debuff_effect: Dictionary = effect.duplicate()
			debuff_effect["amount"] = _effect_amount(effect)
			_apply_debuff_to_target(debuff_effect, target)
			_log("%s aplicou %s." % [card.display_name, str(effect.get("debuff", "debuff"))])
		"multi_debuff":
			if bool(effect.get("snare", false)):
				_apply_debuff_to_target({"debuff": "snare", "amount": int(effect.get("snare_amount", 1))}, target)
			if int(effect.get("weaken_amount", 0)) > 0:
				_apply_debuff_to_target({"debuff": "weaken", "amount": int(effect.get("weaken_amount", 0)) + _ability_power_bonus()}, target)
			if bool(effect.get("remove_keywords", false)):
				_remove_keywords_from_target(target)
			_log("%s prendeu o alvo." % card.display_name)
		"punish_snared":
			var amount: int = int(effect.get("snared_amount", effect.get("amount", 1))) if _target_is_snared(target) else int(effect.get("amount", 1))
			_apply_debuff_to_target({"debuff": "weaken", "amount": amount + _ability_power_bonus()}, target)
			_log("%s puniu a criatura alvo." % card.display_name)
		"buff_ally":
			var ally_slot: int = int(target.get("slot", _strongest_ally_slot()))
			_buff_slot(PLAYER_ID, ally_slot, _effect_number(effect, "attack"), _effect_number(effect, "health"), bool(effect.get("temporary", false)))
			_log("%s fortaleceu uma criatura aliada." % card.display_name)
		"buff_all_allies":
			for index: int in range(player_slots.size()):
				if player_slots[index] != null:
					_buff_slot(PLAYER_ID, index, _effect_number(effect, "attack"), _effect_number(effect, "health"), bool(effect.get("temporary", false)))
			_log("%s fortaleceu a mesa aliada." % card.display_name)
		"gain_mana":
			var mana_gained: int = int(effect.get("mana", effect.get("amount", 0)))
			mana += mana_gained
			temporary_ability_power_bonus += int(effect.get("temporary_ability_power", 0))
			_log("%s gerou %d mana." % [card.display_name, mana_gained])
		"promote":
			if int(effect.get("picks", 1)) >= 3:
				_resolve_promote_all(target, _effect_number(effect, "attack"), _effect_number(effect, "health"))
				_log("%s concedeu todos os bonus." % card.display_name)
			else:
				pending_choices.append({
					"action": "promote",
					"source_name": card.display_name,
					"target": target.duplicate(),
					"attack": _effect_number(effect, "attack"),
					"health": _effect_number(effect, "health"),
					"remaining_picks": maxi(1, int(effect.get("picks", 1))),
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

func _draw_enemy_to_hand_size() -> void:
	while enemy_hand.size() < enemy_hand_count:
		if enemy_deck.is_empty():
			if enemy_discard.is_empty():
				return
			enemy_deck = enemy_discard.duplicate()
			enemy_discard = []
			_shuffle_deck(enemy_deck)
		enemy_hand.append(enemy_deck.pop_front())

func _resolve_enemy_turn_actions() -> void:
	if not enemy_commander_enabled or enemy_hand_count <= 0:
		return
	_draw_enemy_to_hand_size()
	var played_count: int = 0
	while played_count < 12:
		var play: Dictionary = _best_enemy_play()
		if play.is_empty():
			break
		if not _play_enemy_card_from_hand(int(play.get("hand_index", -1)), Dictionary(play.get("target", {}))):
			break
		played_count += 1
	if played_count > 0:
		_log("Comandante inimigo jogou %d carta(s)." % played_count)

func _best_enemy_play() -> Dictionary:
	for index: int in range(enemy_hand.size()):
		var card = _card(enemy_hand[index])
		if card == null or not card.occupies_slot() or int(card.cost) > enemy_mana:
			continue
		var slot_index: int = _best_enemy_creature_slot()
		if slot_index >= 0:
			return {"hand_index": index, "target": {"owner": ENEMY_ID, "slot": slot_index}}
	for index: int in range(enemy_hand.size()):
		var card = _card(enemy_hand[index])
		if card == null or card.occupies_slot() or int(card.cost) > enemy_mana:
			continue
		var target: Dictionary = _best_enemy_spell_target(card)
		if not target.is_empty():
			return {"hand_index": index, "target": target}
	return {}

func _play_enemy_card_from_hand(hand_index: int, target: Dictionary) -> bool:
	if hand_index < 0 or hand_index >= enemy_hand.size():
		return false
	var card = _card(enemy_hand[hand_index])
	if card == null or int(card.cost) > enemy_mana:
		return false
	enemy_mana -= int(card.cost)
	var card_id: String = enemy_hand[hand_index]
	enemy_hand.remove_at(hand_index)
	enemy_discard.append(card_id)
	if card.occupies_slot():
		var slot_index: int = int(target.get("slot", _best_enemy_creature_slot()))
		if slot_index < 0 or slot_index >= enemy_slots.size() or enemy_slots[slot_index] != null:
			return false
		enemy_slots[slot_index] = _build_occupant(card, ENEMY_ID, true)
		_log("Comandante inimigo invocou %s no slot %d." % [card.display_name, slot_index + 1])
	else:
		_resolve_enemy_spell(card, target)
	_check_outcome()
	return true

func _resolve_enemy_spell(card, target: Dictionary) -> void:
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage":
			var amount: int = int(effect.get("amount", effect.get("damage", 0)))
			var target_data: Dictionary = target if not target.is_empty() else _first_player_target()
			if target_data.has("slot"):
				_damage_slot(str(target_data.get("owner", PLAYER_ID)), int(target_data.get("slot", -1)), amount)
			else:
				_damage_hero(str(target_data.get("owner", PLAYER_ID)), amount)
			_log("Comandante inimigo usou %s." % card.display_name)
		"random_damage":
			_resolve_random_damage(int(effect.get("amount", effect.get("damage", 0))), PLAYER_ID)
			_log("Comandante inimigo espalhou dano com %s." % card.display_name)
		"buff_ally":
			var slot_index: int = _strongest_enemy_slot()
			_buff_slot(ENEMY_ID, slot_index, int(effect.get("attack", 0)), int(effect.get("health", 0)), bool(effect.get("temporary", false)))
			_log("Comandante inimigo fortaleceu uma criatura.")

func _best_enemy_creature_slot() -> int:
	for index: int in range(player_slots.size()):
		if player_slots[index] != null and index < enemy_slots.size() and enemy_slots[index] == null:
			return index
	var center: int = int(enemy_slots.size() / 2)
	for distance: int in range(enemy_slots.size()):
		for slot_index: int in [center - distance, center + distance]:
			if slot_index >= 0 and slot_index < enemy_slots.size() and enemy_slots[slot_index] == null:
				return slot_index
	return -1

func _best_enemy_spell_target(card) -> Dictionary:
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage":
			return _first_player_target()
		"random_damage":
			return _board_area_target(PLAYER_ID) if not _area_damage_targets(PLAYER_ID).is_empty() else {}
		"buff_ally":
			var slot_index: int = _strongest_enemy_slot()
			return {"owner": ENEMY_ID, "slot": slot_index} if slot_index >= 0 else {}
	return {}

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

func _resolve_staged_combat_step() -> void:
	var attacked_sources: Dictionary = {}
	_resolve_combat_stage(COMBAT_STAGE_INITIATIVE_FRONT, true, true, attacked_sources)
	_resolve_combat_stage(COMBAT_STAGE_INITIATIVE_OVERFLOW, true, false, attacked_sources)
	_resolve_combat_stage(COMBAT_STAGE_NORMAL_FRONT, false, true, attacked_sources)
	_resolve_combat_stage(COMBAT_STAGE_NORMAL_OVERFLOW, false, false, attacked_sources)

func _resolve_combat_stage(stage_name: String, initiative_stage: bool, front_stage: bool, attacked_sources: Dictionary) -> void:
	if front_stage:
		_resolve_batched_combat_stage(stage_name, initiative_stage, attacked_sources)
	else:
		_resolve_sequential_combat_stage(stage_name, initiative_stage, attacked_sources)

func _resolve_batched_combat_stage(stage_name: String, initiative_stage: bool, attacked_sources: Dictionary) -> void:
	if outcome != "":
		return
	var attacks: Array[Dictionary] = []
	var lane_count: int = max(player_slots.size(), enemy_slots.size())
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		for slot_index: int in range(lane_count):
			var attack: Dictionary = _build_staged_attack_if_valid(stage_name, initiative_stage, true, attacked_sources, owner_id, slot_index)
			if not attack.is_empty():
				attacks.append(attack)
	_apply_stage_attacks(stage_name, attacks)

func _resolve_sequential_combat_stage(stage_name: String, initiative_stage: bool, attacked_sources: Dictionary) -> void:
	if outcome != "":
		return
	var lane_count: int = max(player_slots.size(), enemy_slots.size())
	var stage_started: bool = false
	for slot_index: int in range(lane_count):
		for owner_id: String in [PLAYER_ID, ENEMY_ID]:
			if outcome != "":
				return
			var attack: Dictionary = _build_staged_attack_if_valid(stage_name, initiative_stage, false, attacked_sources, owner_id, slot_index)
			if attack.is_empty():
				continue
			if not stage_started:
				stage_started = true
				_log("%s: ataques sequenciais." % stage_name)
				visual_events.append({"type": "stage", "stage": stage_name, "label": stage_name})
			_apply_stage_attacks(stage_name, [attack], false)

func _build_staged_attack_if_valid(stage_name: String, initiative_stage: bool, front_stage: bool, attacked_sources: Dictionary, owner_id: String, slot_index: int) -> Dictionary:
	var attacker: Dictionary = _slot_occupant(owner_id, slot_index)
	if attacker.is_empty() or bool(attacker.get("objective", false)):
		return {}
	if bool(attacker.get("iniciativa", false)) != initiative_stage:
		return {}
	var source_key: String = _source_key(owner_id, slot_index)
	if attacked_sources.has(source_key):
		return {}
	var target: Dictionary = _front_attack_target(owner_id, slot_index) if front_stage else _overflow_attack_target(owner_id, slot_index)
	if front_stage and target.is_empty():
		return {}
	var preparation: Dictionary = _prepare_staged_attacker(owner_id, slot_index)
	if bool(preparation.get("consumed", false)):
		attacked_sources[source_key] = true
		var forced_target: Dictionary = Dictionary(preparation.get("target", {}))
		if not forced_target.is_empty():
			return _build_attack_event(stage_name, owner_id, slot_index, forced_target)
		return {}
	if target.is_empty():
		return {}
	attacked_sources[source_key] = true
	return _build_attack_event(stage_name, owner_id, slot_index, target)

func _prepare_staged_attacker(owner_id: String, slot_index: int) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return {"can_attack": false}
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if int(occupant.get("slow_turns", 0)) > 0:
		occupant["slow_turns"] = int(occupant.get("slow_turns", 0)) - 1
		slots[slot_index] = occupant
		_set_slots_for_owner(owner_id, slots)
		_log("%s perdeu o ataque por Lentidao." % str(occupant.get("name", "Criatura")))
		return {"can_attack": false, "consumed": true}
	if int(occupant.get("confusion_turns", 0)) > 0:
		occupant["confusion_turns"] = int(occupant.get("confusion_turns", 0)) - 1
		slots[slot_index] = occupant
		_set_slots_for_owner(owner_id, slots)
		var confused_target: Dictionary = _first_same_side_target(owner_id, slot_index)
		if not confused_target.is_empty():
			_log("%s atacou em Confusao." % str(occupant.get("name", "Criatura")))
			return {"can_attack": false, "consumed": true, "target": confused_target}
		return {"can_attack": false, "consumed": true}
	return {"can_attack": true}

func _apply_stage_attacks(stage_name: String, attacks: Array[Dictionary], announce_stage: bool = true) -> void:
	if attacks.is_empty():
		return
	if announce_stage:
		_log("%s: %d ataque(s)." % [stage_name, attacks.size()])
		visual_events.append({"type": "stage", "stage": stage_name, "label": stage_name})
	var slot_damage: Dictionary = {}
	var hero_damage: Dictionary = {}
	for attack: Dictionary in attacks:
		var amount: int = int(attack.get("damage", 0))
		visual_events.append(attack.duplicate(true))
		if bool(attack.get("target_hero", false)):
			var hero_owner: String = str(attack.get("target_owner", ENEMY_ID))
			hero_damage[hero_owner] = int(hero_damage.get(hero_owner, 0)) + amount
			continue
		var target_owner: String = str(attack.get("target_owner", ENEMY_ID))
		var target_slot: int = int(attack.get("target_slot", -1))
		var key: String = _source_key(target_owner, target_slot)
		slot_damage[key] = int(slot_damage.get(key, 0)) + amount
	for owner_key: Variant in hero_damage.keys():
		var owner_id: String = str(owner_key)
		var amount: int = int(hero_damage.get(owner_id, 0))
		if amount <= 0:
			continue
		_damage_hero(owner_id, amount)
		_log("%s recebeu %d de dano." % [_hero_log_name(owner_id), amount])
		visual_events.append({"type": "damage", "stage": stage_name, "target_owner": owner_id, "target_hero": true, "amount": amount, "health_after": player_health if owner_id == PLAYER_ID else enemy_health})
	var damaged_slots: Array[Dictionary] = []
	for key_variant: Variant in slot_damage.keys():
		var key: String = str(key_variant)
		var parts: PackedStringArray = key.split(":")
		if parts.size() != 2:
			continue
		var owner_id: String = parts[0]
		var slot_index: int = int(parts[1])
		var amount: int = int(slot_damage.get(key, 0))
		var slots: Array = _slots_for_owner(owner_id)
		if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
			continue
		var occupant: Dictionary = Dictionary(slots[slot_index])
		occupant["health"] = int(occupant.get("health", 0)) - amount
		slots[slot_index] = occupant
		_set_slots_for_owner(owner_id, slots)
		var damage_event: Dictionary = {
			"type": "damage",
			"stage": stage_name,
			"target_owner": owner_id,
			"target_slot": slot_index,
			"target_card_id": str(occupant.get("card_id", "")),
			"amount": amount,
			"health_after": int(occupant.get("health", 0))
		}
		var event_index: int = visual_events.size()
		visual_events.append(damage_event)
		damaged_slots.append({"owner": owner_id, "slot": slot_index, "event_index": event_index})
		_log("%s recebeu %d de dano." % [str(occupant.get("name", "Criatura")), amount])
	for damaged: Dictionary in damaged_slots:
		var owner_id: String = str(damaged.get("owner", ""))
		var slot_index: int = int(damaged.get("slot", -1))
		var event_index: int = int(damaged.get("event_index", -1))
		var current: Dictionary = _slot_occupant(owner_id, slot_index)
		if current.is_empty():
			continue
		var result: Dictionary = _store_or_destroy_lane_unit(owner_id, slot_index, current)
		if event_index >= 0 and event_index < visual_events.size():
			var event: Dictionary = Dictionary(visual_events[event_index])
			event["destroyed"] = bool(result.get("destroyed", false))
			event["removed"] = bool(result.get("removed", false))
			if bool(result.get("revived", false)):
				event["replacement_occupant"] = Dictionary(result.get("occupant", {})).duplicate(true)
			visual_events[event_index] = event
	_check_outcome()

func _build_attack_event(stage_name: String, owner_id: String, slot_index: int, target: Dictionary) -> Dictionary:
	var attacker: Dictionary = _slot_occupant(owner_id, slot_index)
	var damage: int = int(attacker.get("attack", 0))
	var event: Dictionary = {
		"type": "attack",
		"stage": stage_name,
		"source_owner": owner_id,
		"source_slot": slot_index,
		"source_name": str(attacker.get("name", "Criatura")),
		"target_owner": str(target.get("owner", _opponent_id(owner_id))),
		"target_hero": bool(target.get("hero", false)),
		"target_name": _target_display_name(target),
		"damage": damage
	}
	if target.has("slot"):
		event["target_slot"] = int(target.get("slot", -1))
	return event

func _store_or_destroy_lane_unit(owner_id: String, slot_index: int, occupant: Dictionary) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	var result: Dictionary = {
		"destroyed": false,
		"removed": false,
		"revived": false,
		"occupant": occupant.duplicate(true)
	}
	if int(occupant.get("health", 0)) <= 0:
		_log("%s foi destruido." % str(occupant.get("name", "Criatura")))
		var card_id: String = str(occupant.get("card_id", ""))
		var revived: Dictionary = _handle_unit_death(owner_id, occupant, true)
		if revived.is_empty() and owner_id == PLAYER_ID and card_id != "":
			discard.append(card_id)
		slots[slot_index] = revived if not revived.is_empty() else null
		result["destroyed"] = true
		result["removed"] = revived.is_empty()
		result["revived"] = not revived.is_empty()
		result["occupant"] = revived.duplicate(true) if not revived.is_empty() else {}
	else:
		slots[slot_index] = occupant
		result["occupant"] = occupant.duplicate(true)
	_set_slots_for_owner(owner_id, slots)
	return result

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
	if mode == MODE_SURVIVE_TURNS and _board_is_clear(ENEMY_ID):
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
		"moved_this_turn": false,
		"slow_turns": 0,
		"curse_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 0,
		"temporary_health_bonus": 0,
		"regeneration_amount": 0,
		"carrion_amount": 0
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
	var effect: Dictionary = Dictionary(card.effect)
	var regeneration: int = int(effect.get("regeneration", 0))
	if regeneration <= 0 and card.has_keyword("regeneracao"):
		regeneration = 1
	var carrion: int = int(effect.get("carrion", 0))
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
		"regeneracao": regeneration > 0,
		"defensor": card.has_keyword("defensor"),
		"reviver": card.has_keyword("reviver"),
		"revive_marker": false,
		"moved_this_turn": false,
		"slow_turns": 0,
		"curse_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 0,
		"temporary_health_bonus": 0,
		"regeneration_amount": regeneration,
		"carrion_amount": carrion
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
	if invocador_passive_triggered:
		return
	var target_slot: int = _strongest_ally_slot()
	if target_slot >= 0:
		invocador_passive_triggered = true
		_buff_slot(PLAYER_ID, target_slot, 2, 1, false)
		_log("Comandante de Campo concedeu +2/+1 permanente.")

func _resolve_necromancer_active(choice_id: String = "", target: Dictionary = {}) -> void:
	if choice_id == NECRO_CHOICE_ROT:
		ashes -= 2
		_apply_debuff_to_target({"debuff": "rot", "amount": 1}, target)
		_log("Ritual das Sombras aplicou Podridao 1/1.")
	elif choice_id == NECRO_CHOICE_ATTACK_TWO:
		ashes -= 2
		_buff_slot(PLAYER_ID, int(target.get("slot", -1)), 2, 0, true)
		_log("Ritual das Sombras concedeu +2 ATK temporario.")
	elif choice_id == NECRO_CHOICE_REVIVE_ONE_ONE and _revive_from_discard_into_slot(true, int(target.get("slot", -1))):
		ashes -= 4
		_log("Ritual das Sombras reanimou uma criatura 1/1.")
	elif choice_id == NECRO_CHOICE_ROT_TWO:
		ashes -= 4
		_apply_debuff_to_target({"debuff": "rot", "amount": 2}, target)
		_log("Ritual das Sombras aplicou Podridao 2/2.")
	elif choice_id == NECRO_CHOICE_ATTACK_FOUR:
		ashes -= 4
		_buff_slot(PLAYER_ID, int(target.get("slot", -1)), 4, 0, true)
		_log("Ritual das Sombras concedeu +4 ATK temporario.")
	elif choice_id == NECRO_CHOICE_LIGHTNING:
		ashes -= 2
		_damage_hero(ENEMY_ID, 2)
		_log("Ritual das Sombras causou 2 de dano ao heroi inimigo.")
	elif choice_id == NECRO_CHOICE_LIGHTNING_MAJOR:
		ashes -= 4
		_damage_hero(ENEMY_ID, 4)
		_log("Ritual das Sombras causou 4 de dano ao heroi inimigo.")
	else:
		_log("Ritual das Sombras perdeu efeito: escolha invalida.")

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
	_trigger_carrion(owner_id, occupant)
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

func _remove_keywords_from_target(target: Dictionary) -> void:
	if not target.has("slot"):
		return
	var owner_id: String = str(target.get("owner", ENEMY_ID))
	var slot_index: int = int(target.get("slot", -1))
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	occupant["keywords"] = []
	occupant["iniciativa"] = false
	occupant["regeneracao"] = false
	occupant["defensor"] = false
	occupant["reviver"] = false
	occupant["regeneration_amount"] = 0
	occupant["carrion_amount"] = 0
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _target_is_snared(target: Dictionary) -> bool:
	if not target.has("slot"):
		return false
	var owner_id: String = str(target.get("owner", ENEMY_ID))
	var slot_index: int = int(target.get("slot", -1))
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return false
	return int(Dictionary(slots[slot_index]).get("slow_turns", 0)) > 0

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
		occupant["temporary_health_bonus"] = int(occupant.get("temporary_health_bonus", 0)) + health_bonus
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
		var temporary_health: int = int(occupant.get("temporary_health_bonus", 0))
		if temporary_health != 0:
			occupant["max_health"] = max(1, int(occupant.get("max_health", 1)) - temporary_health)
			occupant["health"] = mini(int(occupant.get("health", 0)), int(occupant.get("max_health", 1)))
			occupant["temporary_health_bonus"] = 0
		player_slots[index] = occupant

func _resolve_end_of_combat_regeneration() -> void:
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		var changed: bool = false
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			var regeneration: int = int(occupant.get("regeneration_amount", 0))
			if regeneration <= 0:
				continue
			var before: int = int(occupant.get("health", 0))
			occupant["health"] = mini(int(occupant.get("max_health", before)), before + regeneration)
			if int(occupant.get("health", 0)) != before:
				_log("%s regenerou %d." % [str(occupant.get("name", "Criatura")), regeneration])
			slots[index] = occupant
			changed = true
		if changed:
			_set_slots_for_owner(owner_id, slots)

func _resolve_start_of_player_turn() -> void:
	for index: int in range(player_slots.size()):
		if player_slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(player_slots[index])
		occupant["moved_this_turn"] = false
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
	var bonus: int = temporary_ability_power_bonus
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

func _resolve_random_damage(total: int, owner_id: String = ENEMY_ID) -> void:
	for _point: int in range(max(0, total)):
		var targets: Array[Dictionary] = _area_damage_targets(owner_id)
		if targets.is_empty():
			return
		var target: Dictionary = targets[_rng.randi_range(0, targets.size() - 1)]
		if target.has("slot"):
			_damage_slot(str(target.get("owner", ENEMY_ID)), int(target.get("slot", -1)), 1)
		else:
			_damage_hero(str(target.get("owner", ENEMY_ID)), 1)

func _area_damage_targets(owner_id: String) -> Array[Dictionary]:
	var targets: Array[Dictionary] = _occupied_slot_targets(owner_id)
	if _can_receive_direct_damage(owner_id):
		targets.append({"owner": owner_id, "hero": true})
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
			var attack_bonus: int = int(choice.get("attack", 1 + _ability_power_bonus()))
			var health_bonus: int = int(choice.get("health", 1 + _ability_power_bonus()))
			_buff_slot(PLAYER_ID, slot_index, attack_bonus, health_bonus, false)
			_log("Promover concedeu +%d/+%d." % [attack_bonus, health_bonus])

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
		"regeneracao":
			occupant["regeneracao"] = true
			occupant["regeneration_amount"] = maxi(1, int(occupant.get("regeneration_amount", 0)))
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _resolve_promote_all(target: Dictionary, attack_bonus: int, health_bonus: int) -> void:
	var slot_index: int = int(target.get("slot", -1))
	if slot_index < 0 or slot_index >= player_slots.size() or player_slots[slot_index] == null:
		_log("Promover perdeu efeito: alvo ausente.")
		return
	_buff_slot(PLAYER_ID, slot_index, attack_bonus, health_bonus, false)
	_add_keyword_to_slot(PLAYER_ID, slot_index, "iniciativa")
	_add_keyword_to_slot(PLAYER_ID, slot_index, "defensor")

func _trigger_carrion(_dead_owner_id: String, _dead_occupant: Dictionary) -> void:
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		var changed: bool = false
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			var carrion: int = int(occupant.get("carrion_amount", 0))
			if carrion <= 0 or int(occupant.get("health", 0)) <= 0:
				continue
			occupant["attack"] = int(occupant.get("attack", 0)) + carrion
			occupant["health"] = int(occupant.get("health", 0)) + carrion
			occupant["max_health"] = int(occupant.get("max_health", 0)) + carrion
			slots[index] = occupant
			changed = true
			_log("%s cresceu com Carnica %d." % [str(occupant.get("name", "Criatura")), carrion])
		if changed:
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

func _front_attack_target(owner_id: String, slot_index: int) -> Dictionary:
	var opponent_id: String = _opponent_id(owner_id)
	var opposing_slots: Array = _slots_for_owner(opponent_id)
	if slot_index >= 0 and slot_index < opposing_slots.size() and opposing_slots[slot_index] != null:
		return {"owner": opponent_id, "slot": slot_index}
	return {}

func _overflow_attack_target(owner_id: String, slot_index: int) -> Dictionary:
	var opponent_id: String = _opponent_id(owner_id)
	var defender_target: Dictionary = _nearest_defender_target(opponent_id, slot_index)
	if not defender_target.is_empty():
		return defender_target
	if owner_id == ENEMY_ID:
		return {"owner": PLAYER_ID, "hero": true}
	if _enemy_hero_is_objective():
		return {"owner": ENEMY_ID, "hero": true}
	return _nearest_occupied_slot_target(ENEMY_ID, slot_index)

func _nearest_occupied_slot_target(owner_id: String, lane_index: int) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	var best_index: int = -1
	var best_distance: int = 99999
	for index: int in range(slots.size()):
		if slots[index] == null:
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

func _strongest_enemy_slot() -> int:
	var best_index: int = -1
	var best_attack: int = -1
	for index: int in range(enemy_slots.size()):
		if enemy_slots[index] == null:
			continue
		var attack_value: int = int(Dictionary(enemy_slots[index]).get("attack", 0))
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

func _first_player_target() -> Dictionary:
	for index: int in range(player_slots.size()):
		if player_slots[index] != null:
			return {"owner": PLAYER_ID, "slot": index}
	return {"owner": PLAYER_ID, "hero": true}

func _slot_targets(owner_id: String, include_empty: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if include_empty or slots[index] != null:
			result.append({"owner": owner_id, "slot": index})
	return result

func _summon_slot_targets() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index: int in range(player_slots.size()):
		if player_slots[index] != null and bool(Dictionary(player_slots[index]).get("objective", false)):
			continue
		result.append({"owner": PLAYER_ID, "slot": index})
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
		return _empty_targets()
	return [
		{"owner": PLAYER_ID, "hero": true},
		{"owner": ENEMY_ID, "hero": true}
	]

func _empty_targets() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	return result

func _board_area_target(owner_id: String) -> Dictionary:
	return {"owner": owner_id, "area": "board"}

func _uses_wave_director() -> bool:
	return mode == MODE_WAVES or (mode == MODE_DEFENSE_POSITION and enemy_director == "waves")

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

func _source_key(owner_id: String, slot_index: int) -> String:
	return "%s:%d" % [owner_id, slot_index]

func _target_display_name(target: Dictionary) -> String:
	if bool(target.get("hero", false)):
		return _hero_log_name(str(target.get("owner", ENEMY_ID)))
	var owner_id: String = str(target.get("owner", ENEMY_ID))
	var slot_index: int = int(target.get("slot", -1))
	var occupant: Dictionary = _slot_occupant(owner_id, slot_index)
	return str(occupant.get("name", "Slot %d" % (slot_index + 1)))

func _hero_log_name(owner_id: String) -> String:
	if owner_id == PLAYER_ID:
		return "Jogador"
	return "Heroi inimigo"

func _target_in_options(target: Dictionary, options: Array[Dictionary]) -> bool:
	var normalized: Dictionary = _normalized_target(target, PLAYER_ID)
	for option: Dictionary in options:
		if str(option.get("owner", "")) == str(normalized.get("owner", "")) and int(option.get("slot", -999)) == int(normalized.get("slot", -999)) and bool(option.get("hero", false)) == bool(normalized.get("hero", false)) and str(option.get("area", "")) == str(normalized.get("area", "")):
			return true
	return false

func _normalized_target(target: Dictionary, default_owner: String) -> Dictionary:
	var result: Dictionary = target.duplicate()
	if not result.has("owner"):
		result["owner"] = default_owner
	return result

func _card_can_resolve_without_target(card) -> bool:
	if card == null:
		return false
	var action: String = str(Dictionary(card.effect).get("action", ""))
	return action in ["buff_all_allies", "gain_mana"]

func _card(card_id: String):
	if _catalog == null:
		return null
	return _catalog.find_card(card_id)

func _effective_deck_ids(deck_ids: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for card_id: String in deck_ids:
		result.append(_effective_card_id(card_id))
	return result

func _effective_card_id(card_id: String) -> String:
	var upgrade_count: int = clampi(int(card_upgrade_counts.get(card_id, 0)), 0, 2)
	if upgrade_count <= 0:
		return card_id
	var candidate: String = "%s_lvl%d" % [card_id, upgrade_count + 1]
	return candidate if _catalog != null and _catalog.find_card(candidate) != null else card_id

func _hero_health(hero, fallback: int) -> int:
	if hero == null:
		return fallback
	return int(hero.max_health)

func _typed_string_array(source: Array) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in source:
		result.append(str(item))
	return result

func _enemy_deck_from_starting_slots(encounter: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for setup: Variant in Array(encounter.get("starting_enemy_slots", [])):
		if typeof(setup) != TYPE_DICTIONARY:
			continue
		var card_id: String = str(Dictionary(setup).get("card_id", ""))
		if card_id == "":
			continue
		for _copy: int in range(3):
			result.append(card_id)
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
