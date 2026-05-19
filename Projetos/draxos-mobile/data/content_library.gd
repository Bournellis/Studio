extends Node

const CATALOG_PATH: String = "res://data/generated/draxos_mobile_catalog.tres"
const ContentGeneratorScript = preload("res://tools/content_generator.gd")

var _catalog

func ensure_loaded():
	if _catalog != null:
		return _catalog
	if not ResourceLoader.exists(CATALOG_PATH):
		var result: Dictionary = ContentGeneratorScript.new().generate_all()
		if not bool(result.get("ok", false)):
			push_error(str(result.get("message", "Content generation failed.")))
			return null
	_catalog = ResourceLoader.load(CATALOG_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if _catalog == null:
		push_error("Failed to load generated DraxosMobile catalog.")
	return _catalog

func reload() -> void:
	_catalog = null
	ensure_loaded()

func get_catalog():
	return ensure_loaded()

func get_collection(collection_id: String) -> Array:
	var catalog = ensure_loaded()
	if catalog == null:
		return []
	return catalog.get_collection(collection_id)

func get_item(collection_id: String, item_id: String) -> Dictionary:
	var catalog = ensure_loaded()
	if catalog == null:
		return {}
	return catalog.find_item(collection_id, item_id)

func has_item(collection_id: String, item_id: String) -> bool:
	var catalog = ensure_loaded()
	if catalog == null:
		return false
	return catalog.has_item(collection_id, item_id)

func get_display_name(collection_id: String, item_id: String) -> String:
	var item: Dictionary = get_item(collection_id, item_id)
	if item.is_empty():
		return item_id
	return str(item.get("display_name", item_id))

func validate_catalog() -> Dictionary:
	var result: Dictionary = ContentGeneratorScript.new().validate_current_catalog()
	if not bool(result.get("ok", false)):
		return result
	return {"ok": true, "message": "DraxosMobile content catalog is valid."}
