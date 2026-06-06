extends RefCounted

const STATUS_BLOCKED: String = "blocked"
const STATUS_BROKEN: String = "broken"
const STATUS_RECOMMENDED: String = "recommended"
const STATUS_VIABLE: String = "viable"
const STATUS_RISKY: String = "risky"
const STATUS_WEAK: String = "weak"

static func score_variants(variants: Array[Dictionary], records: Array[Dictionary], blocked_specs: Array[Dictionary], profile: Dictionary, pack: Dictionary = {}) -> Dictionary:
	var records_by_variant: Dictionary = _records_by_variant(records)
	var candidates: Array[Dictionary] = []
	for variant: Dictionary in variants:
		var variant_id: String = str(variant.get("variant_id", ""))
		var variant_records: Array[Dictionary] = _typed_records(Array(records_by_variant.get(variant_id, [])))
		candidates.append(_score_variant(variant, variant_records, profile))
	for blocked: Dictionary in blocked_specs:
		candidates.append(_blocked_candidate(blocked))
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var score_a: float = float(a.get("score", 0.0))
		var score_b: float = float(b.get("score", 0.0))
		if not is_equal_approx(score_a, score_b):
			return score_a > score_b
		return str(a.get("variant_id", "")) < str(b.get("variant_id", ""))
	)
	var by_card: Dictionary = {}
	for candidate: Dictionary in candidates:
		var card_id: String = str(candidate.get("card_id", ""))
		var list: Array = Array(by_card.get(card_id, []))
		list.append(candidate)
		by_card[card_id] = list
	var recommendations: Array[Dictionary] = []
	for card_id: String in _sorted_keys(by_card):
		var card_candidates: Array = Array(by_card.get(card_id, []))
		for candidate_value: Variant in card_candidates:
			if typeof(candidate_value) != TYPE_DICTIONARY:
				continue
			var candidate: Dictionary = Dictionary(candidate_value)
			if str(candidate.get("classification", "")) in [STATUS_RECOMMENDED, STATUS_VIABLE]:
				recommendations.append(candidate)
				break
	return {
		"candidates": candidates,
		"by_card": by_card,
		"recommendations": recommendations,
		"summary": _summary(candidates, recommendations, pack)
	}

static func _score_variant(variant: Dictionary, records: Array[Dictionary], profile: Dictionary) -> Dictionary:
	var pass_count: int = 0
	var warn_count: int = 0
	var fail_count: int = 0
	var signatures: Array[Dictionary] = []
	var reasons: Array[String] = []
	for record: Dictionary in records:
		match str(record.get("status", "FAIL")):
			"PASS":
				pass_count += 1
			"WARN":
				warn_count += 1
			_:
				fail_count += 1
		var result: Dictionary = Dictionary(record.get("result", {}))
		var signature: Dictionary = Dictionary(result.get("enemy_card_effect_signature", {})) if str(variant.get("owner", "")) == "enemy" else Dictionary(result.get("card_effect_signature", {}))
		if not signature.is_empty():
			signatures.append(signature)
	var total: int = maxi(1, records.size())
	var power_value: float = _power_value(variant, signatures, records)
	var role_fit: float = _role_fit(variant, signatures, power_value)
	var power_band: float = _power_band_score(str(variant.get("role", "")), power_value, profile)
	var reliability: float = clamp((float(pass_count) + float(warn_count) * 0.55) / float(total) * 100.0, 0.0, 100.0)
	var context_fit: float = clamp((float(pass_count) + float(warn_count) * 0.5) / float(total) * 100.0, 0.0, 100.0)
	var risk_value: float = _risk_value(variant, records, power_value, profile)
	var risk_score: float = clamp(100.0 - risk_value * 100.0, 0.0, 100.0)
	var novelty: float = 70.0 if str(variant.get("origin", "")) == "variant" else 45.0
	var complexity: float = _complexity_score(variant)
	var sub_scores: Dictionary = {
		"role_fit": role_fit,
		"power_band": power_band,
		"reliability": reliability,
		"context_fit": context_fit,
		"risk": risk_score,
		"novelty": novelty,
		"complexity": complexity
	}
	var score: float = _weighted_score(sub_scores, Dictionary(profile.get("weights", {})))
	if fail_count > 0:
		reasons.append("%d failing context(s)" % fail_count)
	if warn_count > 0:
		reasons.append("%d warning context(s)" % warn_count)
	reasons.append("power value %.1f for role %s" % [power_value, str(variant.get("role", ""))])
	var classification: String = _classification(score, risk_value, fail_count, profile)
	return {
		"variant_id": str(variant.get("variant_id", "")),
		"card_id": str(variant.get("card_id", "")),
		"owner": str(variant.get("owner", "")),
		"role": str(variant.get("role", "")),
		"class_id": str(variant.get("class_id", "")),
		"score": snappedf(score, 0.01),
		"classification": classification,
		"status": classification,
		"power_value": snappedf(power_value, 0.01),
		"risk_value": snappedf(risk_value, 0.01),
		"sub_scores": sub_scores,
		"contexts": {"total": records.size(), "pass": pass_count, "warn": warn_count, "fail": fail_count},
		"numbers": Dictionary(variant.get("numbers", {})).duplicate(true),
		"mechanics": Array(variant.get("mechanics", [])).duplicate(),
		"reasons": reasons,
		"promotion_ready": classification in [STATUS_RECOMMENDED, STATUS_VIABLE]
	}

static func _blocked_candidate(blocked: Dictionary) -> Dictionary:
	var mechanics: Array[String] = []
	for entry_value: Variant in Array(blocked.get("blocked_mechanics", [])):
		if typeof(entry_value) == TYPE_DICTIONARY:
			mechanics.append(str(Dictionary(entry_value).get("mechanic_id", "")))
	return {
		"variant_id": "%s__blocked" % str(blocked.get("card_id", "")),
		"card_id": str(blocked.get("card_id", "")),
		"owner": str(Dictionary(blocked.get("spec", {})).get("owner", "")),
		"role": str(Dictionary(blocked.get("spec", {})).get("role", "")),
		"class_id": str(Dictionary(blocked.get("spec", {})).get("class_id", "")),
		"score": 0.0,
		"classification": STATUS_BLOCKED,
		"status": STATUS_BLOCKED,
		"power_value": 0.0,
		"risk_value": 1.0,
		"sub_scores": {},
		"contexts": {"total": 0, "pass": 0, "warn": 0, "fail": 0},
		"numbers": {},
		"mechanics": mechanics,
		"blocked_mechanics": Array(blocked.get("blocked_mechanics", [])).duplicate(true),
		"reasons": ["blocked missing real engine/lab support: %s" % ",".join(mechanics)],
		"promotion_ready": false
	}

static func _records_by_variant(records: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for record: Dictionary in records:
		var case_data: Dictionary = Dictionary(record.get("case", {}))
		var under_test: Dictionary = Dictionary(case_data.get("card_under_test", {}))
		var variant_id: String = str(under_test.get("id", ""))
		if variant_id == "":
			continue
		var list: Array = Array(result.get(variant_id, []))
		list.append(record)
		result[variant_id] = list
	return result

static func _power_value(variant: Dictionary, signatures: Array[Dictionary], records: Array[Dictionary]) -> float:
	var role: String = str(variant.get("role", ""))
	var best: float = 0.0
	for signature: Dictionary in signatures:
		match role:
			"damage":
				best = maxf(best, float(signature.get("enemy_hero_damage", 0)) + float(signature.get("enemy_slot_damage_total", 0)))
			"summon":
				best = maxf(best, float(signature.get("summoned_attack_total", 0)) + float(signature.get("summoned_health_total", 0)))
			"control":
				best = maxf(best, float(signature.get("freeze_added_total", 0)) + float(signature.get("enemy_frozen_added", 0)) + float(signature.get("enemy_snared_added", 0)) + float(signature.get("poison_added_total", 0)))
			"economy":
				best = maxf(best, float(signature.get("mana_gained", 0)) + float(signature.get("ashes_gained", 0)) + float(signature.get("temporary_ability_power_gained", 0)))
			"card_flow":
				best = maxf(best, float(signature.get("cards_drawn", 0)) + float(signature.get("cards_created", 0)) + absf(float(signature.get("deck_delta", 0))) * 0.25)
			"enemy_pressure":
				best = maxf(best, float(signature.get("enemy_summoned_attack_total", 0)) + float(signature.get("enemy_summoned_health_total", 0)) + float(signature.get("enemy_damage_to_player_hero", 0)) + float(signature.get("enemy_combat_damage_to_player_hero", 0)))
			_:
				best = maxf(best, float(signature.get("summoned_attack_total", 0)) + float(signature.get("enemy_hero_damage", 0)))
	if best <= 0.0:
		for record: Dictionary in records:
			var result: Dictionary = Dictionary(record.get("result", {}))
			best = maxf(best, float(result.get("damage_to_enemy_hero", 0)) + float(result.get("damage_to_player_hero", 0)))
	return best

static func _role_fit(variant: Dictionary, signatures: Array[Dictionary], power_value: float) -> float:
	if power_value <= 0.0:
		return 35.0
	var role: String = str(variant.get("role", ""))
	for signature: Dictionary in signatures:
		var families: Array = Array(signature.get("families", []))
		if role == "damage" and families.has("damage"):
			return 100.0
		if role == "summon" and (families.has("summon") or families.has("enemy_summon")):
			return 100.0
		if role == "enemy_pressure" and (families.has("enemy_summon") or families.has("enemy_stat")):
			return 100.0
		if role == "control" and (families.has("control") or families.has("debuff")):
			return 95.0
		if role == "economy" and families.has("economy"):
			return 95.0
		if role == "card_flow" and families.has("card_flow"):
			return 95.0
	return 70.0

static func _power_band_score(role: String, value: float, profile: Dictionary) -> float:
	var bands: Dictionary = Dictionary(profile.get("bands", {}))
	var band: Dictionary = Dictionary(bands.get(role, bands.get("damage", {"min": 1, "ideal": 3, "max": 6})))
	var min_value: float = float(band.get("min", 1))
	var ideal: float = float(band.get("ideal", min_value))
	var max_value: float = float(band.get("max", ideal))
	if value <= 0.0:
		return 20.0
	if value < min_value:
		return clamp((value / maxf(1.0, min_value)) * 55.0, 0.0, 55.0)
	if value <= ideal:
		return lerpf(70.0, 100.0, (value - min_value) / maxf(1.0, ideal - min_value))
	if value <= max_value:
		return lerpf(100.0, 72.0, (value - ideal) / maxf(1.0, max_value - ideal))
	return maxf(25.0, 72.0 - (value - max_value) * 12.0)

static func _risk_value(variant: Dictionary, records: Array[Dictionary], power_value: float, profile: Dictionary) -> float:
	var role: String = str(variant.get("role", ""))
	var band: Dictionary = Dictionary(Dictionary(profile.get("bands", {})).get(role, {}))
	var max_value: float = float(band.get("max", 999))
	var risk: float = 0.0
	if power_value > max_value:
		risk += minf(0.65, (power_value - max_value) / maxf(1.0, max_value))
	for record: Dictionary in records:
		if str(record.get("status", "")) == "FAIL":
			risk += 0.35
		elif str(record.get("status", "")) == "WARN":
			risk += 0.12
		var result: Dictionary = Dictionary(record.get("result", {}))
		if bool(result.get("policy_action_rejected", false)):
			risk += 0.35
		if str(result.get("capture_quality", "")) in ["ambiguous", "failed", "missing"]:
			risk += 0.2
	return clamp(risk, 0.0, 1.0)

static func _complexity_score(variant: Dictionary) -> float:
	var mechanic_count: int = Array(variant.get("mechanics", [])).size()
	var effect_count: int = Dictionary(Dictionary(variant.get("spec", {})).get("effect", {})).size()
	var penalty: float = float(maxi(0, mechanic_count - 1)) * 10.0 + float(maxi(0, effect_count - 3)) * 5.0
	return clamp(100.0 - penalty, 45.0, 100.0)

static func _weighted_score(sub_scores: Dictionary, weights: Dictionary) -> float:
	var total_weight: float = 0.0
	var score: float = 0.0
	for key: Variant in weights.keys():
		var weight: float = float(weights.get(key, 0.0))
		total_weight += weight
		score += float(sub_scores.get(str(key), 0.0)) * weight
	if total_weight <= 0.0:
		return 0.0
	return score / total_weight

static func _classification(score: float, risk_value: float, fail_count: int, profile: Dictionary) -> String:
	if fail_count > 0:
		return STATUS_BROKEN
	var promotion: Dictionary = Dictionary(profile.get("promotion", {}))
	var recommended_score: float = float(promotion.get("recommended_score", 78))
	var viable_score: float = float(promotion.get("viable_score", 62))
	var max_risk: float = float(promotion.get("max_risk", 0.45))
	if score >= recommended_score and risk_value <= max_risk:
		return STATUS_RECOMMENDED
	if score >= viable_score and risk_value <= max_risk:
		return STATUS_VIABLE
	if risk_value > max_risk:
		return STATUS_RISKY
	if score < 45.0:
		return STATUS_WEAK
	return STATUS_RISKY

static func _summary(candidates: Array[Dictionary], recommendations: Array[Dictionary], pack: Dictionary) -> Dictionary:
	var counts: Dictionary = {}
	var card_ids: Array[String] = []
	for candidate: Dictionary in candidates:
		var classification: String = str(candidate.get("classification", "unknown"))
		counts[classification] = int(counts.get(classification, 0)) + 1
		var card_id: String = str(candidate.get("card_id", ""))
		if card_id != "" and not card_ids.has(card_id):
			card_ids.append(card_id)
	var gate_ok: bool = recommendations.size() >= card_ids.size() and int(counts.get(STATUS_BLOCKED, 0)) == 0 and int(counts.get(STATUS_BROKEN, 0)) == 0
	return {
		"pack_id": str(pack.get("pack_id", "")),
		"candidate_count": candidates.size(),
		"card_count": card_ids.size(),
		"recommendation_count": recommendations.size(),
		"classification_counts": counts,
		"gate_ok": gate_ok
	}

static func _typed_records(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			result.append(Dictionary(value))
	return result

static func _sorted_keys(values: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in values.keys():
		keys.append(str(key))
	keys.sort()
	return keys
