extends RefCounted

const SCHEMA_VERSION: int = 1
const TOOL_ID: String = "lab_diff_reporter"
const TYPE_AUTO: String = "auto"
const TYPE_BATTLE: String = "battle"
const TYPE_SCENARIO: String = "scenario"
const TYPE_RUN_LAB: String = "run_lab"
const STATUS_PASS: String = "PASS"
const STATUS_WARN: String = "WARN"
const STATUS_FAIL: String = "FAIL"

const CSV_HEADERS: PackedStringArray = [
	"id",
	"change_type",
	"before_status",
	"after_status",
	"field",
	"before_value",
	"after_value",
	"delta",
	"tags"
]

static func compare(before_dir: String, after_dir: String, options: Dictionary = {}) -> Dictionary:
	var requested_type: String = str(options.get("type", TYPE_AUTO))
	var detect_result: Dictionary = detect_type(before_dir, after_dir, requested_type)
	if not bool(detect_result.get("ok", false)):
		return detect_result
	var report_type: String = str(detect_result.get("type", ""))
	var before_path: String = _result_path_for(before_dir, report_type)
	var after_path: String = _result_path_for(after_dir, report_type)
	var before_load: Dictionary = _load_json(before_path)
	if not bool(before_load.get("ok", false)):
		return before_load
	var after_load: Dictionary = _load_json(after_path)
	if not bool(after_load.get("ok", false)):
		return after_load
	var report: Dictionary = compare_payloads(
		Dictionary(before_load.get("payload", {})),
		Dictionary(after_load.get("payload", {})),
		report_type,
		options
	)
	report["before_path"] = before_path
	report["after_path"] = after_path
	return report

static func detect_type(before_dir: String, after_dir: String, requested_type: String = TYPE_AUTO) -> Dictionary:
	var normalized_before: String = _normalize_dir(before_dir)
	var normalized_after: String = _normalize_dir(after_dir)
	if requested_type != TYPE_AUTO:
		if not _is_supported_type(requested_type):
			return {"ok": false, "message": "Unsupported lab diff type `%s`." % requested_type}
		var before_path: String = _result_path_for(normalized_before, requested_type)
		var after_path: String = _result_path_for(normalized_after, requested_type)
		if not FileAccess.file_exists(before_path):
			return {"ok": false, "message": "Missing before report `%s`." % before_path}
		if not FileAccess.file_exists(after_path):
			return {"ok": false, "message": "Missing after report `%s`." % after_path}
		return {"ok": true, "type": requested_type}
	for report_type: String in [TYPE_BATTLE, TYPE_SCENARIO, TYPE_RUN_LAB]:
		var before_path: String = _result_path_for(normalized_before, report_type)
		var after_path: String = _result_path_for(normalized_after, report_type)
		if FileAccess.file_exists(before_path) and FileAccess.file_exists(after_path):
			return {"ok": true, "type": report_type}
	return {"ok": false, "message": "Could not auto-detect matching lab reports in `%s` and `%s`." % [before_dir, after_dir]}

static func compare_payloads(before_payload: Dictionary, after_payload: Dictionary, report_type: String, options: Dictionary = {}) -> Dictionary:
	var threshold: float = float(options.get("numeric_threshold", 0.0))
	var before_records: Array[Dictionary] = _records_from_payload(before_payload, report_type)
	var after_records: Array[Dictionary] = _records_from_payload(after_payload, report_type)
	var before_map: Dictionary = _record_map(before_records, report_type)
	var after_map: Dictionary = _record_map(after_records, report_type)
	var ids: Array = before_map.keys()
	for id in after_map.keys():
		if not ids.has(id):
			ids.append(id)
	ids.sort()

	var diffs: Array[Dictionary] = []
	var unchanged_count: int = 0
	var changed_count: int = 0
	var added_count: int = 0
	var removed_count: int = 0
	var status_change_count: int = 0
	var new_failure_count: int = 0
	var resolved_failure_count: int = 0
	var new_warning_count: int = 0
	var resolved_warning_count: int = 0
	var metric_change_count: int = 0

	for id in ids:
		var has_before: bool = before_map.has(id)
		var has_after: bool = after_map.has(id)
		if not has_before:
			added_count += 1
			var added_record: Dictionary = Dictionary(after_map.get(id, {}))
			var added_status: String = _record_status(added_record)
			if added_status == STATUS_FAIL:
				new_failure_count += 1
			elif added_status == STATUS_WARN:
				new_warning_count += 1
			diffs.append(_added_removed_diff(str(id), "added", {}, added_record, report_type))
			continue
		if not has_after:
			removed_count += 1
			var removed_record: Dictionary = Dictionary(before_map.get(id, {}))
			var removed_status: String = _record_status(removed_record)
			if removed_status == STATUS_FAIL:
				resolved_failure_count += 1
			elif removed_status == STATUS_WARN:
				resolved_warning_count += 1
			diffs.append(_added_removed_diff(str(id), "removed", removed_record, {}, report_type))
			continue
		var before_record: Dictionary = Dictionary(before_map.get(id, {}))
		var after_record: Dictionary = Dictionary(after_map.get(id, {}))
		var before_status: String = _record_status(before_record)
		var after_status: String = _record_status(after_record)
		var metric_changes: Array[Dictionary] = _metric_changes(before_record, after_record, report_type, threshold)
		var status_changed: bool = before_status != after_status
		if status_changed:
			status_change_count += 1
			if after_status == STATUS_FAIL:
				new_failure_count += 1
			elif before_status == STATUS_FAIL and after_status != STATUS_FAIL:
				resolved_failure_count += 1
			if after_status == STATUS_WARN:
				new_warning_count += 1
			elif before_status == STATUS_WARN and after_status != STATUS_WARN:
				resolved_warning_count += 1
		metric_change_count += metric_changes.size()
		if status_changed or not metric_changes.is_empty():
			changed_count += 1
			diffs.append({
				"id": str(id),
				"name": _record_name(after_record, before_record, report_type),
				"change_type": "changed",
				"before_status": before_status,
				"after_status": after_status,
				"status_changed": status_changed,
				"metric_changes": metric_changes,
				"tags": _merged_tags(before_record, after_record)
			})
		else:
			unchanged_count += 1

	var summary: Dictionary = {
		"type": report_type,
		"total_before": before_records.size(),
		"total_after": after_records.size(),
		"common_count": ids.size() - added_count - removed_count,
		"unchanged_count": unchanged_count,
		"changed_count": changed_count,
		"added_count": added_count,
		"removed_count": removed_count,
		"status_change_count": status_change_count,
		"new_failure_count": new_failure_count,
		"resolved_failure_count": resolved_failure_count,
		"new_warning_count": new_warning_count,
		"resolved_warning_count": resolved_warning_count,
		"metric_change_count": metric_change_count,
		"gate_ok": new_failure_count == 0 and removed_count == 0,
		"has_changes": changed_count > 0 or added_count > 0 or removed_count > 0
	}
	return {
		"ok": true,
		"schema_version": SCHEMA_VERSION,
		"tool": TOOL_ID,
		"type": report_type,
		"summary": summary,
		"diffs": diffs,
		"options": options.duplicate(true)
	}

static func write_outputs(output_dir: String, report: Dictionary, options: Dictionary = {}) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var json_path: String = "%s/lab_diff.json" % output_dir
	var csv_path: String = "%s/lab_diff.csv" % output_dir
	var markdown_path: String = "%s/lab_diff.md" % output_dir
	var gate_path: String = "%s/lab_diff_gate.md" % output_dir
	var json_result: Dictionary = _write_json(json_path, report)
	if not bool(json_result.get("ok", false)):
		return json_result
	var csv_result: Dictionary = _write_csv(csv_path, Array(report.get("diffs", [])))
	if not bool(csv_result.get("ok", false)):
		return csv_result
	var markdown_result: Dictionary = _write_text(markdown_path, markdown(report, options))
	if not bool(markdown_result.get("ok", false)):
		return markdown_result
	var gate_result: Dictionary = _write_text(gate_path, gate_markdown(report, options))
	if not bool(gate_result.get("ok", false)):
		return gate_result
	return {
		"ok": true,
		"json_path": json_path,
		"csv_path": csv_path,
		"markdown_path": markdown_path,
		"gate_path": gate_path
	}

static func markdown(report: Dictionary, options: Dictionary = {}) -> String:
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var lines: PackedStringArray = PackedStringArray([
		"# Lab Diff Report",
		"",
		"- Type: `%s`" % str(report.get("type", "")),
		"- Before: `%s`" % str(report.get("before_path", "")),
		"- After: `%s`" % str(report.get("after_path", "")),
		"- Records before/after: `%d/%d`" % [int(summary.get("total_before", 0)), int(summary.get("total_after", 0))],
		"- Changed/unchanged: `%d/%d`" % [int(summary.get("changed_count", 0)), int(summary.get("unchanged_count", 0))],
		"- Added/removed: `%d/%d`" % [int(summary.get("added_count", 0)), int(summary.get("removed_count", 0))],
		"- Status changes: `%d`" % int(summary.get("status_change_count", 0)),
		"- New failures/resolved failures: `%d/%d`" % [int(summary.get("new_failure_count", 0)), int(summary.get("resolved_failure_count", 0))],
		"- New warnings/resolved warnings: `%d/%d`" % [int(summary.get("new_warning_count", 0)), int(summary.get("resolved_warning_count", 0))],
		"- Metric changes: `%d`" % int(summary.get("metric_change_count", 0)),
		"- Gate: `%s`" % ("PASS" if bool(summary.get("gate_ok", true)) else "FAIL"),
		"- Command: `%s`" % str(options.get("command", "")),
		"",
		"## Status Changes",
		"| ID | Before | After | Tags |",
		"|---|---:|---:|---|"
	])
	var status_rows: int = 0
	for diff: Dictionary in Array(report.get("diffs", [])):
		if bool(diff.get("status_changed", false)) or str(diff.get("change_type", "")) in ["added", "removed"]:
			status_rows += 1
			lines.append("| `%s` | `%s` | `%s` | `%s` |" % [
				str(diff.get("id", "")),
				str(diff.get("before_status", "")),
				str(diff.get("after_status", "")),
				";".join(Array(diff.get("tags", [])))
			])
	if status_rows == 0:
		lines.append("| _none_ |  |  |  |")
	lines.append("")
	lines.append("## Metric Changes")
	lines.append("| ID | Field | Before | After | Delta |")
	lines.append("|---|---|---:|---:|---:|")
	var metric_rows: int = 0
	for diff: Dictionary in Array(report.get("diffs", [])):
		for change: Dictionary in Array(diff.get("metric_changes", [])):
			metric_rows += 1
			if metric_rows > 80:
				continue
			lines.append("| `%s` | `%s` | `%s` | `%s` | `%s` |" % [
				str(diff.get("id", "")),
				str(change.get("field", "")),
				str(change.get("before", "")),
				str(change.get("after", "")),
				str(change.get("delta", ""))
			])
	if metric_rows == 0:
		lines.append("| _none_ |  |  |  |  |")
	elif metric_rows > 80:
		lines.append("| `_truncated` | `metric_changes` |  |  | `%d more` |" % (metric_rows - 80))
	lines.append("")
	lines.append("## Changed Records")
	for diff: Dictionary in Array(report.get("diffs", [])).slice(0, 40):
		var metric_count: int = Array(diff.get("metric_changes", [])).size()
		lines.append("- `%s`: `%s` -> `%s`, `%d` metric changes" % [
			str(diff.get("id", "")),
			str(diff.get("before_status", "")),
			str(diff.get("after_status", "")),
			metric_count
		])
	return "\n".join(lines) + "\n"

static func gate_markdown(report: Dictionary, options: Dictionary = {}) -> String:
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	var status: String = "PASS" if bool(summary.get("gate_ok", true)) else "FAIL"
	var lines: PackedStringArray = PackedStringArray([
		"# Lab Diff Gate",
		"",
		"- Status: `%s`" % status,
		"- Type: `%s`" % str(report.get("type", "")),
		"- New failures: `%d`" % int(summary.get("new_failure_count", 0)),
		"- Removed records: `%d`" % int(summary.get("removed_count", 0)),
		"- Status changes: `%d`" % int(summary.get("status_change_count", 0)),
		"- Metric changes: `%d`" % int(summary.get("metric_change_count", 0)),
		"- Command: `%s`" % str(options.get("command", "")),
		"",
		"## Blocking Changes"
	])
	var blocking_count: int = 0
	for diff: Dictionary in Array(report.get("diffs", [])):
		if str(diff.get("after_status", "")) == STATUS_FAIL and str(diff.get("before_status", "")) != STATUS_FAIL:
			blocking_count += 1
			lines.append("- `%s`: `%s` -> `%s`" % [str(diff.get("id", "")), str(diff.get("before_status", "")), str(diff.get("after_status", ""))])
		elif str(diff.get("change_type", "")) == "removed":
			blocking_count += 1
			lines.append("- `%s`: removed from after report" % str(diff.get("id", "")))
	if blocking_count == 0:
		lines.append("- none")
	return "\n".join(lines) + "\n"

static func _records_from_payload(payload: Dictionary, report_type: String) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if payload.has("records"):
		for record_value in Array(payload.get("records", [])):
			records.append(Dictionary(record_value).duplicate(true))
		return records
	if report_type == TYPE_RUN_LAB and payload.has("runs"):
		for run_value in Array(payload.get("runs", [])):
			var result: Dictionary = Dictionary(run_value).duplicate(true)
			records.append({
				"schema_version": SCHEMA_VERSION,
				"tool": "autorun_lab",
				"case": {"case_id": str(result.get("case_id", ""))},
				"result": result,
				"timeline": Array(result.get("timeline", [])),
				"warnings": [],
				"tags": [str(result.get("class_id", "")), str(result.get("policy_id", ""))]
			})
	return records

static func _record_map(records: Array[Dictionary], report_type: String) -> Dictionary:
	var mapped: Dictionary = {}
	for record: Dictionary in records:
		var id: String = _record_id(record, report_type)
		if id != "":
			mapped[id] = record
	return mapped

static func _record_id(record: Dictionary, report_type: String) -> String:
	var entity: Dictionary = Dictionary(record.get(_entity_key(report_type), {}))
	var result: Dictionary = Dictionary(record.get("result", {}))
	for key: String in ["id", "case_id", "scenario_id"]:
		if entity.has(key) and str(entity.get(key, "")) != "":
			return str(entity.get(key, ""))
		if result.has(key) and str(result.get(key, "")) != "":
			return str(result.get(key, ""))
	if report_type == TYPE_RUN_LAB:
		return "%s_%s_%s" % [str(result.get("class_id", "")), str(result.get("policy_id", "")), str(result.get("seed", ""))]
	return ""

static func _record_name(primary_record: Dictionary, fallback_record: Dictionary, report_type: String) -> String:
	var entity: Dictionary = Dictionary(primary_record.get(_entity_key(report_type), {}))
	if not entity.has("name"):
		entity = Dictionary(fallback_record.get(_entity_key(report_type), {}))
	return str(entity.get("name", ""))

static func _record_status(record: Dictionary) -> String:
	if record.has("status"):
		return str(record.get("status", ""))
	var result: Dictionary = Dictionary(record.get("result", {}))
	if result.has("ok") and not bool(result.get("ok", false)):
		return STATUS_FAIL
	if not Array(record.get("warnings", [])).is_empty():
		return STATUS_WARN
	return STATUS_PASS

static func _metric_changes(before_record: Dictionary, after_record: Dictionary, report_type: String, threshold: float) -> Array[Dictionary]:
	var changes: Array[Dictionary] = []
	var before_result: Dictionary = Dictionary(before_record.get("result", {}))
	var after_result: Dictionary = Dictionary(after_record.get("result", {}))
	for field: String in _metric_fields(report_type):
		var before_value = before_result.get(field, null)
		var after_value = after_result.get(field, null)
		if before_value == null and after_value == null:
			continue
		if _values_equal(before_value, after_value, threshold):
			continue
		changes.append({
			"field": field,
			"before": before_value,
			"after": after_value,
			"delta": _delta_value(before_value, after_value)
		})
	if report_type == TYPE_BATTLE:
		changes.append_array(_effect_signature_changes(before_result, after_result, threshold))
	return changes

static func _effect_signature_changes(before_result: Dictionary, after_result: Dictionary, threshold: float) -> Array[Dictionary]:
	var changes: Array[Dictionary] = []
	var before_signature: Dictionary = Dictionary(before_result.get("card_effect_signature", {}))
	var after_signature: Dictionary = Dictionary(after_result.get("card_effect_signature", {}))
	if before_signature.is_empty() and after_signature.is_empty():
		return changes
	for field: String in _effect_signature_fields():
		var before_value = before_signature.get(field, null)
		var after_value = after_signature.get(field, null)
		if before_value == null and after_value == null:
			continue
		if _values_equal(before_value, after_value, threshold):
			continue
		changes.append({
			"field": "effect.%s" % field,
			"before": before_value,
			"after": after_value,
			"delta": _delta_value(before_value, after_value)
		})
	return changes

static func _effect_signature_fields() -> PackedStringArray:
	return PackedStringArray([
		"present",
		"sample_count",
		"summons_created",
		"summoned_count",
		"summoned_slot_count",
		"summoned_keyword_count",
		"player_units_delta",
		"enemy_units_delta",
		"enemy_hero_damage",
		"player_hero_damage",
		"enemy_slot_damage_total",
		"player_slot_damage_total",
		"ally_attack_buff_total",
		"ally_health_buff_total",
		"enemy_attack_debuff_total",
		"enemy_health_debuff_total",
		"ally_keyword_gain_count",
		"ally_shield_gain",
		"ally_resistance_gain",
		"enemy_keyword_loss_count",
		"poison_added_total",
		"enemy_poison_added",
		"freeze_added_total",
		"enemy_frozen_added",
		"enemy_snared_added",
		"enemy_slow_added",
		"shield_added_total",
		"mana_gained",
		"temporary_ability_power_delta",
		"temporary_ability_power_gained",
		"temporary_ability_power_lost",
		"ashes_gained",
		"cards_drawn",
		"cards_discarded",
		"cards_created",
		"deck_delta",
		"hand_delta",
		"discard_delta",
		"card_flow_observed",
		"card_flow_expected",
		"card_flow_missing_reason",
		"pending_choices_delta",
		"pending_choice_created",
		"pending_choice_resolved",
		"sacrifice_required",
		"sacrifice_consumed",
		"sacrifice_units_destroyed",
		"log_added",
		"visual_events_added",
		"summoned_attack_total",
		"summoned_health_total",
		"focused_card_play_index",
		"target_card_play_count",
		"target_card_first_play_turn",
		"target_card_first_play_cycle",
		"stopped_after_target",
		"target_capture_mode",
		"capture_quality",
		"support_cards_before_target",
		"support_cards_after_target",
		"support_card_count_before_target",
		"support_card_count_after_target",
		"support_contamination_status",
		"signature_confidence",
		"ambiguous_reason",
		"ambiguity_reasons",
		"keywords_added",
		"keywords_removed",
		"families",
		"enemy_card_played",
		"enemy_card_play_count",
		"enemy_summons_created",
		"enemy_summoned_count",
		"enemy_summoned_attack_total",
		"enemy_summoned_health_total",
		"enemy_summoned_keyword_count",
		"enemy_keywords_added",
		"enemy_damage_to_player_hero",
		"enemy_damage_to_player_slots",
		"enemy_player_units_delta",
		"enemy_combat_damage_to_player_hero",
		"enemy_combat_damage_to_player_slots",
		"enemy_signature_phase",
		"enemy_signature_confidence"
	])

static func _metric_fields(report_type: String) -> PackedStringArray:
	if report_type == TYPE_BATTLE:
		return PackedStringArray([
			"outcome",
			"terminated",
			"turn_count",
			"combat_cycles",
			"player_hp",
			"enemy_hp",
			"cards_played",
			"player_units_alive",
			"enemy_units_alive",
			"damage_to_enemy_hero",
			"damage_to_player_hero"
		])
	if report_type == TYPE_SCENARIO:
		return PackedStringArray([
			"completed_maps",
			"map_count",
			"final_hp",
			"deaths",
			"deck_size",
			"shop_usage",
			"souls_left",
			"relic_count",
			"souls_earned",
			"souls_spent"
		])
	return PackedStringArray([
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
		"deaths"
	])

static func _values_equal(before_value, after_value, threshold: float) -> bool:
	if _is_number(before_value) and _is_number(after_value):
		return abs(float(after_value) - float(before_value)) <= threshold
	return before_value == after_value

static func _delta_value(before_value, after_value):
	if _is_number(before_value) and _is_number(after_value):
		var delta: float = float(after_value) - float(before_value)
		if is_equal_approx(delta, round(delta)):
			return int(round(delta))
		return delta
	return ""

static func _is_number(value) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

static func _added_removed_diff(id: String, change_type: String, before_record: Dictionary, after_record: Dictionary, report_type: String) -> Dictionary:
	return {
		"id": id,
		"name": _record_name(after_record, before_record, report_type),
		"change_type": change_type,
		"before_status": _record_status(before_record) if not before_record.is_empty() else "",
		"after_status": _record_status(after_record) if not after_record.is_empty() else "",
		"status_changed": true,
		"metric_changes": [],
		"tags": _merged_tags(before_record, after_record)
	}

static func _merged_tags(before_record: Dictionary, after_record: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	for tag_value in Array(before_record.get("tags", [])):
		var tag: String = str(tag_value)
		if tag != "" and not tags.has(tag):
			tags.append(tag)
	for tag_value in Array(after_record.get("tags", [])):
		var tag: String = str(tag_value)
		if tag != "" and not tags.has(tag):
			tags.append(tag)
	tags.sort()
	return tags

static func _entity_key(report_type: String) -> String:
	if report_type == TYPE_SCENARIO:
		return "scenario"
	return "case"

static func _is_supported_type(report_type: String) -> bool:
	return report_type in [TYPE_BATTLE, TYPE_SCENARIO, TYPE_RUN_LAB]

static func _result_path_for(dir_path: String, report_type: String) -> String:
	var base: String = _normalize_dir(dir_path)
	if report_type == TYPE_BATTLE:
		return "%s/battle_results.json" % base
	if report_type == TYPE_SCENARIO:
		return "%s/scenario_results.json" % base
	if report_type == TYPE_RUN_LAB:
		var detailed_path: String = "%s/run_lab_detailed.json" % base
		if FileAccess.file_exists(detailed_path):
			return detailed_path
		return "%s/run_lab_metrics.json" % base
	return ""

static func _normalize_dir(dir_path: String) -> String:
	var normalized: String = dir_path.strip_edges()
	while normalized.ends_with("/") or normalized.ends_with("\\"):
		normalized = normalized.substr(0, normalized.length() - 1)
	return normalized

static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "message": "Missing report `%s`." % path}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "message": "Could not read `%s`." % path}
	var text: String = file.get_as_text()
	file.close()
	var payload = JSON.parse_string(text)
	if typeof(payload) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Report `%s` is not a JSON object." % path}
	return {"ok": true, "payload": Dictionary(payload)}

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

static func _write_csv(path: String, diffs: Array) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write `%s`." % path}
	file.store_line(",".join(CSV_HEADERS))
	for diff_value in diffs:
		var diff: Dictionary = Dictionary(diff_value)
		if str(diff.get("change_type", "")) in ["added", "removed"]:
			_write_csv_row(file, diff, str(diff.get("change_type", "")), "", "", "")
		if bool(diff.get("status_changed", false)):
			_write_csv_row(file, diff, "status", "status", str(diff.get("before_status", "")), str(diff.get("after_status", "")))
		for change_value in Array(diff.get("metric_changes", [])):
			var change: Dictionary = Dictionary(change_value)
			_write_csv_row(file, diff, "metric", str(change.get("field", "")), str(change.get("before", "")), str(change.get("after", "")), str(change.get("delta", "")))
	file.close()
	return {"ok": true, "path": path}

static func _write_csv_row(file: FileAccess, diff: Dictionary, change_type: String, field: String, before_value: String, after_value: String, delta: String = "") -> void:
	var row: PackedStringArray = [
		_csv_escape(str(diff.get("id", ""))),
		_csv_escape(change_type),
		_csv_escape(str(diff.get("before_status", ""))),
		_csv_escape(str(diff.get("after_status", ""))),
		_csv_escape(field),
		_csv_escape(before_value),
		_csv_escape(after_value),
		_csv_escape(delta),
		_csv_escape(";".join(Array(diff.get("tags", []))))
	]
	file.store_line(",".join(row))

static func _csv_escape(value: String) -> String:
	if value.find(",") >= 0 or value.find("\"") >= 0 or value.find("\n") >= 0:
		return "\"%s\"" % value.replace("\"", "\"\"")
	return value
