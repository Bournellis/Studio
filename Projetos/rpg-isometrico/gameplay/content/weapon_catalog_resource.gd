class_name WeaponCatalogResource
extends Resource

const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")

@export var entries: Array[WeaponDefinitionResource] = []
