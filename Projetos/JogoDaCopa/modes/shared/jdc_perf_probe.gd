class_name JogoDaCopaPerfProbe
extends RefCounted

const ENABLE_META_KEY: String = "jdc_perf_enabled"
const SCENARIO_META_KEY: String = "jdc_perf_scenario_enabled"
const START_USEC_META_KEY: String = "jdc_perf_start_usec"
const SESSION_LABEL_META_KEY: String = "jdc_perf_session_label"
const QUERY_ENABLE_KEY: String = "jdc_perf"
const QUERY_SCENARIO_KEY: String = "jdc_perf_scenario"
const QUERY_QUIT_AFTER_KEY: String = "jdc_perf_quit_after"
const PREFIX: String = "[JDC_PERF]"

static func ensure_enabled(context: Object, label: String = "runtime") -> bool:
	var root := _get_root(context)
	if root == null:
		return false
	var enabled := _is_truthy_meta(root, ENABLE_META_KEY)
	if not enabled and (_has_enable_arg() or _has_truthy_web_query(QUERY_ENABLE_KEY)):
		enable(root, label)
		enabled = true
	if enabled and (_has_scenario_arg() or _has_truthy_web_query(QUERY_SCENARIO_KEY)):
		root.set_meta(SCENARIO_META_KEY, true)
	return enabled

static func enable(context: Object, label: String = "runtime") -> void:
	var root := _get_root(context)
	if root == null:
		return
	if not root.has_meta(START_USEC_META_KEY):
		root.set_meta(START_USEC_META_KEY, Time.get_ticks_usec())
	root.set_meta(ENABLE_META_KEY, true)
	root.set_meta(SESSION_LABEL_META_KEY, label)
	mark(root, "session.enabled", "label=%s display=%s web=%s" % [label, DisplayServer.get_name(), str(OS.has_feature("web"))])

static func is_enabled(context: Object) -> bool:
	var root := _get_root(context)
	if root == null:
		return false
	if _is_truthy_meta(root, ENABLE_META_KEY):
		return true
	return ensure_enabled(root)

static func is_scenario_enabled(context: Object) -> bool:
	var root := _get_root(context)
	if root == null:
		return false
	ensure_enabled(root)
	return _is_truthy_meta(root, SCENARIO_META_KEY)

static func get_elapsed_seconds(context: Object) -> float:
	var root := _get_root(context)
	if root == null or not root.has_meta(START_USEC_META_KEY):
		return 0.0
	return float(Time.get_ticks_usec() - int(root.get_meta(START_USEC_META_KEY))) / 1000000.0

static func get_quit_after_seconds(context: Object) -> float:
	var from_args := _get_float_arg(["--jdc_perf_quit_after", "--jdc-perf-quit-after"], -1.0)
	if from_args > 0.0:
		return from_args
	if OS.has_feature("web"):
		return _get_float_web_query(QUERY_QUIT_AFTER_KEY, -1.0)
	return -1.0

static func mark(context: Object, stage: String, detail: String = "") -> void:
	var root := _get_root(context)
	if root == null:
		return
	if not _is_truthy_meta(root, ENABLE_META_KEY):
		return
	var now_usec := Time.get_ticks_usec()
	var start_usec := int(root.get_meta(START_USEC_META_KEY, now_usec))
	var delta_ms := float(now_usec - start_usec) / 1000.0
	var absolute_ms := float(now_usec) / 1000.0
	var clean_detail := detail.replace("\n", " ").replace("\r", " ")
	print("%s abs_ms=%.3f dt_ms=%.3f stage=%s detail=%s" % [PREFIX, absolute_ms, delta_ms, stage, clean_detail])

static func begin(context: Object, stage: String, detail: String = "") -> int:
	var now_usec := Time.get_ticks_usec()
	mark(context, "%s.begin" % stage, detail)
	return now_usec

static func end(context: Object, stage: String, begin_usec: int, detail: String = "") -> void:
	if not is_enabled(context):
		return
	var duration_ms := float(Time.get_ticks_usec() - begin_usec) / 1000.0
	var suffix := "duration_ms=%.3f" % duration_ms
	if not detail.is_empty():
		suffix += " %s" % detail
	mark(context, "%s.end" % stage, suffix)

static func _get_root(context: Object) -> Node:
	if context == null:
		return null
	if context is SceneTree:
		return (context as SceneTree).root
	if context is Node:
		var tree := (context as Node).get_tree()
		if tree != null and tree.root != null:
			return tree.root
		return context as Node
	return null

static func _is_truthy_meta(root: Node, key: String) -> bool:
	if root == null or not root.has_meta(key):
		return false
	var value: Variant = root.get_meta(key)
	if value is bool:
		return bool(value)
	var text := str(value).strip_edges().to_lower()
	return text == "1" or text == "true" or text == "yes" or text == "on"

static func _has_enable_arg() -> bool:
	for arg in _collect_args():
		var normalized := arg.strip_edges().to_lower()
		if normalized == "--jdc_perf" or normalized == "--jdc-perf":
			return true
		if normalized.begins_with("--jdc_perf=") or normalized.begins_with("--jdc-perf="):
			return _is_truthy_text(normalized.get_slice("=", 1))
	return false

static func _has_scenario_arg() -> bool:
	for arg in _collect_args():
		var normalized := arg.strip_edges().to_lower()
		if normalized == "--jdc_perf_scenario" or normalized == "--jdc-perf-scenario":
			return true
		if normalized.begins_with("--jdc_perf_scenario=") or normalized.begins_with("--jdc-perf-scenario="):
			return _is_truthy_text(normalized.get_slice("=", 1))
	return false

static func _collect_args() -> Array[String]:
	var args: Array[String] = []
	for arg in OS.get_cmdline_args():
		args.append(str(arg))
	for arg in OS.get_cmdline_user_args():
		args.append(str(arg))
	return args

static func _get_float_arg(names: Array[String], fallback: float) -> float:
	for arg in _collect_args():
		var normalized := arg.strip_edges()
		var lowered := normalized.to_lower()
		for name in names:
			var lowered_name := name.to_lower()
			if lowered.begins_with("%s=" % lowered_name):
				return normalized.get_slice("=", 1).to_float()
	return fallback

static func _has_truthy_web_query(key: String) -> bool:
	if not OS.has_feature("web"):
		return false
	var query_string := str(JavaScriptBridge.eval("window.location.search", true))
	if query_string.is_empty() or query_string == "null":
		return false
	if query_string.begins_with("?"):
		query_string = query_string.substr(1)
	for query_pair in query_string.split("&", false):
		var query_key := query_pair.get_slice("=", 0).uri_decode()
		if query_key != key:
			continue
		var value := query_pair.get_slice("=", 1).uri_decode()
		return value.is_empty() or _is_truthy_text(value)
	return false

static func _get_float_web_query(key: String, fallback: float) -> float:
	if not OS.has_feature("web"):
		return fallback
	var query_string := str(JavaScriptBridge.eval("window.location.search", true))
	if query_string.is_empty() or query_string == "null":
		return fallback
	if query_string.begins_with("?"):
		query_string = query_string.substr(1)
	for query_pair in query_string.split("&", false):
		var query_key := query_pair.get_slice("=", 0).uri_decode()
		if query_key == key:
			return query_pair.get_slice("=", 1).uri_decode().to_float()
	return fallback

static func _is_truthy_text(text: String) -> bool:
	var normalized := text.strip_edges().to_lower()
	return normalized == "1" or normalized == "true" or normalized == "yes" or normalized == "on"
