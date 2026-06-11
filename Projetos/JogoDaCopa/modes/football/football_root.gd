class_name FootballRoot
extends Node3D

const PlayerController = preload("res://gameplay/player/fps_player_controller.gd")
const FootballBallScript = preload("res://gameplay/football/football_ball.gd")
const FootballBotScript = preload("res://gameplay/football/football_bot.gd")
const FootballHudScript = preload("res://presentation/hud/football_hud.gd")
const FeedbackControllerScript = preload("res://presentation/feedback/fps_feedback_controller.gd")
const FootballChaseCameraScript = preload("res://presentation/camera/football_chase_camera.gd")
const FootballFieldBuilderScript = preload("res://modes/football/football_field_builder.gd")
const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")
const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")

const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const MODE_NAME: String = "Copa Arena Futebol"
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
const KICKOFF_COUNTDOWN_DURATION: float = 3.15
const GOAL_SLOWMO_DURATION: float = 0.4
const GOAL_SLOWMO_SCALE: float = 0.38
const MATCH_MODE_GOALS: StringName = &"goals"
const MATCH_MODE_TIMER: StringName = &"timer"
const MATCH_DURATION_SECONDS: float = 180.0
const DOUBLE_GOAL_WINDOW_SECONDS: float = 30.0
const RENDER_GLOW_ENABLED: bool = true
const RENDER_SSAO_ENABLED: bool = true
const RENDER_FOG_ENABLED: bool = true
const RENDER_TOON_ENABLED: bool = false
const BOT_DIFFICULTY_META_KEY: String = "jogodacopa_bot_difficulty"
const MATCH_MODE_META_KEY: String = "jogodacopa_match_mode"
const TOON_RENDER_META_KEY: String = "jogodacopa_toon_render"
const BOT_DIFFICULTY_IDS: Array = [&"easy", &"normal", &"hard"]
const MATCH_MODE_IDS: Array = [&"timer", &"goals"]

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
var toon_render_enabled: bool = RENDER_TOON_ENABLED
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
var goal_slowmo_remaining: float = 0.0
var stadium_scoreboard_score_labels: Dictionary = {}
var stadium_scoreboard_phase_labels: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_main_menu_settings()
	_configure_world()
	_spawn_runtime()
	_restart_play(false)
	_set_intro_open(true)

func _process(_delta: float) -> void:
	if hud != null:
		hud.update_snapshot(_build_hud_snapshot())
	_update_stadium_scoreboards()
	_update_goal_slowmo(_delta)

func _physics_process(delta: float) -> void:
	if intro_open or menu_open:
		return
	_update_player_presentation_fx(delta)
	if kickoff_countdown_remaining > 0.0:
		_update_kickoff_countdown(delta)
		return
	player_touch_cooldown_remaining = maxf(0.0, player_touch_cooldown_remaining - delta)
	arcade_contact_cooldown_remaining = maxf(0.0, arcade_contact_cooldown_remaining - delta)
	ball_contact_audio_cooldown_remaining = maxf(0.0, ball_contact_audio_cooldown_remaining - delta)
	if goal_reset_timer > 0.0:
		goal_reset_timer = maxf(0.0, goal_reset_timer - delta)
		if goal_reset_timer <= 0.0 and not match_over:
			_restart_play(true)
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
	_update_avatar_states()

func _input(event: InputEvent) -> void:
	if intro_open:
		return
	if event.is_action_pressed("ui_back"):
		_set_menu_open(not menu_open)
		get_viewport().set_input_as_handled()
		return
	if menu_open:
		return
	if event is InputEventMouseButton and event.is_pressed() and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		_capture_mouse_if_playing()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart_round"):
		restart_match()
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("arcade_emote"):
		_trigger_arcade_emote(true)
		get_viewport().set_input_as_handled()

func restart_match() -> void:
	_set_intro_open(false)
	_set_menu_open(false)
	player_score = 0
	bot_score = 0
	match_over = false
	goal_reset_timer = 0.0
	last_goal_player_scored = false
	kickoff_owner = &"player"
	match_time_remaining = MATCH_DURATION_SECONDS
	golden_goal_active = false
	last_thirty_announced = false
	last_goal_value = 1
	player_super_meter = 0.0
	bot_super_meter = 0.0
	player_super_used_this_kickoff = false
	bot_super_used_this_kickoff = false
	_reset_arcade_field()
	_restart_play(false)
	if hud != null:
		hud.reset_feedback()
	if feedback != null:
		feedback.clear_effects()
	_capture_mouse_if_playing()

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

func set_match_mode(next_match_mode_id: StringName) -> void:
	match_mode_id = _sanitize_match_mode(next_match_mode_id)
	if match_mode_id == MATCH_MODE_TIMER and match_time_remaining <= 0.0 and not golden_goal_active:
		match_time_remaining = MATCH_DURATION_SECONDS

func set_toon_render_enabled(is_enabled: bool) -> void:
	toon_render_enabled = is_enabled
	_apply_toon_rendering()

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

func debug_is_toon_render_enabled() -> bool:
	return toon_render_enabled

func debug_set_toon_render_enabled(is_enabled: bool) -> void:
	set_toon_render_enabled(is_enabled)

func debug_set_match_mode(next_match_mode_id: StringName) -> void:
	set_match_mode(next_match_mode_id)

func debug_get_match_time_remaining() -> float:
	return match_time_remaining

func debug_set_match_time_remaining(next_time_remaining: float) -> void:
	match_time_remaining = maxf(0.0, next_time_remaining)
	last_thirty_announced = match_time_remaining <= DOUBLE_GOAL_WINDOW_SECONDS

func debug_update_match_clock(delta: float) -> void:
	_update_match_clock(delta)

func debug_is_golden_goal_active() -> bool:
	return golden_goal_active

func debug_get_last_goal_value() -> int:
	return last_goal_value

func debug_is_match_over() -> bool:
	return match_over

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

func debug_trigger_arcade_emote(player_triggered: bool = true) -> void:
	_trigger_arcade_emote(player_triggered)

func debug_get_arena_config() -> Dictionary:
	return {
		"field_width": FIELD_WIDTH,
		"field_length": FIELD_LENGTH,
		"wall_height": WALL_HEIGHT,
		"ceiling_height": CEILING_HEIGHT,
		"goal_half_width": GOAL_HALF_WIDTH,
		"goal_height": GOAL_HEIGHT
	}

func debug_get_stadium_scoreboard_text(side_name: String = "North") -> String:
	var label := _get_stadium_scoreboard_score_label(side_name)
	return label.text if label != null else ""

func _configure_world() -> void:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	environment.environment = _build_night_environment()
	add_child(environment)

	_add_stadium_key_light()
	_build_football_pitch()

func _build_night_environment() -> Environment:
	var env := Environment.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.004, 0.01, 0.04, 1.0)
	sky_material.sky_horizon_color = Color(0.02, 0.065, 0.14, 1.0)
	sky_material.sky_curve = 0.18
	sky_material.sky_energy_multiplier = 0.72
	sky_material.ground_bottom_color = Color(0.012, 0.02, 0.028, 1.0)
	sky_material.ground_horizon_color = Color(0.02, 0.05, 0.08, 1.0)
	sky_material.ground_curve = 0.12
	sky_material.ground_energy_multiplier = 0.36
	sky_material.sun_angle_max = 1.0
	sky_material.sun_curve = 0.04
	sky_material.sky_cover = _build_star_cover_texture()
	sky_material.sky_cover_modulate = Color(1.0, 1.0, 1.0, 0.18)

	var sky := Sky.new()
	sky.sky_material = sky_material

	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = 0.82
	env.background_intensity = 0.72
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.44, 0.58, 0.72, 1.0)
	env.ambient_light_energy = 0.34
	env.ambient_light_sky_contribution = 0.74
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.08
	env.tonemap_white = 1.72

	env.glow_enabled = RENDER_GLOW_ENABLED
	env.set("glow_levels/1", false)
	env.set("glow_levels/2", true)
	env.set("glow_levels/3", true)
	env.set("glow_levels/4", true)
	env.set("glow_levels/5", false)
	env.set("glow_levels/6", false)
	env.set("glow_levels/7", false)
	env.glow_normalized = true
	env.glow_intensity = 0.42
	env.glow_strength = 0.92
	env.glow_bloom = 0.28
	env.glow_hdr_threshold = 0.86
	env.glow_hdr_scale = 1.65
	env.glow_hdr_luminance_cap = 9.0

	env.ssao_enabled = RENDER_SSAO_ENABLED
	env.ssao_radius = 2.6
	env.ssao_intensity = 0.52
	env.ssao_power = 1.22
	env.ssao_detail = 0.38
	env.ssao_sharpness = 0.48
	env.ssao_light_affect = 0.18

	env.fog_enabled = RENDER_FOG_ENABLED
	env.fog_light_color = Color(0.12, 0.22, 0.36, 1.0)
	env.fog_light_energy = 0.28
	env.fog_density = 0.014
	env.fog_aerial_perspective = 0.34
	env.fog_sky_affect = 0.24
	env.fog_depth_begin = 30.0
	env.fog_depth_end = 110.0
	env.fog_depth_curve = 1.1
	return env

func _build_star_cover_texture() -> Texture2D:
	var noise := FastNoiseLite.new()
	noise.seed = 20260610
	noise.frequency = 0.032
	noise.fractal_octaves = 1
	var texture := NoiseTexture2D.new()
	texture.width = 512
	texture.height = 256
	texture.normalize = true
	texture.noise = noise
	return texture

func _add_stadium_key_light() -> void:
	var key_light := DirectionalLight3D.new()
	key_light.name = "StadiumKeyLight"
	key_light.rotation_degrees = Vector3(-56.0, -34.0, 0.0)
	key_light.light_color = Color(0.74, 0.86, 1.0, 1.0)
	key_light.light_energy = 1.85
	key_light.light_indirect_energy = 0.44
	key_light.light_specular = 0.64
	key_light.shadow_enabled = true
	key_light.directional_shadow_max_distance = 88.0
	key_light.directional_shadow_fade_start = 0.74
	key_light.shadow_bias = 0.045
	key_light.shadow_normal_bias = 0.82
	add_child(key_light)

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
	var runtime_root := Node3D.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)

	player = PlayerController.new()
	player.name = "Player"
	player.position = PLAYER_SPAWN
	player.rotation.y = 0.0
	player.move_speed = 8.8
	player.jump_velocity = 6.15
	player.air_control = 0.82
	player.boost_speed_multiplier = 1.56
	player.boost_stamina_deplete_per_second = 39.0
	player.boost_stamina_recharge_per_second = 25.0
	player.shot_cooldown = 0.2
	player.alt_fire_cooldown = 0.88
	runtime_root.add_child(player)
	player.shoot_requested.connect(_on_player_kick_requested)
	player.charged_shoot_requested.connect(_on_player_charged_kick_requested)
	player.alt_fire_requested.connect(_on_player_strong_kick_requested)
	player.arcade_dash_started.connect(func(_direction: Vector3) -> void:
		if player_avatar != null:
			player_avatar.play_slide()
	)
	player.arcade_flip_started.connect(func(_direction: Vector3) -> void:
		if player_avatar != null:
			player_avatar.play_flip()
	)
	player.damaged.connect(func(_amount: float, _remaining_health: float) -> void:
		if player_avatar != null:
			player_avatar.play_hit()
	)

	player_avatar = PlayerAvatarScript.new()
	player_avatar.name = "PlayerAvatar"
	player_avatar.local_first_person = false
	player.add_child(player_avatar)
	player_avatar.apply_appearance(selected_appearance)

	ball = FootballBallScript.new()
	ball.name = "Ball"
	ball.position = BALL_SPAWN
	runtime_root.add_child(ball)
	ball.configure(BALL_SPAWN)
	ball.body_entered.connect(_on_ball_body_entered)
	_build_kickoff_marker(runtime_root)

	var first_person_camera: Camera3D = player.get_camera() as Camera3D
	if first_person_camera != null:
		first_person_camera.current = false
	chase_camera = FootballChaseCameraScript.new()
	chase_camera.name = "FootballChaseCamera"
	runtime_root.add_child(chase_camera)
	chase_camera.configure(player, ball)

	bot = FootballBotScript.new()
	bot.name = "FootballBot"
	bot.position = BOT_SPAWN
	bot.rotation.y = PI
	runtime_root.add_child(bot)
	bot.configure(ball, Vector3(0.0, 0.0, GOAL_LINE_NORTH), Vector3(0.0, 0.0, GOAL_LINE_SOUTH), FIELD_HALF_WIDTH, FIELD_HALF_LENGTH)
	bot.set_difficulty(bot_difficulty_id)
	bot.kick_requested.connect(_on_bot_kick_requested)
	bot.arcade_dash_started.connect(func(_direction: Vector3) -> void:
		if bot_avatar != null:
			bot_avatar.play_slide()
	)
	bot.arcade_flip_started.connect(func(_direction: Vector3) -> void:
		if bot_avatar != null:
			bot_avatar.play_flip()
	)
	bot.damaged.connect(func(_amount: float, _remaining_health: float) -> void:
		if bot_avatar != null:
			bot_avatar.play_hit()
	)

	bot_avatar = PlayerAvatarScript.new()
	bot_avatar.name = "BotAvatar"
	bot_avatar.set_character_variant(&"female")
	bot.add_child(bot_avatar)
	bot_avatar.apply_appearance(bot_appearance)
	bot.set_combatant_body_visible(false)

	feedback = FeedbackControllerScript.new()
	feedback.name = "FeedbackController"
	add_child(feedback)

	hud = FootballHudScript.new()
	hud.name = "FootballHud"
	add_child(hud)
	hud.sensitivity_changed.connect(_on_sensitivity_changed)
	hud.start_requested.connect(_start_match)
	hud.resume_requested.connect(func() -> void:
		_set_menu_open(false)
	)
	hud.rematch_requested.connect(restart_match)
	hud.main_menu_requested.connect(_return_to_main_menu)
	hud.skin_tone_previous_requested.connect(func() -> void:
		_cycle_skin_tone(-1)
	)
	hud.skin_tone_next_requested.connect(func() -> void:
		_cycle_skin_tone(1)
	)
	hud.country_kit_previous_requested.connect(func() -> void:
		_cycle_country_kit(-1)
	)
	hud.country_kit_next_requested.connect(func() -> void:
		_cycle_country_kit(1)
	)
	hud.set_sensitivity_value(player.mouse_sensitivity)
	_update_avatar_selection_labels()
	_collect_arcade_field_nodes()
	_apply_toon_rendering()

func _apply_main_menu_settings() -> void:
	var tree := get_tree()
	if tree == null or tree.root == null:
		return
	if tree.root.has_meta(BOT_DIFFICULTY_META_KEY):
		set_bot_difficulty(StringName(str(tree.root.get_meta(BOT_DIFFICULTY_META_KEY))))
	if tree.root.has_meta(MATCH_MODE_META_KEY):
		set_match_mode(StringName(str(tree.root.get_meta(MATCH_MODE_META_KEY))))
	if tree.root.has_meta(TOON_RENDER_META_KEY):
		set_toon_render_enabled(bool(tree.root.get_meta(TOON_RENDER_META_KEY)))

func _restart_play(after_goal: bool) -> void:
	phase_label = &"kickoff" if not after_goal else &"reset"
	Engine.time_scale = 1.0
	goal_slowmo_remaining = 0.0
	player_super_used_this_kickoff = false
	bot_super_used_this_kickoff = false
	if after_goal:
		_advance_kickoff_owner()
	var ball_spawn := _get_ball_spawn_for_kickoff()
	player.global_position = _get_player_spawn_for_kickoff()
	player.rotation = Vector3.ZERO
	player.configure_for_round()
	player.clear_movement_impulses()
	bot.global_position = _get_bot_spawn_for_kickoff()
	bot.rotation.y = PI
	bot.configure(ball, Vector3(0.0, 0.0, GOAL_LINE_NORTH), Vector3(0.0, 0.0, GOAL_LINE_SOUTH), FIELD_HALF_WIDTH, FIELD_HALF_LENGTH)
	bot.set_difficulty(bot_difficulty_id)
	player_kickoff_waiting_for_touch = kickoff_owner == &"player" and not match_over
	if player_kickoff_waiting_for_touch and bot.has_method("start_kickoff_defense_hold"):
		bot.start_kickoff_defense_hold(_get_player_kickoff_bot_defense_position(ball_spawn))
	ball.teleport_to_spawn(ball_spawn)
	_update_kickoff_marker(ball_spawn, true)
	if chase_camera != null:
		chase_camera.snap_to_target()
	player_touch_cooldown_remaining = 0.0
	arcade_contact_cooldown_remaining = 0.0
	ball_contact_audio_cooldown_remaining = 0.0
	player_ball_control_state = &"free"
	player_ball_control_strength = 0.0
	last_kick_assist_strength = 0.0
	if match_over:
		bot.set_celebrating(true)
	else:
		bot.set_celebrating(false)
	if not intro_open:
		_start_kickoff_countdown()
	else:
		phase_label = &"play"

func _on_player_kick_requested(_origin: Vector3, _direction: Vector3, _damage: float, _knockback: float) -> void:
	_try_player_kick(_get_player_kick_origin(), _get_player_kick_direction(), PLAYER_KICK_FORCE, PLAYER_KICK_LIFT, false)

func _on_player_charged_kick_requested(_origin: Vector3, _direction: Vector3, charge_fraction: float, _held_seconds: float) -> void:
	var clamped_charge := clampf(charge_fraction, 0.0, 1.0)
	var force := PLAYER_KICK_FORCE * lerpf(1.0, CHARGED_KICK_FORCE_MULTIPLIER, clamped_charge)
	var lift := PLAYER_KICK_LIFT + CHARGED_KICK_LIFT_BONUS * clamped_charge
	_try_player_kick(_get_player_kick_origin(), _get_player_kick_direction(), force, lift, false)

func _on_player_strong_kick_requested(_origin: Vector3, _direction: Vector3, _damage: float, _knockback: float, _speed: float, _radius: float, _overcharged: bool) -> void:
	if _can_player_use_super():
		_try_player_kick(_get_player_kick_origin(), _get_player_kick_direction(), SUPER_SHOT_FORCE, SUPER_SHOT_LIFT, true, true)
		return
	_try_player_kick(_get_player_kick_origin(), _get_player_kick_direction(), PLAYER_STRONG_KICK_FORCE, PLAYER_STRONG_KICK_LIFT, true)

func _try_player_kick(origin: Vector3, direction: Vector3, force: float, lift: float, strong: bool, super_shot: bool = false) -> void:
	if match_over or intro_open or menu_open or goal_reset_timer > 0.0 or kickoff_countdown_remaining > 0.0:
		return
	var connected := _can_reach_ball(origin, direction)
	last_kick_assist_strength = _get_kick_assist_strength(origin, direction) if connected else 0.0
	if player_avatar != null:
		player_avatar.play_kick(strong)
	if hud != null:
		hud.show_kick(strong, connected, last_kick_assist_strength)
	if not connected:
		return
	var kick_direction := _build_kick_direction(origin, direction)
	_notify_player_touched_ball()
	ball.kick(kick_direction, force, lift)
	if super_shot:
		player_super_meter = 0.0
		player_super_used_this_kickoff = true
	else:
		_add_player_super(SUPER_TOUCH_GAIN)
	if feedback != null:
		feedback.play_football_kick(ball.global_position, kick_direction, strong)
	if chase_camera != null:
		chase_camera.play_shake(0.2 if super_shot else (0.09 if strong else 0.045), 0.22 if super_shot else (0.18 if strong else 0.1))

func _on_bot_kick_requested(origin: Vector3, direction: Vector3, force: float, lift: float) -> void:
	if match_over or intro_open or goal_reset_timer > 0.0 or kickoff_countdown_remaining > 0.0:
		return
	var to_ball: Vector3 = ball.global_position - origin
	if to_ball.length() > bot.kick_range + 0.55:
		return
	if bot_avatar != null:
		bot_avatar.play_kick(false)
	var applied_force := force
	var applied_lift := lift
	var bot_super := _can_bot_use_super()
	if bot_super:
		bot_super_meter = 0.0
		bot_super_used_this_kickoff = true
		applied_force = SUPER_SHOT_FORCE
		applied_lift = SUPER_SHOT_LIFT
	_notify_any_ball_touched()
	ball.kick(direction, applied_force, applied_lift)
	if not bot_super:
		_add_bot_super(SUPER_TOUCH_GAIN)
	if feedback != null:
		feedback.play_football_kick(ball.global_position, direction, bot_super)
	if chase_camera != null:
		chase_camera.play_shake(0.16 if bot_super else 0.035, 0.2 if bot_super else 0.08)

func _update_player_ball_control(_delta: float) -> void:
	if player == null or ball == null:
		player_ball_control_state = &"free"
		player_ball_control_strength = 0.0
		return
	var state: Dictionary = FootballMatchRulesScript.get_player_possession_state(
		player.global_position,
		_get_player_kick_direction(),
		player.velocity,
		ball.global_position,
		PLAYER_TOUCH_RADIUS,
		PLAYER_NEAR_BALL_RADIUS
	)
	player_ball_control_state = state.get("state", &"free")
	player_ball_control_strength = float(state.get("strength", 0.0))

func _process_player_ball_contact() -> void:
	if player_touch_cooldown_remaining > 0.0:
		return
	var contact: Dictionary = FootballMatchRulesScript.get_player_contact_kick(
		player.global_position,
		player.velocity,
		ball.global_position,
		PLAYER_TOUCH_RADIUS,
		2.0
	)
	if not bool(contact.get("connected", false)):
		return
	var contact_direction: Vector3 = contact.get("direction", Vector3.ZERO)
	var boost_multiplier := 1.35 if player.is_boosting() else 1.0
	var contact_lift := 0.42 if player.is_boosting() else 0.18
	_notify_player_touched_ball()
	ball.kick(contact_direction, PLAYER_TOUCH_FORCE * boost_multiplier, contact_lift)
	_add_player_super(SUPER_TOUCH_GAIN)
	player_touch_cooldown_remaining = PLAYER_TOUCH_COOLDOWN

func _on_ball_body_entered(body: Node) -> void:
	if feedback == null or ball == null or ball_contact_audio_cooldown_remaining > 0.0:
		return
	var ball_speed: float = ball.linear_velocity.length()
	if ball_speed < 2.0:
		return
	var body_name := str(body.name).to_lower()
	if body_name.contains("glass") or body_name.contains("wall") or body_name.contains("goal"):
		feedback.play_ball_glass(ball.global_position)
	else:
		feedback.play_ball_bounce(ball.global_position, ball_speed > 12.0)
	ball_contact_audio_cooldown_remaining = 0.12

func _process_arcade_action_contacts() -> void:
	if arcade_contact_cooldown_remaining > 0.0 or player == null or bot == null or ball == null:
		return
	var handled := false
	if player.has_method("is_arcade_dashing") and player.is_arcade_dashing():
		handled = _process_arcade_dash_contact(player, bot, true) or handled
	if bot.has_method("debug_is_arcade_dashing") and bot.debug_is_arcade_dashing():
		handled = _process_arcade_dash_contact(bot, player, false) or handled
	if handled:
		arcade_contact_cooldown_remaining = ARCADE_CONTACT_COOLDOWN

func _process_arcade_dash_contact(actor: Node3D, target: Node3D, actor_is_player: bool) -> bool:
	var actor_position: Vector3 = actor.global_position
	var target_position: Vector3 = target.global_position
	var dash_direction := _get_arcade_dash_direction(actor, actor_is_player)
	var ball_close := _flat_distance(actor_position, ball.global_position) <= ARCADE_SLIDE_BALL_RADIUS
	var body_close := _flat_distance(actor_position, target_position) <= ARCADE_BODY_CONTACT_RADIUS
	if not ball_close and not body_close:
		return false
	if ball_close:
		if actor_is_player:
			_notify_player_touched_ball()
		else:
			_notify_any_ball_touched()
		ball.kick(dash_direction, ARCADE_SLIDE_BALL_FORCE, ARCADE_SLIDE_BALL_LIFT)
		if actor_is_player:
			_add_player_super(SUPER_TOUCH_GAIN)
		else:
			_add_bot_super(SUPER_TOUCH_GAIN)
		if actor_is_player and player_avatar != null:
			player_avatar.play_slide()
		elif not actor_is_player and bot_avatar != null:
			bot_avatar.play_slide()
		if body_close:
			_apply_arcade_knockback_and_stun(target, dash_direction, ARCADE_SLIDE_KNOCKBACK_FORCE, ARCADE_SLIDE_STUN_DURATION)
		return true
	if body_close:
		if actor_is_player and player_avatar != null and player_avatar.has_method("play_push"):
			player_avatar.play_push()
		elif not actor_is_player and bot_avatar != null and bot_avatar.has_method("play_push"):
			bot_avatar.play_push()
		_apply_arcade_knockback(target, dash_direction, ARCADE_SHOULDER_KNOCKBACK_FORCE)
		_apply_arcade_knockback(actor, -dash_direction, ARCADE_SHOULDER_KNOCKBACK_FORCE * 0.72)
		return true
	return false

func _get_arcade_dash_direction(actor: Node3D, actor_is_player: bool) -> Vector3:
	var direction := Vector3.ZERO
	if actor_is_player and actor.has_method("get_arcade_dash_direction"):
		direction = actor.get_arcade_dash_direction()
	elif not actor_is_player and actor.has_method("debug_get_arcade_dash_direction"):
		direction = actor.debug_get_arcade_dash_direction()
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		direction = -actor.global_transform.basis.z
		direction.y = 0.0
	return direction.normalized() if direction.length_squared() > 0.0001 else Vector3.FORWARD

func _apply_arcade_knockback_and_stun(target: Node, direction: Vector3, force: float, stun_duration: float) -> void:
	_apply_arcade_knockback(target, direction, force)
	if target.has_method("apply_arcade_stun"):
		target.apply_arcade_stun(stun_duration)
	if target == player and player_avatar != null:
		player_avatar.play_hit()
	elif target == bot and bot_avatar != null:
		bot_avatar.play_hit()

func _apply_arcade_knockback(target: Node, direction: Vector3, force: float) -> void:
	if target.has_method("apply_knockback"):
		target.apply_knockback(direction, force, 1.05)

func _collect_arcade_field_nodes() -> void:
	boost_pad_areas.clear()
	for node: Node in get_tree().get_nodes_in_group("football_boost_pad"):
		if node is Area3D:
			var boost_pad := node as Area3D
			boost_pad_areas.append(boost_pad)
			_set_boost_pad_active(boost_pad, true)
			boost_pad.set_meta("respawn_remaining", 0.0)
	jump_pad_areas.clear()
	for node: Node in get_tree().get_nodes_in_group("football_jump_pad"):
		if node is Area3D:
			var jump_pad := node as Area3D
			jump_pad_areas.append(jump_pad)
			jump_pad.set_meta("cooldown_remaining", 0.0)
	if bot != null and bot.has_method("set_boost_pad_targets"):
		var bot_pad_targets: Array[Node3D] = []
		for pad: Area3D in boost_pad_areas:
			bot_pad_targets.append(pad)
		bot.set_boost_pad_targets(bot_pad_targets)

func _reset_arcade_field() -> void:
	for pad: Area3D in boost_pad_areas:
		_set_boost_pad_active(pad, true)
		pad.set_meta("respawn_remaining", 0.0)
	for jump_pad: Area3D in jump_pad_areas:
		jump_pad.set_meta("cooldown_remaining", 0.0)

func _update_arcade_field(delta: float) -> void:
	_update_boost_pads(delta)
	_update_jump_pads(delta)

func _update_boost_pads(delta: float) -> void:
	if boost_pad_areas.is_empty():
		return
	for pad: Area3D in boost_pad_areas:
		if pad == null:
			continue
		if not _is_boost_pad_active(pad):
			var respawn_remaining := maxf(0.0, float(pad.get_meta("respawn_remaining", 0.0)) - delta)
			pad.set_meta("respawn_remaining", respawn_remaining)
			if respawn_remaining <= 0.0:
				_set_boost_pad_active(pad, true)
			continue
		if player != null and _flat_distance(player.global_position, pad.global_position) <= BOOST_PAD_COLLECT_RADIUS:
			_collect_boost_pad(pad, true)
		elif bot != null and _flat_distance(bot.global_position, pad.global_position) <= BOOST_PAD_COLLECT_RADIUS:
			_collect_boost_pad(pad, false)

func _collect_boost_pad(pad: Area3D, collected_by_player: bool) -> void:
	var full_pad := str(pad.get_meta("pad_type", "small")) == "large"
	if collected_by_player and player != null:
		if full_pad and player.has_method("refill_boost_stamina"):
			player.refill_boost_stamina()
		elif player.has_method("add_boost_stamina"):
			player.add_boost_stamina(BOOST_PAD_SMALL_STAMINA)
	elif not collected_by_player and bot != null and bot.has_method("notify_boost_pad_collected"):
		bot.notify_boost_pad_collected(full_pad)
	_set_boost_pad_active(pad, false)
	pad.set_meta("respawn_remaining", BOOST_PAD_RESPAWN_SECONDS)
	if feedback != null:
		feedback.play_pickup(pad.global_position, &"boost")

func _is_boost_pad_active(pad: Area3D) -> bool:
	return bool(pad.get_meta("active", true))

func _set_boost_pad_active(pad: Area3D, is_active: bool) -> void:
	pad.set_meta("active", is_active)
	for child: Node in pad.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = is_active

func _update_jump_pads(delta: float) -> void:
	if jump_pad_areas.is_empty():
		return
	for jump_pad: Area3D in jump_pad_areas:
		if jump_pad == null:
			continue
		var cooldown_remaining := maxf(0.0, float(jump_pad.get_meta("cooldown_remaining", 0.0)) - delta)
		jump_pad.set_meta("cooldown_remaining", cooldown_remaining)
		if cooldown_remaining > 0.0:
			continue
		if player != null and _flat_distance(player.global_position, jump_pad.global_position) <= JUMP_PAD_COLLECT_RADIUS:
			player.apply_jump_pad_launch(JUMP_PAD_LAUNCH_VELOCITY)
			jump_pad.set_meta("cooldown_remaining", JUMP_PAD_COOLDOWN_SECONDS)
			if feedback != null:
				feedback.play_jump_pad(jump_pad.global_position, JUMP_PAD_LAUNCH_VELOCITY)
		elif bot != null and _flat_distance(bot.global_position, jump_pad.global_position) <= JUMP_PAD_COLLECT_RADIUS:
			bot.apply_jump_pad_launch(JUMP_PAD_LAUNCH_VELOCITY)
			jump_pad.set_meta("cooldown_remaining", JUMP_PAD_COOLDOWN_SECONDS)
			if feedback != null:
				feedback.play_jump_pad(jump_pad.global_position, JUMP_PAD_LAUNCH_VELOCITY)

func _process_goal_detection() -> void:
	var goal_side := FootballMatchRulesScript.detect_goal(ball.global_position, GOAL_HALF_WIDTH, GOAL_LINE_NORTH, GOAL_LINE_SOUTH, GOAL_HEIGHT)
	if goal_side == 1:
		_register_goal(true)
	elif goal_side == -1:
		_register_goal(false)

func _register_goal(player_scored: bool) -> void:
	last_goal_player_scored = player_scored
	var score_result: Dictionary = FootballMatchRulesScript.apply_goal_score_for_mode(
		player_score,
		bot_score,
		player_scored,
		GOAL_LIMIT,
		match_mode_id,
		match_time_remaining,
		DOUBLE_GOAL_WINDOW_SECONDS,
		golden_goal_active
	)
	player_score = int(score_result.get("player_score", player_score))
	bot_score = int(score_result.get("bot_score", bot_score))
	last_goal_value = int(score_result.get("goal_value", 1))
	var double_goal := bool(score_result.get("double_goal", false))
	phase_label = &"goal"
	goal_reset_timer = GOAL_RESET_DELAY
	bot.set_celebrating(true)
	if player_scored:
		_add_bot_super(SUPER_GOAL_SUFFERED_GAIN)
	else:
		_add_player_super(SUPER_GOAL_SUFFERED_GAIN)
	if hud != null:
		hud.show_goal(player_scored, last_goal_value, double_goal)
	if player_scored and player_avatar != null:
		player_avatar.play_celebrate()
	elif not player_scored and bot_avatar != null:
		bot_avatar.play_celebrate()
	if feedback != null:
		var goal_z := GOAL_LINE_NORTH if player_scored else GOAL_LINE_SOUTH
		feedback.play_football_goal(Vector3(0.0, 1.0, goal_z), player_scored)
	_trigger_goal_gamefeel()
	if not player_scored:
		_trigger_arcade_emote(false)
	if bool(score_result.get("match_over", false)):
		_finish_match(bool(score_result.get("player_won", false)))

func _add_player_super(amount: float) -> void:
	player_super_meter = clampf(player_super_meter + amount, 0.0, SUPER_METER_MAX)

func _add_bot_super(amount: float) -> void:
	bot_super_meter = clampf(bot_super_meter + amount * _get_bot_super_gain_multiplier(), 0.0, SUPER_METER_MAX)

func _can_player_use_super() -> bool:
	return player_super_meter >= SUPER_METER_MAX and not player_super_used_this_kickoff

func _can_bot_use_super() -> bool:
	return bot_super_meter >= SUPER_METER_MAX and not bot_super_used_this_kickoff

func _get_bot_super_gain_multiplier() -> float:
	return SUPER_BOT_HARD_GAIN_MULTIPLIER if bot_difficulty_id == &"hard" else 1.0

func _update_match_clock(delta: float) -> void:
	if match_mode_id != MATCH_MODE_TIMER or golden_goal_active or match_over:
		return
	var previous_time := match_time_remaining
	match_time_remaining = maxf(0.0, match_time_remaining - delta)
	if previous_time > DOUBLE_GOAL_WINDOW_SECONDS and match_time_remaining <= DOUBLE_GOAL_WINDOW_SECONDS and match_time_remaining > 0.0:
		last_thirty_announced = true
		if hud != null:
			hud.show_announcement("ULTIMO MINUTO!", 0.9, &"last_minute")
	var timer_result: Dictionary = FootballMatchRulesScript.resolve_timer_state(player_score, bot_score, match_time_remaining, match_mode_id, golden_goal_active)
	if bool(timer_result.get("golden_goal_active", false)) and not golden_goal_active:
		golden_goal_active = true
		phase_label = &"golden_goal"
		if hud != null:
			hud.show_announcement("GOLDEN GOAL!", 1.05, &"golden_goal")
		return
	if bool(timer_result.get("match_over", false)):
		_finish_match(bool(timer_result.get("player_won", false)))

func _finish_match(player_won: bool) -> void:
	match_over = true
	goal_reset_timer = 0.0
	phase_label = &"match_end"
	if bot != null:
		bot.set_celebrating(true)
	if player_won and player_avatar != null:
		player_avatar.play_celebrate()
	elif not player_won and bot_avatar != null:
		bot_avatar.play_celebrate()
	if hud != null:
		hud.show_match_end(player_won)
	if feedback != null:
		feedback.play_round_end(player_won)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _trigger_arcade_emote(player_triggered: bool) -> void:
	if goal_reset_timer <= 0.0 and not match_over:
		return
	var actor_position := Vector3.ZERO
	if player_triggered:
		if player_avatar != null:
			player_avatar.play_celebrate()
		actor_position = player.global_position if player != null else Vector3.ZERO
	else:
		if bot_avatar != null:
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
	var ball_distance := 0.0
	var ball_relative := Vector3.ZERO
	var ball_relative_local := Vector3.ZERO
	if player != null and ball != null:
		ball_relative = ball.global_position - player.global_position
		ball_relative_local = player.global_transform.basis.inverse() * ball_relative
		ball_distance = Vector3(player.global_position.x, 0.0, player.global_position.z).distance_to(Vector3(ball.global_position.x, 0.0, ball.global_position.z))
	return {
		"status": MODE_NAME,
		"player_score": player_score,
		"bot_score": bot_score,
		"goal_limit": GOAL_LIMIT,
		"match_mode": match_mode_id,
		"match_time_remaining": match_time_remaining,
		"golden_goal_active": golden_goal_active,
		"ball_distance": ball_distance,
		"ball_relative_x": ball_relative_local.x,
		"ball_relative_z": ball_relative_local.z,
		"player_kit_code": _get_kit_code(selected_appearance.country_kit_id),
		"bot_kit_code": _get_kit_code(bot_appearance.country_kit_id),
		"player_kit_color": AvatarCatalogScript.get_kit_primary_color(selected_appearance.country_kit_id),
		"bot_kit_color": AvatarCatalogScript.get_kit_primary_color(bot_appearance.country_kit_id),
		"ball_control": player_ball_control_state,
		"ball_control_strength": player_ball_control_strength,
		"boost_fraction": player.get_boost_stamina_fraction() if player != null else 0.0,
		"boost_active": player.is_boosting() if player != null else false,
		"dash_cooldown_fraction": player.get_arcade_dash_cooldown_fraction() if player != null and player.has_method("get_arcade_dash_cooldown_fraction") else 0.0,
		"shoot_charge_fraction": player.get_shoot_charge_fraction() if player != null and player.has_method("get_shoot_charge_fraction") else 0.0,
		"player_super_fraction": player_super_meter / SUPER_METER_MAX,
		"bot_state": bot.debug_get_state() if bot != null else "none",
		"bot_difficulty": bot_difficulty_id,
		"kickoff_owner": kickoff_owner,
		"phase": phase_label,
		"countdown": kickoff_countdown_remaining,
		"hint": "Comecar inicia | WASD move | Shift boost | E/Ctrl dash | Mouse gira jogador/camera | LMB segura/carrega | RMB forte/SUPER | Space jump | T emote pos-gol | R restart | Esc menu" if intro_open else "WASD move | Shift boost | E/Ctrl dash | LMB segura/carrega | RMB forte/SUPER | Space jump/flip | T emote pos-gol | paredes/teto rebatem | R restart | Esc menu"
	}

func _advance_kickoff_owner() -> void:
	kickoff_owner = &"bot" if kickoff_owner == &"player" else &"player"

func _get_player_spawn_for_kickoff() -> Vector3:
	if kickoff_owner == &"bot":
		return Vector3(0.0, PLAYER_SPAWN.y, FIELD_HALF_LENGTH - BOT_KICKOFF_PLAYER_SAFE_Z_OFFSET)
	return PLAYER_SPAWN

func _get_bot_spawn_for_kickoff() -> Vector3:
	if kickoff_owner == &"bot":
		return Vector3(0.0, BOT_SPAWN.y, -FIELD_HALF_LENGTH + 9.0)
	return _get_player_kickoff_bot_defense_position(_get_ball_spawn_for_kickoff())

func _get_ball_spawn_for_kickoff() -> Vector3:
	if kickoff_owner == &"bot":
		return Vector3(0.0, BALL_SPAWN.y, -9.0)
	return Vector3(0.0, BALL_SPAWN.y, 9.0)

func _get_player_kickoff_bot_defense_position(ball_spawn: Vector3) -> Vector3:
	var own_goal := Vector3(0.0, BOT_SPAWN.y, GOAL_LINE_NORTH)
	return ball_spawn.lerp(own_goal, PLAYER_KICKOFF_BOT_DEFENSE_RATIO)

func _get_kit_code(country_kit_id: StringName) -> String:
	match country_kit_id:
		&"brazil":
			return "BRA"
		&"argentina":
			return "ARG"
		&"france":
			return "FRA"
		&"japan":
			return "JPN"
		&"portugal":
			return "POR"
		&"germany":
			return "GER"
		_:
			return "KIT"

func _sanitize_bot_difficulty(next_difficulty_id: StringName) -> StringName:
	return next_difficulty_id if BOT_DIFFICULTY_IDS.has(next_difficulty_id) else &"normal"

func _sanitize_match_mode(next_match_mode_id: StringName) -> StringName:
	return next_match_mode_id if MATCH_MODE_IDS.has(next_match_mode_id) else MATCH_MODE_TIMER

func _update_stadium_scoreboards() -> void:
	var player_kit_code := _get_kit_code(selected_appearance.country_kit_id)
	var bot_kit_code := _get_kit_code(bot_appearance.country_kit_id)
	for side_name in ["North", "South"]:
		var score_label := _get_stadium_scoreboard_score_label(side_name)
		if score_label != null:
			score_label.text = "%s %d - %d %s" % [player_kit_code, player_score, bot_score, bot_kit_code]
		var phase_label_node := _get_stadium_scoreboard_phase_label(side_name)
		if phase_label_node != null:
			phase_label_node.text = _get_stadium_scoreboard_phase_text()

func _get_stadium_scoreboard_score_label(side_name: String) -> Label:
	if not stadium_scoreboard_score_labels.has(side_name):
		stadium_scoreboard_score_labels[side_name] = get_node_or_null("WorldCupScoreboard%sViewport/ScoreRoot/ScoreLabel" % side_name)
	return stadium_scoreboard_score_labels.get(side_name) as Label

func _get_stadium_scoreboard_phase_label(side_name: String) -> Label:
	if not stadium_scoreboard_phase_labels.has(side_name):
		stadium_scoreboard_phase_labels[side_name] = get_node_or_null("WorldCupScoreboard%sViewport/ScoreRoot/PhaseLabel" % side_name)
	return stadium_scoreboard_phase_labels.get(side_name) as Label

func _get_stadium_scoreboard_phase_text() -> String:
	if match_over:
		return "FIM DE JOGO"
	if golden_goal_active:
		return "GOLDEN GOAL"
	if phase_label == &"goal":
		return "GOL!"
	if phase_label == &"intro":
		return "FUTEBOL 1x1"
	if phase_label == &"kickoff" or phase_label == &"reset":
		return "SAIDA"
	return "AO VIVO"

func _start_kickoff_countdown() -> void:
	kickoff_countdown_remaining = KICKOFF_COUNTDOWN_DURATION
	countdown_last_number = 0
	phase_label = &"kickoff"
	_set_round_input_locked(true)
	if hud != null:
		hud.show_announcement("SAIDA PLAYER" if kickoff_owner == &"player" else "SAIDA BOT", 0.68, &"kickoff_owner")
		hud.show_countdown("3", 0.45)
	if feedback != null:
		feedback.play_countdown_tick(false)
		feedback.set_ambience_ducked(false)

func _update_kickoff_countdown(delta: float) -> void:
	kickoff_countdown_remaining = maxf(0.0, kickoff_countdown_remaining - delta)
	var next_number := int(ceilf(kickoff_countdown_remaining))
	if next_number > 0 and next_number != countdown_last_number:
		countdown_last_number = next_number
		if hud != null:
			hud.show_countdown(str(next_number), 0.36)
		if feedback != null:
			feedback.play_countdown_tick(false)
	if kickoff_countdown_remaining > 0.0:
		return
	_set_round_input_locked(false)
	phase_label = &"play"
	if hud != null:
		hud.show_countdown("VAI!", 0.48)
	if feedback != null:
		feedback.play_countdown_tick(true)
		feedback.play_referee_whistle(ball.global_position if ball != null else Vector3.ZERO)

func _set_round_input_locked(is_locked: bool) -> void:
	if is_locked:
		_set_player_persistent_vfx(false, false)
	if player != null and player.has_method("set_input_locked"):
		player.set_input_locked(is_locked)
	if bot != null:
		bot.set_physics_process(not is_locked)
	if is_locked:
		if player != null:
			player.clear_movement_impulses()
		if bot != null:
			bot.velocity = Vector3.ZERO
		if ball != null:
			ball.linear_velocity = Vector3.ZERO
			ball.angular_velocity = Vector3.ZERO

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
			hud.set_pause_menu_visible(false, player.mouse_sensitivity)
			hud.set_intro_visible(true)
		return
	get_tree().paused = false
	if feedback != null:
		feedback.set_ambience_ducked(false)
	if phase_label == &"intro":
		phase_label = &"play"
	if hud != null:
		hud.set_intro_visible(false)

func _set_menu_open(is_open: bool) -> void:
	if intro_open and is_open:
		return
	menu_open = is_open
	if menu_open:
		_set_player_persistent_vfx(false, false)
	get_tree().paused = menu_open
	if hud != null:
		hud.set_pause_menu_visible(menu_open, player.mouse_sensitivity)
	if feedback != null:
		feedback.set_ambience_ducked(menu_open)
	if menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_capture_mouse_if_playing()

func _return_to_main_menu() -> void:
	intro_open = false
	get_tree().paused = false
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _build_kickoff_marker(parent: Node3D) -> void:
	kickoff_marker = MeshInstance3D.new()
	kickoff_marker.name = "KickoffMarker"
	var marker_mesh := CylinderMesh.new()
	marker_mesh.top_radius = KICKOFF_MARKER_RADIUS
	marker_mesh.bottom_radius = KICKOFF_MARKER_RADIUS
	marker_mesh.height = 0.035
	marker_mesh.radial_segments = 48
	kickoff_marker.mesh = marker_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.86, 1.0, 0.48)
	material.emission_enabled = true
	material.emission = Color(0.15, 0.9, 1.0, 1.0)
	material.emission_energy_multiplier = 1.65
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	kickoff_marker.material_override = material
	kickoff_marker.visible = false
	parent.add_child(kickoff_marker)

func _update_kickoff_marker(ball_spawn: Vector3, is_visible: bool) -> void:
	if kickoff_marker == null:
		return
	kickoff_marker.global_position = Vector3(ball_spawn.x, 0.045, ball_spawn.z)
	kickoff_marker.visible = is_visible

func _notify_player_touched_ball() -> void:
	if player_kickoff_waiting_for_touch:
		player_kickoff_waiting_for_touch = false
		if bot != null and bot.has_method("release_kickoff_defense_hold"):
			bot.release_kickoff_defense_hold()
	_notify_any_ball_touched()

func _notify_any_ball_touched() -> void:
	if kickoff_marker != null:
		kickoff_marker.visible = false

func _capture_mouse_if_playing() -> void:
	if DisplayServer.get_name().to_lower().contains("headless"):
		return
	if intro_open or menu_open or match_over:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_sensitivity_changed(value: float) -> void:
	if player != null:
		player.set_mouse_sensitivity(value)
	if hud != null:
		hud.set_sensitivity_value(player.mouse_sensitivity)

func _cycle_skin_tone(step: int) -> void:
	selected_appearance.skin_tone_id = AvatarCatalogScript.get_next_skin_tone_id(selected_appearance.skin_tone_id, step)
	_apply_selected_player_appearance()

func _cycle_country_kit(step: int) -> void:
	selected_appearance.country_kit_id = AvatarCatalogScript.get_next_country_kit_id(selected_appearance.country_kit_id, step)
	_apply_selected_player_appearance()

func _apply_selected_player_appearance() -> void:
	if player_avatar != null:
		player_avatar.apply_appearance(selected_appearance)
	_update_avatar_selection_labels()

func _apply_toon_rendering() -> void:
	if player_avatar != null and player_avatar.has_method("set_toon_render_enabled"):
		player_avatar.set_toon_render_enabled(toon_render_enabled)
	if bot_avatar != null and bot_avatar.has_method("set_toon_render_enabled"):
		bot_avatar.set_toon_render_enabled(toon_render_enabled)
	if ball != null and ball.has_method("set_toon_render_enabled"):
		ball.set_toon_render_enabled(toon_render_enabled)

func _update_avatar_selection_labels() -> void:
	if hud == null:
		return
	hud.set_avatar_selection_labels(
		AvatarCatalogScript.get_skin_label(selected_appearance.skin_tone_id),
		AvatarCatalogScript.get_country_kit_label(selected_appearance.country_kit_id)
	)

func _update_avatar_states() -> void:
	if player_avatar != null and player != null:
		var player_flat_speed := Vector3(player.velocity.x, 0.0, player.velocity.z).length()
		player_avatar.set_move_state(player_flat_speed, player.is_on_floor(), player.velocity.y)
	if bot_avatar != null and bot != null:
		var bot_flat_speed := Vector3(bot.velocity.x, 0.0, bot.velocity.z).length()
		bot_avatar.set_move_state(bot_flat_speed, bot.is_on_floor(), bot.velocity.y)

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
