extends RefCounted

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"

const COUNTER_FIELDS: Array[String] = [
	"summons_created",
	"player_units_delta",
	"enemy_units_delta",
	"enemy_hero_damage",
	"player_hero_damage",
	"enemy_slot_damage_total",
	"player_slot_damage_total",
	"ally_attack_buff_total",
	"ally_health_buff_total",
	"enemy_attack_debuff_total",
	"enemy_health_debuff_total",
	"poison_added_total",
	"freeze_added_total",
	"shield_added_total",
	"mana_gained",
	"ashes_gained",
	"cards_drawn",
	"cards_discarded",
	"pending_choices_delta",
	"log_added",
	"visual_events_added",
	"summoned_attack_total",
	"summoned_health_total"
]

static func snapshot_from_engine(engine) -> Dictionary:
	return {
		"player_health": int(engine.player_health),
		"enemy_health": int(engine.enemy_health),
		"mana": int(engine.mana),
		"ashes": int(engine.ashes),
		"hand_size": Array(engine.hand).size(),
		"deck_size": Array(engine.deck).size(),
		"discard_size": Array(engine.discard).size(),
		"pending_choice_count": Array(engine.pending_choices).size(),
		"log_count": Array(engine.log_lines).size(),
		"visual_event_count": Array(engine.visual_events).size(),
		"player_slots": _compact_slots(Array(engine.player_slots)),
		"enemy_slots": _compact_slots(Array(engine.enemy_slots))
	}

static func build_sample(card_id: String, target: Dictionary, before: Dictionary, after: Dictionary) -> Dictionary:
	var sample: Dictionary = _empty_signature(card_id)
	sample["target"] = target.duplicate(true)
	sample["target_owner"] = str(target.get("owner", ""))
	sample["target_slot"] = int(target.get("slot", -1)) if target.has("slot") else -1
	sample["target_hero"] = bool(target.get("hero", false))
	sample["enemy_hero_damage"] = maxi(0, int(before.get("enemy_health", 0)) - int(after.get("enemy_health", 0)))
	sample["player_hero_damage"] = maxi(0, int(before.get("player_health", 0)) - int(after.get("player_health", 0)))
	sample["mana_gained"] = maxi(0, int(after.get("mana", 0)) - int(before.get("mana", 0)))
	sample["ashes_gained"] = maxi(0, int(after.get("ashes", 0)) - int(before.get("ashes", 0)))
	sample["cards_drawn"] = maxi(0, int(before.get("deck_size", 0)) - int(after.get("deck_size", 0)))
	sample["cards_discarded"] = maxi(0, int(after.get("discard_size", 0)) - int(before.get("discard_size", 0)) - 1)
	sample["pending_choices_delta"] = int(after.get("pending_choice_count", 0)) - int(before.get("pending_choice_count", 0))
	sample["log_added"] = maxi(0, int(after.get("log_count", 0)) - int(before.get("log_count", 0)))
	sample["visual_events_added"] = maxi(0, int(after.get("visual_event_count", 0)) - int(before.get("visual_event_count", 0)))
	_apply_slot_delta(sample, PLAYER_ID, Array(before.get("player_slots", [])), Array(after.get("player_slots", [])))
	_apply_slot_delta(sample, ENEMY_ID, Array(before.get("enemy_slots", [])), Array(after.get("enemy_slots", [])))
	sample["families"] = _families_for(sample)
	return sample

static func aggregate(card_id: String, samples: Array) -> Dictionary:
	var signature: Dictionary = _empty_signature(card_id)
	signature["present"] = not samples.is_empty()
	signature["sample_count"] = samples.size()
	var keyword_added: Dictionary = {}
	var keyword_removed: Dictionary = {}
	for sample_value: Variant in samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue
		var sample: Dictionary = Dictionary(sample_value)
		for field: String in COUNTER_FIELDS:
			signature[field] = int(signature.get(field, 0)) + int(sample.get(field, 0))
		_merge_counts(keyword_added, Dictionary(sample.get("keywords_added", {})))
		_merge_counts(keyword_removed, Dictionary(sample.get("keywords_removed", {})))
	signature["keywords_added"] = keyword_added
	signature["keywords_removed"] = keyword_removed
	signature["families"] = _families_for(signature)
	return signature

static func empty_missing(card_id: String, reason: String) -> Dictionary:
	var signature: Dictionary = _empty_signature(card_id)
	signature["present"] = false
	signature["missing_reason"] = reason
	return signature

static func _empty_signature(card_id: String) -> Dictionary:
	var signature: Dictionary = {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"target_owner": "",
		"target_slot": -1,
		"target_hero": false,
		"keywords_added": {},
		"keywords_removed": {},
		"families": []
	}
	for field: String in COUNTER_FIELDS:
		signature[field] = 0
	return signature

static func _compact_slots(slots: Array) -> Array:
	var result: Array = []
	for slot_value: Variant in slots:
		if typeof(slot_value) != TYPE_DICTIONARY:
			result.append(null)
			continue
		var occupant: Dictionary = Dictionary(slot_value)
		result.append({
			"card_id": str(occupant.get("card_id", "")),
			"name": str(occupant.get("name", "")),
			"attack": int(occupant.get("attack", 0)),
			"health": int(occupant.get("health", 0)),
			"max_health": int(occupant.get("max_health", 0)),
			"keywords": Array(occupant.get("keywords", [])).duplicate(),
			"poison_amount": int(occupant.get("poison_amount", 0)),
			"frozen_turns": int(occupant.get("frozen_turns", 0)),
			"shield_charges": int(occupant.get("shield_charges", 0))
		})
	return result

static func _apply_slot_delta(signature: Dictionary, owner_id: String, before_slots: Array, after_slots: Array) -> void:
	var limit: int = maxi(before_slots.size(), after_slots.size())
	var before_alive: int = _occupied_count(before_slots)
	var after_alive: int = _occupied_count(after_slots)
	if owner_id == PLAYER_ID:
		signature["player_units_delta"] = after_alive - before_alive
	else:
		signature["enemy_units_delta"] = after_alive - before_alive
	for index: int in range(limit):
		var before_slot: Variant = before_slots[index] if index < before_slots.size() else null
		var after_slot: Variant = after_slots[index] if index < after_slots.size() else null
		var before_occupant: Dictionary = Dictionary(before_slot) if typeof(before_slot) == TYPE_DICTIONARY else {}
		var after_occupant: Dictionary = Dictionary(after_slot) if typeof(after_slot) == TYPE_DICTIONARY else {}
		if before_occupant.is_empty() and after_occupant.is_empty():
			continue
		if before_occupant.is_empty() and not after_occupant.is_empty():
			if owner_id == PLAYER_ID:
				signature["summons_created"] = int(signature.get("summons_created", 0)) + 1
				signature["summoned_attack_total"] = int(signature.get("summoned_attack_total", 0)) + int(after_occupant.get("attack", 0))
				signature["summoned_health_total"] = int(signature.get("summoned_health_total", 0)) + int(after_occupant.get("max_health", after_occupant.get("health", 0)))
				_add_keyword_delta(signature, "keywords_added", Array(after_occupant.get("keywords", [])), [])
			continue
		if not before_occupant.is_empty() and after_occupant.is_empty():
			if owner_id == ENEMY_ID:
				signature["enemy_slot_damage_total"] = int(signature.get("enemy_slot_damage_total", 0)) + maxi(0, int(before_occupant.get("health", 0)))
			else:
				signature["player_slot_damage_total"] = int(signature.get("player_slot_damage_total", 0)) + maxi(0, int(before_occupant.get("health", 0)))
			continue
		if str(before_occupant.get("card_id", "")) != str(after_occupant.get("card_id", "")):
			continue
		_apply_existing_slot_delta(signature, owner_id, before_occupant, after_occupant)

static func _apply_existing_slot_delta(signature: Dictionary, owner_id: String, before_occupant: Dictionary, after_occupant: Dictionary) -> void:
	var health_delta: int = int(after_occupant.get("health", 0)) - int(before_occupant.get("health", 0))
	var max_health_delta: int = int(after_occupant.get("max_health", 0)) - int(before_occupant.get("max_health", 0))
	var attack_delta: int = int(after_occupant.get("attack", 0)) - int(before_occupant.get("attack", 0))
	if owner_id == ENEMY_ID:
		signature["enemy_slot_damage_total"] = int(signature.get("enemy_slot_damage_total", 0)) + maxi(0, -health_delta)
		signature["enemy_attack_debuff_total"] = int(signature.get("enemy_attack_debuff_total", 0)) + maxi(0, -attack_delta)
		signature["enemy_health_debuff_total"] = int(signature.get("enemy_health_debuff_total", 0)) + maxi(0, -max_health_delta)
	else:
		signature["player_slot_damage_total"] = int(signature.get("player_slot_damage_total", 0)) + maxi(0, -health_delta)
		signature["ally_attack_buff_total"] = int(signature.get("ally_attack_buff_total", 0)) + maxi(0, attack_delta)
		signature["ally_health_buff_total"] = int(signature.get("ally_health_buff_total", 0)) + maxi(0, max_health_delta)
	signature["poison_added_total"] = int(signature.get("poison_added_total", 0)) + maxi(0, int(after_occupant.get("poison_amount", 0)) - int(before_occupant.get("poison_amount", 0)))
	signature["freeze_added_total"] = int(signature.get("freeze_added_total", 0)) + maxi(0, int(after_occupant.get("frozen_turns", 0)) - int(before_occupant.get("frozen_turns", 0)))
	signature["shield_added_total"] = int(signature.get("shield_added_total", 0)) + maxi(0, int(after_occupant.get("shield_charges", 0)) - int(before_occupant.get("shield_charges", 0)))
	_add_keyword_delta(signature, "keywords_added", Array(after_occupant.get("keywords", [])), Array(before_occupant.get("keywords", [])))
	_add_keyword_delta(signature, "keywords_removed", Array(before_occupant.get("keywords", [])), Array(after_occupant.get("keywords", [])))

static func _add_keyword_delta(signature: Dictionary, key: String, source: Array, existing: Array) -> void:
	var counts: Dictionary = Dictionary(signature.get(key, {}))
	for keyword_value: Variant in source:
		var keyword: String = str(keyword_value)
		if keyword == "" or existing.has(keyword):
			continue
		counts[keyword] = int(counts.get(keyword, 0)) + 1
	signature[key] = counts

static func _families_for(signature: Dictionary) -> Array[String]:
	var families: Array[String] = []
	if int(signature.get("enemy_hero_damage", 0)) > 0 or int(signature.get("enemy_slot_damage_total", 0)) > 0:
		families.append("damage")
	if int(signature.get("summons_created", 0)) > 0:
		families.append("summon")
	if int(signature.get("ally_attack_buff_total", 0)) > 0 or int(signature.get("ally_health_buff_total", 0)) > 0 or int(signature.get("shield_added_total", 0)) > 0:
		families.append("buff")
	if int(signature.get("enemy_attack_debuff_total", 0)) > 0 or int(signature.get("enemy_health_debuff_total", 0)) > 0:
		families.append("debuff")
	if int(signature.get("poison_added_total", 0)) > 0 or int(signature.get("freeze_added_total", 0)) > 0:
		families.append("control")
	if int(signature.get("mana_gained", 0)) > 0 or int(signature.get("ashes_gained", 0)) > 0 or int(signature.get("cards_drawn", 0)) > 0:
		families.append("economy")
	if not Dictionary(signature.get("keywords_added", {})).is_empty() or not Dictionary(signature.get("keywords_removed", {})).is_empty():
		families.append("keyword")
	if int(signature.get("pending_choices_delta", 0)) != 0:
		families.append("choice")
	if families.is_empty() and bool(signature.get("present", false)):
		families.append("played")
	return families

static func _occupied_count(slots: Array) -> int:
	var count: int = 0
	for slot_value: Variant in slots:
		if typeof(slot_value) == TYPE_DICTIONARY:
			count += 1
	return count

static func _merge_counts(target: Dictionary, source: Dictionary) -> void:
	for key: Variant in source.keys():
		target[str(key)] = int(target.get(str(key), 0)) + int(source.get(key, 0))
