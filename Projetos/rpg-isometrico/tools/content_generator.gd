class_name ContentGenerator
extends RefCounted

const RaceDefinitionResource = preload("res://gameplay/content/race_definition_resource.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")
const RaceCatalogResource = preload("res://gameplay/content/race_catalog_resource.gd")
const WeaponCatalogResource = preload("res://gameplay/content/weapon_catalog_resource.gd")
const SkillCatalogResource = preload("res://gameplay/content/skill_catalog_resource.gd")
const PotionCatalogResource = preload("res://gameplay/content/potion_catalog_resource.gd")
const CampaignCatalogResource = preload("res://modes/campaign/campaign_catalog_resource.gd")
const CampaignRouteDefinitionResource = preload("res://modes/campaign/campaign_route_definition_resource.gd")
const CampaignStageReferenceResource = preload("res://modes/campaign/campaign_stage_reference_resource.gd")

const RACE_DEFINITIONS_DIR: String = "res://definitions/races"
const WEAPON_DEFINITIONS_DIR: String = "res://definitions/weapons"
const SKILL_DEFINITIONS_DIR: String = "res://definitions/skills"
const POTION_DEFINITIONS_DIR: String = "res://definitions/potions"
const CAMPAIGN_DEFINITIONS_DIR: String = "res://definitions/campaigns"

const GENERATED_RACES_DIR: String = "res://resources/generated/races"
const GENERATED_WEAPONS_DIR: String = "res://resources/generated/weapons"
const GENERATED_SKILLS_DIR: String = "res://resources/generated/skills"
const GENERATED_POTIONS_DIR: String = "res://resources/generated/potions"
const GENERATED_CATALOGS_DIR: String = "res://resources/generated/catalogs"

const SKILL_KIND_BY_ID: Dictionary = {
	"projectile": SkillDefinitionResource.SkillKind.PROJECTILE,
	"self_buff": SkillDefinitionResource.SkillKind.SELF_BUFF,
	"area_burst": SkillDefinitionResource.SkillKind.AREA_BURST,
	"leap_strike": SkillDefinitionResource.SkillKind.LEAP_STRIKE
}

const POTION_KIND_BY_ID: Dictionary = {
	"heal": PotionDefinitionResource.PotionKind.HEAL,
	"barrier": PotionDefinitionResource.PotionKind.BARRIER
}

func generate_all() -> Dictionary:
	_ensure_output_dirs()

	var race_resources: Array[RaceDefinitionResource] = []
	for definition: Dictionary in _load_definitions(RACE_DEFINITIONS_DIR):
		var race: RaceDefinitionResource = RaceDefinitionResource.new()
		race.id = StringName(str(definition.get("id", "")))
		race.display_name = str(definition.get("display_name", ""))
		race.description = str(definition.get("description", ""))
		race.weapon_ids = PackedStringArray(_variant_to_string_array(definition.get("weapon_ids", [])))
		race.skill_ids = PackedStringArray(_variant_to_string_array(definition.get("skill_ids", [])))
		race.potion_ids = PackedStringArray(_variant_to_string_array(definition.get("potion_ids", [])))
		race_resources.append(race)
		var race_save_error: Error = ResourceSaver.save(race, "%s/%s.tres" % [GENERATED_RACES_DIR, String(race.id)])
		if race_save_error != OK:
			return {"ok": false, "message": "Failed to save race %s." % race.id}

	var weapon_resources: Array[WeaponDefinitionResource] = []
	for definition: Dictionary in _load_definitions(WEAPON_DEFINITIONS_DIR):
		var weapon: WeaponDefinitionResource = WeaponDefinitionResource.new()
		weapon.id = StringName(str(definition.get("id", "")))
		weapon.race_id = StringName(str(definition.get("race_id", "")))
		weapon.display_name = str(definition.get("display_name", ""))
		weapon.description = str(definition.get("description", ""))
		weapon.basic_attack_damage = float(definition.get("basic_attack_damage", 20.0))
		weapon.basic_attack_cooldown = float(definition.get("basic_attack_cooldown", 0.6))
		weapon.basic_attack_range = float(definition.get("basic_attack_range", 2.2))
		weapon.move_speed = float(definition.get("move_speed", 6.0))
		weapon.max_health = float(definition.get("max_health", 140.0))
		weapon.dash_distance = float(definition.get("dash_distance", 5.0))
		weapon.dash_cooldown = float(definition.get("dash_cooldown", 1.3))
		weapon_resources.append(weapon)
		var weapon_save_error: Error = ResourceSaver.save(weapon, "%s/%s.tres" % [GENERATED_WEAPONS_DIR, String(weapon.id)])
		if weapon_save_error != OK:
			return {"ok": false, "message": "Failed to save weapon %s." % weapon.id}

	var skill_resources: Array[SkillDefinitionResource] = []
	for definition: Dictionary in _load_definitions(SKILL_DEFINITIONS_DIR):
		var skill: SkillDefinitionResource = SkillDefinitionResource.new()
		skill.id = StringName(str(definition.get("id", "")))
		skill.race_id = StringName(str(definition.get("race_id", "")))
		skill.weapon_id = StringName(str(definition.get("weapon_id", "")))
		skill.display_name = str(definition.get("display_name", ""))
		skill.description = str(definition.get("description", ""))
		skill.kind = int(SKILL_KIND_BY_ID.get(str(definition.get("kind", "projectile")), SkillDefinitionResource.SkillKind.PROJECTILE))
		skill.cooldown = float(definition.get("cooldown", 3.0))
		skill.damage = float(definition.get("damage", 20.0))
		skill.range = float(definition.get("range", 5.0))
		skill.duration = float(definition.get("duration", 0.0))
		skill.value = float(definition.get("value", 0.0))
		skill_resources.append(skill)
		var skill_save_error: Error = ResourceSaver.save(skill, "%s/%s.tres" % [GENERATED_SKILLS_DIR, String(skill.id)])
		if skill_save_error != OK:
			return {"ok": false, "message": "Failed to save skill %s." % skill.id}

	var potion_resources: Array[PotionDefinitionResource] = []
	for definition: Dictionary in _load_definitions(POTION_DEFINITIONS_DIR):
		var potion: PotionDefinitionResource = PotionDefinitionResource.new()
		potion.id = StringName(str(definition.get("id", "")))
		potion.race_id = StringName(str(definition.get("race_id", "")))
		potion.display_name = str(definition.get("display_name", ""))
		potion.description = str(definition.get("description", ""))
		potion.kind = int(POTION_KIND_BY_ID.get(str(definition.get("kind", "heal")), PotionDefinitionResource.PotionKind.HEAL))
		potion.cooldown = float(definition.get("cooldown", 12.0))
		potion.value = float(definition.get("value", 40.0))
		potion.duration = float(definition.get("duration", 0.0))
		potion_resources.append(potion)
		var potion_save_error: Error = ResourceSaver.save(potion, "%s/%s.tres" % [GENERATED_POTIONS_DIR, String(potion.id)])
		if potion_save_error != OK:
			return {"ok": false, "message": "Failed to save potion %s." % potion.id}

	var race_catalog: RaceCatalogResource = RaceCatalogResource.new()
	race_catalog.entries = race_resources
	if ResourceSaver.save(race_catalog, "%s/race_catalog.tres" % GENERATED_CATALOGS_DIR) != OK:
		return {"ok": false, "message": "Failed to save race catalog."}

	var weapon_catalog: WeaponCatalogResource = WeaponCatalogResource.new()
	weapon_catalog.entries = weapon_resources
	if ResourceSaver.save(weapon_catalog, "%s/weapon_catalog.tres" % GENERATED_CATALOGS_DIR) != OK:
		return {"ok": false, "message": "Failed to save weapon catalog."}

	var skill_catalog: SkillCatalogResource = SkillCatalogResource.new()
	skill_catalog.entries = skill_resources
	if ResourceSaver.save(skill_catalog, "%s/skill_catalog.tres" % GENERATED_CATALOGS_DIR) != OK:
		return {"ok": false, "message": "Failed to save skill catalog."}

	var potion_catalog: PotionCatalogResource = PotionCatalogResource.new()
	potion_catalog.entries = potion_resources
	if ResourceSaver.save(potion_catalog, "%s/potion_catalog.tres" % GENERATED_CATALOGS_DIR) != OK:
		return {"ok": false, "message": "Failed to save potion catalog."}

	var campaign_routes: Array[CampaignRouteDefinitionResource] = []
	var route_keys: Dictionary = {}
	for definition: Dictionary in _load_definitions(CAMPAIGN_DEFINITIONS_DIR):
		var route_result: Dictionary = _build_campaign_route_definition(definition, route_keys)
		if not bool(route_result.get("ok", false)):
			return route_result
		campaign_routes.append(route_result.get("route"))

	var campaign_catalog: CampaignCatalogResource = CampaignCatalogResource.new()
	campaign_catalog.entries = campaign_routes
	if ResourceSaver.save(campaign_catalog, "%s/campaign_catalog.tres" % GENERATED_CATALOGS_DIR) != OK:
		return {"ok": false, "message": "Failed to save campaign catalog."}

	return {
		"ok": true,
		"message": "Generated canonical first-slice content.",
		"counts": {
			"races": race_resources.size(),
			"weapons": weapon_resources.size(),
			"skills": skill_resources.size(),
			"potions": potion_resources.size(),
			"campaign_routes": campaign_routes.size()
		}
	}

func _load_definitions(dir_path: String) -> Array[Dictionary]:
	var dir: DirAccess = DirAccess.open(dir_path)
	if dir == null:
		return []

	var file_names: Array[String] = []
	dir.list_dir_begin()
	while true:
		var entry_name: String = dir.get_next()
		if entry_name == "":
			break
		if dir.current_is_dir():
			continue
		if not entry_name.ends_with(".json"):
			continue
		file_names.append(entry_name)
	dir.list_dir_end()

	file_names.sort()

	var definitions: Array[Dictionary] = []
	for file_name: String in file_names:
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("%s/%s" % [dir_path, file_name]))
		if parsed is Dictionary:
			definitions.append(parsed)
	return definitions

func _variant_to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			result.append(str(entry))
	return result

func _build_campaign_route_definition(definition: Dictionary, route_keys: Dictionary) -> Dictionary:
	var route := CampaignRouteDefinitionResource.new()
	route.campaign_id = StringName(str(definition.get("campaign_id", "")))
	route.difficulty_id = StringName(str(definition.get("difficulty_id", "")))
	if route.campaign_id == &"" or route.difficulty_id == &"":
		return {"ok": false, "message": "Campaign route definitions require campaign_id and difficulty_id."}

	var route_key: String = _build_campaign_route_key(route.campaign_id, route.difficulty_id)
	if route_keys.has(route_key):
		return {"ok": false, "message": "Duplicate campaign route %s." % route_key}
	route_keys[route_key] = true

	route.campaign_display_name = str(definition.get("campaign_display_name", "Campanha"))
	route.difficulty_label = str(definition.get("difficulty_label", "Dificuldade local"))

	var stage_reference_definitions: Array = Array(definition.get("stage_references", []))
	if stage_reference_definitions.is_empty():
		return {"ok": false, "message": "Campaign route %s requires at least one stage reference." % route_key}

	var boss_stage_count: int = 0
	var stage_ids: Dictionary = {}
	for stage_reference_variant: Variant in stage_reference_definitions:
		var stage_result: Dictionary = _build_campaign_stage_reference(Dictionary(stage_reference_variant), route_key)
		if not bool(stage_result.get("ok", false)):
			return stage_result
		var stage_reference: CampaignStageReferenceResource = stage_result.get("stage_reference")
		if stage_ids.has(stage_reference.stage_id):
			return {
				"ok": false,
				"message": "Campaign route %s reuses stage_id %s." % [route_key, String(stage_reference.stage_id)]
			}
		stage_ids[stage_reference.stage_id] = true
		if stage_reference.is_boss_stage:
			boss_stage_count += 1
		route.stage_references.append(stage_reference)

	if boss_stage_count != 1:
		return {
			"ok": false,
			"message": "Campaign route %s must declare exactly one boss stage." % route_key
		}

	return {"ok": true, "route": route}

func _build_campaign_stage_reference(definition: Dictionary, route_key: String) -> Dictionary:
	var stage_reference := CampaignStageReferenceResource.new()
	stage_reference.stage_id = StringName(str(definition.get("stage_id", "")))
	stage_reference.scene_path = str(definition.get("scene_path", ""))
	stage_reference.is_boss_stage = bool(definition.get("is_boss_stage", false))

	if stage_reference.stage_id == &"":
		return {"ok": false, "message": "Campaign route %s contains a stage without stage_id." % route_key}
	if stage_reference.scene_path == "":
		return {
			"ok": false,
			"message": "Campaign route %s stage %s is missing scene_path." % [
				route_key,
				String(stage_reference.stage_id)
			]
		}

	return {"ok": true, "stage_reference": stage_reference}

func _build_campaign_route_key(campaign_id: StringName, difficulty_id: StringName) -> String:
	return "%s:%s" % [String(campaign_id), String(difficulty_id)]

func _ensure_output_dirs() -> void:
	for output_dir: String in [
		GENERATED_RACES_DIR,
		GENERATED_WEAPONS_DIR,
		GENERATED_SKILLS_DIR,
		GENERATED_POTIONS_DIR,
		GENERATED_CATALOGS_DIR
	]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
