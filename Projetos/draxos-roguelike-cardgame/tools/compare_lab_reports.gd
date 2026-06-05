extends SceneTree

const LabDiffReporterScript = preload("res://tools/lab/lab_diff_reporter.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	quit(_run_compare())

func _run_compare() -> int:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var options: Dictionary = _parse_options(args)
	if str(options.get("before", "")) == "" or str(options.get("after", "")) == "":
		printerr("[compare_lab_reports] --before and --after are required.")
		return 1
	var compare_options: Dictionary = {
		"type": str(options.get("type", "auto")),
		"numeric_threshold": float(options.get("numeric_threshold", 0.0)),
		"command": str(options.get("command", ""))
	}
	var report: Dictionary = LabDiffReporterScript.compare(str(options.get("before", "")), str(options.get("after", "")), compare_options)
	if not bool(report.get("ok", false)):
		printerr("[compare_lab_reports] %s" % str(report.get("message", "Could not compare lab reports.")))
		return 1
	var write_result: Dictionary = LabDiffReporterScript.write_outputs(str(options.get("out", "")), report, compare_options)
	if not bool(write_result.get("ok", false)):
		printerr("[compare_lab_reports] %s" % str(write_result.get("message", "Could not write lab diff outputs.")))
		return 1
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	print("[compare_lab_reports] type=%s changed=%d unchanged=%d added=%d removed=%d status_changes=%d metric_changes=%d new_failures=%d" % [
		str(report.get("type", "")),
		int(summary.get("changed_count", 0)),
		int(summary.get("unchanged_count", 0)),
		int(summary.get("added_count", 0)),
		int(summary.get("removed_count", 0)),
		int(summary.get("status_change_count", 0)),
		int(summary.get("metric_change_count", 0)),
		int(summary.get("new_failure_count", 0))
	])
	print("[compare_lab_reports] wrote %s, %s, %s, and %s" % [
		str(write_result.get("json_path", "")),
		str(write_result.get("csv_path", "")),
		str(write_result.get("markdown_path", "")),
		str(write_result.get("gate_path", ""))
	])
	if str(options.get("mode", "explore")) == "gate" and not bool(summary.get("gate_ok", true)):
		return 1
	return 0

func _parse_options(args: PackedStringArray) -> Dictionary:
	var raw: Dictionary = {
		"before": "",
		"after": "",
		"type": "auto",
		"out": "user://lab_diff/latest",
		"mode": "explore",
		"numeric_threshold": 0.0,
		"command": "compare_lab_reports %s" % " ".join(Array(args))
	}
	for arg: String in args:
		if arg.begins_with("--before="):
			raw["before"] = arg.trim_prefix("--before=")
		elif arg.begins_with("--after="):
			raw["after"] = arg.trim_prefix("--after=")
		elif arg.begins_with("--type="):
			raw["type"] = arg.trim_prefix("--type=")
		elif arg.begins_with("--out="):
			raw["out"] = arg.trim_prefix("--out=")
		elif arg.begins_with("--mode="):
			raw["mode"] = arg.trim_prefix("--mode=")
		elif arg == "--gate":
			raw["mode"] = "gate"
		elif arg.begins_with("--numeric-threshold="):
			raw["numeric_threshold"] = float(arg.trim_prefix("--numeric-threshold="))
	return raw
