extends RefCounted

const RESULT_HEADERS: PackedStringArray = [
	"scenario_id",
	"name",
	"status",
	"class_id",
	"policy_id",
	"seed",
	"tags",
	"completed_maps",
	"map_count",
	"final_hp",
	"deaths",
	"deck_size",
	"shop_usage",
	"souls_left",
	"warning_count",
	"failure_count"
]

static func write_outputs(output_dir: String, records: Array[Dictionary], summary: Dictionary, options: Dictionary = {}) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var results_path: String = "%s/scenario_results.json" % output_dir
	var csv_path: String = "%s/scenario_results.csv" % output_dir
	var summary_path: String = "%s/scenario_summary.json" % output_dir
	var markdown_path: String = "%s/scenario_summary.md" % output_dir
	var gate_path: String = "%s/scenario_gate.md" % output_dir
	var payload: Dictionary = {"records": records, "summary": summary}
	var json_result: Dictionary = _write_json(results_path, payload)
	if not bool(json_result.get("ok", false)):
		return json_result
	var csv_result: Dictionary = _write_csv(csv_path, records)
	if not bool(csv_result.get("ok", false)):
		return csv_result
	var summary_result: Dictionary = _write_json(summary_path, summary)
	if not bool(summary_result.get("ok", false)):
		return summary_result
	var markdown_result: Dictionary = _write_text(markdown_path, markdown(summary, records, options))
	if not bool(markdown_result.get("ok", false)):
		return markdown_result
	var gate_result: Dictionary = _write_text(gate_path, gate_markdown(summary, records, options))
	if not bool(gate_result.get("ok", false)):
		return gate_result
	return {
		"ok": true,
		"results_path": results_path,
		"csv_path": csv_path,
		"summary_path": summary_path,
		"markdown_path": markdown_path,
		"gate_path": gate_path
	}

static func markdown(summary: Dictionary, records: Array[Dictionary], options: Dictionary = {}) -> String:
	var lines: PackedStringArray = PackedStringArray([
		"# Scenario Fixtures Summary",
		"",
		"- Pack: `%s`" % str(summary.get("pack_id", "")),
		"- Simulation: `%s`" % str(summary.get("simulation_mode", "")),
		"- Mode: `%s`" % str(summary.get("mode", "explore")),
		"- Scenarios: `%d`" % int(summary.get("total_scenarios", 0)),
		"- PASS/WARN/FAIL: `%d/%d/%d`" % [int(summary.get("pass_count", 0)), int(summary.get("warn_count", 0)), int(summary.get("fail_count", 0))],
		"- Command: `%s`" % str(options.get("command", "")),
		"",
		"## Status Matrix",
		"| Scenario | Status | Class | Policy | Tags |",
		"|---|---:|---|---|---|"
	])
	for record: Dictionary in records:
		var scenario: Dictionary = Dictionary(record.get("scenario", {}))
		lines.append("| `%s` | `%s` | `%s` | `%s` | `%s` |" % [
			str(scenario.get("id", "")),
			str(record.get("status", "")),
			str(scenario.get("class_id", "")),
			str(scenario.get("policy_id", "")),
			";".join(Array(record.get("tags", [])))
		])
	lines.append("")
	_append_group_section(lines, "By Tag", Dictionary(summary.get("by_tag", {})))
	_append_group_section(lines, "By Class", Dictionary(summary.get("by_class", {})))
	_append_group_section(lines, "By Policy", Dictionary(summary.get("by_policy", {})))
	if not Array(summary.get("checkpoint_highlights", [])).is_empty():
		lines.append("## Checkpoints")
		for entry: Dictionary in Array(summary.get("checkpoint_highlights", [])).slice(0, 12):
			lines.append("- `%s` `%s`: `%s` actual `%s`, expected `%s`" % [
				str(entry.get("scenario_id", "")),
				str(entry.get("field", "")),
				str(entry.get("status", "")),
				str(entry.get("actual", "")),
				str(entry.get("expected", ""))
			])
		lines.append("")
	if not Array(summary.get("warnings", [])).is_empty():
		lines.append("## Top Warnings")
		for entry: Dictionary in Array(summary.get("warnings", [])).slice(0, 8):
			lines.append("- `%s`: %s" % [str(entry.get("scenario_id", "")), str(entry.get("message", ""))])
		lines.append("")
	if not Array(summary.get("failures", [])).is_empty():
		lines.append("## Failures")
		for entry: Dictionary in Array(summary.get("failures", [])).slice(0, 8):
			lines.append("- `%s`: %s" % [str(entry.get("scenario_id", "")), str(entry.get("message", ""))])
		lines.append("")
	return "\n".join(lines) + "\n"

static func gate_markdown(summary: Dictionary, records: Array[Dictionary], options: Dictionary = {}) -> String:
	var status: String = "PASS" if int(summary.get("fail_count", 0)) == 0 else "FAIL"
	var lines: PackedStringArray = PackedStringArray([
		"# Scenario Fixtures Gate",
		"",
		"- Status: `%s`" % status,
		"- Pack: `%s`" % str(summary.get("pack_id", "")),
		"- PASS/WARN/FAIL: `%d/%d/%d`" % [int(summary.get("pass_count", 0)), int(summary.get("warn_count", 0)), int(summary.get("fail_count", 0))],
		"- Command: `%s`" % str(options.get("command", "")),
		"",
		"## Results"
	])
	for record: Dictionary in records:
		var scenario: Dictionary = Dictionary(record.get("scenario", {}))
		lines.append("- `%s`: `%s`" % [str(scenario.get("id", "")), str(record.get("status", ""))])
	return "\n".join(lines) + "\n"

static func _append_group_section(lines: PackedStringArray, title: String, groups: Dictionary) -> void:
	if groups.is_empty():
		return
	lines.append("## %s" % title)
	lines.append("| Group | Total | PASS | WARN | FAIL |")
	lines.append("|---|---:|---:|---:|---:|")
	var keys: Array = groups.keys()
	keys.sort()
	for key: String in keys:
		var group: Dictionary = Dictionary(groups.get(key, {}))
		lines.append("| `%s` | %d | %d | %d | %d |" % [
			key,
			int(group.get("total", 0)),
			int(group.get("pass", 0)),
			int(group.get("warn", 0)),
			int(group.get("fail", 0))
		])
	lines.append("")

static func _write_json(path: String, payload: Dictionary) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write %s." % path}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return {"ok": true, "path": path}

static func _write_text(path: String, text: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write %s." % path}
	file.store_string(text)
	file.close()
	return {"ok": true, "path": path}

static func _write_csv(path: String, records: Array[Dictionary]) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write %s." % path}
	file.store_line(",".join(RESULT_HEADERS))
	for record: Dictionary in records:
		var scenario: Dictionary = Dictionary(record.get("scenario", {}))
		var result: Dictionary = Dictionary(record.get("result", {}))
		var row: PackedStringArray = [
			_csv_escape(str(scenario.get("id", ""))),
			_csv_escape(str(scenario.get("name", ""))),
			_csv_escape(str(record.get("status", ""))),
			_csv_escape(str(scenario.get("class_id", ""))),
			_csv_escape(str(scenario.get("policy_id", ""))),
			_csv_escape(str(scenario.get("seed", ""))),
			_csv_escape(";".join(Array(record.get("tags", [])))),
			str(int(result.get("completed_maps", 0))),
			str(int(result.get("map_count", 0))),
			str(int(result.get("final_hp", 0))),
			str(int(result.get("deaths", 0))),
			str(int(result.get("deck_size", 0))),
			str(int(result.get("shop_usage", 0))),
			str(int(result.get("souls_left", 0))),
			str(Array(record.get("warnings", [])).size()),
			str(Array(record.get("failures", [])).size())
		]
		file.store_line(",".join(row))
	file.close()
	return {"ok": true, "path": path}

static func _csv_escape(value: String) -> String:
	if value.find(",") >= 0 or value.find("\"") >= 0 or value.find("\n") >= 0:
		return "\"%s\"" % value.replace("\"", "\"\"")
	return value
