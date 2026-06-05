extends SceneTree

const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")
const RouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")

var _failures: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	_expect(RouteContractScript.is_fullscreen_gameplay("mode_shell"), "mode_shell is registered as fullscreen gameplay.")
	_expect(not RouteContractScript.shows_app_chrome("mode_shell"), "mode_shell hides app chrome.")
	for viewport_size: Vector2i in [Vector2i(360, 800), Vector2i(390, 844), Vector2i(432, 936), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		await _check_openworld_screen(viewport_size)
	if not _failures.is_empty():
		for failure: String in _failures:
			printerr("[smoke-openworld-visual-layout] %s" % failure)
		return 1
	print("[smoke-openworld-visual-layout] OK fullscreen contract, joystick, HUD and hidden technical details")
	return 0

func _check_openworld_screen(viewport_size: Vector2i) -> void:
	root.size = viewport_size
	await process_frame
	var screen: Control = ScreenScript.new()
	root.add_child(screen)
	await process_frame
	screen.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen.position = Vector2.ZERO
	screen.size = Vector2(viewport_size)
	screen.call("_layout_overlay")
	await process_frame

	var context := "Openworld %s" % str(viewport_size)
	for node_name: String in [
		"OpenworldForestScreen",
		"OpenworldForestWorldView",
		"OpenworldHudTop",
		"OpenworldInventoryButton",
		"OpenworldDepositButton",
		"OpenworldCompleteButton",
		"OpenworldBackButton",
	]:
		_expect_node_fits(screen, node_name, context)
	_expect(_find_node_by_name(screen, "OpenworldForestWorld2D") is Node2D, "%s has Node2D world." % context)
	_expect(_find_node_by_name(screen, "OpenworldPlayer") is CharacterBody2D, "%s has CharacterBody2D player." % context)
	_expect(_find_node_by_name(screen, "OpenworldBoundaryWalls") is StaticBody2D, "%s has boundary walls." % context)
	_expect(_find_node_by_name(screen, "OpenworldForestBoard") == null, "%s does not use legacy fixed board." % context)
	_expect(_find_node_by_name(screen, "OpenworldTechnicalDetails") == null, "%s hides technical details initially." % context)
	var joystick := _find_node_by_name(screen, "OpenworldVirtualJoystick") as Control
	_expect(joystick != null and not joystick.visible, "%s joystick starts hidden instead of fixed corner." % context)

	var joystick_center := Vector2(viewport_size) * 0.5
	_send_mouse_button(screen, joystick_center, true)
	_send_mouse_motion(screen, joystick_center + Vector2(64, 0))
	await process_frame
	_expect_node_fits(screen, "OpenworldVirtualJoystick", "%s free joystick" % context)
	if joystick != null:
		_expect(joystick.visible, "%s free joystick becomes visible on pointer press." % context)
		_expect((joystick.position + joystick.size * 0.5).distance_to(joystick_center) <= 2.0, "%s free joystick is centered on press point." % context)
	_expect(Vector2(screen.call("get_joystick_vector_for_tests")).x > 0.5, "%s free joystick works away from fixed corner." % context)
	_send_mouse_button(screen, joystick_center + Vector2(64, 0), false)
	await process_frame
	if joystick != null:
		_expect(not joystick.visible, "%s free joystick hides on release." % context)

	var inventory := _find_node_by_name(screen, "OpenworldInventoryButton") as Button
	if inventory != null:
		inventory.pressed.emit()
		await process_frame
		_expect(_find_node_by_name(screen, "OpenworldInventorySheet") != null, "%s opens inventory sheet." % context)
		_expect(_find_node_by_name(screen, "OpenworldTechnicalDetails") == null, "%s keeps technical details collapsed in sheet." % context)

	screen.queue_free()
	await process_frame

func _expect_node_fits(root_node: Node, node_name: String, context: String) -> void:
	var node := _find_node_by_name(root_node, node_name) as Control
	if node == null:
		_failures.append("%s missing node %s." % [context, node_name])
		return
	if not node.is_visible_in_tree():
		return
	var viewport_size := Vector2(root.size)
	var rect := node.get_global_rect()
	var tolerance := 2.0
	if rect.position.x < -tolerance or rect.position.y < -tolerance or rect.end.x > viewport_size.x + tolerance or rect.end.y > viewport_size.y + tolerance:
		_failures.append("%s %s overflow: left=%.1f top=%.1f right=%.1f bottom=%.1f viewport=%.1fx%.1f." % [
			context,
			node_name,
			rect.position.x,
			rect.position.y,
			rect.end.x,
			rect.end.y,
			viewport_size.x,
			viewport_size.y,
		])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _find_node_by_name(root_node: Node, node_name: String) -> Node:
	if root_node == null:
		return null
	if root_node.name == node_name:
		return root_node
	for child: Node in root_node.get_children():
		var found := _find_node_by_name(child, node_name)
		if found != null:
			return found
	return null

func _send_mouse_button(screen: Control, position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	screen.call("_input", event)

func _send_mouse_motion(screen: Control, position: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	screen.call("_input", event)
