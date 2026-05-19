extends Control

const ProjectInfoScript := preload("res://core/project_info.gd")

@onready var status_label: Label = %StatusLabel
@onready var action_list: VBoxContainer = %ActionList

func _ready() -> void:
	status_label.text = "%s - MVP tecnico minimo" % ProjectInfoScript.PROJECT_NAME
	_build_action_buttons()

func _build_action_buttons() -> void:
	for action in ProjectInfoScript.boot_actions():
		var button := Button.new()
		button.text = action
		button.custom_minimum_size = Vector2(320, 48)
		button.disabled = true
		action_list.add_child(button)
