extends "res://addons/gut/test.gd"

const PlayerController = preload("res://gameplay/player/player_controller.gd")
const BossTrollController = preload("res://gameplay/boss/boss_troll_controller.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")

class DummyTarget extends Node3D:
	var is_dead: bool = false
	var damage_taken: float = 0.0

	func take_damage(amount: float, _source_id: StringName = &"") -> void:
		damage_taken += amount

func test_projectile_skill_uses_manual_aim_point_for_hit_resolution() -> void:
	var player: PlayerController = _spawn_player_with_skill(SkillDefinitionResource.SkillKind.PROJECTILE, 4.4, 34.0)
	var target: DummyTarget = add_child_autofree(DummyTarget.new())
	target.global_position = Vector3(3.0, 0.0, 0.0)
	player.target = target

	player.set_skill_aim_world_override(Vector3(0.0, 0.0, 3.0))
	player._use_skill(0)
	assert_eq(target.damage_taken, 0.0)

	player = _spawn_player_with_skill(SkillDefinitionResource.SkillKind.PROJECTILE, 4.4, 34.0)
	target = add_child_autofree(DummyTarget.new())
	target.global_position = Vector3(3.0, 0.0, 0.0)
	player.target = target
	player.set_skill_aim_world_override(Vector3(3.0, 0.0, 0.0))
	player._use_skill(0)
	assert_eq(target.damage_taken, 34.0)

func test_leap_skill_lands_on_manual_point_instead_of_homing_to_target() -> void:
	var player: PlayerController = _spawn_player_with_skill(SkillDefinitionResource.SkillKind.LEAP_STRIKE, 5.0, 42.0)
	var target: DummyTarget = add_child_autofree(DummyTarget.new())
	target.global_position = Vector3(4.0, 0.0, 0.0)
	player.target = target

	player.set_skill_aim_world_override(Vector3(0.0, 0.0, 4.0))
	player._use_skill(0)

	assert_true(player.global_position.distance_to(Vector3(0.0, 0.0, 4.0)) <= 0.05)
	assert_eq(target.damage_taken, 0.0)

func test_leap_skill_only_hits_when_manual_landing_point_catches_target() -> void:
	var player: PlayerController = _spawn_player_with_skill(SkillDefinitionResource.SkillKind.LEAP_STRIKE, 5.0, 42.0)
	var target: DummyTarget = add_child_autofree(DummyTarget.new())
	target.global_position = Vector3(4.0, 0.0, 0.0)
	player.target = target

	player.set_skill_aim_world_override(Vector3(4.0, 0.0, 0.0))
	player._use_skill(0)

	assert_true(player.global_position.distance_to(Vector3(4.0, 0.0, 0.0)) <= 0.05)
	assert_eq(target.damage_taken, 42.0)

func test_basic_attack_reaches_large_boss_targets_by_ground_footprint_instead_of_center_only() -> void:
	var player: PlayerController = _spawn_player_with_basic_attack(2.35, 22.0)
	var boss: BossTrollController = add_child_autofree(BossTrollController.new())
	boss.configure(&"boss_troll", null, player)
	boss.global_position = Vector3(3.0, 0.0, 0.0)
	player.target = boss

	player._use_basic_attack()

	assert_lt(boss.health, boss.max_health)

func test_basic_attack_still_misses_large_boss_targets_when_ground_edge_distance_exceeds_range() -> void:
	var player: PlayerController = _spawn_player_with_basic_attack(2.35, 22.0)
	var boss: BossTrollController = add_child_autofree(BossTrollController.new())
	boss.configure(&"boss_troll", null, player)
	boss.global_position = Vector3(4.8, 0.0, 0.0)
	player.target = boss

	player._use_basic_attack()

	assert_eq(boss.health, boss.max_health)

func _spawn_player_with_skill(skill_kind: int, skill_range: float, skill_damage: float) -> PlayerController:
	var weapon := WeaponDefinitionResource.new()
	weapon.max_health = 150.0
	weapon.move_speed = 5.8
	weapon.basic_attack_damage = 22.0
	weapon.basic_attack_range = 2.35

	var skill := SkillDefinitionResource.new()
	skill.kind = skill_kind
	skill.range = skill_range
	skill.damage = skill_damage
	skill.cooldown = 1.0

	var loadout := LoadoutData.new()
	loadout.weapon = weapon
	loadout.skills = [skill]

	var player: PlayerController = add_child_autofree(PlayerController.new())
	player.configure(loadout, null)
	player.global_position = Vector3.ZERO
	return player

func _spawn_player_with_basic_attack(basic_attack_range: float, basic_attack_damage: float) -> PlayerController:
	var weapon := WeaponDefinitionResource.new()
	weapon.max_health = 150.0
	weapon.move_speed = 5.8
	weapon.basic_attack_damage = basic_attack_damage
	weapon.basic_attack_range = basic_attack_range

	var loadout := LoadoutData.new()
	loadout.weapon = weapon
	loadout.skills = []
	loadout.potions = []

	var player: PlayerController = add_child_autofree(PlayerController.new())
	player.configure(loadout, null)
	player.global_position = Vector3.ZERO
	return player
