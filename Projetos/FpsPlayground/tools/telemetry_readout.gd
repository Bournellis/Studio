extends SceneTree

const TelemetryReadoutAnalyzerScript = preload("res://gameplay/telemetry/telemetry_readout_analyzer.gd")

var _session_path: String = ""
var _root_path: String = TelemetryReadoutAnalyzer.DEFAULT_TELEMETRY_ROOT
var _use_latest: bool = false
var _json_output: bool = false
var _help_requested: bool = false

func _initialize() -> void:
	_parse_command_line()
	call_deferred("_run")

func _run() -> void:
	var exit_code := _run_readout()
	quit(exit_code)

func _run_readout() -> int:
	if _help_requested:
		_print_help()
		return 0

	var analyzer = TelemetryReadoutAnalyzerScript.new()
	var readout: Dictionary
	if _use_latest or _session_path.is_empty():
		readout = analyzer.analyze_latest(_root_path)
	else:
		readout = analyzer.analyze_session(_session_path)

	if _json_output:
		print(JSON.stringify(readout, "\t"))
	else:
		print(analyzer.build_text_report(readout))
	return 0 if bool(readout.get("ok", false)) else 1

func _parse_command_line() -> void:
	for arg: String in _collect_command_line_args():
		if arg == "--help" or arg == "-h":
			_help_requested = true
		elif arg == "--latest":
			_use_latest = true
		elif arg == "--json":
			_json_output = true
		elif arg.begins_with("--session="):
			_session_path = arg.get_slice("=", 1).strip_edges()
		elif arg.begins_with("--root="):
			_root_path = arg.get_slice("=", 1).strip_edges()

func _collect_command_line_args() -> Array[String]:
	var args: Array[String] = []
	for arg: String in OS.get_cmdline_args():
		args.append(arg)
	for arg: String in OS.get_cmdline_user_args():
		args.append(arg)
	return args

func _print_help() -> void:
	print("FpsPlayground telemetry readout")
	print("")
	print("Usage:")
	print("  godot --headless --path <project> -s res://tools/telemetry_readout.gd -- --latest")
	print("  godot --headless --path <project> -s res://tools/telemetry_readout.gd -- --session=\"<session_path>\"")
	print("")
	print("Options:")
	print("  --latest          Read latest session under user://telemetry.")
	print("  --root=<path>     Override telemetry root for --latest.")
	print("  --session=<path>  Read one telemetry session directory.")
	print("  --json            Print full JSON readout.")
