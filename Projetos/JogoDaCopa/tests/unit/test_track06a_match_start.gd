extends "res://addons/gut/test.gd"

const FACING_TOLERANCE_DEGREES: float = 12.0

func test_initial_kickoff_starts_countdown_once() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	assert_eq(football.debug_get_kickoff_countdown_start_count(), 0)
	football.debug_start_match_with_countdown()

	assert_eq(football.debug_get_kickoff_countdown_start_count(), 1)
	assert_no_new_orphans()

func test_initial_kickoff_avatar_visuals_face_opponents() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	football.debug_start_match()
	await get_tree().physics_frame

	_assert_avatar_faces_opponent(football.debug_get_player_avatar(), football.debug_get_player(), football.debug_get_bot(), "initial player")
	_assert_avatar_faces_opponent(football.debug_get_bot_avatar(), football.debug_get_bot(), football.debug_get_player(), "initial bot")
	assert_no_new_orphans()

func test_post_goal_kickoff_starts_countdown_once() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	football.debug_reset_kickoff_countdown_start_count()

	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._physics_process(0.1)
	football._physics_process(1.3)

	assert_eq(football.debug_get_kickoff_countdown_start_count(), 1)
	assert_no_new_orphans()

func test_post_goal_kickoff_avatar_visuals_face_opponents() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()

	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._physics_process(0.1)
	football._physics_process(1.3)

	_assert_avatar_faces_opponent(football.debug_get_player_avatar(), football.debug_get_player(), football.debug_get_bot(), "post-goal player")
	_assert_avatar_faces_opponent(football.debug_get_bot_avatar(), football.debug_get_bot(), football.debug_get_player(), "post-goal bot")
	assert_no_new_orphans()

func test_hud_omits_in_game_hints_and_crosshair_but_keeps_controls_data() -> void:
	var hud := FootballHud.new()
	add_child_autofree(hud)
	await get_tree().process_frame

	assert_null(hud.get_node_or_null("HudRoot/HintLabel"))
	assert_null(hud.get_node_or_null("HudRoot/FootballCrosshair"))
	var control_hints := FootballHud.get_control_hints()
	assert_gt(control_hints.size(), 0)
	assert_true(_control_hints_include(control_hints, "Mover", "WASD"))
	assert_true(_control_hints_include(control_hints, "Chute forte / SUPER", "RMB"))
	assert_true(_control_hints_include(control_hints, "Menu", "Esc"))
	assert_no_new_orphans()

func _assert_avatar_faces_opponent(avatar, owner: Node3D, opponent: Node3D, label: String) -> void:
	var visual_forward: Vector3 = avatar.debug_get_model_front_direction()
	visual_forward.y = 0.0
	var to_opponent := opponent.global_position - owner.global_position
	to_opponent.y = 0.0
	assert_gt(visual_forward.length(), 0.001, "%s visual forward should be non-zero" % label)
	assert_gt(to_opponent.length(), 0.001, "%s opponent direction should be non-zero" % label)
	if visual_forward.length() <= 0.001 or to_opponent.length() <= 0.001:
		return
	var angle_degrees := rad_to_deg(visual_forward.normalized().angle_to(to_opponent.normalized()))
	assert_lt(angle_degrees, FACING_TOLERANCE_DEGREES, "%s facing angle %.2f" % [label, angle_degrees])

func _control_hints_include(control_hints: Array[Dictionary], action: String, input: String) -> bool:
	for entry: Dictionary in control_hints:
		if str(entry.get("action", "")) == action and str(entry.get("input", "")) == input:
			return true
	return false
