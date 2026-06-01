extends SceneTree

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const ModeRegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const BOOT_SCREEN_PATH := "res://modes/boot/boot.gd"

var _failures: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	print("[smoke-mode-hub] checking official mode registry and hub")
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_viewport(Vector2i(390, 844))

	_check_registry_contract()
	await _check_refuge_mode_entry()
	await _check_mode_hub_route()

	if not _failures.is_empty():
		for failure: String in _failures:
			printerr("[smoke-mode-hub] %s" % failure)
		return 1
	print("[smoke-mode-hub] OK")
	return 0

func _check_registry_contract() -> void:
	var ids := Array(ModeRegistryScript.registered_ids())
	ids.sort()
	_expect(ids == ["autobattler", "basebuilder", "cardgame", "openworld", "towerdefense"], "Registry keeps the five official mode ids.")
	_expect(ModeRegistryScript.display_name("basebuilder") == "Basebuilder", "Basebuilder display name is official.")
	_expect(ModeRegistryScript.display_name("autobattler") == "Autobattler", "Autobattler display name is official.")
	_expect(ModeRegistryScript.display_name("towerdefense") == "Towerdefense", "Towerdefense display name is official.")
	_expect(ModeRegistryScript.display_name("cardgame") == "Cardgame", "Cardgame display name is official.")
	_expect(ModeRegistryScript.display_name("openworld") == "Openworld", "Openworld display name is official.")
	_expect(ModeRegistryScript.can_launch("basebuilder"), "Basebuilder is launchable.")
	_expect(ModeRegistryScript.can_launch("autobattler"), "Autobattler is launchable.")
	_expect(ModeRegistryScript.can_launch("openworld"), "Openworld is launchable.")
	_expect(not ModeRegistryScript.can_launch("towerdefense"), "Towerdefense stays staged.")
	_expect(not ModeRegistryScript.can_launch("cardgame"), "Cardgame stays staged.")

func _check_refuge_mode_entry() -> void:
	var boot := _new_boot()
	await process_frame
	boot.call("_show_screen", "refuge")
	await process_frame
	await process_frame
	var mode_button := _find_node_by_name(boot, "RefugeIcon_Modos") as Button
	_expect(mode_button != null, "Refugio exposes the mode hub icon.")
	if mode_button != null:
		mode_button.emit_signal("pressed")
	await process_frame
	for node_name: String in ["ModeCard_basebuilder", "ModeCard_autobattler", "ModeCard_openworld", "ModeCard_towerdefense", "ModeCard_cardgame"]:
		_expect(_find_node_by_name(boot, node_name) != null, "Refugio popup renders %s." % node_name)
	var actions := Dictionary(boot.get("_action_buttons"))
	_expect(actions.has(AppShellActionContractScript.ACTION_SHOW_BASE), "Mode popup wires Basebuilder.")
	_expect(actions.has(AppShellActionContractScript.ACTION_OPEN_ARENA), "Mode popup wires Autobattler.")
	_expect(actions.has(AppShellActionContractScript.open_mode_shell_action("openworld")), "Mode popup wires Openworld.")
	boot.queue_free()
	await process_frame

func _check_mode_hub_route() -> void:
	var boot := _new_boot()
	await process_frame
	boot.call("_show_screen", "mode_hub")
	await process_frame
	await process_frame
	for text: String in ["Basebuilder\nActive", "Autobattler\nActive", "Openworld Bosque\nInternal Alpha", "Towerdefense\nStaged", "Cardgame\nStaged"]:
		_expect(_find_button_by_text(boot, text) != null, "Mode hub route renders %s." % text.replace("\n", " "))
	var actions := Dictionary(boot.get("_action_buttons"))
	_expect(actions.has(AppShellActionContractScript.ACTION_SHOW_BASE), "Mode hub route wires Basebuilder.")
	_expect(actions.has(AppShellActionContractScript.ACTION_OPEN_ARENA), "Mode hub route wires Autobattler.")
	_expect(actions.has(AppShellActionContractScript.open_mode_shell_action("openworld")), "Mode hub route wires Openworld.")
	_expect(actions.has("mode_disabled:towerdefense"), "Mode hub route marks Towerdefense disabled.")
	_expect(actions.has("mode_disabled:cardgame"), "Mode hub route marks Cardgame disabled.")
	boot.queue_free()
	await process_frame

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

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
