class_name BootBaseSurfaceCrafting
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const BaseSurfaceSummaryScript := preload("res://modes/boot/surfaces/base_surface_summary.gd")
const BaseSurfaceTextScript := preload("res://modes/boot/surfaces/base_surface_text.gd")
const BaseSurfaceVisualsScript := preload("res://modes/boot/surfaces/base_surface_visuals.gd")

static func crafting_panel(host: Node) -> Control:
	var panel := BaseSurfaceVisualsScript.base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(BaseSurfaceVisualsScript.base_label(host, "Crafting", "text_primary", 18))

	var crafting := SessionStore.crafting_snapshot()
	if crafting.is_empty():
		box.add_child(BaseSurfaceVisualsScript.base_label(host, "Triture Ossos em Po de Osso. Prepare pocoes na Fogueira do Bosque.", "text_secondary"))
		box.add_child(embedded_action_button(host, "Sincronizar Crafting", AppShellActionContractScript.ACTION_SHOW_CRAFTING))
		return panel

	var inventory := BaseSurfaceSummaryScript.as_array(crafting.get("inventory", []))
	var stock := _total_potions(inventory)
	box.add_child(BaseSurfaceVisualsScript.base_label(host, "Ossos %s | Po de Osso %s | Pocoes %d" % [
		BaseSurfaceSummaryScript.format_number(float(SessionStore.resources_snapshot().get("ossos", 0))),
		BaseSurfaceSummaryScript.format_number(float(SessionStore.resources_snapshot().get("po_osso", 0))),
		stock,
	], "text_secondary"))
	box.add_child(BaseSurfaceVisualsScript.base_label(host, "Triturar 1 Osso cria 1 Po de Osso. As pocoes agora usam materiais do Bau e a Fogueira do Bosque.", "text_secondary"))

	var actions := GridContainer.new()
	actions.columns = 1 if BaseSurfaceVisualsScript.compact_layout(host) else 2
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("h_separation", 8)
	actions.add_theme_constant_override("v_separation", 8)
	box.add_child(actions)
	actions.add_child(embedded_action_button(host, "Triturar Ossos", AppShellActionContractScript.ACTION_CRUSH_BONES, "Triturar 1 Osso em 1 Po de Osso?"))
	actions.add_child(embedded_action_button(host, "Abrir Bosque", AppShellActionContractScript.open_mode_shell_action("openworld")))
	return panel

static func _total_potions(inventory: Array) -> int:
	var total := 0
	for potion_id: String in ["pocao_vida", "pocao_foco", "pocao_resguardo"]:
		total += BaseSurfaceTextScript.inventory_quantity(inventory, potion_id)
	return total

static func embedded_action_button(host: Node, text: String, action_id: String, confirm_message: String = "") -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = text
	button.custom_minimum_size = button_min_size(host)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prepare_touch_button(host, button)
	host.call("_apply_action_button_style", button, action_id, str(host.get("_current_screen")))
	button.pressed.connect(func() -> void:
		host.call("_trigger_action", action_id, confirm_message)
	)
	register_action_button(host, action_id, button)
	return button

static func button_min_size(host: Node) -> Vector2:
	var min_size: Vector2 = host.call("_button_min_size")
	return min_size

static func prepare_touch_button(host: Node, button: Button) -> void:
	host.call("_prepare_touch_button", button)

static func register_action_button(host: Node, action_id: String, button: Button) -> void:
	var action_buttons: Dictionary = host.get("_action_buttons")
	action_buttons[action_id] = button
