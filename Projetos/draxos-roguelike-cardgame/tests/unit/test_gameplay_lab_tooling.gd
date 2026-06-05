extends "res://tests/unit/draxos_test_base.gd"

const BattleEvaluatorScript = preload("res://tools/lab/battle_evaluator.gd")
const BattleFixtureLoaderScript = preload("res://tools/lab/battle_fixture_loader.gd")
const BattlePolicyScript = preload("res://tools/lab/battle_policy.gd")
const BattleReporterScript = preload("res://tools/lab/battle_reporter.gd")
const BattleRunnerScript = preload("res://tools/lab/battle_runner.gd")

func test_battle_fixture_loader_loads_track02_core_pack() -> void:
	var load_result: Dictionary = BattleFixtureLoaderScript.load_pack_result("track02_battle_core_v1")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_battle_core_v1")
	assert_eq(str(pack.get("simulation_mode", "")), "battle_engine_v1")
	assert_eq(Array(pack.get("cases", [])).size(), 12)

func test_battle_fixture_loader_rejects_missing_required_fields() -> void:
	var invalid_pack: Dictionary = {
		"pack_id": "invalid",
		"schema_version": 1,
		"simulation_mode": "battle_engine_v1",
		"cases": [
			{
				"name": "Missing required fields",
				"tags": ["unit"],
				"seed": 20260518,
				"deck": [],
				"config": {},
				"turn_limit": 1
			}
		]
	}
	var validation: Dictionary = BattleFixtureLoaderScript.validate_pack_result(invalid_pack, "memory://invalid")
	assert_false(bool(validation.get("ok", true)))
	var message: String = str(validation.get("message", ""))
	assert_string_contains(message, "missing `id`")
	assert_string_contains(message, "missing `class_id`")
	assert_string_contains(message, "missing `encounter_id`")
	assert_string_contains(message, "missing `policy_id`")
	assert_string_contains(message, "missing `expectations`")

func test_battle_policy_never_chooses_rejected_action() -> void:
	var pack: Dictionary = BattleFixtureLoaderScript.load_pack("track02_battle_core_v1")
	var cases: Array[Dictionary] = BattleFixtureLoaderScript.cases_for(pack, "tutorial_arcano_baseline")
	assert_eq(cases.size(), 1)
	var case_data: Dictionary = cases[0]
	var engine = _engine_for_case(case_data)
	var policy_result: Dictionary = BattlePolicyScript.play_turn(engine, "baseline_legal", {"max_actions_per_turn": 8})
	assert_true(bool(policy_result.get("ok", false)), str(policy_result.get("failed_actions", [])))
	assert_eq(Array(policy_result.get("failed_actions", [])).size(), 0)
	assert_gt(Array(policy_result.get("cards_played", [])).size(), 0)

func test_battle_runner_executes_tutorial_baseline_with_timeline() -> void:
	var pack: Dictionary = BattleFixtureLoaderScript.load_pack("track02_battle_core_v1")
	var cases: Array[Dictionary] = BattleFixtureLoaderScript.cases_for(pack, "tutorial_arcano_baseline")
	var run_result: Dictionary = BattleRunnerScript.run_cases(ContentLibrary.get_catalog(), pack, cases)
	assert_true(bool(run_result.get("ok", false)))
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	assert_eq(records.size(), 1)
	var record: Dictionary = records[0]
	assert_eq(str(record.get("status", "")), BattleEvaluatorScript.STATUS_PASS)
	assert_gt(Array(record.get("timeline", [])).size(), 0)

func test_battle_runner_respects_turn_limit() -> void:
	var pack: Dictionary = BattleFixtureLoaderScript.load_pack("track02_battle_core_v1")
	var cases: Array[Dictionary] = BattleFixtureLoaderScript.cases_for(pack, "boss_08_end_turn_signal")
	assert_eq(cases.size(), 1)
	var case_data: Dictionary = cases[0].duplicate(true)
	case_data["turn_limit"] = 1
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), pack, case_data)
	assert_eq(int(metrics.get("turn_count", 0)), 1)
	assert_true(bool(metrics.get("turn_limit_hit", false)))

func test_battle_evaluator_marks_pass() -> void:
	var case_data: Dictionary = {
		"expectations": {
			"required": {
				"outcome_equals": "vitoria",
				"terminated_equals": true,
				"turn_count_min": 1,
				"player_hp_min": 1
			}
		}
	}
	var evaluation: Dictionary = BattleEvaluatorScript.evaluate(case_data, _fake_metrics("vitoria", true, 2, 10, 0, 3, 0, 8))
	assert_eq(str(evaluation.get("status", "")), BattleEvaluatorScript.STATUS_PASS)
	assert_true(bool(evaluation.get("ok", false)))

func test_battle_evaluator_marks_warn_without_failure() -> void:
	var case_data: Dictionary = {
		"expectations": {
			"required": {
				"terminated_equals": true
			},
			"watch": {
				"outcome_equals": "vitoria",
				"player_hp_min": 1
			}
		}
	}
	var evaluation: Dictionary = BattleEvaluatorScript.evaluate(case_data, _fake_metrics("derrota", true, 3, 0, 10, 6, 3, 10))
	assert_eq(str(evaluation.get("status", "")), BattleEvaluatorScript.STATUS_WARN)
	assert_true(bool(evaluation.get("ok", false)))
	assert_gt(Array(evaluation.get("warnings", [])).size(), 0)

func test_battle_evaluator_marks_fail_and_gate_summary_is_not_ok() -> void:
	var case_data: Dictionary = {
		"id": "forced_fail",
		"class_id": "arcano",
		"encounter_id": "unit",
		"policy_id": "baseline_legal",
		"tags": ["unit"],
		"expectations": {
			"required": {
				"outcome_equals": "vitoria",
				"player_hp_min": 10
			}
		}
	}
	var metrics: Dictionary = _fake_metrics("derrota", true, 2, 0, 5, 3, 2, 10)
	var evaluation: Dictionary = BattleEvaluatorScript.evaluate(case_data, metrics)
	assert_eq(str(evaluation.get("status", "")), BattleEvaluatorScript.STATUS_FAIL)
	assert_false(bool(evaluation.get("ok", true)))
	var records: Array[Dictionary] = [{
		"case": case_data,
		"result": metrics,
		"timeline": [],
		"expectations": Array(evaluation.get("expectations", [])),
		"warnings": Array(evaluation.get("warnings", [])),
		"failures": Array(evaluation.get("failures", [])),
		"tags": ["unit"],
		"status": str(evaluation.get("status", ""))
	}]
	var summary: Dictionary = BattleRunnerScript.summarize(records, {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, {"mode": "gate"})
	assert_eq(int(summary.get("fail_count", 0)), 1)

func test_battle_loader_filters_by_case_id() -> void:
	var pack: Dictionary = BattleFixtureLoaderScript.load_pack("track02_battle_core_v1")
	var cases: Array[Dictionary] = BattleFixtureLoaderScript.cases_for(pack, "field_fogo_duel_signal")
	assert_eq(cases.size(), 1)
	assert_eq(str(cases[0].get("id", "")), "field_fogo_duel_signal")

func test_battle_loader_filters_by_tags() -> void:
	var pack: Dictionary = BattleFixtureLoaderScript.load_pack("track02_battle_core_v1")
	var cases: Array[Dictionary] = BattleFixtureLoaderScript.cases_for(pack, "", PackedStringArray(["stress"]))
	assert_eq(cases.size(), 2)
	for case_data: Dictionary in cases:
		assert_true(Array(case_data.get("tags", [])).has("stress"))

func test_battle_reporter_markdown_contains_status_matrix() -> void:
	var metrics: Dictionary = _fake_metrics("vitoria", true, 1, 20, 24, 1, 0, 0)
	var record: Dictionary = {
		"case": {
			"id": "unit_pass",
			"name": "Unit pass",
			"class_id": "arcano",
			"encounter_id": "unit",
			"policy_id": "baseline_legal"
		},
		"result": metrics,
		"timeline": [],
		"expectations": [],
		"warnings": [],
		"failures": [],
		"tags": ["unit"],
		"status": BattleEvaluatorScript.STATUS_PASS
	}
	var records: Array[Dictionary] = [record]
	var summary: Dictionary = BattleRunnerScript.summarize(records, {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, {"mode": "explore"})
	var markdown: String = BattleReporterScript.markdown(summary, records, {"command": "unit"})
	assert_string_contains(markdown, "Status Matrix")
	assert_string_contains(markdown, "PASS/WARN/FAIL")
	assert_string_contains(markdown, "unit_pass")

func _engine_for_case(case_data: Dictionary):
	var catalog = ContentLibrary.get_catalog()
	var encounter: Dictionary = catalog.find_encounter(str(case_data.get("encounter_id", ""))).duplicate(true)
	var config: Dictionary = Dictionary(case_data.get("config", {})).duplicate(true)
	config["class_id"] = str(case_data.get("class_id", ""))
	config["encounter"] = encounter
	var engine_script = load("res://battle/battle_engine.gd")
	var engine = engine_script.new()
	engine.start_battle(catalog, Array(case_data.get("deck", [])), config)
	return engine

func _fake_metrics(outcome: String, terminated: bool, turn_count: int, player_hp: int, enemy_hp: int, cards_played: int, damage_to_enemy: int, damage_to_player: int) -> Dictionary:
	return {
		"ok": true,
		"outcome": outcome,
		"terminated": terminated,
		"turn_count": turn_count,
		"combat_cycles": turn_count,
		"player_hp": player_hp,
		"enemy_hp": enemy_hp,
		"cards_played": cards_played,
		"player_units_alive": 1,
		"enemy_units_alive": 0,
		"damage_to_enemy_hero": damage_to_enemy,
		"damage_to_player_hero": damage_to_player,
		"timeline": []
	}
