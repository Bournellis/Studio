class_name DraxosArenaDevFixtureProvider
extends RefCounted

const ProjectInfoScript := preload("res://core/project_info.gd")

const TUTORIAL_ARENA_ID := "arena_tutorial_cinzas"
const EARLY_ARENA_ID := "arena_cinzas_curta"

static func enabled() -> bool:
	return enabled_for_runtime(OS.has_feature("editor"))

static func enabled_for_runtime(editor_feature: bool) -> bool:
	return editor_feature or bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/arena_dev_fixtures_enabled", false))

static func state_fallback_result(result: Dictionary, active_save_type: String) -> Dictionary:
	return state_fallback_result_for_runtime(result, active_save_type, OS.has_feature("editor"))

static func state_fallback_result_for_runtime(result: Dictionary, active_save_type: String, editor_feature: bool) -> Dictionary:
	if bool(result.get("ok", false)) or not enabled_for_runtime(editor_feature):
		return result
	return state_result(active_save_type)

static func start_attempt_fallback_result(
	result: Dictionary,
	arena_id: String,
	difficulty_id: String,
	difficulty_tier: int,
	session_store: Object
) -> Dictionary:
	if bool(result.get("ok", false)) or not enabled():
		return result
	return _fixture_attempt_result(
		_fixture_start_attempt(arena_id, difficulty_id, difficulty_tier, session_store),
		_active_save_type(session_store)
	)

static func resolve_duel_fallback_result(
	result: Dictionary,
	attempt: Dictionary,
	duel_index: int,
	session_store: Object
) -> Dictionary:
	if bool(result.get("ok", false)) or not enabled():
		return result
	return _fixture_result(_fixture_resolve_duel(attempt, duel_index, session_store), _active_save_type(session_store))

static func choose_buff_fallback_result(
	result: Dictionary,
	attempt: Dictionary,
	buff_id: String,
	session_store: Object
) -> Dictionary:
	if bool(result.get("ok", false)) or not enabled():
		return result
	return _fixture_result(_fixture_choose_buff(attempt, buff_id, session_store), _active_save_type(session_store))

static func abandon_attempt_fallback_result(result: Dictionary, attempt: Dictionary, session_store: Object) -> Dictionary:
	if bool(result.get("ok", false)) or not enabled():
		return result
	return _fixture_result(_fixture_abandon_attempt(attempt), _active_save_type(session_store))

static func claim_summary_fallback_result(result: Dictionary, attempt: Dictionary, session_store: Object) -> Dictionary:
	if bool(result.get("ok", false)) or not enabled():
		return result
	return _fixture_result(_fixture_claim_summary(attempt), _active_save_type(session_store))

static func state_result(active_save_type: String) -> Dictionary:
	return _fixture_result(_base_arena_state(), active_save_type)

static func _base_arena_state() -> Dictionary:
	return {
		"ok": true,
		"schema_version": "pve_arena_state_v1",
		"dev_fixture": true,
		"arenas": [
			{"id": TUTORIAL_ARENA_ID, "display_name": "Tutorial: Cinzas Do Refugio", "difficulty_tier": 0, "duel_count": 1, "enabled": true, "unlocked": true},
			{"id": EARLY_ARENA_ID, "display_name": "Arena Curta Das Cinzas", "difficulty_tier": 1, "duel_count": 3, "enabled": true, "unlocked": true},
		],
		"active_attempt": null,
		"records": [],
		"reward_limits": {"daily_key": "dev", "weekly_key": "dev"},
		"summary": {},
	}

static func _fixture_start_attempt(arena_id: String, difficulty_id: String, difficulty_tier: int, session_store: Object) -> Dictionary:
	var duels_total := 1 if arena_id == TUTORIAL_ARENA_ID else 3
	return {
		"attempt_id": "dev-%s-%d" % [arena_id, difficulty_tier],
		"arena_id": arena_id,
		"difficulty_id": difficulty_id,
		"difficulty_tier": difficulty_tier,
		"current_step_index": 0,
		"duel_index": 0,
		"duel_count": duels_total,
		"state": "active",
		"locked_loadout_hash": "sha256:dev-loadout",
		"next_enemy_id": _enemy_id_for_duel(1),
		"duels_won": 0,
		"loadout_summary": {"label": _current_loadout_label(session_store)},
		"next_enemy": _enemy_for_duel(1),
		"temporary_buffs": [],
		"buff_offer": {},
	}

static func _fixture_resolve_duel(attempt: Dictionary, duel_index: int, session_store: Object) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	var duels_total := maxi(1, int(next_attempt.get("duel_count", next_attempt.get("duels_total", 1))))
	var won := mini(duel_index, duels_total)
	next_attempt["duels_won"] = won
	next_attempt["current_step_index"] = won
	next_attempt["last_completed_duel_index"] = duel_index
	next_attempt["duel_index"] = won
	next_attempt["next_enemy_id"] = _enemy_id_for_duel(mini(won + 1, duels_total))
	next_attempt["next_enemy"] = _enemy_for_duel(mini(won + 1, duels_total))
	if won >= duels_total:
		next_attempt["state"] = "completed"
		next_attempt["buff_offer"] = {}
		next_attempt["summary"] = _summary_for_attempt(next_attempt, 1.0)
	else:
		next_attempt["state"] = "awaiting_buff"
		next_attempt["buff_offer"] = _buff_offer_for_duel(duel_index)
	state["active_attempt"] = next_attempt
	state["last_duel"] = {
		"duel_index": duel_index,
		"battle_log": _fixture_battle_log(next_attempt, duel_index, session_store),
		"rewards": {"type": "ARENA_PVE_DEV_FIXTURE", "resources": {"xp": 12, "ossos": 2}},
	}
	state["summary"] = _as_dictionary(next_attempt.get("summary", {}))
	return state

static func _fixture_choose_buff(attempt: Dictionary, buff_id: String, session_store: Object) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	var buffs := _as_array(next_attempt.get("temporary_buffs", []))
	var chosen := _buff_by_id(_pending_buff_choices(next_attempt), buff_id)
	if chosen.is_empty():
		chosen = {"id": buff_id, "display_name": buff_id}
	buffs.append(chosen)
	next_attempt["temporary_buffs"] = buffs
	next_attempt["buff_offer"] = {}
	next_attempt["state"] = "active"
	next_attempt["next_enemy"] = _enemy_for_duel(int(next_attempt.get("current_step_index", next_attempt.get("duel_index", 0))) + 1)
	if not next_attempt.has("loadout_summary"):
		next_attempt["loadout_summary"] = {"label": _current_loadout_label(session_store)}
	state["active_attempt"] = next_attempt
	return state

static func _fixture_abandon_attempt(attempt: Dictionary) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	next_attempt["state"] = "abandoned"
	next_attempt["status"] = "abandoned"
	next_attempt["buff_offer"] = {}
	var summary := _summary_for_attempt(next_attempt, 0.0)
	summary["claimed"] = true
	summary["reward_already_applied"] = false
	summary["mutates_economy"] = false
	next_attempt["summary"] = summary
	state["active_attempt"] = next_attempt
	state["summary"] = summary
	return state

static func _fixture_claim_summary(attempt: Dictionary) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	next_attempt["state"] = "claimed"
	var summary := _summary_for_attempt(next_attempt, 1.0)
	summary["claimed"] = true
	summary["reward_already_applied"] = true
	summary["mutates_economy"] = false
	next_attempt["summary"] = summary
	state["active_attempt"] = next_attempt
	state["summary"] = summary
	return state

static func _fixture_result(state: Dictionary, active_save_type: String) -> Dictionary:
	return {
		"ok": true,
		"_client": {"save_type": active_save_type},
		"body": {
			"ok": true,
			"arena_state": state,
			"dev_fixture": true,
		},
	}

static func _fixture_attempt_result(attempt: Dictionary, active_save_type: String) -> Dictionary:
	return {
		"ok": true,
		"_client": {"save_type": active_save_type},
		"body": {
			"ok": true,
			"schema_version": "pve_arena_attempt_v1",
			"attempt": attempt,
			"dev_fixture": true,
		},
	}

static func _fixture_battle_log(attempt: Dictionary, duel_index: int, session_store: Object) -> Dictionary:
	var enemy := _enemy_for_duel(duel_index)
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "%s-duel-%d" % [str(attempt.get("attempt_id", "arena-dev")), duel_index],
		"seed": "arena-dev-%d" % duel_index,
		"mode": ProjectInfoScript.FIRST_SLICE_MODE,
		"duration": 12.0,
		"participants": {
			"player": {"id": "player", "display_name": _player_display_name(session_store)},
			"opponent": {"id": str(enemy.get("id", "arena_enemy")), "display_name": str(enemy.get("display_name", "Inimigo PVE")), "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 1.0, "seq": 2, "type": "weapon_attack", "source": "player", "target": "opponent", "damage": 12, "hp_after": 34},
			{"t": 2.0, "seq": 3, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
		],
		"metadata": {
			"mode": "PVE_ARENA_V1",
			"attempt_id": str(attempt.get("attempt_id", "")),
			"arena_id": str(attempt.get("arena_id", "")),
			"difficulty_tier": int(attempt.get("difficulty_tier", 0)),
			"duel_index": duel_index,
			"duel_count": int(attempt.get("duel_count", attempt.get("duels_total", 1))),
			"enemy_id": str(enemy.get("id", "pve_aprendiz_cinzas")),
			"temporary_buffs": _as_array(attempt.get("temporary_buffs", [])),
			"locked_loadout_hash": str(attempt.get("locked_loadout_hash", "sha256:dev-loadout")),
			"hp_reset": true,
		},
	}

static func _current_loadout_label(session_store: Object) -> String:
	var combat := {}
	if session_store.has_method("combat_build_snapshot"):
		combat = _as_dictionary(session_store.call("combat_build_snapshot"))
	if combat.is_empty():
		return "Build atual do save ativo."
	return "%s | %s spells | pocao %s" % [
		str(combat.get("weapon_id", combat.get("weapon_type", "Instrumento"))),
		_as_array(combat.get("spell_slots", combat.get("spellIds", []))).size(),
		"equipada" if not _as_array(combat.get("potion_slots", [])).is_empty() else "pendente",
	]

static func _player_display_name(session_store: Object) -> String:
	if session_store.has_method("player_display_name"):
		return str(session_store.call("player_display_name"))
	return "Player"

static func _enemy_for_duel(duel_index: int) -> Dictionary:
	var enemies := [
		{"id": "pve_aprendiz_cinzas", "display_name": "Aprendiz Das Cinzas", "archetype": "starter_instrument"},
		{"id": "pve_guardiao_barreira", "display_name": "Guardiao De Barreira", "archetype": "defensive_occultist"},
		{"id": "pve_sussurrador_veu", "display_name": "Sussurrador Do Veu", "archetype": "mental_controller"},
	]
	return Dictionary(enemies[clampi(duel_index - 1, 0, enemies.size() - 1)]).duplicate(true)

static func _enemy_id_for_duel(duel_index: int) -> String:
	return str(_enemy_for_duel(duel_index).get("id", "pve_aprendiz_cinzas"))

static func _buff_offer_for_duel(duel_index: int) -> Dictionary:
	return {
		"offer_id": "dev-offer-%d" % duel_index,
		"after_duel_index": duel_index,
		"choices": [
			{"id": "arena_buff_vitalidade_menor", "display_name": "Vitalidade Menor", "description": "+4% HP maximo"},
			{"id": "arena_buff_potencia_menor", "display_name": "Potencia Ritual Menor", "description": "+4% Potencia Ritual"},
			{"id": "arena_buff_guarda_menor", "display_name": "Guarda Menor", "description": "+4% Guarda"},
		],
	}

static func _buff_by_id(choices: Array, buff_id: String) -> Dictionary:
	for choice_variant: Variant in choices:
		var choice := _as_dictionary(choice_variant)
		if str(choice.get("id", "")) == buff_id:
			return choice.duplicate(true)
	return {}

static func _summary_for_attempt(attempt: Dictionary, clear_rate: float) -> Dictionary:
	return {
		"status": _attempt_state(attempt),
		"duels_won": int(attempt.get("duels_won", 0)),
		"duels_total": int(attempt.get("duel_count", attempt.get("duels_total", 1))),
		"clear_rate": clear_rate,
		"repeat_factor": 0.65,
		"reward_label": "XP, Ossos e recursos calibraveis da Arena PVE",
		"reward_already_applied": true,
		"mutates_economy": false,
	}

static func _pending_buff_choices(attempt: Dictionary) -> Array:
	var offer := _as_dictionary(attempt.get("buff_offer", {}))
	return _as_array(offer.get("choices", attempt.get("pending_buff_choices", [])))

static func _attempt_state(attempt: Dictionary) -> String:
	var state := str(attempt.get("state", attempt.get("status", ""))).strip_edges()
	return "active" if state == "" else state

static func _active_save_type(session_store: Object) -> String:
	return str(session_store.get("active_save_type"))

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
