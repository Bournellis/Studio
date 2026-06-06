extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const DesignLabRunnerScript = preload("res://tools/lab/design_lab_runner.gd")
const ProposalLoaderScript = preload("res://tools/lab/design_lab_proposal_loader.gd")
const ReporterScript = preload("res://tools/lab/design_lab_reporter.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	quit(_run_design_lab())

func _run_design_lab() -> int:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var options: Dictionary = _parse_options(args)
	print("[run_design_lab] pack=%s card=%s components=%s mode=%s profile=%s max_variants=%d" % [
		str(options.get("pack", "")),
		",".join(PackedStringArray(options.get("cards", PackedStringArray()))),
		",".join(PackedStringArray(options.get("components", PackedStringArray()))),
		str(options.get("mode", "")),
		str(options.get("profile", "pack-default")) if str(options.get("profile", "")) != "" else "pack-default",
		int(options.get("max_variants", 0))
	])
	var load_result: Dictionary = ProposalLoaderScript.load_pack_result(str(options.get("pack", "")))
	if not bool(load_result.get("ok", false)):
		printerr("[run_design_lab] %s" % str(load_result.get("message", "Could not load design proposal pack.")))
		return 1
	var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[run_design_lab] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1
	var content_library = root.get_node_or_null("ContentLibrary")
	if content_library == null:
		printerr("[run_design_lab] ContentLibrary autoload is missing.")
		return 1
	content_library.reload()
	var catalog = content_library.get_catalog()
	if catalog == null:
		printerr("[run_design_lab] Missing generated slice catalog.")
		return 1
	var report: Dictionary = DesignLabRunnerScript.run(catalog, Dictionary(load_result.get("pack", {})), Dictionary(load_result.get("registry", {})), options)
	var write_result: Dictionary = ReporterScript.write_outputs(str(options.get("out", "")), report, options)
	if not bool(write_result.get("ok", false)):
		printerr("[run_design_lab] %s" % str(write_result.get("message", "Failed to write outputs.")))
		return 1
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	print("[run_design_lab] wrote %s, %s, %s, %s, and %s" % [
		str(write_result.get("results_path", "")),
		str(write_result.get("csv_path", "")),
		str(write_result.get("summary_path", "")),
		str(write_result.get("gate_path", "")),
		str(write_result.get("promotion_path", ""))
	])
	print("[run_design_lab] gate=%s candidates=%d recommendations=%d blocked_mechanics=%d" % [
		"PASS" if bool(summary.get("gate_ok", false)) else "FAIL",
		int(summary.get("candidate_count", 0)),
		int(summary.get("recommendation_count", 0)),
		int(summary.get("blocked_mechanic_count", 0))
	])
	if str(options.get("mode", "explore")) == "gate" and not bool(summary.get("gate_ok", false)):
		return 1
	return 0

func _parse_options(args: PackedStringArray) -> Dictionary:
	var raw: Dictionary = {
		"pack": ProposalLoaderScript.default_pack_id(),
		"cards": PackedStringArray(["all"]),
		"mode": "explore",
		"components": PackedStringArray(["battle", "encounter"]),
		"profile": "",
		"max_variants": 40,
		"out": "",
		"stop_on_failure": false,
		"command": "run_design_lab %s" % " ".join(Array(args))
	}
	for arg: String in args:
		if arg.begins_with("--pack="):
			raw["pack"] = arg.trim_prefix("--pack=")
		elif arg.begins_with("--card="):
			raw["cards"] = _split_string_list(arg.trim_prefix("--card="))
		elif arg.begins_with("--cards="):
			raw["cards"] = _split_string_list(arg.trim_prefix("--cards="))
		elif arg.begins_with("--mode="):
			raw["mode"] = arg.trim_prefix("--mode=")
		elif arg == "--gate":
			raw["mode"] = "gate"
		elif arg.begins_with("--components="):
			raw["components"] = _split_string_list(arg.trim_prefix("--components="))
		elif arg.begins_with("--profile="):
			raw["profile"] = arg.trim_prefix("--profile=")
		elif arg.begins_with("--max-variants="):
			raw["max_variants"] = int(arg.trim_prefix("--max-variants="))
		elif arg.begins_with("--out="):
			raw["out"] = arg.trim_prefix("--out=")
		elif arg == "--stop-on-failure":
			raw["stop_on_failure"] = true
	if str(raw.get("out", "")) == "":
		raw["out"] = "user://design_lab/%s" % str(raw.get("pack", ProposalLoaderScript.default_pack_id()))
	return raw

func _split_string_list(value: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	for item: String in value.split(",", false):
		var trimmed: String = item.strip_edges()
		if trimmed != "":
			result.append(trimmed)
	if result.is_empty():
		result.append("all")
	return result
