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
	var signature_quality: Dictionary = Dictionary(summary.get("signature_quality", {}))
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
		"- Effect signatures: player `%s` (`%d` expected), enemy `%s` (`%d` expected)" % [
			str(coverage.get("player_effect_signature_mode", "off")),
			int(coverage.get("expected_player_effect_signatures", 0)),
			str(coverage.get("enemy_effect_signature_mode", "off")),
			int(coverage.get("expected_enemy_effect_signatures", 0))
		],
		"- Card-flow expected/observed/missing: `%d/%d/%d`" % [
			int(coverage.get("expected_card_flow_player_cards", signature_quality.get("card_flow_expected_count", 0))),
			int(signature_quality.get("card_flow_observed_count", 0)),
			int(signature_quality.get("card_flow_missing_count", 0))
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
		"## Player Coverage",
		"",
		"- By class: `%s`" % _inline_field_counts(Dictionary(coverage.get("filtered_player_cards_by_class", coverage.get("player_cards_total_by_class", {})))),
		"- By source: `%s`" % _inline_field_counts(Dictionary(coverage.get("filtered_player_cards_by_source", coverage.get("player_cards_total_by_source", {})))),
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
	lines.append("## Player Effect Deltas")
	var effect_changes: Array = Array(summary.get("effect_changes", []))
	if effect_changes.is_empty():
		lines.append("- none")
	else:
		for item: Dictionary in effect_changes.slice(0, 24):
			lines.append("- `%s` `%s`: `%s` -> `%s` (`%s`)" % [
				str(item.get("id", "")),
				str(item.get("field", "")),
				str(item.get("before", "")),
				str(item.get("after", "")),
				str(item.get("delta", ""))
			])
	lines.append("")
	lines.append("## Utility Effect Deltas")
	var utility_rows: Array = []
	for item: Dictionary in effect_changes:
		var field: String = str(item.get("field", ""))
		if field in ["effect.temporary_ability_power_delta", "effect.temporary_ability_power_gained", "effect.temporary_ability_power_lost"]:
			utility_rows.append(item)
	if utility_rows.is_empty():
		lines.append("- none")
	else:
		for item: Dictionary in utility_rows.slice(0, 20):
			lines.append("- `%s` `%s`: `%s` -> `%s` (`%s`)" % [
				str(item.get("id", "")),
				str(item.get("field", "")),
				str(item.get("before", "")),
				str(item.get("after", "")),
				str(item.get("delta", ""))
			])
	lines.append("")
	lines.append("## Card Flow Coverage")
	lines.append("- Expected/filtered/observed/missing: `%d/%d/%d/%d`" % [
		int(coverage.get("expected_card_flow_player_cards", 0)),
		int(coverage.get("filtered_card_flow_player_cards", 0)),
		int(signature_quality.get("card_flow_observed_count", 0)),
		int(signature_quality.get("card_flow_missing_count", 0))
	])
	var card_flow_cases: Array = Array(signature_quality.get("card_flow_cases", []))
	if card_flow_cases.is_empty():
		lines.append("- missing cases: none")
	else:
		for item: Dictionary in card_flow_cases.slice(0, 12):
			lines.append("- `%s` `%s`: observed `%s`, signature `%s`, reason `%s`" % [
				str(item.get("case_id", "")),
				str(item.get("card_id", "")),
				str(item.get("card_flow_observed", "")),
				str(item.get("signature_present", "")),
				str(item.get("missing_reason", ""))
			])
	var card_flow_rows: Array = []
	for item: Dictionary in effect_changes:
		var field: String = str(item.get("field", ""))
		if field in ["effect.cards_drawn", "effect.cards_discarded", "effect.cards_created", "effect.deck_delta", "effect.hand_delta", "effect.discard_delta", "effect.card_flow_observed", "effect.card_flow_expected", "effect.card_flow_missing_reason"]:
			card_flow_rows.append(item)
	if card_flow_rows.is_empty():
		lines.append("- deltas: none")
	else:
		lines.append("- deltas:")
		for item: Dictionary in card_flow_rows.slice(0, 20):
			lines.append("  - `%s` `%s`: `%s` -> `%s` (`%s`)" % [
				str(item.get("id", "")),
				str(item.get("field", "")),
				str(item.get("before", "")),
				str(item.get("after", "")),
				str(item.get("delta", ""))
			])
	lines.append("")
	lines.append("## Effect Family Matrix")
	var by_effect_family: Dictionary = Dictionary(summary.get("by_effect_family", {}))
	if by_effect_family.is_empty():
		lines.append("- none")
	else:
		lines.append("| Family | Changes | Fields |")
		lines.append("|---|---:|---|")
		for family: String in _sorted_keys(by_effect_family):
			var entry: Dictionary = Dictionary(by_effect_family.get(family, {}))
			lines.append("| `%s` | `%d` | `%s` |" % [
				family,
				int(entry.get("change_count", 0)),
				_inline_field_counts(Dictionary(entry.get("fields", {})))
			])
	lines.append("")
	lines.append("## Non-Damage Coverage Matrix")
	var quality_by_family: Dictionary = Dictionary(signature_quality.get("by_family", {}))
	if quality_by_family.is_empty():
		var non_damage_families: Array[String] = []
		for family: String in _sorted_keys(by_effect_family):
			if not ["damage", "coverage", "support", "other"].has(family):
				non_damage_families.append(family)
		if non_damage_families.is_empty():
			lines.append("- none")
		else:
			lines.append("| Family | Effect changes | Fields |")
			lines.append("|---|---:|---|")
			for family: String in non_damage_families:
				var entry: Dictionary = Dictionary(by_effect_family.get(family, {}))
				lines.append("| `%s` | `%d` | `%s` |" % [
					family,
					int(entry.get("change_count", 0)),
					_inline_field_counts(Dictionary(entry.get("fields", {})))
				])
	else:
		lines.append("| Family | Total | Clean | Support | Ambiguous | Missing |")
		lines.append("|---|---:|---:|---:|---:|---:|")
		for family: String in _sorted_keys(quality_by_family):
			if family == "damage":
				continue
			var entry: Dictionary = Dictionary(quality_by_family.get(family, {}))
			lines.append("| `%s` | `%d` | `%d` | `%d` | `%d` | `%d` |" % [
				family,
				int(entry.get("total", 0)),
				int(entry.get("clean_count", 0)),
				int(entry.get("support_assisted_count", 0)),
				int(entry.get("ambiguous_count", 0)),
				int(entry.get("missing_count", 0))
			])
	lines.append("")
	lines.append("## Target Capture Quality")
	if signature_quality.is_empty():
		lines.append("- none")
	else:
		lines.append("- Clean/support-required/ambiguous/failed/repeated: `%d/%d/%d/%d/%d`" % [
			int(signature_quality.get("capture_clean_count", 0)),
			int(signature_quality.get("capture_support_required_count", 0)),
			int(signature_quality.get("capture_ambiguous_count", 0)),
			int(signature_quality.get("capture_failed_count", 0)),
			int(signature_quality.get("repeated_target_count", 0))
		])
		var target_cases: Array = Array(signature_quality.get("cases", []))
		if target_cases.is_empty():
			lines.append("- notable cases: none")
		else:
			for item: Dictionary in target_cases.slice(0, 20):
				lines.append("- `%s` `%s`: capture `%s`, plays `%d`, reasons `%s`" % [
					str(item.get("case_id", "")),
					str(item.get("card_id", "")),
					str(item.get("capture_quality", "")),
					int(item.get("target_card_play_count", 0)),
					", ".join(Array(item.get("ambiguity_reasons", [])))
				])
	lines.append("")
	lines.append("## Support Contamination")
	if signature_quality.is_empty():
		var support_changes: Array = Array(summary.get("support_contamination_changes", []))
		if support_changes.is_empty():
			lines.append("- none")
		else:
			for item: Dictionary in support_changes.slice(0, 20):
				lines.append("- `%s` `%s`: `%s` -> `%s`" % [
					str(item.get("id", "")),
					str(item.get("field", "")),
					str(item.get("before", "")),
					str(item.get("after", ""))
				])
	else:
		lines.append("- Total signatures: `%d`" % int(signature_quality.get("total", 0)))
		lines.append("- Clean/support/ambiguous/missing: `%d/%d/%d/%d`" % [
			int(signature_quality.get("clean_count", 0)),
			int(signature_quality.get("support_assisted_count", 0)),
			int(signature_quality.get("ambiguous_count", 0)),
			int(signature_quality.get("missing_count", 0))
		])
		var quality_cases: Array = Array(signature_quality.get("cases", []))
		if quality_cases.is_empty():
			lines.append("- notable cases: none")
		else:
			for item: Dictionary in quality_cases.slice(0, 20):
				lines.append("- `%s` `%s`: `%s` / `%s` (%s)" % [
					str(item.get("case_id", "")),
					str(item.get("card_id", "")),
					str(item.get("support_contamination_status", "")),
					str(item.get("signature_confidence", "")),
					str(item.get("reason", ""))
				])
	lines.append("")
	lines.append("## Top Effect Delta Cards")
	var top_effect_cards: Array = Array(summary.get("top_effect_delta_cards", []))
	if top_effect_cards.is_empty():
		lines.append("- none")
	else:
		for item: Dictionary in top_effect_cards.slice(0, 12):
			lines.append("- `%s`: `%d` effect-related changes" % [
				str(item.get("card_id", "")),
				int(item.get("change_count", 0))
			])
	lines.append("")
	lines.append("## Missing Effect Signatures")
	var missing_signatures: Array = Array(summary.get("missing_signatures", []))
	if missing_signatures.is_empty():
		lines.append("- none")
	else:
		for item: Dictionary in missing_signatures.slice(0, 20):
			lines.append("- `%s` in `%s`" % [str(item.get("id", "")), str(item.get("component", ""))])
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
		"- Effect changes: `%d`" % int(summary.get("effect_change_count", 0)),
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

static func _sorted_keys(values: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for key: Variant in values.keys():
		result.append(str(key))
	result.sort()
	return result

static func _inline_field_counts(values: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for key: String in _sorted_keys(values):
		parts.append("%s:%d" % [key, int(values.get(key, 0))])
	return ", ".join(parts)

static func _csv(value: String) -> String:
	var escaped: String = value.replace("\"", "\"\"")
	if escaped.find(",") >= 0 or escaped.find("\"") >= 0 or escaped.find("\n") >= 0:
		return "\"%s\"" % escaped
	return escaped
