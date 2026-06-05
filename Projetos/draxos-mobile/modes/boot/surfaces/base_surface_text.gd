class_name BootBaseSurfaceText
extends RefCounted

const BaseSurfaceSummaryScript := preload("res://modes/boot/surfaces/base_surface_summary.gd")

static func empty_refuge_timeline_text(has_valid_access_token: bool, progression_lab_local_only: bool) -> String:
	if has_valid_access_token:
		return "Refugio sincronizando automaticamente..."
	if progression_lab_local_only:
		return "Refugio local do Lab ainda sem dados carregados."
	return "Refugio pronto para carregar depois da entrada."

static func empty_refuge_body_text(has_valid_access_token: bool, progression_lab_local_only: bool) -> String:
	if has_valid_access_token:
		return "Sincronizando predios, producao e fila."
	if progression_lab_local_only:
		return "Carregue os dados do Lab."
	return "Entre ou use Guest dev para sincronizar."

static func strip_routine_prefix(text: String, prefix: String) -> String:
	var stripped := text.strip_edges()
	if stripped.begins_with(prefix):
		stripped = stripped.substr(prefix.length()).strip_edges()
	if stripped.ends_with("."):
		stripped = stripped.substr(0, stripped.length() - 1).strip_edges()
	return stripped

static func strip_after_separator(text: String) -> String:
	var stripped := text.strip_edges()
	var separator_index := stripped.find(" | ")
	if separator_index >= 0:
		stripped = stripped.substr(0, separator_index).strip_edges()
	if stripped.ends_with("."):
		stripped = stripped.substr(0, stripped.length() - 1).strip_edges()
	return stripped

static func benefit_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces != "" and produces != "<null>":
		return "%s por dia: %s | armazenamento: %s" % [
			produces.capitalize(),
			BaseSurfaceSummaryScript.format_number(float(structure.get("daily_production", 0.0))),
			BaseSurfaceSummaryScript.format_number(float(structure.get("storage_cap", 0.0))),
		]
	return str(structure.get("benefit_label", "Bonus permanente."))

static func pending_text(structure: Dictionary) -> String:
	var produces := str(structure.get("produces", ""))
	if produces == "" or produces == "<null>":
		return "Este predio nao gera recurso direto."
	return "%s %s de %s" % [
		BaseSurfaceSummaryScript.format_number(float(structure.get("pending_collectable", 0.0))),
		produces.capitalize(),
		BaseSurfaceSummaryScript.format_number(float(structure.get("storage_cap", 0.0))),
	]

static func upgrade_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	if next_level == null:
		return "nivel maximo"
	var cost := BaseSurfaceSummaryScript.as_dictionary(structure.get("upgrade_cost", {}))
	return "L%s | custo %s | tempo %s" % [
		str(next_level),
		BaseSurfaceSummaryScript.format_cost(cost),
		BaseSurfaceSummaryScript.format_duration(int(structure.get("upgrade_duration_seconds", 0))),
	]

static func next_level_text(structure: Dictionary) -> String:
	var next_level: Variant = structure.get("next_level", null)
	return "max" if next_level == null else "L%s" % str(next_level)

static func short_status(structure: Dictionary) -> String:
	var active_job := BaseSurfaceSummaryScript.as_dictionary(structure.get("active_job", {}))
	if not active_job.is_empty():
		return "Upgrade %s" % BaseSurfaceSummaryScript.format_duration(int(active_job.get("remaining_seconds", 0)))
	if bool(structure.get("can_upgrade", false)):
		return "Upgrade pronto"
	return str(structure.get("blocked_message", "Bloqueado"))

static func status_color_token(structure: Dictionary) -> String:
	if bool(structure.get("can_upgrade", false)):
		return "status_success"
	var reason := str(structure.get("blocked_reason", ""))
	if reason == "INSUFFICIENT_RESOURCES" or reason == "CONSTRUCTION_QUEUE_FULL":
		return "status_warning"
	return "text_secondary"

static func structure_tooltip(structure: Dictionary) -> String:
	var structure_id := str(structure.get("structure_id", ""))
	return "%s\nO que e: %s\nComo funciona: %s\nImporta porque: %s" % [
		BaseSurfaceSummaryScript.structure_label(structure_id, str(structure.get("display_name", ""))),
		str(structure.get("description", "")),
		upgrade_text(structure),
		benefit_text(structure),
	]

static func inventory_quantity(inventory: Array, item_id: String) -> int:
	for item_variant: Variant in inventory:
		var item := BaseSurfaceSummaryScript.as_dictionary(item_variant)
		if str(item.get("item_id", "")) == item_id:
			return int(item.get("quantity", 0))
	return 0
