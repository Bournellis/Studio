extends RefCounted

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"

const COUNTER_FIELDS: Array[String] = [
	"summons_created",
	"summoned_count",
	"summoned_slot_count",
	"summoned_keyword_count",
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
	"ally_keyword_gain_count",
	"ally_shield_gain",
	"ally_resistance_gain",
	"enemy_keyword_loss_count",
	"poison_added_total",
	"enemy_poison_added",
	"freeze_added_total",
	"enemy_frozen_added",
	"enemy_snared_added",
	"enemy_slow_added",
	"shield_added_total",
	"mana_gained",
	"temporary_ability_power_delta",
	"temporary_ability_power_gained",
	"temporary_ability_power_lost",
	"ashes_gained",
	"cards_drawn",
	"cards_discarded",
	"cards_created",
	"deck_delta",
	"hand_delta",
	"discard_delta",
	"pending_choices_delta",
	"pending_choice_created",
	"pending_choice_resolved",
	"sacrifice_required",
	"sacrifice_consumed",
	"sacrifice_units_destroyed",
	"log_added",
	"visual_events_added",
	"summoned_attack_total",
	"summoned_health_total",
	"enemy_card_play_count",
	"enemy_summons_created",
	"enemy_summoned_count",
	"enemy_summoned_attack_total",
	"enemy_summoned_health_total",
	"enemy_summoned_keyword_count",
	"enemy_damage_to_player_hero",
	"enemy_damage_to_player_slots",
	"enemy_player_units_delta",
	"enemy_combat_damage_to_player_hero",
	"enemy_combat_damage_to_player_slots",
	"support_card_count_before_target",
	"support_card_count_after_target"
]

static func snapshot_from_engine(engine) -> Dictionary:
	var engine_state: Dictionary = engine.get_state() if engine.has_method("get_state") else {}
	return {
		"player_health": int(engine.player_health),
		"enemy_health": int(engine.enemy_health),
		"mana": int(engine.mana),
		"ashes": int(engine.ashes),
		"ability_power": int(engine_state.get("ability_power", 0)),
		"temporary_ability_power": int(engine_state.get("temporary_ability_power", 0)),
		"dead_unit_count": int(engine_state.get("dead_unit_count", 0)),
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
	var temporary_ability_power_delta: int = int(after.get("temporary_ability_power", 0)) - int(before.get("temporary_ability_power", 0))
	sample["temporary_ability_power_delta"] = temporary_ability_power_delta
	sample["temporary_ability_power_gained"] = maxi(0, temporary_ability_power_delta)
	sample["temporary_ability_power_lost"] = maxi(0, -temporary_ability_power_delta)
	sample["ashes_gained"] = maxi(0, int(after.get("ashes", 0)) - int(before.get("ashes", 0)))
	sample["cards_drawn"] = maxi(0, int(before.get("deck_size", 0)) - int(after.get("deck_size", 0)))
	sample["cards_discarded"] = maxi(0, int(after.get("discard_size", 0)) - int(before.get("discard_size", 0)) - 1)
	sample["deck_delta"] = int(after.get("deck_size", 0)) - int(before.get("deck_size", 0))
	sample["hand_delta"] = int(after.get("hand_size", 0)) - int(before.get("hand_size", 0))
	sample["discard_delta"] = int(after.get("discard_size", 0)) - int(before.get("discard_size", 0))
	if int(sample["hand_delta"]) > 0 and int(sample["deck_delta"]) >= 0:
		sample["cards_created"] = int(sample["hand_delta"])
	sample["pending_choices_delta"] = int(after.get("pending_choice_count", 0)) - int(before.get("pending_choice_count", 0))
	sample["pending_choice_created"] = maxi(0, int(sample["pending_choices_delta"]))
	sample["pending_choice_resolved"] = maxi(0, -int(sample["pending_choices_delta"]))
	sample["log_added"] = maxi(0, int(after.get("log_count", 0)) - int(before.get("log_count", 0)))
	sample["visual_events_added"] = maxi(0, int(after.get("visual_event_count", 0)) - int(before.get("visual_event_count", 0)))
	_apply_slot_delta(sample, PLAYER_ID, Array(before.get("player_slots", [])), Array(after.get("player_slots", [])))
	_apply_slot_delta(sample, ENEMY_ID, Array(before.get("enemy_slots", [])), Array(after.get("enemy_slots", [])))
	apply_card_flow_quality(sample)
	sample["families"] = _families_for(sample)
	_update_signature_quality(sample)
	return sample

static func build_enemy_play_sample(card_id: String, before: Dictionary, after_play: Dictionary) -> Dictionary:
	var sample: Dictionary = _empty_signature(card_id)
	sample["enemy_card_played"] = true
	sample["enemy_card_play_count"] = 1
	sample["enemy_signature_phase"] = "play"
	sample["enemy_signature_confidence"] = "clean"
	sample["support_contamination_status"] = "clean"
	sample["signature_confidence"] = "clean"
	sample["capture_quality"] = "clean"
	sample["enemy_damage_to_player_hero"] = maxi(0, int(before.get("player_health", 0)) - int(after_play.get("player_health", 0)))
	sample["enemy_damage_to_player_slots"] = _slot_damage_between(Array(before.get("player_slots", [])), Array(after_play.get("player_slots", [])))
	sample["enemy_player_units_delta"] = _occupied_count(Array(after_play.get("player_slots", []))) - _occupied_count(Array(before.get("player_slots", [])))
	_apply_enemy_summon_delta(sample, card_id, Array(before.get("enemy_slots", [])), Array(after_play.get("enemy_slots", [])))
	sample["families"] = _families_for(sample)
	return sample

static func build_enemy_combat_sample(card_id: String, after_play: Dictionary, after_combat: Dictionary) -> Dictionary:
	var sample: Dictionary = _empty_signature(card_id)
	sample["enemy_signature_phase"] = "combat"
	sample["enemy_signature_confidence"] = "clean"
	sample["support_contamination_status"] = "clean"
	sample["signature_confidence"] = "clean"
	sample["capture_quality"] = "clean"
	sample["enemy_combat_damage_to_player_hero"] = maxi(0, int(after_play.get("player_health", 0)) - int(after_combat.get("player_health", 0)))
	sample["enemy_combat_damage_to_player_slots"] = _slot_damage_between(Array(after_play.get("player_slots", [])), Array(after_combat.get("player_slots", [])))
	sample["enemy_damage_to_player_hero"] = int(sample.get("enemy_combat_damage_to_player_hero", 0))
	sample["enemy_damage_to_player_slots"] = int(sample.get("enemy_combat_damage_to_player_slots", 0))
	sample["enemy_player_units_delta"] = _occupied_count(Array(after_combat.get("player_slots", []))) - _occupied_count(Array(after_play.get("player_slots", [])))
	sample["families"] = _families_for(sample)
	return sample

static func aggregate(card_id: String, samples: Array) -> Dictionary:
	var signature: Dictionary = _empty_signature(card_id)
	signature["present"] = not samples.is_empty()
	signature["sample_count"] = samples.size()
	var keyword_added: Dictionary = {}
	var keyword_removed: Dictionary = {}
	var enemy_keyword_added: Dictionary = {}
	var has_enemy_play: bool = false
	var has_enemy_combat: bool = false
	for sample_value: Variant in samples:
		if typeof(sample_value) != TYPE_DICTIONARY:
			continue
		var sample: Dictionary = Dictionary(sample_value)
		for field: String in COUNTER_FIELDS:
			signature[field] = int(signature.get(field, 0)) + int(sample.get(field, 0))
		_merge_counts(keyword_added, Dictionary(sample.get("keywords_added", {})))
		_merge_counts(keyword_removed, Dictionary(sample.get("keywords_removed", {})))
		_merge_counts(enemy_keyword_added, Dictionary(sample.get("enemy_keywords_added", {})))
		if bool(sample.get("enemy_card_played", false)):
			signature["enemy_card_played"] = true
			has_enemy_play = true
		var enemy_phase: String = str(sample.get("enemy_signature_phase", ""))
		if enemy_phase == "play":
			has_enemy_play = true
		elif enemy_phase == "combat":
			has_enemy_combat = true
		elif enemy_phase == "play_plus_combat":
			has_enemy_play = true
			has_enemy_combat = true
		_merge_unique_strings(signature["support_cards_before_target"], sample.get("support_cards_before_target", []))
		_merge_unique_strings(signature["support_cards_after_target"], sample.get("support_cards_after_target", []))
		var focused_index: int = int(sample.get("focused_card_play_index", -1))
		if focused_index >= 0 and (int(signature.get("focused_card_play_index", -1)) < 0 or focused_index < int(signature.get("focused_card_play_index", -1))):
			signature["focused_card_play_index"] = focused_index
		if str(sample.get("support_contamination_status", "")) == "support_assisted":
			signature["support_contamination_status"] = "support_assisted"
		if str(sample.get("signature_confidence", "")) == "ambiguous":
			signature["signature_confidence"] = "ambiguous"
		if bool(sample.get("card_flow_expected", false)):
			signature["card_flow_expected"] = true
		if bool(sample.get("card_flow_observed", false)):
			signature["card_flow_observed"] = true
		var card_flow_reason: String = str(sample.get("card_flow_missing_reason", ""))
		if card_flow_reason != "":
			signature["card_flow_missing_reason"] = card_flow_reason if str(signature.get("card_flow_missing_reason", "")) == "" else "%s; %s" % [str(signature.get("card_flow_missing_reason", "")), card_flow_reason]
		var ambiguous_reason: String = str(sample.get("ambiguous_reason", sample.get("signature_ambiguous_reason", "")))
		if ambiguous_reason != "":
			var existing_reason: String = str(signature.get("ambiguous_reason", ""))
			signature["ambiguous_reason"] = ambiguous_reason if existing_reason == "" else "%s; %s" % [existing_reason, ambiguous_reason]
	signature["keywords_added"] = keyword_added
	signature["keywords_removed"] = keyword_removed
	signature["enemy_keywords_added"] = enemy_keyword_added
	if has_enemy_play and has_enemy_combat:
		signature["enemy_signature_phase"] = "play_plus_combat"
	elif has_enemy_play:
		signature["enemy_signature_phase"] = "play"
	elif has_enemy_combat:
		signature["enemy_signature_phase"] = "combat"
	if bool(signature.get("enemy_card_played", false)) or int(signature.get("enemy_card_play_count", 0)) > 0:
		signature["enemy_signature_confidence"] = "clean"
	apply_card_flow_quality(signature)
	_update_signature_quality(signature)
	signature["families"] = _families_for(signature)
	return signature

static func empty_missing(card_id: String, reason: String) -> Dictionary:
	var signature: Dictionary = _empty_signature(card_id)
	signature["present"] = false
	signature["sample_count"] = 0
	signature["missing_reason"] = reason
	signature["support_contamination_status"] = "missing"
	signature["signature_confidence"] = "missing"
	signature["enemy_signature_confidence"] = "missing"
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
		"enemy_keywords_added": {},
		"families": [],
		"enemy_card_played": false,
		"enemy_signature_phase": "",
		"enemy_signature_confidence": "none",
		"focused_card_play_index": -1,
		"target_card_play_count": 0,
		"target_card_first_play_turn": -1,
		"target_card_first_play_cycle": -1,
		"stopped_after_target": false,
		"target_capture_mode": "",
		"capture_quality": "none",
		"ambiguity_reasons": [],
		"support_cards_before_target": [],
		"support_cards_after_target": [],
		"support_contamination_status": "none",
		"signature_confidence": "none",
		"ambiguous_reason": "",
		"card_flow_expected": false,
		"card_flow_observed": false,
		"card_flow_missing_reason": ""
	}
	for field: String in COUNTER_FIELDS:
		signature[field] = 0
	return signature

static func apply_card_flow_quality(signature: Dictionary) -> void:
	var expected: bool = bool(signature.get("card_flow_expected", false))
	var explicit_flow: bool = (
		int(signature.get("cards_drawn", 0)) > 0
		or int(signature.get("cards_discarded", 0)) > 0
		or int(signature.get("cards_created", 0)) > 0
	)
	var expected_deck_shift: bool = expected and int(signature.get("deck_delta", 0)) != 0
	var observed: bool = bool(signature.get("card_flow_observed", false)) or explicit_flow or expected_deck_shift
	signature["card_flow_observed"] = observed
	if expected and not observed:
		signature["card_flow_missing_reason"] = "expected card-flow counters were not observed"
	elif observed:
		signature["card_flow_missing_reason"] = ""

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
			"slow_turns": int(occupant.get("slow_turns", 0)),
			"curse_turns": int(occupant.get("curse_turns", 0)),
			"confusion_turns": int(occupant.get("confusion_turns", 0)),
			"shield_charges": int(occupant.get("shield_charges", 0)),
			"resistance_amount": int(occupant.get("resistance_amount", 0)),
			"resistance_remaining": int(occupant.get("resistance_remaining", 0))
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
				signature["summoned_count"] = int(signature.get("summoned_count", 0)) + 1
				signature["summoned_slot_count"] = int(signature.get("summoned_slot_count", 0)) + 1
				signature["summoned_attack_total"] = int(signature.get("summoned_attack_total", 0)) + int(after_occupant.get("attack", 0))
				signature["summoned_health_total"] = int(signature.get("summoned_health_total", 0)) + int(after_occupant.get("max_health", after_occupant.get("health", 0)))
				var summon_keywords: Array = Array(after_occupant.get("keywords", []))
				signature["summoned_keyword_count"] = int(signature.get("summoned_keyword_count", 0)) + summon_keywords.size()
				_add_keyword_delta(signature, "keywords_added", summon_keywords, [])
			continue
		if not before_occupant.is_empty() and after_occupant.is_empty():
			if owner_id == ENEMY_ID:
				signature["enemy_slot_damage_total"] = int(signature.get("enemy_slot_damage_total", 0)) + maxi(0, int(before_occupant.get("health", 0)))
			else:
				signature["player_slot_damage_total"] = int(signature.get("player_slot_damage_total", 0)) + maxi(0, int(before_occupant.get("health", 0)))
				signature["sacrifice_units_destroyed"] = int(signature.get("sacrifice_units_destroyed", 0)) + 1
			continue
		if str(before_occupant.get("card_id", "")) != str(after_occupant.get("card_id", "")):
			continue
		_apply_existing_slot_delta(signature, owner_id, before_occupant, after_occupant)

static func _apply_enemy_summon_delta(signature: Dictionary, card_id: String, before_slots: Array, after_slots: Array) -> void:
	var limit: int = maxi(before_slots.size(), after_slots.size())
	for index: int in range(limit):
		var before_slot: Variant = before_slots[index] if index < before_slots.size() else null
		var after_slot: Variant = after_slots[index] if index < after_slots.size() else null
		if typeof(before_slot) == TYPE_DICTIONARY or typeof(after_slot) != TYPE_DICTIONARY:
			continue
		var after_occupant: Dictionary = Dictionary(after_slot)
		if str(after_occupant.get("card_id", "")) != card_id:
			continue
		signature["enemy_summons_created"] = int(signature.get("enemy_summons_created", 0)) + 1
		signature["enemy_summoned_count"] = int(signature.get("enemy_summoned_count", 0)) + 1
		signature["enemy_summoned_attack_total"] = int(signature.get("enemy_summoned_attack_total", 0)) + int(after_occupant.get("attack", 0))
		signature["enemy_summoned_health_total"] = int(signature.get("enemy_summoned_health_total", 0)) + int(after_occupant.get("max_health", after_occupant.get("health", 0)))
		var keywords: Array = Array(after_occupant.get("keywords", []))
		signature["enemy_summoned_keyword_count"] = int(signature.get("enemy_summoned_keyword_count", 0)) + keywords.size()
		_add_keyword_delta(signature, "enemy_keywords_added", keywords, [])

static func _slot_damage_between(before_slots: Array, after_slots: Array) -> int:
	var total: int = 0
	var limit: int = maxi(before_slots.size(), after_slots.size())
	for index: int in range(limit):
		var before_slot: Variant = before_slots[index] if index < before_slots.size() else null
		var after_slot: Variant = after_slots[index] if index < after_slots.size() else null
		var before_occupant: Dictionary = Dictionary(before_slot) if typeof(before_slot) == TYPE_DICTIONARY else {}
		var after_occupant: Dictionary = Dictionary(after_slot) if typeof(after_slot) == TYPE_DICTIONARY else {}
		if before_occupant.is_empty():
			continue
		if after_occupant.is_empty() or str(before_occupant.get("card_id", "")) != str(after_occupant.get("card_id", "")):
			total += maxi(0, int(before_occupant.get("health", 0)))
		else:
			total += maxi(0, int(before_occupant.get("health", 0)) - int(after_occupant.get("health", 0)))
	return total

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
	var poison_delta: int = maxi(0, int(after_occupant.get("poison_amount", 0)) - int(before_occupant.get("poison_amount", 0)))
	var freeze_delta: int = maxi(0, int(after_occupant.get("frozen_turns", 0)) - int(before_occupant.get("frozen_turns", 0)))
	var shield_delta: int = maxi(0, int(after_occupant.get("shield_charges", 0)) - int(before_occupant.get("shield_charges", 0)))
	var slow_delta: int = maxi(0, int(after_occupant.get("slow_turns", 0)) - int(before_occupant.get("slow_turns", 0)))
	var resistance_delta: int = maxi(
		int(after_occupant.get("resistance_amount", 0)) - int(before_occupant.get("resistance_amount", 0)),
		int(after_occupant.get("resistance_remaining", 0)) - int(before_occupant.get("resistance_remaining", 0))
	)
	signature["poison_added_total"] = int(signature.get("poison_added_total", 0)) + poison_delta
	signature["freeze_added_total"] = int(signature.get("freeze_added_total", 0)) + freeze_delta
	signature["shield_added_total"] = int(signature.get("shield_added_total", 0)) + shield_delta
	var before_keywords: Array = Array(before_occupant.get("keywords", []))
	var after_keywords: Array = Array(after_occupant.get("keywords", []))
	var added_keywords: Array = _keyword_delta_list(after_keywords, before_keywords)
	var removed_keywords: Array = _keyword_delta_list(before_keywords, after_keywords)
	_add_keyword_delta(signature, "keywords_added", after_keywords, before_keywords)
	_add_keyword_delta(signature, "keywords_removed", before_keywords, after_keywords)
	if owner_id == PLAYER_ID:
		signature["ally_keyword_gain_count"] = int(signature.get("ally_keyword_gain_count", 0)) + added_keywords.size()
		signature["ally_shield_gain"] = int(signature.get("ally_shield_gain", 0)) + shield_delta
		if resistance_delta > 0:
			signature["ally_resistance_gain"] = int(signature.get("ally_resistance_gain", 0)) + resistance_delta
		if added_keywords.has("resistencia"):
			signature["ally_resistance_gain"] = int(signature.get("ally_resistance_gain", 0)) + 1
	else:
		signature["enemy_keyword_loss_count"] = int(signature.get("enemy_keyword_loss_count", 0)) + removed_keywords.size()
		signature["enemy_poison_added"] = int(signature.get("enemy_poison_added", 0)) + poison_delta
		signature["enemy_frozen_added"] = int(signature.get("enemy_frozen_added", 0)) + freeze_delta
		signature["enemy_snared_added"] = int(signature.get("enemy_snared_added", 0)) + slow_delta
		signature["enemy_slow_added"] = int(signature.get("enemy_slow_added", 0)) + slow_delta

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
	if int(signature.get("summons_created", 0)) > 0 or int(signature.get("summoned_count", 0)) > 0:
		families.append("summon")
	if (
		int(signature.get("ally_attack_buff_total", 0)) > 0
		or int(signature.get("ally_health_buff_total", 0)) > 0
		or int(signature.get("shield_added_total", 0)) > 0
		or int(signature.get("ally_keyword_gain_count", 0)) > 0
		or int(signature.get("ally_shield_gain", 0)) > 0
		or int(signature.get("ally_resistance_gain", 0)) > 0
	):
		families.append("buff")
	if int(signature.get("enemy_attack_debuff_total", 0)) > 0 or int(signature.get("enemy_health_debuff_total", 0)) > 0:
		families.append("debuff")
	if (
		int(signature.get("poison_added_total", 0)) > 0
		or int(signature.get("freeze_added_total", 0)) > 0
		or int(signature.get("enemy_poison_added", 0)) > 0
		or int(signature.get("enemy_frozen_added", 0)) > 0
		or int(signature.get("enemy_snared_added", 0)) > 0
	):
		families.append("control")
	if (
		int(signature.get("mana_gained", 0)) > 0
		or int(signature.get("ashes_gained", 0)) > 0
		or int(signature.get("cards_drawn", 0)) > 0
		or int(signature.get("cards_discarded", 0)) > 0
		or int(signature.get("cards_created", 0)) > 0
		or int(signature.get("deck_delta", 0)) != 0
		or int(signature.get("hand_delta", 0)) != 0
		or int(signature.get("discard_delta", 0)) != 0
	):
		families.append("economy")
	if bool(signature.get("card_flow_observed", false)):
		families.append("card_flow")
	if (
		int(signature.get("temporary_ability_power_delta", 0)) != 0
		or int(signature.get("temporary_ability_power_gained", 0)) > 0
		or int(signature.get("temporary_ability_power_lost", 0)) > 0
	):
		families.append("utility")
	if not Dictionary(signature.get("keywords_added", {})).is_empty() or not Dictionary(signature.get("keywords_removed", {})).is_empty():
		families.append("keyword")
	if int(signature.get("enemy_summons_created", 0)) > 0 or int(signature.get("enemy_summoned_count", 0)) > 0:
		families.append("enemy_summon")
	if int(signature.get("enemy_summoned_attack_total", 0)) > 0 or int(signature.get("enemy_summoned_health_total", 0)) > 0:
		families.append("enemy_stat")
	if int(signature.get("enemy_summoned_keyword_count", 0)) > 0 or not Dictionary(signature.get("enemy_keywords_added", {})).is_empty():
		families.append("enemy_keyword")
	if (
		int(signature.get("enemy_damage_to_player_hero", 0)) > 0
		or int(signature.get("enemy_damage_to_player_slots", 0)) > 0
		or int(signature.get("enemy_combat_damage_to_player_hero", 0)) > 0
		or int(signature.get("enemy_combat_damage_to_player_slots", 0)) > 0
		or int(signature.get("enemy_player_units_delta", 0)) < 0
	):
		families.append("enemy_combat_damage")
	if (
		int(signature.get("pending_choices_delta", 0)) != 0
		or int(signature.get("pending_choice_created", 0)) > 0
		or int(signature.get("pending_choice_resolved", 0)) > 0
		or int(signature.get("sacrifice_required", 0)) > 0
		or int(signature.get("sacrifice_consumed", 0)) > 0
		or int(signature.get("sacrifice_units_destroyed", 0)) > 0
	):
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

static func _merge_unique_strings(target: Array, source: Variant) -> void:
	if typeof(source) != TYPE_ARRAY:
		return
	for value: Variant in Array(source):
		var text: String = str(value)
		if text != "" and not target.has(text):
			target.append(text)

static func _keyword_delta_list(primary: Array, baseline: Array) -> Array:
	var delta: Array = []
	for keyword_value: Variant in primary:
		var keyword: String = str(keyword_value)
		if keyword != "" and not baseline.has(keyword):
			delta.append(keyword)
	return delta

static func _update_signature_quality(signature: Dictionary) -> void:
	var before_cards: Array = Array(signature.get("support_cards_before_target", []))
	var after_cards: Array = Array(signature.get("support_cards_after_target", []))
	var support_before_count: int = maxi(int(signature.get("support_card_count_before_target", 0)), before_cards.size())
	var support_after_count: int = maxi(int(signature.get("support_card_count_after_target", 0)), after_cards.size())
	signature["support_card_count_before_target"] = support_before_count
	signature["support_card_count_after_target"] = support_after_count
	if support_before_count > 0:
		signature["support_contamination_status"] = "support_assisted"
		if str(signature.get("signature_confidence", "")) in ["", "none", "clean"]:
			signature["signature_confidence"] = "support_assisted"
		if str(signature.get("ambiguous_reason", "")) == "":
			signature["ambiguous_reason"] = "support cards were played before the focused card"
	elif int(signature.get("sample_count", 0)) > 0:
		signature["support_contamination_status"] = "clean"
		if str(signature.get("signature_confidence", "")) in ["", "none"]:
			signature["signature_confidence"] = "clean"
	if int(signature.get("sample_count", 0)) > 1:
		signature["signature_confidence"] = "ambiguous"
		if str(signature.get("ambiguous_reason", "")) == "":
			signature["ambiguous_reason"] = "multiple focused-card samples were captured"
