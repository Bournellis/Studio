class_name FootballMatchPresentationController
extends RefCounted

const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")


static func build_hud_snapshot(root: Node, mode_name: String, avatar_catalog_script: Object) -> Dictionary:
	var ball_distance := 0.0
	var ball_relative := Vector3.ZERO
	var ball_relative_local := Vector3.ZERO
	if root.player != null and root.ball != null:
		ball_relative = root.ball.global_position - root.player.global_position
		ball_relative_local = root.player.global_transform.basis.inverse() * ball_relative
		ball_distance = Vector3(root.player.global_position.x, 0.0, root.player.global_position.z).distance_to(Vector3(root.ball.global_position.x, 0.0, root.ball.global_position.z))
	return {
		"status": mode_name,
		"player_score": root.player_score,
		"bot_score": root.bot_score,
		"goal_limit": root.GOAL_LIMIT,
		"match_mode": root.match_mode_id,
		"match_time_remaining": root.match_time_remaining,
		"golden_goal_active": root.golden_goal_active,
		"ball_distance": ball_distance,
		"ball_relative_x": ball_relative_local.x,
		"ball_relative_z": ball_relative_local.z,
		"player_kit_code": get_kit_code(root.selected_appearance.country_kit_id),
		"bot_kit_code": get_kit_code(root.bot_appearance.country_kit_id),
		"player_kit_color": avatar_catalog_script.get_kit_primary_color(root.selected_appearance.country_kit_id),
		"bot_kit_color": avatar_catalog_script.get_kit_primary_color(root.bot_appearance.country_kit_id),
		"ball_control": root.player_ball_control_state,
		"ball_control_strength": root.player_ball_control_strength,
		"boost_fraction": root.player.get_boost_stamina_fraction() if root.player != null else 0.0,
		"boost_active": root.player.is_boosting() if root.player != null else false,
		"dash_cooldown_fraction": root.player.get_arcade_dash_cooldown_fraction() if root.player != null and root.player.has_method("get_arcade_dash_cooldown_fraction") else 0.0,
		"shoot_charge_fraction": root.player.get_shoot_charge_fraction() if root.player != null and root.player.has_method("get_shoot_charge_fraction") else 0.0,
		"player_super_fraction": root.player_super_meter / root.SUPER_METER_MAX,
		"bot_state": root.bot.debug_get_state() if root.bot != null else "none",
		"bot_difficulty": root.bot_difficulty_id,
		"kickoff_owner": root.kickoff_owner,
		"phase": root.phase_label,
		"countdown": root.kickoff_countdown_remaining,
	}


static func update_hud_snapshot(root: Node, delta: float, mode_name: String, avatar_catalog_script: Object) -> void:
	if root.hud == null:
		return
	root.hud_snapshot_elapsed += delta
	if root.hud_snapshot_elapsed < root.HUD_SNAPSHOT_INTERVAL_SECONDS:
		return
	root.hud_snapshot_elapsed = 0.0
	root.hud.update_snapshot(build_hud_snapshot(root, mode_name, avatar_catalog_script))


static func request_hud_and_scoreboard_refresh(root: Node, scoreboard_update_interval: float) -> void:
	root.hud_snapshot_elapsed = root.HUD_SNAPSHOT_INTERVAL_SECONDS
	root.stadium_scoreboard_elapsed = scoreboard_update_interval


static func build_result_snapshot(root: Node, avatar_catalog_script: Object) -> Dictionary:
	var summary := FootballMatchRulesScript.build_match_stats_summary(root.match_stats)
	var player_code := get_kit_code(root.selected_appearance.country_kit_id)
	var bot_code := get_kit_code(root.bot_appearance.country_kit_id)
	return {
		"player_score": root.player_score,
		"bot_score": root.bot_score,
		"player_kit_code": player_code,
		"bot_kit_code": bot_code,
		"player_kit_color": avatar_catalog_script.get_kit_primary_color(root.selected_appearance.country_kit_id),
		"bot_kit_color": avatar_catalog_script.get_kit_primary_color(root.bot_appearance.country_kit_id),
		"stats_text": format_result_stats(summary, player_code, bot_code)
	}


static func format_result_stats(summary: Dictionary, player_code: String, bot_code: String) -> String:
	var period_line := "Gols por periodo: 1T %s %d-%d %s | 2T %s %d-%d %s" % [
		player_code,
		int(summary.get("player_goals_first_half", 0)),
		int(summary.get("bot_goals_first_half", 0)),
		bot_code,
		player_code,
		int(summary.get("player_goals_second_half", 0)),
		int(summary.get("bot_goals_second_half", 0)),
		bot_code
	]
	if int(summary.get("player_goals_golden_goal", 0)) + int(summary.get("bot_goals_golden_goal", 0)) > 0:
		period_line += " | GG %s %d-%d %s" % [
			player_code,
			int(summary.get("player_goals_golden_goal", 0)),
			int(summary.get("bot_goals_golden_goal", 0)),
			bot_code
		]
	if int(summary.get("player_goals_regular", 0)) + int(summary.get("bot_goals_regular", 0)) > 0:
		period_line += " | Unico %s %d-%d %s" % [
			player_code,
			int(summary.get("player_goals_regular", 0)),
			int(summary.get("bot_goals_regular", 0)),
			bot_code
		]
	var longest_team := StringName(str(summary.get("longest_touch_team", &"none")))
	var longest_label := player_code if longest_team == &"player" else (bot_code if longest_team == &"bot" else "-")
	return "%s\nChutes: %d total (%s %d / %s %d)\nPosse por toques: %s %d%% / %s %d%% (%d-%d toques)\nSUPERS usados: %s %d / %s %d\nMaior sequencia de toques: %s %d" % [
		period_line,
		int(summary.get("total_shots", 0)),
		player_code,
		int(summary.get("player_shots", 0)),
		bot_code,
		int(summary.get("bot_shots", 0)),
		player_code,
		int(summary.get("player_possession_percent", 50)),
		bot_code,
		int(summary.get("bot_possession_percent", 50)),
		int(summary.get("player_touches", 0)),
		int(summary.get("bot_touches", 0)),
		player_code,
		int(summary.get("player_supers", 0)),
		bot_code,
		int(summary.get("bot_supers", 0)),
		longest_label,
		int(summary.get("longest_touch_streak", 0))
	]


static func get_kit_code(country_kit_id: StringName) -> String:
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
