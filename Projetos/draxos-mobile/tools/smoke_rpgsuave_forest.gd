extends SceneTree

const ModelScript := preload("res://dev/minigames/rpgsuave/rpgsuave_forest_model.gd")
const ScreenScript := preload("res://dev/minigames/rpgsuave/rpgsuave_forest_screen.gd")
const RegistryScript := preload("res://modes/boot/ui/minigame_shell_registry.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	_expect(RegistryScript.is_available("rpgsuave"), "Rpgsuave registry is available.")
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
	_expect(screen.name == "RpgsuaveForestScreen", "Screen instantiates.")
	screen.queue_free()
	await process_frame

	if _failures.is_empty():
		print("[smoke-rpgsuave-forest] OK local collection, pocket, deposit and craft")
		return 0
	for failure in _failures:
		printerr("[smoke-rpgsuave-forest] %s" % failure)
	return 1

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
