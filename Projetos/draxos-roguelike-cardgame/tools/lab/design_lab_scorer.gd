extends RefCounted

const OfficialBaselineIndexScript = preload("res://tools/lab/design_lab_official_baseline_index.gd")

const STATUS_BLOCKED: String = "blocked"
const STATUS_BROKEN: String = "broken"
const STATUS_RECOMMENDED: String = "recommended"
const STATUS_VIABLE: String = "viable"
const STATUS_RISKY: String = "risky"
const STATUS_WEAK: String = "weak"

static func score_variants(variants: Array[Dictionary], records: Array[Dictionary], blocked_specs: Array[Dictionary], profile: Dictionary, pack: Dictionary = {}, official_index: Dictionary = {}) -> Dictionary:
	var records_by_variant: Dictionary = _records_by_variant(records)
	var candidates: Array[Dictionary] = []
	for variant: Dictionary in variants:
		var variant_id: String = str(variant.get("variant_id", ""))
		var variant_records: Array[Dictionary] = _typed_records(Array(records_by_variant.get(variant_id, [])))
		candidates.append(_score_variant(variant, variant_records, profile, official_index))
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

static func _score_variant(variant: Dictionary, records: Array[Dictionary], profile: Dictionary, official_index: Dictionary) -> Dictionary:
	var pass_count: int = 0
	var warn_count: int = 0
	var fail_count: int = 0
	var signatures: Array[Dictionary] = []
	var reasons: Array[String] = []
	var context_failures: Array[Dictionary] = []
	for record: Dictionary in records:
		match str(record.get("status", "FAIL")):
			"PASS":
				pass_count += 1
			"WARN":
				warn_count += 1
			_:
				fail_count += 1
				context_failures.append(_context_failure(record))
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
	var official_neighbors: Array[Dictionary] = OfficialBaselineIndexScript.neighbors_for_variant(official_index, variant, int(Dictionary(profile.get("official_neighbors", {})).get("limit", 3)))
	var neighbor_assessment: Dictionary = _neighbor_assessment(variant, power_value, official_neighbors, profile)
	var curve_fit: float = _curve_fit_score(variant, power_value, profile)
	var entry_timing_fit: float = _entry_timing_fit(variant, power_value, profile)
	var role_ceiling_risk: float = _role_ceiling_risk(variant, power_value, profile)
	var replacement_risk: float = float(neighbor_assessment.get("replacement_risk", 0.0))
	var redundancy_risk: float = float(neighbor_assessment.get("redundancy_risk", 0.0))
	var official_neighbor_fit: float = float(neighbor_assessment.get("official_neighbor_fit", 70.0))
	var risk_value: float = _risk_value(variant, records, power_value, profile, replacement_risk, redundancy_risk, role_ceiling_risk)
	var risk_score: float = clamp(100.0 - risk_value * 100.0, 0.0, 100.0)
	var novelty: float = 70.0 if str(variant.get("origin", "")) == "variant" else 45.0
	var complexity: float = _complexity_score(variant)
	var sub_scores: Dictionary = {
		"role_fit": role_fit,
		"power_band": power_band,
		"curve_fit": curve_fit,
		"official_neighbor_fit": official_neighbor_fit,
		"entry_timing_fit": entry_timing_fit,
		"reliability": reliability,
		"context_fit": context_fit,
		"risk": risk_score,
		"replacement_safety": clamp(100.0 - replacement_risk * 100.0, 0.0, 100.0),
		"redundancy_safety": clamp(100.0 - redundancy_risk * 100.0, 0.0, 100.0),
		"role_ceiling_safety": clamp(100.0 - role_ceiling_risk * 100.0, 0.0, 100.0),
		"novelty": novelty,
		"complexity": complexity
	}
	var score: float = _weighted_score(sub_scores, Dictionary(profile.get("weights", {})))
	if fail_count > 0:
		reasons.append("%d failing context(s)" % fail_count)
	if warn_count > 0:
		reasons.append("%d warning context(s)" % warn_count)
	reasons.append("power value %.1f for role %s" % [power_value, str(variant.get("role", ""))])
	for reason_value: Variant in Array(neighbor_assessment.get("reasons", [])):
		reasons.append(str(reason_value))
	var risk_notes: Array[String] = _risk_notes(replacement_risk, redundancy_risk, role_ceiling_risk, entry_timing_fit, context_failures)
	var manual_review_questions: Array[String] = _manual_review_questions(variant, official_neighbors, risk_notes)
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
		"official_neighbors": official_neighbors,
		"risk_notes": risk_notes,
		"context_failures": context_failures,
		"manual_review_questions": manual_review_questions,
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
		"official_neighbors": [],
		"risk_notes": ["mechanic has no real engine/lab support yet"],
		"context_failures": [],
		"manual_review_questions": ["What engine, AI, UI and signature hooks must exist before this idea can receive numeric tuning?"],
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
				var summoned_pressure: float = float(signature.get("enemy_summoned_attack_total", 0)) + float(signature.get("enemy_summoned_health_total", 0))
				var damage_pressure: float = float(signature.get("enemy_damage_to_player_hero", 0)) + float(signature.get("enemy_combat_damage_to_player_hero", 0))
				best = maxf(best, maxf(summoned_pressure, damage_pressure))
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

static func _risk_value(variant: Dictionary, records: Array[Dictionary], power_value: float, profile: Dictionary, replacement_risk: float, redundancy_risk: float, role_ceiling_risk: float) -> float:
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
	risk += replacement_risk * 0.35
	risk += redundancy_risk * 0.12
	risk += role_ceiling_risk * 0.3
	return clamp(risk, 0.0, 1.0)

static func _neighbor_assessment(variant: Dictionary, power_value: float, neighbors: Array[Dictionary], profile: Dictionary) -> Dictionary:
	if neighbors.is_empty():
		return {
			"official_neighbor_fit": 70.0,
			"replacement_risk": 0.0,
			"redundancy_risk": 0.0,
			"reasons": ["no close official neighbor found; manual baseline review required"]
		}
	var nearest: Dictionary = Dictionary(neighbors[0])
	var margin: float = float(Dictionary(profile.get("official_neighbors", {})).get("power_margin", 1.5))
	var delta: float = power_value - float(nearest.get("power_value", 0.0))
	var same_cost: bool = int(nearest.get("cost", -99)) == _variant_cost(variant)
	var fit: float = 92.0
	var replacement_risk: float = 0.0
	var redundancy_risk: float = 0.0
	var reasons: Array[String] = []
	reasons.append("closest official `%s` cost %d power %.1f delta %.1f" % [
		str(nearest.get("card_id", "")),
		int(nearest.get("cost", 0)),
		float(nearest.get("power_value", 0.0)),
		delta
	])
	if delta > margin:
		fit = maxf(25.0, 92.0 - (delta - margin) * 16.0)
		if same_cost:
			replacement_risk = clamp((delta - margin) / maxf(1.0, float(nearest.get("power_value", 1.0))), 0.0, 1.0)
			reasons.append("replacement risk: stronger than nearest official at same cost")
	elif delta < -margin * 1.5:
		fit = maxf(45.0, 88.0 + delta * 8.0)
		reasons.append("below official neighbor band; may feel weak")
	else:
		fit = 95.0
		if same_cost and absf(delta) <= 0.75 and Array(variant.get("mechanics", [])).size() <= 1:
			redundancy_risk = 0.35
			reasons.append("redundancy risk: very close to existing official card")
	return {
		"official_neighbor_fit": clamp(fit, 0.0, 100.0),
		"replacement_risk": replacement_risk,
		"redundancy_risk": redundancy_risk,
		"reasons": reasons
	}

static func _curve_fit_score(variant: Dictionary, power_value: float, profile: Dictionary) -> float:
	var role: String = str(variant.get("role", ""))
	var cost: int = maxi(1, _variant_cost(variant))
	var curve: Dictionary = Dictionary(profile.get("curve", {}))
	var role_curve: Dictionary = Dictionary(curve.get(role, curve.get("default", {})))
	var ideal_per_cost: float = float(role_curve.get("ideal_power_per_cost", 3.5))
	var tolerance: float = float(role_curve.get("tolerance", 1.5))
	var actual: float = power_value / float(cost)
	var delta: float = absf(actual - ideal_per_cost)
	if delta <= tolerance:
		return 100.0
	return clamp(100.0 - (delta - tolerance) * 18.0, 25.0, 100.0)

static func _entry_timing_fit(variant: Dictionary, power_value: float, profile: Dictionary) -> float:
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	var timing: String = str(spec.get("timing", "mid"))
	var role: String = str(variant.get("role", ""))
	var band: Dictionary = Dictionary(Dictionary(profile.get("bands", {})).get(role, {}))
	var max_value: float = float(band.get("max", 999.0))
	var cost: int = _variant_cost(variant)
	var score: float = 92.0
	if timing in ["starter", "early", "first_combat", "map_1_8"]:
		if cost > 3:
			score -= float(cost - 3) * 10.0
		if power_value > max_value:
			score -= (power_value - max_value) * 12.0
	elif timing in ["late", "boss", "map_20_29"]:
		if power_value < float(band.get("ideal", 1.0)):
			score -= 18.0
	else:
		if power_value > max_value * 1.25:
			score -= (power_value - max_value) * 8.0
	return clamp(score, 25.0, 100.0)

static func _role_ceiling_risk(variant: Dictionary, power_value: float, profile: Dictionary) -> float:
	var role: String = str(variant.get("role", ""))
	var band: Dictionary = Dictionary(Dictionary(profile.get("bands", {})).get(role, {}))
	var max_value: float = float(band.get("max", 999.0))
	if power_value <= max_value:
		return 0.0
	return clamp((power_value - max_value) / maxf(1.0, max_value), 0.0, 1.0)

static func _variant_cost(variant: Dictionary) -> int:
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	return int(Dictionary(variant.get("numbers", {})).get("cost", spec.get("cost", 0)))

static func _risk_notes(replacement_risk: float, redundancy_risk: float, role_ceiling_risk: float, entry_timing_fit: float, context_failures: Array[Dictionary]) -> Array[String]:
	var notes: Array[String] = []
	if replacement_risk >= 0.2:
		notes.append("May obsolete an official neighbor at the same cost.")
	if redundancy_risk >= 0.25:
		notes.append("Very close to an existing official card; confirm the design purpose is distinct.")
	if role_ceiling_risk >= 0.2:
		notes.append("Power exceeds the role ceiling for the selected profile.")
	if entry_timing_fit < 65.0:
		notes.append("Timing or curve looks unsafe for the intended entry point.")
	if not context_failures.is_empty():
		notes.append("At least one required context failed.")
	return notes

static func _manual_review_questions(variant: Dictionary, neighbors: Array[Dictionary], risk_notes: Array[String]) -> Array[String]:
	var questions: Array[String] = []
	if neighbors.is_empty():
		questions.append("Which official card should this idea be compared against before promotion?")
	elif not risk_notes.is_empty():
		questions.append("Does this card need to be stronger than `%s`, or should its numbers come down?" % str(Dictionary(neighbors[0]).get("card_id", "")))
	if str(Dictionary(variant.get("spec", {})).get("design_intent", "")).strip_edges() == "":
		questions.append("What player/enemy behavior is this card supposed to create?")
	return questions

static func _context_failure(record: Dictionary) -> Dictionary:
	var case_data: Dictionary = Dictionary(record.get("case", {}))
	var result: Dictionary = Dictionary(record.get("result", {}))
	return {
		"case_id": str(case_data.get("id", "")),
		"status": str(record.get("status", "")),
		"capture_quality": str(result.get("capture_quality", "")),
		"policy_action_rejected": bool(result.get("policy_action_rejected", false))
	}

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
	var broken_risk: float = float(promotion.get("broken_risk", 0.82))
	if risk_value >= broken_risk:
		return STATUS_BROKEN
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
	var gate_ok: bool = recommendations.size() >= card_ids.size() and int(counts.get(STATUS_BLOCKED, 0)) == 0
	return {
		"pack_id": str(pack.get("pack_id", "")),
		"candidate_count": candidates.size(),
		"card_count": card_ids.size(),
		"recommendation_count": recommendations.size(),
		"rejected_candidate_count": int(counts.get(STATUS_BROKEN, 0)) + int(counts.get(STATUS_RISKY, 0)) + int(counts.get(STATUS_WEAK, 0)),
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
