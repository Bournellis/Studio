extends SceneTree

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const ModeRegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const BOOT_SCREEN_PATH := "res://modes/boot/boot.gd"

var _failures: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	print("[smoke-bosque-entry] checking official registry and Bosque direct entry")
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	ProjectSettings.set_setting("draxos_mobile/modes/openworld/enabled", true)
	_prepare_viewport(Vector2i(390, 844))

	_check_registry_contract()
	await _check_bosque_direct_entry()

	if not _failures.is_empty():
		for failure: String in _failures:
			printerr("[smoke-bosque-entry] %s" % failure)
		return 1
	print("[smoke-bosque-entry] OK")
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
	_expect(ModeRegistryScript.can_launch("basebuilder"), "Basebuilder remains launchable by its own surface.")
	_expect(ModeRegistryScript.can_launch("autobattler"), "Autobattler remains launchable by Arena PVE.")
	_expect(ModeRegistryScript.can_launch("openworld"), "Openworld remains launchable by Bosque.")
	_expect(not ModeRegistryScript.can_launch("towerdefense"), "Towerdefense stays staged.")
	_expect(not ModeRegistryScript.can_launch("cardgame"), "Cardgame stays staged.")

func _check_bosque_direct_entry() -> void:
	var boot := _new_boot()
	await process_frame
	boot.call("_show_screen", "refuge")
	await process_frame
	await process_frame

	_expect(_find_node_by_name(boot, "RefugeIcon_Modos") == null, "Refugio no longer exposes a Mode Hub icon.")
	_expect(_find_node_by_name(boot, "RefugeIcon_Preparacao") == null, "Refugio no longer exposes direct Preparation icon.")
	_expect(_find_node_by_name(boot, "RefugeIcon_Coletar") == null, "Refugio no longer exposes collect-all icon.")
	_expect(_find_node_by_name(boot, "RefugeIcon_Energia") == null, "Refugio no longer exposes energy shortcut.")
	_expect(_find_button_by_text(boot, "Openworld") == null, "Entry dev tools do not expose Openworld shortcut.")
	_expect(_find_button_by_text(boot, "Openworld Bosque") == null, "Dev tools do not expose Openworld Bosque shortcut.")

	for node_name: String in ["ModeCard_basebuilder", "ModeCard_autobattler", "ModeCard_openworld", "ModeCard_towerdefense", "ModeCard_cardgame"]:
		_expect(_find_node_by_name(boot, node_name) == null, "Refugio does not render retired %s." % node_name)

	var bosque_button := _find_node_by_name(boot, "RefugeIcon_Bosque") as Button
	_expect(bosque_button != null, "Refugio exposes Bosque icon.")
	_expect(bosque_button != null and str(bosque_button.text) == "Bosque", "Bosque icon keeps player-facing name.")
	var actions := Dictionary(boot.get("_action_buttons"))
	_expect(actions.has(AppShellActionContractScript.open_mode_shell_action("openworld")), "Bosque wires openworld shell action.")
	_expect(not actions.has(AppShellActionContractScript.mode_disabled_action("towerdefense")), "Towerdefense staged action is not player-facing.")
	_expect(not actions.has(AppShellActionContractScript.mode_disabled_action("cardgame")), "Cardgame staged action is not player-facing.")

	if bosque_button != null:
		bosque_button.emit_signal("pressed")
	await process_frame
	await process_frame

	_expect(str(boot.get("_current_screen")) == AppShellRouteContractScript.ROUTE_MODE_SHELL, "Bosque opens mode shell route.")
	_expect(str(boot.get("_active_mode_id")) == "openworld", "Bosque opens openworld mode id.")
	_expect(not _label_tree_contains(boot, "Hub interno dos cinco modos oficiais"), "Mode Hub copy is not rendered.")
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
	if root_node == null:
		return null
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

func _label_tree_contains(root_node: Node, needle: String) -> bool:
	if root_node == null:
		return false
	if root_node is Label and str((root_node as Label).text).contains(needle):
		return true
	for child: Node in root_node.get_children():
		if _label_tree_contains(child, needle):
			return true
	return false

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
