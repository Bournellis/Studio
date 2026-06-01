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
	_expect(screen.find_child("OpenworldForestWorldView", true, false) != null, "Fullscreen world view exists.")
	_expect(screen.find_child("OpenworldVirtualJoystick", true, false) != null, "Virtual joystick exists.")
	_expect(screen.find_child("OpenworldHudTop", true, false) != null, "In-game HUD exists.")
	_expect(screen.find_child("OpenworldInventoryButton", true, false) != null, "Inventory button exists.")
	_expect(screen.find_child("OpenworldForestBoard", true, false) == null, "Legacy fixed board was removed.")
	var player_before: Vector2 = screen.get_player_position()
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	for _frame in 12:
		await process_frame
	screen.set_debug_joystick_vector(Vector2.ZERO)
	_expect(screen.get_player_position().x > player_before.x, "Debug joystick vector moves the player.")
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
