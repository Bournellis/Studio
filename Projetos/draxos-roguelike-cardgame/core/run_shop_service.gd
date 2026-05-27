extends RefCounted

static func upgrade_cost(base_cost: int) -> int:
	return base_cost

static func remove_card_cost(base_cost: int, has_free_remove_relic: bool, free_remove_used: bool) -> int:
	if has_free_remove_relic and not free_remove_used:
		return 0
	return base_cost

static func duplicate_card_cost(base_cost: int, has_discount_relic: bool, discount_used: bool) -> int:
	if has_discount_relic and not discount_used:
		return int(base_cost / 2)
	return base_cost

static func card_cost_for_rarity(rarity: String, common_cost: int, rare_cost: int, ultra_cost: int) -> int:
	match rarity:
		"rara", "rare":
			return rare_cost
		"ultra_rara", "ultra_rare", "ultra":
			return ultra_cost
	return common_cost

static func relic_cost_for_rarity(rarity: String, common_cost: int, rare_cost: int, ultra_cost: int) -> int:
	match rarity:
		"rara", "rare":
			return rare_cost
		"ultra_rara", "ultra_rare", "ultra":
			return ultra_cost
	return common_cost

static func max_health_cost(purchase_count: int, first_cost: int, second_cost: int) -> int:
	return first_cost if purchase_count <= 0 else second_cost

static func reroll_cost(reroll_count: int, base_cost: int, step_cost: int) -> int:
	return base_cost + (step_cost * maxi(0, reroll_count))
