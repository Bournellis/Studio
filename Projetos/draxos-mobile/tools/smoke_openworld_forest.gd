extends SceneTree

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")
const RegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	_expect(RegistryScript.is_available("openworld"), "Openworld registry is available.")
	var model = ModelScript.new()
	_expect(model.start_collection("galho").get("ok") == true, "Can start galho collection.")
	_expect(model.advance_collection(0.1, true).get("cancelled") == true, "Moving cancels collection.")
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
	_expect(screen.find_child("OpenworldPlayer", true, false) is CharacterBody2D, "CharacterBody2D player exists.")
	_expect(screen.find_child("OpenworldBoundaryWalls", true, false) is StaticBody2D, "Boundary walls exist.")
	_expect(screen.find_child("OpenworldVirtualJoystick", true, false) != null, "Virtual joystick exists.")
	_expect(screen.find_child("OpenworldHudTop", true, false) != null, "In-game HUD exists.")
	_expect(screen.find_child("OpenworldInventoryButton", true, false) != null, "Inventory button exists.")
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

	var world = screen.call("get_openworld_world_2d")
	var chest_position: Vector2 = world.call("obstacle_position", "chest_home")
	var chest_collision_radius: float = world.call("chest_collision_radius")
	screen.call("set_player_position_for_tests", chest_position + Vector2(-chest_collision_radius - 44.0, 0))
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await _wait_physics_frames(48)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	_expect(screen.get_player_position().distance_to(chest_position) >= chest_collision_radius + 18.0, "Chest blocks the player body.")

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

	screen.call("begin_free_joystick_for_tests", Vector2(210, 420))
	screen.call("drag_free_joystick_for_tests", Vector2(270, 420))
	_expect(Vector2(screen.call("get_joystick_vector_for_tests")).x > 0.5, "Free joystick drag produces movement vector.")
	screen.call("end_free_joystick_for_tests")
	_expect(Vector2(screen.call("get_joystick_vector_for_tests")) == Vector2.ZERO, "Free joystick resets on release.")
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
