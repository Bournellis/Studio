extends "res://addons/gut/test.gd"

const CombatClarity3D = preload("res://presentation/feedback/combat_clarity_3d.gd")

class DummyPlayer extends Node3D:
	var target
	var basic_attack_cooldown: float = 0.0
	var basic_attack_range: float = 2.2
	var dash_cooldown: float = 0.0
	var dash_distance: float = 5.0
	var skill_ranges: Dictionary = {0: 4.4, 3: 5.0}
	var skill_readiness: Dictionary = {0: true, 3: true}
	var skill_hit_radii: Dictionary = {0: 1.05, 3: 2.25}

	func get_basic_attack_cooldown() -> float:
		return basic_attack_cooldown

	func get_basic_attack_range() -> float:
		return basic_attack_range

	func get_dash_cooldown() -> float:
		return dash_cooldown

	func get_dash_distance() -> float:
		return dash_distance

	func get_skill_index_by_kind(skill_kind: int) -> int:
		if skill_kind == 0:
			return 0
		if skill_kind == 3:
			return 3
		return -1

	func get_skill_range(index: int) -> float:
		return float(skill_ranges.get(index, 0.0))

	func get_skill_hit_radius(index: int) -> float:
		return float(skill_hit_radii.get(index, 0.0))

	func is_skill_ready(index: int) -> bool:
		return bool(skill_readiness.get(index, false))

	func clamp_skill_aim_point(world_point: Vector3, max_distance: float) -> Vector3:
		var flat_point: Vector3 = Vector3(world_point.x, global_position.y, world_point.z)
		var toward_point: Vector3 = flat_point - global_position
		toward_point.y = 0.0
		if toward_point.length_squared() <= 0.0001:
			return global_position
		if toward_point.length() > max_distance:
			return global_position + toward_point.normalized() * max_distance
		return flat_point

class DummyBot extends Node3D:
	var is_dead: bool = false
	var winding_up: bool = false
	var attack_range: float = 1.8

	func is_attack_winding_up() -> bool:
		return winding_up

	func get_attack_range() -> float:
		return attack_range

func test_clarity_layer_creates_expected_indicator_nodes() -> void:
	var layer: CombatClarity3D = add_child_autofree(CombatClarity3D.new())
	var player: DummyPlayer = add_child_autofree(DummyPlayer.new())
	var bot: DummyBot = add_child_autofree(DummyBot.new())
	var camera: Camera3D = add_child_autofree(Camera3D.new())
	player.target = bot
	player.position = Vector3.ZERO
	bot.position = Vector3(2.0, 0.0, 0.0)
	camera.position = Vector3(8.0, 10.0, 8.0)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	layer.bind(player, bot, camera)
	await get_tree().process_frame

	assert_not_null(layer.get_node_or_null("PlayerAttackRange"))
	assert_not_null(layer.get_node_or_null("PlayerDashRange"))
	assert_not_null(layer.get_node_or_null("BotThreatRange"))
	assert_not_null(layer.get_node_or_null("AimMarker"))
	assert_not_null(layer.get_node_or_null("ProjectileImpactPreview"))
	assert_not_null(layer.get_node_or_null("LeapLandingPreview"))
