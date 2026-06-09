extends SceneTree

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")
const RegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

var _failures: Array[String] = []
const PLAYER_RADIUS := 20.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	_expect(RegistryScript.is_available("openworld"), "Openworld registry is available.")
	var world_source := FileAccess.get_file_as_string("res://modes/openworld/openworld_forest_world_2d.gd")
	_expect(not world_source.contains("_draw_ground_marker"), "Bosque does not draw disliked double-circle floor markers.")
	var model = ModelScript.new()
	_expect(model.start_collection("galho").get("ok") == true, "Can start galho collection.")
	var moving_progress: Dictionary = model.advance_collection(0.1, true, 0.0)
	_expect(moving_progress.get("ok") == true and moving_progress.get("cancelled") != true, "Moving inside collection radius keeps collection.")
	var distance_cancel: Dictionary = model.advance_collection(0.1, false, 999.0)
	_expect(distance_cancel.get("cancelled") == true and distance_cancel.get("reason") == "distance", "Distance cancels collection.")
	for _index in 20:
		model.add_to_pocket("pedra_pequena")
	_expect(model.start_collection("pedra").get("reason") == "pocket_full", "Full pocket blocks heavy collection.")
	model.deposit_all()
	model.chest = {"galho": 4, "folha": 3, "resina": 1}
	_expect(model.craft("bolsa_simples_1").get("ok") == true, "Crafting bag upgrade succeeds.")
	_expect(is_equal_approx(model.capacity(), 25.0), "Bag upgrade changes capacity.")

	var screen = ScreenScript.new()
	root.add_child(screen)
	await process_frame
	_expect(screen.name == "OpenworldForestScreen", "Screen instantiates.")
	_expect(screen.find_child("OpenworldForestWorldView", true, false) is SubViewportContainer, "Fullscreen world viewport wrapper exists.")
	_expect(screen.find_child("OpenworldForestWorld2D", true, false) is Node2D, "Node2D world exists.")
	var world = screen.call("get_openworld_world_2d")
	_expect(screen.find_child("OpenworldPlayer", true, false) is CharacterBody2D, "CharacterBody2D player exists.")
	_expect(screen.find_child("OpenworldBoundaryWalls", true, false) is StaticBody2D, "Boundary walls exist.")
	_expect(screen.find_child("OpenworldVirtualJoystick", true, false) != null, "Virtual joystick exists.")
	_expect(screen.find_child("OpenworldHudTop", true, false) != null, "In-game HUD exists.")
	_expect(screen.find_child("OpenworldInventoryButton", true, false) != null, "Inventory button exists.")
	var launcher_prompt := screen.find_child("OpenworldLauncherPrompt", true, false) as Control
	_expect(launcher_prompt != null, "Diegetic launcher prompt exists.")
	_expect(int(world.call("launcher_count")) == 5, "Bosque instantiates five public diegetic launcher landmarks.")
	var launcher_ids := Array(world.call("launcher_entry_ids"))
	_expect(launcher_ids.has("arena_pve_gate"), "Arena PVE launcher landmark exists.")
	_expect(launcher_ids.has("refugio_workbench"), "Refugio launcher landmark exists.")
	_expect(launcher_ids.has("shop_stall"), "Shop launcher landmark exists.")
	_expect(launcher_ids.has("social_totem"), "Social launcher landmark exists.")
	_expect(launcher_ids.has("profile_shrine"), "Profile launcher landmark exists.")
	for launcher_id in launcher_ids:
		var clean_id := str(launcher_id)
		_expect(not clean_id.contains("tower"), "Tower/Card future launcher entries stay out of V1.")
		_expect(not clean_id.contains("card"), "Tower/Card future launcher entries stay out of V1.")
		_expect(not clean_id.contains("dev"), "Dev tools stay out of launcher catalog.")
	_expect(screen.find_child("OpenworldForestBoard", true, false) == null, "Legacy fixed board was removed.")
	var player_before: Vector2 = screen.get_player_position()
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await _wait_physics_frames(18)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	_expect(screen.get_player_position().x > player_before.x, "Debug joystick vector moves the player.")
	_expect(InputMap.has_action("openworld_move_left"), "Openworld left input action exists.")
	_expect(InputMap.has_action("openworld_move_right"), "Openworld right input action exists.")
	_expect(InputMap.has_action("openworld_move_up"), "Openworld up input action exists.")
	_expect(InputMap.has_action("openworld_move_down"), "Openworld down input action exists.")
	var keyboard_before: Vector2 = screen.get_player_position()
	_send_key_event(screen, KEY_D, true)
	await _wait_physics_frames(12)
	_send_key_event(screen, KEY_D, false)
	_expect(screen.get_player_position().x > keyboard_before.x, "Real D key event moves the player.")

	var launcher_signals: Array[Dictionary] = []
	screen.shell_action_requested.connect(func(action_id: String, entry_id: String) -> void:
		launcher_signals.append({"action_id": action_id, "entry_id": entry_id})
	)
	var arena_launcher_position: Vector2 = world.call("launcher_position", "arena_pve_gate")
	screen.call("set_player_position_for_tests", arena_launcher_position)
	screen.call("_update_labels")
	var arena_launcher_state: Dictionary = world.call("launcher_visual_state", "arena_pve_gate")
	_expect(launcher_prompt != null and launcher_prompt.visible, "Nearest launcher shows one contextual prompt.")
	_expect(bool(arena_launcher_state.get("highlighted", false)), "Nearest launcher receives procedural highlight.")
	var tapped_entry: Dictionary = world.call("launcher_entry_at_world_position", arena_launcher_position)
	_expect(str(tapped_entry.get("entry_id", "")) == "arena_pve_gate", "Arena launcher can be resolved from a tap/click world position.")
	screen.call("_handle_launcher_action_requested", str(tapped_entry.get("action_id", "")), str(tapped_entry.get("entry_id", "")))
	await _wait_process_frames(4)
	var launcher_signal := launcher_signals[0] if not launcher_signals.is_empty() else {}
	_expect(str(launcher_signal.get("action_id", "")) == AppShellActionContractScript.ACTION_OPEN_ARENA, "Clicking Arena landmark emits open_arena.")
	_expect(str(launcher_signal.get("entry_id", "")) == "arena_pve_gate", "Clicking Arena landmark preserves entry id.")

	await _expect_obstacle_blocks(screen, "chest_home", Vector2.RIGHT)
	await _expect_obstacle_blocks(screen, "tree_large_mid", Vector2.RIGHT)
	await _expect_obstacle_blocks(screen, "rock_large_path", Vector2.RIGHT)

	screen.call("set_player_position_for_tests", Vector2(24, 330))
	screen.set_debug_joystick_vector(Vector2.LEFT)
	await _wait_physics_frames(36)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	_expect(screen.get_player_position().x >= 19.0, "Left boundary keeps player inside.")

	var galho_position: Vector2 = world.call("resource_position", "galho")
	screen.call("set_player_position_for_tests", galho_position + Vector2(-90, 0))
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await _wait_physics_frames(72)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	_expect(screen.get_player_position().x > galho_position.x + 18.0, "Resource areas do not block movement.")
	screen.call("set_player_position_for_tests", galho_position + Vector2(-88, 0))
	screen.call("_update_labels")
	var galho_near_state: Dictionary = world.call("resource_visual_state", "galho")
	_expect(bool(galho_near_state.get("nearby", false)), "Nearby resource gets a procedural visual marker.")
	_expect(not bool(galho_near_state.get("nearest", false)), "Nearby resource marker is distinct from active collection range.")
	screen.call("set_player_position_for_tests", galho_position + Vector2(-12, 0))
	screen.call("_update_labels")
	var galho_collect_state: Dictionary = world.call("resource_visual_state", "galho")
	_expect(bool(galho_collect_state.get("nearest", false)), "Collectable resource gets active collection highlight.")
	var screen_model = screen.get_model()
	screen_model.deposit_all()
	screen_model.chest = {"galho": 2, "folha_seca": 2, "pedra_pequena": 1}
	_expect(screen_model.craft("fogueira_estavel_1").get("ok") == true, "Crafting campfire succeeds in screen model.")
	screen.call("_update_labels")
	_expect(world.call("structure_visible", "fogueira_estavel_1"), "Built campfire becomes visible in the forest.")
	_expect(world.call("structure_collision_enabled", "fogueira_estavel_1"), "Built campfire keeps its contracted small blocker.")

	var joystick := screen.find_child("OpenworldVirtualJoystick", true, false) as Control
	_expect(joystick != null and not joystick.visible, "Free joystick starts hidden.")
	_send_mouse_button(screen, Vector2(210, 420), true)
	_send_mouse_motion(screen, Vector2(270, 420))
	_expect(Vector2(screen.call("get_joystick_vector_for_tests")).x > 0.5, "Free joystick drag produces movement vector.")
	_send_mouse_button(screen, Vector2(270, 420), false)
	_expect(Vector2(screen.call("get_joystick_vector_for_tests")) == Vector2.ZERO, "Free joystick resets on release.")
	_expect(joystick != null and not joystick.visible, "Free joystick hides on release.")
	screen.queue_free()
	await process_frame

	if _failures.is_empty():
		print("[smoke-openworld-forest] OK local collection, pocket, deposit and craft")
		return 0
	for failure in _failures:
		printerr("[smoke-openworld-forest] %s" % failure)
	return 1

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _wait_physics_frames(frames: int) -> void:
	for _frame in frames:
		await physics_frame

func _wait_process_frames(frames: int) -> void:
	for _frame in frames:
		await process_frame

func _expect_obstacle_blocks(screen, object_id: String, movement_direction: Vector2) -> void:
	var world = screen.call("get_openworld_world_2d")
	var direction := movement_direction.normalized()
	var obstacle_center: Vector2 = world.call("obstacle_collision_center", object_id)
	var obstacle_shape := str(world.call("obstacle_collision_shape", object_id))
	var obstacle_size: Vector2 = world.call("obstacle_collision_size", object_id)
	var obstacle_radius: float = float(world.call("obstacle_collision_radius", object_id))
	var support_distance := _obstacle_support_distance(obstacle_shape, obstacle_size, obstacle_radius, direction)
	screen.call("set_player_position_for_tests", obstacle_center - direction * (support_distance + PLAYER_RADIUS + 70.0))
	await process_frame
	screen.set_debug_joystick_vector(direction)
	await _wait_physics_frames(48)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	var final_projection: float = (screen.get_player_position() - obstacle_center).dot(direction)
	_expect(final_projection <= -(support_distance + PLAYER_RADIUS - 2.0), "%s blocks the player body." % object_id)

func _obstacle_support_distance(shape: String, size: Vector2, radius: float, direction: Vector2) -> float:
	if shape == "rectangle":
		return absf(direction.x) * size.x * 0.5 + absf(direction.y) * size.y * 0.5
	return radius

func _send_key_event(screen, keycode: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = pressed
	screen.call("_input", event)

func _send_mouse_button(screen, position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = position
	screen.call("_input", event)

func _send_mouse_motion(screen, position: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = position
	screen.call("_input", event)
