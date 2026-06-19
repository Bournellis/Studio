class_name FootballRoot
extends Node3D

const FootballFieldBuilderScript = preload("res://modes/football/football_field_builder.gd")
const FootballRuntimeSpawnerScript = preload("res://modes/football/football_runtime_spawner.gd")
const FootballMatchFlowControllerScript = preload("res://modes/football/football_match_flow_controller.gd")
const FootballMatchPresentationControllerScript = preload("res://modes/football/football_match_presentation_controller.gd")
const FootballMatchResolutionControllerScript = preload("res://modes/football/football_match_resolution_controller.gd")
const FootballKickSuperControllerScript = preload("res://modes/football/football_kick_super_controller.gd")
const FootballBallContactControllerScript = preload("res://modes/football/football_ball_contact_controller.gd")
const FootballArcadeFieldControllerScript = preload("res://modes/football/football_arcade_field_controller.gd")
const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")
const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const RenderProfileScript = preload("res://autoloads/render_profile.gd")
const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")
const FootballWorldEnvironmentScript = preload("res://modes/football/football_world_environment.gd")
const FootballCaptureDirectorScript = preload("res://modes/football/football_capture_director.gd")
const FootballScoreboardControllerScript = preload("res://modes/football/football_scoreboard_controller.gd")
const FootballRenderSettingsControllerScript = preload("res://modes/football/football_render_settings_controller.gd")
const FootballPerfScenarioScript = preload("res://modes/football/football_perf_scenario.gd")
const FootballWebLoadingControllerScript = preload("res://modes/football/football_web_loading_controller.gd")

const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const MODE_NAME: String = "Super Campeão"
const GOAL_LIMIT: int = 3
const FIELD_WIDTH: float = 38.0
const FIELD_LENGTH: float = 54.0
const FIELD_HALF_WIDTH: float = FIELD_WIDTH * 0.5
const FIELD_HALF_LENGTH: float = FIELD_LENGTH * 0.5
const WALL_HEIGHT: float = 7.2
const CEILING_HEIGHT: float = 8.8
const WALL_THICKNESS: float = 0.8
const GOAL_HALF_WIDTH: float = 4.32
const GOAL_HEIGHT: float = 3.45
const GOAL_SIDE_WALL_X: float = GOAL_HALF_WIDTH + 0.72
const GOAL_SIDE_WALL_THICKNESS: float = 0.55
const GOAL_CLOSED_DEPTH: float = 3.8
const GOAL_LINE_NORTH: float = -FIELD_HALF_LENGTH
const GOAL_LINE_SOUTH: float = FIELD_HALF_LENGTH
const PLAYER_SPAWN: Vector3 = Vector3(0.0, 0.05, 18.0)
const BOT_SPAWN: Vector3 = Vector3(0.0, 0.05, -18.0)
const BALL_SPAWN: Vector3 = Vector3(0.0, 0.68, 0.0)
const BOT_KICKOFF_PLAYER_SAFE_Z_OFFSET: float = 10.5
const PLAYER_KICKOFF_BOT_DEFENSE_RATIO: float = 0.65
const KICKOFF_MARKER_RADIUS: float = 1.55
const PLAYER_KICK_REACH: float = 2.2
const PLAYER_KICK_ASSIST_RADIUS: float = 2.38
const PLAYER_TOUCH_RADIUS: float = 1.42
const PLAYER_TOUCH_FORCE: float = 5.2
const PLAYER_CONTACT_MINIMUM_TOUCH_SPEED: float = 2.0
const PLAYER_NEAR_BALL_RADIUS: float = 2.5
const ARCADE_SLIDE_BALL_RADIUS: float = 2.05
const ARCADE_BODY_CONTACT_RADIUS: float = 1.35
const ARCADE_CONTACT_COOLDOWN: float = 0.24
const ARCADE_SLIDE_BALL_FORCE: float = 7.2
const ARCADE_SLIDE_BALL_LIFT: float = 0.32
const ARCADE_SLIDE_STUN_DURATION: float = 0.5
const ARCADE_SLIDE_KNOCKBACK_FORCE: float = 8.0
const ARCADE_SHOULDER_KNOCKBACK_FORCE: float = 4.6
const PLAYER_KICK_FORCE: float = 20.5
const PLAYER_STRONG_KICK_FORCE: float = 29.0
const PLAYER_KICK_LIFT: float = 2.35
const PLAYER_STRONG_KICK_LIFT: float = 7.2
const CHARGED_KICK_FORCE_MULTIPLIER: float = 1.55
const CHARGED_KICK_LIFT_BONUS: float = 1.1
const SUPER_METER_MAX: float = 100.0
const SUPER_TOUCH_GAIN: float = 15.0
const SUPER_GOAL_SUFFERED_GAIN: float = 45.0
const SUPER_BOT_HARD_GAIN_MULTIPLIER: float = 1.25
const SUPER_SHOT_FORCE: float = 38.5
const SUPER_SHOT_LIFT: float = 9.4
const BOOST_PAD_SMALL_STAMINA: float = 25.0
const BOOST_PAD_RESPAWN_SECONDS: float = 4.0
const BOOST_PAD_COLLECT_RADIUS: float = 1.25
const JUMP_PAD_COLLECT_RADIUS: float = 1.55
const JUMP_PAD_COOLDOWN_SECONDS: float = 0.75
const JUMP_PAD_LAUNCH_VELOCITY: Vector3 = Vector3(0.0, 9.2, 0.0)
const PLAYER_TOUCH_COOLDOWN: float = 0.18
const GOAL_RESET_DELAY: float = 1.25
const KICKOFF_COUNTDOWN_DURATION: float = 3.0
const GOAL_SLOWMO_DURATION: float = 0.4
const GOAL_SLOWMO_SCALE: float = 0.38
const MATCH_MODE_GOALS: StringName = &"goals"
const MATCH_MODE_TIMER: StringName = &"timer"
const MATCH_DURATION_SECONDS: float = 180.0
const DOUBLE_GOAL_WINDOW_SECONDS: float = 30.0
const BOT_DIFFICULTY_META_KEY: String = "jogodacopa_bot_difficulty"
const MATCH_MODE_META_KEY: String = "jogodacopa_match_mode"
const RESULT_SUPPRESS_TRANSITION_PULSE_KEY: String = "suppress_transition_pulse"
const BOT_DIFFICULTY_IDS: Array = [&"easy", &"normal", &"hard"]
const MATCH_MODE_IDS: Array = [&"timer", &"goals"]
const SCREEN_TRANSITION_SECONDS: float = 0.25
const HUD_SNAPSHOT_INTERVAL_SECONDS: float = 0.1

var player
var player_avatar
var chase_camera
var bot
var bot_avatar
var ball
var hud
var feedback
var selected_appearance = AvatarCatalogScript.get_default_appearance()
var bot_appearance = AvatarAppearanceScript.new(&"brown", &"france")
var player_score: int = 0
var bot_score: int = 0
var match_over: bool = false
var intro_open: bool = false
var menu_open: bool = false
var phase_label: StringName = &"kickoff"
var goal_reset_timer: float = 0.0
var player_touch_cooldown_remaining: float = 0.0
var arcade_contact_cooldown_remaining: float = 0.0
var ball_contact_audio_cooldown_remaining: float = 0.0
var player_ball_control_state: StringName = &"free"
var player_ball_control_strength: float = 0.0
var last_kick_assist_strength: float = 0.0
var last_goal_player_scored: bool = false
var kickoff_owner: StringName = &"player"
var bot_difficulty_id: StringName = &"normal"
var match_mode_id: StringName = MATCH_MODE_TIMER
var match_time_remaining: float = MATCH_DURATION_SECONDS
var golden_goal_active: bool = false
var last_thirty_announced: bool = false
var last_goal_value: int = 1
var player_super_meter: float = 0.0
var bot_super_meter: float = 0.0
var player_super_used_this_kickoff: bool = false
var bot_super_used_this_kickoff: bool = false
var boost_pad_areas: Array[Area3D] = []
var jump_pad_areas: Array[Area3D] = []
var kickoff_marker: MeshInstance3D
var player_kickoff_waiting_for_touch: bool = false
var kickoff_countdown_remaining: float = 0.0
var countdown_last_number: int = 0
var debug_kickoff_countdown_start_count: int = 0
var goal_slowmo_remaining: float = 0.0
var world_environment: WorldEnvironment
var stadium_scoreboard_score_labels: Dictionary = {}
var stadium_scoreboard_phase_labels: Dictionary = {}
var stadium_scoreboard_viewports: Dictionary = {}
var web_loading_overlay: CanvasLayer
var web_loading_bar: ProgressBar
var web_loading_label: Label
var web_loading_active: bool = false
var match_stats: Dictionary = FootballMatchRulesScript.build_empty_match_stats()
var capture_scene_active: bool = false
var perf_scenario_active: bool = false
var perf_scenario_elapsed: float = 0.0
var perf_scenario_step: int = -1
var perf_stability_sample_elapsed: float = 0.0
var hud_snapshot_elapsed: float = HUD_SNAPSHOT_INTERVAL_SECONDS
var stadium_scoreboard_elapsed: float = FootballScoreboardControllerScript.UPDATE_INTERVAL_SECONDS
var web_feedback_scenario_filter_loaded: bool = false
var web_feedback_scenario_allow_all: bool = true
var web_feedback_scenario_enabled: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	PerfProbeScript.ensure_enabled(self, "football")
	if RenderProfileScript.is_web_platform():
		web_loading_active = true
		FootballWebLoadingControllerScript.build_overlay(self, MODE_NAME)
		call_deferred("_ready_web_async")
		return
	_ready_sync()

func _ready_sync() -> void:
	var ready_begin := PerfProbeScript.begin(self, "football.ready")
	FootballRenderSettingsControllerScript.apply_main_menu_settings(self)
	FootballRenderSettingsControllerScript.connect_game_settings_signals(self, Callable(self, "_on_settings_quality_changed"))
	var stage_begin := PerfProbeScript.begin(self, "football.configure_world")
	_configure_world()
	PerfProbeScript.end(self, "football.configure_world", stage_begin)
	stage_begin = PerfProbeScript.begin(self, "football.spawn_runtime")
	_spawn_runtime()
	PerfProbeScript.end(self, "football.spawn_runtime", stage_begin)
	stage_begin = PerfProbeScript.begin(self, "football.restart_play_initial")
	_restart_play(false, false)
	PerfProbeScript.end(self, "football.restart_play_initial", stage_begin)
	_set_intro_open(true)
	call_deferred("_apply_capture_scene_from_meta")
	call_deferred("_mark_first_runtime_frame")
	PerfProbeScript.end(self, "football.ready", ready_begin)

func _ready_web_async() -> void:
	var ready_begin := PerfProbeScript.begin(self, "football.ready")
	FootballRenderSettingsControllerScript.apply_main_menu_settings(self)
	FootballRenderSettingsControllerScript.connect_game_settings_signals(self, Callable(self, "_on_settings_quality_changed"))
	FootballWebLoadingControllerScript.set_progress(self, PerfProbeScript, MODE_NAME, "Preparando arena", 0.08)
	await get_tree().process_frame
	var stage_begin := PerfProbeScript.begin(self, "football.configure_world")
	_configure_world()
	PerfProbeScript.end(self, "football.configure_world", stage_begin)
	FootballWebLoadingControllerScript.set_progress(self, PerfProbeScript, MODE_NAME, "Carregando jogadores", 0.36)
	await get_tree().process_frame
	stage_begin = PerfProbeScript.begin(self, "football.spawn_runtime")
	_spawn_runtime()
	PerfProbeScript.end(self, "football.spawn_runtime", stage_begin)
	if FootballWebLoadingControllerScript.RENDER_WARMUP_ENABLED:
		FootballWebLoadingControllerScript.set_progress(self, PerfProbeScript, MODE_NAME, "Aquecendo render", 0.52)
		await FootballWebLoadingControllerScript.warmup_first_render(self, RenderProfileScript, PerfProbeScript, FootballFieldBuilderScript, MODE_NAME)
	FootballWebLoadingControllerScript.set_progress(self, PerfProbeScript, MODE_NAME, "Preparando partida", 0.90)
	stage_begin = PerfProbeScript.begin(self, "football.restart_play_initial")
	_restart_play(false, false)
	PerfProbeScript.end(self, "football.restart_play_initial", stage_begin)
	if FootballWebLoadingControllerScript.RENDER_WARMUP_ENABLED:
		FootballWebLoadingControllerScript.set_progress(self, PerfProbeScript, MODE_NAME, "Aquecendo efeitos", 0.92)
		await FootballWebLoadingControllerScript.warmup_first_use_feedback(self, RenderProfileScript, PerfProbeScript)
		stage_begin = PerfProbeScript.begin(self, "football.restart_play_after_warmup")
		_restart_play(false, false)
		PerfProbeScript.end(self, "football.restart_play_after_warmup", stage_begin)
		FootballWebLoadingControllerScript.set_progress(self, PerfProbeScript, MODE_NAME, "Estabilizando quadros", 0.97)
		await FootballWebLoadingControllerScript.wait_until_settled(self, PerfProbeScript, FootballFieldBuilderScript)
	_set_intro_open(true)
	FootballWebLoadingControllerScript.set_progress(self, PerfProbeScript, MODE_NAME, "Entrando em campo", 1.0)
	_apply_capture_scene_from_meta()
	call_deferred("_mark_first_runtime_frame")
	PerfProbeScript.end(self, "football.ready", ready_begin)
	FootballWebLoadingControllerScript.release_gameplay_under_overlay(self, PerfProbeScript)
	await FootballWebLoadingControllerScript.wait_until_settled(self, PerfProbeScript, FootballFieldBuilderScript)
	FootballWebLoadingControllerScript.hide_overlay(self, PerfProbeScript)

func _process(_delta: float) -> void:
	_maybe_quit_after_perf_duration()
	if web_loading_active:
		return
	if perf_scenario_active:
		_update_perf_scenario(_delta)
	if PerfProbeScript.is_enabled(self):
		_update_perf_stability_sampling(_delta)
	_update_hud_snapshot(_delta)
	_update_stadium_scoreboards(_delta)
	_update_goal_slowmo(_delta)

func _physics_process(delta: float) -> void:
	if web_loading_active:
		return
	if intro_open or menu_open:
		return
	_update_player_presentation_fx(delta)
	if kickoff_countdown_remaining > 0.0:
		_update_kickoff_countdown(delta)
		return
	_update_contact_cooldowns(delta)
	if FootballMatchResolutionControllerScript.update_goal_reset(self, delta):
		return
	if match_over:
		return
	_update_match_clock(delta)
	if match_over:
		return
	_update_player_ball_control(delta)
	_process_player_ball_contact()
	_process_arcade_action_contacts()
	_update_arcade_field(delta)
	_process_goal_detection()
	_update_avatar_states(delta)

func _input(event: InputEvent) -> void:
	if web_loading_active:
		return
	if event.is_action_pressed("ui_back"):
		if _get_escape_target() == &"menu":
			_return_to_main_menu()
		else:
			_set_menu_open(not menu_open)
		get_viewport().set_input_as_handled()
		return
	if intro_open:
		return
	if menu_open:
		return
	if not match_over and event is InputEventMouseButton and event.is_pressed() and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		_capture_mouse_if_playing(true)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("arcade_emote"):
		_trigger_arcade_emote(true)
		get_viewport().set_input_as_handled()

func _get_escape_target() -> StringName:
	return &"menu" if intro_open or match_over else &"pause"

func restart_match(capture_mouse: bool = true) -> void:
	FootballMatchResolutionControllerScript.restart_match(self, capture_mouse)

func debug_get_player():
	return player

func debug_get_player_avatar():
	return player_avatar

func debug_get_chase_camera():
	return chase_camera

func debug_get_camera_focus_position() -> Vector3:
	return chase_camera.debug_get_focus_position() if chase_camera != null else Vector3.ZERO

func debug_get_camera_desired_position() -> Vector3:
	return chase_camera.debug_get_desired_position() if chase_camera != null else Vector3.ZERO

func debug_get_player_kick_origin() -> Vector3:
	return _get_player_kick_origin()

func debug_get_player_kick_direction() -> Vector3:
	return _get_player_kick_direction()

func debug_get_player_ball_control_state() -> StringName:
	return player_ball_control_state

func debug_get_player_ball_control_strength() -> float:
	return player_ball_control_strength

func debug_get_last_kick_assist_strength() -> float:
	return last_kick_assist_strength

func debug_get_player_boost_fraction() -> float:
	return player.get_boost_stamina_fraction() if player != null else 0.0

func debug_get_player_dash_cooldown_fraction() -> float:
	return player.get_arcade_dash_cooldown_fraction() if player != null and player.has_method("get_arcade_dash_cooldown_fraction") else 0.0

func debug_get_player_super_meter() -> float:
	return player_super_meter

func debug_get_bot_super_meter() -> float:
	return bot_super_meter

func debug_set_player_super_meter(next_meter: float) -> void:
	player_super_meter = clampf(next_meter, 0.0, SUPER_METER_MAX)

func debug_set_bot_super_meter(next_meter: float) -> void:
	bot_super_meter = clampf(next_meter, 0.0, SUPER_METER_MAX)

func debug_player_super_used_this_kickoff() -> bool:
	return player_super_used_this_kickoff

func debug_is_kickoff_locked() -> bool:
	return kickoff_countdown_remaining > 0.0

func debug_get_kickoff_countdown_remaining() -> float:
	return kickoff_countdown_remaining

func debug_get_kickoff_countdown_last_number() -> int:
	return countdown_last_number

func debug_get_kickoff_countdown_start_count() -> int:
	return debug_kickoff_countdown_start_count

func debug_reset_kickoff_countdown_start_count() -> void:
	debug_kickoff_countdown_start_count = 0

func debug_is_goal_slowmo_active() -> bool:
	return goal_slowmo_remaining > 0.0

func debug_get_feedback():
	return feedback

func debug_update_player_ball_control(delta: float = 0.1) -> void:
	_update_player_ball_control(delta)

func debug_process_arcade_action_contacts() -> void:
	_process_arcade_action_contacts()

func debug_update_arcade_field(delta: float = 0.1) -> void:
	_update_arcade_field(delta)

func debug_get_boost_pad_count() -> int:
	return boost_pad_areas.size()

func debug_get_jump_pad_count() -> int:
	return jump_pad_areas.size()

func debug_is_boost_pad_active(index: int) -> bool:
	if index < 0 or index >= boost_pad_areas.size():
		return false
	return _is_boost_pad_active(boost_pad_areas[index])

func debug_build_hud_snapshot() -> Dictionary:
	return _build_hud_snapshot()

func debug_get_hud_snapshot_interval_seconds() -> float:
	return HUD_SNAPSHOT_INTERVAL_SECONDS

func debug_get_stadium_scoreboard_interval_seconds() -> float:
	return FootballScoreboardControllerScript.UPDATE_INTERVAL_SECONDS

func debug_get_match_stats_summary() -> Dictionary:
	return FootballMatchRulesScript.build_match_stats_summary(match_stats)

func debug_get_render_profile_id() -> StringName:
	return RenderProfileScript.get_active_profile_id()

func debug_get_render_environment_settings() -> Dictionary:
	return RenderProfileScript.get_environment_settings()

func debug_get_escape_target() -> StringName:
	return _get_escape_target()

func debug_get_bot():
	return bot

func debug_is_bot_kickoff_hold_active() -> bool:
	return bot.debug_is_kickoff_hold_active() if bot != null and bot.has_method("debug_is_kickoff_hold_active") else false

func debug_get_bot_last_approach_label() -> StringName:
	return bot.debug_get_last_approach_label() if bot != null else &"none"

func debug_get_bot_difficulty_id() -> StringName:
	return bot_difficulty_id

func debug_set_bot_difficulty(next_difficulty_id: StringName) -> void:
	set_bot_difficulty(next_difficulty_id)

func set_bot_difficulty(next_difficulty_id: StringName) -> void:
	bot_difficulty_id = _sanitize_bot_difficulty(next_difficulty_id)
	if bot != null:
		bot.set_difficulty(bot_difficulty_id)
		bot_difficulty_id = bot.debug_get_difficulty_id()
	_request_hud_and_scoreboard_refresh()

func set_match_mode(next_match_mode_id: StringName) -> void:
	FootballMatchResolutionControllerScript.set_match_mode(self, next_match_mode_id)

func debug_get_kickoff_owner() -> StringName:
	return kickoff_owner

func debug_set_kickoff_owner(next_owner: StringName) -> void:
	kickoff_owner = &"bot" if next_owner == &"bot" else &"player"

func debug_get_bot_avatar():
	return bot_avatar

func debug_get_ball():
	return ball

func debug_is_kickoff_marker_visible() -> bool:
	return kickoff_marker != null and kickoff_marker.visible

func debug_get_kickoff_marker_position() -> Vector3:
	return kickoff_marker.global_position if kickoff_marker != null else Vector3.ZERO

func debug_is_camera_inside_goal_shell() -> bool:
	if chase_camera == null:
		return false
	var camera_position: Vector3 = chase_camera.global_position
	var inside_goal_width := absf(camera_position.x) <= GOAL_SIDE_WALL_X
	var inside_goal_height := camera_position.y >= -0.1 and camera_position.y <= GOAL_HEIGHT + 0.8
	var inside_north_shell := camera_position.z <= GOAL_LINE_NORTH + 0.1 and camera_position.z >= GOAL_LINE_NORTH - GOAL_CLOSED_DEPTH - 0.4
	var inside_south_shell := camera_position.z >= GOAL_LINE_SOUTH - 0.1 and camera_position.z <= GOAL_LINE_SOUTH + GOAL_CLOSED_DEPTH + 0.4
	return inside_goal_width and inside_goal_height and (inside_north_shell or inside_south_shell)

func debug_get_player_score() -> int:
	return player_score

func debug_get_bot_score() -> int:
	return bot_score

func debug_get_goal_limit() -> int:
	return GOAL_LIMIT

func debug_get_match_mode() -> StringName:
	return match_mode_id

func debug_set_match_mode(next_match_mode_id: StringName) -> void:
	set_match_mode(next_match_mode_id)

func debug_get_match_time_remaining() -> float:
	return match_time_remaining

func debug_set_match_time_remaining(next_time_remaining: float) -> void:
	match_time_remaining = maxf(0.0, next_time_remaining)
	last_thirty_announced = match_time_remaining <= DOUBLE_GOAL_WINDOW_SECONDS
	_request_hud_and_scoreboard_refresh()

func debug_update_match_clock(delta: float) -> void:
	_update_match_clock(delta)

func debug_is_golden_goal_active() -> bool:
	return golden_goal_active

func debug_get_last_goal_value() -> int:
	return last_goal_value

func debug_is_match_over() -> bool:
	return match_over

func debug_is_player_input_locked() -> bool:
	return player.debug_is_input_locked() if player != null and player.has_method("debug_is_input_locked") else false

func debug_is_intro_open() -> bool:
	return intro_open

func debug_start_match() -> void:
	_start_match()
	debug_finish_kickoff_countdown()
	debug_release_bot_kickoff_hold()

func debug_start_match_with_countdown() -> void:
	_start_match()

func debug_finish_kickoff_countdown() -> void:
	kickoff_countdown_remaining = 0.0
	countdown_last_number = 0
	_set_round_input_locked(false)
	if not match_over:
		phase_label = &"play"
	Engine.time_scale = 1.0
	_request_hud_and_scoreboard_refresh()

func debug_release_bot_kickoff_hold() -> void:
	player_kickoff_waiting_for_touch = false
	if bot != null and bot.has_method("release_kickoff_defense_hold"):
		bot.release_kickoff_defense_hold()

func debug_cycle_skin_tone(step: int = 1) -> void:
	_cycle_skin_tone(step)

func debug_cycle_country_kit(step: int = 1) -> void:
	_cycle_country_kit(step)

func debug_get_selected_skin_tone_id() -> StringName:
	return selected_appearance.skin_tone_id

func debug_get_selected_country_kit_id() -> StringName:
	return selected_appearance.country_kit_id

func debug_force_ball_position(next_ball_position: Vector3) -> void:
	if ball == null:
		return
	ball.global_position = next_ball_position
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO

func debug_set_score(next_player_score: int, next_bot_score: int) -> void:
	player_score = maxi(0, next_player_score)
	bot_score = maxi(0, next_bot_score)
	_request_hud_and_scoreboard_refresh()

func debug_trigger_arcade_emote(player_triggered: bool = true) -> void:
	_trigger_arcade_emote(player_triggered)

func debug_get_arena_config() -> Dictionary:
	return {
		"field_width": FIELD_WIDTH,
		"field_length": FIELD_LENGTH,
		"wall_height": WALL_HEIGHT,
		"ceiling_height": CEILING_HEIGHT,
		"wall_thickness": WALL_THICKNESS,
		"goal_half_width": GOAL_HALF_WIDTH,
		"goal_height": GOAL_HEIGHT,
		"goal_side_wall_x": GOAL_SIDE_WALL_X,
		"goal_side_wall_thickness": GOAL_SIDE_WALL_THICKNESS,
		"goal_closed_depth": GOAL_CLOSED_DEPTH,
		"goal_line_north": GOAL_LINE_NORTH,
		"goal_line_south": GOAL_LINE_SOUTH
	}

func debug_get_stadium_scoreboard_text(side_name: String = "North") -> String:
	var label := _get_stadium_scoreboard_score_label(side_name)
	return label.text if label != null else ""

func _apply_capture_scene_from_meta() -> void:
	FootballCaptureDirectorScript.apply_from_meta(self, get_tree())

func _configure_world() -> void:
	RenderProfileScript.report_runtime_profile_once("FootballRoot")
	var stage_begin := PerfProbeScript.begin(self, "football.world_environment")
	world_environment = FootballWorldEnvironmentScript.add_world_environment(self, RenderProfileScript)
	PerfProbeScript.end(self, "football.world_environment", stage_begin)

	stage_begin = PerfProbeScript.begin(self, "football.key_light")
	FootballWorldEnvironmentScript.add_stadium_key_light(self)
	PerfProbeScript.end(self, "football.key_light", stage_begin)
	stage_begin = PerfProbeScript.begin(self, "football.field_builder")
	_build_football_pitch()
	PerfProbeScript.end(self, "football.field_builder", stage_begin)

func _build_night_environment() -> Environment:
	return FootballWorldEnvironmentScript.build_night_environment(RenderProfileScript)

func _build_football_pitch() -> void:
	FootballFieldBuilderScript.build(self, {
		"field_width": FIELD_WIDTH,
		"field_length": FIELD_LENGTH,
		"wall_height": WALL_HEIGHT,
		"ceiling_height": CEILING_HEIGHT,
		"wall_thickness": WALL_THICKNESS,
		"goal_half_width": GOAL_HALF_WIDTH,
		"goal_height": GOAL_HEIGHT,
		"goal_side_wall_x": GOAL_SIDE_WALL_X,
		"goal_side_wall_thickness": GOAL_SIDE_WALL_THICKNESS,
		"goal_closed_depth": GOAL_CLOSED_DEPTH,
		"goal_line_north": GOAL_LINE_NORTH,
		"goal_line_south": GOAL_LINE_SOUTH,
	})

func _spawn_runtime() -> void:
	FootballRuntimeSpawnerScript.spawn(self, RenderProfileScript, PerfProbeScript)

func _get_game_settings():
	return FootballRenderSettingsControllerScript.get_game_settings(self)

func _on_settings_quality_changed(_quality_id: StringName) -> void:
	FootballRenderSettingsControllerScript.refresh_render_profile_runtime(self)

func _on_pause_quality_changed(_quality_id: StringName) -> void:
	FootballRenderSettingsControllerScript.on_pause_quality_changed(self, _quality_id)

func _refresh_render_profile_runtime() -> void:
	FootballRenderSettingsControllerScript.refresh_render_profile_runtime(self)

func _restart_play(after_goal: bool, start_countdown: bool = true) -> void:
	FootballMatchFlowControllerScript.restart_play(self, after_goal, start_countdown)

func _on_player_kick_requested(_origin: Vector3, _direction: Vector3, _damage: float, _knockback: float) -> void:
	FootballKickSuperControllerScript.on_player_kick_requested(self, _origin, _direction, _damage, _knockback)

func _on_player_charged_kick_requested(_origin: Vector3, _direction: Vector3, charge_fraction: float, _held_seconds: float) -> void:
	FootballKickSuperControllerScript.on_player_charged_kick_requested(self, _origin, _direction, charge_fraction, _held_seconds)

func _on_player_strong_kick_requested(_origin: Vector3, _direction: Vector3, _damage: float, _knockback: float, _speed: float, _radius: float, _overcharged: bool) -> void:
	FootballKickSuperControllerScript.on_player_strong_kick_requested(self, _origin, _direction, _damage, _knockback, _speed, _radius, _overcharged)

func _try_player_kick(origin: Vector3, direction: Vector3, force: float, lift: float, strong: bool, super_shot: bool = false) -> void:
	FootballKickSuperControllerScript.try_player_kick(self, origin, direction, force, lift, strong, super_shot)

func _on_bot_kick_requested(origin: Vector3, direction: Vector3, force: float, lift: float) -> void:
	FootballKickSuperControllerScript.on_bot_kick_requested(self, origin, direction, force, lift)

func _update_contact_cooldowns(delta: float) -> void:
	player_touch_cooldown_remaining = maxf(0.0, player_touch_cooldown_remaining - delta)
	arcade_contact_cooldown_remaining = maxf(0.0, arcade_contact_cooldown_remaining - delta)
	ball_contact_audio_cooldown_remaining = maxf(0.0, ball_contact_audio_cooldown_remaining - delta)

func _update_player_ball_control(_delta: float) -> void:
	if player == null or ball == null:
		player_ball_control_state = &"free"
		player_ball_control_strength = 0.0
		return
	var flat_forward := _flatten_normalized(_get_player_kick_direction())
	if flat_forward.length_squared() <= 0.0001:
		flat_forward = Vector3.FORWARD
	var player_center: Vector3 = player.global_position + Vector3.UP * 0.48
	var ball_position: Vector3 = ball.global_position
	var flat_delta := Vector3(ball_position.x - player_center.x, 0.0, ball_position.z - player_center.z)
	var distance := flat_delta.length()
	if distance <= 0.0001:
		player_ball_control_state = &"contact"
		player_ball_control_strength = 1.0
		return
	var ball_direction := flat_delta / distance
	var forward_dot := ball_direction.dot(flat_forward)
	var reachable: bool = distance <= PLAYER_NEAR_BALL_RADIUS and forward_dot >= -0.12
	var touching: bool = distance <= PLAYER_TOUCH_RADIUS
	if touching:
		player_ball_control_state = &"contact"
	elif reachable:
		player_ball_control_state = &"reachable"
	else:
		player_ball_control_state = &"free"
	var proximity_strength := 1.0 - clampf(distance / maxf(0.01, PLAYER_NEAR_BALL_RADIUS), 0.0, 1.0)
	var facing_strength := clampf((forward_dot + 0.12) / 1.12, 0.0, 1.0)
	player_ball_control_strength = clampf(proximity_strength * 0.62 + facing_strength * 0.38, 0.0, 1.0)

func _process_player_ball_contact() -> void:
	if player_touch_cooldown_remaining > 0.0:
		return
	var player_center: Vector3 = player.global_position + Vector3.UP * 0.5
	var ball_position: Vector3 = ball.global_position
	var delta := ball_position - player_center
	var flat_delta := Vector3(delta.x, 0.0, delta.z)
	var flat_delta_length_squared := flat_delta.length_squared()
	if flat_delta_length_squared > PLAYER_TOUCH_RADIUS * PLAYER_TOUCH_RADIUS:
		return
	var player_velocity: Vector3 = player.velocity
	var flat_velocity := Vector3(player_velocity.x, 0.0, player_velocity.z)
	if flat_velocity.length_squared() < PLAYER_CONTACT_MINIMUM_TOUCH_SPEED * PLAYER_CONTACT_MINIMUM_TOUCH_SPEED:
		return
	var contact_direction_source := flat_velocity.normalized() * 0.6
	if flat_delta_length_squared > 0.0001:
		contact_direction_source += flat_delta.normalized()
	var contact_direction := contact_direction_source.normalized()
	if contact_direction.length_squared() <= 0.0001:
		return
	var boost_multiplier := 1.35 if player.is_boosting() else 1.0
	var contact_lift := 0.42 if player.is_boosting() else 0.18
	_notify_player_touched_ball()
	ball.kick(contact_direction, PLAYER_TOUCH_FORCE * boost_multiplier, contact_lift)
	_add_player_super(SUPER_TOUCH_GAIN)
	player_touch_cooldown_remaining = PLAYER_TOUCH_COOLDOWN

func _process_arcade_action_contacts() -> void:
	if arcade_contact_cooldown_remaining > 0.0 or player == null or bot == null or ball == null:
		return
	var handled := false
	if player.is_arcade_dashing():
		handled = FootballBallContactControllerScript.process_arcade_dash_contact(self, player, bot, true, player.get_arcade_dash_direction()) or handled
	if bot.debug_is_arcade_dashing():
		handled = FootballBallContactControllerScript.process_arcade_dash_contact(self, bot, player, false, bot.debug_get_arcade_dash_direction()) or handled
	if handled:
		arcade_contact_cooldown_remaining = ARCADE_CONTACT_COOLDOWN

func _flatten_normalized(value: Vector3) -> Vector3:
	value.y = 0.0
	return value.normalized() if value.length_squared() > 0.0001 else Vector3.ZERO

func _on_ball_body_entered(body: Node) -> void:
	FootballBallContactControllerScript.on_ball_body_entered(self, body, RenderProfileScript)

func _collect_arcade_field_nodes() -> void:
	FootballArcadeFieldControllerScript.collect_nodes(self)

func _reset_arcade_field() -> void:
	FootballArcadeFieldControllerScript.reset(self)

func _update_arcade_field(delta: float) -> void:
	FootballArcadeFieldControllerScript.update(self, delta)

func _update_boost_pads(delta: float) -> void:
	FootballArcadeFieldControllerScript.update_boost_pads(self, delta)

func _collect_boost_pad(pad: Area3D, collected_by_player: bool) -> void:
	FootballArcadeFieldControllerScript.collect_boost_pad(self, pad, collected_by_player)

func _is_boost_pad_active(pad: Area3D) -> bool:
	return FootballArcadeFieldControllerScript.is_boost_pad_active(pad)

func _set_boost_pad_active(pad: Area3D, is_active: bool) -> void:
	FootballArcadeFieldControllerScript.set_boost_pad_active(pad, is_active)

func _update_jump_pads(delta: float) -> void:
	FootballArcadeFieldControllerScript.update_jump_pads(self, delta)

func _process_goal_detection() -> void:
	FootballMatchResolutionControllerScript.process_goal_detection(self)

func _register_goal(player_scored: bool) -> void:
	FootballMatchResolutionControllerScript.register_goal(self, player_scored)

func _add_player_super(amount: float) -> void:
	FootballKickSuperControllerScript.add_player_super(self, amount)

func _add_bot_super(amount: float) -> void:
	FootballKickSuperControllerScript.add_bot_super(self, amount)

func _can_player_use_super() -> bool:
	return FootballKickSuperControllerScript.can_player_use_super(self)

func _can_bot_use_super() -> bool:
	return FootballKickSuperControllerScript.can_bot_use_super(self)

func _get_bot_super_gain_multiplier() -> float:
	return FootballKickSuperControllerScript.get_bot_super_gain_multiplier(self)

func _update_match_clock(delta: float) -> void:
	FootballMatchResolutionControllerScript.update_match_clock(self, delta)

func _finish_match(player_won: bool) -> void:
	FootballMatchResolutionControllerScript.finish_match(self, player_won)

func _trigger_arcade_emote(player_triggered: bool) -> void:
	PerfProbeScript.mark(self, "event.arcade_emote", "player=%s" % str(player_triggered))
	if goal_reset_timer <= 0.0 and not match_over:
		return
	var actor_position := Vector3.ZERO
	var skip_web_avatar_celebration := RenderProfileScript.is_web_platform()
	if player_triggered:
		if player_avatar != null and not skip_web_avatar_celebration:
			player_avatar.play_celebrate()
		actor_position = player.global_position if player != null else Vector3.ZERO
	else:
		if bot_avatar != null and not skip_web_avatar_celebration:
			bot_avatar.play_celebrate()
		actor_position = bot.global_position if bot != null else Vector3.ZERO
	if hud != null:
		hud.show_announcement("QUE FESTA!" if player_triggered else "O BOT PROVOCA!", 0.75, &"emote")
	if feedback != null and feedback.has_method("play_arcade_confetti"):
		feedback.play_arcade_confetti(actor_position, player_triggered)

func _can_reach_ball(origin: Vector3, direction: Vector3) -> bool:
	var assist: Dictionary = FootballMatchRulesScript.get_kick_assist(
		origin,
		direction,
		ball.global_position,
		ball.ball_radius,
		PLAYER_KICK_REACH,
		PLAYER_KICK_ASSIST_RADIUS
	)
	return bool(assist.get("connected", false))

func _get_kick_assist_strength(origin: Vector3, direction: Vector3) -> float:
	var assist: Dictionary = FootballMatchRulesScript.get_kick_assist(
		origin,
		direction,
		ball.global_position,
		ball.ball_radius,
		PLAYER_KICK_REACH,
		PLAYER_KICK_ASSIST_RADIUS
	)
	return float(assist.get("assist_strength", 0.0))

func _build_kick_direction(origin: Vector3, direction: Vector3) -> Vector3:
	return FootballMatchRulesScript.build_kick_direction(origin, direction, ball.global_position, -player.global_transform.basis.z)

func _get_player_kick_origin() -> Vector3:
	return player.global_position + Vector3.UP * 0.92 if player != null else Vector3.UP * 0.92

func _get_player_kick_direction() -> Vector3:
	if player == null:
		return Vector3.FORWARD
	var forward: Vector3 = -player.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		return Vector3.FORWARD
	return forward.normalized()

func _build_hud_snapshot() -> Dictionary:
	return FootballMatchPresentationControllerScript.build_hud_snapshot(self, MODE_NAME, AvatarCatalogScript)

func _update_hud_snapshot(delta: float) -> void:
	FootballMatchPresentationControllerScript.update_hud_snapshot(self, delta, MODE_NAME, AvatarCatalogScript)

func _request_hud_and_scoreboard_refresh() -> void:
	FootballMatchPresentationControllerScript.request_hud_and_scoreboard_refresh(self, FootballScoreboardControllerScript.UPDATE_INTERVAL_SECONDS)

func _build_result_snapshot() -> Dictionary:
	return FootballMatchPresentationControllerScript.build_result_snapshot(self, AvatarCatalogScript)

func _format_result_stats(summary: Dictionary, player_code: String, bot_code: String) -> String:
	return FootballMatchPresentationControllerScript.format_result_stats(summary, player_code, bot_code)

func _get_kit_code(country_kit_id: StringName) -> String:
	return FootballMatchPresentationControllerScript.get_kit_code(country_kit_id)

func _sanitize_bot_difficulty(next_difficulty_id: StringName) -> StringName:
	return next_difficulty_id if BOT_DIFFICULTY_IDS.has(next_difficulty_id) else &"normal"

func _sanitize_match_mode(next_match_mode_id: StringName) -> StringName:
	return next_match_mode_id if MATCH_MODE_IDS.has(next_match_mode_id) else MATCH_MODE_TIMER

func _update_stadium_scoreboards(delta: float) -> void:
	FootballScoreboardControllerScript.update(self, delta, RenderProfileScript)

func _get_stadium_scoreboard_score_label(side_name: String) -> Label:
	return FootballScoreboardControllerScript.get_score_label(self, side_name)

func _get_stadium_scoreboard_phase_label(side_name: String) -> Label:
	return FootballScoreboardControllerScript.get_phase_label(self, side_name)

func _get_stadium_scoreboard_viewport(side_name: String) -> SubViewport:
	return FootballScoreboardControllerScript.get_viewport(self, side_name)

func _request_stadium_scoreboard_update(side_name: String) -> void:
	FootballScoreboardControllerScript.request_update(self, side_name, RenderProfileScript)

func _get_stadium_scoreboard_phase_text() -> String:
	return FootballScoreboardControllerScript.get_phase_text(self)

func _start_kickoff_countdown() -> void:
	FootballMatchFlowControllerScript.start_kickoff_countdown(self)

func _update_kickoff_countdown(delta: float) -> void:
	FootballMatchFlowControllerScript.update_kickoff_countdown(self, delta)

func _set_round_input_locked(is_locked: bool) -> void:
	FootballMatchFlowControllerScript.set_round_input_locked(self, is_locked)

func _update_player_presentation_fx(_delta: float) -> void:
	var boost_fraction := 0.0
	var boost_active := false
	if player != null and player.is_boosting():
		boost_fraction = 1.0
		boost_active = true
	if player != null and player.has_method("is_arcade_dashing") and player.is_arcade_dashing():
		boost_active = true
	if chase_camera != null:
		chase_camera.set_boost_fov_fraction(boost_fraction)
	var skid_active := false
	if player != null and player.is_on_floor():
		var flat_speed := Vector3(player.velocity.x, 0.0, player.velocity.z).length()
		skid_active = flat_speed > 7.2 and not boost_active
	_set_player_persistent_vfx(boost_active, skid_active)

func _set_player_persistent_vfx(boost_active: bool, skid_active: bool) -> void:
	if player_avatar != null:
		player_avatar.set_boost_trail_active(boost_active)
		player_avatar.set_skid_dust_active(skid_active)

func _trigger_goal_gamefeel() -> void:
	if RenderProfileScript.is_web_platform():
		goal_slowmo_remaining = 0.0
		Engine.time_scale = 1.0
		PerfProbeScript.mark(self, "event.goal_gamefeel", "web_slowmo_disabled=true")
		return
	goal_slowmo_remaining = GOAL_SLOWMO_DURATION
	if not DisplayServer.get_name().to_lower().contains("headless"):
		Engine.time_scale = GOAL_SLOWMO_SCALE
	if chase_camera != null:
		chase_camera.focus_goal(GOAL_SLOWMO_DURATION)
		chase_camera.play_shake(0.16, 0.32)

func _update_goal_slowmo(delta: float) -> void:
	if goal_slowmo_remaining <= 0.0:
		return
	goal_slowmo_remaining = maxf(0.0, goal_slowmo_remaining - delta)
	if goal_slowmo_remaining <= 0.0:
		Engine.time_scale = 1.0

func _start_match() -> void:
	PerfProbeScript.mark(self, "event.match_start")
	if hud != null:
		hud.play_transition_pulse(SCREEN_TRANSITION_SECONDS)
	_set_intro_open(false)
	if hud != null:
		hud.reset_feedback()
	_start_kickoff_countdown()
	_capture_mouse_if_playing()

func _set_intro_open(is_open: bool) -> void:
	intro_open = is_open
	if intro_open:
		menu_open = false
		_set_player_persistent_vfx(false, false)
		phase_label = &"intro"
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if feedback != null:
			feedback.set_ambience_ducked(true)
		if hud != null:
			hud.set_pause_menu_visible(false)
			hud.set_intro_visible(true)
		_request_hud_and_scoreboard_refresh()
		return
	get_tree().paused = false
	if feedback != null:
		feedback.set_ambience_ducked(false)
	if phase_label == &"intro":
		phase_label = &"play"
	if hud != null:
		hud.set_intro_visible(false)
	_request_hud_and_scoreboard_refresh()

func _set_menu_open(is_open: bool) -> void:
	if intro_open and is_open:
		return
	PerfProbeScript.mark(self, "event.pause_menu", "open=%s" % str(is_open))
	menu_open = is_open
	if menu_open:
		_set_player_persistent_vfx(false, false)
	get_tree().paused = menu_open
	if hud != null:
		hud.set_pause_menu_visible(menu_open, player.mouse_sensitivity if player != null else 0.0)
	if feedback != null:
		feedback.set_ambience_ducked(menu_open)
	if menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_capture_mouse_if_playing()
	_request_hud_and_scoreboard_refresh()

func _return_to_main_menu() -> void:
	PerfProbeScript.mark(self, "event.return_to_main_menu")
	call_deferred("_return_to_main_menu_async")

func _return_to_main_menu_async() -> void:
	if hud != null:
		hud.play_fade_to_black(SCREEN_TRANSITION_SECONDS)
	await get_tree().create_timer(SCREEN_TRANSITION_SECONDS, true, false, true).timeout
	intro_open = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _mark_first_runtime_frame() -> void:
	if not is_inside_tree():
		return
	PerfProbeScript.mark(self, "football.first_frame")

func _maybe_quit_after_perf_duration() -> void:
	FootballPerfScenarioScript.maybe_quit_after_duration(self, PerfProbeScript)

func _update_perf_stability_sampling(delta: float) -> void:
	FootballPerfScenarioScript.update_stability_sampling(self, delta, PerfProbeScript, FootballFieldBuilderScript)

func _build_perf_stability_extra_counts() -> Dictionary:
	return FootballPerfScenarioScript.build_stability_extra_counts(self, FootballFieldBuilderScript)

func _start_perf_scenario() -> void:
	FootballPerfScenarioScript.start(self, PerfProbeScript)

func _update_perf_scenario(delta: float) -> void:
	FootballPerfScenarioScript.update(self, delta, PerfProbeScript, RenderProfileScript)

func _update_kickoff_marker(ball_spawn: Vector3, is_visible: bool) -> void:
	FootballMatchFlowControllerScript.update_kickoff_marker(self, ball_spawn, is_visible)

func _notify_player_touched_ball() -> void:
	FootballMatchFlowControllerScript.notify_player_touched_ball(self)

func _notify_any_ball_touched() -> void:
	FootballMatchFlowControllerScript.notify_any_ball_touched(self)

func _notify_ball_touched_by(team: StringName) -> void:
	FootballMatchFlowControllerScript.notify_ball_touched_by(self, team)

func _record_shot_stat(team: StringName, super_used: bool) -> void:
	FootballMatchResolutionControllerScript.record_shot_stat(self, team, super_used)

func _record_goal_stat(player_scored: bool, goal_value: int) -> void:
	FootballMatchResolutionControllerScript.record_goal_stat(self, player_scored, goal_value)

func _capture_mouse_if_playing(allow_web_capture: bool = false) -> void:
	if DisplayServer.get_name().to_lower().contains("headless"):
		return
	if RenderProfileScript.is_web_platform() and not allow_web_capture:
		return
	if capture_scene_active:
		return
	if intro_open or menu_open or match_over:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_sensitivity_changed(value: float) -> void:
	FootballRenderSettingsControllerScript.on_sensitivity_changed(self, value)

func _cycle_skin_tone(step: int) -> void:
	selected_appearance.skin_tone_id = AvatarCatalogScript.get_next_skin_tone_id(selected_appearance.skin_tone_id, step)
	_apply_selected_player_appearance()

func _cycle_country_kit(step: int) -> void:
	selected_appearance.country_kit_id = AvatarCatalogScript.get_next_country_kit_id(selected_appearance.country_kit_id, step)
	_apply_selected_player_appearance()

func _apply_selected_player_appearance() -> void:
	if player_avatar != null:
		player_avatar.apply_appearance(selected_appearance)
	_request_hud_and_scoreboard_refresh()

func _update_avatar_states(delta: float) -> void:
	if player_avatar != null and player != null:
		var player_flat_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
		var player_flat_speed := player_flat_velocity.length()
		player_avatar.update_visual_movement_facing(player_flat_velocity, player.rotation.y, delta)
		player_avatar.set_move_state(player_flat_speed, player.is_on_floor(), player.velocity.y)
	if bot_avatar != null and bot != null:
		var bot_flat_speed := Vector3(bot.velocity.x, 0.0, bot.velocity.z).length()
		bot_avatar.set_move_state(bot_flat_speed, bot.is_on_floor(), bot.velocity.y)
