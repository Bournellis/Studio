class_name PlayerAvatar3D
extends Node3D

const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")

const MALE_MODEL_PATH: String = "res://assets/characters/quaternius_ubc/base/Superhero_Male_FullBody.gltf"
const FEMALE_MODEL_PATH: String = "res://assets/characters/quaternius_ubc/base/Superhero_Female_FullBody.gltf"
const UAL_ANIMATION_LIBRARY_PATH: String = "res://assets/characters/quaternius_ubc/animations/UAL1_Standard.glb"
const REAL_MODEL_SCALE: Vector3 = Vector3(0.92, 0.92, 0.92)
const SPRINT_SPEED_THRESHOLD: float = 9.8
const DEFAULT_STATE: StringName = &"idle"
const KICK_ANIMATION_NAME: StringName = &"JogoDaCopa_Kick"
const RESET_ANIMATION_NAME: StringName = &"RESET"
const EYE_TINT: Color = Color(0.94, 0.96, 1.0, 1.0)
const EYEBROW_TINT: Color = Color(0.075, 0.055, 0.04, 1.0)
const HAIR_EMISSION_TINT: Color = Color(0.08, 0.06, 0.045, 1.0)
const ROOT_MOTION_BONE: StringName = &"root"
const MODEL_FORWARD_COMPENSATION_YAW: float = PI
const MOVEMENT_FACING_SPEED_THRESHOLD: float = 0.5
const MOVEMENT_FACING_LERP_SPEED: float = 10.0

const ANIMATION_BY_STATE: Dictionary = {
	&"idle": &"Idle",
	&"move": &"Jog_Fwd",
	&"sprint": &"Sprint",
	&"jump": &"Jump_Start",
	&"fall": &"Jump",
	&"land": &"Jump_Land",
	&"kick": KICK_ANIMATION_NAME,
	&"strong_kick": KICK_ANIMATION_NAME,
	&"celebrate": &"Dance",
	&"emote": &"Idle_Talking",
	&"hit": &"Hit_Chest",
	&"slide": &"Roll",
	&"flip": &"Roll",
	&"push": &"Push",
}

const LOGICAL_PARTS: Array[StringName] = [
	&"head",
	&"neck",
	&"left_hand",
	&"right_hand",
	&"torso",
	&"chest_stripe",
	&"left_upper_arm",
	&"right_upper_arm",
	&"left_lower_arm",
	&"right_lower_arm",
	&"shorts",
	&"left_upper_leg",
	&"right_upper_leg",
	&"left_lower_leg",
	&"right_lower_leg",
	&"left_foot",
	&"right_foot",
]

@export var local_first_person: bool = false
@export var character_variant: StringName = &"male"

var appearance = AvatarCatalogScript.get_default_appearance()
var part_root: Node3D
var model_instance: Node3D
var skeleton: Skeleton3D
var animation_player: AnimationPlayer
var animation_tree: AnimationTree
var state_machine: AnimationNodeStateMachine
var state_playback: AnimationNodeStateMachinePlayback
var body_mesh: MeshInstance3D
var real_meshes: Array[MeshInstance3D] = []
var part_meshes: Dictionary = {}
var logical_part_colors: Dictionary = {}
var animation_state: StringName = DEFAULT_STATE
var animation_timer: float = 0.0
var last_move_speed: float = 0.0
var last_grounded: bool = true
var last_vertical_velocity: float = 0.0
var boost_trail_particles: GPUParticles3D
var skid_dust_particles: GPUParticles3D
var toon_render_enabled: bool = false
var toon_outline_material: StandardMaterial3D
var loaded_animation_names: Array[StringName] = []
var real_model_fallback_reason: String = ""
var model_instance_spawn_position: Vector3 = Vector3.ZERO
var model_instance_spawn_rotation: Vector3 = Vector3.ZERO
var skeleton_spawn_position: Vector3 = Vector3.ZERO
var skeleton_spawn_rotation: Vector3 = Vector3.ZERO
var movement_facing_enabled: bool = false

func _ready() -> void:
	_build_avatar()
	apply_appearance(appearance)

func _process(delta: float) -> void:
	if animation_timer > 0.0:
		animation_timer = maxf(0.0, animation_timer - delta)
		if animation_timer <= 0.0:
			_update_state_from_motion()

func set_character_variant(next_variant: StringName) -> void:
	character_variant = &"female" if next_variant == &"female" else &"male"
	if part_root == null:
		return
	part_root.queue_free()
	part_root = null
	model_instance = null
	skeleton = null
	animation_player = null
	animation_tree = null
	state_machine = null
	state_playback = null
	body_mesh = null
	real_meshes.clear()
	part_meshes.clear()
	loaded_animation_names.clear()
	real_model_fallback_reason = ""
	boost_trail_particles = null
	skid_dust_particles = null
	_build_avatar()
	apply_appearance(appearance)

func apply_appearance(next_appearance) -> void:
	if next_appearance == null:
		appearance = AvatarCatalogScript.get_default_appearance()
	else:
		appearance = next_appearance.duplicate_appearance()
	if part_root == null:
		return
	var skin_color: Color = AvatarCatalogScript.get_skin_color(appearance.skin_tone_id)
	var shirt_primary: Color = AvatarCatalogScript.get_kit_primary_color(appearance.country_kit_id)
	var shirt_secondary: Color = AvatarCatalogScript.get_kit_secondary_color(appearance.country_kit_id)
	var shorts_color: Color = AvatarCatalogScript.get_kit_shorts_color(appearance.country_kit_id)
	var socks_color: Color = AvatarCatalogScript.get_kit_socks_color(appearance.country_kit_id)
	logical_part_colors[&"head"] = skin_color
	logical_part_colors[&"neck"] = skin_color
	logical_part_colors[&"left_hand"] = skin_color
	logical_part_colors[&"right_hand"] = skin_color
	logical_part_colors[&"torso"] = shirt_primary
	logical_part_colors[&"chest_stripe"] = shirt_secondary
	logical_part_colors[&"left_upper_arm"] = shirt_primary
	logical_part_colors[&"right_upper_arm"] = shirt_primary
	logical_part_colors[&"left_lower_arm"] = skin_color
	logical_part_colors[&"right_lower_arm"] = skin_color
	logical_part_colors[&"shorts"] = shorts_color
	logical_part_colors[&"left_upper_leg"] = shorts_color
	logical_part_colors[&"right_upper_leg"] = shorts_color
	logical_part_colors[&"left_lower_leg"] = socks_color
	logical_part_colors[&"right_lower_leg"] = socks_color
	logical_part_colors[&"left_foot"] = Color(0.04, 0.045, 0.05, 1.0)
	logical_part_colors[&"right_foot"] = Color(0.04, 0.045, 0.05, 1.0)
	_apply_real_materials(skin_color, shirt_primary, shirt_secondary)
	_sync_toon_outline_nodes()

func set_toon_render_enabled(is_enabled: bool) -> void:
	toon_render_enabled = is_enabled
	if part_root != null:
		apply_appearance(appearance)
		_sync_toon_outline_nodes()

func set_move_state(move_speed: float, grounded: bool, vertical_velocity: float = 0.0) -> void:
	last_move_speed = move_speed
	last_grounded = grounded
	last_vertical_velocity = vertical_velocity
	if animation_timer > 0.0:
		return
	_update_state_from_motion()

func set_movement_facing_enabled(is_enabled: bool) -> void:
	movement_facing_enabled = is_enabled

func update_visual_movement_facing(horizontal_velocity: Vector3, logical_parent_yaw: float, delta: float) -> void:
	if not movement_facing_enabled or part_root == null:
		return
	var flat_velocity := Vector3(horizontal_velocity.x, 0.0, horizontal_velocity.z)
	if flat_velocity.length() <= MOVEMENT_FACING_SPEED_THRESHOLD:
		return
	var target_world_yaw := atan2(-flat_velocity.x, -flat_velocity.z)
	var target_local_yaw := wrapf(target_world_yaw - logical_parent_yaw, -PI, PI)
	part_root.rotation.y = lerp_angle(part_root.rotation.y, target_local_yaw, clampf(MOVEMENT_FACING_LERP_SPEED * delta, 0.0, 1.0))

func play_kick(strong: bool = false) -> void:
	animation_timer = 0.34 if strong else 0.28
	_travel_state(&"strong_kick" if strong else &"kick", true)

func play_celebrate() -> void:
	animation_timer = 1.25
	_travel_state(&"celebrate", true)

func play_emote() -> void:
	animation_timer = 1.0
	_travel_state(&"emote", true)

func play_hit() -> void:
	animation_timer = 0.34
	_travel_state(&"hit", true)

func play_slide() -> void:
	animation_timer = 0.38
	_travel_state(&"slide", true)

func play_flip() -> void:
	animation_timer = 0.42
	_travel_state(&"flip", true)

func play_push() -> void:
	animation_timer = 0.55
	_travel_state(&"push", true)

func set_boost_trail_active(is_active: bool) -> void:
	if boost_trail_particles != null:
		boost_trail_particles.emitting = is_active

func set_skid_dust_active(is_active: bool) -> void:
	if skid_dust_particles != null:
		skid_dust_particles.emitting = is_active

func debug_get_part_count() -> int:
	return part_meshes.size()

func debug_has_part(part_name: StringName) -> bool:
	return part_meshes.has(part_name)

func debug_get_animation_state() -> StringName:
	return animation_state

func debug_get_skin_tone_id() -> StringName:
	return appearance.skin_tone_id

func debug_get_country_kit_id() -> StringName:
	return appearance.country_kit_id

func debug_get_skin_color() -> Color:
	return AvatarCatalogScript.get_skin_color(appearance.skin_tone_id)

func debug_get_shirt_primary_color() -> Color:
	return AvatarCatalogScript.get_kit_primary_color(appearance.country_kit_id)

func debug_get_part_albedo_color(part_id: StringName) -> Color:
	return logical_part_colors.get(part_id, Color.TRANSPARENT)

func debug_has_persistent_vfx() -> bool:
	return boost_trail_particles != null and skid_dust_particles != null

func debug_is_boost_trail_emitting() -> bool:
	return boost_trail_particles != null and boost_trail_particles.emitting

func debug_is_skid_dust_emitting() -> bool:
	return skid_dust_particles != null and skid_dust_particles.emitting

func debug_is_toon_render_enabled() -> bool:
	return toon_render_enabled

func debug_get_toon_outline_count() -> int:
	var count := 0
	for mesh_instance in real_meshes:
		var outline := mesh_instance.get_node_or_null("ToonOutline") as MeshInstance3D
		if outline != null and outline.visible:
			count += 1
	return count

func debug_has_real_model() -> bool:
	return model_instance != null and skeleton != null and body_mesh != null and not real_meshes.is_empty()

func debug_get_real_skeleton_bone_count() -> int:
	return skeleton.get_bone_count() if skeleton != null else 0

func debug_has_animation_tree() -> bool:
	return animation_tree != null and animation_tree.active

func debug_get_animation_count() -> int:
	return loaded_animation_names.size()

func debug_has_animation(animation_name: StringName) -> bool:
	return loaded_animation_names.has(animation_name)

func debug_get_character_variant() -> StringName:
	return character_variant

func debug_get_real_model_fallback_reason() -> String:
	return real_model_fallback_reason

func debug_get_model_instance_local_position() -> Vector3:
	return model_instance.position if model_instance != null else Vector3.ZERO

func debug_get_model_instance_local_rotation() -> Vector3:
	return model_instance.rotation if model_instance != null else Vector3.ZERO

func debug_get_skeleton_local_position() -> Vector3:
	return skeleton.position if skeleton != null else Vector3.ZERO

func debug_get_skeleton_local_rotation() -> Vector3:
	return skeleton.rotation if skeleton != null else Vector3.ZERO

func debug_get_visual_heading_yaw() -> float:
	return part_root.rotation.y if part_root != null else 0.0

func debug_get_model_forward_compensation_yaw() -> float:
	return model_instance_spawn_rotation.y

func debug_get_model_front_direction() -> Vector3:
	if model_instance == null:
		return Vector3.FORWARD
	return model_instance.global_transform.basis.z.normalized()

func debug_get_bone_pose_rotation_y(bone_name: StringName) -> float:
	if skeleton == null:
		return 0.0
	var bone_index := skeleton.find_bone(str(bone_name))
	if bone_index < 0:
		return 0.0
	return skeleton.get_bone_pose_rotation(bone_index).get_euler().y

func debug_get_bone_pose_position(bone_name: StringName) -> Vector3:
	if skeleton == null:
		return Vector3.ZERO
	var bone_index := skeleton.find_bone(str(bone_name))
	if bone_index < 0:
		return Vector3.ZERO
	return skeleton.get_bone_pose_position(bone_index)

func debug_animation_has_stripped_root_motion(animation_name: StringName) -> bool:
	if animation_player == null or not loaded_animation_names.has(animation_name):
		return false
	var animation := animation_player.get_animation(animation_name)
	if animation == null:
		return false
	for track_index in range(animation.get_track_count()):
		if _get_animation_bone_from_path(animation.track_get_path(track_index)) == ROOT_MOTION_BONE:
			return false
	return true

func debug_reset_real_model_pose() -> void:
	_reset_real_model_pose()

func debug_get_textured_surface_count() -> int:
	var count := 0
	for mesh_instance in real_meshes:
		count += _count_textured_surfaces(mesh_instance)
	return count

func debug_get_textured_surface_override_count() -> int:
	var count := 0
	for mesh_instance in real_meshes:
		if mesh_instance.mesh == null:
			continue
		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var source_material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if source_material == null or source_material.albedo_texture == null:
				continue
			var override_material := mesh_instance.get_surface_override_material(surface_index) as StandardMaterial3D
			if override_material != null and override_material.albedo_texture != null:
				count += 1
	return count

func _build_avatar() -> void:
	if part_root != null:
		return
	loaded_animation_names.clear()
	real_model_fallback_reason = ""
	part_root = Node3D.new()
	part_root.name = "AvatarParts"
	add_child(part_root)
	_instantiate_real_model()
	_build_animation_player()
	_build_animation_tree()
	_build_logical_part_map()
	_build_persistent_vfx()
	_apply_first_person_visibility()
	_travel_state(DEFAULT_STATE, true)

func _instantiate_real_model() -> void:
	var model_path := FEMALE_MODEL_PATH if character_variant == &"female" else MALE_MODEL_PATH
	var packed_scene := load(model_path)
	if packed_scene == null or not (packed_scene is PackedScene):
		_report_real_avatar_fallback("Failed to load real avatar model: %s" % model_path)
		return
	model_instance = (packed_scene as PackedScene).instantiate() as Node3D
	if model_instance == null:
		_report_real_avatar_fallback("Failed to instantiate real avatar model: %s" % model_path)
		return
	model_instance.name = "RealCharacterModel"
	model_instance.rotation.y = MODEL_FORWARD_COMPENSATION_YAW
	model_instance.scale = REAL_MODEL_SCALE
	part_root.add_child(model_instance)
	model_instance_spawn_position = model_instance.position
	model_instance_spawn_rotation = model_instance.rotation
	skeleton = model_instance.get_node_or_null("Armature/Skeleton3D") as Skeleton3D
	if skeleton == null:
		_report_real_avatar_fallback("Real avatar model has no Skeleton3D: %s" % model_path)
		return
	skeleton_spawn_position = skeleton.position
	skeleton_spawn_rotation = skeleton.rotation
	real_meshes.clear()
	_collect_meshes(model_instance, real_meshes)
	if real_meshes.is_empty():
		_report_real_avatar_fallback("Real avatar model has no MeshInstance3D nodes: %s" % model_path)
		return
	for mesh_instance in real_meshes:
		if str(mesh_instance.name).to_lower().contains("superhero"):
			body_mesh = mesh_instance
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	if body_mesh == null:
		_report_real_avatar_fallback("Real avatar model has no body mesh containing 'superhero': %s" % model_path)

func _build_animation_player() -> void:
	if model_instance == null:
		_report_real_avatar_fallback("Skipped animation build because real model instance is missing.")
		return
	var animation_scene := load(UAL_ANIMATION_LIBRARY_PATH)
	if animation_scene == null or not (animation_scene is PackedScene):
		_report_real_avatar_fallback("Failed to load UAL animation library: %s" % UAL_ANIMATION_LIBRARY_PATH)
		return
	var animation_instance := (animation_scene as PackedScene).instantiate()
	var source_player := _find_animation_player(animation_instance)
	if source_player == null:
		_report_real_avatar_fallback("UAL animation library has no AnimationPlayer")
		animation_instance.free()
		return
	animation_player = AnimationPlayer.new()
	animation_player.name = "RealAnimationPlayer"
	animation_player.root_node = NodePath("..")
	model_instance.add_child(animation_player)
	var library := AnimationLibrary.new()
	for animation_name in source_player.get_animation_list():
		var animation: Animation = source_player.get_animation(animation_name)
		if animation == null:
			_report_real_avatar_fallback("UAL animation is null: %s" % animation_name)
			continue
		var copied_animation := animation.duplicate(true) as Animation
		_remove_root_motion_tracks(copied_animation)
		library.add_animation(animation_name, copied_animation)
		loaded_animation_names.append(StringName(animation_name))
	if loaded_animation_names.is_empty():
		_report_real_avatar_fallback("UAL animation library copied zero animations: %s" % UAL_ANIMATION_LIBRARY_PATH)
	library.add_animation(KICK_ANIMATION_NAME, _build_authorial_kick_animation())
	loaded_animation_names.append(KICK_ANIMATION_NAME)
	library.add_animation(RESET_ANIMATION_NAME, _build_reset_animation())
	loaded_animation_names.append(RESET_ANIMATION_NAME)
	animation_player.add_animation_library("", library)
	animation_instance.free()

func _build_animation_tree() -> void:
	if model_instance == null or animation_player == null:
		_report_real_avatar_fallback("Skipped animation tree because model or animation player is missing.")
		return
	animation_tree = AnimationTree.new()
	animation_tree.name = "RealAnimationTree"
	animation_tree.anim_player = NodePath("../RealAnimationPlayer")
	state_machine = AnimationNodeStateMachine.new()
	var state_names: Array[StringName] = []
	for state: StringName in ANIMATION_BY_STATE.keys():
		var animation_name: StringName = ANIMATION_BY_STATE[state]
		if not loaded_animation_names.has(animation_name):
			_report_real_avatar_fallback("Animation state '%s' missing clip '%s'." % [state, animation_name])
			continue
		var animation_node := AnimationNodeAnimation.new()
		animation_node.animation = animation_name
		state_machine.add_node(str(state), animation_node)
		state_names.append(state)
	for from_state in state_names:
		for to_state in state_names:
			if from_state == to_state:
				continue
			var transition := AnimationNodeStateMachineTransition.new()
			transition.xfade_time = 0.08
			state_machine.add_transition(str(from_state), str(to_state), transition)
	animation_tree.tree_root = state_machine
	model_instance.add_child(animation_tree)
	animation_tree.active = true
	state_playback = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	if state_playback == null or state_names.is_empty():
		_report_real_avatar_fallback("AnimationTree playback/state list was not created.")

func _build_logical_part_map() -> void:
	part_meshes.clear()
	for part_id in LOGICAL_PARTS:
		part_meshes[part_id] = body_mesh

func _apply_real_materials(skin_color: Color, shirt_primary: Color, shirt_secondary: Color) -> void:
	for mesh_instance in real_meshes:
		mesh_instance.material_override = null
		var mesh_name := str(mesh_instance.name).to_lower()
		var tint := shirt_primary.lerp(skin_color, 0.22)
		var emission := shirt_secondary
		var emission_energy := 0.11
		if mesh_name.contains("eyebrow"):
			tint = EYEBROW_TINT
			emission = HAIR_EMISSION_TINT
			emission_energy = 0.04
		elif mesh_name.contains("eye"):
			tint = EYE_TINT
			emission = Color(0.18, 0.28, 0.36, 1.0)
			emission_energy = 0.08
		_apply_surface_material_tint(mesh_instance, tint, emission, emission_energy)

func _apply_surface_material_tint(mesh_instance: MeshInstance3D, tint: Color, emission: Color, emission_energy: float) -> void:
	if mesh_instance.mesh == null:
		return
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var source_material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
		var material: StandardMaterial3D
		if source_material != null:
			material = source_material.duplicate(true) as StandardMaterial3D
		else:
			material = _build_character_material(Color.WHITE, emission, emission_energy)
		_tint_character_material(material, tint, emission, emission_energy)
		mesh_instance.set_surface_override_material(surface_index, material)

func _tint_character_material(material: StandardMaterial3D, tint: Color, emission: Color, emission_energy: float) -> void:
	material.albedo_color = _quantize_toon_color(_multiply_color(material.albedo_color, tint)) if toon_render_enabled else _multiply_color(material.albedo_color, tint)
	material.emission_enabled = true
	material.emission = material.albedo_color if toon_render_enabled else emission
	material.emission_energy_multiplier = maxf(emission_energy, 0.16) if toon_render_enabled else emission_energy
	if toon_render_enabled:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func _sync_toon_outline_nodes() -> void:
	for mesh_instance in real_meshes:
		var outline := mesh_instance.get_node_or_null("ToonOutline") as MeshInstance3D
		if outline == null and toon_render_enabled:
			outline = MeshInstance3D.new()
			outline.name = "ToonOutline"
			outline.mesh = mesh_instance.mesh
			outline.skeleton = mesh_instance.skeleton
			outline.skin = mesh_instance.skin
			outline.scale = Vector3.ONE * 1.025
			outline.material_override = _get_toon_outline_material()
			outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			mesh_instance.add_child(outline)
		if outline != null:
			outline.visible = toon_render_enabled
			outline.mesh = mesh_instance.mesh
			outline.skeleton = mesh_instance.skeleton
			outline.skin = mesh_instance.skin
			outline.material_override = _get_toon_outline_material()

func _build_character_material(color: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = _quantize_toon_color(color) if toon_render_enabled else color
	material.roughness = 0.78
	material.emission_enabled = true
	material.emission = material.albedo_color if toon_render_enabled else emission
	material.emission_energy_multiplier = maxf(emission_energy, 0.16) if toon_render_enabled else emission_energy
	if toon_render_enabled:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _get_toon_outline_material() -> StandardMaterial3D:
	if toon_outline_material != null:
		return toon_outline_material
	toon_outline_material = StandardMaterial3D.new()
	toon_outline_material.albedo_color = Color(0.012, 0.016, 0.022, 1.0)
	toon_outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	toon_outline_material.cull_mode = BaseMaterial3D.CULL_FRONT
	return toon_outline_material

func _quantize_toon_color(color: Color) -> Color:
	return Color(
		floorf(color.r * 3.0 + 0.5) / 3.0,
		floorf(color.g * 3.0 + 0.5) / 3.0,
		floorf(color.b * 3.0 + 0.5) / 3.0,
		color.a
	)

func _multiply_color(base: Color, tint: Color) -> Color:
	return Color(
		clampf(base.r * tint.r, 0.0, 1.0),
		clampf(base.g * tint.g, 0.0, 1.0),
		clampf(base.b * tint.b, 0.0, 1.0),
		base.a * tint.a
	)

func _count_textured_surfaces(mesh_instance: MeshInstance3D) -> int:
	if mesh_instance.mesh == null:
		return 0
	var count := 0
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var source_material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
		if source_material != null and source_material.albedo_texture != null:
			count += 1
	return count

func _apply_first_person_visibility() -> void:
	if not local_first_person:
		return
	for mesh_instance in real_meshes:
		mesh_instance.visible = false

func _update_state_from_motion() -> void:
	if not last_grounded:
		_travel_state(&"jump" if last_vertical_velocity > 0.0 else &"fall")
	elif last_move_speed > SPRINT_SPEED_THRESHOLD:
		_travel_state(&"sprint")
	elif last_move_speed > 0.55:
		_travel_state(&"move")
	else:
		_travel_state(&"idle")

func _travel_state(next_state: StringName, force: bool = false) -> void:
	if not force and animation_state == next_state:
		return
	animation_state = next_state
	_reset_real_model_pose()
	var animation_name: StringName = ANIMATION_BY_STATE.get(next_state, &"Idle")
	if state_playback != null and state_machine != null and state_machine.has_node(str(next_state)):
		state_playback.travel(str(next_state))
	elif animation_player != null and loaded_animation_names.has(animation_name):
		animation_player.play(animation_name)

func _remove_root_motion_tracks(animation: Animation) -> void:
	if animation == null:
		return
	for track_index in range(animation.get_track_count() - 1, -1, -1):
		if _get_animation_bone_from_path(animation.track_get_path(track_index)) == ROOT_MOTION_BONE:
			animation.remove_track(track_index)

func _get_animation_bone_from_path(track_path: NodePath) -> StringName:
	var path_text := str(track_path)
	var separator_index := path_text.rfind(":")
	if separator_index < 0:
		return &""
	return StringName(path_text.substr(separator_index + 1).to_lower())

func _build_reset_animation() -> Animation:
	var animation := Animation.new()
	animation.length = 0.001
	animation.loop_mode = Animation.LOOP_NONE
	return animation

func _reset_real_model_pose() -> void:
	if model_instance != null:
		model_instance.position = model_instance_spawn_position
		model_instance.rotation = model_instance_spawn_rotation
		model_instance.scale = REAL_MODEL_SCALE
	if skeleton != null:
		skeleton.position = skeleton_spawn_position
		skeleton.rotation = skeleton_spawn_rotation
		skeleton.reset_bone_poses()

func _report_real_avatar_fallback(reason: String) -> void:
	real_model_fallback_reason = reason
	push_error("Real avatar fallback on %s variant=%s: %s" % [name, character_variant, reason])

func _build_authorial_kick_animation() -> Animation:
	var animation := Animation.new()
	animation.length = 0.32
	animation.loop_mode = Animation.LOOP_NONE
	_add_rotation_track(animation, "spine_02", [
		Vector3.ZERO,
		Vector3(0.08, -0.16, 0.0),
		Vector3(-0.14, 0.22, 0.0),
		Vector3.ZERO,
	])
	_add_rotation_track(animation, "thigh_r", [
		Vector3.ZERO,
		Vector3(0.74, 0.0, 0.08),
		Vector3(-1.08, 0.0, -0.06),
		Vector3.ZERO,
	])
	_add_rotation_track(animation, "calf_r", [
		Vector3.ZERO,
		Vector3(-0.58, 0.0, 0.0),
		Vector3(0.28, 0.0, 0.0),
		Vector3.ZERO,
	])
	_add_rotation_track(animation, "foot_r", [
		Vector3.ZERO,
		Vector3(0.18, 0.0, 0.0),
		Vector3(-0.34, 0.0, 0.0),
		Vector3.ZERO,
	])
	_add_rotation_track(animation, "upperarm_l", [
		Vector3.ZERO,
		Vector3(-0.18, 0.0, -0.32),
		Vector3(0.28, 0.0, -0.16),
		Vector3.ZERO,
	])
	_add_rotation_track(animation, "upperarm_r", [
		Vector3.ZERO,
		Vector3(0.22, 0.0, 0.26),
		Vector3(-0.18, 0.0, 0.18),
		Vector3.ZERO,
	])
	return animation

func _add_rotation_track(animation: Animation, bone_name: String, rotations: Array[Vector3]) -> void:
	var track_index := animation.add_track(Animation.TYPE_ROTATION_3D)
	animation.track_set_path(track_index, NodePath("Armature/Skeleton3D:%s" % bone_name))
	var times: Array[float] = [0.0, 0.11, 0.22, 0.32]
	for index in range(mini(rotations.size(), times.size())):
		animation.rotation_track_insert_key(track_index, times[index], Quaternion.from_euler(rotations[index]))

func _build_persistent_vfx() -> void:
	if part_root == null:
		return
	if boost_trail_particles == null:
		boost_trail_particles = _create_persistent_particles(
			"BoostTrailParticles",
			Vector3(0.0, 0.32, 0.58),
			Color(0.3, 0.92, 1.0, 1.0),
			54,
			0.26,
			Vector3(0.0, 0.05, 1.0),
			1.25,
			0.04
		)
		part_root.add_child(boost_trail_particles)
	if skid_dust_particles == null:
		skid_dust_particles = _create_persistent_particles(
			"SkidDustParticles",
			Vector3(0.0, 0.08, 0.02),
			Color(0.72, 0.84, 0.68, 0.82),
			28,
			0.28,
			Vector3(0.0, 0.7, 0.12),
			0.75,
			0.055
		)
		part_root.add_child(skid_dust_particles)

func _create_persistent_particles(node_name: String, local_position: Vector3, color: Color, amount: int, lifetime: float, direction: Vector3, speed: float, radius: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = node_name
	particles.position = local_position
	particles.amount = amount
	particles.lifetime = lifetime
	particles.emitting = false
	particles.local_coords = true
	particles.explosiveness = 0.0
	particles.randomness = 0.48
	var process_material := ParticleProcessMaterial.new()
	process_material.gravity = Vector3(0.0, -1.6, 0.0)
	process_material.direction = direction.normalized() if direction.length_squared() > 0.0001 else Vector3.UP
	process_material.initial_velocity_min = speed * 0.35
	process_material.initial_velocity_max = speed
	process_material.spread = 42.0
	process_material.scale_min = 0.18
	process_material.scale_max = 0.5
	particles.process_material = process_material
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = _build_vfx_material(color)
	particles.draw_pass_1 = mesh
	return particles

func _build_vfx_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.35
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _collect_meshes(node: Node, output: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		output.append(node)
	for child in node.get_children():
		_collect_meshes(child, output)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
