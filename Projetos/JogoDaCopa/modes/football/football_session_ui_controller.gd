class_name FootballSessionUiController
extends RefCounted

const RenderProfileScript = preload("res://autoloads/render_profile.gd")
const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")


static func handle_input(root: Node, event: InputEvent) -> void:
	if root.web_loading_active:
		return
	if event.is_action_pressed("ui_back"):
		if get_escape_target(root) == &"menu":
			root._return_to_main_menu()
		else:
			root._set_menu_open(not root.menu_open)
		root.get_viewport().set_input_as_handled()
		return
	if root.intro_open:
		return
	if root.menu_open:
		return
	if not root.match_over and event is InputEventMouseButton and event.is_pressed() and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		capture_mouse_if_playing(root, true)
		root.get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("arcade_emote"):
		root._trigger_arcade_emote(true)
		root.get_viewport().set_input_as_handled()


static func get_escape_target(root: Node) -> StringName:
	return &"menu" if root.intro_open or root.match_over else &"pause"


static func start_match(root: Node) -> void:
	PerfProbeScript.mark(root, "event.match_start")
	if root.hud != null:
		root.hud.play_transition_pulse(root.SCREEN_TRANSITION_SECONDS)
	root._set_intro_open(false)
	if root.hud != null:
		root.hud.reset_feedback()
	root._start_kickoff_countdown()
	capture_mouse_if_playing(root)


static func set_intro_open(root: Node, is_open: bool) -> void:
	root.intro_open = is_open
	if root.intro_open:
		root.menu_open = false
		root._set_player_persistent_vfx(false, false)
		root.phase_label = &"intro"
		root.get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if root.feedback != null:
			root.feedback.set_ambience_ducked(true)
		if root.hud != null:
			root.hud.set_pause_menu_visible(false)
			root.hud.set_intro_visible(true)
		root._request_hud_and_scoreboard_refresh()
		return
	root.get_tree().paused = false
	if root.feedback != null:
		root.feedback.set_ambience_ducked(false)
	if root.phase_label == &"intro":
		root.phase_label = &"play"
	if root.hud != null:
		root.hud.set_intro_visible(false)
	root._request_hud_and_scoreboard_refresh()


static func set_menu_open(root: Node, is_open: bool) -> void:
	if root.intro_open and is_open:
		return
	PerfProbeScript.mark(root, "event.pause_menu", "open=%s" % str(is_open))
	root.menu_open = is_open
	if root.menu_open:
		root._set_player_persistent_vfx(false, false)
	root.get_tree().paused = root.menu_open
	if root.hud != null:
		root.hud.set_pause_menu_visible(root.menu_open, root.player.mouse_sensitivity if root.player != null else 0.0)
	if root.feedback != null:
		root.feedback.set_ambience_ducked(root.menu_open)
	if root.menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		capture_mouse_if_playing(root)
	root._request_hud_and_scoreboard_refresh()


static func return_to_main_menu(root: Node) -> void:
	PerfProbeScript.mark(root, "event.return_to_main_menu")
	root.call_deferred("_return_to_main_menu_async")


static func return_to_main_menu_async(root: Node) -> void:
	if root.hud != null:
		root.hud.play_fade_to_black(root.SCREEN_TRANSITION_SECONDS)
	await root.get_tree().create_timer(root.SCREEN_TRANSITION_SECONDS, true, false, true).timeout
	root.intro_open = false
	root.get_tree().paused = false
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	root.get_tree().change_scene_to_file(root.MENU_SCENE_PATH)


static func capture_mouse_if_playing(root: Node, allow_web_capture: bool = false) -> void:
	if DisplayServer.get_name().to_lower().contains("headless"):
		return
	if RenderProfileScript.is_web_platform() and not allow_web_capture:
		return
	if root.capture_scene_active:
		return
	if root.intro_open or root.menu_open or root.match_over:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
