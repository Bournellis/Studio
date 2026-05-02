class_name LoadoutUnlockResolver
extends RefCounted

const PlayerProfile = preload("res://gameplay/profile/player_profile.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")

static func is_skill_unlocked_for_builder(
	profile: PlayerProfile,
	skill_id: StringName,
	override_unlocked: bool = false
) -> bool:
	if override_unlocked:
		return true
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	return resolved_profile.is_skill_unlocked(skill_id)

static func is_potion_unlocked_for_builder(
	profile: PlayerProfile,
	potion_id: StringName,
	override_unlocked: bool = false
) -> bool:
	if override_unlocked:
		return true
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	return resolved_profile.is_potion_unlocked(potion_id)

static func build_builder_unlock_report(
	profile: PlayerProfile,
	skills: Array,
	potions: Array,
	override_unlocked: bool = false,
	required_skill_count: int = 4,
	required_potion_count: int = 2
) -> Dictionary:
	var available_skill_count: int = 0
	var available_potion_count: int = 0
	var locked_skill_ids: Array[String] = []
	var locked_potion_ids: Array[String] = []

	for skill_variant: Variant in skills:
		var skill: SkillDefinitionResource = skill_variant as SkillDefinitionResource
		if skill == null:
			continue
		if is_skill_unlocked_for_builder(profile, skill.id, override_unlocked):
			available_skill_count += 1
		else:
			locked_skill_ids.append(String(skill.id))

	for potion_variant: Variant in potions:
		var potion: PotionDefinitionResource = potion_variant as PotionDefinitionResource
		if potion == null:
			continue
		if is_potion_unlocked_for_builder(profile, potion.id, override_unlocked):
			available_potion_count += 1
		else:
			locked_potion_ids.append(String(potion.id))

	return {
		"uses_profile_unlocks": not override_unlocked,
		"required_skill_count": maxi(0, required_skill_count),
		"required_potion_count": maxi(0, required_potion_count),
		"available_skill_count": available_skill_count,
		"available_potion_count": available_potion_count,
		"missing_skill_count": maxi(0, required_skill_count - available_skill_count),
		"missing_potion_count": maxi(0, required_potion_count - available_potion_count),
		"locked_skill_ids": locked_skill_ids,
		"locked_potion_ids": locked_potion_ids,
		"has_required_pool": (
			available_skill_count >= required_skill_count
			and available_potion_count >= required_potion_count
		)
	}

static func validate_loadout_access(
	profile: PlayerProfile,
	loadout: LoadoutData,
	override_unlocked: bool = false
) -> Dictionary:
	if loadout == null:
		return {"ok": false, "message": "O kit precisa existir."}
	if override_unlocked:
		return {"ok": true, "message": "Kit liberado pelo override de desenvolvimento."}

	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	for skill_variant: Variant in loadout.skills:
		var skill: SkillDefinitionResource = skill_variant as SkillDefinitionResource
		if skill == null:
			continue
		if not resolved_profile.is_skill_unlocked(skill.id):
			return {
				"ok": false,
				"message": "A habilidade %s ainda nao foi aprendida na Campanha do Troll para uso em modos livres." % skill.display_name
			}

	for potion_variant: Variant in loadout.potions:
		var potion: PotionDefinitionResource = potion_variant as PotionDefinitionResource
		if potion == null:
			continue
		if not resolved_profile.is_potion_unlocked(potion.id):
			return {
				"ok": false,
				"message": "A pocao %s ainda nao foi aprendida na Campanha do Troll para uso em modos livres." % potion.display_name
			}

	return {"ok": true, "message": "Kit liberado para modos livres."}
