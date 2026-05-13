extends Node2D

const PLAYER_SPEED: float = 220.0
const MAP_RECT: Rect2 = Rect2(Vector2(80, 80), Vector2(1120, 600))
const NPC_POSITION: Vector2 = Vector2(420, 330)
const INTERACTION_RADIUS: float = 86.0
const ENCOUNTER_MARKERS: Array[Dictionary] = [
	{"id": "emboscada_na_ponte", "label": "Pouso", "position": Vector2(720, 300), "requires": "", "min_rank": 0},
	{"id": "duelista_bandido", "label": "Guardiao", "position": Vector2(880, 330), "requires": "emboscada_na_ponte", "min_rank": 0},
	{"id": "emboscada_no_cruzamento", "label": "Conduto", "position": Vector2(1020, 390), "requires": "duelista_bandido", "min_rank": 0},
	{"id": "fortaleza_do_desfiladeiro", "label": "Bastiao", "position": Vector2(1080, 230), "requires": "emboscada_no_cruzamento", "min_rank": 0},
	{"id": "invasao_em_ondas", "label": "Ondas", "position": Vector2(700, 220), "requires": "fortaleza_do_desfiladeiro", "min_rank": 0},
	{"id": "defesa_do_portao", "label": "Defesa", "position": Vector2(520, 220), "requires": "invasao_em_ondas", "min_rank": 0},
	{"id": "colosso_fragmentado", "label": "Nucleo", "position": Vector2(360, 250), "requires": "defesa_do_portao", "min_rank": 0},
	{"id": "enigma_da_ponte", "label": "Selos", "position": Vector2(260, 360), "requires": "colosso_fragmentado", "min_rank": 0},
	{"id": "patrulha_avancada", "label": "Varredura", "position": Vector2(900, 180), "requires": "", "min_rank": 1},
	{"id": "duelista_sombrio", "label": "Conduto 2", "position": Vector2(1020, 290), "requires": "", "min_rank": 2},
	{"id": "emboscada_reforcos", "label": "Reforcamento", "position": Vector2(820, 430), "requires": "", "min_rank": 3},
]

var player_position: Vector2 = Vector2(180, 330)
var prompt_label: Label
var rank_label: Label
var dialogue_panel: PanelContainer
var dialogue_text: Label
var portrait_rect: TextureRect
var player_sprite: Sprite2D
var marker_nodes: Node2D
var close_dialogue_button: Button

func _ready() -> void:
	set_process(true)
	_build_art_nodes()
	_build_canvas()
	queue_redraw()

func _process(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if input_vector.length() > 0.0:
		player_position += input_vector.normalized() * PLAYER_SPEED * delta
		player_position.x = clampf(player_position.x, MAP_RECT.position.x + 18.0, MAP_RECT.end.x - 18.0)
		player_position.y = clampf(player_position.y, MAP_RECT.position.y + 18.0, MAP_RECT.end.y - 18.0)
		if player_sprite != null:
			player_sprite.position = player_position
		queue_redraw()
	_update_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_try_interact()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.045, 0.055, 0.06), true)
	draw_rect(MAP_RECT, Color(0.12, 0.16, 0.14), true)
	draw_rect(MAP_RECT, Color(0.34, 0.42, 0.36), false, 4.0)

	for index: int in range(ENCOUNTER_MARKERS.size() - 1):
		var from_marker: Dictionary = ENCOUNTER_MARKERS[index]
		var to_marker: Dictionary = ENCOUNTER_MARKERS[index + 1]
		var from_position: Vector2 = Vector2(from_marker.get("position", Vector2.ZERO))
		var to_position: Vector2 = Vector2(to_marker.get("position", Vector2.ZERO))
		var path_color: Color = Color(0.3, 0.34, 0.32)
		if GameSession.has_completed_encounter(str(from_marker.get("id", ""))):
			path_color = Color(0.42, 0.6, 0.44)
		draw_line(from_position, to_position, path_color, 5.0)

	draw_circle(NPC_POSITION, 28.0, Color(0.3, 0.46, 0.78))
	draw_string(ThemeDB.fallback_font, NPC_POSITION + Vector2(-48, -42), "Comando", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)

	for marker: Dictionary in ENCOUNTER_MARKERS:
		var marker_position: Vector2 = Vector2(marker.get("position", Vector2.ZERO))
		var encounter_id: String = str(marker.get("id", ""))
		var status_text: String = _marker_status_text(marker)
		var encounter_color: Color = Color(0.24, 0.25, 0.26)
		if _marker_available(marker):
			encounter_color = Color(0.72, 0.42, 0.28)
		if GameSession.has_completed_encounter(encounter_id):
			encounter_color = Color(0.28, 0.42, 0.32)
		draw_rect(Rect2(marker_position - Vector2(28, 28), Vector2(56, 56)), encounter_color, true)
		if GameSession.active_encounter_id == encounter_id:
			draw_rect(Rect2(marker_position - Vector2(34, 34), Vector2(68, 68)), Color(0.95, 0.82, 0.42), false, 3.0)
		draw_string(ThemeDB.fallback_font, marker_position + Vector2(-46, -38), str(marker.get("label", "Encontro")), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		draw_string(ThemeDB.fallback_font, marker_position + Vector2(-48, 46), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.9, 0.92, 0.86))

	draw_circle(player_position, 22.0, Color(0.86, 0.86, 0.72))
	draw_string(ThemeDB.fallback_font, player_position + Vector2(-48, -34), "Jogador", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)

func _build_canvas() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)

	var top_bar: PanelContainer = PanelContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = 16
	top_bar.offset_top = 12
	top_bar.offset_right = -16
	top_bar.offset_bottom = 64
	top_bar.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.1)))
	layer.add_child(top_bar)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 16)
	top_bar.add_child(top_row)

	rank_label = Label.new()
	rank_label.add_theme_color_override("font_color", Color(0.75, 0.88, 1.0))
	top_row.add_child(rank_label)

	prompt_label = Label.new()
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(prompt_label)

	dialogue_panel = PanelContainer.new()
	dialogue_panel.visible = false
	dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	dialogue_panel.offset_left = 80
	dialogue_panel.offset_top = -190
	dialogue_panel.offset_right = -80
	dialogue_panel.offset_bottom = -28
	dialogue_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.09, 0.12)))
	layer.add_child(dialogue_panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	dialogue_panel.add_child(box)

	var dialogue_row: HBoxContainer = HBoxContainer.new()
	dialogue_row.add_theme_constant_override("separation", 10)
	box.add_child(dialogue_row)

	portrait_rect = TextureRect.new()
	portrait_rect.name = "portrait_rect"
	portrait_rect.custom_minimum_size = Vector2(72, 72)
	portrait_rect.texture = AssetIds.texture("portrait_npc_viajante")
	portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait_rect.modulate = Color.WHITE if portrait_rect.texture != null else UiTokens.color("placeholder")
	dialogue_row.add_child(portrait_rect)

	dialogue_text = Label.new()
	dialogue_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_row.add_child(dialogue_text)

	close_dialogue_button = Button.new()
	close_dialogue_button.text = "Fechar"
	close_dialogue_button.pressed.connect(func() -> void: dialogue_panel.visible = false)
	box.add_child(close_dialogue_button)
	_update_prompt()

func _try_interact() -> void:
	if player_position.distance_to(NPC_POSITION) <= INTERACTION_RADIUS:
		_interact_npc()
		return
	var marker: Dictionary = _nearest_encounter_marker()
	if not marker.is_empty():
		_interact_encounter(marker)

func _interact_npc() -> void:
	var rank_name: String = GameSession.get_rank_display_name()
	if not GameSession.has_npc_reward_card:
		var reward_id: String = GameSession.claim_npc_reward()
		dialogue_text.text = "%s — o comando Draxos autoriza uma tecnica para testar na missao: %s." % [rank_name, ContentLibrary.get_card_name(reward_id)]
		GameSession.save_game()
	elif GameSession.completed_encounter_ids.size() > GameSession.npc_reward_index:
		var progressive_reward_id: String = GameSession.claim_npc_progressive_reward()
		if progressive_reward_id != "":
			dialogue_text.text = "%s — o comando libera uma nova opcao pelo progresso: %s." % [rank_name, ContentLibrary.get_card_name(progressive_reward_id)]
			GameSession.save_game()
		else:
			dialogue_text.text = "%s — o comando observa a operacao. Nao ha novas tecnicas por enquanto." % rank_name
	else:
		dialogue_text.text = "%s — o comando observa a operacao. Novas missoes aparecem conforme voce vence." % rank_name
	dialogue_panel.visible = true
	_update_prompt()
	queue_redraw()

func _interact_encounter(marker: Dictionary) -> void:
	if not GameSession.has_npc_reward_card:
		dialogue_text.text = "O marcador ainda nao responde. Fale com o comando antes de iniciar a missao."
		dialogue_panel.visible = true
		return
	if not _marker_available(marker):
		dialogue_text.text = "A rota ainda esta bloqueada. Conclua a missao anterior."
		dialogue_panel.visible = true
		return
	GameSession.set_active_encounter(str(marker.get("id", GameSession.ACTIVE_ENCOUNTER_ID)))
	GameSession.save_game()
	GameSession.capture_pre_combat_snapshot()
	get_tree().change_scene_to_file("res://modes/battle/deck_setup.tscn")

func _update_prompt() -> void:
	if prompt_label == null:
		return
	if rank_label != null:
		rank_label.text = "Rank: %s" % GameSession.get_rank_display_name()
	if player_position.distance_to(NPC_POSITION) <= INTERACTION_RADIUS:
		prompt_label.text = "E: falar com comando | WASD: mover"
	elif not _nearest_encounter_marker().is_empty():
		prompt_label.text = "E: abrir missao | WASD: mover"
	else:
		prompt_label.text = "WASD: mover | E: interagir"

func _nearest_encounter_marker() -> Dictionary:
	for marker: Dictionary in ENCOUNTER_MARKERS:
		if player_position.distance_to(Vector2(marker.get("position", Vector2.ZERO))) <= INTERACTION_RADIUS:
			return marker
	return {}

func _marker_available(marker: Dictionary) -> bool:
	var required_id: String = str(marker.get("requires", ""))
	if required_id != "" and not GameSession.has_completed_encounter(required_id):
		return false
	var min_rank: int = int(marker.get("min_rank", 0))
	return GameSession.operacao_rank >= min_rank

func _marker_status_text(marker: Dictionary) -> String:
	var encounter_id: String = str(marker.get("id", ""))
	if GameSession.has_completed_encounter(encounter_id):
		return "Concluido"
	if _marker_available(marker):
		return "Disponivel"
	var min_rank: int = int(marker.get("min_rank", 0))
	if GameSession.operacao_rank < min_rank:
		var rank_names: Array[String] = ["Recruta", "Agente", "Operativo", "Comandante"]
		return "Requer: %s" % rank_names[clampi(min_rank, 0, 3)]
	return "Bloqueado"

func _panel_style(fill: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = Color(0.24, 0.28, 0.3)
	style.border_width_left = 2
	style.border_width_top = 2
	style.b