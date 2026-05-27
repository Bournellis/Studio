extends RefCounted

const ENEMY_AI_TERRA: String = "terra"
const ENEMY_AI_GELO: String = "gelo"
const ENEMY_AI_AR: String = "ar"
const ENEMY_AI_FOGO: String = "fogo"

const PROFILES: Dictionary = {
	"terra": {
		"display_name": "Terra",
		"summary": "estabiliza lanes e protege ameacas duraveis",
		"lane_pressure": 1.05,
		"empty_lane": 0.55,
		"defender": 1.35,
		"high_value": 0.85,
		"thorns_risk": 1.10,
		"control": 0.45,
		"direct": 0.55,
		"trade": 0.80,
		"durability": 1.20,
		"protect": 1.25,
		"burst": 0.50
	},
	"gelo": {
		"display_name": "Gelo",
		"summary": "controla a maior ameaca e cria atrito",
		"lane_pressure": 0.85,
		"empty_lane": 0.45,
		"defender": 0.95,
		"high_value": 1.45,
		"thorns_risk": 1.00,
		"control": 1.65,
		"direct": 0.50,
		"trade": 0.70,
		"durability": 0.95,
		"protect": 0.80,
		"burst": 0.45
	},
	"ar": {
		"display_name": "Ar",
		"summary": "pressiona lanes vazias e dano rapido",
		"lane_pressure": 1.00,
		"empty_lane": 1.70,
		"defender": 0.65,
		"high_value": 0.75,
		"thorns_risk": 0.80,
		"control": 0.40,
		"direct": 1.55,
		"trade": 0.60,
		"durability": 0.40,
		"protect": 0.40,
		"burst": 1.35
	},
	"fogo": {
		"display_name": "Fogo",
		"summary": "forca trocas explosivas e cascatas de morte",
		"lane_pressure": 1.30,
		"empty_lane": 1.05,
		"defender": 0.85,
		"high_value": 1.05,
		"thorns_risk": 0.45,
		"control": 0.35,
		"direct": 1.15,
		"trade": 1.55,
		"durability": 0.55,
		"protect": 0.35,
		"burst": 1.50
	}
}

static func has_profile(profile_id: String) -> bool:
	return PROFILES.has(profile_id)

static func profile(profile_id: String) -> Dictionary:
	if PROFILES.has(profile_id):
		return Dictionary(PROFILES[profile_id])
	return Dictionary(PROFILES[ENEMY_AI_TERRA])

static func resolve_profile_id(encounter: Dictionary, config: Dictionary) -> String:
	var explicit_profile: String = str(config.get("enemy_ai_profile", encounter.get("enemy_ai_profile", ""))).to_lower()
	if has_profile(explicit_profile):
		return explicit_profile
	var inferred: String = infer_profile_from_encounter(encounter)
	if has_profile(inferred):
		return inferred
	return ENEMY_AI_TERRA

static func infer_profile_from_encounter(encounter: Dictionary) -> String:
	var profile_counts: Dictionary = {ENEMY_AI_TERRA: 0, ENEMY_AI_GELO: 0, ENEMY_AI_AR: 0, ENEMY_AI_FOGO: 0}
	for card_id: String in _string_array(encounter.get("enemy_deck", [])):
		_count_profile_hint(profile_counts, card_id)
	for setup: Variant in Array(encounter.get("starting_enemy_slots", [])):
		if typeof(setup) == TYPE_DICTIONARY:
			_count_profile_hint(profile_counts, str(Dictionary(setup).get("card_id", "")))
	for summon: Variant in Array(encounter.get("boss_summons", [])):
		if typeof(summon) == TYPE_DICTIONARY:
			_count_profile_hint(profile_counts, str(Dictionary(summon).get("card_id", "")))
	var best_profile: String = ENEMY_AI_TERRA
	var best_count: int = -1
	for profile_id: String in [ENEMY_AI_TERRA, ENEMY_AI_GELO, ENEMY_AI_AR, ENEMY_AI_FOGO]:
		var count: int = int(profile_counts.get(profile_id, 0))
		if count > best_count:
			best_count = count
			best_profile = profile_id
	return best_profile

static func priority_lines(profile_id: String, profile_name: String) -> Array[String]:
	match profile_id:
		ENEMY_AI_GELO:
			return ["Perfil %s: controla a maior ameaca." % profile_name, "Prioriza Veneno, Congelar e atrito."]
		ENEMY_AI_AR:
			return ["Perfil %s: pressiona lanes vazias." % profile_name, "Prioriza Iniciativa, Atropelar e dano rapido."]
		ENEMY_AI_FOGO:
			return ["Perfil %s: aceita trocas explosivas." % profile_name, "Prioriza Brutal, Furia, morte e dano direto."]
		_:
			return ["Perfil %s: estabiliza a mesa." % profile_name, "Prioriza Defensor, Espinhos, Resistencia e Crescer."]

static func field_effect_hint(profile_id: String, active_hint: String) -> String:
	if active_hint != "":
		return active_hint
	match profile_id:
		ENEMY_AI_GELO:
			return "Controle/atrito provavel: Congelar, Veneno ou atraso no alvo forte."
		ENEMY_AI_AR:
			return "Pressao posicional provavel: lane vazia, Iniciativa ou Atropelar."
		ENEMY_AI_FOGO:
			return "Troca explosiva provavel: Brutal, Furia, Espinhos ou morte em cadeia."
		_:
			return "Estabilizacao provavel: bloqueios, Espinhos, Resistencia ou Crescer."

static func _count_profile_hint(profile_counts: Dictionary, card_id: String) -> void:
	for profile_id: String in [ENEMY_AI_TERRA, ENEMY_AI_GELO, ENEMY_AI_AR, ENEMY_AI_FOGO]:
		if card_id.begins_with("enemy_%s_" % profile_id) or card_id.find("_%s_" % profile_id) >= 0:
			profile_counts[profile_id] = int(profile_counts.get(profile_id, 0)) + 1
			return

static func _string_array(source: Variant) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in Array(source):
		result.append(str(item))
	return result
