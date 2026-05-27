extends GutTest

const BootScreenScript = preload("res://modes/boot/boot.gd")

func after_each() -> void:
	ProjectSettings.set_setting("draxos_mobile/ui/force_compact_layout", false)

func test_boot_compact_layout_groups_actions_for_mobile_landscape() -> void:
	ProjectSettings.set_setting("draxos_mobile/ui/force_compact_layout", true)
	var boot = BootScreenScript.new()
	add_child_autofree(boot)

	assert_true(boot._compact_layout)
	assert_eq(boot._action_button_columns(), 3)
	assert_eq(boot._base_map_columns(), 6)
	var hub_button := boot._nav_buttons["hub"] as Button
	assert_true(hub_button.custom_minimum_size.y >= 48.0)

	var action_grid := _first_action_grid(boot._content_body)
	assert_not_null(action_grid)
	assert_eq(action_grid.columns, 3)
	var sign_up_button := boot._action_buttons["email_sign_up"] as Button
	assert_true(sign_up_button.custom_minimum_size.y >= 48.0)
	assert_false(_has_direct_button_child(boot._content_body))

func _first_action_grid(parent: Node) -> GridContainer:
	for child: Node in parent.get_children():
		if child is GridContainer:
			return child
	return null

func _has_direct_button_child(parent: Node) -> bool:
	for child: Node in parent.get_children():
		if child is Button:
			return true
	return false
