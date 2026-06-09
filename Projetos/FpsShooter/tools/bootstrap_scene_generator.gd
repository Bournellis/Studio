class_name BootstrapSceneGenerator
extends RefCounted

const ArenaRootScript = preload("res://modes/arena/arena_root.gd")

func generate_all() -> Dictionary:
	var root := ArenaRootScript.new()
	root.name = "ArenaRoot"
	var packed := PackedScene.new()
	var pack_result := packed.pack(root)
	if pack_result != OK:
		return {"ok": false, "message": "Failed to pack arena scene: %s" % error_string(pack_result)}
	var save_result := ResourceSaver.save(packed, "res://modes/arena/arena.tscn")
	if save_result != OK:
		root.free()
		return {"ok": false, "message": "Failed to save arena scene: %s" % error_string(save_result)}
	root.free()
	return {"ok": true, "message": "Arena scene generated."}
