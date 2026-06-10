extends "res://addons/gut/test.gd"

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const FootballChaseCameraScript = preload("res://presentation/camera/football_chase_camera.gd")
const FootballBallScript = preload("res://gameplay/football/football_ball.gd")
const FootballBotScript = preload("res://gameplay/football/football_bot.gd")
const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const BOT_DIFFICULTY_META_KEY: String = "jogodacopa_bot_difficulty"
const MATCH_MODE_META_KEY: String = "jogodacopa_match_mode"
const TOON_RENDER_META_KEY: String = "jogodacopa_toon_render"

const EXPECTED_ACTIONS: PackedStringArray = [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"jump",
	"boost",
	"arcade_dash",
	"arcade_emote",
	"shoot",
	"alt_fire",
	"restart_round",
	"ui_back"
]

func before_all() -> void:
	var result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func after_each() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if get_tree().root.has_meta(BOT_DIFFICULTY_META_KEY):
		get_tree().root.remove_meta(BOT_DIFFICULTY_META_KEY)
	if get_tree().root.has_meta(MATCH_MODE_META_KEY):
		get_tree().root.remove_meta(MATCH_MODE_META_KEY)
	if get_tree().root.has_meta(TOON_RENDER_META_KEY):
		get_tree().root.remove_meta(TOON_RENDER_META_KEY)
	for action_name: String in EXPECTED_ACTIONS:
		Input.action_release(action_name)

func test_input_actions_are_bootstrapped() -> void:
	for action_name: String in EXPECTED_ACTIONS:
		assert_true(InputMap.has_action(action_name), "Missing input action %s" % action_name)
		assert_gt(InputMap.action_get_events(action_name).size(), 0, "Input action %s has no binding" % action_name)

func test_main_menu_scene_boots_with_football_button_only() -> void:
	var menu_scene := load("res://modes/menu/main_menu.tscn") as PackedScene
	assert_not_null(menu_scene)
	var menu := menu_scene.instantiate()
	add_child_autofree(menu)
	await get_tree().process_frame

	assert_eq(menu.debug_get_mode_path(&"football"), "res://modes/football/football.tscn")
	assert_eq(menu.debug_get_mode_path(&"arena"), "")
	assert_true(menu.debug_has_arena_preview())
	assert_eq(menu.debug_get_selected_kit_id(), &"brazil")
	assert_eq(menu.debug_get_selected_bot_difficulty_id(), &"normal")
	assert_eq(menu.debug_get_selected_match_mode_id(), &"timer")
	assert_false(menu.debug_is_toon_render_enabled())
	menu.debug_cycle_bot_difficulty(1)
	assert_eq(menu.debug_get_selected_bot_difficulty_id(), &"hard")
	menu.debug_cycle_match_mode(1)
	assert_eq(menu.debug_get_selected_match_mode_id(), &"goals")
	assert_eq(menu.debug_get_quality_text(), "Alta")
	assert_not_null(menu.get_node_or_null("ArenaPreviewViewport"))
	assert_not_null(menu.get_node_or_null("ArenaPreview"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/FootballButton"))
	assert_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/ArenaButton"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/SkinPreviewRow"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/KitPreviewRow"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/BotDifficultyRow"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/MatchModeRow"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/VolumeRow/VolumeSlider"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/QualityRow/QualityOption"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/ToonRenderRow/ToonRenderToggle"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/QuitButton"))
	var menu_panel := menu.get_node("MenuCenter/MenuPanel") as PanelContainer
	assert_eq(menu_panel.custom_minimum_size, Vector2(560.0, 640.0))
	assert_no_new_orphans()

func test_football_scene_boots_with_player_bot_ball_goals_and_hud() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	assert_not_null(football_scene)
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	assert_not_null(football.get_node_or_null("WorldEnvironment"))
	var world_environment := football.get_node("WorldEnvironment") as WorldEnvironment
	var environment := world_environment.environment
	assert_not_null(environment)
	assert_eq(environment.background_mode, Environment.BG_SKY)
	assert_not_null(environment.sky)
	assert_eq(environment.tonemap_mode, Environment.TONE_MAPPER_ACES)
	assert_true(environment.glow_enabled)
	assert_true(environment.ssao_enabled)
	assert_true(environment.fog_enabled)
	assert_lt(environment.ambient_light_energy, 0.5)
	var key_light := football.get_node("StadiumKeyLight") as DirectionalLight3D
	assert_not_null(key_light)
	assert_true(key_light.shadow_enabled)
	assert_gt(key_light.directional_shadow_max_distance, 70.0)
	assert_not_null(football.get_node_or_null("FootballPitch"))
	assert_null(football.get_node_or_null("PitchGrassStripe0"))
	assert_null(football.get_node_or_null("CenterLine"))
	var pitch_mesh := football.get_node("FootballPitch/FootballPitchMesh") as MeshInstance3D
	assert_true(pitch_mesh.material_override is ShaderMaterial)
	assert_not_null(football.get_node_or_null("NorthGoalSideWallL"))
	assert_not_null(football.get_node_or_null("SouthGoalSideWallR"))
	assert_not_null(football.get_node_or_null("WestGlassWall"))
	assert_not_null(football.get_node_or_null("EastGlassWall"))
	assert_not_null(football.get_node_or_null("ArenaGlassCeiling"))
	assert_not_null(football.get_node_or_null("NorthBackGlass"))
	assert_not_null(football.get_node_or_null("SouthBackGlass"))
	assert_not_null(football.get_node_or_null("NorthGoalRoofGlass"))
	assert_not_null(football.get_node_or_null("SouthGoalRoofGlass"))
	assert_not_null(football.get_node_or_null("NorthGoalRoofFrontFrame"))
	assert_not_null(football.get_node_or_null("SouthGoalRoofBackFrame"))
	assert_true((football.get_node("NorthNetTint") as MeshInstance3D).material_override is ShaderMaterial)
	assert_not_null(football.get_node_or_null("WestGlassFramePost0"))
	assert_not_null(football.get_node_or_null("EastGlassFramePost0"))
	assert_not_null(football.get_node_or_null("ArenaRoofFrameNorth"))
	assert_not_null(football.get_node_or_null("ArenaRoofRib0"))
	assert_not_null(football.get_node_or_null("NorthStandTier0"))
	assert_not_null(football.get_node_or_null("SouthStandTier2"))
	assert_not_null(football.get_node_or_null("WestStandTier0"))
	assert_not_null(football.get_node_or_null("EastStandTier1"))
	assert_true((football.get_node("NorthCrowdBand0") as MeshInstance3D).material_override is ShaderMaterial)
	assert_not_null(football.get_node_or_null("NorthCountryBanner0"))
	assert_not_null(football.get_node_or_null("NorthCountryBanner0Label"))
	assert_false((football.get_node("NorthCountryBanner0Label") as Label3D).text.is_empty())
	assert_not_null(football.get_node_or_null("SouthCountryBanner7Stripe2"))
	assert_not_null(football.get_node_or_null("WorldCupScoreboardNorth"))
	assert_not_null(football.get_node_or_null("WorldCupScoreboardNorthViewport"))
	assert_not_null(football.get_node_or_null("WorldCupScoreboardNorthLiveDisplay"))
	assert_not_null(football.get_node_or_null("StadiumLightNW"))
	assert_true(football.get_node("StadiumLightNW") is SpotLight3D)
	var stadium_spot := football.get_node("StadiumLightNW") as SpotLight3D
	assert_false(stadium_spot.shadow_enabled)
	assert_gt(stadium_spot.spot_range, 45.0)
	assert_eq(football.debug_get_boost_pad_count(), 8)
	assert_eq(football.debug_get_jump_pad_count(), 2)
	assert_not_null(football.get_node_or_null("BoostPadSmall0"))
	assert_not_null(football.get_node_or_null("BoostPadLarge1"))
	assert_not_null(football.get_node_or_null("JumpPadNorth"))
	assert_not_null(football.get_node_or_null("WestWallRamp"))
	assert_not_null(football.get_node_or_null("CornerRampEN"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/Player/PlayerAvatar"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/FootballChaseCamera"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/FootballBot"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/FootballBot/BotAvatar"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/Ball"))
	assert_not_null(football.get_node_or_null("FootballHud"))
	assert_not_null(football.get_node_or_null("FeedbackController"))
	assert_eq(football.debug_get_goal_limit(), 3)
	assert_eq(football.debug_get_match_mode(), &"timer")
	assert_false(football.debug_is_toon_render_enabled())
	assert_almost_eq(football.debug_get_match_time_remaining(), 180.0, 0.01)
	assert_eq(football.debug_get_player_score(), 0)
	assert_eq(football.debug_get_bot_score(), 0)
	assert_eq(football.debug_get_stadium_scoreboard_text("North"), "BRA 0 - 0 FRA")
	football.debug_cycle_country_kit(1)
	football.debug_set_score(2, 1)
	football._process(0.0)
	assert_eq(football.debug_get_stadium_scoreboard_text("North"), "ARG 2 - 1 FRA")
	football.debug_set_score(0, 0)
	football.debug_cycle_country_kit(-1)
	football._process(0.0)
	assert_true(football.debug_get_ball().get_script() == FootballBallScript)
	assert_not_null(load("res://assets/football/football_ball_panels.gdshader"))
	assert_true(football.debug_get_ball().debug_has_panel_asset_material())
	assert_true(football.debug_get_ball().debug_has_speed_trail())
	assert_true(football.debug_get_ball().debug_has_fireball_particles())
	assert_false(football.debug_get_ball().debug_is_toon_render_enabled())
	assert_false(football.debug_get_ball().debug_has_toon_outline())
	assert_true(football.debug_get_bot().get_script() == FootballBotScript)
	assert_true(football.debug_get_player_avatar().get_script() == PlayerAvatarScript)
	assert_true(football.debug_get_bot_avatar().get_script() == PlayerAvatarScript)
	assert_null(football.debug_get_player_avatar().get_node_or_null("AvatarParts/CopaAssetSkeleton"))
	assert_null(football.debug_get_player_avatar().get_node_or_null("AvatarParts/AssetAnimationTree"))
	assert_true(football.debug_get_player_avatar().debug_has_persistent_vfx())
	assert_false(football.debug_get_player_avatar().debug_is_toon_render_enabled())
	assert_eq(football.debug_get_player_avatar().debug_get_toon_outline_count(), 0)
	assert_true(football.debug_get_chase_camera().get_script() == FootballChaseCameraScript)
	assert_true(football.debug_get_chase_camera().debug_get_camera().current)
	assert_false(football.debug_get_player().get_camera().current)
	assert_false(football.debug_get_player_avatar().local_first_person)
	assert_eq(football.debug_get_player_avatar().debug_get_country_kit_id(), &"brazil")
	assert_eq(football.debug_get_bot_avatar().debug_get_country_kit_id(), &"france")
	assert_true(football.debug_is_intro_open())
	assert_true(get_tree().paused)
	var football_hud = football.get_node("FootballHud")
	assert_true(football_hud.intro_panel.visible)
	assert_true(football_hud.debug_has_broadcast_scoreboard())
	assert_not_null(football_hud.get_node_or_null("HudRoot/IntroCenter/IntroPanel"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/ControlLabel"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/BoostBar"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/BroadcastScoreRow/PlayerKitSwatch"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/BallOffscreenIndicator"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ResultCenter/ResultPanel"))
	football.debug_force_ball_position(Vector3(20.0, 0.68, -18.0))
	football_hud.update_snapshot(football.debug_build_hud_snapshot())
	assert_true(football_hud.debug_is_ball_indicator_visible())
	football.debug_force_ball_position(Vector3(0.0, 0.68, 0.0))
	var arena_config: Dictionary = football.debug_get_arena_config()
	assert_gt(float(arena_config.get("field_width", 0.0)), 32.0)
	assert_gt(float(arena_config.get("wall_height", 0.0)), 6.0)
	assert_almost_eq(float(arena_config.get("goal_half_width", 0.0)), 4.32, 0.01)
	assert_almost_eq(float(arena_config.get("goal_height", 0.0)), 3.45, 0.01)
	var north_post_collision := football.get_node("NorthGoalPostL/NorthGoalPostLCollision") as CollisionShape3D
	var north_post_shape := north_post_collision.shape as BoxShape3D
	assert_almost_eq(north_post_shape.size.y, 3.45, 0.01)
	var north_roof_collision := football.get_node("NorthGoalRoofGlass/NorthGoalRoofGlassCollision") as CollisionShape3D
	var north_roof_shape := north_roof_collision.shape as BoxShape3D
	assert_gt(north_roof_shape.size.x, 10.0)
	assert_gt(north_roof_shape.size.z, 3.6)
	assert_gt(north_roof_shape.size.y, 0.3)
	var frame_mesh := football.get_node("WestGlassFrameTop") as MeshInstance3D
	var frame_material := frame_mesh.material_override as StandardMaterial3D
	assert_not_null(frame_material)
	if frame_material != null:
		assert_true(frame_material.emission_enabled)
		assert_gt(frame_material.emission_energy_multiplier, 1.5)
	var glass_mesh := football.get_node("WestGlassWall/WestGlassWallMesh") as MeshInstance3D
	var glass_material := glass_mesh.material_override as StandardMaterial3D
	assert_not_null(glass_material)
	if glass_material != null:
		assert_true(glass_material.rim_enabled)
		assert_true(glass_material.clearcoat_enabled)
		assert_gt(glass_material.emission_energy_multiplier, 0.5)
	assert_gt(football.debug_get_ball().physics_material_override.bounce, 0.8)
	assert_gt(football.debug_get_ball().physics_material_override.friction, 0.3)
	assert_no_new_orphans()

func test_football_ball_indicator_uses_player_local_basis() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var player = football.debug_get_player()
	var hud = football.get_node("FootballHud")
	player.global_position = Vector3.ZERO
	player.rotation.y = PI * 0.5
	await get_tree().process_frame

	var forward: Vector3 = -player.global_transform.basis.z
	football.debug_force_ball_position(player.global_position + forward * 24.0 + Vector3.UP * 0.63)
	hud.update_snapshot(football.debug_build_hud_snapshot())
	assert_true(hud.debug_get_ball_indicator_text().contains("FRENTE"))

	var right: Vector3 = player.global_transform.basis.x
	football.debug_force_ball_position(player.global_position + right * 24.0 + Vector3.UP * 0.63)
	hud.update_snapshot(football.debug_build_hud_snapshot())
	assert_true(hud.debug_get_ball_indicator_text().contains("D"))
	assert_no_new_orphans()

func test_football_chase_camera_keeps_ball_focus_subtle_when_far() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var chase_camera = football.debug_get_chase_camera()
	player.global_position = Vector3.ZERO
	player.rotation = Vector3.ZERO
	football.debug_force_ball_position(Vector3(0.0, 0.58, -1.0))
	chase_camera.snap_to_target()
	var close_weight: float = chase_camera.debug_get_ball_focus_weight()
	football.debug_force_ball_position(Vector3(0.0, 0.58, -16.0))
	chase_camera.snap_to_target()
	var far_weight: float = chase_camera.debug_get_ball_focus_weight()

	assert_gt(far_weight, close_weight)
	assert_true(far_weight <= 0.11)
	assert_no_new_orphans()

func test_football_intro_cycles_avatar_skin_and_country_kit() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var avatar = football.debug_get_player_avatar()
	var hud = football.get_node("FootballHud")
	assert_eq(football.debug_get_selected_skin_tone_id(), &"tan")
	assert_eq(football.debug_get_selected_country_kit_id(), &"brazil")
	assert_eq(avatar.debug_get_part_albedo_color(&"torso"), AvatarCatalogScript.get_kit_primary_color(&"brazil"))

	football.debug_cycle_skin_tone(1)
	football.debug_cycle_country_kit(1)

	assert_eq(football.debug_get_selected_skin_tone_id(), &"brown")
	assert_eq(football.debug_get_selected_country_kit_id(), &"argentina")
	assert_eq(avatar.debug_get_skin_tone_id(), &"brown")
	assert_eq(avatar.debug_get_country_kit_id(), &"argentina")
	assert_true(hud.skin_tone_label.text.contains("Pele morena"))
	assert_true(hud.country_kit_label.text.contains("Argentina"))
	assert_no_new_orphans()

func test_football_player_near_ball_stays_loose_without_dribble_lock() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	player.global_position = Vector3(0.0, 0.05, 4.0)
	player.rotation = Vector3.ZERO
	player.velocity = Vector3(0.0, 0.0, -6.0)
	football.debug_force_ball_position(player.global_position + Vector3(0.0, 0.53, -1.0))
	var before_kicks: int = ball.debug_get_kick_count()
	var before_dribbles: int = ball.debug_get_dribble_control_count()

	football.debug_update_player_ball_control(0.1)

	assert_eq(ball.debug_get_kick_count(), before_kicks)
	assert_eq(ball.debug_get_dribble_control_count(), before_dribbles)
	assert_eq(football.debug_get_player_ball_control_state(), &"contact")
	assert_almost_eq(ball.linear_velocity.length(), 0.0, 0.001)
	assert_no_new_orphans()

func test_football_ball_ground_grip_slows_roll_without_air_drag() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var ball = football.debug_get_ball()
	ball.global_position = Vector3(0.0, 0.58, 0.0)
	ball.linear_velocity = Vector3(12.0, 0.1, 0.0)
	assert_true(ball.debug_is_ground_rolling())
	ball.debug_apply_ground_roll_drag(0.25)
	var ground_speed := Vector2(ball.linear_velocity.x, ball.linear_velocity.z).length()
	assert_lt(ground_speed, 9.0)

	ball.global_position = Vector3(0.0, 2.4, 0.0)
	ball.linear_velocity = Vector3(12.0, 0.1, 0.0)
	assert_false(ball.debug_is_ground_rolling())
	ball.debug_apply_ground_roll_drag(0.25)
	var air_speed := Vector2(ball.linear_velocity.x, ball.linear_velocity.z).length()
	assert_almost_eq(air_speed, 12.0, 0.001)
	assert_no_new_orphans()

func test_football_player_boost_spends_stamina() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var before_stamina: float = player.debug_get_boost_stamina()
	Input.action_press("move_forward")
	Input.action_press("boost")
	await get_tree().physics_frame
	Input.action_release("move_forward")
	Input.action_release("boost")

	assert_lt(player.debug_get_boost_stamina(), before_stamina)
	assert_lt(football.debug_get_player_boost_fraction(), 1.0)
	assert_no_new_orphans()

func test_football_kickoff_countdown_locks_ball_interaction() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match_with_countdown()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	var before_kicks: int = ball.debug_get_kick_count()
	football._on_player_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0)

	assert_true(football.debug_is_kickoff_locked())
	assert_eq(ball.debug_get_kick_count(), before_kicks)
	football.debug_finish_kickoff_countdown()
	football._on_player_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks + 1)
	assert_no_new_orphans()

func test_football_player_kick_assist_connects_near_front_side_ball() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	player.global_position = Vector3.ZERO
	player.rotation = Vector3.ZERO
	var origin: Vector3 = football.debug_get_player_kick_origin()
	var direction: Vector3 = football.debug_get_player_kick_direction()
	football.debug_force_ball_position(origin + direction * 2.05 + Vector3.RIGHT * 1.05 + Vector3.DOWN * 0.34)

	var before_kicks: int = ball.debug_get_kick_count()
	football._on_player_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 99.0, 99.0)

	assert_eq(ball.debug_get_kick_count(), before_kicks + 1)
	assert_almost_eq(ball.debug_get_last_kick_force(), 20.5, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 2.35, 0.01)
	assert_gt(ball.linear_velocity.y, 2.0)
	assert_gt(football.debug_get_last_kick_assist_strength(), 0.0)
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"kick")
	assert_no_new_orphans()

func test_football_charged_kick_preserves_tap_and_scales_hold() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var ball = football.debug_get_ball()
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_charged_kick_requested(Vector3.ZERO, Vector3.FORWARD, 0.0, 0.1)

	assert_almost_eq(ball.debug_get_last_kick_force(), 20.5, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 2.35, 0.01)

	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_charged_kick_requested(Vector3.ZERO, Vector3.FORWARD, 1.0, 0.8)

	assert_almost_eq(ball.debug_get_last_kick_force(), 31.775, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 3.45, 0.01)
	assert_no_new_orphans()

func test_football_strong_kick_uses_stronger_force() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	var hud = football.get_node("FootballHud")
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_strong_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_almost_eq(ball.debug_get_last_kick_force(), 29.0, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 7.2, 0.01)
	assert_gt(ball.linear_velocity.y, 6.5)
	assert_eq(hud.last_event, &"strong_kick")
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"strong_kick")
	assert_gt(ball.linear_velocity.length(), 0.1)
	assert_no_new_orphans()

func test_football_super_shot_is_once_per_kickoff() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	football.debug_set_player_super_meter(100.0)
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_strong_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_almost_eq(ball.debug_get_last_kick_force(), 38.5, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 9.4, 0.01)
	assert_almost_eq(football.debug_get_player_super_meter(), 0.0, 0.01)
	assert_true(football.debug_player_super_used_this_kickoff())

	football.debug_set_player_super_meter(100.0)
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_strong_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_almost_eq(ball.debug_get_last_kick_force(), 29.0, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 7.2, 0.01)
	assert_no_new_orphans()

func test_football_ball_fireball_uses_speed_hysteresis() -> void:
	var ball = FootballBallScript.new()
	add_child_autofree(ball)
	await get_tree().process_frame

	ball.linear_velocity = Vector3(25.0, 0.0, 0.0)
	ball.debug_update_visual_asset(0.1)
	assert_true(ball.debug_is_fireball_active())

	ball.linear_velocity = Vector3(22.0, 0.0, 0.0)
	ball.debug_update_visual_asset(0.1)
	assert_true(ball.debug_is_fireball_active())

	ball.linear_velocity = Vector3(20.0, 0.0, 0.0)
	ball.debug_update_visual_asset(0.1)
	assert_false(ball.debug_is_fireball_active())
	assert_no_new_orphans()

func test_football_boost_pads_respawn_and_restore_stamina() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	var small_pad := football.get_node("BoostPadSmall0") as Area3D
	var large_pad := football.get_node("BoostPadLarge0") as Area3D
	bot.global_position = Vector3(0.0, 0.05, 16.0)

	player.debug_set_boost_stamina(40.0)
	player.global_position = small_pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.1)

	assert_almost_eq(player.debug_get_boost_stamina(), 65.0, 0.01)
	assert_false(bool(small_pad.get_meta("active", true)))
	football.debug_update_arcade_field(3.8)
	assert_false(bool(small_pad.get_meta("active", true)))
	football.debug_update_arcade_field(0.3)
	assert_true(bool(small_pad.get_meta("active", false)))

	player.debug_set_boost_stamina(12.0)
	player.global_position = large_pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.1)

	assert_almost_eq(player.debug_get_boost_stamina(), 100.0, 0.01)
	assert_false(bool(large_pad.get_meta("active", true)))
	assert_no_new_orphans()

func test_football_bot_collects_route_boost_pad() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	var player = football.debug_get_player()
	var pad := football.get_node("BoostPadSmall1") as Area3D
	player.global_position = Vector3(-14.0, 0.05, 16.0)
	bot.global_position = pad.global_position + Vector3(0.0, 0.0, -4.0)
	football.debug_force_ball_position(pad.global_position + Vector3(0.0, 0.6, 4.5))
	bot._physics_process(0.1)

	assert_eq(bot.debug_get_last_approach_label(), &"boost_pad")
	bot.global_position = pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.1)

	assert_eq(bot.debug_get_boost_pad_collect_count(), 1)
	assert_false(bool(pad.get_meta("active", true)))
	assert_no_new_orphans()

func test_football_jump_pad_launches_characters_not_ball() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	var jump_pad := football.get_node("JumpPadNorth") as Area3D
	football.debug_force_ball_position(jump_pad.global_position + Vector3(0.0, 0.58, 0.0))
	var before_kicks: int = ball.debug_get_kick_count()
	var before_player_launches: int = player.debug_get_jump_pad_launch_count()

	player.global_position = jump_pad.global_position + Vector3.UP * 0.05
	bot.global_position = Vector3(12.0, 0.05, 12.0)
	football.debug_update_arcade_field(0.1)

	assert_eq(player.debug_get_jump_pad_launch_count(), before_player_launches + 1)
	assert_gt(player.debug_get_vertical_velocity(), 8.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks)
	assert_almost_eq(ball.linear_velocity.length(), 0.0, 0.001)

	player.global_position = Vector3(-12.0, 0.05, 12.0)
	bot.global_position = jump_pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.8)
	football.debug_update_arcade_field(0.1)

	assert_gt(bot.debug_get_vertical_velocity(), 8.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks)
	assert_no_new_orphans()

func test_football_bot_approaches_behind_ball_before_attacking() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	football.debug_force_ball_position(Vector3(0.0, 0.58, 0.0))
	await get_tree().physics_frame

	assert_eq(bot.debug_get_last_approach_label(), &"chase_setup")
	assert_lt(bot.debug_get_last_move_target().z, football.debug_get_ball().global_position.z)
	assert_no_new_orphans()

func test_football_bot_uses_prediction_difficulty_and_boost() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	football.set_bot_difficulty(&"hard")
	football.debug_force_ball_position(Vector3(0.0, 0.58, 0.0))
	ball.linear_velocity = Vector3(8.0, 0.0, 0.0)
	bot._physics_process(0.1)

	assert_eq(football.debug_get_bot_difficulty_id(), &"hard")
	assert_eq(bot.debug_get_difficulty_id(), &"hard")
	assert_lt(bot.debug_get_aim_error_radius(), 0.2)
	assert_gt(bot.debug_get_last_predicted_ball_position().x, ball.global_position.x)
	assert_true(bot.debug_is_boosting())
	assert_no_new_orphans()

func test_football_arcade_dash_spends_stamina_and_slides_ball_with_stun() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	player.global_position = Vector3.ZERO
	player.rotation = Vector3.ZERO
	bot.global_position = Vector3(0.0, 0.05, -0.92)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -1.1))
	var before_stamina: float = player.debug_get_boost_stamina()
	var before_kicks: int = ball.debug_get_kick_count()

	assert_true(player.request_arcade_dash(Vector3.FORWARD))
	football.debug_process_arcade_action_contacts()

	assert_eq(player.debug_get_arcade_dash_count(), 1)
	assert_lt(player.debug_get_boost_stamina(), before_stamina)
	assert_gt(football.debug_get_player_dash_cooldown_fraction(), 0.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks + 1)
	assert_almost_eq(ball.debug_get_last_kick_force(), 7.2, 0.01)
	assert_gt(bot.debug_get_arcade_stun_remaining(), 0.0)
	assert_gt(bot.debug_get_knockback_event_count(), 0)
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"slide")
	assert_no_new_orphans()

func test_football_arcade_flip_consumes_once_and_resets_for_floor() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	player.global_position.y = 2.0
	player.debug_force_arcade_flip_available(true)
	await get_tree().physics_frame

	assert_true(player.request_arcade_flip(Vector3.FORWARD))
	assert_eq(player.debug_get_arcade_flip_count(), 1)
	assert_false(player.debug_is_arcade_flip_available())
	assert_false(player.request_arcade_flip(Vector3.FORWARD))
	player.debug_reset_arcade_flip_for_floor()
	assert_true(player.debug_is_arcade_flip_available())
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"flip")
	assert_no_new_orphans()

func test_football_bot_uses_arcade_dash_for_defense() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	football.set_bot_difficulty(&"hard")
	bot.global_position = Vector3(8.0, 0.05, -18.0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -20.0))
	ball.linear_velocity = Vector3(0.0, 0.0, -8.0)
	bot._physics_process(0.1)

	assert_gt(bot.debug_get_arcade_dash_count(), 0)
	assert_true(bot.debug_is_arcade_dashing())
	assert_eq(football.debug_get_bot_avatar().debug_get_animation_state(), &"slide")
	assert_no_new_orphans()

func test_football_uses_main_menu_bot_difficulty_in_hud() -> void:
	get_tree().root.set_meta(BOT_DIFFICULTY_META_KEY, &"hard")
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var hud = football.get_node("FootballHud")
	hud.update_snapshot(football.debug_build_hud_snapshot())

	assert_eq(football.debug_get_bot_difficulty_id(), &"hard")
	assert_eq(football.debug_get_bot().debug_get_difficulty_id(), &"hard")
	assert_true(hud.flow_label.text.contains("Bot hard"))
	assert_no_new_orphans()

func test_football_kickoff_alternates_after_goal_reset() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()

	assert_eq(football.debug_get_kickoff_owner(), &"player")
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._physics_process(0.1)
	assert_eq(football.debug_get_player_score(), 1)
	football._physics_process(1.3)

	assert_eq(football.debug_get_kickoff_owner(), &"bot")
	assert_lt(football.debug_get_ball().global_position.z, 0.0)
	assert_true(football.debug_is_kickoff_locked())
	assert_no_new_orphans()

func test_football_goal_updates_score_and_match_ends_at_three() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_set_match_mode(&"goals")
	football.debug_start_match()
	await get_tree().physics_frame

	football.debug_set_score(2, 0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()

	assert_eq(football.debug_get_player_score(), 3)
	assert_eq(football.debug_get_bot_score(), 0)
	assert_true(football.debug_is_match_over())
	assert_eq(football.get_node("FootballHud").last_event, &"match_end")
	var football_hud = football.get_node("FootballHud")
	assert_true(football_hud.debug_is_result_panel_visible())
	assert_eq(football_hud.debug_get_result_title(), "VITORIA")
	assert_not_null(football_hud.get_node_or_null("HudRoot/ResultCenter/ResultPanel/ResultMargin/ResultBox/ResultButtons/RematchButton"))
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"celebrate")
	assert_true(football.debug_is_goal_slowmo_active())
	assert_true(football.debug_get_chase_camera().debug_is_goal_focus_active())
	assert_no_new_orphans()

func test_football_timer_mode_enters_golden_goal_and_next_goal_wins() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_set_match_mode(&"timer")
	football.debug_start_match()
	await get_tree().physics_frame

	football.debug_set_score(1, 1)
	football.debug_set_match_time_remaining(0.05)
	football._physics_process(0.1)

	assert_true(football.debug_is_golden_goal_active())
	assert_false(football.debug_is_match_over())
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"golden_goal")

	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()

	assert_eq(football.debug_get_player_score(), 2)
	assert_eq(football.debug_get_bot_score(), 1)
	assert_eq(football.debug_get_last_goal_value(), 1)
	assert_true(football.debug_is_match_over())
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"match_end")
	assert_no_new_orphans()

func test_football_timer_mode_goal_counts_double_in_final_30_seconds() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_set_match_mode(&"timer")
	football.debug_start_match()
	await get_tree().physics_frame
	(football.get_node("FootballHud") as FootballHud).reset_feedback()

	football.debug_set_match_time_remaining(29.0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()

	assert_eq(football.debug_get_player_score(), 2)
	assert_eq(football.debug_get_last_goal_value(), 2)
	assert_false(football.debug_is_match_over())
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"double_goal")
	assert_true((football.get_node("FootballHud") as FootballHud).debug_get_event_text().contains("VALE 2"))
	assert_no_new_orphans()

func test_football_arcade_emote_only_triggers_after_goal() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var feedback = football.debug_get_feedback()
	football.debug_trigger_arcade_emote(true)
	assert_eq(feedback.debug_get_confetti_count(), 0)

	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()
	var confetti_after_goal: int = feedback.debug_get_confetti_count()
	football.debug_trigger_arcade_emote(true)

	assert_eq(feedback.debug_get_confetti_count(), confetti_after_goal + 1)
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"celebrate")
	assert_no_new_orphans()

func test_football_toon_render_toggle_is_off_by_default_and_isolated() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var player_avatar = football.debug_get_player_avatar()
	var bot_avatar = football.debug_get_bot_avatar()
	var ball = football.debug_get_ball()

	assert_false(football.debug_is_toon_render_enabled())
	assert_eq(player_avatar.debug_get_toon_outline_count(), 0)
	assert_eq(bot_avatar.debug_get_toon_outline_count(), 0)
	assert_false(ball.debug_has_toon_outline())

	football.debug_set_toon_render_enabled(true)

	assert_true(football.debug_is_toon_render_enabled())
	assert_true(player_avatar.debug_is_toon_render_enabled())
	assert_true(bot_avatar.debug_is_toon_render_enabled())
	assert_true(ball.debug_is_toon_render_enabled())
	assert_gt(player_avatar.debug_get_toon_outline_count(), 0)
	assert_gt(bot_avatar.debug_get_toon_outline_count(), 0)
	assert_true(ball.debug_has_toon_outline())

	football.debug_set_toon_render_enabled(false)

	assert_false(player_avatar.debug_is_toon_render_enabled())
	assert_false(ball.debug_is_toon_render_enabled())
	assert_eq(player_avatar.debug_get_toon_outline_count(), 0)
	assert_false(ball.debug_has_toon_outline())
	assert_no_new_orphans()

func test_football_feedback_exposes_boost_and_skid_vfx() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var avatar = football.debug_get_player_avatar()
	var feedback = football.debug_get_feedback()
	assert_true(avatar.debug_has_persistent_vfx())

	avatar.set_boost_trail_active(true)
	avatar.set_skid_dust_active(true)

	assert_true(avatar.debug_is_boost_trail_emitting())
	assert_true(avatar.debug_is_skid_dust_emitting())
	assert_eq(feedback.debug_active_effect_count(), 0)
	assert_no_new_orphans()

func test_football_bot_kick_request_moves_ball() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	football.debug_force_ball_position(bot.global_position + Vector3(0.0, 0.55, 1.1))
	football._on_bot_kick_requested(bot.global_position + Vector3.UP * 0.9, Vector3.BACK, 11.0, 0.7)

	assert_eq(ball.debug_get_kick_count(), 1)
	assert_almost_eq(ball.debug_get_last_kick_force(), 11.0, 0.01)
	assert_eq(football.debug_get_bot_avatar().debug_get_animation_state(), &"kick")
	assert_gt(ball.linear_velocity.length(), 0.1)
	assert_no_new_orphans()
