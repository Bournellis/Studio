class_name BattleEngine
extends RefCounted

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"
const NEUTRAL_ID: String = "neutro"

const MODE_CLEAR_BOARD: String = "limpar_mesa"
const MODE_DUEL: String = "duelo"
const MODE_WAVES: String = "ondas"
const MODE_DEFENSE: String = "defesa"
const MODE_BOSS_PARTS: String = "chefe_multiparte"
const MODE_PUZZLE: String = "quebra_cabeca"

const DAMAGE_FISICO_MELEE: String = "fisico_melee"
const DAMAGE_FISICO_ALCANCE: String = "fisico_alcance"
const DAMAGE_MAGICO: String = "magico"

const PHASE_UPKEEP: String = "manutencao"
const PHASE_DRAW: String = "compra"
const PHASE_MAIN: String = "fase_principal"
const PHASE_DISCARD: String = "descarte"
const PHASE_ENDED: String = "encerrada"

const STARTING_HAND_SIZE: int = 5
const STARTING_MAX_HAND_SIZE: int = 5
const MAX_HAND_SIZE_CAP: int = 7
const DISCARD_PHASE_TARGET: int = 7
const TEMPORARY_HAND_CEILING: int = 8
const IMMEDIATE_DISCARD_TRIGGER: int = 9
const STARTING_ENERGY_MAX: int = 3
const MAX_ENERGY_CAP: int = 8
const COMMAND_DECK_LIMIT: int = 4
const DEFAULT_PLAYER_HEALTH: int = 25
const DEFAULT_ENEMY_HEALTH: int = 20
const MAX_LOG_LINES: int = 18
const MAX_AUTO_STEPS: int = 24

# Compatibility aliases kept while UI/tests migrate to Portuguese terms.
const VARIANT_C1: String = "c1"
const PHASE_MAIN_COMPAT: String = PHASE_MAIN

var turno: int = 1
var round_number: int = 1
var player_health: int = DEFAULT_PLAYER_HEALTH
var player_armor: int = 0
var enemy_health: int = DEFAULT_ENEMY_HEALTH
var enemy_armor: int = 0
var energy: int = STARTING_ENERGY_MAX
var deck: Array = []
var hand: Array = []
# Deprecated compatibility mirror. Active rules use bottom-of-deck cycling.
var discard: Array = []
var player_slots: Array = []
var enemy_slots: Array = []
var neutral_slots: Array = []
var log_lines: Array[String] = []
var eventos_visuais: Array[Dictionary] = []
var outcome: String = ""
var hero_power_used: bool = false
var current_phase: String = PHASE_MAIN
var battle_variant_id: String = VARIANT_C1
var modo_batalha: String = MODE_CLEAR_BOARD
var encounter_id: String = ""
var encounter_name: String = ""
var wave_index: int = 0
var wave_count: int = 0
var defense_turn_limit: int = 0
var defense_turns_survived: int = 0
var boss_part_slots: Array[int] = []
var puzzle_target_slots: Array[int] = []
var puzzle_turn_limit: int = 0
var puzzle_turns_used: int = 0
var active_player_id: String = PLAYER_ID
var priority_owner_id: String = PLAYER_ID
var consecutive_passes: int = 0
var controladores: Dictionary = {}
var tabuleiro: Dictionary = {}
var discard_controller_id: String = ""
var discard_target_size: int = DISCARD_PHASE_TARGET
var discard_voluntary_allowed: bool = true
var _discard_return_phase: String = ""
var _discard_return_priority_owner_id: String = ""

var active_class_id: String = ""
var fluxo: int = 0

var _catalog
var _player_slot_definitions: Array = []
var _enemy_slot_definitions: Array = []
var _neutral_slot_definitions: Array = []
var _player_slot_labels: Array[String] = []
var _enemy_slot_labels: Array[String] = []
var _neutral_slot_labels: Array[String] = []
var _attack_routes: Dictionary = {}
var _waves: Array = []
var _enemy_ai_enabled: bool = true
var _auto_depth: int = 0

func start_battle(catalog, deck_ids: Array, config: Dictionary = {}) -> void:
	_catalog = catalog
	log_lines = []
	eventos_visuais = []
	outcome = ""
	battle_variant_id = VARIANT_C1
	turno = 1
	round_number = 1
	wave_index = 0
	wave_count = 0
	defense_turn_limit = 0
	defense_turns_survived = 0
	boss_part_slots = []
	puzzle_target_slots = []
	puzzle_turn_limit = 0
	puzzle_turns_used = 0
	_waves = []
	active_player_id = PLAYER_ID
	priority_owner_id = PLAYER_ID
	consecutive_passes = 0
	current_phase = PHASE_UPKEEP
	_enemy_ai_enabled = bool(config.get("enemy_ai_enabled", config.get("enemy_script_enabled", true)))
	active_class_id = str(config.get("class_id", ""))
	fluxo = 0

	var encounter: Dictionary = _encounter_from_config(config)
	encounter_id = str(encounter.get("id", "emboscada_na_ponte"))
	encounter_name = str(encounter.get("display_name", "Emboscada na Ponte"))
	modo_batalha = str(encounter.get("mode", MODE_CLEAR_BOARD))
	_configure_controllers(deck_ids, encounter)
	_configure_board(encounter)

	_log("Encontro iniciado: %s." % encounter_name)
	_start_turn(PLAYER_ID)

func get_state() -> Dictionary:
	return {
		"turno": turno,
		"round": round_number,
		"player_health": player_health,
		"player_armor": player_armor,
		"enemy_health": enemy_health,
		"enemy_armor": enemy_armor,
		"energy": energy,
		"deck": deck.duplicate(),
		"hand": hand.duplicate(),
		"player_slots": player_slots.duplicate(true),
		"enemy_slots": enemy_slots.duplicate(true),
		"neutral_slots": neutral_slots.duplicate(true),
		"log": log_lines.duplicate(),
		"eventos_visuais": eventos_visuais.duplicate(true),
		"outcome": outcome,
		"hero_power_used": hero_power_used,
		"current_phase": current_phase,
		"battle_variant_id": battle_variant_id,
		"modo_batalha": modo_batalha,
		"encounter_id": encounter_id,
		"wave_index": wave_index,
		"wave_count": wave_count,
		"wave_label": get_wave_label(),
		"defense_turn_limit": defense_turn_limit,
		"defense_turns_survived": defense_turns_survived,
		"defense_label": get_defense_label(),
		"boss_part_slots": boss_part_slots.duplicate(),
		"boss_parts_destroyed": _boss_parts_destroyed_count(),
		"boss_part_count": boss_part_slots.size(),
		"boss_label": get_boss_label(),
		"puzzle_target_slots": puzzle_target_slots.duplicate(),
		"puzzle_targets_cleared": _puzzle_targets_cleared_count(),
		"puzzle_target_count": puzzle_target_slots.size(),
		"puzzle_turn_limit": puzzle_turn_limit,
		"puzzle_turns_used": puzzle_turns_used,
		"puzzle_label": get_puzzle_label(),
		"active_player_id": active_player_id,
		"priority_owner_id": priority_owner_id,
		"consecutive_passes": consecutive_passes,
		"discard_controller_id": discard_controller_id,
		"discard_target_size": discard_target_size,
		"controladores": controladores.duplicate(true)
	}

func is_c1_variant() -> bool:
	return true

func get_variant_label() -> String:
	return "C1"

func get_mode_label() -> String:
	match modo_batalha:
		MODE_CLEAR_BOARD:
			return "Limpar mesa"
		MODE_DUEL:
			return "Duelo"
		MODE_WAVES:
			return "Ondas"
		MODE_DEFENSE:
			return "Defesa"
		MODE_BOSS_PARTS:
			return "Chefe multiparte"
		MODE_PUZZLE:
			return "Quebra-cabeca"
		_:
			return modo_batalha

func get_wave_label() -> String:
	if modo_batalha != MODE_WAVES or wave_count <= 0:
		return ""
	return "Onda %d/%d" % [wave_index + 1, wave_count]

func get_defense_label() -> String:
	if modo_batalha != MODE_DEFENSE or defense_turn_limit <= 0:
		return ""
	return "Defesa %d/%d" % [defense_turns_survived, defense_turn_limit]

func get_mode_progress_label() -> String:
	var wave_text: String = get_wave_label()
	if wave_text != "":
		return wave_text
	var defense_text: String = get_defense_label()
	if defense_text != "":
		return defense_text
	var boss_text: String = get_boss_label()
	if boss_text != "":
		return boss_text
	return get_puzzle_label()

func get_boss_label() -> String:
	if modo_batalha != MODE_BOSS_PARTS or boss_part_slots.is_empty():
		return ""
	return "Partes %d/%d" % [_boss_parts_destroyed_count(), boss_part_slots.size()]

func get_puzzle_label() -> String:
	if modo_batalha != MODE_PUZZLE or puzzle_target_slots.is_empty():
		return ""
	return "Alvos %d/%d | Turnos %d/%d" % [
		_puzzle_targets_cleared_count(),
		puzzle_target_slots.size(),
		puzzle_turns_used,
		puzzle_turn_limit
	]

func get_priority_label() -> String:
	if outcome != "":
		return "Prioridade: n/a"
	if current_phase == PHASE_DISCARD:
		if discard_controller_id == PLAYER_ID:
			return "Descarte: voce"
		return "Descarte: inimigo"
	if current_phase != PHASE_MAIN:
		return "Prioridade: n/a"
	if priority_owner_id == PLAYER_ID:
		return "Prioridade: voce"
	return "Prioridade: inimigo"

func get_active_controller_label() -> String:
	if active_player_id == PLAYER_ID:
		return "Turno: jogador"
	return "Turno: inimigo"

func can_play_main_actions() -> bool:
	return outcome == "" and current_phase == PHASE_MAIN and priority_owner_id == PLAYER_ID

func can_play_card(card) -> bool:
	if card == null or not can_play_main_actions():
		return false
	if int(card.cost) > _controller_energy(PLAYER_ID):
		return false
	return true

func can_use_player_hero_power() -> bool:
	if not can_play_main_actions() or active_player_id != PLAYER_ID:
		return false
	var controller: Dictionary = _controller(PLAYER_ID)
	return not bool(controller.get("hero_power_used", false)) and int(controller.get("energy", 0)) >= 1

func can_discard_from_hand(hand_index: int) -> bool:
	if outcome != "" or current_phase != PHASE_DISCARD or discard_controller_id != PLAYER_ID:
		return false
	var controller_hand: Array = Array(_controller(PLAYER_ID).get("hand", []))
	return hand_index >= 0 and hand_index < controller_hand.size()

func can_finish_discard() -> bool:
	if outcome != "" or current_phase != PHASE_DISCARD or discard_controller_id != PLAYER_ID:
		return false
	return Array(_controller(PLAYER_ID).get("hand", [])).size() <= discard_target_size

func discard_card_from_hand(hand_index: int) -> Dictionary:
	if not can_discard_from_hand(hand_index):
		return _fail("Nenhuma carta valida para descarte.")
	var controller: Dictionary = _controller(PLAYER_ID)
	var controller_hand: Array = Array(controller.get("hand", []))
	var card_id: String = str(controller_hand[hand_index])
	controller_hand.remove_at(hand_index)
	controller["hand"] = controller_hand
	_set_controller(PLAYER_ID, controller)
	_move_card_to_bottom_of_deck(PLAYER_ID, card_id)
	_log("Descarte: %s vai para o fundo do deck." % _card_name(card_id))
	_sync_public_fields()
	if _discard_return_phase != "" and controller_hand.size() <= discard_target_size:
		_finish_immediate_discard()
	return {"ok": true, "message": "%s foi enviado ao fundo do deck." % _card_name(card_id)}

func finish_discard_phase() -> Dictionary:
	if current_phase != PHASE_DISCARD or discard_controller_id != PLAYER_ID:
		return _fail("Nao ha descarte do jogador para encerrar.")
	if not can_finish_discard():
		return _fail("Descarte cartas ate ficar com %d carta(s)." % discard_target_size)
	_finish_public_discard_phase()
	return {"ok": true, "message": "Descarte encerrado."}

func use_player_hero_power(target: Dictionary = {}) -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if not can_play_main_actions():
		return _fail("Hero power so pode ser usado quando voce tem prioridade.")
	if active_player_id != PLAYER_ID:
		return _fail("Hero power so pode ser usado no seu proprio turno.")
	var controller: Dictionary = _controller(PLAYER_ID)
	if bool(controller.get("hero_power_used", false)):
		return _fail("Hero power ja usado neste turno.")
	if int(controller.get("energy", 0)) < 1:
		return _fail("Energia insuficiente para o hero power.")

	var hp_effect: Dictionary = _get_active_hero_power_effect()
	var action: String = str(hp_effect.get("action", ""))
	if action == "gain_stats":
		return _use_hero_power_gain_stats(hp_effect, target, controller)
	return _use_hero_power_preparar_defesa(controller)

func _get_active_hero_power_effect() -> Dictionary:
	if active_class_id == "":
		return {}
	ContentLibrary.ensure_loaded()
	var class_def: Dictionary = ContentLibrary.get_class_definition(active_class_id)
	if class_def.is_empty():
		return {}
	var hero: Dictionary = Dictionary(class_def.get("hero", {}))
	var hp: Dictionary = Dictionary(hero.get("hero_power", {}))
	return Dictionary(hp.get("effect", {}))

func _use_hero_power_preparar_defesa(controller: Dictionary) -> Dictionary:
	controller["energy"] = int(controller.get("energy", 0)) - 1
	controller["hero_power_used"] = true
	var hero: Dictionary = Dictionary(controller.get("hero", {}))
	hero["armor"] = int(hero.get("armor", 0)) + 2
	controller["hero"] = hero
	_set_controller(PLAYER_ID, controller)
	_sync_public_fields()
	_log("Preparar Defesa: jogador ganha 2 de armadura.")
	_visual("armadura", PLAYER_ID, -1, "Armadura +2", Color(0.35, 0.75, 1.0))
	_after_action_resolved(PLAYER_ID, false)
	return {"ok": true, "message": "Preparar Defesa concedeu 2 de armadura."}

func _use_hero_power_gain_stats(effect: Dictionary, target: Dictionary, controller: Dictionary) -> Dictionary:
	var hp_target: String = str(effect.get("target", ""))
	if hp_target == "any_own_creature":
		var slot_index: int = int(target.get("slot", -1))
		var slots: Array = _slots_for_owner(PLAYER_ID)
		if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
			return _fail("Hero power requer um slot aliado valido como alvo.")
		var atk_bonus: int = int(effect.get("attack", 0))
		var hp_bonus: int = int(effect.get("health", 0))
		controller["energy"] = int(controller.get("energy", 0)) - 1
		controller["hero_power_used"] = true
		_set_controller(PLAYER_ID, controller)
		_apply_permanent_stat_buff(PLAYER_ID, slot_index, atk_bonus, hp_bonus)
		_sync_public_fields()
		_log("Amplificar: %s ganha +%d/+%d permanente." % [_slot_label(PLAYER_ID, slot_index), atk_bonus, hp_bonus])
		_visual("buff", PLAYER_ID, slot_index, "+%d ATK" % atk_bonus, Color(1.0, 0.85, 0.2))
		_after_action_resolved(PLAYER_ID, false)
		return {"ok": true, "message": "Amplificar aplicado."}
	return _fail("Hero power gain_stats: alvo nao suportado: %s." % hp_target)

func _player_fluxo_bonus(controller_id: String) -> int:
	if controller_id != PLAYER_ID or active_class_id != "arcano":
		return 0
	return fluxo

func _try_trigger_fluxo(controller_id: String) -> void:
	if controller_id != PLAYER_ID or active_class_id != "arcano":
		return
	fluxo += 1
	_log("Fluxo: %d." % fluxo)
	_visual("buff", PLAYER_ID, -1, "Fluxo +1", Color(0.55, 0.78, 1.0))

func play_card_from_hand(hand_index: int, target: Dictionary) -> Dictionary:
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if current_phase != PHASE_MAIN:
		return _fail("Cartas so podem ser jogadas na fase principal.")
	if priority_owner_id != PLAYER_ID:
		return _fail("A prioridade esta com o inimigo.")
	var controller: Dictionary = _controller(PLAYER_ID)
	var controller_hand: Array = Array(controller.get("hand", []))
	if hand_index < 0 or hand_index >= controller_hand.size():
		return _fail("Carta de mao invalida.")

	var card_id: String = str(controller_hand[hand_index])
	var card = _catalog.find_card(card_id)
	if card == null:
		return _fail("Carta inexistente: %s." % card_id)
	if int(card.cost) > int(controller.get("energy", 0)):
		return _fail("Energia insuficiente para %s." % card.display_name)

	if card.occupies_slot():
		return _play_permanent(PLAYER_ID, hand_index, card, target)
	if card.is_damage_spell():
		var r: Dictionary = _play_damage_spell(PLAYER_ID, hand_index, card, target)
		if bool(r.get("ok", false)):
			_try_trigger_fluxo(PLAYER_ID)
		return r
	if card.is_board_spell():
		var r: Dictionary = _play_board_spell(PLAYER_ID, hand_index, card)
		if bool(r.get("ok", false)):
			_try_trigger_fluxo(PLAYER_ID)
		return r
	if card.is_buff_command():
		return _play_buff_command(PLAYER_ID, hand_index, card, target)
	if card.is_stat_buff_spell():
		return _play_stat_buff_spell(PLAYER_ID, hand_index, card, target)
	return _fail("Tipo de carta ainda nao suportado: %s." % str(card.card_type))

func advance_phase() -> Dictionary:
	if outcome != "":
		return {"ok": false, "message": "A batalha ja terminou."}
	if current_phase == PHASE_DISCARD:
		return finish_discard_phase()
	if current_phase != PHASE_MAIN:
		return {"ok": false, "message": "A fase atual resolve automaticamente."}
	if priority_owner_id == PLAYER_ID:
		return pass_priority(PLAYER_ID)
	_auto_enemy_until_player_priority()
	return {"ok": true, "message": "Inimigo resolvido automaticamente."}

func end_player_turn() -> Dictionary:
	return advance_phase()

func pass_priority(owner_id: String = PLAYER_ID) -> Dictionary:
	owner_id = _normalize_owner_id(owner_id)
	if outcome != "":
		return {"ok": false, "message": "A batalha ja terminou."}
	if current_phase != PHASE_MAIN:
		return _fail("Prioridade so existe na fase principal.")
	if priority_owner_id != owner_id:
		return _fail("A prioridade esta com %s." % _owner_label(priority_owner_id))

	consecutive_passes += 1
	_log("%s passa prioridade." % _owner_label(owner_id))
	if consecutive_passes >= 2:
		_log("Dois passes encerram a fase principal.")
		_end_main_phase()
	else:
		priority_owner_id = _opponent_id(owner_id)
		_log("Prioridade: %s." % _owner_label(priority_owner_id))

	if owner_id == PLAYER_ID:
		_auto_enemy_until_player_priority()
	return {"ok": true, "message": "Prioridade passada." if outcome == "" else "Batalha encerrada."}

func resolve_enemy_priority() -> Dictionary:
	if outcome != "":
		return {"ok": false, "message": "A batalha ja terminou."}
	if current_phase != PHASE_MAIN:
		return _fail("A fase atual nao aceita prioridade.")
	if priority_owner_id != ENEMY_ID:
		return _fail("A prioridade nao esta com o inimigo.")
	return _perform_enemy_action()

func attack_with_unit(owner_id: String, slot_index: int, target: Dictionary) -> Dictionary:
	owner_id = _normalize_owner_id(owner_id)
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if current_phase != PHASE_MAIN:
		return _fail("Ataques so podem ser declarados na fase principal.")
	if priority_owner_id != owner_id:
		return _fail("A prioridade esta com %s." % _owner_label(priority_owner_id))
	if not _can_attack_from_slot(owner_id, slot_index):
		return _fail("Essa carta nao pode atacar agora.")

	var legal_options: Array = get_attack_options(owner_id, slot_index)
	if not _target_in_options(target, legal_options):
		return _fail("Alvo de ataque invalido.")

	var attacker_slots: Array = _slots_for_owner(owner_id)
	var attacker: Dictionary = Dictionary(attacker_slots[slot_index])
	var target_owner: String = _normalize_owner_id(str(target.get("owner", _opponent_id(owner_id))))
	var target_slot: int = int(target.get("slot", -1))
	var amount: int = int(attacker.get("attack", 0))

	attacker["exhausted"] = true
	attacker["ready"] = false
	attacker_slots[slot_index] = attacker
	_set_slots_for_owner(owner_id, attacker_slots)
	_log("%s declara ataque contra %s." % [_slot_label(owner_id, slot_index), _target_label(target)])
	_visual("ataque", owner_id, slot_index, "Ataque", Color(1.0, 0.82, 0.3))

	if target_slot >= 0:
		var target_slots: Array = _slots_for_owner(target_owner)
		if target_slot >= target_slots.size() or target_slots[target_slot] == null:
			return _fail("Alvo de ataque invalido.")
		var defender: Dictionary = Dictionary(target_slots[target_slot])
		var defender_damage: int = int(defender.get("attack", 0))
		var defender_health_before: int = int(defender.get("health", 0))
		var attack_damage_type: String = _attack_damage_type(attacker)
		_apply_unit_damage(target_owner, target_slot, amount, attack_damage_type, _has_keyword(attacker, "voadora"))
		_apply_unit_damage(owner_id, slot_index, defender_damage, _attack_damage_type(defender), _has_keyword(defender, "voadora"))
		_log("%s causa %d e recebe %d de volta." % [_slot_label(owner_id, slot_index), amount, defender_damage])
		var route: Dictionary = Dictionary(_attack_routes.get(_route_key(owner_id, slot_index), {}))
		if _has_keyword(attacker, "atropelar") and amount > defender_health_before:
			var overflow: int = amount - defender_health_before
			_apply_trample_overflow(owner_id, route, target_owner, target_slot, overflow, attack_damage_type, _has_keyword(attacker, "voadora"))
	else:
		_apply_hero_damage(target_owner, amount)
		_log("%s causa %d de dano direto." % [_slot_label(owner_id, slot_index), amount])

	_remove_destroyed()
	_check_outcome()
	_after_action_resolved(owner_id, false)
	return {"ok": true, "message": "Ataque resolvido."}

func move_unit(controller_id: String, from_owner_id: String, from_slot_index: int, to_owner_id: String, to_slot_index: int) -> Dictionary:
	controller_id = _normalize_owner_id(controller_id)
	from_owner_id = _normalize_owner_id(from_owner_id)
	to_owner_id = _normalize_owner_id(to_owner_id)
	if outcome != "":
		return _fail("A batalha ja terminou.")
	if current_phase != PHASE_MAIN:
		return _fail("Movimento so pode ser feito na fase principal.")
	if priority_owner_id != controller_id:
		return _fail("A prioridade esta com %s." % _owner_label(priority_owner_id))
	if to_owner_id != controller_id and to_owner_id != NEUTRAL_ID:
		return _fail("Criaturas so podem mover para area aliada ou neutra.")
	var from_slots: Array = _slots_for_owner(from_owner_id)
	var to_slots: Array = _slots_for_owner(to_owner_id)
	if from_slot_index < 0 or from_slot_index >= from_slots.size() or from_slots[from_slot_index] == null:
		return _fail("Origem de movimento invalida.")
	if to_slot_index < 0 or to_slot_index >= to_slots.size() or to_slots[to_slot_index] != null:
		return _fail("Destino de movimento invalido.")
	var occupant: Dictionary = Dictionary(from_slots[from_slot_index])
	if str(occupant.get("owner", "")) != controller_id:
		return _fail("Essa carta nao pertence a %s." % _owner_label(controller_id))
	if str(occupant.get("type", "")) != "criatura":
		return _fail("Apenas criaturas podem mover.")
	if bool(occupant.get("moved_this_turn", false)):
		return _fail("Essa criatura ja moveu neste turno.")
	occupant["moved_this_turn"] = true
	from_slots[from_slot_index] = null
	to_slots[to_slot_index] = occupant
	_set_slots_for_owner(from_owner_id, from_slots)
	_set_slots_for_owner(to_owner_id, to_slots)
	_log("%s move de %s para %s." % [str(occupant.get("name", "Criatura")), _slot_label(from_owner_id, from_slot_index), _slot_label(to_owner_id, to_slot_index)])
	_after_action_resolved(controller_id, false)
	return {"ok": true, "message": "Movimento resolvido."}

func get_attack_options(owner_id: String, slot_index: int) -> Array:
	owner_id = _normalize_owner_id(owner_id)
	if not _can_attack_from_slot(owner_id, slot_index):
		return []

	var options: Array = []
	var seen: Dictionary = {}
	var route: Dictionary = Dictionary(_attack_routes.get(_route_key(owner_id, slot_index), {}))
	var attacker: Dictionary = Dictionary(_slots_for_owner(owner_id)[slot_index])
	var can_choose_multiple: bool = _has_keyword(attacker, "alcance") or _has_keyword(attacker, "voadora")
	if can_choose_multiple:
		for route_target: Variant in _route_all_reachable_targets(route):
			if typeof(route_target) != TYPE_DICTIONARY:
				continue
			if _route_target_is_legal_for_attacker(owner_id, attacker, Dictionary(route_target)):
				var target_owner: String = _normalize_owner_id(str(Dictionary(route_target).get("owner", _opponent_id(owner_id))))
				var target_slot: int = int(Dictionary(route_target).get("slot", -1))
				_add_attack_option(options, seen, {"owner": target_owner, "slot": target_slot})
	else:
		var melee_target: Dictionary = _first_melee_route_target(owner_id, attacker, route)
		if not melee_target.is_empty():
			_add_attack_option(options, seen, melee_target)

	var fallback: String = str(route.get("fallback", "hero"))
	if options.is_empty() and fallback == "hero":
		_add_attack_option(options, seen, {"owner": _opponent_id(owner_id), "slot": -1})
	return options

func get_slot_attack_status(owner_id: String, slot_index: int) -> String:
	owner_id = _normalize_owner_id(owner_id)
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return "Livre"
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if int(occupant.get("attack", 0)) <= 0:
		return "Sem ataque"
	if bool(occupant.get("summoning_sick", false)) and not (_has_keyword(occupant, "rapido") or _has_keyword(occupant, "voadora")):
		return "Enjoo"
	if bool(occupant.get("exhausted", false)):
		return "Exausta"
	if priority_owner_id != owner_id:
		return "Aguardando prioridade"
	if get_attack_options(owner_id, slot_index).is_empty():
		return "Sem alvo"
	return "Pode atacar"

func _route_all_reachable_targets(route: Dictionary) -> Array:
	var result: Array = []
	result.append_array(Array(route.get("targets", [])))
	result.append_array(Array(route.get("fallback_slots", [])))
	result.append_array(Array(route.get("ranged_targets", [])))
	return result

func _route_melee_targets(route: Dictionary) -> Array:
	var result: Array = []
	result.append_array(Array(route.get("targets", [])))
	result.append_array(Array(route.get("fallback_slots", [])))
	return result

func _first_melee_route_target(owner_id: String, attacker: Dictionary, route: Dictionary) -> Dictionary:
	for route_target: Variant in _route_melee_targets(route):
		if typeof(route_target) != TYPE_DICTIONARY:
			continue
		var target: Dictionary = Dictionary(route_target)
		if _route_target_is_legal_for_attacker(owner_id, attacker, target):
			return {
				"owner": _normalize_owner_id(str(target.get("owner", _opponent_id(owner_id)))),
				"slot": int(target.get("slot", -1))
			}
	return {}

func _route_target_is_legal_for_attacker(owner_id: String, attacker: Dictionary, target: Dictionary) -> bool:
	var target_owner: String = _normalize_owner_id(str(target.get("owner", _opponent_id(owner_id))))
	var target_slot: int = int(target.get("slot", -1))
	if target_slot < 0:
		return false
	var target_slots: Array = _slots_for_owner(target_owner)
	if target_slot >= target_slots.size() or target_slots[target_slot] == null:
		return false
	var target_occupant: Dictionary = Dictionary(target_slots[target_slot])
	var damage_type: String = _attack_damage_type(attacker)
	var attacker_is_flying: bool = _has_keyword(attacker, "voadora")
	if not _damage_can_affect_occupant(target_occupant, damage_type, attacker_is_flying):
		return false
	if damage_type == DAMAGE_FISICO_MELEE and not attacker_is_flying and str(_slot_definition(target_owner, target_slot).get("elevation", "chao")) == "alto":
		return false
	return true

func _apply_trample_overflow(owner_id: String, route: Dictionary, current_owner: String, current_slot: int, overflow: int, damage_type: String, source_is_flying: bool) -> void:
	var after_current: bool = false
	for route_target: Variant in _route_melee_targets(route):
		if typeof(route_target) != TYPE_DICTIONARY:
			continue
		var target: Dictionary = Dictionary(route_target)
		var target_owner: String = _normalize_owner_id(str(target.get("owner", _opponent_id(owner_id))))
		var target_slot: int = int(target.get("slot", -1))
		if target_owner == current_owner and target_slot == current_slot:
			after_current = true
			continue
		if not after_current:
			continue
		var target_slots: Array = _slots_for_owner(target_owner)
		if target_slot < 0 or target_slot >= target_slots.size() or target_slots[target_slot] == null:
			continue
		var target_occupant: Dictionary = Dictionary(target_slots[target_slot])
		if not _damage_can_affect_occupant(target_occupant, damage_type, source_is_flying):
			continue
		_apply_unit_damage(target_owner, target_slot, overflow, damage_type, source_is_flying)
		_log("Atropelar causa %d de excesso em %s." % [overflow, _slot_label(target_owner, target_slot)])
		return
	if str(route.get("fallback", "none")) == "hero":
		_apply_hero_damage(_opponent_id(owner_id), overflow)
		_log("Atropelar causa %d de excesso ao heroi." % overflow)

func get_phase_label() -> String:
	match current_phase:
		PHASE_UPKEEP:
			return "Manutencao"
		PHASE_DRAW:
			return "Compra"
		PHASE_MAIN:
			return "Fase principal"
		PHASE_DISCARD:
			return "Descarte"
		PHASE_ENDED:
			return "Encerrada"
		_:
			return current_phase

func get_advance_phase_label() -> String:
	if outcome != "":
		return "Encerrado"
	if current_phase == PHASE_DISCARD:
		if discard_controller_id == PLAYER_ID:
			if can_finish_discard():
				return "Encerrar descarte"
			return "Descarte cartas"
		return "Descarte automatico"
	if current_phase != PHASE_MAIN:
		return "Aguarde"
	if priority_owner_id == PLAYER_ID:
		return "Passar prioridade"
	return "Inimigo automatico"

func get_board_route_summary() -> String:
	var parts: Array[String] = []
	for index: int in range(player_slots.size()):
		var route: Dictionary = Dictionary(_attack_routes.get(_route_key(PLAYER_ID, index), {}))
		var labels: Array[String] = []
		for target: Variant in Array(route.get("targets", [])):
			if typeof(target) == TYPE_DICTIONARY:
				labels.append(_target_label(Dictionary(target)))
		var fallback: String = str(route.get("fallback", "none"))
		if fallback == "hero":
			labels.append("Heroi inimigo")
		elif fallback == "none":
			labels.append("sem alvo vazio")
		parts.append("%s -> %s" % [_slot_label(PLAYER_ID, index), "/".join(labels)])
	return "Rotas: %s" % " | ".join(parts)

func get_slot_label(owner_id: String, slot_index: int) -> String:
	return _slot_label(_normalize_owner_id(owner_id), slot_index)

func force_player_health(value: int) -> void:
	var controller: Dictionary = _controller(PLAYER_ID)
	var hero: Dictionary = Dictionary(controller.get("hero", {}))
	hero["health"] = value
	controller["hero"] = hero
	_set_controller(PLAYER_ID, controller)
	_sync_public_fields()
	_check_outcome()

func force_enemy_health(value: int) -> void:
	var controller: Dictionary = _controller(ENEMY_ID)
	if not controller.has("hero"):
		return
	var hero: Dictionary = Dictionary(controller.get("hero", {}))
	hero["health"] = value
	controller["hero"] = hero
	_set_controller(ENEMY_ID, controller)
	_sync_public_fields()
	_check_outcome()

func _encounter_from_config(config: Dictionary) -> Dictionary:
	var encounter_key: String = str(config.get("encontro", config.get("encounter_id", config.get("encounter", ""))))
	if encounter_key == "":
		encounter_key = str(_catalog.get("default_encounter_id")) if _catalog != null else ""
	if encounter_key == "":
		encounter_key = "emboscada_na_ponte"
	if _catalog != null and _catalog.has_method("find_encounter"):
		var found: Dictionary = _catalog.find_encounter(encounter_key)
		if not found.is_empty():
			return found
	return {
		"id": "emboscada_na_ponte",
		"display_name": "Emboscada na Ponte",
		"mode": MODE_CLEAR_BOARD,
		"board_id": "ponte_estavel",
		"starting_enemy_slots": []
	}

func _configure_controllers(deck_ids: Array, encounter: Dictionary) -> void:
	controladores = {}
	var player_hero_resource = _catalog.player_hero
	var enemy_hero_resource = _catalog.enemy_hero
	var encounter_mode: String = str(encounter.get("mode", MODE_CLEAR_BOARD))
	var enemy_is_encounter_controller: bool = encounter_mode == MODE_CLEAR_BOARD or encounter_mode == MODE_WAVES or encounter_mode == MODE_DEFENSE or encounter_mode == MODE_BOSS_PARTS or encounter_mode == MODE_PUZZLE
	var player_controller: Dictionary = {
		"id": PLAYER_ID,
		"kind": "humano",
		"hero": _hero_state(player_hero_resource, PLAYER_ID, DEFAULT_PLAYER_HEALTH),
		"deck": deck_ids.duplicate(),
		"hand": [],
		"energy": 0,
		"energy_max": STARTING_ENERGY_MAX,
		"max_hand_size": STARTING_MAX_HAND_SIZE,
		"turns_started": 0,
		"hero_power_used": false,
		"initial_hand_drawn": false
	}
	var enemy_controller: Dictionary = {
		"id": ENEMY_ID,
		"kind": "encontro" if enemy_is_encounter_controller else "inimigo_ia",
		"deck": Array(encounter.get("enemy_deck", [])).duplicate(),
		"hand": [],
		"energy": 0,
		"energy_max": STARTING_ENERGY_MAX,
		"max_hand_size": STARTING_MAX_HAND_SIZE,
		"turns_started": 0,
		"hero_power_used": false,
		"initial_hand_drawn": false
	}
	if encounter_mode == MODE_DUEL:
		enemy_controller["hero"] = _hero_state(enemy_hero_resource, ENEMY_ID, DEFAULT_ENEMY_HEALTH)
	controladores[PLAYER_ID] = player_controller
	controladores[ENEMY_ID] = enemy_controller
	_sync_public_fields()

func _configure_board(encounter: Dictionary) -> void:
	var board: Dictionary = {}
	if _catalog != null and _catalog.has_method("find_board"):
		board = _catalog.find_board(str(encounter.get("board_id", "")))
	tabuleiro = board
	_player_slot_definitions = Array(board.get("player_slots", _default_slot_definitions(PLAYER_ID, 3)))
	_enemy_slot_definitions = Array(board.get("enemy_slots", _default_slot_definitions(ENEMY_ID, 3)))
	_neutral_slot_definitions = Array(board.get("neutral_slots", []))
	player_slots = _empty_slots(_player_slot_definitions.size())
	enemy_slots = _empty_slots(_enemy_slot_definitions.size())
	neutral_slots = _empty_slots(_neutral_slot_definitions.size())
	_player_slot_labels = _labels_from_slot_definitions(_player_slot_definitions, "P")
	_enemy_slot_labels = _labels_from_slot_definitions(_enemy_slot_definitions, "E")
	_neutral_slot_labels = _labels_from_slot_definitions(_neutral_slot_definitions, "N")
	_attack_routes = {}
	_register_routes(PLAYER_ID, Dictionary(board.get("player_routes", {})), _player_slot_definitions.size(), ENEMY_ID)
	_register_routes(ENEMY_ID, Dictionary(board.get("enemy_routes", {})), _enemy_slot_definitions.size(), PLAYER_ID)

	_waves = Array(encounter.get("waves", []))
	wave_count = _waves.size() if modo_batalha == MODE_WAVES else 0
	wave_index = 0
	defense_turn_limit = int(encounter.get("defense_turn_limit", 0)) if modo_batalha == MODE_DEFENSE else 0
	defense_turns_survived = 0
	_configure_boss_parts(encounter)
	_configure_puzzle(encounter)
	if modo_batalha == MODE_WAVES and wave_count > 0:
		_spawn_wave(0)
	else:
		_spawn_enemy_setups(Array(encounter.get("starting_enemy_slots", [])))

func _configure_boss_parts(encounter: Dictionary) -> void:
	boss_part_slots = []
	if modo_batalha != MODE_BOSS_PARTS:
		return
	for raw_slot: Variant in Array(encounter.get("boss_part_slots", [])):
		var slot_index: int = int(raw_slot)
		if slot_index < 0 or slot_index >= enemy_slots.size():
			continue
		if boss_part_slots.has(slot_index):
			continue
		boss_part_slots.append(slot_index)

func _configure_puzzle(encounter: Dictionary) -> void:
	puzzle_target_slots = []
	puzzle_turn_limit = 0
	puzzle_turns_used = 0
	if modo_batalha != MODE_PUZZLE:
		return
	puzzle_turn_limit = int(encounter.get("puzzle_turn_limit", 0))
	for raw_slot: Variant in Array(encounter.get("puzzle_target_slots", [])):
		var slot_index: int = int(raw_slot)
		if slot_index < 0 or slot_index >= enemy_slots.size():
			continue
		if puzzle_target_slots.has(slot_index):
			continue
		puzzle_target_slots.append(slot_index)

func _spawn_wave(index: int) -> void:
	if index < 0 or index >= _waves.size():
		return
	var wave: Dictionary = Dictionary(_waves[index])
	var wave_number: int = int(wave.get("wave_number", index + 1))
	_spawn_enemy_setups(Array(wave.get("starting_enemy_slots", [])))
	_log("Onda %d/%d chega ao campo." % [wave_number, wave_count])

func _spawn_enemy_setups(setups: Array) -> void:
	for setup: Variant in setups:
		if typeof(setup) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(setup)
		var slot_index: int = int(data.get("slot", -1))
		var card = _catalog.find_card(str(data.get("card_id", "")))
		if card == null or slot_index < 0 or slot_index >= enemy_slots.size():
			continue
		enemy_slots[slot_index] = _build_occupant(card, ENEMY_ID, false)

func _start_turn(controller_id: String) -> void:
	if outcome != "":
		return
	active_player_id = _normalize_owner_id(controller_id)
	discard_controller_id = ""
	discard_target_size = DISCARD_PHASE_TARGET
	discard_voluntary_allowed = true
	_discard_return_phase = ""
	_discard_return_priority_owner_id = ""
	current_phase = PHASE_UPKEEP
	_log("Turno %d: %s." % [turno, _owner_label(active_player_id)])
	_resolve_upkeep(active_player_id)
	_check_outcome()
	if outcome != "":
		return
	current_phase = PHASE_DRAW
	_resolve_draw(active_player_id)
	_check_outcome()
	if outcome != "":
		return
	current_phase = PHASE_MAIN
	priority_owner_id = active_player_id
	consecutive_passes = 0
	_log("Fase principal. Prioridade: %s." % _owner_label(priority_owner_id))
	_sync_public_fields()
	if priority_owner_id == ENEMY_ID:
		_auto_enemy_until_player_priority()

func _resolve_upkeep(controller_id: String) -> void:
	if controller_id == PLAYER_ID and active_class_id == "arcano":
		fluxo = 0
	var controller: Dictionary = _controller(controller_id)
	_maybe_spawn_next_wave(controller_id)
	var turns_started: int = int(controller.get("turns_started", 0)) + 1
	controller["turns_started"] = turns_started
	if turns_started > 1:
		controller["energy_max"] = min(MAX_ENERGY_CAP, int(controller.get("energy_max", STARTING_ENERGY_MAX)) + 1)
		controller["max_hand_size"] = min(MAX_HAND_SIZE_CAP, int(controller.get("max_hand_size", STARTING_MAX_HAND_SIZE)) + 1)
	controller["energy"] = int(controller.get("energy_max", STARTING_ENERGY_MAX))
	controller["hero_power_used"] = false
	_set_controller(controller_id, controller)
	_ready_controller_slots(controller_id)
	_apply_burning_terrain(controller_id)
	_log("Manutencao: %s recarrega energia para %d." % [_owner_label(controller_id), int(controller.get("energy", 0))])
	_sync_public_fields()

func _maybe_spawn_next_wave(controller_id: String) -> void:
	if modo_batalha != MODE_WAVES or controller_id != ENEMY_ID:
		return
	if wave_count <= 0 or wave_index >= wave_count - 1:
		return
	if not _enemy_board_is_clear():
		return
	wave_index += 1
	_spawn_wave(wave_index)
	_sync_public_fields()

func _resolve_draw(controller_id: String) -> void:
	var controller: Dictionary = _controller(controller_id)
	if _is_encounter_controller(controller_id):
		_log("Compra: controlador de encontro nao compra cartas.")
		return
	var was_initial_draw: bool = not bool(controller.get("initial_hand_drawn", false))
	controller["initial_hand_drawn"] = true
	_set_controller(controller_id, controller)
	var drawn: int = _draw_to_hand_limit(controller_id)
	if was_initial_draw:
		_log("Mao inicial de %s: %d carta(s)." % [_owner_label(controller_id), drawn])
	else:
		_log("Compra de %s: %d carta(s)." % [_owner_label(controller_id), drawn])
	_sync_public_fields()

func _end_main_phase() -> void:
	current_phase = PHASE_DISCARD
	discard_controller_id = active_player_id
	discard_target_size = DISCARD_PHASE_TARGET
	discard_voluntary_allowed = true
	priority_owner_id = active_player_id
	consecutive_passes = 0
	_log("Fase de descarte: %s." % _owner_label(discard_controller_id))
	if discard_controller_id == ENEMY_ID:
		_auto_discard_to_limit(ENEMY_ID, discard_target_size)
		_finish_public_discard_phase()
	else:
		_sync_public_fields()

func _finish_public_discard_phase() -> void:
	_cleanup_turn(active_player_id)
	if outcome != "":
		return
	_record_defense_turn_survived(active_player_id)
	_record_puzzle_turn_used(active_player_id)
	_check_outcome()
	if outcome != "":
		return
	discard_controller_id = ""
	discard_target_size = DISCARD_PHASE_TARGET
	discard_voluntary_allowed = true
	turno += 1
	round_number = turno
	_start_turn(_opponent_id(active_player_id))

func _cleanup_turn(controller_id: String) -> void:
	_log("Limpeza tecnica do turno de %s." % _owner_label(controller_id))
	_remove_destroyed()
	_check_outcome()

func _record_defense_turn_survived(controller_id: String) -> void:
	if modo_batalha != MODE_DEFENSE or controller_id != ENEMY_ID:
		return
	defense_turns_survived = min(defense_turn_limit, defense_turns_survived + 1)
	_log("Defesa: %d/%d turno(s) inimigo(s) sobrevivido(s)." % [defense_turns_survived, defense_turn_limit])
	_sync_public_fields()

func _record_puzzle_turn_used(controller_id: String) -> void:
	if modo_batalha != MODE_PUZZLE or controller_id != PLAYER_ID:
		return
	puzzle_turns_used = min(puzzle_turn_limit, puzzle_turns_used + 1)
	_log("Quebra-cabeca: %d/%d turno(s) do jogador usado(s)." % [puzzle_turns_used, puzzle_turn_limit])
	_sync_public_fields()

func _perform_enemy_action() -> Dictionary:
	if not _enemy_ai_enabled:
		return pass_priority(ENEMY_ID)
	if priority_owner_id != ENEMY_ID or current_phase != PHASE_MAIN:
		return {"ok": false, "message": "Inimigo sem prioridade."}

	if modo_batalha == MODE_DUEL:
		var power_result: Dictionary = _enemy_use_hero_power()
		if bool(power_result.get("ok", false)):
			return power_result

	if modo_batalha == MODE_DUEL:
		var play_result: Dictionary = _enemy_play_best_card()
		if bool(play_result.get("ok", false)):
			return play_result

	var attack_result: Dictionary = _enemy_attack_best_ready_unit()
	if bool(attack_result.get("ok", false)):
		return attack_result

	return pass_priority(ENEMY_ID)

func _enemy_use_hero_power() -> Dictionary:
	if modo_batalha != MODE_DUEL or active_player_id != ENEMY_ID:
		return {"ok": false, "message": "Poder inimigo indisponivel."}
	var controller: Dictionary = _controller(ENEMY_ID)
	if not controller.has("hero") or bool(controller.get("hero_power_used", false)):
		return {"ok": false, "message": "Poder inimigo ja usado."}
	controller["hero_power_used"] = true
	_set_controller(ENEMY_ID, controller)
	_apply_hero_damage(PLAYER_ID, 1)
	_log("Golpe Direto causa 1 de dano magico ao heroi do jogador.")
	_after_action_resolved(ENEMY_ID, false)
	return {"ok": true, "message": "Golpe Direto resolvido."}

func _enemy_attack_best_ready_unit() -> Dictionary:
	var best_slot: int = -1
	var best_attack: int = -1
	var best_target: Dictionary = {}
	for index: int in range(enemy_slots.size()):
		var options: Array = get_attack_options(ENEMY_ID, index)
		if options.is_empty():
			continue
		var occupant: Dictionary = Dictionary(enemy_slots[index])
		var attack_value: int = int(occupant.get("attack", 0))
		if attack_value > best_attack:
			best_attack = attack_value
			best_slot = index
			best_target = Dictionary(options[0])
	if best_slot == -1:
		return {"ok": false, "message": "Inimigo sem ataque."}
	return attack_with_unit(ENEMY_ID, best_slot, best_target)

func _auto_enemy_until_player_priority() -> void:
	if _auto_depth > 0:
		return
	_auto_depth += 1
	var steps: int = 0
	while outcome == "" and current_phase == PHASE_MAIN and priority_owner_id == ENEMY_ID and steps < MAX_AUTO_STEPS:
		steps += 1
		var result: Dictionary = _perform_enemy_action()
		if not bool(result.get("ok", false)):
			break
	if steps >= MAX_AUTO_STEPS:
		_log("Automacao inimiga interrompida por limite de seguranca.")
		priority_owner_id = PLAYER_ID
	_auto_depth -= 1
	_sync_public_fields()

func _enemy_play_best_card() -> Dictionary:
	var controller: Dictionary = _controller(ENEMY_ID)
	var controller_hand: Array = Array(controller.get("hand", []))
	var best_index: int = -1
	var best_cost: int = -1
	var best_priority: int = -1
	for index: int in range(controller_hand.size()):
		var card = _catalog.find_card(str(controller_hand[index]))
		if card == null:
			continue
		if int(card.cost) > int(controller.get("energy", 0)):
			continue
		var priority: int = -1
		if card.occupies_slot():
			if _first_open_slot(ENEMY_ID) == -1:
				continue
			priority = 2
		elif card.is_damage_spell() and _controller_has_hero(PLAYER_ID):
			priority = 1
		else:
			continue
		if priority > best_priority or (priority == best_priority and int(card.cost) > best_cost):
			best_priority = priority
			best_cost = int(card.cost)
			best_index = index
	if best_index == -1:
		return {"ok": false, "message": "Inimigo sem carta jogavel."}
	var card = _catalog.find_card(str(controller_hand[best_index]))
	if card.occupies_slot():
		return _play_permanent(ENEMY_ID, best_index, card, {"owner": ENEMY_ID, "slot": _first_open_slot(ENEMY_ID)})
	return _play_damage_spell(ENEMY_ID, best_index, card, {"owner": PLAYER_ID, "slot": -1})

func _play_permanent(controller_id: String, hand_index: int, card, target: Dictionary) -> Dictionary:
	var target_owner: String = _normalize_owner_id(str(target.get("owner", controller_id)))
	if target_owner != controller_id and target_owner != NEUTRAL_ID:
		return _fail("Permanentes precisam entrar em slot aliado ou neutro.")
	var slot_index: int = int(target.get("slot", -1))
	var slots: Array = _slots_for_owner(target_owner)
	if slot_index < 0 or slot_index >= slots.size():
		return _fail("Escolha um slot valido.")
	if slots[slot_index] != null:
		return _fail("Esse slot ja esta ocupado.")
	if not _slot_accepts_card(target_owner, slot_index, card):
		return _fail("%s nao pode entrar em %s." % [card.display_name, _slot_label(target_owner, slot_index)])

	slots[slot_index] = _build_occupant(card, controller_id, not _has_card_keyword(card, "rapido"))
	_set_slots_for_owner(target_owner, slots)
	_spend_card(controller_id, hand_index, card)
	_log("%s entra em %s." % [card.display_name, _slot_label(target_owner, slot_index)])
	_visual("invocacao", target_owner, slot_index, "Entrada", Color(0.55, 1.0, 0.55))
	if controller_id == PLAYER_ID and active_class_id == "invocador":
		_trigger_comandante_de_campo()
	_check_outcome()
	_after_action_resolved(controller_id, _is_instant_speed_card(card))
	return {"ok": true, "message": "Carta jogada."}

func _play_damage_spell(controller_id: String, hand_index: int, card, target: Dictionary) -> Dictionary:
	var target_owner: String = _normalize_owner_id(str(target.get("owner", _opponent_id(controller_id))))
	var slot_index: int = int(target.get("slot", -1))
	var amount: int = int(card.effect.get("amount", card.effect.get("damage", 0))) + _player_fluxo_bonus(controller_id)
	if slot_index >= 0:
		var target_slots: Array = _slots_for_owner(target_owner)
		if slot_index >= target_slots.size() or target_slots[slot_index] == null:
			return _fail("Magia precisa de um alvo valido.")
		_apply_unit_damage(target_owner, slot_index, amount, DAMAGE_MAGICO)
		_log("%s causa %d de dano em %s." % [card.display_name, amount, _slot_label(target_owner, slot_index)])
	else:
		if not _controller_has_hero(target_owner):
			return _fail("Este encontro nao possui heroi inimigo como alvo.")
		_apply_hero_damage(target_owner, amount)
		_log("%s causa %d de dano ao heroi." % [card.display_name, amount])

	_spend_card(controller_id, hand_index, card)
	_remove_destroyed()
	_check_outcome()
	_after_action_resolved(controller_id, _is_instant_speed_card(card))
	return {"ok": true, "message": "Magia resolvida."}

func _play_board_spell(controller_id: String, hand_index: int, card) -> Dictionary:
	var action_target: String = str(card.effect.get("target", ""))
	if str(card.effect.get("apply_status", "")) == "queimando" and action_target == "all_enemy_slots":
		var target_owner: String = _opponent_id(controller_id)
		var definitions: Array = _enemy_slot_definitions if target_owner == ENEMY_ID else _player_slot_definitions
		for index: int in range(definitions.size()):
			var slot_def: Dictionary = Dictionary(definitions[index])
			slot_def["status"] = _append_status(Array(slot_def.get("status", [])), "queimando")
			definitions[index] = slot_def
		if target_owner == ENEMY_ID:
			_enemy_slot_definitions = definitions
		else:
			_player_slot_definitions = definitions
		_spend_card(controller_id, hand_index, card)
		_log("%s incendeia todos os slots inimigos." % card.display_name)
		_visual("magia", target_owner, -1, "Queimando", Color(0.95, 0.35, 0.18))
		_after_action_resolved(controller_id, _is_instant_speed_card(card))
		return {"ok": true, "message": "Magia de tabuleiro resolvida."}
	if str(card.effect.get("remove_status", "")) == "enjoo" and str(card.effect.get("apply_status", "")) == "pronta":
		var slots: Array = _slots_for_owner(controller_id)
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			if str(occupant.get("type", "")) != "criatura":
				continue
			occupant["summoning_sick"] = false
			occupant["ready"] = true
			occupant["exhausted"] = false
			slots[index] = occupant
		_set_slots_for_owner(controller_id, slots)
		_spend_card(controller_id, hand_index, card)
		_log("%s deixa as criaturas amigas prontas." % card.display_name)
		_visual("buff", controller_id, -1, "Prontas", Color(0.4, 0.9, 1.0))
		_after_action_resolved(controller_id, _is_instant_speed_card(card))
		return {"ok": true, "message": "Magia de tabuleiro resolvida."}
	if str(card.effect.get("action", "")) == "gain_stats" and str(card.effect.get("target", "")) == "all_own_creatures":
		var atk_bonus: int = int(card.effect.get("attack", 0))
		var hp_bonus: int = int(card.effect.get("health", 0))
		var slots: Array = _slots_for_owner(controller_id)
		for i: int in range(slots.size()):
			if slots[i] == null:
				continue
			_apply_permanent_stat_buff(controller_id, i, atk_bonus, hp_bonus)
		_spend_card(controller_id, hand_index, card)
		_log("%s: todas as criaturas aliadas ganham +%d/+%d permanente." % [card.display_name, atk_bonus, hp_bonus])
		_visual("buff", controller_id, -1, "+%d/+%d todas" % [atk_bonus, hp_bonus], Color(1.0, 0.85, 0.2))
		_after_action_resolved(controller_id, _is_instant_speed_card(card))
		return {"ok": true, "message": "Magia de tabuleiro resolvida."}
	return _fail("Magia de tabuleiro ainda nao suportada: %s." % card.display_name)

func _play_buff_command(controller_id: String, hand_index: int, card, target: Dictionary) -> Dictionary:
	var target_owner: String = _normalize_owner_id(str(target.get("owner", controller_id)))
	if target_owner != controller_id:
		return _fail("Comando defensivo precisa de alvo aliado.")
	var slot_index: int = int(target.get("slot", -1))
	var slots: Array = _slots_for_owner(controller_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return _fail("Escolha um alvo aliado valido.")

	var amount: int = int(card.effect.get("amount", 0))
	var occupant: Dictionary = Dictionary(slots[slot_index])
	occupant["health"] = int(occupant.get("health", 0)) + amount
	occupant["max_health"] = int(occupant.get("max_health", 0)) + amount
	slots[slot_index] = occupant
	_set_slots_for_owner(controller_id, slots)
	_spend_card(controller_id, hand_index, card)
	_log("%s fortalece %s em +%d vida." % [card.display_name, _slot_label(controller_id, slot_index), amount])
	_visual("buff", controller_id, slot_index, "+%d vida" % amount, Color(0.4, 0.9, 1.0))
	_after_action_resolved(controller_id, _is_instant_speed_card(card))
	return {"ok": true, "message": "Comando resolvido."}

func _play_stat_buff_spell(controller_id: String, hand_index: int, card, target: Dictionary) -> Dictionary:
	var target_owner: String = _normalize_owner_id(str(target.get("owner", controller_id)))
	if target_owner != controller_id:
		return _fail("Buff de stats precisa de alvo aliado.")
	var slot_index: int = int(target.get("slot", -1))
	var slots: Array = _slots_for_owner(controller_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return _fail("Escolha um aliado valido para o buff.")
	var atk_bonus: int = int(card.effect.get("attack", 0))
	var hp_bonus: int = int(card.effect.get("health", 0))
	_apply_permanent_stat_buff(controller_id, slot_index, atk_bonus, hp_bonus)
	_spend_card(controller_id, hand_index, card)
	_log("%s: %s ganha +%d/+%d permanente." % [card.display_name, _slot_label(controller_id, slot_index), atk_bonus, hp_bonus])
	_visual("buff", controller_id, slot_index, "+%d/+%d" % [atk_bonus, hp_bonus], Color(1.0, 0.85, 0.2))
	_after_action_resolved(controller_id, _is_instant_speed_card(card))
	return {"ok": true, "message": "Buff de stats aplicado."}

func _apply_permanent_stat_buff(owner_id: String, slot_index: int, atk_bonus: int, hp_bonus: int) -> void:
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if atk_bonus != 0:
		occupant["attack"] = int(occupant.get("attack", 0)) + atk_bonus
	if hp_bonus != 0:
		occupant["health"] = int(occupant.get("health", 0)) + hp_bonus
		occupant["max_health"] = int(occupant.get("max_health", 0)) + hp_bonus
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)

func _trigger_comandante_de_campo() -> void:
	var slots: Array = _slots_for_owner(PLAYER_ID)
	var best_index: int = -1
	var best_atk: int = -1
	for i: int in range(slots.size()):
		if slots[i] == null:
			continue
		var atk: int = int(Dictionary(slots[i]).get("attack", 0))
		if atk > best_atk:
			best_atk = atk
			best_index = i
	if best_index < 0:
		return
	var occ_name: String = str(Dictionary(slots[best_index]).get("name", "criatura"))
	_apply_permanent_stat_buff(PLAYER_ID, best_index, 1, 0)
	_log("Comandante de Campo: %s ganha +1/+0." % occ_name)
	_visual("buff", PLAYER_ID, best_index, "+1 ATK", Color(1.0, 0.85, 0.2))

func _after_action_resolved(controller_id: String, instant: bool) -> void:
	if outcome != "" or current_phase != PHASE_MAIN:
		return
	consecutive_passes = 0
	if instant:
		_log("Acao instantanea: prioridade permanece com %s." % _owner_label(controller_id))
	else:
		priority_owner_id = _opponent_id(controller_id)
		_log("Prioridade: %s." % _owner_label(priority_owner_id))
	if controller_id == PLAYER_ID:
		_auto_enemy_until_player_priority()
	_sync_public_fields()

func _spend_card(controller_id: String, hand_index: int, card) -> void:
	var controller: Dictionary = _controller(controller_id)
	var controller_hand: Array = Array(controller.get("hand", []))
	var card_id: String = str(controller_hand[hand_index])
	controller["energy"] = int(controller.get("energy", 0)) - int(card.cost)
	controller_hand.remove_at(hand_index)
	controller["hand"] = controller_hand
	_set_controller(controller_id, controller)
	if not card.occupies_slot():
		_move_card_to_bottom_of_deck(controller_id, card_id)
	_sync_public_fields()

func _draw_cards_for(controller_id: String, amount: int) -> int:
	var controller: Dictionary = _controller(controller_id)
	var controller_deck: Array = Array(controller.get("deck", []))
	var controller_hand: Array = Array(controller.get("hand", []))
	var drawn: int = 0
	for _i: int in range(amount):
		if controller_deck.is_empty():
			break
		var card_id: String = str(controller_deck.pop_front())
		controller_hand.append(card_id)
		drawn += 1
	controller["deck"] = controller_deck
	controller["hand"] = controller_hand
	_set_controller(controller_id, controller)
	_enforce_immediate_hand_limit(controller_id)
	return drawn

func _draw_to_hand_limit(controller_id: String) -> int:
	var controller: Dictionary = _controller(controller_id)
	var controller_hand: Array = Array(controller.get("hand", []))
	var target_size: int = int(controller.get("max_hand_size", STARTING_MAX_HAND_SIZE))
	if controller_hand.size() >= target_size:
		return 0
	return _draw_cards_for(controller_id, target_size - controller_hand.size())

func _move_card_to_bottom_of_deck(controller_id: String, card_id: String) -> void:
	if card_id == "":
		return
	var controller: Dictionary = _controller(controller_id)
	var controller_deck: Array = Array(controller.get("deck", []))
	controller_deck.append(card_id)
	controller["deck"] = controller_deck
	_set_controller(controller_id, controller)

func _enforce_immediate_hand_limit(controller_id: String) -> void:
	var controller: Dictionary = _controller(controller_id)
	var controller_hand: Array = Array(controller.get("hand", []))
	if controller_hand.size() < IMMEDIATE_DISCARD_TRIGGER:
		return
	if controller_id == ENEMY_ID:
		_auto_discard_to_limit(controller_id, TEMPORARY_HAND_CEILING)
		return
	discard_controller_id = PLAYER_ID
	discard_target_size = TEMPORARY_HAND_CEILING
	discard_voluntary_allowed = false
	_discard_return_phase = current_phase
	_discard_return_priority_owner_id = priority_owner_id
	current_phase = PHASE_DISCARD
	priority_owner_id = PLAYER_ID
	_log("Limite temporario: descarte ate ficar com %d carta(s)." % TEMPORARY_HAND_CEILING)
	_sync_public_fields()

func _auto_discard_to_limit(controller_id: String, target_size: int) -> void:
	var controller: Dictionary = _controller(controller_id)
	var controller_hand: Array = Array(controller.get("hand", []))
	while controller_hand.size() > target_size:
		var discard_index: int = _lowest_cost_card_index(controller_hand)
		var card_id: String = str(controller_hand[discard_index])
		controller_hand.remove_at(discard_index)
		controller["hand"] = controller_hand
		_set_controller(controller_id, controller)
		_move_card_to_bottom_of_deck(controller_id, card_id)
		controller = _controller(controller_id)
		controller_hand = Array(controller.get("hand", []))
		_log("Descarte automatico: %s vai para o fundo do deck." % _card_name(card_id))
	_sync_public_fields()

func _lowest_cost_card_index(card_ids: Array) -> int:
	var best_index: int = 0
	var best_cost: int = 999
	for index: int in range(card_ids.size()):
		var card = _catalog.find_card(str(card_ids[index])) if _catalog != null else null
		var cost: int = int(card.cost) if card != null else 999
		if cost < best_cost:
			best_cost = cost
			best_index = index
	return best_index

func _finish_immediate_discard() -> void:
	current_phase = _discard_return_phase
	priority_owner_id = _discard_return_priority_owner_id
	discard_controller_id = ""
	discard_target_size = DISCARD_PHASE_TARGET
	discard_voluntary_allowed = true
	_discard_return_phase = ""
	_discard_return_priority_owner_id = ""
	_sync_public_fields()

func _attack_damage_type(occupant: Dictionary) -> String:
	if _has_keyword(occupant, "alcance"):
		return DAMAGE_FISICO_ALCANCE
	return DAMAGE_FISICO_MELEE

func _damage_can_affect_occupant(occupant: Dictionary, damage_type: String, source_is_flying: bool = false) -> bool:
	if damage_type == DAMAGE_FISICO_MELEE and _has_keyword(occupant, "voadora") and not source_is_flying:
		return false
	return true

func _coverage_value(owner_id: String, slot_index: int, occupant: Dictionary) -> int:
	var value: int = 0
	var slot_def: Dictionary = _slot_definition(owner_id, slot_index)
	if str(slot_def.get("terrain", "")) == "cobertura":
		value += 1
	if _has_keyword(occupant, "cobertura"):
		value += 1
	return value

func _append_status(statuses: Array, status_id: String) -> Array:
	if not statuses.has(status_id):
		statuses.append(status_id)
	return statuses

func _slot_has_status(slot_def: Dictionary, status_id: String) -> bool:
	return str(slot_def.get("terrain", "")) == status_id or Array(slot_def.get("status", [])).has(status_id)

func _occupant_has_status(occupant: Dictionary, status_id: String) -> bool:
	return Array(occupant.get("status", [])).has(status_id) or _has_keyword(occupant, status_id)

func _apply_unit_damage(owner_id: String, slot_index: int, amount: int, damage_type: String = DAMAGE_FISICO_MELEE, source_is_flying: bool = false) -> int:
	if amount <= 0:
		return 0
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return 0
	var final_amount: int = amount
	var slot_def: Dictionary = _slot_definition(owner_id, slot_index)
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if not _damage_can_affect_occupant(occupant, damage_type, source_is_flying):
		_log("%s evita dano %s." % [_slot_label(owner_id, slot_index), damage_type])
		return 0
	if damage_type == DAMAGE_FISICO_ALCANCE:
		final_amount = max(0, final_amount - _coverage_value(owner_id, slot_index, occupant))
	occupant["health"] = int(occupant.get("health", 0)) - final_amount
	slots[slot_index] = occupant
	_set_slots_for_owner(owner_id, slots)
	_visual("dano", owner_id, slot_index, "-%d" % final_amount, Color(1.0, 0.35, 0.25))
	return final_amount

func _apply_hero_damage(owner_id: String, amount: int) -> void:
	if amount <= 0:
		return
	var controller: Dictionary = _controller(owner_id)
	if not controller.has("hero"):
		return
	var hero: Dictionary = Dictionary(controller.get("hero", {}))
	var armor: int = int(hero.get("armor", 0))
	var absorbed: int = min(armor, amount)
	armor -= absorbed
	var remaining: int = amount - absorbed
	hero["armor"] = armor
	hero["health"] = int(hero.get("health", 0)) - remaining
	controller["hero"] = hero
	_set_controller(owner_id, controller)
	_visual("dano_heroi", owner_id, -1, "-%d" % amount, Color(1.0, 0.28, 0.25))
	_sync_public_fields()

func _apply_burning_terrain(controller_id: String) -> void:
	var slots: Array = _slots_for_owner(controller_id)
	for index: int in range(slots.size()):
		var slot_def: Dictionary = _slot_definition(controller_id, index)
		if slots[index] == null:
			continue
		var occupant: Dictionary = Dictionary(slots[index])
		if _slot_has_status(slot_def, "queimando"):
			_apply_unit_damage(controller_id, index, 1, DAMAGE_MAGICO)
			_log("Slot queimando causa 1 em %s." % _slot_label(controller_id, index))
		if _occupant_has_status(occupant, "queimando") and slots[index] != null:
			_apply_unit_damage(controller_id, index, 1, DAMAGE_MAGICO)
			_log("Criatura queimando causa 1 em %s." % _slot_label(controller_id, index))
	_remove_destroyed()

func _remove_destroyed() -> void:
	for lane: int in range(player_slots.size()):
		if player_slots[lane] != null and int(player_slots[lane].get("health", 0)) <= 0:
			var player_card_id: String = str(player_slots[lane].get("card_id", ""))
			_log("%s foi destruida em %s." % [str(player_slots[lane].get("name", "Carta")), _slot_label(PLAYER_ID, lane)])
			_visual("morte", PLAYER_ID, lane, "Destruida", Color(1.0, 0.45, 0.45))
			player_slots[lane] = null
			_move_card_to_bottom_of_deck(PLAYER_ID, player_card_id)
	for lane: int in range(enemy_slots.size()):
		if enemy_slots[lane] != null and int(enemy_slots[lane].get("health", 0)) <= 0:
			var enemy_card_id: String = str(enemy_slots[lane].get("card_id", ""))
			_log("%s foi destruida em %s." % [str(enemy_slots[lane].get("name", "Carta")), _slot_label(ENEMY_ID, lane)])
			_visual("morte", ENEMY_ID, lane, "Destruida", Color(1.0, 0.45, 0.45))
			enemy_slots[lane] = null
			_move_card_to_bottom_of_deck(ENEMY_ID, enemy_card_id)
	for lane: int in range(neutral_slots.size()):
		if neutral_slots[lane] != null and int(neutral_slots[lane].get("health", 0)) <= 0:
			var neutral_occupant: Dictionary = Dictionary(neutral_slots[lane])
			var neutral_card_id: String = str(neutral_occupant.get("card_id", ""))
			var owner_id: String = _normalize_owner_id(str(neutral_occupant.get("owner", PLAYER_ID)))
			_log("%s foi destruida em %s." % [str(neutral_occupant.get("name", "Carta")), _slot_label(NEUTRAL_ID, lane)])
			_visual("morte", NEUTRAL_ID, lane, "Destruida", Color(1.0, 0.45, 0.45))
			neutral_slots[lane] = null
			_move_card_to_bottom_of_deck(owner_id, neutral_card_id)

func _check_outcome() -> void:
	if outcome != "":
		return
	_sync_public_fields()
	var player_dead: bool = player_health <= 0
	var puzzle_failed: bool = modo_batalha == MODE_PUZZLE and puzzle_turn_limit > 0 and puzzle_turns_used >= puzzle_turn_limit and not _puzzle_targets_are_clear()
	var victory: bool = false
	if modo_batalha == MODE_DUEL:
		victory = _controller_has_hero(ENEMY_ID) and enemy_health <= 0
	elif modo_batalha == MODE_WAVES:
		victory = wave_count > 0 and wave_index >= wave_count - 1 and _enemy_board_is_clear()
	elif modo_batalha == MODE_DEFENSE:
		victory = defense_turn_limit > 0 and defense_turns_survived >= defense_turn_limit
	elif modo_batalha == MODE_BOSS_PARTS:
		victory = _boss_parts_are_clear()
	elif modo_batalha == MODE_PUZZLE:
		victory = _puzzle_targets_are_clear()
	else:
		victory = _enemy_board_is_clear()
	if player_dead or puzzle_failed:
		outcome = "defeat"
		current_phase = PHASE_ENDED
		if player_dead:
			_log("Derrota: o heroi do jogador chegou a 0 HP.")
		else:
			_log("Derrota: o quebra-cabeca nao foi resolvido a tempo.")
	elif victory:
		outcome = "victory"
		current_phase = PHASE_ENDED
		_log("Vitoria: objetivo do encontro concluido.")

func _enemy_board_is_clear() -> bool:
	for occupant: Variant in enemy_slots:
		if occupant != null:
			return false
	return true

func _boss_parts_are_clear() -> bool:
	return not boss_part_slots.is_empty() and _boss_parts_destroyed_count() >= boss_part_slots.size()

func _boss_parts_destroyed_count() -> int:
	var destroyed: int = 0
	for slot_index: int in boss_part_slots:
		if slot_index < 0 or slot_index >= enemy_slots.size() or enemy_slots[slot_index] == null:
			destroyed += 1
	return destroyed

func _puzzle_targets_are_clear() -> bool:
	return not puzzle_target_slots.is_empty() and _puzzle_targets_cleared_count() >= puzzle_target_slots.size()

func _puzzle_targets_cleared_count() -> int:
	var cleared: int = 0
	for slot_index: int in puzzle_target_slots:
		if slot_index < 0 or slot_index >= enemy_slots.size() or enemy_slots[slot_index] == null:
			cleared += 1
	return cleared

func _ready_controller_slots(controller_id: String) -> void:
	for owner_id: String in [controller_id, NEUTRAL_ID]:
		var slots: Array = _slots_for_owner(owner_id)
		var changed: bool = false
		for index: int in range(slots.size()):
			if slots[index] == null:
				continue
			var occupant: Dictionary = Dictionary(slots[index])
			if str(occupant.get("owner", "")) != controller_id:
				continue
			occupant["ready"] = true
			occupant["exhausted"] = false
			occupant["summoning_sick"] = false
			occupant["moved_this_turn"] = false
			slots[index] = occupant
			changed = true
		if changed:
			_set_slots_for_owner(owner_id, slots)

func _build_occupant(card, owner_id: String, summoning_sick: bool) -> Dictionary:
	var keywords: Array = Array(card.keywords)
	if _has_card_keyword(card, "rapido") or _has_card_keyword(card, "voadora"):
		summoning_sick = false
	return {
		"card_id": card.id,
		"name": card.display_name,
		"owner": owner_id,
		"type": card.card_type,
		"attack": int(card.attack),
		"health": int(card.health),
		"max_health": int(card.health),
		"ready": not summoning_sick,
		"exhausted": false,
		"summoning_sick": summoning_sick,
		"moved_this_turn": false,
		"keywords": keywords,
		"status": [],
		"command_cost": int(card.command_cost),
		"ranged": bool(card.effect.get("ranged", false)) or _has_card_keyword(card, "alcance")
	}

func _can_attack_from_slot(owner_id: String, slot_index: int) -> bool:
	if outcome != "" or current_phase != PHASE_MAIN or priority_owner_id != owner_id:
		return false
	var slots: Array = _slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return false
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if int(occupant.get("attack", 0)) <= 0:
		return false
	if bool(occupant.get("exhausted", false)):
		return false
	if bool(occupant.get("summoning_sick", false)) and not (_has_keyword(occupant, "rapido") or _has_keyword(occupant, "voadora")):
		return false
	if _has_keyword(occupant, "defensor"):
		return false
	return true

func _route_occupied_targets(owner_id: String, slot_index: int) -> Array:
	var result: Array = []
	var route: Dictionary = Dictionary(_attack_routes.get(_route_key(owner_id, slot_index), {}))
	for target: Variant in Array(route.get("targets", [])):
		if typeof(target) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(target)
		var target_owner: String = _normalize_owner_id(str(data.get("owner", _opponent_id(owner_id))))
		var target_slot: int = int(data.get("slot", -1))
		var slots: Array = _slots_for_owner(target_owner)
		if target_slot >= 0 and target_slot < slots.size() and slots[target_slot] != null:
			result.append({"owner": target_owner, "slot": target_slot})
	return result

func _slot_accepts_card(owner_id: String, slot_index: int, card) -> bool:
	var slot_def: Dictionary = _slot_definition(owner_id, slot_index)
	var accepts: Array = Array(slot_def.get("accepts", ["criatura", "estrutura", "permanente"]))
	if not accepts.has(str(card.card_type)):
		return false
	return true

func _register_routes(owner_id: String, configured_routes: Dictionary, source_count: int, target_owner_id: String) -> void:
	for index: int in range(source_count):
		var route_targets: Array = []
		var fallback_slots: Array = []
		var ranged_targets: Array = []
		var fallback: String = "hero" if modo_batalha == MODE_DUEL or owner_id == ENEMY_ID else "none"
		var raw: Variant = configured_routes.get(str(index), configured_routes.get(_slot_label(owner_id, index), null))
		if typeof(raw) == TYPE_DICTIONARY:
			var raw_dict: Dictionary = Dictionary(raw)
			route_targets = Array(raw_dict.get("targets", []))
			fallback_slots = Array(raw_dict.get("fallback_slots", []))
			ranged_targets = Array(raw_dict.get("ranged_targets", []))
			fallback = str(raw_dict.get("fallback", fallback))
		elif typeof(raw) == TYPE_ARRAY:
			route_targets = Array(raw)
		if route_targets.is_empty():
			route_targets.append({"owner": target_owner_id, "slot": index})
		_attack_routes[_route_key(owner_id, index)] = {
			"targets": route_targets,
			"fallback_slots": fallback_slots,
			"ranged_targets": ranged_targets,
			"fallback": fallback
		}

func _default_slot_definitions(owner_id: String, count: int) -> Array:
	var result: Array = []
	var prefix: String = "P" if owner_id == PLAYER_ID else "E"
	for index: int in range(count):
		result.append({
			"id": "%s%d" % [prefix, index + 1],
			"terrain": "normal",
			"elevation": "chao",
			"accepts": ["criatura", "estrutura", "permanente"]
		})
	return result

func _labels_from_slot_definitions(definitions: Array, prefix: String) -> Array[String]:
	var labels: Array[String] = []
	for index: int in range(definitions.size()):
		var definition: Dictionary = Dictionary(definitions[index])
		labels.append(str(definition.get("label", definition.get("id", "%s%d" % [prefix, index + 1]))))
	return labels

func _empty_slots(count: int) -> Array:
	var result: Array = []
	for _index: int in range(count):
		result.append(null)
	return result

func _slot_definition(owner_id: String, slot_index: int) -> Dictionary:
	owner_id = _normalize_owner_id(owner_id)
	var definitions: Array = _player_slot_definitions
	if owner_id == ENEMY_ID:
		definitions = _enemy_slot_definitions
	elif owner_id == NEUTRAL_ID:
		definitions = _neutral_slot_definitions
	if slot_index < 0 or slot_index >= definitions.size():
		return {}
	return Dictionary(definitions[slot_index])

func _first_open_slot(owner_id: String) -> int:
	var slots: Array = _slots_for_owner(owner_id)
	for index: int in range(slots.size()):
		if slots[index] == null:
			return index
	return -1

func _controller(controller_id: String) -> Dictionary:
	controller_id = _normalize_owner_id(controller_id)
	return Dictionary(controladores.get(controller_id, {}))

func _set_controller(controller_id: String, controller: Dictionary) -> void:
	controladores[_normalize_owner_id(controller_id)] = controller

func _controller_energy(controller_id: String) -> int:
	return int(_controller(controller_id).get("energy", 0))

func _is_encounter_controller(controller_id: String) -> bool:
	return controller_id == ENEMY_ID and str(_controller(controller_id).get("kind", "")) == "encontro"

func _controller_has_hero(controller_id: String) -> bool:
	return _controller(controller_id).has("hero")

func _hero_state(hero_resource, owner_id: String, fallback_health: int) -> Dictionary:
	var max_health: int = fallback_health
	var hero_id: String = owner_id
	var hero_name: String = _owner_label(owner_id)
	if hero_resource != null:
		max_health = int(hero_resource.max_health)
		hero_id = str(hero_resource.id)
		hero_name = str(hero_resource.display_name)
	return {
		"id": hero_id,
		"name": hero_name,
		"controller": owner_id,
		"health": max_health,
		"max_health": max_health,
		"armor": 0
	}

func _sync_public_fields() -> void:
	var player: Dictionary = _controller(PLAYER_ID)
	var player_hero: Dictionary = Dictionary(player.get("hero", {}))
	player_health = int(player_hero.get("health", player_health))
	player_armor = int(player_hero.get("armor", 0))
	energy = int(player.get("energy", energy))
	deck = Array(player.get("deck", [])).duplicate()
	hand = Array(player.get("hand", [])).duplicate()
	discard = []
	hero_power_used = bool(player.get("hero_power_used", false))
	var enemy: Dictionary = _controller(ENEMY_ID)
	if enemy.has("hero"):
		var enemy_hero: Dictionary = Dictionary(enemy.get("hero", {}))
		enemy_health = int(enemy_hero.get("health", enemy_health))
		enemy_armor = int(enemy_hero.get("armor", 0))
	else:
		enemy_health = 0
		enemy_armor = 0

func _slots_for_owner(owner_id: String) -> Array:
	var normalized: String = _normalize_owner_id(owner_id)
	if normalized == ENEMY_ID:
		return enemy_slots
	if normalized == NEUTRAL_ID:
		return neutral_slots
	return player_slots

func _set_slots_for_owner(owner_id: String, slots: Array) -> void:
	var normalized: String = _normalize_owner_id(owner_id)
	if normalized == ENEMY_ID:
		enemy_slots = slots
	elif normalized == NEUTRAL_ID:
		neutral_slots = slots
	else:
		player_slots = slots

func _opponent_id(owner_id: String) -> String:
	return ENEMY_ID if _normalize_owner_id(owner_id) == PLAYER_ID else PLAYER_ID

func _owner_label(owner_id: String) -> String:
	return "jogador" if _normalize_owner_id(owner_id) == PLAYER_ID else "inimigo"

func _normalize_owner_id(owner_id: String) -> String:
	if owner_id in ["neutral", "neutro", NEUTRAL_ID]:
		return NEUTRAL_ID
	if owner_id in ["enemy", "inimigo", ENEMY_ID]:
		return ENEMY_ID
	return PLAYER_ID

func _route_key(owner_id: String, slot_index: int) -> String:
	return "%s:%d" % [_normalize_owner_id(owner_id), slot_index]

func _slot_label(owner_id: String, slot_index: int) -> String:
	owner_id = _normalize_owner_id(owner_id)
	var labels: Array[String] = _player_slot_labels
	var prefix: String = "P"
	if owner_id == ENEMY_ID:
		labels = _enemy_slot_labels
		prefix = "E"
	elif owner_id == NEUTRAL_ID:
		labels = _neutral_slot_labels
		prefix = "N"
	if slot_index >= 0 and slot_index < labels.size():
		return labels[slot_index]
	return "%s%d" % [prefix, slot_index + 1]

func _target_label(target: Dictionary) -> String:
	var owner_id: String = _normalize_owner_id(str(target.get("owner", ENEMY_ID)))
	var slot_index: int = int(target.get("slot", -1))
	if slot_index >= 0:
		return _slot_label(owner_id, slot_index)
	if owner_id == ENEMY_ID:
		return "Heroi inimigo"
	return "Heroi do jogador"

func _add_attack_option(options: Array, seen: Dictionary, target: Dictionary) -> void:
	var key: String = "%s:%d" % [str(target.get("owner", "")), int(target.get("slot", -1))]
	if seen.has(key):
		return
	seen[key] = true
	target["label"] = _target_label(target)
	options.append(target)

func _target_in_options(target: Dictionary, options: Array) -> bool:
	var target_owner: String = _normalize_owner_id(str(target.get("owner", "")))
	var target_slot: int = int(target.get("slot", -99))
	for option: Variant in options:
		var option_dict: Dictionary = Dictionary(option)
		if _normalize_owner_id(str(option_dict.get("owner", ""))) == target_owner and int(option_dict.get("slot", -99)) == target_slot:
			return true
	return false

func _is_instant_speed_card(card) -> bool:
	return card != null and (str(card.speed) == "instantanea" or _has_card_keyword(card, "instantaneo"))

func _has_card_keyword(card, keyword: String) -> bool:
	return card != null and card.has_method("has_keyword") and (card.has_keyword(keyword) or card.has_keyword(_keyword_alias(keyword)))

func _has_keyword(occupant: Dictionary, keyword: String) -> bool:
	var keywords: Array = Array(occupant.get("keywords", []))
	return keywords.has(keyword) or keywords.has(_keyword_alias(keyword))

func _keyword_alias(keyword: String) -> String:
	match keyword:
		"rapido":
			return "fast"
		"defensor":
			return "defender"
		"alcance":
			return "reach"
		"atropelar":
			return "trample"
		_:
			return keyword

func _card_name(card_id: String) -> String:
	if _catalog == null:
		return card_id
	return _catalog.card_name(card_id)

func _visual(kind: String, owner_id: String, slot_index: int, text: String, color: Color) -> void:
	eventos_visuais.append({
		"kind": kind,
		"owner": _normalize_owner_id(owner_id),
		"slot": slot_index,
		"text": text,
		"color": color
	})

func _log(line: String) -> void:
	log_lines.append(line)
	if log_lines.size() > MAX_LOG_LINES:
		log_lines.pop_front()

func _fail(message: String) -> Dictionary:
	_log(message)
	return {"ok": false, "message": message}
