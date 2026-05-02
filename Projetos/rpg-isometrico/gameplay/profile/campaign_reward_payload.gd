class_name CampaignRewardPayload
extends RefCounted

const REWARD_KIND_STAGE_COMPLETION: StringName = &"campaign_stage_completion"

var reward_id: String = ""
var reward_kind: StringName = REWARD_KIND_STAGE_COMPLETION
var campaign_id: StringName = &""
var difficulty_id: StringName = &""
var stage_number: int = 0
var title: String = ""
var summary_lines: Array[String] = []
var permanent_skill_unlock_ids: Array[String] = []
var permanent_potion_unlock_ids: Array[String] = []
var menu_unlock_mode_ids: Array[String] = []
var pending_level_increase: int = 0
var pending_skill_points: int = 0
var next_level: int = 0
var marks_tutorial_completed: bool = false

func apply_dictionary(payload: Dictionary) -> CampaignRewardPayload:
	reward_id = str(payload.get("reward_id", ""))
	reward_kind = StringName(str(payload.get("reward_kind", String(REWARD_KIND_STAGE_COMPLETION))))
	campaign_id = StringName(str(payload.get("campaign_id", "")))
	difficulty_id = StringName(str(payload.get("difficulty_id", "")))
	stage_number = maxi(0, int(payload.get("stage_number", 0)))
	title = str(payload.get("title", ""))
	summary_lines = _sanitize_string_array(payload.get("summary_lines", []))
	permanent_skill_unlock_ids = _sanitize_string_array(payload.get("permanent_skill_unlock_ids", []))
	permanent_potion_unlock_ids = _sanitize_string_array(payload.get("permanent_potion_unlock_ids", []))
	menu_unlock_mode_ids = _sanitize_string_array(payload.get("menu_unlock_mode_ids", []))
	pending_level_increase = maxi(0, int(payload.get("pending_level_increase", 0)))
	pending_skill_points = maxi(0, int(payload.get("pending_skill_points", 0)))
	next_level = maxi(0, int(payload.get("next_level", 0)))
	marks_tutorial_completed = bool(payload.get("marks_tutorial_completed", false))
	return self

func to_dictionary() -> Dictionary:
	return {
		"reward_id": reward_id,
		"reward_kind": String(reward_kind),
		"campaign_id": String(campaign_id),
		"difficulty_id": String(difficulty_id),
		"stage_number": stage_number,
		"title": title,
		"summary_lines": summary_lines.duplicate(),
		"permanent_skill_unlock_ids": permanent_skill_unlock_ids.duplicate(),
		"permanent_potion_unlock_ids": permanent_potion_unlock_ids.duplicate(),
		"menu_unlock_mode_ids": menu_unlock_mode_ids.duplicate(),
		"pending_level_increase": pending_level_increase,
		"pending_skill_points": pending_skill_points,
		"next_level": next_level,
		"marks_tutorial_completed": marks_tutorial_completed
	}

func is_empty() -> bool:
	return (
		reward_id == ""
		and
		stage_number <= 0
		and title == ""
		and summary_lines.is_empty()
		and permanent_skill_unlock_ids.is_empty()
		and permanent_potion_unlock_ids.is_empty()
		and menu_unlock_mode_ids.is_empty()
		and pending_level_increase <= 0
		and pending_skill_points <= 0
		and next_level <= 0
		and not marks_tutorial_completed
	)

func build_overlay_lines() -> Array[String]:
	var lines: Array[String] = []
	if next_level > 0 and pending_level_increase > 0:
		lines.append("Nivel %d preparado para a proxima etapa da Campanha Classica." % next_level)
	if pending_skill_points > 0:
		lines.append("%d ponto%s de habilidade aguardam escolha para reforcar o kit." % [
			pending_skill_points,
			"" if pending_skill_points == 1 else "s"
		])
	for line: String in summary_lines:
		lines.append(line)
	return lines

static func _sanitize_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is PackedStringArray:
		for entry: String in value:
			if entry == "" or result.has(entry):
				continue
			result.append(entry)
	elif value is Array:
		for entry_variant: Variant in value:
			var entry: String = str(entry_variant)
			if entry == "" or result.has(entry):
				continue
			result.append(entry)
	return result
