class_name BootHubSurfacePreparationPresenter
extends "res://modes/boot/surfaces/hub_surface_common_presenter.gd"

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const ProgressionClarityPresenterScript := preload("res://modes/boot/surfaces/progression_clarity_presenter.gd")

static func preparation_panel(host: Node, compact: bool, context: String = "refuge_legacy") -> PanelContainer:
	return _preparation_panel(host, compact, context)

static func _preparation_first_session_hint(combat_build: Dictionary, spell_slots: Array) -> String:
	var level := int(SessionStore.player_snapshot().get("level", combat_build.get("level", 0)))
	if level <= 2:
		return "Primeira sessao: o Instrumento Ritual inicial ja basta para entrar na Arena PVE."
	var equipped_spells := 0
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		var spell_id := str(slot.get("spell_id", "")).strip_edges()
		if spell_id != "" and spell_id != "<null>" and spell_id.to_lower() != "null":
			equipped_spells += 1
	if equipped_spells <= 0:
		return "Primeira sessao: sem habilidades equipadas, confirme o Instrumento Ritual e abra a Arena."
	return "Primeira sessao: confira instrumento, habilidades e pocao antes da Arena."

static func _preparation_panel(host: Node, compact: bool, context: String = "refuge_legacy") -> PanelContainer:
	var behavior_only := context == "arena_active_behavior"
	var arena_embedded := context == "arena_pre_start" or behavior_only
	var panel_name := "ArenaActivePreparationPanel" if behavior_only else "PreparationPanel"
	var panel := _panel(host, panel_name, "bg_panel", "border_active")
	var box := _panel_box(panel, compact)
	var combat_build := SessionStore.combat_build_snapshot()
	var account_build := SessionStore.build_snapshot()
	var options := _as_dictionary(combat_build.get("equipment_options", {}))
	var inventory := _as_array(combat_build.get("inventory", []))
	var potion_slots := _as_array(combat_build.get("potion_slots", []))
	var spell_slots := _preparation_spell_slots(combat_build)

	box.add_child(_section_label("Comportamento da tentativa" if behavior_only else "Preparacao da Arena", compact))
	if behavior_only:
		box.add_child(_body_label("Loadout travado para esta tentativa. Entre duelos, ajuste apenas comportamento simples.", compact))
	else:
		box.add_child(_body_label("Este e o loadout que sera travado ao iniciar uma tentativa.", compact))
		box.add_child(_body_label(_preparation_first_session_hint(combat_build, spell_slots), compact))
	var feedback_message := str(host.get_meta("preparation_feedback_message", "")).strip_edges()
	if feedback_message != "":
		box.add_child(_body_label("Ultima escolha: %s" % feedback_message, compact))
	var level_text := _preparation_account_power_text(combat_build)

	var instrument_id := _first_non_empty_string(combat_build, ["weapon_type", "weapon_id", "instrument_id", "ritual_instrument_id"])
	if instrument_id == "":
		instrument_id = _first_non_empty_string(account_build, ["weapon_type", "weapon_id", "instrument_id", "ritual_instrument_id"])
	var familiar_id := _first_non_empty_string(combat_build, ["pet_id", "familiar_id"])
	if familiar_id == "":
		familiar_id = _first_non_empty_string(account_build, ["pet_id", "familiar_id"])
	var doctrine_id := _first_non_empty_string(combat_build, ["passive_id", "doctrine_id", "doutrina_id"])
	if doctrine_id == "":
		doctrine_id = _first_non_empty_string(account_build, ["passive_id", "doctrine_id", "doutrina_id"])
	var stock := _inventory_quantity(inventory, AppShellActionContractScript.ITEM_HEALTH_POTION)
	var potion_slot := _first_dictionary(potion_slots)
	var potion_id := str(potion_slot.get("potion_id", ""))
	var potion_behavior := _as_dictionary(potion_slot.get("behavior", {}))

	box.add_child(_body_label("Loadout atual: %s, %s, %s, %s" % [
		_preparation_item_label(instrument_id),
		_preparation_spell_summary(spell_slots),
		_preparation_item_label(doctrine_id) if doctrine_id != "" else "Sem Doutrina",
		_preparation_item_label(familiar_id) if familiar_id != "" else "Sem Familiar",
	], compact))
	box.add_child(_body_label("%s\n%s" % [
		level_text if level_text != "" else "Nivel e poder ainda sincronizando",
		"Pocao e comportamento: %s | %s" % [
			_potion_status_text(potion_id),
			_potion_timing_text(potion_id, potion_behavior) if _potion_timing_text(potion_id, potion_behavior) != "" else "sem uso automatico",
		],
	], compact))
	if not arena_embedded:
		var cta_grid := _button_grid(compact, 1)
		box.add_child(cta_grid)
		cta_grid.add_child(_entry_action_button(host, "Abrir Arena PVE", AppShellActionContractScript.ACTION_OPEN_ARENA, compact, "", true))

	box.add_child(_section_label("Ajustar comportamento" if behavior_only else "Editar loadout e comportamento", compact))
	if behavior_only:
		box.add_child(_body_label("Instrumento, habilidades equipadas, Doutrina, Familiar e slot de Pocao nao podem mudar ate encerrar a tentativa.", compact))
	else:
		box.add_child(_body_label("Ajuste instrumento, habilidades, Doutrina, Familiar, Pocao e preferencias simples.", compact))
	box.add_child(_body_label("Resumo:\nInstrumento: %s\nHabilidades: %s\nDoutrina: %s\nFamiliar: %s\nPocao: %s" % [
		_preparation_item_label(instrument_id),
		_preparation_spell_summary(spell_slots),
		_preparation_item_label(doctrine_id) if doctrine_id != "" else "Sem Doutrina",
		_preparation_item_label(familiar_id) if familiar_id != "" else "Sem Familiar",
		_potion_status_text(potion_id),
	], compact))
	var progression_lines := ProgressionClarityPresenterScript.preparation_progress_lines(combat_build, 3)
	if not behavior_only and not progression_lines.is_empty():
		box.add_child(_section_label("Proximos marcos", compact))
		for line: String in progression_lines:
			box.add_child(_body_label(line, compact))
	if not behavior_only:
		box.add_child(_section_label("Instrumento Ritual", compact))
		if instrument_id != "":
			box.add_child(_body_label("Em uso: %s%s" % [
				_preparation_item_label(instrument_id),
				_preparation_level_suffix_with_fallback(combat_build, account_build, ["weapon_level", "instrument_level"]),
			], compact))
		_render_preparation_options(
			host,
			box,
			compact,
			_as_array(options.get("weapons", [])),
			instrument_id,
			"instrument",
			false
		)

	box.add_child(_section_label("Habilidades", compact))
	if spell_slots.is_empty():
		box.add_child(_body_label("Nenhuma habilidade equipada.", compact))
	else:
		for slot: Dictionary in spell_slots:
			var position := int(slot.get("slot_index", 1))
			var spell_id := str(slot.get("spell_id", "")).strip_edges()
			var unlocked := bool(slot.get("unlocked", true))
			if not unlocked:
				box.add_child(_body_label("Habilidade %d: desbloqueia no nivel %d." % [position, int(slot.get("unlock_level", 1))], compact))
				continue
			if spell_id == "" or spell_id == "<null>" or spell_id.to_lower() == "null":
				box.add_child(_body_label("Habilidade %d: vazia." % position, compact))
				continue
			box.add_child(_body_label("Habilidade %d: %s | %s" % [
				position,
				_preparation_item_label(spell_id),
				_spell_timing_text(_as_dictionary(slot.get("behavior", {}))),
			], compact))
			var remove_spell_actions := _button_grid(compact, 2)
			box.add_child(remove_spell_actions)
			remove_spell_actions.add_child(_entry_action_button(host, "Usar na Arena", AppShellActionContractScript.enable_spell_behavior_action(spell_id), compact))
			remove_spell_actions.add_child(_entry_action_button(host, "Pausar", AppShellActionContractScript.disable_spell_behavior_action(spell_id), compact))
			if not behavior_only:
				remove_spell_actions.add_child(_entry_action_button(host, "Remover", AppShellActionContractScript.remove_spell_position_action(position), compact))
	if behavior_only:
		box.add_child(_body_label("Para trocar habilidades, encerre a tentativa e volte para a selecao da Arena.", compact))
	else:
		_render_spell_options(host, box, compact, _as_array(options.get("spells", [])), spell_slots)

	if not behavior_only:
		box.add_child(_section_label("Doutrina", compact))
		var doctrine_text := _preparation_item_label(doctrine_id) if doctrine_id != "" else "Nenhuma Doutrina equipada"
		if doctrine_id != "":
			doctrine_text += _preparation_level_suffix_with_fallback(combat_build, account_build, ["passive_level", "doctrine_level", "doutrina_level"])
		box.add_child(_body_label("Em uso: %s" % doctrine_text, compact))
		_render_preparation_options(
			host,
			box,
			compact,
			_as_array(options.get("doutrines", [])),
			doctrine_id,
			"doctrine",
			true,
			AppShellActionContractScript.remove_doctrine_action()
		)

		box.add_child(_section_label("Familiar", compact))
		var familiar_text := _preparation_item_label(familiar_id) if familiar_id != "" else "Nenhum Familiar equipado"
		if familiar_id != "":
			familiar_text += _preparation_level_suffix_with_fallback(combat_build, account_build, ["pet_level", "familiar_level"])
		box.add_child(_body_label("Em uso: %s" % familiar_text, compact))
		_render_preparation_options(
			host,
			box,
			compact,
			_as_array(options.get("familiars", [])),
			familiar_id,
			"familiar",
			true,
			AppShellActionContractScript.remove_familiar_action()
		)

	box.add_child(_section_label("Pocao", compact))
	box.add_child(_body_label(_potion_status_text(potion_id), compact))
	box.add_child(_body_label("Estoque: %d" % stock, compact))
	var potion_timing_text := _potion_timing_text(potion_id, potion_behavior)
	if potion_timing_text != "":
		box.add_child(_body_label(potion_timing_text, compact))

	var potion_actions := _button_grid(compact, 2)
	box.add_child(potion_actions)
	if not behavior_only:
		potion_actions.add_child(_entry_action_button(host, "Equipar Pocao de Vida", AppShellActionContractScript.ACTION_EQUIP_HEALTH_POTION, compact))
		potion_actions.add_child(_entry_action_button(host, "Remover pocao", AppShellActionContractScript.ACTION_UNEQUIP_POTION, compact))
	potion_actions.add_child(_entry_action_button(host, "Usar com vida baixa", AppShellActionContractScript.ACTION_ENABLE_POTION_DEFAULT, compact))
	potion_actions.add_child(_entry_action_button(host, "Pausar pocao", AppShellActionContractScript.ACTION_DISABLE_POTION, compact))
	return panel

static func _potion_status_text(potion_id: String) -> String:
	var cleaned := potion_id.strip_edges()
	if cleaned == AppShellActionContractScript.ITEM_HEALTH_POTION:
		return "Pocao de Vida equipada"
	if cleaned == "" or cleaned == "<null>" or cleaned.to_lower() == "null":
		return "Nenhuma pocao equipada"
	return "%s equipada" % _preparation_item_label(cleaned)

static func _potion_timing_text(potion_id: String, behavior: Dictionary) -> String:
	if potion_id.strip_edges() != AppShellActionContractScript.ITEM_HEALTH_POTION:
		return ""
	if not bool(behavior.get("enabled", true)):
		return "Pocao pausada"
	return "Usa automaticamente com vida baixa"

static func _spell_timing_text(behavior: Dictionary) -> String:
	if behavior.is_empty():
		return "Usa quando estiver pronta"
	if not bool(behavior.get("enabled", true)):
		return "Pausada para Arena"
	var condition_text := _condition_text(behavior)
	if condition_text == "":
		return "Usa quando estiver pronta"
	return "Usa quando estiver pronta; %s" % condition_text

static func _condition_text(behavior: Dictionary) -> String:
	var hp := _as_dictionary(behavior.get("hp", {}))
	var mana := _as_dictionary(behavior.get("mana", {}))
	var parts := PackedStringArray()
	if str(hp.get("mode", "ignore")) != "ignore":
		parts.append("Vida %s %d%%" % [
			"abaixo de" if str(hp.get("mode", "")) == "below" else "acima de",
			int(hp.get("percent", 0)),
		])
	if str(mana.get("mode", "ignore")) != "ignore":
		parts.append("Mana %s %d%%" % [
			"abaixo de" if str(mana.get("mode", "")) == "below" else "acima de",
			int(mana.get("percent", 0)),
		])
	if parts.is_empty():
		return ""
	return "entra melhor com %s" % " e ".join(parts)

static func _preparation_item_label(item_id: String) -> String:
	var cleaned := item_id.strip_edges()
	if cleaned == AppShellActionContractScript.ITEM_HEALTH_POTION:
		return "Pocao de Vida"
	match cleaned:
		"varinha_cinzas":
			return "Varinha de Cinzas"
		"athame_hematico":
			return "Athame Hematico"
		"cajado_ossario":
			return "Cajado Ossario"
		"orbe_tempestade":
			return "Orbe da Tempestade"
		"grimorio_veu":
			return "Grimorio do Veu"
		"idolo_pedra_viva":
			return "Idolo de Pedra Viva"
		"doutrina_pavor":
			return "Doutrina do Pavor"
		"pacto_familiar":
			return "Pacto Familiar"
		"corvo_pressagio":
			return "Corvo de Pressagio"
		"incisao_ritual":
			return "Incisao Ritual"
		"sussurro_medo":
			return "Sussurro do Medo"
	if cleaned == "":
		return "Nao definido"
	return _humanize_id(cleaned)

static func _preparation_spell_slots(combat_build: Dictionary) -> Array:
	var direct_slots := _as_array(combat_build.get("spell_slots", []))
	if not direct_slots.is_empty():
		var normalized := []
		for slot_variant: Variant in direct_slots:
			var slot := _as_dictionary(slot_variant)
			if not slot.is_empty():
				normalized.append(slot)
		return normalized

	var equipped := _as_array(combat_build.get("equipped_spells", []))
	if equipped.is_empty():
		return []

	var fallback := []
	for index in range(equipped.size()):
		var equipped_spell := _as_dictionary(equipped[index])
		var spell_id := str(equipped_spell.get("spell_id", "")).strip_edges()
		if spell_id == "":
			continue
		fallback.append({
			"slot_index": index + 1,
			"unlock_level": 1,
			"unlocked": true,
			"spell_id": spell_id,
			"behavior": _as_dictionary(equipped_spell.get("behavior", {})),
		})
	return fallback

static func _preparation_spell_summary(spell_slots: Array) -> String:
	var count := 0
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		var spell_id := str(slot.get("spell_id", "")).strip_edges()
		if spell_id != "" and spell_id != "<null>" and spell_id.to_lower() != "null":
			count += 1
	if count <= 0:
		return "Sem habilidades"
	if count == 1:
		return "1 habilidade"
	return "%d habilidades" % count

static func _render_preparation_options(
	host: Node,
	box: VBoxContainer,
	compact: bool,
	options: Array,
	current_id: String,
	action_kind: String,
	allow_remove: bool,
	remove_action: String = ""
) -> void:
	var rendered := false
	var visible_count := mini(options.size(), 8)
	for index in range(visible_count):
		var option := _as_dictionary(options[index])
		var item_id := str(option.get("id", "")).strip_edges()
		if item_id == "":
			continue
		rendered = true
		var name := str(option.get("display_name", "")).strip_edges()
		if name == "":
			name = _preparation_item_label(item_id)
		var equipped := bool(option.get("equipped", false)) or item_id == current_id
		var unlocked := bool(option.get("unlocked", true))
		var detail := "Em uso" if equipped else "Disponivel"
		if not unlocked:
			detail = str(option.get("locked_reason", "")).strip_edges()
			if detail == "":
				detail = "Bloqueado por nivel."
		box.add_child(_body_label("%s: %s" % [name, detail], compact))
		if unlocked and not equipped:
			var grid := _button_grid(compact, 1)
			box.add_child(grid)
			grid.add_child(_entry_action_button(host, "Equipar", _preparation_equip_action(action_kind, item_id), compact))

	if options.size() > visible_count:
		box.add_child(_body_label("Mais escolhas aparecem conforme o catalogo cresce.", compact))
	if not rendered:
		box.add_child(_body_label("Nenhuma escolha disponivel agora.", compact))
	if allow_remove and current_id != "" and remove_action != "":
		var remove_grid := _button_grid(compact, 1)
		box.add_child(remove_grid)
		remove_grid.add_child(_entry_action_button(host, "Remover", remove_action, compact))

static func _render_spell_options(host: Node, box: VBoxContainer, compact: bool, options: Array, spell_slots: Array) -> void:
	var equipped_ids := _equipped_spell_ids(spell_slots)
	var rendered := false
	var visible_count := mini(options.size(), 10)
	for index in range(visible_count):
		var option := _as_dictionary(options[index])
		var spell_id := str(option.get("id", "")).strip_edges()
		if spell_id == "":
			continue
		rendered = true
		var name := str(option.get("display_name", "")).strip_edges()
		if name == "":
			name = _preparation_item_label(spell_id)
		var equipped := bool(option.get("equipped", false)) or bool(equipped_ids.get(spell_id, false))
		var unlocked := bool(option.get("unlocked", true))
		var detail := "Em uso" if equipped else "Disponivel"
		if not unlocked:
			detail = str(option.get("locked_reason", "")).strip_edges()
			if detail == "":
				detail = "Bloqueada por nivel."
		box.add_child(_body_label("%s: %s" % [name, detail], compact))
		if unlocked and not equipped:
			var position := _first_open_spell_position(spell_slots)
			if position <= 0:
				position = _first_unlocked_spell_position(spell_slots)
			if position > 0:
				var grid := _button_grid(compact, 1)
				box.add_child(grid)
				grid.add_child(_entry_action_button(
					host,
					"Equipar na habilidade %d" % position,
					AppShellActionContractScript.equip_spell_position_action(position, spell_id),
					compact
				))
	if options.size() > visible_count:
		box.add_child(_body_label("Mais habilidades aparecem conforme o catalogo cresce.", compact))
	if not rendered:
		box.add_child(_body_label("Nenhuma habilidade disponivel agora.", compact))

static func _preparation_equip_action(action_kind: String, item_id: String) -> String:
	match action_kind:
		"instrument":
			return AppShellActionContractScript.equip_instrument_action(item_id)
		"doctrine":
			return AppShellActionContractScript.equip_doctrine_action(item_id)
		"familiar":
			return AppShellActionContractScript.equip_familiar_action(item_id)
		_:
			return ""

static func _equipped_spell_ids(spell_slots: Array) -> Dictionary:
	var equipped := {}
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		var spell_id := str(slot.get("spell_id", "")).strip_edges()
		if spell_id != "" and spell_id != "<null>" and spell_id.to_lower() != "null":
			equipped[spell_id] = true
	return equipped

static func _first_open_spell_position(spell_slots: Array) -> int:
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		if not bool(slot.get("unlocked", true)):
			continue
		var spell_id := str(slot.get("spell_id", "")).strip_edges()
		if spell_id == "" or spell_id == "<null>" or spell_id.to_lower() == "null":
			return int(slot.get("slot_index", 1))
	return 0

static func _first_unlocked_spell_position(spell_slots: Array) -> int:
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		if bool(slot.get("unlocked", true)):
			return int(slot.get("slot_index", 1))
	return 0

static func _humanize_id(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned == "":
		return ""
	cleaned = cleaned.replace("-", " ")
	cleaned = cleaned.replace("_", " ")
	return cleaned.capitalize()

static func _preparation_level_suffix(data: Dictionary, keys: Array) -> String:
	for key_variant: Variant in keys:
		var key := str(key_variant)
		if data.has(key):
			var level := int(data.get(key, 0))
			if level > 0:
				return " L%d" % level
	return ""

static func _preparation_level_suffix_with_fallback(primary: Dictionary, fallback: Dictionary, keys: Array) -> String:
	var suffix := _preparation_level_suffix(primary, keys)
	if suffix != "":
		return suffix
	return _preparation_level_suffix(fallback, keys)

static func _preparation_account_power_text(combat_build: Dictionary = {}) -> String:
	var parts := PackedStringArray()
	var level := int(SessionStore.player_snapshot().get("level", 0))
	if level > 0:
		parts.append("Nivel %d" % level)
	var power := int(combat_build.get("power", SessionStore.player_snapshot().get("power", 0)))
	if power > 0:
		parts.append("Poder %d" % power)
	return " | ".join(parts)

static func _first_non_empty_string(data: Dictionary, keys: Array) -> String:
	for key_variant: Variant in keys:
		var key := str(key_variant)
		var value := str(data.get(key, "")).strip_edges()
		if value != "" and value != "<null>" and value.to_lower() != "null":
			return value
	return ""

static func _inventory_quantity(inventory: Array, item_id: String) -> int:
	for item_variant: Variant in inventory:
		var item := _as_dictionary(item_variant)
		if str(item.get("item_id", "")) == item_id:
			return int(item.get("quantity", 0))
	return 0

static func _first_dictionary(items: Array) -> Dictionary:
	for item: Variant in items:
		if item is Dictionary:
			return Dictionary(item)
	return {}
