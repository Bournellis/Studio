class_name OpenworldForestModel
extends RefCounted

const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")

const MODE_ID := "openworld"
const SLICE_ID := "forest"
const RULESET_ID := "openworld_forest_ruleset_v1"
const RULESET_VERSION := 1
const SCHEMA_VERSION := "openworld_forest_snapshot_v1"

const BASE_SPEED := 160.0
const BASE_CAPACITY := 20.0
const LOAD_PENALTY_START_RATIO := 0.6
const MIN_LOADED_SPEED := 80.0
const UPGRADED_MIN_LOADED_SPEED := 95.0
const COLLECTION_RADIUS := 40.0
const COLLECTION_CANCEL_RADIUS := 52.0
const GUIDANCE_VERSION := 1
const GUIDANCE_STEPS := [
	"Explore o Bosque sem pressa.",
	"Pare perto de um recurso para coletar.",
	"Seu bolso guarda o que voce encontra. Quando pesar, volte ao bau.",
	"Perto do bau, use Depositar para guardar tudo.",
	"Com materiais no bau, crie melhorias e pequenas estruturas.",
	"Quando quiser, encerre a visita e volte depois.",
]
const LEGACY_ITEM_IDS := {
	"ossos_preview": "resto_ritual",
	"po_osso_preview": "po_cinzento",
}

var pocket: Dictionary = {}
var chest: Dictionary = {}
var upgrades: Dictionary = {}
var structures: Dictionary = {}
var active_collection: Dictionary = {}
var guidance: Dictionary = _default_guidance()
var last_message := ""

func reset() -> void:
	pocket = {}
	chest = {}
	upgrades = {}
	structures = {}
	active_collection = {}
	guidance = _default_guidance()
	last_message = "Bosque local reiniciado."

static func item_definitions() -> Dictionary:
	return RulesetScript.item_definitions()

static func recipes() -> Dictionary:
	return RulesetScript.recipes()

func snapshot() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"mode_id": MODE_ID,
		"slice_id": SLICE_ID,
		"ruleset_id": RULESET_ID,
		"ruleset_version": RULESET_VERSION,
		"pocket": pocket.duplicate(true),
		"chest": chest.duplicate(true),
		"upgrades": upgrades.duplicate(true),
		"structures": structures.duplicate(true),
		"capacity": capacity(),
		"pocket_weight": pocket_weight(),
		"current_speed": current_speed(),
		"guidance": guidance_state(),
		"last_message": last_message,
	}

func apply_snapshot(snapshot_payload: Dictionary) -> void:
	var ruleset_id := str(snapshot_payload.get("ruleset_id", ""))
	if ruleset_id != "" and ruleset_id != RULESET_ID:
		return
	apply_authoritative_patch(snapshot_payload, false)
	if not snapshot_payload.has("last_message"):
		last_message = "Bosque retomado."

func apply_authoritative_patch(snapshot_patch: Dictionary, preserve_active_collection: bool = true) -> void:
	if snapshot_patch.has("pocket"):
		pocket = _positive_int_dictionary(snapshot_patch.get("pocket", {}))
	if snapshot_patch.has("chest"):
		chest = _positive_int_dictionary(snapshot_patch.get("chest", {}))
	if snapshot_patch.has("upgrades"):
		upgrades = _boolean_dictionary(snapshot_patch.get("upgrades", {}))
	if snapshot_patch.has("structures"):
		structures = _boolean_dictionary(snapshot_patch.get("structures", {}))
	_sync_structure_upgrade_aliases()
	if snapshot_patch.has("guidance"):
		guidance = _guidance_dictionary(snapshot_patch.get("guidance", {}))
	if snapshot_patch.has("active_collection"):
		active_collection = _as_dictionary(snapshot_patch.get("active_collection", {})).duplicate(true)
	elif not preserve_active_collection:
		active_collection = {}
	if snapshot_patch.has("last_message"):
		last_message = str(snapshot_patch.get("last_message", last_message))

func result_payload(session_seconds: float = 0.0) -> Dictionary:
	return {
		"mode_id": MODE_ID,
		"slice_id": SLICE_ID,
		"ruleset_id": RULESET_ID,
		"ruleset_version": RULESET_VERSION,
		"session_seconds": maxf(0.0, session_seconds),
		"deposited_items": chest.duplicate(true),
		"local_upgrades": upgrades.duplicate(true),
		"local_structures": structures.duplicate(true),
		"guidance": guidance_state(),
		"activity_score": activity_score(),
	}

func visit_summary_text(session_seconds: float = 0.0, reward_text: String = "Sem recompensa.") -> String:
	var parts := PackedStringArray()
	parts.append("Resumo da visita: %s no Bosque." % _format_seconds(session_seconds))
	parts.append("Bau: %s." % inventory_summary_text(chest, "nada depositado"))
	parts.append("Criacoes: %s." % upgrades_summary_text("nenhuma criacao"))
	var clean_reward := reward_text.strip_edges()
	if clean_reward == "":
		clean_reward = "Sem recompensa."
	if not clean_reward.ends_with("."):
		clean_reward += "."
	parts.append(clean_reward)
	return " ".join(parts)

func activity_score() -> int:
	var score := 0
	for key: String in chest.keys():
		score += int(chest.get(key, 0)) * maxi(1, int(round(item_weight(key))))
	for key: String in upgrades.keys():
		if bool(upgrades.get(key, false)):
			score += 5
	return score

func capacity() -> float:
	return BASE_CAPACITY + (5.0 if has_upgrade("bolsa_simples_1") else 0.0)

func min_loaded_speed() -> float:
	return UPGRADED_MIN_LOADED_SPEED if has_upgrade("trilha_aberta_1") else MIN_LOADED_SPEED

func pocket_weight() -> float:
	return inventory_weight(pocket)

func pocket_load_ratio() -> float:
	if capacity() <= 0.0:
		return 0.0
	return clampf(pocket_weight() / capacity(), 0.0, 1.0)

func pocket_status_text() -> String:
	var weight := pocket_weight()
	var load_ratio := pocket_load_ratio()
	var prefix := "Bolso %.1f/%.1f" % [weight, capacity()]
	if pocket.is_empty():
		return "%s vazio" % prefix
	if weight >= capacity() - 0.001:
		return "%s cheio; volte ao bau" % prefix
	if load_ratio >= 0.82:
		return "%s quase cheio; planeje deposito" % prefix
	if load_ratio >= LOAD_PENALTY_START_RATIO:
		return "%s pesado; velocidade reduzida" % prefix
	return "%s confortavel" % prefix

func inventory_weight(source: Dictionary) -> float:
	var total := 0.0
	for key: String in source.keys():
		total += item_weight(key) * float(source.get(key, 0))
	return total

func current_speed() -> float:
	var load_ratio := 0.0 if capacity() <= 0.0 else pocket_weight() / capacity()
	if load_ratio <= LOAD_PENALTY_START_RATIO:
		return BASE_SPEED
	var penalty_ratio := clampf(
		(load_ratio - LOAD_PENALTY_START_RATIO) / (1.0 - LOAD_PENALTY_START_RATIO),
		0.0,
		1.0
	)
	return lerpf(BASE_SPEED, min_loaded_speed(), penalty_ratio)

func item_weight(item_id: String) -> float:
	return float(_item_definition(canonical_item_id(item_id)).get("weight", 0.0))

func item_display_name(item_id: String) -> String:
	var clean_item_id := canonical_item_id(item_id)
	var display_name := str(_item_definition(clean_item_id).get("display_name", clean_item_id))
	if display_name.ends_with(" preview"):
		return display_name.substr(0, display_name.length() - " preview".length())
	if display_name.ends_with(" Preview"):
		return display_name.substr(0, display_name.length() - " Preview".length())
	return display_name

func recipe_display_name(recipe_id: String) -> String:
	return str(_recipe(recipe_id).get("display_name", recipe_id))

func upgrade_display_name(upgrade_id: String) -> String:
	for recipe_id: String in recipes().keys():
		var recipe := _recipe(recipe_id)
		if str(recipe.get("upgrade_id", "")) == upgrade_id:
			return str(recipe.get("display_name", upgrade_id))
	return upgrade_id

func gather_duration(item_id: String) -> float:
	var duration := float(_item_definition(item_id).get("gather_time", 1.0))
	if has_upgrade("maos_rituais_1"):
		duration *= 0.9
	return maxf(0.1, duration)

func can_carry(item_id: String, quantity: int = 1) -> bool:
	var clean_item_id := canonical_item_id(item_id)
	if not item_definitions().has(clean_item_id):
		return false
	return pocket_weight() + item_weight(clean_item_id) * float(maxi(1, quantity)) <= capacity() + 0.001

func add_to_pocket(item_id: String, quantity: int = 1) -> Dictionary:
	var clean_item_id := canonical_item_id(item_id)
	var amount := maxi(1, quantity)
	if not item_definitions().has(clean_item_id):
		last_message = "Recurso desconhecido: %s." % clean_item_id
		return {"ok": false, "reason": "unknown_item", "message": last_message}
	if not can_carry(clean_item_id, amount):
		last_message = "Bolso cheio. Volte ao bau para depositar."
		return {"ok": false, "reason": "pocket_full", "message": last_message}
	pocket[clean_item_id] = int(pocket.get(clean_item_id, 0)) + amount
	last_message = "+%d %s no bolso. %s." % [amount, item_display_name(clean_item_id), pocket_status_text()]
	return {"ok": true, "item_id": clean_item_id, "quantity": amount, "message": last_message}

func deposit_all() -> Dictionary:
	var moved := pocket.duplicate(true)
	for key: String in pocket.keys():
		chest[key] = int(chest.get(key, 0)) + int(pocket.get(key, 0))
	pocket = {}
	active_collection = {}
	if not moved.is_empty():
		last_message = "Bolso depositado no bau: %s." % inventory_summary_text(moved, "nada para depositar")
	else:
		last_message = "Bolso vazio; nada para depositar."
	return {"ok": true, "moved": moved, "chest": chest.duplicate(true), "message": last_message}

func can_craft(recipe_id: String) -> bool:
	var recipe := _recipe(recipe_id)
	if recipe.is_empty():
		return false
	if has_upgrade(str(recipe.get("upgrade_id", ""))):
		return false
	var cost := _as_dictionary(recipe.get("cost", {}))
	for key: String in cost.keys():
		if int(chest.get(key, 0)) < int(cost.get(key, 0)):
			return false
	return true

func craft(recipe_id: String) -> Dictionary:
	var recipe := _recipe(recipe_id)
	if recipe.is_empty():
		last_message = "Receita local desconhecida."
		return {"ok": false, "reason": "unknown_recipe", "message": last_message}
	if not can_craft(recipe_id):
		last_message = "Materiais locais insuficientes ou upgrade ja ativo."
		return {"ok": false, "reason": "cannot_craft", "message": last_message}
	var cost := _as_dictionary(recipe.get("cost", {}))
	for key: String in cost.keys():
		chest[key] = maxi(0, int(chest.get(key, 0)) - int(cost.get(key, 0)))
	var upgrade_id := str(recipe.get("upgrade_id", "")).strip_edges()
	if upgrade_id != "":
		upgrades[upgrade_id] = true
		if upgrade_id == "fogueira_estavel_1":
			structures[upgrade_id] = true
	var output := _as_dictionary(recipe.get("output", {}))
	for key: String in output.keys():
		chest[key] = int(chest.get(key, 0)) + int(output.get(key, 0))
	last_message = "Criado: %s." % str(recipe.get("display_name", recipe_id))
	return {"ok": true, "recipe_id": recipe_id, "upgrade_id": upgrade_id, "message": last_message}

func has_upgrade(upgrade_id: String) -> bool:
	var clean_id := upgrade_id.strip_edges()
	if clean_id == "fogueira_estavel_1" and bool(structures.get(clean_id, false)):
		return true
	return bool(upgrades.get(clean_id, false))

func available_craft_count() -> int:
	var count := 0
	for recipe_id: String in recipes().keys():
		if can_craft(recipe_id):
			count += 1
	return count

func first_available_recipe_name() -> String:
	for recipe_id: String in recipes().keys():
		if can_craft(recipe_id):
			return recipe_display_name(recipe_id)
	return ""

func recipe_state_text(recipe_id: String) -> String:
	var recipe := _recipe(recipe_id)
	if recipe.is_empty():
		return "Receita indisponivel."
	var upgrade_id := str(recipe.get("upgrade_id", "")).strip_edges()
	if upgrade_id != "" and has_upgrade(upgrade_id):
		return "Ja criado."
	var missing := recipe_missing_text(recipe_id)
	if missing != "":
		return "Falta: %s." % missing
	return "Pronto para criar."

func recipe_missing_text(recipe_id: String) -> String:
	var recipe := _recipe(recipe_id)
	if recipe.is_empty():
		return ""
	var cost := _as_dictionary(recipe.get("cost", {}))
	var parts := PackedStringArray()
	for key: String in _sorted_keys(cost):
		var missing := int(cost.get(key, 0)) - int(chest.get(key, 0))
		if missing > 0:
			parts.append("%s x%d" % [item_display_name(key), missing])
	return ", ".join(parts)

func inventory_summary_text(source: Dictionary, empty_text: String = "-") -> String:
	if source.is_empty():
		return empty_text
	var parts := PackedStringArray()
	for key: String in _sorted_keys(source):
		parts.append("%s x%d" % [item_display_name(key), int(source.get(key, 0))])
	return ", ".join(parts)

func upgrades_summary_text(empty_text: String = "-") -> String:
	var active := PackedStringArray()
	for key: String in _sorted_keys(upgrades):
		if bool(upgrades.get(key, false)):
			active.append(upgrade_display_name(key))
	for key: String in _sorted_keys(structures):
		if bool(structures.get(key, false)) and not bool(upgrades.get(key, false)):
			active.append(upgrade_display_name(key))
	return empty_text if active.is_empty() else ", ".join(active)

func guidance_state() -> Dictionary:
	guidance = _guidance_dictionary(guidance)
	return guidance.duplicate(true)

func guidance_text() -> String:
	if not guidance_visible():
		return ""
	var step := int(guidance_state().get("current_step", 1))
	return str(GUIDANCE_STEPS[step - 1]) if step >= 1 and step <= GUIDANCE_STEPS.size() else ""

func guidance_visible() -> bool:
	var state := guidance_state()
	var step := int(state.get("current_step", 1))
	return not bool(state.get("dismissed", false)) and step >= 1 and step <= GUIDANCE_STEPS.size()

func mark_guidance_step(step: int) -> bool:
	if step < 1 or step > GUIDANCE_STEPS.size():
		return false
	var state := guidance_state()
	if int(state.get("current_step", 1)) != step:
		return false
	var completed: Array = _as_array(state.get("completed_steps", []))
	var changed := false
	if not completed.has(step):
		completed.append(step)
		completed.sort()
		changed = true
	var next_step := mini(GUIDANCE_STEPS.size() + 1, max(step + 1, int(state.get("current_step", 1))))
	if int(state.get("current_step", 1)) != next_step:
		state["current_step"] = next_step
		changed = true
	if next_step > GUIDANCE_STEPS.size() and not bool(state.get("dismissed", false)):
		state["dismissed"] = true
		changed = true
	state["completed_steps"] = completed
	if changed:
		state["last_seen_at"] = _now_iso()
		guidance = _guidance_dictionary(state)
	return changed

func advance_guidance() -> bool:
	if not guidance_visible():
		return false
	return mark_guidance_step(int(guidance_state().get("current_step", 1)))

func dismiss_guidance() -> bool:
	var state := guidance_state()
	if bool(state.get("dismissed", false)):
		return false
	state["dismissed"] = true
	state["last_seen_at"] = _now_iso()
	guidance = _guidance_dictionary(state)
	return true

func reopen_guidance() -> bool:
	var state := guidance_state()
	if int(state.get("current_step", 1)) > GUIDANCE_STEPS.size() or _as_array(state.get("completed_steps", [])).size() >= GUIDANCE_STEPS.size():
		state["current_step"] = 1
		state["completed_steps"] = []
	state["dismissed"] = false
	state["last_seen_at"] = _now_iso()
	guidance = _guidance_dictionary(state)
	return true

func start_collection(item_id: String) -> Dictionary:
	var clean_item_id := canonical_item_id(item_id)
	if not item_definitions().has(clean_item_id):
		last_message = "Recurso desconhecido."
		return {"ok": false, "reason": "unknown_item", "message": last_message}
	if not can_carry(clean_item_id):
		last_message = "Bolso cheio. Volte ao bau para depositar."
		return {"ok": false, "reason": "pocket_full", "message": last_message}
	active_collection = {
		"item_id": clean_item_id,
		"elapsed": 0.0,
		"duration": gather_duration(clean_item_id),
	}
	last_message = "Parado perto de %s. Coletando..." % item_display_name(clean_item_id)
	return {"ok": true, "item_id": clean_item_id, "duration": active_collection["duration"], "message": last_message}

func advance_collection(delta: float, moved: bool = false, distance: float = 0.0, commit_to_pocket: bool = true) -> Dictionary:
	if active_collection.is_empty():
		return {"ok": false, "reason": "no_active_collection"}
	if moved or distance > COLLECTION_CANCEL_RADIUS:
		return cancel_collection("moved")
	active_collection["elapsed"] = float(active_collection.get("elapsed", 0.0)) + maxf(0.0, delta)
	var duration := float(active_collection.get("duration", 0.1))
	if float(active_collection.get("elapsed", 0.0)) < duration:
		return {
			"ok": true,
			"completed": false,
			"progress": collection_progress(),
			"message": last_message,
		}
	var item_id := str(active_collection.get("item_id", ""))
	active_collection = {}
	if not commit_to_pocket:
		last_message = "Coleta enviada ao servidor."
		return {
			"ok": true,
			"completed": true,
			"item_id": item_id,
			"quantity": 1,
			"progress": 1.0,
			"message": last_message,
		}
	var added := add_to_pocket(item_id, 1)
	added["completed"] = bool(added.get("ok", false))
	added["progress"] = 1.0 if bool(added.get("ok", false)) else 0.0
	return added

func cancel_collection(reason: String = "cancelled") -> Dictionary:
	if active_collection.is_empty():
		return {"ok": false, "reason": "no_active_collection"}
	active_collection = {}
	last_message = "Coleta cancelada." if reason != "moved" else "Voce se moveu e a coleta parou."
	return {"ok": true, "cancelled": true, "reason": reason, "message": last_message}

func collection_progress() -> float:
	if active_collection.is_empty():
		return 0.0
	var duration := maxf(0.1, float(active_collection.get("duration", 0.1)))
	return clampf(float(active_collection.get("elapsed", 0.0)) / duration, 0.0, 1.0)

func _item_definition(item_id: String) -> Dictionary:
	return _as_dictionary(item_definitions().get(canonical_item_id(item_id), {}))

func _recipe(recipe_id: String) -> Dictionary:
	return _as_dictionary(recipes().get(recipe_id, {}))

func _positive_int_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	var source := _as_dictionary(value)
	for key: String in source.keys():
		var clean_key := canonical_item_id(key)
		var amount := int(source.get(key, 0))
		if amount > 0 and item_definitions().has(clean_key):
			result[clean_key] = int(result.get(clean_key, 0)) + amount
	return result

func _boolean_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	var source := _as_dictionary(value)
	for key: String in source.keys():
		if bool(source.get(key, false)):
			result[key] = true
	return result

func _sync_structure_upgrade_aliases() -> void:
	if bool(upgrades.get("fogueira_estavel_1", false)):
		structures["fogueira_estavel_1"] = true
	if bool(structures.get("fogueira_estavel_1", false)):
		upgrades["fogueira_estavel_1"] = true

func _guidance_dictionary(value: Variant) -> Dictionary:
	var source := _default_guidance()
	var payload := _as_dictionary(value)
	source["version"] = GUIDANCE_VERSION
	source["current_step"] = clampi(int(payload.get("current_step", source.get("current_step", 1))), 1, GUIDANCE_STEPS.size() + 1)
	source["dismissed"] = bool(payload.get("dismissed", source.get("dismissed", false)))
	source["last_seen_at"] = str(payload.get("last_seen_at", source.get("last_seen_at", "")))
	var completed: Array = []
	var raw_completed: Variant = payload.get("completed_steps", source.get("completed_steps", []))
	if raw_completed is Dictionary:
		for key: Variant in raw_completed.keys():
			if bool(raw_completed.get(key, false)):
				var step := clampi(int(key), 1, GUIDANCE_STEPS.size())
				if not completed.has(step):
					completed.append(step)
	elif raw_completed is Array:
		for value_step: Variant in raw_completed:
			var step := clampi(int(value_step), 1, GUIDANCE_STEPS.size())
			if not completed.has(step):
				completed.append(step)
	completed.sort()
	source["completed_steps"] = completed
	if completed.size() >= GUIDANCE_STEPS.size():
		source["current_step"] = GUIDANCE_STEPS.size() + 1
		source["dismissed"] = true
	return source

static func _default_guidance() -> Dictionary:
	return {
		"version": GUIDANCE_VERSION,
		"current_step": 1,
		"completed_steps": [],
		"dismissed": false,
		"last_seen_at": "",
	}

static func _now_iso() -> String:
	return Time.get_datetime_string_from_system(true)

static func _format_seconds(seconds: float) -> String:
	var total := maxi(0, int(round(seconds)))
	var minutes := total / 60
	var remainder := total % 60
	if minutes <= 0:
		return "%ds" % remainder
	return "%dm%02ds" % [minutes, remainder]

static func _sorted_keys(source: Dictionary) -> PackedStringArray:
	var keys := PackedStringArray()
	for key: String in source.keys():
		keys.append(key)
	keys.sort()
	return keys

static func canonical_item_id(item_id: String) -> String:
	var clean_id := item_id.strip_edges()
	return str(LEGACY_ITEM_IDS.get(clean_id, clean_id))

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return value
	return []
