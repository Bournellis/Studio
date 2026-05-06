class_name SceneGenerator
extends RefCounted

const FRONTEND_SCENE_PATH: String = "res://modes/frontend/frontend.tscn"
const BOOT_SCENE_PATH: String = "res://modes/boot/boot.tscn"
const TUTORIAL_SCENE_PATH: String = "res://modes/tutorial/tutorial.tscn"
const CAMPAIGN_SCENE_PATH: String = "res://modes/campaign/campaign.tscn"
const CAMPAIGN_STAGE_DIR_PATH: String = "res://modes/campaign/stages"
const ARENA_SCENE_PATH: String = "res://modes/arena/arena.tscn"
const SURVIVAL_SCENE_PATH: String = "res://modes/survival/survival.tscn"
const BOSS_SCENE_PATH: String = "res://modes/boss/boss.tscn"

const FRONTEND_SCRIPT_PATH: String = "res://modes/frontend/frontend_root.gd"
const BOOT_SCRIPT_PATH: String = "res://modes/boot/boot_root.gd"
const TUTORIAL_SCRIPT_PATH: String = "res://modes/tutorial/tutorial_root.gd"
const CAMPAIGN_SCRIPT_PATH: String = "res://modes/campaign/campaign_root.gd"
const CAMPAIGN_STAGE_SCRIPT_PATH: String = "res://modes/campaign/campaign_stage_scene.gd"
const ARENA_SCRIPT_PATH: String = "res://modes/arena/arena_root.gd"
const SURVIVAL_SCRIPT_PATH: String = "res://modes/survival/survival_root.gd"
const BOSS_SCRIPT_PATH: String = "res://modes/boss/boss_root.gd"

func generate_all() -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://modes/boot"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://modes/frontend"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://modes/tutorial"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://modes/campaign"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAMPAIGN_STAGE_DIR_PATH))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://modes/arena"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://modes/survival"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://modes/boss"))

	if not ResourceLoader.exists(BOOT_SCENE_PATH):
		var boot_result: Error = _save_scene(Control.new(), load(BOOT_SCRIPT_PATH), BOOT_SCENE_PATH)
		if boot_result != OK:
			return {"ok": false, "message": "Failed to save boot scene."}

	if not ResourceLoader.exists(FRONTEND_SCENE_PATH):
		var frontend_result: Error = _save_scene(Control.new(), load(FRONTEND_SCRIPT_PATH), FRONTEND_SCENE_PATH)
		if frontend_result != OK:
			return {"ok": false, "message": "Failed to save frontend scene."}

	if not ResourceLoader.exists(TUTORIAL_SCENE_PATH):
		var tutorial_result: Error = _save_scene(Node3D.new(), load(TUTORIAL_SCRIPT_PATH), TUTORIAL_SCENE_PATH)
		if tutorial_result != OK:
			return {"ok": false, "message": "Failed to save tutorial scene."}

	if not ResourceLoader.exists(CAMPAIGN_SCENE_PATH):
		var campaign_result: Error = _save_scene(Node3D.new(), load(CAMPAIGN_SCRIPT_PATH), CAMPAIGN_SCENE_PATH)
		if campaign_result != OK:
			return {"ok": false, "message": "Failed to save campaign scene."}

	var campaign_stage_result: Dictionary = _generate_campaign_stage_scenes()
	if not bool(campaign_stage_result.get("ok", false)):
		return campaign_stage_result

	if not ResourceLoader.exists(ARENA_SCENE_PATH):
		var arena_result: Error = _save_scene(Node3D.new(), load(ARENA_SCRIPT_PATH), ARENA_SCENE_PATH)
		if arena_result != OK:
			return {"ok": false, "message": "Failed to save arena scene."}

	if not ResourceLoader.exists(SURVIVAL_SCENE_PATH):
		var survival_result: Error = _save_scene(Node3D.new(), load(SURVIVAL_SCRIPT_PATH), SURVIVAL_SCENE_PATH)
		if survival_result != OK:
			return {"ok": false, "message": "Failed to save survival scene."}

	if not ResourceLoader.exists(BOSS_SCENE_PATH):
		var boss_result: Error = _save_scene(Node3D.new(), load(BOSS_SCRIPT_PATH), BOSS_SCENE_PATH)
		if boss_result != OK:
			return {"ok": false, "message": "Failed to save boss scene."}

	return {"ok": true, "message": "Main scenes already exist or were scaffolded without overwrite."}

func _save_scene(root_node: Node, script_resource: Script, save_path: String) -> Error:
	root_node.name = save_path.get_file().get_basename().capitalize()
	root_node.set_script(script_resource)
	var packed_scene: PackedScene = PackedScene.new()
	var pack_error: Error = packed_scene.pack(root_node)
	root_node.free()
	if pack_error != OK:
		return pack_error
	return ResourceSaver.save(packed_scene, save_path)

func _generate_campaign_stage_scenes() -> Dictionary:
	var stage_script: Script = load(CAMPAIGN_STAGE_SCRIPT_PATH)
	if stage_script == null:
		return {"ok": false, "message": "Failed to load campaign stage scene script."}

	for stage_spec: Dictionary in _build_campaign_stage_specs():
		var stage_node: Node3D = Node3D.new()
		stage_node.name = str(stage_spec.get("scene_name", "CampaignStage"))
		stage_node.set_script(stage_script)
		for property_key: Variant in stage_spec.keys():
			var key: String = str(property_key)
			if key == "scene_name" or key == "scene_path":
				continue
			if key == "prop_specs":
				stage_node.set("prop_specs_json", var_to_str(stage_spec[property_key]))
				continue
			if key == "enemy_specs":
				stage_node.set("enemy_specs_json", var_to_str(stage_spec[property_key]))
				continue
			stage_node.set(key, stage_spec[property_key])

		var save_error: Error = _save_packed_scene(stage_node, str(stage_spec.get("scene_path", "")))
		if save_error != OK:
			return {
				"ok": false,
				"message": "Failed to save campaign stage scene %s." % str(stage_spec.get("scene_path", ""))
			}
	return {"ok": true, "message": "Campaign stage scenes refreshed."}

func _save_packed_scene(root_node: Node, save_path: String) -> Error:
	var packed_scene: PackedScene = PackedScene.new()
	var pack_error: Error = packed_scene.pack(root_node)
	root_node.free()
	if pack_error != OK:
		return pack_error
	return ResourceSaver.save(packed_scene, save_path)

func _build_campaign_stage_specs() -> Array[Dictionary]:
	var stage_specs: Array[Dictionary] = _build_easy_campaign_stage_specs()
	stage_specs.append_array(_build_normal_campaign_stage_specs())
	return stage_specs

func _build_easy_campaign_stage_specs() -> Array[Dictionary]:
	return [
		{
			"scene_name": "CampaignMission01",
			"scene_path": "%s/campaign_mission_01.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 1,
			"stage_id": "mission_01",
			"display_name": "Missao 1 - Tutorial",
			"objective_text": "Defenda a entrada da forja e aprenda os primeiros recursos do kit dos Imortais.",
			"reward_title": "Missao 1 defendida",
			"reward_summary_lines": PackedStringArray([
				"Survival abriu como desafio extra de resistencia.",
				"Brado dos Imortais agora faz parte do kit permanente aprendido na campanha."
			]),
			"reward_permanent_skill_unlock_ids": PackedStringArray(["heroic_rally"]),
			"reward_menu_unlock_mode_ids": PackedStringArray(["survival"]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"reward_marks_tutorial_completed": true,
			"player_spawn_position": Vector3(-6.0, 1.05, 0.0),
			"camera_offset": Vector3(7.8, 16.4, 7.8),
			"camera_size": 12.4,
			"floor_size": Vector3(30.0, 1.0, 24.0),
			"floor_color": Color(0.22, 0.18, 0.14, 1.0),
			"floor_emission": Color(0.08, 0.05, 0.03, 1.0),
			"wall_color": Color(0.28, 0.24, 0.2, 1.0),
			"wall_emission": Color(0.09, 0.05, 0.04, 1.0),
			"prop_specs": [
				{
					"name": "ForgeAnvil",
					"position": Vector3(5.4, 0.9, 0.0),
					"size": Vector3(2.8, 1.8, 2.0),
					"albedo": Color(0.34, 0.32, 0.3, 1.0),
					"emission": Color(0.12, 0.08, 0.06, 1.0)
				},
				{
					"name": "ForgeBench",
					"position": Vector3(7.2, 0.75, -4.0),
					"size": Vector3(2.4, 1.5, 1.2),
					"albedo": Color(0.3, 0.24, 0.2, 1.0),
					"emission": Color(0.1, 0.06, 0.04, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(2.8, 1.05, -2.0),
					"config": {
						"max_health": 34.0,
						"attack_damage": 8.0,
						"move_speed": 2.8,
						"attack_cooldown": 1.35,
						"attack_windup": 0.64,
						"attack_recovery": 0.48,
						"body_scale": 1.0
					}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(5.2, 1.05, 2.4),
					"config": {
						"max_health": 46.0,
						"attack_damage": 10.0,
						"move_speed": 3.0,
						"attack_cooldown": 1.24,
						"attack_windup": 0.6,
						"attack_recovery": 0.42,
						"body_scale": 1.08
					}
				}
			]
		},
		{
			"scene_name": "CampaignMission02",
			"scene_path": "%s/campaign_mission_02.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 2,
			"stage_id": "mission_02",
			"display_name": "Mapa 2 - Corredor da Brasa",
			"objective_text": "Segure o corredor de brasa enquanto os trolls tentam cercar a forja.",
			"reward_title": "Corredor da Brasa seguro",
			"reward_summary_lines": PackedStringArray([
				"Salto Quebrador agora faz parte do kit permanente aprendido na campanha."
			]),
			"reward_permanent_skill_unlock_ids": PackedStringArray(["breaker_leap"]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"player_spawn_position": Vector3(0.0, 1.05, -8.0),
			"floor_size": Vector3(36.0, 1.0, 30.0),
			"floor_color": Color(0.18, 0.16, 0.14, 1.0),
			"floor_emission": Color(0.11, 0.05, 0.03, 1.0),
			"wall_color": Color(0.26, 0.22, 0.2, 1.0),
			"wall_emission": Color(0.12, 0.05, 0.04, 1.0),
			"prop_specs": [
				{
					"name": "BrazierLeft",
					"position": Vector3(-7.0, 0.85, -0.8),
					"size": Vector3(1.8, 1.7, 1.8),
					"albedo": Color(0.32, 0.28, 0.24, 1.0),
					"emission": Color(0.22, 0.08, 0.04, 1.0)
				},
				{
					"name": "BrazierRight",
					"position": Vector3(7.0, 0.85, 0.8),
					"size": Vector3(1.8, 1.7, 1.8),
					"albedo": Color(0.32, 0.28, 0.24, 1.0),
					"emission": Color(0.22, 0.08, 0.04, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(-6.2, 1.05, 2.2),
					"config": {"max_health": 60.0, "attack_damage": 10.0, "move_speed": 3.0, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(0.0, 1.05, 4.4),
					"config": {"max_health": 62.0, "attack_damage": 10.5, "move_speed": 3.0, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(6.0, 1.05, 1.9),
					"config": {"max_health": 58.0, "attack_damage": 10.2, "move_speed": 3.05, "orbit_sign": 1}
				}
			]
		},
		{
			"scene_name": "CampaignMission03",
			"scene_path": "%s/campaign_mission_03.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 3,
			"stage_id": "mission_03",
			"display_name": "Mapa 3 - Patio das Bigornas",
			"objective_text": "Limpe o patio das bigornas antes que os trolls tomem os acessos laterais.",
			"reward_title": "Patio das Bigornas recuperado",
			"reward_summary_lines": PackedStringArray([
				"Impacto do Martelo agora faz parte do kit permanente aprendido na campanha."
			]),
			"reward_permanent_skill_unlock_ids": PackedStringArray(["hammer_impact"]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"player_spawn_position": Vector3(0.0, 1.05, -9.0),
			"floor_size": Vector3(40.0, 1.0, 34.0),
			"floor_color": Color(0.16, 0.17, 0.18, 1.0),
			"floor_emission": Color(0.08, 0.05, 0.04, 1.0),
			"wall_color": Color(0.24, 0.24, 0.25, 1.0),
			"wall_emission": Color(0.08, 0.05, 0.05, 1.0),
			"prop_specs": [
				{
					"name": "AnvilClusterA",
					"position": Vector3(-6.0, 0.8, -1.5),
					"size": Vector3(2.6, 1.6, 2.0),
					"albedo": Color(0.34, 0.34, 0.36, 1.0),
					"emission": Color(0.1, 0.06, 0.05, 1.0)
				},
				{
					"name": "AnvilClusterB",
					"position": Vector3(5.8, 0.8, 1.6),
					"size": Vector3(2.6, 1.6, 2.0),
					"albedo": Color(0.34, 0.34, 0.36, 1.0),
					"emission": Color(0.1, 0.06, 0.05, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(-8.0, 1.05, 3.8),
					"config": {"max_health": 72.0, "attack_damage": 11.2, "move_speed": 3.1, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(-2.0, 1.05, 6.4),
					"config": {"max_health": 74.0, "attack_damage": 11.5, "move_speed": 3.08, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(4.2, 1.05, 6.8),
					"config": {"max_health": 76.0, "attack_damage": 11.8, "move_speed": 3.1, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(8.4, 1.05, 3.6),
					"config": {"max_health": 80.0, "attack_damage": 12.4, "move_speed": 3.15, "orbit_sign": -1, "body_scale": 1.2}
				}
			]
		},
		{
			"scene_name": "CampaignMission04",
			"scene_path": "%s/campaign_mission_04.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 4,
			"stage_id": "mission_04",
			"display_name": "Mapa 4 - Muralha Interna",
			"objective_text": "Proteja a muralha interna e sobreviva a ultima investida antes do chefe.",
			"reward_title": "Muralha Interna protegida",
			"reward_summary_lines": PackedStringArray([
				"Tonico de Baluarte agora faz parte do kit permanente aprendido na campanha."
			]),
			"reward_permanent_potion_unlock_ids": PackedStringArray(["bastion_tonic"]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"player_spawn_position": Vector3(0.0, 1.05, -9.4),
			"floor_size": Vector3(42.0, 1.0, 36.0),
			"floor_color": Color(0.15, 0.14, 0.16, 1.0),
			"floor_emission": Color(0.1, 0.04, 0.05, 1.0),
			"wall_color": Color(0.26, 0.22, 0.24, 1.0),
			"wall_emission": Color(0.1, 0.04, 0.05, 1.0),
			"prop_specs": [
				{
					"name": "GateLeft",
					"position": Vector3(-8.8, 1.1, 7.2),
					"size": Vector3(2.4, 2.2, 2.0),
					"albedo": Color(0.3, 0.26, 0.24, 1.0),
					"emission": Color(0.12, 0.05, 0.05, 1.0)
				},
				{
					"name": "GateRight",
					"position": Vector3(8.8, 1.1, 7.2),
					"size": Vector3(2.4, 2.2, 2.0),
					"albedo": Color(0.3, 0.26, 0.24, 1.0),
					"emission": Color(0.12, 0.05, 0.05, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(-8.2, 1.05, 2.2),
					"config": {"max_health": 86.0, "attack_damage": 12.5, "move_speed": 3.2, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(-2.6, 1.05, 6.8),
					"config": {"max_health": 88.0, "attack_damage": 12.8, "move_speed": 3.2, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(2.6, 1.05, 6.8),
					"config": {"max_health": 90.0, "attack_damage": 13.1, "move_speed": 3.2, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(8.2, 1.05, 2.4),
					"config": {"max_health": 96.0, "attack_damage": 13.8, "move_speed": 3.22, "orbit_sign": -1, "body_scale": 1.26}
				}
			]
		},
		{
			"scene_name": "CampaignMission05",
			"scene_path": "%s/campaign_mission_05.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 5,
			"stage_id": "mission_05",
			"display_name": "Mapa 5 - Chefe",
			"objective_text": "Derrote o Boss Troll para concluir a Campanha do Troll.",
			"is_boss_stage": true,
			"reward_title": "Campanha Classica concluida",
			"reward_summary_lines": PackedStringArray([
				"Boss abriu como desafio extra de maestria depois da jornada principal."
			]),
			"reward_menu_unlock_mode_ids": PackedStringArray(["boss"]),
			"player_spawn_position": Vector3(0.0, 1.05, 9.8),
			"floor_size": Vector3(38.0, 1.0, 38.0),
			"floor_color": Color(0.2, 0.18, 0.19, 1.0),
			"floor_emission": Color(0.14, 0.08, 0.07, 1.0),
			"wall_color": Color(0.3, 0.26, 0.26, 1.0),
			"wall_emission": Color(0.12, 0.08, 0.08, 1.0),
			"prop_specs": [
				{
					"name": "BossTorchWest",
					"position": Vector3(-10.0, 0.9, 0.0),
					"size": Vector3(1.2, 1.8, 1.2),
					"albedo": Color(0.36, 0.3, 0.28, 1.0),
					"emission": Color(0.24, 0.1, 0.06, 1.0)
				},
				{
					"name": "BossTorchEast",
					"position": Vector3(10.0, 0.9, 0.0),
					"size": Vector3(1.2, 1.8, 1.2),
					"albedo": Color(0.36, 0.3, 0.28, 1.0),
					"emission": Color(0.24, 0.1, 0.06, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "boss_troll",
					"position": Vector3(0.0, 1.05, 0.0),
					"boss_id": "boss_troll"
				}
			]
		}
	]

func _build_normal_campaign_stage_specs() -> Array[Dictionary]:
	return [
		{
			"scene_name": "CampaignMission01Normal",
			"scene_path": "%s/campaign_mission_01_normal.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 1,
			"stage_id": "mission_01",
			"display_name": "Mapa 1 - Entrada Aquecida",
			"objective_text": "Segure a entrada aquecida da forja enquanto a rota Normal traz a primeira investida completa.",
			"reward_title": "Entrada Aquecida dominada",
			"reward_summary_lines": PackedStringArray([
				"A rota Normal segue para o proximo setor da forja sem novas recompensas permanentes."
			]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"player_spawn_position": Vector3(-5.0, 1.05, -1.2),
			"camera_offset": Vector3(8.2, 17.2, 8.2),
			"camera_size": 13.2,
			"floor_size": Vector3(34.0, 1.0, 28.0),
			"floor_color": Color(0.2, 0.17, 0.15, 1.0),
			"floor_emission": Color(0.12, 0.06, 0.04, 1.0),
			"wall_color": Color(0.3, 0.25, 0.22, 1.0),
			"wall_emission": Color(0.11, 0.06, 0.05, 1.0),
			"prop_specs": [
				{
					"name": "NormalForgeRack",
					"position": Vector3(6.4, 0.9, -3.6),
					"size": Vector3(2.6, 1.8, 1.4),
					"albedo": Color(0.32, 0.27, 0.24, 1.0),
					"emission": Color(0.14, 0.08, 0.05, 1.0)
				},
				{
					"name": "NormalCoalCrate",
					"position": Vector3(5.8, 0.75, 3.4),
					"size": Vector3(2.2, 1.5, 1.8),
					"albedo": Color(0.26, 0.22, 0.2, 1.0),
					"emission": Color(0.1, 0.05, 0.04, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(2.2, 1.05, -4.4),
					"config": {"max_health": 52.0, "attack_damage": 10.5, "move_speed": 3.05, "attack_cooldown": 1.24, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(4.8, 1.05, 0.4),
					"config": {"max_health": 56.0, "attack_damage": 11.0, "move_speed": 3.1, "attack_cooldown": 1.2, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(1.6, 1.05, 4.2),
					"config": {"max_health": 60.0, "attack_damage": 11.4, "move_speed": 3.14, "attack_cooldown": 1.16, "orbit_sign": -1, "body_scale": 1.08}
				}
			]
		},
		{
			"scene_name": "CampaignMission02Normal",
			"scene_path": "%s/campaign_mission_02_normal.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 2,
			"stage_id": "mission_02",
			"display_name": "Mapa 2 - Esteira de Escoria",
			"objective_text": "Atravesse a esteira de escoria enquanto os trolls chegam por dois corredores laterais.",
			"reward_title": "Esteira de Escoria atravessada",
			"reward_summary_lines": PackedStringArray([
				"A rota Normal aumenta a pressao sem abrir novas recompensas permanentes."
			]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"player_spawn_position": Vector3(0.0, 1.05, -9.2),
			"floor_size": Vector3(38.0, 1.0, 32.0),
			"floor_color": Color(0.18, 0.16, 0.17, 1.0),
			"floor_emission": Color(0.12, 0.05, 0.05, 1.0),
			"wall_color": Color(0.27, 0.24, 0.25, 1.0),
			"wall_emission": Color(0.11, 0.05, 0.05, 1.0),
			"prop_specs": [
				{
					"name": "SlagChannelWest",
					"position": Vector3(-7.4, 0.72, 1.2),
					"size": Vector3(2.2, 1.45, 4.8),
					"albedo": Color(0.3, 0.25, 0.24, 1.0),
					"emission": Color(0.16, 0.08, 0.05, 1.0)
				},
				{
					"name": "SlagChannelEast",
					"position": Vector3(7.4, 0.72, -1.2),
					"size": Vector3(2.2, 1.45, 4.8),
					"albedo": Color(0.3, 0.25, 0.24, 1.0),
					"emission": Color(0.16, 0.08, 0.05, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(-7.2, 1.05, 4.0),
					"config": {"max_health": 68.0, "attack_damage": 11.6, "move_speed": 3.14, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(-2.0, 1.05, 6.0),
					"config": {"max_health": 72.0, "attack_damage": 12.0, "move_speed": 3.16, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(3.0, 1.05, 5.8),
					"config": {"max_health": 74.0, "attack_damage": 12.4, "move_speed": 3.18, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(7.0, 1.05, 2.2),
					"config": {"max_health": 78.0, "attack_damage": 12.8, "move_speed": 3.2, "orbit_sign": -1, "body_scale": 1.12}
				}
			]
		},
		{
			"scene_name": "CampaignMission03Normal",
			"scene_path": "%s/campaign_mission_03_normal.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 3,
			"stage_id": "mission_03",
			"display_name": "Mapa 3 - Cruzamento das Tenazes",
			"objective_text": "Segure o cruzamento das tenazes antes que os trolls fechem o arco central da forja.",
			"reward_title": "Cruzamento das Tenazes seguro",
			"reward_summary_lines": PackedStringArray([
				"A reta final da rota Normal ja esta aberta."
			]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"player_spawn_position": Vector3(0.0, 1.05, -10.2),
			"floor_size": Vector3(42.0, 1.0, 36.0),
			"floor_color": Color(0.16, 0.16, 0.18, 1.0),
			"floor_emission": Color(0.1, 0.05, 0.06, 1.0),
			"wall_color": Color(0.24, 0.23, 0.26, 1.0),
			"wall_emission": Color(0.09, 0.05, 0.06, 1.0),
			"prop_specs": [
				{
					"name": "ClampBlockWest",
					"position": Vector3(-8.4, 0.8, -0.4),
					"size": Vector3(2.8, 1.6, 2.2),
					"albedo": Color(0.33, 0.33, 0.35, 1.0),
					"emission": Color(0.11, 0.07, 0.06, 1.0)
				},
				{
					"name": "ClampBlockEast",
					"position": Vector3(8.4, 0.8, 0.6),
					"size": Vector3(2.8, 1.6, 2.2),
					"albedo": Color(0.33, 0.33, 0.35, 1.0),
					"emission": Color(0.11, 0.07, 0.06, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(-9.0, 1.05, 4.2),
					"config": {"max_health": 88.0, "attack_damage": 13.2, "move_speed": 3.2, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(-4.0, 1.05, 7.0),
					"config": {"max_health": 92.0, "attack_damage": 13.6, "move_speed": 3.22, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(0.0, 1.05, 8.0),
					"config": {"max_health": 96.0, "attack_damage": 14.0, "move_speed": 3.24, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(4.0, 1.05, 7.0),
					"config": {"max_health": 98.0, "attack_damage": 14.3, "move_speed": 3.24, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(9.2, 1.05, 4.0),
					"config": {"max_health": 104.0, "attack_damage": 14.8, "move_speed": 3.26, "orbit_sign": 1, "body_scale": 1.22}
				}
			]
		},
		{
			"scene_name": "CampaignMission04Normal",
			"scene_path": "%s/campaign_mission_04_normal.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 4,
			"stage_id": "mission_04",
			"display_name": "Mapa 4 - Fossos da Fundicao",
			"objective_text": "Sobreviva aos fossos da fundicao antes de abrir o ultimo acesso ao chefe.",
			"reward_title": "Fossos da Fundicao vencidos",
			"reward_summary_lines": PackedStringArray([
				"O chefe aguarda alem da muralha final da rota Normal."
			]),
			"reward_pending_level_increase": 1,
			"reward_pending_skill_points": 1,
			"player_spawn_position": Vector3(0.0, 1.05, -10.8),
			"floor_size": Vector3(44.0, 1.0, 38.0),
			"floor_color": Color(0.15, 0.14, 0.17, 1.0),
			"floor_emission": Color(0.12, 0.05, 0.06, 1.0),
			"wall_color": Color(0.25, 0.22, 0.25, 1.0),
			"wall_emission": Color(0.11, 0.05, 0.06, 1.0),
			"prop_specs": [
				{
					"name": "PitRimWest",
					"position": Vector3(-9.0, 0.76, 6.2),
					"size": Vector3(2.8, 1.5, 2.4),
					"albedo": Color(0.32, 0.28, 0.28, 1.0),
					"emission": Color(0.17, 0.08, 0.06, 1.0)
				},
				{
					"name": "PitRimEast",
					"position": Vector3(9.0, 0.76, 6.2),
					"size": Vector3(2.8, 1.5, 2.4),
					"albedo": Color(0.32, 0.28, 0.28, 1.0),
					"emission": Color(0.17, 0.08, 0.06, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "troll",
					"position": Vector3(-9.4, 1.05, 2.6),
					"config": {"max_health": 110.0, "attack_damage": 15.0, "move_speed": 3.26, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(-4.8, 1.05, 7.0),
					"config": {"max_health": 114.0, "attack_damage": 15.4, "move_speed": 3.28, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(0.0, 1.05, 8.4),
					"config": {"max_health": 118.0, "attack_damage": 15.8, "move_speed": 3.3, "orbit_sign": 1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(4.8, 1.05, 7.0),
					"config": {"max_health": 122.0, "attack_damage": 16.2, "move_speed": 3.3, "orbit_sign": -1}
				},
				{
					"enemy_type": "troll",
					"position": Vector3(9.2, 1.05, 3.0),
					"config": {"max_health": 128.0, "attack_damage": 16.8, "move_speed": 3.32, "orbit_sign": 1, "body_scale": 1.28}
				}
			]
		},
		{
			"scene_name": "CampaignMission05Normal",
			"scene_path": "%s/campaign_mission_05_normal.tscn" % CAMPAIGN_STAGE_DIR_PATH,
			"stage_number": 5,
			"stage_id": "mission_05",
			"display_name": "Mapa 5 - Chefe da Muralha",
			"objective_text": "Derrote o Boss Troll no passe Normal da Campanha do Troll.",
			"is_boss_stage": true,
			"reward_title": "Campanha Classica em Normal concluida",
			"reward_summary_lines": PackedStringArray([
				"A Campanha do Troll em Normal foi concluida."
			]),
			"player_spawn_position": Vector3(0.0, 1.05, 10.2),
			"floor_size": Vector3(40.0, 1.0, 40.0),
			"floor_color": Color(0.18, 0.17, 0.19, 1.0),
			"floor_emission": Color(0.15, 0.08, 0.08, 1.0),
			"wall_color": Color(0.31, 0.27, 0.28, 1.0),
			"wall_emission": Color(0.13, 0.08, 0.08, 1.0),
			"prop_specs": [
				{
					"name": "NormalBossTorchWest",
					"position": Vector3(-11.2, 0.9, -1.8),
					"size": Vector3(1.4, 1.9, 1.4),
					"albedo": Color(0.36, 0.31, 0.29, 1.0),
					"emission": Color(0.26, 0.11, 0.07, 1.0)
				},
				{
					"name": "NormalBossTorchEast",
					"position": Vector3(11.2, 0.9, 1.8),
					"size": Vector3(1.4, 1.9, 1.4),
					"albedo": Color(0.36, 0.31, 0.29, 1.0),
					"emission": Color(0.26, 0.11, 0.07, 1.0)
				}
			],
			"enemy_specs": [
				{
					"enemy_type": "boss_troll",
					"position": Vector3(0.0, 1.05, 0.0),
					"boss_id": "boss_troll"
				}
			]
		}
	]
