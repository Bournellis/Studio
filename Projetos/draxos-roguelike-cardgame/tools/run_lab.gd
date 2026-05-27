extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const RoutePacingSimulatorScript = preload("res://tools/route_pacing_simulator.gd")
const DEFAULT_CLASSES: PackedStringArray = ["arcano", "invocador", "necromante"]
const DEFAULT_SEEDS: PackedInt64Array = [20260518]
const DEFAULT_OUTPUT_DIR: String = "user://run_lab"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = _run_lab()
	quit(exit_code)

func _run_lab() -> int:
	var options: Dictionary = _parse_options()
	var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[run_lab] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1
	var content_library = root.get_node_or_null("ContentLibrary")
	if content_library == null:
		printerr("[run_lab] ContentLibrary autoload is missing.")
		return 1
	content_library.reload()
	var catalog = content_library.get_catalog()
	if catalog == null:
		printerr("[run_lab] Missing generated slice catalog.")
		return 1
	var session = root.get_node_or_null("RunSession")
	if session == null:
		printerr("[run_lab] RunSession autoload is missing.")
		return 1

	var results: Array[Dictionary] = []
	for class_id: String in Array(options.get("classes", DEFAULT_CLASSES)):
		for seed: int in Array(options.get("seeds", DEFAULT_SEEDS)):
			var result: Dictionary = _simulate_route(session, catalog, class_id, seed)
			results.append(result)
			print("[run_lab] %s seed=%d maps=%d/%d turns_est=%d hp=%d/%d deaths=%d deck=%d relics=%d shop=%d" % [
				class_id,
				seed,
				int(result.get("completed_maps", 0)),
				int(result.get("map_count", 0)),
				int(result.get("estimated_turns", 0)),
				int(result.get("final_hp", 0)),
				int(result.get("max_hp", 0)),
				int(result.get("deaths", 0)),
				int(result.get("deck_size", 0)),
				int(result.get("relic_count", 0)),
				int(result.get("shop_usage", 0))
			])
	var output_dir: String = str(options.get("out", DEFAULT_OUTPUT_DIR))
	var write_result: Dictionary = _write_outputs(output_dir, results)
	if not bool(write_result.get("ok", false)):
		printerr("[run_lab] %s" % str(write_result.get("message", "Failed to write outputs.")))
		return 1
	print("[run_lab] wrote %s and %s" % [str(write_result.get("json_path", "")), str(write_result.get("csv_path", ""))])
	return 0

func _parse_options() -> Dictionary:
	var options: Dictionary = {
		"classes": DEFAULT_CLASSES,
		"seeds": DEFAULT_SEEDS,
		"out": DEFAULT_OUTPUT_DIR
	}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--class="):
			options["classes"] = PackedStringArray([arg.trim_prefix("--class=")])
		elif arg.begins_with("--classes="):
			options["classes"] = PackedStringArray(arg.trim_prefix("--classes=").split(",", false))
		elif arg.begins_with("--seed="):
			options["seeds"] = PackedInt64Array([int(arg.trim_prefix("--seed="))])
		elif arg.begins_with("--seeds="):
			var seeds: PackedInt64Array = PackedInt64Array()
			for seed_text: String in arg.trim_prefix("--seeds=").split(",", false):
				seeds.append(int(seed_text))
			options["seeds"] = seeds
		elif arg.begins_with("--out="):
			options["out"] = arg.trim_prefix("--out=")
	return options

func _simulate_route(session, catalog, class_id: String, seed: int) -> Dictionary:
	return RoutePacingSimulatorScript.new().simulate_route(session, catalog, class_id, seed)

func _write_outputs(output_dir: String, results: Array[Dictionary]) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var json_path: String = "%s/run_lab_metrics.json" % output_dir
	var csv_path: String = "%s/run_lab_metrics.csv" % output_dir
	var json_file := FileAccess.open(json_path, FileAccess.WRITE)
	if json_file == null:
		return {"ok": false, "message": "Could not write %s." % json_path}
	json_file.store_string(JSON.stringify({"runs": results}, "\t"))
	var csv_file := FileAccess.open(csv_path, FileAccess.WRITE)
	if csv_file == null:
		return {"ok": false, "message": "Could not write %s." % csv_path}
	var headers: PackedStringArray = ["class_id", "seed", "ok", "completed_maps", "map_count", "estimated_turns", "hp_loss", "final_hp", "max_hp", "deck_size", "relic_count", "souls_earned", "souls_spent", "souls_left", "shop_usage", "deaths", "shop_actions", "message"]
	csv_file.store_line(",".join(headers))
	for result: Dictionary in results:
		var row: PackedStringArray = PackedStringArray()
		for header: String in headers:
			if header == "shop_actions":
				row.append(_csv_escape(";".join(Array(result.get(header, [])))))
			else:
				row.append(_csv_escape(str(result.get(header, ""))))
		csv_file.store_line(",".join(row))
	return {"ok": true, "json_path": json_path, "csv_path": csv_path}

func _csv_escape(value: String) -> String:
	if value.find(",") >= 0 or value.find("\"") >= 0 or value.find("\n") >= 0:
		return "\"%s\"" % value.replace("\"", "\"\"")
	return value
