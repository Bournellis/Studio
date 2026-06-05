extends "res://tests/unit/draxos_test_base.gd"

const ScenarioEvaluatorScript = preload("res://tools/lab/scenario_evaluator.gd")
const ScenarioFixtureLoaderScript = preload("res://tools/lab/scenario_fixture_loader.gd")
const ScenarioReporterScript = preload("res://tools/lab/scenario_reporter.gd")
const ScenarioRunnerScript = preload("res://tools/lab/scenario_runner.gd")

func test_scenario_fixture_loader_loads_track02_core_pack() -> void:
	var load_result: Dictionary = ScenarioFixtureLoaderScript.load_pack_result("track02_core_v1")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_core_v1")
	assert_eq(str(pack.get("simulation_mode", "")), "macro_route_v1")
	assert_eq(Array(pack.get("scenarios", [])).size(), 12)

func test_scenario_fixture_loader_rejects_missing_required_fields() -> void:
	var invalid_pack: Dictionary = {
		"pack_id": "invalid",
		"schema_version": 1,
		"simulation_mode": "macro_route_v1",
		"scenarios": [
			{
				"name": "Missing id",
				"tags": ["route"],
				"class_id": "arcano",
				"seed": 20260518,
				"policy_id": "baseline",
				"focus": "Invalid fixture",
				"expectations": {}
			}
		]
	}
	var validation: Dictionary = ScenarioFixtureLoaderScript.validate_pack_result(invalid_pack, "memory://invalid")
	assert_false(bool(validation.get("ok", true)))
	assert_string_contains(str(validation.get("message", "")), "missing `id`")

func test_scenario_runner_executes_baseline_with_timeline() -> void:
	var pack: Dictionary = ScenarioFixtureLoaderScript.load_pack("track02_core_v1")
	var scenarios: Array[Dictionary] = ScenarioFixtureLoaderScript.scenarios_for(pack, "route_baseline_arcano_seed_20260518")
	assert_eq(scenarios.size(), 1)
	var run_result: Dictionary = ScenarioRunnerScript.run_scenarios(RunSession, ContentLibrary.get_catalog(), pack, scenarios)
	assert_true(bool(run_result.get("ok", false)))
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	assert_eq(records.size(), 1)
	var record: Dictionary = records[0]
	assert_eq(str(record.get("status", "")), ScenarioEvaluatorScript.STATUS_PASS)
	assert_eq(Array(record.get("timeline", [])).size(), 29)

func test_scenario_evaluator_marks_pass() -> void:
	var scenario: Dictionary = {
		"expectations": {
			"required": {
				"complete_route": true,
				"no_deaths": true,
				"final_hp_min": 10,
				"map_checkpoints": [
					{"map": 8, "hp_after_min": 5}
				]
			}
		}
	}
	var evaluation: Dictionary = ScenarioEvaluatorScript.evaluate(scenario, _fake_metrics(13, 0, 38, 21, 71))
	assert_eq(str(evaluation.get("status", "")), ScenarioEvaluatorScript.STATUS_PASS)
	assert_true(bool(evaluation.get("ok", false)))

func test_scenario_evaluator_marks_warn_without_failure() -> void:
	var scenario: Dictionary = {
		"expectations": {
			"required": {
				"complete_route": true
			},
			"watch": {
				"no_deaths": true,
				"final_hp_min": 10
			}
		}
	}
	var evaluation: Dictionary = ScenarioEvaluatorScript.evaluate(scenario, _fake_metrics(3, 2, 38, 0, 362))
	assert_eq(str(evaluation.get("status", "")), ScenarioEvaluatorScript.STATUS_WARN)
	assert_true(bool(evaluation.get("ok", false)))
	assert_gt(Array(evaluation.get("warnings", [])).size(), 0)

func test_scenario_evaluator_marks_fail_and_gate_summary_is_not_ok() -> void:
	var scenario: Dictionary = {
		"id": "forced_fail",
		"class_id": "arcano",
		"policy_id": "baseline",
		"tags": ["unit"],
		"expectations": {
			"required": {
				"complete_route": true,
				"final_hp_min": 99
			}
		}
	}
	var metrics: Dictionary = _fake_metrics(13, 0, 38, 21, 71)
	var evaluation: Dictionary = ScenarioEvaluatorScript.evaluate(scenario, metrics)
	assert_eq(str(evaluation.get("status", "")), ScenarioEvaluatorScript.STATUS_FAIL)
	assert_false(bool(evaluation.get("ok", true)))
	var records: Array[Dictionary] = [{
		"scenario": scenario,
		"result": metrics,
		"timeline": Array(metrics.get("timeline", [])),
		"expectations": Array(evaluation.get("expectations", [])),
		"warnings": Array(evaluation.get("warnings", [])),
		"failures": Array(evaluation.get("failures", [])),
		"tags": ["unit"],
		"status": str(evaluation.get("status", ""))
	}]
	var summary: Dictionary = ScenarioRunnerScript.summarize(records, {"pack_id": "unit", "simulation_mode": "macro_route_v1"}, {"mode": "gate"})
	assert_eq(int(summary.get("fail_count", 0)), 1)

func test_scenario_loader_filters_by_scenario_id() -> void:
	var pack: Dictionary = ScenarioFixtureLoaderScript.load_pack("track02_core_v1")
	var scenarios: Array[Dictionary] = ScenarioFixtureLoaderScript.scenarios_for(pack, "shop_baseline_recovery_budget")
	assert_eq(scenarios.size(), 1)
	assert_eq(str(scenarios[0].get("id", "")), "shop_baseline_recovery_budget")

func test_scenario_loader_filters_by_tags() -> void:
	var pack: Dictionary = ScenarioFixtureLoaderScript.load_pack("track02_core_v1")
	var scenarios: Array[Dictionary] = ScenarioFixtureLoaderScript.scenarios_for(pack, "", PackedStringArray(["stress"]))
	assert_eq(scenarios.size(), 3)
	for scenario: Dictionary in scenarios:
		assert_true(Array(scenario.get("tags", [])).has("stress"))

func test_scenario_reporter_markdown_contains_status_matrix() -> void:
	var metrics: Dictionary = _fake_metrics(13, 0, 38, 21, 71)
	var record: Dictionary = {
		"scenario": {
			"id": "unit_pass",
			"name": "Unit pass",
			"class_id": "arcano",
			"policy_id": "baseline"
		},
		"result": metrics,
		"timeline": Array(metrics.get("timeline", [])),
		"expectations": [],
		"warnings": [],
		"failures": [],
		"tags": ["unit"],
		"status": ScenarioEvaluatorScript.STATUS_PASS
	}
	var records: Array[Dictionary] = [record]
	var summary: Dictionary = ScenarioRunnerScript.summarize(records, {"pack_id": "unit", "simulation_mode": "macro_route_v1"}, {"mode": "explore"})
	var markdown: String = ScenarioReporterScript.markdown(summary, records, {"command": "unit"})
	assert_string_contains(markdown, "Status Matrix")
	assert_string_contains(markdown, "PASS/WARN/FAIL")
	assert_string_contains(markdown, "unit_pass")

func _fake_metrics(final_hp: int, deaths: int, deck_size: int, shop_usage: int, souls_left: int) -> Dictionary:
	return {
		"ok": true,
		"completed_maps": 29,
		"map_count": 29,
		"final_hp": final_hp,
		"deaths": deaths,
		"deck_size": deck_size,
		"shop_usage": shop_usage,
		"souls_left": souls_left,
		"relic_count": 6,
		"timeline": [
			{"map": 8, "hp_after": 5, "hp_loss_est": 5},
			{"map": 29, "hp_after": final_hp, "hp_loss_est": 8}
		]
	}
