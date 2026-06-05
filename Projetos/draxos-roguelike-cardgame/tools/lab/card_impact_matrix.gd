extends RefCounted

const PLAYER_KIND: String = "player"
const ENEMY_KIND: String = "enemy"
const LEGACY_KIND: String = "legacy_inactive"
const DEFAULT_SEED: int = 20260518

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
			"expected_legacy_inactive_cards": int(Dictionary(pack.get("card_sets", {})).get("expected_legacy_inactive_cards", 0)),
			"player_cards_total": Array(discovery.get("player_cards", [])).size(),
			"enemy_cards_total": Array(discovery.get("enemy_cards", [])).size(),
			"legacy_inactive_cards_total": Array(discovery.get("legacy_inactive_cards", [])).size(),
			"filtered_player_cards": player_cards.size(),
			"filtered_enemy_cards": enemy_cards.size(),
			"battle_cases": cases.size()
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
	if expected_player > 0 and player_cards.size() != expected_player:
		errors.append("Expected %d player cards, found %d." % [expected_player, player_cards.size()])
	if expected_enemy > 0 and enemy_cards.size() != expected_enemy:
		errors.append("Expected %d enemy cards, found %d." % [expected_enemy, enemy_cards.size()])
	if expected_legacy > 0 and legacy_cards.size() != expected_legacy:
		errors.append("Expected %d legacy inactive cards, found %d." % [expected_legacy, legacy_cards.size()])
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
		var base_ids: Array[String] = []
		for card_id: String in _unique_strings(Array(class_option.get("starter_deck", []))):
			base_ids.append(card_id)
		var core_id: String = str(CLASS_CORE_COST2.get(class_id, ""))
		if core_id != "" and not base_ids.has(core_id):
			base_ids.append(core_id)
		var rewards: Dictionary = Dictionary(Dictionary(catalog.track_contract.get("track_02_player_card_rewards", {})).get(class_id, {}))
		for element: Variant in Array(card_sets.get("player_core_reward_elements", ["terra"])):
			for card_id: String in _unique_strings(Array(rewards.get(str(element), []))):
				if not base_ids.has(card_id):
					base_ids.append(card_id)
		for base_id: String in base_ids:
			for suffix: Variant in suffixes:
				var card_id: String = "%s%s" % [base_id, str(suffix)]
				var card = catalog.find_card(card_id)
				if card == null:
					continue
				result.append(_card_entry(card_id, PLAYER_KIND, class_id, card))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("id", "")) < str(b.get("id", "")))
	return result

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

static func _card_entry(card_id: String, kind: String, class_id: String, card) -> Dictionary:
	return {
		"id": card_id,
		"kind": kind,
		"class_id": class_id,
		"type": str(card.card_type),
		"cost": int(card.cost),
		"attack": int(card.attack),
		"health": int(card.health),
		"action": str(Dictionary(card.effect).get("action", "")),
		"keywords": Array(card.keywords),
		"effect_family": _effect_family(card)
	}

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
	return {
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
		"encounter_override": _player_encounter_override_for(family)
	}

static func _enemy_case(card_data: Dictionary, pack: Dictionary) -> Dictionary:
	var template: Dictionary = Dictionary(Dictionary(pack.get("case_templates", {})).get("enemy", {}))
	var card_id: String = str(card_data.get("id", ""))
	return {
		"id": "card_impact_enemy_%s" % card_id,
		"name": "Card Impact Enemy %s" % card_id,
		"tags": ["card_impact", "card_under_test", "enemy_card"],
		"class_id": "arcano",
		"encounter_id": str(template.get("encounter_id", "card_impact_enemy_harness")),
		"seed": int(template.get("seed", DEFAULT_SEED)),
		"policy_id": str(template.get("policy_id", "end_turn_only")),
		"deck": ["arcano_barreira", "arcano_fagulha", "arcano_choque"],
		"config": Dictionary(template.get("config", {})).duplicate(true),
		"turn_limit": int(template.get("turn_limit", 1)),
		"expectations": Dictionary(template.get("expectations", {})).duplicate(true),
		"card_under_test": card_data.duplicate(true),
		"effect_signature_required": false,
		"effect_signature_scope": "enemy_report_only",
		"effect_family": str(card_data.get("effect_family", "enemy")),
		"encounter_override": _enemy_encounter_override(card_id)
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
	return {
		"id": "card_impact_player_%s_harness" % family,
		"display_name": "Card Impact Player %s Harness" % family.capitalize(),
		"mode": mode,
		"enemy_director": "prefilled_board",
		"enemy_health": 40,
		"player_slots_count": 3,
		"enemy_slots_count": 3,
		"starting_enemy_slots": [{"slot": 1, "card_id": "enemy_terra_elemental_areia"}],
		"enemy_commander_enabled": false
	}

static func _enemy_encounter_override(card_id: String) -> Dictionary:
	return {
		"id": "card_impact_enemy_harness",
		"display_name": "Card Impact Enemy Harness",
		"mode": "limpar_mesa",
		"enemy_director": "prefilled_board",
		"enemy_health": 40,
		"player_slots_count": 3,
		"enemy_slots_count": 3,
		"starting_enemy_slots": [{"slot": 1, "card_id": card_id}],
		"enemy_commander_enabled": false
	}

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

static func _effect_family(card) -> String:
	var action: String = str(Dictionary(card.effect).get("action", ""))
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

static func _requires_player_effect_signature(pack: Dictionary) -> bool:
	var config: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	if config.is_empty():
		return false
	if not bool(config.get("enabled", false)):
		return false
	var player_config: Dictionary = Dictionary(config.get("player", {}))
	return str(player_config.get("mode", "required")) == "required" and bool(player_config.get("fail_on_missing_signature", true))

static func _typed_card_array(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			result.append(Dictionary(value))
	return result
