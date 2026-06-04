extends RefCounted

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"

const BOARD_FORMAT_FRONT_REAR: String = "frente_retaguarda"
const COMBAT_STAGE_INITIATIVE_FRONT: String = "Iniciativa - Frente"
const COMBAT_STAGE_INITIATIVE_OVERFLOW: String = "Iniciativa - Sobra"
const COMBAT_STAGE_NORMAL_FRONT: String = "Combate - Frente"
const COMBAT_STAGE_NORMAL_OVERFLOW: String = "Combate - Sobra"

static func resolve_staged_combat_step(engine) -> void:
	var attacked_sources: Dictionary = {}
	resolve_combat_stage(engine, COMBAT_STAGE_INITIATIVE_FRONT, true, true, attacked_sources)
	resolve_combat_stage(engine, COMBAT_STAGE_INITIATIVE_OVERFLOW, true, false, attacked_sources)
	resolve_combat_stage(engine, COMBAT_STAGE_NORMAL_FRONT, false, true, attacked_sources)
	resolve_combat_stage(engine, COMBAT_STAGE_NORMAL_OVERFLOW, false, false, attacked_sources)

static func resolve_combat_stage(engine, stage_name: String, initiative_stage: bool, front_stage: bool, attacked_sources: Dictionary) -> void:
	if front_stage:
		resolve_batched_combat_stage(engine, stage_name, initiative_stage, attacked_sources)
	else:
		resolve_sequential_combat_stage(engine, stage_name, initiative_stage, attacked_sources)

static func resolve_batched_combat_stage(engine, stage_name: String, initiative_stage: bool, attacked_sources: Dictionary) -> void:
	if engine.outcome != "":
		return
	var attacks: Array[Dictionary] = []
	var lane_count: int = max(engine.player_slots.size(), engine.enemy_slots.size())
	for owner_id: String in [PLAYER_ID, ENEMY_ID]:
		for slot_index: int in range(lane_count):
			var attack: Dictionary = build_staged_attack_if_valid(engine, stage_name, initiative_stage, true, attacked_sources, owner_id, slot_index)
			if not attack.is_empty():
				attacks.append(attack)
	apply_stage_attacks(engine, stage_name, attacks)

static func resolve_sequential_combat_stage(engine, stage_name: String, initiative_stage: bool, attacked_sources: Dictionary) -> void:
	if engine.outcome != "":
		return
	var lane_count: int = max(engine.player_slots.size(), engine.enemy_slots.size())
	var stage_started: bool = false
	for slot_index: int in range(lane_count):
		for owner_id: String in [PLAYER_ID, ENEMY_ID]:
			if engine.outcome != "":
				return
			var attack: Dictionary = build_staged_attack_if_valid(engine, stage_name, initiative_stage, false, attacked_sources, owner_id, slot_index)
			if attack.is_empty():
				continue
			if not stage_started:
				stage_started = true
				engine._log("%s: ataques sequenciais." % stage_name)
				engine.visual_events.append({"type": "stage", "stage": stage_name, "label": stage_name})
			apply_stage_attacks(engine, stage_name, [attack], false)

static func build_staged_attack_if_valid(engine, stage_name: String, initiative_stage: bool, front_stage: bool, attacked_sources: Dictionary, owner_id: String, slot_index: int) -> Dictionary:
	var attacker: Dictionary = engine._slot_occupant(owner_id, slot_index)
	if attacker.is_empty() or bool(attacker.get("objective", false)):
		return {}
	if engine.board_format == BOARD_FORMAT_FRONT_REAR and slot_index >= 3:
		var own_slots: Array = engine._slots_for_owner(owner_id)
		var front_index: int = slot_index - 3
		if front_index >= 0 and front_index < own_slots.size() and own_slots[front_index] != null:
			return {}
	if bool(attacker.get("iniciativa", false)) != initiative_stage:
		return {}
	var source_key: String = engine._source_key(owner_id, slot_index)
	if attacked_sources.has(source_key):
		return {}
	var target: Dictionary = engine._front_attack_target(owner_id, slot_index) if front_stage else engine._overflow_attack_target(owner_id, slot_index)
	if front_stage and target.is_empty():
		return {}
	var preparation: Dictionary = prepare_staged_attacker(engine, owner_id, slot_index)
	if bool(preparation.get("consumed", false)):
		attacked_sources[source_key] = true
		var forced_target: Dictionary = Dictionary(preparation.get("target", {}))
		if not forced_target.is_empty():
			return build_attack_event(engine, stage_name, owner_id, slot_index, forced_target)
		return {}
	if target.is_empty():
		return {}
	attacked_sources[source_key] = true
	return build_attack_event(engine, stage_name, owner_id, slot_index, target)

static func prepare_staged_attacker(engine, owner_id: String, slot_index: int) -> Dictionary:
	var slots: Array = engine._slots_for_owner(owner_id)
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return {"can_attack": false}
	var occupant: Dictionary = Dictionary(slots[slot_index])
	if int(occupant.get("frozen_turns", 0)) > 0:
		occupant["frozen_turns"] = int(occupant.get("frozen_turns", 0)) - 1
		slots[slot_index] = occupant
		engine._set_slots_for_owner(owner_id, slots)
		engine._log("%s perdeu o ataque por Congelado." % str(occupant.get("name", "Criatura")))
		return {"can_attack": false, "consumed": true}
	if int(occupant.get("slow_turns", 0)) > 0:
		occupant["slow_turns"] = int(occupant.get("slow_turns", 0)) - 1
		slots[slot_index] = occupant
		engine._set_slots_for_owner(owner_id, slots)
		engine._log("%s perdeu o ataque por Lentidao." % str(occupant.get("name", "Criatura")))
		return {"can_attack": false, "consumed": true}
	if int(occupant.get("confusion_turns", 0)) > 0:
		occupant["confusion_turns"] = int(occupant.get("confusion_turns", 0)) - 1
		slots[slot_index] = occupant
		engine._set_slots_for_owner(owner_id, slots)
		var confused_target: Dictionary = engine._first_same_side_target(owner_id, slot_index)
		if not confused_target.is_empty():
			engine._log("%s atacou em Confusao." % str(occupant.get("name", "Criatura")))
			return {"can_attack": false, "consumed": true, "target": confused_target}
		return {"can_attack": false, "consumed": true}
	return {"can_attack": true}

static func apply_stage_attacks(engine, stage_name: String, attacks: Array[Dictionary], announce_stage: bool = true) -> void:
	if attacks.is_empty():
		return
	if announce_stage:
		engine._log("%s: %d ataque(s)." % [stage_name, attacks.size()])
		engine.visual_events.append({"type": "stage", "stage": stage_name, "label": stage_name})
	var damaged_slots: Array[Dictionary] = []
	for attack: Dictionary in attacks:
		var amount: int = int(attack.get("damage", 0))
		engine.visual_events.append(attack.duplicate(true))
		if bool(attack.get("target_hero", false)):
			var hero_owner: String = str(attack.get("target_owner", ENEMY_ID))
			damage_hero(engine, hero_owner, amount)
			apply_attack_success_keywords(engine, attack, {"damage_dealt": amount, "target_hero": true}, damaged_slots)
			engine._log("%s recebeu %d de dano." % [engine._hero_log_name(hero_owner), amount])
			engine.visual_events.append({"type": "damage", "stage": stage_name, "target_owner": hero_owner, "target_hero": true, "amount": amount, "health_after": engine.player_health if hero_owner == PLAYER_ID else engine.enemy_health})
			continue
		var target_owner: String = str(attack.get("target_owner", ENEMY_ID))
		var target_slot: int = int(attack.get("target_slot", -1))
		var damage_result: Dictionary = deal_slot_damage(engine, target_owner, target_slot, amount, {
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
		var event_index: int = engine.visual_events.size()
		engine.visual_events.append(damage_event)
		queue_damaged_slot(damaged_slots, target_owner, target_slot, event_index)
		engine._log("%s recebeu %d de dano." % [str(Dictionary(damage_result.get("occupant", {})).get("name", "Criatura")), int(damage_result.get("damage_dealt", 0))])
		apply_attack_success_keywords(engine, attack, damage_result, damaged_slots)
	for damaged: Dictionary in damaged_slots:
		var owner_id: String = str(damaged.get("owner", ""))
		var slot_index: int = int(damaged.get("slot", -1))
		var event_index: int = int(damaged.get("event_index", -1))
		var current: Dictionary = engine._slot_occupant(owner_id, slot_index)
		if current.is_empty():
			continue
		var result: Dictionary = store_or_destroy_lane_unit(engine, owner_id, slot_index, current)
		if event_index >= 0 and event_index < engine.visual_events.size():
			var event: Dictionary = Dictionary(engine.visual_events[event_index])
			event["destroyed"] = bool(result.get("destroyed", false))
			event["removed"] = bool(result.get("removed", false))
			if bool(result.get("revived", false)):
				event["replacement_occupant"] = Dictionary(result.get("occupant", {})).duplicate(true)
			engine.visual_events[event_index] = event
	engine._check_outcome()

static func queue_damaged_slot(damaged_slots: Array[Dictionary], owner_id: String, slot_index: int, event_index: int = -1) -> void:
	for existing: Dictionary in damaged_slots:
		if str(existing.get("owner", "")) == owner_id and int(existing.get("slot", -1)) == slot_index:
			if int(existing.get("event_index", -1)) < 0 and event_index >= 0:
				existing["event_index"] = event_index
			return
	damaged_slots.append({"owner": owner_id, "slot": slot_index, "event_index": event_index})

static func destroy_queued_damaged_slots(engine, damaged_slots: Array[Dictionary]) -> void:
	for damaged: Dictionary in damaged_slots:
		var owner_id: String = str(damaged.get("owner", ""))
		var slot_index: int = int(damaged.get("slot", -1))
		var current: Dictionary = engine._slot_occupant(owner_id, slot_index)
		if current.is_empty():
			continue
		store_or_destroy_lane_unit(engine, owner_id, slot_index, current)

static func apply_attack_success_keywords(engine, attack: Dictionary, damage_result: Dictionary, damaged_slots: Array[Dictionary]) -> void:
	var damage_dealt: int = int(damage_result.get("damage_dealt", 0))
	if damage_dealt <= 0:
		return
	var source_owner: String = str(attack.get("source_owner", ""))
	var source_slot: int = int(attack.get("source_slot", -1))
	var attacker: Dictionary = engine._slot_occupant(source_owner, source_slot)
	if attacker.is_empty():
		return
	engine._apply_drain(source_owner, int(attacker.get("drain_amount", 0)))
	if bool(attacker.get("veneno", false)) and not bool(damage_result.get("target_hero", false)):
		engine._apply_poison_to_slot(str(damage_result.get("target_owner", "")), int(damage_result.get("target_slot", -1)), int(attacker.get("poison_apply_amount", 1)))
	if bool(attacker.get("congelar", false)) and not bool(damage_result.get("target_hero", false)):
		engine._apply_freeze_to_slot(str(damage_result.get("target_owner", "")), int(damage_result.get("target_slot", -1)), 1)
	if bool(attacker.get("drenar_almas", false)) and not bool(damage_result.get("target_hero", false)) and int(damage_result.get("health_after", 1)) <= 0:
		var dead_attack: int = int(Dictionary(damage_result.get("occupant", {})).get("attack", 0))
		engine.bonus_souls += max(0, dead_attack)
		engine._log("%s drenou %d Alma(s)." % [str(attacker.get("name", "Criatura")), max(0, dead_attack)])
	if bool(attacker.get("brutal", false)) and not bool(damage_result.get("target_hero", false)) and str(attack.get("stage", "")).find("Frente") >= 0:
		apply_brutal_damage(engine, attack, damaged_slots)
	if bool(attacker.get("atropelar", false)) and not bool(damage_result.get("target_hero", false)) and int(damage_result.get("excess", 0)) > 0:
		apply_trample_damage(engine, attack, int(damage_result.get("excess", 0)), damaged_slots)
	if int(Dictionary(damage_result.get("occupant", {})).get("thorns_amount", 0)) > 0 and not bool(damage_result.get("target_hero", false)):
		apply_thorns_damage(engine, attack, damage_result, damaged_slots)
	if bool(attacker.get("ecoar", false)) and not bool(attacker.get("echo_used", false)):
		engine._mark_echo_used(source_owner, source_slot)
		apply_echo_damage(engine, attack, damage_dealt, damaged_slots)

static func apply_brutal_damage(engine, attack: Dictionary, damaged_slots: Array[Dictionary]) -> void:
	var target_owner: String = str(attack.get("target_owner", ""))
	var target_slot: int = int(attack.get("target_slot", -1))
	for adjacent_slot: int in [target_slot - 1, target_slot + 1]:
		var result: Dictionary = deal_slot_damage(engine, target_owner, adjacent_slot, 1, {
			"source_owner": str(attack.get("source_owner", "")),
			"source_slot": int(attack.get("source_slot", -1)),
			"source_kind": "combat",
			"defer_death": true
		})
		if result.is_empty():
			continue
		queue_damaged_slot(damaged_slots, target_owner, adjacent_slot, -1)

static func apply_trample_damage(engine, attack: Dictionary, excess: int, damaged_slots: Array[Dictionary]) -> void:
	var target: Dictionary = engine._trample_overflow_target(str(attack.get("source_owner", "")), int(attack.get("source_slot", -1)), str(attack.get("target_owner", "")), int(attack.get("target_slot", -1)))
	if target.is_empty():
		return
	if bool(target.get("hero", false)):
		damage_hero(engine, str(target.get("owner", "")), excess)
		engine._apply_drain(str(attack.get("source_owner", "")), int(engine._slot_occupant(str(attack.get("source_owner", "")), int(attack.get("source_slot", -1))).get("drain_amount", 0)))
		engine._log("Atropelar causou %d de dano excedente." % excess)
		return
	var result: Dictionary = deal_slot_damage(engine, str(target.get("owner", "")), int(target.get("slot", -1)), excess, {
		"source_owner": str(attack.get("source_owner", "")),
		"source_slot": int(attack.get("source_slot", -1)),
		"source_kind": "combat",
		"defer_death": true
	})
	if not result.is_empty():
		queue_damaged_slot(damaged_slots, str(target.get("owner", "")), int(target.get("slot", -1)), -1)
		engine._log("Atropelar causou %d de dano excedente." % int(result.get("damage_dealt", 0)))

static func apply_thorns_damage(engine, attack: Dictionary, damage_result: Dictionary, damaged_slots: Array[Dictionary]) -> void:
	var thorns: int = int(Dictionary(damage_result.get("occupant", {})).get("thorns_amount", 0))
	if thorns <= 0:
		return
	var source_owner: String = str(attack.get("source_owner", ""))
	var source_slot: int = int(attack.get("source_slot", -1))
	var result: Dictionary = deal_slot_damage(engine, source_owner, source_slot, thorns, {
		"source_kind": "combat",
		"defer_death": true,
		"bypass_resistance": true
	})
	if result.is_empty():
		return
	queue_damaged_slot(damaged_slots, source_owner, source_slot, -1)
	engine._log("Espinhos devolveu %d de dano." % int(result.get("damage_dealt", 0)))

static func apply_echo_damage(engine, attack: Dictionary, damage: int, damaged_slots: Array[Dictionary]) -> void:
	if damage <= 0:
		return
	if bool(attack.get("target_hero", false)):
		damage_hero(engine, str(attack.get("target_owner", "")), damage)
		engine._apply_drain(str(attack.get("source_owner", "")), int(engine._slot_occupant(str(attack.get("source_owner", "")), int(attack.get("source_slot", -1))).get("drain_amount", 0)))
		engine._log("Ecoar repetiu %d de dano." % damage)
		return
	var result: Dictionary = deal_slot_damage(engine, str(attack.get("target_owner", "")), int(attack.get("target_slot", -1)), damage, {
		"source_owner": str(attack.get("source_owner", "")),
		"source_slot": int(attack.get("source_slot", -1)),
		"source_kind": "combat",
		"defer_death": true
	})
	if result.is_empty():
		return
	queue_damaged_slot(damaged_slots, str(attack.get("target_owner", "")), int(attack.get("target_slot", -1)), -1)
	engine._log("Ecoar repetiu %d de dano." % int(result.get("damage_dealt", 0)))

static func build_attack_event(engine, stage_name: String, owner_id: String, slot_index: int, target: Dictionary) -> Dictionary:
	var attacker: Dictionary = engine._slot_occupant(owner_id, slot_index)
	var damage: int = int(attacker.get("attack", 0)) + engine._inspire_bonus_for(owner_id, slot_index) + engine._board_attack_bonus(owner_id, slot_index)
	var event: Dictionary = {
		"type": "attack",
		"stage": stage_name,
		"source_owner": owner_id,
		"source_slot": slot_index,
		"source_name": str(attacker.get("name", "Criatura")),
		"target_owner": str(target.get("owner", engine._opponent_id(owner_id))),
		"target_hero": bool(target.get("hero", false)),
		"target_name": engine._target_display_name(target),
		"damage": damage
	}
	if target.has("slot"):
		event["target_slot"] = int(target.get("slot", -1))
	return event

static func store_or_destroy_lane_unit(engine, owner_id: String, slot_index: int, occupant: Dictionary) -> Dictionary:
	var slots: Array = engine._slots_for_owner(owner_id)
	var result: Dictionary = {
		"destroyed": false,
		"removed": false,
		"revived": false,
		"occupant": occupant.duplicate(true)
	}
	if int(occupant.get("health", 0)) <= 0:
		engine._log("%s foi destruido." % str(occupant.get("name", "Criatura")))
		engine.dead_unit_count += 1
		var card_id: String = str(occupant.get("card_id", ""))
		var revived: Dictionary = engine._handle_unit_death(owner_id, occupant, true)
		if revived.is_empty() and owner_id == PLAYER_ID and card_id != "":
			engine.discard.append(card_id)
		slots[slot_index] = revived if not revived.is_empty() else null
		result["destroyed"] = true
		result["removed"] = revived.is_empty()
		result["revived"] = not revived.is_empty()
		result["occupant"] = revived.duplicate(true) if not revived.is_empty() else {}
	else:
		slots[slot_index] = occupant
		result["occupant"] = occupant.duplicate(true)
	engine._set_slots_for_owner(owner_id, slots)
	engine._recalculate_pact_bonuses(owner_id)
	return result

static func resolve_attack(engine, owner_id: String, slot_index: int, target: Dictionary) -> void:
	var slots: Array = engine._slots_for_owner(owner_id)
	var attacker: Dictionary = Dictionary(slots[slot_index])
	var damage: int = int(attacker.get("attack", 0)) + engine._inspire_bonus_for(owner_id, slot_index) + engine._board_attack_bonus(owner_id, slot_index)
	if bool(target.get("hero", false)):
		damage_hero(engine, str(target.get("owner", engine._opponent_id(owner_id))), damage)
		engine._log("%s atacou diretamente." % str(attacker.get("name", "Criatura")))
		return
	var target_owner: String = str(target.get("owner", engine._opponent_id(owner_id)))
	var target_slot: int = int(target.get("slot", -1))
	var damaged_slots: Array[Dictionary] = []
	var attack: Dictionary = build_attack_event(engine, "Ataque manual", owner_id, slot_index, target)
	var result: Dictionary = deal_slot_damage(engine, target_owner, target_slot, damage, {
		"source_owner": owner_id,
		"source_slot": slot_index,
		"source_kind": "combat",
		"defer_death": true
	})
	if not result.is_empty():
		queue_damaged_slot(damaged_slots, target_owner, target_slot, -1)
		apply_attack_success_keywords(engine, attack, result, damaged_slots)
		destroy_queued_damaged_slots(engine, damaged_slots)
	engine._log("%s atacou o slot %d." % [str(attacker.get("name", "Criatura")), target_slot + 1])

static func damage_slot(engine, owner_id: String, slot_index: int, amount: int, source_kind: String = "effect") -> void:
	deal_slot_damage(engine, owner_id, slot_index, amount, {"source_kind": source_kind})

static func deal_slot_damage(engine, owner_id: String, slot_index: int, amount: int, context: Dictionary = {}) -> Dictionary:
	var slots: Array = engine._slots_for_owner(owner_id)
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
			engine._remove_keyword_from_occupant(occupant, "escudo")
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
	engine._set_slots_for_owner(owner_id, slots)
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
		destroy_queued_damaged_slots(engine, [{"owner": owner_id, "slot": slot_index, "event_index": -1}])
	return result

static func damage_hero(engine, owner_id: String, amount: int) -> void:
	if owner_id == PLAYER_ID:
		engine.player_health = max(0, engine.player_health - amount)
	else:
		engine.enemy_health = max(0, engine.enemy_health - amount)
