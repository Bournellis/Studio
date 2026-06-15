class_name FootballRuntimeSpawner
extends RefCounted

const PlayerControllerScript = preload("res://gameplay/player/fps_player_controller.gd")
const FootballBallScript = preload("res://gameplay/football/football_ball.gd")
const FootballBotScript = preload("res://gameplay/football/football_bot.gd")
const FootballHudScript = preload("res://presentation/hud/football_hud.gd")
const FeedbackControllerScript = preload("res://presentation/feedback/fps_feedback_controller.gd")
const FootballChaseCameraScript = preload("res://presentation/camera/football_chase_camera.gd")
const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")


static func spawn(root: Node, render_profile_script: Object, perf_probe_script: Object) -> void:
	var runtime_root := Node3D.new()
	runtime_root.name = "RuntimeRoot"
	root.add_child(runtime_root)

	var stage_begin: int = perf_probe_script.begin(root, "football.player_controller")
	root.player = PlayerControllerScript.new()
	root.player.name = "Player"
	root.player.position = root.PLAYER_SPAWN
	root.player.rotation.y = 0.0
	root.player.move_speed = 8.8
	root.player.jump_velocity = 6.15
	root.player.air_control = 0.82
	root.player.boost_speed_multiplier = 1.56
	root.player.boost_stamina_deplete_per_second = 39.0
	root.player.boost_stamina_recharge_per_second = 25.0
	root.player.shot_cooldown = 0.2
	root.player.alt_fire_cooldown = 0.88
	runtime_root.add_child(root.player)
	var settings = root._get_game_settings()
	if settings != null:
		root.player.set_mouse_sensitivity(settings.get_mouse_sensitivity())
	root.player.shoot_requested.connect(Callable(root, "_on_player_kick_requested"))
	root.player.charged_shoot_requested.connect(Callable(root, "_on_player_charged_kick_requested"))
	root.player.alt_fire_requested.connect(Callable(root, "_on_player_strong_kick_requested"))
	root.player.arcade_dash_started.connect(func(_direction: Vector3) -> void:
		if root.player_avatar != null:
			root.player_avatar.play_slide()
		if root.chase_camera != null and root.chase_camera.has_method("play_dash_fov_kick"):
			root.chase_camera.play_dash_fov_kick(0.5, 0.22)
	)
	root.player.arcade_flip_started.connect(func(_direction: Vector3) -> void:
		if root.player_avatar != null:
			root.player_avatar.play_flip()
	)
	root.player.damaged.connect(func(_amount: float, _remaining_health: float) -> void:
		if root.player_avatar != null:
			root.player_avatar.play_hit()
	)
	perf_probe_script.end(root, "football.player_controller", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.player_avatar")
	root.player_avatar = PlayerAvatarScript.new()
	root.player_avatar.name = "PlayerAvatar"
	root.player_avatar.local_first_person = false
	root.player_avatar.set_movement_facing_enabled(true)
	root.player.add_child(root.player_avatar)
	root.player_avatar.apply_appearance(root.selected_appearance)
	perf_probe_script.end(root, "football.player_avatar", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.ball")
	root.ball = FootballBallScript.new()
	root.ball.name = "Ball"
	root.ball.position = root.BALL_SPAWN
	runtime_root.add_child(root.ball)
	root.ball.configure(root.BALL_SPAWN)
	root.ball.body_entered.connect(Callable(root, "_on_ball_body_entered"))
	_build_kickoff_marker(root, runtime_root, render_profile_script)
	perf_probe_script.end(root, "football.ball", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.camera")
	var first_person_camera: Camera3D = root.player.get_camera() as Camera3D
	if first_person_camera != null:
		first_person_camera.current = false
	root.chase_camera = FootballChaseCameraScript.new()
	root.chase_camera.name = "FootballChaseCamera"
	runtime_root.add_child(root.chase_camera)
	root.chase_camera.configure(root.player, root.ball)
	perf_probe_script.end(root, "football.camera", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.bot_controller")
	root.bot = FootballBotScript.new()
	root.bot.name = "FootballBot"
	root.bot.position = root.BOT_SPAWN
	root.bot.rotation.y = PI
	runtime_root.add_child(root.bot)
	root.bot.configure(root.ball, Vector3(0.0, 0.0, root.GOAL_LINE_NORTH), Vector3(0.0, 0.0, root.GOAL_LINE_SOUTH), root.FIELD_HALF_WIDTH, root.FIELD_HALF_LENGTH)
	root.bot.set_difficulty(root.bot_difficulty_id)
	root.bot.kick_requested.connect(Callable(root, "_on_bot_kick_requested"))
	root.bot.arcade_dash_started.connect(func(_direction: Vector3) -> void:
		if root.bot_avatar != null:
			root.bot_avatar.play_slide()
	)
	root.bot.arcade_flip_started.connect(func(_direction: Vector3) -> void:
		if root.bot_avatar != null:
			root.bot_avatar.play_flip()
	)
	root.bot.damaged.connect(func(_amount: float, _remaining_health: float) -> void:
		if root.bot_avatar != null:
			root.bot_avatar.play_hit()
	)
	perf_probe_script.end(root, "football.bot_controller", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.bot_avatar")
	root.bot_avatar = PlayerAvatarScript.new()
	root.bot_avatar.name = "BotAvatar"
	root.bot_avatar.set_character_variant(&"female")
	root.bot.add_child(root.bot_avatar)
	root.bot_avatar.apply_appearance(root.bot_appearance)
	root.bot.set_combatant_body_visible(false)
	perf_probe_script.end(root, "football.bot_avatar", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.feedback_audio")
	root.feedback = FeedbackControllerScript.new()
	root.feedback.name = "FeedbackController"
	root.add_child(root.feedback)
	perf_probe_script.end(root, "football.feedback_audio", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.hud")
	root.hud = FootballHudScript.new()
	root.hud.name = "FootballHud"
	root.add_child(root.hud)
	root.hud.sensitivity_changed.connect(Callable(root, "_on_sensitivity_changed"))
	root.hud.quality_changed.connect(Callable(root, "_on_pause_quality_changed"))
	root.hud.start_requested.connect(Callable(root, "_start_match"))
	root.hud.resume_requested.connect(func() -> void:
		root._set_menu_open(false)
	)
	root.hud.restart_requested.connect(Callable(root, "restart_match"))
	root.hud.rematch_requested.connect(Callable(root, "restart_match"))
	root.hud.main_menu_requested.connect(Callable(root, "_return_to_main_menu"))
	root.hud.set_sensitivity_value(root.player.mouse_sensitivity)
	perf_probe_script.end(root, "football.hud", stage_begin)

	stage_begin = perf_probe_script.begin(root, "football.collect_arcade_nodes")
	root._collect_arcade_field_nodes()
	perf_probe_script.end(root, "football.collect_arcade_nodes", stage_begin, "boost=%d jump=%d" % [root.boost_pad_areas.size(), root.jump_pad_areas.size()])
	perf_probe_script.log_material_counts(root, root)


static func _build_kickoff_marker(root: Node, parent: Node3D, render_profile_script: Object) -> void:
	root.kickoff_marker = MeshInstance3D.new()
	root.kickoff_marker.name = "KickoffMarker"
	var marker_mesh := CylinderMesh.new()
	marker_mesh.top_radius = root.KICKOFF_MARKER_RADIUS
	marker_mesh.bottom_radius = root.KICKOFF_MARKER_RADIUS
	marker_mesh.height = 0.035
	marker_mesh.radial_segments = 48
	root.kickoff_marker.mesh = marker_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.86, 1.0, 0.48)
	material.emission_enabled = true
	material.emission = Color(0.15, 0.9, 1.0, 1.0)
	material.emission_energy_multiplier = render_profile_script.adjust_emission_energy(1.65, render_profile_script.ROLE_NEON)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	root.kickoff_marker.material_override = material
	root.kickoff_marker.visible = false
	parent.add_child(root.kickoff_marker)
