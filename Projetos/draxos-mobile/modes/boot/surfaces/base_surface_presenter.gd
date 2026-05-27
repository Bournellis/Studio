class_name BootBaseSurfacePresenter
extends RefCounted

const RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]
const BASE_STRUCTURE_IDS := ["altar_das_almas", "nucleo_energia", "pocos_sangue", "minas_cristal", "estrutura_stats", "ossario"]

static func render(host: Node) -> void:
	_add_body_text(host, "Base do Refugio: predios permanentes, coleta offline e uma fila de construcao server-authoritative.")
	_add_action_button(host, "Atualizar base", "show_base")
	_add_action_button(host, "Coletar producao", "collect_base", "Coletar a producao offline acumulada da base?")
	_add_action_button(host, "Comprar Energia alpha", "buy_energy_pack_alpha", "Gastar 80 Diamantes para comprar 80 Energia no save ativo?")
	host.set("_timeline_label", _add_output_label(host, ""))
	var base_state_container := VBoxContainer.new()
	base_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	base_state_container.add_theme_constant_override("separation", 10)
	_content_body(host).add_child(base_state_container)
	host.set("_base_state_container", base_state_container)
	render_state(host)

static func render_state(host: Node, collected: Dictionary = {}) -> void:
	var timeline := _timeline_label(host)
	if timeline == null:
		return
	var container := _base_state_container(host)
	if container != null:
		_clear_node_children(container)
	var base := SessionStore.base_state
	if base.is_empty():
		timeline.text = "Base ainda nao carregada. Use Atualizar base."
		if container != null:
			container.add_child(_base_info_panel(
				host,
				"Base nao carregada",
				"Use Atualizar base para buscar os predios, a fila de construcao e os recursos no servidor."
			))
		return

	var resources := SessionStore.resources
	var lines := PackedStringArray()
	if SessionStore.is_progression_lab_local_only():
		lines.append("Refugio Progression Lab local (somente leitura)")
		lines.append("Acoes online exigem cache server-backed criado pelo seeder Supabase.")
	else:
		lines.append("Refugio server-authoritative")
	lines.append("Recursos: %s" % _format_resources(resources))
	if not collected.is_empty():
		if _resource_total(collected) <= 0.0:
			lines.append("Coleta: nada acumulado agora.")
		else:
			lines.append("Coletado: %s" % _format_resources(collected, false))

	var structures := _as_array(base.get("structures", []))
	if structures.is_empty():
		lines.append("Estruturas: nenhuma estrutura retornada pelo servidor.")
	else:
		lines.append("Estruturas: %d predios clicaveis no mapa abaixo." % structures.size())
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		if structure.is_empty():
			continue
		lines.append("- %s L%s | pendente %s/%s | %s" % [
			_structure_label(str(structure.get("structure_id", "")), str(structure.get("display_name", ""))),
			str(structure.get("level", 0)),
			_format_number(float(structure.get("pending_collectable", 0.0))),
			_format_number(float(structure.get("storage_cap", 0.0))),
			str(structure.get("blocked_message", "Upgrade bloqueado.")),
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
	var base := SessionStore.base_state
	var structures := _as_array(base.get("structures", []))
	var structure := _base_structure_by_id(structures, structure_id)
	return bool(structure.get("can_upgrade", false))

static func routine_summary(base: Dictionary, collected: Dictionary = {}) -> Dictionary:
	var structures := _as_array(base.get("structures", []))
	var active_jobs := _active_base_jobs(_as_array(base.get("jobs", [])))
	var slots: int = maxi(0, int(base.get("construction_slots", 1)))
	var free_slots: int = maxi(0, slots - active_jobs.size())
	var collect_ready := _collect_ready_resources(structures)
	var next_upgrade := _next_upgrade_candidate(structures)
	return {
		"collect_ready": collect_ready,
		"collect_text": _routine_collect_text(collect_ready, collected),
		"has_collect_ready": not collect_ready.is_empty(),
		"active_job_count": active_jobs.size(),
		"job_lines": _routine_job_lines(active_jobs),
		"construction_slots": slots,
		"free_slots": free_slots,
		"next_upgrade_id": str(next_upgrade.get("structure_id", "")),
		"next_upgrade_ready": bool(next_upgrade.get("can_upgrade", false)),
		"next_upgrade_text": _routine_next_upgrade_text(next_upgrade),
	}

static func _render_playable_panels(host: Node, structures: Array, base: Dictionary, collected: Dictionary) -> void:
	var container := _base_state_container(host)
	if container == null:
		return
	_ensure_selected_base_structure(host, structures)
	_add_responsive_panel_layout(host, container, [
		_base_summary_panel(host, base, collected),
		_base_routine_panel(host, base, collected),
		_base_map_panel(host, structures),
		_base_detail_panel(host, structures),
	], 2)

static func _base_summary_panel(host: Node, base: Dictionary, collected: Dictionary) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Resumo da Base", "text_primary", 17))
	box.add_child(_base_label(host, "Recursos: %s" % _format_resources(SessionStore.resources), "text_secondary"))
	var active_jobs := _active_base_jobs(_as_array(base.get("jobs", [])))
	box.add_child(_base_label(host, "Fila de construcao: %d/%d" % [
		active_jobs.size(),
		int(base.get("construction_slots", 1)),
	], "text_secondary"))
	if not collected.is_empty():
		var collect_text := "Coleta: nada acumulado agora."
		if _resource_total(collected) > 0.0:
			collect_text = "Coletado agora: %s" % _format_resources(collected, false)
		box.add_child(_base_label(host, collect_text, "status_success"))
	if SessionStore.is_progression_lab_active():
		box.add_child(_base_label(host, "Progression Lab: base isolada do save normal.", "status_warning"))
	return panel

static func _base_routine_panel(host: Node, base: Dictionary, collected: Dictionary) -> Control:
	var routine := routine_summary(base, collected)
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, "Rotina da Base", "text_primary", 17))

	var collect_color := "status_success" if bool(routine.get("has_collect_ready", false)) else "text_secondary"
	box.add_child(_base_label(host, str(routine.get("collect_text", "Coleta pronta: sem dados da Base.")), collect_color))

	var active_job_count := int(routine.get("active_job_count", 0))
	if active_job_count <= 0:
		box.add_child(_base_label(host, "Jobs em andamento: nenhum.", "text_secondary"))
	else:
		box.add_child(_base_label(host, "Jobs em andamento: %d." % active_job_count, "text_secondary"))
		for line: String in Array(routine.get("job_lines", [])):
			box.add_child(_base_label(host, "- %s" % line, "text_secondary"))

	var free_slots := int(routine.get("free_slots", 0))
	var slots := int(routine.get("construction_slots", 0))
	var slot_color := "status_success" if free_slots > 0 else "status_warning"
	box.add_child(_base_label(host, "Slots livres: %d/%d." % [free_slots, slots], slot_color))

	var upgrade_color := "status_success" if bool(routine.get("next_upgrade_ready", false)) else "text_secondary"
	box.add_child(_base_label(host, "Proximo upgrade: %s" % str(routine.get("next_upgrade_text", "")), upgrade_color))
	return panel

static func _base_map_panel(host: Node, structures: Array) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_base_label(host, "Mapa da Base", "text_primary", 17))
	var grid := GridContainer.new()
	grid.columns = _base_map_columns(host)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	box.add_child(grid)
	for structure_id: String in BASE_STRUCTURE_IDS:
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
		box.add_child(_base_label(host, "Selecione um predio no mapa da Base.", "text_secondary"))
		return panel

	var structure_id := str(structure.get("structure_id", ""))
	var display_label := _structure_label(structure_id, str(structure.get("display_name", "")))
	box.add_child(_base_label(host, "%s - Level %s/%s" % [
		display_label,
		str(structure.get("level", 0)),
		str(structure.get("max_level", 40)),
	], "text_primary", 18))
	box.add_child(_base_label(host, str(structure.get("description", "")), "text_secondary"))
	box.add_child(_base_label(host, "Beneficio: %s" % _base_benefit_text(structure), "text_secondary"))
	box.add_child(_base_label(host, "Producao pendente: %s" % _base_pending_text(structure), "text_secondary"))
	box.add_child(_base_label(host, "Proximo upgrade: %s" % _base_upgrade_text(structure), "text_secondary"))
	box.add_child(_base_label(host, "Status: %s" % str(structure.get("blocked_message", "")), _base_status_color_token(structure)))

	var action_id := "upgrade_base_structure:%s" % structure_id
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
	button.custom_minimum_size = Vector2(148, 96) if _compact_layout(host) else Vector2(190, 112)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = _base_structure_tooltip(structure)
	button.add_theme_stylebox_override("normal", _base_structure_card_style(structure_id, selected))
	button.add_theme_stylebox_override("hover", _base_structure_card_style(structure_id, true))
	button.add_theme_stylebox_override("pressed", _base_structure_card_style(structure_id, true))
	_prepare_touch_button(host, button)
	var action_id := "select_base_structure:%s" % structure_id
	button.pressed.connect(func() -> void:
		host.call("_trigger_action", action_id)
	)
	_register_action_button(host, action_id, button)
	return button

static func _ensure_selected_base_structure(host: Node, structures: Array) -> void:
	var selected_id := _selected_base_structure_id(host)
	if not _base_structure_by_id(structures, selected_id).is_empty():
		return
	for structure_id: String in BASE_STRUCTURE_IDS:
		if not _base_structure_by_id(structures, structure_id).is_empty():
			host.set("_selected_base_structure_id", structure_id)
			return
	if not structures.is_empty():
		host.set("_selected_base_structure_id", str(_as_dictionary(structures[0]).get("structure_id", selected_id)))

static func _base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		if str(structure.get("structure_id", "")) == structure_id:
			return structure
	return {}

static func _base_panel(host: Node) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(host, "bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return panel

static func _base_info_panel(host: Node, title_text: String, body_text: String) -> Control:
	var panel := _base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_base_label(host, title_text, "text_primary", 17))
	box.add_child(_base_label(host, body_text, "text_secondary"))
	return panel

static func _base_label(host: Node, text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	if font_size > 0:
		label.add_theme_font_size_override("font_size", max(12, font_size - 1) if _compact_layout(host) else font_size)
	elif _compact_layout(host):
		label.add_theme_font_size_override("font_size", 13)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func _base_structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _base_structure_color(structure_id).darkened(0.25 if selected else 0.45)
	style.border_color = UiTokens.color("status_success") if selected else UiTokens.color("border_default")
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func _base_structure_color(structure_id: String) -> Color:
	match structure_id:
		"altar_das_almas":
			return Color(0.45, 0.35, 0.78)
		"nucleo_energia":
			return Color(0.25, 0.58, 0.86)
		"pocos_sangue":
			return Color(0.70, 0.20, 0.26)
		"minas_cristal":
			return Color(0.22, 0.66, 0.62)
		"estrutura_stats":
			return Color(0.58, 0.58, 0.50)
		"ossario":
			return Color(0.72, 0.66, 0.54)
	return UiTokens.color("bg_panel_alt")

static func _base_structure_symbol(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "[ALM]"
		"nucleo_energia":
			return "[ENE]"
		"pocos_sangue":
			return "[SAN]"
		"minas_cristal":
			return "[CRI]"
		"estrutura_stats":
			return "[STA]"
		"ossario":
			return "[OSS]"
	return "[???]"

static func _base_structure_short_label(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "Altar"
		"nucleo_energia":
			return "Nucleo"
		"pocos_sangue":
			return "Pocos"
		"minas_cristal":
			return "Minas"
		"estrutura_stats":
			return "Stats"
		"ossario":
			return "Ossario"
	return structure_id

static func _base_benefit_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces != "" and produces != "<null>":
		return "%s por dia: %s | armazenamento: %s" % [
			produces.capitalize(),
			_format_number(float(structure.get("daily_production", 0.0))),
			_format_number(float(structure.get("storage_cap", 0.0))),
		]
	return str(structure.get("benefit_label", "Bonus permanente."))

static func _base_pending_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces == "" or produces == "<null>":
		return "Este predio nao gera coleta direta."
	return "%s %s de %s" % [
		_format_number(float(structure.get("pending_collectable", 0.0))),
		produces.capitalize(),
		_format_number(float(structure.get("storage_cap", 0.0))),
	]

static func _base_upgrade_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	if next_level == null:
		return "nivel maximo"
	var cost := _as_dictionary(structure.get("upgrade_cost", {}))
	return "L%s | custo %s | tempo %s" % [
		str(next_level),
		_format_cost(cost),
		_format_duration(int(structure.get("upgrade_duration_seconds", 0))),
	]

static func _base_next_level_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	return "max" if next_level == null else "L%s" % str(next_level)

static func _base_short_status(structure: Dictionary) -> String:
	var active_job := _as_dictionary(structure.get("active_job", {}))
	if not active_job.is_empty():
		return "Upgrade %s" % _format_duration(int(active_job.get("remaining_seconds", 0)))
	if bool(structure.get("can_upgrade", false)):
		return "Upgrade pronto"
	return str(structure.get("blocked_message", "Bloqueado"))

static func _base_status_color_token(structure: Dictionary) -> String:
	if bool(structure.get("can_upgrade", false)):
		return "status_success"
	var reason := str(structure.get("blocked_reason", ""))
	if reason == "INSUFFICIENT_RESOURCES" or reason == "CONSTRUCTION_QUEUE_FULL":
		return "status_warning"
	return "text_secondary"

static func _base_structure_tooltip(structure: Dictionary) -> String:
	var structure_id := str(structure.get("structure_id", ""))
	return "%s\nO que e: %s\nComo funciona: %s\nImporta porque: %s" % [
		_structure_label(structure_id, str(structure.get("display_name", ""))),
		str(structure.get("description", "")),
		_base_upgrade_text(structure),
		_base_benefit_text(structure),
	]

static func _active_base_jobs(jobs: Array) -> Array:
	var active: Array = []
	for item: Variant in jobs:
		var job := _as_dictionary(item)
		if str(job.get("status", "")) == "active":
			active.append(job)
	return active

static func _collect_ready_resources(structures: Array) -> Dictionary:
	var ready := {}
	for item: Variant in structures:
		var structure := _as_dictionary(item)
		var resource_id := str(structure.get("produces", ""))
		if resource_id == "" or resource_id == "<null>":
			continue
		var amount := float(structure.get("pending_collectable", 0.0))
		if amount <= 0.005:
			continue
		ready[resource_id] = float(ready.get(resource_id, 0.0)) + amount
	return ready

static func _routine_collect_text(collect_ready: Dictionary, collected: Dictionary) -> String:
	if not collect_ready.is_empty():
		return "Coleta pronta: %s." % _format_nonzero_resources(collect_ready)
	if _resource_total(collected) > 0.0:
		return "Coleta pronta: coletado agora %s." % _format_nonzero_resources(collected)
	return "Coleta pronta: nada acumulado agora."

static func _routine_job_lines(active_jobs: Array) -> Array:
	var lines: Array = []
	for item: Variant in active_jobs:
		var job := _as_dictionary(item)
		var structure_id := str(job.get("structure_id", ""))
		var display_name := str(job.get("display_name", ""))
		lines.append("%s -> L%s | resta %s" % [
			_structure_label(structure_id, display_name),
			str(job.get("target_level", "?")),
			_format_duration(int(job.get("remaining_seconds", 0))),
		])
	return lines

static func _next_upgrade_candidate(structures: Array) -> Dictionary:
	var blocked_candidate := {}
	var active_candidate := {}
	for structure_id: String in BASE_STRUCTURE_IDS:
		var structure := _base_structure_by_id(structures, structure_id)
		if structure.is_empty() or structure.get("next_level", null) == null:
			continue
		if bool(structure.get("can_upgrade", false)):
			return structure
		var active_job := _as_dictionary(structure.get("active_job", {}))
		if active_job.is_empty() and blocked_candidate.is_empty():
			blocked_candidate = structure
		elif not active_job.is_empty() and active_candidate.is_empty():
			active_candidate = structure
	if not blocked_candidate.is_empty():
		return blocked_candidate
	return active_candidate

static func _routine_next_upgrade_text(structure: Dictionary) -> String:
	if structure.is_empty():
		return "sem upgrade disponivel no payload atual."
	var structure_id := str(structure.get("structure_id", ""))
	var next_level: Variant = structure.get("next_level", null)
	if next_level == null:
		return "%s no nivel maximo." % _structure_label(structure_id, str(structure.get("display_name", "")))
	var status := "pronto para iniciar" if bool(structure.get("can_upgrade", false)) else str(structure.get("blocked_message", "Upgrade bloqueado."))
	return "%s para L%s | custo %s | tempo %s | %s" % [
		_structure_label(structure_id, str(structure.get("display_name", ""))),
		str(next_level),
		_format_cost(_as_dictionary(structure.get("upgrade_cost", {}))),
		_format_duration(int(structure.get("upgrade_duration_seconds", 0))),
		status,
	]

static func _format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "-"
	var parts := PackedStringArray()
	for key: String in cost.keys():
		parts.append("%s %s" % [str(key).capitalize(), _format_number(float(cost.get(key, 0.0)))])
	return " | ".join(parts)

static func _format_duration(total_seconds: int) -> String:
	var seconds: int = max(0, total_seconds)
	var hours := int(float(seconds) / 3600.0)
	var minutes := int(float(seconds % 3600) / 60.0)
	var remaining_seconds: int = seconds % 60
	if hours > 0:
		return "%dh %02dm" % [hours, minutes]
	if minutes > 0:
		return "%dm %02ds" % [minutes, remaining_seconds]
	return "%ds" % remaining_seconds

static func _format_number(value: float) -> String:
	if abs(value - round(value)) < 0.005:
		return str(int(round(value)))
	return "%.2f" % value

static func _format_nonzero_resources(resources: Dictionary) -> String:
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		var amount := float(resources.get(key, 0.0))
		if amount > 0.005:
			parts.append("%s %s" % [key.capitalize(), _format_number(amount)])
	for raw_key: Variant in resources.keys():
		var key := str(raw_key)
		if RESOURCE_KEYS.has(key):
			continue
		var amount := float(resources.get(key, 0.0))
		if amount > 0.005:
			parts.append("%s %s" % [key.capitalize(), _format_number(amount)])
	if parts.is_empty():
		return "nenhum recurso"
	return " | ".join(parts)

static func _format_resources(resources: Dictionary, include_diamond: bool = true) -> String:
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		if key == "diamante" and not include_diamond:
			continue
		parts.append("%s %s" % [key.capitalize(), str(resources.get(key, 0))])
	return " | ".join(parts)

static func _resource_total(resources: Dictionary) -> float:
	var total := 0.0
	for key: String in RESOURCE_KEYS:
		total += float(resources.get(key, 0.0))
	return total

static func _structure_label(structure_id: String, fallback: String = "") -> String:
	if fallback != "":
		return fallback
	match structure_id:
		"altar_das_almas":
			return "Altar das Almas"
		"nucleo_energia":
			return "Nucleo de Energia"
		"pocos_sangue":
			return "Pocos de Sangue"
		"minas_cristal":
			return "Minas de Cristal"
		"estrutura_stats":
			return "Estrutura de Stats"
		"ossario":
			return "Ossario"
	return structure_id

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
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color(bg_token)
	style.border_color = UiTokens.color(border_token)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10 if _compact_layout(host) else 14
	style.content_margin_right = 10 if _compact_layout(host) else 14
	style.content_margin_top = 8 if _compact_layout(host) else 12
	style.content_margin_bottom = 8 if _compact_layout(host) else 12
	return style

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
