extends RefCounted

static func state_from_body(body: Dictionary, current_arena_state: Dictionary) -> Dictionary:
	var explicit_state := _as_dictionary(body.get("arena_state", {}))
	if not explicit_state.is_empty():
		return normalize_state(explicit_state)
	if str(body.get("schema_version", "")) == "pve_arena_state_v1":
		return normalize_state(body)
	if str(body.get("schema_version", "")) == "arena_list_response_v1":
		var list_state := empty_state()
		list_state["arenas"] = normalize_arena_list(_as_array(body.get("arenas", [])))
		list_state["progress"] = _as_dictionary(body.get("progress", {})).duplicate(true)
		list_state["records"] = [_as_dictionary(body.get("progress", {})).duplicate(true)]
		list_state["attempts"] = normalize_arena_attempts(_as_array(body.get("attempts", [])))
		for attempt_variant: Variant in _as_array(list_state.get("attempts", [])):
			var attempt := _as_dictionary(attempt_variant)
			if str(attempt.get("status", "")) == "active":
				list_state["active_attempt"] = attempt.duplicate(true)
				break
		return list_state
	if str(body.get("schema_version", "")) == "pve_arena_attempt_v1" or body.get("attempt", null) is Dictionary:
		var state := current_arena_state.duplicate(true)
		if state.is_empty():
			state = empty_state()
		var step := _as_dictionary(body.get("step", {}))
		state["active_attempt"] = normalize_arena_attempt(_as_dictionary(body.get("attempt", {})), step)
		if body.get("progress", null) is Dictionary:
			state["progress"] = _as_dictionary(body.get("progress", {})).duplicate(true)
			state["records"] = [_as_dictionary(body.get("progress", {})).duplicate(true)]
		if body.get("battle_log", null) is Dictionary or body.get("rewards", null) is Dictionary or body.get("buff_offer", null) is Dictionary or not step.is_empty():
			var battle_log := _as_dictionary(body.get("battle_log", step.get("battle_log", {})))
			var reward_payload := _as_dictionary(body.get("rewards", step.get("reward_payload", body.get("reward_payload", {}))))
			state["last_duel"] = {
				"battle_log": battle_log.duplicate(true),
				"rewards": reward_payload.duplicate(true),
				"buff_offer": buff_offer_from_step(step).duplicate(true),
			}
		var summary := summary_from_body(body, _as_dictionary(state.get("active_attempt", {})))
		if not summary.is_empty():
			state["summary"] = summary
		return state
	return {}

static func normalize_state(state: Dictionary) -> Dictionary:
	var normalized := state.duplicate(true)
	normalized["arenas"] = normalize_arena_list(_as_array(normalized.get("arenas", [])))
	var active_attempt := _as_dictionary(normalized.get("active_attempt", {}))
	if not active_attempt.is_empty():
		normalized["active_attempt"] = normalize_arena_attempt(active_attempt, {})
	return normalized

static func empty_state() -> Dictionary:
	return {
		"ok": true,
		"schema_version": "pve_arena_state_v1",
		"arenas": [],
		"active_attempt": null,
		"records": [],
		"reward_limits": {},
		"summary": {},
	}

static func normalize_arena_list(arenas: Array) -> Array:
	var output: Array = []
	for arena_variant: Variant in arenas:
		var arena := _as_dictionary(arena_variant).duplicate(true)
		arena["duel_count"] = int(arena.get("duel_count", arena.get("max_steps", 1)))
		arena["difficulty_tier"] = int(arena.get("difficulty_tier", arena.get("difficulty_rank", 0)))
		arena["difficulties"] = normalize_arena_difficulties(arena, _as_array(arena.get("difficulties", [])))
		var selected_difficulty := default_arena_difficulty(arena)
		if not selected_difficulty.is_empty():
			arena["difficulty_id"] = str(selected_difficulty.get("difficulty_id", arena.get("difficulty_id", ""))).strip_edges()
			arena["difficulty_tier"] = int(selected_difficulty.get("difficulty_tier", selected_difficulty.get("difficulty_rank", arena.get("difficulty_tier", 0))))
			arena["max_steps"] = int(selected_difficulty.get("max_steps", arena.get("max_steps", arena.get("duel_count", 1))))
			arena["duel_count"] = int(arena.get("duel_count", arena.get("max_steps", selected_difficulty.get("max_steps", 1))))
			if not arena.has("reward_preview"):
				arena["reward_preview"] = _as_dictionary(selected_difficulty.get("reward_preview", {}))
			if not arena.has("clear_rate_target"):
				arena["clear_rate_target"] = _as_dictionary(selected_difficulty.get("clear_rate_target", {}))
		if not arena.has("unlocked"):
			arena["unlocked"] = bool(arena.get("enabled", true))
		if not bool(arena.get("unlocked", true)) and str(arena.get("locked_reason", "")).strip_edges() == "":
			arena["locked_reason"] = locked_reason(arena)
		output.append(arena)
	return output

static func normalize_arena_difficulties(arena: Dictionary, difficulties: Array) -> Array:
	var output: Array = []
	if difficulties.is_empty():
		var fallback := arena.duplicate(true)
		fallback["difficulty_id"] = str(fallback.get("difficulty_id", fallback.get("default_difficulty_id", ""))).strip_edges()
		fallback["difficulty_tier"] = int(fallback.get("difficulty_tier", fallback.get("difficulty_rank", 0)))
		fallback["max_steps"] = int(fallback.get("max_steps", fallback.get("duel_count", 1)))
		fallback["unlocked"] = bool(fallback.get("unlocked", fallback.get("enabled", true)))
		output.append(fallback)
		return output
	for difficulty_variant: Variant in difficulties:
		var difficulty := _as_dictionary(difficulty_variant).duplicate(true)
		difficulty["difficulty_id"] = str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
		difficulty["difficulty_tier"] = int(difficulty.get("difficulty_tier", difficulty.get("difficulty_rank", 0)))
		difficulty["max_steps"] = int(difficulty.get("max_steps", difficulty.get("enemy_count", arena.get("duel_count", 1))))
		if not difficulty.has("unlocked"):
			difficulty["unlocked"] = bool(arena.get("unlocked", arena.get("enabled", true)))
		if not bool(difficulty.get("unlocked", true)) and str(difficulty.get("locked_reason", "")).strip_edges() == "":
			difficulty["locked_reason"] = locked_reason(difficulty)
		output.append(difficulty)
	return output

static func default_arena_difficulty(arena: Dictionary) -> Dictionary:
	var difficulties := _as_array(arena.get("difficulties", []))
	if difficulties.is_empty():
		return {}
	var default_id := str(arena.get("default_difficulty_id", "")).strip_edges()
	for difficulty_variant: Variant in difficulties:
		var difficulty := _as_dictionary(difficulty_variant)
		if default_id != "" and str(difficulty.get("difficulty_id", "")).strip_edges() == default_id:
			return difficulty.duplicate(true)
	return _as_dictionary(difficulties[0]).duplicate(true)

static func normalize_arena_attempts(attempts: Array) -> Array:
	var output: Array = []
	for attempt_variant: Variant in attempts:
		output.append(normalize_arena_attempt(_as_dictionary(attempt_variant), {}))
	return output

static func normalize_arena_attempt(attempt: Dictionary, step: Dictionary = {}) -> Dictionary:
	if attempt.is_empty():
		return {}
	var normalized := attempt.duplicate(true)
	var attempt_id := str(normalized.get("attempt_id", normalized.get("id", ""))).strip_edges()
	normalized["attempt_id"] = attempt_id
	normalized["duel_count"] = int(normalized.get("duel_count", normalized.get("max_steps", 1)))
	normalized["duel_index"] = int(normalized.get("duel_index", normalized.get("current_step_index", 0)))
	normalized["difficulty_tier"] = int(normalized.get("difficulty_tier", normalized.get("difficulty_rank", 0)))
	normalized["temporary_buffs"] = _as_array(normalized.get("temporary_buffs", normalized.get("active_buffs", [])))
	normalized["duels_won"] = int(normalized.get("duels_won", normalized.get("current_step_index", 0)))
	if not normalized.has("locked_loadout_hash"):
		normalized["locked_loadout_hash"] = "server:%s" % attempt_id
	if not normalized.has("loadout_summary"):
		normalized["loadout_summary"] = {"label": "Loadout travado no servidor para esta tentativa."}
	if not step.is_empty():
		var buff_offer := buff_offer_from_step(step)
		if not buff_offer.is_empty():
			normalized["buff_offer"] = buff_offer
			normalized["state"] = "awaiting_buff"
		elif str(normalized.get("state", "")).strip_edges() == "":
			normalized["state"] = str(normalized.get("status", "active"))
	elif str(normalized.get("state", "")).strip_edges() == "":
		normalized["state"] = str(normalized.get("status", "active"))
	normalized["next_enemy_id"] = next_enemy_id(normalized)
	normalized["next_enemy"] = {
		"id": str(normalized.get("next_enemy_id", "")),
		"display_name": str(normalized.get("next_enemy_id", "Proximo inimigo")),
	}
	return normalized

static func buff_offer_from_step(step: Dictionary) -> Dictionary:
	var choices := _as_array(step.get("buff_options", []))
	if choices.is_empty():
		return {}
	return {
		"offer_id": "step-%s" % str(step.get("step_index", "0")),
		"step_index": int(step.get("step_index", 0)),
		"after_duel_index": int(step.get("step_index", 0)),
		"choices": choices,
	}

static func summary_from_body(body: Dictionary, attempt: Dictionary) -> Dictionary:
	var explicit_summary := _as_dictionary(body.get("summary", {}))
	if not explicit_summary.is_empty():
		return explicit_summary.duplicate(true)
	var status := str(attempt.get("status", attempt.get("state", "")))
	if status not in ["completed", "failed", "abandoned", "claimed"]:
		return {}
	var reward_payload := _as_dictionary(body.get("reward_payload", attempt.get("reward_payload", {})))
	return {
		"status": status,
		"duels_won": int(attempt.get("duels_won", attempt.get("current_step_index", 0))),
		"duels_total": int(attempt.get("duel_count", attempt.get("max_steps", 1))),
		"repeat_factor": "aplicado pelo servidor" if bool(reward_payload.get("repeat_reduction_applied", false)) else "first clear/record",
		"reward_label": str(reward_payload.get("reason", "recompensa da Arena PVE")),
	}

static func next_enemy_id(attempt: Dictionary) -> String:
	var sequence := _as_array(attempt.get("enemy_sequence", []))
	if sequence.is_empty():
		return ""
	var index := clampi(int(attempt.get("current_step_index", attempt.get("duel_index", 0))), 0, sequence.size() - 1)
	return str(sequence[index])

static func locked_reason(arena: Dictionary) -> String:
	for key: String in ["unlock_reason", "blocked_message", "blocked_reason"]:
		var reason := str(arena.get(key, "")).strip_edges()
		if reason != "":
			return reason
	var required_difficulty := int(arena.get("required_completed_difficulty", -1))
	if required_difficulty == 0:
		return "Conclua tutorial."
	if required_difficulty > 0:
		return "Conclua dificuldade %d." % required_difficulty
	var unlock_rule := str(arena.get("unlock_rule", "")).strip_edges()
	if unlock_rule != "":
		return "Conclua arenas anteriores."
	var unlock := _as_dictionary(arena.get("unlock", {}))
	var required_arena := str(unlock.get("arena_id", "")).strip_edges()
	if required_arena != "":
		return "Conclua a arena anterior."
	return "Bloqueada."

static func arena_by_id(arena_state: Dictionary, arena_id: String) -> Dictionary:
	var normalized_id := arena_id.strip_edges()
	if normalized_id == "":
		return {}
	for arena_variant: Variant in _as_array(arena_state.get("arenas", [])):
		var arena := _as_dictionary(arena_variant)
		if str(arena.get("id", "")).strip_edges() == normalized_id:
			return arena.duplicate(true)
	return {}

static func arena_difficulty_by_id(arena_state: Dictionary, arena_id: String, difficulty_id: String = "") -> Dictionary:
	var arena := arena_by_id(arena_state, arena_id)
	if arena.is_empty():
		return {}
	var normalized_difficulty := difficulty_id.strip_edges()
	var default_id := str(arena.get("default_difficulty_id", arena.get("difficulty_id", ""))).strip_edges()
	for difficulty_variant: Variant in _as_array(arena.get("difficulties", [])):
		var difficulty := _as_dictionary(difficulty_variant)
		var candidate_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
		if candidate_id == "":
			continue
		if normalized_difficulty == "" and candidate_id == default_id:
			return difficulty.duplicate(true)
		if normalized_difficulty != "" and candidate_id == normalized_difficulty:
			return difficulty.duplicate(true)
	if normalized_difficulty == "":
		return arena.duplicate(true)
	return {}

static func active_attempt(arena_state: Dictionary) -> Dictionary:
	return _as_dictionary(arena_state.get("active_attempt", {})).duplicate(true)

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
