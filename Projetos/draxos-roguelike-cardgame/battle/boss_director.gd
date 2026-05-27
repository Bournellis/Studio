extends RefCounted

static func phase_state(enemy_health: int, enemy_max_health: int) -> Dictionary:
	var ratio: float = 1.0 if enemy_max_health <= 0 else float(enemy_health) / float(enemy_max_health)
	if ratio > 0.66:
		return {"label": "Fase 1 - invocacao", "next_trigger": "HP <= 66% ou proxima manutencao."}
	if ratio > 0.33:
		return {"label": "Fase 2 - pressao", "next_trigger": "HP <= 33% ou mesa inimiga vazia."}
	return {"label": "Fase 3 - ruptura", "next_trigger": "Especial final em manutencoes futuras."}

static func next_hook_description(boss_phase_hooks: Array[Dictionary], boss_phase_hook_state: Dictionary) -> String:
	for index: int in range(boss_phase_hooks.size()):
		var hook: Dictionary = boss_phase_hooks[index]
		var hook_id: String = str(hook.get("id", "hook_%d" % index))
		if bool(boss_phase_hook_state.get(hook_id, false)):
			continue
		var description: String = str(hook.get("description", hook.get("action", "")))
		if description != "":
			return description
	return ""
