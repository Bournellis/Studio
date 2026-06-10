class_name BootstrapSceneGenerator
extends RefCounted

const ArenaRootScript = preload("res://modes/arena/arena_root.gd")
const FootballRootScript = preload("res://modes/football/football_root.gd")
const MainMenuRootScript = preload("res://modes/menu/main_menu_root.gd")

const MENU_SCENE_PATH := "res://modes/menu/main_menu.tscn"
const ARENA_SCENE_PATH := "res://modes/arena/arena.tscn"
const FOOTBALL_SCENE_PATH := "res://modes/football/football.tscn"

func generate_all() -> Dictionary:
	var menu_result := _pack_scene(MainMenuRootScript, "MainMenuRoot", MENU_SCENE_PATH)
	if not bool(menu_result.get("ok", false)):
		return menu_result
	var arena_result := _pack_scene(ArenaRootScript, "ArenaRoot", ARENA_SCENE_PATH)
	if not bool(arena_result.get("ok", false)):
		return arena_result
	var football_result := _pack_scene(FootballRootScript, "FootballRoot", FOOTBALL_SCENE_PATH)
	if not bool(football_result.get("ok", false)):
		return football_result
	return {"ok": true, "message": "FPS Playground scenes generated."}

func _pack_scene(script: Script, root_name: String, scene_path: String) -> Dictionary:
	var root := script.new() as Node
	root.name = root_name
	var packed := PackedScene.new()
	var pack_result := packed.pack(root)
	if pack_result != OK:
		root.free()
		return {"ok": false, "message": "Failed to pack %s: %s" % [scene_path, error_string(pack_result)]}
	var save_result := ResourceSaver.save(packed, scene_path)
	if save_result != OK:
		root.free()
		return {"ok": false, "message": "Failed to save %s: %s" % [scene_path, error_string(save_result)]}
	root.free()
	_normalize_scene_file(scene_path)
	return {"ok": true, "message": "%s generated." % scene_path}

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
