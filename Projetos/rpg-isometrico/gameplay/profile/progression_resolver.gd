class_name ProgressionResolver
extends RefCounted

const PlayerProfile = preload("res://gameplay/profile/player_profile.gd")
const CampaignRewardPayload = preload("res://gameplay/profile/campaign_reward_payload.gd")

const BLACKSMITH_CAMPAIGN_ID: StringName = &"blacksmith_campaign"
const HEROIC_RACE_ID: StringName = &"heroic"
const HEROIC_WEAPON_ID: StringName = &"heroic_hammer"
const TUTORIAL_SKILL_ID: StringName = &"blacksmith_hammer_throw"
const TUTORIAL_POTION_ID: StringName = &"vital_flask"
const SECOND_SKILL_ID: StringName = &"heroic_rally"
const THIRD_SKILL_ID: StringName = &"breaker_leap"
const FOURTH_SKILL_ID: StringName = &"hammer_impact"
const BARRIER_POTION_ID: StringName = &"bastion_tonic"
const FREE_CAMPAIGN_DIFFICULTY_ID: StringName = &"free"
const SURVIVAL_MODE_ID_TEXT: String = "survival"
const BOSS_MODE_ID_TEXT: String = "boss"

const CLASSIC_CAMPAIGN_SKILL_ORDER: PackedStringArray = [
	"blacksmith_hammer_throw",
	"heroic_rally",
	"breaker_leap",
	"hammer_impact"
]

const CLASSIC_CAMPAIGN_POTION_ORDER: PackedStringArray = [
	"vital_flask",
	"bastion_tonic"
]

static func apply_mandatory_tutorial_completion(profile: PlayerProfile) -> PlayerProfile:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	resolved_profile.tutorial_completed = true
	resolved_profile.unlock_race(HEROIC_RACE_ID)
	resolved_profile.unlock_weapon(HEROIC_WEAPON_ID)
	resolved_profile.unlock_skill(TUTORIAL_SKILL_ID)
	resolved_profile.unlock_skill(SECOND_SKILL_ID)
	resolved_profile.unlock_potion(TUTORIAL_POTION_ID)
	return resolved_profile

static func apply_tutorial_skill_unlock(profile: PlayerProfile) -> PlayerProfile:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	resolved_profile.unlock_race(HEROIC_RACE_ID)
	resolved_profile.unlock_weapon(HEROIC_WEAPON_ID)
	resolved_profile.unlock_skill(TUTORIAL_SKILL_ID)
	return resolved_profile

static func apply_tutorial_potion_unlock(profile: PlayerProfile) -> PlayerProfile:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	resolved_profile.unlock_race(HEROIC_RACE_ID)
	resolved_profile.unlock_weapon(HEROIC_WEAPON_ID)
	resolved_profile.unlock_potion(TUTORIAL_POTION_ID)
	return resolved_profile

static func apply_campaign_reward_payload(
	profile: PlayerProfile,
	reward_payload: CampaignRewardPayload
) -> PlayerProfile:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	if reward_payload == null or reward_payload.is_empty():
		return resolved_profile

	if reward_payload.reward_id != "" and resolved_profile.has_applied_reward(reward_payload.reward_id):
		return resolved_profile

	if reward_payload.marks_tutorial_completed:
		resolved_profile = apply_mandatory_tutorial_completion(resolved_profile)

	for skill_id_text: String in reward_payload.permanent_skill_unlock_ids:
		resolved_profile.unlock_skill(StringName(skill_id_text))

	for potion_id_text: String in reward_payload.permanent_potion_unlock_ids:
		resolved_profile.unlock_potion(StringName(potion_id_text))

	if reward_payload.reward_id != "":
		resolved_profile.record_applied_reward(reward_payload.reward_id)
	return resolved_profile

# Legacy compatibility for suspended runs saved before F05 payload authorship moved into stage scenes.
static func get_stage_completion_reward_lines(stage_number: int) -> Array[String]:
	var reward_payload: CampaignRewardPayload = build_campaign_stage_reward_payload(stage_number, 0, 0, 0)
	return reward_payload.summary_lines.duplicate()

static func build_campaign_stage_reward_payload(
	stage_number: int,
	current_level: int,
	pending_level_increase: int = -1,
	pending_skill_points: int = -1
) -> CampaignRewardPayload:
	var reward_payload := CampaignRewardPayload.new()
	reward_payload.reward_id = "legacy:%s:%s:%02d" % [
		String(BLACKSMITH_CAMPAIGN_ID),
		String(PlayerProfile.EASY_DIFFICULTY_ID),
		maxi(0, stage_number)
	]
	reward_payload.campaign_id = BLACKSMITH_CAMPAIGN_ID
	reward_payload.difficulty_id = PlayerProfile.EASY_DIFFICULTY_ID
	reward_payload.stage_number = maxi(0, stage_number)
	reward_payload.title = "Campanha Classica concluida" if stage_number >= 5 else "Etapa %d concluida" % stage_number
	if stage_number >= 5:
		reward_payload.pending_level_increase = maxi(0, pending_level_increase)
		reward_payload.pending_skill_points = maxi(0, pending_skill_points)
	else:
		reward_payload.pending_level_increase = maxi(0, 1 if pending_level_increase < 0 else pending_level_increase)
		reward_payload.pending_skill_points = maxi(0, 1 if pending_skill_points < 0 else pending_skill_points)
	if reward_payload.pending_level_increase > 0 and current_level > 0:
		reward_payload.next_level = current_level + reward_payload.pending_level_increase
	match stage_number:
		1:
			reward_payload.summary_lines = [
				"Survival abriu como desafio extra de resistencia.",
				"Brado dos Imortais agora faz parte do kit permanente aprendido na campanha."
			]
			reward_payload.permanent_skill_unlock_ids = [String(SECOND_SKILL_ID)]
			reward_payload.menu_unlock_mode_ids = [SURVIVAL_MODE_ID_TEXT]
			reward_payload.marks_tutorial_completed = true
		2:
			reward_payload.summary_lines = [
				"Salto Quebrador agora faz parte do kit permanente aprendido na campanha."
			]
			reward_payload.permanent_skill_unlock_ids = [String(THIRD_SKILL_ID)]
		3:
			reward_payload.summary_lines = [
				"Impacto do Martelo agora faz parte do kit permanente aprendido na campanha."
			]
			reward_payload.permanent_skill_unlock_ids = [String(FOURTH_SKILL_ID)]
		4:
			reward_payload.summary_lines = [
				"Tonico de Baluarte agora faz parte do kit permanente aprendido na campanha."
			]
			reward_payload.permanent_potion_unlock_ids = [String(BARRIER_POTION_ID)]
		5:
			reward_payload.summary_lines = [
				"Boss abriu como desafio extra de maestria depois da jornada principal."
			]
			reward_payload.menu_unlock_mode_ids = [BOSS_MODE_ID_TEXT]
	return reward_payload
static func get_classic_campaign_skill_order() -> PackedStringArray:
	return CLASSIC_CAMPAIGN_SKILL_ORDER

static func get_classic_campaign_potion_order() -> PackedStringArray:
	return CLASSIC_CAMPAIGN_POTION_ORDER

static func build_campaign_run_key(campaign_id: StringName, difficulty_id: StringName) -> StringName:
	var resolved_campaign_id: String = String(campaign_id if campaign_id != &"" else BLACKSMITH_CAMPAIGN_ID)
	var resolved_difficulty_id: String = String(
		difficulty_id if difficulty_id != &"" else PlayerProfile.EASY_DIFFICULTY_ID
	)
	return StringName("campaign:%s:%s" % [resolved_campaign_id, resolved_difficulty_id])

static func build_legacy_campaign_run_key(campaign_id: StringName) -> StringName:
	var resolved_campaign_id: String = String(campaign_id if campaign_id != &"" else BLACKSMITH_CAMPAIGN_ID)
	return StringName("campaign:%s" % resolved_campaign_id)

static func build_survival_run_key() -> StringName:
	return &"survival"

static func build_boss_run_key(boss_id: StringName = &"") -> StringName:
	var resolved_boss_id: String = String(boss_id if boss_id != &"" else &"boss_troll")
	return StringName("boss:%s" % resolved_boss_id)

static func apply_campaign_completion(
	profile: PlayerProfile,
	campaign_id: StringName,
	difficulty_id: StringName
) -> PlayerProfile:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	var resolved_campaign_id: StringName = campaign_id if campaign_id != &"" else BLACKSMITH_CAMPAIGN_ID
	var resolved_difficulty_id: StringName = (
		difficulty_id if difficulty_id != &"" else PlayerProfile.EASY_DIFFICULTY_ID
	)
	resolved_profile.record_campaign_completion(resolved_campaign_id, resolved_difficulty_id)
	return resolved_profile

static func has_completed_blacksmith_campaign(profile: PlayerProfile) -> bool:
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	return resolved_profile.has_completed_campaign(BLACKSMITH_CAMPAIGN_ID, PlayerProfile.EASY_DIFFICULTY_ID)
