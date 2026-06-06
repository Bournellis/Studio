extends RefCounted

const ProposalLoaderScript = preload("res://tools/lab/design_lab_proposal_loader.gd")

const CLASS_SUPPORT: Dictionary = {
	"arcano": ["arcano_fagulha", "arcano_barreira", "arcano_choque", "arcano_fagulha"],
	"invocador": ["invocador_soldado", "invocador_batedor", "invocador_promover", "invocador_soldado"],
	"necromante": ["necro_esqueleto", "necro_morto_vivo", "necro_prender", "necro_esqueleto"]
}

static func build_cases(pack: Dictionary, variants: Array[Dictionary], options: Dictionary = {}) -> Dictionary:
	var cases: Array[Dictionary] = []
	var contexts: Array[Dictionary] = _typed_contexts(Array(pack.get("encounter_contexts", [])))
	for variant: Dictionary in variants:
		var owner: String = str(variant.get("owner", "player"))
		var matching_contexts: Array[Dictionary] = _contexts_for_variant(variant, contexts)
		if matching_contexts.is_empty():
			matching_contexts = [_default_context(owner)]
		for context: Dictionary in matching_contexts:
			if owner == "enemy":
				cases.append(_enemy_case(variant, context))
			else:
				cases.append(_player_case(variant, context))
	return {"ok": true, "cases": cases, "summary": {"cases": cases.size(), "variants": variants.size()}}

static func _player_case(variant: Dictionary, context: Dictionary) -> Dictionary:
	var variant_id: String = str(variant.get("variant_id", ""))
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	var class_id: String = str(variant.get("class_id", spec.get("class_id", "arcano")))
	var role: String = str(variant.get("role", spec.get("role", "played")))
	var required: bool = bool(context.get("required", true))
	var required_rules: Dictionary = {
		"policy_action_rejected_equals": false,
		"combat_cycles_min": 1
	}
	var watch_rules: Dictionary = {
		"card_under_test_played_equals": true,
		"card_effect_signature_present_equals": true,
		"card_under_test_play_count_max": 1
	}
	if required:
		for key: Variant in watch_rules.keys():
			required_rules[key] = watch_rules.get(key)
		watch_rules = {}
	return {
		"id": "design_lab_%s_%s" % [variant_id, str(context.get("id", "default"))],
		"name": "Design Lab %s %s" % [variant_id, str(context.get("name", context.get("id", "default")))],
		"tags": ["design_lab", "prototype", "variant", "player_card", class_id, "role_%s" % role, "context_%s" % str(context.get("id", "default"))],
		"class_id": class_id,
		"encounter_id": str(context.get("encounter_id", "design_lab_player_harness")),
		"seed": int(context.get("seed", 20260606)),
		"policy_id": str(context.get("policy_id", "card_focus_isolated")),
		"deck": _player_deck(variant_id, class_id),
		"config": _player_config(context),
		"turn_limit": int(context.get("turn_limit", 2)),
		"expectations": {"required": required_rules, "watch": watch_rules},
		"card_under_test": _card_under_test(variant, "player"),
		"effect_signature_required": required,
		"effect_signature_scope": "player",
		"effect_family": _effect_family(variant),
		"target_capture": {
			"mode": "isolated_once",
			"stop_after_target": true,
			"max_support_cards_before_target": int(context.get("max_support_cards_before_target", 1))
		},
		"encounter_override": _player_encounter_override(context)
	}

static func _enemy_case(variant: Dictionary, context: Dictionary) -> Dictionary:
	var variant_id: String = str(variant.get("variant_id", ""))
	var required: bool = bool(context.get("required", true))
	var required_rules: Dictionary = {
		"policy_action_rejected_equals": false,
		"combat_cycles_min": 1
	}
	var watch_rules: Dictionary = {
		"card_effect_signature_present_equals": true,
		"enemy_card_under_test_played_equals": true,
		"enemy_card_effect_signature_present_equals": true
	}
	if required:
		for key: Variant in watch_rules.keys():
			required_rules[key] = watch_rules.get(key)
		watch_rules = {}
	var config: Dictionary = _enemy_config(context)
	config["enemy_commander_enabled"] = true
	config["enemy_mana_per_turn"] = int(config.get("enemy_mana_per_turn", 10))
	config["enemy_mana"] = int(config.get("enemy_mana", 10))
	config["enemy_hand_count"] = 1
	config["enemy_deck"] = [variant_id]
	return {
		"id": "design_lab_enemy_%s_%s" % [variant_id, str(context.get("id", "enemy_causal"))],
		"name": "Design Lab Enemy %s" % variant_id,
		"tags": ["design_lab", "prototype", "variant", "enemy_card", "enemy_causal_signature", "role_%s" % str(variant.get("role", ""))],
		"class_id": "arcano",
		"encounter_id": str(context.get("encounter_id", "design_lab_enemy_harness")),
		"seed": int(context.get("seed", 20260606)),
		"policy_id": str(context.get("policy_id", "end_turn_only")),
		"deck": ["arcano_barreira", "arcano_fagulha", "arcano_choque"],
		"config": config,
		"turn_limit": int(context.get("turn_limit", 1)),
		"expectations": {"required": required_rules, "watch": watch_rules},
		"card_under_test": _card_under_test(variant, "enemy"),
		"effect_signature_required": required,
		"effect_signature_scope": "enemy",
		"effect_family": _effect_family(variant),
		"encounter_override": _enemy_encounter_override(context, variant_id)
	}

static func _card_under_test(variant: Dictionary, kind: String) -> Dictionary:
	return {
		"id": str(variant.get("variant_id", "")),
		"kind": kind,
		"class_id": str(variant.get("class_id", "")),
		"role": str(variant.get("role", "")),
		"origin": "variant",
		"prototype_card_id": str(variant.get("card_id", "")),
		"numbers": Dictionary(variant.get("numbers", {})).duplicate(true)
	}

static func _player_deck(card_id: String, class_id: String) -> Array[String]:
	var deck: Array[String] = [card_id]
	for support_id: String in Array(CLASS_SUPPORT.get(class_id, CLASS_SUPPORT.get("arcano", []))):
		if support_id != card_id:
			deck.append(support_id)
	while deck.size() < 8:
		deck.append(deck[mini(deck.size() - 1, 1)])
	return deck

static func _player_config(context: Dictionary) -> Dictionary:
	return {
		"player_health": int(context.get("player_health", 40)),
		"mana_per_turn": int(context.get("mana_per_turn", 10)),
		"max_hand_size": int(context.get("max_hand_size", 8)),
		"shuffle_deck": false
	}

static func _enemy_config(context: Dictionary) -> Dictionary:
	return {
		"player_health": int(context.get("player_health", 40)),
		"mana_per_turn": int(context.get("mana_per_turn", 10)),
		"max_hand_size": int(context.get("max_hand_size", 5)),
		"shuffle_deck": false
	}

static func _player_encounter_override(context: Dictionary) -> Dictionary:
	return {
		"id": str(context.get("encounter_id", "design_lab_player_harness")),
		"display_name": str(context.get("name", "Design Lab Player Harness")),
		"mode": str(context.get("mode", "duelo")),
		"enemy_director": str(context.get("enemy_director", "prefilled_board")),
		"enemy_health": int(context.get("enemy_health", 80)),
		"player_slots_count": int(context.get("player_slots_count", 3)),
		"enemy_slots_count": int(context.get("enemy_slots_count", 3)),
		"starting_enemy_slots": Array(context.get("starting_enemy_slots", [{"slot": 1, "card_id": "enemy_terra_elemental_tita"}])).duplicate(true),
		"starting_player_slots": Array(context.get("starting_player_slots", [])).duplicate(true),
		"enemy_commander_enabled": false
	}

static func _enemy_encounter_override(context: Dictionary, card_id: String) -> Dictionary:
	return {
		"id": str(context.get("encounter_id", "design_lab_enemy_harness")),
		"display_name": str(context.get("name", "Design Lab Enemy Harness")),
		"mode": str(context.get("mode", "duelo")),
		"enemy_director": str(context.get("enemy_director", "prefilled_board")),
		"enemy_health": int(context.get("enemy_health", 40)),
		"player_slots_count": int(context.get("player_slots_count", 3)),
		"enemy_slots_count": int(context.get("enemy_slots_count", 3)),
		"starting_player_slots": Array(context.get("starting_player_slots", [])).duplicate(true),
		"starting_enemy_slots": Array(context.get("starting_enemy_slots", [])).duplicate(true),
		"enemy_commander_enabled": true,
		"enemy_hand_count": 1,
		"enemy_deck": [card_id]
	}

static func _contexts_for_variant(variant: Dictionary, contexts: Array[Dictionary]) -> Array[Dictionary]:
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	var owner: String = str(variant.get("owner", "player"))
	var ids: Array = Array(spec.get("context_ids", []))
	var result: Array[Dictionary] = []
	for context: Dictionary in contexts:
		if str(context.get("owner", owner)) != owner:
			continue
		var context_id: String = str(context.get("id", ""))
		if ids.is_empty() or ids.has(context_id):
			result.append(context)
	return result

static func _default_context(owner: String) -> Dictionary:
	if owner == "enemy":
		return {"id": "enemy_causal_default", "owner": "enemy", "required": true, "policy_id": "end_turn_only", "turn_limit": 1}
	return {"id": "player_isolated_default", "owner": "player", "required": true, "policy_id": "card_focus_isolated", "turn_limit": 2}

static func _effect_family(variant: Dictionary) -> String:
	var role: String = str(variant.get("role", ""))
	match role:
		"damage":
			return "damage"
		"control":
			return "control"
		"buff":
			return "buff"
		"economy":
			return "economy"
		"card_flow":
			return "card_flow"
		"enemy_pressure":
			return "enemy"
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	var card_type: String = str(spec.get("type", spec.get("card_type", "")))
	if card_type in ["criatura", "estrutura", "permanente", "unit", "structure", "support"]:
		return "summon"
	return "played"

static func _typed_contexts(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			result.append(Dictionary(value))
	return result
