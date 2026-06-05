extends RefCounted

const RESULTS_JSON: String = "card_impact_results.json"
const RESULTS_CSV: String = "card_impact_results.csv"
const SUMMARY_JSON: String = "card_impact_summary.json"
const SUMMARY_MD: String = "card_impact_summary.md"
const GATE_MD: String = "card_impact_gate.md"

static func write_outputs(output_dir: String, report: Dictionary, options: Dictionary = {}) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var results_path: String = "%s/%s" % [output_dir, RESULTS_JSON]
	var csv_path: String = "%s/%s" % [output_dir, RESULTS_CSV]
	var summary_path: String = "%s/%s" % [output_dir, SUMMARY_JSON]
	var markdown_path: String = "%s/%s" % [output_dir, SUMMARY_MD]
	var gate_path: String = "%s/%s" % [output_dir, GATE_MD]
	for write_result: Dictionary in [
		_write_json(results_path, report),
		_write_csv(csv_path, report),
		_write_json(summary_path, Dictionary(report.get("summary", {}))),
		_write_text(markdown_path, markdown(report, options)),
		_write_text(gate_path, gate_markdown(report, options))
	]:
		if not bool(write_result.get("ok", false)):
			return write_result
	return {
		"ok": true,
		"results_path": results_path,
		"csv_path": csv_path,
		"summary_path": summary_path,
		"markdown_path": markdown_path,
		"gate_path": gate_path
	}

static func markdown(report: Dictionary, options: Dictionary = {}) -> String:
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var coverage: Dictionary = Dictionary(summary.get("coverage", {}))
	var lines: PackedStringArray = PackedStringArray([
		"# Card Impact Report",
		"",
		"- Phase: `%s`" % str(report.get("phase", "")),
		"- Pack: `%s`" % str(report.get("pack_id", "")),
		"- Gate: `%s`" % ("PASS" if bool(summary.get("gate_ok", true)) else "FAIL"),
		"- Cards expected/covered: `%d/%d`" % [int(coverage.get("expected_active_cards", 0)), int(coverage.get("covered_active_cards", 0))],
		"- Player/enemy/legacy inactive: `%d/%d/%d`" % [
			int(coverage.get("player_cards_total", 0)),
			int(coverage.get("enemy_cards_total", 0)),
			int(coverage.get("legacy_inactive_cards_total", 0))
		],
		"- Structural errors: `%d`" % Array(summary.get("structural_errors", [])).size(),
		"- Command: `%s`" % str(options.get("command", "")),
		"",
		"## Impact Matrix",
		"| Scope | Expected | Covered | Catalog total |",
		"|---|---:|---:|---:|",
		"| Player active | `%d` | `%d` | `%d` |" % [
			int(coverage.get("expected_player_cards", 0)),
			int(coverage.get("filtered_player_cards", 0)),
			int(coverage.get("player_cards_total", 0))
		],
		"| Enemy active | `%d` | `%d` | `%d` |" % [
			int(coverage.get("expected_enemy_cards", 0)),
			int(coverage.get("filtered_enemy_cards", 0)),
			int(coverage.get("enemy_cards_total", 0))
		],
		"| Legacy inactive | `%d` | `%d` | `%d` |" % [
			int(coverage.get("expected_legacy_inactive_cards", 0)),
			int(coverage.get("legacy_inactive_cards_total", 0)),
			int(coverage.get("legacy_inactive_cards_total", 0))
		],
		"",
		"## Components",
		"| Component | Status | PASS | WARN | FAIL | Changes | Metric changes |",
		"|---|---:|---:|---:|---:|---:|---:|"
	])
	for component: Dictionary in Array(summary.get("components", [])):
		lines.append("| `%s` | `%s` | `%d` | `%d` | `%d` | `%d` | `%d` |" % [
			str(component.get("component", "")),
			str(component.get("status", "")),
			int(component.get("pass_count", 0)),
			int(component.get("warn_count", 0)),
			int(component.get("fail_count", 0)),
			int(component.get("changed_count", 0)),
			int(component.get("metric_change_count", 0))
		])
	lines.append("")
	lines.append("## Top Impacted Cards")
	var top_cards: Array = Array(summary.get("top_impacted_cards", []))
	if top_cards.is_empty():
		lines.append("- none")
	else:
		for item: Dictionary in top_cards.slice(0, 12):
			lines.append("- `%s`: `%d` changes, `%d` metric changes, `%d` status changes" % [
				str(item.get("card_id", "")),
				int(item.get("change_count", 0)),
				int(item.get("metric_change_count", 0)),
				int(item.get("status_change_count", 0))
			])
	lines.append("")
	lines.append("## Status Changes")
	var status_changes: Array = Array(summary.get("status_changes", []))
	if status_changes.is_empty():
		lines.append("- none")
	else:
		for item: Dictionary in status_changes.slice(0, 20):
			lines.append("- `%s`: `%s` -> `%s`" % [str(item.get("id", "")), str(item.get("before_status", "")), str(item.get("after_status", ""))])
	lines.append("")
	lines.append("## Metric Changes")
	var metric_changes: Array = Array(summary.get("metric_changes", []))
	if metric_changes.is_empty():
		lines.append("- none")
	else:
		for item: Dictionary in metric_changes.slice(0, 20):
			lines.append("- `%s` `%s`: `%s` -> `%s` (`%s`)" % [
				str(item.get("id", "")),
				str(item.get("field", "")),
				str(item.get("before", "")),
				str(item.get("after", "")),
				str(item.get("delta", ""))
			])
	lines.append("")
	lines.append("## Structural Errors")
	var structural_errors: Array = Array(summary.get("structural_errors", []))
	if structural_errors.is_empty():
		lines.append("- none")
	else:
		for error: Variant in structural_errors:
			lines.append("- %s" % str(error))
	return "\n".join(lines) + "\n"

static func gate_markdown(report: Dictionary, options: Dictionary = {}) -> String:
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var lines: PackedStringArray = PackedStringArray([
		"# Card Impact Gate",
		"",
		"- Status: `%s`" % ("PASS" if bool(summary.get("gate_ok", true)) else "FAIL"),
		"- Phase: `%s`" % str(report.get("phase", "")),
		"- Structural errors: `%d`" % Array(summary.get("structural_errors", [])).size(),
		"- New failures: `%d`" % int(summary.get("new_failure_count", 0)),
		"- Removed records: `%d`" % int(summary.get("removed_count", 0)),
		"- Command: `%s`" % str(options.get("command", "")),
		"",
		"## Blocking Changes"
	])
	var blockers: Array = Array(summary.get("blocking_changes", []))
	if blockers.is_empty():
		lines.append("- none")
	else:
		for blocker: Variant in blockers:
			lines.append("- %s" % str(blocker))
	return "\n".join(lines) + "\n"

static func _write_json(path: String, payload: Dictionary) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write `%s`." % path}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return {"ok": true, "path": path}

static func _write_text(path: String, text: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write `%s`." % path}
	file.store_string(text)
	file.close()
	return {"ok": true, "path": path}

static func _write_csv(path: String, report: Dictionary) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write `%s`." % path}
	file.store_line("component,id,status,field,before,after,delta")
	for component: Dictionary in Array(Dictionary(report.get("summary", {})).get("components", [])):
		file.store_line("%s,%s,%s,,,%s," % [
			_csv(str(component.get("component", ""))),
			_csv("summary"),
			_csv(str(component.get("status", ""))),
			_csv(str(component.get("changed_count", 0)))
		])
	for change: Dictionary in Array(Dictionary(report.get("summary", {})).get("metric_changes", [])):
		file.store_line("%s,%s,%s,%s,%s,%s,%s" % [
			_csv(str(change.get("component", ""))),
			_csv(str(change.get("id", ""))),
			_csv("metric_change"),
			_csv(str(change.get("field", ""))),
			_csv(str(change.get("before", ""))),
			_csv(str(change.get("after", ""))),
			_csv(str(change.get("delta", "")))
		])
	file.close()
	return {"ok": true, "path": path}

static func _csv(value: String) -> String:
	var escaped: String = value.replace("\"", "\"\"")
	if escaped.find(",") >= 0 or escaped.find("\"") >= 0 or escaped.find("\n") >= 0:
		return "\"%s\"" % escaped
	return escaped
