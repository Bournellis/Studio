extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleFixtureLoaderScript = preload("res://tools/lab/battle_fixture_loader.gd")
const BattleReporterScript = preload("res://tools/lab/battle_reporter.gd")
const BattleRunnerScript = preload("res://tools/lab/battle_runner.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = _run_battle_lab()
	quit(exit_code)

func _run_battle_lab() -> int:
	var user_args: PackedStringArray = OS.get_cmdline_user_args()
	var options: Dictionary = _parse_options(user_args)
	print("[run_battle_lab] pack=%s case=%s tags=%s policy=%s mode=%s" % [
		str(options.get("pack", "")),
		str(options.get("case_id", "")),
		",".join(PackedStringArray(options.get("tags", PackedStringArray()))),
		str(options.get("policy", "")),
		str(options.get("mode", "explore"))
	])
	var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[run_battle_lab] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1
	var content_library = root.get_node_or_null("ContentLibrary")
	if content_library == null:
		printerr("[run_battle_lab] ContentLibrary autoload is missing.")
		return 1
	content_library.reload()
	var catalog = content_library.get_catalog()
	if catalog == null:
		printerr("[run_battle_lab] Missing generated slice catalog.")
		return 1

	var load_result: Dictionary = BattleFixtureLoaderScript.load_pack_result(str(options.get("pack", "")))
	if not bool(load_result.get("ok", false)):
		printerr("[run_battle_lab] %s" % str(load_result.get("message", "Could not load battle pack.")))
		return 1
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	var cases: Array[Dictionary] = BattleFixtureLoaderScript.cases_for(
		pack,
		str(options.get("case_id", "")),
		PackedStringArray(options.get("tags", PackedStringArray()))
	)
	if cases.is_empty():
		printerr("[run_battle_lab] No cases matched the requested filters.")
		return 1
	var run_result: Dictionary = BattleRunnerScript.run_cases(catalog, pack, cases, options)
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	var summary: Dictionary = Dictionary(run_result.get("summary", {}))
	for record: Dictionary in records:
		_print_record(record)
	var write_result: Dictionary = BattleReporterScript.write_outputs(str(options.get("out", "")), records, summary, options)
	if not bool(write_result.get("ok", false)):
		printerr("[run_battle_lab] %s" % str(write_result.get("message", "Failed to write outputs.")))
		return 1
	print("[run_battle_lab] wrote %s, %s, %s, %s, and %s" % [
		str(write_result.get("results_path", "")),
		str(write_result.get("csv_path", "")),
		str(write_result.get("summary_path", "")),
		str(write_result.get("markdown_path", "")),
		str(write_result.get("gate_path", ""))
	])
	print("[run_battle_lab] summary pass=%d warn=%d fail=%d" % [
		int(summary.get("pass_count", 0)),
		int(summary.get("warn_count", 0)),
		int(summary.get("fail_count", 0))
	])
	if str(options.get("mode", "explore")) == "gate" and int(summary.get("fail_count", 0)) > 0:
		return 1
	return 0

func _parse_options(args: PackedStringArray) -> Dictionary:
	var pack_id: String = BattleFixtureLoaderScript.default_pack_id()
	var raw: Dictionary = {
		"pack": pack_id,
		"case_id": "",
		"tags": PackedStringArray(),
		"policy": "",
		"out": "",
		"mode": "explore",
		"stop_on_failure": false,
		"max_actions_per_turn": 24,
		"command": "run_battle_lab %s" % " ".join(Array(args))
	}
	for arg: String in args:
		if arg.begins_with("--pack="):
			raw["pack"] = arg.trim_prefix("--pack=")
		elif arg.begins_with("--case="):
			raw["case_id"] = arg.trim_prefix("--case=")
		elif arg.begins_with("--tags="):
			raw["tags"] = _split_string_list(arg.trim_prefix("--tags="))
		elif arg.begins_with("--policy="):
			raw["policy"] = arg.trim_prefix("--policy=")
		elif arg.begins_with("--out="):
			raw["out"] = arg.trim_prefix("--out=")
		elif arg.begins_with("--mode="):
			raw["mode"] = arg.trim_prefix("--mode=")
		elif arg == "--gate":
			raw["mode"] = "gate"
		elif arg == "--stop-on-failure":
			raw["stop_on_failure"] = true
		elif arg.begins_with("--max-actions-per-turn="):
			raw["max_actions_per_turn"] = int(arg.trim_prefix("--max-actions-per-turn="))
	if str(raw.get("out", "")) == "":
		raw["out"] = "user://battle_lab/%s" % str(raw.get("pack", pack_id))
	return raw

func _split_string_list(value: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	for item: String in value.split(",", false):
		var trimmed: String = item.strip_edges()
		if trimmed != "":
			result.append(trimmed)
	return result

func _print_record(record: Dictionary) -> void:
	var case_data: Dictionary = Dictionary(record.get("case", {}))
	var result: Dictionary = Dictionary(record.get("result", {}))
	print("[run_battle_lab] %s status=%s class=%s encounter=%s policy=%s seed=%d outcome=%s turns=%d hp=%d enemy_hp=%d cards=%d" % [
		str(case_data.get("id", "")),
		str(record.get("status", "")),
		str(case_data.get("class_id", "")),
		str(case_data.get("encounter_id", "")),
		str(result.get("policy_id", case_data.get("policy_id", ""))),
		int(case_data.get("seed", 0)),
		str(result.get("outcome", "")),
		int(result.get("turn_count", 0)),
		int(result.get("player_hp", 0)),
		int(result.get("enemy_hp", 0)),
		int(result.get("cards_played", 0))
	])
