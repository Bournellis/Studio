extends RefCounted

static func filtered_events(events: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event: Variant in events:
		if typeof(event) == TYPE_DICTIONARY and str(Dictionary(event).get("type", "")) in ["stage", "attack", "damage"]:
			result.append(Dictionary(event))
	return result

static func event_sources_slot(event: Dictionary, owner_id: String, slot_index: int) -> bool:
	return str(event.get("source_owner", "")) == owner_id and int(event.get("source_slot", -999)) == slot_index

static func event_targets_slot(event: Dictionary, owner_id: String, slot_index: int) -> bool:
	return not bool(event.get("target_hero", false)) and str(event.get("target_owner", "")) == owner_id and int(event.get("target_slot", -999)) == slot_index

static func event_targets_hero(event: Dictionary, owner_id: String) -> bool:
	return bool(event.get("target_hero", false)) and str(event.get("target_owner", "")) == owner_id

static func state_after_event(state: Dictionary, event: Dictionary) -> Dictionary:
	var result: Dictionary = state.duplicate(true)
	if result.is_empty() or str(event.get("type", "")) != "damage":
		return result
	var owner_id: String = str(event.get("target_owner", ""))
	if bool(event.get("target_hero", false)):
		var health_key: String = "player_health" if owner_id == BattleEngine.PLAYER_ID else "enemy_health"
		if event.has("health_after"):
			result[health_key] = int(event.get("health_after", result.get(health_key, 0)))
		else:
			result[health_key] = max(0, int(result.get(health_key, 0)) - int(event.get("amount", 0)))
		return result
	var slot_index: int = int(event.get("target_slot", -1))
	var slots_key: String = state_slots_key(owner_id)
	if slots_key == "" or not result.has(slots_key):
		return result
	var slots: Array = Array(result.get(slots_key, []))
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return result
	var occupant: Dictionary = Dictionary(slots[slot_index])
	occupant["health"] = int(event.get("health_after", int(occupant.get("health", 0)) - int(event.get("amount", 0))))
	if bool(event.get("destroyed", false)):
		var replacement: Dictionary = Dictionary(event.get("replacement_occupant", {}))
		slots[slot_index] = replacement if not replacement.is_empty() else null
	else:
		slots[slot_index] = occupant
	result[slots_key] = slots
	return result

static func state_slots_key(owner_id: String) -> String:
	if owner_id == BattleEngine.PLAYER_ID:
		return "player_slots"
	if owner_id == BattleEngine.ENEMY_ID:
		return "enemy_slots"
	return ""

static func event_text(event: Dictionary) -> String:
	match str(event.get("type", "")):
		"stage":
			return str(event.get("label", event.get("stage", "Etapa")))
		"attack":
			return "%s -> %s | %d dano" % [str(event.get("source_name", "Criatura")), str(event.get("target_name", "Alvo")), int(event.get("damage", 0))]
		"damage":
			return "%s | dano %d" % [str(event.get("stage", "Combate")), int(event.get("amount", 0))]
	return ""
