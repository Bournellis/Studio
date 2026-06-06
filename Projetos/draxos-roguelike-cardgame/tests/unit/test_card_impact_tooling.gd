extends "res://tests/unit/draxos_test_base.gd"

const BattleEffectSignatureScript = preload("res://tools/lab/battle_effect_signature.gd")
const BattlePolicyScript = preload("res://tools/lab/battle_policy.gd")
const BattleRunnerScript = preload("res://tools/lab/battle_runner.gd")
const CardFlowExpectationEvaluatorScript = preload("res://tools/lab/card_flow_expectation_evaluator.gd")
const CardImpactMatrixScript = preload("res://tools/lab/card_impact_matrix.gd")
const CardImpactPackLoaderScript = preload("res://tools/lab/card_impact_pack_loader.gd")
const CardImpactReporterScript = preload("res://tools/lab/card_impact_reporter.gd")
const CardImpactRunnerScript = preload("res://tools/lab/card_impact_runner.gd")

func test_card_impact_loader_loads_track02_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v1")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v1")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v1")

func test_card_impact_loader_loads_track02_v2_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v2")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v2")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v2")
	assert_true(bool(Dictionary(pack.get("effect_signatures", {})).get("enabled", false)))
	assert_eq(int(Dictionary(pack.get("effect_signatures", {})).get("schema_version", 0)), 2)

func test_card_impact_loader_loads_track02_v3_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v3")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	var signatures: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	var target_capture: Dictionary = Dictionary(signatures.get("target_capture", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v3")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v3")
	assert_eq(int(signatures.get("schema_version", 0)), 3)
	assert_eq(str(target_capture.get("mode", "")), "isolated_once")
	assert_true(bool(target_capture.get("stop_after_target", false)))

func test_card_impact_loader_loads_track02_v4_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v4")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	var signatures: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v4")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v4")
	assert_eq(int(signatures.get("schema_version", 0)), 4)
	assert_eq(str(card_sets.get("player_scope", "")), "full_active_player_v1")
	assert_eq(int(card_sets.get("expected_player_cards", 0)), 108)

func test_card_impact_loader_loads_track02_v4_1_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v4_1")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	var signatures: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v4_1")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v4_1")
	assert_eq(int(signatures.get("schema_version", 0)), 4)
	assert_eq(int(card_sets.get("expected_player_cards", 0)), 108)
	assert_eq(int(card_sets.get("expected_card_flow_player_cards", 0)), 3)

func test_card_impact_loader_loads_track02_v4_2_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v4_2")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {}))
	var expectations: Dictionary = Dictionary(pack.get("card_flow_expectations", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v4_2")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v4_2")
	assert_eq(int(card_sets.get("expected_player_cards", 0)), 108)
	assert_eq(int(card_sets.get("expected_card_flow_player_cards", 0)), 3)
	assert_true(bool(expectations.get("enabled", false)))
	assert_eq(Array(expectations.get("checks", [])).size(), 21)

func test_card_impact_loader_rejects_unknown_simulation_mode() -> void:
	var pack: Dictionary = _pack_v4().duplicate(true)
	pack["simulation_mode"] = "card_impact_future"
	var result: Dictionary = CardImpactPackLoaderScript.validate_pack_result(pack, "unit")
	assert_false(bool(result.get("ok", true)))
	assert_string_contains(str(result.get("message", "")), "simulation_mode")

func test_card_impact_loader_rejects_invalid_card_flow_expectation() -> void:
	var pack: Dictionary = _pack_v4_2().duplicate(true)
	var expectations: Dictionary = Dictionary(pack.get("card_flow_expectations", {})).duplicate(true)
	var checks: Array = Array(expectations.get("checks", [])).duplicate(true)
	var bad_check: Dictionary = Dictionary(checks[0]).duplicate(true)
	bad_check.erase("field")
	checks[0] = bad_check
	expectations["checks"] = checks
	pack["card_flow_expectations"] = expectations
	var result: Dictionary = CardImpactPackLoaderScript.validate_pack_result(pack, "unit")
	assert_false(bool(result.get("ok", true)))
	assert_string_contains(str(result.get("message", "")), "card_flow_expectations")

func test_card_impact_v4_1_stays_without_explicit_card_flow_expectations() -> void:
	assert_false(_pack_v4_1().has("card_flow_expectations"))

func test_card_impact_matrix_discovers_expected_cards() -> void:
	var pack: Dictionary = _pack()
	var discovery: Dictionary = CardImpactMatrixScript.discover_cards(ContentLibrary.get_catalog(), pack)
	assert_true(bool(discovery.get("ok", false)), "; ".join(Array(discovery.get("errors", []))))
	assert_eq(Array(discovery.get("player_cards", [])).size(), 54)
	assert_eq(Array(discovery.get("enemy_cards", [])).size(), 30)
	assert_eq(Array(discovery.get("legacy_inactive_cards", [])).size(), 15)

func test_card_impact_v3_matrix_still_discovers_core_player_cards() -> void:
	var discovery: Dictionary = CardImpactMatrixScript.discover_cards(ContentLibrary.get_catalog(), _pack_v3())
	assert_true(bool(discovery.get("ok", false)), "; ".join(Array(discovery.get("errors", []))))
	assert_eq(Array(discovery.get("player_cards", [])).size(), 54)
	assert_eq(Array(discovery.get("enemy_cards", [])).size(), 30)
	assert_eq(Array(discovery.get("legacy_inactive_cards", [])).size(), 15)

func test_card_impact_v4_matrix_discovers_full_player_cards() -> void:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4(), PackedStringArray(["all"]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	assert_eq(Array(matrix.get("player_cards", [])).size(), 108)
	assert_eq(Array(matrix.get("enemy_cards", [])).size(), 30)
	var summary: Dictionary = Dictionary(matrix.get("summary", {}))
	assert_eq(int(summary.get("battle_cases", 0)), 138)
	assert_eq(Dictionary(summary.get("filtered_player_cards_by_class", {})), {"arcano": 36, "invocador": 36, "necromante": 36})
	assert_eq(Dictionary(summary.get("filtered_player_cards_by_source", {})), {"starter": 27, "core_cost2": 9, "reward": 72})

func test_card_impact_v4_1_matrix_discovers_card_flow_player_cards() -> void:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_1(), PackedStringArray(["all"]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	assert_eq(Array(matrix.get("player_cards", [])).size(), 108)
	assert_eq(Array(matrix.get("enemy_cards", [])).size(), 30)
	var summary: Dictionary = Dictionary(matrix.get("summary", {}))
	assert_eq(int(summary.get("battle_cases", 0)), 138)
	assert_eq(int(summary.get("card_flow_player_cards_total", 0)), 3)
	assert_eq(int(summary.get("filtered_card_flow_player_cards", 0)), 3)

func test_card_impact_v4_2_matrix_discovers_card_flow_player_cards() -> void:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_2(), PackedStringArray(["all"]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	assert_eq(Array(matrix.get("player_cards", [])).size(), 108)
	assert_eq(Array(matrix.get("enemy_cards", [])).size(), 30)
	var summary: Dictionary = Dictionary(matrix.get("summary", {}))
	assert_eq(int(summary.get("battle_cases", 0)), 138)
	assert_eq(int(summary.get("card_flow_player_cards_total", 0)), 3)
	assert_eq(int(summary.get("filtered_card_flow_player_cards", 0)), 3)

func test_card_impact_v4_1_matrix_classifies_colheita_as_card_flow() -> void:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_1(), PackedStringArray(["necro_colheita_das_almas", "necro_colheita_das_almas_lvl2", "necro_colheita_das_almas_lvl3"]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 3)
	var found_lvl3_prestate: bool = false
	for case_data: Dictionary in cases:
		assert_eq(str(case_data.get("effect_family", "")), "card_flow")
		assert_true(Array(case_data.get("tags", [])).has("effect_card_flow"))
		assert_true(bool(case_data.get("card_flow_expected", false)))
		if str(Dictionary(case_data.get("card_under_test", {})).get("id", "")) == "necro_colheita_das_almas_lvl3":
			found_lvl3_prestate = true
			assert_eq(int(Dictionary(case_data.get("lab_prestate", {})).get("initial_dead_unit_count", 0)), 2)
	assert_true(found_lvl3_prestate)

func test_card_impact_v4_matrix_includes_non_terra_reward_cards() -> void:
	var discovery: Dictionary = CardImpactMatrixScript.discover_cards(ContentLibrary.get_catalog(), _pack_v4())
	var ids: Array[String] = []
	for card: Dictionary in Array(discovery.get("player_cards", [])):
		ids.append(str(card.get("id", "")))
	for card_id: String in ["arcano_vortice", "invocador_cavaleiro_arcano", "necro_lich"]:
		assert_true(ids.has(card_id), "%s should be covered by V4." % card_id)

func test_card_impact_matrix_excludes_legacy_inactive_cards() -> void:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["all"]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	for case_data: Dictionary in Array(matrix.get("cases", [])):
		var card_id: String = str(Dictionary(case_data.get("card_under_test", {})).get("id", ""))
		assert_false(card_id.begins_with("elemental_"), "%s should stay legacy inactive." % card_id)
	var summary: Dictionary = Dictionary(matrix.get("summary", {}))
	assert_eq(int(summary.get("battle_cases", 0)), 84)
	assert_eq(int(summary.get("legacy_inactive_cards_total", 0)), 15)

func test_card_impact_matrix_fails_when_active_count_is_missing() -> void:
	var pack: Dictionary = _pack().duplicate(true)
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {})).duplicate(true)
	card_sets["expected_player_cards"] = 55
	pack["card_sets"] = card_sets
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), pack, PackedStringArray(["all"]))
	assert_false(bool(matrix.get("ok", true)))
	assert_string_contains("; ".join(Array(matrix.get("errors", []))), "Expected 55 player cards")

func test_card_impact_v3_matrix_uses_isolated_policy_and_target_capture() -> void:
	var case_data: Dictionary = _single_case_v3("arcano_choque")
	var target_capture: Dictionary = Dictionary(case_data.get("target_capture", {}))
	assert_eq(str(case_data.get("policy_id", "")), "card_focus_isolated")
	assert_eq(str(target_capture.get("mode", "")), "isolated_once")
	assert_true(bool(target_capture.get("stop_after_target", false)))

func test_card_focus_policy_prioritizes_target_when_legal() -> void:
	var case_data: Dictionary = _single_case("arcano_choque")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data, {"max_actions_per_turn": 1})
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_played", false)))
	var timeline: Array = Array(metrics.get("timeline", []))
	assert_gt(timeline.size(), 0)
	var played: Array = Array(Dictionary(timeline[0]).get("cards_played", []))
	assert_gt(played.size(), 0)
	assert_eq(str(Dictionary(played[0]).get("card_id", "")), "arcano_choque")
	assert_true(bool(metrics.get("card_effect_signature_present", false)), str(metrics.get("card_effect_signature_missing_reason", "")))

func test_battle_effect_signature_detects_damage_and_summon() -> void:
	var before_damage: Dictionary = _effect_snapshot(40, 40, [], [_slot("enemy_terra_elemental_areia", 2, 4, 4)])
	var after_damage: Dictionary = _effect_snapshot(40, 36, [], [_slot("enemy_terra_elemental_areia", 2, 1, 4)])
	var damage_sample: Dictionary = BattleEffectSignatureScript.build_sample("arcano_choque", {"owner": "inimigo", "hero": true}, before_damage, after_damage)
	assert_eq(int(damage_sample.get("enemy_hero_damage", 0)), 4)
	assert_eq(int(damage_sample.get("enemy_slot_damage_total", 0)), 3)
	assert_true(Array(damage_sample.get("families", [])).has("damage"))

	var before_summon: Dictionary = _effect_snapshot(40, 40, [null], [])
	var after_summon: Dictionary = _effect_snapshot(40, 40, [_slot("necro_esqueleto", 1, 3, 3, ["ressurgir"])], [])
	var summon_sample: Dictionary = BattleEffectSignatureScript.build_sample("necro_esqueleto", {"owner": "jogador", "slot": 0}, before_summon, after_summon)
	assert_eq(int(summon_sample.get("summons_created", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_count", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_slot_count", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_keyword_count", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_health_total", 0)), 3)
	assert_true(Array(summon_sample.get("families", [])).has("summon"))

func test_battle_effect_signature_detects_buff_control_and_economy() -> void:
	var before: Dictionary = _effect_snapshot(40, 40, [_slot("invocador_soldado", 2, 2, 2)], [_slot("enemy_terra_elemental_areia", 3, 4, 4)])
	var after: Dictionary = _effect_snapshot(40, 40, [_slot("invocador_soldado", 4, 4, 4, ["escudo"], 0, 0, 1, 0, 0)], [_slot("enemy_terra_elemental_areia", 2, 4, 4, [], 2, 1, 0, 2)], 14, 3, 4, 7, 2, 7)
	var sample: Dictionary = BattleEffectSignatureScript.build_sample("unit", {"owner": "jogador", "area": "board"}, before, after)
	assert_eq(int(sample.get("ally_attack_buff_total", 0)), 2)
	assert_eq(int(sample.get("ally_health_buff_total", 0)), 2)
	assert_eq(int(sample.get("shield_added_total", 0)), 1)
	assert_eq(int(sample.get("ally_keyword_gain_count", 0)), 1)
	assert_eq(int(sample.get("ally_shield_gain", 0)), 1)
	assert_eq(int(sample.get("enemy_attack_debuff_total", 0)), 1)
	assert_eq(int(sample.get("poison_added_total", 0)), 2)
	assert_eq(int(sample.get("enemy_poison_added", 0)), 2)
	assert_eq(int(sample.get("freeze_added_total", 0)), 1)
	assert_eq(int(sample.get("enemy_frozen_added", 0)), 1)
	assert_eq(int(sample.get("enemy_snared_added", 0)), 2)
	assert_eq(int(sample.get("mana_gained", 0)), 4)
	assert_eq(int(sample.get("ashes_gained", 0)), 3)
	assert_eq(int(sample.get("cards_drawn", 0)), 1)
	assert_eq(int(sample.get("deck_delta", 0)), -1)
	assert_eq(int(sample.get("hand_delta", 0)), 1)
	assert_eq(int(sample.get("discard_delta", 0)), 1)

func test_battle_effect_signature_detects_temporary_ability_power() -> void:
	var before: Dictionary = _effect_snapshot(40, 40, [], [], 10, 0, 3, 8, 1, 3, 0)
	var after: Dictionary = _effect_snapshot(40, 40, [], [], 10, 0, 3, 8, 2, 4, 2)
	var sample: Dictionary = BattleEffectSignatureScript.build_sample("arcano_acelerar_lvl2", {"owner": "jogador"}, before, after)
	assert_eq(int(sample.get("temporary_ability_power_delta", 0)), 2)
	assert_eq(int(sample.get("temporary_ability_power_gained", 0)), 2)
	assert_eq(int(sample.get("temporary_ability_power_lost", 0)), 0)
	assert_true(Array(sample.get("families", [])).has("utility"))

func test_battle_effect_signature_aggregates_support_metadata() -> void:
	var sample: Dictionary = BattleEffectSignatureScript.build_sample(
		"invocador_promover",
		{"owner": "jogador", "slot": 0},
		_effect_snapshot(40, 40, [_slot("invocador_soldado", 2, 2, 2)], []),
		_effect_snapshot(40, 40, [_slot("invocador_soldado", 3, 3, 3)], [])
	)
	sample["focused_card_play_index"] = 1
	sample["support_cards_before_target"] = ["invocador_soldado"]
	sample["support_card_count_before_target"] = 1
	var signature: Dictionary = BattleEffectSignatureScript.aggregate("invocador_promover", [sample])
	assert_eq(str(signature.get("support_contamination_status", "")), "support_assisted")
	assert_eq(str(signature.get("signature_confidence", "")), "support_assisted")
	assert_eq(int(signature.get("support_card_count_before_target", 0)), 1)

func test_card_focus_policy_never_chooses_rejected_action() -> void:
	var case_data: Dictionary = _single_case("arcano_choque")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data, {"max_actions_per_turn": 8})
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_eq(Array(metrics.get("runner_warnings", [])).size(), 0)

func test_card_focus_isolated_policy_stops_after_target_once() -> void:
	var case_data: Dictionary = _single_case_v3("arcano_choque")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_played", false)))
	assert_eq(int(metrics.get("card_under_test_play_count", 0)), 1)
	assert_eq(int(metrics.get("target_card_play_count", 0)), 1)
	assert_true(bool(metrics.get("stopped_after_target", false)))
	assert_eq(str(metrics.get("capture_quality", "")), "clean")
	assert_eq(int(metrics.get("support_card_count_after_target", -1)), 0)
	var signature: Dictionary = Dictionary(metrics.get("card_effect_signature", {}))
	assert_eq(str(signature.get("capture_quality", "")), "clean")
	assert_eq(int(signature.get("target_card_play_count", 0)), 1)

func test_card_focus_isolated_policy_allows_minimum_support_before_target() -> void:
	var case_data: Dictionary = _single_case_v3("invocador_promover")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_played", false)))
	assert_eq(int(metrics.get("target_card_play_count", 0)), 1)
	assert_true(bool(metrics.get("stopped_after_target", false)))
	assert_eq(str(metrics.get("capture_quality", "")), "support_required")
	assert_gt(int(metrics.get("support_card_count_before_target", 0)), 0)
	assert_eq(int(metrics.get("support_card_count_after_target", -1)), 0)
	assert_true(Array(metrics.get("ambiguity_reasons", [])).has("support_before_target"))

func test_card_impact_runner_executes_player_case_and_records_card_under_test() -> void:
	var report: Dictionary = CardImpactRunnerScript.run_phase(ContentLibrary.get_catalog(), RunSession, _pack(), {
		"phase": "before",
		"components": PackedStringArray(["battle"]),
		"cards": PackedStringArray(["arcano_choque"]),
		"out": "user://card_impact/gut_player",
		"mode": "gate"
	})
	assert_true(bool(report.get("ok", false)), str(Dictionary(report.get("summary", {})).get("structural_errors", [])))
	var components: Array = Array(Dictionary(report.get("summary", {})).get("components", []))
	assert_eq(components.size(), 1)
	assert_eq(str(Dictionary(components[0]).get("status", "")), "PASS")

func test_card_impact_v2_runner_executes_player_case_and_records_effect_signature() -> void:
	var report: Dictionary = CardImpactRunnerScript.run_phase(ContentLibrary.get_catalog(), RunSession, _pack_v2(), {
		"phase": "before",
		"components": PackedStringArray(["battle"]),
		"cards": PackedStringArray(["arcano_choque"]),
		"out": "user://card_impact/gut_v2_player",
		"mode": "gate"
	})
	assert_true(bool(report.get("ok", false)), str(Dictionary(report.get("summary", {})).get("structural_errors", [])))
	var components: Array = Array(Dictionary(report.get("summary", {})).get("components", []))
	assert_eq(components.size(), 1)
	assert_eq(str(Dictionary(components[0]).get("status", "")), "PASS")
	var signature_quality: Dictionary = Dictionary(Dictionary(components[0]).get("signature_quality", {}))
	assert_eq(int(signature_quality.get("total", 0)), 1)

func test_card_impact_v3_runner_records_target_capture_quality() -> void:
	var report: Dictionary = CardImpactRunnerScript.run_phase(ContentLibrary.get_catalog(), RunSession, _pack_v3(), {
		"phase": "before",
		"components": PackedStringArray(["battle"]),
		"cards": PackedStringArray(["arcano_choque"]),
		"out": "user://card_impact/gut_v3_player",
		"mode": "gate"
	})
	assert_true(bool(report.get("ok", false)), str(Dictionary(report.get("summary", {})).get("blocking_changes", [])))
	var components: Array = Array(Dictionary(report.get("summary", {})).get("components", []))
	var signature_quality: Dictionary = Dictionary(Dictionary(components[0]).get("signature_quality", {}))
	assert_eq(int(signature_quality.get("total", 0)), 1)
	assert_eq(int(signature_quality.get("capture_clean_count", 0)), 1)
	assert_eq(int(signature_quality.get("repeated_target_count", 0)), 0)

func test_card_impact_v4_runner_records_temporary_ability_power_signature() -> void:
	var case_data: Dictionary = _single_case_v4("arcano_acelerar_lvl2")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_effect_signature_present", false)), str(metrics.get("card_effect_signature_missing_reason", "")))
	var signature: Dictionary = Dictionary(metrics.get("card_effect_signature", {}))
	assert_eq(int(signature.get("temporary_ability_power_gained", 0)), 2)
	assert_true(Array(signature.get("families", [])).has("utility"))

func test_card_impact_v3_enemy_case_stays_report_only_for_target_capture() -> void:
	var report: Dictionary = CardImpactRunnerScript.run_phase(ContentLibrary.get_catalog(), RunSession, _pack_v3(), {
		"phase": "before",
		"components": PackedStringArray(["battle"]),
		"cards": PackedStringArray(["enemy_terra_elemental_areia"]),
		"out": "user://card_impact/gut_v3_enemy",
		"mode": "gate"
	})
	assert_true(bool(report.get("ok", false)), str(Dictionary(report.get("summary", {})).get("blocking_changes", [])))
	var components: Array = Array(Dictionary(report.get("summary", {})).get("components", []))
	var signature_quality: Dictionary = Dictionary(Dictionary(components[0]).get("signature_quality", {}))
	assert_eq(int(signature_quality.get("missing_count", 0)), 1)
	assert_eq(int(signature_quality.get("capture_failed_count", 0)), 0)

func test_card_impact_v2_runner_marks_support_assisted_signature() -> void:
	var case_data: Dictionary = _single_case_v2("invocador_promover")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_played", false)))
	assert_true(bool(metrics.get("card_effect_signature_present", false)), str(metrics.get("card_effect_signature_missing_reason", "")))
	assert_eq(str(metrics.get("support_contamination_status", "")), "support_assisted")
	assert_gt(int(metrics.get("support_card_count_before_target", 0)), 0)
	var signature: Dictionary = Dictionary(metrics.get("card_effect_signature", {}))
	assert_eq(str(signature.get("support_contamination_status", "")), "support_assisted")

func test_card_impact_runner_executes_enemy_case_and_records_participation() -> void:
	var case_data: Dictionary = _single_case("enemy_terra_elemental_areia")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_seen", false)))
	assert_true(bool(metrics.get("card_under_test_participated", false)))

func test_card_impact_filters_player_enemy_and_id() -> void:
	var player_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["player"]))
	assert_eq(Array(player_matrix.get("player_cards", [])).size(), 54)
	assert_eq(Array(player_matrix.get("enemy_cards", [])).size(), 0)
	var enemy_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["enemy"]))
	assert_eq(Array(enemy_matrix.get("player_cards", [])).size(), 0)
	assert_eq(Array(enemy_matrix.get("enemy_cards", [])).size(), 30)
	var id_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["arcano_choque"]))
	assert_eq(Array(id_matrix.get("player_cards", [])).size(), 1)
	assert_eq(Array(id_matrix.get("enemy_cards", [])).size(), 0)
	assert_eq(Array(id_matrix.get("cases", [])).size(), 1)

func test_card_impact_v4_filters_player_enemy_and_reward_id() -> void:
	var player_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4(), PackedStringArray(["player"]))
	assert_eq(Array(player_matrix.get("player_cards", [])).size(), 108)
	assert_eq(Array(player_matrix.get("enemy_cards", [])).size(), 0)
	var enemy_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4(), PackedStringArray(["enemy"]))
	assert_eq(Array(enemy_matrix.get("player_cards", [])).size(), 0)
	assert_eq(Array(enemy_matrix.get("enemy_cards", [])).size(), 30)
	var id_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4(), PackedStringArray(["arcano_vortice"]))
	assert_eq(Array(id_matrix.get("player_cards", [])).size(), 1)
	assert_eq(str(Dictionary(Array(id_matrix.get("player_cards", []))[0]).get("source", "")), "reward")
	assert_eq(Array(id_matrix.get("cases", [])).size(), 1)

func test_card_impact_v4_1_filters_player_enemy_and_card_flow_id() -> void:
	var player_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_1(), PackedStringArray(["player"]))
	assert_eq(Array(player_matrix.get("player_cards", [])).size(), 108)
	assert_eq(Array(player_matrix.get("enemy_cards", [])).size(), 0)
	var enemy_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_1(), PackedStringArray(["enemy"]))
	assert_eq(Array(enemy_matrix.get("player_cards", [])).size(), 0)
	assert_eq(Array(enemy_matrix.get("enemy_cards", [])).size(), 30)
	var id_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_1(), PackedStringArray(["necro_colheita_das_almas"]))
	assert_eq(Array(id_matrix.get("player_cards", [])).size(), 1)
	assert_eq(str(Dictionary(Array(id_matrix.get("player_cards", []))[0]).get("effect_family", "")), "card_flow")
	assert_eq(Array(id_matrix.get("cases", [])).size(), 1)

func test_card_impact_v4_1_runner_observes_base_card_flow() -> void:
	var case_data: Dictionary = _single_case_v4_1("necro_colheita_das_almas")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_effect_signature_present", false)), str(metrics.get("card_effect_signature_missing_reason", "")))
	var signature: Dictionary = Dictionary(metrics.get("card_effect_signature", {}))
	assert_eq(int(signature.get("cards_drawn", 0)), 2)
	assert_eq(int(signature.get("deck_delta", 0)), -2)
	assert_true(bool(signature.get("card_flow_expected", false)))
	assert_true(bool(signature.get("card_flow_observed", false)))
	assert_true(Array(signature.get("families", [])).has("card_flow"))

func test_card_impact_v4_1_runner_observes_lvl2_card_flow() -> void:
	var case_data: Dictionary = _single_case_v4_1("necro_colheita_das_almas_lvl2")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_effect_signature_present", false)), str(metrics.get("card_effect_signature_missing_reason", "")))
	var signature: Dictionary = Dictionary(metrics.get("card_effect_signature", {}))
	assert_eq(int(signature.get("ashes_gained", 0)), 3)
	assert_eq(int(signature.get("cards_drawn", 0)), 2)
	assert_eq(int(signature.get("deck_delta", 0)), -2)
	assert_true(bool(signature.get("card_flow_expected", false)))
	assert_true(bool(signature.get("card_flow_observed", false)))

func test_card_impact_v4_1_runner_observes_lvl3_card_flow_with_lab_prestate() -> void:
	var case_data: Dictionary = _single_case_v4_1("necro_colheita_das_almas_lvl3")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_eq(int(metrics.get("initial_dead_unit_count", 0)), 2)
	var signature: Dictionary = Dictionary(metrics.get("card_effect_signature", {}))
	assert_eq(int(signature.get("ashes_gained", 0)), 6)
	assert_eq(int(signature.get("cards_drawn", 0)), 2)
	assert_eq(int(signature.get("deck_delta", 0)), -2)
	assert_true(bool(signature.get("card_flow_observed", false)))

func test_card_flow_expectation_evaluator_passes_current_colheita_signature() -> void:
	var summary: Dictionary = CardFlowExpectationEvaluatorScript.evaluate_records(
		_pack_v4_2(),
		[_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 2, true, 1))],
		{"card_ids": PackedStringArray(["necro_colheita_das_almas"])}
	)
	assert_eq(int(summary.get("pass_count", 0)), 7)
	assert_eq(int(summary.get("warn_count", 0)), 0)
	assert_eq(int(summary.get("fail_count", 0)), 0)

func test_card_flow_expectation_evaluator_fails_when_cards_drawn_regresses() -> void:
	var summary: Dictionary = CardFlowExpectationEvaluatorScript.evaluate_records(
		_pack_v4_2(),
		[_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 1, true, 1))],
		{"card_ids": PackedStringArray(["necro_colheita_das_almas"])}
	)
	assert_gt(int(summary.get("required_fail_count", 0)), 0)
	assert_gt(int(summary.get("fail_count", 0)), 0)

func test_card_flow_expectation_evaluator_fails_when_deck_delta_regresses() -> void:
	var summary: Dictionary = CardFlowExpectationEvaluatorScript.evaluate_records(
		_pack_v4_2(),
		[_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 2, true, 1, -1))],
		{"card_ids": PackedStringArray(["necro_colheita_das_almas"])}
	)
	assert_gt(int(summary.get("required_fail_count", 0)), 0)

func test_card_flow_expectation_evaluator_marks_watch_without_fail() -> void:
	var summary: Dictionary = CardFlowExpectationEvaluatorScript.evaluate_records(
		_pack_v4_2(),
		[_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 3, true, 1))],
		{"card_ids": PackedStringArray(["necro_colheita_das_almas"])}
	)
	assert_eq(int(summary.get("fail_count", 0)), 0)
	assert_gt(int(summary.get("warn_count", 0)), 0)

func test_card_impact_compare_same_same_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_same"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_eq(Array(summary.get("metric_changes", [])).size(), 0)

func test_card_impact_compare_new_fail_is_not_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_fail"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "FAIL", 12)])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_false(bool(summary.get("gate_ok", true)))
	assert_eq(int(summary.get("new_failure_count", 0)), 1)

func test_card_impact_compare_metric_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 7)])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_gt(Array(summary.get("metric_changes", [])).size(), 0)

func test_card_impact_compare_effect_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_effect_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12, _effect_signature("arcano_choque", 3))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12, _effect_signature("arcano_choque", 4))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v2(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_gt(Array(summary.get("effect_changes", [])).size(), 0)
	assert_gt(Array(summary.get("top_effect_delta_cards", [])).size(), 0)

func test_card_impact_compare_non_damage_effect_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_non_damage_effect_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_esqueleto", "PASS", 12, _summon_effect_signature("necro_esqueleto", 2))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_esqueleto", "PASS", 12, _summon_effect_signature("necro_esqueleto", 4))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v2(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_gt(Array(summary.get("effect_changes", [])).size(), 0)
	assert_true(Dictionary(summary.get("by_effect_family", {})).has("summon"))

func test_card_impact_v3_compare_repeated_target_capture_is_gate_blocker() -> void:
	var out_dir: String = "user://card_impact/gut_compare_repeated_target"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12, _target_capture_signature("arcano_choque", 1, "clean"))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12, _target_capture_signature("arcano_choque", 2, "ambiguous"))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v3(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_false(bool(summary.get("gate_ok", true)))
	assert_gt(int(Dictionary(summary.get("signature_quality", {})).get("repeated_target_count", 0)), 0)
	assert_string_contains("; ".join(Array(summary.get("blocking_changes", []))), "focused card more than once")

func test_card_impact_v4_compare_utility_effect_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_utility_effect_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_acelerar_lvl2", "PASS", 12, _utility_effect_signature("arcano_acelerar_lvl2", 3))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_acelerar_lvl2", "PASS", 12, _utility_effect_signature("arcano_acelerar_lvl2", 2))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_true(Dictionary(summary.get("by_effect_family", {})).has("utility"))
	assert_gt(Array(summary.get("effect_changes", [])).size(), 0)

func test_card_impact_v4_compare_same_same_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_v4_same"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_vortice", "PASS", 12, _target_capture_signature("arcano_vortice", 1, "clean"))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_vortice", "PASS", 12, _target_capture_signature("arcano_vortice", 1, "clean"))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_eq(Array(summary.get("effect_changes", [])).size(), 0)

func test_card_impact_v4_1_compare_same_same_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_v4_1_same"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 1, true))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 1, true))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4_1(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_eq(int(Dictionary(summary.get("signature_quality", {})).get("card_flow_observed_count", 0)), 1)

func test_card_impact_v4_1_gate_blocks_missing_card_flow_observation() -> void:
	var out_dir: String = "user://card_impact/gut_compare_v4_1_missing_card_flow"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 1, true))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 0, false))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4_1(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_false(bool(summary.get("gate_ok", true)))
	assert_gt(int(Dictionary(summary.get("signature_quality", {})).get("card_flow_missing_count", 0)), 0)

func test_card_impact_v4_1_compare_card_flow_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_v4_1_card_flow_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 1, true))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", 2, true))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4_1(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_true(Dictionary(summary.get("by_effect_family", {})).has("card_flow"))
	assert_gt(Array(summary.get("effect_changes", [])).size(), 0)
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "Card Flow Coverage")
	assert_string_contains(markdown, "effect.cards_drawn")

func test_card_impact_v4_2_compare_same_same_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_v4_2_same"
	var records: Array = _v4_2_card_flow_records(2, true, 1)
	_write_battle_payload("%s/before/battle" % out_dir, records)
	_write_battle_payload("%s/after/battle" % out_dir, records)
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4_2(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var expectations: Dictionary = Dictionary(summary.get("card_flow_expectations", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_eq(int(expectations.get("pass_count", 0)), 21)
	assert_eq(int(expectations.get("fail_count", 0)), 0)

func test_card_impact_v4_2_compare_card_flow_delta_that_meets_required_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_v4_2_card_flow_watch"
	_write_battle_payload("%s/before/battle" % out_dir, _v4_2_card_flow_records(2, true, 1))
	_write_battle_payload("%s/after/battle" % out_dir, _v4_2_card_flow_records(3, true, 1))
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4_2(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var expectations: Dictionary = Dictionary(summary.get("card_flow_expectations", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_eq(int(expectations.get("fail_count", 0)), 0)
	assert_gt(int(expectations.get("warn_count", 0)), 0)
	assert_gt(Array(summary.get("effect_changes", [])).size(), 0)

func test_card_impact_v4_2_compare_after_required_regression_fails_gate() -> void:
	var out_dir: String = "user://card_impact/gut_compare_v4_2_card_flow_fail"
	_write_battle_payload("%s/before/battle" % out_dir, _v4_2_card_flow_records(2, true, 1))
	_write_battle_payload("%s/after/battle" % out_dir, _v4_2_card_flow_records(1, true, 1))
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v4_2(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var expectations: Dictionary = Dictionary(summary.get("card_flow_expectations", {}))
	assert_false(bool(summary.get("gate_ok", true)))
	assert_gt(int(expectations.get("required_fail_count", 0)), 0)
	assert_string_contains("; ".join(Array(summary.get("blocking_changes", []))), "required card-flow expectations")

func test_card_impact_reporter_markdown_contains_impact_matrix() -> void:
	var report: Dictionary = {
		"phase": "compare",
		"pack_id": "unit",
		"summary": {
			"gate_ok": true,
			"coverage": {
				"expected_active_cards": 84,
				"covered_active_cards": 84,
				"expected_player_cards": 54,
				"expected_enemy_cards": 30,
				"expected_legacy_inactive_cards": 15,
				"filtered_player_cards": 54,
				"filtered_enemy_cards": 30,
				"player_cards_total": 54,
				"enemy_cards_total": 30,
				"legacy_inactive_cards_total": 15
			},
			"structural_errors": [],
			"components": [{"component": "battle", "status": "PASS", "pass_count": 1, "warn_count": 0, "fail_count": 0}],
			"top_impacted_cards": [{"card_id": "arcano_choque", "change_count": 1, "metric_change_count": 1, "status_change_count": 0}],
			"status_changes": [],
			"metric_changes": [],
			"blocking_changes": []
		}
	}
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "Impact Matrix")
	assert_string_contains(markdown, "Top Impacted Cards")
	assert_string_contains(markdown, "arcano_choque")

func test_card_impact_reporter_markdown_contains_effect_delta_sections() -> void:
	var report: Dictionary = {
		"phase": "compare",
		"pack_id": "unit_v2",
		"summary": {
			"gate_ok": true,
			"coverage": {
				"expected_active_cards": 84,
				"covered_active_cards": 84,
				"expected_player_cards": 54,
				"expected_enemy_cards": 30,
				"expected_legacy_inactive_cards": 15,
				"filtered_player_cards": 54,
				"filtered_enemy_cards": 30,
				"player_cards_total": 54,
				"enemy_cards_total": 30,
				"legacy_inactive_cards_total": 15
			},
			"structural_errors": [],
			"components": [{"component": "battle", "status": "PASS", "pass_count": 1, "warn_count": 0, "fail_count": 0}],
			"top_impacted_cards": [],
			"top_effect_delta_cards": [{"card_id": "arcano_choque", "change_count": 1}],
			"by_effect_family": {"damage": {"change_count": 1, "fields": {"enemy_hero_damage": 1}}},
			"effect_changes": [{"id": "card_impact_player_arcano_choque", "field": "effect.enemy_hero_damage", "before": 3, "after": 4, "delta": 1}],
			"missing_signatures": [],
			"signature_quality": {
				"capture_clean_count": 1,
				"capture_support_required_count": 0,
				"capture_ambiguous_count": 0,
				"capture_failed_count": 0,
				"repeated_target_count": 0,
				"cases": []
			},
			"status_changes": [],
			"metric_changes": [],
			"blocking_changes": []
		}
	}
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "Player Effect Deltas")
	assert_string_contains(markdown, "Effect Family Matrix")
	assert_string_contains(markdown, "Non-Damage Coverage Matrix")
	assert_string_contains(markdown, "Support Contamination")
	assert_string_contains(markdown, "Target Capture Quality")
	assert_string_contains(markdown, "Top Effect Delta Cards")

func test_card_impact_reporter_markdown_contains_v4_full_coverage_and_utility() -> void:
	var report: Dictionary = {
		"phase": "compare",
		"pack_id": "unit_v4",
		"summary": {
			"gate_ok": true,
			"coverage": {
				"expected_active_cards": 138,
				"covered_active_cards": 138,
				"expected_player_cards": 108,
				"expected_enemy_cards": 30,
				"expected_legacy_inactive_cards": 15,
				"filtered_player_cards": 108,
				"filtered_enemy_cards": 30,
				"player_cards_total": 108,
				"enemy_cards_total": 30,
				"legacy_inactive_cards_total": 15,
				"filtered_player_cards_by_class": {"arcano": 36, "invocador": 36, "necromante": 36},
				"filtered_player_cards_by_source": {"starter": 27, "core_cost2": 9, "reward": 72}
			},
			"structural_errors": [],
			"components": [{"component": "battle", "status": "PASS", "pass_count": 1, "warn_count": 0, "fail_count": 0}],
			"effect_changes": [{"id": "card_impact_player_arcano_acelerar_lvl2", "field": "effect.temporary_ability_power_gained", "before": 3, "after": 2, "delta": -1}],
			"top_impacted_cards": [],
			"top_effect_delta_cards": [],
			"by_effect_family": {"utility": {"change_count": 1, "fields": {"temporary_ability_power_gained": 1}}},
			"signature_quality": {},
			"status_changes": [],
			"metric_changes": [],
			"blocking_changes": []
		}
	}
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "138/138")
	assert_string_contains(markdown, "108/30/15")
	assert_string_contains(markdown, "By class")
	assert_string_contains(markdown, "reward:72")
	assert_string_contains(markdown, "Utility Effect Deltas")
	assert_string_contains(markdown, "temporary_ability_power_gained")

func test_card_impact_reporter_markdown_contains_card_flow_coverage() -> void:
	var report: Dictionary = {
		"phase": "compare",
		"pack_id": "unit_v4_1",
		"summary": {
			"gate_ok": true,
			"coverage": {
				"expected_active_cards": 138,
				"covered_active_cards": 138,
				"expected_player_cards": 108,
				"expected_enemy_cards": 30,
				"expected_legacy_inactive_cards": 15,
				"expected_card_flow_player_cards": 3,
				"filtered_player_cards": 108,
				"filtered_enemy_cards": 30,
				"filtered_card_flow_player_cards": 3,
				"player_cards_total": 108,
				"enemy_cards_total": 30,
				"legacy_inactive_cards_total": 15
			},
			"structural_errors": [],
			"components": [{"component": "battle", "status": "PASS", "pass_count": 1, "warn_count": 0, "fail_count": 0}],
			"effect_changes": [{"id": "card_impact_player_necro_colheita_das_almas", "field": "effect.cards_drawn", "before": 1, "after": 2, "delta": 1}],
			"signature_quality": {
				"card_flow_expected_count": 3,
				"card_flow_observed_count": 2,
				"card_flow_missing_count": 0,
				"card_flow_cases": []
			},
			"top_impacted_cards": [],
			"top_effect_delta_cards": [],
			"by_effect_family": {"card_flow": {"change_count": 1, "fields": {"cards_drawn": 1}}},
			"status_changes": [],
			"metric_changes": [],
			"blocking_changes": []
		}
	}
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "Card Flow Coverage")
	assert_string_contains(markdown, "effect.cards_drawn")

func test_card_impact_reporter_markdown_contains_card_flow_expectations() -> void:
	var report: Dictionary = {
		"phase": "compare",
		"pack_id": "unit_v4_2",
		"summary": {
			"gate_ok": true,
			"coverage": {
				"expected_active_cards": 138,
				"covered_active_cards": 138,
				"expected_player_cards": 108,
				"expected_enemy_cards": 30,
				"expected_legacy_inactive_cards": 15,
				"expected_card_flow_player_cards": 3,
				"filtered_player_cards": 108,
				"filtered_enemy_cards": 30,
				"filtered_card_flow_player_cards": 3,
				"player_cards_total": 108,
				"enemy_cards_total": 30,
				"legacy_inactive_cards_total": 15
			},
			"structural_errors": [],
			"components": [{"component": "battle", "status": "PASS", "pass_count": 1, "warn_count": 0, "fail_count": 0}],
			"effect_changes": [{"id": "card_impact_player_necro_colheita_das_almas", "field": "effect.cards_drawn", "before": 1, "after": 2, "delta": 1}],
			"signature_quality": {},
			"card_flow_expectations": {
				"enabled": true,
				"total_count": 1,
				"pass_count": 1,
				"warn_count": 0,
				"fail_count": 0,
				"results": [{"card_id": "necro_colheita_das_almas", "field": "cards_drawn", "op": ">=", "expected": 2, "actual": 2, "severity": "required", "status": "PASS"}]
			},
			"top_impacted_cards": [],
			"top_effect_delta_cards": [],
			"by_effect_family": {"card_flow": {"change_count": 1, "fields": {"cards_drawn": 1}}},
			"status_changes": [],
			"metric_changes": [],
			"blocking_changes": []
		}
	}
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "Card Flow Expectations")
	assert_string_contains(markdown, "necro_colheita_das_almas")

func _pack() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v1")

func _pack_v2() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v2")

func _pack_v3() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v3")

func _pack_v4() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v4")

func _pack_v4_1() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v4_1")

func _pack_v4_2() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v4_2")

func _single_case(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _single_case_v2(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v2(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _single_case_v3(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v3(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _single_case_v4(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _single_case_v4_1(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_1(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _single_case_v4_2(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v4_2(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _fake_battle_record(case_id: String, status: String, enemy_hp: int, effect_signature: Dictionary = {}) -> Dictionary:
	return {
		"schema_version": 1,
		"tool": "gameplay_battle_lab",
		"case": {
			"id": case_id,
			"name": case_id
		},
		"result": {
			"case_id": case_id,
			"outcome": "",
			"terminated": false,
			"turn_count": 1,
			"combat_cycles": 1,
			"player_hp": 40,
			"enemy_hp": enemy_hp,
			"cards_played": 1,
			"player_units_alive": 1,
			"enemy_units_alive": 1,
			"damage_to_enemy_hero": 0,
			"damage_to_player_hero": 0,
			"card_effect_signature": effect_signature
		},
		"timeline": [],
		"expectations": [],
		"warnings": [],
		"tags": ["card_impact", "card_under_test"],
		"status": status
	}

func _write_battle_payload(dir_path: String, records: Array) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))
	var file: FileAccess = FileAccess.open("%s/battle_results.json" % dir_path, FileAccess.WRITE)
	assert_not_null(file)
	file.store_string(JSON.stringify({"records": records}, "\t"))
	file.close()

func _effect_snapshot(player_hp: int, enemy_hp: int, player_slots: Array, enemy_slots: Array, mana: int = 10, ashes: int = 0, hand_size: int = 3, deck_size: int = 8, discard_size: int = 1, log_count: int = 3, temporary_ability_power: int = 0) -> Dictionary:
	return {
		"player_health": player_hp,
		"enemy_health": enemy_hp,
		"mana": mana,
		"ashes": ashes,
		"temporary_ability_power": temporary_ability_power,
		"hand_size": hand_size,
		"deck_size": deck_size,
		"discard_size": discard_size,
		"pending_choice_count": 0,
		"log_count": log_count,
		"visual_event_count": 0,
		"player_slots": player_slots,
		"enemy_slots": enemy_slots
	}

func _slot(card_id: String, attack: int, health: int, max_health: int, keywords: Array = [], poison: int = 0, frozen: int = 0, shield: int = 0, slow: int = 0, resistance: int = 0) -> Dictionary:
	return {
		"card_id": card_id,
		"name": card_id,
		"attack": attack,
		"health": health,
		"max_health": max_health,
		"keywords": keywords,
		"poison_amount": poison,
		"frozen_turns": frozen,
		"shield_charges": shield,
		"slow_turns": slow,
		"resistance_amount": resistance,
		"resistance_remaining": resistance
	}

func _effect_signature(card_id: String, enemy_hero_damage: int) -> Dictionary:
	return {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"enemy_hero_damage": enemy_hero_damage,
		"families": ["damage"],
		"keywords_added": {},
		"keywords_removed": {}
	}

func _target_capture_signature(card_id: String, target_count: int, capture_quality: String) -> Dictionary:
	return {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"enemy_hero_damage": 3,
		"families": ["damage"],
		"support_contamination_status": "clean" if capture_quality == "clean" else "support_assisted",
		"signature_confidence": "clean" if capture_quality == "clean" else "ambiguous",
		"capture_quality": capture_quality,
		"target_card_play_count": target_count,
		"target_card_first_play_turn": 1,
		"target_card_first_play_cycle": 1,
		"stopped_after_target": true,
		"target_capture_mode": "isolated_once",
		"ambiguity_reasons": [] if capture_quality == "clean" else ["target_played_multiple_times"],
		"keywords_added": {},
		"keywords_removed": {}
	}

func _summon_effect_signature(card_id: String, summoned_attack_total: int) -> Dictionary:
	return {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"summons_created": 1,
		"summoned_count": 1,
		"summoned_attack_total": summoned_attack_total,
		"families": ["summon"],
		"keywords_added": {},
		"keywords_removed": {}
	}

func _utility_effect_signature(card_id: String, temporary_ability_power_gained: int) -> Dictionary:
	return {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"temporary_ability_power_delta": temporary_ability_power_gained,
		"temporary_ability_power_gained": temporary_ability_power_gained,
		"temporary_ability_power_lost": 0,
		"families": ["utility"],
		"keywords_added": {},
		"keywords_removed": {},
		"support_contamination_status": "clean",
		"signature_confidence": "clean",
		"capture_quality": "clean",
		"target_card_play_count": 1,
		"target_capture_mode": "isolated_once"
	}

func _v4_2_card_flow_records(cards_drawn: int, observed: bool, hand_delta: int) -> Array:
	return [
		_fake_battle_record("card_impact_player_necro_colheita_das_almas", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas", cards_drawn, observed, hand_delta)),
		_fake_battle_record("card_impact_player_necro_colheita_das_almas_lvl2", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas_lvl2", cards_drawn, observed, hand_delta)),
		_fake_battle_record("card_impact_player_necro_colheita_das_almas_lvl3", "PASS", 12, _card_flow_effect_signature("necro_colheita_das_almas_lvl3", cards_drawn, observed, hand_delta))
	]

func _card_flow_effect_signature(card_id: String, cards_drawn: int, observed: bool, hand_delta: int = 1, deck_delta: int = 2147483647) -> Dictionary:
	return {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"ashes_gained": 3,
		"cards_drawn": cards_drawn,
		"cards_discarded": 0,
		"cards_created": 0,
		"deck_delta": -cards_drawn if deck_delta == 2147483647 else deck_delta,
		"hand_delta": hand_delta,
		"discard_delta": 1,
		"card_flow_expected": true,
		"card_flow_observed": observed,
		"card_flow_missing_reason": "" if observed else "expected card-flow counters were not observed",
		"families": ["economy", "card_flow"],
		"keywords_added": {},
		"keywords_removed": {},
		"support_contamination_status": "clean",
		"signature_confidence": "clean",
		"capture_quality": "clean",
		"target_card_play_count": 1,
		"target_capture_mode": "isolated_once"
	}
