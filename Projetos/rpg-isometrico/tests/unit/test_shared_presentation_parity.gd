extends "res://addons/gut/test.gd"

const ContentGenerator = preload("res://tools/content_generator.gd")
const SceneGenerator = preload("res://tools/scene_generator.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const BossTrollController = preload("res://gameplay/boss/boss_troll_controller.gd")
const CombatHud = preload("res://presentation/hud/combat_hud.gd")

class DummyHudPlayer extends Node:
	var health: float = 96.0
	var max_health: float = 150.0
	var barrier_amount: float = 0.0
	var barrier_time_remaining: float = 0.0
	var buff_time_remaining: float = 0.0
	var skill_labels: PackedStringArray = ["Arremesso", "Rally", "Leap", "Impacto"]
	var skill_cooldowns: Array[float] = [0.0, 1.2, 0.0, 3.4]
	var potion_labels: PackedStringArray = ["Vida", "Barreira"]
	var potion_cooldowns: Array[float] = [0.0, 4.0]

	func get_barrier_amount() -> float:
		return barrier_amount

	func get_barrier_time_remaining() -> float:
		return barrier_time_remaining

	func get_buff_time_remaining() -> float:
		return buff_time_remaining

	func has_skill_slot(index: int) -> bool:
		return index >= 0 and index < skill_labels.size()

	func has_potion_slot(index: int) -> bool:
		return index >= 0 and index < potion_labels.size()

	func get_skill_slot_label(index: int) -> String:
		return str(skill_labels[index])

	func get_potion_slot_label(index: int) -> String:
		return str(potion_labels[index])

	func get_skill_cooldown(index: int) -> float:
		return float(skill_cooldowns[index])

	func get_potion_cooldown(index: int) -> float:
		return float(potion_cooldowns[index])

class DummyHudSessionManager extends Node:
	enum SessionState {
		LOADING,
		PRE_MATCH,
		IN_PROGRESS,
		POST_MATCH,
		SESSION_END
	}

	var state: SessionState = SessionState.LOADING
	var state_remaining: float = 0.0

	func get_state_remaining_seconds() -> float:
		return state_remaining

class DummyHudShellSource extends Node:
	var snapshot: Dictionary = {
		"mode_id": "arena_bot",
		"context_text": "Tempo: 3.2s",
		"module_title": "Arena Bot: treino de kit",
		"module_detail": "Simulacao local | distancia 2.4m | bot avancando",
		"opponent_visible": true,
		"opponent_label": "Bot",
		"opponent_status_text": "Bot: pressionando",
		"opponent_health": 117.0,
		"opponent_max_health": 135.0
	}

	func get_shell_snapshot() -> Dictionary:
		return snapshot.duplicate(true)

func after_each() -> void:
	var launch_context = get_node_or_null("/root/LaunchContext")
	if launch_context != null:
		launch_context.clear_pending_mode_launch()
	var content_library = get_node_or_null("/root/ContentLibrary")
	if content_library != null:
		content_library.unload()

func test_combat_hud_snapshots_remain_structurally_consistent_across_solo_modes() -> void:
	var arena_root = await _instantiate_mode(LocalModeCatalog.ARENA_MODE_ID, {})
	var arena_session_manager = arena_root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(arena_session_manager.session_started, 1.5))
	var arena_hud: CombatHud = arena_root.get_node("PresentationRoot/CombatHud")
	var arena_snapshot: Dictionary = arena_hud.get_shell_snapshot()
	assert_eq(str(arena_snapshot.get("mode_id", "")), "arena_bot")
	assert_true(str(arena_snapshot.get("context_text", "")).begins_with("Tempo:"))
	assert_eq(str(arena_snapshot.get("module_title", "")), "Arena Bot: treino de kit")
	assert_true(str(arena_snapshot.get("module_detail", "")).contains("Simulacao local"))
	assert_true(bool(arena_snapshot.get("opponent_visible", false)))
	assert_not_null(arena_hud.get_node_or_null("HudPanel/PlayerCard"))
	assert_not_null(arena_hud.get_node_or_null("HudPanel/ContextChip"))
	assert_not_null(arena_hud.get_node_or_null("HudPanel/ActionRail"))
	assert_true((arena_hud.get_node("HudPanel/OpponentCard") as PanelContainer).visible)

	var survival_root = await _instantiate_mode(LocalModeCatalog.SURVIVAL_MODE_ID, {"start_wave": 2})
	var survival_session_manager = survival_root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(survival_session_manager.session_started, 1.5))
	var survival_hud: CombatHud = survival_root.get_node("PresentationRoot/CombatHud")
	var survival_snapshot: Dictionary = survival_hud.get_shell_snapshot()
	assert_eq(str(survival_snapshot.get("mode_id", "")), "survival")
	assert_true(str(survival_snapshot.get("context_text", "")).begins_with("Tempo:"))
	assert_eq(str(survival_snapshot.get("module_title", "")), "Survival: onda 2 de 7")
	assert_true(str(survival_snapshot.get("module_detail", "")).contains("trolls ativos"))
	assert_false(bool(survival_snapshot.get("opponent_visible", true)))
	assert_false((survival_hud.get_node("HudPanel/OpponentCard") as PanelContainer).visible)

	var campaign_root = await _instantiate_mode(
		LocalModeCatalog.CAMPAIGN_MODE_ID,
		{
			"campaign_id": "blacksmith_campaign",
			"difficulty_id": "easy"
		}
	)
	var campaign_session_manager = campaign_root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(campaign_session_manager.session_started, 1.5))
	var campaign_hud: CombatHud = campaign_root.get_node("PresentationRoot/CombatHud")
	var campaign_snapshot: Dictionary = campaign_hud.get_shell_snapshot()
	assert_eq(str(campaign_snapshot.get("mode_id", "")), "campaign")
	assert_true(str(campaign_snapshot.get("context_text", "")).begins_with("Tempo:"))
	assert_eq(str(campaign_snapshot.get("module_title", "")), "Campanha do Troll: Missao 1 - Tutorial (1/5)")
	assert_true(str(campaign_snapshot.get("module_detail", "")).contains("Classic - Easy"))
	assert_false(bool(campaign_snapshot.get("opponent_visible", true)))
	assert_false((campaign_hud.get_node("HudPanel/OpponentCard") as PanelContainer).visible)

	var boss_root = await _instantiate_mode(LocalModeCatalog.BOSS_MODE_ID, {"boss_id": "boss_troll"})
	var boss_session_manager = boss_root.get_node("RuntimeRoot/SessionManager")
	assert_true(await wait_for_signal(boss_session_manager.session_started, 1.5))
	var boss: BossTrollController = boss_root.get_node("RuntimeRoot/Boss")
	assert_true(await _wait_until_boss_not_invulnerable(boss, 3.0))
	var boss_hud: CombatHud = boss_root.get_node("PresentationRoot/CombatHud")
	var boss_snapshot: Dictionary = boss_hud.get_shell_snapshot()
	assert_eq(str(boss_snapshot.get("mode_id", "")), "boss")
	assert_true(str(boss_snapshot.get("context_text", "")).begins_with("Tempo:"))
	assert_true(str(boss_snapshot.get("module_title", "")).contains("Boss Troll: Fase 1 | vida"))
	assert_true(str(boss_snapshot.get("module_detail", "")).contains("rugido"))
	assert_true(bool(boss_snapshot.get("opponent_visible", false)))
	assert_true((boss_hud.get_node("HudPanel/OpponentCard") as PanelContainer).visible)
	assert_no_new_orphans()

func test_arena_result_now_uses_shared_summary_contract() -> void:
	var root = await _instantiate_mode(LocalModeCatalog.ARENA_MODE_ID, {})
	var session_manager = root.get_node("RuntimeRoot/SessionManager")
	var captured_results: Array[Dictionary] = []
	session_manager.session_ended.connect(func(result: Dictionary): captured_results.append(result.duplicate(true)), CONNECT_ONE_SHOT)

	assert_true(await wait_for_signal(session_manager.session_started, 1.5))
	var game_loop = root.get_node("RuntimeRoot/GameLoop")
	game_loop.conclude(game_loop._build_result(true))

	assert_true(await wait_for_signal(session_manager.session_ended, 3.0))
	assert_false(captured_results.is_empty())
	var captured_result: Dictionary = captured_results[0]
	var summary_lines: Variant = captured_result.get("summary_lines", [])
	assert_eq(str(captured_result.get("title", "")), "Treino concluido!")
	assert_eq(str(captured_result.get("winner", "")), "player")
	assert_true(summary_lines is Array and summary_lines.size() >= 2)
	var extra_summary: Dictionary = captured_result.get("round_summary", {}).get("extra_mode", {})
	assert_eq(str(extra_summary.get("role", "")), "Treino de kit")
	assert_false(bool(extra_summary.get("grants_permanent_progress", true)))

	var overlay = root.get_node("PresentationRoot/ResultOverlay")
	assert_true((overlay as CanvasLayer).visible)
	assert_not_null(overlay.find_child("EyebrowLabel", true, false))
	assert_not_null(overlay.find_child("SummaryLabel", true, false))
	assert_not_null(overlay.find_child("DetailsScroll", true, false))
	assert_eq(str(overlay.eyebrow_label.text), "RESULTADO DO EXTRA")
	assert_true(str(overlay.details_label.text).contains("Resumo principal:"))
	assert_true(str(overlay.details_label.text).contains("Extra:"))
	assert_true(str(overlay.details_label.text).contains("Progressao permanente: sem alteracao"))
	assert_true(str(overlay.details_label.text).contains("Proximo passo:"))
	assert_true(str(overlay.details_label.text).contains("testar outra combinacao"))
	assert_true(str(overlay.details_label.text).contains("Jogador"))
	assert_eq(str(overlay.return_button.text), "Voltar a Campanha e Extras")
	assert_no_new_orphans()

func test_combat_hud_uses_compact_layout_and_contextual_hint() -> void:
	var player: DummyHudPlayer = add_child_autofree(DummyHudPlayer.new())
	var session: DummyHudSessionManager = add_child_autofree(DummyHudSessionManager.new())
	var shell_source: DummyHudShellSource = add_child_autofree(DummyHudShellSource.new())

	await get_tree().process_frame

	var hud: CombatHud = CombatHud.new()
	add_child_autofree(hud)
	await get_tree().process_frame
	hud.bind(player, session, null, shell_source)
	hud._process(0.0)

	assert_not_null(hud.get_node_or_null("HudPanel/PlayerCard"))
	assert_not_null(hud.get_node_or_null("HudPanel/ContextChip"))
	assert_not_null(hud.get_node_or_null("HudPanel/ActionRail"))

	var opponent_card: PanelContainer = hud.get_node("HudPanel/OpponentCard") as PanelContainer
	assert_true(opponent_card.visible)

	var action_rail: PanelContainer = hud.get_node("HudPanel/ActionRail") as PanelContainer
	var hud_panel: Control = hud.get_node("HudPanel") as Control
	var slot_q: PanelContainer = action_rail.find_child("ActionSlot_Q", true, false) as PanelContainer
	var slot_q_name: Label = slot_q.find_child("SlotNameLabel", true, false) as Label
	var slot_q_state: Label = slot_q.find_child("SlotStateLabel", true, false) as Label
	var slot_e: PanelContainer = action_rail.find_child("ActionSlot_E", true, false) as PanelContainer
	var slot_e_state: Label = slot_e.find_child("SlotStateLabel", true, false) as Label
	assert_false(hud_panel is Container)
	assert_true(action_rail.size.x <= 480.0)
	assert_true(action_rail.size.y <= 80.0)
	assert_eq(slot_q.size_flags_horizontal & Control.SIZE_EXPAND, 0)
	assert_true(slot_q.custom_minimum_size.x <= 68.0)
	assert_eq(slot_q_name.text, "Arremesso")
	assert_eq(slot_q_state.text, "pronto")
	assert_eq(slot_e_state.text, "1.2s")

	var hint_panel: PanelContainer = hud.get_node("HintPanel") as PanelContainer
	var hint_label: Label = hint_panel.find_child("HintLabel", true, false) as Label
	session.state = DummyHudSessionManager.SessionState.PRE_MATCH
	session.state_remaining = 0.6
	hud._process(0.0)
	assert_true(hint_panel.visible)
	assert_string_contains(hint_label.text, "Q E R F")

	session.state = DummyHudSessionManager.SessionState.IN_PROGRESS
	hud._process(0.0)
	assert_true(hint_panel.visible)
	hud._process(4.1)
	assert_false(hint_panel.visible)

	hud.set_skill_highlight(0)
	hud._process(0.0)
	assert_true(hint_panel.visible)
	assert_string_contains(hint_label.text, "Use Q")
	hud.clear_slot_highlights()
	hud._process(0.0)
	assert_false(hint_panel.visible)

	assert_not_null(hud.get_node_or_null("HudPanel"))
	assert_not_null(hud.get_node_or_null("HintPanel"))
	assert_no_new_orphans()

func _instantiate_mode(mode_id: StringName, parameters: Dictionary) -> Node3D:
	var content_result: Dictionary = ContentGenerator.new().generate_all()
	assert_true(bool(content_result.get("ok", false)), str(content_result.get("message", "")))

	var scene_result: Dictionary = SceneGenerator.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))

	var loadout = _build_valid_loadout()
	var launch_result: Dictionary = get_node("/root/LaunchContext").set_pending_mode_launch(mode_id, loadout, parameters)
	assert_true(bool(launch_result.get("ok", false)), str(launch_result.get("message", "")))

	var scene: PackedScene = load(LocalModeCatalog.get_scene_path(mode_id))
	assert_not_null(scene)

	var root: Node3D = scene.instantiate()
	add_child_autofree(root)
	await get_tree().process_frame
	await get_tree().process_frame
	return root

func _build_valid_loadout():
	var library = get_node("/root/ContentLibrary")
	library.reload()
	var races = library.get_races()
	assert_eq(races.size(), 1)

	var race = races[0]
	var weapon = library.get_weapons_for_race(race.id)[0]
	var skills = library.get_skills_for_weapon(race.id, weapon.id)
	var potions = library.get_potions_for_race(race.id)
	return library.build_loadout_from_ids(
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

func _wait_until_boss_not_invulnerable(boss: BossTrollController, timeout_seconds: float) -> bool:
	var timeout_at: int = Time.get_ticks_msec() + int(timeout_seconds * 1000.0)
	while Time.get_ticks_msec() < timeout_at:
		if boss != null and is_instance_valid(boss) and not bool(boss.get_runtime_snapshot().get("invulnerable", true)):
			return true
		await get_tree().process_frame
	return false
