extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const ScenarioFixtureLoaderScript = preload("res://tools/lab/scenario_fixture_loader.gd")
const ScenarioReporterScript = preload("res://tools/lab/scenario_reporter.gd")
const ScenarioRunnerScript = preload("res://tools/lab/scenario_runner.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = _run_scenarios()
	quit(exit_code)

func _run_scenarios() -> int:
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	var options: Dictionary = _parse_options(user_args)
	print("[run_scenarios] pack=%s scenario=%s tags=%s mode=%s" % [
		str(options.get("pack", "")),
		str(options.get("scenario", "")),
		",".join(PackedStringArray(options.get("tags", PackedStringArray()))),
		str(options.get("mode", "explore"))
	])
	var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[run_scenarios] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1
	var content_library = root.get_node_or_null("ContentLibrary")
	if content_library == null:
		printerr("[run_scenarios] ContentLibrary autoload is missing.")
		return 1
	content_library.reload()
	var catalog = content_library.get_catalog()
	if catalog == null:
		printerr("[run_scenarios] Missing generated slice catalog.")
		return 1
	var session = root.get_node_or_null("RunSession")
	if session == null:
		printerr("[run_scenarios] RunSession autoload is missing.")
		return 1

	var load_result: Dictionary = ScenarioFixtureLoaderScript.load_pack_result(str(options.get("pack", "")))
	if not bool(load_result.get("ok", false)):
		printerr("[run_scenarios] %s" % str(load_result.get("message", "Could not load scenario pack.")))
		return 1
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	var scenarios: Array[Dictionary] = ScenarioFixtureLoaderScript.scenarios_for(
		pack,
		str(options.get("scenario", "")),
		PackedStringArray(options.get("tags", PackedStringArray()))
	)
	if scenarios.is_empty():
		printerr("[run_scenarios] No scenarios matched the requested filters.")
		return 1
	var run_result: Dictionary = ScenarioRunnerScript.run_scenarios(session, catalog, pack, scenarios, options)
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	var summary: Dictionary = Dictionary(run_result.get("summary", {}))
	for record: Dictionary in records:
		_print_record(record)
	var write_result: Dictionary = ScenarioReporterScript.write_outputs(str(options.get("out", "")), records, summary, options)
	if not bool(write_result.get("ok", false)):
		printerr("[run_scenarios] %s" % str(write_result.get("message", "Failed to write outputs.")))
		return 1
	print("[run_scenarios] wrote %s, %s, %s, %s, and %s" % [
		str(write_result.get("results_path", "")),
		str(write_result.get("csv_path", "")),
		str(write_result.get("summary_path", "")),
		str(write_result.get("markdown_path", "")),
		str(write_result.get("gate_path", ""))
	])
	print("[run_scenarios] summary pass=%d warn=%d fail=%d" % [
		int(summary.get("pass_count", 0)),
		int(summary.get("warn_count", 0)),
		int(summary.get("fail_count", 0))
	])
	if str(options.get("mode", "explore")) == "gate" and int(summary.get("fail_count", 0)) > 0:
		return 1
	return 0

func _parse_options(args: PackedStringArray) -> Dictionary:
	var pack_id: String = ScenarioFixtureLoaderScript.default_pack_id()
	var raw: Dictionary = {
		"pack": pack_id,
		"scenario": "",
		"tags": PackedStringArray(),
		"out": "",
		"mode": "explore",
		"stop_on_failure": false,
		"command": "run_scenarios %s" % " ".join(Array(args))
	}
	for arg: String in args:
		if arg.begins_with("--pack="):
			raw["pack"] = arg.trim_prefix("--pack=")
		elif arg.begins_with("--scenario="):
			raw["scenario"] = arg.trim_prefix("--scenario=")
		elif arg.begins_with("--tags="):
			raw["tags"] = _split_string_list(arg.trim_prefix("--tags="))
		elif arg.begins_with("--out="):
			raw["out"] = arg.trim_prefix("--out=")
		elif arg.begins_with("--mode="):
			raw["mode"] = arg.trim_prefix("--mode=")
		elif arg == "--gate":
			raw["mode"] = "gate"
		elif arg == "--stop-on-failure":
			raw["stop_on_failure"] = true
	if str(raw.get("out", "")) == "":
		raw["out"] = "user://scenario_lab/%s" % str(raw.get("pack", pack_id))
	return raw

func _split_string_list(value: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	for item: String in value.split(",", false):
		var trimmed: String = item.strip_edges()
		if trimmed != "":
			result.append(trimmed)
	return result

func _print_record(record: Dictionary) -> void:
	var scenario: Dictionary = Dictionary(record.get("scenario", {}))
	var result: Dictionary = Dictionary(record.get("result", {}))
	print("[run_scenarios] %s status=%s class=%s policy=%s seed=%d hp=%d deaths=%d deck=%d shop=%d" % [
		str(scenario.get("id", "")),
		str(record.get("status", "")),
		str(scenario.get("class_id", "")),
		str(scenario.get("policy_id", "")),
		int(scenario.get("seed", 0)),
		int(result.get("final_hp", 0)),
		int(result.get("deaths", 0)),
		int(result.get("deck_size", 0)),
		int(result.get("shop_usage", 0))
	])
