extends RefCounted

static func player_values(state: Dictionary) -> Dictionary:
	return {
		"hp_text": str(int(state.get("player_health", 0))),
		"mana_text": "%d/%d" % [int(state.get("mana", 0)), int(state.get("mana_per_turn", 0))],
		"class_resource": class_resource_data(state)
	}

static func enemy_commander_values(state: Dictionary) -> Dictionary:
	var enabled: bool = bool(state.get("enemy_commander_enabled", false))
	return {
		"visible": enabled,
		"hp_text": str(int(state.get("enemy_health", 0))),
		"mana_text": "%d/%d" % [int(state.get("enemy_mana", 0)), int(state.get("enemy_mana_per_turn", 0))],
		"hand_count": int(state.get("enemy_hand_count", 0)) if enabled else 0
	}

static func class_resource_data(state: Dictionary) -> Dictionary:
	match RunSession.selected_class_id:
		"arcano":
			if RunSession.class_passive_unlocked:
				return {"label": "Fluxo", "value": int(state.get("flow", 0))}
		"necromante":
			if RunSession.class_passive_unlocked or RunSession.class_active_unlocked or int(state.get("ashes", 0)) > 0:
				return {"label": "Cinzas", "value": int(state.get("ashes", 0))}
	return {}

static func objective_text(state: Dictionary, enemy_display_name: String) -> String:
	var mode: String = str(state.get("mode", ""))
	match mode:
		BattleEngine.MODE_WAVES:
			var total_waves: int = int(state.get("waves_total", 0))
			if total_waves > 0:
				return "Onda %d/%d" % [int(state.get("wave_index", 0)), total_waves]
		BattleEngine.MODE_DEFENSE_POSITION:
			return "Defenda %d/%d" % [int(state.get("survived_turns", 0)), int(state.get("required_defense_turns", 0))]
		BattleEngine.MODE_SURVIVE_TURNS:
			return "Sobreviva %d/%d" % [int(state.get("survived_turns", 0)), int(state.get("required_survive_turns", 0))]
		BattleEngine.MODE_SUMMONER_BOSS:
			return "Chefe HP %d" % int(state.get("enemy_health", 0))
		BattleEngine.MODE_AMBUSH:
			return "Emboscada | mana inicial 0"
		BattleEngine.MODE_ESCORT:
			return "Escolte o Cargo ate o ultimo slot"
		BattleEngine.MODE_INVASION:
			return "Invasao | portais no 3 e 5"
	if bool(state.get("enemy_commander_enabled", false)):
		return "Derrote %s" % enemy_display_name
	return ""

static func enemy_hero_visible(state: Dictionary) -> bool:
	return str(state.get("mode", "")) in [BattleEngine.MODE_DUEL, BattleEngine.MODE_SUMMONER_BOSS]

static func hero_display_name(owner_id: String) -> String:
	var catalog = ContentLibrary.get_catalog()
	if owner_id == BattleEngine.PLAYER_ID:
		return RunSession.player_display_name()
	if owner_id == BattleEngine.ENEMY_ID and catalog != null and catalog.enemy_hero != null:
		return str(catalog.enemy_hero.display_name)
	return "Inimigo" if owner_id == BattleEngine.ENEMY_ID else "Player"
