extends RefCounted

const ProposalLoaderScript = preload("res://tools/lab/design_lab_proposal_loader.gd")

static func generate_variants(pack: Dictionary, registry: Dictionary, options: Dictionary = {}) -> Dictionary:
	var max_variants_per_card: int = maxi(1, int(options.get("max_variants", 40)))
	var card_filter: PackedStringArray = PackedStringArray(options.get("cards", PackedStringArray(["all"])))
	var specs: Array[Dictionary] = ProposalLoaderScript.filtered_card_specs(pack, card_filter)
	var variants: Array[Dictionary] = []
	var blocked_specs: Array[Dictionary] = []
	var errors: Array[String] = []
	for spec: Dictionary in specs:
		var blocked: Array[Dictionary] = ProposalLoaderScript.blocked_mechanics_for_card(spec, registry)
		if not blocked.is_empty():
			blocked_specs.append({
				"card_id": ProposalLoaderScript.card_spec_id(spec),
				"spec": spec.duplicate(true),
				"blocked_mechanics": blocked
			})
			continue
		var card_variants: Array[Dictionary] = _generate_card_variants(spec, max_variants_per_card)
		if card_variants.is_empty():
			errors.append("card `%s` generated no valid variants" % ProposalLoaderScript.card_spec_id(spec))
		variants.append_array(card_variants)
	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"variants": variants,
		"blocked_specs": blocked_specs,
		"summary": {
			"card_specs": specs.size(),
			"variants": variants.size(),
			"blocked_specs": blocked_specs.size(),
			"max_variants_per_card": max_variants_per_card
		}
	}

static func _generate_card_variants(spec: Dictionary, max_variants: int) -> Array[Dictionary]:
	var variant_space: Dictionary = Dictionary(spec.get("variant_space", {}))
	var fields: Array[String] = _sorted_keys(variant_space)
	var values_by_field: Dictionary = {}
	for field: String in fields:
		values_by_field[field] = _values_for_range(variant_space.get(field))
	var combos: Array[Dictionary] = []
	_expand_combos(fields, values_by_field, 0, {}, combos, max_variants)
	var result: Array[Dictionary] = []
	for numbers: Dictionary in combos:
		if not _numbers_are_valid(spec, numbers):
			continue
		var variant_id: String = _variant_id(spec, numbers)
		result.append({
			"variant_id": variant_id,
			"card_id": ProposalLoaderScript.card_spec_id(spec),
			"owner": str(spec.get("owner", "")),
			"role": str(spec.get("role", "")),
			"class_id": str(spec.get("class_id", "enemy" if str(spec.get("owner", "")) == "enemy" else "arcano")),
			"mechanics": Array(spec.get("mechanics", [])).duplicate(),
			"numbers": numbers.duplicate(true),
			"spec": spec.duplicate(true),
			"origin": "variant"
		})
		if result.size() >= max_variants:
			break
	return result

static func _expand_combos(fields: Array[String], values_by_field: Dictionary, index: int, current: Dictionary, result: Array[Dictionary], limit: int) -> void:
	if result.size() >= limit:
		return
	if index >= fields.size():
		result.append(current.duplicate(true))
		return
	var field: String = fields[index]
	for value: Variant in Array(values_by_field.get(field, [])):
		current[field] = value
		_expand_combos(fields, values_by_field, index + 1, current, result, limit)
		if result.size() >= limit:
			break
	current.erase(field)

static func _values_for_range(source: Variant) -> Array:
	if typeof(source) == TYPE_ARRAY:
		return Array(source).duplicate()
	if typeof(source) == TYPE_DICTIONARY:
		var data: Dictionary = Dictionary(source)
		if data.has("values") and typeof(data.get("values")) == TYPE_ARRAY:
			return Array(data.get("values", [])).duplicate()
		var min_value: int = int(data.get("min", data.get("value", 0)))
		var max_value: int = int(data.get("max", min_value))
		var step: int = maxi(1, int(data.get("step", 1)))
		var values: Array = []
		for number: int in range(min_value, max_value + 1, step):
			values.append(number)
		return values
	return [source]

static func _numbers_are_valid(spec: Dictionary, numbers: Dictionary) -> bool:
	var card_type: String = str(spec.get("type", spec.get("card_type", "")))
	var cost: int = int(numbers.get("cost", spec.get("cost", 0)))
	if cost < 0 or cost > 10:
		return false
	if card_type in ["criatura", "estrutura", "permanente", "unit", "structure", "support"]:
		var attack: int = int(numbers.get("attack", spec.get("attack", 0)))
		var health: int = int(numbers.get("health", spec.get("health", 0)))
		if attack < 0 or health <= 0:
			return false
	return true

static func _variant_id(spec: Dictionary, numbers: Dictionary) -> String:
	var parts: Array[String] = [ProposalLoaderScript.card_spec_id(spec)]
	for field: String in _sorted_keys(numbers):
		parts.append("%s_%s" % [_sanitize_field(field), str(numbers.get(field))])
	return "__".join(parts)

static func _sanitize_field(field: String) -> String:
	return field.replace(".", "_").replace("/", "_").replace(" ", "_")

static func _sorted_keys(values: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in values.keys():
		keys.append(str(key))
	keys.sort()
	return keys
