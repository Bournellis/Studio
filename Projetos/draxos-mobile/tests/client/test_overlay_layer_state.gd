extends GutTest

const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const OverlayLayerStateScript := preload("res://modes/boot/ui/overlay_layer_state.gd")

func test_routes_panel_between_menu_and_arena_layers() -> void:
	var refs := _build_overlay_layer_state_fixture()
	var state = refs.get("state")
	var menu_layer := refs.get("menu_layer") as Control
	var arena_layer := refs.get("arena_layer") as Control
	var modal_layer := refs.get("modal_layer") as Control
	var modal_backdrop := refs.get("modal_backdrop") as Control
	var panel := refs.get("panel") as PanelContainer
	var confirm_panel := refs.get("confirm_panel") as PanelContainer

	assert_eq(state.top_layer_name(false, true), "menu")
	assert_eq(state.layer_name_for_control(panel), "menu")

	state.apply_route_layer(AppShellRouteContractScript.ROUTE_ARENA_ACTIVE)
	await wait_process_frames(1)

	assert_true(arena_layer.visible)
	assert_false(menu_layer.visible)
	assert_true(panel.get_parent() == arena_layer)
	assert_eq(panel.name, "ModeShellArenaFullscreenPanel")
	assert_eq(state.top_layer_name(false, true), "arena_fullscreen")
	assert_eq(state.layer_name_for_control(panel), "arena_fullscreen")
	assert_true(bool(state.panel_diagnostics(AppShellRouteContractScript.ROUTE_ARENA_ACTIVE).get("fullscreen", false)))

	state.sync_modal_visibility(true)
	await wait_process_frames(1)

	assert_true(modal_layer.visible)
	assert_true(modal_backdrop.visible)
	assert_true(confirm_panel.visible)
	assert_eq(state.top_layer_name(true, true), "modal")
	assert_true(bool(state.modal_diagnostics(true).get("topmost", false)))

func test_uses_topmost_layer_for_hit_testing() -> void:
	var refs := _build_overlay_layer_state_fixture()
	var state = refs.get("state")
	var menu_button := refs.get("menu_button") as Button
	var arena_button := refs.get("arena_button") as Button
	var modal_button := refs.get("modal_button") as Button
	var point := Vector2(40, 40)

	await wait_process_frames(1)
	assert_true(state.top_control_at_point(point, false, true) == menu_button)

	state.apply_route_layer(AppShellRouteContractScript.ROUTE_ARENA_ACTIVE)
	await wait_process_frames(1)
	assert_true(state.top_control_at_point(point, false, true) == arena_button)

	state.sync_modal_visibility(true)
	await wait_process_frames(1)
	assert_true(state.top_control_at_point(point, true, true) == modal_button)

func _build_overlay_layer_state_fixture() -> Dictionary:
	var root := Control.new()
	root.name = "LayerStateFixtureRoot"
	root.size = Vector2(320, 240)
	add_child_autofree(root)

	var menu_layer := Control.new()
	menu_layer.name = "ModeShellMenuLayer"
	menu_layer.size = root.size
	root.add_child(menu_layer)

	var arena_layer := Control.new()
	arena_layer.name = "ModeShellArenaFullscreenLayer"
	arena_layer.size = root.size
	arena_layer.visible = false
	root.add_child(arena_layer)

	var modal_layer := Control.new()
	modal_layer.name = "ModeShellModalLayer"
	modal_layer.size = root.size
	modal_layer.visible = false
	root.add_child(modal_layer)

	var modal_backdrop := ColorRect.new()
	modal_backdrop.name = "ModeShellModalBackdrop"
	modal_backdrop.size = root.size
	modal_backdrop.visible = false
	modal_layer.add_child(modal_backdrop)

	var panel := PanelContainer.new()
	panel.name = "ModeShellMenuPanel"
	panel.position = Vector2(12, 12)
	panel.size = Vector2(160, 96)
	menu_layer.add_child(panel)

	var confirm_panel := PanelContainer.new()
	confirm_panel.name = "ModeShellMenuConfirmPanel"
	confirm_panel.position = Vector2(12, 12)
	confirm_panel.size = Vector2(160, 96)
	confirm_panel.visible = false
	modal_layer.add_child(confirm_panel)

	var menu_button := Button.new()
	menu_button.name = "MenuButton"
	menu_button.text = "Menu"
	menu_button.position = Vector2(20, 20)
	menu_button.size = Vector2(96, 44)
	menu_layer.add_child(menu_button)

	var arena_button := Button.new()
	arena_button.name = "ArenaButton"
	arena_button.text = "Arena"
	arena_button.position = Vector2(20, 20)
	arena_button.size = Vector2(96, 44)
	arena_layer.add_child(arena_button)

	var modal_button := Button.new()
	modal_button.name = "ModalButton"
	modal_button.text = "Modal"
	modal_button.position = Vector2(20, 20)
	modal_button.size = Vector2(96, 44)
	confirm_panel.add_child(modal_button)

	var state = OverlayLayerStateScript.new()
	state.bind(root, menu_layer, arena_layer, modal_layer, modal_backdrop, panel, confirm_panel)
	return {
		"state": state,
		"menu_layer": menu_layer,
		"arena_layer": arena_layer,
		"modal_layer": modal_layer,
		"modal_backdrop": modal_backdrop,
		"panel": panel,
		"confirm_panel": confirm_panel,
		"menu_button": menu_button,
		"arena_button": arena_button,
		"modal_button": modal_button,
	}
