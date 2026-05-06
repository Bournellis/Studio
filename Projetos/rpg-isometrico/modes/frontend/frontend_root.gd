class_name FrontendRoot
extends Control

const LoadoutValidator = preload("res://gameplay/loadouts/loadout_validator.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const RaceDefinitionResource = preload("res://gameplay/content/race_definition_resource.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")
const LoadoutUnlockResolver = preload("res://gameplay/profile/loadout_unlock_resolver.gd")
const PlayerProfile = preload("res://gameplay/profile/player_profile.gd")
const ProgressionResolver = preload("res://gameplay/profile/progression_resolver.gd")
const ModeAvailabilityResolver = preload("res://gameplay/profile/mode_availability_resolver.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const CampaignCatalogResource = preload("res://modes/campaign/campaign_catalog_resource.gd")
const CampaignRouteDefinitionResource = preload("res://modes/campaign/campaign_route_definition_resource.gd")

const DEV_UNLOCK_LABEL: String = "Liberar tudo (dev)"
const MENU_PAGE_PLAY: StringName = &"play"
const MENU_PAGE_LOADOUT: StringName = &"loadout"

var loadout_validator: LoadoutValidator = LoadoutValidator.new()
var selected_mode_id: StringName = LocalModeCatalog.CAMPAIGN_MODE_ID
var selected_campaign_difficulty_id: StringName = PlayerProfile.EASY_DIFFICULTY_ID
var player_profile: PlayerProfile = PlayerProfile.new()
var developer_unlock_all_enabled: bool = false
var current_menu_page: StringName = MENU_PAGE_PLAY
var campaign_catalog: CampaignCatalogResource
var campaign_routes: Array[CampaignRouteDefinitionResource] = []

@onready var background: ColorRect = $Background
@onready var glow: ColorRect = $Glow
@onready var page_margin: MarginContainer = $PageMargin
@onready var main_layout: HBoxContainer = $PageMargin/MainLayout
@onready var info_panel: PanelContainer = $PageMargin/MainLayout/InfoPanel
@onready var info_margin: MarginContainer = $PageMargin/MainLayout/InfoPanel/InfoMargin
@onready var info_column: VBoxContainer = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn
@onready var eyebrow_label: Label = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn/EyebrowLabel
@onready var title_label: Label = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn/TitleLabel
@onready var subtitle_label: Label = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn/SubtitleLabel
@onready var canon_label: Label = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn/CanonLabel
@onready var info_label: Label = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn/InfoLabel
@onready var save_state_label: Label = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn/SaveStateLabel
@onready var controls_label: Label = $PageMargin/MainLayout/InfoPanel/InfoMargin/InfoColumn/ControlsLabel
@onready var loadout_panel: PanelContainer = $PageMargin/MainLayout/LoadoutPanel
@onready var loadout_margin: MarginContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin
@onready var loadout_column: VBoxContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn
@onready var config_title_label: Label = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/ConfigTitleLabel
@onready var race_section: VBoxContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/RaceSection
@onready var weapon_section: VBoxContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/WeaponSection
@onready var race_option: OptionButton = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/RaceSection/RaceOption
@onready var weapon_option: OptionButton = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/WeaponSection/WeaponOption
@onready var skills_column: VBoxContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SelectionScroll/SelectionContent/SkillsSection/SkillsColumn
@onready var potions_column: VBoxContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SelectionScroll/SelectionContent/PotionsSection/PotionsColumn
@onready var skills_section_label: Label = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SelectionScroll/SelectionContent/SkillsSection/SkillsSectionLabel
@onready var potions_section_label: Label = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SelectionScroll/SelectionContent/PotionsSection/PotionsSectionLabel
@onready var summary_label: Label = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SummaryLabel
@onready var message_label: Label = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/MessageLabel
@onready var selection_scroll: ScrollContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SelectionScroll
@onready var selection_content: VBoxContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/SelectionScroll/SelectionContent
@onready var action_row: HBoxContainer = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/ActionRow
@onready var saved_button: Button = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/ActionRow/SavedButton
@onready var canonical_button: Button = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/ActionRow/CanonicalButton
@onready var start_button: Button = $PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/ActionRow/StartButton

var mode_section: VBoxContainer
var mode_section_label: Label
var mode_groups_column: VBoxContainer
var mode_summary_label: Label
var developer_toggle_button: CheckButton
var campaign_difficulty_section: VBoxContainer
var campaign_difficulty_label: Label
var campaign_difficulty_row: HBoxContainer
var campaign_difficulty_buttons: Dictionary = {}
var authored_mode_notice: Label
var configure_loadout_button: Button
var back_to_modes_button: Button
var suspended_run_card: PanelContainer
var suspended_run_card_eyebrow_label: Label
var suspended_run_card_title_label: Label
var suspended_run_card_body_label: Label
var suspended_run_card_hint_label: Label
var skill_toggles: Array[CheckBox] = []
var potion_toggles: Array[CheckBox] = []
var saved_selection: Dictionary = {}
var mode_buttons: Dictionary = {}
var mode_group_rows: Dictionary = {}
var suspended_run_prompt_backdrop: ColorRect
var suspended_run_prompt_panel: PanelContainer
var suspended_run_prompt_title_label: Label
var suspended_run_prompt_label: Label
var suspended_run_prompt_hint_label: Label
var suspended_continue_button: Button
var suspended_abandon_button: Button
var suspended_cancel_button: Button
var pending_prompt_mode_id: StringName = &""

func _ready() -> void:
	_configure_layout()
	_ensure_mode_controls()
	_load_campaign_routes()
	_ensure_campaign_difficulty_controls()
	_ensure_authored_mode_notice()
	_ensure_suspended_run_card()
	_ensure_navigation_controls()
	_ensure_suspended_run_prompt()
	_configure_theme()
	_connect_signals()
	_content_library().ensure_loaded()
	player_profile = _profile_store().load_profile()
	saved_selection = _settings_store().load_saved_selection()
	_restore_saved_mode_if_available()
	_ensure_selected_mode_is_supported()
	_populate_races()
	_refresh_state()

func _configure_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	page_margin.add_theme_constant_override("margin_left", 32)
	page_margin.add_theme_constant_override("margin_top", 28)
	page_margin.add_theme_constant_override("margin_right", 32)
	page_margin.add_theme_constant_override("margin_bottom", 28)

	main_layout.add_theme_constant_override("separation", 24)
	main_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL

	info_panel.custom_minimum_size = Vector2(320.0, 0.0)
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	loadout_panel.custom_minimum_size = Vector2(540.0, 0.0)
	loadout_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loadout_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	for margin: MarginContainer in [info_margin, loadout_margin]:
		margin.add_theme_constant_override("margin_left", 18)
		margin.add_theme_constant_override("margin_top", 18)
		margin.add_theme_constant_override("margin_right", 18)
		margin.add_theme_constant_override("margin_bottom", 18)

	info_column.add_theme_constant_override("separation", 12)
	info_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_column.size_flags_vertical = Control.SIZE_EXPAND_FILL

	loadout_column.add_theme_constant_override("separation", 14)
	loadout_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loadout_column.size_flags_vertical = Control.SIZE_EXPAND_FILL

	selection_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	selection_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	selection_scroll.follow_focus = true

	selection_content.add_theme_constant_override("separation", 14)
	selection_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	skills_column.add_theme_constant_override("separation", 6)
	potions_column.add_theme_constant_override("separation", 6)
	action_row.add_theme_constant_override("separation", 8)
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_label.custom_minimum_size = Vector2(0.0, 64.0)

func _ensure_mode_controls() -> void:
	if mode_section != null:
		return

	mode_section = VBoxContainer.new()
	mode_section.name = "ModeSection"
	mode_section.add_theme_constant_override("separation", 10)
	mode_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	mode_section_label = Label.new()
	mode_section_label.name = "ModeSectionLabel"
	mode_section.add_child(mode_section_label)

	mode_groups_column = VBoxContainer.new()
	mode_groups_column.name = "ModeGroupsColumn"
	mode_groups_column.add_theme_constant_override("separation", 12)
	mode_groups_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_section.add_child(mode_groups_column)

	for group_id_text: String in LocalModeCatalog.get_menu_group_ids():
		var group_id: StringName = StringName(group_id_text)
		var group_container: VBoxContainer = VBoxContainer.new()
		group_container.name = "%sGroup" % LocalModeCatalog.get_menu_group_display_name(group_id)
		group_container.add_theme_constant_override("separation", 6)
		mode_groups_column.add_child(group_container)

		var group_label: Label = Label.new()
		group_label.name = "%sLabel" % group_container.name
		group_label.text = LocalModeCatalog.get_menu_group_display_name(group_id)
		group_label.add_theme_font_size_override("font_size", 15)
		group_container.add_child(group_label)

		var group_row: HBoxContainer = HBoxContainer.new()
		group_row.name = "%sRow" % group_container.name
		group_row.add_theme_constant_override("separation", 8)
		group_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		group_container.add_child(group_row)
		mode_group_rows[String(group_id)] = group_row

		for mode_id_text: String in LocalModeCatalog.get_modes_for_menu_group(group_id):
			var mode_id: StringName = StringName(mode_id_text)
			var button: Button = Button.new()
			button.name = _build_mode_button_name(mode_id)
			button.text = LocalModeCatalog.get_display_name(mode_id)
			button.toggle_mode = true
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if mode_id == LocalModeCatalog.CAMPAIGN_MODE_ID:
				button.custom_minimum_size = Vector2(0.0, 58.0)
				button.add_theme_font_size_override("font_size", 18)
			else:
				button.custom_minimum_size = Vector2(0.0, 44.0)
			button.pressed.connect(_on_mode_button_pressed.bind(mode_id))
			group_row.add_child(button)
			mode_buttons[String(mode_id)] = button

	mode_summary_label = Label.new()
	mode_summary_label.name = "ModeSummaryLabel"
	mode_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mode_summary_label.modulate = Color(0.78, 0.82, 0.88, 1.0)
	mode_section.add_child(mode_summary_label)

	if OS.is_debug_build():
		developer_toggle_button = CheckButton.new()
		developer_toggle_button.name = "DeveloperUnlockToggle"
		developer_toggle_button.text = DEV_UNLOCK_LABEL
		developer_toggle_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mode_section.add_child(developer_toggle_button)

	loadout_column.add_child(mode_section)
	loadout_column.move_child(mode_section, 1)

func _load_campaign_routes() -> void:
	campaign_catalog = CampaignCatalogResource.load_generated()
	campaign_routes.clear()
	if campaign_catalog == null:
		return
	campaign_routes = campaign_catalog.get_routes_for_campaign(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID)

func _ensure_campaign_difficulty_controls() -> void:
	if campaign_difficulty_section != null:
		return

	campaign_difficulty_section = VBoxContainer.new()
	campaign_difficulty_section.name = "CampaignDifficultySection"
	campaign_difficulty_section.add_theme_constant_override("separation", 6)
	campaign_difficulty_section.visible = false
	loadout_column.add_child(campaign_difficulty_section)
	loadout_column.move_child(campaign_difficulty_section, 2)

	campaign_difficulty_label = Label.new()
	campaign_difficulty_label.name = "CampaignDifficultyLabel"
	campaign_difficulty_label.text = "Rota da campanha"
	campaign_difficulty_section.add_child(campaign_difficulty_label)

	campaign_difficulty_row = HBoxContainer.new()
	campaign_difficulty_row.name = "CampaignDifficultyRow"
	campaign_difficulty_row.add_theme_constant_override("separation", 8)
	campaign_difficulty_section.add_child(campaign_difficulty_row)

	for route: CampaignRouteDefinitionResource in campaign_routes:
		var difficulty_id: StringName = route.difficulty_id
		var button := Button.new()
		button.name = _build_campaign_difficulty_button_name(difficulty_id)
		button.text = _build_campaign_difficulty_short_label(difficulty_id)
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = route.difficulty_label
		button.pressed.connect(_on_campaign_difficulty_pressed.bind(difficulty_id))
		campaign_difficulty_row.add_child(button)
		campaign_difficulty_buttons[String(difficulty_id)] = button

func _ensure_authored_mode_notice() -> void:
	if authored_mode_notice != null:
		return

	authored_mode_notice = Label.new()
	authored_mode_notice.name = "AuthoredModeNotice"
	authored_mode_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	authored_mode_notice.modulate = Color(0.94, 0.83, 0.62, 1.0)
	authored_mode_notice.visible = false
	loadout_column.add_child(authored_mode_notice)
	loadout_column.move_child(authored_mode_notice, 2)

func _ensure_navigation_controls() -> void:
	if back_to_modes_button == null:
		back_to_modes_button = Button.new()
		back_to_modes_button.name = "BackToModesButton"
		back_to_modes_button.text = "Voltar aos modos"
		back_to_modes_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		action_row.add_child(back_to_modes_button)
		action_row.move_child(back_to_modes_button, 0)

	if configure_loadout_button == null:
		configure_loadout_button = Button.new()
		configure_loadout_button.name = "ConfigureLoadoutButton"
		configure_loadout_button.text = "Preparar kit"
		configure_loadout_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		action_row.add_child(configure_loadout_button)
		action_row.move_child(configure_loadout_button, maxi(0, action_row.get_child_count() - 2))

func _ensure_suspended_run_card() -> void:
	if suspended_run_card != null:
		return

	suspended_run_card = PanelContainer.new()
	suspended_run_card.name = "SuspendedRunCard"
	suspended_run_card.visible = false
	suspended_run_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_column.add_child(suspended_run_card)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	suspended_run_card.add_child(margin)

	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	suspended_run_card_eyebrow_label = Label.new()
	suspended_run_card_eyebrow_label.name = "SuspendedRunCardEyebrowLabel"
	column.add_child(suspended_run_card_eyebrow_label)

	suspended_run_card_title_label = Label.new()
	suspended_run_card_title_label.name = "SuspendedRunCardTitleLabel"
	suspended_run_card_title_label.add_theme_font_size_override("font_size", 22)
	column.add_child(suspended_run_card_title_label)

	suspended_run_card_body_label = Label.new()
	suspended_run_card_body_label.name = "SuspendedRunCardBodyLabel"
	suspended_run_card_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(suspended_run_card_body_label)

	suspended_run_card_hint_label = Label.new()
	suspended_run_card_hint_label.name = "SuspendedRunCardHintLabel"
	suspended_run_card_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(suspended_run_card_hint_label)

func _ensure_suspended_run_prompt() -> void:
	if suspended_run_prompt_panel != null:
		return

	suspended_run_prompt_backdrop = ColorRect.new()
	suspended_run_prompt_backdrop.name = "SuspendedRunPromptBackdrop"
	suspended_run_prompt_backdrop.visible = false
	suspended_run_prompt_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	suspended_run_prompt_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(suspended_run_prompt_backdrop)

	suspended_run_prompt_panel = PanelContainer.new()
	suspended_run_prompt_panel.name = "SuspendedRunPrompt"
	suspended_run_prompt_panel.visible = false
	suspended_run_prompt_panel.set_anchors_preset(Control.PRESET_CENTER)
	suspended_run_prompt_panel.custom_minimum_size = Vector2(420.0, 0.0)
	suspended_run_prompt_panel.offset_left = -210.0
	suspended_run_prompt_panel.offset_top = -112.0
	suspended_run_prompt_panel.offset_right = 210.0
	suspended_run_prompt_panel.offset_bottom = 112.0
	suspended_run_prompt_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(suspended_run_prompt_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	suspended_run_prompt_panel.add_child(margin)

	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	suspended_run_prompt_title_label = Label.new()
	suspended_run_prompt_title_label.name = "SuspendedRunPromptTitleLabel"
	suspended_run_prompt_title_label.text = "Run suspensa"
	suspended_run_prompt_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	suspended_run_prompt_title_label.add_theme_font_size_override("font_size", 24)
	column.add_child(suspended_run_prompt_title_label)

	suspended_run_prompt_label = Label.new()
	suspended_run_prompt_label.name = "SuspendedRunPromptLabel"
	suspended_run_prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	suspended_run_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(suspended_run_prompt_label)

	suspended_run_prompt_hint_label = Label.new()
	suspended_run_prompt_hint_label.name = "SuspendedRunPromptHintLabel"
	suspended_run_prompt_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	suspended_run_prompt_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(suspended_run_prompt_hint_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 10)
	column.add_child(button_row)

	suspended_continue_button = Button.new()
	suspended_continue_button.name = "SuspendedRunContinueButton"
	suspended_continue_button.text = "Continuar"
	suspended_continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(suspended_continue_button)

	suspended_abandon_button = Button.new()
	suspended_abandon_button.name = "SuspendedRunAbandonButton"
	suspended_abandon_button.text = "Abandonar"
	suspended_abandon_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(suspended_abandon_button)

	suspended_cancel_button = Button.new()
	suspended_cancel_button.name = "SuspendedRunCancelButton"
	suspended_cancel_button.text = "Cancelar"
	suspended_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(suspended_cancel_button)

func _build_panel_style(bg_color: Color, border_color: Color, corner_radius: int = 16) -> StyleBoxFlat:
	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = bg_color
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = border_color
	style_box.corner_radius_top_left = corner_radius
	style_box.corner_radius_top_right = corner_radius
	style_box.corner_radius_bottom_right = corner_radius
	style_box.corner_radius_bottom_left = corner_radius
	return style_box

func _configure_theme() -> void:
	background.color = Color(0.05, 0.08, 0.12, 1.0)
	glow.color = Color(0.62, 0.2, 0.12, 0.08)

	for panel: PanelContainer in [info_panel, loadout_panel]:
		panel.add_theme_stylebox_override(
			"panel",
			_build_panel_style(Color(0.09, 0.12, 0.16, 0.92), Color(0.77, 0.39, 0.2, 0.46))
		)

	eyebrow_label.text = "MENU LOCAL"
	eyebrow_label.modulate = Color(0.96, 0.76, 0.58, 1.0)

	title_label.text = "RPG Isometrico"
	title_label.add_theme_font_size_override("font_size", 36)

	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	canon_label.text = ""
	canon_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	canon_label.modulate = Color(0.74, 0.82, 0.9, 1.0)
	canon_label.visible = false

	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.modulate = Color(0.78, 0.78, 0.84, 1.0)

	save_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_state_label.modulate = Color(0.94, 0.83, 0.62, 1.0)

	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.modulate = Color(0.78, 0.78, 0.84, 1.0)

	config_title_label.text = "Preparar kit"
	config_title_label.add_theme_font_size_override("font_size", 24)
	mode_section_label.text = "Campanha principal e extras"
	if campaign_difficulty_label != null:
		campaign_difficulty_label.modulate = Color(0.82, 0.88, 0.94, 1.0)

	$PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/RaceSection/RaceSectionLabel.text = "Raca"
	$PageMargin/MainLayout/LoadoutPanel/LoadoutMargin/LoadoutColumn/WeaponSection/WeaponSectionLabel.text = "Arma"

	saved_button.text = "Restaurar salvo"
	canonical_button.text = "Montar kit"
	if configure_loadout_button != null:
		configure_loadout_button.text = "Preparar kit"
	if back_to_modes_button != null:
		back_to_modes_button.text = "Voltar aos modos"

	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if suspended_run_card != null:
		suspended_run_card.add_theme_stylebox_override(
			"panel",
			_build_panel_style(Color(0.12, 0.1, 0.09, 0.96), Color(0.96, 0.58, 0.24, 0.72), 18)
		)
	if suspended_run_card_eyebrow_label != null:
		suspended_run_card_eyebrow_label.modulate = Color(1.0, 0.78, 0.5, 1.0)
	if suspended_run_card_title_label != null:
		suspended_run_card_title_label.modulate = Color(0.99, 0.92, 0.84, 1.0)
	if suspended_run_card_body_label != null:
		suspended_run_card_body_label.modulate = Color(0.9, 0.92, 0.96, 1.0)
	if suspended_run_card_hint_label != null:
		suspended_run_card_hint_label.modulate = Color(0.98, 0.82, 0.64, 1.0)

	if suspended_run_prompt_backdrop != null:
		suspended_run_prompt_backdrop.color = Color(0.02, 0.03, 0.05, 0.66)
	if suspended_run_prompt_panel != null:
		suspended_run_prompt_panel.add_theme_stylebox_override(
			"panel",
			_build_panel_style(Color(0.08, 0.09, 0.11, 0.98), Color(0.96, 0.58, 0.24, 0.66), 20)
		)
	if suspended_run_prompt_title_label != null:
		suspended_run_prompt_title_label.modulate = Color(0.99, 0.9, 0.78, 1.0)
	if suspended_run_prompt_label != null:
		suspended_run_prompt_label.modulate = Color(0.92, 0.94, 0.98, 1.0)
	if suspended_run_prompt_hint_label != null:
		suspended_run_prompt_hint_label.modulate = Color(0.98, 0.82, 0.64, 1.0)
	if suspended_continue_button != null:
		suspended_continue_button.modulate = Color(0.84, 0.98, 0.86, 1.0)
	if suspended_abandon_button != null:
		suspended_abandon_button.modulate = Color(1.0, 0.82, 0.76, 1.0)
	if suspended_cancel_button != null:
		suspended_cancel_button.modulate = Color(0.9, 0.92, 0.96, 1.0)

func _connect_signals() -> void:
	if not race_option.item_selected.is_connected(_on_race_selected):
		race_option.item_selected.connect(_on_race_selected)
	if not weapon_option.item_selected.is_connected(_on_weapon_selected):
		weapon_option.item_selected.connect(_on_weapon_selected)
	if not saved_button.pressed.is_connected(_on_apply_saved_pressed):
		saved_button.pressed.connect(_on_apply_saved_pressed)
	if not canonical_button.pressed.is_connected(_on_apply_canonical_pressed):
		canonical_button.pressed.connect(_on_apply_canonical_pressed)
	if not start_button.pressed.is_connected(_on_start_pressed):
		start_button.pressed.connect(_on_start_pressed)
	if configure_loadout_button != null and not configure_loadout_button.pressed.is_connected(_on_configure_loadout_pressed):
		configure_loadout_button.pressed.connect(_on_configure_loadout_pressed)
	if back_to_modes_button != null and not back_to_modes_button.pressed.is_connected(_on_back_to_modes_pressed):
		back_to_modes_button.pressed.connect(_on_back_to_modes_pressed)
	if developer_toggle_button != null and not developer_toggle_button.toggled.is_connected(_on_developer_unlock_toggled):
		developer_toggle_button.toggled.connect(_on_developer_unlock_toggled)
	if suspended_continue_button != null and not suspended_continue_button.pressed.is_connected(_on_suspended_continue_pressed):
		suspended_continue_button.pressed.connect(_on_suspended_continue_pressed)
	if suspended_abandon_button != null and not suspended_abandon_button.pressed.is_connected(_on_suspended_abandon_pressed):
		suspended_abandon_button.pressed.connect(_on_suspended_abandon_pressed)
	if suspended_cancel_button != null and not suspended_cancel_button.pressed.is_connected(_on_suspended_cancel_pressed):
		suspended_cancel_button.pressed.connect(_on_suspended_cancel_pressed)

func _populate_races() -> void:
	race_option.clear()
	var races: Array[RaceDefinitionResource] = _content_library().get_races()
	for race: RaceDefinitionResource in races:
		var index: int = race_option.get_item_count()
		race_option.add_item(race.display_name)
		race_option.set_item_metadata(index, String(race.id))

	if race_option.get_item_count() == 0:
		save_state_label.text = "Nenhum conteudo foi encontrado. Rode a validacao para gerar os recursos."
		return

	race_option.select(0)
	_on_race_selected(race_option.get_selected())

func _on_race_selected(_index: int) -> void:
	_populate_weapons()
	_rebuild_skill_and_potion_lists()
	_refresh_state()

func _on_weapon_selected(_index: int) -> void:
	_rebuild_skill_and_potion_lists()
	_refresh_state()

func _populate_weapons() -> void:
	weapon_option.clear()
	var race_id: StringName = _get_selected_race_id()
	for weapon: WeaponDefinitionResource in _content_library().get_weapons_for_race(race_id):
		var index: int = weapon_option.get_item_count()
		weapon_option.add_item(weapon.display_name)
		weapon_option.set_item_metadata(index, String(weapon.id))

	if weapon_option.get_item_count() == 0:
		return

	weapon_option.select(0)

func _rebuild_skill_and_potion_lists() -> void:
	_clear_container(skills_column)
	_clear_container(potions_column)
	skill_toggles.clear()
	potion_toggles.clear()

	var race_id: StringName = _get_selected_race_id()
	var weapon_id: StringName = _get_selected_weapon_id()

	for skill: SkillDefinitionResource in _get_builder_skill_definitions(race_id, weapon_id):
		var toggle: CheckBox = CheckBox.new()
		var unlocked_for_builder: bool = _is_builder_skill_unlocked(skill.id)
		toggle.text = _build_builder_skill_toggle_text(skill, unlocked_for_builder)
		toggle.button_pressed = false
		toggle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		toggle.tooltip_text = "" if unlocked_for_builder else "Aprenda este recurso na Campanha do Troll para usar em modos livres."
		toggle.set_meta("entry_id", String(skill.id))
		toggle.set_meta("entry_label", skill.display_name)
		toggle.set_meta("progression_locked", not unlocked_for_builder)
		toggle.disabled = not unlocked_for_builder
		toggle.toggled.connect(_on_selection_toggled)
		skills_column.add_child(toggle)
		skill_toggles.append(toggle)

	for potion: PotionDefinitionResource in _get_builder_potion_definitions(race_id):
		var toggle: CheckBox = CheckBox.new()
		var unlocked_for_builder: bool = _is_builder_potion_unlocked(potion.id)
		toggle.text = _build_builder_potion_toggle_text(potion, unlocked_for_builder)
		toggle.button_pressed = false
		toggle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		toggle.tooltip_text = "" if unlocked_for_builder else "Aprenda este recurso na Campanha do Troll para usar em modos livres."
		toggle.set_meta("entry_id", String(potion.id))
		toggle.set_meta("entry_label", potion.display_name)
		toggle.set_meta("progression_locked", not unlocked_for_builder)
		toggle.disabled = not unlocked_for_builder
		toggle.toggled.connect(_on_selection_toggled)
		potions_column.add_child(toggle)
		potion_toggles.append(toggle)

	_update_selection_constraints()
	_update_saved_button_state()

func _clear_container(container: VBoxContainer) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _on_selection_toggled(_pressed: bool) -> void:
	_refresh_state()

func _on_mode_button_pressed(mode_id: StringName) -> void:
	selected_mode_id = LocalModeCatalog.normalize_mode_id(mode_id)
	current_menu_page = MENU_PAGE_PLAY
	_hide_suspended_run_prompt()
	_rebuild_skill_and_potion_lists()
	_refresh_state()

func _on_campaign_difficulty_pressed(difficulty_id: StringName) -> void:
	selected_campaign_difficulty_id = difficulty_id
	_hide_suspended_run_prompt()
	_refresh_state()

func _on_developer_unlock_toggled(enabled: bool) -> void:
	developer_unlock_all_enabled = enabled
	_rebuild_skill_and_potion_lists()
	_refresh_state()

func _on_configure_loadout_pressed() -> void:
	if _mode_uses_authored_loadout(selected_mode_id):
		return
	var mode_state: Dictionary = _get_surface_launch_state()
	if not bool(mode_state.get("unlocked", false)):
		message_label.text = str(mode_state.get("reason", "Modo local bloqueado."))
		message_label.modulate = Color(0.97, 0.72, 0.67, 1.0)
		return
	current_menu_page = MENU_PAGE_LOADOUT
	_hide_suspended_run_prompt()
	_refresh_state()

func _on_back_to_modes_pressed() -> void:
	current_menu_page = MENU_PAGE_PLAY
	_hide_suspended_run_prompt()
	_refresh_state()

func _is_loadout_page() -> bool:
	return current_menu_page == MENU_PAGE_LOADOUT and not _mode_uses_authored_loadout(selected_mode_id)

func _refresh_state() -> void:
	_ensure_selected_mode_is_supported()
	_ensure_selected_campaign_difficulty_is_supported()
	if _mode_uses_authored_loadout(selected_mode_id) or not bool(_get_surface_launch_state().get("unlocked", false)):
		current_menu_page = MENU_PAGE_PLAY

	_update_selection_constraints()

	var loadout: LoadoutData = _build_current_loadout()
	var mode_state: Dictionary = _get_surface_launch_state()
	var uses_authored_loadout: bool = _mode_uses_authored_loadout(selected_mode_id)
	var is_loadout_page: bool = _is_loadout_page()
	var result: Dictionary = {"ok": true, "message": ""} if uses_authored_loadout else _validate_builder_loadout(loadout)
	var saved_report: Dictionary = _build_saved_selection_report()
	var selected_skills: Array[String] = _get_selected_ids(skill_toggles)
	var selected_potions: Array[String] = _get_selected_ids(potion_toggles)
	var selected_skill_labels: Array[String] = _get_selected_labels(skill_toggles)
	var selected_potion_labels: Array[String] = _get_selected_labels(potion_toggles)
	_update_section_titles(selected_skills.size(), selected_potions.size())
	_update_saved_button_state(saved_report)
	if is_loadout_page:
		_update_save_state_label(loadout, bool(result.get("ok", false)), saved_report)
		summary_label.text = _build_summary_text(loadout, selected_skill_labels, selected_potion_labels)
	else:
		save_state_label.text = _build_play_save_state_text(mode_state, saved_report)
		summary_label.text = _build_play_summary_text(mode_state, saved_report)
	message_label.text = _build_status_message(result, mode_state) if is_loadout_page or uses_authored_loadout or _selected_mode_has_suspended_run() or not bool(mode_state.get("unlocked", false)) else _build_play_status_message(saved_report)

	var is_ready_to_launch: bool = bool(mode_state.get("unlocked", false)) and (
		_selected_mode_has_suspended_run()
		or uses_authored_loadout
		or (is_loadout_page and bool(result.get("ok", false)))
	)
	message_label.modulate = Color(0.73, 0.91, 0.69, 1.0) if is_ready_to_launch else Color(0.97, 0.72, 0.67, 1.0)
	start_button.disabled = not is_ready_to_launch
	canonical_button.disabled = uses_authored_loadout or (skill_toggles.is_empty() and potion_toggles.is_empty())
	if configure_loadout_button != null:
		configure_loadout_button.disabled = uses_authored_loadout or not bool(mode_state.get("unlocked", false))
	_refresh_mode_presentation()
	_refresh_mode_specific_surface()
	_refresh_suspended_run_surface()

func _refresh_mode_specific_surface() -> void:
	var uses_authored_loadout: bool = _mode_uses_authored_loadout(selected_mode_id)
	var is_loadout_page: bool = _is_loadout_page()
	var mode_state: Dictionary = _get_surface_launch_state()
	var is_unlocked: bool = bool(mode_state.get("unlocked", false))
	var has_suspended_run: bool = _selected_mode_has_suspended_run() and not _is_loadout_page()

	mode_section.visible = not is_loadout_page
	race_section.visible = is_loadout_page
	weapon_section.visible = is_loadout_page
	selection_scroll.visible = is_loadout_page
	saved_button.visible = is_loadout_page
	canonical_button.visible = is_loadout_page
	if back_to_modes_button != null:
		back_to_modes_button.visible = is_loadout_page
	if configure_loadout_button != null:
		configure_loadout_button.visible = not is_loadout_page and not uses_authored_loadout and is_unlocked
	authored_mode_notice.visible = not is_loadout_page and uses_authored_loadout
	campaign_difficulty_section.visible = not is_loadout_page and _is_campaign_mode_selected()
	summary_label.visible = is_loadout_page
	start_button.visible = uses_authored_loadout or is_loadout_page or has_suspended_run or not is_unlocked

	if is_loadout_page:
		config_title_label.text = "Kit para %s" % _build_selected_entry_label()
		authored_mode_notice.text = ""
	elif uses_authored_loadout:
		config_title_label.text = "Jogar"
		authored_mode_notice.text = _build_authored_mode_notice_text()
	else:
		config_title_label.text = "Jogar"
		authored_mode_notice.text = ""

func _refresh_suspended_run_surface() -> void:
	if suspended_run_card == null:
		return

	var has_suspended_run: bool = _selected_mode_has_suspended_run() and not _is_loadout_page()
	suspended_run_card.visible = has_suspended_run
	if not has_suspended_run:
		return

	suspended_run_card_eyebrow_label.text = _build_suspended_run_origin_badge_text(selected_mode_id)
	suspended_run_card_title_label.text = _build_suspended_run_display_title(selected_mode_id)
	suspended_run_card_body_label.text = _build_suspended_run_card_body_text(selected_mode_id)
	suspended_run_card_hint_label.text = _build_suspended_run_card_hint_text(selected_mode_id)

func _refresh_mode_presentation() -> void:
	info_label.text = ModeAvailabilityResolver.get_frontend_banner(player_profile, developer_unlock_all_enabled)
	subtitle_label.text = _build_loadout_page_subtitle_text() if _is_loadout_page() else _build_selected_mode_subtitle_text()
	controls_label.text = LocalModeCatalog.get_controls_hint(selected_mode_id)

	var mode_state: Dictionary = _get_surface_launch_state()
	var mode_summary: String = _build_selected_mode_summary_text()
	if not bool(mode_state.get("unlocked", false)):
		mode_summary += "\n\nBloqueado: %s" % str(mode_state.get("reason", ""))
	elif str(mode_state.get("tag", "")) != "":
		mode_summary += "\n\nStatus: %s" % str(mode_state.get("tag", ""))
	mode_summary_label.text = mode_summary

	start_button.text = _build_start_button_label(mode_state)

	for key: Variant in mode_buttons.keys():
		var button: Button = mode_buttons[key]
		var mode_id: StringName = StringName(str(key))
		var button_state: Dictionary = _get_mode_state(mode_id)
		var is_selected: bool = mode_id == selected_mode_id
		var is_unlocked: bool = bool(button_state.get("unlocked", false))
		button.set_pressed_no_signal(is_selected)
		button.text = _build_mode_card_text(mode_id, button_state)
		button.disabled = false
		button.tooltip_text = str(button_state.get("tag", ""))
		if not is_unlocked:
			button.tooltip_text = str(button_state.get("reason", ""))
			button.modulate = Color(0.58, 0.6, 0.64, 0.88) if not is_selected else Color(0.76, 0.66, 0.56, 0.92)
		else:
			button.modulate = Color(1.0, 0.92, 0.82, 1.0) if is_selected else Color(0.82, 0.86, 0.92, 0.92)

	_refresh_campaign_difficulty_buttons()

	if developer_toggle_button != null:
		developer_toggle_button.set_pressed_no_signal(developer_unlock_all_enabled)
		developer_toggle_button.text = "%s: ativo" % DEV_UNLOCK_LABEL if developer_unlock_all_enabled else DEV_UNLOCK_LABEL
		developer_toggle_button.tooltip_text = "Libera Campanha e extras locais para iteracao rapida. Duelo Privado permanece fora da navegacao publica."

func _build_mode_card_text(mode_id: StringName, mode_state: Dictionary) -> String:
	var tag: String = str(mode_state.get("tag", ""))
	if tag == "":
		return LocalModeCatalog.get_display_name(mode_id)
	return "%s\n%s" % [LocalModeCatalog.get_display_name(mode_id), tag]

func _refresh_campaign_difficulty_buttons() -> void:
	if campaign_difficulty_section == null:
		return
	campaign_difficulty_section.visible = _is_campaign_mode_selected() and not _is_loadout_page()
	for key: Variant in campaign_difficulty_buttons.keys():
		var difficulty_id: StringName = StringName(str(key))
		var button: Button = campaign_difficulty_buttons[key]
		var route_state: Dictionary = _get_campaign_route_state(difficulty_id)
		var is_selected: bool = difficulty_id == _get_selected_campaign_difficulty_id()
		var is_unlocked: bool = bool(route_state.get("unlocked", false))
		button.set_pressed_no_signal(is_selected)
		button.disabled = not is_unlocked
		button.tooltip_text = str(route_state.get("reason", "")) if not is_unlocked else str(route_state.get("tag", ""))
		if is_unlocked:
			button.modulate = Color(1.0, 0.9, 0.8, 1.0) if is_selected else Color(0.82, 0.86, 0.92, 0.92)
		else:
			button.modulate = Color(0.6, 0.62, 0.66, 0.88)

func _build_selected_mode_subtitle_text() -> String:
	if _is_selected_campaign_free():
		return "Replay livre da Campanha do Troll: prepare um kit completo ja aprendido e revisite a rota sem novas recompensas permanentes."
	if not _mode_uses_authored_loadout(selected_mode_id):
		return LocalModeCatalog.get_subtitle(selected_mode_id)
	if _get_selected_campaign_difficulty_id() == &"normal":
		return "A segunda rota da Campanha do Troll revisita a forja em um passe mais dificil, sem novas recompensas permanentes nesta fase."
	return LocalModeCatalog.get_subtitle(selected_mode_id)

func _build_loadout_page_subtitle_text() -> String:
	if _is_selected_campaign_free():
		return "Monte o kit livre da campanha: 1 raca, 1 arma, 4 habilidades e 2 pocoes ja aprendidas."
	return "Monte o kit livre deste extra: 1 raca, 1 arma, 4 habilidades e 2 pocoes ja aprendidas."

func _build_selected_mode_summary_text() -> String:
	if _is_campaign_mode_selected():
		return _build_campaign_mode_summary_text()
	return LocalModeCatalog.get_summary(selected_mode_id)

func _build_campaign_mode_summary_text() -> String:
	if _is_selected_campaign_free():
		return "Campanha Livre e replay/buildcraft pos-Classic: usa o kit preparado com recursos aprendidos e nao substitui a rota principal de unlocks."
	if _get_selected_campaign_difficulty_id() == &"normal":
		return "Segunda rota da Campanha do Troll. Classic - Normal mantem 5 etapas, fecha no chefe e usa o mesmo kit dos Imortais / Martelo."
	return LocalModeCatalog.get_summary(selected_mode_id)

func _build_campaign_save_state_text() -> String:
	if _selected_mode_has_suspended_run():
		return _build_suspended_run_save_state_text(selected_mode_id)
	if _is_selected_campaign_free():
		var route_state: Dictionary = _get_selected_campaign_route_state()
		if not bool(route_state.get("unlocked", false)):
			return str(route_state.get("reason", "Conclua Classic - Easy para liberar Campanha Livre."))
		return "Campanha Livre e replay de buildcraft: prepare um kit completo aprendido na campanha, sem novas recompensas permanentes."
	if _get_selected_campaign_difficulty_id() == &"normal":
		var route_state: Dictionary = _get_selected_campaign_route_state()
		if not bool(route_state.get("unlocked", false)):
			return str(route_state.get("reason", "Conclua a Campanha do Troll em Easy para liberar a rota Normal."))
		return "A Campanha classica em Normal usa uma segunda rota de 5 etapas. Survival, Boss e Arena Bot ficam como extras de resistencia, maestria e treino de kit."
	return "A Campanha classica e a jornada principal. Survival, Boss e Arena Bot ficam como extras de resistencia, maestria e treino de kit."

func _get_selected_campaign_display_name() -> String:
	var selected_route: CampaignRouteDefinitionResource = _get_selected_campaign_route()
	if selected_route != null and selected_route.campaign_display_name != "":
		return selected_route.campaign_display_name
	return LocalModeCatalog.get_display_name(LocalModeCatalog.CAMPAIGN_MODE_ID)

func _get_selected_campaign_difficulty_id() -> StringName:
	return selected_campaign_difficulty_id if selected_campaign_difficulty_id != &"" else PlayerProfile.EASY_DIFFICULTY_ID

func _is_campaign_mode_selected() -> bool:
	return LocalModeCatalog.normalize_mode_id(selected_mode_id) == LocalModeCatalog.CAMPAIGN_MODE_ID

func _is_selected_campaign_free() -> bool:
	return _is_campaign_mode_selected() and _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID

func _ensure_selected_campaign_difficulty_is_supported() -> void:
	if not _is_campaign_mode_selected():
		selected_campaign_difficulty_id = PlayerProfile.EASY_DIFFICULTY_ID
		return
	for route: CampaignRouteDefinitionResource in campaign_routes:
		if route != null and route.difficulty_id == selected_campaign_difficulty_id:
			return
	selected_campaign_difficulty_id = PlayerProfile.EASY_DIFFICULTY_ID

func _get_selected_campaign_route() -> CampaignRouteDefinitionResource:
	for route: CampaignRouteDefinitionResource in campaign_routes:
		if route != null and route.difficulty_id == _get_selected_campaign_difficulty_id():
			return route
	return null

func _get_campaign_route_state(difficulty_id: StringName) -> Dictionary:
	return ModeAvailabilityResolver.get_campaign_route_state(
		player_profile,
		ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
		difficulty_id,
		developer_unlock_all_enabled
	)

func _get_selected_campaign_route_state() -> Dictionary:
	return _get_campaign_route_state(_get_selected_campaign_difficulty_id())

func _get_surface_launch_state() -> Dictionary:
	if _is_campaign_mode_selected():
		return _get_selected_campaign_route_state()
	return _get_mode_state(selected_mode_id)

func _build_campaign_difficulty_button_name(difficulty_id: StringName) -> String:
	return "CampaignDifficulty%sButton" % _build_campaign_difficulty_short_label(difficulty_id)

func _build_campaign_difficulty_short_label(difficulty_id: StringName) -> String:
	if difficulty_id == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
		return "Livre"
	return String(difficulty_id).capitalize()

func _build_selected_entry_label() -> String:
	if _is_selected_campaign_free():
		return "Campanha Livre"
	return LocalModeCatalog.get_display_name(selected_mode_id)

func _current_label_or_placeholder(resource: Resource) -> String:
	if resource == null:
		return "-"
	if resource is RaceDefinitionResource:
		return resource.display_name
	if resource is WeaponDefinitionResource:
		return resource.display_name
	return resource.resource_name

func _build_summary_text(loadout: LoadoutData, skill_labels: Array[String], potion_labels: Array[String]) -> String:
	if _mode_uses_authored_loadout(selected_mode_id):
		return _build_campaign_summary_text()

	return "Modo: %s\nRaca: %s\nArma: %s\n%s\n%s" % [
		_build_selected_entry_label(),
		_current_label_or_placeholder(loadout.race),
		_current_label_or_placeholder(loadout.weapon),
		_format_selection_summary("Habilidades", skill_labels, 4, "nenhuma selecionada"),
		_format_selection_summary("Pocoes", potion_labels, 2, "nenhuma selecionada")
	]

func _build_campaign_summary_text() -> String:
	var survival_state: Dictionary = _get_mode_state(LocalModeCatalog.SURVIVAL_MODE_ID)
	var boss_state: Dictionary = _get_mode_state(LocalModeCatalog.BOSS_MODE_ID)
	var stage_entry: String = _build_campaign_stage_entry_text()
	if _get_selected_campaign_difficulty_id() == &"normal":
		var selected_route: CampaignRouteDefinitionResource = _get_selected_campaign_route()
		return "Modo: %s\nRota: %s\nEstrutura: Classico - sequencial\nEntrada atual: %s\nSurvival: %s\nBoss: %s" % [
			_get_selected_campaign_display_name(),
			"Classic - Normal" if selected_route == null else selected_route.difficulty_label,
			stage_entry,
			"liberado" if bool(survival_state.get("unlocked", false)) else "bloqueado",
			"liberado" if bool(boss_state.get("unlocked", false)) else "bloqueado"
		]
	return "Modo: %s\nEstrutura: Classico - sequencial\nEntrada atual: %s\nSurvival: %s\nBoss: %s" % [
		_get_selected_campaign_display_name(),
		stage_entry,
		"liberado" if bool(survival_state.get("unlocked", false)) else "bloqueado",
		"liberado" if bool(boss_state.get("unlocked", false)) else "bloqueado"
	]

func _build_authored_mode_notice_text() -> String:
	if developer_unlock_all_enabled:
		return "Override de desenvolvimento ativo. A Campanha do Troll continua authored, mas os gates do produto ficam abertos para teste rapido."
	if _selected_mode_has_suspended_run():
		return _build_campaign_authored_notice_text()
	if _get_selected_campaign_difficulty_id() == &"normal":
		var route_state: Dictionary = _get_selected_campaign_route_state()
		if not bool(route_state.get("unlocked", false)):
			return str(route_state.get("reason", "Conclua a Campanha do Troll em Easy para liberar a rota Normal."))
		return "Campanha do Troll em Normal usa uma segunda rota sem novas recompensas permanentes. Os modos extras ficam para treino, maestria e replay."
	return "A Campanha do Troll e a jornada principal: progressao e kit guiados antes dos modos extras."

func _build_play_save_state_text(mode_state: Dictionary, saved_report: Dictionary) -> String:
	if _selected_mode_has_suspended_run():
		return _build_suspended_run_save_state_text(selected_mode_id)
	if _mode_uses_authored_loadout(selected_mode_id):
		return _build_campaign_save_state_text()
	if not bool(mode_state.get("unlocked", false)):
		return str(mode_state.get("reason", "Modo local bloqueado."))
	if bool(saved_report.get("compatible", false)) and StringName(str(saved_report.get("mode_id", ""))) == selected_mode_id:
		return "Existe um kit salvo para este modo. Use Preparar kit para revisar ou entrar com a ultima combinacao."
	if _is_selected_campaign_free():
		return "Campanha Livre selecionada. Use Preparar kit para escolher 4 habilidades e 2 pocoes ja aprendidas antes de entrar."
	return "Modo livre selecionado. Use Preparar kit para escolher 4 habilidades e 2 pocoes antes de entrar."

func _build_play_summary_text(mode_state: Dictionary, saved_report: Dictionary) -> String:
	var lines: Array[String] = [
		"Modo: %s" % _build_selected_entry_label()
	]
	if _mode_uses_authored_loadout(selected_mode_id):
		lines.append("Entrada: %s" % _build_campaign_stage_entry_text())
		if _get_selected_campaign_difficulty_id() == &"normal":
			var selected_route: CampaignRouteDefinitionResource = _get_selected_campaign_route()
			lines.append("Rota: %s" % ("Classic - Normal" if selected_route == null else selected_route.difficulty_label))
	else:
		lines.append("Kit: preparado na proxima pagina")
		if bool(saved_report.get("compatible", false)) and StringName(str(saved_report.get("mode_id", ""))) == selected_mode_id:
			lines.append("Salvo local: disponivel")
	if not bool(mode_state.get("unlocked", false)):
		lines.append("Status: bloqueado")
	elif str(mode_state.get("tag", "")) != "":
		lines.append("Status: %s" % str(mode_state.get("tag", "")))
	return "\n".join(lines)

func _build_play_status_message(saved_report: Dictionary) -> String:
	if bool(saved_report.get("compatible", false)) and StringName(str(saved_report.get("mode_id", ""))) == selected_mode_id:
		return "Use Preparar kit para revisar o salvo ou entrar na Campanha Livre." if _is_selected_campaign_free() else "Use Preparar kit para revisar o salvo ou entrar no modo livre."
	return "Use Preparar kit para montar a combinacao da Campanha Livre." if _is_selected_campaign_free() else "Use Preparar kit para montar a combinacao deste modo livre."

func _format_selection_summary(label: String, selected_labels: Array[String], required_count: int, empty_text: String) -> String:
	var selected_text: String = empty_text if selected_labels.is_empty() else ", ".join(selected_labels)
	return "%s (%d/%d): %s" % [label, selected_labels.size(), required_count, selected_text]

func _build_status_message(result: Dictionary, mode_state: Dictionary) -> String:
	if not bool(mode_state.get("unlocked", false)):
		return str(mode_state.get("reason", ""))
	if _selected_mode_has_suspended_run():
		return _build_suspended_run_status_text(selected_mode_id)
	if _mode_uses_authored_loadout(selected_mode_id):
		if _get_selected_campaign_difficulty_id() == &"normal":
			return "Campanha pronta para seguir a rota Classic - Normal."
		return "Campanha pronta para seguir a rota Classic."
	var builder_unlock_report: Dictionary = _build_builder_unlock_report()
	if bool(builder_unlock_report.get("uses_profile_unlocks", false)) and not bool(builder_unlock_report.get("has_required_pool", true)):
		return _build_builder_unlock_shortage_message(builder_unlock_report)
	if bool(result.get("ok", false)):
		return "Kit pronto para %s." % _build_selected_entry_label()
	return str(result.get("message", ""))

func _update_save_state_label(loadout: LoadoutData, is_valid_loadout: bool, saved_report: Dictionary = {}) -> void:
	if _selected_mode_has_suspended_run():
		save_state_label.text = _build_suspended_run_save_state_text(selected_mode_id)
		return

	if _mode_uses_authored_loadout(selected_mode_id):
		save_state_label.text = _build_campaign_save_state_text()
		return

	if saved_report.is_empty():
		saved_report = _build_saved_selection_report()
	if not bool(saved_report.get("compatible", false)) and bool(saved_report.get("has_saved", false)):
		save_state_label.text = str(saved_report.get("issue_message", "O kit salvo nao combina com o pacote atual."))
		return
	var builder_unlock_report: Dictionary = _build_builder_unlock_report()
	if bool(builder_unlock_report.get("uses_profile_unlocks", false)) and not bool(builder_unlock_report.get("has_required_pool", true)):
		save_state_label.text = _build_builder_unlock_save_state_text(builder_unlock_report)
		return
	if not bool(saved_report.get("has_saved", false)):
		save_state_label.text = "Nenhum kit livre salvo ainda. A selecao atual sera gravada quando voce entrar em um modo livre."
		return

	var saved_mode_suffix: String = _build_saved_mode_suffix(saved_report)
	if not is_valid_loadout:
		save_state_label.text = "Existe um kit salvo%s. A selecao atual ainda nao esta completa; use Restaurar salvo para recuperar a ultima combinacao pronta." % saved_mode_suffix
		return

	if _loadout_matches_saved_selection(loadout):
		save_state_label.text = "A selecao atual corresponde ao kit salvo localmente%s." % saved_mode_suffix
		return

	save_state_label.text = "Existe um kit salvo%s, mas a selecao atual esta diferente. Use Restaurar salvo para voltar para a ultima combinacao." % saved_mode_suffix

func _loadout_matches_saved_selection(loadout: LoadoutData) -> bool:
	if loadout == null or not loadout.is_valid() or saved_selection.is_empty():
		return false

	if str(saved_selection.get("race_id", "")) != String(loadout.race.id):
		return false
	if str(saved_selection.get("weapon_id", "")) != String(loadout.weapon.id):
		return false
	if _extract_string_array(saved_selection.get("skill_ids", [])) != Array(loadout.get_skill_ids()):
		return false
	if _extract_string_array(saved_selection.get("potion_ids", [])) != Array(loadout.get_potion_ids()):
		return false

	return true

func _content_library() -> Node:
	return get_node("/root/ContentLibrary")

func _settings_store() -> Node:
	return get_node("/root/SettingsStore")

func _profile_store() -> Node:
	return get_node("/root/ProfileStore")

func _launch_context() -> Node:
	return get_node("/root/LaunchContext")

func _build_current_loadout() -> LoadoutData:
	if _mode_uses_authored_loadout(selected_mode_id):
		return _build_authored_loadout_for_mode(selected_mode_id)

	return _content_library().build_loadout_from_ids(
		_get_selected_race_id(),
		_get_selected_weapon_id(),
		PackedStringArray(_get_selected_ids(skill_toggles)),
		PackedStringArray(_get_selected_ids(potion_toggles))
	)

func _build_launch_loadout(resume_suspended_run: bool) -> LoadoutData:
	if resume_suspended_run:
		var suspended_loadout: LoadoutData = _build_loadout_from_suspended_run(selected_mode_id)
		if suspended_loadout != null and suspended_loadout.is_valid():
			return suspended_loadout
	return _build_current_loadout()

func _build_loadout_from_suspended_run(mode_id: StringName) -> LoadoutData:
	var run_key: StringName = _get_suspended_run_key(mode_id)
	if run_key == &"":
		return null
	var payload: Dictionary = _get_suspended_run_payload(mode_id)
	return _build_loadout_from_payload(Dictionary(payload.get("loadout", {})))

func _build_loadout_from_payload(payload: Dictionary) -> LoadoutData:
	if payload.is_empty():
		return null
	return _content_library().build_loadout_from_ids(
		StringName(str(payload.get("race_id", ""))),
		StringName(str(payload.get("weapon_id", ""))),
		PackedStringArray(_extract_string_array(payload.get("skill_ids", []))),
		PackedStringArray(_extract_string_array(payload.get("potion_ids", [])))
	)
 
func _build_suspended_run_status_text(mode_id: StringName) -> String:
	var origin_hint: String = _build_suspended_run_origin_hint(mode_id)
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
				return "Existe uma run suspensa da Campanha Livre%s. Ao entrar, voce escolhe entre Continuar ou Abandonar." % origin_hint
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Existe uma run suspensa da Campanha do Troll em Normal%s. Ao entrar, voce escolhe entre Continuar ou Abandonar." % origin_hint
			return "Existe uma run suspensa desta campanha%s. Ao entrar, voce escolhe entre Continuar ou Abandonar." % origin_hint
		_:
			return "Existe uma run suspensa de %s%s. Ao entrar, voce escolhe entre Continuar ou Abandonar." % [
				LocalModeCatalog.get_display_name(mode_id),
				origin_hint
			]

func _build_suspended_run_save_state_text(mode_id: StringName) -> String:
	var origin_detail: String = _build_suspended_run_origin_detail(mode_id)
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
				return "Existe uma run suspensa da Campanha Livre%s. Use Entrar para decidir entre continuar o replay atual ou abandonar e recomecar do Mapa 1." % origin_detail
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Existe uma run suspensa da Campanha do Troll em Normal%s. Use Entrar para decidir entre continuar a rota atual ou abandonar e recomecar do Mapa 1." % origin_detail
			return "Existe uma run suspensa da Campanha do Troll%s. Use Entrar para decidir entre continuar a rota atual ou abandonar e recomecar da Missao 1." % origin_detail
		_:
			return "Existe uma run suspensa de %s%s. Use Entrar para decidir entre continuar a sessao atual ou abandonar e voltar ao estado inicial do modo." % [
				LocalModeCatalog.get_display_name(mode_id),
				origin_detail
			]

func _build_suspended_run_prompt_text(mode_id: StringName) -> String:
	var origin_detail: String = _build_suspended_run_origin_detail(mode_id)
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
				return "Existe uma run suspensa da Campanha Livre%s. Voce quer continuar o replay atual ou abandonar e recomecar do Mapa 1?" % origin_detail
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Existe uma run suspensa da Campanha do Troll em Normal%s. Voce quer continuar da rota atual ou abandonar e recomecar do Mapa 1?" % origin_detail
			return "Existe uma run suspensa da Campanha do Troll%s. Voce quer continuar da rota atual ou abandonar e recomecar da Missao 1?" % origin_detail
		_:
			return "Existe uma run suspensa de %s%s. Voce quer continuar da sessao atual ou abandonar e voltar ao estado inicial do modo?" % [
				LocalModeCatalog.get_display_name(mode_id),
				origin_detail
			]

func _build_suspended_run_display_title(mode_id: StringName) -> String:
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
				return "Campanha Livre em pausa"
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Campanha do Troll em pausa (Normal)"
			return "Campanha do Troll em pausa"
		_:
			return "%s em pausa" % LocalModeCatalog.get_display_name(mode_id)

func _build_suspended_run_origin_badge_text(mode_id: StringName) -> String:
	match _get_suspended_run_origin(mode_id):
		"quit":
			return "SALVO AO FECHAR O JOGO"
		"menu":
			return "SALVO AO VOLTAR AO MENU"
		_:
			return "RUN SUSPENSA"

func _build_suspended_run_card_body_text(mode_id: StringName) -> String:
	var payload: Dictionary = _get_suspended_run_payload(mode_id)
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			return _build_campaign_suspended_run_body_text(payload)
		LocalModeCatalog.SURVIVAL_MODE_ID:
			return _build_survival_suspended_run_body_text(payload)
		LocalModeCatalog.BOSS_MODE_ID:
			return _build_boss_suspended_run_body_text(payload)
		_:
			return _build_suspended_run_prompt_text(mode_id)

func _build_campaign_suspended_run_body_text(payload: Dictionary) -> String:
	var stage_label: String = _build_campaign_stage_label_from_payload(payload)
	var current_level: int = maxi(1, int(payload.get("current_level", 1)))
	var pending_level_increase: int = maxi(0, int(payload.get("pending_level_increase", 0)))
	var pending_skill_points: int = maxi(0, int(payload.get("pending_skill_points", 0)))
	var reward_stage_number: int = maxi(0, int(payload.get("reward_stage_number", 0)))
	var lines: Array[String] = ["Entrada preparada: %s." % stage_label]
	if reward_stage_number > 0:
		lines.append("Recompensa do mapa %d ainda esta pendente antes do proximo combate." % reward_stage_number)
	if pending_level_increase > 0 or pending_skill_points > 0:
		lines.append("Level up pendente para o nivel %d com %d ponto%s para distribuir." % [
			current_level + pending_level_increase,
			pending_skill_points,
			"" if pending_skill_points == 1 else "s"
		])
	else:
		lines.append("Nivel atual da campanha: %d." % current_level)
	var player_health_text: String = _build_player_health_text_from_payload(payload)
	if player_health_text != "":
		lines.append("Vida salva: %s." % player_health_text)
	return "\n".join(lines)

func _build_survival_suspended_run_body_text(payload: Dictionary) -> String:
	var wave_payload: Dictionary = Dictionary(payload.get("wave_manager", {}))
	var current_wave: int = maxi(1, int(wave_payload.get("current_wave", payload.get("start_wave", 1))))
	var completed_waves: int = maxi(0, int(wave_payload.get("completed_waves", maxi(0, current_wave - 1))))
	var target_wave: int = maxi(0, int(wave_payload.get("target_wave", 0)))
	var lines: Array[String] = ["Retomada preparada a partir da onda %d." % current_wave]
	if target_wave > 0:
		lines.append("Progresso salvo: %d/%d ondas concluidas." % [completed_waves, target_wave])
	var player_health_text: String = _build_player_health_text_from_payload(payload)
	if player_health_text != "":
		lines.append("Vida salva: %s." % player_health_text)
	return "\n".join(lines)

func _build_boss_suspended_run_body_text(payload: Dictionary) -> String:
	var boss_payload: Dictionary = Dictionary(payload.get("boss", {}))
	var lines: Array[String] = ["Arena pronta para retomar o confronto com %s." % _build_boss_resume_name(payload)]
	var health_ratio: float = clampf(float(boss_payload.get("health_ratio", -1.0)), -1.0, 1.0)
	if health_ratio >= 0.0:
		lines.append("Vida restante do boss: %d%%." % int(round(health_ratio * 100.0)))
	var player_health_text: String = _build_player_health_text_from_payload(payload)
	if player_health_text != "":
		lines.append("Vida salva: %s." % player_health_text)
	return "\n".join(lines)

func _build_campaign_stage_label_from_payload(payload: Dictionary) -> String:
	var current_stage_index: int = clampi(int(payload.get("current_stage_index", 0)), 0, 4)
	var difficulty_id: StringName = StringName(str(payload.get("difficulty_id", String(_get_selected_campaign_difficulty_id()))))
	if current_stage_index <= 0 and difficulty_id == PlayerProfile.EASY_DIFFICULTY_ID:
		return "Missao 1 / Tutorial"
	return "Mapa %d" % (current_stage_index + 1)

func _build_boss_resume_name(payload: Dictionary) -> String:
	match str(payload.get("boss_id", "")):
		"boss_troll":
			return "Boss Troll"
		_:
			return "o boss atual"

func _build_player_health_text_from_payload(payload: Dictionary) -> String:
	var player_payload: Dictionary = Dictionary(payload.get("player", {}))
	var combat_payload: Dictionary = Dictionary(player_payload.get("combat", {}))
	var max_health: float = float(combat_payload.get("max_health", 0.0))
	if max_health <= 0.0:
		return ""
	var health: float = clampf(float(combat_payload.get("health", 0.0)), 0.0, max_health)
	return "%d%%" % int(round((health / max_health) * 100.0))

func _build_suspended_run_card_hint_text(mode_id: StringName) -> String:
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
				return "Entrar abre a decisao entre Continuar o replay livre ou Abandonar e recomecar do Mapa 1."
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Entrar abre a decisao entre Continuar a rota atual ou Abandonar e recomecar do Mapa 1."
			return "Entrar abre a decisao entre Continuar a rota atual ou Abandonar e recomecar da Missao 1."
		_:
			return "Entrar abre a decisao entre Continuar a sessao atual ou Abandonar e limpar a run suspensa deste modo."

func _build_suspended_run_prompt_hint_text(mode_id: StringName) -> String:
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
				return "Continuar retoma a Campanha Livre com o mesmo kit salvo. Abandonar remove a run suspensa e volta o replay para o Mapa 1."
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Continuar retoma a rota Classic no mesmo estado salvo. Abandonar remove a run suspensa e volta a campanha para o Mapa 1."
			return "Continuar retoma a rota Classic no mesmo estado salvo. Abandonar remove a run suspensa e volta a campanha para a Missao 1."
		_:
			return "Continuar retoma o mesmo estado salvo. Abandonar remove a run suspensa e volta o modo para o estado inicial."

func _build_campaign_stage_entry_text() -> String:
	if not _selected_mode_has_suspended_run():
		if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
			return "Mapa 1"
		if _get_selected_campaign_difficulty_id() == &"normal":
			return "Mapa 1"
		return "Missao 1 / Tutorial"
	match _get_suspended_run_origin(selected_mode_id):
		"quit":
			return "Run suspensa apos fechar o jogo"
		"menu":
			return "Run suspensa ao voltar ao menu"
		_:
			return "Run suspensa"

func _build_campaign_authored_notice_text() -> String:
	match _get_suspended_run_origin(selected_mode_id):
		"quit":
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Existe uma run suspensa da Campanha do Troll em Normal, salva quando o jogo foi fechado. Ao entrar, o menu vai oferecer continuar ou abandonar antes de iniciar uma nova rota."
			return "Existe uma run suspensa da Campanha do Troll, salva quando o jogo foi fechado. Ao entrar, o menu vai oferecer continuar ou abandonar antes de iniciar uma nova rota."
		"menu":
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Existe uma run suspensa da Campanha do Troll em Normal, salva ao voltar para o menu. Ao entrar, o menu vai oferecer continuar ou abandonar antes de iniciar uma nova rota."
			return "Existe uma run suspensa da Campanha do Troll, salva ao voltar para o menu. Ao entrar, o menu vai oferecer continuar ou abandonar antes de iniciar uma nova rota."
		_:
			if _get_selected_campaign_difficulty_id() == &"normal":
				return "Existe uma run suspensa da Campanha do Troll em Normal. Ao entrar, o menu vai oferecer continuar ou abandonar antes de iniciar uma nova rota."
			return "Existe uma run suspensa da Campanha do Troll. Ao entrar, o menu vai oferecer continuar ou abandonar antes de iniciar uma nova rota."

func _build_suspended_run_origin_hint(mode_id: StringName) -> String:
	match _get_suspended_run_origin(mode_id):
		"quit":
			return ", salva quando o jogo foi fechado"
		"menu":
			return ", salva ao voltar para o menu"
		_:
			return ""

func _build_suspended_run_origin_detail(mode_id: StringName) -> String:
	match _get_suspended_run_origin(mode_id):
		"quit":
			return ", salva quando o jogo foi fechado"
		"menu":
			return ", salva ao voltar para o menu"
		_:
			return ""

func _get_suspended_run_payload(mode_id: StringName) -> Dictionary:
	if LocalModeCatalog.normalize_mode_id(mode_id) == LocalModeCatalog.CAMPAIGN_MODE_ID:
		return _profile_store().get_campaign_suspended_run(
			ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
			_get_selected_campaign_difficulty_id()
		)
	var run_key: StringName = _get_suspended_run_key(mode_id)
	if run_key == &"":
		return {}
	return _profile_store().get_suspended_run(run_key)

func _get_suspended_run_origin(mode_id: StringName) -> String:
	return str(_get_suspended_run_payload(mode_id).get("suspend_origin", ""))

func _build_authored_loadout_for_mode(mode_id: StringName) -> LoadoutData:
	var loadout := LoadoutData.new()
	if mode_id != LocalModeCatalog.CAMPAIGN_MODE_ID:
		return loadout

	var races: Array[RaceDefinitionResource] = _content_library().get_races()
	if races.is_empty():
		return loadout

	var race: RaceDefinitionResource = races[0]
	var weapons: Array[WeaponDefinitionResource] = _content_library().get_weapons_for_race(race.id)
	if weapons.is_empty():
		return loadout

	var weapon: WeaponDefinitionResource = weapons[0]
	var skill_ids: PackedStringArray = PackedStringArray()
	for skill_id: String in ProgressionResolver.get_classic_campaign_skill_order():
		skill_ids.append(skill_id)

	var potion_ids: PackedStringArray = PackedStringArray()
	for potion_id: String in ProgressionResolver.get_classic_campaign_potion_order():
		potion_ids.append(potion_id)

	return _content_library().build_loadout_from_ids(race.id, weapon.id, skill_ids, potion_ids)

func _is_builder_skill_unlocked(skill_id: StringName) -> bool:
	if _mode_uses_authored_loadout(selected_mode_id):
		return true
	return LoadoutUnlockResolver.is_skill_unlocked_for_builder(
		player_profile,
		skill_id,
		developer_unlock_all_enabled
	)

func _is_builder_potion_unlocked(potion_id: StringName) -> bool:
	if _mode_uses_authored_loadout(selected_mode_id):
		return true
	return LoadoutUnlockResolver.is_potion_unlocked_for_builder(
		player_profile,
		potion_id,
		developer_unlock_all_enabled
	)

func _build_builder_skill_toggle_text(skill: SkillDefinitionResource, unlocked_for_builder: bool) -> String:
	if unlocked_for_builder:
		return "%s - %s" % [skill.display_name, skill.description]
	return "%s - %s\nBloqueada: aprenda na Campanha do Troll para usar em modos livres." % [skill.display_name, skill.description]

func _build_builder_potion_toggle_text(potion: PotionDefinitionResource, unlocked_for_builder: bool) -> String:
	if unlocked_for_builder:
		return "%s - %s" % [potion.display_name, potion.description]
	return "%s - %s\nBloqueada: aprenda na Campanha do Troll para usar em modos livres." % [potion.display_name, potion.description]

func _get_builder_skill_definitions(race_id: StringName, weapon_id: StringName) -> Array[SkillDefinitionResource]:
	var ordered_skills: Array[SkillDefinitionResource] = []
	for skill_id_text: String in ProgressionResolver.get_classic_campaign_skill_order():
		var skill_id: StringName = StringName(skill_id_text)
		var skill: SkillDefinitionResource = _content_library().get_skill(skill_id)
		if skill == null:
			continue
		if skill.race_id != race_id:
			continue
		if skill.weapon_id != &"" and skill.weapon_id != weapon_id:
			continue
		ordered_skills.append(skill)
	return ordered_skills

func _get_builder_potion_definitions(race_id: StringName) -> Array[PotionDefinitionResource]:
	var ordered_potions: Array[PotionDefinitionResource] = []
	for potion_id_text: String in ProgressionResolver.get_classic_campaign_potion_order():
		var potion_id: StringName = StringName(potion_id_text)
		var potion: PotionDefinitionResource = _content_library().get_potion(potion_id)
		if potion == null:
			continue
		if potion.race_id != &"" and potion.race_id != race_id:
			continue
		ordered_potions.append(potion)
	return ordered_potions

func _build_builder_unlock_report() -> Dictionary:
	if _mode_uses_authored_loadout(selected_mode_id):
		return {
			"uses_profile_unlocks": false,
			"has_required_pool": true
		}
	var race_id: StringName = _get_selected_race_id()
	var weapon_id: StringName = _get_selected_weapon_id()
	return LoadoutUnlockResolver.build_builder_unlock_report(
		player_profile,
		_get_builder_skill_definitions(race_id, weapon_id),
		_get_builder_potion_definitions(race_id),
		developer_unlock_all_enabled
	)

func _build_builder_unlock_gap_summary(report: Dictionary) -> String:
	var parts: Array[String] = []
	var missing_skill_count: int = int(report.get("missing_skill_count", 0))
	var missing_potion_count: int = int(report.get("missing_potion_count", 0))
	if missing_skill_count > 0:
		parts.append("faltam %d %s aprendida%s" % [
			missing_skill_count,
			"habilidade" if missing_skill_count == 1 else "habilidades",
			"" if missing_skill_count == 1 else "s"
		])
	if missing_potion_count > 0:
		parts.append("faltam %d %s aprendida%s" % [
			missing_potion_count,
			"pocao" if missing_potion_count == 1 else "pocoes",
			"" if missing_potion_count == 1 else "s"
		])
	if parts.is_empty():
		return "kit livre 4/2 completo"
	return "%s para fechar o kit livre 4/2" % " e ".join(parts)

func _build_builder_unlock_shortage_message(report: Dictionary) -> String:
	return "Este modo livre ja esta visivel, mas o perfil ainda nao aprendeu recursos suficientes para um kit completo. %s. Continue na Campanha do Troll para aprender o restante do kit%s" % [
		_build_builder_unlock_gap_summary(report),
		" ou use Liberar tudo (dev)." if OS.is_debug_build() else "."
	]

func _build_builder_unlock_save_state_text(report: Dictionary) -> String:
	return "Modos livres usam apenas recursos de kit aprendidos na conta. Este perfil tem %d/4 habilidades e %d/2 pocoes disponiveis para este kit. %s." % [
		int(report.get("available_skill_count", 0)),
		int(report.get("available_potion_count", 0)),
		_build_builder_unlock_gap_summary(report)
	]

func _validate_builder_loadout(loadout: LoadoutData) -> Dictionary:
	var structural_validation: Dictionary = loadout_validator.validate(loadout)
	if not bool(structural_validation.get("ok", false)):
		return structural_validation
	return LoadoutUnlockResolver.validate_loadout_access(
		player_profile,
		loadout,
		developer_unlock_all_enabled
	)

func _update_selection_constraints() -> void:
	_apply_selection_limit(skill_toggles, 4)
	_apply_selection_limit(potion_toggles, 2)

func _apply_selection_limit(toggles: Array[CheckBox], max_selected: int) -> void:
	var selected_count: int = _count_selected(toggles)
	for toggle: CheckBox in toggles:
		if bool(toggle.get_meta("progression_locked", false)):
			toggle.disabled = true
			continue
		toggle.disabled = selected_count >= max_selected and not toggle.button_pressed

func _count_selected(toggles: Array[CheckBox]) -> int:
	var total: int = 0
	for toggle: CheckBox in toggles:
		if toggle.button_pressed:
			total += 1
	return total

func _update_section_titles(skill_count: int, potion_count: int) -> void:
	skills_section_label.text = "Habilidades (selecione 4) - %d/4" % skill_count
	potions_section_label.text = "Pocoes (selecione 2) - %d/2" % potion_count

func _update_saved_button_state(saved_report: Dictionary = {}) -> void:
	if saved_report.is_empty():
		saved_report = _build_saved_selection_report()
	saved_button.text = "Restaurar salvo"
	saved_button.tooltip_text = ""
	if bool(saved_report.get("has_saved", false)):
		var mode_id: StringName = StringName(str(saved_report.get("mode_id", "")))
		if mode_id != &"":
			var saved_label: String = "Campanha Livre" if mode_id == LocalModeCatalog.CAMPAIGN_MODE_ID and _is_selected_campaign_free() else LocalModeCatalog.get_display_name(mode_id)
			saved_button.text = "Restaurar salvo (%s)" % saved_label
		if not bool(saved_report.get("compatible", false)):
			saved_button.tooltip_text = str(saved_report.get("issue_message", ""))
	saved_button.disabled = not bool(saved_report.get("compatible", false))

func _get_selected_ids(toggles: Array[CheckBox]) -> Array[String]:
	var ids: Array[String] = []
	for toggle: CheckBox in toggles:
		if toggle.button_pressed:
			ids.append(str(toggle.get_meta("entry_id", "")))
	return ids

func _get_selected_labels(toggles: Array[CheckBox]) -> Array[String]:
	var labels: Array[String] = []
	for toggle: CheckBox in toggles:
		if toggle.button_pressed:
			labels.append(str(toggle.get_meta("entry_label", "")))
	return labels

func _get_selected_race_id() -> StringName:
	var selected_index: int = race_option.get_selected()
	if race_option.get_item_count() == 0 or selected_index < 0:
		return &""
	return StringName(str(race_option.get_item_metadata(selected_index)))

func _get_selected_weapon_id() -> StringName:
	var selected_index: int = weapon_option.get_selected()
	if weapon_option.get_item_count() == 0 or selected_index < 0:
		return &""
	return StringName(str(weapon_option.get_item_metadata(selected_index)))

func _find_option_index_by_metadata(option_button: OptionButton, preferred_value: String) -> int:
	if preferred_value != "":
		for index: int in range(option_button.get_item_count()):
			if str(option_button.get_item_metadata(index)) == preferred_value:
				return index
	return -1

func _extract_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			result.append(str(entry))
	return result

func _restore_saved_mode_if_available() -> void:
	var saved_mode_id: StringName = _get_saved_selection_mode_id()
	if saved_mode_id != &"":
		selected_mode_id = saved_mode_id

func _ensure_selected_mode_is_supported() -> void:
	if LocalModeCatalog.is_supported_mode(selected_mode_id) and LocalModeCatalog.is_public_menu_mode(selected_mode_id):
		return

	selected_mode_id = ModeAvailabilityResolver.get_first_available_local_mode_id(
		player_profile,
		developer_unlock_all_enabled
	)

func _get_saved_selection_mode_id() -> StringName:
	var mode_id: StringName = LocalModeCatalog.normalize_mode_id(
		StringName(str(saved_selection.get("mode_id", "")))
	)
	if LocalModeCatalog.is_supported_mode(mode_id) and LocalModeCatalog.is_public_menu_mode(mode_id):
		return mode_id
	return &""

func _get_mode_state(mode_id: StringName) -> Dictionary:
	return ModeAvailabilityResolver.get_local_mode_state(
		player_profile,
		mode_id,
		developer_unlock_all_enabled
	)

func _build_saved_mode_suffix(saved_report: Dictionary) -> String:
	var mode_id: StringName = StringName(str(saved_report.get("mode_id", "")))
	if mode_id == &"":
		return ""
	if mode_id == LocalModeCatalog.CAMPAIGN_MODE_ID and _is_selected_campaign_free():
		return " para Campanha Livre"
	return " para %s" % LocalModeCatalog.get_display_name(mode_id)

func _build_saved_selection_report() -> Dictionary:
	if saved_selection.is_empty():
		return {
			"has_saved": false,
			"compatible": false,
			"mode_id": &"",
			"issue_message": ""
		}

	var report: Dictionary = {
		"has_saved": true,
		"compatible": true,
		"mode_id": _get_saved_selection_mode_id(),
		"issue_message": ""
	}
	var mode_suffix: String = _build_saved_mode_suffix(report)
	var race_id: StringName = StringName(str(saved_selection.get("race_id", "")))
	var weapon_id: StringName = StringName(str(saved_selection.get("weapon_id", "")))
	if _content_library().get_race(race_id) == null:
		report["compatible"] = false
		report["issue_message"] = "O kit salvo%s nao combina mais com o pacote atual. A raca salva nao existe mais; monte uma nova combinacao e entre em um modo para atualizar o perfil local." % mode_suffix
		return report
	if _content_library().get_weapon(weapon_id) == null:
		report["compatible"] = false
		report["issue_message"] = "O kit salvo%s nao combina mais com o pacote atual. A arma salva nao existe mais; monte uma nova combinacao e entre em um modo para atualizar o perfil local." % mode_suffix
		return report

	var missing_skills: int = 0
	for skill_id: String in _extract_string_array(saved_selection.get("skill_ids", [])):
		if _content_library().get_skill(StringName(skill_id)) == null:
			missing_skills += 1
	var missing_potions: int = 0
	for potion_id: String in _extract_string_array(saved_selection.get("potion_ids", [])):
		if _content_library().get_potion(StringName(potion_id)) == null:
			missing_potions += 1
	if missing_skills > 0 or missing_potions > 0:
		report["compatible"] = false
		report["issue_message"] = "O kit salvo%s nao combina mais com o pacote atual. %s Monte uma nova combinacao e entre em um modo para atualizar o perfil local." % [
			mode_suffix,
			_build_saved_selection_missing_summary(missing_skills, missing_potions)
		]
		return report

	var saved_loadout: LoadoutData = _content_library().build_loadout_from_ids(
		race_id,
		weapon_id,
		PackedStringArray(_extract_string_array(saved_selection.get("skill_ids", []))),
		PackedStringArray(_extract_string_array(saved_selection.get("potion_ids", [])))
	)
	var validation: Dictionary = _validate_builder_loadout(saved_loadout)
	if not bool(validation.get("ok", false)):
		report["compatible"] = false
		report["issue_message"] = "O kit salvo%s nao combina com o estado atual da conta. %s Monte uma nova combinacao com os recursos aprendidos atuais ou avance na campanha para liberar esse pacote." % [
			mode_suffix,
			str(validation.get("message", ""))
		]
	return report

func _build_saved_selection_missing_summary(missing_skills: int, missing_potions: int) -> String:
	var parts: Array[String] = []
	if missing_skills > 0:
		parts.append("%d %s do pacote salvo %s ausente%s" % [
			missing_skills,
			"habilidade" if missing_skills == 1 else "habilidades",
			"esta" if missing_skills == 1 else "estao",
			"" if missing_skills == 1 else "s"
		])
	if missing_potions > 0:
		parts.append("%d %s do pacote salvo %s ausente%s" % [
			missing_potions,
			"pocao" if missing_potions == 1 else "pocoes",
			"esta" if missing_potions == 1 else "estao",
			"" if missing_potions == 1 else "s"
		])
	if parts.is_empty():
		return ""
	var joined: String = " e ".join(parts)
	return "%s. " % joined

func _on_apply_saved_pressed() -> void:
	var saved_report: Dictionary = _build_saved_selection_report()
	if not bool(saved_report.get("has_saved", false)):
		return
	if not bool(saved_report.get("compatible", false)):
		message_label.text = str(saved_report.get("issue_message", "O kit salvo nao combina com o pacote atual."))
		message_label.modulate = Color(0.97, 0.72, 0.67, 1.0)
		return

	var saved_mode_id: StringName = StringName(str(saved_report.get("mode_id", "")))
	if saved_mode_id != &"":
		selected_mode_id = saved_mode_id

	var race_index: int = _find_option_index_by_metadata(race_option, str(saved_selection.get("race_id", "")))
	if race_index < 0:
		message_label.text = "O kit salvo nao combina mais com o pacote atual."
		message_label.modulate = Color(0.97, 0.72, 0.67, 1.0)
		return

	race_option.select(race_index)
	_populate_weapons()

	var weapon_index: int = _find_option_index_by_metadata(weapon_option, str(saved_selection.get("weapon_id", "")))
	if weapon_index < 0:
		message_label.text = "A arma salva nao existe no pacote atual."
		message_label.modulate = Color(0.97, 0.72, 0.67, 1.0)
		_rebuild_skill_and_potion_lists()
		_refresh_state()
		return

	weapon_option.select(weapon_index)
	_rebuild_skill_and_potion_lists()
	_apply_saved_toggle_selection(skill_toggles, _extract_string_array(saved_selection.get("skill_ids", [])), 4)
	_apply_saved_toggle_selection(potion_toggles, _extract_string_array(saved_selection.get("potion_ids", [])), 2)
	_refresh_state()

func _apply_saved_toggle_selection(toggles: Array[CheckBox], selected_ids: Array[String], max_selected: int) -> void:
	var applied: int = 0
	for toggle: CheckBox in toggles:
		if applied >= max_selected:
			break
		if bool(toggle.get_meta("progression_locked", false)):
			continue
		if selected_ids.has(str(toggle.get_meta("entry_id", ""))):
			toggle.button_pressed = true
			applied += 1

func _on_apply_canonical_pressed() -> void:
	for toggle: CheckBox in skill_toggles:
		if not bool(toggle.get_meta("progression_locked", false)):
			toggle.button_pressed = true
	for toggle: CheckBox in potion_toggles:
		if not bool(toggle.get_meta("progression_locked", false)):
			toggle.button_pressed = true
	_refresh_state()

func _on_start_pressed() -> void:
	launch_selected_mode()

func launch_selected_mode(perform_scene_change: bool = true) -> Dictionary:
	var mode_state: Dictionary = _get_surface_launch_state()
	if not bool(mode_state.get("unlocked", false)):
		var locked_result: Dictionary = {
			"ok": false,
			"message": str(mode_state.get("reason", "Modo local bloqueado."))
		}
		message_label.text = str(locked_result.get("message", ""))
		message_label.modulate = Color(0.97, 0.72, 0.67, 1.0)
		return locked_result

	if _selected_mode_has_suspended_run():
		pending_prompt_mode_id = selected_mode_id
		_show_suspended_run_prompt()
		var prompt_result: Dictionary = {
			"ok": true,
			"scene_path": LocalModeCatalog.get_scene_path(selected_mode_id),
			"mode_id": String(selected_mode_id),
			"prompted_suspended_run": true
		}
		message_label.text = _build_suspended_run_status_text(selected_mode_id)
		message_label.modulate = Color(0.98, 0.86, 0.66, 1.0)
		return prompt_result

	if not _mode_uses_authored_loadout(selected_mode_id) and not _is_loadout_page():
		var loadout_page_result: Dictionary = {
			"ok": false,
			"message": "Use Preparar kit para montar a combinacao antes de entrar neste modo."
		}
		message_label.text = str(loadout_page_result.get("message", ""))
		message_label.modulate = Color(0.97, 0.72, 0.67, 1.0)
		return loadout_page_result

	return _launch_mode_internal(perform_scene_change, false)

func _launch_mode_internal(perform_scene_change: bool, resume_suspended_run: bool) -> Dictionary:
	var loadout: LoadoutData = _build_launch_loadout(resume_suspended_run)
	var uses_authored_loadout: bool = _mode_uses_authored_loadout(selected_mode_id)
	var validation: Dictionary = {"ok": true, "message": ""}
	if not uses_authored_loadout:
		validation = loadout_validator.validate(loadout) if resume_suspended_run else _validate_builder_loadout(loadout)
	if not bool(validation.get("ok", false)):
		message_label.text = str(validation.get("message", ""))
		return validation

	if not uses_authored_loadout and not resume_suspended_run:
		_settings_store().save_selected_loadout(loadout, selected_mode_id)
		saved_selection = _settings_store().load_saved_selection()
		var saved_report: Dictionary = _build_saved_selection_report()
		_update_saved_button_state(saved_report)
		_update_save_state_label(loadout, true, saved_report)
		message_label.text = "Kit local atualizado para %s." % _build_selected_entry_label()
	elif not uses_authored_loadout and resume_suspended_run:
		message_label.text = "Run suspensa retomada para %s." % LocalModeCatalog.get_display_name(selected_mode_id)
	else:
		message_label.text = "Rota Classic preparada para %s." % LocalModeCatalog.get_display_name(selected_mode_id)
	message_label.modulate = Color(0.73, 0.91, 0.69, 1.0)

	var launch_result: Dictionary = _launch_context().set_pending_mode_launch(
		selected_mode_id,
		loadout,
		_build_launch_parameters_for_selected_mode(resume_suspended_run)
	)
	if not bool(launch_result.get("ok", false)):
		message_label.text = str(launch_result.get("message", "Falha ao preparar o modo local."))
		message_label.modulate = Color(0.97, 0.72, 0.67, 1.0)
		return launch_result

	if perform_scene_change:
		get_tree().change_scene_to_file(str(launch_result.get("scene_path", LocalModeCatalog.get_scene_path(selected_mode_id))))
	return launch_result

func _mode_uses_authored_loadout(mode_id: StringName) -> bool:
	return (
		LocalModeCatalog.normalize_mode_id(mode_id) == LocalModeCatalog.CAMPAIGN_MODE_ID
		and _get_selected_campaign_difficulty_id() != ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID
	)

func _should_route_campaign_to_tutorial() -> bool:
	return false

func _build_start_button_label(mode_state: Dictionary) -> String:
	if selected_mode_id == LocalModeCatalog.CAMPAIGN_MODE_ID and bool(mode_state.get("unlocked", false)):
		if _get_selected_campaign_difficulty_id() == ProgressionResolver.FREE_CAMPAIGN_DIFFICULTY_ID:
			if _selected_mode_has_suspended_run() and not _is_loadout_page():
				return "Continuar Campanha Livre"
			return "Entrar na Campanha Livre" if _is_loadout_page() else "Preparar Campanha Livre"
		if _get_selected_campaign_difficulty_id() == &"normal":
			return "Continuar a Campanha (Normal)"
		return "Continuar a Campanha"
	if not bool(mode_state.get("unlocked", false)):
		return "Modo bloqueado"
	if _selected_mode_has_suspended_run() and not _is_loadout_page():
		return "Continuar %s" % LocalModeCatalog.get_display_name(selected_mode_id)
	return LocalModeCatalog.get_action_label(selected_mode_id)

func _show_suspended_run_prompt() -> void:
	if suspended_run_prompt_panel == null:
		return
	var prompt_mode_id: StringName = pending_prompt_mode_id if pending_prompt_mode_id != &"" else selected_mode_id
	suspended_run_prompt_title_label.text = _build_suspended_run_display_title(prompt_mode_id)
	suspended_run_prompt_label.text = _build_suspended_run_prompt_text(prompt_mode_id)
	suspended_run_prompt_hint_label.text = _build_suspended_run_prompt_hint_text(prompt_mode_id)
	if suspended_run_prompt_backdrop != null:
		suspended_run_prompt_backdrop.visible = true
	suspended_run_prompt_panel.visible = true
	suspended_continue_button.grab_focus()

func _hide_suspended_run_prompt() -> void:
	if suspended_run_prompt_backdrop != null:
		suspended_run_prompt_backdrop.visible = false
	if suspended_run_prompt_panel != null:
		suspended_run_prompt_panel.visible = false
	pending_prompt_mode_id = &""

func _selected_mode_has_suspended_run() -> bool:
	if LocalModeCatalog.normalize_mode_id(selected_mode_id) == LocalModeCatalog.CAMPAIGN_MODE_ID:
		return _profile_store().has_campaign_suspended_run(
			ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
			_get_selected_campaign_difficulty_id()
		)
	var run_key: StringName = _get_suspended_run_key(selected_mode_id)
	return run_key != &"" and _profile_store().has_suspended_run(run_key)

func _get_suspended_run_key(mode_id: StringName) -> StringName:
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			return ProgressionResolver.build_campaign_run_key(
				ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
				_get_selected_campaign_difficulty_id()
			)
		LocalModeCatalog.SURVIVAL_MODE_ID:
			return ProgressionResolver.build_survival_run_key()
		LocalModeCatalog.BOSS_MODE_ID:
			return ProgressionResolver.build_boss_run_key(&"boss_troll")
		_:
			return &""

func _on_suspended_continue_pressed() -> void:
	_hide_suspended_run_prompt()
	_launch_mode_internal(true, true)

func _on_suspended_abandon_pressed() -> void:
	var run_key: StringName = _get_suspended_run_key(pending_prompt_mode_id if pending_prompt_mode_id != &"" else selected_mode_id)
	if LocalModeCatalog.normalize_mode_id(pending_prompt_mode_id if pending_prompt_mode_id != &"" else selected_mode_id) == LocalModeCatalog.CAMPAIGN_MODE_ID:
		_profile_store().clear_campaign_suspended_run(
			ProgressionResolver.BLACKSMITH_CAMPAIGN_ID,
			_get_selected_campaign_difficulty_id()
		)
	elif run_key != &"":
		_profile_store().clear_suspended_run(run_key)
	player_profile = _profile_store().load_profile()
	_hide_suspended_run_prompt()
	_refresh_state()
	_launch_mode_internal(true, false)

func _build_launch_parameters_for_selected_mode(resume_suspended_run: bool) -> Dictionary:
	var overrides: Dictionary = {
		"resume_suspended_run": resume_suspended_run
	}
	if LocalModeCatalog.normalize_mode_id(selected_mode_id) == LocalModeCatalog.CAMPAIGN_MODE_ID:
		overrides["campaign_id"] = String(ProgressionResolver.BLACKSMITH_CAMPAIGN_ID)
		overrides["difficulty_id"] = String(_get_selected_campaign_difficulty_id())
	return LocalModeCatalog.build_launch_parameters(selected_mode_id, overrides)

func _on_suspended_cancel_pressed() -> void:
	_hide_suspended_run_prompt()

func _build_mode_button_name(mode_id: StringName) -> String:
	match LocalModeCatalog.normalize_mode_id(mode_id):
		LocalModeCatalog.CAMPAIGN_MODE_ID:
			return "CampanhaModeButton"
		LocalModeCatalog.SURVIVAL_MODE_ID:
			return "SurvivalModeButton"
		LocalModeCatalog.BOSS_MODE_ID:
			return "BossModeButton"
		LocalModeCatalog.ARENA_BOT_MODE_ID:
			return "ArenaBotModeButton"
		LocalModeCatalog.ARENA_PVP_MODE_ID:
			return "ArenaPvpModeButton"
		_:
			return "ModeButton"
