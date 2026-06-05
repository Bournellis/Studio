extends RefCounted

const RUN_HEADERS: PackedStringArray = [
	"case_id",
	"class_id",
	"seed",
	"policy_id",
	"ok",
	"completed_maps",
	"map_count",
	"estimated_turns",
	"hp_loss",
	"final_hp",
	"max_hp",
	"deck_size",
	"relic_count",
	"souls_earned",
	"souls_spent",
	"souls_left",
	"shop_usage",
	"deaths",
	"shop_actions",
	"message"
]

static func write_outputs(output_dir: String, records: Array[Dictionary], summary: Dictionary, comparison: Dictionary = {}, baseline_comparison: Dictionary = {}) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var metrics: Array[Dictionary] = []
	for record: Dictionary in records:
		metrics.append(Dictionary(record.get("result", {})).duplicate(true))
	var detailed_path: String = "%s/run_lab_detailed.json" % output_dir
	var metrics_path: String = "%s/run_lab_metrics.json" % output_dir
	var metrics_csv_path: String = "%s/run_lab_metrics.csv" % output_dir
	var summary_path: String = "%s/run_lab_summary.json" % output_dir
	var summary_csv_path: String = "%s/run_lab_summary.csv" % output_dir
	var markdown_path: String = "%s/run_lab_summary.md" % output_dir

	var detailed_payload: Dictionary = {"records": records, "summary": summary}
	if not comparison.is_empty():
		detailed_payload["golden_comparison"] = comparison
	if not baseline_comparison.is_empty():
		detailed_payload["baseline_comparison"] = baseline_comparison
	var detailed_result: Dictionary = _write_json(detailed_path, detailed_payload)
	if not bool(detailed_result.get("ok", false)):
		return detailed_result

	var metrics_payload: Dictionary = {"runs": metrics, "summary": summary}
	if not comparison.is_empty():
		metrics_payload["golden_comparison"] = comparison
	if not baseline_comparison.is_empty():
		metrics_payload["baseline_comparison"] = baseline_comparison
	var metrics_result: Dictionary = _write_json(metrics_path, metrics_payload)
	if not bool(metrics_result.get("ok", false)):
		return metrics_result
	var csv_result: Dictionary = _write_run_csv(metrics_csv_path, metrics)
	if not bool(csv_result.get("ok", false)):
		return csv_result
	var summary_result: Dictionary = _write_json(summary_path, summary)
	if not bool(summary_result.get("ok", false)):
		return summary_result
	var summary_csv_result: Dictionary = _write_summary_csv(summary_csv_path, summary)
	if not bool(summary_csv_result.get("ok", false)):
		return summary_csv_result
	var markdown_result: Dictionary = _write_text(markdown_path, _summary_markdown(summary, comparison, baseline_comparison))
	if not bool(markdown_result.get("ok", false)):
		return markdown_result
	return {
		"ok": true,
		"detailed_path": detailed_path,
		"json_path": metrics_path,
		"csv_path": metrics_csv_path,
		"summary_path": summary_path,
		"summary_csv_path": summary_csv_path,
		"markdown_path": markdown_path
	}

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

static func _write_run_csv(path: String, metrics: Array[Dictionary]) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write %s." % path}
	file.store_line(",".join(RUN_HEADERS))
	for result: Dictionary in metrics:
		var row: PackedStringArray = PackedStringArray()
		for header: String in RUN_HEADERS:
			if header == "shop_actions":
				row.append(_csv_escape(";".join(Array(result.get(header, [])))))
			else:
				row.append(_csv_escape(str(result.get(header, ""))))
		file.store_line(",".join(row))
	file.close()
	return {"ok": true, "path": path}

static func _write_summary_csv(path: String, summary: Dictionary) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write %s." % path}
	var headers: PackedStringArray = ["group_type", "group", "total_runs", "victory_rate", "completion_rate", "avg_final_hp", "avg_deck_size", "avg_shop_usage", "avg_deaths"]
	file.store_line(",".join(headers))
	_write_summary_row(file, "all", "all", summary)
	for class_id: String in Dictionary(summary.get("by_class", {})).keys():
		_write_summary_row(file, "class", class_id, Dictionary(Dictionary(summary.get("by_class", {})).get(class_id, {})))
	for policy_id: String in Dictionary(summary.get("by_policy", {})).keys():
		_write_summary_row(file, "policy", policy_id, Dictionary(Dictionary(summary.get("by_policy", {})).get(policy_id, {})))
	file.close()
	return {"ok": true, "path": path}

static func _write_summary_row(file: FileAccess, group_type: String, group: String, data: Dictionary) -> void:
	var averages: Dictionary = Dictionary(data.get("averages", {}))
	var row: PackedStringArray = [
		group_type,
		group,
		str(int(data.get("total_runs", 0))),
		"%.4f" % float(data.get("victory_rate", 0.0)),
		"%.4f" % float(data.get("completion_rate", 0.0)),
		"%.2f" % float(averages.get("final_hp", 0.0)),
		"%.2f" % float(averages.get("deck_size", 0.0)),
		"%.2f" % float(averages.get("shop_usage", 0.0)),
		"%.2f" % float(averages.get("deaths", 0.0))
	]
	file.store_line(",".join(row))

static func _summary_markdown(summary: Dictionary, comparison: Dictionary, baseline_comparison: Dictionary) -> String:
	var averages: Dictionary = Dictionary(summary.get("averages", {}))
	var lines: PackedStringArray = PackedStringArray([
		"# AutoRun Lab Summary",
		"",
		"- Preset: `%s`" % str(summary.get("preset", "")),
		"- Simulation: `%s`" % str(summary.get("simulation_mode", "")),
		"- Runs: `%d`" % int(summary.get("total_runs", 0)),
		"- Victory rate: `%.1f%%`" % (float(summary.get("victory_rate", 0.0)) * 100.0),
		"- Completion rate: `%.1f%%`" % (float(summary.get("completion_rate", 0.0)) * 100.0),
		"- Avg final HP: `%.2f`" % float(averages.get("final_hp", 0.0)),
		"- Avg deck size: `%.2f`" % float(averages.get("deck_size", 0.0)),
		"- Avg shop usage: `%.2f`" % float(averages.get("shop_usage", 0.0)),
		""
	])
	lines.append("## By Class")
	for class_id: String in Dictionary(summary.get("by_class", {})).keys():
		var group: Dictionary = Dictionary(Dictionary(summary.get("by_class", {})).get(class_id, {}))
		lines.append("- `%s`: victory `%.1f%%`, avg HP `%.2f`, avg deck `%.2f`" % [
			class_id,
			float(group.get("victory_rate", 0.0)) * 100.0,
			float(Dictionary(group.get("averages", {})).get("final_hp", 0.0)),
			float(Dictionary(group.get("averages", {})).get("deck_size", 0.0))
		])
	lines.append("")
	lines.append("## By Policy")
	for policy_id: String in Dictionary(summary.get("by_policy", {})).keys():
		var group: Dictionary = Dictionary(Dictionary(summary.get("by_policy", {})).get(policy_id, {}))
		lines.append("- `%s`: victory `%.1f%%`, completion `%.1f%%`, avg shop `%.2f`" % [
			policy_id,
			float(group.get("victory_rate", 0.0)) * 100.0,
			float(group.get("completion_rate", 0.0)) * 100.0,
			float(Dictionary(group.get("averages", {})).get("shop_usage", 0.0))
		])
	if not Array(summary.get("risk_maps", [])).is_empty():
		lines.append("")
		lines.append("## Risk Maps")
		for entry: Dictionary in Array(summary.get("risk_maps", [])).slice(0, 5):
			lines.append("- Map `%d`: `%d` risk events" % [int(entry.get("map", 0)), int(entry.get("risk_events", 0))])
	if not comparison.is_empty():
		lines.append("")
		lines.append("- Golden comparison: `%s`" % ("ok" if bool(comparison.get("ok", false)) else "mismatch"))
	if not baseline_comparison.is_empty():
		lines.append("- Baseline comparison: `%s`" % ("ok" if bool(baseline_comparison.get("ok", false)) else "mismatch"))
	return "\n".join(lines) + "\n"

static func _csv_escape(value: String) -> String:
	if value.find(",") >= 0 or value.find("\"") >= 0 or value.find("\n") >= 0:
		return "\"%s\"" % value.replace("\"", "\"\"")
	return value
