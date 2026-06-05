extends "res://tests/unit/draxos_test_base.gd"

const LabAggregatorScript = preload("res://tools/lab/lab_aggregator.gd")
const LabBaselineStoreScript = preload("res://tools/lab/lab_baseline_store.gd")
const LabCaseBuilderScript = preload("res://tools/lab/lab_case_builder.gd")
const LabRunnerScript = preload("res://tools/lab/lab_runner.gd")
const LabScorecardScript = preload("res://tools/lab/lab_scorecard.gd")
const RoutePacingSimulatorScript = preload("res://tools/route_pacing_simulator.gd")

func test_lab_case_builder_expands_seed_policy_matrix() -> void:
	var options: Dictionary = LabCaseBuilderScript.parse_options(PackedStringArray([
		"--preset=quick",
		"--seed-start=900",
		"--seed-count=2",
		"--policies=baseline,no_shop"
	]))
	assert_eq(str(options.get("preset", "")), "quick")
	assert_eq(PackedInt64Array(options.get("seeds", PackedInt64Array())).size(), 2)
	assert_eq(PackedStringArray(options.get("policies", PackedStringArray())).size(), 2)
	assert_eq(int(options.get("case_count", 0)), 12)
	var cases: Array[Dictionary] = LabCaseBuilderScript.build_cases(options)
	assert_eq(cases.size(), 12)
	assert_eq(str(cases[0].get("case_id", "")), "arcano:900:baseline")
	assert_eq(str(cases[1].get("case_id", "")), "arcano:900:no_shop")
	assert_eq(str(cases[1].get("shop_policy", "")), "none")

func test_route_pacing_simulator_supports_no_shop_policy_and_timeline() -> void:
	var simulator = RoutePacingSimulatorScript.new()
	var metrics: Dictionary = simulator.simulate_route(RunSession, ContentLibrary.get_catalog(), "arcano", 20260518, {
		"policy_id": "no_shop",
		"reward_policy": "baseline",
		"shop_policy": "none",
		"timeline": true
	})
	assert_true(bool(metrics.get("ok", false)), str(metrics.get("message", "")))
	assert_eq(str(metrics.get("policy_id", "")), "no_shop")
	assert_eq(int(metrics.get("shop_usage", -1)), 0)
	assert_eq(int(metrics.get("souls_spent", -1)), 0)
	assert_eq(Array(metrics.get("timeline", [])).size(), 29)
	var first_event: Dictionary = Dictionary(Array(metrics.get("timeline", []))[0])
	assert_eq(int(first_event.get("map", 0)), 1)
	assert_true(first_event.has("hp_before"))
	assert_true(first_event.has("hp_after"))

func test_lab_runner_and_aggregator_return_summary_by_class_and_policy() -> void:
	var options: Dictionary = LabCaseBuilderScript.parse_options(PackedStringArray([
		"--classes=arcano,invocador",
		"--seeds=20260518",
		"--policies=baseline,no_shop"
	]))
	var cases: Array[Dictionary] = LabCaseBuilderScript.build_cases(options)
	var run_result: Dictionary = LabRunnerScript.run_cases(RunSession, ContentLibrary.get_catalog(), cases, options)
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	assert_eq(records.size(), 4)
	var summary: Dictionary = LabAggregatorScript.aggregate(records, options)
	assert_eq(int(summary.get("total_runs", 0)), 4)
	assert_true(Dictionary(summary.get("by_class", {})).has("arcano"))
	assert_true(Dictionary(summary.get("by_policy", {})).has("baseline"))
	assert_true(Dictionary(summary.get("by_policy", {})).has("no_shop"))
	assert_gt(float(Dictionary(summary.get("averages", {})).get("deck_size", 0.0)), 0.0)
	var baseline_comparison: Dictionary = LabBaselineStoreScript.compare_summary(summary, {
		"baseline_id": "mixed_policy_unit_test",
		"summary_fields": {
			"victory_rate_min": 0.0,
			"completion_rate_min": 1.0,
			"avg_deck_size_min": 30.0,
			"avg_deck_size_max": 42.0,
			"avg_shop_usage_min": 0.0,
			"avg_shop_usage_max": 30.0
		}
	})
	assert_true(bool(baseline_comparison.get("ok", false)), LabBaselineStoreScript.format_comparison(baseline_comparison))

func test_lab_baseline_store_loads_official_quick_gate() -> void:
	var baseline: Dictionary = LabBaselineStoreScript.load_baseline("track02_quick_v1", "quick")
	assert_eq(str(baseline.get("baseline_id", "")), "track02_quick_v1")
	var summary: Dictionary = _quick_contract_summary()
	var comparison: Dictionary = LabBaselineStoreScript.compare_summary(summary, baseline)
	assert_true(bool(comparison.get("ok", false)), LabBaselineStoreScript.format_comparison(comparison))

func test_lab_baseline_store_reports_gate_failure() -> void:
	var baseline: Dictionary = LabBaselineStoreScript.load_baseline("track02_quick_v1", "quick")
	var summary: Dictionary = _quick_contract_summary()
	var averages: Dictionary = Dictionary(summary.get("averages", {}))
	averages["deck_size"] = 44.0
	summary["averages"] = averages
	var maxes: Dictionary = Dictionary(summary.get("maxes", {}))
	maxes["deck_size"] = 46.0
	summary["maxes"] = maxes
	var comparison: Dictionary = LabBaselineStoreScript.compare_summary(summary, baseline)
	assert_false(bool(comparison.get("ok", false)))
	assert_string_contains(LabBaselineStoreScript.format_comparison(comparison), "deck_size")

func test_lab_scorecard_builds_human_contract_report() -> void:
	var summary: Dictionary = _quick_contract_summary()
	var baseline: Dictionary = LabBaselineStoreScript.load_baseline("track02_quick_v1", "quick")
	var comparison: Dictionary = LabBaselineStoreScript.compare_summary(summary, baseline)
	var scorecard: Dictionary = LabScorecardScript.build(summary, comparison)
	assert_eq(str(Dictionary(scorecard.get("gate", {})).get("status", "")), "pass")
	assert_eq(Array(scorecard.get("class_rows", [])).size(), 3)
	assert_eq(Array(scorecard.get("policy_rows", [])).size(), 1)
	var markdown: String = LabScorecardScript.markdown(scorecard)
	assert_string_contains(markdown, "Class Matrix")
	assert_string_contains(markdown, "Policy Matrix")

func _quick_contract_summary() -> Dictionary:
	var arcano: Dictionary = _quick_group(10, 13.6, 38.3, 36.0, 41.0, 21.5, 52.5, 0.0)
	var invocador: Dictionary = _quick_group(10, 13.9, 38.3, 37.0, 41.0, 21.6, 50.5, 0.0)
	var necromante: Dictionary = _quick_group(10, 13.6, 37.0, 35.0, 38.0, 21.6, 47.0, 0.0)
	var baseline: Dictionary = _quick_group(30, 13.7, 37.8667, 35.0, 41.0, 21.5667, 50.0, 0.0)
	return {
		"total_runs": 30,
		"ok_runs": 30,
		"failed_runs": 0,
		"victories": 30,
		"victory_rate": 1.0,
		"completion_rate": 1.0,
		"preset": "quick",
		"simulation_mode": "macro_route_v1",
		"averages": baseline.get("averages", {}),
		"mins": baseline.get("mins", {}),
		"maxes": baseline.get("maxes", {}),
		"by_class": {
			"arcano": arcano,
			"invocador": invocador,
			"necromante": necromante
		},
		"by_policy": {
			"baseline": baseline
		},
		"risk_maps": [],
		"extremes": {
			"highest_deck_size": {"case_id": "arcano:20260524:baseline", "value": 41},
			"lowest_final_hp": {"case_id": "arcano:20260518:baseline", "value": 13}
		}
	}

func _quick_group(total_runs: int, avg_final_hp: float, avg_deck_size: float, min_deck_size: float, max_deck_size: float, avg_shop_usage: float, avg_souls_left: float, max_deaths: float) -> Dictionary:
	return {
		"total_runs": total_runs,
		"ok_runs": total_runs,
		"failed_runs": 0,
		"victories": total_runs,
		"victory_rate": 1.0,
		"completion_rate": 1.0,
		"averages": {
			"completed_maps": 29.0,
			"estimated_turns": 217.0,
			"final_hp": avg_final_hp,
			"deck_size": avg_deck_size,
			"relic_count": 6.5,
			"shop_usage": avg_shop_usage,
			"souls_left": avg_souls_left,
			"souls_spent": 312.0,
			"deaths": 0.0
		},
		"mins": {
			"completed_maps": 29.0,
			"final_hp": 13.0,
			"deck_size": min_deck_size,
			"souls_left": 26.0,
			"deaths": 0.0
		},
		"maxes": {
			"completed_maps": 29.0,
			"final_hp": 16.0,
			"deck_size": max_deck_size,
			"souls_spent": 336.0,
			"shop_usage": 22.0,
			"deaths": max_deaths
		}
	}
