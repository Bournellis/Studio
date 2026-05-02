extends "res://addons/gut/test.gd"

const SkillFeedback3D = preload("res://presentation/feedback/skill_feedback_3d.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")

class DummyPlayer extends Node3D:
	signal skill_used(effect: Dictionary)

	func emit_skill(effect: Dictionary) -> void:
		skill_used.emit(effect)

func test_skill_feedback_layer_spawns_distinct_effect_buckets() -> void:
	var layer: SkillFeedback3D = add_child_autofree(SkillFeedback3D.new())
	var player: DummyPlayer = add_child_autofree(DummyPlayer.new())
	layer.bind(player)
	await get_tree().process_frame

	player.emit_skill({
		"skill_kind": SkillDefinitionResource.SkillKind.PROJECTILE,
		"origin_position": Vector3.ZERO,
		"impact_position": Vector3(3.0, 0.0, 0.0),
		"duration": 0.0,
		"hit_confirmed": true
	})
	player.emit_skill({
		"skill_kind": SkillDefinitionResource.SkillKind.SELF_BUFF,
		"origin_position": Vector3(1.0, 0.0, 1.0),
		"impact_position": Vector3(1.0, 0.0, 1.0),
		"duration": 3.5,
		"hit_confirmed": false
	})
	player.emit_skill({
		"skill_kind": SkillDefinitionResource.SkillKind.AREA_BURST,
		"origin_position": Vector3(-1.0, 0.0, 0.0),
		"impact_position": Vector3(-1.0, 0.0, 0.0),
		"range": 3.2,
		"duration": 0.0,
		"hit_confirmed": true
	})
	player.emit_skill({
		"skill_kind": SkillDefinitionResource.SkillKind.LEAP_STRIKE,
		"origin_position": Vector3(0.0, 0.0, -2.0),
		"impact_position": Vector3(2.5, 0.0, -1.0),
		"duration": 0.0,
		"hit_confirmed": true
	})
	await get_tree().process_frame

	var projectile_root: Node3D = layer.get_node_or_null("ProjectileEffects")
	var buff_root: Node3D = layer.get_node_or_null("BuffEffects")
	var burst_root: Node3D = layer.get_node_or_null("BurstEffects")
	var leap_root: Node3D = layer.get_node_or_null("LeapEffects")
	assert_not_null(projectile_root)
	assert_not_null(buff_root)
	assert_not_null(burst_root)
	assert_not_null(leap_root)
	assert_eq(projectile_root.get_child_count(), 1)
	assert_eq(buff_root.get_child_count(), 1)
	assert_eq(burst_root.get_child_count(), 1)
	assert_eq(leap_root.get_child_count(), 1)
