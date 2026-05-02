class_name PlayerProfile
extends RefCounted

const PROFILE_VERSION: int = 1
const EASY_DIFFICULTY_ID: StringName = &"easy"

var profile_version: int = PROFILE_VERSION
var tutorial_completed: bool = false
var completed_campaign_difficulties: Dictionary = {}
var unlocked_race_ids: Array[String] = []
var unlocked_weapon_ids: Array[String] = []
var unlocked_skill_ids: Array[String] = []
var unlocked_potion_ids: Array[String] = []
var applied_reward_ids: Array[String] = []
var suspended_runs: Dictionary = {}
var mastery: Dictionary = {}

func apply_dictionary(payload: Dictionary) -> PlayerProfile:
	profile_version = int(payload.get("profile_version", PROFILE_VERSION))
	tutorial_completed = bool(payload.get("tutorial_completed", false))
	completed_campaign_difficulties = _sanitize_dictionary_of_string_arrays(
		payload.get("completed_campaign_difficulties", {})
	)
	unlocked_race_ids = _sanitize_string_array(payload.get("unlocked_race_ids", []))
	unlocked_weapon_ids = _sanitize_string_array(payload.get("unlocked_weapon_ids", []))
	unlocked_skill_ids = _sanitize_string_array(payload.get("unlocked_skill_ids", []))
	unlocked_potion_ids = _sanitize_string_array(payload.get("unlocked_potion_ids", []))
	applied_reward_ids = _sanitize_string_array(payload.get("applied_reward_ids", []))
	suspended_runs = _sanitize_dictionary(payload.get("suspended_runs", {}))
	mastery = Dictionary(payload.get("mastery", {})).duplicate(true)
	return self

func to_dictionary() -> Dictionary:
	return {
		"profile_version": profile_version,
		"tutorial_completed": tutorial_completed,
		"completed_campaign_difficulties": completed_campaign_difficulties.duplicate(true),
		"unlocked_race_ids": unlocked_race_ids.duplicate(),
		"unlocked_weapon_ids": unlocked_weapon_ids.duplicate(),
		"unlocked_skill_ids": unlocked_skill_ids.duplicate(),
		"unlocked_potion_ids": unlocked_potion_ids.duplicate(),
		"applied_reward_ids": applied_reward_ids.duplicate(),
		"suspended_runs": suspended_runs.duplicate(true),
		"mastery": mastery.duplicate(true)
	}

func has_completed_campaign(campaign_id: StringName, difficulty_id: StringName = &"") -> bool:
	var completed_difficulties: Array = completed_campaign_difficulties.get(String(campaign_id), [])
	if difficulty_id == &"":
		return not completed_difficulties.is_empty()
	return completed_difficulties.has(String(difficulty_id))

func get_completed_campaign_count() -> int:
	var completed_count: int = 0
	for campaign_id: Variant in completed_campaign_difficulties.keys():
		var completed_difficulties: Array = completed_campaign_difficulties[campaign_id]
		if not completed_difficulties.is_empty():
			completed_count += 1
	return completed_count

func record_campaign_completion(campaign_id: StringName, difficulty_id: StringName) -> void:
	var campaign_key: String = String(campaign_id)
	var completed_difficulties: Array = completed_campaign_difficulties.get(campaign_key, [])
	var difficulty_key: String = String(difficulty_id)
	if not completed_difficulties.has(difficulty_key):
		completed_difficulties.append(difficulty_key)
		completed_difficulties.sort()
	completed_campaign_difficulties[campaign_key] = completed_difficulties

func unlock_race(race_id: StringName) -> void:
	_append_unique(unlocked_race_ids, String(race_id))

func unlock_weapon(weapon_id: StringName) -> void:
	_append_unique(unlocked_weapon_ids, String(weapon_id))

func unlock_skill(skill_id: StringName) -> void:
	_append_unique(unlocked_skill_ids, String(skill_id))

func unlock_potion(potion_id: StringName) -> void:
	_append_unique(unlocked_potion_ids, String(potion_id))

func is_skill_unlocked(skill_id: StringName) -> bool:
	return unlocked_skill_ids.has(String(skill_id))

func is_potion_unlocked(potion_id: StringName) -> bool:
	return unlocked_potion_ids.has(String(potion_id))

func has_applied_reward(reward_id: String) -> bool:
	return applied_reward_ids.has(reward_id)

func record_applied_reward(reward_id: String) -> void:
	_append_unique(applied_reward_ids, reward_id)

func has_suspended_run(run_key: StringName) -> bool:
	return suspended_runs.has(String(run_key))

func get_suspended_run(run_key: StringName) -> Dictionary:
	return Dictionary(suspended_runs.get(String(run_key), {})).duplicate(true)

func set_suspended_run(run_key: StringName, payload: Dictionary) -> void:
	var key: String = String(run_key)
	if key == "":
		return
	suspended_runs[key] = Dictionary(payload).duplicate(true)

func clear_suspended_run(run_key: StringName) -> void:
	suspended_runs.erase(String(run_key))

static func _append_unique(target: Array[String], value: String) -> void:
	if value == "":
		return
	if target.has(value):
		return
	target.append(value)
	target.sort()

static func _sanitize_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			var string_value: String = str(entry)
			if string_value == "":
				continue
			if result.has(string_value):
				continue
			result.append(string_value)
	result.sort()
	return result

static func _sanitize_dictionary_of_string_arrays(value: Variant) -> Dictionary:
	var result: Dictionary = {}
	if value is Dictionary:
		for key: Variant in value.keys():
			var sanitized_key: String = str(key)
			if sanitized_key == "":
				continue
			result[sanitized_key] = _sanitize_string_array(value[key])
	return result

static func _sanitize_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value).duplicate(true)
	return {}
