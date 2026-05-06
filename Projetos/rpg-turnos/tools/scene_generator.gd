class_name SceneGenerator
extends RefCounted

const SCENES: Array[Dictionary] = [
	{"path": "res://modes/boot/boot.tscn", "script": "res://modes/boot/boot_root.gd", "type": "control"},
	{"path": "res://modes/world/world.tscn", "script": "res://modes/world/world_root.gd", "type": "node2d"},
	{"path": "res://modes/battle/deck_setup.tscn", "script": "res://modes/battle/deck_setup_root.gd", "type": "control"},
	{"path": "res://modes/battle/battle.tscn", "script": "res://modes/battle/battle_root.gd", "type": "control"},
	{"path": "res://modes/battle/result.tscn", "script": "res://modes/battle/result_root.gd", "type": "control"}
]

func generate_all() -> Dictionary:
	for scene_spec: Dictionary in SCENES:
		var scene_path: String = str(scene_spec.get("path", ""))
		var script_path: String = str(scene_spec.get("script", ""))
		if ResourceLoader.exists(scene_path):
			var repair_result: Error = _repair_scene(scene_path, script_path, str(scene_spec.get("type", "control")))
			if repair_result != OK:
				return {"ok": false, "message": "Failed to repair scene %s." % scene_path}
			continue
		var result: Error = _save_scene(scene_path, script_path, str(scene_spec.get("type", "control")))
		if result != OK:
			return {"ok": false, "message": "Failed to generate scene %s." % scene_path}
	return {"ok": true, "message": "Playable slice scenes exist or were generated."}

func _repair_scene(scene_path: String, script_path: String, node_type: String) -> Error:
	if node_type != "control":
		return OK
	var packed_scene: PackedScene = load(scene_path)
	if packed_scene == null:
		return ERR_FILE_CANT_OPEN
	var root_node: Node = packed_scene.instantiate()
	if root_node == null:
		return ERR_CANT_CREATE
	if root_node is Control:
		_prepare_control_root(root_node)
		var script_resource: Script = load(script_path)
		if script_resource == null:
			root_node.free()
			return ERR_FILE_CANT_OPEN
		root_node.set_script(script_resource)
		var repacked_scene: PackedScene = PackedScene.new()
		var pack_error: Error = repacked_scene.pack(root_node)
		root_node.free()
		if pack_error != OK:
			return pack_error
		return ResourceSaver.save(repacked_scene, scene_path)
	root_node.free()
	return OK

func _save_scene(scene_path: String, script_path: String, node_type: String) -> Error:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(scene_path.get_base_dir()))
	var root_node: Node = _create_root_node(node_type)
	root_node.name = scene_path.get_file().get_basename().capitalize()

	var script_resource: Script = load(script_path)
	if script_resource == null:
		root_node.free()
		return ERR_FILE_CANT_OPEN
	root_node.set_script(script_resource)

	var packed_scene: PackedScene = PackedScene.new()
	var pack_error: Error = packed_scene.pack(root_node)
	root_node.free()
	if pack_error != OK:
		return pack_error
	return ResourceSaver.save(packed_scene, scene_path)

func _create_root_node(node_type: String) -> Node:
	if node_type == "node2d":
		return Node2D.new()
	var root: Control = Control.new()
	_prepare_control_root(root)
	return root

func _prepare_control_root(root: Control) -> void:
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
