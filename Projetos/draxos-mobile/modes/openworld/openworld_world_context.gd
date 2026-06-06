class_name BosqueWorldContext
extends RefCounted

const SCHEMA_VERSION := "bosque_world_context_v1"

static func build(model: Object, session_store: Node, bridge: Object, session_state: String, station_nearby: bool) -> Dictionary:
	var durable_progress := {}
	if bridge != null and bridge.has_method("durable_progress_snapshot"):
		durable_progress = _as_dictionary(bridge.call("durable_progress_snapshot"))
	var account_resources := {}
	var crafting := {}
	var arena := {}
	if session_store != null:
		if session_store.has_method("resources_snapshot"):
			account_resources = _as_dictionary(session_store.call("resources_snapshot"))
		if session_store.has_method("crafting_snapshot"):
			crafting = _as_dictionary(session_store.call("crafting_snapshot"))
		if session_store.has_method("arena_pve_state_snapshot"):
			arena = _as_dictionary(session_store.call("arena_pve_state_snapshot"))
	return {
		"schema_version": SCHEMA_VERSION,
		"session_state": session_state,
		"station_nearby": station_nearby,
		"forest": {
			"source_label": "Bosque",
			"pocket_label": "Mochila do Bosque",
			"chest_label": "Bau do Bosque",
			"pocket": _model_dictionary(model, "pocket"),
			"chest": _model_dictionary(model, "chest"),
			"upgrades": _model_dictionary(model, "upgrades"),
			"structures": _model_dictionary(model, "structures"),
			"durable_progress": durable_progress,
		},
		"account": {
			"source_label": "Conta/Ossario",
			"resources": account_resources,
		},
		"crafting": {
			"source_label": "Pocoes globais",
			"state": crafting,
		},
		"arena": {
			"source_label": "Arena",
			"state": arena,
		},
	}

static func _model_dictionary(model: Object, property_name: String) -> Dictionary:
	if model == null:
		return {}
	var value: Variant = model.get(property_name)
	return _as_dictionary(value).duplicate(true)

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
