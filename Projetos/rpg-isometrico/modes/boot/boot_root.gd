class_name BootRoot
extends Control

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

var status_label: Label

func _init() -> void:
	_ensure_status_label()

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	call_deferred("_route_initial_scene")

func resolve_initial_scene_path() -> String:
	return LocalModeCatalog.FRONTEND_SCENE_PATH

func _route_initial_scene() -> void:
	if status_label != null:
		status_label.text = "Preparando o menu principal..."
	get_tree().change_scene_to_file(resolve_initial_scene_path())

func _ensure_status_label() -> void:
	if status_label != null:
		return

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Preparando o bootstrap..."
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.anchor_left = 0.0
	status_label.anchor_top = 0.0
	status_label.anchor_right = 1.0
	status_label.anchor_bottom = 1.0
	add_child(status_label)

func _profile_store() -> Node:
	if is_inside_tree():
		return get_node_or_null("/root/ProfileStore")

	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop.root.get_node_or_null("ProfileStore")
	return null
