class_name ModeAvailabilityResolver
extends RefCounted

const PlayerProfile = preload("res://gameplay/profile/player_profile.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

static func get_local_mode_state(
	profile: PlayerProfile,
	mode_id: StringName,
	unlock_all_for_dev: bool = false
) -> Dictionary:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	var resolved_mode_id: StringName = LocalModeCatalog.normalize_mode_id(mode_id)
	if unlock_all_for_dev and resolved_mode_id != LocalModeCatalog.ARENA_PVP_MODE_ID:
		return {
			"unlocked": true,
			"reason": "",
			"tag": "Override de desenvolvimento"
		}

	match resolved_mode_id:
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			return {
				"unlocked": true,
				"reason": "",
				"tag": "Campanha principal"
			}
		LocalModeCatalog.SURVIVAL_MODE_ID:
			if resolved_profile.tutorial_completed:
				return {
					"unlocked": true,
					"reason": "",
					"tag": "Prova de resistencia"
				}
			return {
				"unlocked": false,
				"reason": "Conclua a Missao 1/tutorial da Campanha do Troll para liberar Survival.",
				"tag": "Extra bloqueado"
			}
		LocalModeCatalog.BOSS_MODE_ID:
			if ProgressionResolver.has_completed_blacksmith_campaign(resolved_profile):
				return {
					"unlocked": true,
					"reason": "",
					"tag": "Pratica de maestria"
				}
			return {
				"unlocked": false,
				"reason": "Conclua a Campanha do Troll em Classic - Easy para abrir Boss como extra de maestria.",
				"tag": "Extra bloqueado"
			}
		LocalModeCatalog.ARENA_BOT_MODE_ID:
			return {
				"unlocked": true,
				"reason": "",
				"tag": "Treino de kit"
			}
		LocalModeCatalog.ARENA_PVP_MODE_ID:
			return {
				"unlocked": false,
				"reason": "Duelo Privado / Arena PvP e experimental e nao faz parte da navegacao publica desta fase.",
				"tag": "Experimental"
			}
		_:
			return {
				"unlocked": false,
				"reason": "Modo nao suportado na surface atual.",
				"tag": "Indisponivel"
			}

static func get_campaign_route_state(
	profile: PlayerProfile,
	campaign_id: StringName,
	difficulty_id: StringName,
	unlock_all_for_dev: bool = false
) -> Dictionary:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	var resolved_campaign_id: StringName = (
		campaign_id if campaign_id != &"" else ProgressionResolver.BLACKSMITH_CAMPAIGN_ID
	)
	var resolved_difficulty_id: StringName = (
		difficulty_id if difficulty_id != &"" else PlayerProfile.EASY_DIFFICULTY_ID
	)
	if unlock_all_for_dev:
		return {
			"unlocked": true,
			"reason": "",
			"tag": "Override de desenvolvimento"
		}

	match resolved_difficulty_id:
		PlayerProfile.EASY_DIFFICULTY_ID:
			return {
				"unlocked": true,
				"reason": "",
				"tag": "Entrada principal"
			}
		&"normal":
			if resolved_profile.has_completed_campaign(resolved_campaign_id, PlayerProfile.EASY_DIFFICULTY_ID):
				return {
					"unlocked": true,
					"reason": "",
					"tag": "Liberado apos concluir Easy"
				}
			return {
				"unlocked": false,
				"reason": "Conclua a Campanha do Troll em Easy para liberar a rota Normal.",
				"tag": "Requer Easy"
			}
		ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
			if resolved_profile.has_completed_campaign(resolved_campaign_id, PlayerProfile.EASY_DIFFICULTY_ID):
				return {
					"unlocked": true,
					"reason": "",
					"tag": "Replay livre"
				}
			return {
				"unlocked": false,
				"reason": "Conclua a Campanha do Troll em Classic - Easy para liberar Campanha Livre.",
				"tag": "Requer Easy"
			}
		_:
			return {
				"unlocked": false,
				"reason": "Dificuldade de campanha indisponivel nesta base.",
				"tag": "Indisponivel"
			}

static func get_first_available_local_mode_id(
	profile: PlayerProfile,
	unlock_all_for_dev: bool = false
) -> StringName:
	for mode_id_text: String in LocalModeCatalog.get_public_menu_mode_ids():
		var mode_id: StringName = StringName(mode_id_text)
		var mode_state: Dictionary = get_local_mode_state(profile, mode_id, unlock_all_for_dev)
		if bool(mode_state.get("unlocked", false)):
			return mode_id
	return &""

static func get_frontend_banner(
	profile: PlayerProfile,
	unlock_all_for_dev: bool = false
) -> String:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	if unlock_all_for_dev:
		return "Override de desenvolvimento ativo: Campanha e extras locais ficam liberados para teste rapido. Duelo Privado segue fora da navegacao publica."
	if ProgressionResolver.has_completed_blacksmith_campaign(resolved_profile):
		return "Jornada principal concluida: Campanha do Troll segue disponivel, com Survival, Boss e Arena Bot como extras de resistencia, maestria e treino de kit."
	if resolved_profile.tutorial_completed:
		return "Campanha em andamento: Survival e Arena Bot estao liberados como extras de resistencia e treino; Boss segue bloqueado ate fechar a Campanha do Troll."
	return "Comece pela Campanha do Troll. Arena Bot fica como treino de kit; Survival abre apos a Missao 1 e Boss so depois da campanha."
