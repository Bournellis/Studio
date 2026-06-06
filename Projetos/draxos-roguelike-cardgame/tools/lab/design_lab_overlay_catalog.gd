extends RefCounted

const CardDefinitionResourceScript = preload("res://data/resources/card_definition_resource.gd")

static func build_overlay(base_catalog, pack: Dictionary, variants: Array[Dictionary]) -> Dictionary:
	if base_catalog == null:
		return {"ok": false, "message": "Missing base catalog."}
	var catalog = base_catalog.duplicate(true)
	var prototype_ids: Array[String] = []
	for variant: Dictionary in variants:
		var card = _build_card_resource(catalog, variant)
		if card == null:
			return {"ok": false, "message": "Could not build prototype card for `%s`." % str(variant.get("variant_id", ""))}
		catalog.cards.append(card)
		prototype_ids.append(str(card.id))
	_apply_encounter_overlays(catalog, pack)
	return {
		"ok": true,
		"catalog": catalog,
		"prototype_card_ids": prototype_ids,
		"official_card_count": Array(base_catalog.cards).size(),
		"overlay_card_count": Array(catalog.cards).size()
	}

static func _build_card_resource(catalog, variant: Dictionary):
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	var extends_id: String = str(spec.get("extends_card_id", ""))
	var card = null
	if extends_id != "":
		var base_card = catalog.find_card(extends_id)
		if base_card != null:
			card = base_card.duplicate(true)
	if card == null:
		card = CardDefinitionResourceScript.new()
	card.id = str(variant.get("variant_id", spec.get("new_card_id", spec.get("id", ""))))
	card.display_name = str(spec.get("display_name", card.id))
	if not str(card.display_name).contains("[DLab]"):
		card.display_name = "%s [DLab]" % card.display_name
	card.card_type = str(spec.get("type", spec.get("card_type", card.card_type)))
	card.cost = int(spec.get("cost", card.cost))
	card.command_cost = int(spec.get("command_cost", card.command_cost))
	card.speed = str(spec.get("speed", card.speed))
	card.attack = int(spec.get("attack", card.attack))
	card.health = int(spec.get("health", card.health))
	card.text = str(spec.get("text", card.text))
	card.keywords = PackedStringArray(Array(spec.get("keywords", Array(card.keywords))))
	var effect: Dictionary = Dictionary(card.effect).duplicate(true)
	for key: Variant in Dictionary(spec.get("effect", {})).keys():
		effect[key] = Dictionary(spec.get("effect", {})).get(key)
	card.effect = effect
	for field: String in _sorted_keys(Dictionary(variant.get("numbers", {}))):
		_apply_number(card, field, Dictionary(variant.get("numbers", {})).get(field))
	return card

static func _apply_number(card, field: String, value: Variant) -> void:
	match field:
		"cost":
			card.cost = int(value)
		"command_cost":
			card.command_cost = int(value)
		"attack":
			card.attack = int(value)
		"health":
			card.health = int(value)
		_:
			if field.begins_with("effect."):
				var key: String = field.trim_prefix("effect.")
				var effect: Dictionary = Dictionary(card.effect).duplicate(true)
				effect[key] = value
				card.effect = effect

static func _apply_encounter_overlays(catalog, pack: Dictionary) -> void:
	for encounter_value: Variant in Array(pack.get("encounters", [])):
		if typeof(encounter_value) == TYPE_DICTIONARY:
			_upsert_encounter(catalog, Dictionary(encounter_value))
	for context_value: Variant in Array(pack.get("encounter_contexts", [])):
		if typeof(context_value) != TYPE_DICTIONARY:
			continue
		var context: Dictionary = Dictionary(context_value)
		if typeof(context.get("encounter")) == TYPE_DICTIONARY:
			_upsert_encounter(catalog, Dictionary(context.get("encounter", {})))

static func _upsert_encounter(catalog, encounter: Dictionary) -> void:
	var encounter_id: String = str(encounter.get("id", ""))
	if encounter_id == "":
		return
	for index: int in range(catalog.encounters.size()):
		if str(Dictionary(catalog.encounters[index]).get("id", "")) == encounter_id:
			catalog.encounters[index] = encounter.duplicate(true)
			return
	catalog.encounters.append(encounter.duplicate(true))

static func _sorted_keys(values: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in values.keys():
		keys.append(str(key))
	keys.sort()
	return keys
