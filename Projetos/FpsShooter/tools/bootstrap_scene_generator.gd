class_name BootstrapSceneGenerator
extends RefCounted

const ArenaRootScript = preload("res://modes/arena/arena_root.gd")
const ARENA_SCENE_PATH := "res://modes/arena/arena.tscn"

func generate_all() -> Dictionary:
	var root := ArenaRootScript.new()
	root.name = "ArenaRoot"
	var packed := PackedScene.new()
	var pack_result := packed.pack(root)
	if pack_result != OK:
		return {"ok": false, "message": "Failed to pack arena scene: %s" % error_string(pack_result)}
	var save_result := ResourceSaver.save(packed, ARENA_SCENE_PATH)
	if save_result != OK:
		root.free()
		return {"ok": false, "message": "Failed to save arena scene: %s" % error_string(save_result)}
	root.free()
	_normalize_scene_file(ARENA_SCENE_PATH)
	return {"ok": true, "message": "Arena scene generated."}

func _normalize_scene_file(path: String) -> void:
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		return
	var normalized := text.replace(" unique_id=1370895612", "").replace(" unique_id=1442128668", "")
	normalized = RegEx.create_from_string(" unique_id=\\d+").sub(normalized, "", true)
	if normalized == text:
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(normalized)
