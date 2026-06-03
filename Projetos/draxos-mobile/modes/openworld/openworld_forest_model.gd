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

var pocket: Dictionary = {}
var chest: Dictionary = {}
var upgrades: Dictionary = {}
var active_collection: Dictionary = {}
var last_message := ""

func reset() -> void:
	pocket = {}
	chest = {}
	upgrades = {}
	active_collection = {}
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
		"capacity": capacity(),
		"pocket_weight": pocket_weight(),
		"current_speed": current_speed(),
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
	if not preserve_active_collection:
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
		"activity_score": activity_score(),
	}

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
	return float(_item_definition(item_id).get("weight", 0.0))

func item_display_name(item_id: String) -> String:
	var display_name := str(_item_definition(item_id).get("display_name", item_id))
	if display_name.ends_with(" preview"):
		return display_name.substr(0, display_name.length() - " preview".length())
	if display_name.ends_with(" Preview"):
		return display_name.substr(0, display_name.length() - " Preview".length())
	return display_name

func gather_duration(item_id: String) -> float:
	var duration := float(_item_definition(item_id).get("gather_time", 1.0))
	if has_upgrade("maos_rituais_1"):
		duration *= 0.9
	return maxf(0.1, duration)

func can_carry(item_id: String, quantity: int = 1) -> bool:
	if not item_definitions().has(item_id):
		return false
	return pocket_weight() + item_weight(item_id) * float(maxi(1, quantity)) <= capacity() + 0.001

func add_to_pocket(item_id: String, quantity: int = 1) -> Dictionary:
	var amount := maxi(1, quantity)
	if not item_definitions().has(item_id):
		last_message = "Recurso desconhecido: %s." % item_id
		return {"ok": false, "reason": "unknown_item", "message": last_message}
	if not can_carry(item_id, amount):
		last_message = "Bolso cheio. Volte ao bau."
		return {"ok": false, "reason": "pocket_full", "message": last_message}
	pocket[item_id] = int(pocket.get(item_id, 0)) + amount
	last_message = "+%d %s no bolso." % [amount, item_display_name(item_id)]
	return {"ok": true, "item_id": item_id, "quantity": amount, "message": last_message}

func deposit_all() -> Dictionary:
	var moved := pocket.duplicate(true)
	for key: String in pocket.keys():
		chest[key] = int(chest.get(key, 0)) + int(pocket.get(key, 0))
	pocket = {}
	active_collection = {}
	last_message = "Deposito local atualizado." if not moved.is_empty() else "Bolso vazio."
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
	var output := _as_dictionary(recipe.get("output", {}))
	for key: String in output.keys():
		chest[key] = int(chest.get(key, 0)) + int(output.get(key, 0))
	last_message = "Craft local: %s." % str(recipe.get("display_name", recipe_id))
	return {"ok": true, "recipe_id": recipe_id, "upgrade_id": upgrade_id, "message": last_message}

func has_upgrade(upgrade_id: String) -> bool:
	return bool(upgrades.get(upgrade_id, false))

func start_collection(item_id: String) -> Dictionary:
	if not item_definitions().has(item_id):
		last_message = "Recurso desconhecido."
		return {"ok": false, "reason": "unknown_item", "message": last_message}
	if not can_carry(item_id):
		last_message = "Bolso cheio. Volte ao bau."
		return {"ok": false, "reason": "pocket_full", "message": last_message}
	active_collection = {
		"item_id": item_id,
		"elapsed": 0.0,
		"duration": gather_duration(item_id),
	}
	last_message = "Coletando %s..." % item_display_name(item_id)
	return {"ok": true, "item_id": item_id, "duration": active_collection["duration"], "message": last_message}

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
		last_message = "Coleta aguardando servidor."
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
	last_message = "Coleta cancelada." if reason != "moved" else "Coleta cancelada ao mover."
	return {"ok": true, "cancelled": true, "reason": reason, "message": last_message}

func collection_progress() -> float:
	if active_collection.is_empty():
		return 0.0
	var duration := maxf(0.1, float(active_collection.get("duration", 0.1)))
	return clampf(float(active_collection.get("elapsed", 0.0)) / duration, 0.0, 1.0)

func _item_definition(item_id: String) -> Dictionary:
	return _as_dictionary(item_definitions().get(item_id, {}))

func _recipe(recipe_id: String) -> Dictionary:
	return _as_dictionary(recipes().get(recipe_id, {}))

func _positive_int_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	var source := _as_dictionary(value)
	for key: String in source.keys():
		var amount := int(source.get(key, 0))
		if amount > 0 and item_definitions().has(key):
			result[key] = amount
	return result

func _boolean_dictionary(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	var source := _as_dictionary(value)
	for key: String in source.keys():
		if bool(source.get(key, false)):
			result[key] = true
	return result

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}
