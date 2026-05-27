extends RefCounted

static func active_hint(field_effects: Array[String]) -> String:
	if field_effects.is_empty():
		return ""
	var labels: Array[String] = []
	for effect_id: String in field_effects:
		var tooltip: String = ContentLibrary.board_effect_tooltip_text(effect_id)
		if tooltip == "":
			labels.append(effect_id)
			continue
		labels.append(tooltip.split(":")[0])
	return "Efeito de campo ativo: %s." % ", ".join(labels)
