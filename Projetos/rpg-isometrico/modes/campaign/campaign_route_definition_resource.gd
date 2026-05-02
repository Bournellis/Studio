class_name CampaignRouteDefinitionResource
extends Resource

const CampaignStageReferenceResource = preload("res://modes/campaign/campaign_stage_reference_resource.gd")

@export var campaign_id: StringName
@export var difficulty_id: StringName
@export var campaign_display_name: String = ""
@export var difficulty_label: String = ""
@export var stage_references: Array[CampaignStageReferenceResource] = []

func matches(route_campaign_id: StringName, route_difficulty_id: StringName) -> bool:
	return campaign_id == route_campaign_id and difficulty_id == route_difficulty_id

func get_stage_count() -> int:
	return stage_references.size()

func get_stage_reference(stage_index: int) -> CampaignStageReferenceResource:
	if stage_index < 0 or stage_index >= stage_references.size():
		return null
	return stage_references[stage_index]
