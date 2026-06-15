class_name FootballArcadeFieldController
extends RefCounted


static func collect_nodes(root: Node) -> void:
	root.boost_pad_areas.clear()
	for node: Node in root.get_tree().get_nodes_in_group("football_boost_pad"):
		if node is Area3D:
			var boost_pad := node as Area3D
			root.boost_pad_areas.append(boost_pad)
			set_boost_pad_active(boost_pad, true)
			boost_pad.set_meta("respawn_remaining", 0.0)
	root.jump_pad_areas.clear()
	for node: Node in root.get_tree().get_nodes_in_group("football_jump_pad"):
		if node is Area3D:
			var jump_pad := node as Area3D
			root.jump_pad_areas.append(jump_pad)
			jump_pad.set_meta("cooldown_remaining", 0.0)
	if root.bot != null and root.bot.has_method("set_boost_pad_targets"):
		var bot_pad_targets: Array[Node3D] = []
		for pad: Area3D in root.boost_pad_areas:
			bot_pad_targets.append(pad)
		root.bot.set_boost_pad_targets(bot_pad_targets)


static func reset(root: Node) -> void:
	for pad: Area3D in root.boost_pad_areas:
		set_boost_pad_active(pad, true)
		pad.set_meta("respawn_remaining", 0.0)
	for jump_pad: Area3D in root.jump_pad_areas:
		jump_pad.set_meta("cooldown_remaining", 0.0)


static func update(root: Node, delta: float) -> void:
	update_boost_pads(root, delta)
	update_jump_pads(root, delta)


static func update_boost_pads(root: Node, delta: float) -> void:
	if root.boost_pad_areas.is_empty():
		return
	for pad: Area3D in root.boost_pad_areas:
		if pad == null:
			continue
		if not is_boost_pad_active(pad):
			var respawn_remaining := maxf(0.0, float(pad.get_meta("respawn_remaining", 0.0)) - delta)
			pad.set_meta("respawn_remaining", respawn_remaining)
			if respawn_remaining <= 0.0:
				set_boost_pad_active(pad, true)
			continue
		if root.player != null and _flat_distance(root.player.global_position, pad.global_position) <= root.BOOST_PAD_COLLECT_RADIUS:
			collect_boost_pad(root, pad, true)
		elif root.bot != null and _flat_distance(root.bot.global_position, pad.global_position) <= root.BOOST_PAD_COLLECT_RADIUS:
			collect_boost_pad(root, pad, false)


static func collect_boost_pad(root: Node, pad: Area3D, collected_by_player: bool) -> void:
	var full_pad := str(pad.get_meta("pad_type", "small")) == "large"
	if collected_by_player and root.player != null:
		if full_pad and root.player.has_method("refill_boost_stamina"):
			root.player.refill_boost_stamina()
		elif root.player.has_method("add_boost_stamina"):
			root.player.add_boost_stamina(root.BOOST_PAD_SMALL_STAMINA)
	elif not collected_by_player and root.bot != null and root.bot.has_method("notify_boost_pad_collected"):
		root.bot.notify_boost_pad_collected(full_pad)
	set_boost_pad_active(pad, false)
	pad.set_meta("respawn_remaining", root.BOOST_PAD_RESPAWN_SECONDS)
	if root.feedback != null:
		root.feedback.play_pickup(pad.global_position, &"boost")


static func is_boost_pad_active(pad: Area3D) -> bool:
	return bool(pad.get_meta("active", true))


static func set_boost_pad_active(pad: Area3D, is_active: bool) -> void:
	pad.set_meta("active", is_active)
	for child: Node in pad.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = is_active


static func update_jump_pads(root: Node, delta: float) -> void:
	if root.jump_pad_areas.is_empty():
		return
	for jump_pad: Area3D in root.jump_pad_areas:
		if jump_pad == null:
			continue
		var cooldown_remaining := maxf(0.0, float(jump_pad.get_meta("cooldown_remaining", 0.0)) - delta)
		jump_pad.set_meta("cooldown_remaining", cooldown_remaining)
		if cooldown_remaining > 0.0:
			continue
		if root.player != null and _flat_distance(root.player.global_position, jump_pad.global_position) <= root.JUMP_PAD_COLLECT_RADIUS:
			root.player.apply_jump_pad_launch(root.JUMP_PAD_LAUNCH_VELOCITY)
			jump_pad.set_meta("cooldown_remaining", root.JUMP_PAD_COOLDOWN_SECONDS)
			if root.feedback != null:
				root.feedback.play_jump_pad(jump_pad.global_position, root.JUMP_PAD_LAUNCH_VELOCITY)
		elif root.bot != null and _flat_distance(root.bot.global_position, jump_pad.global_position) <= root.JUMP_PAD_COLLECT_RADIUS:
			root.bot.apply_jump_pad_launch(root.JUMP_PAD_LAUNCH_VELOCITY)
			jump_pad.set_meta("cooldown_remaining", root.JUMP_PAD_COOLDOWN_SECONDS)
			if root.feedback != null:
				root.feedback.play_jump_pad(jump_pad.global_position, root.JUMP_PAD_LAUNCH_VELOCITY)


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
