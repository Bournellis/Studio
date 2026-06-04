extends RefCounted

static func player_unit_threat_score(occupant: Dictionary) -> float:
	if occupant.is_empty():
		return 0.0
	var score: float = float(int(occupant.get("attack", 0)) * 2 + int(occupant.get("health", 0)))
	if bool(occupant.get("objective", false)):
		score += 12.0
	if bool(occupant.get("defensor", false)):
		score += 4.0
	if bool(occupant.get("iniciativa", false)) or bool(occupant.get("atropelar", false)) or bool(occupant.get("brutal", false)) or bool(occupant.get("ecoar", false)):
		score += 3.0
	if bool(occupant.get("espinhos", false)) or int(occupant.get("thorns_amount", 0)) > 0:
		score += 2.0
	if bool(occupant.get("escudo", false)) or bool(occupant.get("resistencia", false)) or bool(occupant.get("imune", false)):
		score += 2.0
	return score

static func enemy_unit_value(occupant: Dictionary) -> float:
	if occupant.is_empty():
		return 0.0
	var score: float = float(int(occupant.get("attack", 0)) * 2 + int(occupant.get("health", 0)))
	if bool(occupant.get("defensor", false)) or bool(occupant.get("resistencia", false)) or bool(occupant.get("escudo", false)):
		score += 3.0
	if bool(occupant.get("crescer", false)) or bool(occupant.get("furia", false)) or bool(occupant.get("ressurgir", false)):
		score += 3.0
	return score
