extends "res://tests/unit/draxos_test_base.gd"

const ContextBuilderScript = preload("res://tools/lab/design_lab_context_builder.gd")
const OverlayCatalogScript = preload("res://tools/lab/design_lab_overlay_catalog.gd")
const ProposalLoaderScript = preload("res://tools/lab/design_lab_proposal_loader.gd")
const PromotionManifestValidatorScript = preload("res://tools/lab/design_lab_promotion_manifest_validator.gd")
const ReporterScript = preload("res://tools/lab/design_lab_reporter.gd")
const ScorerScript = preload("res://tools/lab/design_lab_scorer.gd")
const VariantGeneratorScript = preload("res://tools/lab/design_lab_variant_generator.gd")

func test_design_lab_loader_accepts_sample_pack() -> void:
	var load_result: Dictionary = ProposalLoaderScript.load_pack_result("design_lab_sample_v1")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	assert_eq(str(pack.get("pack_id", "")), "design_lab_sample_v1")
	assert_eq(ProposalLoaderScript.card_specs(pack).size(), 3)

func test_design_lab_loader_rejects_card_without_intent_role_context_or_variant_space() -> void:
	var load_result: Dictionary = ProposalLoaderScript.load_registry_result()
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = _minimal_pack()
	pack["cards"] = [{
		"id": "bad_card",
		"new_card_id": "bad_card",
		"owner": "player",
		"class_id": "arcano",
		"timing": "early",
		"valid_targets": [],
		"mechanics": ["damage"]
	}]
	pack["encounter_contexts"] = []
	var result: Dictionary = ProposalLoaderScript.validate_pack_result(pack, Dictionary(load_result.get("registry", {})), "unit")
	assert_false(bool(result.get("ok", true)))
	var message: String = str(result.get("message", ""))
	assert_string_contains(message, "role")
	assert_string_contains(message, "design_intent")
	assert_string_contains(message, "valid_targets")
	assert_string_contains(message, "variant_space")
	assert_string_contains(message, "context")

func test_design_lab_registry_rejects_unknown_mechanic() -> void:
	var load_result: Dictionary = ProposalLoaderScript.load_registry_result()
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = _minimal_pack()
	pack["mechanics"] = [{"mechanic_id": "mechanic_does_not_exist"}]
	pack["cards"][0]["mechanics"] = ["mechanic_does_not_exist"]
	var result: Dictionary = ProposalLoaderScript.validate_pack_result(pack, Dictionary(load_result.get("registry", {})), "unit")
	assert_false(bool(result.get("ok", true)))
	assert_string_contains(str(result.get("message", "")), "mechanic_does_not_exist")

func test_design_lab_blocked_mechanic_generates_blocked_spec() -> void:
	var registry_result: Dictionary = ProposalLoaderScript.load_registry_result()
	assert_true(bool(registry_result.get("ok", false)), str(registry_result.get("message", "")))
	var pack: Dictionary = _minimal_pack()
	pack["mechanics"] = [{"mechanic_id": "steal_mana"}]
	pack["cards"][0]["mechanics"] = ["steal_mana"]
	var validation: Dictionary = ProposalLoaderScript.validate_pack_result(pack, Dictionary(registry_result.get("registry", {})), "unit")
	assert_true(bool(validation.get("ok", false)), str(validation.get("message", "")))
	var generated: Dictionary = VariantGeneratorScript.generate_variants(pack, Dictionary(registry_result.get("registry", {})), {"max_variants": 3, "cards": PackedStringArray(["all"])})
	assert_eq(Array(generated.get("variants", [])).size(), 0)
	assert_eq(Array(generated.get("blocked_specs", [])).size(), 1)

func test_design_lab_overlay_adds_lab_only_card_without_mutating_official_catalog() -> void:
	var registry_result: Dictionary = ProposalLoaderScript.load_registry_result()
	var pack: Dictionary = _minimal_pack()
	var generated: Dictionary = VariantGeneratorScript.generate_variants(pack, Dictionary(registry_result.get("registry", {})), {"max_variants": 1, "cards": PackedStringArray(["all"])})
	var variants: Array[Dictionary] = _typed_dictionary_array(Array(generated.get("variants", [])))
	assert_eq(variants.size(), 1)
	var base_catalog = ContentLibrary.get_catalog()
	var base_count: int = Array(base_catalog.cards).size()
	var variant_id: String = str(variants[0].get("variant_id", ""))
	assert_null(base_catalog.find_card(variant_id))
	var overlay: Dictionary = OverlayCatalogScript.build_overlay(base_catalog, pack, variants)
	assert_true(bool(overlay.get("ok", false)), str(overlay.get("message", "")))
	var overlay_catalog = overlay.get("catalog")
	assert_not_null(overlay_catalog.find_card(variant_id))
	assert_eq(Array(base_catalog.cards).size(), base_count)
	assert_eq(Array(overlay_catalog.cards).size(), base_count + 1)

func test_design_lab_variant_generator_produces_stable_ids_and_respects_limit() -> void:
	var registry_result: Dictionary = ProposalLoaderScript.load_registry_result()
	var pack: Dictionary = _minimal_pack()
	var first: Dictionary = VariantGeneratorScript.generate_variants(pack, Dictionary(registry_result.get("registry", {})), {"max_variants": 2, "cards": PackedStringArray(["all"])})
	var second: Dictionary = VariantGeneratorScript.generate_variants(pack, Dictionary(registry_result.get("registry", {})), {"max_variants": 2, "cards": PackedStringArray(["all"])})
	var first_variants: Array = Array(first.get("variants", []))
	var second_variants: Array = Array(second.get("variants", []))
	assert_eq(first_variants.size(), 2)
	assert_eq(second_variants.size(), 2)
	assert_eq(str(Dictionary(first_variants[0]).get("variant_id", "")), str(Dictionary(second_variants[0]).get("variant_id", "")))

func test_design_lab_context_builder_builds_player_and_enemy_cases() -> void:
	var registry_result: Dictionary = ProposalLoaderScript.load_registry_result()
	var load_result: Dictionary = ProposalLoaderScript.load_pack_result("design_lab_sample_v1")
	var generated: Dictionary = VariantGeneratorScript.generate_variants(Dictionary(load_result.get("pack", {})), Dictionary(registry_result.get("registry", {})), {"max_variants": 1, "cards": PackedStringArray(["all"])})
	var context_result: Dictionary = ContextBuilderScript.build_cases(Dictionary(load_result.get("pack", {})), _typed_dictionary_array(Array(generated.get("variants", []))))
	assert_true(bool(context_result.get("ok", false)))
	var cases: Array = Array(context_result.get("cases", []))
	assert_gt(cases.size(), 0)
	var has_enemy: bool = false
	var has_player: bool = false
	for case_value: Variant in cases:
		var tags: Array = Array(Dictionary(case_value).get("tags", []))
		has_enemy = has_enemy or tags.has("enemy_card")
		has_player = has_player or tags.has("player_card")
	assert_true(has_enemy)
	assert_true(has_player)

func test_design_lab_scorer_ranks_candidates_deterministically() -> void:
	var variant_low: Dictionary = _variant("card_a__low", "card_a", 3)
	var variant_good: Dictionary = _variant("card_a__good", "card_a", 5)
	var records: Array[Dictionary] = [
		_fake_record("card_a__low", 3, "PASS"),
		_fake_record("card_a__good", 5, "PASS")
	]
	var profile: Dictionary = {
		"profile_id": "unit",
		"weights": {"role_fit": 0.3, "power_band": 0.3, "reliability": 0.2, "context_fit": 0.1, "risk": 0.1},
		"bands": {"damage": {"min": 3, "ideal": 5, "max": 6}},
		"promotion": {"recommended_score": 70, "viable_score": 55, "max_risk": 0.5}
	}
	var scored: Dictionary = ScorerScript.score_variants([variant_low, variant_good], records, [], profile, {"pack_id": "unit"})
	var candidates: Array = Array(scored.get("candidates", []))
	assert_eq(str(Dictionary(candidates[0]).get("variant_id", "")), "card_a__good")
	assert_true(float(Dictionary(candidates[0]).get("score", 0.0)) >= float(Dictionary(candidates[1]).get("score", 0.0)))

func test_design_lab_reporter_writes_candidates_blocked_and_promotion_manifest() -> void:
	var report: Dictionary = {
		"pack_id": "unit_design_lab",
		"summary": {"gate_ok": true, "candidate_count": 1, "card_count": 1, "recommendation_count": 1, "classification_counts": {"recommended": 1}},
		"candidates": [{
			"card_id": "card_a",
			"variant_id": "card_a__good",
			"owner": "player",
			"role": "damage",
			"classification": "recommended",
			"score": 88.0,
			"risk_value": 0.1,
			"power_value": 5,
			"numbers": {"cost": 1, "effect.amount": 5},
			"contexts": {"pass": 1, "warn": 0, "fail": 0},
			"reasons": ["unit"]
		}],
		"by_card": {"card_a": [{
			"card_id": "card_a",
			"variant_id": "card_a__good",
			"classification": "recommended",
			"score": 88.0,
			"risk_value": 0.1,
			"reasons": ["unit"]
		}]},
		"recommendations": [{
			"card_id": "card_a",
			"variant_id": "card_a__good",
			"owner": "player",
			"role": "damage",
			"classification": "recommended",
			"score": 88.0,
			"numbers": {"cost": 1, "effect.amount": 5}
		}],
		"blocked_mechanics": [{"mechanic_id": "steal_mana", "description": "blocked"}]
	}
	var out_dir: String = "user://design_lab/gut_reporter_unit"
	var write_result: Dictionary = ReporterScript.write_outputs(out_dir, report, {"mode": "explore", "command": "unit"})
	assert_true(bool(write_result.get("ok", false)), str(write_result.get("message", "")))
	assert_true(FileAccess.file_exists("%s/design_lab_summary.md" % out_dir))
	assert_true(FileAccess.file_exists("%s/promotion_manifest.json" % out_dir))
	var markdown: String = FileAccess.get_file_as_string("%s/design_lab_summary.md" % out_dir)
	assert_string_contains(markdown, "Top Candidates By Card")
	assert_string_contains(markdown, "Blocked Mechanics")
	assert_string_contains(markdown, "Promotion Manifest")
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string("%s/promotion_manifest.json" % out_dir))
	assert_eq(Array(Dictionary(manifest).get("selected_candidates", [])).size(), 1)
	var validation: Dictionary = PromotionManifestValidatorScript.validate_manifest(Dictionary(manifest))
	assert_true(bool(validation.get("ok", false)), "; ".join(Array(validation.get("errors", []))))

func test_design_lab_promotion_manifest_validator_rejects_unsafe_manifest() -> void:
	var manifest: Dictionary = {
		"schema_version": 1,
		"pack_id": "unit_design_lab",
		"generated_by": "Design Lab",
		"manual_approval_required": false,
		"selected_candidates": [{
			"card_id": "card_a",
			"variant_id": "card_a__broken",
			"owner": "player",
			"role": "damage",
			"classification": "risky",
			"numbers": {"effect.amount": 99},
			"suggested_diffs": [{"field": "effect.amount", "value": 99}],
			"required_validations": ["validate.gd"]
		}],
		"blocked_mechanics": []
	}
	var validation: Dictionary = PromotionManifestValidatorScript.validate_manifest(manifest)
	assert_false(bool(validation.get("ok", true)))
	var errors: String = "; ".join(Array(validation.get("errors", [])))
	assert_string_contains(errors, "manual_approval_required")
	assert_string_contains(errors, "classification")
	assert_string_contains(errors, "run_design_lab")
	assert_string_contains(errors, "run_card_impact")

func _minimal_pack() -> Dictionary:
	return {
		"pack_id": "unit_design_pack",
		"schema_version": 1,
		"design_goal": "unit",
		"notes": "unit",
		"mechanics": [{"mechanic_id": "damage"}],
		"scoring_profile": "default",
		"promotion_policy": {"manual_approval_required": true},
		"cards": [{
			"id": "unit_proto_damage",
			"new_card_id": "unit_proto_damage",
			"owner": "player",
			"class_id": "arcano",
			"role": "damage",
			"design_intent": "unit playable damage card",
			"timing": "early",
			"valid_targets": ["enemy_unit", "enemy_hero"],
			"mechanics": ["damage"],
			"display_name": "Unit Damage",
			"type": "magia",
			"cost": 1,
			"effect": {"action": "damage", "amount": 3},
			"variant_space": {"cost": [1, 2], "effect.amount": [3, 4]},
			"context_ids": ["unit_context"]
		}],
		"encounter_contexts": [{
			"id": "unit_context",
			"owner": "player",
			"required": true,
			"starting_enemy_slots": [{"slot": 1, "card_id": "enemy_terra_elemental_tita"}],
			"policy_id": "card_focus_isolated",
			"turn_limit": 2
		}]
	}

func _variant(variant_id: String, card_id: String, amount: int) -> Dictionary:
	return {
		"variant_id": variant_id,
		"card_id": card_id,
		"owner": "player",
		"role": "damage",
		"class_id": "arcano",
		"mechanics": ["damage"],
		"numbers": {"effect.amount": amount},
		"origin": "variant",
		"spec": {"effect": {"action": "damage", "amount": amount}}
	}

func _fake_record(variant_id: String, damage: int, status: String) -> Dictionary:
	return {
		"case": {"card_under_test": {"id": variant_id}},
		"result": {
			"card_effect_signature": {
				"present": true,
				"families": ["damage"],
				"enemy_hero_damage": damage,
				"enemy_slot_damage_total": 0
			},
			"capture_quality": "clean",
			"policy_action_rejected": false
		},
		"status": status
	}

func _typed_dictionary_array(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			result.append(Dictionary(value))
	return result
