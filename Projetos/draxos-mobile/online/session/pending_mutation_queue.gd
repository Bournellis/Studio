extends RefCounted

const TelemetrySliceScript := preload("res://online/session/telemetry_slice.gd")

const MUTATION_STATUS_PENDING := "pending"
const MUTATION_STATUS_COMPLETED := "completed"
const MUTATION_STATUS_FAILED := "failed"
const SAVE_TYPE_NORMAL := "normal"
const SAVE_TYPE_PROGRESSION_LAB := "progression_lab"

static func prepare(queue: Dictionary, endpoint: String, scope_id: String, action_id: String, payload: Dictionary = {}) -> Dictionary:
	var normalized_endpoint := endpoint.strip_edges()
	var normalized_scope := scope_id.strip_edges()
	var normalized_action := action_id.strip_edges()
	var base_payload := payload.duplicate(true)
	base_payload.erase("request_hash")
	var request_id := str(base_payload.get("request_id", "")).strip_edges()
	if request_id != "" and queue.has(request_id):
		var existing := _as_dictionary(queue.get(request_id, {}))
		if str(existing.get("status", MUTATION_STATUS_PENDING)) == MUTATION_STATUS_COMPLETED:
			request_id = ""
		elif not _record_matches(existing, normalized_endpoint, normalized_scope, normalized_action, base_payload):
			request_id = ""
	if request_id == "":
		request_id = _matching_pending_request_id(queue, normalized_endpoint, normalized_scope, normalized_action, base_payload)
	if request_id == "":
		request_id = TelemetrySliceScript.create_request_id()
	base_payload["request_id"] = request_id
	var request_hash := request_hash_for_mutation(normalized_endpoint, base_payload)
	var existing_record := _as_dictionary(queue.get(request_id, {}))
	var attempts := int(existing_record.get("attempts", 0)) + 1 if not existing_record.is_empty() else 1
	var canonical_payload := canonical_json(base_payload)
	var record := {
		"request_id": request_id,
		"request_hash": request_hash,
		"endpoint": normalized_endpoint,
		"scope_id": normalized_scope,
		"action_id": normalized_action,
		"save_type": save_type_from_scope(normalized_scope),
		"payload": base_payload.duplicate(true),
		"payload_canonical": canonical_payload,
		"status": MUTATION_STATUS_PENDING,
		"attempts": attempts,
		"timestamp": Time.get_unix_time_from_system(),
	}
	queue[request_id] = record
	var body := base_payload.duplicate(true)
	body["request_hash"] = request_hash
	return {
		"queue": queue,
		"mutation": {
			"request_id": request_id,
			"request_hash": request_hash,
			"endpoint": normalized_endpoint,
			"scope_id": normalized_scope,
			"action_id": normalized_action,
			"payload": body,
			"attempts": attempts,
			"status": MUTATION_STATUS_PENDING,
		},
	}

static func mark(queue: Dictionary, request_id: String, status: String, payload: Dictionary = {}) -> Dictionary:
	var normalized := request_id.strip_edges()
	if not queue.has(normalized):
		return {
			"queue": queue,
			"changed": false,
		}
	var record := _as_dictionary(queue.get(normalized, {})).duplicate(true)
	record["status"] = _normalize_status(status)
	record["completed_at"] = Time.get_unix_time_from_system()
	if not payload.is_empty():
		record["response_payload"] = payload.duplicate(true)
	queue[normalized] = record
	return {
		"queue": queue,
		"changed": true,
	}

static func clear(queue: Dictionary, request_id: String) -> Dictionary:
	var normalized := request_id.strip_edges()
	var had_record := queue.has(normalized)
	queue.erase(normalized)
	return {
		"queue": queue,
		"changed": had_record,
	}

static func get_record(queue: Dictionary, request_id: String) -> Dictionary:
	return _as_dictionary(queue.get(request_id.strip_edges(), {})).duplicate(true)

static func normalize(source: Dictionary) -> Dictionary:
	var normalized := {}
	for key: Variant in source.keys():
		var request_id := str(key).strip_edges()
		if request_id == "":
			continue
		var record := _as_dictionary(source.get(key, {})).duplicate(true)
		record["request_id"] = str(record.get("request_id", request_id)).strip_edges()
		record["request_hash"] = str(record.get("request_hash", "")).strip_edges()
		record["endpoint"] = str(record.get("endpoint", "")).strip_edges()
		record["scope_id"] = str(record.get("scope_id", "")).strip_edges()
		record["action_id"] = str(record.get("action_id", "")).strip_edges()
		record["status"] = _normalize_status(str(record.get("status", MUTATION_STATUS_PENDING)))
		record["attempts"] = maxi(1, int(record.get("attempts", 1)))
		record["payload"] = _as_dictionary(record.get("payload", {})).duplicate(true)
		record["payload_canonical"] = str(record.get("payload_canonical", canonical_json(record["payload"])))
		record["save_type"] = str(record.get("save_type", save_type_from_scope(str(record.get("scope_id", "")))))
		normalized[request_id] = record
	return normalized

static func prune_pending_outside_save(queue: Dictionary, active_save_type: String) -> Dictionary:
	var active_type := _normalize_save_type(active_save_type)
	var pruned := {}
	for key: Variant in queue.keys():
		var request_id := str(key).strip_edges()
		var record := _as_dictionary(queue.get(key, {})).duplicate(true)
		var status := _normalize_status(str(record.get("status", MUTATION_STATUS_PENDING)))
		var record_save_type := str(record.get("save_type", save_type_from_scope(str(record.get("scope_id", "")))))
		if status == MUTATION_STATUS_PENDING and record_save_type != "" and record_save_type != active_type:
			continue
		pruned[request_id] = record
	return pruned

static func counts_by_save(queue: Dictionary) -> Dictionary:
	var counts := {
		SAVE_TYPE_NORMAL: 0,
		SAVE_TYPE_PROGRESSION_LAB: 0,
		"unscoped": 0,
	}
	for record_variant: Variant in queue.values():
		var record := _as_dictionary(record_variant)
		if _normalize_status(str(record.get("status", MUTATION_STATUS_PENDING))) != MUTATION_STATUS_PENDING:
			continue
		var save_type := str(record.get("save_type", save_type_from_scope(str(record.get("scope_id", "")))))
		if save_type == SAVE_TYPE_NORMAL or save_type == SAVE_TYPE_PROGRESSION_LAB:
			counts[save_type] = int(counts.get(save_type, 0)) + 1
		else:
			counts["unscoped"] = int(counts.get("unscoped", 0)) + 1
	return counts

static func request_hash_for_mutation(endpoint: String, payload: Dictionary) -> String:
	var canonical_payload := payload.duplicate(true)
	canonical_payload.erase("request_hash")
	return sha256_text("sha256", canonical_json({
		"endpoint": endpoint.strip_edges(),
		"payload": canonical_payload,
	}))

static func sha256_text(prefix: String, value: String) -> String:
	var hashing := HashingContext.new()
	var start_error := hashing.start(HashingContext.HASH_SHA256)
	if start_error != OK:
		return ""
	hashing.update(value.to_utf8_buffer())
	var digest := hashing.finish().hex_encode()
	if prefix.strip_edges() == "":
		return digest
	return "%s:%s" % [prefix.strip_edges(), digest]

static func canonical_json(value: Variant) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT, TYPE_FLOAT:
			return JSON.stringify(value)
		TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH:
			return JSON.stringify(str(value))
		TYPE_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			var parts := PackedStringArray()
			for item: Variant in value:
				parts.append(canonical_json(item))
			return "[%s]" % ",".join(parts)
		TYPE_DICTIONARY:
			var dictionary := Dictionary(value)
			var keys := PackedStringArray()
			for key: Variant in dictionary.keys():
				keys.append(str(key))
			keys.sort()
			var parts := PackedStringArray()
			for key: String in keys:
				parts.append("%s:%s" % [JSON.stringify(key), canonical_json(dictionary[key])])
			return "{%s}" % ",".join(parts)
		_:
			return JSON.stringify(value)

static func save_type_from_scope(scope_id: String) -> String:
	var normalized := scope_id.strip_edges().to_lower()
	if normalized.ends_with(":%s" % SAVE_TYPE_PROGRESSION_LAB):
		return SAVE_TYPE_PROGRESSION_LAB
	if normalized.ends_with(":%s" % SAVE_TYPE_NORMAL):
		return SAVE_TYPE_NORMAL
	return ""

static func _matching_pending_request_id(queue: Dictionary, endpoint: String, scope_id: String, action_id: String, payload: Dictionary) -> String:
	for key: Variant in queue.keys():
		var record := _as_dictionary(queue.get(key, {}))
		if str(record.get("status", "")) != MUTATION_STATUS_PENDING:
			continue
		if _record_matches(record, endpoint, scope_id, action_id, payload):
			return str(record.get("request_id", key)).strip_edges()
	return ""

static func _record_matches(record: Dictionary, endpoint: String, scope_id: String, action_id: String, payload: Dictionary) -> bool:
	if str(record.get("endpoint", "")) != endpoint:
		return false
	if str(record.get("scope_id", "")) != scope_id:
		return false
	if str(record.get("action_id", "")) != action_id:
		return false
	var record_payload := _as_dictionary(record.get("payload", {})).duplicate(true)
	record_payload.erase("request_id")
	record_payload.erase("request_hash")
	var incoming_payload := payload.duplicate(true)
	incoming_payload.erase("request_id")
	incoming_payload.erase("request_hash")
	return canonical_json(record_payload) == canonical_json(incoming_payload)

static func _normalize_status(status: String) -> String:
	var normalized := status.strip_edges()
	if normalized == MUTATION_STATUS_COMPLETED or normalized == MUTATION_STATUS_FAILED:
		return normalized
	return MUTATION_STATUS_PENDING

static func _normalize_save_type(save_type: String) -> String:
	if save_type.strip_edges().to_lower() == SAVE_TYPE_PROGRESSION_LAB:
		return SAVE_TYPE_PROGRESSION_LAB
	return SAVE_TYPE_NORMAL

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
