class_name DraxosOperationState
extends RefCounted

const DEFAULT_SCOPE := "app"
const ERROR_ACTION_FAILED := "ACTION_FAILED"

const TOKEN_SCOPE_KEY := "scope"
const TOKEN_VERSION_KEY := "version"
const TOKEN_ACTION_KEY := "action_id"

var _busy_by_scope: Dictionary = {}
var _errors_by_action: Dictionary = {}
var _lifecycle_versions: Dictionary = {}

static func normalize_scope(scope_id: String) -> String:
	var candidate := scope_id.strip_edges()
	if candidate == "":
		return DEFAULT_SCOPE
	return candidate

static func normalize_action(action_id: String) -> String:
	return action_id.strip_edges()

func begin_busy(scope_id: String = DEFAULT_SCOPE, action_id: String = "") -> Dictionary:
	var scope := normalize_scope(scope_id)
	var action := normalize_action(action_id)
	var token := next_lifecycle_token(scope, action)
	_busy_by_scope[scope] = {
		TOKEN_ACTION_KEY: action,
		"token": token.duplicate(true),
	}
	if action != "":
		clear_action_error(action)
	return token

func complete_busy(scope_id: String = DEFAULT_SCOPE, token: Dictionary = {}) -> bool:
	var scope := normalize_scope(scope_id)
	if not _busy_by_scope.has(scope):
		return false
	if not token.is_empty() and not is_current_lifecycle_token(token):
		return false
	_busy_by_scope.erase(scope)
	return true

func clear_busy(scope_id: String = DEFAULT_SCOPE) -> bool:
	var scope := normalize_scope(scope_id)
	var had_scope := _busy_by_scope.has(scope)
	_busy_by_scope.erase(scope)
	return had_scope

func clear_all_busy() -> void:
	_busy_by_scope.clear()

func is_busy(scope_id: String = DEFAULT_SCOPE) -> bool:
	return _busy_by_scope.has(normalize_scope(scope_id))

func any_busy() -> bool:
	return not _busy_by_scope.is_empty()

func busy_action(scope_id: String = DEFAULT_SCOPE) -> String:
	var state := _busy_state(scope_id)
	return str(state.get(TOKEN_ACTION_KEY, ""))

func busy_scopes() -> PackedStringArray:
	var scopes := PackedStringArray()
	for scope: Variant in _busy_by_scope.keys():
		scopes.append(str(scope))
	scopes.sort()
	return scopes

func next_lifecycle_token(scope_id: String = DEFAULT_SCOPE, action_id: String = "") -> Dictionary:
	var scope := normalize_scope(scope_id)
	var version := int(_lifecycle_versions.get(scope, 0)) + 1
	_lifecycle_versions[scope] = version
	return {
		TOKEN_SCOPE_KEY: scope,
		TOKEN_VERSION_KEY: version,
		TOKEN_ACTION_KEY: normalize_action(action_id),
	}

func invalidate_scope(scope_id: String = DEFAULT_SCOPE) -> Dictionary:
	var scope := normalize_scope(scope_id)
	_busy_by_scope.erase(scope)
	return next_lifecycle_token(scope)

func is_current_lifecycle_token(token: Dictionary) -> bool:
	if token.is_empty():
		return false
	var scope := normalize_scope(str(token.get(TOKEN_SCOPE_KEY, "")))
	var version := int(token.get(TOKEN_VERSION_KEY, 0))
	if version <= 0:
		return false
	return int(_lifecycle_versions.get(scope, 0)) == version

func set_action_error(action_id: String, error_payload: Variant) -> Dictionary:
	var action := normalize_action(action_id)
	if action == "":
		return {}
	var normalized := _normalize_error(action, error_payload)
	_errors_by_action[action] = normalized
	return normalized.duplicate(true)

func action_error(action_id: String) -> Dictionary:
	var action := normalize_action(action_id)
	if not _errors_by_action.has(action):
		return {}
	var payload: Dictionary = _errors_by_action[action]
	return payload.duplicate(true)

func has_action_error(action_id: String) -> bool:
	return _errors_by_action.has(normalize_action(action_id))

func clear_action_error(action_id: String) -> bool:
	var action := normalize_action(action_id)
	var had_error := _errors_by_action.has(action)
	_errors_by_action.erase(action)
	return had_error

func clear_errors() -> void:
	_errors_by_action.clear()

func error_actions() -> PackedStringArray:
	var actions := PackedStringArray()
	for action: Variant in _errors_by_action.keys():
		actions.append(str(action))
	actions.sort()
	return actions

func snapshot() -> Dictionary:
	return {
		"busy_scopes": busy_scopes(),
		"busy_by_scope": _busy_by_scope.duplicate(true),
		"errors_by_action": _errors_by_action.duplicate(true),
		"lifecycle_versions": _lifecycle_versions.duplicate(true),
	}

func _busy_state(scope_id: String) -> Dictionary:
	var scope := normalize_scope(scope_id)
	if not _busy_by_scope.has(scope):
		return {}
	return Dictionary(_busy_by_scope[scope])

func _normalize_error(action_id: String, error_payload: Variant) -> Dictionary:
	var payload: Dictionary = {}
	if error_payload is Dictionary:
		payload = (error_payload as Dictionary).duplicate(true)
	else:
		payload = {
			"code": ERROR_ACTION_FAILED,
			"message": str(error_payload),
		}
	payload["action_id"] = action_id
	if str(payload.get("code", "")).strip_edges() == "":
		payload["code"] = ERROR_ACTION_FAILED
	if not payload.has("message"):
		payload["message"] = ""
	return payload
