class_name FootballPresentationFxController
extends RefCounted

const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")
const RenderProfileScript = preload("res://autoloads/render_profile.gd")


static func trigger_arcade_emote(root: Node, player_triggered: bool) -> void:
	PerfProbeScript.mark(root, "event.arcade_emote", "player=%s" % str(player_triggered))
	if root.goal_reset_timer <= 0.0 and not root.match_over:
		return
	var actor_position := Vector3.ZERO
	var skip_web_avatar_celebration := RenderProfileScript.is_web_platform()
	if player_triggered:
		if root.player_avatar != null and not skip_web_avatar_celebration:
			root.player_avatar.play_celebrate()
		actor_position = root.player.global_position if root.player != null else Vector3.ZERO
	else:
		if root.bot_avatar != null and not skip_web_avatar_celebration:
			root.bot_avatar.play_celebrate()
		actor_position = root.bot.global_position if root.bot != null else Vector3.ZERO
	if root.hud != null:
		root.hud.show_announcement("QUE FESTA!" if player_triggered else "O BOT PROVOCA!", 0.75, &"emote")
	if root.feedback != null and root.feedback.has_method("play_arcade_confetti"):
		root.feedback.play_arcade_confetti(actor_position, player_triggered)


static func update_player_presentation_fx(root: Node, _delta: float) -> void:
	var boost_fraction := 0.0
	var boost_active := false
	if root.player != null and root.player.is_boosting():
		boost_fraction = 1.0
		boost_active = true
	if root.player != null and root.player.has_method("is_arcade_dashing") and root.player.is_arcade_dashing():
		boost_active = true
	if root.chase_camera != null:
		root.chase_camera.set_boost_fov_fraction(boost_fraction)
	var skid_active := false
	if root.player != null and root.player.is_on_floor():
		var flat_speed := Vector3(root.player.velocity.x, 0.0, root.player.velocity.z).length()
		skid_active = flat_speed > 7.2 and not boost_active
	set_player_persistent_vfx(root, boost_active, skid_active)


static func set_player_persistent_vfx(root: Node, boost_active: bool, skid_active: bool) -> void:
	if root.player_avatar != null:
		root.player_avatar.set_boost_trail_active(boost_active)
		root.player_avatar.set_skid_dust_active(skid_active)


static func trigger_goal_gamefeel(root: Node) -> void:
	if RenderProfileScript.is_web_platform():
		root.goal_slowmo_remaining = 0.0
		Engine.time_scale = 1.0
		PerfProbeScript.mark(root, "event.goal_gamefeel", "web_slowmo_disabled=true")
		return
	root.goal_slowmo_remaining = root.GOAL_SLOWMO_DURATION
	if not DisplayServer.get_name().to_lower().contains("headless"):
		Engine.time_scale = root.GOAL_SLOWMO_SCALE
	if root.chase_camera != null:
		root.chase_camera.focus_goal(root.GOAL_SLOWMO_DURATION)
		root.chase_camera.play_shake(0.16, 0.32)


static func update_goal_slowmo(root: Node, delta: float) -> void:
	if root.goal_slowmo_remaining <= 0.0:
		return
	root.goal_slowmo_remaining = maxf(0.0, root.goal_slowmo_remaining - delta)
	if root.goal_slowmo_remaining <= 0.0:
		Engine.time_scale = 1.0


static func cycle_skin_tone(root: Node, step: int) -> void:
	root.selected_appearance.skin_tone_id = AvatarCatalogScript.get_next_skin_tone_id(root.selected_appearance.skin_tone_id, step)
	apply_selected_player_appearance(root)


static func cycle_country_kit(root: Node, step: int) -> void:
	root.selected_appearance.country_kit_id = AvatarCatalogScript.get_next_country_kit_id(root.selected_appearance.country_kit_id, step)
	apply_selected_player_appearance(root)


static func apply_selected_player_appearance(root: Node) -> void:
	if root.player_avatar != null:
		root.player_avatar.apply_appearance(root.selected_appearance)
	root._request_hud_and_scoreboard_refresh()


static func update_avatar_states(root: Node, delta: float) -> void:
	if root.player_avatar != null and root.player != null:
		var player_flat_velocity := Vector3(root.player.velocity.x, 0.0, root.player.velocity.z)
		var player_flat_speed := player_flat_velocity.length()
		root.player_avatar.update_visual_movement_facing(player_flat_velocity, root.player.rotation.y, delta)
		root.player_avatar.set_move_state(player_flat_speed, root.player.is_on_floor(), root.player.velocity.y)
	if root.bot_avatar != null and root.bot != null:
		var bot_flat_speed := Vector3(root.bot.velocity.x, 0.0, root.bot.velocity.z).length()
		root.bot_avatar.set_move_state(bot_flat_speed, root.bot.is_on_floor(), root.bot.velocity.y)
