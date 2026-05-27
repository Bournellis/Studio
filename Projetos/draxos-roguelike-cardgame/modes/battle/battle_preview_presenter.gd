extends RefCounted

static func card_preview_data(engine: BattleEngine, card_id: String, occupant: Dictionary) -> Dictionary:
	var card = ContentLibrary.get_card(card_id)
	if card == null:
		return {"title": card_id, "subtitle": "Carta", "body": "", "state": ""}
	var subtitle: String = "%s | Custo %d" % [UiTokens.type_display_name(str(card.card_type)), int(card.cost)]
	if card.occupies_slot():
		subtitle += " | %d/%d" % [int(card.attack), int(card.health)]
	var body: String = VisualAssets.card_display_text(card, engine.get_card_text_context(card_id))
	var keyword_text: String = ContentLibrary.keywords_tooltip_text(Array(card.keywords))
	if keyword_text != "":
		body += "\n\n%s" % keyword_text
	var state: String = ""
	if not occupant.is_empty():
		var state_parts: Array[String] = []
		var current_attack: int = int(occupant.get("attack", 0))
		var current_health: int = int(occupant.get("health", 0))
		var current_max_health: int = int(occupant.get("max_health", card.health))
		if current_attack != int(card.attack):
			state_parts.append("ATK atual %d (base %d)" % [current_attack, int(card.attack)])
		else:
			state_parts.append("ATK %d" % current_attack)
		if current_health != int(card.health) or current_max_health != int(card.health):
			state_parts.append("HP atual %d/%d (base %d)" % [current_health, current_max_health, int(card.health)])
		else:
			state_parts.append("HP %d/%d" % [current_health, current_max_health])
		var temporary_attack: int = int(occupant.get("temporary_attack_bonus", 0))
		if temporary_attack != 0:
			state_parts.append("Bonus temporario +%d ATK" % temporary_attack)
		state_parts.append_array(ContentLibrary.status_summary_parts(occupant))
		if bool(occupant.get("defensor", false)):
			state_parts.append("Defensor")
		if bool(occupant.get("revive_marker", false)):
			state_parts.append("Revive usado")
		state = " | ".join(state_parts)
	return {"title": str(card.display_name), "subtitle": subtitle, "body": body, "state": state}

static func slot_preview_data(engine: BattleEngine, owner_id: String, slot_index: int, occupant: Variant) -> Dictionary:
	if occupant == null:
		return {
			"title": "%s %d" % ["Slot aliado" if owner_id == BattleEngine.PLAYER_ID else "Slot inimigo", slot_index + 1],
			"subtitle": "Livre",
			"body": "Pode receber cartas ou efeitos validos para este lado da mesa.",
			"state": ""
		}
	var data: Dictionary = Dictionary(occupant)
	if str(data.get("card_id", "")) == "" and bool(data.get("objective", false)):
		return {
			"title": str(data.get("name", "Objetivo de Defesa")),
			"subtitle": "Objetivo de defesa",
			"body": "Proteja este slot ate o objetivo do encontro ser concluido.",
			"state": "ATK %d | HP %d/%d" % [int(data.get("attack", 0)), int(data.get("health", 0)), int(data.get("max_health", data.get("health", 0)))]
		}
	return card_preview_data(engine, str(data.get("card_id", "")), data)

static func hero_preview_data(owner_id: String, display_name: String, health: int) -> Dictionary:
	return {
		"title": display_name,
		"subtitle": "Heroi %s" % ("aliado" if owner_id == BattleEngine.PLAYER_ID else "inimigo"),
		"body": "Alvo visivel do combate. Criaturas inimigas sem frente nem defensor causam dano ao jogador; herois inimigos recebem dano direto nos modos apropriados.",
		"state": "Vida %d" % health
	}

static func class_passive_preview_data() -> Dictionary:
	if not RunSession.class_passive_unlocked:
		return {}
	return {
		"title": class_passive_display_name(),
		"subtitle": "Passiva de classe",
		"body": class_passive_detail_text(),
		"state": "Liberada"
	}

static func class_active_preview_data(engine: BattleEngine, choice_id: String = "") -> Dictionary:
	if not RunSession.class_active_unlocked:
		return {}
	return {
		"title": class_active_display_name(engine, choice_id),
		"subtitle": "Spell de classe",
		"body": class_active_detail_text(engine, choice_id),
		"state": "Disponivel" if engine.can_use_class_active() else "Indisponivel neste turno"
	}

static func class_passive_display_name() -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "Fluxo Continuo"
		"invocador":
			return "Comandante de Campo"
		"necromante":
			return "Colheita Sombria"
	return "Passiva"

static func class_passive_detail_text() -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "Cada carta jogada neste turno gera 1 Fluxo. Fluxo aumenta dano direto de spells e da Rajada Arcana ate o inicio do proximo turno."
		"invocador":
			return "A primeira criatura aliada invocada a cada turno faz a criatura aliada com maior ATK receber +2/+1 permanente durante a batalha."
		"necromante":
			return "Sempre que qualquer criatura morre em campo, aliada ou inimiga, ganha 1 Cinza. Cinzas acumulam e alimentam o Ritual das Sombras."
	return ""

static func class_active_display_name(engine: BattleEngine, choice_id: String = "") -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "Rajada Arcana"
		"invocador":
			return "Ordem de Guerra"
		"necromante":
			for choice: Dictionary in engine.get_necromancer_active_choices():
				if str(choice.get("id", "")) == choice_id:
					return str(choice.get("display_name", "Ritual das Sombras"))
			return "Ritual das Sombras"
	return "Spell de Classe"

static func class_active_detail_text(engine: BattleEngine, choice_id: String = "") -> String:
	match RunSession.selected_class_id:
		"arcano":
			return "1 mana. Arraste para uma criatura ou heroi valido; causa 1 + Fluxo de dano."
		"invocador":
			return "0 mana. Arraste para a mesa aliada; concede +2/+0 permanente a aliada com maior ATK."
		"necromante":
			for choice: Dictionary in engine.get_necromancer_active_choices():
				if str(choice.get("id", "")) == choice_id:
					return "%d Cinzas. %s" % [int(choice.get("cost_ashes", 0)), str(choice.get("text", ""))]
			return "Clique para escolher Podridao, Furia, Raio das Cinzas ou upgrades antes de arrastar."
	return ""
