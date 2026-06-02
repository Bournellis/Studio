extends SceneTree

const OUTPUT_DIR := "res://build/track15_mobile_ux_checkpoint"
const VIEWPORT_SIZE := Vector2i(390, 844)

class CaptureHost:
	extends Control

	const LOCAL_COLORS := {
		"bg_deep": Color("#080B10"),
		"bg_void": Color("#040507"),
		"bg_shell": Color("#0B0D12"),
		"bg_panel": Color("#151B22"),
		"bg_panel_alt": Color("#202832"),
		"bg_elevated": Color("#1A2028"),
		"bg_pressed": Color("#242C36"),
		"bg_blood_wash": Color("#26070B"),
		"border_default": Color("#405060"),
		"border_active": Color("#6FA6C8"),
		"border_subtle": Color("#26313D"),
		"border_blood": Color("#6D1D25"),
		"border_gold": Color("#806B36"),
		"text_primary": Color("#F0EEE5"),
		"text_secondary": Color("#AEB7BF"),
		"text_muted": Color("#77818A"),
		"text_on_accent": Color("#FFF6EA"),
		"accent_astral": Color("#5DD4C8"),
		"accent_blood": Color("#B95757"),
		"accent_crimson": Color("#D53F4A"),
		"accent_ritual": Color("#A76DFF"),
		"accent_bone": Color("#D6C08A"),
		"accent_ember": Color("#E08442"),
		"status_success": Color("#66B56F"),
		"status_warning": Color("#D6A84F"),
		"status_error": Color("#D86D6D"),
		"placeholder": Color("#2B3440"),
	}

	var _compact_layout := true
	var _first_screen_root: Control
	var _content_body: VBoxContainer
	var _action_buttons: Dictionary = {}
	var _current_action_grid: GridContainer
	var _timeline_label: Label
	var _base_state_container: VBoxContainer
	var _shop_state_container: VBoxContainer
	var _selected_base_structure_id := "altar_das_almas"
	var _current_screen := "entry"
	var _update_gate: Dictionary = {}
	var _auth_email_input: LineEdit
	var _auth_password_input: LineEdit
	var _auth_username_input: LineEdit
	var _auth_invite_input: LineEdit
	var _immersive_feedback_panel: Control
	var _immersive_status_label: Label
	var _immersive_detail_label: Label
	var _immersive_error_label: Label
	var _refuge_menu_popup: PopupPanel

	func configure(route_id: String, use_content_shell: bool, title_text: String = "") -> void:
		name = "Track15CaptureHost"
		_current_screen = route_id
		_compact_layout = true
		_first_screen_root = self
		_action_buttons.clear()
		set_anchors_preset(Control.PRESET_TOP_LEFT)
		position = Vector2.ZERO
		size = Vector2(VIEWPORT_SIZE)
		custom_minimum_size = Vector2(VIEWPORT_SIZE)
		if use_content_shell:
			_build_content_shell(title_text)

	func _build_content_shell(title_text: String) -> void:
		var background := ColorRect.new()
		background.color = _color("bg_deep")
		background.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(background)

		var margin := MarginContainer.new()
		margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		add_child(margin)

		var scroll := ScrollContainer.new()
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		margin.add_child(scroll)

		_content_body = VBoxContainer.new()
		_content_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_content_body.custom_minimum_size = Vector2(VIEWPORT_SIZE.x - 20, 0)
		_content_body.add_theme_constant_override("separation", 10)
		scroll.add_child(_content_body)
		var sync_content_width := func() -> void:
			_content_body.custom_minimum_size.x = maxf(0.0, scroll.size.x - 18.0)
		scroll.resized.connect(sync_content_width)
		sync_content_width.call()

		var title := Label.new()
		title.text = title_text
		title.add_theme_color_override("font_color", _color("text_primary"))
		title.add_theme_font_size_override("font_size", 24)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_content_body.add_child(title)

	func _button_min_size() -> Vector2:
		return Vector2(0, 56)

	func _base_map_columns() -> int:
		return 1

	func _surface_columns(max_columns: int = 2) -> int:
		return mini(maxi(max_columns, 1), 1 if _compact_layout else max_columns)

	func _battle_lab_available() -> bool:
		return true

	func _progression_lab_available() -> bool:
		return true

	func _openworld_mode_available() -> bool:
		return true

	func _prepare_touch_button(button: Button) -> void:
		button.custom_minimum_size.x = maxf(button.custom_minimum_size.x, 56)
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 56)
		button.add_theme_font_size_override("font_size", 17)

	func _apply_action_button_style(button: Button, action_id: String, screen_id: String = "") -> void:
		var primary := action_id == "open_arena" or action_id == "return_refuge" or action_id == "arena_resolve_duel"
		var accent := "accent_blood" if action_id == "open_arena" else "accent_astral"
		if screen_id == "shop":
			accent = "accent_bone"
		var style := StyleBoxFlat.new()
		style.bg_color = _color("bg_panel").lerp(_color(accent), 0.18 if primary else 0.08)
		style.border_color = _color(accent if primary else "border_default")
		style.set_border_width_all(2 if primary else 1)
		style.set_corner_radius_all(6)
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		button.add_theme_color_override("font_color", _color("text_primary"))
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)

	func _trigger_action(_action_id: String, _confirm_message: String = "") -> void:
		pass

	func _normalize_route(route_id: String) -> String:
		return route_id

	func _show_screen(route_id: String, _push_history: bool = true) -> void:
		_current_screen = route_id

	func _sync_immersive_feedback() -> void:
		if _immersive_feedback_panel != null:
			_immersive_feedback_panel.visible = false
		if _immersive_status_label != null:
			_immersive_status_label.text = ""
			_immersive_status_label.visible = false
		if _immersive_detail_label != null:
			_immersive_detail_label.text = ""
			_immersive_detail_label.visible = false
		if _immersive_error_label != null:
			_immersive_error_label.text = ""
			_immersive_error_label.visible = false

	func _sync_buttons() -> void:
		pass

	func _add_section_label(text: String) -> Label:
		_current_action_grid = null
		var label := Label.new()
		label.text = text
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", _color("text_primary"))
		_content_body.add_child(label)
		return label

	func _add_body_text(text: String) -> Label:
		_current_action_grid = null
		var label := Label.new()
		label.text = text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", _color("text_secondary"))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_content_body.add_child(label)
		return label

	func _add_output_label(text: String) -> Label:
		_current_action_grid = null
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_content_body.add_child(panel)

		var label := Label.new()
		label.text = text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", _color("text_primary"))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_child(label)
		return label

	func _add_content_control(control: Control) -> void:
		_current_action_grid = null
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_content_body.add_child(control)

	func _add_action_button(text: String, action_id: String, confirm_message: String = "", disabled: bool = false, tooltip: String = "") -> Button:
		var button := Button.new()
		button.text = text
		button.tooltip_text = tooltip if tooltip != "" else text
		button.disabled = disabled
		button.custom_minimum_size = _button_min_size()
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_prepare_touch_button(button)
		button.pressed.connect(func() -> void:
			_trigger_action(action_id, confirm_message)
		)
		_ensure_action_grid().add_child(button)
		_action_buttons[action_id] = button
		return button

	func _ensure_action_grid() -> GridContainer:
		if _current_action_grid != null and is_instance_valid(_current_action_grid):
			return _current_action_grid
		var grid := GridContainer.new()
		grid.columns = 1
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		_content_body.add_child(grid)
		_current_action_grid = grid
		return grid

	func _add_responsive_panel_layout(container: VBoxContainer, panels: Array, _max_columns: int = 2) -> void:
		for panel: Variant in panels:
			if panel is Control:
				container.add_child(panel as Control)

	func _panel_style(bg_token: String, border_token: String) -> StyleBoxFlat:
		var style := StyleBoxFlat.new()
		style.bg_color = _color(bg_token)
		style.border_color = _color(border_token)
		style.set_border_width_all(1)
		style.set_corner_radius_all(6)
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		return style

	func _color(token: String) -> Color:
		return Color(LOCAL_COLORS.get(token, Color.WHITE))

var _current_capture: Control
var _failures: Array[String] = []
var _session_store: Node
var _hub_surface_presenter_script: GDScript
var _base_surface_presenter_script: GDScript
var _shop_surface_presenter_script: GDScript
var _battle_replay_presenter_script: GDScript
var _preparation_presenter_script: GDScript
var _arena_surface_presenter_script: GDScript

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_capture()
	quit(exit_code)

func _run_capture() -> int:
	root.size = VIEWPORT_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	_session_store = root.get_node_or_null("/root/SessionStore")
	if _session_store == null:
		_failures.append("SessionStore autoload is not available.")
		return 1
	if not _load_presenters():
		return 1
	_seed_session_store()

	await _capture_entry()
	await _capture_refuge()
	await _capture_preparation()
	await _capture_arena_selection()
	await _capture_arena_active()
	await _capture_arena_replay()
	await _capture_arena_buff_choice()
	await _capture_battle()
	await _capture_summary()
	await _capture_arena_summary()
	await _capture_base()
	await _capture_shop()

	_clear_capture()
	if _failures.is_empty():
		print("[track15-capture] OK screenshots in %s" % ProjectSettings.globalize_path(OUTPUT_DIR))
		return 0

	for failure: String in _failures:
		printerr("[track15-capture] %s" % failure)
	return 1

func _capture_entry() -> void:
	var host := _new_host("entry", false)
	_hub_surface_presenter_script.render_entry(host)
	await _capture("01_entry.png")

func _capture_refuge() -> void:
	var host := _new_host("refuge", false)
	_hub_surface_presenter_script.render_refuge(host)
	await _capture("02_refugio.png")

func _capture_preparation() -> void:
	var host := _new_host("preparation", true, "Preparacao")
	host._content_body.add_child(_preparation_presenter_script.preparation_panel(host, true))
	await _capture("07_preparacao.png")

func _capture_arena_selection() -> void:
	_apply_sample_arena_selection_state()
	var host := _new_host("arena_selection", true, "Arena PVE")
	var presenter = _arena_surface_presenter_script.new()
	presenter.render_selection(host)
	await _capture("08_arena_selection.png")

func _capture_arena_active() -> void:
	_apply_sample_arena_active_state()
	var host := _new_host("arena_active", true, "Tentativa")
	var presenter = _arena_surface_presenter_script.new()
	presenter.render_active(host)
	await _capture("09_arena_active.png")
	var toggle := _find_button_by_text(host, "Mostrar detalhes do loadout")
	if toggle != null:
		toggle.pressed.emit()
		await root.get_tree().process_frame
		await _capture("12_arena_loadout_expanded.png")

func _capture_arena_replay() -> void:
	var host := _new_host("arena_replay", false)
	var presenter = _battle_replay_presenter_script.new()
	presenter.render_fullscreen_replay(host, host, true, _sample_arena_battle_log(), _sample_rewards())
	await _capture("13_arena_replay.png")

func _capture_arena_buff_choice() -> void:
	_apply_sample_arena_buff_state()
	var host := _new_host("arena_buff_choice", true, "Buff")
	var presenter = _arena_surface_presenter_script.new()
	presenter.render_buff_choice(host)
	await _capture("10_arena_buff.png")

func _capture_battle() -> void:
	var host := _new_host("battle_running", false)
	var presenter = _battle_replay_presenter_script.new()
	presenter.render_fullscreen_replay(host, host, true, _sample_battle_log(), _sample_rewards())
	await _capture("03_batalha.png")

func _capture_summary() -> void:
	var host := _new_host("battle_summary", false)
	var presenter = _battle_replay_presenter_script.new()
	presenter.render_fullscreen_summary(host, host, true, _sample_battle_log(), _sample_rewards(), _session_resources(), false)
	await _capture("04_summary.png")

func _capture_arena_summary() -> void:
	_apply_sample_arena_summary_state()
	var host := _new_host("arena_summary", true, "Resultado Arena")
	var presenter = _arena_surface_presenter_script.new()
	presenter.render_summary(host)
	await _capture("11_arena_summary.png")

func _capture_base() -> void:
	var host := _new_host("base", true, "Base")
	_base_surface_presenter_script.render(host)
	await _capture("05_base.png")

func _capture_shop() -> void:
	var host := _new_host("shop", true, "Loja")
	_shop_surface_presenter_script.render(host)
	await _capture("06_loja.png")

func _load_presenters() -> bool:
	_hub_surface_presenter_script = load("res://modes/boot/surfaces/hub_surface_presenter.gd") as GDScript
	_base_surface_presenter_script = load("res://modes/boot/surfaces/base_surface_presenter.gd") as GDScript
	_shop_surface_presenter_script = load("res://modes/boot/surfaces/shop_surface_presenter.gd") as GDScript
	_battle_replay_presenter_script = load("res://modes/boot/surfaces/battle_replay_presenter.gd") as GDScript
	_preparation_presenter_script = load("res://modes/boot/surfaces/hub_surface_preparation_presenter.gd") as GDScript
	_arena_surface_presenter_script = load("res://modes/boot/surfaces/arena_surface_presenter.gd") as GDScript
	if _hub_surface_presenter_script == null:
		_failures.append("Could not load hub surface presenter.")
	if _base_surface_presenter_script == null:
		_failures.append("Could not load base surface presenter.")
	if _shop_surface_presenter_script == null:
		_failures.append("Could not load shop surface presenter.")
	if _battle_replay_presenter_script == null:
		_failures.append("Could not load battle replay presenter.")
	if _preparation_presenter_script == null:
		_failures.append("Could not load preparation presenter.")
	if _arena_surface_presenter_script == null:
		_failures.append("Could not load arena surface presenter.")
	return _failures.is_empty()

func _new_host(route_id: String, use_content_shell: bool, title_text: String = "") -> CaptureHost:
	_clear_capture()
	var host := CaptureHost.new()
	host.configure(route_id, use_content_shell, title_text)
	root.add_child(host)
	_current_capture = host
	return host

func _clear_capture() -> void:
	if _current_capture != null and is_instance_valid(_current_capture):
		root.remove_child(_current_capture)
		_current_capture.queue_free()
	_current_capture = null

func _find_button_by_text(node: Node, text: String) -> Button:
	if node == null:
		return null
	if node is Button and str((node as Button).text) == text:
		return node as Button
	for child: Node in node.get_children():
		var found := _find_button_by_text(child, text)
		if found != null:
			return found
	return null

func _capture(file_name: String) -> void:
	await process_frame
	await process_frame
	if DisplayServer.get_name().to_lower().contains("headless"):
		_failures.append("Renderer is headless; cannot capture %s." % file_name)
		return
	var texture := root.get_texture()
	if texture == null:
		_failures.append("Renderer did not expose viewport texture for %s." % file_name)
		return
	var image := texture.get_image()
	if image == null or image.is_empty():
		_failures.append("Screenshot is empty: %s" % file_name)
		return
	var path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join(file_name))
	var error := image.save_png(path)
	if error != OK:
		_failures.append("Could not save screenshot %s: %s" % [file_name, str(error)])

func _seed_session_store() -> void:
	_session_store.call("clear_session")
	_session_store.call("set_active_save_type", "normal")
	_session_store.call("apply_auth_session", {
		"access_token": "track15_visual_access",
		"refresh_token": "track15_visual_refresh",
		"expires_at": int(Time.get_unix_time_from_system()) + 3600,
		"user_id": "track15_visual_user",
		"auth_method": "email",
		"email": "fabio@draxos.local",
	})
	_session_store.call("apply_server_state", {
		"ok": true,
		"player": {
			"id": "track15_visual_player",
			"username": "Fabio",
			"display_name": "Fabio",
			"level": 12,
			"power": 1480,
			"save_type": "normal",
		},
		"resources": _sample_resources(),
		"build": {
			"instrumento_ritual": "cajado_sanguineo",
			"doutrina": "hemomancia",
			"familiar": "corvo_ossario",
		},
		"last_battle_id": "track15_visual_battle",
	})
	_session_store.call("apply_base_result", {
		"ok": true,
		"base": _sample_base_state(),
		"resources": _sample_resources(),
	})
	_session_store.call("apply_battle_result", {
		"ok": true,
		"battle_log": _sample_battle_log(),
		"rewards": _sample_rewards(),
		"competition": {
			"ranking": {"rank": 42, "arena_points": 1260},
			"arena_delta": 18,
		},
	})
	_session_store.call("apply_monetization_result", {
		"ok": true,
		"monetization": _sample_monetization_state(),
		"resources": _sample_resources(),
		"player": {
			"id": "track15_visual_player",
			"username": "Fabio",
			"display_name": "Fabio",
			"level": 12,
			"power": 1480,
			"save_type": "normal",
		},
	})
	_session_store.call("apply_build_result", _sample_build_result())

func _sample_build_result() -> Dictionary:
	return {
		"ok": true,
		"save_type": "normal",
		"build": {
			"weapon_type": "varinha_cinzas",
			"weapon_level": 4,
			"passive_id": "doutrina_pavor",
			"passive_level": 2,
			"pet_id": "corvo_pressagio",
			"pet_level": 3,
		},
		"combat_build": {
			"level": 12,
			"power": 1480,
			"weapon_type": "varinha_cinzas",
			"weapon_level": 4,
			"passive_id": "doutrina_pavor",
			"passive_level": 2,
			"pet_id": "corvo_pressagio",
			"pet_level": 3,
			"inventory": [{"item_id": "pocao_vida", "quantity": 3}],
			"potion_slots": [{
				"slot_index": 1,
				"potion_id": "pocao_vida",
				"behavior": {"enabled": true, "hp": {"mode": "below", "percent": 40}},
			}],
			"spell_slots": [
				{"slot_index": 1, "unlock_level": 1, "unlocked": true, "spell_id": "sussurro_medo", "behavior": {"enabled": true}},
				{"slot_index": 2, "unlock_level": 1, "unlocked": true, "spell_id": "incisao_ritual", "behavior": {"enabled": true}},
				{"slot_index": 3, "unlock_level": 25, "unlocked": false, "spell_id": null, "behavior": {}},
			],
			"equipment_options": {
				"weapons": [
					{"id": "varinha_cinzas", "display_name": "Varinha de Cinzas", "unlocked": true, "equipped": true},
					{"id": "athame_hematico", "display_name": "Athame Hematico", "unlocked": true, "equipped": false},
				],
				"spells": [
					{"id": "sussurro_medo", "display_name": "Sussurro do Medo", "unlocked": true, "equipped": true},
					{"id": "incisao_ritual", "display_name": "Incisao Ritual", "unlocked": true, "equipped": true},
				],
				"doutrines": [
					{"id": "doutrina_pavor", "display_name": "Doutrina do Pavor", "unlocked": true, "equipped": true},
					{"id": "pacto_familiar", "display_name": "Pacto Familiar", "unlocked": true, "equipped": false},
				],
				"familiars": [
					{"id": "corvo_pressagio", "display_name": "Corvo de Pressagio", "unlocked": true, "equipped": true},
					{"id": "gato_tumular", "display_name": "Gato Tumular", "unlocked": true, "equipped": false},
				],
			},
		},
	}

func _apply_sample_arena_selection_state() -> void:
	_session_store.call("apply_arena_result", {
		"ok": true,
		"body": {
			"ok": true,
			"schema_version": "pve_arena_state_v1",
			"progress": {
				"tutorial_completed": true,
				"metadata": {
					"completed_tiers": {"arena_tutorial_cinzas:s1_d00_intro": true},
					"completed_arenas": {"arena_tutorial_cinzas": true},
				},
			},
			"arenas": [
				{
					"id": "arena_tutorial_cinzas",
					"display_name": "Tutorial: Cinzas do Refugio",
					"duel_count": 1,
					"unlocked": true,
					"difficulties": [
						{"difficulty_id": "s1_d00_intro", "max_steps": 1, "recommended_level_min": 1, "recommended_level_max": 3, "recommended_power_min": 80, "recommended_power_max": 180, "unlocked": true},
					],
				},
				{
					"id": "arena_cinzas_curta",
					"display_name": "Arena Curta das Cinzas",
					"duel_count": 3,
					"unlocked": true,
					"difficulties": [
						{"difficulty_id": "s1_d00_intro", "max_steps": 3, "recommended_level_min": 3, "recommended_level_max": 4, "recommended_power_min": 160, "recommended_power_max": 260, "unlocked": true},
						{"difficulty_id": "s1_d01_aprendiz", "max_steps": 3, "recommended_level_min": 5, "recommended_level_max": 6, "recommended_power_min": 280, "recommended_power_max": 470, "unlocked": true},
					],
				},
				{
					"id": "arena_veu_curta",
					"display_name": "Arena do Veu",
					"duel_count": 4,
					"unlocked": false,
					"locked_reason": "Conclua a Arena Curta.",
					"difficulties": [
						{"difficulty_id": "s1_d02_iniciado", "max_steps": 4, "recommended_level_min": 8, "recommended_level_max": 10, "recommended_power_min": 650, "recommended_power_max": 1300, "unlocked": false, "locked_reason": "Conclua a Arena Curta."},
					],
				},
			],
		},
	})

func _apply_sample_arena_active_state() -> void:
	_session_store.call("apply_arena_result", {
		"ok": true,
		"body": {
			"ok": true,
			"schema_version": "pve_arena_state_v1",
			"active_attempt": _sample_active_attempt(false),
		},
	})

func _apply_sample_arena_buff_state() -> void:
	_session_store.call("apply_arena_result", {
		"ok": true,
		"body": {
			"ok": true,
			"schema_version": "pve_arena_state_v1",
			"active_attempt": _sample_active_attempt(true),
		},
	})

func _apply_sample_arena_summary_state() -> void:
	_session_store.call("apply_arena_result", {
		"ok": true,
		"body": {
			"ok": true,
			"schema_version": "pve_arena_state_v1",
			"active_attempt": {
				"attempt_id": "visual-arena",
				"arena_id": "arena_cinzas_curta",
				"status": "completed",
				"duel_count": 3,
				"duels_won": 3,
				"locked_loadout_hash": "sha256:visual",
			},
			"summary": {
				"status": "completed",
				"duels_won": 3,
				"duels_total": 3,
				"reward_label": "XP, Ossos e Almas aplicados",
			},
		},
	})

func _sample_active_attempt(with_buff_offer: bool) -> Dictionary:
	var attempt := {
		"attempt_id": "visual-arena",
		"arena_id": "arena_cinzas_curta",
		"status": "active",
		"duel_index": 1,
		"duel_count": 3,
		"duels_won": 1,
		"enemy_sequence": ["Sentinela das Cinzas", "Guardiao da Barreira", "Arauto do Veu"],
		"locked_loadout_hash": "sha256:visual",
		"loadout_summary": {"label": "Varinha de Cinzas, 2 habilidades, Pocao de Vida"},
		"next_enemy": {"display_name": "Guardiao da Barreira"},
		"temporary_buffs": [{"id": "arena_buff_vitalidade_menor", "display_name": "Vitalidade Menor"}],
	}
	if with_buff_offer:
		attempt["status"] = "awaiting_buff"
		attempt["buff_offer"] = {
			"choices": [
				{"id": "arena_buff_vitalidade_menor", "display_name": "Vitalidade Menor", "description": "+4% HP maximo"},
				{"id": "arena_buff_potencia_menor", "display_name": "Potencia Ritual Menor", "description": "+4% Potencia Ritual"},
				{"id": "arena_buff_guarda_menor", "display_name": "Guarda Menor", "description": "+4% Guarda"},
			],
		}
	return attempt

func _session_resources() -> Dictionary:
	var value: Variant = _session_store.get("resources") if _session_store != null else {}
	return Dictionary(value) if value is Dictionary else {}

func _sample_resources() -> Dictionary:
	return {
		"almas": 1850,
		"energia": 72,
		"sangue": 430,
		"cristais": 260,
		"ossos": 910,
		"diamante": 320,
	}

func _sample_base_state() -> Dictionary:
	return {
		"construction_slots": 2,
		"structures": [
			_structure("altar_das_almas", "Altar das Almas", 7, "almas", 96, 240, true, {"almas": 280, "ossos": 90}),
			_structure("nucleo_energia", "Nucleo de Energia", 5, "energia", 18, 70, false, {"almas": 210, "cristais": 80}),
			_structure("pocos_sangue", "Pocos de Sangue", 4, "sangue", 42, 110, false, {"sangue": 180, "ossos": 60}),
			_structure("minas_cristal", "Minas de Cristal", 3, "cristais", 24, 90, false, {"almas": 190, "cristais": 75}),
			_structure("estrutura_stats", "Sala de Treino", 3, "", 0, 0, false, {"almas": 260}),
			_structure("ossario", "Ossario", 6, "ossos", 120, 300, false, {"ossos": 220}),
		],
		"jobs": [
			{
				"structure_id": "nucleo_energia",
				"display_name": "Nucleo de Energia",
				"target_level": 6,
				"status": "active",
				"remaining_seconds": 1840,
			},
		],
	}

func _structure(
	structure_id: String,
	display_name: String,
	level: int,
	produces: String,
	pending: float,
	cap: float,
	can_upgrade: bool,
	cost: Dictionary
) -> Dictionary:
	return {
		"structure_id": structure_id,
		"display_name": display_name,
		"level": level,
		"max_level": 40,
		"description": "Parte viva da rotina do Refugio.",
		"produces": produces,
		"daily_production": maxf(pending * 1.8, 10.0),
		"pending_collectable": pending,
		"storage_cap": cap,
		"benefit_label": "Melhora a rotina e o poder do save.",
		"next_level": level + 1,
		"upgrade_cost": cost,
		"upgrade_duration_seconds": 3600 + level * 120,
		"can_upgrade": can_upgrade,
		"blocked_reason": "" if can_upgrade else "INSUFFICIENT_RESOURCES",
		"blocked_message": "Pronto para evoluir" if can_upgrade else "Junte recursos para evoluir",
	}

func _sample_battle_log() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "track15_visual_battle",
		"mode": "MVP_ONLY",
		"duration": 18.5,
		"result": {
			"winner": "player",
			"ranking": {"rank": 42, "arena_points": 1260},
			"arena_delta": 18,
		},
		"events": [
			{"t": 1.0, "seq": 1, "type": "spell_cast", "source": "player", "target": "opponent", "spell_id": "hemorragia_induzida", "damage": 42, "hp_after": 258},
			{"t": 2.2, "seq": 2, "type": "pet_attack", "source": "player", "target": "opponent", "pet_id": "corvo_ossario", "damage": 24, "hp_after": 234},
			{"t": 4.8, "seq": 3, "type": "spell_cast", "source": "opponent", "target": "player", "spell_id": "lanca_fria", "damage": 35, "hp_after": 265},
			{"t": 8.0, "seq": 4, "type": "weapon_attack", "source": "player", "target": "opponent", "damage": 58, "hp_after": 176},
			{"t": 16.5, "seq": 5, "type": "battle_end", "winner": "player"},
		],
	}

func _sample_arena_battle_log() -> Dictionary:
	var battle_log := _sample_battle_log()
	battle_log["battle_id"] = "track15_visual_arena_duel"
	battle_log["mode"] = "PVE_ARENA_V1"
	battle_log["metadata"] = {
		"mode": "PVE_ARENA_V1",
		"arena_id": "arena_cinzas_curta",
		"difficulty_id": "s1_d01_aprendiz",
		"duel_index": 2,
		"duel_count": 3,
	}
	battle_log["participants"] = {
		"player": {"id": "track15_visual_player", "display_name": "Draxos"},
		"opponent": {"id": "arena_guardiao", "display_name": "Guardiao da Barreira", "is_bot": true},
	}
	return battle_log

func _sample_rewards() -> Dictionary:
	return {
		"resources": {
			"xp": 50,
			"almas": 120,
			"sangue": 35,
			"ossos": 80,
		},
	}

func _sample_monetization_state() -> Dictionary:
	return {
		"shop_summary": {
			"diamond_balance": 320,
			"currency": "diamante",
			"premium_unlocked": false,
			"daily_redeems_claimed": 1,
			"daily_redeems_total": 4,
			"daily_redeem_period_key": "2026-05-28",
			"reset_timezone": "America/Sao_Paulo",
			"convenience_owned": [],
		},
		"alpha_products": [
			{
				"id": "alpha_redeem_small",
				"label": "Resgate pequeno",
				"daily_redeem": true,
				"already_redeemed": true,
				"can_purchase": false,
				"resources": {"diamante": 40},
				"cost": {},
				"description": "Pacote diario pequeno para teste interno.",
			},
			{
				"id": "alpha_redeem_medium",
				"label": "Resgate medio",
				"daily_redeem": true,
				"already_redeemed": false,
				"can_purchase": true,
				"resources": {"diamante": 120},
				"cost": {},
				"description": "Pacote diario medio para acelerar uma rodada curta.",
			},
			{
				"id": "alpha_energy_pack_small",
				"label": "Comprar Energia",
				"daily_redeem": false,
				"can_purchase": true,
				"resources": {"energia": 80},
				"cost": {"diamante": 80},
				"effect": {},
				"description": "Energia para continuar upgrades do Refugio.",
			},
			{
				"id": "alpha_double_construction_queue",
				"label": "Comprar fila dupla",
				"daily_redeem": false,
				"can_purchase": true,
				"resources": {},
				"cost": {"diamante": 180},
				"effect": {"type": "construction_slots", "value": 2},
				"description": "Aumenta a fila de construcao do Refugio.",
			},
		],
		"daily_rewards": [
			{"id": "daily_collect_base", "label": "Coleta diaria", "xp": 60, "resources": {"almas": 90, "ossos": 60}, "period_key": "2026-05-28", "claimed": false},
		],
		"battle_pass": {
			"pass": {"id": "season_01", "display_name": "Season 01"},
			"progress": {"pass_xp": 340, "premium_unlocked": false},
			"rewards": [
				{"id": "bp_01", "label": "Marco I", "xp": 100, "resources": {"almas": 150}, "period_key": "season_01", "claimed": true},
				{"id": "bp_02", "label": "Marco II", "xp": 250, "resources": {"diamante": 30}, "period_key": "season_01", "claimed": false, "premium_required": true},
			],
		},
	}
