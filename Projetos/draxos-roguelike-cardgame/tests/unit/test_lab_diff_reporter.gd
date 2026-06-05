extends "res://tests/unit/draxos_test_base.gd"

const LabDiffReporterScript = preload("res://tools/lab/lab_diff_reporter.gd")

func test_lab_diff_detects_battle_status_and_metric_changes() -> void:
	var report: Dictionary = LabDiffReporterScript.compare_payloads(
		{"records": [_battle_record("boss_08", "PASS", {"cards_played": 12, "enemy_hp": 0}), _battle_record("boss_22", "WARN", {"enemy_hp": 22})]},
		{"records": [_battle_record("boss_08", "FAIL", {"cards_played": 11, "enemy_hp": 0}), _battle_record("boss_22", "WARN", {"enemy_hp": 20})]},
		"battle"
	)
	assert_true(bool(report.get("ok", false)))
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_eq(int(summary.get("changed_count", 0)), 2)
	assert_eq(int(summary.get("status_change_count", 0)), 1)
	assert_eq(int(summary.get("new_failure_count", 0)), 1)
	assert_eq(int(summary.get("metric_change_count", 0)), 2)
	assert_false(bool(summary.get("gate_ok", true)))

func test_lab_diff_keeps_unchanged_scenario_gate_ok() -> void:
	var before: Dictionary = {"records": [_scenario_record("route", "PASS", {"final_hp": 13, "deaths": 0})]}
	var after: Dictionary = {"records": [_scenario_record("route", "PASS", {"final_hp": 13, "deaths": 0})]}
	var report: Dictionary = LabDiffReporterScript.compare_payloads(before, after, "scenario")
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_eq(int(summary.get("unchanged_count", 0)), 1)
	assert_eq(int(summary.get("changed_count", 0)), 0)
	assert_true(bool(summary.get("gate_ok", false)))

func test_lab_diff_detects_run_lab_metric_changes_and_added_records() -> void:
	var before: Dictionary = {"runs": [_run_metric("arcano_baseline_1", "arcano", 20260518, {"final_hp": 13, "deck_size": 38})]}
	var after: Dictionary = {"runs": [
		_run_metric("arcano_baseline_1", "arcano", 20260518, {"final_hp": 10, "deck_size": 38}),
		_run_metric("invocador_baseline_1", "invocador", 20260518, {"final_hp": 16, "deck_size": 37})
	]}
	var report: Dictionary = LabDiffReporterScript.compare_payloads(before, after, "run_lab")
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_eq(int(summary.get("changed_count", 0)), 1)
	assert_eq(int(summary.get("added_count", 0)), 1)
	assert_eq(int(summary.get("metric_change_count", 0)), 1)
	assert_true(bool(summary.get("gate_ok", false)))

func test_lab_diff_writes_outputs_and_markdown_status_matrix() -> void:
	var report: Dictionary = LabDiffReporterScript.compare_payloads(
		{"records": [_battle_record("boss_08", "PASS", {"cards_played": 12})]},
		{"records": [_battle_record("boss_08", "FAIL", {"cards_played": 11})]},
		"battle",
		{"command": "unit"}
	)
	report["before_path"] = "user://before/battle_results.json"
	report["after_path"] = "user://after/battle_results.json"
	var out_dir: String = "user://lab_diff/unit_test"
	var write_result: Dictionary = LabDiffReporterScript.write_outputs(out_dir, report, {"command": "unit"})
	assert_true(bool(write_result.get("ok", false)), str(write_result.get("message", "")))
	assert_true(FileAccess.file_exists("%s/lab_diff.json" % out_dir))
	assert_true(FileAccess.file_exists("%s/lab_diff.csv" % out_dir))
	assert_true(FileAccess.file_exists("%s/lab_diff.md" % out_dir))
	assert_true(FileAccess.file_exists("%s/lab_diff_gate.md" % out_dir))
	var markdown: String = FileAccess.get_file_as_string("%s/lab_diff.md" % out_dir)
	assert_string_contains(markdown, "Status Changes")
	assert_string_contains(markdown, "Metric Changes")
	assert_string_contains(markdown, "boss_08")

func _battle_record(id: String, status: String, overrides: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {
		"outcome": "vitoria",
		"terminated": true,
		"turn_count": 8,
		"combat_cycles": 8,
		"player_hp": 3,
		"enemy_hp": 0,
		"cards_played": 12,
		"player_units_alive": 1,
		"enemy_units_alive": 0,
		"damage_to_enemy_hero": 22,
		"damage_to_player_hero": 47
	}
	for key: String in overrides.keys():
		result[key] = overrides[key]
	return {
		"case": {"id": id, "name": id, "class_id": "arcano", "encounter_id": "unit"},
		"result": result,
		"warnings": [],
		"failures": [] if status != "FAIL" else [{"message": "forced"}],
		"tags": ["unit"],
		"status": status
	}

func _scenario_record(id: String, status: String, overrides: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {
		"completed_maps": 29,
		"map_count": 29,
		"final_hp": 13,
		"deaths": 0,
		"deck_size": 38,
		"shop_usage": 21,
		"souls_left": 71,
		"relic_count": 6,
		"souls_earned": 362,
		"souls_spent": 291
	}
	for key: String in overrides.keys():
		result[key] = overrides[key]
	return {
		"scenario": {"id": id, "name": id, "class_id": "arcano", "policy_id": "baseline"},
		"result": result,
		"warnings": [],
		"failures": [],
		"tags": ["unit"],
		"status": status
	}

func _run_metric(case_id: String, class_id: String, seed: int, overrides: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {
		"case_id": case_id,
		"class_id": class_id,
		"policy_id": "baseline",
		"seed": seed,
		"ok": true,
		"completed_maps": 29,
		"map_count": 29,
		"estimated_turns": 217,
		"hp_loss": 116,
		"final_hp": 13,
		"max_hp": 46,
		"deck_size": 38,
		"relic_count": 6,
		"souls_earned": 362,
		"souls_spent": 291,
		"souls_left": 71,
		"shop_usage": 21,
		"deaths": 0
	}
	for key: String in overrides.keys():
		result[key] = overrides[key]
	return result
