class_name RaceCatalogResource
extends Resource

const RaceDefinitionResource = preload("res://gameplay/content/race_definition_resource.gd")

@export var entries: Array[RaceDefinitionResource] = []
