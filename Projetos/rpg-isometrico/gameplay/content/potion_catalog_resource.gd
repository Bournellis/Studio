class_name PotionCatalogResource
extends Resource

const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")

@export var entries: Array[PotionDefinitionResource] = []
