class_name FootballRenderSettingsController
extends RefCounted

const RenderProfileScript = preload("res://autoloads/render_profile.gd")
const FootballScoreboardControllerScript = preload("res://modes/football/football_scoreboard_controller.gd")
const FootballWorldEnvironmentScript = preload("res://modes/football/football_world_environment.gd")


static func apply_main_menu_settings(root: Node) -> void:
	var tree := root.get_tree()
	if tree == null or tree.root == null:
		return
	if tree.root.has_meta(root.BOT_DIFFICULTY_META_KEY):
		root.set_bot_difficulty(StringName(str(tree.root.get_meta(root.BOT_DIFFICULTY_META_KEY))))
	if tree.root.has_meta(root.MATCH_MODE_META_KEY):
		root.set_match_mode(StringName(str(tree.root.get_meta(root.MATCH_MODE_META_KEY))))


static func get_game_settings(root: Node):
	return root.get_node_or_null("/root/GameSettings")


static func connect_game_settings_signals(root: Node, quality_changed_callable: Callable) -> void:
	var settings = get_game_settings(root)
	if settings == null:
		return
	if not settings.quality_changed.is_connected(quality_changed_callable):
		settings.quality_changed.connect(quality_changed_callable)


static func on_pause_quality_changed(root: Node, _quality_id: StringName) -> void:
	if get_game_settings(root) == null:
		refresh_render_profile_runtime(root)


static func refresh_render_profile_runtime(root: Node) -> void:
	if root.world_environment != null:
		root.world_environment.environment = FootballWorldEnvironmentScript.build_night_environment(RenderProfileScript)
	FootballScoreboardControllerScript.resize_viewports(root, RenderProfileScript)
	root._request_hud_and_scoreboard_refresh()


static func on_sensitivity_changed(root: Node, value: float) -> void:
	if root.player != null:
		root.player.set_mouse_sensitivity(value)
	var settings = get_game_settings(root)
	if settings != null and root.player != null:
		settings.set_mouse_sensitivity(root.player.mouse_sensitivity)
	if root.hud != null:
		root.hud.set_sensitivity_value(root.player.mouse_sensitivity)
