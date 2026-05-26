class_name BackendConfig
extends RefCounted

const ENVIRONMENT_LOCAL := "local"
const ENVIRONMENT_INTERNAL_ALPHA := "internal_alpha_v0"
const ENVIRONMENT_CUSTOM := "custom"
const DEFAULT_BACKEND_ENVIRONMENT := ENVIRONMENT_LOCAL

const DEFAULT_LOCAL_SUPABASE_URL := "http://127.0.0.1:54321"
const DEFAULT_LOCAL_PUBLISHABLE_KEY := "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH"

const SETTING_BACKEND_ENVIRONMENT := "draxos_mobile/backend/environment"
const SETTING_SUPABASE_URL := "draxos_mobile/supabase/url"
const SETTING_SUPABASE_PUBLISHABLE_KEY := "draxos_mobile/supabase/publishable_key"
const SETTING_INTERNAL_ALPHA_SUPABASE_URL := "draxos_mobile/internal_alpha/supabase_url"
const SETTING_INTERNAL_ALPHA_PUBLISHABLE_KEY := "draxos_mobile/internal_alpha/publishable_key"

const ENV_BACKEND_ENVIRONMENT := "DRAXOS_MOBILE_BACKEND_ENV"
const ENV_SUPABASE_URL := "DRAXOS_MOBILE_SUPABASE_URL"
const ENV_SUPABASE_PUBLISHABLE_KEY := "DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY"

const ERROR_SUPABASE_URL_MISSING := "SUPABASE_URL_MISSING"
const ERROR_SUPABASE_URL_INVALID := "SUPABASE_URL_INVALID"
const ERROR_PUBLISHABLE_KEY_MISSING := "SUPABASE_PUBLISHABLE_KEY_MISSING"
const ERROR_PUBLISHABLE_KEY_LOOKS_SECRET := "SUPABASE_PUBLISHABLE_KEY_LOOKS_SECRET"

static func load_from_project_settings() -> Dictionary:
	var environment := _env_string(
		ENV_BACKEND_ENVIRONMENT,
		_setting_string(SETTING_BACKEND_ENVIRONMENT, DEFAULT_BACKEND_ENVIRONMENT)
	)
	var normalized_environment := normalize_environment(environment)

	var url := ""
	var key := ""
	match normalized_environment:
		ENVIRONMENT_LOCAL:
			url = _setting_string(SETTING_SUPABASE_URL, DEFAULT_LOCAL_SUPABASE_URL)
			key = _setting_string(SETTING_SUPABASE_PUBLISHABLE_KEY, DEFAULT_LOCAL_PUBLISHABLE_KEY)
		ENVIRONMENT_INTERNAL_ALPHA:
			url = _setting_string(SETTING_INTERNAL_ALPHA_SUPABASE_URL, "")
			key = _setting_string(SETTING_INTERNAL_ALPHA_PUBLISHABLE_KEY, "")
		_:
			url = _setting_string(SETTING_SUPABASE_URL, "")
			key = _setting_string(SETTING_SUPABASE_PUBLISHABLE_KEY, "")

	url = _env_string(ENV_SUPABASE_URL, url)
	key = _env_string(ENV_SUPABASE_PUBLISHABLE_KEY, key)
	return config_from_values(normalized_environment, url, key, "project_settings+env")

static func config_from_values(environment: String, url: String, key: String, source: String = "manual") -> Dictionary:
	var normalized_environment := normalize_environment(environment)
	var normalized_url := normalize_url(url)
	var normalized_key := key.strip_edges()
	var errors := validate_client_config(normalized_url, normalized_key)
	return {
		"ok": errors.is_empty(),
		"environment": normalized_environment,
		"supabase_url": normalized_url,
		"publishable_key": normalized_key,
		"source": source,
		"errors": errors,
		"is_remote": normalized_environment != ENVIRONMENT_LOCAL,
	}

static func normalize_environment(environment: String) -> String:
	var normalized := environment.strip_edges().to_lower()
	if normalized == ENVIRONMENT_LOCAL or normalized == ENVIRONMENT_INTERNAL_ALPHA or normalized == ENVIRONMENT_CUSTOM:
		return normalized
	return ENVIRONMENT_CUSTOM

static func normalize_url(url: String) -> String:
	return url.strip_edges().trim_suffix("/")

static func validate_client_config(url: String, key: String) -> PackedStringArray:
	var errors := PackedStringArray()
	if url.strip_edges() == "":
		errors.append(ERROR_SUPABASE_URL_MISSING)
	elif not (url.begins_with("http://") or url.begins_with("https://")):
		errors.append(ERROR_SUPABASE_URL_INVALID)

	if key.strip_edges() == "":
		errors.append(ERROR_PUBLISHABLE_KEY_MISSING)
	elif _looks_like_secret_key(key):
		errors.append(ERROR_PUBLISHABLE_KEY_LOOKS_SECRET)
	return errors

static func client_environment_variables() -> PackedStringArray:
	return PackedStringArray([
		ENV_BACKEND_ENVIRONMENT,
		ENV_SUPABASE_URL,
		ENV_SUPABASE_PUBLISHABLE_KEY,
	])

static func _setting_string(key: String, fallback: String) -> String:
	return str(ProjectSettings.get_setting(key, fallback)).strip_edges()

static func _env_string(key: String, fallback: String) -> String:
	if OS.has_environment(key):
		var value := OS.get_environment(key).strip_edges()
		if value != "":
			return value
	return fallback

static func _looks_like_secret_key(key: String) -> bool:
	var normalized := key.strip_edges().to_lower()
	return (
		normalized.begins_with("sb_secret_")
		or normalized.begins_with("sb_service_")
		or normalized.find("service_role") >= 0
		or normalized.find("secret") >= 0
	)
