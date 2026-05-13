extends Node

const MANIFEST_PATH: String = "res://data/definitions/visual_assets.json"
const REQUIRED_SURFACES: Array[String] = [
	"main_menu_background",
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

func class_portrait_entry(class_id: String) -> Dictionary:
	var portraits: Dictionary = Dictionary(ensure_loaded().get("class_portraits", {}))
	return Dictionary(portraits.get(class_id, {}))

func ship_button_entry(button_id: String) -> Dictionary:
	var buttons: Dictionary = Dictionary(ensure_loaded().get("ship_buttons", {}))
	return Dictionary(buttons.get(button_id, {}))

func ship_overlay_entry(overlay_id: String) -> Dictionary:
	var overlays: Dictionary = Dictionary(ensure_loaded().get("ship_overlays", {}))
	return Dictionary(overlays.get(overlay_id, {}))

func surface_texture(surface_id: String) -> Texture2D:
	var entry: Dictionary = surface_entry(surface_id)
	var texture: Texture2D = _load_texture(str(entry.get("path", "")), false)
	if texture != null:
		return texture
	var fallback_surface: String = str(entry.get("fallback_surface", ""))
	if fallback_surface != "":
		return surface_texture(fallback_surface)
	_warn_missing_path(str(entry.get("path", "")))
	return null

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

func class_portrait_texture(class_id: String) -> Texture2D:
	return _load_texture(str(class_portrait_entry(class_id).get("path", "")))

func ship_button_texture(button_id: String) -> Texture2D:
	return _load_texture(str(ship_button_entry(button_id).get("path", "")), false)

func ship_overlay_texture(overlay_id: String, class_id: String = "") -> Texture2D:
	var path: String = ship_overlay_texture_path(overlay_id, class_id)
	if path == "":
		return null
	if ship_overlay_requires_alpha(overlay_id) and not ship_overlay_show_without_alpha(overlay_id) and not _path_has_alpha(path):
		return null
	return _load_texture(path, false)

func ship_overlay_texture_path(overlay_id: String, class_id: String = "") -> String:
	var candidates: Array[String] = _ship_overlay_candidate_paths(ship_overlay_entry(overlay_id), class_id)
	for path: String in candidates:
		if path != "" and FileAccess.file_exists(path):
			return path
	return candidates[0] if not candidates.is_empty() else ""

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

func class_portrait_color(class_id: String) -> Color:
	var entry: Dictionary = class_portrait_entry(class_id)
	return _color_from_hex(str(entry.get("fallback_color", "#56616A")), Color(0.34, 0.38, 0.42))

func ship_button_color(button_id: String) -> Color:
	var entry: Dictionary = ship_button_entry(button_id)
	return _color_from_hex(str(entry.get("fallback_color", "#263038")), Color(0.15, 0.19, 0.22))

func ship_overlay_color(overlay_id: String) -> Color:
	var entry: Dictionary = ship_overlay_entry(overlay_id)
	return _color_from_hex(str(entry.get("fallback_color", "#33424A")), Color(0.20, 0.26, 0.29))

func ship_overlay_position(overlay_id: String) -> Vector2:
	var position: Dictionary = Dictionary(ship_overlay_entry(overlay_id).get("position", {}))
	return Vector2(
		clampf(float(position.get("x", 0.5)), 0.0, 1.0),
		clampf(float(position.get("y", 0.5)), 0.0, 1.0)
	)

func ship_overlay_size(overlay_id: String) -> Vector2:
	var size_entry: Dictionary = Dictionary(ship_overlay_entry(overlay_id).get("size", {}))
	return Vector2(
		clampf(float(size_entry.get("x", 0.16)), 0.02, 1.0),
		clampf(float(size_entry.get("y", 0.28)), 0.02, 1.0)
	)

func ship_overlay_label(overlay_id: String) -> String:
	return str(ship_overlay_entry(overlay_id).get("hover_label", overlay_id.capitalize()))

func ship_overlay_requires_alpha(overlay_id: String) -> bool:
	return bool(ship_overlay_entry(overlay_id).get("requires_alpha", false))

func ship_overlay_show_without_alpha(overlay_id: String) -> bool:
	return bool(ship_overlay_entry(overlay_id).get("show_without_alpha", true))

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
	var portraits: Dictionary = Dictionary(ensure_loaded().get("class_portraits", {}))
	for class_id: String in portraits.keys():
		_append_missing_path(missing, str(Dictionary(portraits.get(class_id, {})).get("path", "")))
	var buttons: Dictionary = Dictionary(ensure_loaded().get("ship_buttons", {}))
	for button_id: String in buttons.keys():
		_append_missing_path(missing, str(Dictionary(buttons.get(button_id, {})).get("path", "")))
	var overlays: Dictionary = Dictionary(ensure_loaded().get("ship_overlays", {}))
	for overlay_id: String in overlays.keys():
		var overlay_entry: Dictionary = Dictionary(overlays.get(overlay_id, {}))
		for path: String in _ship_overlay_all_declared_paths(overlay_entry):
			_append_missing_path(missing, path)
	return missing

func ship_overlay_alpha_debt_report() -> Array[String]:
	var warnings: Array[String] = []
	var overlays: Dictionary = Dictionary(ensure_loaded().get("ship_overlays", {}))
	for overlay_id: String in overlays.keys():
		if not ship_overlay_requires_alpha(str(overlay_id)):
			continue
		var overlay_entry: Dictionary = Dictionary(overlays.get(overlay_id, {}))
		for path: String in _ship_overlay_all_declared_paths(overlay_entry):
			if path == "" or not FileAccess.file_exists(path):
				continue
			if not _path_has_alpha(path):
				warnings.append("Ship overlay %s requires alpha, but %s has no transparent pixels." % [str(overlay_id), path])
	return warnings

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
		var portraits: Dictionary = Dictionary(manifest.get("class_portraits", {}))
		for class_option: Dictionary in catalog.class_options:
			var class_id: String = str(class_option.get("id", ""))
			var portrait_entry: Dictionary = Dictionary(portraits.get(class_id, {}))
			if portrait_entry.is_empty() or str(portrait_entry.get("path", "")) == "":
				errors.append("Missing class portrait entry: %s." % class_id)
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

	var ship_overlays: Dictionary = Dictionary(manifest.get("ship_overlays", {}))
	for overlay_id: String in ["deck", "map", "souls"]:
		var overlay_entry: Dictionary = Dictionary(ship_overlays.get(overlay_id, {}))
		if overlay_entry.is_empty():
			errors.append("Missing ship overlay entry: %s." % overlay_id)
			continue
		var declared_paths: Array[String] = _ship_overlay_all_declared_paths(overlay_entry)
		if declared_paths.is_empty():
			errors.append("Ship overlay %s needs a path or path_by_class entry." % overlay_id)
		var overlay_position: Dictionary = Dictionary(overlay_entry.get("position", {}))
		var overlay_size: Dictionary = Dictionary(overlay_entry.get("size", {}))
		if overlay_position.is_empty():
			errors.append("Ship overlay %s needs normalized position." % overlay_id)
		if overlay_size.is_empty():
			errors.append("Ship overlay %s needs normalized size." % overlay_id)
		var px: float = float(overlay_position.get("x", -1.0))
		var py: float = float(overlay_position.get("y", -1.0))
		var sx: float = float(overlay_size.get("x", -1.0))
		var sy: float = float(overlay_size.get("y", -1.0))
		if px < 0.0 or px > 1.0 or py < 0.0 or py > 1.0:
			errors.append("Ship overlay %s position must be normalized." % overlay_id)
		if sx <= 0.0 or sx > 1.0 or sy <= 0.0 or sy > 1.0:
			errors.append("Ship overlay %s size must be normalized and positive." % overlay_id)

	var missing_assets: Array[String] = missing_asset_report()
	var alpha_warnings: Array[String] = ship_overlay_alpha_debt_report()
	return {
		"ok": errors.is_empty(),
		"message": "Visual asset manifest valid." if errors.is_empty() else "\n".join(errors),
		"errors": errors,
		"missing_assets": missing_assets,
		"alpha_warnings": alpha_warnings
	}

func _empty_manifest() -> Dictionary:
	return {
		"version": 1,
		"surfaces": {},
		"frames": {},
		"cards": {},
		"class_portraits": {},
		"ship_buttons": {},
		"ship_overlays": {},
		"run_map_nodes": {}
	}

func _load_texture(path: String, warn_missing: bool = true) -> Texture2D:
	if path == "" or not FileAccess.file_exists(path):
		if warn_missing:
			_warn_missing_path(path)
		return null
	if ResourceLoader.exists(path):
		var loaded: Resource = load(path)
		if loaded is Texture2D:
			return loaded
	if path.to_lower().ends_with(".png"):
		var image: Image = Image.new()
		var image_error: Error = image.load(ProjectSettings.globalize_path(path))
		if image_error == OK:
			return ImageTexture.create_from_image(image)
	if warn_missing:
		_warn_missing_path(path)
	return null

func _append_missing_path(missing: Array[String], path: String) -> void:
	if path != "" and not FileAccess.file_exists(path):
		missing.append(path)

func _ship_overlay_candidate_paths(entry: Dictionary, class_id: String = "") -> Array[String]:
	var candidates: Array[String] = []
	if class_id != "":
		var by_class: Dictionary = Dictionary(entry.get("path_by_class", {}))
		var class_path: String = str(by_class.get(class_id, ""))
		if class_path != "":
			candidates.append(class_path)
	var path: String = str(entry.get("path", ""))
	if path != "":
		candidates.append(path)
	if class_id != "":
		var fallback_by_class: Dictionary = Dictionary(entry.get("fallback_path_by_class", {}))
		var fallback_class_path: String = str(fallback_by_class.get(class_id, ""))
		if fallback_class_path != "":
			candidates.append(fallback_class_path)
	var fallback_path: String = str(entry.get("fallback_path", ""))
	if fallback_path != "":
		candidates.append(fallback_path)
	return candidates

func _ship_overlay_all_declared_paths(entry: Dictionary) -> Array[String]:
	var paths: Array[String] = []
	for path: String in _ship_overlay_candidate_paths(entry):
		if path != "":
			paths.append(path)
	for dictionary_key: String in ["path_by_class", "fallback_path_by_class"]:
		var by_class: Dictionary = Dictionary(entry.get(dictionary_key, {}))
		for class_id: String in by_class.keys():
			var path: String = str(by_class.get(class_id, ""))
			if path != "" and not paths.has(path):
				paths.append(path)
	return paths

func _path_has_alpha(path: String) -> bool:
	if path == "" or not FileAccess.file_exists(path):
		return false
	var image: Image = Image.new()
	var image_error: Error = image.load(ProjectSettings.globalize_path(path))
	if image_error != OK:
		return false
	return image.detect_alpha() != Image.ALPHA_NONE

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
