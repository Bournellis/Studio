extends SceneTree

const CardImpactPackLoaderScript = preload("res://tools/lab/card_impact_pack_loader.gd")
const CardImpactReporterScript = preload("res://tools/lab/card_impact_reporter.gd")
const CardImpactRunnerScript = preload("res://tools/lab/card_impact_runner.gd")
const ContentGeneratorScript = preload("res://tools/content_generator.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	quit(_run_card_impact())

func _run_card_impact() -> int:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var options: Dictionary = _parse_options(args)
	print("[run_card_impact] pack=%s phase=%s cards=%s components=%s mode=%s" % [
		str(options.get("pack", "")),
		str(options.get("phase", "")),
		",".join(PackedStringArray(options.get("cards", PackedStringArray()))),
		",".join(PackedStringArray(options.get("components", PackedStringArray()))),
		str(options.get("mode", "explore"))
	])
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result(str(options.get("pack", "")))
	if not bool(load_result.get("ok", false)):
		printerr("[run_card_impact] %s" % str(load_result.get("message", "Could not load card impact pack.")))
		return 1
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))

	var catalog = null
	var session = null
	if str(options.get("phase", "")) != "compare":
		var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
		if not bool(content_result.get("ok", false)):
			printerr("[run_card_impact] %s" % str(content_result.get("message", "Content generation failed.")))
			return 1
		var content_library = root.get_node_or_null("ContentLibrary")
		if content_library == null:
			printerr("[run_card_impact] ContentLibrary autoload is missing.")
			return 1
		content_library.reload()
		catalog = content_library.get_catalog()
		if catalog == null:
			printerr("[run_card_impact] Missing generated slice catalog.")
			return 1
		session = root.get_node_or_null("RunSession")
		if session == null:
			printerr("[run_card_impact] RunSession autoload is missing.")
			return 1

	var report: Dictionary = CardImpactRunnerScript.run_phase(catalog, session, pack, options)
	var write_result: Dictionary = CardImpactReporterScript.write_outputs(str(options.get("out", "")), report, options)
	if not bool(write_result.get("ok", false)):
		printerr("[run_card_impact] %s" % str(write_result.get("message", "Failed to write outputs.")))
		return 1
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	print("[run_card_impact] wrote %s, %s, %s, %s, and %s" % [
		str(write_result.get("results_path", "")),
		str(write_result.get("csv_path", "")),
		str(write_result.get("summary_path", "")),
		str(write_result.get("markdown_path", "")),
		str(write_result.get("gate_path", ""))
	])
	print("[run_card_impact] gate=%s structural_errors=%d new_failures=%d removed=%d" % [
		"PASS" if bool(summary.get("gate_ok", false)) else "FAIL",
		Array(summary.get("structural_errors", [])).size(),
		int(summary.get("new_failure_count", 0)),
		int(summary.get("removed_count", 0))
	])
	if str(options.get("mode", "explore")) == "gate" and not bool(summary.get("gate_ok", false)):
		return 1
	return 0

func _parse_options(args: PackedStringArray) -> Dictionary:
	var raw: Dictionary = {
		"pack": CardImpactPackLoaderScript.default_pack_id(),
		"phase": "before",
		"out": "",
		"cards": PackedStringArray(["all"]),
		"components": PackedStringArray(["battle", "scenario", "run_lab"]),
		"mode": "explore",
		"stop_on_failure": false,
		"numeric_threshold": 0.0,
		"command": "run_card_impact %s" % " ".join(Array(args))
	}
	for arg: String in args:
		if arg.begins_with("--pack="):
			raw["pack"] = arg.trim_prefix("--pack=")
		elif arg.begins_with("--phase="):
			raw["phase"] = arg.trim_prefix("--phase=")
		elif arg.begins_with("--out="):
			raw["out"] = arg.trim_prefix("--out=")
		elif arg.begins_with("--cards="):
			raw["cards"] = _split_string_list(arg.trim_prefix("--cards="))
		elif arg.begins_with("--components="):
			raw["components"] = _split_string_list(arg.trim_prefix("--components="))
		elif arg.begins_with("--mode="):
			raw["mode"] = arg.trim_prefix("--mode=")
		elif arg == "--gate":
			raw["mode"] = "gate"
		elif arg == "--stop-on-failure":
			raw["stop_on_failure"] = true
		elif arg.begins_with("--numeric-threshold="):
			raw["numeric_threshold"] = float(arg.trim_prefix("--numeric-threshold="))
	if not (str(raw.get("phase", "")).to_lower() in ["before", "after", "compare"]):
		raw["phase"] = "before"
	if str(raw.get("out", "")) == "":
		raw["out"] = "user://card_impact/%s" % str(raw.get("pack", CardImpactPackLoaderScript.default_pack_id()))
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
