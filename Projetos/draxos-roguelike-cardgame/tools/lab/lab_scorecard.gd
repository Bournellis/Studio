extends RefCounted

const SCHEMA_VERSION: int = 1
const TOOL_ID: String = "autorun_lab_scorecard"

static func build(summary: Dictionary, baseline_comparison: Dictionary = {}) -> Dictionary:
	var averages: Dictionary = Dictionary(summary.get("averages", {}))
	var maxes: Dictionary = Dictionary(summary.get("maxes", {}))
	var mins: Dictionary = Dictionary(summary.get("mins", {}))
	var gate_status: String = _gate_status(baseline_comparison)
	var scorecard: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"tool": TOOL_ID,
		"preset": str(summary.get("preset", "")),
		"simulation_mode": str(summary.get("simulation_mode", "")),
		"gate": {
			"status": gate_status,
			"baseline_id": str(baseline_comparison.get("baseline_id", "")),
			"differences": Array(baseline_comparison.get("differences", []))
		},
		"overall": {
			"runs": int(summary.get("total_runs", 0)),
			"victory_rate": float(summary.get("victory_rate", 0.0)),
			"completion_rate": float(summary.get("completion_rate", 0.0)),
			"avg_final_hp": float(averages.get("final_hp", 0.0)),
			"min_final_hp": float(mins.get("final_hp", 0.0)),
			"avg_deck_size": float(averages.get("deck_size", 0.0)),
			"max_deck_size": float(maxes.get("deck_size", 0.0)),
			"avg_relic_count": float(averages.get("relic_count", 0.0)),
			"avg_shop_usage": float(averages.get("shop_usage", 0.0)),
			"avg_souls_left": float(averages.get("souls_left", 0.0)),
			"avg_deaths": float(averages.get("deaths", 0.0)),
			"max_deaths": float(maxes.get("deaths", 0.0)),
			"risk_map_count": Array(summary.get("risk_maps", [])).size()
		},
		"sections": [],
		"class_rows": _group_rows(Dictionary(summary.get("by_class", {})), "class_id"),
		"policy_rows": _group_rows(Dictionary(summary.get("by_policy", {})), "policy_id"),
		"risk_maps": Array(summary.get("risk_maps", [])).duplicate(true),
		"extremes": Dictionary(summary.get("extremes", {})).duplicate(true)
	}
	scorecard["sections"] = [
		_survival_section(scorecard),
		_route_section(summary),
		_economy_section(scorecard),
		_deck_section(scorecard)
	]
	return scorecard

static func markdown(scorecard: Dictionary) -> String:
	var overall: Dictionary = Dictionary(scorecard.get("overall", {}))
	var gate: Dictionary = Dictionary(scorecard.get("gate", {}))
	var lines: PackedStringArray = PackedStringArray([
		"# AutoRun Lab Scorecard",
		"",
		"- Preset: `%s`" % str(scorecard.get("preset", "")),
		"- Simulation: `%s`" % str(scorecard.get("simulation_mode", "")),
		"- Runs: `%d`" % int(overall.get("runs", 0)),
		"- Gate: `%s`%s" % [
			str(gate.get("status", "not_run")).to_upper(),
			(" against `%s`" % str(gate.get("baseline_id", ""))) if str(gate.get("baseline_id", "")) != "" else ""
		],
		""
	])
	lines.append("## Overall")
	lines.append("| Area | Status | Signal |")
	lines.append("|---|---|---|")
	for section: Dictionary in Array(scorecard.get("sections", [])):
		lines.append("| `%s` | `%s` | %s |" % [
			str(section.get("id", "")),
			str(section.get("status", "")),
			str(section.get("signal", ""))
		])
	lines.append("")
	lines.append("## Class Matrix")
	lines.append("| Class | Win | Complete | Avg HP | Avg Deck | Max Deck | Avg Shop | Status |")
	lines.append("|---|---:|---:|---:|---:|---:|---:|---|")
	for row: Dictionary in Array(scorecard.get("class_rows", [])):
		lines.append("| `%s` | %.1f%% | %.1f%% | %.2f | %.2f | %.0f | %.2f | `%s` |" % [
			str(row.get("class_id", "")),
			float(row.get("victory_rate", 0.0)) * 100.0,
			float(row.get("completion_rate", 0.0)) * 100.0,
			float(row.get("avg_final_hp", 0.0)),
			float(row.get("avg_deck_size", 0.0)),
			float(row.get("max_deck_size", 0.0)),
			float(row.get("avg_shop_usage", 0.0)),
			str(row.get("status", ""))
		])
	lines.append("")
	lines.append("## Policy Matrix")
	lines.append("| Policy | Win | Complete | Avg HP | Avg Deck | Avg Shop | Avg Souls Left | Status |")
	lines.append("|---|---:|---:|---:|---:|---:|---:|---|")
	for row: Dictionary in Array(scorecard.get("policy_rows", [])):
		lines.append("| `%s` | %.1f%% | %.1f%% | %.2f | %.2f | %.2f | %.2f | `%s` |" % [
			str(row.get("policy_id", "")),
			float(row.get("victory_rate", 0.0)) * 100.0,
			float(row.get("completion_rate", 0.0)) * 100.0,
			float(row.get("avg_final_hp", 0.0)),
			float(row.get("avg_deck_size", 0.0)),
			float(row.get("avg_shop_usage", 0.0)),
			float(row.get("avg_souls_left", 0.0)),
			str(row.get("status", ""))
		])
	if not Array(scorecard.get("risk_maps", [])).is_empty():
		lines.append("")
		lines.append("## Risk Maps")
		for entry: Dictionary in Array(scorecard.get("risk_maps", [])).slice(0, 8):
			lines.append("- Map `%d`: `%d` risk events" % [int(entry.get("map", 0)), int(entry.get("risk_events", 0))])
	if not Array(gate.get("differences", [])).is_empty():
		lines.append("")
		lines.append("## Gate Differences")
		for difference: Dictionary in Array(gate.get("differences", [])).slice(0, 8):
			lines.append("- `%s`: actual `%s`, expected `%s`" % [
				str(difference.get("field", "")),
				str(difference.get("actual", "")),
				str(difference.get("expected", ""))
			])
	return "\n".join(lines) + "\n"

static func _gate_status(baseline_comparison: Dictionary) -> String:
	if baseline_comparison.is_empty():
		return "not_run"
	return "pass" if bool(baseline_comparison.get("ok", false)) else "fail"

static func _group_rows(groups: Dictionary, id_field: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var keys: Array = groups.keys()
	keys.sort()
	for key: String in keys:
		var group: Dictionary = Dictionary(groups.get(key, {}))
		var averages: Dictionary = Dictionary(group.get("averages", {}))
		var maxes: Dictionary = Dictionary(group.get("maxes", {}))
		var row: Dictionary = {
			id_field: key,
			"victory_rate": float(group.get("victory_rate", 0.0)),
			"completion_rate": float(group.get("completion_rate", 0.0)),
			"avg_final_hp": float(averages.get("final_hp", 0.0)),
			"avg_deck_size": float(averages.get("deck_size", 0.0)),
			"max_deck_size": float(maxes.get("deck_size", 0.0)),
			"avg_shop_usage": float(averages.get("shop_usage", 0.0)),
			"avg_souls_left": float(averages.get("souls_left", 0.0)),
			"max_deaths": float(maxes.get("deaths", 0.0))
		}
		row["status"] = _group_status(row)
		rows.append(row)
	return rows

static func _group_status(row: Dictionary) -> String:
	if float(row.get("victory_rate", 0.0)) < 1.0 or float(row.get("completion_rate", 0.0)) < 1.0 or float(row.get("max_deaths", 0.0)) > 0.0:
		return "fail"
	if float(row.get("avg_final_hp", 0.0)) < 10.0 or float(row.get("max_deck_size", 0.0)) > 42.0:
		return "watch"
	return "pass"

static func _survival_section(scorecard: Dictionary) -> Dictionary:
	var overall: Dictionary = Dictionary(scorecard.get("overall", {}))
	var status: String = "pass"
	if float(overall.get("victory_rate", 0.0)) < 1.0 or float(overall.get("completion_rate", 0.0)) < 1.0 or float(overall.get("max_deaths", 0.0)) > 0.0:
		status = "fail"
	elif float(overall.get("avg_final_hp", 0.0)) < 10.0:
		status = "watch"
	return {
		"id": "survival",
		"status": status,
		"signal": "victory %.1f%%, completion %.1f%%, avg HP %.2f, max deaths %.0f" % [
			float(overall.get("victory_rate", 0.0)) * 100.0,
			float(overall.get("completion_rate", 0.0)) * 100.0,
			float(overall.get("avg_final_hp", 0.0)),
			float(overall.get("max_deaths", 0.0))
		]
	}

static func _route_section(summary: Dictionary) -> Dictionary:
	var averages: Dictionary = Dictionary(summary.get("averages", {}))
	var status: String = "pass"
	var turns: float = float(averages.get("estimated_turns", 0.0))
	if float(averages.get("completed_maps", 0.0)) < 29.0 or turns < 110.0 or turns > 230.0:
		status = "fail"
	return {
		"id": "route",
		"status": status,
		"signal": "avg maps %.2f, avg turns %.2f" % [
			float(averages.get("completed_maps", 0.0)),
			turns
		]
	}

static func _economy_section(scorecard: Dictionary) -> Dictionary:
	var overall: Dictionary = Dictionary(scorecard.get("overall", {}))
	var status: String = "pass"
	if float(overall.get("avg_souls_left", 0.0)) < 15.0 or float(overall.get("avg_shop_usage", 0.0)) > 35.0:
		status = "watch"
	return {
		"id": "economy",
		"status": status,
		"signal": "avg shop %.2f, avg souls left %.2f, avg relics %.2f" % [
			float(overall.get("avg_shop_usage", 0.0)),
			float(overall.get("avg_souls_left", 0.0)),
			float(overall.get("avg_relic_count", 0.0))
		]
	}

static func _deck_section(scorecard: Dictionary) -> Dictionary:
	var overall: Dictionary = Dictionary(scorecard.get("overall", {}))
	var status: String = "pass"
	if float(overall.get("max_deck_size", 0.0)) > 45.0:
		status = "fail"
	elif float(overall.get("avg_deck_size", 0.0)) < 30.0 or float(overall.get("avg_deck_size", 0.0)) > 42.0:
		status = "watch"
	return {
		"id": "deck",
		"status": status,
		"signal": "avg deck %.2f, max deck %.0f" % [
			float(overall.get("avg_deck_size", 0.0)),
			float(overall.get("max_deck_size", 0.0))
		]
	}
