extends Node

const CATALOG_PATH: String = "res://data/generated/slice_catalog.tres"
const ContentGeneratorScript = preload("res://tools/content_generator.gd")

var _catalog

func ensure_loaded():
	if _catalog != null:
		return _catalog
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(result.get("ok", false)):
		push_error(str(result.get("message", "Content generation failed.")))
		return null
	_catalog = load(CATALOG_PATH)
	if _catalog == null:
		push_error("Failed to load generated slice catalog.")
	return _catalog

func reload() -> void:
	_catalog = null
	ensure_loaded()

func get_catalog():
	return ensure_loaded()

func get_card(card_id: String):
	var catalog = ensure_loaded()
	if catalog == null:
		return null
	return catalog.find_card(card_id)

func get_card_name(card_id: String) -> String:
	var catalog = ensure_loaded()
	if catalog == null:
		return card_id
	return catalog.card_name(card_id)

func get_starter_deck_ids() -> Array:
	var catalog = ensure_loaded()
	if catalog == null:
		return []
	return Array(catalog.starter_deck_ids)

func get_class_options() -> Array:
	var catalog = ensure_loaded()
	if catalog == null:
		return []
	return Array(catalog.class_options)

func find_class_option(class_id: String) -> Dictionary:
	var catalog = ensure_loaded()
	if catalog == null:
		return {}
	return catalog.find_class_option(class_id)

func get_default_encounter_id() -> String:
	var catalog = ensure_loaded()
	if catalog == null:
		return ""
	return catalog.default_encounter_id

func get_all_encounters() -> Array:
	var catalog = ensure_loaded()
	if catalog == null:
		return []
	return catalog.all_encounters()

func get_encounter_display_name(encounter_id: String) -> String:
	var catalog = ensure_loaded()
	if catalog == null:
		return encounter_id
	var encounter: Dictionary = catalog.find_encounter(encounter_id)
	return str(encounter.get("display_name", encounter_id))

func get_run_map() -> Dictionary:
	var catalog = ensure_loaded()
	if catalog == null:
		return {}
	return Dictionary(catalog.run_map)

func get_track_contract() -> Dictionary:
	var catalog = ensure_loaded()
	if catalog == null:
		return {}
	return Dictionary(catalog.track_contract)

func get_reward_schedule() -> Array:
	var contract: Dictionary = get_track_contract()
	return Array(contract.get("reward_schedule", []))

func get_shop_prices() -> Dictionary:
	var contract: Dictionary = get_track_contract()
	return Dictionary(contract.get("shop_prices", {}))

func get_keyword_definitions() -> Array:
	var contract: Dictionary = get_track_contract()
	return Array(contract.get("keyword_definitions", []))

func get_keyword_definition(keyword_id: String) -> Dictionary:
	var normalized_id: String = normalize_keyword_id(keyword_id)
	for definition: Variant in get_keyword_definitions():
		if typeof(definition) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(definition)
		if str(data.get("id", "")) == normalized_id:
			return data
	return {}

func get_keyword_display_name(keyword_id: String) -> String:
	var definition: Dictionary = get_keyword_definition(keyword_id)
	if definition.is_empty():
		return _humanize_id(keyword_id)
	return str(definition.get("display_name", _humanize_id(keyword_id)))

func keyword_tooltip_text(keyword_id: String) -> String:
	var definition: Dictionary = get_keyword_definition(keyword_id)
	if definition.is_empty():
		return "Keyword sem definicao: %s" % keyword_id
	var lines: Array[String] = [
		"%s: %s" % [str(definition.get("display_name", _humanize_id(keyword_id))), str(definition.get("tooltip", definition.get("summary", "")))]
	]
	var timing: String = str(definition.get("timing", ""))
	if timing != "":
		lines.append("Timing: %s" % timing)
	var status: String = str(definition.get("status", ""))
	if status != "" and status != "implemented":
		lines.append("Status: %s" % status)
	return "\n".join(lines)

func keywords_tooltip_text(keywords: Array) -> String:
	var parts: Array[String] = []
	for keyword: Variant in keywords:
		var tooltip: String = keyword_tooltip_text(str(keyword))
		if tooltip != "":
			parts.append(tooltip)
	return "\n".join(parts)

func get_status_definitions() -> Array:
	var contract: Dictionary = get_track_contract()
	return Array(contract.get("status_definitions", []))

func status_summary_parts(data: Dictionary) -> Array[String]:
	var parts: Array[String] = []
	for definition: Variant in get_status_definitions():
		if typeof(definition) != TYPE_DICTIONARY:
			continue
		var status: Dictionary = Dictionary(definition)
		var key: String = str(status.get("value_key", status.get("id", "")))
		if key == "" or not data.has(key):
			continue
		var value: Variant = data.get(key)
		if typeof(value) == TYPE_BOOL:
			if not bool(value):
				continue
			parts.append(str(status.get("format", status.get("display_name", key))).replace("{value}", "1"))
			continue
		var amount: int = int(value)
		if amount <= 0:
			continue
		parts.append(str(status.get("format", status.get("display_name", key))).replace("{value}", str(amount)))
	return parts

func status_tooltip_text(data: Dictionary) -> String:
	var parts: Array[String] = []
	for definition: Variant in get_status_definitions():
		if typeof(definition) != TYPE_DICTIONARY:
			continue
		var status: Dictionary = Dictionary(definition)
		var key: String = str(status.get("value_key", status.get("id", "")))
		if key == "" or not data.has(key):
			continue
		var value: Variant = data.get(key)
		if typeof(value) == TYPE_BOOL and not bool(value):
			continue
		if typeof(value) != TYPE_BOOL and int(value) <= 0:
			continue
		var label: String = str(status.get("display_name", _humanize_id(key)))
		var tooltip: String = str(status.get("tooltip", ""))
		var timing: String = str(status.get("timing", ""))
		var line: String = "%s: %s" % [label, tooltip]
		if timing != "":
			line += " Timing: %s." % timing
		parts.append(line)
	return "\n".join(parts)

func card_tooltip_text(card_id: String, context: Dictionary = {}) -> String:
	var card = get_card(card_id)
	if card == null:
		return ""
	var lines: Array[String] = [str(card.display_name)]
	var subtitle: String = "%s | Custo %d" % [UiTokens.type_display_name(str(card.card_type)), int(card.cost)]
	if card.occupies_slot():
		subtitle += " | %d/%d" % [int(card.attack), int(card.health)]
	lines.append(subtitle)
	var body: String = VisualAssets.card_display_text(card, context)
	if body != "":
		lines.append(body)
	var keywords: String = keywords_tooltip_text(Array(card.keywords))
	if keywords != "":
		lines.append(keywords)
	return "\n\n".join(lines)

func relic_tooltip_text(relic_id: String) -> String:
	var relic: Dictionary = get_relic_definition(relic_id)
	if relic.is_empty():
		return ""
	var lines: Array[String] = [
		str(relic.get("display_name", relic_id)),
		str(relic.get("effect_text", ""))
	]
	var status: String = str(relic.get("effect_status", "implemented"))
	if status != "implemented":
		lines.append("Efeito pendente: %s." % status)
	return "\n".join(lines)

func reward_choice_tooltip(choice: Dictionary) -> String:
	var body: String = str(choice.get("body", ""))
	if choice.has("card_id"):
		var card_text: String = card_tooltip_text(str(choice.get("card_id", "")))
		return _join_tooltip_sections(body, card_text)
	if choice.has("relic_id"):
		return _join_tooltip_sections(body, relic_tooltip_text(str(choice.get("relic_id", ""))))
	return body

func shop_choice_tooltip(choice: Dictionary) -> String:
	var cost_line: String = "Custo: %d Almas." % int(choice.get("cost", 0))
	return _join_tooltip_sections(cost_line, reward_choice_tooltip(choice))

func board_effect_tooltip_text(effect_id: String) -> String:
	for definition: Variant in Array(get_track_contract().get("board_effect_definitions", [])):
		if typeof(definition) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(definition)
		if str(data.get("id", "")) == effect_id:
			return "%s: %s" % [str(data.get("display_name", _humanize_id(effect_id))), str(data.get("tooltip", ""))]
	return ""

func enemy_intent_tooltip_text(intent_id: String) -> String:
	for definition: Variant in Array(get_track_contract().get("enemy_intent_definitions", [])):
		if typeof(definition) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(definition)
		if str(data.get("id", "")) == intent_id:
			return "%s: %s" % [str(data.get("display_name", _humanize_id(intent_id))), str(data.get("tooltip", ""))]
	return ""

func missing_tooltip_report() -> Array[String]:
	var missing: Array[String] = []
	var keyword_ids: Array[String] = []
	for definition: Variant in get_keyword_definitions():
		if typeof(definition) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = Dictionary(definition)
		var keyword_id: String = str(data.get("id", ""))
		if keyword_id == "":
			missing.append("Keyword definition without id.")
			continue
		keyword_ids.append(keyword_id)
		if str(data.get("display_name", "")) == "" or str(data.get("tooltip", "")) == "":
			missing.append("Keyword %s needs display_name and tooltip." % keyword_id)
	for card in get_catalog().cards:
		for keyword: String in card.keywords:
			if not keyword_ids.has(normalize_keyword_id(keyword)):
				missing.append("Card %s references missing keyword tooltip %s." % [str(card.id), keyword])
	for relic: Variant in get_relic_definitions():
		if typeof(relic) == TYPE_DICTIONARY:
			var relic_data: Dictionary = Dictionary(relic)
			if str(relic_data.get("display_name", "")) == "" or str(relic_data.get("effect_text", "")) == "":
				missing.append("Relic %s needs tooltip text." % str(relic_data.get("id", "")))
	for surface: Variant in Array(get_track_contract().get("tooltip_surfaces", [])):
		if str(surface) == "":
			missing.append("Tooltip surface entry cannot be empty.")
	return missing

func normalize_keyword_id(keyword_id: String) -> String:
	var normalized: String = keyword_id.strip_edges().to_lower()
	normalized = normalized.replace(" ", "_")
	normalized = normalized.replace("-", "_")
	if normalized == "remover_keyword":
		normalized = "remover_keywords"
	return normalized

func get_relic_definitions() -> Array:
	var contract: Dictionary = get_track_contract()
	return Array(contract.get("relics", []))

func get_relic_definition(relic_id: String) -> Dictionary:
	for relic: Variant in get_relic_definitions():
		if typeof(relic) != TYPE_DICTIONARY:
			continue
		var relic_data: Dictionary = Dictionary(relic)
		if str(relic_data.get("id", "")) == relic_id:
			return relic_data
	return {}

func get_relic_display_name(relic_id: String) -> String:
	var relic: Dictionary = get_relic_definition(relic_id)
	if relic.is_empty():
		return relic_id
	return str(relic.get("display_name", relic_id))

func get_relics_by_rarity(rarity_ids: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for relic: Variant in get_relic_definitions():
		if typeof(relic) != TYPE_DICTIONARY:
			continue
		var relic_data: Dictionary = Dictionary(relic)
		if rarity_ids.has(str(relic_data.get("rarity", ""))):
			result.append(relic_data)
	return result

func find_reward_schedule_entry(map_index: int) -> Dictionary:
	for entry: Variant in get_reward_schedule():
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var entry_data: Dictionary = Dictionary(entry)
		if int(entry_data.get("map", 0)) == map_index:
			return entry_data
	return {}

func _join_tooltip_sections(first: String, second: String) -> String:
	if first == "":
		return second
	if second == "":
		return first
	return "%s\n\n%s" % [first, second]

func _humanize_id(value: String) -> String:
	return value.replace("_", " ").capitalize()
