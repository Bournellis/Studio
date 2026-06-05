class_name OpenworldForestInteractionController
extends RefCounted

const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")

var model: Variant = null
var runtime: Variant = null

var record_event_callable := Callable()
var uses_authority_callable := Callable()
var session_blocked_callable := Callable()
var near_chest_callable := Callable()
var bridge_callable := Callable()
var update_callable := Callable()

func configure(
	next_model: Variant,
	next_runtime: Variant,
	next_record_event_callable: Callable,
	next_uses_authority_callable: Callable,
	next_session_blocked_callable: Callable,
	next_near_chest_callable: Callable,
	next_bridge_callable: Callable,
	next_update_callable: Callable
) -> void:
	model = next_model
	runtime = next_runtime
	record_event_callable = next_record_event_callable
	uses_authority_callable = next_uses_authority_callable
	session_blocked_callable = next_session_blocked_callable
	near_chest_callable = next_near_chest_callable
	bridge_callable = next_bridge_callable
	update_callable = next_update_callable

func tick_collection(delta: float, moved: bool) -> void:
	if model == null or runtime == null:
		return
	if _session_blocked():
		return
	if moved:
		if not model.active_collection.is_empty():
			model.advance_collection(0.0, true)
			runtime.active_collection_node_id = ""
			_record_event("collect_cancel", {
				"reason": "moved",
				"position": runtime.position_payload(),
				"session_seconds": int(runtime.session_seconds),
			})
		return
	_advance_nearby_collection(delta)

func deposit_near_chest() -> void:
	if model == null or runtime == null:
		return
	if _session_blocked():
		model.last_message = "Sessao do Bosque concluida."
		_update()
		return
	if not _near_chest():
		model.last_message = "Aproxime-se do bau para depositar."
		_update()
		return
	if model.pocket.is_empty():
		model.last_message = "Bolso vazio; nada para depositar."
		_update()
		return
	if _uses_integrated_authority():
		model.last_message = "Depositando bolso no servidor..."
		_record_event("deposit_all", {
			"position": runtime.position_payload(),
			"session_seconds": int(runtime.session_seconds),
		})
		_update()
		return
	model.deposit_all()
	_record_event("deposit_all", {
		"position": runtime.position_payload(),
		"session_seconds": int(runtime.session_seconds),
	})
	_update()

func craft_recipe(recipe_id: String) -> void:
	if model == null or runtime == null:
		return
	if _session_blocked():
		model.last_message = "Sessao do Bosque concluida."
		_update()
		return
	if _uses_integrated_authority():
		if not model.can_craft(recipe_id):
			model.last_message = model.recipe_state_text(recipe_id)
			_update()
			return
		model.last_message = "Criando %s no servidor..." % model.recipe_display_name(recipe_id)
		_record_event("craft", {
			"recipe_id": recipe_id,
			"position": runtime.position_payload(),
			"session_seconds": int(runtime.session_seconds),
		})
		_update()
		return
	model.craft(recipe_id)
	_record_event("craft", {
		"recipe_id": recipe_id,
		"position": runtime.position_payload(),
		"session_seconds": int(runtime.session_seconds),
	})
	_update()

func _advance_nearby_collection(delta: float) -> void:
	var bridge: Variant = _bridge()
	var nearest: Dictionary = runtime.nearest_resource(bridge)
	if nearest.is_empty():
		if not model.active_collection.is_empty():
			model.cancel_collection("distance")
			runtime.active_collection_node_id = ""
			_record_event("collect_cancel", {
				"reason": "distance",
				"position": runtime.position_payload(),
				"session_seconds": int(runtime.session_seconds),
			})
		return
	var item_id := str(nearest.get("item_id", ""))
	var node_id := str(nearest.get("node_id", ""))
	var distance: float = runtime.player_position.distance_to(Vector2(nearest.get("position", Vector2.ZERO)))
	if model.active_collection.is_empty():
		model.start_collection(item_id)
		runtime.active_collection_node_id = node_id
		_record_event("collect_start", {
			"node_id": node_id,
			"item_id": item_id,
			"position": runtime.position_payload(),
			"session_seconds": int(runtime.session_seconds),
		})
	var active_item := str(model.active_collection.get("item_id", ""))
	if active_item != item_id or runtime.active_collection_node_id != node_id:
		model.cancel_collection("target_changed")
		_record_event("collect_cancel", {
			"reason": "target_changed",
			"position": runtime.position_payload(),
			"session_seconds": int(runtime.session_seconds),
		})
		model.start_collection(item_id)
		runtime.active_collection_node_id = node_id
		_record_event("collect_start", {
			"node_id": node_id,
			"item_id": item_id,
			"position": runtime.position_payload(),
			"session_seconds": int(runtime.session_seconds),
		})
	var authoritative_online := _uses_integrated_authority()
	var result: Dictionary = model.advance_collection(delta, false, distance, not authoritative_online)
	if bool(result.get("completed", false)):
		runtime.mark_collected(node_id)
		if authoritative_online and bridge != null and bridge.has_method("remember_pending_collected_node"):
			bridge.remember_pending_collected_node(node_id)
		runtime.active_collection_node_id = ""
		_record_event("collect_complete", {
			"node_id": node_id,
			"item_id": item_id,
			"position": runtime.position_payload(),
			"session_seconds": int(runtime.session_seconds),
		})

func _record_event(event_type: String, event_payload: Dictionary) -> void:
	if record_event_callable.is_valid():
		record_event_callable.call(event_type, event_payload)

func _uses_integrated_authority() -> bool:
	return bool(uses_authority_callable.call()) if uses_authority_callable.is_valid() else false

func _session_blocked() -> bool:
	return bool(session_blocked_callable.call()) if session_blocked_callable.is_valid() else false

func _near_chest() -> bool:
	return bool(near_chest_callable.call()) if near_chest_callable.is_valid() else false

func _bridge() -> Variant:
	return bridge_callable.call() if bridge_callable.is_valid() else null

func _update() -> void:
	if update_callable.is_valid():
		update_callable.call()
