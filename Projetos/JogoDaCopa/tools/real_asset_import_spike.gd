extends SceneTree

const ASSET_PATHS: Array[String] = [
	"res://assets/characters/quaternius_ubc/base/Superhero_Male_FullBody.gltf",
	"res://assets/characters/quaternius_ubc/base/Superhero_Female_FullBody.gltf",
	"res://assets/characters/quaternius_ubc/animations/UAL1_Standard.glb",
]

func _initialize() -> void:
	var failures: int = 0
	for asset_path in ASSET_PATHS:
		if not _inspect_asset(asset_path):
			failures += 1
	quit(failures)

func _inspect_asset(asset_path: String) -> bool:
	print("--- %s" % asset_path)
	var packed_scene := load(asset_path)
	if packed_scene == null or not (packed_scene is PackedScene):
		push_error("Failed to load PackedScene: %s" % asset_path)
		return false
	var instance := (packed_scene as PackedScene).instantiate()
	if instance == null:
		push_error("Failed to instantiate: %s" % asset_path)
		return false
	var skeletons: Array[Skeleton3D] = []
	var animation_players: Array[AnimationPlayer] = []
	var meshes: Array[MeshInstance3D] = []
	_collect_nodes(instance, skeletons, animation_players, meshes)
	for skeleton in skeletons:
		print("Skeleton: %s path=%s bones=%d" % [skeleton.name, instance.get_path_to(skeleton), skeleton.get_bone_count()])
		var bone_names: Array[String] = []
		for bone_index in range(skeleton.get_bone_count()):
			bone_names.append(skeleton.get_bone_name(bone_index))
		print("Bones: %s" % ", ".join(bone_names))
	for mesh_instance in meshes:
		var surface_count := mesh_instance.mesh.get_surface_count() if mesh_instance.mesh != null else 0
		print("Mesh: %s path=%s surfaces=%d" % [mesh_instance.name, instance.get_path_to(mesh_instance), surface_count])
	for animation_player in animation_players:
		var animations := animation_player.get_animation_list()
		print("AnimationPlayer: %s animations=%d" % [animation_player.name, animations.size()])
		for animation_name in animations:
			print("  - %s" % animation_name)
		if animations.size() > 0:
			var animation: Animation = animation_player.get_animation(animations[0])
			var sample_count := mini(animation.get_track_count(), 5)
			for index in range(sample_count):
				print("    track[%d]=%s" % [index, animation.track_get_path(index)])
	var ok := skeletons.size() > 0
	if not ok:
		push_error("No Skeleton3D found in %s" % asset_path)
	instance.free()
	return ok

func _collect_nodes(node: Node, skeletons: Array[Skeleton3D], animation_players: Array[AnimationPlayer], meshes: Array[MeshInstance3D]) -> void:
	if node is Skeleton3D:
		skeletons.append(node)
	if node is AnimationPlayer:
		animation_players.append(node)
	if node is MeshInstance3D:
		meshes.append(node)
	for child in node.get_children():
		_collect_nodes(child, skeletons, animation_players, meshes)
