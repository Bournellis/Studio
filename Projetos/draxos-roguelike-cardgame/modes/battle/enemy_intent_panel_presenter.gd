extends RefCounted

static func profile_text(intent: Dictionary) -> String:
	var text: String = "%s: %s" % [str(intent.get("profile_name", "")), str(intent.get("profile_summary", ""))]
	if str(intent.get("kind", "")) == "boss":
		return "%s | %s" % [str(intent.get("current_phase", "")), text]
	return text

static func body_text(intent: Dictionary, compact: bool) -> String:
	var lines: Array[String] = []
	for priority: Variant in Array(intent.get("priorities", [])):
		var priority_text: String = str(priority)
		if priority_text != "":
			lines.append(priority_text)
	var lanes: Array = Array(intent.get("lane_pressure", []))
	if not lanes.is_empty():
		lines.append(str(lanes[0]))
	if str(intent.get("kind", "")) == "boss":
		lines.append("Gatilho: %s" % str(intent.get("next_scripted_trigger", "")))
		lines.append("Especial: %s" % str(intent.get("next_major_special_action", "")))
	else:
		var field_hint: String = str(intent.get("incoming_field_effect", ""))
		if field_hint != "":
			lines.append(field_hint)
	var max_lines: int = 5 if compact else 6
	return "\n".join(lines.slice(0, max_lines))

static func tooltip_text(intent: Dictionary) -> String:
	var ids: Array = Array(intent.get("tooltip_ids", []))
	var lines: Array[String] = []
	for intent_id: Variant in ids:
		var tooltip: String = ContentLibrary.enemy_intent_tooltip_text(str(intent_id))
		if tooltip != "":
			lines.append(tooltip)
	if lines.is_empty():
		return str(intent.get("incoming_pressure", ""))
	return "\n\n".join(lines)
