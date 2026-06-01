extends SceneTree

const BOOT_SCREEN_PATH := "res://modes/boot/boot.gd"

var _failures: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	print("[smoke-modes-ops-panel] checking Labs Dev Ops safe shell")
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	_prepare_viewport(Vector2i(390, 844))

	var boot := _new_boot()
	await process_frame
	boot.call("_show_screen", "modes_ops")
	await process_frame
	await process_frame

	_expect(_find_label_by_text(boot, "Labs Dev Ops") != null, "Ops route renders title.")
	_expect(_find_button_by_text(boot, "Atualizar Ops") != null, "Ops route renders refresh action.")
	_expect(_find_button_by_text(boot, "Desabilitar Openworld") != null, "Ops route renders disable action.")
	_expect(_find_button_by_text(boot, "Habilitar Openworld") != null, "Ops route renders enable action.")
	_expect(_find_label_by_text(boot, "Entre com uma conta alpha para consultar Ops.") != null, "Ops route hides sensitive data without auth.")
	_expect(_count_buttons(boot) >= 3, "Ops route keeps actions inside app shell.")
	boot.queue_free()
	await process_frame

	if not _failures.is_empty():
		for failure: String in _failures:
			printerr("[smoke-modes-ops-panel] %s" % failure)
		return 1
	print("[smoke-modes-ops-panel] OK")
	return 0

func _prepare_viewport(viewport_size: Vector2i) -> void:
	root.size = viewport_size

func _new_boot() -> Control:
	var boot_script: Script = load(BOOT_SCREEN_PATH)
	if boot_script == null or not boot_script.can_instantiate():
		_failures.append("Boot screen script failed to load.")
		return null
	var boot: Control = boot_script.new()
	root.add_child(boot)
	return boot

func _find_button_by_text(root_node: Node, text: String) -> Button:
	for child: Node in root_node.find_children("*", "Button", true, false):
		var button := child as Button
		if button != null and button.text == text:
			return button
	return null

func _find_label_by_text(root_node: Node, text: String) -> Label:
	for child: Node in root_node.find_children("*", "Label", true, false):
		var label := child as Label
		if label != null and label.text == text:
			return label
	return null

func _count_buttons(root_node: Node) -> int:
	return root_node.find_children("*", "Button", true, false).size()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
