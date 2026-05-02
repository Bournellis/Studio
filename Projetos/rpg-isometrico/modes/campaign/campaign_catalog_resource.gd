class_name CampaignCatalogResource
extends Resource

const CampaignRouteDefinitionResource = preload("res://modes/campaign/campaign_route_definition_resource.gd")

const GENERATED_CAMPAIGN_CATALOG_PATH: String = "res://resources/generated/catalogs/campaign_catalog.tres"

@export var entries: Array[CampaignRouteDefinitionResource] = []

static func load_generated() -> CampaignCatalogResource:
	return load(GENERATED_CAMPAIGN_CATALOG_PATH) as CampaignCatalogResource

func find_route(campaign_id: StringName, difficulty_id: StringName) -> CampaignRouteDefinitionResource:
	for entry: CampaignRouteDefinitionResource in entries:
		if entry != null and entry.matches(campaign_id, difficulty_id):
			return entry
	return null

func get_routes_for_campaign(campaign_id: StringName) -> Array[CampaignRouteDefinitionResource]:
	var routes: Array[CampaignRouteDefinitionResource] = []
	for entry: CampaignRouteDefinitionResource in entries:
		if entry != null and entry.campaign_id == campaign_id:
			routes.append(entry)
	routes.sort_custom(func(a: CampaignRouteDefinitionResource, b: CampaignRouteDefinitionResource) -> bool:
		return _get_difficulty_order(a.difficulty_id) < _get_difficulty_order(b.difficulty_id)
	)
	return routes

func _get_difficulty_order(difficulty_id: StringName) -> int:
	match difficulty_id:
		&"easy":
			return 0
		&"normal":
			return 1
		&"free":
			return 2
		&"hard":
			return 3
		_:
			return 99
