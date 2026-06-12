class_name JogoDaCopaPerfProbe
extends RefCounted

const ENABLE_META_KEY: String = "jdc_perf_enabled"
const SCENARIO_META_KEY: String = "jdc_perf_scenario_enabled"
const START_USEC_META_KEY: String = "jdc_perf_start_usec"
const SESSION_LABEL_META_KEY: String = "jdc_perf_session_label"
const QUERY_ENABLE_KEY: String = "jdc_perf"
const QUERY_SCENARIO_KEY: String = "jdc_perf_scenario"
const QUERY_QUIT_AFTER_KEY: String = "jdc_perf_quit_after"
const QUERY_STABILITY_KEY: String = "jdc_perf_stability"
const QUERY_DETAIL_KEY: String = "jdc_perf_detail"
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

static func is_stability_enabled(context: Object) -> bool:
	if OS.has_feature("web") and _has_web_query(QUERY_STABILITY_KEY):
		return _has_truthy_web_query(QUERY_STABILITY_KEY)
	return true

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
	if not _should_emit_stage(stage):
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

static func log_material_counts(context: Object, scene_root: Node) -> void:
	if not is_enabled(context) or scene_root == null:
		return
	var stats_by_category := {}
	_collect_material_counts(scene_root, stats_by_category)
	var category_names := stats_by_category.keys()
	category_names.sort()
	var total_material_ids := {}
	var total_variant_keys := {}
	var total_meshes := 0
	var total_surfaces := 0
	var total_refs := 0
	var total_standard := 0
	var total_shader := 0
	for category_name in category_names:
		var stats: Dictionary = stats_by_category[category_name]
		var material_ids: Dictionary = stats["material_ids"]
		var variant_keys: Dictionary = stats["variant_keys"]
		total_meshes += int(stats["meshes"])
		total_surfaces += int(stats["surfaces"])
		total_refs += int(stats["refs"])
		total_standard += int(stats["standard"])
		total_shader += int(stats["shader"])
		for material_id in material_ids.keys():
			total_material_ids[material_id] = true
		for variant_key in variant_keys.keys():
			total_variant_keys[variant_key] = true
		mark(
			context,
			"material_counts.category",
			"category=%s meshes=%d surfaces=%d material_refs=%d unique_materials=%d standard_refs=%d shader_refs=%d variants=%d" % [
				str(category_name),
				int(stats["meshes"]),
				int(stats["surfaces"]),
				int(stats["refs"]),
				material_ids.size(),
				int(stats["standard"]),
				int(stats["shader"]),
				variant_keys.size(),
			]
		)
	mark(
		context,
		"material_counts.summary",
		"categories=%d meshes=%d surfaces=%d material_refs=%d unique_materials=%d standard_refs=%d shader_refs=%d variants=%d" % [
			category_names.size(),
			total_meshes,
			total_surfaces,
			total_refs,
			total_material_ids.size(),
			total_standard,
			total_shader,
			total_variant_keys.size(),
		]
	)

static func log_stability_sample(context: Object, scene_root: Node, extra_counts: Dictionary = {}) -> void:
	if not is_enabled(context) or scene_root == null:
		return
	var counts := _collect_stability_counts(scene_root)
	for key in extra_counts.keys():
		counts[str(key)] = extra_counts[key]
	var keys := counts.keys()
	keys.sort()
	var parts: Array[String] = []
	for key in keys:
		parts.append("%s=%s" % [str(key), _format_sample_value(counts[key])])
	mark(context, "stability.sample", " ".join(parts))

static func _collect_stability_counts(scene_root: Node) -> Dictionary:
	var scene_counts := {
		"live_particle_nodes": 0,
		"live_emitting_particles": 0,
		"live_transient_nodes": 0,
		"live_feedback_nodes": 0,
	}
	_collect_scene_stability_counts(scene_root, scene_counts)
	return {
		"elapsed_s": get_elapsed_seconds(scene_root),
		"fps": Performance.get_monitor(Performance.TIME_FPS),
		"memory_static": Performance.get_monitor(Performance.MEMORY_STATIC),
		"object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
		"object_resource_count": Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"object_node_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"object_orphan_node_count": Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		"render_total_objects": Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		"render_video_mem_used": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED),
		"render_texture_mem_used": Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),
		"live_particle_nodes": scene_counts["live_particle_nodes"],
		"live_emitting_particles": scene_counts["live_emitting_particles"],
		"live_transient_nodes": scene_counts["live_transient_nodes"],
		"live_feedback_nodes": scene_counts["live_feedback_nodes"],
	}

static func _collect_scene_stability_counts(node: Node, counts: Dictionary) -> void:
	if node is GPUParticles3D or node is CPUParticles3D:
		counts["live_particle_nodes"] = int(counts["live_particle_nodes"]) + 1
		if bool(node.get("emitting")):
			counts["live_emitting_particles"] = int(counts["live_emitting_particles"]) + 1
	if _is_transient_probe_node(node):
		counts["live_transient_nodes"] = int(counts["live_transient_nodes"]) + 1
	if str(node.name).begins_with("Feedback"):
		counts["live_feedback_nodes"] = int(counts["live_feedback_nodes"]) + 1
	for child in node.get_children():
		_collect_scene_stability_counts(child, counts)

static func _is_transient_probe_node(node: Node) -> bool:
	var node_name := str(node.name).to_lower()
	return (
		node_name.begins_with("feedback")
		or node_name.contains("burst")
		or node_name.contains("trail")
		or node_name.contains("confetti")
		or node_name.contains("tone")
		or node_name.contains("particles")
	)

static func _format_sample_value(value: Variant) -> String:
	if value is bool:
		return "1" if bool(value) else "0"
	if value is float:
		return "%.3f" % float(value)
	return str(value).replace(" ", "_")

static func _should_emit_stage(stage: String) -> bool:
	if _is_detail_enabled():
		return true
	return (
		stage == "session.enabled"
		or stage.begins_with("event.")
		or stage.begins_with("perf_scenario.")
		or stage.begins_with("stability.")
		or stage.begins_with("loading.")
		or stage.begins_with("web_warmup.")
		or stage.begins_with("football.ready")
		or stage.begins_with("football.restart_play")
	)

static func _is_detail_enabled() -> bool:
	if OS.has_feature("web") and _has_web_query(QUERY_DETAIL_KEY):
		return _has_truthy_web_query(QUERY_DETAIL_KEY)
	return true

static func _collect_material_counts(node: Node, stats_by_category: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var stats := _get_material_count_stats(stats_by_category, _classify_material_node(mesh_instance))
		stats["meshes"] = int(stats["meshes"]) + 1
		var materials := _get_effective_mesh_materials(mesh_instance)
		stats["surfaces"] = int(stats["surfaces"]) + materials.size()
		for material in materials:
			_record_material(stats, material)
	elif node is MultiMeshInstance3D:
		var multimesh_instance := node as MultiMeshInstance3D
		var stats := _get_material_count_stats(stats_by_category, _classify_material_node(multimesh_instance))
		stats["meshes"] = int(stats["meshes"]) + 1
		var materials := _get_effective_multimesh_materials(multimesh_instance)
		stats["surfaces"] = int(stats["surfaces"]) + materials.size()
		for material in materials:
			_record_material(stats, material)
	for child in node.get_children():
		_collect_material_counts(child, stats_by_category)

static func _get_effective_mesh_materials(mesh_instance: MeshInstance3D) -> Array[Material]:
	var materials: Array[Material] = []
	if mesh_instance.material_override != null:
		materials.append(mesh_instance.material_override)
		return materials
	if mesh_instance.mesh == null:
		return materials
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var material := mesh_instance.get_surface_override_material(surface_index)
		if material == null:
			material = mesh_instance.mesh.surface_get_material(surface_index)
		if material != null:
			materials.append(material)
	return materials

static func _get_effective_multimesh_materials(multimesh_instance: MultiMeshInstance3D) -> Array[Material]:
	var materials: Array[Material] = []
	if multimesh_instance.material_override != null:
		materials.append(multimesh_instance.material_override)
		return materials
	if multimesh_instance.multimesh == null or multimesh_instance.multimesh.mesh == null:
		return materials
	var mesh := multimesh_instance.multimesh.mesh
	for surface_index in range(mesh.get_surface_count()):
		var material := mesh.surface_get_material(surface_index)
		if material != null:
			materials.append(material)
	return materials

static func _record_material(stats: Dictionary, material: Material) -> void:
	stats["refs"] = int(stats["refs"]) + 1
	(stats["material_ids"] as Dictionary)[material.get_instance_id()] = true
	(stats["variant_keys"] as Dictionary)[_get_material_variant_key(material)] = true
	if material is ShaderMaterial:
		stats["shader"] = int(stats["shader"]) + 1
	elif material is StandardMaterial3D:
		stats["standard"] = int(stats["standard"]) + 1

static func _get_material_count_stats(stats_by_category: Dictionary, category: String) -> Dictionary:
	if not stats_by_category.has(category):
		stats_by_category[category] = {
			"meshes": 0,
			"surfaces": 0,
			"refs": 0,
			"standard": 0,
			"shader": 0,
			"material_ids": {},
			"variant_keys": {},
		}
	return stats_by_category[category]

static func _classify_material_node(geometry_instance: GeometryInstance3D) -> String:
	if geometry_instance.has_meta("material_probe_category"):
		return str(geometry_instance.get_meta("material_probe_category"))
	var node_name := geometry_instance.name.to_lower()
	var path_text := str(geometry_instance.get_path()).to_lower()
	if path_text.contains("playeravatar") or path_text.contains("botavatar"):
		return "avatares"
	if path_text.contains("feedback") or node_name.contains("trail") or node_name.contains("burst") or node_name.contains("fireball") or node_name.contains("boostpad") or node_name.contains("jumppad"):
		return "vfx"
	if geometry_instance.is_in_group("football_crowd") or node_name.contains("crowd"):
		return "torcida"
	if node_name.contains("stand") or node_name.contains("corridor") or node_name.contains("skyline"):
		return "estandes"
	if node_name.contains("banner") or node_name.contains("flag") or node_name.contains("mast"):
		return "banners"
	if node_name.contains("glass") or node_name.contains("net"):
		return "vidro"
	if node_name.contains("scoreboard") or path_text.contains("scoreboard"):
		return "placares"
	if node_name.contains("frame") or node_name.contains("post") or node_name.contains("rail") or node_name.contains("rib") or node_name.contains("bar") or node_name.contains("halo") or node_name.contains("marker"):
		return "neon"
	if node_name.contains("pitch") or node_name.contains("line") or node_name.contains("stripe") or node_name.contains("spot") or node_name.contains("mouth"):
		return "campo"
	if node_name.contains("ball"):
		return "bola"
	return "outros"

static func _get_material_variant_key(material: Material) -> String:
	if material is ShaderMaterial:
		var shader_material := material as ShaderMaterial
		var shader := shader_material.shader
		var shader_hash := "none"
		var uniform_names: Array[String] = []
		if shader != null:
			shader_hash = str(hash(shader.code))
			for uniform_data in shader.get_shader_uniform_list():
				uniform_names.append(str(uniform_data.get("name", "")))
			uniform_names.sort()
		return "ShaderMaterial|shader=%s|uniforms=%s" % [shader_hash, ",".join(uniform_names)]
	if material is StandardMaterial3D:
		var standard := material as StandardMaterial3D
		return "StandardMaterial3D|shade=%d|trans=%d|depth=%d|cull=%d|emission=%s|rim=%s|clearcoat=%s|metallic=%.2f|rough=%.2f|albedo_tex=%s|emission_tex=%s|normal_tex=%s" % [
			int(standard.shading_mode),
			int(standard.transparency),
			int(standard.depth_draw_mode),
			int(standard.cull_mode),
			str(standard.emission_enabled),
			str(standard.rim_enabled),
			str(standard.clearcoat_enabled),
			standard.metallic,
			standard.roughness,
			str(standard.albedo_texture != null),
			str(standard.emission_texture != null),
			str(standard.normal_texture != null),
		]
	return material.get_class()

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

static func _has_web_query(key: String) -> bool:
	if not OS.has_feature("web"):
		return false
	var query_string := str(JavaScriptBridge.eval("window.location.search", true))
	if query_string.is_empty() or query_string == "null":
		return false
	if query_string.begins_with("?"):
		query_string = query_string.substr(1)
	for query_pair in query_string.split("&", false):
		var query_key := query_pair.get_slice("=", 0).uri_decode()
		if query_key == key:
			return true
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
