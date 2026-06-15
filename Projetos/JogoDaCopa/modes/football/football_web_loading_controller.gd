class_name FootballWebLoadingController
extends RefCounted

const RENDER_WARMUP_ENABLED: bool = true
const RENDER_WARMUP_CHUNK_SIZE: int = 1024
const RENDER_WARMUP_DEFER_DECORATIVE: bool = false
const RENDER_WARMUP_CORE_GLASS_NODES: int = 2
const LOADING_SETTLE_REQUIRED_FRAMES: int = 5
const LOADING_SETTLE_MAX_FRAMES: int = 120
const LOADING_SETTLE_FRAME_MS: float = 33.0
const FIRST_USE_WARMUP_FRAMES: int = 1
const REAL_JUMP_PAD_WARMUP_FRAMES: int = 120
const FIRST_USE_DECAY_SECONDS: float = 0.8

static func build_overlay(root: Node, mode_name: String) -> void:
	root.web_loading_overlay = CanvasLayer.new()
	root.web_loading_overlay.name = "WebLoadingOverlay"
	root.web_loading_overlay.layer = 128
	root.add_child(root.web_loading_overlay)
	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 1.0)
	root.web_loading_overlay.add_child(shade)
	var panel := VBoxContainer.new()
	panel.name = "LoadingPanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -260.0
	panel.offset_top = -54.0
	panel.offset_right = 260.0
	panel.offset_bottom = 54.0
	panel.add_theme_constant_override("separation", 16)
	root.web_loading_overlay.add_child(panel)
	root.web_loading_label = Label.new()
	root.web_loading_label.name = "LoadingLabel"
	root.web_loading_label.text = mode_name
	root.web_loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.web_loading_label.add_theme_font_size_override("font_size", 24)
	panel.add_child(root.web_loading_label)
	root.web_loading_bar = ProgressBar.new()
	root.web_loading_bar.name = "LoadingProgress"
	root.web_loading_bar.min_value = 0.0
	root.web_loading_bar.max_value = 1.0
	root.web_loading_bar.value = 0.0
	root.web_loading_bar.custom_minimum_size = Vector2(520.0, 18.0)
	panel.add_child(root.web_loading_bar)

static func set_progress(root: Node, perf_probe_script: Object, mode_name: String, label_text: String, progress_value: float) -> void:
	perf_probe_script.mark(root, "loading.progress", "label=%s value=%.2f" % [label_text, progress_value])
	if root.web_loading_label != null:
		root.web_loading_label.text = mode_name
	if root.web_loading_bar != null:
		root.web_loading_bar.value = clampf(progress_value, 0.0, 1.0)

static func hide_overlay(root: Node, perf_probe_script: Object) -> void:
	root.web_loading_active = false
	perf_probe_script.mark(root, "loading.overlay_hidden")
	perf_probe_script.mark(root, "event.visible_match_start")
	if root.web_loading_overlay == null:
		return
	root.web_loading_overlay.queue_free()
	root.web_loading_overlay = null
	root.web_loading_label = null
	root.web_loading_bar = null

static func release_gameplay_under_overlay(root: Node, perf_probe_script: Object) -> void:
	root.web_loading_active = false
	perf_probe_script.mark(root, "loading.gameplay_released")

static func warmup_first_render(root: Node, render_profile_script: Object, perf_probe_script: Object, field_builder_script: Object, mode_name: String) -> void:
	if not render_profile_script.is_web_platform():
		return
	var warmup_begin: int = perf_probe_script.begin(root, "web_warmup.first_render")
	var buckets: Dictionary = collect_warmup_buckets(root, false)
	var total_nodes := 0
	for category in buckets.keys():
		total_nodes += (buckets[category] as Array).size()
	if total_nodes <= 0:
		perf_probe_script.end(root, "web_warmup.first_render", warmup_begin, "nodes=0")
		return
	perf_probe_script.mark(root, "web_warmup.visible", "nodes=%d categories=%d" % [total_nodes, buckets.size()])
	set_progress(root, perf_probe_script, mode_name, "Aquecendo render: arena completa", 0.88)
	await wait_until_settled(root, perf_probe_script, field_builder_script)
	perf_probe_script.mark(root, "web_warmup.core.end", "shown=%d/%d" % [total_nodes, total_nodes])
	perf_probe_script.end(root, "web_warmup.first_render", warmup_begin, "nodes=%d" % total_nodes)

static func warmup_first_use_feedback(root: Node, render_profile_script: Object, perf_probe_script: Object) -> void:
	if not render_profile_script.is_web_platform():
		return
	var warmup_begin: int = perf_probe_script.begin(root, "web_warmup.first_use_feedback")
	var previous_audio_volumes: Dictionary = set_warmup_audio_volume(-80.0)
	var warmup_position := Vector3(0.0, 0.72, 1.25)
	var warmup_direction := Vector3(0.0, 0.0, -1.0)
	if root.ball != null:
		root.debug_force_ball_position(warmup_position)
	await wait_first_use_frames(root, perf_probe_script, "position")
	if root.player != null and root.ball != null:
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "gameplay_strong_kick")
		root.debug_finish_kickoff_countdown()
		root.debug_force_ball_position(root.player.global_position + (-root.player.global_transform.basis.z * 1.2) + Vector3.UP * 0.55)
		root._try_player_kick(root._get_player_kick_origin(), root._get_player_kick_direction(), root.PLAYER_KICK_FORCE, root.PLAYER_KICK_LIFT, true)
		await wait_first_use_frames(root, perf_probe_script, "gameplay_strong_kick", FIRST_USE_WARMUP_FRAMES + 2)
		root.debug_force_ball_position(warmup_position)
	if root.feedback != null:
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "whistle_countdown")
		root.feedback.play_countdown_tick(false)
		root.feedback.play_countdown_tick(true)
		root.feedback.play_referee_whistle(warmup_position)
		await wait_first_use_frames(root, perf_probe_script, "whistle_countdown", FIRST_USE_WARMUP_FRAMES + 2)
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "kick")
		root.feedback.play_football_kick(warmup_position, warmup_direction, true)
		root.feedback.play_ball_bounce(warmup_position, true)
		root.feedback.play_ball_glass(warmup_position)
		await wait_first_use_frames(root, perf_probe_script, "kick", FIRST_USE_WARMUP_FRAMES + 2)
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "goal_player")
		root.feedback.play_football_goal(warmup_position + Vector3(0.0, 0.0, 3.5), true)
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "goal_bot")
		root.feedback.play_football_goal(warmup_position + Vector3(0.0, 0.0, -3.5), false)
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "confetti_player")
		root.feedback.play_arcade_confetti(warmup_position + Vector3(0.0, 0.0, 1.75), true)
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "confetti_bot")
		root.feedback.play_arcade_confetti(warmup_position + Vector3(0.0, 0.0, -1.75), false)
		root.feedback.play_jump_pad(warmup_position + Vector3(2.5, 0.0, 0.0), root.JUMP_PAD_LAUNCH_VELOCITY)
		await wait_first_use_frames(root, perf_probe_script, "goal_confetti_batch", FIRST_USE_WARMUP_FRAMES + 2)
		if root.player != null and not root.jump_pad_areas.is_empty():
			perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "actual_jump_pad")
			root.player.global_position = root.jump_pad_areas[0].global_position
			if root.chase_camera != null:
				root.chase_camera.snap_to_target()
			root._update_arcade_field(0.1)
			await wait_first_use_frames(root, perf_probe_script, "actual_jump_pad", REAL_JUMP_PAD_WARMUP_FRAMES)
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "actual_goal_confetti")
		root.debug_set_score(0, 0)
		root.debug_force_ball_position(Vector3(0.0, 0.68, root.GOAL_LINE_SOUTH + 0.35))
		root._process_goal_detection()
		await wait_first_use_frames(root, perf_probe_script, "actual_goal_confetti", FIRST_USE_WARMUP_FRAMES + 2)
		root.restart_match(false)
		root.debug_force_ball_position(warmup_position)
		await wait_first_use_frames(root, perf_probe_script, "restart_after_actual_goal")
	if root.hud != null:
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "hud_goal_messages")
		root.hud.show_goal(true)
		root.hud.show_goal(false)
		await wait_first_use_frames(root, perf_probe_script, "hud_goal_messages", FIRST_USE_WARMUP_FRAMES + 2)
	if root.ball != null:
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "fireball")
		root.debug_force_ball_position(warmup_position)
		root.ball.linear_velocity = warmup_direction * root.SUPER_SHOT_FORCE
		if root.ball.has_method("debug_update_visual_asset"):
			root.ball.debug_update_visual_asset(0.016)
	if root.feedback != null:
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "round_end")
		root.feedback.play_round_end(true)
		perf_probe_script.mark(root, "web_warmup.first_use_feedback.step", "result_flow")
		root._finish_match(true)
		await wait_first_use_frames(root, perf_probe_script, "result_flow", FIRST_USE_WARMUP_FRAMES + 2)
	await root.get_tree().create_timer(FIRST_USE_DECAY_SECONDS, false).timeout
	if root.ball != null:
		root.ball.linear_velocity = Vector3.ZERO
		root.ball.angular_velocity = Vector3.ZERO
		if root.ball.has_method("debug_update_visual_asset"):
			root.ball.debug_update_visual_asset(0.016)
	root.restart_match(false)
	await wait_first_use_frames(root, perf_probe_script, "restart_after_result")
	if root.feedback != null:
		root.feedback.clear_effects()
		await wait_first_use_frames(root, perf_probe_script, "clear_effects")
	restore_warmup_audio_volume(previous_audio_volumes)
	perf_probe_script.end(root, "web_warmup.first_use_feedback", warmup_begin)

static func wait_first_use_frames(root: Node, perf_probe_script: Object, label: String, frame_count: int = FIRST_USE_WARMUP_FRAMES) -> void:
	for frame_index in range(maxi(1, frame_count)):
		perf_probe_script.mark(root, "web_warmup.first_use_frame", "label=%s frame=%d/%d" % [label, frame_index + 1, frame_count])
		await root.get_tree().process_frame

static func set_warmup_audio_volume(volume_db: float) -> Dictionary:
	var previous_volumes := {}
	for bus_name in ["SFX", "UI", "Ambience"]:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			continue
		previous_volumes[bus_name] = AudioServer.get_bus_volume_db(bus_index)
		AudioServer.set_bus_volume_db(bus_index, volume_db)
	return previous_volumes

static func restore_warmup_audio_volume(previous_volumes: Dictionary) -> void:
	for bus_name in previous_volumes.keys():
		var bus_index := AudioServer.get_bus_index(str(bus_name))
		if bus_index < 0:
			continue
		AudioServer.set_bus_volume_db(bus_index, float(previous_volumes[bus_name]))

static func wait_until_settled(root: Node, perf_probe_script: Object, field_builder_script: Object) -> void:
	var settle_begin: int = perf_probe_script.begin(root, "web_warmup.settle")
	var stable_frames := 0
	var previous_signature := get_loading_settle_signature(field_builder_script)
	var previous_ticks := Time.get_ticks_usec()
	for frame_index in range(LOADING_SETTLE_MAX_FRAMES):
		await root.get_tree().process_frame
		var current_ticks := Time.get_ticks_usec()
		var frame_ms := float(current_ticks - previous_ticks) / 1000.0
		previous_ticks = current_ticks
		var current_signature := get_loading_settle_signature(field_builder_script)
		var signature_stable := current_signature == previous_signature
		if signature_stable and frame_ms < LOADING_SETTLE_FRAME_MS:
			stable_frames += 1
		else:
			stable_frames = 0
		previous_signature = current_signature
		perf_probe_script.mark(
			root,
			"web_warmup.settle.sample",
			"frame=%d stable=%d frame_ms=%.3f object_count=%d node_count=%d resource_count=%d render_objects=%d" % [
				frame_index + 1,
				stable_frames,
				frame_ms,
				int(current_signature["object_count"]),
				int(current_signature["object_node_count"]),
				int(current_signature["object_resource_count"]),
				int(current_signature["render_total_objects"])
			]
		)
		if stable_frames >= LOADING_SETTLE_REQUIRED_FRAMES:
			perf_probe_script.end(root, "web_warmup.settle", settle_begin, "stable_frames=%d frames=%d" % [stable_frames, frame_index + 1])
			return
	perf_probe_script.end(root, "web_warmup.settle", settle_begin, "stable_frames=%d timeout_frames=%d" % [stable_frames, LOADING_SETTLE_MAX_FRAMES])

static func get_loading_settle_signature(field_builder_script: Object) -> Dictionary:
	var field_counts: Dictionary = field_builder_script.debug_get_static_cache_counts()
	return {
		"object_count": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"object_node_count": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"object_resource_count": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		"render_total_objects": int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		"field_crowd_material_cache": int(field_counts.get("field_crowd_material_cache", 0)),
		"field_flag_material_cache": int(field_counts.get("field_flag_material_cache", 0)),
		"field_halo_material_cache": int(field_counts.get("field_halo_material_cache", 0)),
		"field_net_material_cache": int(field_counts.get("field_net_material_cache", 0)),
	}

static func finish_deferred_render_warmup(root: Node, render_profile_script: Object, perf_probe_script: Object, buckets: Dictionary, state: Dictionary) -> void:
	if not render_profile_script.is_web_platform():
		return
	var warmup_begin: int = perf_probe_script.begin(root, "web_warmup.deferred_render")
	await reveal_warmup_categories(root, perf_probe_script, "", buckets, ["vidro"], "vidro", state, false)
	await reveal_warmup_categories(root, perf_probe_script, "", buckets, ["estandes"], "estandes", state, false)
	await reveal_warmup_categories(root, perf_probe_script, "", buckets, ["torcida"], "torcida", state, false)
	await reveal_warmup_categories(root, perf_probe_script, "", buckets, ["banners"], "banners", state, false)
	await reveal_warmup_categories(root, perf_probe_script, "", buckets, ["neon", "placares"], "neon/placares", state, false)
	await reveal_warmup_categories(root, perf_probe_script, "", buckets, ["vfx", "outros"], "restante", state, false)
	perf_probe_script.end(root, "web_warmup.deferred_render", warmup_begin, "shown=%d/%d" % [int(state["revealed"]), int(state["total"])])

static func collect_warmup_buckets(root: Node, hide_nodes: bool = true) -> Dictionary:
	var buckets := {}
	collect_warmup_buckets_from_node(root, buckets, hide_nodes)
	return buckets

static func collect_warmup_buckets_from_node(node: Node, buckets: Dictionary, hide_nodes: bool = true) -> void:
	if node is GeometryInstance3D:
		var geometry_instance := node as GeometryInstance3D
		if geometry_instance.visible:
			var category := classify_material_probe_node(geometry_instance)
			if not buckets.has(category):
				buckets[category] = []
			(buckets[category] as Array).append(geometry_instance)
			if hide_nodes:
				geometry_instance.visible = false
	for child in node.get_children():
		collect_warmup_buckets_from_node(child, buckets, hide_nodes)

static func reveal_warmup_categories(root: Node, perf_probe_script: Object, mode_name: String, buckets: Dictionary, categories: Array, label: String, state: Dictionary, update_loading_progress: bool = true, limit_nodes: int = -1) -> void:
	var nodes: Array = []
	if limit_nodes > 0 and categories.size() == 1 and buckets.has(categories[0]):
		var category_key = categories[0]
		var source_nodes := buckets[category_key] as Array
		var selected_count = mini(limit_nodes, source_nodes.size())
		for index in range(selected_count):
			nodes.append(source_nodes[index])
		var remaining_nodes: Array = []
		for index in range(selected_count, source_nodes.size()):
			remaining_nodes.append(source_nodes[index])
		buckets[category_key] = remaining_nodes
	else:
		for category in categories:
			if buckets.has(category):
				nodes.append_array(buckets[category] as Array)
	if nodes.is_empty():
		return
	var total := int(state["total"])
	for chunk_start in range(0, nodes.size(), RENDER_WARMUP_CHUNK_SIZE):
		var chunk_end := mini(nodes.size(), chunk_start + RENDER_WARMUP_CHUNK_SIZE)
		for index in range(chunk_start, chunk_end):
			var geometry_instance := nodes[index] as GeometryInstance3D
			if geometry_instance != null:
				geometry_instance.visible = true
		state["revealed"] = int(state["revealed"]) + (chunk_end - chunk_start)
		if update_loading_progress:
			var progress := lerpf(0.52, 0.88, float(state["revealed"]) / float(total))
			set_progress(root, perf_probe_script, mode_name, "Aquecendo render: %s" % label, progress)
		perf_probe_script.mark(
			root,
			"web_warmup.chunk",
			"label=%s shown=%d/%d total=%d nodes=%s" % [label, chunk_end, nodes.size(), int(state["revealed"]), format_warmup_node_names(nodes, chunk_start, chunk_end)]
		)
		await root.get_tree().process_frame

static func format_warmup_node_names(nodes: Array, chunk_start: int, chunk_end: int) -> String:
	var names: Array[String] = []
	for index in range(chunk_start, chunk_end):
		var node := nodes[index] as Node
		if node != null:
			names.append(node.name)
	return ",".join(names)

static func classify_material_probe_node(geometry_instance: GeometryInstance3D) -> String:
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
