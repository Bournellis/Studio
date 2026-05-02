class_name LoadoutValidator
extends RefCounted

const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")

func validate(loadout: LoadoutData) -> Dictionary:
	if loadout == null:
		return {"ok": false, "message": "O kit precisa existir."}

	if loadout.race == null:
		return {"ok": false, "message": "Selecione uma raca."}

	if loadout.weapon == null:
		return {"ok": false, "message": "Selecione uma arma."}

	if loadout.weapon.race_id != loadout.race.id:
		return {"ok": false, "message": "A arma precisa pertencer a raca selecionada."}

	if loadout.skills.size() != 4:
		return {"ok": false, "message": "Selecione exatamente 4 habilidades para fechar o kit livre."}

	var seen_skills: Dictionary[StringName, bool] = {}
	for skill: SkillDefinitionResource in loadout.skills:
		if skill == null:
			return {"ok": false, "message": "Todas as habilidades precisam estar definidas."}
		if skill.race_id != loadout.race.id:
			return {"ok": false, "message": "A habilidade %s nao pertence a raca selecionada." % skill.display_name}
		if skill.weapon_id != &"" and skill.weapon_id != loadout.weapon.id:
			return {"ok": false, "message": "A habilidade %s nao combina com a arma selecionada." % skill.display_name}
		if seen_skills.has(skill.id):
			return {"ok": false, "message": "As 4 habilidades precisam ser diferentes."}
		seen_skills[skill.id] = true

	if loadout.potions.size() != 2:
		return {"ok": false, "message": "Selecione exatamente 2 pocoes para fechar o kit livre."}

	var seen_potions: Dictionary[StringName, bool] = {}
	for potion: PotionDefinitionResource in loadout.potions:
		if potion == null:
			return {"ok": false, "message": "As pocoes precisam estar definidas."}
		if potion.race_id != &"" and potion.race_id != loadout.race.id:
			return {"ok": false, "message": "A pocao %s nao pertence a raca selecionada." % potion.display_name}
		if seen_potions.has(potion.id):
			return {"ok": false, "message": "As 2 pocoes precisam ser diferentes."}
		seen_potions[potion.id] = true

	return {"ok": true, "message": "Kit valido."}
