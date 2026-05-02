extends Node

const PlayerProfile = preload("res://gameplay/profile/player_profile.gd")
const CampaignRewardPayload = preload("res://gameplay/profile/campaign_reward_payload.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")

const SAVE_PATH: String = "user://player_profile.json"

var _cached_profile: PlayerProfile

func load_profile() -> PlayerProfile:
	if _cached_profile != null:
		return _cached_profile

	if not FileAccess.file_exists(SAVE_PATH):
		_cached_profile = PlayerProfile.new()
		return _cached_profile

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_cached_profile = PlayerProfile.new()
		return _cached_profile

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_cached_profile = PlayerProfile.new()
		return _cached_profile

	_cached_profile = PlayerProfile.new().apply_dictionary(parsed)
	return _cached_profile

func save_profile(profile: PlayerProfile) -> void:
	_cached_profile = profile if profile != null else PlayerProfile.new()
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not write player profile to %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(_cached_profile.to_dictionary(), "\t"))

func clear_profile() -> void:
	_cached_profile = null
	var absolute_path: String = ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(absolute_path)

func is_mandatory_tutorial_pending() -> bool:
	return not load_profile().tutorial_completed

func complete_mandatory_tutorial() -> PlayerProfile:
	var resolved_profile: PlayerProfile = ProgressionResolver.apply_mandatory_tutorial_completion(load_profile())
	save_profile(resolved_profile)
	return resolved_profile

func unlock_tutorial_skill() -> PlayerProfile:
	var resolved_profile: PlayerProfile = ProgressionResolver.apply_tutorial_skill_unlock(load_profile())
	save_profile(resolved_profile)
	return resolved_profile

func unlock_tutorial_potion() -> PlayerProfile:
	var resolved_profile: PlayerProfile = ProgressionResolver.apply_tutorial_potion_unlock(load_profile())
	save_profile(resolved_profile)
	return resolved_profile

func apply_campaign_stage_completion(reward_payload: CampaignRewardPayload) -> PlayerProfile:
	var resolved_profile: PlayerProfile = ProgressionResolver.apply_campaign_reward_payload(
		load_profile(),
		reward_payload
	)
	save_profile(resolved_profile)
	return resolved_profile

func complete_campaign(campaign_id: StringName, difficulty_id: StringName) -> PlayerProfile:
	var resolved_profile: PlayerProfile = ProgressionResolver.apply_campaign_completion(
		load_profile(),
		campaign_id,
		difficulty_id
	)
	save_profile(resolved_profile)
	return resolved_profile

func has_suspended_run(run_key: StringName) -> bool:
	return load_profile().has_suspended_run(run_key)

func get_suspended_run(run_key: StringName) -> Dictionary:
	return load_profile().get_suspended_run(run_key)

func has_campaign_suspended_run(campaign_id: StringName, difficulty_id: StringName) -> bool:
	var resolved_profile: PlayerProfile = load_profile()
	var route_run_key: StringName = ProgressionResolver.build_campaign_run_key(campaign_id, difficulty_id)
	if resolved_profile.has_suspended_run(route_run_key):
		return true
	return _is_legacy_easy_campaign_run(campaign_id, difficulty_id, resolved_profile)

func get_campaign_suspended_run(campaign_id: StringName, difficulty_id: StringName) -> Dictionary:
	var resolved_profile: PlayerProfile = load_profile()
	var route_run_key: StringName = ProgressionResolver.build_campaign_run_key(campaign_id, difficulty_id)
	if resolved_profile.has_suspended_run(route_run_key):
		return resolved_profile.get_suspended_run(route_run_key)

	if not _is_legacy_easy_campaign_run(campaign_id, difficulty_id, resolved_profile):
		return {}

	var legacy_run_key: StringName = ProgressionResolver.build_legacy_campaign_run_key(campaign_id)
	var migrated_payload: Dictionary = _build_migrated_campaign_payload(
		resolved_profile.get_suspended_run(legacy_run_key),
		campaign_id,
		difficulty_id
	)
	if migrated_payload.is_empty():
		return {}

	resolved_profile.set_suspended_run(route_run_key, migrated_payload)
	resolved_profile.clear_suspended_run(legacy_run_key)
	save_profile(resolved_profile)
	return migrated_payload

func save_suspended_run(run_key: StringName, payload: Dictionary) -> PlayerProfile:
	var resolved_profile: PlayerProfile = load_profile()
	resolved_profile.set_suspended_run(run_key, payload)
	save_profile(resolved_profile)
	return resolved_profile

func clear_suspended_run(run_key: StringName) -> PlayerProfile:
	var resolved_profile: PlayerProfile = load_profile()
	resolved_profile.clear_suspended_run(run_key)
	save_profile(resolved_profile)
	return resolved_profile

func save_campaign_suspended_run(
	campaign_id: StringName,
	difficulty_id: StringName,
	payload: Dictionary
) -> PlayerProfile:
	var resolved_profile: PlayerProfile = load_profile()
	var route_run_key: StringName = ProgressionResolver.build_campaign_run_key(campaign_id, difficulty_id)
	var resolved_payload: Dictionary = _build_migrated_campaign_payload(payload, campaign_id, difficulty_id)
	resolved_profile.set_suspended_run(route_run_key, resolved_payload)
	_clear_legacy_campaign_run_if_needed(resolved_profile, campaign_id, difficulty_id)
	save_profile(resolved_profile)
	return resolved_profile

func clear_campaign_suspended_run(campaign_id: StringName, difficulty_id: StringName) -> PlayerProfile:
	var resolved_profile: PlayerProfile = load_profile()
	var route_run_key: StringName = ProgressionResolver.build_campaign_run_key(campaign_id, difficulty_id)
	resolved_profile.clear_suspended_run(route_run_key)
	_clear_legacy_campaign_run_if_needed(resolved_profile, campaign_id, difficulty_id)
	save_profile(resolved_profile)
	return resolved_profile

func _is_legacy_easy_campaign_run(
	campaign_id: StringName,
	difficulty_id: StringName,
	profile: PlayerProfile
) -> bool:
	if difficulty_id != PlayerProfile.EASY_DIFFICULTY_ID:
		return false
	var resolved_profile: PlayerProfile = profile if profile != null else PlayerProfile.new()
	return resolved_profile.has_suspended_run(ProgressionResolver.build_legacy_campaign_run_key(campaign_id))

func _clear_legacy_campaign_run_if_needed(
	profile: PlayerProfile,
	campaign_id: StringName,
	difficulty_id: StringName
) -> void:
	if profile == null or difficulty_id != PlayerProfile.EASY_DIFFICULTY_ID:
		return
	profile.clear_suspended_run(ProgressionResolver.build_legacy_campaign_run_key(campaign_id))

func _build_migrated_campaign_payload(
	payload: Dictionary,
	campaign_id: StringName,
	difficulty_id: StringName
) -> Dictionary:
	var migrated_payload: Dictionary = Dictionary(payload).duplicate(true)
	if migrated_payload.is_empty():
		return {}
	migrated_payload["campaign_id"] = String(campaign_id)
	migrated_payload["difficulty_id"] = String(difficulty_id)

	var reward_payload: Dictionary = Dictionary(migrated_payload.get("reward_payload", {})).duplicate(true)
	if not reward_payload.is_empty():
		reward_payload["campaign_id"] = String(campaign_id)
		reward_payload["difficulty_id"] = String(difficulty_id)
		migrated_payload["reward_payload"] = reward_payload

	return migrated_payload
