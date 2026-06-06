extends RefCounted

const PLAYER_KIND: String = "player"
const ENEMY_KIND: String = "enemy"
const LEGACY_KIND: String = "legacy_inactive"
const DEFAULT_SEED: int = 20260518
const PLAYER_SCOPE_CORE_CLASS_V1: String = "core_class_v1"
const PLAYER_SCOPE_FULL_ACTIVE_V1: String = "full_active_player_v1"

const CLASS_CORE_COST2: Dictionary = {
	"arcano": "arcano_tempestade",
	"invocador": "invocador_guardiao",
	"necromante": "necro_zumbi"
}

const CLASS_SUPPORT: Dictionary = {
	"arcano": ["arcano_fagulha", "arcano_barreira", "arcano_choque", "arcano_fagulha"],
	"invocador": ["invocador_soldado", "invocador_batedor", "invocador_promover", "invocador_soldado"],
	"necromante": ["necro_esqueleto", "necro_morto_vivo", "necro_prender", "necro_esqueleto"]
}

const EFFECT_DAMAGE_ACTIONS: Array[String] = ["damage", "flow_damage", "adjacent_damage", "random_damage", "all_enemy_damage", "punish_snared"]
const EFFECT_CONTROL_ACTIONS: Array[String] = ["debuff", "weaken", "snare", "multi_debuff", "freeze_random_enemy", "poison_all_enemies"]
const EFFECT_BUFF_ACTIONS: Array[String] = ["buff_ally", "promote", "buff_all_allies", "shield_all_allies"]
const EFFECT_ECONOMY_ACTIONS: Array[String] = ["gain_mana", "gain_ashes"]
const EFFECT_CARD_FLOW_ACTIONS: Array[String] = ["draw", "draw_cards", "discard", "discard_cards", "create_card", "create_cards"]
const CARD_FLOW_EFFECT_KEYS: Array[String] = ["draw_if_at_least", "draw_cards", "cards_drawn", "discard_cards", "cards_discarded", "create_card", "create_cards", "cards_created", "deck_delta", "hand_delta", "discard_delta"]

static func build_matrix(catalog, pack: Dictionary, card_filter: PackedStringArray = PackedStringArray()) -> Dictionary:
	var discovery: Dictionary = discover_cards(catalog, pack)
	var errors: Array[String] = Array(discovery.get("errors", []))
	var player_cards: Array[Dictionary] = _filter_cards(Array(discovery.get("player_cards", [])), card_filter)
	var enemy_cards: Array[Dictionary] = _filter_cards(Array(discovery.get("enemy_cards", [])), card_filter)
	if _filter_mode(card_filter) == PLAYER_KIND:
		enemy_cards = []
	elif _filter_mode(card_filter) == ENEMY_KIND:
		player_cards = []
	if player_cards.is_empty() and enemy_cards.is_empty():
		errors.append("No active cards matched filter `%s`." % ",".join(card_filter))
	var cases: Array[Dictionary] = []
	for card_data: Dictionary in player_cards:
		cases.append(_player_case(card_data, pack))
	for card_data: Dictionary in enemy_cards:
		cases.append(_enemy_case(card_data, pack))
	var expected_count: int = player_cards.size() + enemy_cards.size()
	if cases.size() != expected_count:
		errors.append("Generated %d cases for %d filtered active cards." % [cases.size(), expected_count])
	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"discovery": discovery,
		"player_cards": player_cards,
		"enemy_cards": enemy_cards,
		"cases": cases,
		"summary": {
			"expected_player_cards": int(Dictionary(pack.get("card_sets", {})).get("expected_player_cards", 0)),
			"expected_enemy_cards": int(Dictionary(pack.get("card_sets", {})).get("expected_enemy_cards", 0)),
			"expected_enemy_effect_signatures": int(Dictionary(pack.get("card_sets", {})).get("expected_enemy_effect_signatures", 0)),
			"expected_legacy_inactive_cards": int(Dictionary(pack.get("card_sets", {})).get("expected_legacy_inactive_cards", 0)),
			"expected_card_flow_player_cards": int(Dictionary(pack.get("card_sets", {})).get("expected_card_flow_player_cards", 0)),
			"player_cards_total": Array(discovery.get("player_cards", [])).size(),
			"enemy_cards_total": Array(discovery.get("enemy_cards", [])).size(),
			"legacy_inactive_cards_total": Array(discovery.get("legacy_inactive_cards", [])).size(),
			"card_flow_player_cards_total": _card_flow_cards(Array(discovery.get("player_cards", []))).size(),
			"filtered_player_cards": player_cards.size(),
			"filtered_enemy_cards": enemy_cards.size(),
			"filtered_enemy_effect_signature_cards": enemy_cards.size() if _requires_enemy_effect_signature(pack) else 0,
			"filtered_card_flow_player_cards": _card_flow_cards(player_cards).size(),
			"battle_cases": cases.size(),
			"player_cards_total_by_class": _count_cards_by_field(Array(discovery.get("player_cards", [])), "class_id"),
			"filtered_player_cards_by_class": _count_cards_by_field(player_cards, "class_id"),
			"player_cards_total_by_source": _count_cards_by_field(Array(discovery.get("player_cards", [])), "source"),
			"filtered_player_cards_by_source": _count_cards_by_field(player_cards, "source")
		}
	}

static func discover_cards(catalog, pack: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	if catalog == null:
		return {"ok": false, "errors": ["Missing catalog."], "player_cards": [], "enemy_cards": [], "legacy_inactive_cards": []}
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {}))
	var player_cards: Array[Dictionary] = _discover_player_cards(catalog, card_sets)
	var enemy_cards: Array[Dictionary] = _discover_enemy_cards(catalog, card_sets)
	var legacy_cards: Array[Dictionary] = _discover_legacy_inactive_cards(catalog, card_sets)
	var expected_player: int = int(card_sets.get("expected_player_cards", 0))
	var expected_enemy: int = int(card_sets.get("expected_enemy_cards", 0))
	var expected_legacy: int = int(card_sets.get("expected_legacy_inactive_cards", 0))
	var expected_card_flow: int = int(card_sets.get("expected_card_flow_player_cards", 0))
	if expected_player > 0 and player_cards.size() != expected_player:
		errors.append("Expected %d player cards, found %d." % [expected_player, player_cards.size()])
	if expected_enemy > 0 and enemy_cards.size() != expected_enemy:
		errors.append("Expected %d enemy cards, found %d." % [expected_enemy, enemy_cards.size()])
	if expected_legacy > 0 and legacy_cards.size() != expected_legacy:
		errors.append("Expected %d legacy inactive cards, found %d." % [expected_legacy, legacy_cards.size()])
	if expected_card_flow > 0:
		var card_flow_count: int = _card_flow_cards(player_cards).size()
		if card_flow_count != expected_card_flow:
			errors.append("Expected %d card-flow player cards, found %d." % [expected_card_flow, card_flow_count])
	var active_legacy_refs: Array[String] = _legacy_references_in_encounters(catalog, legacy_cards)
	if not active_legacy_refs.is_empty():
		errors.append("Legacy elemental cards are referenced by active encounters: %s." % ",".join(active_legacy_refs))
	return {
		"ok": errors.is_empty(),
		"errors": errors,
		"player_cards": player_cards,
		"enemy_cards": enemy_cards,
		"legacy_inactive_cards": legacy_cards
	}

static func _discover_player_cards(catalog, card_sets: Dictionary) -> Array[Dictionary]:
	var suffixes: Array = Array(card_sets.get("player_upgrade_suffixes", ["", "_lvl2", "_lvl3"]))
	var result: Array[Dictionary] = []
	for class_option: Dictionary in Array(catalog.class_options):
		var class_id: String = str(class_option.get("id", ""))
		if class_id == "":
			continue
		for base_entry: Dictionary in _player_base_entries(catalog, class_option, class_id, card_sets):
			var base_id: String = str(base_entry.get("id", ""))
			for suffix: Variant in suffixes:
				var card_id: String = "%s%s" % [base_id, str(suffix)]
				var card = catalog.find_card(card_id)
				if card == null:
					continue
				result.append(_card_entry(card_id, PLAYER_KIND, class_id, card, {
					"base_id": base_id,
					"source": str(base_entry.get("source", "")),
					"reward_element": str(base_entry.get("reward_element", ""))
				}))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
	return result

static func _player_base_entries(catalog, class_option: Dictionary, class_id: String, card_sets: Dictionary) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for card_id: String in _unique_strings(Array(class_option.get("starter_deck", []))):
		_add_player_base_entry(entries, card_id, "starter", "")
	var core_id: String = str(CLASS_CORE_COST2.get(class_id, ""))
	if core_id != "":
		_add_player_base_entry(entries, core_id, "core_cost2", "")
	var rewards: Dictionary = Dictionary(Dictionary(catalog.track_contract.get("track_02_player_card_rewards", {})).get(class_id, {}))
	for element: String in _reward_elements_for_scope(rewards, card_sets):
		for card_id: String in _unique_strings(Array(rewards.get(element, []))):
			_add_player_base_entry(entries, card_id, "reward", element)
	return entries

static func _reward_elements_for_scope(rewards: Dictionary, card_sets: Dictionary) -> Array[String]:
	var scope: String = str(card_sets.get("player_scope", PLAYER_SCOPE_CORE_CLASS_V1))
	if scope == PLAYER_SCOPE_FULL_ACTIVE_V1:
		return _sorted_keys(rewards)
	var result: Array[String] = []
	for element: Variant in Array(card_sets.get("player_core_reward_elements", ["terra"])):
		var element_id: String = str(element)
		if element_id != "" and not result.has(element_id):
			result.append(element_id)
	return result

static func _add_player_base_entry(entries: Array[Dictionary], card_id: String, source: String, reward_element: String) -> void:
	if card_id == "":
		return
	for entry: Dictionary in entries:
		if str(entry.get("id", "")) == card_id:
			return
	entries.append({"id": card_id, "source": source, "reward_element": reward_element})

static func _discover_enemy_cards(catalog, card_sets: Dictionary) -> Array[Dictionary]:
	var ids: Array[String] = []
	var galleries: Dictionary = Dictionary(catalog.track_contract.get("enemy_card_galleries", {}))
	for gallery_key: Variant in galleries.keys():
		for card_id: String in _unique_strings(Array(galleries.get(gallery_key, []))):
			if not ids.has(card_id):
				ids.append(card_id)
	ids.sort()
	var result: Array[Dictionary] = []
	for card_id: String in ids:
		var card = catalog.find_card(card_id)
		if card == null:
			continue
		result.append(_card_entry(card_id, ENEMY_KIND, "enemy", card))
	return result

static func _discover_legacy_inactive_cards(catalog, card_sets: Dictionary) -> Array[Dictionary]:
	var prefix: String = str(card_sets.get("legacy_inactive_prefix", "elemental_"))
	var result: Array[Dictionary] = []
	for card in catalog.cards:
		var card_id: String = str(card.id)
		if card_id.begins_with(prefix):
			result.append(_card_entry(card_id, LEGACY_KIND, "legacy", card))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
	return result

static func _card_entry(card_id: String, kind: String, class_id: String, card, extra: Dictionary = {}) -> Dictionary:
	var effect: Dictionary = Dictionary(card.effect).duplicate(true)
	var entry: Dictionary = {
		"id": card_id,
		"kind": kind,
		"class_id": class_id,
		"type": str(card.card_type),
		"cost": int(card.cost),
		"attack": int(card.attack),
		"health": int(card.health),
		"action": str(effect.get("action", "")),
		"effect": effect,
		"keywords": Array(card.keywords),
		"effect_family": _effect_family(card),
		"card_flow_expected": _is_card_flow_card(card)
	}
	for key: Variant in extra.keys():
		entry[str(key)] = extra.get(key)
	return entry

static func _player_case(card_data: Dictionary, pack: Dictionary) -> Dictionary:
	var template: Dictionary = Dictionary(Dictionary(pack.get("case_templates", {})).get("player", {}))
	var card_id: String = str(card_data.get("id", ""))
	var class_id: String = str(card_data.get("class_id", "arcano"))
	var family: String = str(card_data.get("effect_family", "played"))
	var expectations: Dictionary = Dictionary(template.get("expectations", {})).duplicate(true)
	if _requires_player_effect_signature(pack):
		var required: Dictionary = Dictionary(expectations.get("required", {})).duplicate(true)
		required["card_effect_signature_present_equals"] = true
		expectations["required"] = required
	var case_result: Dictionary = {
		"id": "card_impact_player_%s" % card_id,
		"name": "Card Impact Player %s" % card_id,
		"tags": ["card_impact", "card_under_test", "player_card", class_id, "effect_%s" % family],
		"class_id": class_id,
		"encounter_id": _player_harness_id(template, family),
		"seed": int(template.get("seed", DEFAULT_SEED)),
		"policy_id": str(template.get("policy_id", "card_focus_legal")),
		"deck": _player_deck(card_data, class_id),
		"config": Dictionary(template.get("config", {})).duplicate(true),
		"turn_limit": int(template.get("turn_limit", 3)),
		"expectations": expectations,
		"card_under_test": card_data.duplicate(true),
		"effect_signature_required": _requires_player_effect_signature(pack),
		"effect_signature_scope": "player",
		"effect_family": family,
		"card_flow_expected": bool(card_data.get("card_flow_expected", false)),
		"target_capture": _target_capture_config(pack),
		"encounter_override": _player_encounter_override_for(family)
	}
	var lab_prestate: Dictionary = _lab_prestate_for(card_data)
	if not lab_prestate.is_empty():
		case_result["lab_prestate"] = lab_prestate
	return case_result

static func _enemy_case(card_data: Dictionary, pack: Dictionary) -> Dictionary:
	var template: Dictionary = Dictionary(Dictionary(pack.get("case_templates", {})).get("enemy", {}))
	var card_id: String = str(card_data.get("id", ""))
	var enemy_signature_required: bool = _requires_enemy_effect_signature(pack)
	var tags: Array[String] = ["card_impact", "card_under_test", "enemy_card"]
	if enemy_signature_required:
		tags.append("enemy_causal_signature")
	var config: Dictionary = Dictionary(template.get("config", {})).duplicate(true)
	if enemy_signature_required:
		config["enemy_commander_enabled"] = true
		config["enemy_mana_per_turn"] = int(config.get("enemy_mana_per_turn", 10))
		config["enemy_mana"] = int(config.get("enemy_mana", 10))
		config["enemy_hand_count"] = 1
		config["enemy_deck"] = [card_id]
	var expectations: Dictionary = Dictionary(template.get("expectations", {})).duplicate(true)
	if enemy_signature_required:
		var required: Dictionary = Dictionary(expectations.get("required", {})).duplicate(true)
		required["card_effect_signature_present_equals"] = true
		required["enemy_card_under_test_played_equals"] = true
		required["enemy_card_effect_signature_present_equals"] = true
		expectations["required"] = required
	return {
		"id": "card_impact_enemy_%s" % card_id,
		"name": "Card Impact Enemy %s" % card_id,
		"tags": tags,
		"class_id": "arcano",
		"encounter_id": str(template.get("encounter_id", "card_impact_enemy_harness")),
		"seed": int(template.get("seed", DEFAULT_SEED)),
		"policy_id": str(template.get("policy_id", "end_turn_only")),
		"deck": ["arcano_barreira", "arcano_fagulha", "arcano_choque"],
		"config": config,
		"turn_limit": int(template.get("turn_limit", 1)),
		"expectations": expectations,
		"card_under_test": card_data.duplicate(true),
		"effect_signature_required": enemy_signature_required,
		"effect_signature_scope": "enemy" if enemy_signature_required else "enemy_report_only",
		"effect_family": str(card_data.get("effect_family", "enemy")),
		"encounter_override": _enemy_encounter_override(card_id, enemy_signature_required)
	}

static func _player_deck(card_data: Dictionary, class_id: String) -> Array[String]:
	var card_id: String = str(card_data.get("id", ""))
	var action: String = str(card_data.get("action", ""))
	var deck: Array[String] = []
	if action in ["buff_all_allies", "gain_mana", "shield_all_allies"]:
		deck.append(_support_card_for(class_id, card_id))
	deck.append(card_id)
	for support_id: String in Array(CLASS_SUPPORT.get(class_id, CLASS_SUPPORT.get("arcano", []))):
		if support_id != card_id:
			deck.append(support_id)
	while deck.size() < 8:
		deck.append(str(deck[maxi(0, mini(deck.size() - 1, 1))]))
	return deck

static func _support_card_for(class_id: String, card_id: String) -> String:
	for support_id: String in Array(CLASS_SUPPORT.get(class_id, CLASS_SUPPORT.get("arcano", []))):
		if support_id != card_id:
			return support_id
	return card_id

static func _player_encounter_override() -> Dictionary:
	return _player_encounter_override_for("played")

static func _player_harness_id(template: Dictionary, family: String) -> String:
	var harnesses: Dictionary = Dictionary(template.get("harnesses", {}))
	if harnesses.has(family):
		return str(harnesses.get(family, ""))
	if harnesses.has("default"):
		return str(harnesses.get("default", ""))
	return str(template.get("encounter_id", "card_impact_player_harness"))

static func _player_encounter_override_for(family: String) -> Dictionary:
	var mode: String = "duelo" if family in ["damage", "control"] else "limpar_mesa"
	var enemy_health: int = 160 if family == "damage" else 40
	var enemy_card_id: String = "enemy_terra_elemental_tita" if family == "damage" else "enemy_terra_elemental_areia"
	return {
		"id": "card_impact_player_%s_harness" % family,
		"display_name": "Card Impact Player %s Harness" % family.capitalize(),
		"mode": mode,
		"enemy_director": "prefilled_board",
		"enemy_health": enemy_health,
		"player_slots_count": 3,
		"enemy_slots_count": 3,
		"starting_enemy_slots": [{"slot": 1, "card_id": enemy_card_id}],
		"enemy_commander_enabled": false
	}

static func _enemy_encounter_override(card_id: String, causal_signature: bool = false) -> Dictionary:
	var encounter: Dictionary = {
		"id": "card_impact_enemy_harness",
		"display_name": "Card Impact Enemy Harness",
		"mode": "limpar_mesa",
		"enemy_director": "prefilled_board",
		"enemy_health": 40,
		"player_slots_count": 3,
		"enemy_slots_count": 3,
		"enemy_commander_enabled": false
	}
	if causal_signature:
		encounter["enemy_commander_enabled"] = true
		encounter["enemy_hand_count"] = 1
		encounter["enemy_deck"] = [card_id]
		encounter["mode"] = "duelo"
		encounter["starting_enemy_slots"] = []
	else:
		encounter["starting_enemy_slots"] = [{"slot": 1, "card_id": card_id}]
	return encounter

static func _filter_cards(cards: Array, card_filter: PackedStringArray) -> Array[Dictionary]:
	var mode: String = _filter_mode(card_filter)
	if mode in ["", PLAYER_KIND, ENEMY_KIND, "all"]:
		return _typed_card_array(cards)
	var requested: Dictionary = {}
	for id: String in card_filter:
		requested[id] = true
	var result: Array[Dictionary] = []
	for card: Dictionary in _typed_card_array(cards):
		if requested.has(str(card.get("id", ""))):
			result.append(card)
	return result

static func _filter_mode(card_filter: PackedStringArray) -> String:
	if card_filter.is_empty():
		return "all"
	if card_filter.size() == 1:
		var value: String = str(card_filter[0])
		if value in ["all", PLAYER_KIND, ENEMY_KIND]:
			return value
	return "ids"

static func _legacy_references_in_encounters(catalog, legacy_cards: Array) -> Array[String]:
	var legacy_ids: Array[String] = []
	for card_data: Dictionary in _typed_card_array(legacy_cards):
		legacy_ids.append(str(card_data.get("id", "")))
	var referenced: Array[String] = []
	var haystack: String = JSON.stringify(Array(catalog.encounters))
	for card_id: String in legacy_ids:
		if haystack.find("\"%s\"" % card_id) >= 0:
			referenced.append(card_id)
	return referenced

static func _unique_strings(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		var text: String = str(value)
		if text != "" and not result.has(text):
			result.append(text)
	return result

static func _sorted_keys(values: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for key: Variant in values.keys():
		result.append(str(key))
	result.sort()
	return result

static func _count_cards_by_field(cards: Array, field: String) -> Dictionary:
	var counts: Dictionary = {}
	for card: Dictionary in _typed_card_array(cards):
		var key: String = str(card.get(field, "unknown"))
		if key == "":
			key = "unknown"
		counts[key] = int(counts.get(key, 0)) + 1
	return counts

static func _effect_family(card) -> String:
	var action: String = str(Dictionary(card.effect).get("action", ""))
	if _is_card_flow_card(card):
		return "card_flow"
	if EFFECT_DAMAGE_ACTIONS.has(action):
		return "damage"
	if EFFECT_CONTROL_ACTIONS.has(action):
		return "control"
	if EFFECT_BUFF_ACTIONS.has(action):
		return "buff"
	if EFFECT_ECONOMY_ACTIONS.has(action):
		return "economy"
	if card.occupies_slot():
		return "summon"
	return "played"

static func _is_card_flow_card(card) -> bool:
	var effect: Dictionary = Dictionary(card.effect)
	var action: String = str(effect.get("action", ""))
	if EFFECT_CARD_FLOW_ACTIONS.has(action):
		return true
	for key: String in CARD_FLOW_EFFECT_KEYS:
		if not effect.has(key):
			continue
		var value: Variant = effect.get(key)
		if typeof(value) == TYPE_BOOL:
			if bool(value):
				return true
		elif typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
			if float(value) != 0.0:
				return true
		elif str(value) != "":
			return true
	return false

static func _card_flow_cards(cards: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card: Dictionary in _typed_card_array(cards):
		if bool(card.get("card_flow_expected", false)):
			result.append(card)
	return result

static func _lab_prestate_for(card_data: Dictionary) -> Dictionary:
	if not bool(card_data.get("card_flow_expected", false)):
		return {}
	var effect: Dictionary = Dictionary(card_data.get("effect", {}))
	var threshold: int = int(effect.get("draw_if_at_least", 0))
	if threshold <= 0 or not bool(effect.get("per_dead_unit", false)):
		return {}
	var base_amount: int = int(effect.get("amount", 0))
	var needed_dead_units: int = maxi(0, threshold - base_amount)
	if needed_dead_units <= 0:
		return {}
	return {"initial_dead_unit_count": needed_dead_units}

static func _requires_player_effect_signature(pack: Dictionary) -> bool:
	var config: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	if config.is_empty():
		return false
	if not bool(config.get("enabled", false)):
		return false
	var player_config: Dictionary = Dictionary(config.get("player", {}))
	return str(player_config.get("mode", "required")) == "required" and bool(player_config.get("fail_on_missing_signature", true))

static func _requires_enemy_effect_signature(pack: Dictionary) -> bool:
	var config: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	if config.is_empty():
		return false
	if not bool(config.get("enabled", false)):
		return false
	var enemy_config: Dictionary = Dictionary(config.get("enemy", {}))
	return str(enemy_config.get("mode", "report_only")) == "required" and bool(enemy_config.get("fail_on_missing_signature", true))

static func _target_capture_config(pack: Dictionary) -> Dictionary:
	var config: Dictionary = Dictionary(Dictionary(pack.get("effect_signatures", {})).get("target_capture", {})).duplicate(true)
	if config.is_empty():
		return {}
	return config

static func _typed_card_array(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			result.append(Dictionary(value))
	return result
