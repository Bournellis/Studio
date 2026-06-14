class_name OpenworldPersistenceState
extends RefCounted

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

const LOCAL_STATE_SCHEMA := "openworld_forest_local_checkpoint_v1"
const PENDING_OPS_SCHEMA := "openworld_pending_ops_cache_v1"
const DURABLE_PROGRESS_SCHEMA := "openworld_forest_progress_v2"

static func active_session_cache_payload(
	active_save_type: String,
	session_id: String,
	started_at_unix: int,
	expires_at_unix: int,
	snapshot_revision: int,
	accepted_checkpoint_id: String,
	client_sequence: int,
	checkpoint_dirty: bool,
	checkpoint_in_flight: bool,
	last_checkpoint_subject: String,
	reward_pending: bool,
	pending_collected_nodes: Dictionary,
	pending_operations: Array[Dictionary],
	snapshot_payload: Dictionary
) -> Dictionary:
	return {
		"schema_version": LOCAL_STATE_SCHEMA,
		"save_type": active_save_type,
		"session_id": session_id,
		"started_at": started_at_unix,
		"expires_at": expires_at_unix,
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"snapshot_revision": snapshot_revision,
		"accepted_checkpoint_id": accepted_checkpoint_id,
		"client_sequence": client_sequence,
		"checkpoint_dirty": checkpoint_dirty,
		"checkpoint_in_flight": checkpoint_in_flight,
		"last_checkpoint_subject": last_checkpoint_subject,
		"reward_pending": reward_pending,
		"pending_collected_nodes": pending_collected_nodes.duplicate(true),
		"pending_operations": pending_operations.duplicate(true),
		"snapshot_payload": snapshot_payload.duplicate(true),
		"updated_at_unix": Time.get_unix_time_from_system(),
	}

static func pending_ops_cache_payload(
	active_save_type: String,
	session_id: String,
	started_at_unix: int,
	expires_at_unix: int,
	client_sequence: int,
	operations: Array[Dictionary]
) -> Dictionary:
	return {
		"schema_version": PENDING_OPS_SCHEMA,
		"save_type": active_save_type,
		"session_id": session_id,
		"started_at": started_at_unix,
		"expires_at": expires_at_unix,
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"client_sequence": client_sequence,
		"operations": operations.duplicate(true),
		"updated_at_unix": Time.get_unix_time_from_system(),
	}

static func pending_ops_from_cache(
	cache: Dictionary,
	active_save_type: String,
	session_id: String,
	now_unix: int,
	max_cache_seconds: int,
	grace_seconds: int
) -> Array[Dictionary]:
	if not pending_ops_cache_matches_context(cache, active_save_type, session_id):
		return []
	if not local_session_cache_is_live(cache, now_unix, max_cache_seconds, grace_seconds):
		return []
	return operation_array(cache.get("operations", []))

static func pending_ops_cache_matches_context(cache: Dictionary, active_save_type: String, session_id: String) -> bool:
	if cache.is_empty():
		return false
	if str(cache.get("schema_version", "")) != PENDING_OPS_SCHEMA:
		return false
	if str(cache.get("save_type", active_save_type)) != active_save_type:
		return false
	if str(cache.get("session_id", "")).strip_edges() != session_id.strip_edges():
		return false
	if str(cache.get("ruleset_id", "")) != ModelScript.RULESET_ID:
		return false
	if int(cache.get("ruleset_version", 0)) != ModelScript.RULESET_VERSION:
		return false
	return true

static func local_session_cache_is_live(local_state: Dictionary, now_unix: int, max_cache_seconds: int, grace_seconds: int) -> bool:
	var expires_at := timestamp_to_unix(local_state.get("expires_at", 0))
	if expires_at <= 0 or expires_at <= now_unix:
		return false
	var started_at := timestamp_to_unix(local_state.get("started_at", 0))
	if started_at > 0 and now_unix - started_at > max_cache_seconds + grace_seconds:
		return false
	return true

static func operation_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var source := _as_array(value)
	for operation_variant: Variant in source:
		var operation := _as_dictionary(operation_variant)
		if operation.is_empty():
			continue
		var op_id := str(operation.get("op_id", "")).strip_edges()
		var op_type := str(operation.get("type", "")).strip_edges()
		if not op_id.begins_with("owop_") or op_type == "":
			continue
		result.append(operation.duplicate(true))
	return result

static func durable_source_from_snapshot(snapshot_payload: Dictionary) -> Dictionary:
	var durable_progress := _as_dictionary(snapshot_payload.get("durable_progress", {}))
	if not durable_progress.is_empty():
		return durable_progress
	if snapshot_payload.has("pocket") or snapshot_payload.has("chest") or snapshot_payload.has("upgrades") or snapshot_payload.has("structures") or snapshot_payload.has("node_state"):
		return snapshot_payload
	var durable_base := _as_dictionary(snapshot_payload.get("durable_base", {}))
	return durable_base

static func normalize_durable_progress(source: Dictionary, metadata: Dictionary = {}, active_save_type: String = "normal") -> Dictionary:
	if source.is_empty() and metadata.is_empty():
		return {}
	var upgrades := true_dictionary(source.get("upgrades", {}))
	var structures := true_dictionary(source.get("structures", {}))
	if bool(upgrades.get("fogueira_estavel_1", false)):
		structures["fogueira_estavel_1"] = true
	if bool(structures.get("fogueira_estavel_1", false)):
		upgrades["fogueira_estavel_1"] = true
	return {
		"schema_version": DURABLE_PROGRESS_SCHEMA,
		"save_type": str(source.get("save_type", metadata.get("save_type", active_save_type))),
		"ruleset_id": str(source.get("ruleset_id", metadata.get("ruleset_id", ModelScript.RULESET_ID))),
		"ruleset_version": int(source.get("ruleset_version", metadata.get("ruleset_version", ModelScript.RULESET_VERSION))),
		"pocket": positive_int_dictionary(source.get("pocket", {})),
		"chest": positive_int_dictionary(source.get("chest", {})),
		"upgrades": upgrades,
		"structures": structures,
		"guidance": _as_dictionary(source.get("guidance", metadata.get("guidance", {}))).duplicate(true),
		"node_state": _as_dictionary(source.get("node_state", metadata.get("node_state", {}))).duplicate(true),
		"reward_ledger": _as_dictionary(source.get("reward_ledger", metadata.get("reward_ledger", {}))).duplicate(true),
		"applied_ops": _as_dictionary(source.get("applied_ops", metadata.get("applied_ops", {}))).duplicate(true),
		"last_checkpoint_session_id": str(source.get("last_checkpoint_session_id", metadata.get("last_checkpoint_session_id", ""))),
		"last_completed_session_id": str(source.get("last_completed_session_id", metadata.get("last_completed_session_id", ""))),
		"progress_revision": int(source.get("progress_revision", metadata.get("progress_revision", metadata.get("snapshot_revision", 0)))),
		"updated_at_unix": int(source.get("updated_at_unix", Time.get_unix_time_from_system())),
	}

static func durable_progress_matches_context(progress: Dictionary, active_save_type: String) -> bool:
	if str(progress.get("save_type", active_save_type)) != active_save_type:
		return false
	if str(progress.get("ruleset_id", ModelScript.RULESET_ID)) != ModelScript.RULESET_ID:
		return false
	if int(progress.get("ruleset_version", ModelScript.RULESET_VERSION)) != ModelScript.RULESET_VERSION:
		return false
	return true

static func durable_progress_patch(progress: Dictionary, active_save_type: String) -> Dictionary:
	if progress.is_empty():
		return {}
	if not durable_progress_matches_context(progress, active_save_type):
		return {}
	return {
		"ruleset_id": ModelScript.RULESET_ID,
		"ruleset_version": ModelScript.RULESET_VERSION,
		"pocket": positive_int_dictionary(progress.get("pocket", {})),
		"chest": positive_int_dictionary(progress.get("chest", {})),
		"upgrades": true_dictionary(progress.get("upgrades", {})),
		"structures": true_dictionary(progress.get("structures", {})),
		"guidance": _as_dictionary(progress.get("guidance", {})).duplicate(true),
		"node_state": _as_dictionary(progress.get("node_state", {})).duplicate(true),
	}

static func positive_int_dictionary(value: Variant) -> Dictionary:
	var source := _as_dictionary(value)
	var result: Dictionary = {}
	for key: String in source.keys():
		var clean_key := ModelScript.canonical_item_id(str(key))
		var amount := maxi(0, int(source.get(key, 0)))
		if amount > 0:
			result[clean_key] = int(result.get(clean_key, 0)) + amount
	return result

static func true_dictionary(value: Variant) -> Dictionary:
	var source := _as_dictionary(value)
	var result: Dictionary = {}
	for key: String in source.keys():
		if bool(source.get(key, false)):
			result[key] = true
	return result

static func timestamp_to_unix(value: Variant) -> int:
	if value is int:
		return int(value)
	if value is float:
		return int(value)
	var text := str(value).strip_edges()
	if text == "" or text == "<null>":
		return 0
	if text.is_valid_int():
		return int(text)
	var clean := text.replace("Z", "")
	var plus_index := clean.find("+", 19)
	if plus_index >= 0:
		clean = clean.substr(0, plus_index)
	var minus_index := clean.find("-", 19)
	if minus_index >= 0:
		clean = clean.substr(0, minus_index)
	if clean.length() > 19:
		clean = clean.substr(0, 19)
	return int(Time.get_unix_time_from_datetime_string(clean))

static func _as_array(value: Variant) -> Array:
	return value if value is Array else []

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
