extends Node

const MANIFEST_PATH: String = "res://data/definitions/visual_assets.json"
const REQUIRED_SURFACES: Array[String] = [
	"ship_hub_background",
	"mission_map_background",
	"battle_board_background"
]
const REQUIRED_FRAMES: Array[String] = [
	"frame_arcano",
	"frame_invocador",
	"frame_necromante",
	"frame_elemental",
	"frame_neutral"
]

var _manifest: Dictionary = {}
var _load_attempted: bool = false
var _warned_paths: Dictionary = {}

func ensure_loaded() -> Dictionary:
	if _load_attempted:
		return _manifest
	_load_attempted = true
	if not FileAccess.file_exists(MANIFEST_PATH):
		push_warning("Visual asset manifest missing: %s" % MANIFEST_PATH)
		_manifest = _empty_manifest()
		return _manifest
	var manifest_text: String = FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed: Variant = JSON.parse_string(manifest_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Visual asset manifest is invalid JSON: %s" % MANIFEST_PATH)
		_manifest = _empty_manifest()
		return _manifest
	_manifest = Dictionary(parsed)
	return _manifest

func reload() -> void:
	_manifest = {}
	_load_attempted = false
	_warned_paths = {}
	ensure_loaded()

func surface_entry(surface_id: String) -> Dictionary:
	var surfaces: Dictionary = Dictionary(ensure_loaded().get("surfaces", {}))
	return Dictionary(surfaces.get(surface_id, {}))

func frame_entry(frame_id: String) -> Dictionary:
	var frames: Dictionary = Dictionary(ensure_loaded().get("frames", {}))
	return Dictionary(frames.get(frame_id, {}))

func card_entry(card_id: String) -> Dictionary:
	var cards: Dictionary = Dictionary(ensure_loaded().get("cards", {}))
	return Dictionary(cards.get(card_id, {}))

func surface_texture(surface_id: String) -> Texture2D:
	return _load_texture(str(surface_entry(surface_id).get("path", "")))

func card_art_texture(card_id: String) -> Texture2D:
	return _load_texture(str(card_entry(card_id).get("art_path", "")))

func card_frame_texture(card_id: String) -> Texture2D:
	var frame_id: String = card_frame_id(card_id)
	return _load_texture(str(frame_entry(frame_id).get("path", "")))

func card_frame_overlay_texture(card_id: String) -> Texture2D:
	if not card_frame_overlay_safe(card_id):
		return null
	return card_frame_texture(card_id)

func card_frame_overlay_safe(card_id: String) -> bool:
	return frame_overlay_safe(card_frame_id(card_id))

func frame_overlay_safe(frame_id: String) -> bool:
	var entry: Dictionary = frame_entry(frame_id)
	return bool(entry.get("overlay_safe", false))

func card_frame_id(card_id: String) -> String:
	var entry: Dictionary = card_entry(card_id)
	var frame_id: String = str(entry.get("frame_id", ""))
	if frame_id != "":
		return frame_id
	return "frame_neutral"

func card_frame_color(card_id: String) -> Color:
	var entry: Dictionary = frame_entry(card_frame_id(card_id))
	return _color_from_hex(str(entry.get("fallback_color", "#56616A")), Color(0.34, 0.38, 0.42))

func surface_fallback_color(surface_id: String) -> Color:
	var entry: Dictionary = surface_entry(surface_id)
	return _color_from_hex(str(entry.get("fallback_color", "#0B0D0F")), Color(0.045, 0.05, 0.055))

func surface_accent_color(surface_id: String) -> Color:
	var entry: Dictionary = surface_entry(surface_id)
	return _color_from_hex(str(entry.get("accent_color", "#5A7080")), Color(0.35, 0.44, 0.5))

func build_surface_background(surface_id: String) -> Control:
	var texture: Texture2D = surface_texture(surface_id)
	if texture != null:
		var rect: TextureRect = TextureRect.new()
		rect.name = "VisualSurface_%s" % surface_id
		rect.texture = texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		return rect

	var fallback: Control = Control.new()
	fallback.name = "VisualSurface_%s" % surface_id
	fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var fill: ColorRect = ColorRect.new()
	fill.name = "VisualSurfaceFallbackFill"
	fill.color = surface_fallback_color(surface_id)
	fill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fallback.add_child(fill)

	var accent: ColorRect = ColorRect.new()
	accent.name = "VisualSurfaceFallbackAccent"
	accent.color = _with_alpha(surface_accent_color(surface_id), 0.22)
	accent.anchor_left = 0.0
	accent.anchor_top = 0.0
	accent.anchor_right = 1.0
	accent.anchor_bottom = 0.0
	accent.offset_left = 0.0
	accent.offset_top = 0.0
	accent.offset_right = 0.0
	accent.offset_bottom = 96.0
	fallback.add_child(accent)

	var label: Label = Label.new()
	label.name = "VisualSurfaceFallbackLabel"
	label.text = str(surface_entry(surface_id).get("fallback_label", surface_id))
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.86, 0.88, 0.82, 0.45))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_right = -24.0
	label.offset_bottom = -20.0
	fallback.add_child(label)
	return fallback

func node_position(node_id: String) -> Vector2:
	var nodes: Dictionary = Dictionary(ensure_loaded().get("run_map_nodes", {}))
	var entry: Dictionary = Dictionary(nodes.get(node_id, {}))
	var position: Dictionary = Dictionary(entry.get("position", {}))
	return Vector2(
		clampf(float(position.get("x", 0.5)), 0.0, 1.0),
		clampf(float(position.get("y", 0.5)), 0.0, 1.0)
	)

func node_label(node_id: String) -> String:
	var nodes: Dictionary = Dictionary(ensure_loaded().get("run_map_nodes", {}))
	var entry: Dictionary = Dictionary(nodes.get(node_id, {}))
	return str(entry.get("label", node_id))

func card_display_text(card, context: Dictionary = {}) -> String:
	if card == null:
		return ""
	var entry: Dictionary = card_entry(str(card.id))
	var template: String = str(entry.get("text_template", ""))
	if template == "":
		return str(card.text)
	return _format_card_text(template, card, context)

func missing_asset_report() -> Array[String]:
	var missing: Array[String] = []
	var surfaces: Dictionary = Dictionary(ensure_loaded().get("surfaces", {}))
	for surface_id: String in surfaces.keys():
		_append_missing_path(missing, str(Dictionary(surfaces.get(surface_id, {})).get("path", "")))
	var frames: Dictionary = Dictionary(ensure_loaded().get("frames", {}))
	for frame_id: String in frames.keys():
		_append_missing_path(missing, str(Dictionary(frames.get(frame_id, {})).get("path", "")))
	var cards: Dictionary = Dictionary(ensure_loaded().get("cards", {}))
	for card_id: String in cards.keys():
		_append_missing_path(missing, str(Dictionary(cards.get(card_id, {})).get("art_path", "")))
	return missing

func validate_manifest(catalog = null) -> Dictionary:
	var errors: Array[String] = []
	if not FileAccess.file_exists(MANIFEST_PATH):
		errors.append("Visual asset manifest file is missing.")
	var manifest: Dictionary = ensure_loaded()
	if manifest.is_empty():
		errors.append("Visual asset manifest is empty or invalid.")

	var surfaces: Dictionary = Dictionary(manifest.get("surfaces", {}))
	for surface_id: String in REQUIRED_SURFACES:
		var entry: Dictionary = Dictionary(surfaces.get(surface_id, {}))
		if entry.is_empty() or str(entry.get("path", "")) == "":
			errors.append("Missing visual surface entry: %s." % surface_id)

	var frames: Dictionary = Dictionary(manifest.get("frames", {}))
	for frame_id: String in REQUIRED_FRAMES:
		var entry: Dictionary = Dictionary(frames.get(frame_id, {}))
		if entry.is_empty() or str(entry.get("path", "")) == "":
			errors.append("Missing card frame entry: %s." % frame_id)

	var cards: Dictionary = Dictionary(manifest.get("cards", {}))
	if catalog != null:
		for card in catalog.cards:
			var card_id: String = str(card.id)
			var entry: Dictionary = Dictionary(cards.get(card_id, {}))
			if entry.is_empty():
				errors.append("Missing visual card entry: %s." % card_id)
				continue
			if str(entry.get("art_path", "")) == "":
				errors.append("Visual card %s needs art_path." % card_id)
			var frame_id: String = str(entry.get("frame_id", ""))
			if frame_id == "" or not frames.has(frame_id):
				errors.append("Visual card %s references missing frame_id %s." % [card_id, frame_id])

		var node_positions: Dictionary = Dictionary(manifest.get("run_map_nodes", {}))
		for node: Dictionary in Array(catalog.run_map.get("nodes", [])):
			var node_id: String = str(node.get("id", ""))
			var node_entry: Dictionary = Dictionary(node_positions.get(node_id, {}))
			var position: Dictionary = Dictionary(node_entry.get("position", {}))
			if position.is_empty():
				errors.append("Run map node %s needs visual position." % node_id)
				continue
			var x: float = float(position.get("x", -1.0))
			var y: float = float(position.get("y", -1.0))
			if x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0:
				errors.append("Run map node %s position must be normalized." % node_id)

	var missing_assets: Array[String] = missing_asset_report()
	return {
		"ok": errors.is_empty(),
		"message": "Visual asset manifest valid." if errors.is_empty() else "\n".join(errors),
		"errors": errors,
		"missing_assets": missing_assets
	}

func _empty_manifest() -> Dictionary:
	return {
		"version": 1,
		"surfaces": {},
		"frames": {},
		"cards": {},
		"run_map_nodes": {}
	}

func _load_texture(path: String) -> Texture2D:
	if path == "" or not FileAccess.file_exists(path):
		_warn_missing_path(path)
		return null
	var loaded: Resource = load(path)
	if loaded is Texture2D:
		return loaded
	_warn_missing_path(path)
	return null

func _append_missing_path(missing: Array[String], path: String) -> void:
	if path != "" and not FileAccess.file_exists(path):
		missing.append(path)

func _warn_missing_path(path: String) -> void:
	if path == "" or _warned_paths.has(path):
		return
	_warned_paths[path] = true
	push_warning("Visual asset missing, using fallback: %s" % path)

func _format_card_text(template: String, card, context: Dictionary = {}) -> String:
	var values: Dictionary = _card_template_values(card, context)
	var result: String = template
	for key: String in values.keys():
		result = result.replace("{%s}" % key, str(values.get(key, "")))
	return result

func _card_template_values(card, context: Dictionary = {}) -> Dictionary:
	var values: Dictionary = {
		"cost": int(card.cost),
		"attack": int(card.attack),
		"health": int(card.health),
		"ability_power": int(context.get("ability_power", 0)),
		"flow": int(context.get("flow", 0))
	}
	var effect: Dictionary = Dictionary(card.effect)
	if effect.has("amount"):
		values["amount"] = int(context.get("amount", int(effect.get("amount", 0))))
	if effect.has("attack"):
		values["effect_attack"] = int(context.get("effect_attack", int(effect.get("attack", 0))))
	if effect.has("health"):
		values["effect_health"] = int(context.get("effect_health", int(effect.get("health", 0))))
	for nested_key: String in ["on_enter", "on_death"]:
		if effect.has(nested_key) and typeof(effect.get(nested_key)) == TYPE_DICTIONARY:
			var nested: Dictionary = Dictionary(effect.get(nested_key))
			if nested.has("amount") and not values.has("amount"):
				values["amount"] = int(context.get("amount", int(nested.get("amount", 0))))
	return values

func _color_from_hex(hex: String, fallback: Color) -> Color:
	if hex == "":
		return fallback
	return Color(hex)

func _with_alpha(color: Color, alpha: float) -> Color:
	return Color(color.r, color.g, color.b, alpha)
