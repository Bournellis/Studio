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
const MODE_AMBUSH: String = "emboscada"
const MODE_ESCORT: String = "escolta"
const MODE_INVASION: String = "invasao"

const BOARD_FORMAT_STANDARD: String = "padrao"
const BOARD_FORMAT_ASYMMETRIC: String = "assimetrico"
const BOARD_FORMAT_CENTRAL_CORE: String = "nucleo_central"
const BOARD_FORMAT_FLANK: String = "flanco"
const BOARD_FORMAT_FRONT_REAR: String = "frente_retaguarda"
const BOARD_FORMAT_ABYSS: String = "abismo"

const FIELD_TERRENO_ROCHOSO: String = "terreno_rochoso"
const FIELD_CHAO_VIVO: String = "chao_vivo"
const FIELD_GEADA: String = "geada"
const FIELD_CORRENTE_SUBMERSA: String = "corrente_submersa"
const FIELD_TABULEIRO_INSTAVEL: String = "tabuleiro_instavel"
const FIELD_FRIO_INTENSO: String = "frio_intenso"
const FIELD_NEVASCA: String = "nevasca"
const FIELD_VENTANIA: String = "ventania"
const FIELD_SLOT_CENTRAL_AMPLIFICADO: String = "slot_central_amplificado"
const FIELD_RELAMPAGO: String = "relampago"
const FIELD_TURBULENCIA: String = "turbulencia"
const FIELD_OLHO_TEMPESTADE: String = "olho_tempestade"
const FIELD_BRASA_VIVA: String = "brasa_viva"
const FIELD_INFERNO: String = "inferno"
const FIELD_PISO_LAVA: String = "piso_lava"
const FIELD_FURIA_ABISMO: String = "furia_abismo"
const FIELD_CINZAS_VIVAS: String = "cinzas_vivas"
const FIELD_PORTAL_ABERTO: String = "portal_aberto"
const FIELD_INFERNO_TOTAL: String = "inferno_total"

const PHASE_PRECOMBAT: String = "preparo_pre_combate"
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
const RELIC_MARCA_DE_GUERRA: String = "marca_de_guerra"
const RELIC_ECO_MENOR: String = "eco_menor"
const RELIC_CATALISADOR_ARCANO: String = "catalisador_arcano"
const RELIC_ESTANDARTE_VIVO: String = "estandarte_vivo"
const RELIC_CORACAO_DE_ETER: String = "coracao_de_eter"
const ENEMY_AI_TERRA: String = "terra"
const ENEMY_AI_GELO: String = "gelo"
const ENEMY_AI_AR: String = "ar"
const ENEMY_AI_FOGO: String = "fogo"
const ENEMY_AI_PROFILES: Dictionary = {
	"terra": {
		"display_name": "Terra",
		"summary": "estabiliza lanes e protege ameacas duraveis",
		"lane_pressure": 1.05,
		"empty_lane": 0.55,
		"defender": 1.35,
		"high_value": 0.85,
		"thorns_risk": 1.10,
		"control": 0.45,
		"direct": 0.55,
		"trade": 0.80,
		"durability": 1.20,
		"protect": 1.25,
		"burst": 0.50
	},
	"gelo": {
		"display_name": "Gelo",
		"summary": "controla a maior ameaca e cria atrito",
		"lane_pressure": 0.85,
		"empty_lane": 0.45,
		"defender": 0.95,
		"high_value": 1.45,
		"thorns_risk": 1.00,
		"control": 1.65,
		"direct": 0.50,
		"trade": 0.70,
		"durability": 0.95,
		"protect": 0.80,
		"burst": 0.45
	},
	"ar": {
		"display_name": "Ar",
		"summary": "pressiona lanes vazias e dano rapido",
		"lane_pressure": 1.00,
		"empty_lane": 1.70,
		"defender": 0.65,
		"high_value": 0.75,
		"thorns_risk": 0.80,
		"control": 0.40,
		"direct": 1.55,
		"trade": 0.60,
		"durability": 0.40,
		"protect": 0.40,
		"burst": 1.35
	},
	"fogo": {
		"display_name": "Fogo",
		"summary": "forca trocas explosivas e cascatas de morte",
		"lane_pressure": 1.30,
		"empty_lane": 1.05,
		"defender": 0.85,
		"high_value": 1.05,
		"thorns_risk": 0.45,
		"control": 0.35,
		"direct": 1.15,
		"trade": 1.55,
		"durability": 0.55,
		"protect": 0.35,
		"burst": 1.50
	}
}

var turn_number: int = 1
var player_health: int = 30
var player_max_health: int = 30
var enemy_health: int = DEFAULT_ENEMY_HEALTH
var enemy_max_health: int = DEFAULT_ENEMY_HEALTH
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
var precombat_discard_indices: Array[int] = []
var pending_choices: Array[Dictionary] = []
var dead_unit_count: int = 0
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
var enemy_ai_profile_id: String = ENEMY_AI_TERRA
var board_format: String = BOARD_FORMAT_STANDARD
var field_effects: Array[String] = []
var field_effect_state: Dictionary = {}
var boss_summon_index: int = 0
var boss_summons: Array[Dictionary] = []
var boss_phase_hooks: Array[Dictionary] = []
var boss_phase_hook_state: Dictionary = {}
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
var relic_ids: Array[String] = []
var wave_index: int = 0
var waves: Array[Array] = []
var survived_turns: int = 0
var required_survive_turns: int = DEFAULT_OBJECTIVE_TURNS
var required_defense_turns: int = DEFAULT_OBJECTIVE_TURNS
var defense_slot_index: int = 1
var defense_objective_health: int = DEFAULT_DEFENSE_HEALTH
var shuffle_enabled: bool = true
var first_damage_spell_relic_used: bool = false
var first_spell_discount_used: bool = false
var first_summon_health_relic_used: bool = false
var first_summon_attack_relic_used: bool = false
var bonus_souls: int = 0

var _catalog
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func start_battle(catalog, deck_ids: Array, config: Dictionary = {}) -> void:
	_catalog = catalog
	var encounter: Dictionary = _encounter_from_config(config)
	encounter_id = str(encounter.get("id", ""))
	encounter_name = str(encounter.get("display_name", encounter_id))
	mode = str(encounter.get("mode", MODE_CLEAR_BOARD))
	enemy_director = str(encounter.get("enemy_director", "prefilled_board"))
	enemy_ai_profile_id = _resolve_enemy_ai_profile_id(encounter, config)
	board_format = str(config.get("board_format", encounter.get("board_format", BOARD_FORMAT_STANDARD)))
	field_effects = _typed_string_array(Array(config.get("field_effects", encounter.get("field_effects", []))))
	field_effect_state = {}
	mana_per_turn = int(config.get("mana_per_turn", encounter.get("mana_per_turn", DEFAULT_MANA_PER_TURN)))
	mana = mana_per_turn
	max_hand_size = int(config.get("max_hand_size", encounter.get("max_hand_size", DEFAULT_MAX_HAND_SIZE)))
	if _field_effect_active(FIELD_NEVASCA):
		max_hand_size = maxi(1, max_hand_size - 1)
	enemy_commander_enabled = bool(config.get("enemy_commander_enabled", encounter.get("enemy_commander_enabled", false)))
	enemy_mana_per_turn = int(config.get("enemy_mana_per_turn", encounter.get("enemy_mana_per_turn", DEFAULT_MANA_PER_TURN))) if enemy_commander_enabled else 0
	enemy_mana = int(config.get("enemy_mana", encounter.get("enemy_mana", enemy_mana_per_turn))) if enemy_commander_enabled else 0
	enemy_hand_count = int(config.get("enemy_hand_count", encounter.get("enemy_hand_count", max_hand_size))) if enemy_commander_enabled else 0
	player_health = int(config.get("player_health", _hero_health(catalog.player_hero if catalog != null else null, 20)))
	player_max_health = player_health
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
	relic_ids = _typed_string_array(Array(config.get("relic_ids", [])))
	if _has_relic(RELIC_CORACAO_DE_ETER):
		mana += 1
	if mode == MODE_AMBUSH:
		mana = 0
	turn_number = 1
	boss_summon_index = 0
	boss_summons = _typed_dictionary_array(encounter.get("boss_summons", []))
	boss_phase_hooks = _typed_dictionary_array(config.get("boss_phase_hooks", encounter.get("boss_phase_hooks", [])))
	boss_phase_hook_state = {}
	wave_index = 0
	waves = _typed_wave_array(encounter.get("waves", []))
	survived_turns = 0
	required_survive_turns = int(encounter.get("survive_turns", DEFAULT_OBJECTIVE_TURNS))
	required_defense_turns = int(encounter.get("defense_turns", DEFAULT_OBJECTIVE_TURNS))
	defense_slot_index = int(encounter.get("defense_slot", 1))
	defense_objective_health = int(encounter.get("defense_health", DEFAULT_DEFENSE_HEALTH))
	shuffle_enabled = bool(config.get("shuffle_deck", true))
	first_damage_spell_relic_used = false
	first_spell_discount_used = false
	first_summon_health_relic_used = false
	first_summon_attack_relic_used = false
	bonus_souls = 0
	_setup_shuffle(int(config.get("shuffle_seed", 0)), encounter_id)
	outcome = ""
	current_phase = PHASE_MAIN
	log_lines = []
	visual_events = []
	pending_choices = []
	dead_unit_count = 0
	discard = []
	hand = []
	precombat_discard_indices = []
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
	enemy_max_health = enemy_health
	player_slots = _empty_slots(int(encounter.get("player_slots_count", 3)))
	enemy_slots = _empty_slots(int(encounter.get("enemy_slots_count", 3)))
	if mode == MODE_DEFENSE_POSITION:
		_setup_defense_objective()
	elif mode == MODE_ESCORT:
		_setup_escort_objective()
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
		"player_max_health": player_max_health,
		"enemy_health": enemy_health,
		"enemy_max_health": enemy_max_health,
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
		"precombat_discard_indices": precombat_discard_indices.duplicate(),
		"pending_choices": pending_choices.duplicate(true),
		"dead_unit_count": dead_unit_count,
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
		"enemy_ai_profile_id": enemy_ai_profile_id,
		"board_format": board_format,
		"field_effects": field_effects.duplicate(),
		"field_effect_state": field_effect_state.duplicate(true),
		"enemy_intent": get_enemy_intent(),
		"boss_summon_index": boss_summon_index,
		"boss_summons": boss_summons.duplicate(true),
		"boss_phase_hooks": boss_phase_hooks.duplicate(true),
		"selected_class_id": selected_class_id,
		"class_passive_unlocked": class_passive_unlocked,
		"class_active_unlocked": class_active_unlocked,
		"class_active_level": class_active_level,
		"class_active_used": class_active_used,
		"flow": flow,
		"ashes": ashes,
		"bonus_souls": bonus_souls,
		"relic_ids": relic_ids.duplicate(),
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
		MODE_AMBUSH:
			return "Emboscada"
		MODE_ESCORT:
			return "Escolta"
		MODE_INVASION:
			return "Invasao"
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
	return current_phase == PHASE_MAIN and outcome == "" and pending_choices.is_empty() and card != null and _minimum_card_play_cost(card) <= mana and not hand.is_empty()

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
			targets.append_array(_targetable_occupied_slot_targets(PLAYER_ID, true))
			targets.append_array(_targetable_occupied_slot_targets(ENEMY_ID, true))
			targets.append_array(_hero_targets())
			return targets
		"flow_damage":
			var flow_targets: Array[Dictionary] = _targetable_occupied_slot_targets(ENEMY_ID, true)
			if _enemy_hero_is_objective():
				flow_targets.append({"owner": ENEMY_ID, "hero": true})
			return flow_targets
		"adjacent_damage":
			return _targetable_occupied_slot_targets(ENEMY_ID, true)
		"random_damage", "freeze_random_enemy", "all_enemy_damage", "poison_all_enemies":
			var area_targets: Array[Dictionary] = []
			if not _area_damage_targets(ENEMY_ID).is_empty():
				area_targets.append(_board_area_target(ENEMY_ID))
			return area_targets
		"debuff", "weaken", "snare", "multi_debuff", "punish_snared":
			return _targetable_occupied_slot_targets(ENEMY_ID, true)
		"buff_ally", "promote":
			return _targetable_occupied_slot_targets(PLAYER_ID, true)
		"buff_all_allies", "gain_mana", "shield_all_allies":
			if not _occupied_slot_targets(PLAYER_ID).is_empty():
				return [_board_area_target(PLAYER_ID)]
			return _empty_targets()
		"gain_ashes":
			return [_board_area_target(PLAYER_ID)]
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
	if not _target_in_options(_normalized_target(target, PLAYER_ID), get_valid_card_targets(hand_index)):
		return false
	var card = _card(hand[hand_index])
	if card != null and card.occupies_slot() and target.has("slot"):
		var slot_index: int = int(target.get("slot", -1))
		if slot_index >= 0 and slot_index < player_slots.size() and player_slots[slot_index] != null:
			var confirmed_target: Dictionary = target.duplicate()
			confirmed_target["confirm_sacrifice"] = true
			return _card_play_cost_for_target(card, confirmed_target) <= mana
	return _card_play_cost_for_target(card, target) <= mana

func play_card_from_hand(hand_index: int, target: Dictionary = {}) -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if hand_index < 0 or hand_index >= hand.size():
		return _fail("Indice de carta invalido.")
	var card_id: String = hand[hand_index]
	var card = _card(card_id)
	if card == null:
		return _fail("Carta nao encontrada: %s." % card_id)
	if _minimum_card_play_cost(card) > mana:
		return _fail("Mana insuficiente.")
	if current_phase != PHASE_MAIN:
		return _fail("Finalize o preparo antes de jogar cartas.")
	if target.is_empty() and str(Dictionary(card.effect).get("action", "")) in ["random_damage", "buff_all_allies", "gain_mana"]:
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
		var play_cost: int = _card_play_cost_for_target(card, {"owner": PLAYER_ID, "slot": slot_index, "confirm_sacrifice": bool(target.get("confirm_sacrifice", false))})
		if play_cost > mana:
			return _fail("Mana insuficiente.")
		_spend_card(hand_index, card, play_cost)
		_after_card_played()
		if player_slots[slot_index] != null:
			var sacrificed: Dictionary = Dictionary(player_slots[slot_index])
			player_slots[slot_index] = null
			discard.append(str(sacrificed.get("card_id", "")))
			_handle_unit_death(PLAYER_ID, sacrificed, false)
			_log("%s foi sacrificado para abrir espaco." % str(sacrificed.get("name", "Criatura")))
		player_slots[slot_index] = _build_occupant(card, PLAYER_ID, false)
		_apply_summon_field_effect(PLAYER_ID, slot_index)
		_recalculate_pact_bonuses(PLAYER_ID)
		_resolve_on_enter(card, PLAYER_ID, slot_index)
		_apply_relic_summon_bonuses(slot_index)
		_apply_summon_passive(slot_index)
		_log("%s entrou no slot %d." % [card.display_name, slot_index + 1])
	else:
		_spend_card(hand_index, card, _card_play_cost(card))
		_after_card_played()
		_resolve_spell(card, target)
	_draw_to_hand_size()
	_check_outcome()
	return {"ok": true, "message": "Carta jogada."}

func has_pending_choice() -> bool:
	return not pending_choices.is_empty()

func is_precombat_phase() -> bool:
	return current_phase == PHASE_PRECOMBAT and outcome == ""

func toggle_precombat_discard(hand_index: int) -> Dictionary:
	if not _can_mark_hand_discard():
		return _fail("Descarte de fim de combate indisponivel.")
	if hand_index < 0 or hand_index >= hand.size():
		return _fail("Indice de carta invalido.")
	if precombat_discard_indices.has(hand_index):
		precombat_discard_indices.erase(hand_index)
		return {"ok": true, "message": "Carta mantida na mao."}
	precombat_discard_indices.append(hand_index)
	precombat_discard_indices.sort()
	return {"ok": true, "message": "Carta marcada para descarte."}

func confirm_precombat_discard() -> Dictionary:
	if not _can_mark_hand_discard():
		return _fail("Descarte de fim de combate indisponivel.")
	return _discard_marked_hand_cards()

func _discard_marked_hand_cards() -> Dictionary:
	precombat_discard_indices.sort()
	precombat_discard_indices.reverse()
	var discarded_count: int = 0
	for hand_index: int in precombat_discard_indices:
		if hand_index < 0 or hand_index >= hand.size():
			continue
		discard.append(hand[hand_index])
		hand.remove_at(hand_index)
		discarded_count += 1
	precombat_discard_indices = []
	_draw_to_hand_size()
	if discarded_count > 0:
		_log("Fim de combate descartou %d carta(s) marcada(s) e recomprou ate o limite da mao." % discarded_count)
	return {"ok": true, "message": "Descarte de fim de combate concluido."}

func _can_mark_hand_discard() -> bool:
	return current_phase == PHASE_MAIN and outcome == "" and pending_choices.is_empty()

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
	if current_phase != PHASE_MAIN or outcome != "" or class_active_used or not class_active_unlocked:
		return false
	match selected_class_id:
		"arcano":
			return mana >= 1
		"invocador":
			return _first_ally_slot() >= 0
		"necromante":
			return class_active_level >= 1 and ashes >= 2
	return false

func get_valid_class_active_targets(choice_id: String = "") -> Array[Dictionary]:
	if not can_use_class_active():
		return _empty_targets()
	match selected_class_id:
		"arcano":
			var targets: Array[Dictionary] = []
			targets.append_array(_targetable_occupied_slot_targets(PLAYER_ID, true))
			targets.append_array(_targetable_occupied_slot_targets(ENEMY_ID, true))
			targets.append_array(_hero_targets())
			return targets
		"invocador":
			var targets: Array[Dictionary] = []
			if not _occupied_slot_targets(PLAYER_ID).is_empty():
				targets.append(_board_area_target(PLAYER_ID))
			return targets
		"necromante":
			match choice_id:
				NECRO_CHOICE_ROT:
					if ashes < 2:
						return _empty_targets()
					return _targetable_occupied_slot_targets(ENEMY_ID, true)
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
					return _targetable_occupied_slot_targets(ENEMY_ID, true)
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
				_damage_slot(str(arcane_target.get("owner", ENEMY_ID)), int(arcane_target.get("slot", -1)), amount, "class_active")
			else:
				_damage_hero(str(arcane_target.get("owner", ENEMY_ID)), amount)
			_log("Spell de classe Arcano causou %d de dano." % amount)
		"invocador":
			var ally_slot: int = int(target.get("slot", _strongest_ally_slot()))
			var attack_bonus: int = 2 + _ability_power_bonus()
			if str(target.get("area", "")) == "board":
				ally_slot = _strongest_ally_slot()
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
		_reset_resistance_for_cycle()
		_resolve_staged_combat_step()
		_resolve_end_of_combat_regeneration()
		_resolve_end_of_combat_keyword_triggers()
		_resolve_end_of_combat_field_effects()
		_check_outcome()
		_discard_marked_hand_cards()
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
	_resolve_enemy_start_field_effects()
	_check_outcome()
	if outcome != "":
		return
	_resolve_enemy_turn_actions()
	_check_outcome()

func _finish_cycle() -> void:
	if outcome == "" and mode in [MODE_DEFENSE_POSITION, MODE_SURVIVE_TURNS]:
		survived_turns += 1
		_log("Turnos de objetivo sobrevividos: %d/%d." % [survived_turns, _required_objective_turns()])
		_check_outcome()
	if outcome == "" and mode == MODE_ESCORT:
		_advance_escort_objective()
		_check_outcome()
	turn_number += 1
	class_active_used = false
	invocador_passive_triggered = false
	first_spell_discount_used = false
	first_summon_attack_relic_used = false
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
	_resolve_poison_ticks()
	_resolve_maintenance_field_effects()
	if _uses_wave_director() and _board_is_clear(ENEMY_ID) and _has_next_wave():
		_spawn_next_wave()
	if outcome == "":
		_resolve_boss_summon()
	if outcome == "":
		_resolve_boss_phase_hooks()

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
	if _field_effect_active(FIELD_CORRENTE_SUBMERSA):
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
		_apply_summon_field_effect(ENEMY_ID, slot_index)
		_recalculate_pact_bonuses(ENEMY_ID)

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
	_apply_summon_field_effect(ENEMY_ID, open_slot)
	_resolve_on_enter(card, ENEMY_ID, open_slot)
	_log("Chefe Invocador invocou %s no slot %d." % [card.display_name, open_slot + 1])

func _resolve_spell(card, target: Dictionary) -> void:
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage":
			var amount: int = _effect_amount(effect) + _first_damage_spell_bonus()
			if selected_class_id == "arcano" and class_passive_unlocked:
				amount += flow
			var target_data: Dictionary = target if not target.is_empty() else _first_enemy_target()
			if target_data.is_empty():
				_log("%s perdeu efeito: nenhum alvo valido." % card.display_name)
			elif target_data.has("slot"):
				var target_owner: String = str(target_data.get("owner", ENEMY_ID))
				_damage_slot(target_owner, int(target_data.get("slot", -1)), amount, "spell")
			else:
				var target_owner: String = str(target_data.get("owner", ENEMY_ID))
				_damage_hero(target_owner, amount)
			_log("%s causou %d de dano." % [card.display_name, amount])
		"flow_damage":
			var flow_amount: int = int(effect.get("amount", 0)) + flow + _ability_power_bonus() + _first_damage_spell_bonus()
			var flow_target: Dictionary = target if not target.is_empty() else _first_enemy_target()
			if flow_target.is_empty():
				_log("%s perdeu efeito: nenhum alvo valido." % card.display_name)
			elif flow_target.has("slot"):
				_damage_slot(str(flow_target.get("owner", ENEMY_ID)), int(flow_target.get("slot", -1)), flow_amount, "spell")
			else:
				_damage_hero(str(flow_target.get("owner", ENEMY_ID)), flow_amount)
			flow += int(effect.get("gain_flow", 0))
			_log("%s canalizou %d de dano." % [card.display_name, flow_amount])
		"adjacent_damage":
			var amount: int = _effect_amount(effect) + _first_damage_spell_bonus()
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
				_damage_slot(target_owner, slot_index, slot_damage, "spell")
			_log("%s explodiu o slot %d e adjacentes." % [card.display_name, target_slot + 1])
		"random_damage":
			var total: int = _effect_amount(effect) + _first_damage_spell_bonus()
			if selected_class_id == "arcano" and class_passive_unlocked:
				total += flow
			if str(target.get("area", "")) != "board":
				_log("%s perdeu efeito: alvo de area invalido." % card.display_name)
				return
			_resolve_random_damage(total, str(target.get("owner", ENEMY_ID)))
			_log("%s distribuiu %d de dano." % [card.display_name, total])
		"all_enemy_damage":
			var area_amount: int = _effect_amount(effect) + _first_damage_spell_bonus()
			if bool(effect.get("scale_with_flow", false)):
				area_amount += flow
			for enemy_index: int in range(enemy_slots.size()):
				if enemy_slots[enemy_index] != null:
					_damage_slot(ENEMY_ID, enemy_index, area_amount, "spell")
			_log("%s causou %d de dano em cada inimigo." % [card.display_name, area_amount])
		"freeze_random_enemy":
			var frozen_count: int = _freeze_random_enemies(bool(effect.get("all", false)), int(effect.get("count", 1)), int(effect.get("amount", 1)))
			flow += int(effect.get("gain_flow", 0))
			_log("%s congelou %d criatura(s)." % [card.display_name, frozen_count])
		"poison_all_enemies":
			var prepoisoned: int = 0
			for poison_index: int in range(enemy_slots.size()):
				if enemy_slots[poison_index] == null:
					continue
				if int(Dictionary(enemy_slots[poison_index]).get("poison_amount", 0)) > 0:
					prepoisoned += 1
				_apply_poison_to_slot(ENEMY_ID, poison_index, int(effect.get("amount", 1)))
			var ashes_gained: int = prepoisoned * int(effect.get("gain_ashes_per_prepoisoned", 0))
			ashes += ashes_gained
			_log("%s espalhou Veneno." % card.display_name)
		"gain_ashes":
			var gained_ashes: int = int(effect.get("amount", 0))
			if bool(effect.get("per_dead_unit", false)):
				gained_ashes += dead_unit_count
			ashes += gained_ashes
			if int(effect.get("draw_if_at_least", 0)) > 0 and gained_ashes >= int(effect.get("draw_if_at_least", 0)):
				_draw_cards(1)
			_log("%s gerou %d Cinza(s)." % [card.display_name, gained_ashes])
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
			if str(target.get("owner", PLAYER_ID)) != PLAYER_ID or str(target.get("area", "")) != "board":
				_log("%s perdeu efeito: alvo aliado invalido." % card.display_name)
				return
			for index: int in range(player_slots.size()):
				if player_slots[index] != null:
					_buff_slot(PLAYER_ID, index, _effect_number(effect, "attack"), _effect_number(effect, "health"), bool(effect.get("temporary", false)))
			_log("%s fortaleceu a mesa aliada." % card.display_name)
		"gain_mana":
			if str(target.get("owner", PLAYER_ID)) != PLAYER_ID or str(target.get("area", "")) != "board":
				_log("%s perdeu efeito: alvo aliado invalido." % card.display_name)
				return
			var mana_gained: int = int(effect.get("mana", effect.get("amount", 0)))
			mana += mana_gained
			temporary_ability_power_bonus += int(effect.get("temporary_ability_power", 0))
			_log("%s gerou %d mana." % [card.display_name, mana_gained])
		"shield_all_allies":
			for ally_index: int in range(player_slots.size()):
				if player_slots[ally_index] == null:
					continue
				_add_keyword_to_slot(PLAYER_ID, ally_index, "escudo")
				var slots: Array = _slots_for_owner(PLAYER_ID)
				var occupant: Dictionary = Dictionary(slots[ally_index])
				occupant["shield_charges"] = maxi(int(occupant.get("shield_charges", 0)), int(effect.get("shield_charges", 1)))
				slots[ally_index] = occupant
				_set_slots_for_owner(PLAYER_ID, slots)
				if int(effect.get("attack", 0)) != 0:
					_buff_slot(PLAYER_ID, ally_index, int(effect.get("attack", 0)), 0, false)
			_log("%s ergueu Escudos na mesa aliada." % card.display_name)
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

func _spend_card(hand_index: int, card, play_cost: int = -1) -> void:
	mana -= _card_play_cost(card) if play_cost < 0 else play_cost
	if _is_spell_card(card) and _has_relic(RELIC_CATALISADOR_ARCANO):
		first_spell_discount_used = true
	var card_id: String = hand[hand_index]
	hand.remove_at(hand_index)
	_shift_marked_discards_after_hand_removed(hand_index)
	discard.append(card_id)

func _shift_marked_discards_after_hand_removed(hand_index: int) -> void:
	var updated: Array[int] = []
	for marked_index: int in precombat_discard_indices:
		if marked_index == hand_index:
			continue
		updated.append(marked_index - 1 if marked_index > hand_index else marked_index)
	precombat_discard_indices = updated

func _draw_to_hand_size() -> void:
	while hand.size() < max_hand_size:
		if deck.is_empty():
			if discard.is_empty():
				return
			deck = discard.duplicate()
			discard = []
			_shuffle_deck(deck)
		hand.append(deck.pop_front())

func _draw_cards(count: int) -> void:
	for _index: int in range(maxi(0, count)):
		if hand.size() >= max_hand_size:
			return
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
	var best_play: Dictionary = {}
	var best_score: float = -999999.0
	for index: int in range(enemy_hand.size()):
		var card = _card(enemy_hand[index])
		if card == null or not card.occupies_slot() or int(card.cost) > enemy_mana:
			continue
		for slot_index: int in range(enemy_slots.size()):
			if enemy_slots[slot_index] != null:
				continue
			var score: float = _score_enemy_creature_play(card, slot_index, index)
			if best_play.is_empty() or score > best_score:
				best_score = score
				best_play = {"hand_index": index, "target": {"owner": ENEMY_ID, "slot": slot_index}, "score": score}
	for index: int in range(enemy_hand.size()):
		var card = _card(enemy_hand[index])
		if card == null or card.occupies_slot() or int(card.cost) > enemy_mana:
			continue
		var targets: Array[Dictionary] = _enemy_spell_targets(card)
		for target: Dictionary in targets:
			var score: float = _score_enemy_spell_play(card, target, index)
			if best_play.is_empty() or score > best_score:
				best_score = score
				best_play = {"hand_index": index, "target": target.duplicate(), "score": score}
	return best_play

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
		_apply_summon_field_effect(ENEMY_ID, slot_index)
		_resolve_on_enter(card, ENEMY_ID, slot_index)
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
				_damage_slot(str(target_data.get("owner", PLAYER_ID)), int(target_data.get("slot", -1)), amount, "spell")
			else:
				_damage_hero(str(target_data.get("owner", PLAYER_ID)), amount)
			_log("Comandante inimigo usou %s." % card.display_name)
		"random_damage":
			_resolve_random_damage(int(effect.get("amount", effect.get("damage", 0))), PLAYER_ID)
			_log("Comandante inimigo espalhou dano com %s." % card.display_name)
		"all_enemy_damage":
			for player_index: int in range(player_slots.size()):
				if player_slots[player_index] != null:
					_damage_slot(PLAYER_ID, player_index, int(effect.get("amount", 1)), "spell")
			_log("Comandante inimigo atingiu a mesa com %s." % card.display_name)
		"freeze_random_enemy":
			var frozen_count: int = _freeze_random_enemies(bool(effect.get("all", false)), int(effect.get("count", 1)), int(effect.get("amount", 1)), PLAYER_ID)
			_log("Comandante inimigo congelou %d criatura(s)." % frozen_count)
		"poison_all_enemies":
			for player_index: int in range(player_slots.size()):
				if player_slots[player_index] != null:
					_apply_poison_to_slot(PLAYER_ID, player_index, int(effect.get("amount", 1)))
			_log("Comandante inimigo espalhou Veneno.")
		"debuff", "weaken", "snare", "multi_debuff", "punish_snared":
			_apply_debuff_to_target(effect, target)
			_log("Comandante inimigo controlou uma criatura com %s." % card.display_name)
		"buff_ally":
			var slot_index: int = _strongest_enemy_slot()
			_buff_slot(ENEMY_ID, slot_index, int(effect.get("attack", 0)), int(effect.get("health", 0)), bool(effect.get("temporary", false)))
			_log("Comandante inimigo fortaleceu uma criatura.")

func _best_enemy_creature_slot() -> int:
	var best_slot: int = -1
	var best_score: float = -999999.0
	for slot_index: int in range(enemy_slots.size()):
		if enemy_slots[slot_index] != null:
			continue
		var score: float = _score_enemy_lane_for_profile(slot_index, _enemy_ai_profile())
		if best_slot < 0 or score > best_score:
			best_score = score
			best_slot = slot_index
	if best_slot >= 0:
		return best_slot
	return -1

func _best_enemy_spell_target(card) -> Dictionary:
	var best_target: Dictionary = {}
	var best_score: float = -999999.0
	for target: Dictionary in _enemy_spell_targets(card):
		var score: float = _score_enemy_spell_play(card, target, 0)
		if best_target.is_empty() or score > best_score:
			best_score = score
			best_target = target.duplicate()
	return best_target

func _enemy_spell_targets(card) -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage", "debuff", "weaken", "snare", "multi_debuff", "punish_snared":
			targets.append_array(_targetable_occupied_slot_targets(PLAYER_ID, true))
			if _enemy_hero_is_objective() or targets.is_empty():
				targets.append({"owner": PLAYER_ID, "hero": true})
		"random_damage", "all_enemy_damage", "freeze_random_enemy", "poison_all_enemies":
			if not _area_damage_targets(PLAYER_ID).is_empty():
				targets.append(_board_area_target(PLAYER_ID))
			elif _enemy_hero_is_objective():
				targets.append({"owner": PLAYER_ID, "hero": true})
		"buff_ally":
			targets.append_array(_targetable_occupied_slot_targets(ENEMY_ID, false))
	return targets

func _score_enemy_creature_play(card, slot_index: int, hand_index: int) -> float:
	var profile: Dictionary = _enemy_ai_profile()
	var score: float = float(card.attack) * (0.55 + 0.12 * float(profile.get("burst", 1.0)))
	score += float(card.health) * (0.20 + 0.18 * float(profile.get("durability", 1.0)))
	score -= float(card.cost) * 0.18
	score -= float(hand_index) * 0.01
	score += _score_enemy_lane_for_profile(slot_index, profile)
	score += _score_enemy_card_keywords(card, profile)
	var front: Dictionary = _slot_occupant(PLAYER_ID, slot_index)
	if not front.is_empty():
		score += 1.8 * float(profile.get("lane_pressure", 1.0))
		score += _player_unit_threat_score(front) * float(profile.get("high_value", 1.0)) * 0.26
		if bool(front.get("defensor", false)):
			score += 2.4 * float(profile.get("defender", 1.0))
		if int(front.get("thorns_amount", 0)) > 0 and int(card.attack) > 0:
			score -= float(int(front.get("thorns_amount", 0))) * float(profile.get("thorns_risk", 1.0)) * (1.0 if int(card.health) <= 2 else 0.55)
		if int(front.get("attack", 0)) >= int(card.health):
			score += 1.1 * float(profile.get("trade", 1.0))
	else:
		score += 2.0 * float(profile.get("empty_lane", 1.0))
		if _enemy_hero_is_objective():
			score += 2.6 * float(profile.get("direct", 1.0))
	var nearest_defender: Dictionary = _nearest_defender_target(PLAYER_ID, slot_index)
	if not nearest_defender.is_empty() and front.is_empty():
		score += 1.15 * float(profile.get("defender", 1.0))
	if mode == MODE_DEFENSE_POSITION and slot_index == defense_slot_index:
		score += 3.2
	if mode == MODE_SUMMONER_BOSS:
		score += _boss_piece_protection_score(slot_index) * float(profile.get("protect", 1.0))
	return score

func _score_enemy_spell_play(card, target: Dictionary, hand_index: int) -> float:
	var profile: Dictionary = _enemy_ai_profile()
	var effect: Dictionary = Dictionary(card.effect)
	var action: String = str(effect.get("action", ""))
	var score: float = 1.0 - float(card.cost) * 0.12 - float(hand_index) * 0.01
	if bool(target.get("hero", false)):
		var amount: int = int(effect.get("amount", effect.get("damage", 0)))
		score += float(amount) * (1.0 + float(profile.get("direct", 1.0)))
		if player_health <= amount:
			score += 20.0
		return score
	if str(target.get("area", "")) == "board":
		score += float(_area_damage_targets(PLAYER_ID).size()) * (1.4 if action == "random_damage" else 1.0)
		if action in ["freeze_random_enemy", "poison_all_enemies"]:
			score += 2.0 * float(profile.get("control", 1.0))
		return score
	var occupant: Dictionary = _slot_occupant(str(target.get("owner", PLAYER_ID)), int(target.get("slot", -1)))
	if action == "buff_ally":
		score += _enemy_unit_value(occupant) * (0.35 + float(profile.get("protect", 1.0)) * 0.25)
	else:
		score += _player_unit_threat_score(occupant) * (0.30 + float(profile.get("high_value", 1.0)) * 0.18)
		if action in ["debuff", "weaken", "snare", "multi_debuff", "punish_snared"]:
			score += 2.4 * float(profile.get("control", 1.0))
		if int(effect.get("amount", effect.get("damage", 0))) >= int(occupant.get("health", 999)):
			score += 4.0
	return score

func _score_enemy_lane_for_profile(slot_index: int, profile: Dictionary) -> float:
	var score: float = 0.0
	var front: Dictionary = _slot_occupant(PLAYER_ID, slot_index)
	if front.is_empty():
		score += 1.0 * float(profile.get("empty_lane", 1.0))
	else:
		score += 1.0 * float(profile.get("lane_pressure", 1.0))
		score += _player_unit_threat_score(front) * 0.08 * float(profile.get("high_value", 1.0))
	var center: float = float(enemy_slots.size() - 1) * 0.5
	score -= abs(float(slot_index) - center) * 0.08
	return score

func _score_enemy_card_keywords(card, profile: Dictionary) -> float:
	var score: float = 0.0
	for keyword: String in card.keywords:
		match keyword:
			"defensor", "resistencia", "escudo", "crescer":
				score += 0.9 * float(profile.get("durability", 1.0)) + 0.45 * float(profile.get("protect", 1.0))
			"congelar", "veneno":
				score += 1.3 * float(profile.get("control", 1.0))
			"iniciativa", "ecoar", "atropelar":
				score += 1.0 * float(profile.get("direct", 1.0)) + 0.45 * float(profile.get("burst", 1.0))
			"brutal", "furia", "ressurgir":
				score += 1.15 * float(profile.get("trade", 1.0)) + 0.65 * float(profile.get("burst", 1.0))
			"espinhos":
				score += 0.65 * float(profile.get("trade", 1.0)) + 0.55 * float(profile.get("durability", 1.0))
	return score

func get_enemy_intent() -> Dictionary:
	if mode == MODE_SUMMONER_BOSS:
		return _boss_enemy_intent()
	return _common_enemy_intent()

func _common_enemy_intent() -> Dictionary:
	var profile: Dictionary = _enemy_ai_profile()
	var incoming: Dictionary = _estimate_enemy_incoming_pressure()
	var next_play: Dictionary = _best_enemy_play()
	var target_priority: Dictionary = _highest_value_player_target()
	var priorities: Array[String] = _profile_priority_lines(str(profile.get("display_name", "")))
	if not next_play.is_empty():
		priorities.append("Proxima jogada provavel: %s." % _intent_next_play_line(next_play))
	if not target_priority.is_empty():
		priorities.append("Alvo de maior valor: %s." % _target_display_name(target_priority))
	return {
		"visible": _intent_should_be_visible(),
		"kind": "common",
		"title": "Intencao inimiga",
		"profile_id": enemy_ai_profile_id,
		"profile_name": str(profile.get("display_name", "Terra")),
		"profile_summary": str(profile.get("summary", "")),
		"priorities": priorities,
		"target_priority": _target_display_name(target_priority) if not target_priority.is_empty() else "Heroi do jogador",
		"lane_pressure": Array(incoming.get("lanes", [])).duplicate(),
		"incoming_pressure": str(incoming.get("summary", "Sem pressao imediata.")),
		"incoming_field_effect": _profile_field_effect_hint(enemy_ai_profile_id),
		"next_action": _intent_next_play_line(next_play),
		"tooltip_ids": ["lane_pressure", "incoming_pressure", "control_target"]
	}

func _boss_enemy_intent() -> Dictionary:
	var common: Dictionary = _common_enemy_intent()
	var phase: Dictionary = _boss_phase_state()
	var next_special: String = _next_boss_special_action()
	var priorities: Array[String] = []
	for priority: Variant in Array(common.get("priorities", [])):
		priorities.append(str(priority))
	priorities.push_front("Fase atual: %s." % str(phase.get("label", "")))
	priorities.append("Acao especial: %s." % next_special)
	return {
		"visible": true,
		"kind": "boss",
		"title": "Intencao do chefe",
		"profile_id": enemy_ai_profile_id,
		"profile_name": str(common.get("profile_name", "")),
		"profile_summary": str(common.get("profile_summary", "")),
		"priorities": priorities,
		"target_priority": str(common.get("target_priority", "")),
		"lane_pressure": Array(common.get("lane_pressure", [])).duplicate(),
		"incoming_pressure": str(common.get("incoming_pressure", "")),
		"current_phase": str(phase.get("label", "")),
		"next_scripted_trigger": str(phase.get("next_trigger", "")),
		"next_major_special_action": next_special,
		"next_action": str(common.get("next_action", "")),
		"tooltip_ids": ["boss_phase", "lane_pressure", "incoming_pressure"]
	}

func _enemy_ai_profile() -> Dictionary:
	if ENEMY_AI_PROFILES.has(enemy_ai_profile_id):
		return Dictionary(ENEMY_AI_PROFILES[enemy_ai_profile_id])
	return Dictionary(ENEMY_AI_PROFILES[ENEMY_AI_TERRA])

func _resolve_enemy_ai_profile_id(encounter: Dictionary, config: Dictionary) -> String:
	var explicit_profile: String = str(config.get("enemy_ai_profile", encounter.get("enemy_ai_profile", ""))).to_lower()
	if ENEMY_AI_PROFILES.has(explicit_profile):
		return explicit_profile
	var inferred: String = _infer_enemy_ai_profile_from_encounter(encounter)
	if ENEMY_AI_PROFILES.has(inferred):
		return inferred
	return ENEMY_AI_TERRA

func _infer_enemy_ai_profile_from_encounter(encounter: Dictionary) -> String:
	var profile_counts: Dictionary = {ENEMY_AI_TERRA: 0, ENEMY_AI_GELO: 0, ENEMY_AI_AR: 0, ENEMY_AI_FOGO: 0}
	for card_id: String in _typed_string_array(Array(encounter.get("enemy_deck", []))):
		_count_profile_hint(profile_counts, card_id)
	for setup: Variant in Array(encounter.get("starting_enemy_slots", [])):
		if typeof(setup) == TYPE_DICTIONARY:
			_count_profile_hint(profile_counts, str(Dictionary(setup).get("card_id", "")))
	for summon: Variant in Array(encounter.get("boss_summons", [])):
		if typeof(summon) == TYPE_DICTIONARY:
			_count_profile_hint(profile_counts, str(Dictionary(summon).get("card_id", "")))
	var best_profile: String = ENEMY_AI_TERRA
	var best_count: int = -1
	for profile_id: String in [ENEMY_AI_TERRA, ENEMY_AI_GELO, ENEMY_AI_AR, ENEMY_AI_FOGO]:
		var count: int = int(profile_counts.get(profile_id, 0))
		if count > best_count:
			best_count = count
			best_profile = profile_id
	return best_profile

func _count_profile_hint(profile_counts: Dictionary, card_id: String) -> void:
	for profile_id: String in [ENEMY_AI_TERRA, ENEMY_AI_GELO, ENEMY_AI_AR, ENEMY_AI_FOGO]:
		if card_id.begins_with("enemy_%s_" % profile_id) or card_id.find("_%s_" % profile_id) >= 0:
			profile_counts[profile_id] = int(profile_counts.get(profile_id, 0)) + 1
			return

func _player_unit_threat_score(occupant: Dictionary) -> float:
	if occupant.is_empty():
		return 0.0
	var score: float = float(int(occupant.get("attack", 0)) * 2 + int(occupant.get("health", 0)))
	if bool(occupant.get("objective", false)):
		score += 12.0
	if bool(occupant.get("defensor", false)):
		score += 4.0
	if bool(occupant.get("iniciativa", false)) or bool(occupant.get("atropelar", false)) or bool(occupant.get("brutal", false)) or bool(occupant.get("ecoar", false)):
		score += 3.0
	if bool(occupant.get("espinhos", false)) or int(occupant.get("thorns_amount", 0)) > 0:
		score += 2.0
	if bool(occupant.get("escudo", false)) or bool(occupant.get("resistencia", false)) or bool(occupant.get("imune", false)):
		score += 2.0
	return score

func _enemy_unit_value(occupant: Dictionary) -> float:
	if occupant.is_empty():
		return 0.0
	var score: float = float(int(occupant.get("attack", 0)) * 2 + int(occupant.get("health", 0)))
	if bool(occupant.get("defensor", false)) or bool(occupant.get("resistencia", false)) or bool(occupant.get("escudo", false)):
		score += 3.0
	if bool(occupant.get("crescer", false)) or bool(occupant.get("furia", false)) or bool(occupant.get("ressurgir", false)):
		score += 3.0
	return score

func _boss_piece_protection_score(slot_index: int) -> float:
	var score: float = 0.0
	for index: int in range(enemy_slots.size()):
		var occupant: Dictionary = _slot_occupant(ENEMY_ID, index)
		if occupant.is_empty():
			continue
		var distance: int = absi(index - slot_index)
		if distance <= 1:
			score += _enemy_unit_value(occupant) * (0.18 if distance == 0 else 0.10)
	return score

func _intent_should_be_visible() -> bool:
	return enemy_commander_enabled or not _board_is_clear(ENEMY_ID) or mode in [MODE_WAVES, MODE_DEFENSE_POSITION, MODE_SURVIVE_TURNS, MODE_SUMMONER_BOSS, MODE_AMBUSH, MODE_ESCORT, MODE_INVASION]

func _profile_priority_lines(profile_name: String) -> Array[String]:
	match enemy_ai_profile_id:
		ENEMY_AI_GELO:
			return ["Perfil %s: controla a maior ameaca." % profile_name, "Prioriza Veneno, Congelar e atrito."]
		ENEMY_AI_AR:
			return ["Perfil %s: pressiona lanes vazias." % profile_name, "Prioriza Iniciativa, Atropelar e dano rapido."]
		ENEMY_AI_FOGO:
			return ["Perfil %s: aceita trocas explosivas." % profile_name, "Prioriza Brutal, Furia, morte e dano direto."]
		_:
			return ["Perfil %s: estabiliza a mesa." % profile_name, "Prioriza Defensor, Espinhos, Resistencia e Crescer."]

func _profile_field_effect_hint(profile_id: String) -> String:
	var active_hint: String = _active_field_effect_hint()
	if active_hint != "":
		return active_hint
	match profile_id:
		ENEMY_AI_GELO:
			return "Controle/atrito provavel: Congelar, Veneno ou atraso no alvo forte."
		ENEMY_AI_AR:
			return "Pressao posicional provavel: lane vazia, Iniciativa ou Atropelar."
		ENEMY_AI_FOGO:
			return "Troca explosiva provavel: Brutal, Furia, Espinhos ou morte em cadeia."
		_:
			return "Estabilizacao provavel: bloqueios, Espinhos, Resistencia ou Crescer."

func _highest_value_player_target() -> Dictionary:
	var best_target: Dictionary = {}
	var best_score: float = -1.0
	for index: int in range(player_slots.size()):
		var occupant: Dictionary = _slot_occupant(PLAYER_ID, index)
		if occupant.is_empty():
			continue
		var score: float = _player_unit_threat_score(occupant)
		if best_target.is_empty() or score > best_score:
			best_score = score
			best_target = {"owner": PLAYER_ID, "slot": index}
	return best_target

func _estimate_enemy_incoming_pressure() -> Dictionary:
	var lanes: Array[String] = []
	var hero_damage: int = 0
	var board_damage: int = 0
	for slot_index: int in range(enemy_slots.size()):
		var attacker: Dictionary = _slot_occupant(ENEMY_ID, slot_index)
		if attacker.is_empty():
			continue
		if int(attacker.get("frozen_turns", 0)) > 0 or int(attacker.get("slow_turns", 0)) > 0:
			lanes.append("Lane %d: ataque atrasado por controle." % (slot_index + 1))
			continue
		var target: Dictionary = _front_attack_target(ENEMY_ID, slot_index)
		if target.is_empty():
			target = _overflow_attack_target(ENEMY_ID, slot_index)
		if target.is_empty():
			continue
		var damage: int = int(attacker.get("attack", 0)) + _inspire_bonus_for(ENEMY_ID, slot_index) + _board_attack_bonus(ENEMY_ID, slot_index)
		if bool(target.get("hero", false)):
			hero_damage += damage
		else:
			board_damage += damage
		lanes.append("Lane %d: %d dano em %s." % [slot_index + 1, damage, _target_display_name(target)])
	var summary: String = "%d dano ao heroi, %d em criaturas." % [hero_damage, board_damage]
	if hero_damage == 0 and board_damage == 0 and lanes.is_empty():
		summary = "Sem ataque imediato no proximo combate."
	return {"hero_damage": hero_damage, "board_damage": board_damage, "lanes": lanes, "summary": summary}

func _intent_next_play_line(play: Dictionary) -> String:
	if play.is_empty():
		return "Sem carta clara para jogar."
	var hand_index: int = int(play.get("hand_index", -1))
	if hand_index < 0 or hand_index >= enemy_hand.size():
		return "Sem carta clara para jogar."
	var card = _card(enemy_hand[hand_index])
	if card == null:
		return "Sem carta clara para jogar."
	return "%s em %s" % [card.display_name, _target_display_name(Dictionary(play.get("target", {})))]

func _active_field_effect_hint() -> String:
	if field_effects.is_empty():
		return ""
	var labels: Array[String] = []
	for effect_id: String in field_effects:
		var tooltip: String = ContentLibrary.board_effect_tooltip_text(effect_id)
		if tooltip == "":
			labels.append(effect_id)
			continue
		labels.append(tooltip.split(":")[0])
	return "Efeito de campo ativo: %s." % ", ".join(labels)

func _boss_phase_state() -> Dictionary:
	var ratio: float = 1.0 if enemy_max_health <= 0 else float(enemy_health) / float(enemy_max_health)
	if ratio > 0.66:
		return {"label": "Fase 1 - invocacao", "next_trigger": "HP <= 66% ou proxima manutencao."}
	if ratio > 0.33:
		return {"label": "Fase 2 - pressao", "next_trigger": "HP <= 33% ou mesa inimiga vazia."}
	return {"label": "Fase 3 - ruptura", "next_trigger": "Especial final em manutencoes futuras."}

func _next_boss_special_action() -> String:
	if not boss_phase_hooks.is_empty():
		for index: int in range(boss_phase_hooks.size()):
			var hook: Dictionary = boss_phase_hooks[index]
			var hook_id: String = str(hook.get("id", "hook_%d" % index))
			if bool(boss_phase_hook_state.get(hook_id, false)):
				continue
			var description: String = str(hook.get("description", hook.get("action", "")))
			if description != "":
				return description
	if boss_summons.is_empty():
		return "Sem especial roteirizado neste encontro."
	var summon: Dictionary = boss_summons[boss_summon_index % boss_summons.size()]
	var card = _card(str(summon.get("card_id", "")))
	if card == null:
		return "Invocacao roteirizada pendente."
	return "Invocar %s na proxima manutencao disponivel." % card.display_name

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
	if board_format == BOARD_FORMAT_FRONT_REAR and slot_index >= 3:
		var own_slots: Array = _slots_for_owner(owner_id)
		var front_index: int = slot_index - 3
		if front_index >= 0 and front_index < own_slots.size() and own_slots[front_index] != null:
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
	if int(occupant.get("frozen_turns", 0)) > 0:
		occupant["frozen_turns"] = int(occupant.get("frozen_turns", 0)) - 1
		slots[slot_index] = occupant
		_set_slots_for_owner(owner_id, slots)
		_log("%s perdeu o ataque por Congelado." % str(occupant.get("name", "Criatura")))
		return {"can_attack": false, "consumed": true}
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
	var damaged_slots: Array[Dictionary] = []
	for attack: Dictionary in attacks:
		var amount: int = int(attack.get("damage", 0))
		visual_events.append(attack.duplicate(true))
		if bool(attack.get("target_hero", false)):
			var hero_owner: String = str(attack.get("target_owner", ENEMY_ID))
			_damage_hero(hero_owner, amount)
			_apply_attack_success_keywords(attack, {"damage_dealt": amount, "target_hero": true}, damaged_slots)
			_log("%s recebeu %d de dano." % [_hero_log_name(hero_owner), amount])
			visual_events.append({"type": "damage", "stage": stage_name, "target_owner": hero_owner, "target_hero": true, "amount": amount, "health_after": player_health if hero_owner == PLAYER_ID else enemy_health})
			continue
		var target_owner: String = str(attack.get("target_owner", ENEMY_ID))
		var target_slot: int = int(attack.get("target_slot", -1))
		var damage_result: Dictionary = _deal_slot_damage(target_owner, target_slot, amount, {
			"stage": stage_name,
			"source_owner": str(attack.get("source_owner", "")),
			"source_slot": int(attack.get("source_slot", -1)),
			"source_kind": "combat",
			"defer_death": true,
			"bypass_resistance": false
		})
		if damage_result.is_empty():
			continue
		var damage_event: Dictionary = {
			"type": "damage",
			"stage": stage_name,
			"target_owner": target_owner,
			"target_slot": target_slot,
			"target_card_id": str(Dictionary(damage_result.get("occupant", {})).get("card_id", "")),
			"amount": int(damage_result.get("damage_dealt", 0)),
			"prevented": int(damage_result.get("prevented", 0)),
			"health_after": int(damage_result.get("health_after", 0))
		}
		var event_index: int = visual_events.size()
		visual_events.append(damage_event)
		_queue_damaged_slot(damaged_slots, target_owner, target_slot, event_index)
		_log("%s recebeu %d de dano." % [str(Dictionary(damage_result.get("occupant", {})).get("name", "Criatura")), int(damage_result.get("damage_dealt", 0))])
		_apply_attack_success_keywords(attack, damage_result, damaged_slots)
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

func _queue_damaged_slot(damaged_slots: Array[Dictionary], owner_id: String, slot_index: int, event_index: int = -1) -> void:
	for existing: Dictionary in damaged_slots:
		if str(existing.get("owner", "")) == owner_id and int(existing.get("slot", -1)) == slot_index:
			if int(existing.get("event_index", -1)) < 0 and event_index >= 0:
				existing["event_index"] = event_index
			return
	damaged_slots.append({"owner": owner_id, "slot": slot_index, "event_index": event_index})

func _destroy_queued_damaged_slots(damaged_slots: Array[Dictionary]) -> void:
	for damaged: Dictionary in damaged_slots:
		var owner_id: String = str(damaged.get("owner", ""))
		var slot_index: int = int(damaged.get("slot", -1))
		var current: Dictionary = _slot_occupant(owner_id, slot_index)
		if current.is_empty():
			continue
		_store_or_destroy_lane_unit(owner_id, slot_index, current)

func _apply_attack_success_keywords(attack: Dictionary, damage_result: Dictionary, damaged_slots: Array[Dictionary]) -> void:
	var damage_dealt: int = int(damage_result.get("damage_dealt", 0))
	if damage_dealt <= 0:
		return
	var source_owner: String = str(attack.get("source_owner", ""))
	var source_slot: int = int(attack.get("source_slot", -1))
	var attacker: Dictionary = _slot_occupant(source_owner, source_slot)
	if attacker.is_empty():
		return
	_apply_drain(source_owner, int(attacker.get("drain_amount", 0)))
	if bool(attacker.get("veneno", false)) and not bool(damage_result.get("target_hero", false)):
		_apply_poison_to_slot(str(damage_result.get("target_owner", "")), int(damage_result.get("target_slot", -1)), int(attacker.get("poison_apply_amount", 1)))
	if bool(attacker.get("congelar", false)) and not bool(damage_result.get("target_hero", false)):
		_apply_freeze_to_slot(str(damage_result.get("target_owner", "")), int(damage_result.get("target_slot", -1)), 1)
	if bool(attacker.get("drenar_almas", false)) and not bool(damage_result.get("target_hero", false)) and int(damage_result.get("health_after", 1)) <= 0:
		var dead_attack: int = int(Dictionary(damage_result.get("occupant", {})).get("attack", 0))
		bonus_souls += max(0, dead_attack)
		_log("%s drenou %d Alma(s)." % [str(attacker.get("name", "Criatura")), max(0, dead_attack)])
	if bool(attacker.get("brutal", false)) and not bool(damage_result.get("target_hero", false)) and str(attack.get("stage", "")).find("Frente") >= 0:
		_apply_brutal_damage(attack, damaged_slots)
	if bool(attacker.get("atropelar", false)) and not bool(damage_result.get("target_hero", false)) and int(damage_result.get("excess", 0)) > 0:
		_apply_trample_damage(attack, int(damage_result.get("excess", 0)), damaged_slots)
	if int(Dictionary(damage_result.get("occupant", {})).get("thorns_amount", 0)) > 0 and not bool(damage_result.get("target_hero", false)):
		_apply_thorns_damage(attack, damage_result, damaged_slots)
	if bool(attacker.get("ecoar", false)) and not bool(attacker.get("echo_used", false)):
		_mark_echo_used(source_owner, source_slot)
		_apply_echo_damage(attack, damage_dealt, damaged_slots)

func _apply_brutal_damage(attack: Dictionary, damaged_slots: Array[Dictionary]) -> void:
	var target_owner: String = str(attack.get("target_owner", ""))
	var target_slot: int = int(attack.get("target_slot", -1))
	for adjacent_slot: int in [target_slot - 1, target_slot + 1]:
		var result: Dictionary = _deal_slot_damage(target_owner, adjacent_slot, 1, {
			"source_owner": str(attack.get("source_owner", "")),
			"source_slot": int(attack.get("source_slot", -1)),
			"source_kind": "combat",
			"defer_death": true
		})
		if result.is_empty():
			continue
		_queue_damaged_slot(damaged_slots, target_owner, adjacent_slot, -1)

func _apply_trample_damage(attack: Dictionary, excess: int, damaged_slots: Array[Dictionary]) -> void:
	var target: Dictionary = _trample_overflow_target(str(attack.get("source_owner", "")), int(attack.get("source_slot", -1)), str(attack.get("target_owner", "")), int(attack.get("target_slot", -1)))
	if target.is_empty():
		return
	if bool(target.get("hero", false)):
		_damage_hero(str(target.get("owner", "")), excess)
		_apply_drain(str(attack.get("source_owner", "")), int(_slot_occupant(str(attack.get("source_owner", "")), int(attack.get("source_slot", -1))).get("drain_amount", 0)))
		_log("Atropelar causou %d de dano excedente." % excess)
		return
	var result: Dictionary = _deal_slot_damage(str(target.get("owner", "")), int(target.get("slot", -1)), excess, {
		"source_owner": str(attack.get("source_owner", "")),
		"source_slot": int(attack.get("source_slot", -1)),
		"source_kind": "combat",
		"defer_death": true
	})
	if not result.is_empty():
		_queue_damaged_slot(damaged_slots, str(target.get("owner", "")), int(target.get("slot", -1)), -1)
		_log("Atropelar causou %d de dano excedente." % int(result.get("damage_dealt", 0)))

func _apply_thorns_damage(attack: Dictionary, damage_result: Dictionary, damaged_slots: Array[Dictionary]) -> void:
	var thorns: int = int(Dictionary(damage_result.get("occupant", {})).get("thorns_amount", 0))
	if thorns <= 0:
		return
	var source_owner: String = str(attack.get("source_owner", ""))
	var source_slot: int = int(attack.get("source_slot", -1))
	var result: Dictionary = _deal_slot_damage(source_owner, source_slot, thorns, {
		"source_kind": "combat",
		"defer_death": true,
		"bypass_resistance": true
	})
	if result.is_empty():
		return
	_queue_damaged_slot(damaged_slots, source_owner, source_slot, -1)
	_log("Espinhos devolveu %d de dano." % int(result.get("damage_dealt", 0)))

func _apply_echo_damage(attack: Dictionary, damage: int, damaged_slots: Array[Dictionary]) -> void:
	if damage <= 0:
		return
	if bool(attack.get("target_hero", false)):
		_damage_hero(str(attack.get("target_owner", "")), damage)
		_apply_drain(str(attack.get("source_owner", "")), int(_slot_occupant(str(attack.get("source_owner", "")), int(attack.get("source_slot", -1))).get("drain_amount", 0)))
		_log("Ecoar repetiu %d de dano." % damage)
		return
	var result: Dictionary = _deal_slot_damage(str(attack.get("target_owner", "")), int(attack.get("target_slot", -1)), damage, {
		"source_owner": str(attack.get("source_owner", "")),
		"source_slot": int(attack.get("source_slot", -1)),
		"source_kind": "combat",
		"defer_death": true
	})
	if result.is_empty():
		return
	_queue_damaged_slot(damaged_slots, str(attack.get("target_owner", "")), int(attack.get("target_slot", -1)), -1)
	_log("Ecoar repetiu %d de dano." % int(result.get("damage_dealt", 0)))

func _build_attack_event(stage_name: String, owner_id: String, slot_index: int, target: Dictionary) -> Dictionary:
	var attacker: Dictionary = _slot_occupant(owner_id, slot_index)
	var damage: int = int(attacker.get("attack", 0)) + _inspire_bonus_for(owner_id, slot_index) + _board_attack_bonus(owner_id, slot_index)
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
		dead_unit_count += 1
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
	_recalculate_pact_bonuses(owner_id)
	return result

func _resolve_attack(owner_id: String, slot_index: int, target: Dictionary) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	var attacker: Dictionary = Dictionary(slots[slot_index])
	var damage: int = int(attacker.get("attack", 0)) + _inspire_bonus_for(owner_id, slot_index) + _board_attack_bonus(owner_id, slot_index)
	if bool(target.get("hero", false)):
		_damage_hero(str(target.get("owner", _opponent_id(owner_id))), damage)
		_log("%s atacou diretamente." % str(attacker.get("name", "Criatura")))
		return
	var target_owner: String = str(target.get("owner", _opponent_id(owner_id)))
	var target_slot: int = int(target.get("slot", -1))
	var damaged_slots: Array[Dictionary] = []
	var attack: Dictionary = _build_attack_event("Ataque manual", owner_id, slot_index, target)
	var result: Dictionary = _deal_slot_damage(target_owner, target_slot, damage, {
		"source_owner": owner_id,
		"source_slot": slot_index,
		"source_kind": "combat",
		"defer_death": true
	})
	if not result.is_empty():
		_queue_damaged_slot(damaged_slots, target_owner, target_slot, -1)
		_apply_attack_success_keywords(attack, result, damaged_slots)
		_destroy_queued_damaged_slots(damaged_slots)
	_log("%s atacou o slot %d." % [str(attacker.get("name", "Criatura")), target_slot + 1])

func _damage_slot(owner_id: String, slot_index: int, amount: int, source_kind: String = "effect") -> void:
	_deal_slot_damage(owner_id, slot_index, amount, {"source_kind": source_kind})

func _deal_slot_damage(owner_id: String, slot_index: int, amount: int, context: Dictionary = {}) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return {}
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if bool(occupant.get("imune", false)) and str(context.get("source_kind", "")) in ["spell", "class_active", "debuff"]:
		return {
			"occupant": occupant.duplicate(true),
			"damage_dealt": 0,
			"prevented": amount,
			"health_before": int(occupant.get("health", 0)),
			"health_after": int(occupant.get("health", 0)),
			"excess": 0
		}
	var incoming: int = max(0, amount)
	var prevented: int = 0
	if incoming > 0 and int(occupant.get("shield_charges", 0)) > 0:
		occupant["shield_charges"] = int(occupant.get("shield_charges", 0)) - 1
		if int(occupant.get("shield_charges", 0)) <= 0:
			_remove_keyword_from_occupant(occupant, "escudo")
		prevented += incoming
		incoming = 0
	if incoming > 0 and not bool(context.get("bypass_resistance", false)):
		var resistance_remaining: int = int(occupant.get("resistance_remaining", occupant.get("resistance_amount", 0)))
		if resistance_remaining > 0:
			var blocked: int = mini(resistance_remaining, incoming)
			resistance_remaining -= blocked
			incoming -= blocked
			prevented += blocked
			occupant["resistance_remaining"] = resistance_remaining
	var health_before: int = int(occupant.get("health", 0))
	occupant["health"] = health_before - incoming
	if incoming > 0 and str(context.get("source_kind", "")) == "combat" and bool(occupant.get("furia", false)):
		occupant["fury_pending"] = true
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)
	var result: Dictionary = {
		"occupant": occupant.duplicate(true),
		"damage_dealt": incoming,
		"prevented": prevented,
		"health_before": health_before,
		"health_after": int(occupant.get("health", 0)),
		"excess": maxi(0, incoming - maxi(0, health_before)),
		"target_owner": owner_id,
		"target_slot": slot_index
	}
	if not bool(context.get("defer_death", false)):
		_destroy_queued_damaged_slots([{"owner": owner_id, "slot": slot_index, "event_index": -1}])
	return result

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
	if mode == MODE_ESCORT and not _escort_objective_alive():
		outcome = "derrota"
		current_phase = PHASE_ENDED
		return
	if _enemy_hero_is_objective() and enemy_health <= 0:
		outcome = "vitoria"
		current_phase = PHASE_ENDED
		return
	if mode in [MODE_CLEAR_BOARD, MODE_AMBUSH, MODE_INVASION] and _board_is_clear(ENEMY_ID):
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
	if mode == MODE_ESCORT and _escort_objective_reached_goal():
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

func _setup_escort_objective() -> void:
	if player_slots.is_empty():
		return
	player_slots[0] = {
		"owner": PLAYER_ID,
		"card_id": "",
		"name": "Cargo de Escolta",
		"attack": 0,
		"health": int(field_effect_state.get("escort_health", 6)) if field_effect_state.has("escort_health") else 6,
		"max_health": int(field_effect_state.get("escort_health", 6)) if field_effect_state.has("escort_health") else 6,
		"base_attack": 0,
		"base_health": 6,
		"ready": false,
		"keywords": [],
		"iniciativa": false,
		"regeneracao": false,
		"defensor": false,
		"reviver": false,
		"revive_marker": false,
		"objective": true,
		"escort": true,
		"moved_this_turn": false,
		"slow_turns": 0,
		"frozen_turns": 0,
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

func _escort_objective_target() -> Dictionary:
	for index: int in range(player_slots.size()):
		if player_slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(player_slots[index])
		if bool(occupant.get("escort", false)):
			return {"owner": PLAYER_ID, "slot": index}
	return {}

func _escort_objective_alive() -> bool:
	return not _escort_objective_target().is_empty()

func _escort_objective_reached_goal() -> bool:
	var target: Dictionary = _escort_objective_target()
	return not target.is_empty() and int(target.get("slot", -1)) >= player_slots.size() - 1

func _advance_escort_objective() -> void:
	var target: Dictionary = _escort_objective_target()
	if target.is_empty():
		return
	var slot_index: int = int(target.get("slot", -1))
	if slot_index >= player_slots.size() - 1:
		return
	var next_slot: int = slot_index + 1
	if player_slots[next_slot] != null:
		_log("Cargo de Escolta aguardou caminho livre.")
		return
	player_slots[next_slot] = player_slots[slot_index]
	player_slots[slot_index] = null
	_log("Cargo de Escolta avancou para o slot %d." % (next_slot + 1))

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
	var shield_charges: int = int(effect.get("shield_charges", 0))
	if shield_charges <= 0 and card.has_keyword("escudo"):
		shield_charges = 1
	var resistance_amount: int = int(effect.get("resistance_amount", effect.get("resistance", 0)))
	if resistance_amount <= 0 and card.has_keyword("resistencia"):
		resistance_amount = 1
	var thorns_amount: int = int(effect.get("thorns_amount", effect.get("thorns", 0)))
	if thorns_amount <= 0 and card.has_keyword("espinhos"):
		thorns_amount = 1
	var grow_amount: int = int(effect.get("grow_amount", effect.get("grow", 0)))
	if grow_amount <= 0 and card.has_keyword("crescer"):
		grow_amount = 1
	var drain_amount: int = int(effect.get("drain_amount", effect.get("drain", 0)))
	if drain_amount <= 0 and card.has_keyword("drenar"):
		drain_amount = 1
	var poison_amount: int = int(effect.get("poison_apply_amount", effect.get("poison", 0)))
	if poison_amount <= 0 and card.has_keyword("veneno"):
		poison_amount = 1
	var inspire_amount: int = int(effect.get("inspire_amount", effect.get("inspire", 0)))
	if inspire_amount <= 0 and card.has_keyword("inspirar"):
		inspire_amount = 1
	var pact_amount: int = int(effect.get("pact_amount", effect.get("pact", 0)))
	if pact_amount <= 0 and card.has_keyword("pacto"):
		pact_amount = 2
	var sacrifice_discount: int = int(effect.get("sacrifice_discount", effect.get("sacrifice", 0)))
	if sacrifice_discount <= 0 and card.has_keyword("sacrificio"):
		sacrifice_discount = 1
	return {
		"owner": owner_id,
		"card_id": card.id,
		"name": card.display_name,
		"attack": int(card.attack),
		"health": int(card.health),
		"max_health": int(card.health),
		"base_attack": int(card.attack),
		"base_health": int(card.health),
		"ready": ready,
		"keywords": Array(card.keywords),
		"iniciativa": card.has_keyword("iniciativa"),
		"regeneracao": regeneration > 0,
		"defensor": card.has_keyword("defensor"),
		"reviver": card.has_keyword("reviver"),
		"atropelar": card.has_keyword("atropelar"),
		"brutal": card.has_keyword("brutal"),
		"drenar": card.has_keyword("drenar"),
		"espinhos": card.has_keyword("espinhos"),
		"escudo": card.has_keyword("escudo"),
		"resistencia": card.has_keyword("resistencia"),
		"imune": card.has_keyword("imune"),
		"crescer": card.has_keyword("crescer"),
		"furia": card.has_keyword("furia"),
		"ecoar": card.has_keyword("ecoar"),
		"veneno": card.has_keyword("veneno"),
		"congelar": card.has_keyword("congelar"),
		"profanar": card.has_keyword("profanar"),
		"proliferar": card.has_keyword("proliferar"),
		"inspirar": card.has_keyword("inspirar"),
		"pacto": card.has_keyword("pacto"),
		"drenar_almas": card.has_keyword("drenar_almas"),
		"ressurgir": card.has_keyword("ressurgir"),
		"revive_marker": false,
		"ressurgir_marker": false,
		"moved_this_turn": false,
		"slow_turns": 0,
		"frozen_turns": 0,
		"curse_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 0,
		"temporary_health_bonus": 0,
		"regeneration_amount": regeneration,
		"carrion_amount": carrion,
		"shield_charges": shield_charges,
		"resistance_amount": resistance_amount,
		"resistance_remaining": resistance_amount,
		"thorns_amount": thorns_amount,
		"grow_amount": grow_amount,
		"drain_amount": drain_amount,
		"poison_apply_amount": poison_amount,
		"poison_amount": 0,
		"inspire_amount": inspire_amount,
		"pact_amount": pact_amount,
		"pact_bonus_attack": 0,
		"pact_bonus_health": 0,
		"sacrifice_discount": sacrifice_discount,
		"echo_used": false,
		"fury_pending": false
	}

func _after_card_played() -> void:
	if selected_class_id == "arcano" and class_passive_unlocked:
		flow += 1

func _resolve_on_enter(card, owner_id: String = PLAYER_ID, slot_index: int = -1) -> void:
	var effect: Dictionary = Dictionary(card.effect)
	var on_enter: Dictionary = Dictionary(effect.get("on_enter", {}))
	match str(on_enter.get("action", "")):
		"gain_mana":
			mana += int(on_enter.get("amount", 0))
			_log("%s gerou %d de mana neste turno." % [card.display_name, int(on_enter.get("amount", 0))])
		"damage_random_enemy", "random_enemy_damage":
			_damage_random_target(_opponent_id(owner_id), int(on_enter.get("amount", 1)), "effect")
			_log("%s disparou dano ao entrar." % card.display_name)
		"poison_random_enemy":
			_apply_poison_to_random(_opponent_id(owner_id), int(on_enter.get("amount", 1)))
			_log("%s aplicou Veneno ao entrar." % card.display_name)
		"summon_token":
			var count: int = maxi(1, int(on_enter.get("count", 1)))
			for _i: int in range(count):
				if not _summon_token(owner_id, int(on_enter.get("attack", 1)), int(on_enter.get("health", 1)), str(on_enter.get("name", "Recruta"))):
					break
			_log("%s chamou reforcos ao entrar." % card.display_name)
		"buff_lowest_ally":
			var target_slot: int = _lowest_health_slot(owner_id)
			if target_slot >= 0:
				_buff_slot(owner_id, target_slot, int(on_enter.get("attack", 0)), int(on_enter.get("health", 0)), false)
				_log("%s fortaleceu aliada ao entrar." % card.display_name)
		"revive_last_ally":
			var open_slot: int = _first_strict_open_slot(_slots_for_owner(owner_id))
			if owner_id == PLAYER_ID and open_slot >= 0 and _revive_from_discard_into_slot(true, open_slot):
				_log("%s reanimou uma aliada ao entrar." % card.display_name)
	if slot_index >= 0:
		_recalculate_pact_bonuses(owner_id)

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

func _apply_relic_summon_bonuses(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= player_slots.size() or player_slots[slot_index] == null:
		return
	if _has_relic(RELIC_MARCA_DE_GUERRA) and not first_summon_health_relic_used:
		first_summon_health_relic_used = true
		_buff_slot(PLAYER_ID, slot_index, 0, 1, false)
		_log("Marca de Guerra concedeu +1 HP.")
	if _has_relic(RELIC_ESTANDARTE_VIVO) and not first_summon_attack_relic_used:
		first_summon_attack_relic_used = true
		_buff_slot(PLAYER_ID, slot_index, 1, 0, true)
		_log("Estandarte Vivo concedeu +1 ATK temporario.")

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
	if owner_id == ENEMY_ID and _field_effect_active(FIELD_FURIA_ABISMO):
		_summon_token(ENEMY_ID, 3, 1, "Fragmento Enfurecido")
		_log("Furia do Abismo fortaleceu o proximo reforco.")
	if _field_effect_active(FIELD_FRIO_INTENSO):
		_log("Frio Intenso anulou efeitos de morte.")
		return _death_field_replacement(owner_id, occupant)
	_trigger_carrion(owner_id, occupant)
	if bool(occupant.get("profanar", false)):
		_remove_keywords_from_random_enemy(owner_id)
	var card = _card(str(occupant.get("card_id", "")))
	if card != null:
		var on_death: Dictionary = Dictionary(Dictionary(card.effect).get("on_death", {}))
		if str(on_death.get("action", "")) == "damage":
			_damage_first_enemy(int(on_death.get("amount", 0)) + _ability_power_bonus())
		elif str(on_death.get("action", "")) == "random_enemy_damage":
			_damage_random_enemy(int(on_death.get("amount", 0)) + _ability_power_bonus())
		elif str(on_death.get("action", "")) == "poison_random_enemy":
			_apply_poison_to_random(_opponent_id(owner_id), int(on_death.get("amount", 1)))
		elif str(on_death.get("action", "")) == "freeze_random_enemy":
			_freeze_random_enemies(false, 1, int(on_death.get("amount", 1)), _opponent_id(owner_id))
		elif str(on_death.get("action", "")) == "summon_token":
			for _index: int in range(maxi(1, int(on_death.get("count", 1)))):
				if not _summon_token(owner_id, int(on_death.get("attack", 1)), int(on_death.get("health", 1)), str(on_death.get("name", "Token"))):
					break
		elif str(on_death.get("action", "")) == "adjacent_enemy_damage":
			_damage_random_target(_opponent_id(owner_id), int(on_death.get("amount", 1)), "on_death")
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
	if allow_revive and bool(occupant.get("ressurgir", false)) and not bool(occupant.get("ressurgir_marker", false)):
		var revived_weak: Dictionary = _resurrect_occupant(owner_id, occupant)
		var on_ressurgir: Dictionary = Dictionary(Dictionary(card.effect if card != null else {}).get("on_ressurgir", {}))
		if str(on_ressurgir.get("action", "")) == "weaken_random_enemy":
			_apply_debuff_to_target({"debuff": "weaken", "amount": int(on_ressurgir.get("amount", 1))}, _nearest_occupied_slot_target(_opponent_id(owner_id), 0))
		_log("%s ressurgiu enfraquecido." % str(occupant.get("name", "Criatura")))
		return revived_weak
	return _death_field_replacement(owner_id, occupant)

func _death_field_replacement(owner_id: String, occupant: Dictionary) -> Dictionary:
	var base_health: int = int(occupant.get("base_health", occupant.get("max_health", 0)))
	var threshold: int = 99999
	if _field_effect_active(FIELD_CINZAS_VIVAS):
		threshold = 3
	if _field_effect_active(FIELD_INFERNO_TOTAL):
		threshold = mini(threshold, 4)
	if base_health < threshold:
		return {}
	_log("Cinzas Vivas deixaram uma Brasa no slot.")
	return _build_token_occupant(owner_id, 1, 1, "Brasa")

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
	if bool(occupant.get("imune", false)):
		_log("%s ignorou efeito negativo por Imune." % str(occupant.get("name", "Criatura")))
		return
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
		"freeze", "congelar":
			occupant["frozen_turns"] = max(int(occupant.get("frozen_turns", 0)), amount)
		"poison", "veneno":
			occupant["poison_amount"] = _stacked_poison_amount(int(occupant.get("poison_amount", 0)), amount)
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)
	if int(occupant.get("health", 0)) <= 0:
		_damage_slot(owner_id, slot_index, 0, "debuff")

func _remove_keywords_from_target(target: Dictionary) -> void:
	if not target.has("slot"):
		return
	var owner_id: String = str(target.get("owner", ENEMY_ID))
	var slot_index: int = int(target.get("slot", -1))
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if bool(occupant.get("imune", false)):
		_log("%s manteve keywords por Imune." % str(occupant.get("name", "Criatura")))
		return
	occupant["keywords"] = []
	occupant["iniciativa"] = false
	occupant["regeneracao"] = false
	occupant["defensor"] = false
	occupant["reviver"] = false
	occupant["regeneration_amount"] = 0
	occupant["carrion_amount"] = 0
	for keyword: String in ["atropelar", "brutal", "drenar", "espinhos", "escudo", "resistencia", "crescer", "furia", "ecoar", "veneno", "congelar", "profanar", "proliferar", "inspirar", "pacto", "drenar_almas", "ressurgir"]:
		occupant[keyword] = false
	for key: String in ["shield_charges", "resistance_amount", "resistance_remaining", "thorns_amount", "grow_amount", "drain_amount", "poison_apply_amount", "inspire_amount", "pact_amount"]:
		occupant[key] = 0
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)
	_recalculate_pact_bonuses(owner_id)

func _remove_keywords_from_random_enemy(dead_owner_id: String) -> void:
	var targets: Array[Dictionary] = _targetable_occupied_slot_targets(_opponent_id(dead_owner_id), true)
	if targets.is_empty():
		return
	var target: Dictionary = targets[_rng.randi_range(0, targets.size() - 1)]
	_remove_keywords_from_target(target)
	_log("Profanar removeu keywords de uma criatura inimiga.")

func _remove_keyword_from_occupant(occupant: Dictionary, keyword: String) -> void:
	var keywords: Array = Array(occupant.get("keywords", []))
	if keywords.has(keyword):
		keywords.erase(keyword)
	occupant["keywords"] = keywords
	occupant[keyword] = false

func _resurrect_occupant(owner_id: String, occupant: Dictionary) -> Dictionary:
	var revived: Dictionary = occupant.duplicate(true)
	var base_attack: int = int(occupant.get("base_attack", occupant.get("attack", 1)))
	var base_health: int = int(occupant.get("base_health", occupant.get("max_health", 1)))
	var card = _card(str(occupant.get("card_id", "")))
	var effect: Dictionary = Dictionary(card.effect if card != null else {})
	revived["attack"] = maxi(1, int(effect.get("ressurgir_attack", int(floor(float(base_attack) / 2.0)))))
	revived["health"] = maxi(1, int(effect.get("ressurgir_health", int(floor(float(base_health) / 2.0)))))
	revived["max_health"] = int(revived.get("health", 1))
	revived["base_attack"] = int(revived.get("attack", 1))
	revived["base_health"] = int(revived.get("health", 1))
	revived["keywords"] = []
	for keyword: String in ["iniciativa", "regeneracao", "defensor", "reviver", "atropelar", "brutal", "drenar", "espinhos", "escudo", "resistencia", "imune", "crescer", "furia", "ecoar", "veneno", "congelar", "profanar", "proliferar", "inspirar", "pacto", "drenar_almas", "ressurgir"]:
		revived[keyword] = false
	for key: String in ["regeneration_amount", "carrion_amount", "shield_charges", "resistance_amount", "resistance_remaining", "thorns_amount", "grow_amount", "drain_amount", "poison_apply_amount", "inspire_amount", "pact_amount", "pact_bonus_attack", "pact_bonus_health"]:
		revived[key] = 0
	revived["revive_marker"] = false
	revived["ressurgir_marker"] = true
	revived["echo_used"] = false
	revived["fury_pending"] = false
	_recalculate_pact_bonuses(owner_id)
	return revived

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
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			occupant["moved_this_turn"] = false
			var grow_amount: int = int(occupant.get("grow_amount", 0))
			if bool(occupant.get("crescer", false)) and grow_amount > 0:
				occupant["attack"] = int(occupant.get("attack", 0)) + grow_amount
				_log("%s cresceu +%d ATK." % [str(occupant.get("name", "Criatura")), grow_amount])
			slots[index] = occupant
		_set_slots_for_owner(owner_id, slots)
	_resolve_start_of_player_field_effects()

func _reset_resistance_for_cycle() -> void:
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		var changed: bool = false
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			occupant["resistance_remaining"] = int(occupant.get("resistance_amount", 0))
			slots[index] = occupant
			changed = true
		if changed:
			_set_slots_for_owner(owner_id, slots)

func _resolve_end_of_combat_keyword_triggers() -> void:
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			if bool(occupant.get("furia", false)) and bool(occupant.get("fury_pending", false)) and int(occupant.get("health", 0)) > 0:
				occupant["attack"] = int(occupant.get("attack", 0)) + 1
				_log("%s ganhou +1 ATK com Furia." % str(occupant.get("name", "Criatura")))
			occupant["fury_pending"] = false
			slots[index] = occupant
		_set_slots_for_owner(owner_id, slots)
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			if bool(occupant.get("proliferar", false)) and int(occupant.get("health", 0)) > 0:
				_summon_token(owner_id, 1, 1, "Prole")

func _resolve_poison_ticks() -> void:
	var damaged_slots: Array[Dictionary] = []
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var poison: int = int(Dictionary(slots[index]).get("poison_amount", 0))
			if poison <= 0:
				continue
			_deal_slot_damage(owner_id, index, poison, {"source_kind": "poison", "defer_death": true, "bypass_resistance": true})
			_queue_damaged_slot(damaged_slots, owner_id, index, -1)
			_log("%s sofreu %d de Veneno." % [str(Dictionary(slots[index]).get("name", "Criatura")), poison])
	_destroy_queued_damaged_slots(damaged_slots)

func _resolve_enemy_start_field_effects() -> void:
	if _field_effect_active(FIELD_CHAO_VIVO):
		var enemy_target: Dictionary = _random_occupied_target(ENEMY_ID)
		if not enemy_target.is_empty():
			_buff_slot(ENEMY_ID, int(enemy_target.get("slot", -1)), 0, 1, false)
			_log("Chao Vivo fortaleceu uma criatura inimiga.")
	if _field_effect_active(FIELD_VENTANIA) or _field_effect_active(FIELD_OLHO_TEMPESTADE):
		_swap_random_adjacent_enemy()
	if _field_effect_active(FIELD_INFERNO) or _field_effect_active(FIELD_INFERNO_TOTAL):
		_apply_poison_to_random(PLAYER_ID, 1)
		_log("Inferno aplicou Veneno 1 em uma criatura aliada.")
	if _field_effect_active(FIELD_PISO_LAVA):
		_damage_rear_player_slots(1, "Piso de Lava")
	if _field_effect_active(FIELD_SLOT_CENTRAL_AMPLIFICADO) and enemy_slots.size() > 2 and enemy_slots[2] != null:
		_damage_hero(PLAYER_ID, 1)
		_log("Slot Central Amplificado causou 1 dano ao comandante.")

func _resolve_end_of_combat_field_effects() -> void:
	var threshold: int = 0
	if _field_effect_active(FIELD_BRASA_VIVA):
		threshold = 1
	if _field_effect_active(FIELD_INFERNO_TOTAL):
		threshold = maxi(threshold, 2)
	if threshold <= 0:
		return
	var damaged_slots: Array[Dictionary] = []
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			if int(occupant.get("health", 0)) > threshold:
				continue
			_deal_slot_damage(owner_id, index, 1, {"source_kind": "field_effect", "defer_death": true, "bypass_resistance": true})
			_queue_damaged_slot(damaged_slots, owner_id, index, -1)
	if not damaged_slots.is_empty():
		_log("Brasa Viva queimou criaturas feridas.")
	_destroy_queued_damaged_slots(damaged_slots)

func _resolve_maintenance_field_effects() -> void:
	if _field_effect_active(FIELD_PORTAL_ABERTO) or mode == MODE_INVASION:
		_resolve_invasion_portal()

func _resolve_start_of_player_field_effects() -> void:
	if _field_effect_active(FIELD_GEADA):
		if _freeze_random_enemies(false, 1, 1, PLAYER_ID) > 0:
			_log("Geada congelou uma criatura aliada.")
	if _field_effect_active(FIELD_TABULEIRO_INSTAVEL) and turn_number % 2 == 0:
		var target: Dictionary = _random_occupied_target("any")
		if not target.is_empty():
			_apply_freeze_to_slot(str(target.get("owner", PLAYER_ID)), int(target.get("slot", -1)), 1)
			_log("Tabuleiro Instavel congelou um slot por um turno.")
	if _field_effect_active(FIELD_RELAMPAGO) or _field_effect_active(FIELD_OLHO_TEMPESTADE):
		var lightning_target: Dictionary = _random_occupied_target("any")
		if not lightning_target.is_empty():
			_damage_slot(str(lightning_target.get("owner", ENEMY_ID)), int(lightning_target.get("slot", -1)), 2, "field_effect")
			_log("Relampago atingiu uma criatura em campo.")

func _apply_summon_field_effect(owner_id: String, slot_index: int) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if _field_effect_active(FIELD_TURBULENCIA) and int(occupant.get("health", 0)) > 1:
		occupant["health"] = maxi(1, int(occupant.get("health", 0)) - 1)
		occupant["max_health"] = maxi(1, int(occupant.get("max_health", 1)) - 1)
		_log("Turbulencia reduziu a vida da criatura invocada.")
	if _field_effect_active(FIELD_TERRENO_ROCHOSO) and owner_id == PLAYER_ID and (slot_index == 0 or slot_index == slots.size() - 1) and int(occupant.get("health", 0)) <= 2:
		occupant["attack"] = maxi(0, int(occupant.get("attack", 0)) - 1)
		_log("Terreno Rochoso reduziu o ATK na borda.")
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _resolve_boss_phase_hooks() -> void:
	if mode != MODE_SUMMONER_BOSS or boss_phase_hooks.is_empty():
		return
	for index: int in range(boss_phase_hooks.size()):
		var hook: Dictionary = boss_phase_hooks[index]
		var hook_id: String = str(hook.get("id", "hook_%d" % index))
		if bool(boss_phase_hook_state.get(hook_id, false)):
			continue
		if not _boss_phase_hook_triggered(hook):
			continue
		_apply_boss_phase_hook(hook)
		boss_phase_hook_state[hook_id] = true

func _boss_phase_hook_triggered(hook: Dictionary) -> bool:
	match str(hook.get("trigger", "")):
		"turn":
			return turn_number >= int(hook.get("turn", 1))
		"hp_below":
			return enemy_health <= int(hook.get("hp_below", enemy_max_health))
		"board_empty":
			return _board_is_clear(ENEMY_ID)
	return false

func _apply_boss_phase_hook(hook: Dictionary) -> void:
	match str(hook.get("action", "")):
		"summon_card":
			_spawn_enemy_card(str(hook.get("card_id", "")), int(hook.get("attack_bonus", 0)), int(hook.get("health_bonus", 0)))
		"buff_all_enemies":
			_buff_all_slots(ENEMY_ID, int(hook.get("attack", 0)), int(hook.get("health", 0)), false)
		"add_keyword_all_enemies":
			for index: int in range(enemy_slots.size()):
				_add_keyword_to_slot(ENEMY_ID, index, str(hook.get("keyword", "")))
		"damage_player":
			_damage_hero(PLAYER_ID, int(hook.get("amount", 0)))
		"poison_all_player":
			for index: int in range(player_slots.size()):
				_apply_poison_to_slot(PLAYER_ID, index, int(hook.get("amount", 1)))
		"set_field_effect":
			var effect_id: String = str(hook.get("effect", ""))
			if effect_id != "" and not field_effects.has(effect_id):
				field_effects.append(effect_id)
	var description: String = str(hook.get("description", "Fase de chefe resolvida."))
	if description != "":
		_log(description)

func _apply_drain(owner_id: String, amount: int) -> void:
	if amount <= 0:
		return
	if owner_id == PLAYER_ID:
		player_health = mini(player_max_health, player_health + amount)
	else:
		enemy_health = mini(enemy_max_health, enemy_health + amount)
	_log("%s recuperou %d HP com Drenar." % [_hero_log_name(owner_id), amount])

func _apply_poison_to_slot(owner_id: String, slot_index: int, amount: int) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if bool(occupant.get("imune", false)):
		return
	occupant["poison_amount"] = _stacked_poison_amount(int(occupant.get("poison_amount", 0)), amount)
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _apply_poison_to_random(owner_id: String, amount: int) -> void:
	var targets: Array[Dictionary] = _targetable_occupied_slot_targets(owner_id, false)
	if targets.is_empty():
		return
	var target: Dictionary = targets[_rng.randi_range(0, targets.size() - 1)]
	_apply_poison_to_slot(str(target.get("owner", owner_id)), int(target.get("slot", -1)), amount)

func _stacked_poison_amount(current: int, incoming: int) -> int:
	if current <= 0:
		return maxi(1, incoming)
	return maxi(current, incoming) + 1

func _apply_freeze_to_slot(owner_id: String, slot_index: int, amount: int) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if bool(occupant.get("imune", false)):
		return
	occupant["frozen_turns"] = max(int(occupant.get("frozen_turns", 0)), amount)
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _freeze_random_enemies(freeze_all: bool, count: int, amount: int, target_owner_id: String = ENEMY_ID) -> int:
	var targets: Array[Dictionary] = _targetable_occupied_slot_targets(target_owner_id, true)
	if targets.is_empty():
		return 0
	var limit: int = targets.size() if freeze_all else mini(maxi(1, count), targets.size())
	for index: int in range(limit):
		var target_index: int = _rng.randi_range(0, targets.size() - 1)
		var target: Dictionary = targets[target_index]
		targets.remove_at(target_index)
		_apply_freeze_to_slot(str(target.get("owner", ENEMY_ID)), int(target.get("slot", -1)), amount)
	return limit

func _mark_echo_used(owner_id: String, slot_index: int) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	occupant["echo_used"] = true
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _inspire_bonus_for(owner_id: String, slot_index: int) -> int:
	var slots: Array = _slots_for_owner(owner_id)
	var bonus: int = 0
	for adjacent: int in [slot_index - 1, slot_index + 1]:
		if adjacent < 0 or adjacent >= slots.size() or slots[adjacent] == null:
			continue
		var occupant: Dictionary = Dictionary(slots[adjacent])
		if bool(occupant.get("inspirar", false)):
			bonus += int(occupant.get("inspire_amount", 0))
	return bonus

func _board_attack_bonus(owner_id: String, slot_index: int) -> int:
	if board_format == BOARD_FORMAT_CENTRAL_CORE and slot_index == 2:
		return 1
	if _field_effect_active(FIELD_SLOT_CENTRAL_AMPLIFICADO) and slot_index == 2:
		return 1
	return 0

func _trample_overflow_target(owner_id: String, lane_index: int, blocked_owner: String, blocked_slot: int) -> Dictionary:
	var opponent_id: String = _opponent_id(owner_id)
	if owner_id == ENEMY_ID:
		return {"owner": PLAYER_ID, "hero": true}
	if _enemy_hero_is_objective():
		return {"owner": ENEMY_ID, "hero": true}
	return _nearest_occupied_slot_target_except(opponent_id, lane_index, blocked_owner, blocked_slot)

func _nearest_occupied_slot_target_except(owner_id: String, lane_index: int, excluded_owner: String, excluded_slot: int) -> Dictionary:
	var slots: Array = _slots_for_owner(owner_id)
	var best_index: int = -1
	var best_distance: int = 99999
	for index: int in range(slots.size()):
		if slots[index] == null or (owner_id == excluded_owner and index == excluded_slot):
			continue
		var distance: int = absi(index - lane_index)
		if distance < best_distance or (distance == best_distance and (best_index < 0 or index < best_index)):
			best_distance = distance
			best_index = index
	if best_index < 0:
		return {}
	return {"owner": owner_id, "slot": best_index}

func _summon_token(owner_id: String, attack: int, health: int, display_name: String) -> bool:
	var slots: Array = _slots_for_owner(owner_id)
	var open_slot: int = _first_strict_open_slot(slots)
	if open_slot < 0:
		return false
	slots[open_slot] = _build_token_occupant(owner_id, attack, health, display_name)
	_set_slots_for_owner(owner_id, slots)
	_apply_summon_field_effect(owner_id, open_slot)
	_recalculate_pact_bonuses(owner_id)
	_log("%s surgiu no slot %d." % [display_name, open_slot + 1])
	return true

func _build_token_occupant(owner_id: String, attack: int, health: int, display_name: String) -> Dictionary:
	return {
		"owner": owner_id,
		"card_id": "",
		"name": display_name,
		"attack": attack,
		"health": health,
		"max_health": health,
		"base_attack": attack,
		"base_health": health,
		"ready": false,
		"keywords": [],
		"iniciativa": false,
		"regeneracao": false,
		"defensor": false,
		"reviver": false,
		"revive_marker": false,
		"ressurgir_marker": false,
		"objective": false,
		"moved_this_turn": false,
		"slow_turns": 0,
		"frozen_turns": 0,
		"curse_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 0,
		"temporary_health_bonus": 0,
		"regeneration_amount": 0,
		"carrion_amount": 0,
		"shield_charges": 0,
		"resistance_amount": 0,
		"resistance_remaining": 0,
		"poison_amount": 0,
		"pact_bonus_attack": 0,
		"pact_bonus_health": 0
	}

func _lowest_health_slot(owner_id: String) -> int:
	var slots: Array = _slots_for_owner(owner_id)
	var best_index: int = -1
	var best_health: int = 99999
	for index: int in range(slots.size()):
		if slots[index] == null:
			continue
		var health: int = int(Dictionary(slots[index]).get("health", 0))
		if health < best_health:
			best_health = health
			best_index = index
	return best_index

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

func _first_damage_spell_bonus() -> int:
	if first_damage_spell_relic_used or not _has_relic(RELIC_ECO_MENOR):
		return 0
	first_damage_spell_relic_used = true
	return 1

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
			_damage_slot(str(target.get("owner", ENEMY_ID)), int(target.get("slot", -1)), 1, "spell")
		else:
			_damage_hero(str(target.get("owner", ENEMY_ID)), 1)

func _area_damage_targets(owner_id: String) -> Array[Dictionary]:
	var targets: Array[Dictionary] = _targetable_occupied_slot_targets(owner_id, true)
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
		"escudo":
			occupant["escudo"] = true
			occupant["shield_charges"] = maxi(1, int(occupant.get("shield_charges", 0)))
		"resistencia":
			occupant["resistencia"] = true
			occupant["resistance_amount"] = maxi(1, int(occupant.get("resistance_amount", 0)))
			occupant["resistance_remaining"] = int(occupant.get("resistance_amount", 1))
		"pacto":
			occupant["pacto"] = true
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)
	if keyword == "pacto":
		_recalculate_pact_bonuses(owner_id)

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

func _recalculate_pact_bonuses(owner_id: String) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	var pact_count: int = 0
	for index: int in range(slots.size()):
		if slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(slots[index])
		var old_attack: int = int(occupant.get("pact_bonus_attack", 0))
		var old_health: int = int(occupant.get("pact_bonus_health", 0))
		if old_attack != 0 or old_health != 0:
			occupant["attack"] = max(0, int(occupant.get("attack", 0)) - old_attack)
			occupant["max_health"] = max(1, int(occupant.get("max_health", 1)) - old_health)
			occupant["health"] = mini(int(occupant.get("health", 0)), int(occupant.get("max_health", 1)))
			occupant["pact_bonus_attack"] = 0
			occupant["pact_bonus_health"] = 0
			slots[index] = occupant
		if bool(occupant.get("pacto", false)) and int(occupant.get("health", 0)) > 0:
			pact_count += 1
	if pact_count >= 2:
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			if not bool(occupant.get("pacto", false)) or int(occupant.get("health", 0)) <= 0:
				continue
			var amount: int = maxi(1, int(occupant.get("pact_amount", 2)))
			occupant["attack"] = int(occupant.get("attack", 0)) + amount
			occupant["health"] = int(occupant.get("health", 0)) + amount
			occupant["max_health"] = int(occupant.get("max_health", 0)) + amount
			occupant["pact_bonus_attack"] = amount
			occupant["pact_bonus_health"] = amount
			slots[index] = occupant
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
	if board_format == BOARD_FORMAT_FRONT_REAR and slot_index >= 3:
		var own_slots: Array = _slots_for_owner(owner_id)
		var front_index: int = slot_index - 3
		if front_index >= 0 and front_index < own_slots.size() and own_slots[front_index] != null:
			return {}
	var opponent_id: String = _opponent_id(owner_id)
	var opposing_slots: Array = _slots_for_owner(opponent_id)
	if slot_index >= 0 and slot_index < opposing_slots.size() and opposing_slots[slot_index] != null:
		return {"owner": opponent_id, "slot": slot_index}
	return {}

func _overflow_attack_target(owner_id: String, slot_index: int) -> Dictionary:
	var opponent_id: String = _opponent_id(owner_id)
	if owner_id == ENEMY_ID and mode == MODE_ESCORT:
		var escort_target: Dictionary = _escort_objective_target()
		if not escort_target.is_empty():
			return escort_target
	if owner_id == ENEMY_ID and board_format == BOARD_FORMAT_FLANK and (slot_index == 0 or slot_index == enemy_slots.size() - 1):
		return {"owner": PLAYER_ID, "hero": true}
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

func _targetable_occupied_slot_targets(owner_id: String, respect_immune: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if slots[index] == null:
			continue
		if respect_immune and bool(Dictionary(slots[index]).get("imune", false)):
			continue
		result.append({"owner": owner_id, "slot": index})
	return result

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
		_damage_slot(str(target.get("owner", ENEMY_ID)), int(target.get("slot", -1)), amount, "effect")
	else:
		_damage_hero(str(target.get("owner", ENEMY_ID)), amount)

func _damage_random_enemy(amount: int) -> void:
	if amount <= 0:
		return
	var targets: Array[Dictionary] = _area_damage_targets(ENEMY_ID)
	if targets.is_empty():
		return
	var target: Dictionary = targets[_rng.randi_range(0, targets.size() - 1)]
	if target.has("slot"):
		_damage_slot(str(target.get("owner", ENEMY_ID)), int(target.get("slot", -1)), amount, "effect")
	else:
		_damage_hero(str(target.get("owner", ENEMY_ID)), amount)

func _damage_random_target(owner_id: String, amount: int, source_kind: String = "effect") -> void:
	if amount <= 0:
		return
	var targets: Array[Dictionary] = _area_damage_targets(owner_id)
	if targets.is_empty():
		return
	var target: Dictionary = targets[_rng.randi_range(0, targets.size() - 1)]
	if target.has("slot"):
		_damage_slot(str(target.get("owner", owner_id)), int(target.get("slot", -1)), amount, source_kind)
	else:
		_damage_hero(str(target.get("owner", owner_id)), amount)

func _random_occupied_target(owner_id: String) -> Dictionary:
	var targets: Array[Dictionary] = []
	if owner_id == "any":
		targets.append_array(_targetable_occupied_slot_targets(PLAYER_ID, false))
		targets.append_array(_targetable_occupied_slot_targets(ENEMY_ID, false))
	else:
		targets.append_array(_targetable_occupied_slot_targets(owner_id, false))
	if targets.is_empty():
		return {}
	return targets[_rng.randi_range(0, targets.size() - 1)]

func _swap_random_adjacent_enemy() -> void:
	if enemy_slots.size() < 2:
		return
	var candidates: Array[int] = []
	for index: int in range(enemy_slots.size() - 1):
		if enemy_slots[index] != null or enemy_slots[index + 1] != null:
			candidates.append(index)
	if candidates.is_empty():
		return
	var left_index: int = candidates[_rng.randi_range(0, candidates.size() - 1)]
	var right_index: int = left_index + 1
	var left_value: Variant = enemy_slots[left_index]
	enemy_slots[left_index] = enemy_slots[right_index]
	enemy_slots[right_index] = left_value
	_log("Ventania trocou as lanes inimigas %d e %d." % [left_index + 1, right_index + 1])

func _damage_rear_player_slots(amount: int, label: String) -> void:
	var damaged_slots: Array[Dictionary] = []
	for index: int in range(3, player_slots.size()):
		if player_slots[index] == null:
			continue
		_deal_slot_damage(PLAYER_ID, index, amount, {"source_kind": "field_effect", "defer_death": true, "bypass_resistance": true})
		_queue_damaged_slot(damaged_slots, PLAYER_ID, index, -1)
	if not damaged_slots.is_empty():
		_log("%s feriu a retaguarda aliada." % label)
	_destroy_queued_damaged_slots(damaged_slots)

func _resolve_invasion_portal() -> void:
	if not [3, 5].has(turn_number):
		return
	var key: String = "portal_turn_%d" % turn_number
	if bool(field_effect_state.get(key, false)):
		return
	field_effect_state[key] = true
	var left_count: int = _occupied_count_in_range(enemy_slots, 0, mini(2, enemy_slots.size() - 1))
	var right_count: int = _occupied_count_in_range(enemy_slots, 3, enemy_slots.size() - 1)
	var preferred_slots: Array = [0, 1, 2] if left_count <= right_count else [3, 4, 5]
	var spawned: int = 0
	for slot_index: int in preferred_slots:
		if slot_index < 0 or slot_index >= enemy_slots.size() or enemy_slots[slot_index] != null:
			continue
		if _spawn_enemy_card_in_slot("enemy_fogo_fragmento_de_chama", slot_index, 0, 0):
			spawned += 1
		if spawned >= 2:
			break
	if spawned < 2:
		for _i: int in range(2 - spawned):
			if _spawn_enemy_card("enemy_fogo_fragmento_de_chama", 0, 0):
				spawned += 1
	if spawned > 0:
		_log("Portal Aberto invocou %d reforco(s)." % spawned)

func _occupied_count_in_range(slots: Array, first_index: int, last_index: int) -> int:
	var total: int = 0
	for index: int in range(maxi(0, first_index), mini(last_index, slots.size() - 1) + 1):
		if slots[index] != null:
			total += 1
	return total

func _spawn_enemy_card(card_id: String, attack_bonus: int = 0, health_bonus: int = 0) -> bool:
	var open_slot: int = _first_strict_open_slot(enemy_slots)
	if open_slot < 0:
		return false
	return _spawn_enemy_card_in_slot(card_id, open_slot, attack_bonus, health_bonus)

func _spawn_enemy_card_in_slot(card_id: String, slot_index: int, attack_bonus: int = 0, health_bonus: int = 0) -> bool:
	var card = _card(card_id)
	if card == null or slot_index < 0 or slot_index >= enemy_slots.size() or enemy_slots[slot_index] != null:
		return false
	var occupant: Dictionary = _build_occupant(card, ENEMY_ID, true)
	if attack_bonus != 0:
		occupant["attack"] = int(occupant.get("attack", 0)) + attack_bonus
	if health_bonus != 0:
		occupant["health"] = int(occupant.get("health", 0)) + health_bonus
		occupant["max_health"] = int(occupant.get("max_health", 0)) + health_bonus
	enemy_slots[slot_index] = occupant
	_apply_summon_field_effect(ENEMY_ID, slot_index)
	_recalculate_pact_bonuses(ENEMY_ID)
	return true

func _buff_all_slots(owner_id: String, attack_bonus: int, health_bonus: int, temporary: bool) -> void:
	for index: int in range(_slots_for_owner(owner_id).size()):
		if _slot_occupant(owner_id, index).is_empty():
			continue
		_buff_slot(owner_id, index, attack_bonus, health_bonus, temporary)

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
	return action in ["", "all_enemy_damage", "freeze_random_enemy", "gain_ashes", "poison_all_enemies"]

func _card_play_cost(card) -> int:
	if card == null:
		return 0
	var cost: int = int(card.cost)
	if _is_spell_card(card) and _has_relic(RELIC_CATALISADOR_ARCANO) and not first_spell_discount_used:
		return maxi(0, cost - 1)
	return cost

func _minimum_card_play_cost(card) -> int:
	if card == null:
		return 0
	return maxi(0, _card_play_cost(card) - _sacrifice_discount_for_card(card))

func _card_play_cost_for_target(card, target: Dictionary) -> int:
	if card == null:
		return 0
	var cost: int = _card_play_cost(card)
	if card.occupies_slot() and bool(target.get("confirm_sacrifice", false)):
		var slot_index: int = int(target.get("slot", -1))
		if slot_index >= 0 and slot_index < player_slots.size() and player_slots[slot_index] != null:
			cost = maxi(0, cost - _sacrifice_discount_for_card(card))
	return cost

func _sacrifice_discount_for_card(card) -> int:
	if card == null:
		return 0
	var effect: Dictionary = Dictionary(card.effect)
	var discount: int = int(effect.get("sacrifice_discount", effect.get("sacrifice", 0)))
	if discount <= 0 and card.has_keyword("sacrificio"):
		discount = 1
	return discount

func _is_spell_card(card) -> bool:
	return card != null and not card.occupies_slot()

func _has_relic(relic_id: String) -> bool:
	return relic_ids.has(relic_id)

func _field_effect_active(effect_id: String) -> bool:
	if field_effects.has(effect_id):
		return true
	if effect_id == FIELD_VENTANIA and field_effects.has(FIELD_OLHO_TEMPESTADE) and turn_number >= 4:
		return true
	if effect_id == FIELD_RELAMPAGO and field_effects.has(FIELD_OLHO_TEMPESTADE) and turn_number >= 4:
		return true
	if effect_id == FIELD_BRASA_VIVA and field_effects.has(FIELD_INFERNO_TOTAL):
		return true
	if effect_id == FIELD_INFERNO and field_effects.has(FIELD_INFERNO_TOTAL):
		return true
	if effect_id == FIELD_CINZAS_VIVAS and field_effects.has(FIELD_INFERNO_TOTAL):
		return true
	return false

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
