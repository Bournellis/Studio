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
const SETTING_UPDATE_MANIFEST_URL := "draxos_mobile/update/manifest_url"
const SETTING_INTERNAL_ALPHA_SUPABASE_URL := "draxos_mobile/internal_alpha/supabase_url"
const SETTING_INTERNAL_ALPHA_PUBLISHABLE_KEY := "draxos_mobile/internal_alpha/publishable_key"
const SETTING_INTERNAL_ALPHA_UPDATE_MANIFEST_URL := "draxos_mobile/internal_alpha/update_manifest_url"

const ENV_BACKEND_ENVIRONMENT := "DRAXOS_MOBILE_BACKEND_ENV"
const ENV_SUPABASE_URL := "DRAXOS_MOBILE_SUPABASE_URL"
const ENV_SUPABASE_PUBLISHABLE_KEY := "DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY"
const ENV_UPDATE_MANIFEST_URL := "DRAXOS_MOBILE_UPDATE_MANIFEST_URL"

const ERROR_SUPABASE_URL_MISSING := "SUPABASE_URL_MISSING"
const ERROR_SUPABASE_URL_INVALID := "SUPABASE_URL_INVALID"
const ERROR_PUBLISHABLE_KEY_MISSING := "SUPABASE_PUBLISHABLE_KEY_MISSING"
const ERROR_PUBLISHABLE_KEY_LOOKS_SECRET := "SUPABASE_PUBLISHABLE_KEY_LOOKS_SECRET"
const INTERNAL_ALPHA_RUNTIME_CONFIG_PATH := "res://online/internal_alpha_runtime_config.gd"

static func load_from_project_settings() -> Dictionary:
	var runtime_config := _runtime_internal_alpha_config()
	var configured_environment := _setting_string(SETTING_BACKEND_ENVIRONMENT, DEFAULT_BACKEND_ENVIRONMENT)
	var default_environment := configured_environment
	if OS.has_feature("alpha") and not OS.has_environment(ENV_BACKEND_ENVIRONMENT):
		default_environment = str(runtime_config.get("backend_environment", ENVIRONMENT_INTERNAL_ALPHA))
	var environment := _env_string(ENV_BACKEND_ENVIRONMENT, default_environment)
	var normalized_environment := normalize_environment(environment)

	var url := ""
	var key := ""
	var manifest_url := ""
	match normalized_environment:
		ENVIRONMENT_LOCAL:
			url = _setting_string(SETTING_SUPABASE_URL, DEFAULT_LOCAL_SUPABASE_URL)
			key = _setting_string(SETTING_SUPABASE_PUBLISHABLE_KEY, DEFAULT_LOCAL_PUBLISHABLE_KEY)
			manifest_url = _setting_string(SETTING_UPDATE_MANIFEST_URL, "")
		ENVIRONMENT_INTERNAL_ALPHA:
			url = _setting_string(SETTING_INTERNAL_ALPHA_SUPABASE_URL, "")
			key = _setting_string(SETTING_INTERNAL_ALPHA_PUBLISHABLE_KEY, "")
			manifest_url = _setting_string(SETTING_INTERNAL_ALPHA_UPDATE_MANIFEST_URL, "")
			url = str(runtime_config.get("supabase_url", url))
			key = str(runtime_config.get("publishable_key", key))
			manifest_url = str(runtime_config.get("update_manifest_url", manifest_url))
		_:
			url = _setting_string(SETTING_SUPABASE_URL, "")
			key = _setting_string(SETTING_SUPABASE_PUBLISHABLE_KEY, "")
			manifest_url = _setting_string(SETTING_UPDATE_MANIFEST_URL, "")

	url = _env_string(ENV_SUPABASE_URL, url)
	key = _env_string(ENV_SUPABASE_PUBLISHABLE_KEY, key)
	manifest_url = _env_string(ENV_UPDATE_MANIFEST_URL, manifest_url)
	return config_from_values(normalized_environment, url, key, "project_settings+env", manifest_url)

static func config_from_values(environment: String, url: String, key: String, source: String = "manual", manifest_url: String = "") -> Dictionary:
	var normalized_environment := normalize_environment(environment)
	var normalized_url := normalize_url(url)
	var normalized_key := key.strip_edges()
	var normalized_manifest_url := normalize_update_manifest_url(manifest_url, normalized_url)
	var errors := validate_client_config(normalized_url, normalized_key)
	return {
		"ok": errors.is_empty(),
		"environment": normalized_environment,
		"supabase_url": normalized_url,
		"publishable_key": normalized_key,
		"update_manifest_url": normalized_manifest_url,
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

static func normalize_update_manifest_url(manifest_url: String, supabase_url: String) -> String:
	var normalized := manifest_url.strip_edges()
	if normalized == "" and supabase_url.strip_edges() != "":
		normalized = "%s/functions/v1/release/manifest" % supabase_url.strip_edges().trim_suffix("/")
	return normalized

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
		ENV_UPDATE_MANIFEST_URL,
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

static func _runtime_internal_alpha_config() -> Dictionary:
	if not OS.has_feature("alpha"):
		return {}
	if not ResourceLoader.exists(INTERNAL_ALPHA_RUNTIME_CONFIG_PATH):
		return {}
	var script_resource: Resource = load(INTERNAL_ALPHA_RUNTIME_CONFIG_PATH)
	if script_resource == null or not script_resource is GDScript:
		return {}
	var instance: RefCounted = (script_resource as GDScript).new()
	if instance == null or not instance.has_method("config"):
		return {}
	var config: Variant = instance.call("config")
	if config is Dictionary:
		return Dictionary(config)
	return {}
