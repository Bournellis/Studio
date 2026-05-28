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

	func _prepare_touch_button(button: Button) -> void:
		button.custom_minimum_size.x = maxf(button.custom_minimum_size.x, 56)
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 56)
		button.add_theme_font_size_override("font_size", 17)

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

	func _add_action_button(text: String, action_id: String, confirm_message: String = "") -> Button:
		var button := Button.new()
		button.text = text
		button.tooltip_text = text
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
	await _capture_battle()
	await _capture_summary()
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
	if _hub_surface_presenter_script == null:
		_failures.append("Could not load hub surface presenter.")
	if _base_surface_presenter_script == null:
		_failures.append("Could not load base surface presenter.")
	if _shop_surface_presenter_script == null:
		_failures.append("Could not load shop surface presenter.")
	if _battle_replay_presenter_script == null:
		_failures.append("Could not load battle replay presenter.")
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
