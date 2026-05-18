extends Node

const SAVE_VERSION: int = 5
const SLOT_COUNT: int = 3

var current_slot_index: int = 1
var pending_new_game: bool = false
var save_path_prefix: String = "user://draxos_save_slot_"

func get_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []
	for index: int in range(1, SLOT_COUNT + 1):
		slots.append(_slot_info(index))
	return slots

func select_slot(index: int) -> Dictionary:
	if not _valid_slot(index):
		return {"ok": false, "message": "Slot invalido."}
	current_slot_index = index
	return {"ok": true, "message": "Slot %d selecionado." % index}

func begin_new_game(index: int) -> Dictionary:
	var select_result: Dictionary = select_slot(index)
	if not bool(select_result.get("ok", false)):
		return select_result
	if has_save(index):
		return {"ok": false, "message": "Escolha um slot livre para Novo Jogo."}
	RunSession.reset()
	pending_new_game = true
	return {"ok": true, "message": "Novo jogo preparado no Slot %d." % index}

func save_current_run(index: int = -1) -> Dictionary:
	if index == -1:
		index = current_slot_index
	if not _valid_slot(index):
		return {"ok": false, "message": "Slot invalido."}
	if not RunSession.active:
		return {"ok": false, "message": "Nenhuma run ativa para salvar."}
	current_slot_index = index
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://"))
	var payload: Dictionary = {
		"version": SAVE_VERSION,
		"slot_index": index,
		"saved_at_unix": Time.get_unix_time_from_system(),
		"run": RunSession.snapshot()
	}
	var file: FileAccess = FileAccess.open(_slot_path(index), FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Nao foi possivel abrir o arquivo de save."}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	pending_new_game = false
	return {"ok": true, "message": "Slot %d salvo." % index}

func load_slot(index: int) -> Dictionary:
	var data: Dictionary = _load_slot_data(index)
	if data.is_empty():
		return {"ok": false, "message": "Save inexistente ou invalido."}
	var run_data: Dictionary = Dictionary(data.get("run", {}))
	if run_data.is_empty():
		return {"ok": false, "message": "Save sem dados de run."}
	var result: Dictionary = RunSession.load_snapshot(run_data)
	if not bool(result.get("ok", false)):
		return result
	current_slot_index = index
	pending_new_game = false
	return {"ok": true, "message": "Slot %d carregado." % index}

func delete_slot(index: int) -> Dictionary:
	if not _valid_slot(index):
		return {"ok": false, "message": "Slot invalido."}
	if has_save_file(index):
		var remove_result: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(_slot_path(index)))
		if remove_result != OK:
			return {"ok": false, "message": "Nao foi possivel deletar o Slot %d." % index}
	if current_slot_index == index:
		pending_new_game = false
	return {"ok": true, "message": "Slot %d deletado." % index}

func has_save(index: int) -> bool:
	return not _load_slot_data(index).is_empty()

func has_save_file(index: int) -> bool:
	return _valid_slot(index) and FileAccess.file_exists(_slot_path(index))

func slot_summary(index: int) -> String:
	var info: Dictionary = _slot_info(index)
	return str(info.get("summary", "Vazio"))

func random_run_seed() -> int:
	return int((Time.get_unix_time_from_system() * 1000.0) + Time.get_ticks_msec()) % 2147483647

func _slot_info(index: int) -> Dictionary:
	var has_file: bool = has_save_file(index)
	var data: Dictionary = _load_slot_data(index)
	var exists: bool = not data.is_empty()
	var invalid: bool = has_file and not exists
	var summary: String = "Vazio"
	var player_label: String = ""
	var class_label: String = ""
	var map_name: String = ""
	if exists:
		var run_data: Dictionary = Dictionary(data.get("run", {}))
		player_label = str(run_data.get("player_name", RunSession.DEFAULT_PLAYER_NAME))
		class_label = str(run_data.get("selected_class_display_name", run_data.get("selected_class_id", "")))
		map_name = _node_display_name(str(run_data.get("current_node_id", "")))
		summary = "%s | %s | %s" % [player_label if player_label != "" else RunSession.DEFAULT_PLAYER_NAME, class_label if class_label != "" else "Classe desconhecida", map_name]
	elif invalid:
		summary = "Save antigo ou invalido"
	return {
		"index": index,
		"exists": exists,
		"has_file": has_file,
		"invalid": invalid,
		"selected": current_slot_index == index,
		"path": _slot_path(index),
		"summary": summary,
		"player_name": player_label,
		"class_name": class_label,
		"map_name": map_name,
		"data": data
	}

func _load_slot_data(index: int) -> Dictionary:
	if not _valid_slot(index):
		return {}
	var path: String = _slot_path(index)
	if not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var data: Dictionary = Dictionary(parsed)
	if int(data.get("version", 0)) != SAVE_VERSION:
		return {}
	return data

func _node_display_name(node_id: String) -> String:
	if node_id == "":
		return "Rota concluida"
	var run_map: Dictionary = ContentLibrary.get_run_map()
	var catalog = ContentLibrary.get_catalog()
	if catalog == null:
		return node_id
	for node: Dictionary in Array(run_map.get("nodes", [])):
		if str(node.get("id", "")) != node_id:
			continue
		var encounter_id: String = str(node.get("encounter_id", ""))
		var encounter: Dictionary = catalog.find_encounter(encounter_id)
		return str(encounter.get("display_name", node_id))
	return node_id

func _slot_path(index: int) -> String:
	return "%s%d.json" % [save_path_prefix, index]

func _valid_slot(index: int) -> bool:
	return index >= 1 and index <= SLOT_COUNT
