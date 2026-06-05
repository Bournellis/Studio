extends RefCounted

const RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "po_osso", "diamante"]
const BASE_STRUCTURE_IDS := ["altar_das_almas", "nucleo_energia", "pocos_sangue", "minas_cristal", "estrutura_stats", "ossario"]

static func routine_summary(base: Dictionary, collected: Dictionary = {}) -> Dictionary:
	var structures := as_array(base.get("structures", []))
	var active_jobs := active_base_jobs(as_array(base.get("jobs", [])))
	var slots: int = maxi(0, int(base.get("construction_slots", 1)))
	var free_slots: int = maxi(0, slots - active_jobs.size())
	var collect_ready := collect_ready_resources(structures)
	var next_upgrade := next_upgrade_candidate(structures)
	return {
		"collect_ready": collect_ready,
		"collect_text": routine_collect_text(collect_ready, collected),
		"has_collect_ready": not collect_ready.is_empty(),
		"active_job_count": active_jobs.size(),
		"job_lines": routine_job_lines(active_jobs),
		"construction_slots": slots,
		"free_slots": free_slots,
		"next_upgrade_id": str(next_upgrade.get("structure_id", "")),
		"next_upgrade_ready": bool(next_upgrade.get("can_upgrade", false)),
		"next_upgrade_text": routine_next_upgrade_text(next_upgrade),
	}

static func base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	for item: Variant in structures:
		var structure := as_dictionary(item)
		if str(structure.get("structure_id", "")) == structure_id:
			return structure
	return {}

static func active_base_jobs(jobs: Array) -> Array:
	var active: Array = []
	for item: Variant in jobs:
		var job := as_dictionary(item)
		if str(job.get("status", "")) == "active":
			active.append(job)
	return active

static func collect_ready_resources(structures: Array) -> Dictionary:
	var ready := {}
	for item: Variant in structures:
		var structure := as_dictionary(item)
		var resource_id := str(structure.get("produces", ""))
		if resource_id == "" or resource_id == "<null>":
			continue
		var amount := float(structure.get("pending_collectable", 0.0))
		if amount <= 0.005:
			continue
		ready[resource_id] = float(ready.get(resource_id, 0.0)) + amount
	return ready

static func routine_collect_text(collect_ready: Dictionary, collected: Dictionary) -> String:
	if not collect_ready.is_empty():
		return "Producao pendente: %s." % format_nonzero_resources(collect_ready)
	if resource_total(collected) > 0.0:
		return "Producao pendente: atualizada agora %s." % format_nonzero_resources(collected)
	return "Producao pendente: nada acumulado agora."

static func routine_job_lines(active_jobs: Array) -> Array:
	var lines: Array = []
	for item: Variant in active_jobs:
		var job := as_dictionary(item)
		var structure_id := str(job.get("structure_id", ""))
		var display_name := str(job.get("display_name", ""))
		lines.append("%s -> L%s | resta %s" % [
			structure_label(structure_id, display_name),
			str(job.get("target_level", "?")),
			format_duration(int(job.get("remaining_seconds", 0))),
		])
	return lines

static func next_upgrade_candidate(structures: Array) -> Dictionary:
	var blocked_candidate := {}
	var active_candidate := {}
	for structure_id: String in BASE_STRUCTURE_IDS:
		var structure := base_structure_by_id(structures, structure_id)
		if structure.is_empty() or structure.get("next_level", null) == null:
			continue
		if bool(structure.get("can_upgrade", false)):
			return structure
		var active_job := as_dictionary(structure.get("active_job", {}))
		if active_job.is_empty() and blocked_candidate.is_empty():
			blocked_candidate = structure
		elif not active_job.is_empty() and active_candidate.is_empty():
			active_candidate = structure
	if not blocked_candidate.is_empty():
		return blocked_candidate
	return active_candidate

static func routine_next_upgrade_text(structure: Dictionary) -> String:
	if structure.is_empty():
		return "sem upgrade disponivel no payload atual."
	var structure_id := str(structure.get("structure_id", ""))
	var next_level: Variant = structure.get("next_level", null)
	if next_level == null:
		return "%s no nivel maximo." % structure_label(structure_id, str(structure.get("display_name", "")))
	var status := "pronto para iniciar" if bool(structure.get("can_upgrade", false)) else str(structure.get("blocked_message", "Upgrade indisponivel."))
	return "%s para L%s | custo %s | tempo %s | %s" % [
		structure_label(structure_id, str(structure.get("display_name", ""))),
		str(next_level),
		format_cost(as_dictionary(structure.get("upgrade_cost", {}))),
		format_duration(int(structure.get("upgrade_duration_seconds", 0))),
		status,
	]

static func format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "-"
	var parts := PackedStringArray()
	for key: String in cost.keys():
		parts.append("%s %s" % [str(key).capitalize(), format_number(float(cost.get(key, 0.0)))])
	return " | ".join(parts)

static func format_duration(total_seconds: int) -> String:
	var seconds: int = max(0, total_seconds)
	var hours := int(float(seconds) / 3600.0)
	var minutes := int(float(seconds % 3600) / 60.0)
	var remaining_seconds: int = seconds % 60
	if hours > 0:
		return "%dh %02dm" % [hours, minutes]
	if minutes > 0:
		return "%dm %02ds" % [minutes, remaining_seconds]
	return "%ds" % remaining_seconds

static func format_number(value: float) -> String:
	if abs(value - round(value)) < 0.005:
		return str(int(round(value)))
	return "%.2f" % value

static func format_nonzero_resources(resources: Dictionary) -> String:
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		var amount := float(resources.get(key, 0.0))
		if amount > 0.005:
			parts.append("%s %s" % [resource_label(key), format_number(amount)])
	for raw_key: Variant in resources.keys():
		var key := str(raw_key)
		if RESOURCE_KEYS.has(key):
			continue
		var amount := float(resources.get(key, 0.0))
		if amount > 0.005:
			parts.append("%s %s" % [resource_label(key), format_number(amount)])
	if parts.is_empty():
		return "nenhum recurso"
	return " | ".join(parts)

static func format_resources(resources: Dictionary, include_diamond: bool = true) -> String:
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		if key == "diamante" and not include_diamond:
			continue
		parts.append("%s %s" % [resource_label(key), format_number(float(resources.get(key, 0)))])
	return " | ".join(parts)

static func format_short_resources(resources: Dictionary, max_items: int = 3, include_diamond: bool = true) -> String:
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		if key == "diamante" and not include_diamond:
			continue
		if not resources.has(key):
			continue
		parts.append("%s %s" % [resource_label(key), str(resources.get(key, 0))])
		if parts.size() >= max_items:
			break
	var remaining := 0
	for key: String in RESOURCE_KEYS:
		if key == "diamante" and not include_diamond:
			continue
		if resources.has(key) and not parts.has("%s %s" % [resource_label(key), format_number(float(resources.get(key, 0)))]):
			remaining += 1
	if remaining > 0:
		parts.append("+%d" % remaining)
	if parts.is_empty():
		return "sem recursos"
	return ", ".join(parts)

static func routine_collect_display_text(routine: Dictionary) -> String:
	var collect_ready := as_dictionary(routine.get("collect_ready", {}))
	if collect_ready.is_empty():
		return "Producao pendente: nada agora."
	return "Producao pendente: %s." % format_short_resources(collect_ready, 3, false)

static func routine_upgrade_display_text(routine: Dictionary) -> String:
	var next_upgrade_id := str(routine.get("next_upgrade_id", ""))
	if next_upgrade_id == "":
		return "sem upgrade disponivel"
	var status := "pronto" if bool(routine.get("next_upgrade_ready", false)) else "aguardando recursos"
	return "%s %s" % [structure_label(next_upgrade_id), status]

static func resource_total(resources: Dictionary) -> float:
	var total := 0.0
	for key: String in RESOURCE_KEYS:
		total += float(resources.get(key, 0.0))
	return total

static func resource_label(key: String) -> String:
	match key:
		"po_osso":
			return "Po de Osso"
		"almas":
			return "Almas"
		"energia":
			return "Energia"
		"sangue":
			return "Sangue"
		"cristais":
			return "Cristais"
		"ossos":
			return "Ossos"
		"diamante":
			return "Diamante"
		_:
			return key.capitalize()

static func structure_label(structure_id: String, fallback: String = "") -> String:
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

static func as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
