extends RefCounted

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"
const MODE_DEFENSE_POSITION: String = "defesa_posicao"
const MODE_SUMMONER_BOSS: String = "chefe_summoner"

static func resolve_enemy_turn_actions(engine) -> void:
	if not engine.enemy_commander_enabled or engine.enemy_hand_count <= 0:
		return
	engine._draw_enemy_to_hand_size()
	var played_count: int = 0
	while played_count < 12:
		var play: Dictionary = best_enemy_play(engine)
		if play.is_empty():
			break
		if not play_enemy_card_from_hand(engine, int(play.get("hand_index", -1)), Dictionary(play.get("target", {}))):
			break
		played_count += 1
	if played_count > 0:
		engine._log("Comandante inimigo jogou %d carta(s)." % played_count)

static func best_enemy_play(engine) -> Dictionary:
	var best_play: Dictionary = {}
	var best_score: float = -999999.0
	for index: int in range(engine.enemy_hand.size()):
		var card = engine._card(engine.enemy_hand[index])
		if card == null or not card.occupies_slot() or int(card.cost) > engine.enemy_mana:
			continue
		for slot_index: int in range(engine.enemy_slots.size()):
			if engine.enemy_slots[slot_index] != null:
				continue
			var score: float = score_enemy_creature_play(engine, card, slot_index, index)
			if best_play.is_empty() or score > best_score:
				best_score = score
				best_play = {"hand_index": index, "target": {"owner": ENEMY_ID, "slot": slot_index}, "score": score}
	for index: int in range(engine.enemy_hand.size()):
		var card = engine._card(engine.enemy_hand[index])
		if card == null or card.occupies_slot() or int(card.cost) > engine.enemy_mana:
			continue
		var targets: Array[Dictionary] = enemy_spell_targets(engine, card)
		for target: Dictionary in targets:
			var score: float = score_enemy_spell_play(engine, card, target, index)
			if best_play.is_empty() or score > best_score:
				best_score = score
				best_play = {"hand_index": index, "target": target.duplicate(), "score": score}
	return best_play

static func play_enemy_card_from_hand(engine, hand_index: int, target: Dictionary) -> bool:
	if hand_index < 0 or hand_index >= engine.enemy_hand.size():
		return false
	var card = engine._card(engine.enemy_hand[hand_index])
	if card == null or int(card.cost) > engine.enemy_mana:
		return false
	engine.enemy_mana -= int(card.cost)
	var card_id: String = engine.enemy_hand[hand_index]
	engine.enemy_hand.remove_at(hand_index)
	engine.enemy_discard.append(card_id)
	if card.occupies_slot():
		var slot_index: int = int(target.get("slot", best_enemy_creature_slot(engine)))
		if slot_index < 0 or slot_index >= engine.enemy_slots.size() or engine.enemy_slots[slot_index] != null:
			return false
		engine.enemy_slots[slot_index] = engine._build_occupant(card, ENEMY_ID, true)
		engine._apply_summon_field_effect(ENEMY_ID, slot_index)
		engine._resolve_on_enter(card, ENEMY_ID, slot_index)
		engine._log("Comandante inimigo invocou %s no slot %d." % [card.display_name, slot_index + 1])
	else:
		resolve_enemy_spell(engine, card, target)
	engine._check_outcome()
	return true

static func resolve_enemy_spell(engine, card, target: Dictionary) -> void:
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage":
			var amount: int = int(effect.get("amount", effect.get("damage", 0)))
			var target_data: Dictionary = target if not target.is_empty() else engine._first_player_target()
			if target_data.has("slot"):
				engine._damage_slot(str(target_data.get("owner", PLAYER_ID)), int(target_data.get("slot", -1)), amount, "spell")
			else:
				engine._damage_hero(str(target_data.get("owner", PLAYER_ID)), amount)
			engine._log("Comandante inimigo usou %s." % card.display_name)
		"random_damage":
			engine._resolve_random_damage(int(effect.get("amount", effect.get("damage", 0))), PLAYER_ID)
			engine._log("Comandante inimigo espalhou dano com %s." % card.display_name)
		"all_enemy_damage":
			for player_index: int in range(engine.player_slots.size()):
				if engine.player_slots[player_index] != null:
					engine._damage_slot(PLAYER_ID, player_index, int(effect.get("amount", 1)), "spell")
			engine._log("Comandante inimigo atingiu a mesa com %s." % card.display_name)
		"freeze_random_enemy":
			var frozen_count: int = engine._freeze_random_enemies(bool(effect.get("all", false)), int(effect.get("count", 1)), int(effect.get("amount", 1)), PLAYER_ID)
			engine._log("Comandante inimigo congelou %d criatura(s)." % frozen_count)
		"poison_all_enemies":
			for player_index: int in range(engine.player_slots.size()):
				if engine.player_slots[player_index] != null:
					engine._apply_poison_to_slot(PLAYER_ID, player_index, int(effect.get("amount", 1)))
			engine._log("Comandante inimigo espalhou Veneno.")
		"debuff", "weaken", "snare", "multi_debuff", "punish_snared":
			engine._apply_debuff_to_target(effect, target)
			engine._log("Comandante inimigo controlou uma criatura com %s." % card.display_name)
		"buff_ally":
			var slot_index: int = engine._strongest_enemy_slot()
			engine._buff_slot(ENEMY_ID, slot_index, int(effect.get("attack", 0)), int(effect.get("health", 0)), bool(effect.get("temporary", false)))
			engine._log("Comandante inimigo fortaleceu uma criatura.")

static func best_enemy_creature_slot(engine) -> int:
	var best_slot: int = -1
	var best_score: float = -999999.0
	for slot_index: int in range(engine.enemy_slots.size()):
		if engine.enemy_slots[slot_index] != null:
			continue
		var score: float = score_enemy_lane_for_profile(engine, slot_index, engine._enemy_ai_profile())
		if best_slot < 0 or score > best_score:
			best_score = score
			best_slot = slot_index
	if best_slot >= 0:
		return best_slot
	return -1

static func best_enemy_spell_target(engine, card) -> Dictionary:
	var best_target: Dictionary = {}
	var best_score: float = -999999.0
	for target: Dictionary in enemy_spell_targets(engine, card):
		var score: float = score_enemy_spell_play(engine, card, target, 0)
		if best_target.is_empty() or score > best_score:
			best_score = score
			best_target = target.duplicate()
	return best_target

static func enemy_spell_targets(engine, card) -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	var effect: Dictionary = Dictionary(card.effect)
	match str(effect.get("action", "")):
		"damage", "debuff", "weaken", "snare", "multi_debuff", "punish_snared":
			targets.append_array(engine._targetable_occupied_slot_targets(PLAYER_ID, true))
			if engine._enemy_hero_is_objective() or targets.is_empty():
				targets.append({"owner": PLAYER_ID, "hero": true})
		"random_damage", "all_enemy_damage", "freeze_random_enemy", "poison_all_enemies":
			if not engine._area_damage_targets(PLAYER_ID).is_empty():
				targets.append(engine._board_area_target(PLAYER_ID))
			elif engine._enemy_hero_is_objective():
				targets.append({"owner": PLAYER_ID, "hero": true})
		"buff_ally":
			targets.append_array(engine._targetable_occupied_slot_targets(ENEMY_ID, false))
	return targets

static func score_enemy_creature_play(engine, card, slot_index: int, hand_index: int) -> float:
	var profile: Dictionary = engine._enemy_ai_profile()
	var score: float = float(card.attack) * (0.55 + 0.12 * float(profile.get("burst", 1.0)))
	score += float(card.health) * (0.20 + 0.18 * float(profile.get("durability", 1.0)))
	score -= float(card.cost) * 0.18
	score -= float(hand_index) * 0.01
	score += score_enemy_lane_for_profile(engine, slot_index, profile)
	score += score_enemy_card_keywords(card, profile)
	var front: Dictionary = engine._slot_occupant(PLAYER_ID, slot_index)
	if not front.is_empty():
		score += 1.8 * float(profile.get("lane_pressure", 1.0))
		score += engine._player_unit_threat_score(front) * float(profile.get("high_value", 1.0)) * 0.26
		if bool(front.get("defensor", false)):
			score += 2.4 * float(profile.get("defender", 1.0))
		if int(front.get("thorns_amount", 0)) > 0 and int(card.attack) > 0:
			score -= float(int(front.get("thorns_amount", 0))) * float(profile.get("thorns_risk", 1.0)) * (1.0 if int(card.health) <= 2 else 0.55)
		if int(front.get("attack", 0)) >= int(card.health):
			score += 1.1 * float(profile.get("trade", 1.0))
	else:
		score += 2.0 * float(profile.get("empty_lane", 1.0))
		if engine._enemy_hero_is_objective():
			score += 2.6 * float(profile.get("direct", 1.0))
	var nearest_defender: Dictionary = engine._nearest_defender_target(PLAYER_ID, slot_index)
	if not nearest_defender.is_empty() and front.is_empty():
		score += 1.15 * float(profile.get("defender", 1.0))
	if engine.mode == MODE_DEFENSE_POSITION and slot_index == engine.defense_slot_index:
		score += 3.2
	if engine.mode == MODE_SUMMONER_BOSS:
		score += engine._boss_piece_protection_score(slot_index) * float(profile.get("protect", 1.0))
	return score

static func score_enemy_spell_play(engine, card, target: Dictionary, hand_index: int) -> float:
	var profile: Dictionary = engine._enemy_ai_profile()
	var effect: Dictionary = Dictionary(card.effect)
	var action: String = str(effect.get("action", ""))
	var score: float = 1.0 - float(card.cost) * 0.12 - float(hand_index) * 0.01
	if bool(target.get("hero", false)):
		var amount: int = int(effect.get("amount", effect.get("damage", 0)))
		score += float(amount) * (1.0 + float(profile.get("direct", 1.0)))
		if engine.player_health <= amount:
			score += 20.0
		return score
	if str(target.get("area", "")) == "board":
		score += float(engine._area_damage_targets(PLAYER_ID).size()) * (1.4 if action == "random_damage" else 1.0)
		if action in ["freeze_random_enemy", "poison_all_enemies"]:
			score += 2.0 * float(profile.get("control", 1.0))
		return score
	var occupant: Dictionary = engine._slot_occupant(str(target.get("owner", PLAYER_ID)), int(target.get("slot", -1)))
	if action == "buff_ally":
		score += engine._enemy_unit_value(occupant) * (0.35 + float(profile.get("protect", 1.0)) * 0.25)
	else:
		score += engine._player_unit_threat_score(occupant) * (0.30 + float(profile.get("high_value", 1.0)) * 0.18)
		if action in ["debuff", "weaken", "snare", "multi_debuff", "punish_snared"]:
			score += 2.4 * float(profile.get("control", 1.0))
		if int(effect.get("amount", effect.get("damage", 0))) >= int(occupant.get("health", 999)):
			score += 4.0
	return score

static func score_enemy_lane_for_profile(engine, slot_index: int, profile: Dictionary) -> float:
	var score: float = 0.0
	var front: Dictionary = engine._slot_occupant(PLAYER_ID, slot_index)
	if front.is_empty():
		score += 1.0 * float(profile.get("empty_lane", 1.0))
	else:
		score += 1.0 * float(profile.get("lane_pressure", 1.0))
		score += engine._player_unit_threat_score(front) * 0.08 * float(profile.get("high_value", 1.0))
	var center: float = float(engine.enemy_slots.size() - 1) * 0.5
	score -= abs(float(slot_index) - center) * 0.08
	return score

static func score_enemy_card_keywords(card, profile: Dictionary) -> float:
	var score: float = 0.0
	for keyword: String in card.keywords:
		match keyword:
			"defensor", "resistencia", "escudo", "crescer":
				score += 0.9 * float(profile.get("durability", 1.0)) + 0.45 * float(profile.get("protect", 1.0))
			"congelar", "veneno":
				score += 1.3 * float(profile.get("control", 1.0))
			"iniciativa", "ecoar", "atropelar":
				score += 1.0 * float(profile.get("direct", 1.0)) + 0.45 * float(profile.get("burst", 1.0))
			"brutal", "furia", "ressurgir":
				score += 1.15 * float(profile.get("trade", 1.0)) + 0.65 * float(profile.get("burst", 1.0))
			"espinhos":
				score += 0.65 * float(profile.get("trade", 1.0)) + 0.55 * float(profile.get("durability", 1.0))
	return score
