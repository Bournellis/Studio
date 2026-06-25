extends RefCounted

const PLAYER_PREFIX_TO_CLASS: Dictionary = {
	"arcano": "arcano",
	"invocador": "invocador",
	"necro": "necromante",
	"necromante": "necromante"
}

const DAMAGE_ACTIONS: Array[String] = ["damage", "flow_damage", "adjacent_damage", "random_damage", "all_enemy_damage"]
const CONTROL_ACTIONS: Array[String] = ["freeze_random_enemy", "poison_all_enemies", "debuff", "weaken", "snare", "multi_debuff"]
const BUFF_ACTIONS: Array[String] = ["buff_ally", "buff_all_allies", "shield_all_allies", "promote"]
const ECONOMY_ACTIONS: Array[String] = ["gain_mana", "gain_ashes"]

static func build(catalog) -> Dictionary:
	var cards: Array[Dictionary] = []
	if catalog == null:
		return {"cards": cards, "by_id": {}, "summary": _summary(cards)}
	for card in Array(catalog.cards):
		if card == null:
			continue
		var entry: Dictionary = _entry_for_card(card)
		if bool(entry.get("active", true)):
			cards.append(entry)
	var by_id: Dictionary = {}
	for entry: Dictionary in cards:
		by_id[str(entry.get("card_id", ""))] = entry
	return {"cards": cards, "by_id": by_id, "summary": _summary(cards)}

static func neighbors_for_variant(index: Dictionary, variant: Dictionary, limit: int = 3) -> Array[Dictionary]:
	var owner: String = str(variant.get("owner", "player"))
	var class_id: String = str(variant.get("class_id", ""))
	var role: String = str(variant.get("role", ""))
	var effect_family: String = _effect_family_from_variant(variant, role)
	var variant_cost: int = int(Dictionary(variant.get("numbers", {})).get("cost", Dictionary(variant.get("spec", {})).get("cost", 0)))
	var variant_power: float = power_for_variant(variant)
	var scored: Array[Dictionary] = []
	for entry_value: Variant in Array(index.get("cards", [])):
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = Dictionary(entry_value)
		if str(entry.get("owner", "")) != owner:
			continue
		if owner == "player" and class_id != "" and str(entry.get("class_id", "")) != class_id:
			continue
		var similarity: float = 0.0
		if str(entry.get("role", "")) == role:
			similarity += 50.0
		if str(entry.get("effect_family", "")) == effect_family:
			similarity += 25.0
		similarity += maxf(0.0, 15.0 - absf(float(int(entry.get("cost", 0)) - variant_cost)) * 5.0)
		similarity += maxf(0.0, 10.0 - absf(float(entry.get("power_value", 0.0)) - variant_power) * 1.5)
		if similarity <= 35.0:
			continue
		var neighbor: Dictionary = entry.duplicate(true)
		neighbor["similarity"] = snappedf(similarity, 0.01)
		scored.append(neighbor)
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var sim_a: float = float(a.get("similarity", 0.0))
		var sim_b: float = float(b.get("similarity", 0.0))
		if not is_equal_approx(sim_a, sim_b):
			return sim_a > sim_b
		var cost_delta_a: int = absi(int(a.get("cost", 0)) - variant_cost)
		var cost_delta_b: int = absi(int(b.get("cost", 0)) - variant_cost)
		if cost_delta_a != cost_delta_b:
			return cost_delta_a < cost_delta_b
		return str(a.get("card_id", "")) < str(b.get("card_id", ""))
	)
	var result: Array[Dictionary] = []
	for index_value: int in range(mini(limit, scored.size())):
		result.append(Dictionary(scored[index_value]).duplicate(true))
	return result

static func power_for_variant(variant: Dictionary) -> float:
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	var numbers: Dictionary = Dictionary(variant.get("numbers", {}))
	var effect: Dictionary = Dictionary(spec.get("effect", {})).duplicate(true)
	for key: Variant in numbers.keys():
		var field: String = str(key)
		if field.begins_with("effect."):
			effect[field.trim_prefix("effect.")] = numbers.get(key)
	var card_type: String = str(spec.get("type", spec.get("card_type", "")))
	var attack: int = int(numbers.get("attack", spec.get("attack", 0)))
	var health: int = int(numbers.get("health", spec.get("health", 0)))
	var owner: String = str(variant.get("owner", "player"))
	return _power_value(card_type, attack, health, effect, Array(spec.get("keywords", [])), owner)

static func _entry_for_card(card) -> Dictionary:
	var card_id: String = str(card.id)
	var owner: String = "enemy" if card_id.begins_with("enemy_") else "player"
	var class_id: String = _class_id_for_card(card_id)
	var keywords: Array = Array(card.keywords)
	var effect: Dictionary = Dictionary(card.effect)
	var role: String = _role_for_card(card.card_type, effect, keywords, owner)
	var effect_family: String = _effect_family(str(effect.get("action", "")), card.card_type, keywords, role)
	var power_value: float = _power_value(str(card.card_type), int(card.attack), int(card.health), effect, keywords, owner)
	return {
		"card_id": card_id,
		"display_name": str(card.display_name),
		"owner": owner,
		"class_id": class_id,
		"role": role,
		"effect_family": effect_family,
		"cost": int(card.cost),
		"attack": int(card.attack),
		"health": int(card.health),
		"keywords": keywords.duplicate(true),
		"power_value": snappedf(power_value, 0.01),
		"active": not card_id.contains("_legacy")
	}

static func _class_id_for_card(card_id: String) -> String:
	if card_id.begins_with("enemy_"):
		return "enemy"
	var first: String = card_id.split("_", false)[0] if card_id.find("_") >= 0 else card_id
	return str(PLAYER_PREFIX_TO_CLASS.get(first, "unknown"))

static func _role_for_card(card_type: String, effect: Dictionary, keywords: Array, owner: String) -> String:
	var action: String = str(effect.get("action", ""))
	if card_type in ["criatura", "estrutura", "permanente", "unit", "structure", "support"]:
		return "enemy_pressure" if owner == "enemy" else "summon"
	if DAMAGE_ACTIONS.has(action):
		return "damage"
	if CONTROL_ACTIONS.has(action):
		return "control"
	if BUFF_ACTIONS.has(action):
		return "buff"
	if ECONOMY_ACTIONS.has(action):
		return "economy"
	if effect.has("draw_cards") or effect.has("draw_if_at_least"):
		return "card_flow"
	if not keywords.is_empty():
		return "control" if keywords.has("prender") or keywords.has("enfraquecer") else "summon"
	return "utility"

static func _effect_family_from_variant(variant: Dictionary, role: String) -> String:
	var spec: Dictionary = Dictionary(variant.get("spec", {}))
	var card_type: String = str(spec.get("type", spec.get("card_type", "")))
	var effect: Dictionary = Dictionary(spec.get("effect", {}))
	return _effect_family(str(effect.get("action", "")), card_type, Array(spec.get("keywords", [])), role)

static func _effect_family(action: String, card_type: String, keywords: Array, role: String) -> String:
	if DAMAGE_ACTIONS.has(action):
		return "damage"
	if CONTROL_ACTIONS.has(action):
		return "control"
	if BUFF_ACTIONS.has(action):
		return "buff"
	if ECONOMY_ACTIONS.has(action):
		return "economy"
	if card_type in ["criatura", "estrutura", "permanente", "unit", "structure", "support"]:
		return "board"
	if role != "":
		return role
	if not keywords.is_empty():
		return "keyword"
	return "utility"

static func _power_value(card_type: String, attack: int, health: int, effect: Dictionary, keywords: Array, owner: String) -> float:
	var action: String = str(effect.get("action", ""))
	var value: float = 0.0
	if card_type in ["criatura", "estrutura", "permanente", "unit", "structure", "support"]:
		value = float(attack) + float(health)
		value += float(keywords.size()) * (1.0 if owner == "enemy" else 0.75)
		value += float(effect.get("thorns_amount", 0)) * 0.75
		value += float(effect.get("regeneration_amount", 0)) * 0.75
		return value
	if DAMAGE_ACTIONS.has(action):
		value = float(effect.get("amount", effect.get("damage", 0)))
		if action == "adjacent_damage":
			value += float(effect.get("splash_amount", 1)) * 1.5
		elif action == "all_enemy_damage":
			value *= 2.2
		elif action == "random_damage":
			value *= maxf(1.0, float(effect.get("count", 1)) * 0.8)
		return value
	if CONTROL_ACTIONS.has(action):
		return float(effect.get("amount", 1)) + float(effect.get("count", 1)) * 0.75
	if BUFF_ACTIONS.has(action):
		return float(effect.get("attack", 0)) + float(effect.get("health", 0)) + float(effect.get("shield_charges", 0))
	if ECONOMY_ACTIONS.has(action):
		return float(effect.get("amount", effect.get("mana", 0)))
	if effect.has("draw_cards") or effect.has("draw_if_at_least"):
		return float(effect.get("draw_cards", effect.get("draw_if_at_least", 1)))
	return float(effect.get("amount", 0))

static func _summary(cards: Array[Dictionary]) -> Dictionary:
	var by_owner: Dictionary = {}
	var by_role: Dictionary = {}
	for entry: Dictionary in cards:
		var owner: String = str(entry.get("owner", "unknown"))
		var role: String = str(entry.get("role", "unknown"))
		by_owner[owner] = int(by_owner.get(owner, 0)) + 1
		by_role[role] = int(by_role.get(role, 0)) + 1
	return {"card_count": cards.size(), "by_owner": by_owner, "by_role": by_role}
