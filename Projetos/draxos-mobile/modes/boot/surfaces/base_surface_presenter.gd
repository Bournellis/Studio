class_name BootBaseSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const BaseSurfaceSummaryScript := preload("res://modes/boot/surfaces/base_surface_summary.gd")
const BaseSurfaceTextScript := preload("res://modes/boot/surfaces/base_surface_text.gd")
const BaseSurfaceVisualsScript := preload("res://modes/boot/surfaces/base_surface_visuals.gd")
const BaseSurfaceCraftingScript := preload("res://modes/boot/surfaces/base_surface_crafting.gd")

static func render(host: Node) -> void:
	_add_body_text(host, "Acompanhe producao, veja a fila e escolha o proximo upgrade.")
	_add_action_button(host, "Sincronizar Refugio", AppShellActionContractScript.ACTION_SHOW_BASE)
	_add_action_button(host, "Abrir Crafting", AppShellActionContractScript.ACTION_SHOW_CRAFTING)
	var timeline := _add_output_label(host, "")
	timeline.visible = false
	host.set("_timeline_label", timeline)
	var base_state_container := VBoxContainer.new()
	base_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	base_state_container.add_theme_constant_override("separation", 10)
	_content_body(host).add_child(base_state_container)
	host.set("_base_state_container", base_state_container)
	render_state(host)

static func render_refuge_embedded(host: Node, parent: VBoxContainer) -> void:
	var timeline := _base_label(host, "", "text_secondary")
	timeline.visible = false
	parent.add_child(timeline)
	host.set("_timeline_label", timeline)

	var base_state_container := VBoxContainer.new()
	base_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	base_state_container.add_theme_constant_override("separation", 10)
	parent.add_child(base_state_container)
	host.set("_base_state_container", base_state_container)
	render_state(host)

static func render_state(host: Node, collected: Dictionary = {}) -> void:
	var timeline := _timeline_label(host)
	if timeline == null:
		return
	var container := _base_state_container(host)
	if container != null:
		_clear_node_children(container)
	var base := SessionStore.base_snapshot()
	if base.is_empty():
		timeline.text = _empty_refuge_timeline_text()
		if container != null:
			if _is_refuge_screen(host):
				container.add_child(_refuge_empty_panel(host))
			else:
				container.add_child(_base_info_panel(host, "Rotina do Refugio", _empty_refuge_body_text()))
		return

	var resources := SessionStore.resources_snapshot()
	var lines := PackedStringArray()
	if SessionStore.is_progression_lab_local_only():
		lines.append("Refugio Progression Lab local (somente leitura)")
		lines.append("Acoes online exigem um save normal sincronizado.")
	else:
		lines.append("Refugio sincronizado")
	lines.append("Recursos: %s" % _format_resources(resources))
	if not collected.is_empty():
		if _resource_total(collected) <= 0.0:
			lines.append("Producao: nada acumulado agora.")
		else:
			lines.append("Producao atualizada: %s" % _format_resources(collected, false))

	var structures := _as_array(base.get("structures", []))
	if structures.is_empty():
		lines.append("Estruturas: nenhuma construcao carregada.")
	else:
		lines.append("Estruturas: %d predios no mapa abaixo." % structures.size())
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		if structure.is_empty():
			continue
		lines.append("- %s L%s | pendente %s/%s | %s" % [
			_structure_label(str(structure.get("structure_id", "")), str(structure.get("display_name", ""))),
			str(structure.get("level", 0)),
			_format_number(float(structure.get("pending_collectable", 0.0))),
			_format_number(float(structure.get("storage_cap", 0.0))),
			str(structure.get("blocked_message", "Upgrade indisponivel.")),
		])

	var jobs := _as_array(base.get("jobs", []))
	var active_jobs := 0
	for item: Variant in jobs:
		var job := _as_dictionary(item)
		if str(job.get("status", "")) == "active":
			active_jobs += 1
			lines.append("- Em construcao: %s -> L%s | resta %s" % [
				_structure_label(str(job.get("structure_id", ""))),
				str(job.get("target_level", "?")),
				_format_duration(int(job.get("remaining_seconds", 0))),
			])
	lines.append("Fila: %d/%d" % [active_jobs, int(base.get("construction_slots", 1))])
	timeline.text = "\n".join(lines)
	if _is_refuge_screen(host):
		_render_refuge_panels(host, structures, base, collected)
	else:
		_render_playable_panels(host, structures, base, collected)

static func select_structure(host: Node, structure_id: String) -> void:
	if structure_id.strip_edges() == "":
		return
	host.set("_selected_base_structure_id", structure_id.strip_edges())
	render_state(host)

static func can_upgrade_structure(_host: Node, structure_id: String) -> bool:
	if SessionStore.is_progression_lab_local_only():
		return false
	if not SessionStore.has_valid_access_token() or not SessionStore.has_account_state():
		return false
	var base := SessionStore.base_snapshot()
	var structures := _as_array(base.get("structures", []))
	var structure := _base_structure_by_id(structures, structure_id)
	return bool(structure.get("can_upgrade", false))

static func routine_summary(base: Dictionary, collected: Dictionary = {}) -> Dictionary:
	return BaseSurfaceSummaryScript.routine_summary(base, collected)

static func _render_playable_panels(host: Node, structures: Array, base: Dictionary, collected: Dictionary) -> void:
	var container := _base_state_container(host)
	if container == null:
		return
	_ensure_selected_base_structure(host, structures)
	_add_responsive_panel_layout(host, container, [
		_base_summary_panel(host, base, collected),
		_base_routine_panel(host, base, collected),
		_crafting_panel(host),
		_base_map_panel(host, structures),
		_base_detail_panel(host, structures),
	], 2)

static func _render_refuge_panels(host: Node, structures: Array, base: Dictionary, collected: Dictionary) -> void:
	var container := _base_state_container(host)
	if container == null:
		return
	_ensure_selected_base_structure(host, structures)
	_add_responsive_panel_layout(host, container, [
		_refuge_command_panel(host, base, collected),
		_crafting_panel(host),
		_base_map_panel(host, structures),
		_base_detail_panel(host, structures),
	], 1)

static func _refuge_empty_panel(host: Node) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label(host, "Altar do Refugio", "text_primary", 18))
	box.add_child(_base_label(host, _empty_refuge_body_text(), "text_secondary"))
	return panel

static func _crafting_panel(host: Node) -> Control:
	return BaseSurfaceCraftingScript.crafting_panel(host)

static func _refuge_command_panel(host: Node, base: Dictionary, collected: Dictionary) -> Control:
	var routine := routine_summary(base, collected)
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label(host, "Altar do Refugio", "text_primary", 18))

	var status_box := VBoxContainer.new()
	status_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_box.add_theme_constant_override("separation", 3)
	box.add_child(status_box)
	_add_refuge_status_line(host, status_box, "Producao", _refuge_collect_status(routine, collected), "status_success" if bool(routine.get("has_collect_ready", false)) else "text_secondary")
	_add_refuge_status_line(host, status_box, "Fila", _refuge_queue_status(routine), "status_success" if int(routine.get("free_slots", 0)) > 0 else "status_warning")
	_add_refuge_status_line(host, status_box, "Proximo", _refuge_upgrade_status(routine), "status_success" if bool(routine.get("next_upgrade_ready", false)) else "text_secondary")

	return panel

static func _add_refuge_status_line(host: Node, box: VBoxContainer, title: String, value: String, value_color: String) -> void:
	var label := _base_label(host, "%s: %s" % [title, value], value_color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(label)

static func _refuge_collect_status(routine: Dictionary, collected: Dictionary) -> String:
	if bool(routine.get("has_collect_ready", false)):
		return _strip_routine_prefix(str(routine.get("collect_text", "")), "Producao pendente: ")
	if _resource_total(collected) > 0.0:
		return "Atualizada: %s" % _format_nonzero_resources(collected)
	return "Nada agora"

static func _refuge_queue_status(routine: Dictionary) -> String:
	return "%d/%d ativos | %d livre" % [
		int(routine.get("active_job_count", 0)),
		int(routine.get("construction_slots", 0)),
		int(routine.get("free_slots", 0)),
	]

static func _refuge_upgrade_status(routine: Dictionary) -> String:
	var status := _strip_after_separator(str(routine.get("next_upgrade_text", "")))
	return "Sem upgrade" if status == "" else status

static func _base_summary_panel(host: Node, base: Dictionary, collected: Dictionary) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Producao e fila", "text_primary", 17))
	box.add_child(_base_label(host, "Recursos: %s" % _format_short_resources(SessionStore.resources_snapshot(), 3), "text_secondary"))
	var active_jobs := BaseSurfaceSummaryScript.active_base_jobs(_as_array(base.get("jobs", [])))
	box.add_child(_base_label(host, "Fila de construcao: %d/%d" % [
		active_jobs.size(),
		int(base.get("construction_slots", 1)),
	], "text_secondary"))
	if not collected.is_empty():
		var collect_text := "Producao: nada acumulado agora."
		if _resource_total(collected) > 0.0:
			collect_text = "Producao atualizada: %s" % _format_resources(collected, false)
		box.add_child(_base_label(host, collect_text, "status_success"))
	if SessionStore.is_progression_lab_active():
		box.add_child(_base_label(host, "Lab: Refugio separado do save normal.", "status_warning"))
	return panel

static func _base_routine_panel(host: Node, base: Dictionary, collected: Dictionary) -> Control:
	var routine := routine_summary(base, collected)
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Rotina do Refugio", "text_primary", 17))

	var collect_color := "status_success" if bool(routine.get("has_collect_ready", false)) else "text_secondary"
	box.add_child(_base_label(host, _routine_collect_display_text(routine), collect_color))

	var active_job_count := int(routine.get("active_job_count", 0))
	if active_job_count <= 0:
		box.add_child(_base_label(host, "Fila em andamento: nenhuma obra.", "text_secondary"))
	else:
		box.add_child(_base_label(host, "Fila em andamento: %d obra(s)." % active_job_count, "text_secondary"))
		for line: String in Array(routine.get("job_lines", [])):
			box.add_child(_base_label(host, "- %s" % line, "text_secondary"))

	var free_slots := int(routine.get("free_slots", 0))
	var slots := int(routine.get("construction_slots", 0))
	var slot_color := "status_success" if free_slots > 0 else "status_warning"
	box.add_child(_base_label(host, "Slots livres: %d/%d." % [free_slots, slots], slot_color))

	var upgrade_color := "status_success" if bool(routine.get("next_upgrade_ready", false)) else "text_secondary"
	box.add_child(_base_label(host, "Proximo: %s" % _routine_upgrade_display_text(routine), upgrade_color))
	return panel

static func _base_map_panel(host: Node, structures: Array) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label(host, "Mapa do Refugio", "text_primary", 17))
	var grid := GridContainer.new()
	grid.columns = _base_map_columns(host)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for structure_id: String in BaseSurfaceSummaryScript.BASE_STRUCTURE_IDS:
		var structure := _base_structure_by_id(structures, structure_id)
		if structure.is_empty():
			continue
		grid.add_child(_base_structure_button(host, structure))
	return panel

static func _base_detail_panel(host: Node, structures: Array) -> Control:
	var structure := _base_structure_by_id(structures, _selected_base_structure_id(host))
	if structure.is_empty() and not structures.is_empty():
		structure = _as_dictionary(structures[0])
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	if structure.is_empty():
		box.add_child(_base_label(host, "Selecione um predio no mapa do Refugio.", "text_secondary"))
		return panel

	var structure_id := str(structure.get("structure_id", ""))
	var display_label := _structure_label(structure_id, str(structure.get("display_name", "")))
	box.add_child(_base_label(host, "%s - Nivel %s/%s" % [
		display_label,
		str(structure.get("level", 0)),
		str(structure.get("max_level", 40)),
	], "text_primary", 18))
	box.add_child(_base_label(host, str(structure.get("description", "")), "text_secondary"))
	box.add_child(_base_label(host, "Beneficio: %s" % _base_benefit_text(structure), "text_secondary"))
	box.add_child(_base_label(host, "Producao pendente: %s" % _base_pending_text(structure), "text_secondary"))
	box.add_child(_base_label(host, "Proximo upgrade: %s" % _base_upgrade_text(structure), "text_secondary"))
	box.add_child(_base_label(host, "Status: %s" % str(structure.get("blocked_message", "")), _base_status_color_token(structure)))

	var action_id := AppShellActionContractScript.upgrade_base_structure_action(structure_id)
	var upgrade_button := Button.new()
	upgrade_button.text = "Evoluir %s" % display_label
	upgrade_button.custom_minimum_size = _button_min_size(host)
	upgrade_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upgrade_button.tooltip_text = _base_structure_tooltip(structure)
	upgrade_button.disabled = not can_upgrade_structure(host, structure_id)
	_prepare_touch_button(host, upgrade_button)
	upgrade_button.pressed.connect(func() -> void:
		host.call("_trigger_action", action_id, "Iniciar upgrade de %s no servidor?" % display_label)
	)
	box.add_child(upgrade_button)
	_register_action_button(host, action_id, upgrade_button)
	return panel

static func _base_structure_button(host: Node, structure: Dictionary) -> Button:
	var structure_id := str(structure.get("structure_id", ""))
	var selected := structure_id == _selected_base_structure_id(host)
	var button := Button.new()
	button.text = "%s\n%s\nL%s -> %s\n%s" % [
		_base_structure_symbol(structure_id),
		_base_structure_short_label(structure_id),
		str(structure.get("level", 0)),
		_base_next_level_text(structure),
		_base_short_status(structure),
	]
	button.custom_minimum_size = Vector2(0, 96) if _compact_layout(host) else Vector2(0, 112)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = _base_structure_tooltip(structure)
	button.add_theme_stylebox_override("normal", _base_structure_card_style(structure_id, selected))
	button.add_theme_stylebox_override("hover", _base_structure_card_style(structure_id, true))
	button.add_theme_stylebox_override("pressed", _base_structure_card_style(structure_id, true))
	_prepare_touch_button(host, button)
	var action_id := AppShellActionContractScript.select_base_structure_action(structure_id)
	button.pressed.connect(func() -> void:
		host.call("_trigger_action", action_id)
	)
	_register_action_button(host, action_id, button)
	return button

static func _empty_refuge_timeline_text() -> String:
	return BaseSurfaceTextScript.empty_refuge_timeline_text(
		SessionStore.has_valid_access_token(),
		SessionStore.is_progression_lab_local_only()
	)

static func _empty_refuge_body_text() -> String:
	return BaseSurfaceTextScript.empty_refuge_body_text(
		SessionStore.has_valid_access_token(),
		SessionStore.is_progression_lab_local_only()
	)

static func _strip_routine_prefix(text: String, prefix: String) -> String:
	return BaseSurfaceTextScript.strip_routine_prefix(text, prefix)

static func _strip_after_separator(text: String) -> String:
	return BaseSurfaceTextScript.strip_after_separator(text)

static func _ensure_selected_base_structure(host: Node, structures: Array) -> void:
	var selected_id := _selected_base_structure_id(host)
	if not _base_structure_by_id(structures, selected_id).is_empty():
		return
	for structure_id: String in BaseSurfaceSummaryScript.BASE_STRUCTURE_IDS:
		if not _base_structure_by_id(structures, structure_id).is_empty():
			host.set("_selected_base_structure_id", structure_id)
			return
	if not structures.is_empty():
		host.set("_selected_base_structure_id", str(_as_dictionary(structures[0]).get("structure_id", selected_id)))

static func _base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	return BaseSurfaceSummaryScript.base_structure_by_id(structures, structure_id)

static func _base_panel(host: Node) -> PanelContainer:
	return BaseSurfaceVisualsScript.base_panel(host)

static func _base_info_panel(host: Node, title_text: String, body_text: String) -> Control:
	return BaseSurfaceVisualsScript.base_info_panel(host, title_text, body_text)

static func _base_label(host: Node, text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	return BaseSurfaceVisualsScript.base_label(host, text, color_token, font_size)

static func _base_structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	return BaseSurfaceVisualsScript.structure_card_style(structure_id, selected)

static func _base_structure_color(structure_id: String) -> Color:
	return BaseSurfaceVisualsScript.structure_color(structure_id)

static func _base_structure_symbol(structure_id: String) -> String:
	return BaseSurfaceVisualsScript.structure_symbol(structure_id)

static func _base_structure_short_label(structure_id: String) -> String:
	return BaseSurfaceVisualsScript.structure_short_label(structure_id)

static func _base_benefit_text(structure: Dictionary) -> String:
	return BaseSurfaceTextScript.benefit_text(structure)

static func _base_pending_text(structure: Dictionary) -> String:
	return BaseSurfaceTextScript.pending_text(structure)

static func _base_upgrade_text(structure: Dictionary) -> String:
	return BaseSurfaceTextScript.upgrade_text(structure)

static func _base_next_level_text(structure: Dictionary) -> String:
	return BaseSurfaceTextScript.next_level_text(structure)

static func _base_short_status(structure: Dictionary) -> String:
	return BaseSurfaceTextScript.short_status(structure)

static func _base_status_color_token(structure: Dictionary) -> String:
	return BaseSurfaceTextScript.status_color_token(structure)

static func _base_structure_tooltip(structure: Dictionary) -> String:
	return BaseSurfaceTextScript.structure_tooltip(structure)

static func _active_base_jobs(jobs: Array) -> Array:
	return BaseSurfaceSummaryScript.active_base_jobs(jobs)

static func _format_cost(cost: Dictionary) -> String:
	return BaseSurfaceSummaryScript.format_cost(cost)

static func _format_duration(total_seconds: int) -> String:
	return BaseSurfaceSummaryScript.format_duration(total_seconds)

static func _format_number(value: float) -> String:
	return BaseSurfaceSummaryScript.format_number(value)

static func _format_nonzero_resources(resources: Dictionary) -> String:
	return BaseSurfaceSummaryScript.format_nonzero_resources(resources)

static func _format_resources(resources: Dictionary, include_diamond: bool = true) -> String:
	return BaseSurfaceSummaryScript.format_resources(resources, include_diamond)

static func _format_short_resources(resources: Dictionary, max_items: int = 3, include_diamond: bool = true) -> String:
	return BaseSurfaceSummaryScript.format_short_resources(resources, max_items, include_diamond)

static func _routine_collect_display_text(routine: Dictionary) -> String:
	return BaseSurfaceSummaryScript.routine_collect_display_text(routine)

static func _routine_upgrade_display_text(routine: Dictionary) -> String:
	return BaseSurfaceSummaryScript.routine_upgrade_display_text(routine)

static func _resource_total(resources: Dictionary) -> float:
	return BaseSurfaceSummaryScript.resource_total(resources)

static func _resource_label(key: String) -> String:
	return BaseSurfaceSummaryScript.resource_label(key)

static func _structure_label(structure_id: String, fallback: String = "") -> String:
	return BaseSurfaceSummaryScript.structure_label(structure_id, fallback)

static func _content_body(host: Node) -> VBoxContainer:
	return host.get("_content_body") as VBoxContainer

static func _timeline_label(host: Node) -> Label:
	return host.get("_timeline_label") as Label

static func _base_state_container(host: Node) -> VBoxContainer:
	return host.get("_base_state_container") as VBoxContainer

static func _selected_base_structure_id(host: Node) -> String:
	return str(host.get("_selected_base_structure_id"))

static func _compact_layout(host: Node) -> bool:
	return bool(host.get("_compact_layout"))

static func _is_refuge_screen(host: Node) -> bool:
	return str(host.get("_current_screen")) == "refuge"

static func _base_map_columns(host: Node) -> int:
	return int(host.call("_base_map_columns"))

static func _button_min_size(host: Node) -> Vector2:
	var min_size: Vector2 = host.call("_button_min_size")
	return min_size

static func _add_body_text(host: Node, text: String) -> Label:
	return host.call("_add_body_text", text) as Label

static func _add_output_label(host: Node, text: String) -> Label:
	return host.call("_add_output_label", text) as Label

static func _add_action_button(host: Node, text: String, action_id: String, confirm_message: String = "") -> Button:
	return host.call("_add_action_button", text, action_id, confirm_message) as Button

static func _register_action_button(host: Node, action_id: String, button: Button) -> void:
	var action_buttons: Dictionary = host.get("_action_buttons")
	action_buttons[action_id] = button

static func _prepare_touch_button(host: Node, button: Button) -> void:
	host.call("_prepare_touch_button", button)

static func _add_responsive_panel_layout(host: Node, container: VBoxContainer, panels: Array, max_columns: int) -> void:
	host.call("_add_responsive_panel_layout", container, panels, max_columns)

static func _clear_node_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

static func _panel_style(host: Node, bg_token: String, border_token: String) -> StyleBoxFlat:
	return BaseSurfaceVisualsScript.panel_style(host, bg_token, border_token)

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
