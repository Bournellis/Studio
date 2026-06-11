class_name PlayerAvatar3D
extends Node3D

const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const AvatarUniformShader = preload("res://gameplay/avatar/avatar_uniform.gdshader")

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
const DEFAULT_BOOT_COLOR: Color = Color(0.04, 0.045, 0.05, 1.0)
const ROOT_MOTION_BONE: StringName = &"root"
const MODEL_FORWARD_COMPENSATION_YAW: float = PI
const MOVEMENT_FACING_SPEED_THRESHOLD: float = 0.5
const MOVEMENT_FACING_LERP_SPEED: float = 10.0
const REGION_COLOR_SCALE: float = 1.0 / 8.0
const REGION_UNKNOWN: int = 0
const REGION_SKIN: int = 1
const REGION_SHIRT: int = 2
const REGION_SHORTS: int = 3
const REGION_SOCK: int = 4
const REGION_BOOT: int = 5
const HEAD_BONE_NAME: StringName = &"Head"
const HAIR_ATTACHMENT_NAME: StringName = &"HairAttachment"
const KICK_TIMES: Array[float] = [0.0, 0.09, 0.18, 0.27, 0.36]

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
	&"hair",
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
var hair_attachment: BoneAttachment3D
var hair_meshes: Array[MeshInstance3D] = []
var active_hair_style_id: StringName = &""
var active_hair_color_id: StringName = &""
var body_region_vertex_counts: Dictionary = {}
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
	hair_attachment = null
	hair_meshes.clear()
	active_hair_style_id = &""
	active_hair_color_id = &""
	body_region_vertex_counts.clear()
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
	var hair_style_id := _resolve_hair_style_id(appearance.hair_style_id)
	var hair_color_id := _resolve_hair_color_id(appearance.hair_color_id)
	var hair_color: Color = AvatarCatalogScript.get_hair_color_value(hair_color_id)
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
	logical_part_colors[&"left_foot"] = DEFAULT_BOOT_COLOR
	logical_part_colors[&"right_foot"] = DEFAULT_BOOT_COLOR
	logical_part_colors[&"hair"] = hair_color
	_apply_real_materials(skin_color, shirt_primary, shirt_secondary, shorts_color, socks_color, DEFAULT_BOOT_COLOR)
	_sync_hair_attachment(hair_style_id, hair_color_id, hair_color)
	_sync_toon_outline_passes()

func set_toon_render_enabled(is_enabled: bool) -> void:
	toon_render_enabled = is_enabled
	if part_root != null:
		apply_appearance(appearance)
		_sync_toon_outline_passes()

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
	animation_timer = 0.38 if strong else 0.35
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

func debug_get_hair_style_id() -> StringName:
	return active_hair_style_id

func debug_get_hair_color_id() -> StringName:
	return active_hair_color_id

func debug_get_skin_color() -> Color:
	return AvatarCatalogScript.get_skin_color(appearance.skin_tone_id)

func debug_get_shirt_primary_color() -> Color:
	return AvatarCatalogScript.get_kit_primary_color(appearance.country_kit_id)

func debug_get_part_albedo_color(part_id: StringName) -> Color:
	return logical_part_colors.get(part_id, Color.TRANSPARENT)

func debug_get_region_id_for_part(part_id: StringName) -> int:
	return _get_uniform_region_id_for_part(part_id)

func debug_get_region_vertex_count(region_id: int) -> int:
	return int(body_region_vertex_counts.get(region_id, 0))

func debug_find_body_vertex_color_for_region(region_id: int) -> Color:
	if body_mesh == null or body_mesh.mesh == null:
		return Color.TRANSPARENT
	var mesh := body_mesh.mesh as ArrayMesh
	if mesh == null:
		return Color.TRANSPARENT
	for surface_index in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface_index)
		if arrays.size() <= Mesh.ARRAY_COLOR:
			continue
		var colors := arrays[Mesh.ARRAY_COLOR] as PackedColorArray
		for color in colors:
			if _decode_region_color(color) == region_id:
				return color
	return Color.TRANSPARENT

func debug_get_body_uniform_shader_color(parameter_name: StringName) -> Color:
	var material := _get_body_uniform_material(0)
	if material == null:
		return Color.TRANSPARENT
	var value: Variant = material.get_shader_parameter(str(parameter_name))
	return value if value is Color else Color.TRANSPARENT

func debug_get_body_uniform_shader_float(parameter_name: StringName) -> float:
	var material := _get_body_uniform_material(0)
	if material == null:
		return 0.0
	var value: Variant = material.get_shader_parameter(str(parameter_name))
	return float(value) if value is float else 0.0

func debug_has_hair_attachment() -> bool:
	return hair_attachment != null and hair_attachment.bone_name == HEAD_BONE_NAME

func debug_get_hair_mesh_count() -> int:
	return hair_meshes.size()

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
		count += _count_mesh_material_next_passes(mesh_instance)
	for mesh_instance in hair_meshes:
		count += _count_mesh_material_next_passes(mesh_instance)
	return count

func debug_get_toon_outline_mesh_node_count() -> int:
	var count := 0
	for mesh_instance in real_meshes:
		if mesh_instance.get_node_or_null("ToonOutline") != null:
			count += 1
	for mesh_instance in hair_meshes:
		if mesh_instance.get_node_or_null("ToonOutline") != null:
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
			var shader_override := mesh_instance.get_surface_override_material(surface_index) as ShaderMaterial
			if override_material != null and override_material.albedo_texture != null:
				count += 1
			elif shader_override != null and shader_override.get_shader_parameter("skin_texture") != null:
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
	else:
		_rebuild_body_mesh_with_uniform_regions()

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
			transition.xfade_time = _get_transition_blend_time(from_state, to_state)
			state_machine.add_transition(str(from_state), str(to_state), transition)
	animation_tree.tree_root = state_machine
	model_instance.add_child(animation_tree)
	animation_tree.active = true
	state_playback = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	if state_playback == null or state_names.is_empty():
		_report_real_avatar_fallback("AnimationTree playback/state list was not created.")

func _get_transition_blend_time(from_state: StringName, to_state: StringName) -> float:
	if to_state == &"kick" or to_state == &"strong_kick":
		return 0.06
	if from_state == &"kick" or from_state == &"strong_kick":
		return 0.11
	if to_state == &"hit" or from_state == &"hit":
		return 0.10
	if to_state == &"slide" or from_state == &"slide" or to_state == &"flip" or from_state == &"flip":
		return 0.10
	return 0.08

func _build_logical_part_map() -> void:
	part_meshes.clear()
	for part_id in LOGICAL_PARTS:
		part_meshes[part_id] = body_mesh

func _apply_real_materials(skin_color: Color, shirt_primary: Color, shirt_secondary: Color, shorts_color: Color, socks_color: Color, boot_color: Color) -> void:
	for mesh_instance in real_meshes:
		if mesh_instance == body_mesh:
			_apply_body_uniform_materials(skin_color, shirt_primary, shirt_secondary, shorts_color, socks_color, boot_color)
			continue
		mesh_instance.material_override = null
		var mesh_name := str(mesh_instance.name).to_lower()
		var tint := skin_color
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

func _apply_body_uniform_materials(skin_color: Color, shirt_primary: Color, shirt_secondary: Color, shorts_color: Color, socks_color: Color, boot_color: Color) -> void:
	if body_mesh == null or body_mesh.mesh == null:
		return
	body_mesh.material_override = null
	for surface_index in range(body_mesh.mesh.get_surface_count()):
		var source_material := body_mesh.mesh.surface_get_material(surface_index) as StandardMaterial3D
		var material := ShaderMaterial.new()
		material.shader = AvatarUniformShader
		material.set_shader_parameter("skin_color", skin_color)
		material.set_shader_parameter("shirt_primary", shirt_primary)
		material.set_shader_parameter("shirt_secondary", shirt_secondary)
		material.set_shader_parameter("shorts_color", shorts_color)
		material.set_shader_parameter("sock_color", socks_color)
		material.set_shader_parameter("boot_color", boot_color)
		material.set_shader_parameter("toon_intensity", 1.0 if toon_render_enabled else 0.0)
		if source_material != null and source_material.albedo_texture != null:
			material.set_shader_parameter("skin_texture", source_material.albedo_texture)
		_set_material_next_pass(material)
		body_mesh.set_surface_override_material(surface_index, material)

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
	_set_material_next_pass(material)

func _sync_toon_outline_passes() -> void:
	for mesh_instance in real_meshes:
		_sync_mesh_material_next_passes(mesh_instance)
	for mesh_instance in hair_meshes:
		_sync_mesh_material_next_passes(mesh_instance)

func _sync_mesh_material_next_passes(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance == null or mesh_instance.mesh == null:
		return
	var override := mesh_instance.material_override
	if override != null:
		_set_material_next_pass(override)
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var material := mesh_instance.get_surface_override_material(surface_index)
		if material != null:
			_set_material_next_pass(material)

func _set_material_next_pass(material: Material) -> void:
	if material == null:
		return
	material.next_pass = _get_toon_outline_material() if toon_render_enabled else null

func _build_character_material(color: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = _quantize_toon_color(color) if toon_render_enabled else color
	material.roughness = 0.78
	material.emission_enabled = true
	material.emission = material.albedo_color if toon_render_enabled else emission
	material.emission_energy_multiplier = maxf(emission_energy, 0.16) if toon_render_enabled else emission_energy
	if toon_render_enabled:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_set_material_next_pass(material)
	return material

func _get_toon_outline_material() -> StandardMaterial3D:
	if toon_outline_material != null:
		return toon_outline_material
	toon_outline_material = StandardMaterial3D.new()
	toon_outline_material.albedo_color = Color(0.012, 0.016, 0.022, 1.0)
	toon_outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	toon_outline_material.cull_mode = BaseMaterial3D.CULL_FRONT
	if _object_has_property(toon_outline_material, "grow_enabled"):
		toon_outline_material.set("grow_enabled", true)
	if _object_has_property(toon_outline_material, "grow_amount"):
		toon_outline_material.set("grow_amount", 0.018)
	return toon_outline_material

func _rebuild_body_mesh_with_uniform_regions() -> void:
	if body_mesh == null or body_mesh.mesh == null:
		return
	var source_mesh := body_mesh.mesh as ArrayMesh
	if source_mesh == null:
		_report_real_avatar_fallback("Body mesh is not an ArrayMesh; uniform region mask skipped.")
		return
	var rebuilt_mesh := ArrayMesh.new()
	body_region_vertex_counts.clear()
	for surface_index in range(source_mesh.get_surface_count()):
		var arrays := source_mesh.surface_get_arrays(surface_index)
		if arrays.size() <= Mesh.ARRAY_VERTEX:
			continue
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var colors := PackedColorArray()
		colors.resize(vertices.size())
		for vertex_index in range(vertices.size()):
			var bone_index := _get_dominant_bone_index(arrays, vertex_index)
			var bone_name := _get_mesh_bone_name(body_mesh, bone_index)
			var region_id := _get_uniform_region_id_for_bone(bone_name)
			colors[vertex_index] = _encode_region_color(region_id)
			body_region_vertex_counts[region_id] = int(body_region_vertex_counts.get(region_id, 0)) + 1
		arrays[Mesh.ARRAY_COLOR] = colors
		var surface_format := source_mesh.surface_get_format(surface_index) | Mesh.ARRAY_FORMAT_COLOR
		rebuilt_mesh.add_surface_from_arrays(source_mesh.surface_get_primitive_type(surface_index), arrays, [], {}, surface_format)
		if rebuilt_mesh.get_surface_count() > surface_index:
			rebuilt_mesh.surface_set_material(surface_index, source_mesh.surface_get_material(surface_index))
	body_mesh.mesh = rebuilt_mesh

func _get_dominant_bone_index(arrays: Array, vertex_index: int) -> int:
	if arrays.size() <= Mesh.ARRAY_WEIGHTS or arrays[Mesh.ARRAY_BONES] == null or arrays[Mesh.ARRAY_WEIGHTS] == null:
		return -1
	var bones = arrays[Mesh.ARRAY_BONES]
	var weights = arrays[Mesh.ARRAY_WEIGHTS]
	var base_index := vertex_index * 4
	var best_bone := -1
	var best_weight := -1.0
	for influence_index in range(4):
		var array_index := base_index + influence_index
		if array_index >= bones.size() or array_index >= weights.size():
			continue
		var weight := float(weights[array_index])
		if weight > best_weight:
			best_weight = weight
			best_bone = int(bones[array_index])
	return best_bone

func _get_mesh_bone_name(mesh_instance: MeshInstance3D, bone_index: int) -> StringName:
	if bone_index < 0:
		return &""
	if mesh_instance.skin != null and bone_index < mesh_instance.skin.get_bind_count():
		var bind_name := str(mesh_instance.skin.get_bind_name(bone_index))
		if not bind_name.is_empty():
			return StringName(bind_name.to_lower())
	if skeleton != null and bone_index < skeleton.get_bone_count():
		return StringName(str(skeleton.get_bone_name(bone_index)).to_lower())
	return &""

func _get_uniform_region_id_for_bone(bone_name: StringName) -> int:
	var lower_name := str(bone_name).to_lower()
	if lower_name == "head" or lower_name.begins_with("neck") or lower_name.begins_with("lowerarm_") or lower_name.begins_with("hand_") or _is_finger_bone_name(lower_name):
		return REGION_SKIN
	if lower_name.begins_with("spine_") or lower_name.begins_with("clavicle_") or lower_name.begins_with("upperarm_"):
		return REGION_SHIRT
	if lower_name == "pelvis" or lower_name.begins_with("thigh_"):
		return REGION_SHORTS
	if lower_name.begins_with("calf_"):
		return REGION_SOCK
	if lower_name.begins_with("foot_") or lower_name.begins_with("ball_"):
		return REGION_BOOT
	return REGION_SHIRT

func _is_finger_bone_name(lower_name: String) -> bool:
	return lower_name.begins_with("index_") or lower_name.begins_with("middle_") or lower_name.begins_with("ring_") or lower_name.begins_with("pinky_") or lower_name.begins_with("thumb_")

func _get_uniform_region_id_for_part(part_id: StringName) -> int:
	match part_id:
		&"head", &"neck", &"left_hand", &"right_hand", &"left_lower_arm", &"right_lower_arm":
			return REGION_SKIN
		&"torso", &"chest_stripe", &"left_upper_arm", &"right_upper_arm":
			return REGION_SHIRT
		&"shorts", &"left_upper_leg", &"right_upper_leg":
			return REGION_SHORTS
		&"left_lower_leg", &"right_lower_leg":
			return REGION_SOCK
		&"left_foot", &"right_foot":
			return REGION_BOOT
		_:
			return REGION_UNKNOWN

func _encode_region_color(region_id: int) -> Color:
	return Color(float(region_id) * REGION_COLOR_SCALE, 0.0, 0.0, 1.0)

func _decode_region_color(color: Color) -> int:
	return int(round(color.r / REGION_COLOR_SCALE))

func _get_body_uniform_material(surface_index: int) -> ShaderMaterial:
	if body_mesh == null:
		return null
	return body_mesh.get_surface_override_material(surface_index) as ShaderMaterial

func _count_mesh_material_next_passes(mesh_instance: MeshInstance3D) -> int:
	if mesh_instance == null or mesh_instance.mesh == null:
		return 0
	var count := 0
	if mesh_instance.material_override != null and mesh_instance.material_override.next_pass != null:
		count += 1
	for surface_index in range(mesh_instance.mesh.get_surface_count()):
		var material := mesh_instance.get_surface_override_material(surface_index)
		if material != null and material.next_pass != null:
			count += 1
	return count

func _object_has_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false

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

func _resolve_hair_style_id(requested_hair_style_id: StringName) -> StringName:
	if requested_hair_style_id != &"":
		return requested_hair_style_id
	return AvatarCatalogScript.BOT_HAIR_STYLE_ID if character_variant == &"female" else AvatarCatalogScript.DEFAULT_HAIR_STYLE_ID

func _resolve_hair_color_id(requested_hair_color_id: StringName) -> StringName:
	if requested_hair_color_id != &"":
		return requested_hair_color_id
	return AvatarCatalogScript.BOT_HAIR_COLOR_ID if character_variant == &"female" else AvatarCatalogScript.DEFAULT_HAIR_COLOR_ID

func _sync_hair_attachment(hair_style_id: StringName, hair_color_id: StringName, hair_color: Color) -> void:
	if skeleton == null:
		return
	if hair_attachment != null and active_hair_style_id == hair_style_id and active_hair_color_id == hair_color_id and not hair_meshes.is_empty():
		_apply_hair_materials(hair_color)
		_sync_toon_outline_passes()
		return
	_clear_hair_meshes()
	if hair_attachment == null:
		hair_attachment = BoneAttachment3D.new()
		hair_attachment.name = HAIR_ATTACHMENT_NAME
		hair_attachment.bone_name = HEAD_BONE_NAME
		skeleton.add_child(hair_attachment)
	var hair_path := AvatarCatalogScript.get_hair_style_path(hair_style_id)
	var packed_scene := load(hair_path) as PackedScene
	if packed_scene == null:
		_report_real_avatar_fallback("Failed to load hair style '%s': %s" % [hair_style_id, hair_path])
		return
	var source_root := packed_scene.instantiate()
	var source_meshes: Array[MeshInstance3D] = []
	_collect_meshes(source_root, source_meshes)
	var source_skeleton := _find_skeleton(source_root)
	for source_mesh in source_meshes:
		var hair_mesh := MeshInstance3D.new()
		hair_mesh.name = "Hair_%s" % source_mesh.name
		hair_mesh.mesh = source_mesh.mesh
		hair_mesh.transform = _get_hair_head_local_transform(source_skeleton, source_mesh)
		hair_mesh.visible = not local_first_person
		hair_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		hair_attachment.add_child(hair_mesh)
		hair_meshes.append(hair_mesh)
	source_root.free()
	active_hair_style_id = hair_style_id
	active_hair_color_id = hair_color_id
	_apply_hair_materials(hair_color)
	_sync_toon_outline_passes()

func _clear_hair_meshes() -> void:
	for hair_mesh in hair_meshes:
		if is_instance_valid(hair_mesh):
			if hair_mesh.mesh != null:
				for surface_index in range(hair_mesh.mesh.get_surface_count()):
					hair_mesh.set_surface_override_material(surface_index, null)
			hair_mesh.material_override = null
			hair_mesh.mesh = null
			if hair_mesh.get_parent() != null:
				hair_mesh.get_parent().remove_child(hair_mesh)
			hair_mesh.free()
	hair_meshes.clear()

func _get_hair_head_local_transform(source_skeleton: Skeleton3D, source_mesh: MeshInstance3D) -> Transform3D:
	if source_skeleton == null:
		return source_mesh.transform
	var head_index := source_skeleton.find_bone(str(HEAD_BONE_NAME))
	if head_index < 0:
		return source_mesh.transform
	return source_skeleton.get_bone_global_rest(head_index).affine_inverse() * source_mesh.transform

func _apply_hair_materials(hair_color: Color) -> void:
	for hair_mesh in hair_meshes:
		if not is_instance_valid(hair_mesh) or hair_mesh.mesh == null:
			continue
		for surface_index in range(hair_mesh.mesh.get_surface_count()):
			var source_material := hair_mesh.mesh.surface_get_material(surface_index) as StandardMaterial3D
			var material: StandardMaterial3D
			if source_material != null:
				material = source_material.duplicate(true) as StandardMaterial3D
			else:
				material = _build_character_material(Color.WHITE, hair_color, 0.08)
			_tint_character_material(material, hair_color, hair_color, 0.08)
			hair_mesh.set_surface_override_material(surface_index, material)

func _apply_first_person_visibility() -> void:
	if not local_first_person:
		return
	for mesh_instance in real_meshes:
		mesh_instance.visible = false
	for mesh_instance in hair_meshes:
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
	animation.length = 0.36
	animation.loop_mode = Animation.LOOP_NONE
	_add_rotation_track(animation, "spine_02", [
		Vector3.ZERO,
		Vector3(0.04, -0.08, 0.0),
		Vector3(0.10, -0.18, 0.0),
		Vector3(-0.12, 0.18, 0.0),
		Vector3(-0.04, 0.08, 0.0),
	])
	_add_rotation_track(animation, "thigh_r", [
		Vector3(deg_to_rad(45.0), 0.0, 0.04),
		Vector3(deg_to_rad(75.0), 0.0, 0.05),
		Vector3(deg_to_rad(45.0), 0.0, 0.04),
		Vector3(deg_to_rad(60.0), 0.0, -0.04),
		Vector3(deg_to_rad(45.0), 0.0, -0.02),
	])
	_add_rotation_track(animation, "calf_r", [
		Vector3(deg_to_rad(80.0), 0.0, 0.0),
		Vector3(deg_to_rad(80.0), 0.0, 0.0),
		Vector3(deg_to_rad(80.0), 0.0, 0.0),
		Vector3(deg_to_rad(80.0), 0.0, 0.0),
		Vector3(deg_to_rad(80.0), 0.0, 0.0),
	])
	_add_rotation_track(animation, "foot_r", [
		Vector3(deg_to_rad(-8.0), 0.0, 0.0),
		Vector3(deg_to_rad(12.0), 0.0, 0.0),
		Vector3(deg_to_rad(-24.0), 0.0, 0.0),
		Vector3(deg_to_rad(-30.0), 0.0, 0.0),
		Vector3(deg_to_rad(-8.0), 0.0, 0.0),
	])
	_add_rotation_track(animation, "upperarm_l", [
		Vector3.ZERO,
		Vector3(-0.10, 0.0, -0.14),
		Vector3(-0.26, 0.0, -0.28),
		Vector3(0.22, 0.0, -0.18),
		Vector3(0.12, 0.0, -0.08),
	])
	_add_rotation_track(animation, "upperarm_r", [
		Vector3.ZERO,
		Vector3(0.12, 0.0, 0.10),
		Vector3(0.26, 0.0, 0.24),
		Vector3(-0.14, 0.0, 0.16),
		Vector3(-0.08, 0.0, 0.08),
	])
	return animation

func _add_rotation_track(animation: Animation, bone_name: String, rotations: Array[Vector3]) -> void:
	var track_index := animation.add_track(Animation.TYPE_ROTATION_3D)
	animation.track_set_path(track_index, NodePath("Armature/Skeleton3D:%s" % bone_name))
	animation.track_set_interpolation_type(track_index, Animation.INTERPOLATION_CUBIC)
	for index in range(mini(rotations.size(), KICK_TIMES.size())):
		animation.rotation_track_insert_key(track_index, KICK_TIMES[index], Quaternion.from_euler(rotations[index]))

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

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null
