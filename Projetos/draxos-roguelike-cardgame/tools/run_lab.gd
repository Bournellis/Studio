extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const LabAggregatorScript = preload("res://tools/lab/lab_aggregator.gd")
const LabBaselineStoreScript = preload("res://tools/lab/lab_baseline_store.gd")
const LabCaseBuilderScript = preload("res://tools/lab/lab_case_builder.gd")
const LabReporterScript = preload("res://tools/lab/lab_reporter.gd")
const LabRunnerScript = preload("res://tools/lab/lab_runner.gd")
const RunLabGoldenMetricsScript = preload("res://tools/run_lab_golden_metrics.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = _run_lab()
	quit(exit_code)

func _run_lab() -> int:
	var options: Dictionary = LabCaseBuilderScript.parse_options(OS.get_cmdline_user_args())
	print("[run_lab] %s" % LabCaseBuilderScript.describe_options(options))
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

	var cases: Array[Dictionary] = LabCaseBuilderScript.build_cases(options)
	var run_result: Dictionary = LabRunnerScript.run_cases(session, catalog, cases, options)
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	var metrics: Array[Dictionary] = LabRunnerScript.metrics_for_records(records)
	for result: Dictionary in metrics:
		_print_run_metrics(result)

	var comparison: Dictionary = {}
	if bool(options.get("compare_golden", false)):
		comparison = RunLabGoldenMetricsScript.compare_many(metrics, {
			"require_known": bool(options.get("require_golden", false)),
			"strict": bool(options.get("strict_golden", false))
		})
	var summary: Dictionary = LabAggregatorScript.aggregate(records, options)
	var baseline_comparison: Dictionary = {}
	if bool(options.get("compare_baseline", false)) or str(options.get("mode", "")) == "compare":
		var baseline: Dictionary = LabBaselineStoreScript.load_baseline(str(options.get("baseline_path", "")))
		baseline_comparison = LabBaselineStoreScript.compare_summary(summary, baseline)
	var output_dir: String = str(options.get("out", LabCaseBuilderScript.DEFAULT_OUTPUT_DIR))
	var write_result: Dictionary = LabReporterScript.write_outputs(output_dir, records, summary, comparison, baseline_comparison)
	if not bool(write_result.get("ok", false)):
		printerr("[run_lab] %s" % str(write_result.get("message", "Failed to write outputs.")))
		return 1
	print("[run_lab] wrote %s, %s, %s, and %s" % [
		str(write_result.get("json_path", "")),
		str(write_result.get("csv_path", "")),
		str(write_result.get("summary_path", "")),
		str(write_result.get("markdown_path", ""))
	])
	if bool(options.get("save_baseline", false)) or str(options.get("mode", "")) == "baseline":
		var baseline_path: String = str(options.get("baseline_path", ""))
		if baseline_path == "":
			baseline_path = "%s/run_lab_baseline.json" % output_dir
		var baseline_result: Dictionary = LabBaselineStoreScript.save_baseline(baseline_path, summary)
		if not bool(baseline_result.get("ok", false)):
			printerr("[run_lab] %s" % str(baseline_result.get("message", "Failed to save baseline.")))
			return 1
		print("[run_lab] saved baseline %s" % str(baseline_result.get("path", "")))
	if not comparison.is_empty():
		_print_golden_comparison(comparison)
		if not bool(comparison.get("ok", false)):
			return 1
	if not baseline_comparison.is_empty():
		var baseline_message: String = LabBaselineStoreScript.format_comparison(baseline_comparison)
		if bool(baseline_comparison.get("ok", false)):
			print("[run_lab] %s" % baseline_message)
		else:
			printerr("[run_lab] %s" % baseline_message)
			return 1
	if str(options.get("mode", "")) == "validate" and not bool(run_result.get("ok", false)):
		return 1
	return 0

func _print_run_metrics(result: Dictionary) -> void:
	print("[run_lab] %s %s seed=%d maps=%d/%d turns_est=%d hp=%d/%d deaths=%d deck=%d relics=%d shop=%d" % [
		str(result.get("class_id", "")),
		str(result.get("policy_id", "baseline")),
		int(result.get("seed", 0)),
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

func _print_golden_comparison(comparison: Dictionary) -> void:
	for result: Dictionary in Array(comparison.get("results", [])):
		var message: String = RunLabGoldenMetricsScript.format_comparison(result)
		if bool(result.get("ok", false)):
			print("[run_lab] %s" % message)
		else:
			printerr("[run_lab] %s" % message)
	print("[run_lab] golden summary checked=%d mismatches=%d" % [
		int(comparison.get("checked_count", 0)),
		int(comparison.get("mismatch_count", 0))
	])
