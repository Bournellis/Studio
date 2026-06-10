class_name FootballRoot
extends Node3D

const PlayerController = preload("res://gameplay/player/fps_player_controller.gd")
const FootballBallScript = preload("res://gameplay/football/football_ball.gd")
const FootballBotScript = preload("res://gameplay/football/football_bot.gd")
const FootballHudScript = preload("res://presentation/hud/football_hud.gd")
const FeedbackControllerScript = preload("res://presentation/feedback/fps_feedback_controller.gd")
const FootballFieldBuilderScript = preload("res://modes/football/football_field_builder.gd")
const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")

const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const MODE_NAME: String = "Futebol 1x1"
const GOAL_LIMIT: int = 3
const FIELD_WIDTH: float = 32.0
const FIELD_LENGTH: float = 44.0
const FIELD_HALF_WIDTH: float = FIELD_WIDTH * 0.5
const FIELD_HALF_LENGTH: float = FIELD_LENGTH * 0.5
const WALL_HEIGHT: float = 2.4
const WALL_THICKNESS: float = 0.8
const GOAL_HALF_WIDTH: float = 4.1
const GOAL_SIDE_WALL_X: float = GOAL_HALF_WIDTH + 0.62
const GOAL_SIDE_WALL_THICKNESS: float = 0.55
const GOAL_CLOSED_DEPTH: float = 2.9
const GOAL_LINE_NORTH: float = -FIELD_HALF_LENGTH
const GOAL_LINE_SOUTH: float = FIELD_HALF_LENGTH
const PLAYER_SPAWN: Vector3 = Vector3(0.0, 0.05, 14.2)
const BOT_SPAWN: Vector3 = Vector3(0.0, 0.05, -14.2)
const BALL_SPAWN: Vector3 = Vector3(0.0, 0.58, 0.0)
const PLAYER_KICK_REACH: float = 2.25
const PLAYER_TOUCH_RADIUS: float = 1.15
const PLAYER_TOUCH_FORCE: float = 4.8
const PLAYER_KICK_FORCE: float = 15.0
const PLAYER_STRONG_KICK_FORCE: float = 23.0
const PLAYER_KICK_LIFT: float = 1.0
const PLAYER_STRONG_KICK_LIFT: float = 2.35
const PLAYER_TOUCH_COOLDOWN: float = 0.18
const GOAL_RESET_DELAY: float = 1.25

var player
var bot
var ball
var hud
var feedback
var player_score: int = 0
var bot_score: int = 0
var match_over: bool = false
var intro_open: bool = false
var menu_open: bool = false
var phase_label: StringName = &"kickoff"
var goal_reset_timer: float = 0.0
var player_touch_cooldown_remaining: float = 0.0
var last_goal_player_scored: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_world()
	_spawn_runtime()
	_restart_play(false)
	_set_intro_open(true)

func _process(_delta: float) -> void:
	if hud != null:
		hud.update_snapshot(_build_hud_snapshot())

func _physics_process(delta: float) -> void:
	if intro_open or menu_open:
		return
	player_touch_cooldown_remaining = maxf(0.0, player_touch_cooldown_remaining - delta)
	if goal_reset_timer > 0.0:
		goal_reset_timer = maxf(0.0, goal_reset_timer - delta)
		if goal_reset_timer <= 0.0 and not match_over:
			_restart_play(true)
		return
	if match_over:
		return
	_process_player_ball_contact()
	_process_goal_detection()

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

func restart_match() -> void:
	_set_intro_open(false)
	_set_menu_open(false)
	player_score = 0
	bot_score = 0
	match_over = false
	goal_reset_timer = 0.0
	last_goal_player_scored = false
	_restart_play(false)
	if hud != null:
		hud.reset_feedback()
	if feedback != null:
		feedback.clear_effects()
	_capture_mouse_if_playing()

func debug_get_player():
	return player

func debug_get_bot():
	return bot

func debug_get_ball():
	return ball

func debug_get_player_score() -> int:
	return player_score

func debug_get_bot_score() -> int:
	return bot_score

func debug_get_goal_limit() -> int:
	return GOAL_LIMIT

func debug_is_match_over() -> bool:
	return match_over

func debug_is_intro_open() -> bool:
	return intro_open

func debug_start_match() -> void:
	_start_match()

func debug_force_ball_position(next_ball_position: Vector3) -> void:
	if ball == null:
		return
	ball.global_position = next_ball_position
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO

func debug_set_score(next_player_score: int, next_bot_score: int) -> void:
	player_score = maxi(0, next_player_score)
	bot_score = maxi(0, next_bot_score)

func _configure_world() -> void:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.08, 0.12, 1.0)
	env.ambient_light_color = Color(0.84, 0.9, 0.78, 1.0)
	env.ambient_light_energy = 0.94
	environment.environment = env
	add_child(environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "StadiumKeyLight"
	key_light.rotation_degrees = Vector3(-62.0, -30.0, 0.0)
	key_light.light_energy = 2.8
	key_light.shadow_enabled = true
	add_child(key_light)

	var fill_light := OmniLight3D.new()
	fill_light.name = "FestiveFillLight"
	fill_light.position = Vector3(0.0, 7.0, 0.0)
	fill_light.light_color = Color(0.95, 0.82, 0.42, 1.0)
	fill_light.light_energy = 1.3
	fill_light.omni_range = 34.0
	add_child(fill_light)

	_build_football_pitch()

func _build_football_pitch() -> void:
	FootballFieldBuilderScript.build(self, {
		"field_width": FIELD_WIDTH,
		"field_length": FIELD_LENGTH,
		"wall_height": WALL_HEIGHT,
		"wall_thickness": WALL_THICKNESS,
		"goal_half_width": GOAL_HALF_WIDTH,
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
	player.move_speed = 8.4
	player.jump_velocity = 5.8
	player.shot_cooldown = 0.2
	player.alt_fire_cooldown = 0.88
	runtime_root.add_child(player)
	player.shoot_requested.connect(_on_player_kick_requested)
	player.alt_fire_requested.connect(_on_player_strong_kick_requested)

	ball = FootballBallScript.new()
	ball.name = "Ball"
	ball.position = BALL_SPAWN
	runtime_root.add_child(ball)
	ball.configure(BALL_SPAWN)

	bot = FootballBotScript.new()
	bot.name = "FootballBot"
	bot.position = BOT_SPAWN
	bot.rotation.y = PI
	runtime_root.add_child(bot)
	bot.configure(ball, Vector3(0.0, 0.0, GOAL_LINE_NORTH), Vector3(0.0, 0.0, GOAL_LINE_SOUTH))
	bot.kick_requested.connect(_on_bot_kick_requested)

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
	hud.main_menu_requested.connect(_return_to_main_menu)
	hud.set_sensitivity_value(player.mouse_sensitivity)

func _restart_play(after_goal: bool) -> void:
	phase_label = &"kickoff" if not after_goal else &"reset"
	player.global_position = PLAYER_SPAWN
	player.rotation = Vector3.ZERO
	player.configure_for_round()
	player.clear_movement_impulses()
	bot.global_position = BOT_SPAWN
	bot.rotation.y = PI
	bot.configure(ball, Vector3(0.0, 0.0, GOAL_LINE_NORTH), Vector3(0.0, 0.0, GOAL_LINE_SOUTH))
	ball.configure(BALL_SPAWN)
	player_touch_cooldown_remaining = 0.0
	if match_over:
		bot.set_celebrating(true)
	else:
		bot.set_celebrating(false)
	phase_label = &"play"

func _on_player_kick_requested(origin: Vector3, direction: Vector3, _damage: float, _knockback: float) -> void:
	_try_player_kick(origin, direction, PLAYER_KICK_FORCE, PLAYER_KICK_LIFT, false)

func _on_player_strong_kick_requested(origin: Vector3, direction: Vector3, _damage: float, _knockback: float, _speed: float, _radius: float, _overcharged: bool) -> void:
	_try_player_kick(origin, direction, PLAYER_STRONG_KICK_FORCE, PLAYER_STRONG_KICK_LIFT, true)

func _try_player_kick(origin: Vector3, direction: Vector3, force: float, lift: float, strong: bool) -> void:
	if match_over or intro_open or menu_open or goal_reset_timer > 0.0:
		return
	var connected := _can_reach_ball(origin, direction)
	if hud != null:
		hud.show_kick(strong, connected)
	if not connected:
		return
	var kick_direction := _build_kick_direction(origin, direction)
	ball.kick(kick_direction, force, lift)
	if feedback != null:
		feedback.play_football_kick(ball.global_position, kick_direction, strong)

func _on_bot_kick_requested(origin: Vector3, direction: Vector3, force: float, lift: float) -> void:
	if match_over or intro_open or goal_reset_timer > 0.0:
		return
	var to_ball: Vector3 = ball.global_position - origin
	if to_ball.length() > bot.kick_range + 0.55:
		return
	ball.kick(direction, force, lift)
	if feedback != null:
		feedback.play_football_kick(ball.global_position, direction, false)

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
	ball.kick(contact_direction, PLAYER_TOUCH_FORCE, 0.12)
	player_touch_cooldown_remaining = PLAYER_TOUCH_COOLDOWN

func _process_goal_detection() -> void:
	var goal_side := FootballMatchRulesScript.detect_goal(ball.global_position, GOAL_HALF_WIDTH, GOAL_LINE_NORTH, GOAL_LINE_SOUTH)
	if goal_side == 1:
		_register_goal(true)
	elif goal_side == -1:
		_register_goal(false)

func _register_goal(player_scored: bool) -> void:
	last_goal_player_scored = player_scored
	var score_result: Dictionary = FootballMatchRulesScript.apply_goal_score(player_score, bot_score, player_scored, GOAL_LIMIT)
	player_score = int(score_result.get("player_score", player_score))
	bot_score = int(score_result.get("bot_score", bot_score))
	phase_label = &"goal"
	goal_reset_timer = GOAL_RESET_DELAY
	bot.set_celebrating(true)
	if hud != null:
		hud.show_goal(player_scored)
	if feedback != null:
		var goal_z := GOAL_LINE_NORTH if player_scored else GOAL_LINE_SOUTH
		feedback.play_football_goal(Vector3(0.0, 1.0, goal_z), player_scored)
	if bool(score_result.get("match_over", false)):
		match_over = true
		goal_reset_timer = 0.0
		phase_label = &"match_end"
		var player_won := bool(score_result.get("player_won", false))
		if hud != null:
			hud.show_match_end(player_won)
		if feedback != null:
			feedback.play_round_end(player_won)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _can_reach_ball(origin: Vector3, direction: Vector3) -> bool:
	return FootballMatchRulesScript.can_reach_ball(origin, direction, ball.global_position, ball.ball_radius, PLAYER_KICK_REACH)

func _build_kick_direction(origin: Vector3, direction: Vector3) -> Vector3:
	return FootballMatchRulesScript.build_kick_direction(origin, direction, ball.global_position, -player.global_transform.basis.z)

func _build_hud_snapshot() -> Dictionary:
	var ball_distance := 0.0
	if player != null and ball != null:
		ball_distance = Vector3(player.global_position.x, 0.0, player.global_position.z).distance_to(Vector3(ball.global_position.x, 0.0, ball.global_position.z))
	return {
		"status": MODE_NAME,
		"player_score": player_score,
		"bot_score": bot_score,
		"goal_limit": GOAL_LIMIT,
		"ball_distance": ball_distance,
		"bot_state": bot.debug_get_state() if bot != null else "none",
		"phase": phase_label,
		"hint": "Comecar inicia | WASD move | Mouse look | LMB chute | RMB chute forte | Space jump | R restart | Esc menu" if intro_open else "WASD move | Mouse look | LMB chute | RMB chute forte | Space jump | R restart | Esc menu"
	}

func _start_match() -> void:
	_set_intro_open(false)
	if hud != null:
		hud.reset_feedback()
	_capture_mouse_if_playing()

func _set_intro_open(is_open: bool) -> void:
	intro_open = is_open
	if intro_open:
		menu_open = false
		phase_label = &"intro"
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if hud != null:
			hud.set_pause_menu_visible(false, player.mouse_sensitivity)
			hud.set_intro_visible(true)
		return
	get_tree().paused = false
	if phase_label == &"intro":
		phase_label = &"play"
	if hud != null:
		hud.set_intro_visible(false)

func _set_menu_open(is_open: bool) -> void:
	if intro_open and is_open:
		return
	menu_open = is_open
	get_tree().paused = menu_open
	if hud != null:
		hud.set_pause_menu_visible(menu_open, player.mouse_sensitivity)
	if menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_capture_mouse_if_playing()

func _return_to_main_menu() -> void:
	intro_open = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

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
