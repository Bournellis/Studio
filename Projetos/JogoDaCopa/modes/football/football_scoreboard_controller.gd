class_name FootballScoreboardController
extends RefCounted

const UPDATE_INTERVAL_SECONDS: float = 0.1


static func update(root: Node, delta: float, render_profile_script: Object) -> void:
	root.stadium_scoreboard_elapsed += delta
	if root.stadium_scoreboard_elapsed < UPDATE_INTERVAL_SECONDS:
		return
	root.stadium_scoreboard_elapsed = 0.0
	var player_kit_code: String = root._get_kit_code(root.selected_appearance.country_kit_id)
	var bot_kit_code: String = root._get_kit_code(root.bot_appearance.country_kit_id)
	for side_name in ["North", "South"]:
		var content_changed := false
		var score_label := get_score_label(root, side_name)
		if score_label != null:
			var next_score_text := "%s %d - %d %s" % [player_kit_code, root.player_score, root.bot_score, bot_kit_code]
			if score_label.text != next_score_text:
				score_label.text = next_score_text
				content_changed = true
		var phase_label_node := get_phase_label(root, side_name)
		if phase_label_node != null:
			var next_phase_text := get_phase_text(root)
			if phase_label_node.text != next_phase_text:
				phase_label_node.text = next_phase_text
				content_changed = true
		if content_changed:
			request_update(root, side_name, render_profile_script)


static func get_score_label(root: Node, side_name: String) -> Label:
	if not root.stadium_scoreboard_score_labels.has(side_name):
		root.stadium_scoreboard_score_labels[side_name] = root.get_node_or_null("WorldCupScoreboard%sViewport/ScoreRoot/ScoreLabel" % side_name)
	return root.stadium_scoreboard_score_labels.get(side_name) as Label


static func get_phase_label(root: Node, side_name: String) -> Label:
	if not root.stadium_scoreboard_phase_labels.has(side_name):
		root.stadium_scoreboard_phase_labels[side_name] = root.get_node_or_null("WorldCupScoreboard%sViewport/ScoreRoot/PhaseLabel" % side_name)
	return root.stadium_scoreboard_phase_labels.get(side_name) as Label


static func get_viewport(root: Node, side_name: String) -> SubViewport:
	if not root.stadium_scoreboard_viewports.has(side_name):
		root.stadium_scoreboard_viewports[side_name] = root.get_node_or_null("WorldCupScoreboard%sViewport" % side_name)
	return root.stadium_scoreboard_viewports.get(side_name) as SubViewport


static func request_update(root: Node, side_name: String, render_profile_script: Object) -> void:
	if not render_profile_script.is_web_platform():
		return
	var viewport := get_viewport(root, side_name)
	if viewport == null:
		return
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


static func resize_viewports(root: Node, render_profile_script: Object) -> void:
	var target_size: Vector2i = render_profile_script.get_scoreboard_viewport_size()
	for side_name in ["North", "South"]:
		var viewport := get_viewport(root, side_name)
		if viewport == null:
			continue
		viewport.size = target_size
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if render_profile_script.is_web_platform() else SubViewport.UPDATE_ALWAYS


static func get_phase_text(root: Node) -> String:
	if root.match_over:
		return "FIM DE JOGO"
	if root.golden_goal_active:
		return "GOLDEN GOAL"
	if root.phase_label == &"goal":
		return "GOL!"
	if root.phase_label == &"intro":
		return "FUTEBOL 1x1"
	if root.phase_label == &"kickoff" or root.phase_label == &"reset":
		return "SAIDA"
	return "AO VIVO"
