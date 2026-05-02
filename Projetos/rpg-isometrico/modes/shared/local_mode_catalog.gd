class_name LocalModeCatalog
extends RefCounted

const FRONTEND_SCENE_PATH: String = "res://modes/frontend/frontend.tscn"
const TUTORIAL_SCENE_PATH: String = "res://modes/tutorial/tutorial.tscn"
const MENU_GROUP_CAMPAIGN_ID: StringName = &"campaign_main"
const MENU_GROUP_EXTRAS_ID: StringName = &"extras"
const MENU_GROUP_EXPERIMENTAL_ID: StringName = &"experimental"
const MENU_GROUP_ADVENTURE_ID: StringName = MENU_GROUP_CAMPAIGN_ID
const MENU_GROUP_VERSUS_ID: StringName = MENU_GROUP_EXPERIMENTAL_ID
const CAMPAIGN_MODE_ID: StringName = &"campaign"
const ARENA_BOT_MODE_ID: StringName = &"arena_bot"
const ARENA_PVP_MODE_ID: StringName = &"arena_pvp"
const LEGACY_ARENA_MODE_ID: StringName = &"arena"
const ARENA_MODE_ID: StringName = ARENA_BOT_MODE_ID
const SURVIVAL_MODE_ID: StringName = &"survival"
const BOSS_MODE_ID: StringName = &"boss"

const MODE_IDS: PackedStringArray = [
	"campaign",
	"survival",
	"boss",
	"arena_bot",
	"arena_pvp",
]

const PUBLIC_MENU_MODE_IDS: PackedStringArray = [
	"campaign",
	"survival",
	"boss",
	"arena_bot",
]

const MENU_GROUP_IDS: PackedStringArray = [
	"campaign_main",
	"extras",
]

const MODE_METADATA: Dictionary = {
	CAMPAIGN_MODE_ID: {
		"display_name": "Campanha do Troll",
		"scene_path": "res://modes/campaign/campaign.tscn",
		"action_label": "Entrar na Campanha",
		"subtitle": "Jornada principal da build: a campanha comeca na Missao 1/tutorial e segue ate o chefe do Troll.",
		"summary": "Caminho principal de progressao. A Campanha classica ensina o kit, libera recursos permanentes e abre os desafios extras.",
		"controls": "Campanha local: WASD mover | Clique/Space atacar | Shift dash | Q E R F habilidades | 1 2 pocoes | Esc menu",
		"group_id": MENU_GROUP_CAMPAIGN_ID,
		"parameters": {
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy"
		}
	},
	SURVIVAL_MODE_ID: {
		"display_name": "Survival",
		"scene_path": "res://modes/survival/survival.tscn",
		"action_label": "Entrar em Survival",
		"subtitle": "Prova extra de resistencia com o kit aprendido na campanha.",
		"summary": "Desafio de ondas para medir folego, ritmo e dominio do kit. Usa recursos permanentes ja aprendidos; nao substitui a progressao da Campanha Classica.",
		"controls": "Survival local: WASD mover | Clique/Space atacar | Shift dash | Q E R F habilidades | 1 2 pocoes | Esc menu",
		"group_id": MENU_GROUP_EXTRAS_ID,
		"parameters": {
			"start_wave": 1
		}
	},
	BOSS_MODE_ID: {
		"display_name": "Boss",
		"scene_path": "res://modes/boss/boss.tscn",
		"action_label": "Entrar em Boss",
		"subtitle": "Arena extra de maestria contra o Boss Troll depois da campanha.",
		"summary": "Pratica curta de execucao e leitura de perigo. Usa o kit aprendido para dominar o chefe, sem virar nova rota de unlock permanente.",
		"controls": "Boss local: WASD mover | Clique/Space atacar | Shift dash | Q E R F habilidades | 1 2 pocoes | Esc menu",
		"group_id": MENU_GROUP_EXTRAS_ID,
		"parameters": {
			"boss_id": "boss_troll"
		}
	},
	ARENA_BOT_MODE_ID: {
		"display_name": "Arena Bot",
		"scene_path": "res://modes/arena/arena.tscn",
		"action_label": "Entrar na Arena Bot",
		"subtitle": "Simulacao local para testar kit, mira e leitura fora da campanha.",
		"summary": "Campo de treino contra bot para experimentar combinacoes desbloqueadas. Nao promete PvP publico, ranking, matchmaking ou progressao principal.",
		"controls": "Arena Bot: WASD mover | Clique/Space atacar | Shift dash | Q E R F habilidades | 1 2 pocoes",
		"group_id": MENU_GROUP_EXTRAS_ID,
		"parameters": {
			"opponent_id": "bot"
		}
	},
	ARENA_PVP_MODE_ID: {
		"display_name": "Duelo Privado",
		"scene_path": FRONTEND_SCENE_PATH,
		"action_label": "Duelo experimental indisponivel",
		"subtitle": "Surface experimental para futuro convite direto entre jogadores.",
		"summary": "Nao aparece na navegacao publica desta fase. Fica reservado para um gate futuro de duelo privado casual.",
		"controls": "Sem runtime ativo nesta build.",
		"group_id": MENU_GROUP_EXPERIMENTAL_ID,
		"parameters": {
			"placeholder": true
		}
	}
}

static func get_mode_ids() -> PackedStringArray:
	return MODE_IDS

static func get_public_menu_mode_ids() -> PackedStringArray:
	return PUBLIC_MENU_MODE_IDS

static func is_public_menu_mode(mode_id: StringName) -> bool:
	return PUBLIC_MENU_MODE_IDS.has(String(normalize_mode_id(mode_id)))

static func get_menu_group_ids() -> PackedStringArray:
	return MENU_GROUP_IDS

static func get_modes_for_menu_group(group_id: StringName) -> PackedStringArray:
	var resolved_group_id: StringName = StringName(str(group_id))
	var mode_ids: PackedStringArray = []
	for mode_id_text: String in PUBLIC_MENU_MODE_IDS:
		var mode_id: StringName = StringName(mode_id_text)
		if get_menu_group_id(mode_id) != resolved_group_id:
			continue
		mode_ids.append(String(mode_id))
	return mode_ids

static func get_menu_group_id(mode_id: StringName) -> StringName:
	return StringName(str(_get_metadata(mode_id).get("group_id", MENU_GROUP_ADVENTURE_ID)))

static func get_menu_group_display_name(group_id: StringName) -> String:
	match normalize_mode_group_id(group_id):
		MENU_GROUP_CAMPAIGN_ID:
			return "Campanha"
		MENU_GROUP_EXTRAS_ID:
			return "Extras"
		MENU_GROUP_EXPERIMENTAL_ID:
			return "Experimental"
		_:
			return "Grupo"

static func is_supported_mode(mode_id: StringName) -> bool:
	return MODE_METADATA.has(normalize_mode_id(mode_id))

static func get_scene_path(mode_id: StringName) -> String:
	return str(_get_metadata(mode_id).get("scene_path", FRONTEND_SCENE_PATH))

static func get_display_name(mode_id: StringName) -> String:
	return str(_get_metadata(mode_id).get("display_name", "Modo"))

static func get_action_label(mode_id: StringName) -> String:
	return str(_get_metadata(mode_id).get("action_label", "Entrar"))

static func get_subtitle(mode_id: StringName) -> String:
	return str(_get_metadata(mode_id).get("subtitle", ""))

static func get_summary(mode_id: StringName) -> String:
	return str(_get_metadata(mode_id).get("summary", ""))

static func get_controls_hint(mode_id: StringName) -> String:
	return str(_get_metadata(mode_id).get("controls", "Esc volta ao frontend."))

static func build_launch_parameters(mode_id: StringName, overrides: Dictionary = {}) -> Dictionary:
	var resolved_mode_id: StringName = normalize_mode_id(mode_id)
	var defaults: Dictionary = Dictionary(_get_metadata(mode_id).get("parameters", {})).duplicate(true)
	match resolved_mode_id:
		CAMPAIGN_MODE_ID:
			defaults["campaign_id"] = str(overrides.get("campaign_id", defaults.get("campaign_id", "blacksmith_campaign")))
			defaults["difficulty_id"] = str(overrides.get("difficulty_id", defaults.get("difficulty_id", "easy")))
		ARENA_BOT_MODE_ID:
			defaults["opponent_id"] = str(overrides.get("opponent_id", defaults.get("opponent_id", "bot")))
		SURVIVAL_MODE_ID:
			defaults["start_wave"] = maxi(1, int(overrides.get("start_wave", defaults.get("start_wave", 1))))
		BOSS_MODE_ID:
			defaults["boss_id"] = str(overrides.get("boss_id", defaults.get("boss_id", "boss_troll")))
	if overrides.has("resume_suspended_run"):
		defaults["resume_suspended_run"] = bool(overrides.get("resume_suspended_run", false))
	return defaults

static func normalize_mode_id(mode_id: StringName) -> StringName:
	if mode_id == LEGACY_ARENA_MODE_ID:
		return ARENA_BOT_MODE_ID
	return mode_id

static func normalize_mode_group_id(group_id: StringName) -> StringName:
	if group_id == &"":
		return MENU_GROUP_CAMPAIGN_ID
	return group_id

static func _get_metadata(mode_id: StringName) -> Dictionary:
	var resolved_mode_id: StringName = normalize_mode_id(mode_id)
	if MODE_METADATA.has(resolved_mode_id):
		return Dictionary(MODE_METADATA[resolved_mode_id])
	return {}
