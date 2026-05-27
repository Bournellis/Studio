extends RefCounted

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"
const MODE_WAVES: String = "ondas"
const MODE_DEFENSE_POSITION: String = "defesa_posicao"
const MODE_SURVIVE_TURNS: String = "sobreviver_turnos"
const MODE_SUMMONER_BOSS: String = "chefe_summoner"
const MODE_AMBUSH: String = "emboscada"
const MODE_ESCORT: String = "escolta"
const MODE_INVASION: String = "invasao"

static func enemy_intent(engine) -> Dictionary:
	if engine.mode == MODE_SUMMONER_BOSS:
		return boss_enemy_intent(engine)
	return common_enemy_intent(engine)

static func common_enemy_intent(engine) -> Dictionary:
	var profile: Dictionary = engine._enemy_ai_profile()
	var incoming: Dictionary = estimate_enemy_incoming_pressure(engine)
	var next_play: Dictionary = engine._best_enemy_play()
	var target_priority: Dictionary = highest_value_player_target(engine)
	var priorities: Array[String] = engine._profile_priority_lines(str(profile.get("display_name", "")))
	if not next_play.is_empty():
		priorities.append("Proxima jogada provavel: %s." % intent_next_play_line(engine, next_play))
	if not target_priority.is_empty():
		priorities.append("Alvo de maior valor: %s." % engine._target_display_name(target_priority))
	return {
		"visible": intent_should_be_visible(engine),
		"kind": "common",
		"title": "Intencao inimiga",
		"profile_id": engine.enemy_ai_profile_id,
		"profile_name": str(profile.get("display_name", "Terra")),
		"profile_summary": str(profile.get("summary", "")),
		"priorities": priorities,
		"target_priority": engine._target_display_name(target_priority) if not target_priority.is_empty() else "Heroi do jogador",
		"lane_pressure": Array(incoming.get("lanes", [])).duplicate(),
		"incoming_pressure": str(incoming.get("summary", "Sem pressao imediata.")),
		"incoming_field_effect": engine._profile_field_effect_hint(engine.enemy_ai_profile_id),
		"next_action": intent_next_play_line(engine, next_play),
		"tooltip_ids": ["lane_pressure", "incoming_pressure", "control_target"]
	}

static func boss_enemy_intent(engine) -> Dictionary:
	var common: Dictionary = common_enemy_intent(engine)
	var phase: Dictionary = engine._boss_phase_state()
	var next_special: String = engine._next_boss_special_action()
	var priorities: Array[String] = []
	for priority: Variant in Array(common.get("priorities", [])):
		priorities.append(str(priority))
	priorities.push_front("Fase atual: %s." % str(phase.get("label", "")))
	priorities.append("Acao especial: %s." % next_special)
	return {
		"visible": true,
		"kind": "boss",
		"title": "Intencao do chefe",
		"profile_id": engine.enemy_ai_profile_id,
		"profile_name": str(common.get("profile_name", "")),
		"profile_summary": str(common.get("profile_summary", "")),
		"priorities": priorities,
		"target_priority": str(common.get("target_priority", "")),
		"lane_pressure": Array(common.get("lane_pressure", [])).duplicate(),
		"incoming_pressure": str(common.get("incoming_pressure", "")),
		"current_phase": str(phase.get("label", "")),
		"next_scripted_trigger": str(phase.get("next_trigger", "")),
		"next_major_special_action": next_special,
		"next_action": str(common.get("next_action", "")),
		"tooltip_ids": ["boss_phase", "lane_pressure", "incoming_pressure"]
	}

static func boss_piece_protection_score(engine, slot_index: int) -> float:
	var score: float = 0.0
	for index: int in range(engine.enemy_slots.size()):
		var occupant: Dictionary = engine._slot_occupant(ENEMY_ID, index)
		if occupant.is_empty():
			continue
		var distance: int = absi(index - slot_index)
		if distance <= 1:
			score += engine._enemy_unit_value(occupant) * (0.18 if distance == 0 else 0.10)
	return score

static func intent_should_be_visible(engine) -> bool:
	return engine.enemy_commander_enabled or not engine._board_is_clear(ENEMY_ID) or engine.mode in [MODE_WAVES, MODE_DEFENSE_POSITION, MODE_SURVIVE_TURNS, MODE_SUMMONER_BOSS, MODE_AMBUSH, MODE_ESCORT, MODE_INVASION]

static func highest_value_player_target(engine) -> Dictionary:
	var best_target: Dictionary = {}
	var best_score: float = -1.0
	for index: int in range(engine.player_slots.size()):
		var occupant: Dictionary = engine._slot_occupant(PLAYER_ID, index)
		if occupant.is_empty():
			continue
		var score: float = engine._player_unit_threat_score(occupant)
		if best_target.is_empty() or score > best_score:
			best_score = score
			best_target = {"owner": PLAYER_ID, "slot": index}
	return best_target

static func estimate_enemy_incoming_pressure(engine) -> Dictionary:
	var lanes: Array[String] = []
	var hero_damage: int = 0
	var board_damage: int = 0
	for slot_index: int in range(engine.enemy_slots.size()):
		var attacker: Dictionary = engine._slot_occupant(ENEMY_ID, slot_index)
		if attacker.is_empty():
			continue
		if int(attacker.get("frozen_turns", 0)) > 0 or int(attacker.get("slow_turns", 0)) > 0:
			lanes.append("Lane %d: ataque atrasado por controle." % (slot_index + 1))
			continue
		var target: Dictionary = engine._front_attack_target(ENEMY_ID, slot_index)
		if target.is_empty():
			target = engine._overflow_attack_target(ENEMY_ID, slot_index)
		if target.is_empty():
			continue
		var damage: int = int(attacker.get("attack", 0)) + engine._inspire_bonus_for(ENEMY_ID, slot_index) + engine._board_attack_bonus(ENEMY_ID, slot_index)
		if bool(target.get("hero", false)):
			hero_damage += damage
		else:
			board_damage += damage
		lanes.append("Lane %d: %d dano em %s." % [slot_index + 1, damage, engine._target_display_name(target)])
	var summary: String = "%d dano ao heroi, %d em criaturas." % [hero_damage, board_damage]
	if hero_damage == 0 and board_damage == 0 and lanes.is_empty():
		summary = "Sem ataque imediato no proximo combate."
	return {"hero_damage": hero_damage, "board_damage": board_damage, "lanes": lanes, "summary": summary}

static func intent_next_play_line(engine, play: Dictionary) -> String:
	if play.is_empty():
		return "Sem carta clara para jogar."
	var hand_index: int = int(play.get("hand_index", -1))
	if hand_index < 0 or hand_index >= engine.enemy_hand.size():
		return "Sem carta clara para jogar."
	var card = engine._card(engine.enemy_hand[hand_index])
	if card == null:
		return "Sem carta clara para jogar."
	return "%s em %s" % [card.display_name, engine._target_display_name(Dictionary(play.get("target", {})))]
