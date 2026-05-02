class_name CampaignStageScene
extends Node3D

const CampaignRewardPayload = preload("res://gameplay/profile/campaign_reward_payload.gd")

@export var stage_number: int = 1
@export var stage_id: String = "mission_1"
@export var display_name: String = "Missao 1"
@export var objective_text: String = "Defenda a forja."
@export var is_boss_stage: bool = false
@export var player_spawn_position: Vector3 = Vector3(0.0, 1.05, -6.0)
@export var camera_offset: Vector3 = Vector3(8.4, 18.8, 8.4)
@export var camera_size: float = 15.6
@export var floor_size: Vector3 = Vector3(38.0, 1.0, 32.0)
@export var floor_color: Color = Color(0.2, 0.18, 0.16, 1.0)
@export var floor_emission: Color = Color(0.08, 0.05, 0.04, 1.0)
@export var wall_color: Color = Color(0.26, 0.24, 0.22, 1.0)
@export var wall_emission: Color = Color(0.08, 0.05, 0.05, 1.0)
@export_multiline var prop_specs_json: String = "[]"
@export_multiline var enemy_specs_json: String = "[]"
@export var reward_title: String = ""
@export var reward_summary_lines: PackedStringArray = PackedStringArray()
@export var reward_permanent_skill_unlock_ids: PackedStringArray = PackedStringArray()
@export var reward_permanent_potion_unlock_ids: PackedStringArray = PackedStringArray()
@export var reward_menu_unlock_mode_ids: PackedStringArray = PackedStringArray()
@export var reward_pending_level_increase: int = 0
@export var reward_pending_skill_points: int = 0
@export var reward_marks_tutorial_completed: bool = false

func _ready() -> void:
	_build_environment()

func get_player_spawn_position() -> Vector3:
	return player_spawn_position

func get_camera_offset() -> Vector3:
	return camera_offset

func get_camera_size() -> float:
	return camera_size

func get_enemy_specs() -> Array[Dictionary]:
	return _parse_spec_array(enemy_specs_json)

func build_reward_payload(
	campaign_id: StringName,
	difficulty_id: StringName,
	current_level: int
) -> CampaignRewardPayload:
	var reward_payload := CampaignRewardPayload.new()
	reward_payload.reward_id = "%s:%s:%s" % [String(campaign_id), String(difficulty_id), stage_id]
	reward_payload.campaign_id = campaign_id
	reward_payload.difficulty_id = difficulty_id
	reward_payload.stage_number = maxi(0, stage_number)
	reward_payload.title = reward_title if reward_title != "" else "Mapa %d concluido" % stage_number
	reward_payload.summary_lines = _to_string_array(reward_summary_lines)
	reward_payload.permanent_skill_unlock_ids = _to_string_array(reward_permanent_skill_unlock_ids)
	reward_payload.permanent_potion_unlock_ids = _to_string_array(reward_permanent_potion_unlock_ids)
	reward_payload.menu_unlock_mode_ids = _to_string_array(reward_menu_unlock_mode_ids)
	reward_payload.pending_level_increase = maxi(0, reward_pending_level_increase)
	reward_payload.pending_skill_points = maxi(0, reward_pending_skill_points)
	reward_payload.marks_tutorial_completed = reward_marks_tutorial_completed
	if reward_payload.pending_level_increase > 0 and current_level > 0:
		reward_payload.next_level = current_level + reward_payload.pending_level_increase
	return reward_payload

func _build_environment() -> void:
	var floor_root: StaticBody3D = _ensure_static_body("Floor")
	floor_root.position = Vector3(0.0, -0.5, 0.0)
	var floor_collider: CollisionShape3D = _ensure_collision_shape(floor_root, "CollisionShape3D")
	var floor_shape: BoxShape3D = BoxShape3D.new()
	floor_shape.size = floor_size
	floor_collider.shape = floor_shape
	var floor_mesh: MeshInstance3D = _ensure_mesh_instance(floor_root, "Mesh")
	var floor_box: BoxMesh = BoxMesh.new()
	floor_box.size = floor_size
	floor_mesh.mesh = floor_box
	floor_mesh.material_override = _build_material(floor_color, floor_emission, 0.14)

	var walls_root: Node3D = _ensure_node3d("Walls")
	var half_floor_x: float = floor_size.x * 0.5
	var half_floor_z: float = floor_size.z * 0.5
	_configure_box_structure(
		walls_root,
		"NorthWall",
		Vector3(0.0, 1.25, -half_floor_z - 0.55),
		Vector3(floor_size.x + 3.2, 2.5, 1.1),
		wall_color,
		wall_emission
	)
	_configure_box_structure(
		walls_root,
		"SouthWall",
		Vector3(0.0, 1.25, half_floor_z + 0.55),
		Vector3(floor_size.x + 3.2, 2.5, 1.1),
		wall_color,
		wall_emission
	)
	_configure_box_structure(
		walls_root,
		"WestWall",
		Vector3(-half_floor_x - 0.55, 1.25, 0.0),
		Vector3(1.1, 2.5, floor_size.z + 3.2),
		wall_color,
		wall_emission
	)
	_configure_box_structure(
		walls_root,
		"EastWall",
		Vector3(half_floor_x + 0.55, 1.25, 0.0),
		Vector3(1.1, 2.5, floor_size.z + 3.2),
		wall_color,
		wall_emission
	)

	var props_root: Node3D = _ensure_node3d("Props")
	for prop_spec_variant: Variant in _parse_spec_array(prop_specs_json):
		var prop_spec: Dictionary = Dictionary(prop_spec_variant)
		var prop_position: Vector3 = prop_spec.get("position", Vector3.ZERO)
		var prop_size: Vector3 = prop_spec.get("size", Vector3.ONE)
		var prop_albedo: Color = prop_spec.get("albedo", Color(0.28, 0.26, 0.24, 1.0))
		var prop_emission: Color = prop_spec.get("emission", Color(0.08, 0.05, 0.05, 1.0))
		_configure_box_structure(
			props_root,
			str(prop_spec.get("name", "Prop")),
			prop_position,
			prop_size,
			prop_albedo,
			prop_emission
		)

func _configure_box_structure(
	parent: Node3D,
	node_name: String,
	world_position: Vector3,
	size: Vector3,
	albedo: Color,
	emission: Color
) -> void:
	var body: StaticBody3D = parent.get_node_or_null(node_name) as StaticBody3D
	if body == null:
		body = StaticBody3D.new()
		body.name = node_name
		parent.add_child(body)

	body.position = world_position
	var collider: CollisionShape3D = _ensure_collision_shape(body, "CollisionShape3D")
	var mesh_node: MeshInstance3D = _ensure_mesh_instance(body, "Mesh")
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	mesh_node.mesh = mesh
	mesh_node.material_override = _build_material(albedo, emission, 0.1)

func _build_material(albedo: Color, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo
	material.roughness = 0.92
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	return material

func _ensure_node3d(node_name: String) -> Node3D:
	var existing: Node3D = get_node_or_null(node_name) as Node3D
	if existing != null:
		return existing
	var created := Node3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_static_body(node_name: String) -> StaticBody3D:
	var existing: StaticBody3D = get_node_or_null(node_name) as StaticBody3D
	if existing != null:
		return existing
	var created := StaticBody3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_collision_shape(parent: Node, node_name: String) -> CollisionShape3D:
	var existing: CollisionShape3D = parent.get_node_or_null(node_name) as CollisionShape3D
	if existing != null:
		return existing
	var created := CollisionShape3D.new()
	created.name = node_name
	parent.add_child(created)
	return created

func _ensure_mesh_instance(parent: Node, node_name: String) -> MeshInstance3D:
	var existing: MeshInstance3D = parent.get_node_or_null(node_name) as MeshInstance3D
	if existing != null:
		return existing
	var created := MeshInstance3D.new()
	created.name = node_name
	parent.add_child(created)
	return created

func _parse_spec_array(blob: String) -> Array[Dictionary]:
	var parsed: Variant = str_to_var(blob)
	var result: Array[Dictionary] = []
	if parsed is Array:
		for entry: Variant in parsed:
			result.append(Dictionary(entry).duplicate(true))
	return result

func _to_string_array(values: PackedStringArray) -> Array[String]:
	var result: Array[String] = []
	for value: String in values:
		if value == "":
			continue
		result.append(value)
	return result
