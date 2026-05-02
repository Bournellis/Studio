class_name PlayerController
extends "res://gameplay/combat/combat_body_3d.gd"

signal skill_used(effect: Dictionary)
signal potion_used(effect: Dictionary)

const SKILL_ACTIONS: PackedStringArray = ["skill_1", "skill_2", "skill_3", "skill_4"]
const POTION_ACTIONS: PackedStringArray = ["potion_1", "potion_2"]
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")

var loadout
var target
var arena_camera: Camera3D
var skill_aim_world_override: Variant = null
var additional_targets: Array = []

var basic_attack_cooldown_remaining: float = 0.0
var dash_cooldown_remaining: float = 0.0
var dash_time_remaining: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var skill_cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0]
var potion_cooldowns: Array[float] = [0.0, 0.0]
var attack_multiplier: float = 1.0
var move_multiplier: float = 1.0
var buff_time_remaining: float = 0.0
var progression_level: int = 1
var level_damage_multiplier: float = 1.0
var base_max_health: float = 100.0
var base_move_speed: float = 5.5

func _ready() -> void:
	combatant_id = &"player"
	body_color = Color(0.24, 0.72, 1.0, 1.0)
	super._ready()

func configure(next_loadout, context) -> void:
	loadout = next_loadout
	_ensure_loadout_slot_arrays()
	if loadout == null or loadout.weapon == null:
		configure_base(context, 100.0, 5.5)
		base_max_health = max_health
		base_move_speed = move_speed
		apply_progression_level(1)
		return

	configure_base(context, loadout.weapon.max_health, loadout.weapon.move_speed)
	base_max_health = max_health
	base_move_speed = move_speed
	basic_attack_cooldown_remaining = 0.0
	dash_cooldown_remaining = 0.0
	dash_time_remaining = 0.0
	attack_multiplier = 1.0
	move_multiplier = 1.0
	buff_time_remaining = 0.0
	for index: int in range(skill_cooldowns.size()):
		skill_cooldowns[index] = 0.0
	for index: int in range(potion_cooldowns.size()):
		potion_cooldowns[index] = 0.0
	skill_aim_world_override = null
	additional_targets.clear()
	apply_progression_level(1)

func set_additional_targets(next_targets: Array) -> void:
	additional_targets.clear()
	for candidate: Variant in next_targets:
		if candidate == null or not is_instance_valid(candidate) or candidate == self:
			continue
		additional_targets.append(candidate)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	if is_motion_paused():
		velocity = Vector3.ZERO
		move_and_slide()
		return

	_tick_cooldowns(delta)
	_handle_rotation()
	_handle_actions()
	_handle_movement(delta)
	move_and_slide()

func get_skill_cooldown(index: int) -> float:
	if index < 0 or index >= skill_cooldowns.size():
		return 0.0
	return skill_cooldowns[index]

func get_progression_level() -> int:
	return progression_level

func get_skill_slot_label(index: int) -> String:
	if loadout == null or index < 0 or index >= loadout.skills.size():
		return "bloqueada"
	var skill: SkillDefinitionResource = loadout.skills[index]
	if skill == null:
		return "bloqueada"
	return skill.display_name

func get_potion_slot_label(index: int) -> String:
	if loadout == null or index < 0 or index >= loadout.potions.size():
		return "bloqueada"
	var potion: PotionDefinitionResource = loadout.potions[index]
	if potion == null:
		return "bloqueada"
	return potion.display_name

func has_skill_slot(index: int) -> bool:
	return loadout != null and index >= 0 and index < loadout.skills.size() and loadout.skills[index] != null

func has_potion_slot(index: int) -> bool:
	return loadout != null and index >= 0 and index < loadout.potions.size() and loadout.potions[index] != null

func trigger_skill_slot(index: int) -> void:
	_use_skill(index)

func trigger_potion_slot(index: int) -> void:
	_use_potion(index)

func add_runtime_skill(skill: SkillDefinitionResource) -> void:
	if loadout == null or skill == null:
		return
	for existing: SkillDefinitionResource in loadout.skills:
		if existing != null and existing.id == skill.id:
			return
	loadout.skills.append(skill)

func set_runtime_skill_slot(index: int, skill: SkillDefinitionResource) -> void:
	if loadout == null or index < 0 or index >= SKILL_ACTIONS.size():
		return
	_ensure_loadout_slot_arrays()
	loadout.skills[index] = skill

func add_runtime_potion(potion: PotionDefinitionResource) -> void:
	if loadout == null or potion == null:
		return
	for existing: PotionDefinitionResource in loadout.potions:
		if existing != null and existing.id == potion.id:
			return
	loadout.potions.append(potion)

func set_runtime_potion_slot(index: int, potion: PotionDefinitionResource) -> void:
	if loadout == null or index < 0 or index >= POTION_ACTIONS.size():
		return
	_ensure_loadout_slot_arrays()
	loadout.potions[index] = potion

func get_equipped_skill_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	if loadout == null:
		return ids
	for skill: SkillDefinitionResource in loadout.skills:
		ids.append("" if skill == null else String(skill.id))
	return ids

func get_equipped_potion_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	if loadout == null:
		return ids
	for potion: PotionDefinitionResource in loadout.potions:
		ids.append("" if potion == null else String(potion.id))
	return ids

func apply_progression_level(next_level: int) -> void:
	progression_level = maxi(1, next_level)
	level_damage_multiplier = 1.0 + 0.10 * float(maxi(0, progression_level - 1))
	var next_max_health: float = base_max_health * (1.0 + 0.06 * float(maxi(0, progression_level - 1)))
	var current_ratio: float = 1.0
	if max_health > 0.0:
		current_ratio = clampf(health / max_health, 0.0, 1.0)
	max_health = next_max_health
	health = clampf(max_health * current_ratio, 1.0, max_health)
	move_speed = base_move_speed

func get_runtime_snapshot() -> Dictionary:
	return {
		"combat": build_combat_snapshot(),
		"basic_attack_cooldown_remaining": basic_attack_cooldown_remaining,
		"dash_cooldown_remaining": dash_cooldown_remaining,
		"dash_time_remaining": dash_time_remaining,
		"dash_direction": _serialize_variant(dash_direction),
		"skill_cooldowns": skill_cooldowns.duplicate(),
		"potion_cooldowns": potion_cooldowns.duplicate(),
		"attack_multiplier": attack_multiplier,
		"move_multiplier": move_multiplier,
		"buff_time_remaining": buff_time_remaining,
		"progression_level": progression_level,
		"equipped_skill_ids": Array(get_equipped_skill_ids()),
		"equipped_potion_ids": Array(get_equipped_potion_ids())
	}

func restore_runtime_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	apply_progression_level(maxi(1, int(snapshot.get("progression_level", progression_level))))
	restore_combat_snapshot(Dictionary(snapshot.get("combat", {})))
	basic_attack_cooldown_remaining = maxf(0.0, float(snapshot.get("basic_attack_cooldown_remaining", 0.0)))
	dash_cooldown_remaining = maxf(0.0, float(snapshot.get("dash_cooldown_remaining", 0.0)))
	dash_time_remaining = maxf(0.0, float(snapshot.get("dash_time_remaining", 0.0)))
	dash_direction = _deserialize_variant(snapshot.get("dash_direction", ""), Vector3.ZERO)
	_restore_float_array(skill_cooldowns, snapshot.get("skill_cooldowns", []))
	_restore_float_array(potion_cooldowns, snapshot.get("potion_cooldowns", []))
	attack_multiplier = maxf(1.0, float(snapshot.get("attack_multiplier", 1.0)))
	move_multiplier = maxf(1.0, float(snapshot.get("move_multiplier", 1.0)))
	buff_time_remaining = maxf(0.0, float(snapshot.get("buff_time_remaining", 0.0)))

func _restore_float_array(target: Array[float], payload: Variant) -> void:
	if not payload is Array:
		return
	var source: Array = payload
	for index: int in range(target.size()):
		target[index] = maxf(0.0, float(source[index] if index < source.size() else 0.0))

func get_potion_cooldown(index: int) -> float:
	if index < 0 or index >= potion_cooldowns.size():
		return 0.0
	return potion_cooldowns[index]

func get_basic_attack_cooldown() -> float:
	return basic_attack_cooldown_remaining

func get_basic_attack_range() -> float:
	if loadout == null or loadout.weapon == null:
		return 0.0
	return loadout.weapon.basic_attack_range

func get_dash_cooldown() -> float:
	return dash_cooldown_remaining

func get_dash_distance() -> float:
	if loadout == null or loadout.weapon == null:
		return 0.0
	return loadout.weapon.dash_distance

func get_buff_time_remaining() -> float:
	return buff_time_remaining

func get_skill_index_by_kind(skill_kind: int) -> int:
	if loadout == null:
		return -1

	for index: int in range(loadout.skills.size()):
		var skill: SkillDefinitionResource = loadout.skills[index]
		if skill != null and int(skill.kind) == skill_kind:
			return index
	return -1

func get_skill_range(index: int) -> float:
	if loadout == null or index < 0 or index >= loadout.skills.size():
		return 0.0
	var skill: SkillDefinitionResource = loadout.skills[index]
	if skill == null:
		return 0.0
	return skill.range

func is_skill_ready(index: int) -> bool:
	if index < 0 or index >= skill_cooldowns.size():
		return false
	return skill_cooldowns[index] <= 0.0

func get_skill_hit_radius(index: int) -> float:
	if loadout == null or index < 0 or index >= loadout.skills.size():
		return 0.0
	var skill: SkillDefinitionResource = loadout.skills[index]
	if skill == null:
		return 0.0
	return _get_skill_hit_radius(skill)

func clamp_skill_aim_point(world_point: Vector3, max_distance: float) -> Vector3:
	var flat_point: Vector3 = Vector3(world_point.x, global_position.y, world_point.z)
	var toward_point: Vector3 = flat_point - global_position
	toward_point.y = 0.0
	if toward_point.length_squared() <= 0.0001:
		return global_position
	if toward_point.length() > max_distance:
		return global_position + toward_point.normalized() * max_distance
	return flat_point

func set_skill_aim_world_override(world_point: Vector3) -> void:
	skill_aim_world_override = world_point

func clear_skill_aim_world_override() -> void:
	skill_aim_world_override = null

func reset_runtime_motion() -> void:
	velocity = Vector3.ZERO
	dash_direction = Vector3.ZERO
	dash_time_remaining = 0.0

func _tick_cooldowns(delta: float) -> void:
	basic_attack_cooldown_remaining = maxf(0.0, basic_attack_cooldown_remaining - delta)
	dash_cooldown_remaining = maxf(0.0, dash_cooldown_remaining - delta)
	dash_time_remaining = maxf(0.0, dash_time_remaining - delta)

	for index: int in range(skill_cooldowns.size()):
		skill_cooldowns[index] = maxf(0.0, skill_cooldowns[index] - delta)

	for index: int in range(potion_cooldowns.size()):
		potion_cooldowns[index] = maxf(0.0, potion_cooldowns[index] - delta)

	if buff_time_remaining > 0.0:
		buff_time_remaining = maxf(0.0, buff_time_remaining - delta)
		if buff_time_remaining == 0.0:
			attack_multiplier = 1.0
			move_multiplier = 1.0

func _handle_movement(_delta: float) -> void:
	if dash_time_remaining > 0.0:
		var dash_distance: float = 4.4
		if loadout != null and loadout.weapon != null:
			dash_distance = loadout.weapon.dash_distance
		velocity = dash_direction * (dash_distance / 0.14)
		return

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	if arena_camera != null:
		var camera_forward: Vector3 = -arena_camera.global_transform.basis.z
		camera_forward.y = 0.0
		camera_forward = camera_forward.normalized()

		var camera_right: Vector3 = arena_camera.global_transform.basis.x
		camera_right.y = 0.0
		camera_right = camera_right.normalized()

		direction = camera_right * input_vector.x + camera_forward * -input_vector.y

	if direction.length_squared() > 0.0:
		direction = direction.normalized()

	velocity = direction * move_speed * move_multiplier

func _handle_rotation() -> void:
	if arena_camera == null:
		return

	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = arena_camera.project_ray_origin(mouse_position)
	var ray_normal: Vector3 = arena_camera.project_ray_normal(mouse_position)
	if absf(ray_normal.y) < 0.001:
		return

	var distance: float = -ray_origin.y / ray_normal.y
	if distance <= 0.0:
		return

	var hit_point: Vector3 = ray_origin + ray_normal * distance
	var flat_target: Vector3 = Vector3(hit_point.x, global_position.y, hit_point.z)
	if global_position.distance_to(flat_target) <= 0.05:
		return

	look_at(flat_target, Vector3.UP, true)

func _handle_actions() -> void:
	if Input.is_action_just_pressed("basic_attack"):
		_use_basic_attack()

	if Input.is_action_just_pressed("dash"):
		_use_dash()

	for index: int in range(SKILL_ACTIONS.size()):
		if Input.is_action_just_pressed(SKILL_ACTIONS[index]):
			_use_skill(index)

	for index: int in range(POTION_ACTIONS.size()):
		if Input.is_action_just_pressed(POTION_ACTIONS[index]):
			_use_potion(index)

func _use_basic_attack() -> void:
	if loadout == null or loadout.weapon == null:
		return
	if basic_attack_cooldown_remaining > 0.0:
		return

	var selected_target = _get_closest_target_in_range(loadout.weapon.basic_attack_range)
	if selected_target == null:
		return

	target = selected_target
	selected_target.take_damage(loadout.weapon.basic_attack_damage * _get_total_attack_multiplier(), combatant_id)

	basic_attack_cooldown_remaining = loadout.weapon.basic_attack_cooldown
	trigger_action_pulse(Color(1.0, 0.84, 0.58, 1.0), 0.16)
	if game_context != null:
		game_context.register_action(combatant_id, "basic_attack", "Ataque basico")

func _use_dash() -> void:
	if loadout == null or loadout.weapon == null:
		return
	if dash_cooldown_remaining > 0.0:
		return

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	if arena_camera != null:
		var camera_forward: Vector3 = -arena_camera.global_transform.basis.z
		camera_forward.y = 0.0
		camera_forward = camera_forward.normalized()

		var camera_right: Vector3 = arena_camera.global_transform.basis.x
		camera_right.y = 0.0
		camera_right = camera_right.normalized()

		direction = camera_right * input_vector.x + camera_forward * -input_vector.y
	if direction.length_squared() == 0.0:
		direction = -transform.basis.z

	dash_direction = direction.normalized()
	dash_time_remaining = 0.14
	dash_cooldown_remaining = loadout.weapon.dash_cooldown
	trigger_action_pulse(Color(0.94, 0.84, 0.5, 1.0), 0.18)
	if game_context != null:
		game_context.register_action(combatant_id, "dash", "Dash")

func _use_skill(index: int) -> void:
	if loadout == null:
		return
	if index < 0 or index >= loadout.skills.size():
		return
	if skill_cooldowns[index] > 0.0:
		return

	var skill: SkillDefinitionResource = loadout.skills[index]
	if skill == null:
		return

	var origin_position: Vector3 = global_position
	var impact_position: Vector3 = origin_position
	var hit_confirmed: bool = false

	match skill.kind:
		SkillDefinitionResource.SkillKind.PROJECTILE:
			impact_position = _get_target_ground_point(skill.range)
			for hit_target in _get_targets_inside_impact_radius(impact_position, _get_skill_hit_radius(skill)):
				hit_target.take_damage(skill.damage * _get_total_attack_multiplier(), combatant_id)
				hit_confirmed = true
		SkillDefinitionResource.SkillKind.SELF_BUFF:
			impact_position = origin_position
			attack_multiplier = maxf(1.0, skill.value)
			move_multiplier = 1.2
			buff_time_remaining = maxf(skill.duration, 3.5)
		SkillDefinitionResource.SkillKind.AREA_BURST:
			impact_position = origin_position
			for hit_target in _get_targets_inside_impact_radius(impact_position, skill.range):
				hit_target.take_damage(skill.damage * _get_total_attack_multiplier(), combatant_id)
				hit_confirmed = true
		SkillDefinitionResource.SkillKind.LEAP_STRIKE:
			impact_position = _get_target_ground_point(skill.range)
			var toward_impact: Vector3 = impact_position - global_position
			toward_impact.y = 0.0
			if toward_impact.length_squared() > 0.0:
				var travel: float = minf(skill.range, toward_impact.length())
				global_position += toward_impact.normalized() * travel
				impact_position = global_position
			for hit_target in _get_targets_inside_impact_radius(impact_position, _get_skill_hit_radius(skill)):
				hit_target.take_damage(skill.damage * _get_total_attack_multiplier(), combatant_id)
				hit_confirmed = true

	skill_cooldowns[index] = skill.cooldown
	trigger_action_pulse(_skill_pulse_color(skill), 0.22)
	if game_context != null:
		game_context.register_action(combatant_id, "skill", skill.display_name)
	skill_used.emit({
		"slot_index": index,
		"skill_id": String(skill.id),
		"display_name": skill.display_name,
		"skill_kind": int(skill.kind),
		"origin_position": origin_position,
		"impact_position": impact_position,
		"range": skill.range,
		"duration": skill.duration,
		"hit_confirmed": hit_confirmed
	})

func _use_potion(index: int) -> void:
	if loadout == null:
		return
	if index < 0 or index >= loadout.potions.size():
		return
	if potion_cooldowns[index] > 0.0:
		return

	var potion: PotionDefinitionResource = loadout.potions[index]
	if potion == null:
		return

	match potion.kind:
		PotionDefinitionResource.PotionKind.HEAL:
			heal(potion.value)
		PotionDefinitionResource.PotionKind.BARRIER:
			apply_barrier(potion.value, maxf(potion.duration, 3.0))

	potion_cooldowns[index] = potion.cooldown
	trigger_action_pulse(_potion_pulse_color(potion), 0.2)
	if game_context != null:
		game_context.register_action(combatant_id, "potion", potion.display_name)
	potion_used.emit({
		"slot_index": index,
		"potion_id": String(potion.id),
		"display_name": potion.display_name,
		"potion_kind": int(potion.kind)
	})

func _skill_pulse_color(skill: SkillDefinitionResource) -> Color:
	match skill.kind:
		SkillDefinitionResource.SkillKind.PROJECTILE:
			return Color(1.0, 0.78, 0.46, 1.0)
		SkillDefinitionResource.SkillKind.SELF_BUFF:
			return Color(0.52, 0.96, 0.74, 1.0)
		SkillDefinitionResource.SkillKind.AREA_BURST:
			return Color(1.0, 0.52, 0.34, 1.0)
		SkillDefinitionResource.SkillKind.LEAP_STRIKE:
			return Color(0.78, 0.86, 1.0, 1.0)
		_:
			return Color(0.88, 0.88, 0.9, 1.0)

func _potion_pulse_color(potion: PotionDefinitionResource) -> Color:
	match potion.kind:
		PotionDefinitionResource.PotionKind.HEAL:
			return Color(0.42, 0.96, 0.62, 1.0)
		PotionDefinitionResource.PotionKind.BARRIER:
			return Color(0.58, 0.92, 1.0, 1.0)
		_:
			return Color(0.86, 0.86, 0.9, 1.0)

func _get_total_attack_multiplier() -> float:
	return attack_multiplier * level_damage_multiplier

func _get_target_ground_point(max_distance: float) -> Vector3:
	var origin_position: Vector3 = global_position
	var forward: Vector3 = -transform.basis.z
	forward.y = 0.0
	if forward.length_squared() <= 0.0001:
		forward = Vector3.FORWARD
	forward = forward.normalized()

	var override_point: Variant = _resolve_skill_aim_override(max_distance)
	if override_point != null:
		return override_point

	if arena_camera == null:
		return origin_position + forward * max_distance

	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = arena_camera.project_ray_origin(mouse_position)
	var ray_normal: Vector3 = arena_camera.project_ray_normal(mouse_position)
	if absf(ray_normal.y) < 0.001:
		return origin_position + forward * max_distance

	var distance: float = -ray_origin.y / ray_normal.y
	if distance <= 0.0:
		return origin_position + forward * max_distance

	var hit_point: Vector3 = ray_origin + ray_normal * distance
	var flat_target: Vector3 = Vector3(hit_point.x, origin_position.y, hit_point.z)
	var toward_target: Vector3 = flat_target - origin_position
	toward_target.y = 0.0
	if toward_target.length_squared() <= 0.0001:
		return origin_position + forward * max_distance

	if toward_target.length() > max_distance:
		return origin_position + toward_target.normalized() * max_distance
	return flat_target

func _resolve_skill_aim_override(max_distance: float) -> Variant:
	if skill_aim_world_override == null:
		return null

	var override_point: Vector3 = skill_aim_world_override
	override_point.y = global_position.y
	var toward_override: Vector3 = override_point - global_position
	toward_override.y = 0.0
	if toward_override.length_squared() <= 0.0001:
		return global_position
	if toward_override.length() > max_distance:
		return global_position + toward_override.normalized() * max_distance
	return override_point

func _get_targets_inside_impact_radius(impact_position: Vector3, radius: float) -> Array:
	var matches: Array = []
	var flat_impact: Vector3 = Vector3(impact_position.x, global_position.y, impact_position.z)
	for candidate in _get_target_candidates():
		var flat_target: Vector3 = Vector3(candidate.global_position.x, global_position.y, candidate.global_position.z)
		if flat_impact.distance_to(flat_target) <= radius:
			matches.append(candidate)
	return matches

func _get_closest_target_in_range(max_distance: float):
	var selected_target = null
	var selected_distance: float = INF
	for candidate in _get_target_candidates():
		var distance_to_candidate: float = _get_ground_edge_distance_to(candidate)
		if distance_to_candidate > max_distance or distance_to_candidate >= selected_distance:
			continue
		selected_target = candidate
		selected_distance = distance_to_candidate
	return selected_target

func _get_target_candidates() -> Array:
	var candidates: Array = []
	var seen: Dictionary = {}
	for candidate: Variant in [target] + additional_targets:
		if candidate == null or not is_instance_valid(candidate) or candidate.is_dead:
			continue
		var candidate_key: int = candidate.get_instance_id()
		if seen.has(candidate_key):
			continue
		seen[candidate_key] = true
		candidates.append(candidate)
	return candidates

func _get_skill_hit_radius(skill: SkillDefinitionResource) -> float:
	match skill.kind:
		SkillDefinitionResource.SkillKind.PROJECTILE:
			return 1.05
		SkillDefinitionResource.SkillKind.LEAP_STRIKE:
			return 2.25
		_:
			return 0.0

func _get_ground_edge_distance_to(candidate) -> float:
	if candidate == null or not is_instance_valid(candidate):
		return INF
	var center_distance: float = _get_ground_center_distance_to(candidate)
	return maxf(0.0, center_distance - _get_ground_contact_radius(self) - _get_ground_contact_radius(candidate))

func _get_ground_center_distance_to(candidate) -> float:
	var toward_candidate: Vector3 = candidate.global_position - global_position
	toward_candidate.y = 0.0
	return toward_candidate.length()

func _get_ground_contact_radius(target_node: Node3D) -> float:
	if target_node == null or not is_instance_valid(target_node):
		return 0.0
	var collision_shape: CollisionShape3D = target_node.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision_shape == null or collision_shape.shape == null:
		return 0.0
	var horizontal_scale: float = maxf(
		target_node.global_transform.basis.x.length(),
		target_node.global_transform.basis.z.length()
	)
	var shape: Shape3D = collision_shape.shape
	if shape is CapsuleShape3D:
		return (shape as CapsuleShape3D).radius * horizontal_scale
	if shape is SphereShape3D:
		return (shape as SphereShape3D).radius * horizontal_scale
	if shape is CylinderShape3D:
		return (shape as CylinderShape3D).radius * horizontal_scale
	if shape is BoxShape3D:
		var box_shape: BoxShape3D = shape as BoxShape3D
		return maxf(box_shape.size.x, box_shape.size.z) * 0.5 * horizontal_scale
	return 0.0

func _ensure_loadout_slot_arrays() -> void:
	if loadout == null:
		return
	while loadout.skills.size() < SKILL_ACTIONS.size():
		loadout.skills.append(null)
	while loadout.skills.size() > SKILL_ACTIONS.size():
		loadout.skills.pop_back()
	while loadout.potions.size() < POTION_ACTIONS.size():
		loadout.potions.append(null)
	while loadout.potions.size() > POTION_ACTIONS.size():
		loadout.potions.pop_back()
