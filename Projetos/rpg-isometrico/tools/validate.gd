extends SceneTree

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const ContentLibraryScript = preload("res://autoloads/content_library.gd")
const RaceDefinitionResource = preload("res://gameplay/content/race_definition_resource.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")
const CampaignCatalogResource = preload("res://modes/campaign/campaign_catalog_resource.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const LoadoutValidator = preload("res://gameplay/loadouts/loadout_validator.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_validation()
	quit(exit_code)

func _run_validation() -> int:
	print("[validate] generating JSON-driven resources")
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[validate] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1

	print("[validate] generating bootstrap scenes")
	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[validate] %s" % str(scene_result.get("message", "Scene generation failed.")))
		return 1

	print("[validate] checking canonical loadout contract")
	var contract_result: Dictionary = _validate_contract()
	if not bool(contract_result.get("ok", false)):
		printerr("[validate] %s" % str(contract_result.get("message", "Contract validation failed.")))
		return 1

	print("[validate] running GUT")
	var gut_exit_code: int = await _run_gut()
	if gut_exit_code != 0:
		printerr("[validate] GUT failed with exit code %d." % gut_exit_code)
		return gut_exit_code

	var shared_library = root.get_node_or_null("ContentLibrary")
	if shared_library != null:
		shared_library.unload()

	print("[validate] manual smoke expectations: res://docs/canonical-product-foundation-smoke.md")
	print("[validate] campaign framework smoke: res://docs/campaign-framework-smoke.md")
	print("[validate] B0 runtime smoke: res://docs/g4-shared-mode-foundation-smoke.md")
	print("[validate] success")
	return 0

func _validate_contract() -> Dictionary:
	var library = ContentLibraryScript.new()
	library.ensure_loaded()

	var races: Array[RaceDefinitionResource] = library.get_races()
	if races.size() != 1:
		return {"ok": false, "message": "Expected 1 race, found %d." % races.size()}

	var race: RaceDefinitionResource = races[0]
	var weapons: Array[WeaponDefinitionResource] = library.get_weapons_for_race(race.id)
	if weapons.size() != 1:
		return {"ok": false, "message": "Expected 1 weapon, found %d." % weapons.size()}

	var weapon: WeaponDefinitionResource = weapons[0]
	var skills: Array[SkillDefinitionResource] = library.get_skills_for_weapon(race.id, weapon.id)
	var potions: Array[PotionDefinitionResource] = library.get_potions_for_race(race.id)
	if skills.size() != 4 or potions.size() != 2:
		return {"ok": false, "message": "Expected 4 skills and 2 potions for the first slice."}

	var loadout: LoadoutData = library.build_loadout_from_ids(
		race.id,
		weapon.id,
		PackedStringArray([
			String(skills[0].id),
			String(skills[1].id),
			String(skills[2].id),
			String(skills[3].id)
		]),
		PackedStringArray([
			String(potions[0].id),
			String(potions[1].id)
		])
	)

	var validation: Dictionary = LoadoutValidator.new().validate(loadout)
	if not bool(validation.get("ok", false)):
		return validation

	var campaign_catalog: CampaignCatalogResource = load("res://resources/generated/catalogs/campaign_catalog.tres")
	if campaign_catalog == null:
		library.free()
		return {"ok": false, "message": "Missing generated campaign catalog."}

	var campaign_route = campaign_catalog.find_route(&"blacksmith_campaign", &"easy")
	if campaign_route == null:
		library.free()
		return {"ok": false, "message": "Missing blacksmith_campaign / easy route in campaign catalog."}
	if campaign_route.stage_references.size() != 5:
		library.free()
		return {"ok": false, "message": "Expected 5 stage references for blacksmith_campaign / easy."}
	var normal_campaign_route = campaign_catalog.find_route(&"blacksmith_campaign", &"normal")
	if normal_campaign_route == null:
		library.free()
		return {"ok": false, "message": "Missing blacksmith_campaign / normal route in campaign catalog."}
	if normal_campaign_route.stage_references.size() != 5:
		library.free()
		return {"ok": false, "message": "Expected 5 stage references for blacksmith_campaign / normal."}

	for scene_path: String in [
		"res://modes/boot/boot.tscn",
		"res://modes/frontend/frontend.tscn",
		"res://modes/tutorial/tutorial.tscn",
		"res://modes/campaign/campaign.tscn",
		"res://modes/arena/arena.tscn",
		"res://modes/survival/survival.tscn",
		"res://modes/boss/boss.tscn"
	]:
		var scene: Resource = load(scene_path)
		if scene == null:
			library.free()
			return {"ok": false, "message": "Missing generated scene %s." % scene_path}

	for route in [campaign_route, normal_campaign_route]:
		for stage_reference in route.stage_references:
			var scene: Resource = load(stage_reference.scene_path)
			if scene == null:
				library.free()
				return {"ok": false, "message": "Missing generated campaign stage scene %s." % stage_reference.scene_path}

	library.free()
	return {"ok": true, "message": "Canonical first-slice contract is valid."}

func _run_gut() -> int:
	var gut_config = load("res://addons/gut/gut_config.gd").new()
	var load_result: int = int(gut_config.load_options("res://.gutconfig.json"))
	if load_result == -1:
		printerr("[validate] Failed to load res://.gutconfig.json.")
		return 1

	gut_config.options.should_exit = false
	gut_config.options.should_exit_on_success = false

	var gut = load("res://addons/gut/gut.gd").new()
	gut.name = "ValidationGut"
	root.add_child(gut)
	gut_config.apply_options(gut)
	gut.ignore_pause_before_teardown = true

	var completed: Array[bool] = [false]
	var exit_code: Array[int] = [0]
	gut.end_run.connect(func() -> void:
		exit_code[0] = 1 if gut.get_fail_count() > 0 else 0
		completed[0] = true
	)

	gut.test_scripts(gut.unit_test_name == "")
	while not completed[0]:
		await process_frame

	gut.queue_free()
	await process_frame
	return exit_code[0]
