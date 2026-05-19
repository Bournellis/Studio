class_name DraxosMobileCatalog
extends Resource

@export var schema_version: int = 1
@export var generated_from: PackedStringArray = PackedStringArray()
@export var collections: Dictionary = {}

func collection_ids() -> PackedStringArray:
	var ids: Array[String] = []
	for key: Variant in collections.keys():
		ids.append(str(key))
	ids.sort()
	return PackedStringArray(ids)

func get_collection(collection_id: String) -> Array:
	return Array(collections.get(collection_id, [])).duplicate(true)

func find_item(collection_id: String, item_id: String) -> Dictionary:
	for item: Variant in get_collection(collection_id):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_data: Dictionary = Dictionary(item)
		if str(item_data.get("id", "")) == item_id:
			return item_data.duplicate(true)
	return {}

func has_item(collection_id: String, item_id: String) -> bool:
	return not find_item(collection_id, item_id).is_empty()

func enabled_items(collection_id: String) -> Array:
	var result: Array = []
	for item: Variant in get_collection(collection_id):
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_data: Dictionary = Dictionary(item)
		if bool(item_data.get("enabled", false)):
			result.append(item_data.duplicate(true))
	return result

func total_count() -> int:
	var total: int = 0
	for key: Variant in collections.keys():
		total += Array(collections.get(key, [])).size()
	return total
