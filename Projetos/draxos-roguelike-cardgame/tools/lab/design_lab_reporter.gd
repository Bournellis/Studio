extends RefCounted

const RESULTS_FILE: String = "design_lab_results.json"
const CANDIDATES_FILE: String = "design_lab_candidates.csv"
const SUMMARY_FILE: String = "design_lab_summary.md"
const GATE_FILE: String = "design_lab_gate.md"
const PROMOTION_FILE: String = "promotion_manifest.json"

static func write_outputs(out_dir: String, report: Dictionary, options: Dictionary = {}) -> Dictionary:
	var target_dir: String = out_dir
	if target_dir == "":
		target_dir = "user://design_lab/%s" % str(report.get("pack_id", "design_lab"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(target_dir))
	var promotion_manifest: Dictionary = promotion_manifest(report, options)
	var results_path: String = "%s/%s" % [target_dir, RESULTS_FILE]
	var csv_path: String = "%s/%s" % [target_dir, CANDIDATES_FILE]
	var summary_path: String = "%s/%s" % [target_dir, SUMMARY_FILE]
	var gate_path: String = "%s/%s" % [target_dir, GATE_FILE]
	var promotion_path: String = "%s/%s" % [target_dir, PROMOTION_FILE]
	var results_payload: Dictionary = report.duplicate(true)
	results_payload["promotion_manifest"] = promotion_manifest
	var writes: Array[Dictionary] = [
		{"path": results_path, "text": JSON.stringify(results_payload, "\t")},
		{"path": csv_path, "text": candidates_csv(Array(report.get("candidates", [])))},
		{"path": summary_path, "text": summary_markdown(report, promotion_manifest, options)},
		{"path": gate_path, "text": gate_markdown(report, promotion_manifest, options)},
		{"path": promotion_path, "text": JSON.stringify(promotion_manifest, "\t")}
	]
	for write: Dictionary in writes:
		var file: FileAccess = FileAccess.open(str(write.get("path", "")), FileAccess.WRITE)
		if file == null:
			return {"ok": false, "message": "Failed to write %s." % str(write.get("path", ""))}
		file.store_string(str(write.get("text", "")))
		file.close()
	return {
		"ok": true,
		"out_dir": target_dir,
		"results_path": results_path,
		"csv_path": csv_path,
		"summary_path": summary_path,
		"gate_path": gate_path,
		"promotion_path": promotion_path
	}

static func candidates_csv(candidates: Array) -> String:
	var lines: Array[String] = ["card_id,variant_id,owner,role,classification,score,risk,power_value,cost,attack,health,effect_amount,contexts_pass,contexts_warn,contexts_fail,reasons"]
	for value: Variant in candidates:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var candidate: Dictionary = Dictionary(value)
		var numbers: Dictionary = Dictionary(candidate.get("numbers", {}))
		var contexts: Dictionary = Dictionary(candidate.get("contexts", {}))
		lines.append(",".join([
			_csv(str(candidate.get("card_id", ""))),
			_csv(str(candidate.get("variant_id", ""))),
			_csv(str(candidate.get("owner", ""))),
			_csv(str(candidate.get("role", ""))),
			_csv(str(candidate.get("classification", ""))),
			str(candidate.get("score", 0.0)),
			str(candidate.get("risk_value", 0.0)),
			str(candidate.get("power_value", 0.0)),
			str(numbers.get("cost", "")),
			str(numbers.get("attack", "")),
			str(numbers.get("health", "")),
			str(numbers.get("effect.amount", "")),
			str(contexts.get("pass", 0)),
			str(contexts.get("warn", 0)),
			str(contexts.get("fail", 0)),
			_csv("; ".join(Array(candidate.get("reasons", []))))
		]))
	return "\n".join(lines)

static func summary_markdown(report: Dictionary, promotion: Dictionary, options: Dictionary = {}) -> String:
	var lines: Array[String] = []
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	lines.append("# Design Lab Summary")
	lines.append("")
	lines.append("- Pack: `%s`" % str(report.get("pack_id", "")))
	lines.append("- Mode: `%s`" % str(options.get("mode", "explore")))
	lines.append("- Gate: `%s`" % ("PASS" if bool(summary.get("gate_ok", false)) else "FAIL"))
	lines.append("- Candidates: `%d` across `%d` card idea(s)" % [int(summary.get("candidate_count", 0)), int(summary.get("card_count", 0))])
	lines.append("- Recommendations: `%d`" % int(summary.get("recommendation_count", 0)))
	lines.append("")
	lines.append("## Classification Counts")
	lines.append("")
	for key: String in _sorted_keys(Dictionary(summary.get("classification_counts", {}))):
		lines.append("- `%s`: `%d`" % [key, int(Dictionary(summary.get("classification_counts", {})).get(key, 0))])
	lines.append("")
	lines.append("## Top Candidates By Card")
	lines.append("")
	var by_card: Dictionary = Dictionary(report.get("by_card", {}))
	for card_id: String in _sorted_keys(by_card):
		lines.append("### `%s`" % card_id)
		var index: int = 0
		for candidate_value: Variant in Array(by_card.get(card_id, [])):
			if typeof(candidate_value) != TYPE_DICTIONARY:
				continue
			var candidate: Dictionary = Dictionary(candidate_value)
			index += 1
			if index > 3:
				break
			lines.append("- `%s` `%s` score `%s` risk `%s`: %s" % [
				str(candidate.get("variant_id", "")),
				str(candidate.get("classification", "")),
				str(candidate.get("score", 0.0)),
				str(candidate.get("risk_value", 0.0)),
				"; ".join(Array(candidate.get("reasons", [])))
			])
		lines.append("")
	var blocked: Array = Array(report.get("blocked_mechanics", []))
	if not blocked.is_empty():
		lines.append("## Blocked Mechanics")
		lines.append("")
		for entry_value: Variant in blocked:
			if typeof(entry_value) != TYPE_DICTIONARY:
				continue
			var entry: Dictionary = Dictionary(entry_value)
			lines.append("- `%s`: %s" % [str(entry.get("mechanic_id", "")), str(entry.get("description", ""))])
		lines.append("")
	lines.append("## Promotion Manifest")
	lines.append("")
	for candidate_value: Variant in Array(promotion.get("selected_candidates", [])):
		if typeof(candidate_value) != TYPE_DICTIONARY:
			continue
		var selected: Dictionary = Dictionary(candidate_value)
		lines.append("- `%s` -> `%s` (`%s`, score `%s`)" % [
			str(selected.get("card_id", "")),
			str(selected.get("variant_id", "")),
			str(selected.get("classification", "")),
			str(selected.get("score", 0.0))
		])
	if Array(promotion.get("selected_candidates", [])).is_empty():
		lines.append("- No promotable candidates yet.")
	return "\n".join(lines)

static func gate_markdown(report: Dictionary, promotion: Dictionary, options: Dictionary = {}) -> String:
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var lines: Array[String] = []
	lines.append("# Design Lab Gate")
	lines.append("")
	lines.append("- Gate: `%s`" % ("PASS" if bool(summary.get("gate_ok", false)) else "FAIL"))
	lines.append("- Mode: `%s`" % str(options.get("mode", "explore")))
	lines.append("- Pack: `%s`" % str(report.get("pack_id", "")))
	lines.append("- Recommended/viable candidates: `%d`" % Array(promotion.get("selected_candidates", [])).size())
	lines.append("")
	if not bool(summary.get("gate_ok", false)):
		lines.append("## Blockers")
		lines.append("")
		var counts: Dictionary = Dictionary(summary.get("classification_counts", {}))
		for key: String in ["blocked", "broken", "risky", "weak"]:
			var count: int = int(counts.get(key, 0))
			if count > 0:
				lines.append("- `%s`: `%d`" % [key, count])
		if Array(promotion.get("selected_candidates", [])).size() < int(summary.get("card_count", 0)):
			lines.append("- At least one card idea has no viable candidate.")
	else:
		lines.append("All card ideas have a viable or recommended candidate and no blocked/broken candidate remains in the selected set.")
	return "\n".join(lines)

static func promotion_manifest(report: Dictionary, options: Dictionary = {}) -> Dictionary:
	var selected: Array[Dictionary] = []
	for value: Variant in Array(report.get("recommendations", [])):
		if typeof(value) == TYPE_DICTIONARY:
			var candidate: Dictionary = Dictionary(value)
			selected.append({
				"card_id": str(candidate.get("card_id", "")),
				"variant_id": str(candidate.get("variant_id", "")),
				"owner": str(candidate.get("owner", "")),
				"role": str(candidate.get("role", "")),
				"classification": str(candidate.get("classification", "")),
				"score": candidate.get("score", 0.0),
				"numbers": Dictionary(candidate.get("numbers", {})).duplicate(true),
				"suggested_diffs": _suggested_diffs(candidate),
				"required_validations": [
					"run_design_lab --mode=gate --pack=%s --card=%s" % [str(report.get("pack_id", "")), str(candidate.get("card_id", ""))],
					"run_card_impact V4.2/V5 official pack without proposal overlay",
					"run_lab smoke/quick official gates",
					"validate.gd"
				]
			})
	return {
		"schema_version": 1,
		"pack_id": str(report.get("pack_id", "")),
		"generated_by": "Design Lab",
		"manual_approval_required": true,
		"selected_candidates": selected,
		"blocked_mechanics": Array(report.get("blocked_mechanics", [])).duplicate(true),
		"notes": "Promotion is advisory. No official content file is changed by Design Lab V1.",
		"command": str(options.get("command", ""))
	}

static func _suggested_diffs(candidate: Dictionary) -> Array[Dictionary]:
	var diffs: Array[Dictionary] = []
	for key: String in _sorted_keys(Dictionary(candidate.get("numbers", {}))):
		diffs.append({"field": key, "value": Dictionary(candidate.get("numbers", {})).get(key)})
	return diffs

static func _csv(value: String) -> String:
	return "\"%s\"" % value.replace("\"", "\"\"")

static func _sorted_keys(values: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in values.keys():
		keys.append(str(key))
	keys.sort()
	return keys
