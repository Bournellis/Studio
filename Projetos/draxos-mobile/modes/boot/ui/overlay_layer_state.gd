class_name DraxosOverlayLayerState
extends RefCounted

const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")

var _root: Control
var _menu_layer: Control
var _arena_fullscreen_layer: Control
var _modal_layer: Control
var _modal_backdrop: Control
var _panel: PanelContainer
var _confirm_panel: PanelContainer

func bind(
		root: Control,
		menu_layer: Control,
		arena_fullscreen_layer: Control,
		modal_layer: Control,
		modal_backdrop: Control,
		panel: PanelContainer,
		confirm_panel: PanelContainer
) -> void:
	_root = root
	_menu_layer = menu_layer
	_arena_fullscreen_layer = arena_fullscreen_layer
	_modal_layer = modal_layer
	_modal_backdrop = modal_backdrop
	_panel = panel
	_confirm_panel = confirm_panel

func clear() -> void:
	_root = null
	_menu_layer = null
	_arena_fullscreen_layer = null
	_modal_layer = null
	_modal_backdrop = null
	_panel = null
	_confirm_panel = null

func route_uses_arena_fullscreen(route_id: String) -> bool:
	var normalized := AppShellRouteContractScript.normalize(route_id)
	return normalized == AppShellRouteContractScript.ROUTE_ARENA_ACTIVE or normalized == AppShellRouteContractScript.ROUTE_ARENA_REPLAY

func sync_layer_rects() -> void:
	for layer in [_menu_layer, _arena_fullscreen_layer, _modal_layer, _modal_backdrop]:
		var control := layer as Control
		if _is_valid_control(control):
			control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func apply_route_layer(route_id: String) -> void:
	if not _is_valid_control(_panel):
		return
	var use_arena_layer := route_uses_arena_fullscreen(route_id)
	var target_parent: Node = _arena_fullscreen_layer if use_arena_layer else _menu_layer
	if _is_valid_control(target_parent as Control) and _panel.get_parent() != target_parent:
		var current_parent := _panel.get_parent()
		if current_parent != null:
			current_parent.remove_child(_panel)
		target_parent.add_child(_panel)
	_panel.name = "ModeShellArenaFullscreenPanel" if use_arena_layer else "ModeShellMenuPanel"
	show_arena_fullscreen_layer(use_arena_layer)
	if _is_valid_control(_menu_layer):
		_menu_layer.visible = not use_arena_layer
		_menu_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_arena_fullscreen_layer(visible: bool) -> void:
	if not _is_valid_control(_arena_fullscreen_layer):
		return
	_arena_fullscreen_layer.visible = visible
	_arena_fullscreen_layer.mouse_filter = Control.MOUSE_FILTER_STOP if visible else Control.MOUSE_FILTER_IGNORE
	if visible:
		_arena_fullscreen_layer.move_to_front()
		if _is_valid_control(_modal_layer):
			_modal_layer.move_to_front()

func sync_modal_visibility(pending: bool) -> void:
	if _is_valid_control(_modal_layer):
		_modal_layer.visible = pending
		_modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP if pending else Control.MOUSE_FILTER_IGNORE
		if pending:
			_modal_layer.move_to_front()
	if _is_valid_control(_modal_backdrop):
		_modal_backdrop.visible = pending
	if _is_valid_control(_confirm_panel):
		_confirm_panel.visible = pending
		if pending:
			_confirm_panel.move_to_front()

func top_layer_name(confirmation_pending: bool, overlay_open: bool) -> String:
	if confirmation_pending:
		return "modal"
	if _is_valid_control(_arena_fullscreen_layer) and _arena_fullscreen_layer.visible:
		return "arena_fullscreen"
	if overlay_open:
		return "menu"
	return "none"

func panel_diagnostics(route_id: String) -> Dictionary:
	if not _is_valid_control(_panel):
		return {}
	var rect := _panel.get_global_rect()
	return {
		"x": rect.position.x,
		"y": rect.position.y,
		"width": rect.size.x,
		"height": rect.size.y,
		"layer": layer_name_for_control(_panel),
		"fullscreen": route_uses_arena_fullscreen(route_id),
	}

func arena_fullscreen_diagnostics() -> Dictionary:
	if not _is_valid_control(_arena_fullscreen_layer):
		return {}
	var rect := _arena_fullscreen_layer.get_global_rect()
	return {
		"visible": _arena_fullscreen_layer.visible,
		"x": rect.position.x,
		"y": rect.position.y,
		"width": rect.size.x,
		"height": rect.size.y,
		"children": _arena_fullscreen_layer.get_child_count(),
	}

func modal_diagnostics(confirmation_pending: bool) -> Dictionary:
	if not _is_valid_control(_modal_layer):
		return {}
	var rect := _modal_layer.get_global_rect()
	var confirm_rect := Rect2()
	if _is_valid_control(_confirm_panel):
		confirm_rect = _confirm_panel.get_global_rect()
	return {
		"visible": _modal_layer.visible,
		"x": rect.position.x,
		"y": rect.position.y,
		"width": rect.size.x,
		"height": rect.size.y,
		"confirm_x": confirm_rect.position.x,
		"confirm_y": confirm_rect.position.y,
		"confirm_width": confirm_rect.size.x,
		"confirm_height": confirm_rect.size.y,
		"topmost": confirmation_pending and top_layer_name(confirmation_pending, _is_valid_control(_root)) == "modal",
	}

func control_visible_rect(control: Control) -> Rect2:
	if not _is_valid_control(control) or not control.visible or not control.is_visible_in_tree():
		return Rect2()
	var rect := control.get_global_rect()
	var cursor := control.get_parent()
	while cursor != null:
		if cursor is Control:
			var parent_control := cursor as Control
			if parent_control is ScrollContainer or parent_control.clip_contents:
				rect = rect.intersection(parent_control.get_global_rect())
				if rect.size.x <= 0.0 or rect.size.y <= 0.0:
					return Rect2()
		if cursor == _root:
			break
		cursor = cursor.get_parent()
	return rect

func top_control_at_point(point: Vector2, confirmation_pending: bool, overlay_open: bool) -> Control:
	var layer := top_layer_name(confirmation_pending, overlay_open)
	match layer:
		"modal":
			return _find_top_control_at_point(_modal_layer, point)
		"arena_fullscreen":
			return _find_top_control_at_point(_arena_fullscreen_layer, point)
		"menu":
			return _find_top_control_at_point(_menu_layer, point)
		_:
			return null

func layer_name_for_control(control: Control) -> String:
	if control == null:
		return "none"
	if _is_descendant_of(control, _modal_layer):
		return "modal"
	if _is_descendant_of(control, _arena_fullscreen_layer):
		return "arena_fullscreen"
	if _is_descendant_of(control, _menu_layer):
		return "menu"
	return "none"

func _find_top_control_at_point(node: Node, point: Vector2) -> Control:
	if node == null:
		return null
	for index in range(node.get_child_count() - 1, -1, -1):
		var child := node.get_child(index)
		var found := _find_top_control_at_point(child, point)
		if found != null:
			return found
	if node is Button:
		var button := node as Button
		if button.visible and button.is_visible_in_tree() and control_visible_rect(button).has_point(point):
			return button
	elif node is LineEdit:
		var input := node as LineEdit
		if input.visible and input.is_visible_in_tree() and control_visible_rect(input).has_point(point):
			return input
	return null

func _is_descendant_of(node: Node, ancestor: Node) -> bool:
	if node == null or ancestor == null:
		return false
	var cursor := node
	while cursor != null:
		if cursor == ancestor:
			return true
		cursor = cursor.get_parent()
	return false

func _is_valid_control(control: Control) -> bool:
	return control != null and is_instance_valid(control)
