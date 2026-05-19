@tool
extends SceneTree

func _initialize() -> void:
	var root := Control.new()
	root.name = "Boot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.script = load("res://modes/boot/boot.gd")

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	center.owner = root

	var panel := VBoxContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(420, 240)
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(panel)
	panel.owner = root

	var title := Label.new()
	title.name = "StatusLabel"
	title.unique_name_in_owner = true
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "DraxosMobile"
	panel.add_child(title)
	title.owner = root

	var actions := VBoxContainer.new()
	actions.name = "ActionList"
	actions.unique_name_in_owner = true
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(actions)
	actions.owner = root

	var scene := PackedScene.new()
	var result := scene.pack(root)
	if result != OK:
		push_error("Failed to pack boot scene: %s" % result)
		quit(1)
		return

	var save_result := ResourceSaver.save(scene, "res://modes/boot/boot.tscn")
	if save_result != OK:
		push_error("Failed to save boot scene: %s" % save_result)
		quit(1)
		return

	print("Generated res://modes/boot/boot.tscn")
	quit(0)
