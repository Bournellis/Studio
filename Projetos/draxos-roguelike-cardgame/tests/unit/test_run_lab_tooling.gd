extends "res://tests/unit/draxos_test_base.gd"

const LabAggregatorScript = preload("res://tools/lab/lab_aggregator.gd")
const LabBaselineStoreScript = preload("res://tools/lab/lab_baseline_store.gd")
const LabCaseBuilderScript = preload("res://tools/lab/lab_case_builder.gd")
const LabRunnerScript = preload("res://tools/lab/lab_runner.gd")
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
