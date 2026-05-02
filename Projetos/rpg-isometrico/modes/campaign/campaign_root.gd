class_name CampaignRoot
extends Node3D

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const CampaignRewardPayload = preload("res://gameplay/profile/campaign_reward_payload.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const PlayerController = preload("res://gameplay/player/player_controller.gd")
const GameContext = preload("res://gameplay/simulation/game_context.gd")
const CampaignSessionManager = preload("res://modes/campaign/campaign_session_manager.gd")
const CampaignGameLoop = preload("res://modes/campaign/campaign_game_loop.gd")
const CampaignStageManager = preload("res://modes/campaign/campaign_stage_manager.gd")
const CampaignStageScene = preload("res://modes/campaign/campaign_stage_scene.gd")
const CombatHud = preload("res://presentation/hud/combat_hud.gd")
const SkillFeedback3D = preload("res://presentation/feedback/skill_feedback_3d.gd")
const CombatFeedbackLayer = preload("res://presentation/feedback/combat_feedback_layer.gd")
const ResultOverlay = preload("res://presentation/results/result_overlay.gd")
const CampaignFlowOverlay = preload("res://presentation/campaign/campaign_flow_overlay.gd")

const GAMEPLAY_ACTIONS: PackedStringArray = [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"basic_attack",
	"dash",
	"skill_1",
	"skill_2",
	"skill_3",
	"skill_4",
	"potion_1",
	"potion_2"
]

const DEFAULT_CAMERA_OFFSET: Vector3 = Vector3(8.4, 18.8, 8.4)
const DEFAULT_CAMERA_SIZE: float = 15.6
const FLOW_PAUSE_DURATION: float = 9999.0
const TUTORIAL_SKILL_PROMPT_DELAY: float = 0.8
const TUTORIAL_POTION_HEALTH_THRESHOLD: float = 0.60

var world_environment: WorldEnvironment
var key_light: DirectionalLight3D
var fill_light: OmniLight3D
var mode_camera: Camera3D
var runtime_root: Node3D
var combat_readability_root: Node3D
var presentation_root: Node

var launch_request
var game_context
var session_manager
var game_loop
var stage_manager
var player
var combat_hud
var combat_feedback_layer
var flow_overlay
var current_camera_offset: Vector3 = DEFAULT_CAMERA_OFFSET
var current_camera_size: float = DEFAULT_CAMERA_SIZE
var camera_basis: Basis = Basis.IDENTITY
var boss_was_unlocked_at_start: bool = false
var active_flow_kind: StringName = &""
var tutorial_skill_prompt_remaining: float = -1.0
var run_state: Dictionary = {}
var close_handling_active: bool = false

func _ready() -> void:
	if not _launch_context().has_pending_mode_launch(LocalModeCatalog.CAMPAIGN_MODE_ID):
		get_tree().change_scene_to_file(LocalModeCatalog.FRONTEND_SCENE_PATH)
		return

	launch_request = _launch_context().consume_pending_mode_launch()
	boss_was_unlocked_at_start = ProgressionResolver.has_completed_blacksmith_campaign(
		_profile_store().load_profile()
	)
	run_state = _resolve_run_state()
	_clear_gameplay_inputs()
	_content_library().ensure_loaded()
	_configure_close_handling()
	_ensure_scene_scaffold()
	_configure_world()
	_build_runtime()
	session_manager.start_session()

func _exit_tree() -> void:
	_restore_close_handling()

func _process(delta: float) -> void:
	_update_camera()
	_tick_tutorial_prompts(delta)

func _input(event: InputEvent) -> void:
	if _handle_tutorial_prompt_input(event):
		get_viewport().set_input_as_handled()

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_back"):
		_suspend_and_return_to_menu()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_suspend_and_quit_application()

func _ensure_scene_scaffold() -> void:
	world_environment = _ensure_world_environment("WorldEnvironment")
	key_light = _ensure_directional_light("KeyLight")
	fill_light = _ensure_omni_light("FillLight")
	mode_camera = _ensure_camera("ModeCamera")
	runtime_root = _ensure_node3d("RuntimeRoot")
	combat_readability_root = _ensure_node3d("CombatReadabilityRoot")
	presentation_root = _ensure_node("PresentationRoot")

func _configure_world() -> void:
	var environment_resource: Environment = Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color(0.06, 0.06, 0.08, 1.0)
	environment_resource.ambient_light_color = Color(0.94, 0.9, 0.82, 1.0)
	environment_resource.ambient_light_energy = 1.06
	world_environment.environment = environment_resource

	key_light.rotation_degrees = Vector3(-58.0, -36.0, 0.0)
	key_light.light_energy = 2.55
	key_light.shadow_enabled = true

	fill_light.position = Vector3(0.0, 7.2, 0.0)
	fill_light.light_energy = 1.9
	fill_light.omni_range = 45.0

	mode_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	mode_camera.size = current_camera_size
	mode_camera.global_position = current_camera_offset
	mode_camera.look_at(Vector3.ZERO, Vector3.UP)
	camera_basis = mode_camera.global_basis
	mode_camera.current = true

func _build_runtime() -> void:
	game_context = GameContext.new()
	game_context.name = "GameContext"
	runtime_root.add_child(game_context)
	game_context.reset_round()

	session_manager = CampaignSessionManager.new()
	session_manager.name = "SessionManager"
	runtime_root.add_child(session_manager)

	player = PlayerController.new()
	player.name = "Player"
	runtime_root.add_child(player)
	player.configure(_build_runtime_loadout_from_run_state(), game_context)
	player.apply_progression_level(int(run_state.get("current_level", 1)))
	player.arena_camera = mode_camera

	stage_manager = CampaignStageManager.new()
	stage_manager.name = "StageManager"
	runtime_root.add_child(stage_manager)
	stage_manager.configure(
		runtime_root,
		game_context,
		player,
		launch_request.get_campaign_id(),
		launch_request.get_campaign_difficulty_id()
	)

	game_loop = CampaignGameLoop.new()
	game_loop.name = "GameLoop"
	runtime_root.add_child(game_loop)
	game_loop.bind(
		launch_request,
		player,
		game_context,
		session_manager,
		stage_manager,
		boss_was_unlocked_at_start
	)
	session_manager.bind(game_context, game_loop)

	var skill_feedback_layer = SkillFeedback3D.new()
	skill_feedback_layer.name = "SkillFeedback3D"
	combat_readability_root.add_child(skill_feedback_layer)
	skill_feedback_layer.bind(player)

	combat_hud = CombatHud.new()
	combat_hud.name = "CombatHud"
	presentation_root.add_child(combat_hud)
	combat_hud.bind(player, session_manager, game_context, game_loop)

	combat_feedback_layer = CombatFeedbackLayer.new()
	combat_feedback_layer.name = "CombatFeedbackLayer"
	presentation_root.add_child(combat_feedback_layer)
	combat_feedback_layer.bind(player, null, game_context, mode_camera)

	flow_overlay = CampaignFlowOverlay.new()
	flow_overlay.name = "CampaignFlowOverlay"
	presentation_root.add_child(flow_overlay)

	var result_overlay = ResultOverlay.new()
	result_overlay.name = "ResultOverlay"
	presentation_root.add_child(result_overlay)
	result_overlay.bind(session_manager)

	stage_manager.enemy_spawned.connect(_on_enemy_spawned)
	stage_manager.enemy_defeated.connect(_on_enemy_defeated)
	stage_manager.stage_loaded.connect(_on_stage_loaded)
	stage_manager.stage_cleared.connect(_on_stage_cleared)

	if not session_manager.session_started.is_connected(_on_session_started):
		session_manager.session_started.connect(_on_session_started)
	if not session_manager.session_ended.is_connected(_on_session_ended):
		session_manager.session_ended.connect(_on_session_ended)

	player.skill_used.connect(_on_player_skill_used)
	player.potion_used.connect(_on_player_potion_used)
	flow_overlay.continue_requested.connect(_on_flow_continue_requested)
	flow_overlay.skill_selected.connect(_on_level_up_skill_selected)

func _update_camera() -> void:
	if mode_camera == null or player == null:
		return

	var desired_focus: Vector3 = player.global_position + Vector3(0.0, 0.45, 0.0)
	mode_camera.size = current_camera_size
	mode_camera.global_basis = camera_basis
	mode_camera.global_position = desired_focus + current_camera_offset

func _tick_tutorial_prompts(delta: float) -> void:
	if session_manager == null or not session_manager.is_in_progress():
		return
	if _is_free_campaign_replay():
		return
	if int(run_state.get("current_stage_index", 0)) != 0:
		return
	if active_flow_kind != &"":
		return

	if not _is_tutorial_skill_equipped():
		tutorial_skill_prompt_remaining = maxf(-1.0, tutorial_skill_prompt_remaining - delta)
		if tutorial_skill_prompt_remaining >= 0.0:
			return
		_unlock_tutorial_skill_prompt()
		return

	if not _is_tutorial_potion_equipped() and player != null and player.health_fraction() <= TUTORIAL_POTION_HEALTH_THRESHOLD:
		_unlock_tutorial_potion_prompt()

func _on_session_started() -> void:
	combat_hud.visible = true
	_load_stage_from_run_state()

func _on_session_ended(result: Dictionary) -> void:
	if combat_hud != null:
		combat_hud.visible = false
		combat_hud.clear_slot_highlights()
	_resume_combat()
	active_flow_kind = &""
	if not bool(result.get("player_victory", false)):
		_profile_store().clear_campaign_suspended_run(
			launch_request.get_campaign_id(),
			launch_request.get_campaign_difficulty_id()
		)

func _on_enemy_spawned(enemy) -> void:
	if combat_feedback_layer != null and enemy != null:
		combat_feedback_layer.register_combatant(enemy.combatant_id, enemy)

func _on_enemy_defeated(enemy_id: StringName, _enemy) -> void:
	if combat_feedback_layer != null:
		combat_feedback_layer.unregister_combatant(enemy_id)

func _on_stage_loaded(_stage_number: int, stage_scene) -> void:
	if stage_scene == null:
		return
	current_camera_offset = stage_scene.get_camera_offset()
	current_camera_size = stage_scene.get_camera_size()
	player.arena_camera = mode_camera
	player.apply_progression_level(int(run_state.get("current_level", 1)))
	_save_run_state()

func _on_stage_cleared(stage_number: int) -> void:
	if session_manager == null or not session_manager.is_in_progress():
		return
	var current_stage_scene: CampaignStageScene = stage_manager.get_current_stage_scene()
	if current_stage_scene == null:
		return
	if stage_number >= stage_manager.get_stage_count():
		_handle_campaign_victory(current_stage_scene)
		return

	var reward_payload: CampaignRewardPayload = current_stage_scene.build_reward_payload(
		launch_request.get_campaign_id(),
		launch_request.get_campaign_difficulty_id(),
		int(run_state.get("current_level", 1))
	)
	reward_payload = _build_runtime_reward_payload(current_stage_scene, reward_payload)
	if not _is_free_campaign_replay():
		_profile_store().apply_campaign_stage_completion(reward_payload)
	run_state["current_stage_index"] = stage_number
	run_state["pending_level_increase"] = reward_payload.pending_level_increase
	run_state["pending_skill_points"] = reward_payload.pending_skill_points
	_set_pending_reward_payload(reward_payload)
	_apply_reward_runtime_unlocks(reward_payload)
	_save_run_state()

	active_flow_kind = &"reward"
	_pause_combat()
	flow_overlay.show_reward_payload(reward_payload)

func _on_player_skill_used(effect: Dictionary) -> void:
	if active_flow_kind != &"tutorial_skill":
		return
	if int(effect.get("slot_index", -1)) != 0:
		return
	_finalize_tutorial_prompt()

func _on_player_potion_used(effect: Dictionary) -> void:
	if active_flow_kind != &"tutorial_potion":
		return
	if int(effect.get("slot_index", -1)) != 0:
		return
	_finalize_tutorial_prompt()

func _handle_tutorial_prompt_input(event: InputEvent) -> bool:
	if event == null:
		return false
	if event is InputEventKey and event.is_echo():
		return false
	match active_flow_kind:
		&"tutorial_skill":
			if event.is_action_pressed("skill_1"):
				return _trigger_tutorial_prompt_action(&"tutorial_skill")
		&"tutorial_potion":
			if event.is_action_pressed("potion_1"):
				return _trigger_tutorial_prompt_action(&"tutorial_potion")
	return false

func _on_flow_continue_requested() -> void:
	match active_flow_kind:
		&"reward":
			flow_overlay.hide_overlay()
			_clear_pending_reward_payload()
			_save_run_state()
			active_flow_kind = &""
			_load_stage_from_run_state()
		&"level_up":
			_apply_level_up_choice(&"")
		&"stage_briefing":
			flow_overlay.hide_overlay()
			active_flow_kind = &""
			_resume_combat()
			_arm_tutorial_prompt_if_needed()

func _on_level_up_skill_selected(skill_id: StringName) -> void:
	_apply_level_up_choice(skill_id)

func _load_stage_from_run_state() -> void:
	stage_manager.load_stage(int(run_state.get("current_stage_index", 0)))
	current_camera_offset = stage_manager.get_current_camera_offset()
	current_camera_size = stage_manager.get_current_camera_size()
	player.apply_progression_level(int(run_state.get("current_level", 1)))
	if _has_pending_reward_overlay():
		var reward_payload: CampaignRewardPayload = _get_pending_reward_payload()
		active_flow_kind = &"reward"
		_pause_combat()
		flow_overlay.show_reward_payload(reward_payload)
		return
	if _has_pending_level_up():
		_show_level_up_flow()
		return
	if _should_show_stage_briefing():
		_show_stage_briefing_flow()
		return
	_resume_combat()
	_arm_tutorial_prompt_if_needed()

func _handle_campaign_victory(current_stage_scene: CampaignStageScene) -> void:
	_profile_store().clear_campaign_suspended_run(
		launch_request.get_campaign_id(),
		launch_request.get_campaign_difficulty_id()
	)
	_profile_store().complete_campaign(
		launch_request.get_campaign_id(),
		launch_request.get_campaign_difficulty_id()
	)
	_clear_pending_reward_payload()
	var completion_reward_payload: CampaignRewardPayload = current_stage_scene.build_reward_payload(
		launch_request.get_campaign_id(),
		launch_request.get_campaign_difficulty_id(),
		int(run_state.get("current_level", 1))
	)
	completion_reward_payload = _build_runtime_reward_payload(current_stage_scene, completion_reward_payload)
	game_loop.conclude(
		game_loop.build_outcome_result(true, completion_reward_payload.build_overlay_lines())
	)

func _unlock_tutorial_skill_prompt() -> void:
	_profile_store().unlock_tutorial_skill()
	player.set_runtime_skill_slot(0, _content_library().get_skill(ProgressionResolver.TUTORIAL_SKILL_ID))
	run_state["equipped_skill_ids"] = _extract_string_array(player.get_equipped_skill_ids())
	_save_run_state()
	active_flow_kind = &"tutorial_skill"
	_pause_combat()
	if combat_hud != null:
		combat_hud.set_skill_highlight(0)
	flow_overlay.show_tutorial_prompt(
		"Spell 1 liberada",
		"Um grupo de trolls entrou na arena da forja. Pressione Q para usar a primeira spell e retomar o combate."
	)

func _unlock_tutorial_potion_prompt() -> void:
	_profile_store().unlock_tutorial_potion()
	player.set_runtime_potion_slot(0, _content_library().get_potion(ProgressionResolver.TUTORIAL_POTION_ID))
	run_state["equipped_potion_ids"] = _extract_string_array(player.get_equipped_potion_ids())
	_save_run_state()
	active_flow_kind = &"tutorial_potion"
	_pause_combat()
	if combat_hud != null:
		combat_hud.set_potion_highlight(0)
	flow_overlay.show_tutorial_prompt(
		"Pocao 1 liberada",
		"Sua vida entrou em zona de risco. Pressione 1 para usar a pocao de vida e voltar ao ritmo da run."
	)

func _finalize_tutorial_prompt() -> void:
	active_flow_kind = &""
	if combat_hud != null:
		combat_hud.clear_slot_highlights()
	flow_overlay.hide_overlay()
	_resume_combat()

func _trigger_tutorial_prompt_action(flow_kind: StringName) -> bool:
	if player == null or active_flow_kind != flow_kind:
		return false
	match flow_kind:
		&"tutorial_skill":
			if not player.has_skill_slot(0):
				return false
			player.trigger_skill_slot(0)
		&"tutorial_potion":
			if not player.has_potion_slot(0):
				return false
			player.trigger_potion_slot(0)
		_:
			return false
	if active_flow_kind == flow_kind:
		_finalize_tutorial_prompt()
	return true

func _show_level_up_flow() -> void:
	active_flow_kind = &"level_up"
	_pause_combat()
	var next_level: int = int(run_state.get("current_level", 1)) + int(run_state.get("pending_level_increase", 0))
	var available_skills: Array[Dictionary] = _build_level_up_skill_options()
	var snapshot: Dictionary = stage_manager.get_hud_snapshot() if stage_manager != null else {}
	var body_lines: Array[String] = [
		"A proxima etapa da Campanha Classica ja esta carregada. Aplique o avanco do kit antes de retomar o controle.",
		"Proxima etapa: %s." % str(snapshot.get("stage_name", "Campanha do Troll")),
		"Objetivo: %s" % str(snapshot.get("objective_text", "Avance pela campanha.")),
		"Nivel preparado: %d | Pontos de habilidade pendentes: %d" % [
			next_level,
			int(run_state.get("pending_skill_points", 0))
		]
	]
	if available_skills.is_empty():
		body_lines.append("Nenhuma habilidade bloqueada continua disponivel nesta run. O nivel sera aplicado sem nova escolha.")
	flow_overlay.show_level_up_overlay(next_level, available_skills, body_lines)

func _should_show_stage_briefing() -> bool:
	if stage_manager == null or stage_manager.get_current_stage_scene() == null:
		return false
	if active_flow_kind != &"":
		return false
	return true

func _show_stage_briefing_flow() -> void:
	var stage_scene: CampaignStageScene = stage_manager.get_current_stage_scene()
	if stage_scene == null:
		_resume_combat()
		_arm_tutorial_prompt_if_needed()
		return
	active_flow_kind = &"stage_briefing"
	_pause_combat()
	var snapshot: Dictionary = stage_manager.get_hud_snapshot()
	flow_overlay.show_stage_briefing(
		str(snapshot.get("campaign_name", "Campanha do Troll")),
		str(snapshot.get("difficulty_label", "Classic - Easy")),
		stage_scene.display_name,
		int(snapshot.get("stage_number", 1)),
		int(snapshot.get("target_stage_count", 1)),
		stage_scene.objective_text,
		stage_scene.is_boss_stage,
		_is_free_campaign_replay()
	)

func _apply_level_up_choice(skill_id: StringName) -> void:
	var pending_level_increase: int = int(run_state.get("pending_level_increase", 0))
	var target_level: int = int(run_state.get("current_level", 1)) + pending_level_increase
	player.apply_progression_level(target_level)
	run_state["current_level"] = target_level
	run_state["pending_level_increase"] = 0
	run_state["pending_skill_points"] = 0
	_clear_pending_reward_payload()

	if skill_id != &"":
		var slot_index: int = _find_campaign_skill_slot_index(skill_id)
		if slot_index >= 0:
			player.set_runtime_skill_slot(slot_index, _content_library().get_skill(skill_id))
			run_state["equipped_skill_ids"] = _extract_string_array(player.get_equipped_skill_ids())

	run_state["equipped_potion_ids"] = _extract_string_array(player.get_equipped_potion_ids())
	_save_run_state()
	active_flow_kind = &""
	flow_overlay.hide_overlay()
	_resume_combat()
	_arm_tutorial_prompt_if_needed()

func _pause_combat() -> void:
	if player != null:
		player.request_motion_pause(FLOW_PAUSE_DURATION)
	for enemy in stage_manager.get_active_enemies():
		if enemy != null and is_instance_valid(enemy):
			enemy.request_motion_pause(FLOW_PAUSE_DURATION)

func _resume_combat() -> void:
	if player != null:
		player.clear_motion_pause()
	for enemy in stage_manager.get_active_enemies():
		if enemy != null and is_instance_valid(enemy):
			enemy.clear_motion_pause()

func _arm_tutorial_prompt_if_needed() -> void:
	tutorial_skill_prompt_remaining = -1.0
	if int(run_state.get("current_stage_index", 0)) != 0:
		return
	if not _is_tutorial_skill_equipped():
		tutorial_skill_prompt_remaining = TUTORIAL_SKILL_PROMPT_DELAY

func _suspend_and_return_to_menu() -> void:
	_persist_suspended_run_if_possible("menu")
	_restore_close_handling()
	get_tree().change_scene_to_file(LocalModeCatalog.FRONTEND_SCENE_PATH)

func _suspend_and_quit_application() -> void:
	_persist_suspended_run_if_possible("quit")
	_restore_close_handling()
	get_tree().quit()

func _capture_runtime_loadout_into_run_state() -> void:
	if player == null:
		return
	run_state["equipped_skill_ids"] = _extract_string_array(player.get_equipped_skill_ids())
	run_state["equipped_potion_ids"] = _extract_string_array(player.get_equipped_potion_ids())
	if player.loadout != null:
		var loadout_payload: Dictionary = player.loadout.to_id_payload()
		run_state["loadout"] = loadout_payload
		run_state["race_id"] = str(loadout_payload.get("race_id", String(ProgressionResolver.HEROIC_RACE_ID)))
		run_state["weapon_id"] = str(loadout_payload.get("weapon_id", String(ProgressionResolver.HEROIC_WEAPON_ID)))

func _persist_suspended_run_if_possible(suspend_origin: String = "") -> bool:
	if session_manager == null or session_manager.state == session_manager.SessionState.SESSION_END:
		return false
	run_state["suspend_origin"] = suspend_origin
	_capture_runtime_loadout_into_run_state()
	_save_run_state()
	return true

func _save_run_state() -> void:
	_capture_runtime_loadout_into_run_state()
	_profile_store().save_campaign_suspended_run(
		launch_request.get_campaign_id(),
		launch_request.get_campaign_difficulty_id(),
		run_state
	)

func _resolve_run_state() -> Dictionary:
	var saved_run: Dictionary = {}
	if launch_request.should_resume_suspended_run():
		saved_run = _profile_store().get_campaign_suspended_run(
			launch_request.get_campaign_id(),
			launch_request.get_campaign_difficulty_id()
		)
	if saved_run.is_empty():
		return _build_fresh_run_state()
	var resolved_run_state: Dictionary = _sanitize_run_state(saved_run)
	if launch_request.should_resume_suspended_run():
		resolved_run_state["suspend_origin"] = ""
	return resolved_run_state

func _build_fresh_run_state() -> Dictionary:
	var profile = _profile_store().load_profile()
	var race_id: String = String(ProgressionResolver.HEROIC_RACE_ID)
	var weapon_id: String = String(ProgressionResolver.HEROIC_WEAPON_ID)
	var skill_ids: Array[String] = ["", "", "", ""]
	var potion_ids: Array[String] = ["", ""]
	if _is_free_campaign_replay() and launch_request.loadout != null:
		race_id = String(launch_request.loadout.race.id)
		weapon_id = String(launch_request.loadout.weapon.id)
		skill_ids = _extract_string_array(launch_request.loadout.get_skill_ids())
		potion_ids = _extract_string_array(launch_request.loadout.get_potion_ids())
	else:
		if profile.is_skill_unlocked(ProgressionResolver.TUTORIAL_SKILL_ID):
			skill_ids[0] = String(ProgressionResolver.TUTORIAL_SKILL_ID)
		if profile.is_potion_unlocked(ProgressionResolver.TUTORIAL_POTION_ID):
			potion_ids[0] = String(ProgressionResolver.TUTORIAL_POTION_ID)
	return _sanitize_run_state({
		"campaign_id": String(launch_request.get_campaign_id()),
		"difficulty_id": String(launch_request.get_campaign_difficulty_id()),
		"race_id": race_id,
		"weapon_id": weapon_id,
		"current_stage_index": 0,
		"current_level": 1,
		"pending_level_increase": 0,
		"pending_skill_points": 0,
		"equipped_skill_ids": skill_ids,
		"equipped_potion_ids": potion_ids,
		"loadout": {
			"race_id": race_id,
			"weapon_id": weapon_id,
			"skill_ids": skill_ids,
			"potion_ids": potion_ids
		},
		"reward_payload": {},
		"reward_stage_number": 0,
		"suspend_origin": ""
	})

func _sanitize_run_state(payload: Dictionary) -> Dictionary:
	var loadout_payload: Dictionary = Dictionary(payload.get("loadout", {})).duplicate(true)
	var equipped_skill_ids: Array[String] = _extract_string_array(payload.get("equipped_skill_ids", []))
	if equipped_skill_ids.is_empty() and not loadout_payload.is_empty():
		equipped_skill_ids = _extract_string_array(loadout_payload.get("skill_ids", []))
	while equipped_skill_ids.size() < 4:
		equipped_skill_ids.append("")
	while equipped_skill_ids.size() > 4:
		equipped_skill_ids.pop_back()

	var equipped_potion_ids: Array[String] = _extract_string_array(payload.get("equipped_potion_ids", []))
	if equipped_potion_ids.is_empty() and not loadout_payload.is_empty():
		equipped_potion_ids = _extract_string_array(loadout_payload.get("potion_ids", []))
	while equipped_potion_ids.size() < 2:
		equipped_potion_ids.append("")
	while equipped_potion_ids.size() > 2:
		equipped_potion_ids.pop_back()

	var reward_payload_dict: Dictionary = _sanitize_reward_payload(payload)
	var reward_payload: CampaignRewardPayload = _build_reward_payload_from_dictionary(reward_payload_dict)
	var resolved_campaign_id: String = str(payload.get("campaign_id", String(launch_request.get_campaign_id())))
	var resolved_difficulty_id: String = str(payload.get("difficulty_id", String(launch_request.get_campaign_difficulty_id())))
	var resolved_race_id: String = str(payload.get("race_id", loadout_payload.get("race_id", String(ProgressionResolver.HEROIC_RACE_ID))))
	var resolved_weapon_id: String = str(payload.get("weapon_id", loadout_payload.get("weapon_id", String(ProgressionResolver.HEROIC_WEAPON_ID))))
	var route_stage_count: int = CampaignStageManager.get_route_stage_count(
		StringName(resolved_campaign_id),
		StringName(resolved_difficulty_id)
	)
	var max_stage_index: int = maxi(0, route_stage_count - 1)

	return {
		"campaign_id": resolved_campaign_id,
		"difficulty_id": resolved_difficulty_id,
		"race_id": resolved_race_id,
		"weapon_id": resolved_weapon_id,
		"current_stage_index": clampi(int(payload.get("current_stage_index", 0)), 0, max_stage_index),
		"current_level": maxi(1, int(payload.get("current_level", 1))),
		"pending_level_increase": maxi(0, int(payload.get("pending_level_increase", 0))),
		"pending_skill_points": maxi(0, int(payload.get("pending_skill_points", 0))),
		"equipped_skill_ids": equipped_skill_ids,
		"equipped_potion_ids": equipped_potion_ids,
		"loadout": {
			"race_id": resolved_race_id,
			"weapon_id": resolved_weapon_id,
			"skill_ids": equipped_skill_ids,
			"potion_ids": equipped_potion_ids
		},
		"reward_payload": reward_payload_dict,
		"reward_stage_number": reward_payload.stage_number,
		"suspend_origin": str(payload.get("suspend_origin", ""))
	}

func _build_runtime_loadout_from_run_state() -> LoadoutData:
	var loadout := LoadoutData.new()
	loadout.race = _content_library().get_race(StringName(str(run_state.get("race_id", String(ProgressionResolver.HEROIC_RACE_ID)))))
	loadout.weapon = _content_library().get_weapon(StringName(str(run_state.get("weapon_id", String(ProgressionResolver.HEROIC_WEAPON_ID)))))
	loadout.skills = []
	loadout.potions = []
	for skill_id: String in _extract_string_array(run_state.get("equipped_skill_ids", [])):
		var resource = null if skill_id == "" else _content_library().get_skill(StringName(skill_id))
		loadout.skills.append(resource)
	for potion_id: String in _extract_string_array(run_state.get("equipped_potion_ids", [])):
		var resource = null if potion_id == "" else _content_library().get_potion(StringName(potion_id))
		loadout.potions.append(resource)
	return loadout

func _build_runtime_reward_payload(
	stage_scene: CampaignStageScene,
	stage_reward_payload: CampaignRewardPayload
) -> CampaignRewardPayload:
	if not _is_free_campaign_replay():
		return stage_reward_payload
	var reward_payload := CampaignRewardPayload.new()
	reward_payload.reward_id = "replay:%s:%s:%s" % [
		String(launch_request.get_campaign_id()),
		String(launch_request.get_campaign_difficulty_id()),
		stage_scene.stage_id
	]
	reward_payload.campaign_id = launch_request.get_campaign_id()
	reward_payload.difficulty_id = launch_request.get_campaign_difficulty_id()
	reward_payload.stage_number = maxi(0, stage_scene.stage_number)
	reward_payload.title = (
		"Campanha Livre concluida"
		if stage_scene.is_boss_stage
		else "%s concluido em Livre" % stage_scene.display_name
	)
	reward_payload.summary_lines = [
		"Replay livre concluido com o kit preparado.",
		"Nenhuma recompensa permanente foi gerada; a Campanha Livre usa o que ja foi aprendido na Classic."
	]
	return reward_payload

func _is_free_campaign_replay() -> bool:
	if launch_request == null:
		return false
	return launch_request.get_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID

func _build_level_up_skill_options() -> Array[Dictionary]:
	var profile = _profile_store().load_profile()
	var equipped_skill_ids: Array[String] = _extract_string_array(run_state.get("equipped_skill_ids", []))
	var options: Array[Dictionary] = []
	for skill_id_text: String in ProgressionResolver.get_classic_campaign_skill_order():
		if skill_id_text == String(ProgressionResolver.TUTORIAL_SKILL_ID):
			continue
		if equipped_skill_ids.has(skill_id_text):
			continue
		if not profile.is_skill_unlocked(StringName(skill_id_text)):
			continue
		var skill = _content_library().get_skill(StringName(skill_id_text))
		if skill == null:
			continue
		options.append({
			"skill_id": skill_id_text,
			"label": skill.display_name,
			"description": skill.description
		})
	return options

func _has_pending_reward_overlay() -> bool:
	return not _get_pending_reward_payload().is_empty()

func _has_pending_level_up() -> bool:
	return int(run_state.get("pending_level_increase", 0)) > 0

func _is_tutorial_skill_equipped() -> bool:
	var equipped_skill_ids: Array[String] = _extract_string_array(run_state.get("equipped_skill_ids", []))
	return equipped_skill_ids.size() > 0 and equipped_skill_ids[0] == String(ProgressionResolver.TUTORIAL_SKILL_ID)

func _is_tutorial_potion_equipped() -> bool:
	var equipped_potion_ids: Array[String] = _extract_string_array(run_state.get("equipped_potion_ids", []))
	return equipped_potion_ids.size() > 0 and equipped_potion_ids[0] == String(ProgressionResolver.TUTORIAL_POTION_ID)

func _find_campaign_skill_slot_index(skill_id: StringName) -> int:
	for index: int in range(ProgressionResolver.get_classic_campaign_skill_order().size()):
		if ProgressionResolver.get_classic_campaign_skill_order()[index] == String(skill_id):
			return index
	return -1

func _apply_reward_runtime_unlocks(reward_payload: CampaignRewardPayload) -> void:
	if player == null or reward_payload == null:
		return
	var loadout_changed: bool = false
	if reward_payload.marks_tutorial_completed:
		loadout_changed = _apply_runtime_tutorial_completion_unlocks() or loadout_changed
	if not reward_payload.permanent_potion_unlock_ids.is_empty():
		var potion_id: StringName = StringName(reward_payload.permanent_potion_unlock_ids[0])
		var potion_resource = _content_library().get_potion(potion_id)
		if potion_resource != null:
			player.set_runtime_potion_slot(1, potion_resource)
			loadout_changed = true
	if loadout_changed:
		_capture_runtime_loadout_into_run_state()

func _apply_runtime_tutorial_completion_unlocks() -> bool:
	if player == null:
		return false
	var loadout_changed: bool = false
	if not _is_tutorial_skill_equipped():
		var tutorial_skill = _content_library().get_skill(ProgressionResolver.TUTORIAL_SKILL_ID)
		if tutorial_skill != null:
			player.set_runtime_skill_slot(0, tutorial_skill)
			loadout_changed = true
	if not _is_tutorial_potion_equipped():
		var tutorial_potion = _content_library().get_potion(ProgressionResolver.TUTORIAL_POTION_ID)
		if tutorial_potion != null:
			player.set_runtime_potion_slot(0, tutorial_potion)
			loadout_changed = true
	if loadout_changed:
		tutorial_skill_prompt_remaining = -1.0
	return loadout_changed

func _get_campaign_run_key() -> StringName:
	return ProgressionResolver.build_campaign_run_key(
		launch_request.get_campaign_id(),
		launch_request.get_campaign_difficulty_id()
	)

func _extract_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is PackedStringArray:
		for entry: String in value:
			result.append(entry)
	elif value is Array:
		for entry: Variant in value:
			result.append(str(entry))
	return result

func _set_pending_reward_payload(reward_payload: CampaignRewardPayload) -> void:
	var resolved_reward_payload: CampaignRewardPayload = reward_payload if reward_payload != null else CampaignRewardPayload.new()
	run_state["reward_payload"] = resolved_reward_payload.to_dictionary()
	run_state["reward_stage_number"] = resolved_reward_payload.stage_number

func _clear_pending_reward_payload() -> void:
	run_state["reward_payload"] = {}
	run_state["reward_stage_number"] = 0

func _get_pending_reward_payload() -> CampaignRewardPayload:
	return _build_reward_payload_from_dictionary(Dictionary(run_state.get("reward_payload", {})))

func _build_reward_payload_from_dictionary(payload: Dictionary) -> CampaignRewardPayload:
	return CampaignRewardPayload.new().apply_dictionary(payload)

func _sanitize_reward_payload(payload: Dictionary) -> Dictionary:
	var explicit_payload: Dictionary = Dictionary(payload.get("reward_payload", {})).duplicate(true)
	if not explicit_payload.is_empty():
		return _build_reward_payload_from_dictionary(explicit_payload).to_dictionary()
	var legacy_stage_number: int = maxi(0, int(payload.get("reward_stage_number", 0)))
	if legacy_stage_number <= 0:
		return {}
	return ProgressionResolver.build_campaign_stage_reward_payload(
		legacy_stage_number,
		maxi(1, int(payload.get("current_level", 1))),
		maxi(0, int(payload.get("pending_level_increase", 0))),
		maxi(0, int(payload.get("pending_skill_points", 0)))
	).to_dictionary()

func _clear_gameplay_inputs() -> void:
	for action_name: String in GAMEPLAY_ACTIONS:
		Input.action_release(action_name)

func debug_get_run_state() -> Dictionary:
	return run_state.duplicate(true)

func debug_get_active_flow_kind() -> String:
	return String(active_flow_kind)

func debug_trigger_prompt_action() -> bool:
	return _trigger_tutorial_prompt_action(active_flow_kind)

func debug_continue_flow_overlay() -> bool:
	if active_flow_kind == &"reward" or active_flow_kind == &"stage_briefing":
		_on_flow_continue_requested()
		return true
	return false

func debug_apply_first_level_up_option() -> bool:
	if active_flow_kind != &"level_up":
		return false
	var options: Array[Dictionary] = _build_level_up_skill_options()
	if options.is_empty():
		_apply_level_up_choice(&"")
		return true
	_on_level_up_skill_selected(StringName(str(options[0].get("skill_id", ""))))
	return true

func _content_library() -> Node:
	return get_node("/root/ContentLibrary")

func _launch_context() -> Node:
	return get_node("/root/LaunchContext")

func _profile_store() -> Node:
	return get_node("/root/ProfileStore")

func _configure_close_handling() -> void:
	if close_handling_active:
		return
	var tree := get_tree()
	if tree != null:
		tree.auto_accept_quit = false
	close_handling_active = true

func _restore_close_handling() -> void:
	if not close_handling_active:
		return
	var tree := get_tree()
	if tree != null:
		tree.auto_accept_quit = true
	close_handling_active = false

func _ensure_world_environment(node_name: String) -> WorldEnvironment:
	var existing: WorldEnvironment = get_node_or_null(node_name) as WorldEnvironment
	if existing != null:
		return existing
	var created := WorldEnvironment.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_directional_light(node_name: String) -> DirectionalLight3D:
	var existing: DirectionalLight3D = get_node_or_null(node_name) as DirectionalLight3D
	if existing != null:
		return existing
	var created := DirectionalLight3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_omni_light(node_name: String) -> OmniLight3D:
	var existing: OmniLight3D = get_node_or_null(node_name) as OmniLight3D
	if existing != null:
		return existing
	var created := OmniLight3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_camera(node_name: String) -> Camera3D:
	var existing: Camera3D = get_node_or_null(node_name) as Camera3D
	if existing != null:
		return existing
	var created := Camera3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_node3d(node_name: String) -> Node3D:
	var existing: Node3D = get_node_or_null(node_name) as Node3D
	if existing != null:
		return existing
	var created := Node3D.new()
	created.name = node_name
	add_child(created)
	return created

func _ensure_node(node_name: String) -> Node:
	var existing: Node = get_node_or_null(node_name)
	if existing != null:
		return existing
	var created := Node.new()
	created.name = node_name
	add_child(created)
	return created
